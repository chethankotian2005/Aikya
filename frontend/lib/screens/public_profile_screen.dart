import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_tokens.dart';
import '../features/auth/data/user_doc.dart';
import '../models/project_model.dart';
import '../services/firebase_service.dart';
import '../widgets/project_tile.dart';
import '../widgets/shared_widgets.dart';

class PublicProfileScreen extends ConsumerWidget {
  final String uid;

  const PublicProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: FutureBuilder(
          future: ref.read(firebaseServiceProvider).firestore.collection('users').doc(uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data?.data();
            if (snapshot.hasError || data == null) {
              return const Column(
                children: [
                  ScreenHeader(title: 'Profile'),
                  Expanded(
                    child: EmptyState(icon: Icons.person_off_outlined, message: 'This profile could not be loaded.'),
                  ),
                ],
              );
            }

            final user = UserDoc.fromJson({...data, 'uid': uid});
            final privacy = user.privacySettings;

            return Column(
              children: [
                ScreenHeader(title: user.fullName),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    children: [
                      _buildHeader(user),
                      const SizedBox(height: 24),
                      if (privacy.publicBio && (user.bio ?? '').isNotEmpty) ...[
                        _buildBio(user.bio!),
                        const SizedBox(height: 24),
                      ],
                      _buildSocialLinks(user, privacy),
                      if (user.role == UserRole.student) ...[
                        const SizedBox(height: 32),
                        Text('Projects', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        _buildProjects(),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(UserDoc user) {
    final photo = user.profilePictureUrl;
    final subtitle = user.role == UserRole.student
        ? '${user.yearOfStudy ?? '-'} Year · ${user.batch ?? 'AI & ML'}'
        : [user.designation ?? user.role.label, if (user.club != null) user.club].join(' · ');

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.aiBadgeGradient,
            image: photo != null && photo.isNotEmpty
                ? DecorationImage(image: NetworkImage(photo), fit: BoxFit.cover)
                : null,
          ),
          child: photo == null || photo.isEmpty
              ? Center(
                  child: Text(
                    user.initials,
                    style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 16),
        Text(user.fullName, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(subtitle, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)),
        if (user.skills.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [for (final s in user.skills) TagChip(label: s, color: AppColors.secondary)],
          ),
        ],
      ],
    );
  }

  Widget _buildBio(String bio) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(bio, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinks(UserDoc user, PrivacySettings privacy) {
    final links = <(IconData, String, String)>[
      if (privacy.publicGithub && (user.githubUrl ?? '').isNotEmpty) (Icons.code_rounded, 'GitHub', user.githubUrl!),
      if (privacy.publicLinkedin && (user.linkedinUrl ?? '').isNotEmpty)
        (Icons.business_center_rounded, 'LinkedIn', user.linkedinUrl!),
      if (privacy.publicTwitter && (user.twitterHandle ?? '').isNotEmpty)
        (Icons.alternate_email_rounded, 'X', 'https://x.com/${user.twitterHandle!.replaceAll('@', '')}'),
      if (privacy.publicInstagram && (user.instagramHandle ?? '').isNotEmpty)
        (Icons.camera_alt_rounded, 'Instagram', 'https://instagram.com/${user.instagramHandle!.replaceAll('@', '')}'),
      if (privacy.publicPersonalWebsite && (user.personalWebsite ?? '').isNotEmpty)
        (Icons.language_rounded, 'Website', user.personalWebsite!),
    ];
    if (links.isEmpty) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (icon, label, url) in links)
          OutlinedButton.icon(
            onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
            icon: Icon(icon, size: 16),
            label: Text(label),
          ),
      ],
    );
  }

  Widget _buildProjects() {
    return StreamBuilder(
      stream: ProjectDoc.collection.where('ownerUid', isEqualTo: uid).snapshots(),
      builder: (context, snapshot) {
        final projects = snapshot.data?.docs.map(ProjectDoc.fromFirestore).toList() ?? const <ProjectDoc>[];
        if (projects.isEmpty) {
          return Text(
            snapshot.connectionState == ConnectionState.waiting ? 'Loading…' : 'No projects yet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: AppColors.textTertiary),
          );
        }
        return MasonryGridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          itemCount: projects.length,
          itemBuilder: (_, i) => ProjectTile(project: projects[i]),
        );
      },
    );
  }
}
