import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_tokens.dart';
import '../services/firebase_service.dart';
import '../features/auth/data/user_doc.dart';
import '../models/project_model.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PublicProfileScreen extends ConsumerWidget {
  final String uid;

  const PublicProfileScreen({super.key, required this.uid});

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<UserDoc?>(
          future: ref.read(firebaseServiceProvider).firestore
            .collection('users').doc(uid).get()
            .then((doc) => doc.exists ? UserDoc.fromJson({...doc.data()!, 'uid': doc.id}) : null),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.accent));
            }
            if (snapshot.hasError || snapshot.data == null) {
              return _buildErrorState(context);
            }
            final user = snapshot.data!;
            final pSettings = user.privacySettings;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAppBar(context, user.fullName),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    child: Column(
                      children: [
                        _buildProfileHeader(user),
                        const SizedBox(height: 24),
                        if (pSettings.publicBio && user.bio != null && user.bio!.isNotEmpty) ...[
                          _buildBioSection(user.bio!),
                          const SizedBox(height: 24),
                        ],
                        _buildSocialLinks(user, pSettings),
                        const SizedBox(height: 32),
                        _buildProjectsSection(user.uid),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Column(
      children: [
        _buildAppBar(context, 'Profile Not Found'),
        const Expanded(
          child: Center(
            child: Text('User profile could not be loaded.', style: TextStyle(color: AppColors.error)),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserDoc user) {
    final initials = user.fullName.isNotEmpty
        ? user.fullName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '??';

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.aiBadgeGradient,
            image: user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty
                ? DecorationImage(image: NetworkImage(user.profilePictureUrl!), fit: BoxFit.cover)
                : null,
          ),
          child: user.profilePictureUrl == null || user.profilePictureUrl!.isEmpty
              ? Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          user.fullName,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${user.yearOfStudy ?? '-'} Year, ${user.batch ?? '-'}',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        if (user.skills.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: user.skills.map((s) => _buildSkillChip(s)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: Text(
        skill,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildBioSection(String bio) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                'About',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bio,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks(UserDoc user, PrivacySettings settings) {
    List<Widget> buttons = [];
    
    if (settings.publicGithub && user.githubUrl != null && user.githubUrl!.isNotEmpty) {
      buttons.add(_buildSocialButton(Icons.code_rounded, 'GitHub', user.githubUrl!));
    }
    if (settings.publicLinkedin && user.linkedinUrl != null && user.linkedinUrl!.isNotEmpty) {
      buttons.add(_buildSocialButton(Icons.business_center_rounded, 'LinkedIn', user.linkedinUrl!));
    }
    if (settings.publicTwitter && user.twitterHandle != null && user.twitterHandle!.isNotEmpty) {
      buttons.add(_buildSocialButton(Icons.alternate_email_rounded, 'Twitter', 'https://twitter.com/${user.twitterHandle!}'));
    }
    if (settings.publicInstagram && user.instagramHandle != null && user.instagramHandle!.isNotEmpty) {
      buttons.add(_buildSocialButton(Icons.camera_alt_rounded, 'Instagram', 'https://instagram.com/${user.instagramHandle!}'));
    }
    if (settings.publicPersonalWebsite && user.personalWebsite != null && user.personalWebsite!.isNotEmpty) {
      buttons.add(_buildSocialButton(Icons.language_rounded, 'Website', user.personalWebsite!));
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons.map((b) => Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: b)).toList(),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, String url) {
    return InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 20, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildProjectsSection(String uid) {
    // In a real app, we'd query Firestore for projects where ownerId == uid OR contributorIds array-contains uid.
    // For now, mock filtering from sampleProjects based on ownerId or contributorIds.
    final projects = sampleProjects.where((p) => p.ownerId == uid || p.contributorIds.contains(uid)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Projects',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        if (projects.isEmpty)
          Center(
            child: Text(
              'No public projects yet.',
              style: GoogleFonts.poppins(color: AppColors.textTertiary),
            ),
          )
        else
          MasonryGridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            itemCount: projects.length,
            itemBuilder: (context, index) => _ProjectTile(project: projects[index]),
          ),
      ],
    );
  }
}

// Reuse the Tile
class _ProjectTile extends StatelessWidget {
  final ProjectModel project;

  const _ProjectTile({required this.project});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/projects/detail/${project.id}', extra: project),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1 / project.imageHeightMultiplier,
                  child: Image.asset(
                    project.imageUrls.isNotEmpty ? project.imageUrls.first : 'assets/images/placeholder.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                if (project.lookingForTeammate)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.85),
                        borderRadius: AppRadius.borderRadiusFull,
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_add_alt_1_rounded, size: 10, color: AppColors.accent),
                          const SizedBox(width: 4),
                          Text(
                            'TEAMMATE',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'by ${project.author}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
