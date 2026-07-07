import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import '../config/image_field_config.dart';

/// Thin wrapper around image_cropper.
/// Returns null when the user cancels cropping.
class ImageCropService {
  const ImageCropService();

  /// Open the crop UI for [file] using options from [config].
  /// Returns the cropped [File] or null if cancelled.
  Future<File?> crop({
    required File file,
    required BuildContext context,
    required ImageFieldConfig config,
    String? toolbarTitle,
    Color? toolbarColor,
    Color? toolbarWidgetColor,
  }) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,

      uiSettings: [
        AndroidUiSettings(
          cropStyle: config.cropStyle,
          toolbarTitle: toolbarTitle ?? 'Crop Image',
          toolbarColor: toolbarColor ?? Theme.of(context).primaryColor,
          toolbarWidgetColor: toolbarWidgetColor ?? Colors.white,
          initAspectRatio: _toAndroidPreset(config.cropAspectRatio),
          lockAspectRatio:
              config.cropAspectRatio != CropAspectRatioPreset.original,
          aspectRatioPresets: _allPresets(),
          hideBottomControls: false,
        ),
        IOSUiSettings(
          cropStyle: config.cropStyle,
          title: toolbarTitle ?? 'Crop Image',
          aspectRatioPresets: _allPresets(),
          doneButtonTitle: 'Done',
          cancelButtonTitle: 'Cancel',
          resetButtonHidden: false,
        ),
        WebUiSettings(context: context),
      ],
    );

    if (cropped == null) return null;
    return File(cropped.path);
  }

  CropAspectRatioPreset _toAndroidPreset(CropAspectRatioPreset preset) =>
      preset;

  List<CropAspectRatioPreset> _allPresets() => [
    CropAspectRatioPreset.original,
    CropAspectRatioPreset.square,
    CropAspectRatioPreset.ratio3x2,
    CropAspectRatioPreset.ratio4x3,
    CropAspectRatioPreset.ratio16x9,
  ];
}
