import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/theme/app_tokens.dart';
import '../../../services/firebase_service.dart';
import '../../../services/render_api_service.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final bool _isLoading = false;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();

  // Read-only fields
  String _fullName = '';
  String _usn = '';
  String _batch = '';
  String _yearOfStudy = '';
  String? _currentProfilePictureUrl;

  // Editable fields
  String? _phoneNumber;
  final _bioController = TextEditingController();
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _instagramController = TextEditingController();
  final _websiteController = TextEditingController();
  final _twitterController = TextEditingController();
  final _discordController = TextEditingController();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  
  bool _flagForHodReview = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }
  
  void _loadUserData() {
    final userDoc = ref.read(currentUserDocProvider).value;
    if (userDoc != null) {
      setState(() {
        _fullName = userDoc.fullName;
        _usn = userDoc.usn;
        _batch = userDoc.batch ?? 'Unknown';
        _yearOfStudy = userDoc.yearOfStudy ?? 'Unknown';
        
        _currentProfilePictureUrl = userDoc.profilePictureUrl;
        _phoneNumber = userDoc.phone;
        
        if (userDoc.bio != null) _bioController.text = userDoc.bio!;
        if (userDoc.githubUrl != null) _githubController.text = userDoc.githubUrl!;
        if (userDoc.linkedinUrl != null) _linkedinController.text = userDoc.linkedinUrl!;
        if (userDoc.instagramHandle != null) _instagramController.text = userDoc.instagramHandle!;
        if (userDoc.personalWebsite != null) _websiteController.text = userDoc.personalWebsite!;
        if (userDoc.twitterHandle != null) _twitterController.text = userDoc.twitterHandle!;
        if (userDoc.discordHandle != null) _discordController.text = userDoc.discordHandle!;
      });
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _instagramController.dispose();
    _websiteController.dispose();
    _twitterController.dispose();
    _discordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.borderRadiusFull,
                ),
              ),
              Text(
                'Change Profile Photo',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.accent),
                ),
                title: Text('Take Photo', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.secondary),
                ),
                title: Text('Choose from Gallery', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _phoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid phone number',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSm),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception("User not found");

      String? photoUrl = _currentProfilePictureUrl;
      
      if (_profileImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/${user.uid}.jpg');
        await storageRef.putFile(_profileImage!);
        photoUrl = await storageRef.getDownloadURL();
      }

      final idToken = await user.getIdToken();
      // Call Render backend API for profile update
      final response = await http.put(
        Uri.parse('${RenderApiService.baseUrl}/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'fullName': _fullName,
          'usn': _usn,
          'phone': _phoneNumber,
          'bio': _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
          'githubUrl': _githubController.text.trim().isEmpty ? null : _githubController.text.trim(),
          'linkedinUrl': _linkedinController.text.trim().isEmpty ? null : _linkedinController.text.trim(),
          'instagramHandle': _instagramController.text.trim().isEmpty ? null : _instagramController.text.trim(),
          'personalWebsite': _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
          'twitterHandle': _twitterController.text.trim().isEmpty ? null : _twitterController.text.trim(),
          'discordHandle': _discordController.text.trim().isEmpty ? null : _discordController.text.trim(),
          'profilePictureUrl': photoUrl,
          'flagForHodReview': _flagForHodReview,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update profile: ${response.body}');
      }

      // Invalidate the user doc cache so the profile screen refreshes
      ref.invalidate(currentUserDocProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Profile updated successfully!',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSm),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error: ${e.toString()}',
                    style: GoogleFonts.poppins(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSm),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildProfilePictureSection(),
                            const SizedBox(height: 28),
                            _buildSectionHeader('Identity & Academic Info', Icons.school_rounded),
                            const SizedBox(height: 12),
                            _buildLockedFieldCard(),
                            const SizedBox(height: 24),
                            _buildSectionHeader('Contact & Bio', Icons.person_rounded),
                            const SizedBox(height: 12),
                            _buildContactBioCard(),
                            const SizedBox(height: 24),
                            _buildSectionHeader('Social Links', Icons.link_rounded),
                            const SizedBox(height: 12),
                            _buildSocialLinksCard(),
                            const SizedBox(height: 32),
                            _buildSaveButton(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: AppRadius.borderRadiusSm,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  size: 20, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Edit Profile',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Profile Picture ─────────────────────────────────────────────
  Widget _buildProfilePictureSection() {
    final initials = _fullName.isNotEmpty
        ? _fullName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '??';

    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.aiBadgeGradient,
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 3),
              boxShadow: AppShadows.md,
              image: _profileImage != null
                  ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover)
                  : (_currentProfilePictureUrl != null && _currentProfilePictureUrl!.isNotEmpty
                      ? DecorationImage(image: NetworkImage(_currentProfilePictureUrl!), fit: BoxFit.cover)
                      : null),
            ),
            child: (_profileImage == null && (_currentProfilePictureUrl == null || _currentProfilePictureUrl!.isEmpty))
                ? Center(
                    child: Text(
                      initials,
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showImagePickerSheet,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surfaceElevated, width: 3),
                    boxShadow: AppShadows.sm,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section Header ───────────────────────────────────────────────
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ─── Locked Identity Card ─────────────────────────────────────────
  Widget _buildLockedFieldCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _lockedField('Full Name', _fullName, Icons.badge_rounded),
          const SizedBox(height: 12),
          _lockedField('USN', _usn, Icons.numbers_rounded),
          const SizedBox(height: 12),
          _lockedField('Batch Status', '$_yearOfStudy, AI & ML, $_batch', Icons.school_rounded),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              setState(() {
                _flagForHodReview = !_flagForHodReview;
              });
            },
            borderRadius: AppRadius.borderRadiusSm,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _flagForHodReview
                    ? AppColors.success.withValues(alpha: 0.08)
                    : AppColors.accent.withValues(alpha: 0.06),
                borderRadius: AppRadius.borderRadiusSm,
                border: Border.all(
                  color: _flagForHodReview
                      ? AppColors.success.withValues(alpha: 0.3)
                      : AppColors.accent.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _flagForHodReview ? Icons.check_circle_rounded : Icons.flag_rounded,
                    size: 16,
                    color: _flagForHodReview ? AppColors.success : AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _flagForHodReview
                          ? 'Flagged for HOD review. We will manually verify your details.'
                          : 'Need to update name, USN or batch? Tap to flag for HOD review.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _flagForHodReview ? AppColors.success : AppColors.accent,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lockedField(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: AppRadius.borderRadiusXs,
          ),
          child: Icon(icon, size: 16, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value.isNotEmpty ? value : 'N/A',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: AppRadius.borderRadiusXs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_rounded, size: 10, color: AppColors.textTertiary),
              const SizedBox(width: 2),
              Text(
                'LOCKED',
                style: GoogleFonts.poppins(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Contact & Bio Card ───────────────────────────────────────────
  Widget _buildContactBioCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntlPhoneField(
            decoration: _styledInputDecoration('Phone Number', Icons.phone_rounded),
            initialCountryCode: 'IN',
            initialValue: _phoneNumber?.replaceAll('+91', ''),
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
            onChanged: (phone) {
              _phoneNumber = phone.completeNumber;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bioController,
            decoration: _styledInputDecoration('Bio — tell us about yourself', Icons.edit_note_rounded),
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
            maxLines: 3,
            maxLength: 150,
          ),
        ],
      ),
    );
  }

  // ─── Social Links Card ────────────────────────────────────────────
  Widget _buildSocialLinksCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          _socialField(_githubController, 'GitHub URL', Icons.code_rounded),
          const SizedBox(height: 12),
          _socialField(_linkedinController, 'LinkedIn URL', Icons.business_center_rounded),
          const SizedBox(height: 12),
          _socialField(_twitterController, 'Twitter/X Handle', Icons.alternate_email_rounded),
          const SizedBox(height: 12),
          _socialField(_discordController, 'Discord Handle', Icons.gamepad_rounded),
          const SizedBox(height: 12),
          _socialField(_instagramController, 'Instagram Handle', Icons.camera_alt_rounded),
          const SizedBox(height: 12),
          _socialField(_websiteController, 'Personal Website', Icons.language_rounded),
        ],
      ),
    );
  }

  Widget _socialField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: _styledInputDecoration(label, icon),
      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
    );
  }

  InputDecoration _styledInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: AppColors.textTertiary,
      ),
      prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.primarySurface,
      border: OutlineInputBorder(
        borderRadius: AppRadius.borderRadiusSm,
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderRadiusSm,
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderRadiusSm,
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // ─── Save Button ──────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isSaving ? null : _saveProfile,
        borderRadius: AppRadius.borderRadiusSm,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: _isSaving ? null : AppColors.brandGradient,
            color: _isSaving ? AppColors.textTertiary : null,
            borderRadius: AppRadius.borderRadiusSm,
            boxShadow: _isSaving ? null : AppShadows.accentGlow,
          ),
          child: Center(
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_rounded, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Save Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
