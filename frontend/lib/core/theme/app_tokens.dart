import 'package:flutter/material.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// AIKYA Design Tokens — LOCKED
///
/// Canonical color, spacing, radius, shadow values extracted from the AIKYA
/// logo (runner + signal-wave + silhouette marks, navy-to-blue gradient,
/// rounded "Ikya" wordmark on white).
///
/// DO NOT add ad-hoc hex values. Reference these tokens everywhere.
/// ──────────────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────────
  /// Deep navy — headers, nav bars, primary text on light bg
  static const primary = Color(0xFF0E1B3D);

  /// Mid blue — primary buttons, active states, links
  static const secondary = Color(0xFF1F5C99);

  /// Sky blue — highlights, progress bars, chips, AI badges
  static const accent = Color(0xFF3B9AE1);

  static const accentMuted = Color(0x1A3B9AE1); // 10% opacity
  static const accentHover = Color(0xFF2D8AD1);

  /// Neutral black — echoing the profile-silhouette mark.
  /// Icon outlines, dark-mode surface. **NOT body text.**
  static const neutralBlack = Color(0xFF0A0A0A);

  // ── Surfaces ───────────────────────────────────────────────────────────────
  static const onPrimary = Color(0xFFFFFFFF);
  static const primarySurface = Color(0xFFF0F3F8);
  static const primaryContainer = Color(0xFFE1E8F2);
  static const surfaceElevated = Color(0xFFFFFFFF);
  static const border = Color(0xFFD8DFE8);

  /// Dark-mode background
  static const darkSurface = Color(0xFF0B0F1F);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFF0E1B3D);
  static const textSecondary = Color(0xFF4A5A7A);
  static const textTertiary = Color(0xFF8A96B0);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const success = Color(0xFF2ECC71);
  static const warning = Color(0xFFF0A500);
  static const error = Color(0xFFE74C3C);
  static const info = Color(0xFF1F5C99); // mirrors secondary

  // ── AI Badge ───────────────────────────────────────────────────────────────
  static const aiBadgeStart = Color(0xFF1F5C99); // mid blue
  static const aiBadgeEnd = Color(0xFF3B9AE1); // sky blue
  static const aiBorder = Color(0x331F5C99); // 20% mid blue

  // ── Brand Gradient (logo runner: navy → mid blue → sky blue) ───────────────
  static const brandGradientStart = Color(0xFF0E1B3D);
  static const brandGradientMid = Color(0xFF1F5C99);
  static const brandGradientEnd = Color(0xFF3B9AE1);

  static const brandGradient = LinearGradient(
    begin: Alignment(-0.4, -1),
    end: Alignment(0.4, 1),
    colors: [brandGradientStart, brandGradientMid, brandGradientEnd],
  );

  /// Hero gradient — alias for brand gradient (used on splash, nav hero areas)
  static const heroGradient = brandGradient;

  static const aiBadgeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [aiBadgeStart, aiBadgeEnd],
  );

  /// Signal-wave motif overlay (thin arcs at 6% opacity, splash/auth/empty)
  static const waveMotifGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x0F1F5C99), // ~6% mid blue
      Color(0x0F3B9AE1), // ~6% sky blue
    ],
  );
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  AppRadius._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double full = 999;

  static final borderRadiusXs = BorderRadius.circular(xs);
  static final borderRadiusSm = BorderRadius.circular(sm);
  static final borderRadiusMd = BorderRadius.circular(md);
  static final borderRadiusLg = BorderRadius.circular(lg);
  static final borderRadiusXl = BorderRadius.circular(xl);
  static final borderRadiusFull = BorderRadius.circular(full);
}

class AppShadows {
  AppShadows._();

  /// Subtle lift — hoverable items
  static const sm = [
    BoxShadow(color: Color(0x0F0E1B3D), blurRadius: 3, offset: Offset(0, 1)),
  ];

  /// Standard elevation — cards, dropdowns
  static const md = [
    BoxShadow(color: Color(0x140E1B3D), blurRadius: 12, offset: Offset(0, 4)),
  ];

  /// Prominent — modals, floating panels
  static const lg = [
    BoxShadow(color: Color(0x1F0E1B3D), blurRadius: 24, offset: Offset(0, 8)),
  ];

  /// Accent glow — CTA buttons on hover, active AI elements
  static const accentGlow = [
    BoxShadow(color: Color(0x403B9AE1), blurRadius: 16, offset: Offset(0, 4)),
  ];
}
