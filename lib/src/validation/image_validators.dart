

import '../models/image_item.dart';

/// Built-in validator factories for [ImageFormField] and [MultiImageFormField].
///
/// Each method returns a [FormFieldValidator]-compatible function
/// `String? Function(T?)` that you can compose or use standalone.
///
/// ## Single field usage
/// ```dart
/// ImageFormField(
///   validator: ImageValidators.compose([
///     ImageValidators.required(),
///     ImageValidators.maxFileSizeBytes(2 * 1024 * 1024), // 2 MB
///     ImageValidators.allowedExtensions(['jpg', 'png']),
///   ]),
/// )
/// ```
///
/// ## Multi field usage
/// ```dart
/// MultiImageFormField(
///   validator: ImageValidators.multi(
///     minCount: 1,
///     maxCount: 5,
///     perItem: ImageValidators.maxFileSizeBytes(5 * 1024 * 1024),
///   ),
/// )
/// ```
class ImageValidators {
  ImageValidators._();

  // ── Single Image Validators ───────────────────────────────────────────────

  /// Fails if the field is empty ([EmptyImageItem]).
  static String? Function(ImageItem?) required({
    String message = 'Please select an image.',
  }) {
    return (item) {
      if (item == null || item is EmptyImageItem) return message;
      return null;
    };
  }

  /// Fails if the picked local file exceeds [maxBytes].
  /// Network images are skipped — size is unknown without downloading.
  static String? Function(ImageItem?) maxFileSizeBytes(
    int maxBytes, {
    String? message,
  }) {
    return (item) {
      if (item is! LocalImageItem) return null;
      final file = item.file;
      if (!file.existsSync()) return null;
      final size = file.lengthSync();
      if (size > maxBytes) {
        final mb = (maxBytes / (1024 * 1024)).toStringAsFixed(1);
        return message ?? 'File size must not exceed $mb MB.';
      }
      return null;
    };
  }

  /// Fails if the picked local file has an extension not in [allowed].
  /// Extensions are compared case-insensitively without the dot.
  /// Network images are skipped.
  static String? Function(ImageItem?) allowedExtensions(
    List<String> allowed, {
    String? message,
  }) {
    final lower = allowed.map((e) => e.toLowerCase().replaceAll('.', '')).toSet();
    return (item) {
      if (item is! LocalImageItem) return null;
      final ext = item.file.path.split('.').last.toLowerCase();
      if (!lower.contains(ext)) {
        return message ??
            'Only ${lower.join(', ')} files are allowed.';
      }
      return null;
    };
  }

  /// Run a fully custom validation function.
  /// Return a non-null String to fail, null to pass.
  static String? Function(ImageItem?) custom(
    String? Function(ImageItem? item) validator,
  ) =>
      validator;

  /// Compose multiple single-image validators — runs all and returns
  /// the first error message, or null if all pass.
  static String? Function(ImageItem?) compose(
    List<String? Function(ImageItem?)> validators,
  ) {
    return (item) {
      for (final v in validators) {
        final error = v(item);
        if (error != null) return error;
      }
      return null;
    };
  }

  // ── Multi Image Validators ────────────────────────────────────────────────

  /// Validator for [MultiImageFormField].
  ///
  /// [minCount] — minimum number of images required.
  /// [maxCount] — maximum number of images allowed.
  /// [perItem]  — optional single-image validator applied to every item.
  static String? Function(List<ImageItem>?) multi({
    int minCount = 0,
    int? maxCount,
    String? Function(ImageItem?)? perItem,
    String? minMessage,
    String? maxMessage,
  }) {
    return (items) {
      final list = items ?? [];

      if (list.length < minCount) {
        return minMessage ?? 'Please add at least $minCount image(s).';
      }

      if (maxCount != null && list.length > maxCount) {
        return maxMessage ?? 'You can add at most $maxCount image(s).';
      }

      if (perItem != null) {
        for (var i = 0; i < list.length; i++) {
          final error = perItem(list[i]);
          if (error != null) return 'Image ${i + 1}: $error';
        }
      }

      return null;
    };
  }

  /// Convenience — required for multi: at least 1 image.
  static String? Function(List<ImageItem>?) multiRequired({
    String message = 'Please add at least one image.',
  }) =>
      multi(minCount: 1, minMessage: message);
}
