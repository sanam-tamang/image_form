import 'package:flutter/material.dart';
import 'package:image_form/image_form.dart';

void main() => runApp(const ImageFormExampleApp());

class ImageFormExampleApp extends StatelessWidget {
  const ImageFormExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'image_form examples',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const ExampleHome(),
    );
  }
}

class ExampleHome extends StatelessWidget {
  const ExampleHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('image_form examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ExampleTile(
            title: 'Trainer / Student Avatar',
            subtitle: 'Circle · crop · tap to view',
            page: const AvatarExample(),
          ),
          _ExampleTile(
            title: 'Course Thumbnail',
            subtitle: 'Rounded rect · 16:9 crop · cache',
            page: const ThumbnailExample(),
          ),
          _ExampleTile(
            title: 'Organization Logo',
            subtitle: 'Square · no crop · replaceable',
            page: const LogoExample(),
          ),
          _ExampleTile(
            title: 'Certificate Background',
            subtitle: 'Rectangle · free crop · full-width',
            page: const CertificateExample(),
          ),
          _ExampleTile(
            title: 'Play Store Screenshots',
            subtitle: 'Multi image · grid · reorder · remove',
            page: const MultiImageExample(),
          ),
          _ExampleTile(
            title: 'Full Form with Validation',
            subtitle: 'Required · size limit · Form.validate()',
            page: const FormValidationExample(),
          ),
          _ExampleTile(
            title: 'With Controller',
            subtitle: 'ChangeNotifier · dirty check · reset',
            page: const ControllerExample(),
          ),
        ],
      ),
    );
  }
}

// ── 1. Avatar ─────────────────────────────────────────────────────────────────

class AvatarExample extends StatelessWidget {
  const AvatarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return _ExampleScaffold(
      title: 'Trainer Avatar',
      child: Center(
        child: ImageFormField(
          initialUrl: 'https://picsum.photos/seed/trainer/200',
          config: const ImageFieldConfig(
            shape: ImageFieldShape.circle,
            width: 120,
            height: 120,
            enableCrop: true,
            cropAspectRatio: CropAspectRatioPreset.square,
            cropStyle: CropStyle.circle,
            enableCache: true,
            enableTapToView: true,
            editIconPosition: EditIconPosition.bottomRight,
          ),
          decoration: ImageFieldDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
            label: const Text('Profile Photo'),
          ),
          validator: ImageValidators.required(
            message: 'A profile photo is required.',
          ),
          onChanged: (item) => debugPrint('Avatar changed: $item'),
        ),
      ),
    );
  }
}

// ── 2. Course Thumbnail ───────────────────────────────────────────────────────

class ThumbnailExample extends StatelessWidget {
  const ThumbnailExample({super.key});

  @override
  Widget build(BuildContext context) {
    return _ExampleScaffold(
      title: 'Course Thumbnail',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ImageFormField(
          initialUrl: 'https://picsum.photos/seed/course/640/360',
          config: ImageFieldConfig(
            shape: ImageFieldShape.roundedRect,
            width: MediaQuery.of(context).size.width - 48,
            aspectRatio: 16 / 9,
            borderRadius: 16,
            enableCrop: true,
            cropAspectRatio: CropAspectRatioPreset.ratio16x9,
            enableCache: true,
            enableTapToView: true,
            editIconPosition: EditIconPosition.bottomRight,
          ),
          decoration: ImageFieldDecoration(
            label: const Text('Course Thumbnail'),
            helperText: 'Recommended: 1280 × 720 px (16:9)',
            placeholder: const _PlaceholderContent(
              icon: Icons.video_camera_back_outlined,
              label: 'Add thumbnail',
            ),
          ),
          validator: ImageValidators.compose([
            ImageValidators.required(message: 'Please add a course thumbnail.'),
            ImageValidators.maxFileSizeBytes(
              5 * 1024 * 1024,
              message: 'Thumbnail must be under 5 MB.',
            ),
          ]),
        ),
      ),
    );
  }
}

// ── 3. Org Logo ───────────────────────────────────────────────────────────────

class LogoExample extends StatelessWidget {
  const LogoExample({super.key});

  @override
  Widget build(BuildContext context) {
    return _ExampleScaffold(
      title: 'Organization Logo',
      child: Center(
        child: ImageFormField(
          initialUrl: 'https://picsum.photos/seed/logo/200/200',
          config: const ImageFieldConfig(
            shape: ImageFieldShape.square,
            width: 100,
            height: 100,
            enableCrop: false,
            enableCache: true,
            enableTapToView: true,
            allowRemove: true,
            editIconPosition: EditIconPosition.bottomCenter,
          ),
          decoration: const ImageFieldDecoration(
            label: Text('Organization Logo'),
            helperText: 'Square image works best',
          ),
        ),
      ),
    );
  }
}

// ── 4. Certificate Background ─────────────────────────────────────────────────

class CertificateExample extends StatelessWidget {
  const CertificateExample({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 32;

    return _ExampleScaffold(
      title: 'Certificate Background',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ImageFormField(
          initialUrl: 'https://picsum.photos/seed/cert/800/566',
          config: ImageFieldConfig(
            allowGallery: false,
            shape: ImageFieldShape.rectangle,
            allowRemove: false,
            enableEditOnTap: true,
            width: width,
            aspectRatio: 800 / 566, // A4 landscape
            enableCrop: true,
            cropAspectRatio: CropAspectRatioPreset.ratio4x3,
            enableCache: true,
            enableTapToView: true,
            editIconPosition: EditIconPosition.bottomRight,
            fit: BoxFit.cover,
          ),
          decoration: const ImageFieldDecoration(
            label: Text('Certificate Background'),
            helperText: 'Landscape format recommended',
            placeholder: _PlaceholderContent(
              icon: Icons.image_outlined,
              label: 'Add background image',
            ),
          ),
        ),
      ),
    );
  }
}

// ── 5. Multi Image (Play Store screenshots) ────────────────────────────────────

class MultiImageExample extends StatelessWidget {
  const MultiImageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return _ExampleScaffold(
      title: 'App Screenshots',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: MultiImageFormField(
          initialUrls: [
            'https://picsum.photos/seed/s1/400/800',
            'https://picsum.photos/seed/s2/400/800',
            'https://picsum.photos/seed/s3/400/800',
          ],
          minCount: 2,
          maxCount: 8,
          layout: MultiImageLayout.grid,
          gridCrossAxisCount: 3,
          itemHeight: 110,
          allowReorder: true,
          config: const ImageFieldConfig(
            shape: ImageFieldShape.roundedRect,
            borderRadius: 10,
            enableCrop: true,
            cropAspectRatio: CropAspectRatioPreset.ratio3x2,
            enableCache: true,
            enableTapToView: true,
            editIconPosition: EditIconPosition.bottomRight,
          ),
          decoration: const ImageFieldDecoration(
            label: Text('App Screenshots'),
            helperText: 'Add 2–8 screenshots. Long-press to reorder.',
          ),
          validator: ImageValidators.multi(
            minCount: 2,
            maxCount: 8,
            minMessage: 'Please add at least 2 screenshots.',
            maxMessage: 'You can upload up to 8 screenshots.',
            perItem: ImageValidators.maxFileSizeBytes(
              10 * 1024 * 1024,
              message: 'Each screenshot must be under 10 MB.',
            ),
          ),
          onChanged: (items) =>
              debugPrint('Screenshots: ${items.length} items'),
        ),
      ),
    );
  }
}

// ── 6. Full Form + Validation ─────────────────────────────────────────────────

class FormValidationExample extends StatefulWidget {
  const FormValidationExample({super.key});

  @override
  State<FormValidationExample> createState() => _FormValidationExampleState();
}

class _FormValidationExampleState extends State<FormValidationExample> {
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Form is valid ✓')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ExampleScaffold(
      title: 'Form with Validation',
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Avatar field
            ImageFormField(
              config: const ImageFieldConfig(
                shape: ImageFieldShape.circle,
                width: 100,
                height: 100,
                enableCrop: true,
              ),
              decoration: const ImageFieldDecoration(
                label: Text('Profile Photo *'),
              ),
              validator: ImageValidators.required(),
            ),

            const SizedBox(height: 24),

            // Thumbnail field
            ImageFormField(
              config: ImageFieldConfig(
                shape: ImageFieldShape.roundedRect,
                width: MediaQuery.of(context).size.width - 40,
                aspectRatio: 16 / 9,
                enableCrop: true,
                cropAspectRatio: CropAspectRatioPreset.ratio16x9,
              ),
              decoration: const ImageFieldDecoration(
                label: Text('Cover Image *'),
                helperText: 'Max 3 MB',
              ),
              validator: ImageValidators.compose([
                ImageValidators.required(message: 'Cover image is required.'),
                ImageValidators.maxFileSizeBytes(3 * 1024 * 1024),
                ImageValidators.allowedExtensions(['jpg', 'jpeg', 'png']),
              ]),
            ),

            const SizedBox(height: 32),

            FilledButton(onPressed: _submit, child: const Text('Submit')),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () => _formKey.currentState!.reset(),
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 7. Controller Example ─────────────────────────────────────────────────────

class ControllerExample extends StatefulWidget {
  const ControllerExample({super.key});

  @override
  State<ControllerExample> createState() => _ControllerExampleState();
}

class _ControllerExampleState extends State<ControllerExample> {
  late final ImageFieldController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ImageFieldController(
      initialItem: const NetworkImageItem(
        url: 'https://picsum.photos/seed/ctrl/200',
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ExampleScaffold(
      title: 'Controller Example',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Widget driven by controller
            ImageFormField(
              controller: _controller,
              config: const ImageFieldConfig(
                shape: ImageFieldShape.circle,
                width: 120,
                height: 120,
                enableCrop: true,
                enableTapToView: true,
              ),
            ),

            const SizedBox(height: 24),

            // Listen to controller with ValueListenableBuilder
            ValueListenableBuilder<ImageItem>(
              valueListenable: _controller,
              builder: (context, item, _) {
                return Column(
                  children: [
                    Text(
                      'Current: ${item.runtimeType}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Has changed: ${_controller.hasChanged}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _controller.hasChanged
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Programmatic actions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.link, size: 16),
                  label: const Text('Load new URL'),
                  onPressed: () => _controller.setNetworkUrl(
                    'https://picsum.photos/seed/${DateTime.now().millisecond}/200',
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Clear'),
                  onPressed: _controller.clear,
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reset'),
                  onPressed: _controller.reset,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared helper widgets ─────────────────────────────────────────────────────

class _ExampleScaffold extends StatelessWidget {
  const _ExampleScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: child,
    );
  }
}

class _ExampleTile extends StatelessWidget {
  const _ExampleTile({
    required this.title,
    required this.subtitle,
    required this.page,
  });

  final String title;
  final String subtitle;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => page),
        ),
      ),
    );
  }
}

class _PlaceholderContent extends StatelessWidget {
  const _PlaceholderContent({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 36, color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
