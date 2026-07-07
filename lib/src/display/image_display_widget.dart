import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config/image_field_config.dart';
import '../config/image_field_decoration.dart';
import '../models/image_item.dart';

/// Renders an [ImageItem] with the correct source widget
/// (network/local/placeholder) and clips it to the configured shape.
///
/// Used internally by [ImageFormField] and [MultiImageFormField].
/// Not intended for use outside this package — use the form fields directly.
class ImageDisplayWidget extends StatelessWidget {
  const ImageDisplayWidget({
    super.key,
    required this.item,
    required this.config,
    required this.decoration,
    this.width,
    this.height,
    this.isLoading = false,
  });

  final ImageItem item;
  final ImageFieldConfig config;
  final ImageFieldDecoration decoration;
  final double? width;
  final double? height;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ── Resolve size ────────────────────────────────────────────────────────
    final resolvedWidth = width ?? config.width;
    final resolvedHeight = height ?? config.height;

    Widget child = switch (item) {
      NetworkImageItem(:final url, :final headers) => _buildNetwork(
          context,
          url: url,
          headers: headers,
        ),
      LocalImageItem(:final file) => Image.file(
          file,
          fit: config.fit,
          width: resolvedWidth,
          height: resolvedHeight,
          errorBuilder: (_, _, _) => _buildError(context),
        ),
      EmptyImageItem() => _buildPlaceholder(context),
    };

    // ── Loading overlay ─────────────────────────────────────────────────────
    if (isLoading) {
      child = Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          Container(
            color: decoration.overlayColor ?? Colors.black26,
            alignment: Alignment.center,
            child: decoration.loadingWidget ??
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onPrimary,
                ),
          ),
        ],
      );
    }

    // ── Clip to shape ───────────────────────────────────────────────────────
    child = _clipToShape(child, resolvedWidth, resolvedHeight);

    // ── Background & border ─────────────────────────────────────────────────
    child = Container(
      width: resolvedWidth,
      height: resolvedHeight,
      decoration: BoxDecoration(
        color: decoration.backgroundColor ??
            theme.colorScheme.surfaceContainerHighest,
        shape: config.shape == ImageFieldShape.circle
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: config.shape == ImageFieldShape.circle
            ? null
            : _borderRadius(),
        border: decoration.border != null
            ? decoration.border as Border?
            : null,
      ),
      child: child,
    );

    return child;
  }

  // ── Network Image ─────────────────────────────────────────────────────────

  Widget _buildNetwork(
    BuildContext context, {
    required String url,
    Map<String, String>? headers,
  }) {
    if (config.enableCache) {
      return CachedNetworkImage(
        imageUrl: url,
        httpHeaders: headers,
        fit: config.fit,
        width: config.width,
        height: config.height,
        placeholder: (_, _) => decoration.loadingWidget ??
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (context, _, _) => _buildError(context),
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 200),
      );
    }

    return Image.network(
      url,
      headers: headers,
      fit: config.fit,
      width: config.width,
      height: config.height,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return decoration.loadingWidget ??
            const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
      errorBuilder: (context, _, _) => _buildError(context),
    );
  }

  // ── Placeholder & Error ───────────────────────────────────────────────────

  Widget _buildPlaceholder(BuildContext context) {
    return decoration.placeholder ??
        Center(
          child: Icon(
            Icons.camera_alt_outlined,
            size: 32,
            color: Theme.of(context).colorScheme.outline,
          ),
        );
  }

  Widget _buildError(BuildContext context) {
    return decoration.errorWidget ??
        Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 32,
            color: Theme.of(context).colorScheme.error,
          ),
        );
  }

  // ── Shape helpers ─────────────────────────────────────────────────────────

  Widget _clipToShape(Widget child, double? w, double? h) {
    return switch (config.shape) {
      ImageFieldShape.circle => ClipOval(child: child),
      ImageFieldShape.roundedRect => ClipRRect(
          borderRadius: BorderRadius.circular(config.borderRadius),
          child: child,
        ),
      ImageFieldShape.rectangle => ClipRect(child: child),
      ImageFieldShape.square => ClipRect(child: child),
    };
  }

  BorderRadius? _borderRadius() {
    return switch (config.shape) {
      ImageFieldShape.roundedRect =>
        BorderRadius.circular(config.borderRadius),
      _ => BorderRadius.zero,
    };
  }
}
