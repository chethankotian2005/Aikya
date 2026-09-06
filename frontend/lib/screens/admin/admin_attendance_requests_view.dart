import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../core/theme/app_tokens.dart';
import '../../features/admin/data/attendance_request_doc.dart';
import '../../features/auth/data/user_doc.dart';
import '../../features/events/data/event_doc.dart';

class AttendanceRequestPresentationData {
  final AttendanceRequestDoc request;
  final UserDoc? user;
  final EventDoc? event;

  AttendanceRequestPresentationData({
    required this.request,
    required this.user,
    required this.event,
  });
}

class AdminAttendanceRequestsView extends StatefulWidget {
  const AdminAttendanceRequestsView({super.key});

  @override
  State<AdminAttendanceRequestsView> createState() => _AdminAttendanceRequestsViewState();
}

class _AdminAttendanceRequestsViewState extends State<AdminAttendanceRequestsView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final PagingController<DocumentSnapshot?, AttendanceRequestPresentationData> _pagingController =
      PagingController(firstPageKey: null);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(DocumentSnapshot? pageKey) async {
    try {
      const pageSize = 15;
      Query query = _firestore
          .collectionGroup('attendanceRequests') // it's a subcollection under events
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .limit(pageSize);

      if (pageKey != null) {
        query = query.startAfterDocument(pageKey);
      }

      final snap = await query.get();
      final isLastPage = snap.docs.length < pageSize;

      List<AttendanceRequestPresentationData> newItems = [];
      for (var doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final request = AttendanceRequestDoc.fromJson({'id': doc.id, ...data});

        final userSnap = await _firestore.collection('users').doc(request.studentId).get();
        UserDoc? userDoc;
        if (userSnap.exists) {
          userDoc = UserDoc.fromJson({'id': userSnap.id, ...userSnap.data()!});
        }

        final eventSnap = await _firestore.collection('events').doc(request.eventId).get();
        EventDoc? eventDoc;
        if (eventSnap.exists) {
          eventDoc = EventDoc.fromJson({'id': eventSnap.id, ...eventSnap.data()!});
        }

        newItems.add(AttendanceRequestPresentationData(
          request: request,
          user: userDoc,
          event: eventDoc,
        ));
      }

      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        _pagingController.appendPage(newItems, snap.docs.last);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _handleApprove(String id, String eventId) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('attendanceRequests')
          .doc(id)
          .update({'status': 'approved', 'updatedAt': FieldValue.serverTimestamp()});
      _pagingController.refresh();
    } catch (e) {
      // Show error
    }
  }

  void _handleReject(String id, String eventId, String note) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('attendanceRequests')
          .doc(id)
          .update({
        'status': 'rejected',
        'reviewNotes': note,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _pagingController.refresh();
    } catch (e) {
      // Show error
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primarySurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Requests',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Review and approve leave or duty attendance for students.',
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Expanded(
            child: PagedListView<DocumentSnapshot?, AttendanceRequestPresentationData>(
              pagingController: _pagingController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              builderDelegate: PagedChildBuilderDelegate<AttendanceRequestPresentationData>(
                itemBuilder: (context, data, index) {
                  return _RequestCard(
                    data: data,
                    onApprove: () => _handleApprove(data.request.id, data.request.eventId),
                    onReject: (note) => _handleReject(data.request.id, data.request.eventId, note),
                  );
                },
                noItemsFoundIndicatorBuilder: (_) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.done_all_rounded, size: 64, color: AppColors.textTertiary),
                      const SizedBox(height: 16),
                      Text('All caught up!',
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text('No pending attendance requests.',
                          style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                firstPageErrorIndicatorBuilder: (_) => const Center(
                  child: Text('Failed to load pending requests.'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatefulWidget {
  final AttendanceRequestPresentationData data;
  final VoidCallback onApprove;
  final Function(String) onReject;

  const _RequestCard({
    required this.data,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _isExpanded = false;
  bool _isRejecting = false;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _toggleExpand() => setState(() => _isExpanded = !_isExpanded);
  void _handleRejectInitiate() => setState(() => _isRejecting = true);
  void _handleConfirmReject() => widget.onReject(_noteController.text.trim());

  String _formatDate(DateTime dt) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.data.request;
    final user = widget.data.user;
    final event = widget.data.event;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(
          color: _isRejecting ? AppColors.error.withValues(alpha: 0.5) : AppColors.border,
        ),
        boxShadow: AppShadows.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'Unknown Student',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            user?.usn ?? 'Unknown USN',
                            style: GoogleFonts.robotoMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.15),
                                borderRadius: AppRadius.borderRadiusXs,
                              ),
                              child: Text(
                                event?.title ?? 'Unknown Event',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (event != null)
                  Text(
                    _formatDate(event.eventDate),
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _toggleExpand,
              child: AnimatedCrossFade(
                firstChild: Text(
                  req.requestDetails,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                ),
                secondChild: Text(
                  req.requestDetails,
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                ),
                crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: _toggleExpand,
              child: Text(
                _isExpanded ? 'Show less' : 'Read more',
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent),
              ),
            ),
            const SizedBox(height: 20),
            if (_isRejecting) ...[
              TextField(
                controller: _noteController,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Reason for rejection (optional)',
                  hintStyle: GoogleFonts.poppins(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.primaryContainer,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: AppRadius.borderRadiusSm, borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isRejecting ? _handleConfirmReject : _handleRejectInitiate,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: _isRejecting ? AppColors.error : AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(_isRejecting ? 'Confirm Reject' : 'Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
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
