import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../config/image_field_config.dart';
import '../models/image_item.dart';

/// Result returned from [ImageSourceSheet.show].
sealed class SourceSheetResult {}

/// User selected gallery or camera.
final class SourceSelected extends SourceSheetResult {
  SourceSelected(this.source);
  final ImageSource source;
}

/// User tapped "Remove image".
final class SourceRemove extends SourceSheetResult {}

/// User dismissed without selecting.
final class SourceDismissed extends SourceSheetResult {}

/// A modal bottom sheet that lets the user choose between gallery,
/// camera, and remove actions. Respects [ImageFieldConfig] flags
/// to show or hide each option.
class ImageSourceSheet {
  const ImageSourceSheet._();

  /// Show the source sheet and return a [SourceSheetResult].
  static Future<SourceSheetResult> show({
    required BuildContext context,
    required ImageFieldConfig config,
    required ImageItem currentItem,
  }) async {
    final result = await showModalBottomSheet<SourceSheetResult>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) =>
          _SourceSheetContent(config: config, currentItem: currentItem),
    );
    return result ?? SourceDismissed();
  }
}

class _SourceSheetContent extends StatelessWidget {
  const _SourceSheetContent({required this.config, required this.currentItem});

  final ImageFieldConfig config;
  final ImageItem currentItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ────────────────────────────────────────────────
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: colorScheme.outline.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── Title ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  currentItem.hasImage ? 'Change image' : 'Add image',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

            const Divider(height: 16),

            // ── Gallery ────────────────────────────────────────────────────
            if (config.allowGallery)
              _SheetTile(
                icon: Icons.photo_library_outlined,
                label: 'Choose from gallery',
                onTap: () =>
                    Navigator.pop(context, SourceSelected(ImageSource.gallery)),
              ),

            // ── Camera ─────────────────────────────────────────────────────
            if (config.allowCamera)
              _SheetTile(
                icon: Icons.camera_alt_outlined,
                label: 'Take a photo',
                onTap: () =>
                    Navigator.pop(context, SourceSelected(ImageSource.camera)),
              ),

            // ── Remove ─────────────────────────────────────────────────────
            if (config.allowRemove && currentItem.hasImage) ...[
              const Divider(height: 8),
              _SheetTile(
                icon: Icons.delete_outline,
                label: 'Remove image',
                color: colorScheme.error,
                onTap: () => Navigator.pop(context, SourceRemove()),
              ),
            ],

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: effectiveColor, size: 22),
      title: Text(label, style: TextStyle(color: effectiveColor, fontSize: 15)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}
