import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/image_item.dart';

/// Full-screen image viewer opened when [enableTapToView] is true.
/// Supports swipe-down to dismiss and a Hero animation keyed by [heroTag].
class ImageViewerPage extends StatelessWidget {
  const ImageViewerPage({super.key, required this.item, this.heroTag});

  final ImageItem item;
  final Object? heroTag;

  /// Push this page onto the navigator.
  static void show(
    BuildContext context, {
    required ImageItem item,
    Object? heroTag,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        pageBuilder: (_, _, _) => ImageViewerPage(item: item, heroTag: heroTag),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: GestureDetector(
            onTap: () {}, // prevent dismiss on image tap
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: heroTag != null
                  ? Hero(tag: heroTag!, child: _buildImage(context))
                  : _buildImage(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return switch (item) {
      NetworkImageItem(:final url, :final headers) => CachedNetworkImage(
        imageUrl: url,
        httpHeaders: headers,
        fit: BoxFit.contain,
        placeholder: (_, _) =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        errorWidget: (_, _, _) => const Icon(
          Icons.broken_image_outlined,
          color: Colors.white54,
          size: 48,
        ),
      ),
      LocalImageItem(:final file) => Image.file(
        file,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Icon(
          Icons.broken_image_outlined,
          color: Colors.white54,
          size: 48,
        ),
      ),
      EmptyImageItem() => const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.white54,
        size: 48,
      ),
    };
  }
}
