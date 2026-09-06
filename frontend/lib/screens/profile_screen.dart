import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_tokens.dart';
import '../services/firebase_service.dart';
import '../features/auth/presentation/auth_controller.dart';

/// Student personal dashboard featuring profile header and a 3-tab view:
/// My Tickets, My Uploads, and Attendance Requests.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.primarySurface,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildAppBar(context),
              _buildProfileHeader(context, ref),
              _buildActionButtons(context, ref),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTicketsTab(),
                    _buildUploadsTab(),
                    _buildAttendanceTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Text(
            'My Dashboard',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: AppRadius.borderRadiusSm,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.settings_outlined,
                size: 20, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ─── Profile Header ───────────────────────────────────────────────
  Widget _buildProfileHeader(BuildContext context, WidgetRef ref) {
    final userDocAsync = ref.watch(currentUserDocProvider);
    final userDoc = userDocAsync.valueOrNull;

    if (userDoc == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      );
    }

    final initials = userDoc.fullName.isNotEmpty
        ? userDoc.fullName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '??';

    final usn = userDoc.usn.isNotEmpty ? userDoc.usn : 'N/A';
    final batch = userDoc.batch ?? 'Unknown Batch';
    final year = userDoc.yearOfStudy != null ? '${userDoc.yearOfStudy} Year' : 'Unknown Year';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppRadius.borderRadiusLg,
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.md,
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.aiBadgeGradient,
                image: userDoc.profilePictureUrl != null && userDoc.profilePictureUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(userDoc.profilePictureUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: userDoc.profilePictureUrl == null || userDoc.profilePictureUrl!.isEmpty
                  ? Center(
                      child: Text(
                        initials,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 20),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userDoc.fullName,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: AppRadius.borderRadiusXs,
                    ),
                    child: Text(
                      'USN: $usn',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$year · $batch',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Edit Button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  context.push('/profile/edit');
                },
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.edit_rounded, size: 18, color: AppColors.accent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Action Buttons (Edit Profile + Logout) ──────────────────────
  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          // Edit Profile Button
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/profile/edit'),
                borderRadius: AppRadius.borderRadiusSm,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: AppRadius.borderRadiusSm,
                    boxShadow: AppShadows.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Edit Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Logout Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoggingOut ? null : () => _showLogoutConfirmation(context, ref),
              borderRadius: AppRadius.borderRadiusSm,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: AppRadius.borderRadiusSm,
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                ),
                child: _isLoggingOut
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.error),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.logout_rounded, size: 16, color: AppColors.error),
                          const SizedBox(width: 6),
                          Text(
                            'Logout',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLg),
        backgroundColor: AppColors.surfaceElevated,
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to logout? You will need to sign in again to access your dashboard.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _performLogout(ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSm),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout(WidgetRef ref) async {
    setState(() => _isLoggingOut = true);
    try {
      await ref.read(authControllerProvider.notifier).logout();
      // GoRouter redirect will automatically navigate to /login
      // once authState changes to unauthenticated
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  // ─── Tab Bar ──────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 2)),
      ),
      child: TabBar(
        indicatorColor: AppColors.accent,
        indicatorWeight: 3,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'My Tickets'),
          Tab(text: 'My Uploads'),
          Tab(text: 'Attendance'),
        ],
      ),
    );
  }

  // ─── TAB 1: Tickets ───────────────────────────────────────────────
  Widget _buildTicketsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        _ticketCard(
          eventName: 'Neural Hack 2026',
          date: 'Sep 15, 9:00 AM',
          venue: 'Main Lab 1',
          ticketId: 'TKT-8839-AI',
          isActive: true,
        ),
        const SizedBox(height: 16),
        _ticketCard(
          eventName: 'GenAI Workshop',
          date: 'Aug 22, 2:00 PM',
          venue: 'Seminar Hall',
          ticketId: 'TKT-4122-AI',
          isActive: false,
        ),
      ],
    );
  }

  Widget _ticketCard({
    required String eventName,
    required String date,
    required String venue,
    required String ticketId,
    required bool isActive,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          // Left side - Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.accent.withValues(alpha: 0.15) : AppColors.primaryContainer,
                      borderRadius: AppRadius.borderRadiusXs,
                    ),
                    child: Text(
                      isActive ? 'UPCOMING' : 'PAST EVENT',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isActive ? AppColors.accent : AppColors.textTertiary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    eventName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(date, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(venue, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ticketId,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right side - QR Code (simulated with standard divider approach)
          Container(
            width: 1,
            height: 130,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: AppColors.border,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.qr_code_2_rounded,
                size: 64,
                color: isActive ? Colors.black : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── TAB 2: Uploads ───────────────────────────────────────────────
  Widget _buildUploadsTab() {
    return GridView.count(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _uploadThumb('assets/images/proj_robot.jpg', status: 'Pending'),
        _uploadThumb('assets/images/proj_drone.jpg', status: 'Approved'),
        _uploadThumb('assets/images/proj_stock.jpg', status: 'Approved'),
        _uploadThumb('assets/images/event_hackathon.jpg', status: 'Approved'),
      ],
    );
  }

  Widget _uploadThumb(String imagePath, {required String status}) {
    final isPending = status == 'Pending';
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(imagePath, fit: BoxFit.cover),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPending ? AppColors.warning : AppColors.success,
                borderRadius: AppRadius.borderRadiusFull,
              ),
              child: Text(
                status.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── TAB 3: Attendance ────────────────────────────────────────────
  Widget _buildAttendanceTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        _attendanceRequest(
          title: 'Hackathon Duty Leave',
          date: 'Sep 15, 2026',
          status: 'Approved',
          message: 'Granted leave for organizing Neural Hack.',
        ),
        _attendanceRequest(
          title: 'Medical Leave',
          date: 'Aug 04, 2026',
          status: 'Rejected',
          message: 'Medical certificate not attached. Please resubmit.',
        ),
        _attendanceRequest(
          title: 'Paper Presentation',
          date: 'Jul 22, 2026',
          status: 'Approved',
          message: 'Approved for IEEE conference in Bangalore.',
        ),
      ],
    );
  }

  Widget _attendanceRequest({
    required String title,
    required String date,
    required String status,
    required String message,
  }) {
    Color statusColor;
    if (status == 'Approved') {
      statusColor = AppColors.success;
    } else if (status == 'Rejected') {
      statusColor = AppColors.error;
    } else {
      statusColor = AppColors.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: AppRadius.borderRadiusSm,
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            date,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
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
