import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_tokens.dart';
import '../features/auth/data/user_doc.dart';
import '../models/project_model.dart';
import '../services/firebase_service.dart';
import '../utils/friendly_error.dart';
import '../widgets/avatar_picker.dart';
import '../widgets/banner_image.dart';
import '../widgets/shared_widgets.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserDocProvider).valueOrNull;

    return StreamBuilder(
      stream: ProjectDoc.collection.doc(projectId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _message(friendlyError(snapshot.error!));
        }
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.data!.exists) return _message('This project was removed.');

        final project = ProjectDoc.fromFirestore(snapshot.data!);
        final isOwner = user?.uid == project.ownerUid;
        final canDelete = isOwner || user?.role == UserRole.hod;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Project Details'),
            actions: [
              if (canDelete)
                IconButton(
                  tooltip: 'Delete project',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(context, project),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              ClipRRect(
                borderRadius: AppRadius.borderRadiusLg,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: project.images.length > 1
                      ? PageView(
                          children: [for (final url in project.images) BannerImage(url: url, icon: Icons.folder_rounded)],
                        )
                      : BannerImage(
                          url: project.images.isNotEmpty ? project.images.first : null,
                          icon: Icons.folder_rounded,
                        ),
                ),
              ),
              const SizedBox(height: 20),
              if (project.lookingForTeammate) ...[
                const TagChip(label: 'Looking for teammates'),
                const SizedBox(height: 12),
              ],
              Text(
                project.title,
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final t in project.techStack) TagChip(label: t, color: AppColors.secondary)],
              ),
              const SizedBox(height: 20),
              Text('Description', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                project.description.isNotEmpty ? project.description : 'No description provided.',
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
              ),
              if (project.repoUrl != null) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => launchUrl(Uri.parse(project.repoUrl!), mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Open repository / demo'),
                ),
              ],
              if (isOwner) ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Looking for teammates'),
                  value: project.lookingForTeammate,
                  onChanged: (v) => ProjectDoc.collection.doc(project.id).update({'lookingForTeammate': v}),
                ),
              ],
              const SizedBox(height: 24),
              Text('Team', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              for (final uid in {project.ownerUid, ...project.contributors})
                _MemberTile(uid: uid, isOwner: uid == project.ownerUid),
            ],
          ),
        );
      },
    );
  }

  Scaffold _message(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project Details')),
      body: EmptyState(icon: Icons.folder_off_outlined, message: message),
    );
  }

  Future<void> _delete(BuildContext context, ProjectDoc project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete project?'),
        content: Text('"${project.title}" will be removed for everyone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ProjectDoc.collection.doc(project.id).delete();
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e)), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

class _MemberTile extends ConsumerWidget {
  final String uid;
  final bool isOwner;

  const _MemberTile({required this.uid, required this.isOwner});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(firebaseServiceProvider).firestore.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        if (data == null) return const SizedBox.shrink();
        final member = UserDoc.fromJson({...data, 'uid': uid});

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            onTap: () => context.push('/directory/profile/$uid'),
            leading: ProfileAvatar(
              avatarId: member.avatarId,
              profilePictureUrl: member.profilePictureUrl,
              initials: member.initials,
              size: 40,
            ),
            title: Text(member.fullName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            subtitle: Text(isOwner ? 'Owner' : 'Contributor'),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        );
      },
    );
  }
}
