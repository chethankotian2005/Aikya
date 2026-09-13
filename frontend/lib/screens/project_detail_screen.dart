import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_tokens.dart';
import '../models/project_model.dart';
import '../services/firebase_service.dart';
import '../features/auth/data/user_doc.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final ProjectModel project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImageGallery(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          if (project.lookingForTeammate) _buildTeammateBanner(),
                          if (project.lookingForTeammate) const SizedBox(height: 16),
                          Text(
                            project.title,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTags(),
                          const SizedBox(height: 24),
                          Text(
                            'Description',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            project.description.isNotEmpty ? project.description : 'No description provided.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Contributors',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildContributors(ref),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
              child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Project Details',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    if (project.imageUrls.isEmpty) return const SizedBox.shrink();
    
    // For MVP, just show the first image or a simple horizontal scroll if multiple
    return SizedBox(
      height: 250,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: project.imageUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: MediaQuery.of(context).size.width - 40, // Full width minus padding
            decoration: BoxDecoration(
              borderRadius: AppRadius.borderRadiusLg,
              image: DecorationImage(
                image: AssetImage(project.imageUrls[index]), // Assuming assets for MVP, can use NetworkImage if http
                fit: BoxFit.cover,
              ),
              boxShadow: AppShadows.md,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeammateBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.5),
        borderRadius: AppRadius.borderRadiusSm,
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_add_alt_1_rounded, color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Looking for Teammates',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: project.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: AppRadius.borderRadiusSm,
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            tag,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContributors(WidgetRef ref) {
    final allIds = [project.ownerId, ...project.contributorIds];
    
    return Column(
      children: allIds.map((uid) {
        return FutureBuilder<UserDoc?>(
          future: ref.read(firebaseServiceProvider).firestore
            .collection('users').doc(uid).get()
            .then((doc) => doc.exists ? UserDoc.fromJson({...doc.data()!, 'uid': doc.id}) : null),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
              );
            }
            if (snapshot.hasError || snapshot.data == null) {
              return const SizedBox.shrink(); // Hide if error/not found
            }
            final user = snapshot.data!;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => context.push('/directory/profile/${user.uid}'),
                borderRadius: AppRadius.borderRadiusMd,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: AppRadius.borderRadiusMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryContainer,
                          image: user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty
                              ? DecorationImage(image: NetworkImage(user.profilePictureUrl!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: user.profilePictureUrl == null || user.profilePictureUrl!.isEmpty
                            ? Center(
                                child: Text(
                                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              uid == project.ownerId ? 'Owner' : 'Contributor',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: uid == project.ownerId ? AppColors.accent : AppColors.textTertiary,
                                fontWeight: uid == project.ownerId ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
