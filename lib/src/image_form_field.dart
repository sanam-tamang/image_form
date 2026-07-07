import 'package:flutter/material.dart';

import 'config/image_field_config.dart';
import 'config/image_field_decoration.dart';
import 'controller/image_field_controller.dart';
import 'display/edit_overlay_widget.dart';
import 'display/image_display_widget.dart';
import 'display/image_viewer_page.dart';
import 'models/image_item.dart';
import 'picker/image_crop_service.dart';
import 'picker/image_picker_service.dart';
import 'picker/image_source_sheet.dart';

/// A fully-featured Flutter [FormField] for a single image.
///
/// Works like any Flutter form field — plug it into a [Form], call
/// [FormState.validate], [FormState.save], and [FormState.reset].
///
/// ## Minimal usage
/// ```dart
/// ImageFormField(
///   initialUrl: 'https://example.com/photo.jpg',
///   onChanged: (item) => print(item),
/// )
/// ```
///
/// ## With controller
/// ```dart
/// final controller = ImageFieldController(
///   initialItem: NetworkImageItem(url: 'https://example.com/photo.jpg'),
/// );
///
/// ImageFormField(
///   controller: controller,
///   config: ImageFieldConfig(
///     shape: ImageFieldShape.circle,
///     enableCrop: true,
///     cropAspectRatio: CropAspectRatioPreset.square,
///   ),
///   validator: ImageValidators.required(),
/// )
/// ```
///
/// ## With validation
/// ```dart
/// ImageFormField(
///   validator: ImageValidators.compose([
///     ImageValidators.required(),
///     ImageValidators.maxFileSizeBytes(2 * 1024 * 1024),
///   ]),
/// )
/// ```
class ImageFormField extends FormField<ImageItem> {
  ImageFormField({
    super.key,

    // ── Controller / initial value ─────────────────────────────────────────
    this.controller,
    String? initialUrl,
    ImageItem? initialItem,

    // ── Config & decoration ────────────────────────────────────────────────
    this.config = const ImageFieldConfig(),
    this.decoration = const ImageFieldDecoration(),

    // ── Form field standard params ─────────────────────────────────────────
    super.validator,
    super.autovalidateMode = AutovalidateMode.disabled,
    super.enabled = true,
    ValueChanged<ImageItem?>? onChanged,
    super.onSaved,

    // ── Services (injectable for testing) ──────────────────────────────────
    ImagePickerService? pickerService,
    ImageCropService? cropService,
  }) : assert(
         controller == null || initialItem == null,
         'Provide either controller or initialItem, not both.',
       ),
       assert(
         controller == null || initialUrl == null,
         'Provide either controller or initialUrl, not both.',
       ),
       super(
         initialValue:
             controller?.value ??
             initialItem ??
             (initialUrl != null
                 ? NetworkImageItem(url: initialUrl)
                 : const EmptyImageItem()),
         builder: (FormFieldState<ImageItem> state) {
           return _ImageFormFieldBody(
             state: state,
             controller: controller,
             config: config,
             decoration: decoration,
             onChanged: onChanged,
             pickerService: pickerService ?? ImagePickerService(),
             cropService: cropService ?? const ImageCropService(),
           );
         },
       );

  final ImageFieldController? controller;
  final ImageFieldConfig config;
  final ImageFieldDecoration decoration;

  @override
  FormFieldState<ImageItem> createState() => _ImageFormFieldState();
}

// ── State ─────────────────────────────────────────────────────────────────────

class _ImageFormFieldState extends FormFieldState<ImageItem> {
  ImageFormField get _field => widget as ImageFormField;

  @override
  void initState() {
    super.initState();
    _field.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(ImageFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_field.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      _field.controller?.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    _field.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    // Sync FormFieldState value with controller whenever controller changes.
    final controllerValue = _field.controller?.value;
    if (controllerValue != value) {
      didChange(controllerValue);
    }
  }

  @override
  void didChange(ImageItem? value) {
    super.didChange(value);
    // Sync back to controller if present and out of sync.
    final controller = _field.controller;
    if (controller != null && controller.value != value) {
      if (value is NetworkImageItem) {
        controller.setNetworkUrl(value.url, headers: value.headers);
      } else if (value is LocalImageItem) {
        controller.setLocalFile(value.file);
      } else {
        controller.clear();
      }
    }
  }

  @override
  void reset() {
    super.reset();
    _field.controller?.reset();
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _ImageFormFieldBody extends StatefulWidget {
  const _ImageFormFieldBody({
    required this.state,
    required this.controller,
    required this.config,
    required this.decoration,
    required this.pickerService,
    required this.cropService,
    this.onChanged,
  });

  final FormFieldState<ImageItem> state;
  final ImageFieldController? controller;
  final ImageFieldConfig config;
  final ImageFieldDecoration decoration;
  final ValueChanged<ImageItem?>? onChanged;
  final ImagePickerService pickerService;
  final ImageCropService cropService;

  @override
  State<_ImageFormFieldBody> createState() => _ImageFormFieldBodyState();
}

class _ImageFormFieldBodyState extends State<_ImageFormFieldBody> {
  bool _isLoading = false;

  // Convenience getters
  FormFieldState<ImageItem> get _state => widget.state;
  ImageFieldConfig get _config => widget.config;
  ImageFieldDecoration get _decoration => widget.decoration;
  ImageItem get _currentItem => _state.value ?? const EmptyImageItem();
  bool get _enabled => _state.widget.enabled;

  // Unique hero tag per field instance
  final Object _heroTag = Object();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = _state.hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Optional label ───────────────────────────────────────────────────
        if (_decoration.label != null) ...[
          DefaultTextStyle(
            style:
                _decoration.labelStyle ??
                theme.textTheme.bodyMedium!.copyWith(
                  color: hasError
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface,
                ),
            child: _decoration.label!,
          ),
          const SizedBox(height: 6),
        ],

        // ── Image widget ─────────────────────────────────────────────────────
        Padding(
          padding: _decoration.contentPadding,
          child: _buildImageStack(context, hasError),
        ),

        // ── Helper text ──────────────────────────────────────────────────────
        if (_decoration.helperText != null && !hasError) ...[
          const SizedBox(height: 4),
          Text(
            _decoration.helperText!,
            style:
                _decoration.helperStyle ??
                theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
          ),
        ],

        // ── Error text ───────────────────────────────────────────────────────
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            _state.errorText!,
            style:
                _decoration.errorStyle ??
                theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageStack(BuildContext context, bool hasError) {
    // Resolve dimensions
    final width = _config.width;
    final height =
        _config.height ??
        (width != null && _config.aspectRatio != null
            ? width / _config.aspectRatio!
            : width);

    // Error border override
    final effectiveBorder = hasError
        ? (_decoration.errorBorder ??
              Border.all(
                color: Theme.of(context).colorScheme.error,
                width: 1.5,
              ))
        : _decoration.border;

    final display = ImageDisplayWidget(
      item: _currentItem,
      config: _config,
      decoration: _decoration.copyWith(border: effectiveBorder),
      width: width,
      height: height,
      isLoading: _isLoading,
    );

    final stack = Stack(
      clipBehavior: Clip.none,
      children: [
        // Hero wrap for tap-to-view animation
        Hero(tag: _heroTag, child: display),

        // Edit icon overlay
        EditOverlayWidget(
          config: _config,
          decoration: _decoration,
          onTap: _enabled ? _onEditTapped : () {},
          enabled: _enabled,
        ),
      ],
    );

    // Tap gesture
    return GestureDetector(
      onTap: _enabled
          ? (_config.enableEditOnTap
                ? _onEditTapped
                : (_config.enableTapToView && _currentItem.hasImage
                      ? _onImageTapped
                      : null))
          : null,
      child: stack,
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _onEditTapped() async {
    if (!mounted) return;

    // 1. Show source bottom sheet
    final sheetResult = await ImageSourceSheet.show(
      context: context,
      config: _config,
      currentItem: _currentItem,
    );

    if (!mounted) return;

    switch (sheetResult) {
      case SourceDismissed():
        return;

      case SourceRemove():
        _updateItem(const EmptyImageItem());
        return;

      case SourceSelected(:final source):
        // 2. Pick image
        setState(() => _isLoading = true);
        widget.controller?.setLoading(true);

        final pickResult = await widget.pickerService.pick(
          source: source,
          imageQuality: _config.imageQuality,
        );

        if (!mounted) return;

        switch (pickResult) {
          case PickCancelled():
            setState(() => _isLoading = false);
            widget.controller?.setLoading(false);
            return;

          case PickError(:final message):
            setState(() => _isLoading = false);
            widget.controller?.setError(message);
            _showError(message);
            return;

          case PickSuccess(:final file):
            var finalFile = file;

            // 3. Crop if enabled
            if (_config.enableCrop && mounted) {
              final cropped = await widget.cropService.crop(
                file: file,
                context: context,
                config: _config,
              );
              // null means user cancelled crop — keep original
              if (cropped != null) finalFile = cropped;
            }

            if (!mounted) return;
            _updateItem(LocalImageItem(file: finalFile));
        }
    }
  }

  void _onImageTapped() {
    if (!_currentItem.hasImage) return;
    ImageViewerPage.show(context, item: _currentItem, heroTag: _heroTag);
  }

  void _updateItem(ImageItem item) {
    setState(() => _isLoading = false);
    _state.didChange(item);
    widget.onChanged?.call(item);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
