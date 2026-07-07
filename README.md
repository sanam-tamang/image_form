# image_form

A fully-featured Flutter `FormField` for single and multiple images.  
Supports network + local images, caching, crop, validation, ChangeNotifier controller,  
tap-to-view, custom shapes, and editable overlays.

Works for any image use case — avatars, thumbnails, logos, banners, certificates, screenshots.

---

## Features

- **`ImageFormField`** — single image field, works inside `Form`
- **`MultiImageFormField`** — multi-image grid/scroll field with add, replace, remove, reorder
- **Network + local** — shows a network URL, user can replace it with a local pick
- **Caching** — `CachedNetworkImage` + `flutter_cache_manager` (toggleable)
- **Crop** — `image_cropper` integration with aspect ratio + crop style control
- **Shapes** — circle, rounded rectangle, rectangle, square
- **Tap to view** — full-screen Hero viewer on tap
- **Edit icon** — customisable icon, widget, position
- **Validation** — `required`, `maxFileSizeBytes`, `allowedExtensions`, `minCount`, `maxCount`, `custom`, `compose`
- **Controller** — `ImageFieldController` / `MultiImageFieldController` (ChangeNotifier + ValueListenable)
- **Three state options** — controller + ValueListenableBuilder, FormField internal state, or simple setState

---

## Installation

```yaml
dependencies:
  image_form: ^0.0.1
```

Add permissions to your platform files:

**Android** (`AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

**iOS** (`Info.plist`):
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Used to pick profile and course images.</string>
<key>NSCameraUsageDescription</key>
<string>Used to take photos for your profile.</string>
```

---

## Quick start

```dart
import 'package:image_form/image_form.dart';
```

### Avatar (circle, crop, tap to view)

```dart
ImageFormField(
  initialUrl: 'https://example.com/avatar.jpg',
  config: const ImageFieldConfig(
    shape: ImageFieldShape.circle,
    width: 120,
    height: 120,
    enableCrop: true,
    cropAspectRatio: CropAspectRatioPreset.square,
    cropStyle: CropStyle.circle,
    enableTapToView: true,
  ),
  validator: ImageValidators.required(),
  onChanged: (item) => print(item),
)
```

### Course thumbnail (16:9, rounded rect)

```dart
ImageFormField(
  initialUrl: 'https://example.com/thumb.jpg',
  config: ImageFieldConfig(
    shape: ImageFieldShape.roundedRect,
    width: double.infinity,
    aspectRatio: 16 / 9,
    enableCrop: true,
    cropAspectRatio: CropAspectRatioPreset.ratio16x9,
  ),
  validator: ImageValidators.compose([
    ImageValidators.required(),
    ImageValidators.maxFileSizeBytes(5 * 1024 * 1024),
  ]),
)
```

### Multi image (Play Store screenshots)

```dart
MultiImageFormField(
  initialUrls: ['https://example.com/s1.jpg'],
  minCount: 2,
  maxCount: 8,
  layout: MultiImageLayout.grid,
  config: const ImageFieldConfig(
    shape: ImageFieldShape.roundedRect,
    enableCrop: true,
  ),
  validator: ImageValidators.multi(minCount: 2, maxCount: 8),
  onChanged: (items) => print(items.length),
)
```

### With controller

```dart
final controller = ImageFieldController(
  initialItem: NetworkImageItem(url: 'https://example.com/photo.jpg'),
);

// In your widget tree:
ImageFormField(controller: controller)

// Listen with ValueListenableBuilder:
ValueListenableBuilder<ImageItem>(
  valueListenable: controller,
  builder: (context, item, _) => Text(item.toString()),
)

// Programmatic control:
controller.setNetworkUrl('https://example.com/new.jpg');
controller.clear();
controller.reset();
print(controller.hasChanged); // dirty check
```

---

## ImageFieldConfig options

| Property | Type | Default | Description |
|---|---|---|---|
| `shape` | `ImageFieldShape` | `circle` | Visual clip shape |
| `width` | `double?` | null | Fixed width |
| `height` | `double?` | null | Fixed height |
| `aspectRatio` | `double?` | null | width/height ratio |
| `borderRadius` | `double` | `12` | Radius for roundedRect |
| `enableCrop` | `bool` | `false` | Open cropper after pick |
| `cropAspectRatio` | `CropAspectRatioPreset` | `original` | Crop ratio |
| `cropStyle` | `CropStyle` | `rectangle` | Circle or rect overlay |
| `enableCache` | `bool` | `true` | Use CachedNetworkImage |
| `cacheDuration` | `Duration` | `7 days` | Cache TTL |
| `enableTapToView` | `bool` | `true` | Full-screen viewer on tap |
| `enableEditOnTap` | `bool` | `false` | Full surface opens picker |
| `showEditIcon` | `bool` | `true` | Show edit icon badge |
| `editIconPosition` | `EditIconPosition` | `bottomRight` | Badge position |
| `allowGallery` | `bool` | `true` | Show gallery option |
| `allowCamera` | `bool` | `true` | Show camera option |
| `allowRemove` | `bool` | `true` | Show remove option |
| `imageQuality` | `int` | `85` | JPEG compression 0-100 |

---

## ImageItem sealed class

```dart
sealed class ImageItem {}
final class NetworkImageItem extends ImageItem { final String url; ... }
final class LocalImageItem   extends ImageItem { final File file; ... }
final class EmptyImageItem   extends ImageItem {}

// Pattern match:
switch (item) {
  case NetworkImageItem(:final url) => uploadUrl(url),
  case LocalImageItem(:final file)  => uploadFile(file),
  case EmptyImageItem()             => showError('No image'),
}
```

---

## Validators

```dart
ImageValidators.required()
ImageValidators.maxFileSizeBytes(2 * 1024 * 1024)
ImageValidators.allowedExtensions(['jpg', 'png', 'webp'])
ImageValidators.custom((item) => item is EmptyImageItem ? 'Required' : null)
ImageValidators.compose([...])            // single field
ImageValidators.multi(minCount: 1, maxCount: 5, perItem: ...)  // multi field
ImageValidators.multiRequired()
```

---

## Dependencies

| Package | Purpose |
|---|---|
| `cached_network_image` | Network image loading + disk cache |
| `image_picker` | Gallery + camera picking |
| `image_cropper` | Crop UI (Android, iOS, Web) |
| `flutter_cache_manager` | Custom cache policies |
| `path_provider` | Temp file storage |
