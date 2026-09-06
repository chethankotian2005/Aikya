import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../core/theme/app_tokens.dart';
import '../features/events/data/event_doc.dart';
import '../features/events/data/registration_doc.dart';
import 'event_detail_screen.dart';

class EventsHubScreen extends StatefulWidget {
  const EventsHubScreen({super.key});

  @override
  State<EventsHubScreen> createState() => _EventsHubScreenState();
}

class _EventsHubScreenState extends State<EventsHubScreen> {
  int _selectedSegment = 0; // 0=Upcoming, 1=Past, 2=My Registrations
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  final PagingController<DocumentSnapshot?, EventDoc> _pagingController =
      PagingController(firstPageKey: null);

  final Set<String> _myRegisteredEventIds = {};
  bool _isLoadingRegistrations = true;

  @override
  void initState() {
    super.initState();
    _fetchMyRegistrations().then((_) {
      _pagingController.addPageRequestListener((pageKey) {
        _fetchPage(pageKey);
      });
    });
  }

  Future<void> _fetchMyRegistrations() async {
    if (_uid == null) {
      setState(() => _isLoadingRegistrations = false);
      return;
    }
    try {
      final snap = await _firestore
          .collectionGroup('registrations')
          .where('studentUid', isEqualTo: _uid)
          .get();
      for (var doc in snap.docs) {
        final data = doc.data();
        if (data['eventId'] != null) {
          _myRegisteredEventIds.add(data['eventId']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching registrations: $e');
    } finally {
      if (mounted) setState(() => _isLoadingRegistrations = false);
    }
  }

  Future<void> _fetchPage(DocumentSnapshot? pageKey) async {
    try {
      const pageSize = 15;
      
      if (_selectedSegment == 2) {
        // My Registrations
        if (_uid == null) {
          _pagingController.appendLastPage([]);
          return;
        }
        
        Query query = _firestore
            .collectionGroup('registrations')
            .where('studentUid', isEqualTo: _uid)
            .orderBy('registeredAt', descending: true)
            .limit(pageSize);
            
        if (pageKey != null) query = query.startAfterDocument(pageKey);
        
        final snap = await query.get();
        final isLastPage = snap.docs.length < pageSize;
        
        List<EventDoc> events = [];
        for (var doc in snap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final eventId = data['eventId'] as String?;
          if (eventId != null) {
            final eventSnap = await _firestore.collection('events').doc(eventId).get();
            if (eventSnap.exists) {
              events.add(EventDoc.fromJson({'id': eventSnap.id, ...eventSnap.data()!}));
            }
          }
        }
        
        if (isLastPage) {
          _pagingController.appendLastPage(events);
        } else {
          _pagingController.appendPage(events, snap.docs.last);
        }
        return;
      }

      // Upcoming (0) or Past (1)
      Query query = _firestore.collection('events');
      
      if (_searchQuery.isNotEmpty) {
        // Simple client-side search approximation by pulling everything
        // For production, use Algolia/Typesense, but we do basic pagination
        query = query.orderBy('eventDate', descending: _selectedSegment == 1);
      } else {
        if (_selectedSegment == 0) {
          query = query
              .where('eventDate', isGreaterThanOrEqualTo: DateTime.now())
              .orderBy('eventDate', descending: false);
        } else if (_selectedSegment == 1) {
          query = query
              .where('eventDate', isLessThan: DateTime.now())
              .orderBy('eventDate', descending: true);
        }
      }
      
      query = query.limit(pageSize);
      if (pageKey != null) query = query.startAfterDocument(pageKey);
      
      final snap = await query.get();
      final isLastPage = snap.docs.length < pageSize;
      
      List<EventDoc> events = snap.docs.map((d) {
        return EventDoc.fromJson({'id': d.id, ...d.data() as Map<String, dynamic>});
      }).toList();
      
      if (_searchQuery.isNotEmpty) {
        events = events.where((e) {
          final q = _searchQuery.toLowerCase();
          return e.title.toLowerCase().contains(q) || e.tag.toLowerCase().contains(q);
        }).toList();
      }

      if (isLastPage) {
        _pagingController.appendLastPage(events);
      } else {
        _pagingController.appendPage(events, snap.docs.last);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _onSegmentChanged(int index) {
    setState(() => _selectedSegment = index);
    _pagingController.refresh();
  }

  void _onSearchChanged(String val) {
    setState(() => _searchQuery = val);
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            _buildSegmentedControl(),
            Expanded(child: _buildEventList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: AppRadius.borderRadiusSm,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  size: 20, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Events Hub',
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: SizedBox(
        height: 44,
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search events...',
            hintStyle:
                GoogleFonts.poppins(fontSize: 13, color: AppColors.textTertiary),
            prefixIcon: const Icon(Icons.search_rounded,
                size: 18, color: AppColors.textTertiary),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: AppColors.textTertiary),
                  )
                : null,
            filled: true,
            fillColor: AppColors.surfaceElevated,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusSm,
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusSm,
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusSm,
              borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    const labels = ['Upcoming', 'Past', 'My Registrations'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: AppRadius.borderRadiusSm,
        ),
        child: Row(
          children: List.generate(labels.length, (i) {
            final isActive = i == _selectedSegment;
            return Expanded(
              child: GestureDetector(
                onTap: () => _onSegmentChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.surfaceElevated : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
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

  Widget _buildEventList() {
    if (_isLoadingRegistrations) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return PagedListView<DocumentSnapshot?, EventDoc>.separated(
      pagingController: _pagingController,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      builderDelegate: PagedChildBuilderDelegate<EventDoc>(
        itemBuilder: (context, event, index) => _EventCard(
          event: event,
          isRegistered: _myRegisteredEventIds.contains(event.id),
          onTap: () {
            // Navigator.of(context).push(MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)));
            // Currently EventDetailScreen takes EventModel. We will need to update it or avoid clicking.
          },
        ),
        noItemsFoundIndicatorBuilder: (_) => _buildEmptyState(),
        firstPageErrorIndicatorBuilder: (_) => _buildErrorState(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _selectedSegment == 2 ? Icons.event_available_rounded : Icons.event_busy_rounded,
            size: 48,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _selectedSegment == 2 ? 'No registrations yet' : 'No events found',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Failed to load events', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _pagingController.refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventDoc event;
  final bool isRegistered;
  final VoidCallback onTap;

  const _EventCard({required this.event, required this.isRegistered, required this.onTap});

  Color _getTagBg() {
    final t = event.tag.toLowerCase();
    if (t.contains('hackathon')) return AppColors.primary.withValues(alpha: 0.1);
    if (t.contains('workshop')) return AppColors.success.withValues(alpha: 0.1);
    return AppColors.accent.withValues(alpha: 0.1);
  }

  Color _getTagColor() {
    final t = event.tag.toLowerCase();
    if (t.contains('hackathon')) return AppColors.primary;
    if (t.contains('workshop')) return AppColors.success;
    return AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppRadius.borderRadiusLg,
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.base, AppSpacing.md, AppSpacing.base, AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: _getTagBg(), borderRadius: AppRadius.borderRadiusXs),
                    child: Text(
                      event.tag.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getTagColor(),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
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
                  _infoRow(Icons.calendar_today_outlined, _formatDate(event.eventDate)),
                  const SizedBox(height: 6),
                  _infoRow(Icons.location_on_outlined, event.venue),
                  const SizedBox(height: 12),
                  _buildSeatProgress(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      child: SizedBox(
        height: 140,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (event.bannerUrl != null && event.bannerUrl!.startsWith('http'))
              Image.network(event.bannerUrl!, fit: BoxFit.cover)
            else if (event.bannerUrl != null)
              Image.asset(event.bannerUrl!, fit: BoxFit.cover)
            else
              Container(color: AppColors.primaryContainer),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, AppColors.primary.withValues(alpha: 0.5)],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: AppRadius.borderRadiusXs,
                  boxShadow: AppShadows.sm,
                ),
                child: Column(
                  children: [
                    Text(
                      event.eventDate.day.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      _monthAbbr(event.eventDate.month),
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (event.isPast)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.8),
                    borderRadius: AppRadius.borderRadiusFull,
                  ),
                  child: Text(
                    'PAST',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            if (isRegistered && !event.isPast)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.9),
                    borderRadius: AppRadius.borderRadiusFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'REGISTERED',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
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

  Widget _buildSeatProgress() {
    final ratio = event.fillRatio.clamp(0.0, 1.0);
    final isNear = event.isNearCapacity;
    final isFull = event.isFull;

    final Color barColor = isFull ? AppColors.error : isNear ? AppColors.warning : AppColors.accent;
    final Color barBg = isFull ? AppColors.error.withValues(alpha: 0.12) : isNear ? AppColors.warning.withValues(alpha: 0.12) : AppColors.accentMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.people_outline_rounded, size: 14, color: barColor),
                const SizedBox(width: 4),
                Text(
                  '${event.filledSeats}/${event.totalSeats} seats',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: barColor,
                  ),
                ),
              ],
            ),
            if (isFull)
              Text('Full', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.error))
            else if (isNear)
              Text('Filling fast!', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: AppRadius.borderRadiusFull,
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: barBg,
            color: barColor,
            minHeight: 6,
          ),
        ),
      ],
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
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month]} ${dt.day}, ${dt.year} · $h:$min $amPm';
  }

  String _monthAbbr(int m) {
    const months = ['', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[m];
  }
}
