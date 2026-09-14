import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../services/firebase_service.dart';
import '../../../services/render_api_service.dart';
import '../../../utils/friendly_error.dart';
import '../../../utils/image_upload.dart';
import '../data/user_doc.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  bool _saving = false;
  bool _loaded = false;

  String? _phoneNumber;
  String? _currentPhotoUrl;
  final _bioController = TextEditingController();
  final _skillsController = TextEditingController();
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _instagramController = TextEditingController();
  final _websiteController = TextEditingController();
  final _twitterController = TextEditingController();
  final _discordController = TextEditingController();

  XFile? _image;
  Uint8List? _preview;
  bool _flagForHodReview = false;

  PrivacySettings _privacy = const PrivacySettings();
  NotificationSettings _notifications = const NotificationSettings();

  @override
  void dispose() {
    for (final c in [
      _bioController,
      _skillsController,
      _githubController,
      _linkedinController,
      _instagramController,
      _websiteController,
      _twitterController,
      _discordController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _load(UserDoc user) {
    if (_loaded) return;
    _loaded = true;
    _currentPhotoUrl = user.profilePictureUrl;
    _phoneNumber = user.phone;
    _bioController.text = user.bio ?? '';
    _skillsController.text = user.skills.join(', ');
    _githubController.text = user.githubUrl ?? '';
    _linkedinController.text = user.linkedinUrl ?? '';
    _instagramController.text = user.instagramHandle ?? '';
    _websiteController.text = user.personalWebsite ?? '';
    _twitterController.text = user.twitterHandle ?? '';
    _discordController.text = user.discordHandle ?? '';
    _privacy = user.privacySettings;
    _notifications = user.notificationSettings;
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

  String? _text(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save(UserDoc user) async {
    setState(() => _saving = true);
    try {
      final image = _image;
      final photoUrl =
          image == null ? _currentPhotoUrl : await uploadImage(image, 'profile_pictures/${user.uid}.jpg');

      await ref.read(renderApiServiceProvider).updateProfile({
        'fullName': user.fullName,
        if (user.usn.isNotEmpty) 'usn': user.usn,
        'phone': _phoneNumber,
        'bio': _text(_bioController),
        'skills': _skillsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
        'githubUrl': _text(_githubController),
        'linkedinUrl': _text(_linkedinController),
        'instagramHandle': _text(_instagramController),
        'personalWebsite': _text(_websiteController),
        'twitterHandle': _text(_twitterController),
        'discordHandle': _text(_discordController),
        'profilePictureUrl': photoUrl,
        'flagForHodReview': _flagForHodReview,
        'privacySettings': _privacy.toJson(),
        'notificationSettings': _notifications.toJson(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated'), backgroundColor: AppColors.success),
      );
      context.pop();
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
    final user = ref.watch(currentUserDocProvider).valueOrNull;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    _load(user);

    final isStudent = user.role == UserRole.student;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          _buildPhoto(user),
          const SizedBox(height: 24),
          _section('Identity', Icons.school_rounded),
          _card([
            _locked('Full name', user.fullName),
            if (isStudent) _locked('USN', user.usn),
            if (isStudent) _locked('Batch', '${user.yearOfStudy ?? '-'} Year · ${user.batch ?? 'Pending review'}'),
            if (!isStudent) _locked('Role', [user.role.label, if (user.club != null) user.club].join(' · ')),
            if (isStudent)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _flagForHodReview,
                onChanged: (v) => setState(() => _flagForHodReview = v ?? false),
                title: const Text('Name, USN or batch wrong? Flag for HOD review'),
              ),
          ]),
          const SizedBox(height: 24),
          _section('Contact & bio', Icons.person_rounded),
          _card([
            IntlPhoneField(
              decoration: const InputDecoration(labelText: 'Phone number'),
              initialCountryCode: 'IN',
              initialValue: _phoneNumber?.replaceFirst('+91', ''),
              onChanged: (phone) => _phoneNumber = phone.completeNumber,
            ),
            TextField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 150,
              decoration: const InputDecoration(labelText: 'Bio — tell us about yourself'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _skillsController,
              decoration: const InputDecoration(
                labelText: 'Skills',
                hintText: 'Comma separated, e.g. Python, PyTorch, Flutter',
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('Social links', Icons.link_rounded),
          _card([
            _field(_githubController, 'GitHub URL', Icons.code_rounded),
            _field(_linkedinController, 'LinkedIn URL', Icons.business_center_rounded),
            _field(_twitterController, 'X / Twitter handle', Icons.alternate_email_rounded),
            _field(_discordController, 'Discord handle', Icons.forum_outlined),
            _field(_instagramController, 'Instagram handle', Icons.camera_alt_rounded),
            _field(_websiteController, 'Personal website', Icons.language_rounded),
          ]),
          const SizedBox(height: 24),
          _section('Privacy', Icons.security_rounded),
          _card([
            _toggle('Public bio', _privacy.publicBio, (v) => _privacy = _privacy.copyWith(publicBio: v)),
            _toggle('Public GitHub', _privacy.publicGithub, (v) => _privacy = _privacy.copyWith(publicGithub: v)),
            _toggle('Public LinkedIn', _privacy.publicLinkedin,
                (v) => _privacy = _privacy.copyWith(publicLinkedin: v)),
            _toggle('Public Instagram', _privacy.publicInstagram,
                (v) => _privacy = _privacy.copyWith(publicInstagram: v)),
            _toggle('Public X / Twitter', _privacy.publicTwitter,
                (v) => _privacy = _privacy.copyWith(publicTwitter: v)),
            _toggle('Public website', _privacy.publicPersonalWebsite,
                (v) => _privacy = _privacy.copyWith(publicPersonalWebsite: v)),
          ]),
          const SizedBox(height: 24),
          _section('Notifications', Icons.notifications_rounded),
          _card([
            _toggle('Event & attendance updates', _notifications.eventsEnabled,
                (v) => _notifications = _notifications.copyWith(eventsEnabled: v)),
            _toggle('Faculty updates', _notifications.updatesEnabled,
                (v) => _notifications = _notifications.copyWith(updatesEnabled: v)),
            _toggle('Memory Wall approvals', _notifications.memoriesEnabled,
                (v) => _notifications = _notifications.copyWith(memoriesEnabled: v)),
          ]),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _saving ? null : () => _save(user),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_rounded),
            label: const Text('Save profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoto(UserDoc user) {
    final ImageProvider? image = _preview != null
        ? MemoryImage(_preview!)
        : (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty ? NetworkImage(_currentPhotoUrl!) : null);

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.secondary,
            backgroundImage: image,
            child: image == null
                ? Text(user.initials, style: GoogleFonts.poppins(fontSize: 32, color: Colors.white))
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: IconButton.filled(
              tooltip: 'Change photo',
              onPressed: () => showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (ctx) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.camera_alt_rounded),
                        title: const Text('Take photo'),
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_library_rounded),
                        title: const Text('Choose from gallery'),
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              icon: const Icon(Icons.camera_alt_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      ),
    );
  }

  Widget _locked(String label, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textTertiary)),
      subtitle: Text(value.isEmpty ? 'N/A' : value, style: GoogleFonts.poppins(fontSize: 14)),
      trailing: const Icon(Icons.lock_outline, size: 16, color: AppColors.textTertiary),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20)),
      ),
    );
  }

  Widget _toggle(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
      value: value,
      onChanged: (v) => setState(() => onChanged(v)),
    );
  }
}
