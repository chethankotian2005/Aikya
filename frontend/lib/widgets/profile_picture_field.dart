import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_tokens.dart';
import 'avatar_picker.dart';

enum PictureMode { avatar, photo }

/// Lets a user pick a preset avatar (no upload, no storage cost) or upload
/// their own photo through Cloudinary (POST /api/upload-image). The two are
/// mutually exclusive — the caller sends `avatarId: null` when mode is
/// photo and `profilePictureUrl: null` when mode is avatar so the stored
/// profile never has both set at once.
class ProfilePictureField extends StatelessWidget {
  final PictureMode mode;
  final ValueChanged<PictureMode> onModeChanged;
  final int? avatarId;
  final ValueChanged<int> onAvatarChanged;
  final XFile? photoFile;
  final Uint8List? photoPreviewBytes;
  final ValueChanged<XFile?> onPhotoChanged;
  final String? existingPhotoUrl;

  const ProfilePictureField({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.avatarId,
    required this.onAvatarChanged,
    required this.photoFile,
    required this.photoPreviewBytes,
    required this.onPhotoChanged,
    required this.existingPhotoUrl,
  });

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1200);
    if (picked != null) onPhotoChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: AppRadius.borderRadiusFull),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _modeTab('Avatar', PictureMode.avatar),
              _modeTab('Upload photo', PictureMode.photo),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (mode == PictureMode.avatar)
          AvatarPicker(value: avatarId, onChanged: onAvatarChanged)
        else
          GestureDetector(
            onTap: _pickPhoto,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer,
                image: photoPreviewBytes != null
                    ? DecorationImage(image: MemoryImage(photoPreviewBytes!), fit: BoxFit.cover)
                    : existingPhotoUrl != null
                        ? DecorationImage(image: NetworkImage(existingPhotoUrl!), fit: BoxFit.cover)
                        : null,
              ),
              child: photoPreviewBytes == null && existingPhotoUrl == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: AppColors.accent, size: 24),
                        SizedBox(height: 6),
                        Text('Choose a photo', style: TextStyle(fontSize: 11)),
                      ],
                    )
                  : null,
            ),
          ),
      ],
    );
  }

  Widget _modeTab(String label, PictureMode value) {
    final selected = mode == value;
    return GestureDetector(
      onTap: () => onModeChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : Colors.transparent,
          borderRadius: AppRadius.borderRadiusFull,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
