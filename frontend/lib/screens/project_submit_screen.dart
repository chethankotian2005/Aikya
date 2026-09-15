import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_tokens.dart';
import '../models/project_model.dart';
import '../services/firebase_service.dart';
import '../utils/friendly_error.dart';
import '../utils/image_upload.dart';

/// Student project submission (spec §5: students submit projects).
class ProjectSubmitScreen extends ConsumerStatefulWidget {
  const ProjectSubmitScreen({super.key});

  @override
  ConsumerState<ProjectSubmitScreen> createState() => _ProjectSubmitScreenState();
}

class _ProjectSubmitScreenState extends ConsumerState<ProjectSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _techController = TextEditingController();
  final _repoController = TextEditingController();
  bool _lookingForTeammate = false;
  XFile? _image;
  Uint8List? _preview;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _techController.dispose();
    _repoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 2000);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _image = picked;
      _preview = bytes;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserDocProvider).valueOrNull;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      final techStack = _techController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toSet()
          .take(10)
          .toList();

      final image = _image;
      final imageUrl = image == null ? null : await uploadImage(image, UploadFolder.projectImages);

      final repo = _repoController.text.trim();
      final docRef = await ProjectDoc.collection.add(ProjectDoc.newProject(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        techStack: techStack,
        images: imageUrl == null ? const [] : [imageUrl],
        ownerUid: user.uid,
        ownerName: user.fullName,
        lookingForTeammate: _lookingForTeammate,
        repoUrl: repo.isEmpty ? null : repo,
      ));

      if (mounted) context.pushReplacement('/projects/detail/${docRef.id}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e)), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit a Project')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GestureDetector(
              onTap: _saving ? null : _pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.borderRadiusLg,
                  border: Border.all(color: AppColors.border),
                  image: _preview != null
                      ? DecorationImage(image: MemoryImage(_preview!), fit: BoxFit.cover)
                      : null,
                ),
                child: _preview == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.accent),
                          const SizedBox(height: 8),
                          Text(
                            'Add a cover image (optional)',
                            style: GoogleFonts.poppins(color: AppColors.textSecondary),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              maxLength: 120,
              decoration: const InputDecoration(labelText: 'Project title'),
              validator: (v) => (v ?? '').trim().length < 3 ? 'Title must be at least 3 characters' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLength: 2000,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
                hintText: 'What does it do, how is it built, what did you learn?',
              ),
              validator: (v) => (v ?? '').trim().isEmpty ? 'Description is required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _techController,
              decoration: const InputDecoration(
                labelText: 'Tech stack',
                hintText: 'Comma separated, e.g. PyTorch, Flutter, Firebase',
              ),
              validator: (v) => (v ?? '').trim().isEmpty ? 'Add at least one technology' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _repoController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(labelText: 'Repository / demo link (optional)'),
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return null;
                return value.startsWith('http://') || value.startsWith('https://')
                    ? null
                    : 'Link must start with https://';
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Looking for teammates'),
              subtitle: const Text('Shows a TEAMMATE badge on your project'),
              value: _lookingForTeammate,
              onChanged: (v) => setState(() => _lookingForTeammate = v),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Submit project'),
            ),
          ],
        ),
      ),
    );
  }
}
