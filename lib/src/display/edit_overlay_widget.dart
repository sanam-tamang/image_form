import 'package:flutter/material.dart';

import '../config/image_field_config.dart';
import '../config/image_field_decoration.dart';

/// Positions an edit icon over the image using a [Stack] + [Positioned].
/// The icon position is driven by [EditIconPosition] from [ImageFieldConfig].
class EditOverlayWidget extends StatelessWidget {
  const EditOverlayWidget({
    super.key,
    required this.config,
    required this.decoration,
    required this.onTap,
    this.enabled = true,
  });

  final ImageFieldConfig config;
  final ImageFieldDecoration decoration;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!config.showEditIcon || !enabled) return const SizedBox.shrink();

    final icon = _buildIcon(context);
    final positioned = _applyPosition(icon);

    return positioned;
  }

  Widget _buildIcon(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: decoration.editIconPadding,
        decoration: BoxDecoration(
          color: decoration.editIconBackgroundColor ?? Colors.black54,
          borderRadius: BorderRadius.circular(decoration.editIconBorderRadius),
        ),
        child:
            decoration.editIcon ??
            const Icon(Icons.camera_alt, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _applyPosition(Widget icon) {
    const offset = 4.0;

    return switch (config.editIconPosition) {
      EditIconPosition.bottomRight => Positioned(
        bottom: offset,
        right: offset,
        child: icon,
      ),
      EditIconPosition.bottomCenter => Positioned(
        bottom: offset,
        left: 0,
        right: 0,
        child: Center(child: icon),
      ),
      EditIconPosition.bottomLeft => Positioned(
        bottom: offset,
        left: offset,
        child: icon,
      ),
      EditIconPosition.topRight => Positioned(
        top: offset,
        right: offset,
        child: icon,
      ),
      EditIconPosition.topLeft => Positioned(
        top: offset,
        left: offset,
        child: icon,
      ),
      EditIconPosition.center => Positioned.fill(child: Center(child: icon)),
    };
  }
}
