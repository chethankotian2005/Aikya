import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/theme/app_tokens.dart';
import '../../models/firestore/attendance_request.dart';
import '../../models/firestore/event_doc.dart';
import '../../services/firebase_service.dart';
import '../../services/render_api_service.dart';
import '../../utils/friendly_error.dart';
import '../../widgets/shared_widgets.dart';

final _pendingRequestsProvider = StreamProvider.autoDispose<List<AttendanceRequestDoc>>((ref) {
  return AttendanceRequestDoc.collection
      .where('status', isEqualTo: 'pending')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(AttendanceRequestDoc.fromFirestore).toList());
});

/// HOD attendance/OD request workspace — decisions go through the backend
/// so the student is notified.
class AdminAttendanceRequestsView extends ConsumerStatefulWidget {
  const AdminAttendanceRequestsView({super.key});

  @override
  ConsumerState<AdminAttendanceRequestsView> createState() => _AdminAttendanceRequestsViewState();
}

class _AdminAttendanceRequestsViewState extends ConsumerState<AdminAttendanceRequestsView> {
  final Set<String> _busy = {};

  Future<void> _review(AttendanceRequestDoc request, bool approve) async {
    var note = '';
    if (!approve) {
      final controller = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Reject request?'),
          content: TextField(
            controller: controller,
            maxLength: 300,
            decoration: const InputDecoration(labelText: 'Reason (sent to the student)'),
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

    setState(() => _busy.add(request.id));
    try {
      await ref.read(renderApiServiceProvider).reviewAttendance(requestId: request.id, approve: approve, note: note);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e)), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _busy.remove(request.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(_pendingRequestsProvider);

    return requests.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(icon: Icons.error_outline, message: friendlyError(e)),
      data: (list) => list.isEmpty
          ? const EmptyState(icon: Icons.done_all_rounded, message: 'All caught up — no pending requests.')
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _card(list[i]),
            ),
    );
  }

  Widget _card(AttendanceRequestDoc request) {
    final busy = _busy.contains(request.id);
    final db = ref.read(firebaseServiceProvider).firestore;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: Future.wait([
                db.collection('users').doc(request.studentId).get(),
                EventDoc.docRef(request.eventId).get(),
              ]),
              builder: (context, snapshot) {
                final student = snapshot.data?[0].data();
                final event = snapshot.data?[1].data();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student?['fullName'] as String? ?? 'Student',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      [student?['usn'] as String? ?? '', event?['title'] as String? ?? 'Event']
                          .where((s) => s.isNotEmpty)
                          .join(' · '),
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Text(request.requestDetails, style: GoogleFonts.poppins(fontSize: 13, height: 1.5)),
            if (request.createdAt != null)
              Text(
                'Submitted ${timeago.format(request.createdAt!)}',
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textTertiary),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy ? null : () => _review(request, false),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: busy ? null : () => _review(request, true),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
