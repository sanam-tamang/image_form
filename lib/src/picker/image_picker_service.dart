import 'dart:io';

import 'package:image_picker/image_picker.dart';

/// Result from [ImagePickerService.pick].
sealed class PickResult {}

/// User picked an image successfully.
final class PickSuccess extends PickResult {
  PickSuccess(this.file);
  final File file;
}

/// User cancelled the picker without selecting anything.
final class PickCancelled extends PickResult {}

/// The picker threw an error (permissions denied, etc).
final class PickError extends PickResult {
  PickError(this.message);
  final String message;
}

/// Result from [ImagePickerService.pickMultiple].
sealed class MultiPickResult {}

final class MultiPickSuccess extends MultiPickResult {
  MultiPickSuccess(this.files);
  final List<File> files;
}

final class MultiPickCancelled extends MultiPickResult {}

final class MultiPickError extends MultiPickResult {
  MultiPickError(this.message);
  final String message;
}

/// Thin, testable wrapper around the image_picker package.
///
/// Inject a custom instance during tests to mock file picking without
/// real device hardware.
class ImagePickerService {
  ImagePickerService({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Pick a single image from [source].
  /// Returns [PickSuccess], [PickCancelled], or [PickError].
  Future<PickResult> pick({
    required ImageSource source,
    int imageQuality = 85,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      final xFile = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (xFile == null) return PickCancelled();
      return PickSuccess(File(xFile.path));
    } catch (e) {
      return PickError(_errorMessage(e));
    }
  }

  /// Pick multiple images from the gallery at once.
  Future<MultiPickResult> pickMultiple({
    int imageQuality = 85,
    double? maxWidth,
    double? maxHeight,
    int? limit,
  }) async {
    try {
      final xFiles = await _picker.pickMultiImage(
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        limit: limit,
      );

      if (xFiles.isEmpty) return MultiPickCancelled();
      return MultiPickSuccess(xFiles.map((x) => File(x.path)).toList());
    } catch (e) {
      return MultiPickError(_errorMessage(e));
    }
  }

  String _errorMessage(Object e) {
    final msg = e.toString();
    if (msg.contains('photo_access_denied') ||
        msg.contains('camera_access_denied')) {
      return 'Permission denied. Please allow access in Settings.';
    }
    return 'Could not pick image. Please try again.';
  }
}
