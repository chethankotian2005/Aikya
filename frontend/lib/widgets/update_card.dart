import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../core/theme/app_tokens.dart';
import '../models/update_doc.dart';

class UpdateCard extends StatelessWidget {
  final UpdateDoc update;

  const UpdateCard({super.key, required this.update});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Author Avatar Placeholder (initials)
                CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  radius: 20,
                  child: Text(
                    update.authorName.isNotEmpty ? update.authorName[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              update.authorName,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (update.club != null && update.club!.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                borderRadius: AppRadius.borderRadiusSm,
                                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                update.club!.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        '${update.authorDesignation} • ${timeago.format(update.createdAt)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              update.content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Optional Image
          if (update.imageUrl != null && update.imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
              child: ClipRRect(
                borderRadius: AppRadius.borderRadiusSm,
                child: Image.network(
                  update.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: AppColors.primaryContainer,
                    child: const Icon(Icons.broken_image_rounded, color: AppColors.textTertiary),
                  ),
                ),
              ),
            ),

          // Optional Deadline
          if (update.deadlineDate != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderRadiusSm,
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Text(
                      'Deadline: ${_formatDate(update.deadlineDate!)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const SizedBox(height: 4), // Bottom padding if no deadline
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}
