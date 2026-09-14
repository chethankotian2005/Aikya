import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_tokens.dart';
import '../features/auth/data/user_doc.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../models/firestore/attendance_request.dart';
import '../models/firestore/event_doc.dart';
import '../models/firestore/memory_frame_doc.dart';
import '../models/project_model.dart';
import '../services/firebase_service.dart';
import '../utils/friendly_error.dart';
import '../widgets/avatar_picker.dart';
import '../widgets/shared_widgets.dart';
import 'events_hub_screen.dart' show formatEventDate;

String? get _uid => FirebaseAuth.instance.currentUser?.uid;

/// Events the student is registered for, newest registration first.
final myTicketsProvider = StreamProvider.autoDispose<List<EventDoc>>((ref) {
  if (_uid == null) return Stream.value(const []);
  return FirebaseFirestore.instance
      .collectionGroup('registrations')
      .where('studentUid', isEqualTo: _uid)
      .orderBy('registeredAt', descending: true)
      .snapshots()
      .asyncMap((snap) async {
    final docs = await Future.wait(snap.docs.map((reg) => EventDoc.docRef(
          reg.data()['eventId'] as String? ?? reg.reference.parent.parent!.id,
        ).get()));
    return docs.where((d) => d.exists).map(EventDoc.fromFirestore).toList();
  });
});

final myFramesProvider = StreamProvider.autoDispose<List<MemoryFrameDoc>>((ref) {
  if (_uid == null) return Stream.value(const []);
  return MemoryFrameDoc.collection
      .where('uploadedBy', isEqualTo: _uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(MemoryFrameDoc.fromFirestore).toList());
});

final myProjectsProvider = StreamProvider.autoDispose<List<ProjectDoc>>((ref) {
  if (_uid == null) return Stream.value(const []);
  return ProjectDoc.collection
      .where('ownerUid', isEqualTo: _uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(ProjectDoc.fromFirestore).toList());
});

final myAttendanceProvider = StreamProvider.autoDispose<List<AttendanceRequestDoc>>((ref) {
  if (_uid == null) return Stream.value(const []);
  return AttendanceRequestDoc.collection
      .where('studentId', isEqualTo: _uid)
      .snapshots()
      .map((snap) => snap.docs.map(AttendanceRequestDoc.fromFirestore).toList()
        ..sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now())));
});

/// "My Dashboard": profile header plus tickets, uploads and attendance (spec §6).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _loggingOut = false;

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to use AIKYA.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _loggingOut = true);
    await ref.read(authControllerProvider.notifier).logout();
    // The router sends the user to /login once auth state clears.
    if (mounted) setState(() => _loggingOut = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDocProvider).valueOrNull;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final isStudent = user.role == UserRole.student;
    final tabs = isStudent ? const ['My Tickets', 'My Uploads', 'Attendance'] : const ['My Uploads'];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: NestedScrollView(
            headerSliverBuilder: (_, __) => [
              const SliverToBoxAdapter(child: ScreenHeader(title: 'My Dashboard')),
              SliverToBoxAdapter(child: _buildHeader(user)),
              SliverToBoxAdapter(child: _buildActions(user)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: TabBar(
                    isScrollable: false,
                    indicatorColor: AppColors.accent,
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textTertiary,
                    labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                    tabs: [for (final t in tabs) Tab(text: t)],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              children: [
                if (isStudent) const _TicketsTab(),
                _UploadsTab(isStudent: isStudent),
                if (isStudent) const _AttendanceTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UserDoc user) {
    final details = user.role == UserRole.student
        ? ['USN ${user.usn}', '${user.yearOfStudy ?? '-'} Year', if (user.batch != null) user.batch!]
        : [user.designation ?? user.role.label, if (user.club != null) user.club!, if (user.facultyId != null) 'ID ${user.facultyId}'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              ProfileAvatar(avatarId: user.avatarId, initials: user.initials, size: 72),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    TagChip(label: user.role.label),
                    const SizedBox(height: 4),
                    Text(
                      details.join(' · '),
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    if (user.status == 'pending_batch_review')
                      Text(
                        'Batch details pending HOD review',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.warning),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(UserDoc user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ElevatedButton.icon(
            onPressed: () => context.push('/profile/edit'),
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: const Text('Edit Profile'),
          ),
          if (user.role.isStaff)
            OutlinedButton.icon(
              onPressed: () => context.push('/create_update'),
              icon: const Icon(Icons.campaign_outlined, size: 16),
              label: const Text('Post Update'),
            ),
          if (user.role.canBuildEvents)
            OutlinedButton.icon(
              onPressed: () => context.push('/admin'),
              icon: const Icon(Icons.admin_panel_settings_outlined, size: 16),
              label: const Text('Admin Panel'),
            ),
          OutlinedButton.icon(
            onPressed: _loggingOut ? null : _logout,
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
            icon: const Icon(Icons.logout_rounded, size: 16),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

Widget _asyncList<T>(
  AsyncValue<List<T>> value, {
  required IconData emptyIcon,
  required String emptyMessage,
  required Widget Function(List<T>) builder,
}) {
  return value.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (e, _) => EmptyState(icon: Icons.error_outline, message: friendlyError(e)),
    data: (list) => list.isEmpty ? EmptyState(icon: emptyIcon, message: emptyMessage) : builder(list),
  );
}

class _TicketsTab extends ConsumerWidget {
  const _TicketsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _asyncList(
      ref.watch(myTicketsProvider),
      emptyIcon: Icons.confirmation_number_outlined,
      emptyMessage: 'No tickets yet. Register for an event from the Events Hub.',
      builder: (events) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: events.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final event = events[i];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              onTap: () => context.push('/events/${event.id}'),
              title: Text(event.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(formatEventDate(event.eventDate)),
                    Text(event.venue),
                    const SizedBox(height: 6),
                    Text(
                      'Registration #${event.id.substring(0, event.id.length.clamp(0, 6)).toUpperCase()}',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textTertiary, letterSpacing: 1),
                    ),
                  ],
                ),
              ),
              trailing: TagChip(
                label: event.isPast ? 'Past' : 'Upcoming',
                color: event.isPast ? AppColors.textTertiary : AppColors.accent,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UploadsTab extends ConsumerWidget {
  final bool isStudent;
  const _UploadsTab({required this.isStudent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frames = ref.watch(myFramesProvider).valueOrNull ?? const [];
    final projects = isStudent ? ref.watch(myProjectsProvider).valueOrNull ?? const [] : const <ProjectDoc>[];

    if (frames.isEmpty && projects.isEmpty) {
      return EmptyState(
        icon: Icons.cloud_upload_outlined,
        message: isStudent
            ? 'Nothing uploaded yet. Submit a project or share a memory.'
            : 'Nothing uploaded yet. Share a memory from the Memory Wall.',
        action: OutlinedButton(onPressed: () => context.push('/memory'), child: const Text('Open Memory Wall')),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        if (projects.isNotEmpty) ...[
          Text('Projects', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final p in projects)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => context.push('/projects/detail/${p.id}'),
                leading: const Icon(Icons.folder_rounded, color: AppColors.secondary),
                title: Text(p.title),
                subtitle: Text(p.techStack.join(', ')),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
          const SizedBox(height: 16),
        ],
        if (frames.isNotEmpty) ...[
          Text('Memory Wall uploads', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (final f in frames)
                ClipRRect(
                  borderRadius: AppRadius.borderRadiusMd,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(f.imageUrl, fit: BoxFit.cover),
                      Positioned(
                        left: 4,
                        bottom: 4,
                        child: TagChip(
                          label: f.status.name,
                          color: switch (f.status) {
                            FrameStatus.approved => AppColors.success,
                            FrameStatus.rejected => AppColors.error,
                            FrameStatus.pending => AppColors.warning,
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _AttendanceTab extends ConsumerWidget {
  const _AttendanceTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(myAttendanceProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showNewRequestDialog(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New attendance / OD request'),
            ),
          ),
        ),
        Expanded(
          child: _asyncList(
            requests,
            emptyIcon: Icons.fact_check_outlined,
            emptyMessage: 'No attendance requests yet.',
            builder: (list) => ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _AttendanceCard(request: list[i]),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showNewRequestDialog(BuildContext context, WidgetRef ref) async {
    final events = ref.read(myTicketsProvider).valueOrNull ?? const [];
    if (events.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Register for an event first — requests are tied to an event.')),
      );
      return;
    }

    String eventId = events.first.id;
    final detailsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Attendance request'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: eventId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Event'),
                items: [
                  for (final e in events)
                    DropdownMenuItem(value: e.id, child: Text(e.title, overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) => eventId = v ?? eventId,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: detailsController,
                minLines: 3,
                maxLines: 5,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Details',
                  hintText: 'Which classes did you miss and why?',
                ),
                validator: (v) => (v ?? '').trim().length < 10 ? 'Please add a little more detail' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    final details = detailsController.text.trim();
    detailsController.dispose();
    if (submitted != true || _uid == null) return;

    try {
      await AttendanceRequestDoc.collection.add(AttendanceRequestDoc.newRequest(
        studentId: _uid!,
        eventId: eventId,
        requestDetails: details,
      ));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent to the HOD for review.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e)), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

class _AttendanceCard extends StatelessWidget {
  final AttendanceRequestDoc request;
  const _AttendanceCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final color = switch (request.status) {
      'approved' => AppColors.success,
      'rejected' => AppColors.error,
      _ => AppColors.warning,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: EventDoc.docRef(request.eventId).get(),
              builder: (context, snapshot) => Row(
                children: [
                  Expanded(
                    child: Text(
                      snapshot.data?.data()?['title'] as String? ?? 'Event',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    ),
                  ),
                  TagChip(label: request.status, color: color),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(request.requestDetails, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
            if ((request.reviewNotes ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'HOD note: ${request.reviewNotes}',
                style: GoogleFonts.poppins(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
