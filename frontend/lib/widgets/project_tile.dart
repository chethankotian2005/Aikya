import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_tokens.dart';
import '../models/project_model.dart';
import 'banner_image.dart';
import 'shared_widgets.dart';

/// Masonry tile for a student project (Projects showcase + public profiles).
class ProjectTile extends StatelessWidget {
  final ProjectDoc project;

  const ProjectTile({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/projects/detail/${project.id}'),
      borderRadius: AppRadius.borderRadiusLg,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppRadius.borderRadiusLg,
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    BannerImage(
                      url: project.images.isNotEmpty ? project.images.first : null,
                      icon: Icons.folder_rounded,
                    ),
                    if (project.lookingForTeammate)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: AppRadius.borderRadiusFull,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.person_add_alt_1_rounded, size: 11, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'TEAMMATE',
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  if (project.ownerName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'by ${project.ownerName}',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                  if (project.techStack.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final tech in project.techStack.take(4))
                          TagChip(label: tech, color: AppColors.secondary),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
