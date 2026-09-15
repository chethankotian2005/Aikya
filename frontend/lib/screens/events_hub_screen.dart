import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../core/theme/app_tokens.dart';
import '../features/auth/data/user_doc.dart';
import '../models/firestore/event_doc.dart';
import '../services/firebase_service.dart';
import '../utils/friendly_error.dart';
import '../widgets/banner_image.dart';
import '../widgets/shared_widgets.dart';

class EventsHubScreen extends ConsumerStatefulWidget {
  const EventsHubScreen({super.key});

  @override
  ConsumerState<EventsHubScreen> createState() => _EventsHubScreenState();
}

class _EventsHubScreenState extends ConsumerState<EventsHubScreen> {
  static const _pageSize = 15;

  int _segment = 0; // 0 = Upcoming, 1 = Past, 2 = My Registrations (students)
  final _searchController = TextEditingController();
  String _query = '';
  Set<String> _registeredIds = {};

  final _paging = PagingController<DocumentSnapshot?, EventDoc>(firstPageKey: null);

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Query<Map<String, dynamic>> get _myRegistrationsQuery => FirebaseFirestore.instance
      .collectionGroup('registrations')
      .where('studentUid', isEqualTo: _uid)
      .orderBy('registeredAt', descending: true);

  @override
  void initState() {
    super.initState();
    _paging.addPageRequestListener(_fetchPage);
    _loadRegistrations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _paging.dispose();
    super.dispose();
  }

  Future<void> _loadRegistrations() async {
    if (_uid == null) return;
    try {
      final snap = await _myRegistrationsQuery.get();
      if (!mounted) return;
      setState(() {
        _registeredIds = snap.docs
            .map((d) => d.data()['eventId'] as String? ?? d.reference.parent.parent!.id)
            .toSet();
      });
    } catch (e) {
      debugPrint('Could not load registrations: $e');
    }
  }

  Future<void> _fetchPage(DocumentSnapshot? pageKey) async {
    try {
      if (_segment == 2) {
        var query = _myRegistrationsQuery.limit(_pageSize);
        if (pageKey != null) query = query.startAfterDocument(pageKey);
        final snap = await query.get();

        final events = <EventDoc>[];
        for (final reg in snap.docs) {
          final eventId = reg.data()['eventId'] as String? ?? reg.reference.parent.parent!.id;
          final eventSnap = await EventDoc.docRef(eventId).get();
          if (eventSnap.exists) events.add(EventDoc.fromFirestore(eventSnap));
        }
        _appendPage(_filter(events), snap.docs.length < _pageSize, snap.docs.lastOrNull);
        return;
      }

      final now = Timestamp.now();
      final approved = EventDoc.collection.where('status', isEqualTo: 'approved');
      var query = _segment == 0
          ? approved.where('eventDate', isGreaterThanOrEqualTo: now).orderBy('eventDate')
          : approved.where('eventDate', isLessThan: now).orderBy('eventDate', descending: true);
      query = query.limit(_pageSize);
      if (pageKey != null) query = query.startAfterDocument(pageKey);

      final snap = await query.get();
      final events = snap.docs.map(EventDoc.fromFirestore).toList();
      _appendPage(_filter(events), snap.docs.length < _pageSize, snap.docs.lastOrNull);
    } catch (error) {
      _paging.error = error;
    }
  }

  void _appendPage(List<EventDoc> events, bool isLast, DocumentSnapshot? lastDoc) {
    if (isLast || lastDoc == null) {
      _paging.appendLastPage(events);
    } else {
      _paging.appendPage(events, lastDoc);
    }
  }

  List<EventDoc> _filter(List<EventDoc> events) {
    if (_query.isEmpty) return events;
    final q = _query.toLowerCase();
    return events
        .where((e) =>
            e.title.toLowerCase().contains(q) ||
            e.tag.toLowerCase().contains(q) ||
            e.venue.toLowerCase().contains(q))
        .toList();
  }

  void _setSegment(int index) {
    setState(() => _segment = index);
    _paging.refresh();
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value.trim());
    _paging.refresh();
  }

  Future<void> _openEvent(EventDoc event) async {
    await context.push('/events/${event.id}');
    _loadRegistrations();
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = ref.watch(userRoleProvider) == UserRole.student;
    final labels = ['Upcoming', 'Past', if (isStudent) 'My Registrations'];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(title: 'Events Hub'),
            _buildSearchBar(),
            _buildSegmentedControl(labels),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _paging.refresh();
                  await _loadRegistrations();
                },
                child: PagedListView<DocumentSnapshot?, EventDoc>.separated(
                  pagingController: _paging,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  builderDelegate: PagedChildBuilderDelegate<EventDoc>(
                    itemBuilder: (context, event, index) => _EventCard(
                      event: event,
                      isRegistered: _registeredIds.contains(event.id),
                      onTap: () => _openEvent(event),
                    ),
                    noItemsFoundIndicatorBuilder: (_) => EmptyState(
                      icon: _segment == 2 ? Icons.event_available_rounded : Icons.event_busy_rounded,
                      message: _segment == 2
                          ? 'You haven\'t registered for any events yet.'
                          : _query.isNotEmpty
                              ? 'No events match "$_query".'
                              : 'No events here yet.',
                    ),
                    firstPageErrorIndicatorBuilder: (_) => EmptyState(
                      icon: Icons.error_outline,
                      message: friendlyError(_paging.error ?? 'Failed to load events'),
                      action: ElevatedButton(
                        onPressed: _paging.refresh,
                        child: const Text('Retry'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search events...',
          prefixIcon: const Icon(Icons.search_rounded, size: 18),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close_rounded, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(List<String> labels) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: AppRadius.borderRadiusFull,
        ),
        child: Row(
          children: List.generate(labels.length, (i) {
            final isActive = i == _segment;
            return Expanded(
              child: GestureDetector(
                onTap: () => _setSegment(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.surfaceElevated : Colors.transparent,
                    borderRadius: AppRadius.borderRadiusFull,
                    boxShadow: isActive ? AppShadows.sm : null,
                  ),
                  child: Center(
                    child: Text(
                      labels[i],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventDoc event;
  final bool isRegistered;
  final VoidCallback onTap;

  const _EventCard({required this.event, required this.isRegistered, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final barColor = event.isFull
        ? AppColors.error
        : event.isNearCapacity
            ? AppColors.warning
            : AppColors.accent;

    return InkWell(
      onTap: onTap,
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
                aspectRatio: 3 / 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    BannerImage(url: event.bannerUrl),
                    if (event.isPast)
                      const Positioned(top: 10, right: 10, child: _Pill('PAST', AppColors.primary))
                    else if (isRegistered)
                      const Positioned(top: 10, right: 10, child: _Pill('REGISTERED', AppColors.success)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TagChip(label: event.tag),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _infoRow(Icons.calendar_today_outlined, formatEventDate(event.eventDate)),
                  const SizedBox(height: 6),
                  _infoRow(Icons.location_on_outlined, event.venue),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${event.filledSeats}/${event.totalSeats} seats',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: barColor,
                        ),
                      ),
                      if (event.isFull)
                        Text('Full', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.error))
                      else if (event.isNearCapacity)
                        Text('Filling fast', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.warning)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: AppRadius.borderRadiusFull,
                    child: LinearProgressIndicator(
                      value: event.fillRatio.clamp(0.0, 1.0),
                      backgroundColor: barColor.withValues(alpha: 0.12),
                      color: barColor,
                      minHeight: 6,
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

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: AppRadius.borderRadiusFull,
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

String formatEventDate(DateTime dt) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final amPm = dt.hour >= 12 ? 'PM' : 'AM';
  final minute = dt.minute.toString().padLeft(2, '0');
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $hour:$minute $amPm';
}
