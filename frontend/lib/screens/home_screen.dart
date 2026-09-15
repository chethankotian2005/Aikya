import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_tokens.dart';
import '../features/auth/data/user_doc.dart';
import '../models/firestore/event_doc.dart';
import '../providers/updates_provider.dart';
import '../services/firebase_service.dart';
import '../services/messaging_service.dart';
import '../utils/friendly_error.dart';
import '../widgets/avatar_picker.dart';
import '../widgets/banner_image.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/update_card.dart';

class HomeStats {
  final int projects;
  final int upcomingEvents;
  final int students;
  final int alumni;

  const HomeStats({
    required this.projects,
    required this.upcomingEvents,
    required this.students,
    required this.alumni,
  });
}

final homeStatsProvider = FutureProvider.autoDispose<HomeStats>((ref) async {
  final db = FirebaseFirestore.instance;
  Future<int> count(Query<Map<String, dynamic>> query) async =>
      (await query.count().get()).count ?? 0;

  final counts = await Future.wait([
    count(db.collection('projects')),
    count(db
        .collection('events')
        .where('status', isEqualTo: 'approved')
        .where('eventDate', isGreaterThanOrEqualTo: Timestamp.now())),
    count(db.collection('users').where('role', isEqualTo: UserRole.student.firestoreValue)),
    count(db.collection('alumniProfiles')),
  ]);

  return HomeStats(
    projects: counts[0],
    upcomingEvents: counts[1],
    students: counts[2],
    alumni: counts[3],
  );
});

final upcomingEventsProvider = StreamProvider.autoDispose<List<EventDoc>>((ref) {
  return EventDoc.collection
      .where('status', isEqualTo: 'approved')
      .where('eventDate', isGreaterThanOrEqualTo: Timestamp.now())
      .orderBy('eventDate')
      .limit(6)
      .snapshots()
      .map((snap) => snap.docs.map(EventDoc.fromFirestore).toList());
});

/// Home: greeting, live stats, quick actions, upcoming events and the
/// faculty "Updates" feed (spec §6).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _pushRequested = false;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDocProvider).valueOrNull;

    if (user != null && !_pushRequested) {
      _pushRequested = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(messagingServiceProvider).requestPermissionAndSetup(user),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(homeStatsProvider),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(user)),
              SliverToBoxAdapter(child: _buildStatStrip()),
              SliverToBoxAdapter(child: _buildQuickActions(user)),
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Upcoming Events',
                  actionLabel: 'View all',
                  onAction: () => context.push('/events'),
                ),
              ),
              SliverToBoxAdapter(child: _buildEventCarousel()),
              const SliverToBoxAdapter(child: SectionHeader(title: 'Department Updates')),
              _buildUpdatesFeed(),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────
  Widget _buildHeader(UserDoc? user) {
    final subtitle = user == null
        ? ''
        : user.role == UserRole.student
            ? user.usn
            : [user.role.label, if (user.club != null) user.club].join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: ProfileAvatar(
              avatarId: user?.avatarId,
              profilePictureUrl: user?.profilePictureUrl,
              initials: user?.initials ?? '',
              size: 44,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  user?.fullName ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          Image.asset('assets/branding/aikya_logo_cropped.png', height: 36),
        ],
      ),
    );
  }

  // ─── Stats ──────────────────────────────────────────────────────────
  Widget _buildStatStrip() {
    final stats = ref.watch(homeStatsProvider).valueOrNull;
    String value(int? n) => n == null ? '–' : '$n';

    return SizedBox(
      height: 70,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _statPill(Icons.folder_outlined, value(stats?.projects), 'Projects', AppColors.accent),
          const SizedBox(width: AppSpacing.sm),
          _statPill(Icons.calendar_today_outlined, value(stats?.upcomingEvents), 'Upcoming Events',
              AppColors.secondary),
          const SizedBox(width: AppSpacing.sm),
          _statPill(Icons.people_outline_rounded, value(stats?.students), 'Students', AppColors.success),
          const SizedBox(width: AppSpacing.sm),
          _statPill(Icons.school_outlined, value(stats?.alumni), 'Alumni', AppColors.warning),
        ],
      ),
    );
  }

  Widget _statPill(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusFull,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.12)),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Quick actions ──────────────────────────────────────────────────
  Widget _buildQuickActions(UserDoc? user) {
    final role = user?.role;
    final actions = [
      (Icons.photo_library_outlined, 'Memory Wall', '/memory'),
      if (role != null && role.isStaff) (Icons.campaign_outlined, 'Post Update', '/create_update'),
      if (role != null && role.canBuildEvents) (Icons.admin_panel_settings_outlined, 'Admin Panel', '/admin'),
      (Icons.dashboard_outlined, 'My Dashboard', '/profile'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final (icon, label, path) in actions)
            ActionChip(
              avatar: Icon(icon, size: 18, color: AppColors.secondary),
              label: Text(label),
              labelStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              backgroundColor: AppColors.surfaceElevated,
              side: const BorderSide(color: AppColors.border),
              shape: const StadiumBorder(),
              onPressed: () => context.push(path),
            ),
        ],
      ),
    );
  }

  // ─── Upcoming events ────────────────────────────────────────────────
  Widget _buildEventCarousel() {
    final events = ref.watch(upcomingEventsProvider);
    final user = ref.read(currentUserDocProvider).valueOrNull;

    return SizedBox(
      height: 230,
      child: events.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _emptyCard(Icons.error_outline, friendlyError(e)),
        data: (rawList) {
          final list = user?.role == UserRole.student
              ? rawList.where((e) => e.isOpenToYear(user?.yearOfStudy)).toList()
              : rawList;
          return list.isEmpty
            ? _emptyCard(Icons.event_busy_rounded, 'No upcoming events yet.')
            : ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                itemBuilder: (_, i) => _eventCard(list[i]),
              );
        },
      ),
    );
  }

  Widget _eventCard(EventDoc event) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final dotColor = event.isFull
        ? AppColors.error
        : event.isNearCapacity
            ? AppColors.warning
            : AppColors.success;

    return GestureDetector(
      onTap: () => context.push('/events/${event.id}'),
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppRadius.borderRadiusLg,
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 320,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BannerImage(url: event.bannerUrl),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: AppRadius.borderRadiusXs,
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${event.eventDate.day}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            months[event.eventDate.month - 1],
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.75),
                        borderRadius: AppRadius.borderRadiusFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            event.isFull
                                ? 'Full'
                                : '${event.filledSeats}/${event.totalSeats} seats',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TagChip(label: event.tag),
                  const SizedBox(height: 6),
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.venue,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textTertiary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Updates feed ───────────────────────────────────────────────────
  Widget _buildUpdatesFeed() {
    final updates = ref.watch(updatesStreamProvider);

    return updates.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
      ),
      error: (e, _) => SliverToBoxAdapter(child: _emptyCard(Icons.error_outline, friendlyError(e))),
      data: (list) => list.isEmpty
          ? SliverToBoxAdapter(
              child: _emptyCard(Icons.campaign_outlined, 'No department updates yet.'),
            )
          : SliverList.builder(
              itemCount: list.length,
              itemBuilder: (_, i) => UpdateCard(update: list[i]),
            ),
    );
  }

  Widget _emptyCard(IconData icon, String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: AppColors.textTertiary),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ─── Bottom nav ─────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    const destinations = ['/home', '/events', '/projects', '/alumni', '/profile'];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surfaceElevated,
          elevation: 0,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textTertiary,
          selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
          currentIndex: 0,
          onTap: (i) {
            if (i != 0) context.push(destinations[i]);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today_rounded),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder_rounded),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school_rounded),
              label: 'Alumni',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
