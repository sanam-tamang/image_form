import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

/// Shape of the displayed image and its clip boundary.
enum ImageFieldShape {
  /// Circular clip — ideal for avatars, profile pictures.
  circle,

  /// Rounded rectangle — ideal for thumbnails, logos, category images.
  roundedRect,

  /// Sharp rectangle — ideal for banners, certificates, wide covers.
  rectangle,

  /// Equal width and height square — ideal for category icons, app icons.
  square,
}

/// Where the edit icon overlay is anchored on the image.
enum EditIconPosition {
  bottomRight,
  bottomCenter,
  bottomLeft,
  topRight,
  topLeft,
  center,
}

/// Immutable configuration object for all behavioural options.
/// Pass this into [ImageFormField] or [MultiImageFormField].
///
/// All values have sensible defaults so you only override what you need:
/// ```dart
/// ImageFieldConfig(
///   shape: ImageFieldShape.circle,
///   enableCrop: true,
///   cropAspectRatio: CropAspectRatioPreset.square,
/// )
/// ```
class ImageFieldConfig {
  const ImageFieldConfig({
    this.shape = ImageFieldShape.circle,
    this.width,
    this.height,
    this.aspectRatio,
    this.borderRadius = 12.0,
    this.enableCrop = false,
    this.cropAspectRatio = CropAspectRatioPreset.original,
    this.cropStyle = CropStyle.rectangle,
    this.enableCache = true,
    this.cacheDuration = const Duration(days: 7),
    this.enableTapToView = true,
    this.enableEditOnTap = false,
    this.showEditIcon = true,
    this.editIconPosition = EditIconPosition.bottomRight,
    this.allowGallery = true,
    this.allowCamera = true,
    this.allowRemove = true,
    this.imageQuality = 85,
    this.maxFileSizeBytes,
    this.fit = BoxFit.cover,
  });

  // ── Shape & Layout ───────────────────────────────────────────────────────

  /// Visual shape and clip style of the image widget.
  final ImageFieldShape shape;

  /// Explicit width in logical pixels. If null, fills available width.
  final double? width;

  /// Explicit height in logical pixels. If null, derived from aspectRatio
  /// or falls back to width (square).
  final double? height;

  /// Aspect ratio (width / height). Applied when height is not explicit.
  /// Example: 16/9 for video thumbnails, 1.0 for square, 3/4 for portrait.
  final double? aspectRatio;

  /// Corner radius used when shape is [ImageFieldShape.roundedRect].
  final double borderRadius;

  // ── Crop ─────────────────────────────────────────────────────────────────

  /// Whether to open image_cropper after the user picks an image.
  final bool enableCrop;

  /// Aspect ratio preset passed to image_cropper.
  /// Only relevant when [enableCrop] is true.
  final CropAspectRatioPreset cropAspectRatio;

  /// Circle or rectangle crop overlay style.
  /// Only relevant when [enableCrop] is true.
  final CropStyle cropStyle;

  // ── Cache ─────────────────────────────────────────────────────────────────

  /// Use CachedNetworkImage + flutter_cache_manager for network images.
  /// Set false to use plain Image.network with no on-disk caching.
  final bool enableCache;

  /// How long cached network images are kept before re-fetching.
  final Duration cacheDuration;

  // ── Interaction ───────────────────────────────────────────────────────────

  /// Tap on the image (not the edit icon) opens a full-screen viewer.
  final bool enableTapToView;

  /// Tap anywhere on the image (not just the edit icon) opens the picker.
  /// When true, [enableTapToView] is overridden — the whole surface picks.
  final bool enableEditOnTap;

  /// Show the edit icon overlay.
  final bool showEditIcon;

  /// Where the edit icon is anchored.
  final EditIconPosition editIconPosition;

  // ── Picker ────────────────────────────────────────────────────────────────

  /// Show "Gallery" option in the source bottom sheet.
  final bool allowGallery;

  /// Show "Camera" option in the source bottom sheet.
  final bool allowCamera;

  /// Show "Remove" option in the source bottom sheet.
  final bool allowRemove;

  /// JPEG compression quality (0–100) passed to image_picker.
  final int imageQuality;

  /// Maximum allowed file size in bytes. null means no limit.
  /// The built-in [ImageValidators.maxFileSizeBytes] uses this too.
  final int? maxFileSizeBytes;

  // ── Display ───────────────────────────────────────────────────────────────

  /// How the image is fitted inside its bounds.
  final BoxFit fit;

  // ── copyWith ─────────────────────────────────────────────────────────────

  ImageFieldConfig copyWith({
    ImageFieldShape? shape,
    double? width,
    double? height,
    double? aspectRatio,
    double? borderRadius,
    bool? enableCrop,
    CropAspectRatioPreset? cropAspectRatio,
    CropStyle? cropStyle,
    bool? enableCache,
    Duration? cacheDuration,
    bool? enableTapToView,
    bool? enableEditOnTap,
    bool? showEditIcon,
    EditIconPosition? editIconPosition,
    bool? allowGallery,
    bool? allowCamera,
    bool? allowRemove,
    int? imageQuality,
    int? maxFileSizeBytes,
    BoxFit? fit,
  }) {
    return ImageFieldConfig(
      shape: shape ?? this.shape,
      width: width ?? this.width,
      height: height ?? this.height,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      borderRadius: borderRadius ?? this.borderRadius,
      enableCrop: enableCrop ?? this.enableCrop,
      cropAspectRatio: cropAspectRatio ?? this.cropAspectRatio,
      cropStyle: cropStyle ?? this.cropStyle,
      enableCache: enableCache ?? this.enableCache,
      cacheDuration: cacheDuration ?? this.cacheDuration,
      enableTapToView: enableTapToView ?? this.enableTapToView,
      enableEditOnTap: enableEditOnTap ?? this.enableEditOnTap,
      showEditIcon: showEditIcon ?? this.showEditIcon,
      editIconPosition: editIconPosition ?? this.editIconPosition,
      allowGallery: allowGallery ?? this.allowGallery,
      allowCamera: allowCamera ?? this.allowCamera,
      allowRemove: allowRemove ?? this.allowRemove,
      imageQuality: imageQuality ?? this.imageQuality,
      maxFileSizeBytes: maxFileSizeBytes ?? this.maxFileSizeBytes,
      fit: fit ?? this.fit,
    );
  }
}
