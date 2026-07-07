import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/image_item.dart';

/// ChangeNotifier controller for [MultiImageFormField].
///
/// Manages an ordered list of [ImageItem] entries. Each slot can be
/// a [NetworkImageItem], [LocalImageItem], or [EmptyImageItem].
///
/// ```dart
/// final controller = MultiImageFieldController(
///   initialUrls: ['https://example.com/img1.jpg'],
///   maxCount: 5,
/// );
///
/// ValueListenableBuilder<List<ImageItem>>(
///   valueListenable: controller,
///   builder: (context, items, _) { ... },
/// );
/// ```
class MultiImageFieldController extends ChangeNotifier
    implements ValueListenable<List<ImageItem>> {
  MultiImageFieldController({
    List<String>? initialUrls,
    List<ImageItem>? initialItems,
    this.minCount = 0,
    this.maxCount = 10,
  }) : assert(
         initialUrls == null || initialItems == null,
         'Provide either initialUrls or initialItems, not both.',
       ) {
    if (initialItems != null) {
      _items = List.of(initialItems);
    } else if (initialUrls != null) {
      _items = initialUrls
          .map((u) => NetworkImageItem(url: u) as ImageItem)
          .toList();
    } else {
      _items = [];
    }
    _initialItems = List.of(_items);
  }

  final int minCount;
  final int maxCount;

  late List<ImageItem> _items;
  late List<ImageItem> _initialItems;
  bool _isLoading = false;
  String? _errorText;

  // ── ValueListenable ───────────────────────────────────────────────────────

  @override
  List<ImageItem> get value => List.unmodifiable(_items);

  // ── State Reads ───────────────────────────────────────────────────────────

  int get count => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isFull => _items.length >= maxCount;
  bool get hasChanged => !_listEquals(_items, _initialItems);
  bool get isLoading => _isLoading;
  String? get errorText => _errorText;

  ImageItem operator [](int index) => _items[index];

  // ── Add ───────────────────────────────────────────────────────────────────

  /// Add a new local file to the end of the list.
  /// Does nothing if [maxCount] is already reached.
  void addLocalFile(File file) {
    if (_items.length >= maxCount) return;
    _items.add(LocalImageItem(file: file));
    _notify();
  }

  /// Add multiple local files at once.
  void addLocalFiles(List<File> files) {
    final available = maxCount - _items.length;
    final toAdd = files.take(available);
    _items.addAll(toAdd.map((f) => LocalImageItem(file: f)));
    _notify();
  }

  /// Add a network URL item.
  void addNetworkUrl(String url, {Map<String, String>? headers}) {
    if (_items.length >= maxCount) return;
    _items.add(NetworkImageItem(url: url, headers: headers));
    _notify();
  }

  // ── Replace ───────────────────────────────────────────────────────────────

  /// Replace the item at [index] with a new local file.
  void replaceWithFile(int index, File file) {
    _assertIndex(index);
    _items[index] = LocalImageItem(file: file);
    _notify();
  }

  /// Replace the item at [index] with a network URL.
  void replaceWithUrl(int index, String url) {
    _assertIndex(index);
    _items[index] = NetworkImageItem(url: url);
    _notify();
  }

  // ── Remove & Reorder ─────────────────────────────────────────────────────

  /// Remove the item at [index].
  void removeAt(int index) {
    _assertIndex(index);
    _items.removeAt(index);
    _notify();
  }

  /// Move an item from [oldIndex] to [newIndex].
  /// Designed to be passed directly to ReorderableListView.onReorder.
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _items.removeAt(oldIndex);
    _items.insert(newIndex, item);
    _notify();
  }

  /// Remove all items.
  void clearAll() {
    _items.clear();
    _notify();
  }

  /// Reset to the initial list provided in the constructor.
  void reset() {
    _items = List.of(_initialItems);
    _notify();
  }

  // ── Loading & Error ───────────────────────────────────────────────────────

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorText = error;
    notifyListeners();
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _notify() {
    _errorText = null;
    _isLoading = false;
    notifyListeners();
  }

  void _assertIndex(int index) {
    assert(
      index >= 0 && index < _items.length,
      'Index $index is out of range for list of length ${_items.length}',
    );
  }

  bool _listEquals(List<ImageItem> a, List<ImageItem> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
