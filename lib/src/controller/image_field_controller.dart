import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/image_item.dart';

/// ChangeNotifier controller for [ImageFormField].
///
/// Use this when you need programmatic control — resetting the field,
/// reading the current value, checking if the user made a change, or
/// listening to updates outside the form widget tree.
///
/// ## With ValueListenableBuilder
/// ```dart
/// final controller = ImageFieldController(
///   initialItem: NetworkImageItem(url: 'https://example.com/avatar.jpg'),
/// );
///
/// ValueListenableBuilder<ImageItem>(
///   valueListenable: controller,
///   builder: (context, item, _) => Text(item.toString()),
/// );
/// ```
///
/// ## Without builder — listen manually
/// ```dart
/// controller.addListener(() {
///   if (controller.isLocal) uploadToServer(controller.localFile!);
/// });
/// ```
///
/// Always call [dispose] when the controller is no longer needed.
class ImageFieldController extends ChangeNotifier
    implements ValueListenable<ImageItem> {
  ImageFieldController({
    ImageItem? initialItem,
  })  : _initialItem = initialItem ?? const EmptyImageItem(),
        _current = initialItem ?? const EmptyImageItem();

  final ImageItem _initialItem;
  ImageItem _current;
  bool _isLoading = false;
  String? _errorText;

  // ── ValueListenable ───────────────────────────────────────────────────────

  /// The current image item. Rebuilds ValueListenableBuilder on change.
  @override
  ImageItem get value => _current;

  // ── State Reads ───────────────────────────────────────────────────────────

  bool get hasImage => _current.hasImage;
  bool get isLocal => _current.isLocal;
  bool get isNetwork => _current.isNetwork;
  bool get isEmpty => _current.isEmpty;

  /// True if the current value differs from the initial value.
  /// Use this as a "dirty" check before showing a discard-changes dialog.
  bool get hasChanged => _current != _initialItem;

  /// True while the picker or cropper is processing.
  bool get isLoading => _isLoading;

  /// Non-null when a picker or crop error occurred.
  String? get errorText => _errorText;

  /// Convenience accessor — the local File if current item is [LocalImageItem].
  File? get localFile =>
      _current is LocalImageItem ? (_current as LocalImageItem).file : null;

  /// Convenience accessor — the URL if current item is [NetworkImageItem].
  String? get networkUrl =>
      _current is NetworkImageItem ? (_current as NetworkImageItem).url : null;

  // ── Mutations ─────────────────────────────────────────────────────────────

  /// Replace the current image with a network URL.
  /// Useful when loading a user profile from the server after init.
  void setNetworkUrl(String url, {Map<String, String>? headers}) {
    _setCurrent(NetworkImageItem(url: url, headers: headers));
  }

  /// Replace the current image with a locally picked file.
  /// Called automatically by [ImagePickerService] — but available for
  /// manual use (e.g. testing, or pre-setting a local file).
  void setLocalFile(File file) {
    _setCurrent(LocalImageItem(file: file));
  }

  /// Clear the field to [EmptyImageItem] — removes both network and local.
  void clear() {
    _setCurrent(const EmptyImageItem());
  }

  /// Reset back to the initialItem passed to the constructor.
  /// Use this on "Cancel" or "Discard changes".
  void reset() {
    _setCurrent(_initialItem);
  }

  /// Set loading state — shown as an overlay on the image while picking.
  // ignore: use_setters_to_change_properties
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set an error message to surface to the UI.
  // ignore: use_setters_to_change_properties
  void setError(String? error) {
    _errorText = error;
    notifyListeners();
  }

  void _setCurrent(ImageItem item) {
    _current = item;
    _errorText = null;
    _isLoading = false;
    notifyListeners();
  }
}
