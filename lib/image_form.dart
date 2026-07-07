/// image_form — A fully-featured Flutter FormField for single and multiple images.
///
/// Import this single file to access everything:
/// ```dart
/// import 'package:image_form/image_form.dart';
/// ```
library;

// Models
export 'src/models/image_item.dart';

// Config
export 'src/config/image_field_config.dart';
export 'src/config/image_field_decoration.dart';

// Controllers
export 'src/controller/image_field_controller.dart';
export 'src/controller/multi_image_field_controller.dart';

// Widgets — single image
export 'src/image_form_field.dart';

// Widgets — multi image
export 'src/multi/multi_image_form_field.dart';

// Validation
export 'src/validation/image_validators.dart';

// Display (exported so users can build custom UIs if needed)
export 'src/display/image_display_widget.dart';
export 'src/display/image_viewer_page.dart';
export 'src/display/edit_overlay_widget.dart';

// Picker services (exported for testing / custom integration)
export 'src/picker/image_picker_service.dart';
export 'src/picker/image_crop_service.dart';
export 'src/picker/image_source_sheet.dart';

export 'package:image_cropper/image_cropper.dart'
    show CropAspectRatioPreset, CropStyle;
