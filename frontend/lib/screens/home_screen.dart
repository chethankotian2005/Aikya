import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_tokens.dart';
import '../widgets/shared_widgets.dart';

/// Student home screen with greeting header, stat pills, event carousel,
/// activity feed, and bottom navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // ─── Header ─────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            // ─── Stat pills ─────────────────────────────────────────
            SliverToBoxAdapter(child: _buildStatStrip()),

            // ─── Events section ─────────────────────────────────────
            const SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Upcoming Events',
                actionLabel: 'View all',
              ),
            ),
            SliverToBoxAdapter(child: _buildEventCarousel()),

            // ─── Activity feed ──────────────────────────────────────
            const SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Recent Activity',
                actionLabel: 'Filter',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildPinnedAnnouncement(),
                  const SizedBox(height: AppSpacing.md),
                  _buildAiDigest(),
                  const SizedBox(height: AppSpacing.md),
                  _buildCompactCard(
                    image: 'assets/images/event_hackathon.jpg',
                    title:
                        '📸 Workshop Day 1 — Hands-on TensorFlow session photos uploaded',
                    meta: 'Memory Frames · 18 photos · 4h ago',
                    onTap: () => Navigator.of(context).pushNamed('/memory_wall'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildFacultyAnnouncement(),
                  const SizedBox(height: AppSpacing.md),
                  _buildCompactCard(
                    image: 'assets/images/event_workshop.jpg',
                    title:
                        '🎓 Alumni Talk: Career paths after AI & ML — Recording available',
                    meta: 'Memory Frames · Video · Yesterday',
                    onTap: () => Navigator.of(context).pushNamed('/memory_wall'),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ═════════════════════════════════════════════════════════════════
  // HEADER
  // ═════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.aiBadgeGradient,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    'CK',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                      border: Border.all(
                          color: AppColors.primarySurface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Greeting
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
                  'Chethan Kotian',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Actions
          _headerIconButton(Icons.search_rounded),
          const SizedBox(width: AppSpacing.sm),
          _headerIconButton(Icons.notifications_outlined, showBadge: true),
        ],
      ),
    );
  }

  Widget _headerIconButton(IconData icon, {bool showBadge = false}) {
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: AppRadius.borderRadiusSm,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
        ),
        if (showBadge)
          Positioned(
            top: 7,
            right: 7,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error,
                border:
                    Border.all(color: AppColors.surfaceElevated, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════
  // STAT PILLS
  // ═════════════════════════════════════════════════════════════════
  Widget _buildStatStrip() {
    return SizedBox(
      height: 70,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _statPill(Icons.folder_outlined, '12', 'Active Projects',
              const Color(0x1F3B9AE1), AppColors.accent),
          const SizedBox(width: AppSpacing.sm),
          _statPill(Icons.calendar_today_outlined, '5', 'Upcoming Events',
              const Color(0x1F1F5C99), AppColors.secondary),
          const SizedBox(width: AppSpacing.sm),
          _statPill(Icons.people_outline_rounded, '148', 'Dept. Members',
              const Color(0x1F2ECC71), AppColors.success),
          const SizedBox(width: AppSpacing.sm),
          _statPill(Icons.school_outlined, '320+', 'Alumni',
              const Color(0x1FF0A500), AppColors.warning),
        ],
      ),
    );
  }

  Widget _statPill(IconData icon, String value, String label,
      Color bgColor, Color iconColor) {
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
            ),
            child: Icon(icon, size: 14, color: iconColor),
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

  // ═════════════════════════════════════════════════════════════════
  // EVENT CAROUSEL
  // ═════════════════════════════════════════════════════════════════
  Widget _buildEventCarousel() {
    return SizedBox(
      height: 230,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _eventCard(
            image: 'assets/images/event_hackathon.jpg',
            day: '15',
            month: 'SEP',
            seats: '42/50',
            tag: 'Hackathon',
            tagColor: AppColors.accent,
            tagBg: AppColors.accentMuted,
            title: 'Neural Hack 2026 — 24hr AI Build Sprint',
            time: 'Sep 15 · 9:00 AM – Sep 16',
          ),
          const SizedBox(width: AppSpacing.md),
          _eventCard(
            image: 'assets/images/event_workshop.jpg',
            day: '22',
            month: 'SEP',
            seats: '28/40',
            tag: 'Workshop',
            tagColor: AppColors.secondary,
            tagBg: const Color(0x1A1F5C99),
            title: 'Hands-on: Fine-tuning LLMs with LoRA',
            time: 'Sep 22 · 2:00 PM – 5:00 PM',
          ),
          const SizedBox(width: AppSpacing.md),
          _eventCard(
            image: 'assets/images/event_seminar.jpg',
            day: '29',
            month: 'SEP',
            seats: '15/60',
            tag: 'Seminar',
            tagColor: AppColors.warning,
            tagBg: const Color(0x1AF0A500),
            title: 'Vision Transformers in Medical Imaging',
            time: 'Sep 29 · 10:30 AM – 12:00 PM',
          ),
        ],
      ),
    );
  }

  Widget _eventCard({
    required String image,
    required String day,
    required String month,
    required String seats,
    required String tag,
    required Color tagColor,
    required Color tagBg,
    required String title,
    required String time,
  }) {
    return Container(
      width: 270,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner image with overlays
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg)),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(image, fit: BoxFit.cover),
                  // Bottom gradient
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.primary.withValues(alpha: 0.5),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Date badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: AppRadius.borderRadiusXs,
                        boxShadow: AppShadows.sm,
                      ),
                      child: Column(
                        children: [
                          Text(
                            day,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            month,
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
                  // Seat counter with semantic coloring
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Builder(
                      builder: (context) {
                        // Parse "filled/total" to compute fill ratio
                        final parts = seats.split('/');
                        final filled = int.tryParse(parts[0]) ?? 0;
                        final total = parts.length > 1
                            ? (int.tryParse(parts[1]) ?? 1)
                            : 1;
                        final ratio = filled / total;
                        final isFull = filled >= total;
                        final isNear = ratio >= 0.8;

                        final Color dotColor = isFull
                            ? AppColors.error
                            : isNear
                                ? AppColors.warning
                                : AppColors.success;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.75),
                            borderRadius: AppRadius.borderRadiusFull,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: dotColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.person_outline_rounded,
                                  size: 12, color: Colors.white.withValues(alpha: 0.9)),
                              const SizedBox(width: 3),
                              Text(
                                isFull
                                    ? 'Full'
                                    : isNear
                                        ? '$seats · Filling fast'
                                        : '$seats seats',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.base, AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: AppRadius.borderRadiusXs,
                  ),
                  child: Text(
                    tag.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: tagColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
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
                    const Icon(Icons.access_time_rounded,
                        size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        time,
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: AppColors.textTertiary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════
  // FEED CARDS
  // ═════════════════════════════════════════════════════════════════

  Widget _buildPinnedAnnouncement() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.aiBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, AppSpacing.md, AppSpacing.base, 0),
            child: Row(
              children: [
                _feedAvatar('RN',
                    bg: AppColors.primary, textColor: Colors.white),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dr. Rajesh Nayak',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.9))),
                      Text('HOD · AI & ML',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.4))),
                    ],
                  ),
                ),
                Text('2h ago',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.4))),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, AppSpacing.sm, AppSpacing.base, AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accentMuted,
                    borderRadius: AppRadius.borderRadiusXs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 11, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        'PINNED',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.55),
                    children: [
                      TextSpan(
                        text: 'NBA Accreditation prep: ',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                      const TextSpan(
                          text:
                              'All 6th-sem students — upload your project abstracts by Sep 10. COs must be mapped. Coordinate with your project guide.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Reactions
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, 0, AppSpacing.base, AppSpacing.md),
            child: Row(
              children: [
                _reactionBtn(Icons.thumb_up_outlined, '24',
                    color: Colors.white.withValues(alpha: 0.35)),
                const SizedBox(width: AppSpacing.base),
                _reactionBtn(Icons.chat_bubble_outline_rounded, '8 replies',
                    color: Colors.white.withValues(alpha: 0.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiDigest() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.aiBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, AppSpacing.md, AppSpacing.base, 0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.aiBadgeGradient,
                  ),
                  child: const Center(
                    child:
                        Text('✦', style: TextStyle(fontSize: 14, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Weekly Digest ',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          const AiBadge(),
                        ],
                      ),
                      Text('Auto-generated by Gemini',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                Text('Today',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.textTertiary)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, AppSpacing.sm, AppSpacing.base, AppSpacing.md),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.55),
                children: [
                  const TextSpan(text: 'This week: '),
                  TextSpan(
                      text: '3 new project proposals',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const TextSpan(text: ' submitted, '),
                  TextSpan(
                      text: 'Neural Hack',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const TextSpan(
                      text:
                          ' registrations at 84% capacity, and the department published '),
                  TextSpan(
                      text: '2 research papers',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const TextSpan(
                      text:
                          ' in IEEE Access. Sentiment across 12 feedback forms: mostly positive (87%).'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, 0, AppSpacing.base, AppSpacing.md),
            child: Row(
              children: [
                _reactionBtn(Icons.thumb_up_outlined, '16'),
                const SizedBox(width: AppSpacing.base),
                _reactionBtn(Icons.more_horiz_rounded, 'More'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacultyAnnouncement() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, AppSpacing.md, AppSpacing.base, 0),
            child: Row(
              children: [
                _feedAvatar('RP',
                    bg: AppColors.aiBadgeStart, textColor: Colors.white),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Prof. Rashmi P.',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      Text('Faculty · Machine Learning',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                Text('6h ago',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.textTertiary)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, AppSpacing.sm, AppSpacing.base, AppSpacing.md),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.55),
                children: [
                  TextSpan(
                      text: 'Mini-project evaluation ',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const TextSpan(
                      text:
                          'rescheduled to Sep 12 (Friday). Bring hardcopy of synopsis + working demo. Teams of 2-3 only.'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, 0, AppSpacing.base, AppSpacing.md),
            child: Row(
              children: [
                _reactionBtn(Icons.thumb_up_outlined, '11'),
                const SizedBox(width: AppSpacing.base),
                _reactionBtn(
                    Icons.chat_bubble_outline_rounded, '3 replies'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCard({
    required String image,
    required String title,
    required String meta,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppRadius.md)),
            child: Image.asset(
              image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  // ─── Shared helpers ───────────────────────────────────────────────
  Widget _feedAvatar(String initials,
      {required Color bg, required Color textColor}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.poppins(
              fontSize: 12, fontWeight: FontWeight.w700, color: textColor),
        ),
      ),
    );
  }

  Widget _reactionBtn(IconData icon, String label, {Color? color}) {
    final c = color ?? AppColors.textTertiary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: c),
        const SizedBox(width: AppSpacing.xs),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w500, color: c)),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════
  // BOTTOM NAV
  // ═════════════════════════════════════════════════════════════════
  Widget _buildBottomNav() {
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
          selectedItemColor: AppColors.accent,
          unselectedItemColor: const Color(0xFF8A8FA3),
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          currentIndex: _navIndex,
          onTap: (i) {
            setState(() => _navIndex = i);
            if (i == 1) context.push('/events');
            else if (i == 2) context.push('/projects');
            else if (i == 3) context.push('/alumni');
            else if (i == 4) context.push('/profile');
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
