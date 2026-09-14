import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../services/firebase_service.dart';
import '../../../services/render_api_service.dart';
import '../../../utils/friendly_error.dart';
import '../../../utils/image_upload.dart';
import '../../../utils/usn_parser.dart';
import '../data/user_doc.dart';
import 'auth_controller.dart';

/// First-run profile wizard for students (spec §6). Saves through
/// PUT /api/profile so batch/year are resolved server-side.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  int _step = 0;
  bool _saving = false;
  bool _prefilled = false;

  final _identityFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usnController = TextEditingController();
  String? _phoneNumber;
  bool _flagForHodReview = false;

  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _instagramController = TextEditingController();
  final _websiteController = TextEditingController();

  XFile? _image;
  Uint8List? _preview;

  @override
  void dispose() {
    _nameController.dispose();
    _usnController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _instagramController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _prefill(UserDoc user) {
    if (_prefilled) return;
    _prefilled = true;
    _nameController.text = user.fullName;
    _usnController.text = user.usn;
    _phoneNumber = user.phone;
    _githubController.text = user.githubUrl ?? '';
    _linkedinController.text = user.linkedinUrl ?? '';
    _instagramController.text = user.instagramHandle ?? '';
    _websiteController.text = user.personalWebsite ?? '';
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 70, maxWidth: 1024);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _image = picked;
      _preview = bytes;
    });
  }

  String? _nullIfEmpty(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _complete() async {
    final user = ref.read(currentUserDocProvider).valueOrNull;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      final image = _image;
      final photoUrl = image == null ? null : await uploadImage(image, 'profile_pictures/${user.uid}.jpg');

      await ref.read(renderApiServiceProvider).updateProfile({
        'fullName': _nameController.text.trim(),
        'usn': _usnController.text.trim().toUpperCase(),
        'phone': _phoneNumber,
        'githubUrl': _nullIfEmpty(_githubController),
        'linkedinUrl': _nullIfEmpty(_linkedinController),
        'instagramHandle': _nullIfEmpty(_instagramController),
        'personalWebsite': _nullIfEmpty(_websiteController),
        'profilePictureUrl': ?photoUrl,
        'flagForHodReview': _flagForHodReview,
      });

      // The router moves on to /home once the doc shows profileComplete.
      if (mounted) context.go('/home');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e)), backgroundColor: AppColors.error),
      );
    }
  }

  void _continue() {
    if (_step == 0) {
      if (!_identityFormKey.currentState!.validate()) return;
      if (_phoneNumber == null || _phoneNumber!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your phone number')),
        );
        return;
      }
    }
    if (_step < 3) {
      setState(() => _step++);
    } else {
      _complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDocProvider).valueOrNull;
    if (user != null) _prefill(user);

    final parsed = UsnParser.parse(_usnController.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _saving ? null : () => ref.read(authControllerProvider.notifier).logout(),
            child: const Text('Log out'),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              currentStep: _step,
              onStepContinue: _saving ? null : _continue,
              onStepCancel: _step == 0 || _saving ? null : () => setState(() => _step--),
              onStepTapped: _saving ? null : (i) => i < _step ? setState(() => _step = i) : null,
              controlsBuilder: (context, details) => Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(_step == 3 ? 'Complete setup' : 'Continue'),
                    ),
                    const SizedBox(width: 12),
                    if (_step > 0) TextButton(onPressed: details.onStepCancel, child: const Text('Back')),
                    if (_step >= 2) ...[
                      const Spacer(),
                      TextButton(onPressed: details.onStepContinue, child: const Text('Skip')),
                    ],
                  ],
                ),
              ),
              steps: [
                Step(
                  title: const Text('Identity'),
                  isActive: _step >= 0,
                  content: Form(
                    key: _identityFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(labelText: 'Full Name'),
                          validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _usnController,
                          readOnly: user.usn.isNotEmpty,
                          decoration: InputDecoration(
                            labelText: 'USN',
                            helperText: user.usn.isNotEmpty ? 'Linked to your account' : null,
                            suffixIcon: user.usn.isNotEmpty ? const Icon(Icons.lock_outline, size: 18) : null,
                          ),
                          validator: (v) => usnPattern.hasMatch((v ?? '').trim().toUpperCase())
                              ? null
                              : 'Invalid USN — expected e.g. 4MW21AI042',
                        ),
                        const SizedBox(height: 16),
                        IntlPhoneField(
                          decoration: const InputDecoration(labelText: 'Phone Number'),
                          initialCountryCode: 'IN',
                          initialValue: _phoneNumber?.replaceFirst('+91', ''),
                          onChanged: (phone) => _phoneNumber = phone.completeNumber,
                        ),
                      ],
                    ),
                  ),
                ),
                Step(
                  title: const Text('Academic Info'),
                  isActive: _step >= 1,
                  content: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "We've detected you as:\n${parsed?.label ?? 'Unknown'}, AI & ML",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'The HOD office confirms your batch from the official batch table.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _flagForHodReview,
                            onChanged: (v) => setState(() => _flagForHodReview = v ?? false),
                            title: const Text('This looks wrong — flag for HOD review'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Step(
                  title: const Text('Socials'),
                  isActive: _step >= 2,
                  content: Column(
                    children: [
                      TextField(
                        controller: _githubController,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(labelText: 'GitHub URL', prefixIcon: Icon(Icons.code)),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _linkedinController,
                        keyboardType: TextInputType.url,
                        decoration:
                            const InputDecoration(labelText: 'LinkedIn URL', prefixIcon: Icon(Icons.business_center)),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _instagramController,
                        decoration:
                            const InputDecoration(labelText: 'Instagram handle', prefixIcon: Icon(Icons.camera_alt)),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _websiteController,
                        keyboardType: TextInputType.url,
                        decoration:
                            const InputDecoration(labelText: 'Personal website', prefixIcon: Icon(Icons.language)),
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Profile Picture'),
                  isActive: _step >= 3,
                  content: Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.secondary,
                          backgroundImage: _preview != null ? MemoryImage(_preview!) : null,
                          child: _preview == null
                              ? Text(
                                  _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 40, color: Colors.white),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.camera_alt_outlined),
                              label: const Text('Camera'),
                              onPressed: () => _pickImage(ImageSource.camera),
                            ),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const Text('Gallery'),
                              onPressed: () => _pickImage(ImageSource.gallery),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
