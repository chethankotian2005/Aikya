import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_tokens.dart';
import 'admin_dashboard_view.dart';
import 'admin_manage_events_view.dart';
import 'admin_report_generator_view.dart';
import 'admin_accreditation_compiler_view.dart';
import 'admin_moderation_queue_view.dart';
import 'admin_attendance_requests_view.dart';
import 'admin_analytics_view.dart';
import 'admin_batch_config_view.dart';

/// The main host shell for Faculty and Admin users.
class AdminShellScreen extends StatefulWidget {
  final String roleName;

  const AdminShellScreen({
    super.key,
    this.roleName = 'HOD', // e.g., HOD, Event Faculty, Admin
  });

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Dashboard',
    'Manage Events',
    'Report Generator',
    'Accreditation Compiler',
    'Content Moderation',
    'Attendance Requests',
    'Analytics & Insights',
    'Batch Config',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primarySurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Text(
            _titles[_selectedIndex],
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          // Role Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: AppRadius.borderRadiusSm,
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.admin_panel_settings_rounded, size: 14, color: AppColors.accent),
                const SizedBox(width: 6),
                Text(
                  widget.roleName.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    );
  }

  // ─── Drawer ───────────────────────────────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(0)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.aiBadgeGradient,
                    ),
                    child: const Icon(Icons.hub_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AIML Hub.',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Admin Portal',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 8),
            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _drawerItem(0, Icons.dashboard_outlined, 'Dashboard'),
                  _drawerItem(1, Icons.event_outlined, 'Events'),
                  _drawerItem(2, Icons.summarize_outlined, 'Report Generator'),
                  _drawerItem(3, Icons.verified_outlined, 'Accreditation Compiler'),
                  _drawerItem(4, Icons.shield_outlined, 'Moderation'),
                  _drawerItem(5, Icons.fact_check_outlined, 'Attendance Requests'),
                  _drawerItem(6, Icons.insights_outlined, 'Analytics'),
                  if (widget.roleName == 'HOD') _drawerItem(7, Icons.settings_applications_outlined, 'Batch Config'),
                ],
              ),
            ),
            // Footer (Logout)
            const Divider(color: AppColors.border, height: 1),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: Text(
                  'Sign Out',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSm),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          size: 22,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.accent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusSm,
        ),
        onTap: () {
          setState(() => _selectedIndex = index);
          Navigator.of(context).pop(); // Close drawer
        },
      ),
    );
  }

  // ─── Dynamic Body ─────────────────────────────────────────────────
  Widget _buildBody() {
    // Switch between views based on _selectedIndex
    switch (_selectedIndex) {
      case 0:
        return const AdminDashboardView();
      case 1:
        return const AdminManageEventsView();
      case 2:
        return const AdminReportGeneratorView();
      case 3:
        return const AdminAccreditationCompilerView();
      case 4:
        return const AdminModerationQueueView();
      case 5:
        return const AdminAttendanceRequestsView();
      case 6:
        return const AdminAnalyticsView();
      case 7:
        if (widget.roleName == 'HOD') return const AdminBatchConfigView();
        return const Center(child: Text('Unauthorized'));
      default:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction_rounded, size: 48, color: AppColors.textTertiary),
              const SizedBox(height: 16),
              Text(
                '${_titles[_selectedIndex]} is under construction.',
                style: GoogleFonts.poppins(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
    }
  }
}
