import 'package:flutter/material.dart';

import '../core/theme/app_tokens.dart';
import 'avatars.dart';

class AvatarPicker extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;

  const AvatarPicker({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        for (final a in kAvatars)
          Semantics(
            button: true,
            selected: a.id == value,
            label: 'Avatar ${a.id}',
            child: InkWell(
              onTap: () => onChanged(a.id),
              borderRadius: AppRadius.borderRadiusFull,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: a.gradient,
                  ),
                  border: a.id == value
                      ? Border.all(color: AppColors.accent, width: 3)
                      : Border.all(color: Colors.transparent, width: 3),
                ),
                child: Icon(a.icon, color: Colors.white, size: 28),
              ),
            ),
          ),
      ],
    );
  }
}

/// Renders a user's chosen avatar, falling back to initials when none is set.
class ProfileAvatar extends StatelessWidget {
  final int? avatarId;
  final String initials;
  final double size;

  const ProfileAvatar({super.key, required this.avatarId, required this.initials, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final avatar = avatarById(avatarId);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: avatar?.gradient ?? const [AppColors.aiBadgeStart, AppColors.aiBadgeEnd],
        ),
      ),
      child: avatar != null
          ? Icon(avatar.icon, color: Colors.white, size: size * 0.5)
          : Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: size * 0.36,
                ),
              ),
            ),
    );
  }
}
