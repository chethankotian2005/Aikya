import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_tokens.dart';

/// AI-generated content badge — gradient pill with sparkle icon.
/// Use on any machine-generated content to distinguish from human-entered data.
///
/// Surfaces that require this badge:
/// - Report Generator output
/// - Accreditation Compiler output
/// - Sentiment Rollup / Analysis
/// - Auto-generated event summaries
/// - Any ML/AI-processed data display
class AiBadge extends StatelessWidget {
  final String label;
  const AiBadge({super.key, this.label = 'AI Summary'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: AppColors.aiBadgeGradient,
        borderRadius: AppRadius.borderRadiusFull,
        border: Border.all(color: AppColors.aiBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('✦ ', style: TextStyle(fontSize: 9, color: Colors.white)),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header with title and optional "View all" action.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, AppSpacing.lg, 20, AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded,
                      size: 16, color: AppColors.secondary),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
