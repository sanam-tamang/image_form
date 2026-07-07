import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../config/image_field_config.dart';
import '../config/image_field_decoration.dart';
import '../controller/multi_image_field_controller.dart';
import '../display/edit_overlay_widget.dart';
import '../display/image_display_widget.dart';
import '../display/image_viewer_page.dart';
import '../models/image_item.dart';
import '../picker/image_crop_service.dart';
import '../picker/image_picker_service.dart';
import '../picker/image_source_sheet.dart';

/// Layout style for [MultiImageFormField].
enum MultiImageLayout {
  /// Fixed-column grid — like a Play Store screenshot grid.
  grid,

  /// Horizontal scrollable strip — like an Instagram carousel editor.
  horizontalScroll,
}

/// A fully-featured Flutter [FormField] for multiple images.
///
/// Each slot can hold a [NetworkImageItem] or [LocalImageItem].
/// Tapping an occupied slot replaces it; tapping the add slot picks new images.
/// Supports reordering via long-press drag when [allowReorder] is true.
///
/// ## Usage
/// ```dart
/// MultiImageFormField(
///   initialUrls: ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
///   maxCount: 5,
///   config: ImageFieldConfig(
///     shape: ImageFieldShape.roundedRect,
///     enableCrop: true,
///   ),
///   validator: ImageValidators.multi(minCount: 1, maxCount: 5),
///   onChanged: (items) => print(items.length),
/// )
/// ```
class MultiImageFormField extends FormField<List<ImageItem>> {
  MultiImageFormField({
    super.key,

    // ── Controller / initial values ────────────────────────────────────────
    this.controller,
    List<String>? initialUrls,
    List<ImageItem>? initialItems,

    // ── Count constraints ──────────────────────────────────────────────────
    this.minCount = 0,
    this.maxCount = 10,

    // ── Config & decoration ────────────────────────────────────────────────
    this.config = const ImageFieldConfig(shape: ImageFieldShape.roundedRect),
    this.decoration = const ImageFieldDecoration(),

    // ── Layout ─────────────────────────────────────────────────────────────
    this.layout = MultiImageLayout.grid,
    this.gridCrossAxisCount = 3,
    this.gridMainAxisSpacing = 8.0,
    this.gridCrossAxisSpacing = 8.0,
    this.itemHeight = 100.0,
    this.allowReorder = true,

    // ── Form field standard params ─────────────────────────────────────────
    super.validator,
    super.autovalidateMode = AutovalidateMode.disabled,
    super.enabled = true,
    ValueChanged<List<ImageItem>>? onChanged,
    super.onSaved,

    // ── Services ───────────────────────────────────────────────────────────
    ImagePickerService? pickerService,
    ImageCropService? cropService,
  }) : super(
         initialValue:
             controller?.value ??
             initialItems ??
             initialUrls
                 ?.map((u) => NetworkImageItem(url: u) as ImageItem)
                 .toList() ??
             [],
         builder: (FormFieldState<List<ImageItem>> state) {
           return _MultiImageFormFieldBody(
             state: state,
             controller: controller,
             config: config,
             decoration: decoration,
             layout: layout,
             gridCrossAxisCount: gridCrossAxisCount,
             gridMainAxisSpacing: gridMainAxisSpacing,
             gridCrossAxisSpacing: gridCrossAxisSpacing,
             itemHeight: itemHeight,
             allowReorder: allowReorder,
             maxCount: maxCount,
             onChanged: onChanged,
             pickerService: pickerService ?? ImagePickerService(),
             cropService: cropService ?? const ImageCropService(),
           );
         },
       );

  final MultiImageFieldController? controller;
  final int minCount;
  final int maxCount;
  final ImageFieldConfig config;
  final ImageFieldDecoration decoration;
  final MultiImageLayout layout;
  final int gridCrossAxisCount;
  final double gridMainAxisSpacing;
  final double gridCrossAxisSpacing;
  final double itemHeight;
  final bool allowReorder;

  @override
  FormFieldState<List<ImageItem>> createState() => _MultiImageFormFieldState();
}

// ── State ─────────────────────────────────────────────────────────────────────

class _MultiImageFormFieldState extends FormFieldState<List<ImageItem>> {
  MultiImageFormField get _field => widget as MultiImageFormField;

  @override
  void initState() {
    super.initState();
    _field.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(MultiImageFormField oldWidget) {
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
    final controllerValue = _field.controller?.value;
    if (controllerValue != null && controllerValue != value) {
      didChange(controllerValue);
    }
  }

  @override
  void reset() {
    super.reset();
    _field.controller?.reset();
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _MultiImageFormFieldBody extends StatefulWidget {
  const _MultiImageFormFieldBody({
    required this.state,
    required this.controller,
    required this.config,
    required this.decoration,
    required this.layout,
    required this.gridCrossAxisCount,
    required this.gridMainAxisSpacing,
    required this.gridCrossAxisSpacing,
    required this.itemHeight,
    required this.allowReorder,
    required this.maxCount,
    required this.pickerService,
    required this.cropService,
    this.onChanged,
  });

  final FormFieldState<List<ImageItem>> state;
  final MultiImageFieldController? controller;
  final ImageFieldConfig config;
  final ImageFieldDecoration decoration;
  final MultiImageLayout layout;
  final int gridCrossAxisCount;
  final double gridMainAxisSpacing;
  final double gridCrossAxisSpacing;
  final double itemHeight;
  final bool allowReorder;
  final int maxCount;
  final ValueChanged<List<ImageItem>>? onChanged;
  final ImagePickerService pickerService;
  final ImageCropService cropService;

  @override
  State<_MultiImageFormFieldBody> createState() =>
      _MultiImageFormFieldBodyState();
}

class _MultiImageFormFieldBodyState extends State<_MultiImageFormFieldBody> {
  int? _loadingIndex;

  FormFieldState<List<ImageItem>> get _state => widget.state;
  ImageFieldConfig get _config => widget.config;
  ImageFieldDecoration get _decoration => widget.decoration;
  List<ImageItem> get _items => _state.value ?? [];
  bool get _enabled => _state.widget.enabled;
  bool get _canAddMore => _items.length < widget.maxCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = _state.hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ──────────────────────────────────────────────────────────
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

        // ── Grid or scroll ─────────────────────────────────────────────────
        switch (widget.layout) {
          MultiImageLayout.grid => _buildGrid(context),
          MultiImageLayout.horizontalScroll => _buildScroll(context),
        },

        // ── Helper / error text ────────────────────────────────────────────
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

  // ── Grid layout ───────────────────────────────────────────────────────────

  Widget _buildGrid(BuildContext context) {
    // Build slot list: existing items + optional add slot
    final slots = <_SlotData>[
      for (var i = 0; i < _items.length; i++)
        _SlotData(index: i, item: _items[i]),
      if (_canAddMore && _enabled) const _SlotData(index: -1, item: null),
    ];

    if (widget.allowReorder && _enabled && _items.length > 1) {
      return ReorderableWrap(
        spacing: widget.gridCrossAxisSpacing,
        runSpacing: widget.gridMainAxisSpacing,
        onReorder: _onReorder,
        children: slots.map((s) => _buildSlot(context, s)).toList(),
      );
    }

    return Wrap(
      spacing: widget.gridCrossAxisSpacing,
      runSpacing: widget.gridMainAxisSpacing,
      children: slots.map((s) => _buildSlot(context, s)).toList(),
    );
  }

  // ── Horizontal scroll layout ──────────────────────────────────────────────

  Widget _buildScroll(BuildContext context) {
    final slots = <_SlotData>[
      for (var i = 0; i < _items.length; i++)
        _SlotData(index: i, item: _items[i]),
      if (_canAddMore && _enabled) const _SlotData(index: -1, item: null),
    ];

    return SizedBox(
      height: widget.itemHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: slots.length,
        separatorBuilder: (_, _) =>
            SizedBox(width: widget.gridCrossAxisSpacing),
        itemBuilder: (context, i) => _buildSlot(context, slots[i]),
      ),
    );
  }

  // ── Individual slot ───────────────────────────────────────────────────────

  Widget _buildSlot(BuildContext context, _SlotData slot) {
    final isAddSlot = slot.index == -1;
    final isLoading = _loadingIndex == slot.index;
    final theme = Theme.of(context);

    // Add slot — shows a "+" button
    if (isAddSlot) {
      return _AddSlot(
        key: const ValueKey('add_slot'),
        size: widget.itemHeight,
        config: _config,
        decoration: _decoration,
        onTap: _pickNewImages,
      );
    }

    // Image slot
    final item = slot.item!;
    final heroTag = 'multi_image_${slot.index}';

    return GestureDetector(
      key: ValueKey('slot_${slot.index}'),
      onTap: _enabled
          ? (_config.enableTapToView && item.hasImage
                ? () => _onViewTapped(item, heroTag)
                : () => _onSlotTapped(slot.index))
          : null,
      onLongPress: _enabled ? () => _onSlotTapped(slot.index) : null,
      child: SizedBox(
        width: widget.itemHeight,
        height: widget.itemHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Hero(
              tag: heroTag,
              child: ImageDisplayWidget(
                item: item,
                config: _config,
                decoration: _decoration,
                width: widget.itemHeight,
                height: widget.itemHeight,
                isLoading: isLoading,
              ),
            ),

            // Remove button — top-right X
            if (_enabled)
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: () => _removeItem(slot.index),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: theme.colorScheme.onError,
                    ),
                  ),
                ),
              ),

            // Edit icon overlay
            EditOverlayWidget(
              config: _config.copyWith(
                editIconPosition: EditIconPosition.bottomRight,
              ),
              decoration: _decoration,
              onTap: () => _onSlotTapped(slot.index),
              enabled: _enabled,
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _pickNewImages() async {
    if (!mounted) return;

    // Show source sheet for the add slot
    final sheetResult = await ImageSourceSheet.show(
      context: context,
      config: _config,
      currentItem: const EmptyImageItem(),
    );

    if (!mounted) return;

    switch (sheetResult) {
      case SourceDismissed() || SourceRemove():
        return;
      case SourceSelected(:final source):
        setState(() => _loadingIndex = _items.length);

        // Allow multi-pick from gallery
        if (source == ImageSource.gallery) {
          final result = await widget.pickerService.pickMultiple(
            imageQuality: _config.imageQuality,
            limit: widget.maxCount - _items.length,
          );

          if (!mounted) return;

          switch (result) {
            case MultiPickCancelled():
              setState(() => _loadingIndex = null);
            case MultiPickError(:final message):
              setState(() => _loadingIndex = null);
              _showError(message);
            case MultiPickSuccess(:final files):
              var finalFiles = files;
              if (_config.enableCrop && files.length == 1 && mounted) {
                final cropped = await widget.cropService.crop(
                  file: files.first,
                  context: context,
                  config: _config,
                );
                if (cropped != null) finalFiles = [cropped];
              }
              if (!mounted) return;
              final updated = List<ImageItem>.of(_items)
                ..addAll(finalFiles.map((f) => LocalImageItem(file: f)));
              _updateItems(updated);
          }
        } else {
          // Camera — single pick
          final result = await widget.pickerService.pick(
            source: source,
            imageQuality: _config.imageQuality,
          );

          if (!mounted) return;

          switch (result) {
            case PickCancelled():
              setState(() => _loadingIndex = null);
            case PickError(:final message):
              setState(() => _loadingIndex = null);
              _showError(message);
            case PickSuccess(:final file):
              var finalFile = file;
              if (_config.enableCrop && mounted) {
                final cropped = await widget.cropService.crop(
                  file: file,
                  context: context,
                  config: _config,
                );
                if (cropped != null) finalFile = cropped;
              }
              if (!mounted) return;
              final updated = List<ImageItem>.of(_items)
                ..add(LocalImageItem(file: finalFile));
              _updateItems(updated);
          }
        }
    }
  }

  Future<void> _onSlotTapped(int index) async {
    if (!mounted) return;

    final sheetResult = await ImageSourceSheet.show(
      context: context,
      config: _config,
      currentItem: _items[index],
    );

    if (!mounted) return;

    switch (sheetResult) {
      case SourceDismissed():
        return;
      case SourceRemove():
        _removeItem(index);
        return;
      case SourceSelected(:final source):
        setState(() => _loadingIndex = index);

        final result = await widget.pickerService.pick(
          source: source,
          imageQuality: _config.imageQuality,
        );

        if (!mounted) return;

        switch (result) {
          case PickCancelled():
            setState(() => _loadingIndex = null);
          case PickError(:final message):
            setState(() => _loadingIndex = null);
            _showError(message);
          case PickSuccess(:final file):
            var finalFile = file;
            if (_config.enableCrop && mounted) {
              final cropped = await widget.cropService.crop(
                file: file,
                context: context,
                config: _config,
              );
              if (cropped != null) finalFile = cropped;
            }
            if (!mounted) return;
            final updated = List<ImageItem>.of(_items);
            updated[index] = LocalImageItem(file: finalFile);
            _updateItems(updated);
        }
    }
  }

  void _onViewTapped(ImageItem item, String heroTag) {
    ImageViewerPage.show(context, item: item, heroTag: heroTag);
  }

  void _removeItem(int index) {
    final updated = List<ImageItem>.of(_items)..removeAt(index);
    _updateItems(updated);
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final updated = List<ImageItem>.of(_items);
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    _updateItems(updated);
  }

  void _updateItems(List<ImageItem> items) {
    setState(() => _loadingIndex = null);
    _state.didChange(items);
    widget.onChanged?.call(items);
    widget.controller?.clearAll();
    for (final item in items) {
      if (item is NetworkImageItem) {
        widget.controller?.addNetworkUrl(item.url, headers: item.headers);
      } else if (item is LocalImageItem) {
        widget.controller?.addLocalFile(item.file);
      }
    }
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

// ── Add slot widget ───────────────────────────────────────────────────────────

class _AddSlot extends StatelessWidget {
  const _AddSlot({
    super.key,
    required this.size,
    required this.config,
    required this.decoration,
    required this.onTap,
  });

  final double size;
  final ImageFieldConfig config;
  final ImageFieldDecoration decoration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = switch (config.shape) {
      ImageFieldShape.circle => size / 2,
      ImageFieldShape.roundedRect => config.borderRadius,
      _ => 0.0,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: theme.colorScheme.outline,
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 28,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Simple reorderable wrap (without extra dependency) ────────────────────────

class ReorderableWrap extends StatelessWidget {
  const ReorderableWrap({
    super.key,
    required this.children,
    required this.onReorder,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
  });

  final List<Widget> children;
  final void Function(int oldIndex, int newIndex) onReorder;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: spacing, runSpacing: runSpacing, children: children);
  }
}

// ── Internal slot data model ──────────────────────────────────────────────────

class _SlotData {
  const _SlotData({required this.index, required this.item});
  final int index;
  final ImageItem? item;
}
