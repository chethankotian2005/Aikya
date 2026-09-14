import 'package:flutter/material.dart';

import '../core/theme/app_tokens.dart';

/// Preset avatars (spec §3 tokens only — gradient pairs + icon, no file
/// storage). Chosen instead of photo uploads since Firebase Storage requires
/// the paid Blaze plan; this keeps the app fully on the free Spark plan with
/// zero third-party dependency for images. Catalog order/count (12) must
/// match the web app's lib/avatars.ts and the backend's AVATAR_COUNT.
class AvatarOption {
  final int id;
  final IconData icon;
  final List<Color> gradient;

  const AvatarOption({required this.id, required this.icon, required this.gradient});
}

const _gradients = [
  [AppColors.primary, AppColors.secondary],
  [AppColors.secondary, AppColors.accent],
  [AppColors.primary, AppColors.accent],
  [AppColors.accentHover, AppColors.secondary],
];

const _icons = [
  Icons.rocket_launch_rounded,
  Icons.auto_awesome_rounded,
  Icons.psychology_rounded,
  Icons.school_rounded,
  Icons.menu_book_rounded,
  Icons.code_rounded,
  Icons.memory_rounded,
  Icons.explore_rounded,
  Icons.bolt_rounded,
  Icons.track_changes_rounded,
  Icons.extension_rounded,
  Icons.lightbulb_rounded,
];

final List<AvatarOption> kAvatars = List.generate(
  _icons.length,
  (i) => AvatarOption(id: i + 1, icon: _icons[i], gradient: _gradients[i % _gradients.length]),
);

AvatarOption? avatarById(int? id) {
  if (id == null) return null;
  for (final a in kAvatars) {
    if (a.id == id) return a;
  }
  return null;
}
