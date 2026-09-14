import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/theme/app_tokens.dart';
import '../../models/firestore/memory_frame_doc.dart';
import '../../services/render_api_service.dart';
import '../../utils/friendly_error.dart';
import '../../widgets/shared_widgets.dart';

final _pendingFramesProvider = StreamProvider.autoDispose<List<MemoryFrameDoc>>((ref) {
  return MemoryFrameDoc.collection
      .where('status', isEqualTo: FrameStatus.pending.name)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(MemoryFrameDoc.fromFirestore).toList());
});

/// HOD photo moderation queue — approvals go through the backend so the
/// uploader gets a push notification.
class AdminModerationQueueView extends ConsumerStatefulWidget {
  const AdminModerationQueueView({super.key});

  @override
  ConsumerState<AdminModerationQueueView> createState() => _AdminModerationQueueViewState();
}

class _AdminModerationQueueViewState extends ConsumerState<AdminModerationQueueView> {
  final Set<String> _busy = {};

  Future<void> _review(MemoryFrameDoc frame, bool approve) async {
    var note = '';
    if (!approve) {
      final controller = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Reject this photo?'),
          content: TextField(
            controller: controller,
            maxLength: 300,
            decoration: const InputDecoration(labelText: 'Reason (optional, sent to the uploader)'),
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

    setState(() => _busy.add(frame.id));
    try {
      await ref.read(renderApiServiceProvider).reviewMemoryFrame(memoryId: frame.id, approve: approve, note: note);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e)), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _busy.remove(frame.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final frames = ref.watch(_pendingFramesProvider);

    return frames.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(icon: Icons.error_outline, message: friendlyError(e)),
      data: (list) => list.isEmpty
          ? const EmptyState(icon: Icons.check_circle_outline_rounded, message: 'Queue is clear — nothing to review.')
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 360,
                childAspectRatio: 0.72,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: list.length,
              itemBuilder: (_, i) => _card(list[i]),
            ),
    );
  }

  Widget _card(MemoryFrameDoc frame) {
    final busy = _busy.contains(frame.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: Image.network(frame.imageUrl, fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(frame.uploaderName, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                if (frame.caption.isNotEmpty)
                  Text(frame.caption, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12)),
                Text(
                  [
                    if (frame.eventName.isNotEmpty) frame.eventName,
                    if (frame.createdAt != null) timeago.format(frame.createdAt!),
                  ].join(' · '),
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textTertiary),
                ),
                if (frame.reportMarkdown != null) ...[
                  const SizedBox(height: 4),
                  const AiBadge(label: 'Includes report'),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy ? null : () => _review(frame, false),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: busy ? null : () => _review(frame, true),
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
