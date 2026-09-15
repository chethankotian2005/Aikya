import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_tokens.dart';
import '../../features/auth/data/user_doc.dart';
import '../../models/firestore/event_doc.dart';
import '../../services/firebase_service.dart';
import '../../services/render_api_service.dart';
import '../../utils/friendly_error.dart';
import '../../widgets/shared_widgets.dart';
import '../events_hub_screen.dart' show formatEventDate;

/// Events the caller can manage: the HOD sees all, coordinators their own.
final manageableEventsProvider = StreamProvider.autoDispose<List<EventDoc>>((ref) {
  final user = ref.watch(currentUserDocProvider).valueOrNull;
  if (user == null) return Stream.value(const []);

  final query = user.role == UserRole.hod
      ? EventDoc.collection.orderBy('eventDate', descending: true).limit(100)
      : EventDoc.collection
          .where('createdBy', isEqualTo: user.uid)
          .orderBy('eventDate', descending: true)
          .limit(100);

  return query.snapshots().map((snap) => snap.docs.map(EventDoc.fromFirestore).toList());
});

class AdminManageEventsView extends ConsumerWidget {
  const AdminManageEventsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(manageableEventsProvider);
    final isHod = ref.watch(currentUserDocProvider).valueOrNull?.role == UserRole.hod;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/events/new'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New event'),
      ),
      body: events.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(icon: Icons.error_outline, message: friendlyError(e)),
        data: (list) => list.isEmpty
            ? const EmptyState(
                icon: Icons.event_busy_rounded,
                message: 'No events yet. Create one to start accepting registrations.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _EventRow(event: list[i], isHod: isHod),
              ),
      ),
    );
  }
}

class _EventRow extends ConsumerStatefulWidget {
  final EventDoc event;
  final bool isHod;
  const _EventRow({required this.event, required this.isHod});

  @override
  ConsumerState<_EventRow> createState() => _EventRowState();
}

class _EventRowState extends ConsumerState<_EventRow> {
  bool _busy = false;
  bool _generatingSheet = false;

  Future<void> _downloadAttendanceSheet(BuildContext context) async {
    setState(() => _generatingSheet = true);
    try {
      final url = await ref.read(renderApiServiceProvider).generateAttendanceSheet(eventId: widget.event.id);
      if (url.isNotEmpty) await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e)), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _generatingSheet = false);
    }
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text('"${widget.event.title}" and its registration count will be removed.'),
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
    if (confirmed != true) return;

    try {
      await EventDoc.docRef(widget.event.id).delete();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e)), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _review(bool approve) async {
    var note = '';
    if (!approve) {
      final controller = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Reject this event?'),
          content: TextField(
            controller: controller,
            maxLength: 300,
            decoration: const InputDecoration(labelText: 'Reason (optional, sent to the coordinator)'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Reject'),
            ),
          ],
        ),
      );
      note = controller.text.trim();
      controller.dispose();
      if (confirmed != true) return;
    }

    setState(() => _busy = true);
    try {
      await ref.read(renderApiServiceProvider).reviewEvent(eventId: widget.event.id, approve: approve, note: note);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e)), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            onTap: () => context.push('/events/${event.id}'),
            title: Text(event.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(formatEventDate(event.eventDate), style: GoogleFonts.poppins(fontSize: 12)),
                  if (event.isPending)
                    const TagChip(label: 'Awaiting HOD approval', color: AppColors.warning)
                  else if (event.isRejected)
                    const TagChip(label: 'Rejected', color: AppColors.error)
                  else
                    TagChip(
                      label: event.isPast ? 'Past' : 'Upcoming',
                      color: event.isPast ? AppColors.textTertiary : AppColors.success,
                    ),
                  TagChip(label: '${event.filledSeats}/${event.totalSeats} seats', color: AppColors.secondary),
                  if (event.reportMarkdown != null) const AiBadge(label: 'Report ready'),
                ],
              ),
            ),
            trailing: PopupMenuButton<String>(
              tooltip: 'Event actions',
              onSelected: (action) {
                switch (action) {
                  case 'edit':
                    context.push('/admin/events/edit/${event.id}');
                  case 'scan':
                    context.push('/admin/scan-attendance', extra: {
                      'eventId': event.id,
                      'eventTitle': event.title,
                      'sessions': event.sessions,
                    });
                  case 'sheet':
                    _downloadAttendanceSheet(context);
                  case 'report':
                    context.push('/admin/report', extra: event.id);
                  case 'delete':
                    _delete(context);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'scan', child: Text('Scan attendance')),
                PopupMenuItem(
                  value: 'sheet',
                  enabled: !_generatingSheet,
                  child: Text(_generatingSheet ? 'Generating…' : 'Attendance sheet'),
                ),
                const PopupMenuItem(value: 'report', child: Text('Generate report')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
          if (event.isRejected && event.reviewNotes != null && event.reviewNotes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'HOD note: ${event.reviewNotes}',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
              ),
            ),
          if (widget.isHod && event.isPending)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : () => _review(false),
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _busy ? null : () => _review(true),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
