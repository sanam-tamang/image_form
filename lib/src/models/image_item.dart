import 'dart:io';

/// Sealed class representing every possible state an image field can hold.
///
/// Use a switch expression to handle all three cases exhaustively:
/// ```dart
/// switch (item) {
///   case NetworkImageItem(:final url) => Text(url),
///   case LocalImageItem(:final file)  => Text(file.path),
///   case EmptyImageItem()             => const Text('no image'),
/// }
/// ```
sealed class ImageItem {
  const ImageItem();

  /// True when the field has any image — network or local.
  bool get hasImage => this is! EmptyImageItem;

  /// True only when the user picked a local file replacement.
  bool get isLocal => this is LocalImageItem;

  /// True only when showing a remote URL with no local override.
  bool get isNetwork => this is NetworkImageItem;

  /// True when no image is set at all.
  bool get isEmpty => this is EmptyImageItem;
}

/// An image loaded from a remote URL.
/// Rendered via CachedNetworkImage when caching is enabled,
/// plain Image.network otherwise.
final class NetworkImageItem extends ImageItem {
  const NetworkImageItem({required this.url, this.headers});

  final String url;

  /// Optional HTTP headers — useful for authenticated image endpoints.
  final Map<String, String>? headers;

  NetworkImageItem copyWith({String? url, Map<String, String>? headers}) =>
      NetworkImageItem(url: url ?? this.url, headers: headers ?? this.headers);

  @override
  bool operator ==(Object other) =>
      other is NetworkImageItem && other.url == url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'NetworkImageItem(url: $url)';
}

/// An image the user picked from gallery or camera.
/// Always takes priority and displayed on top of any NetworkImageItem.
final class LocalImageItem extends ImageItem {
  const LocalImageItem({required this.file});

  final File file;

  String get path => file.path;

  @override
  bool operator ==(Object other) =>
      other is LocalImageItem && other.file.path == file.path;

  @override
  int get hashCode => file.path.hashCode;

  @override
  String toString() => 'LocalImageItem(path: $path)';
}

/// No image is set. The placeholder widget is shown.
final class EmptyImageItem extends ImageItem {
  const EmptyImageItem();

  @override
  bool operator ==(Object other) => other is EmptyImageItem;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'EmptyImageItem()';
}
