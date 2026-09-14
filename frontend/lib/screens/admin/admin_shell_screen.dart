import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_tokens.dart';
import '../../features/auth/data/user_doc.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../services/firebase_service.dart';
import '../../widgets/shared_widgets.dart';
import 'admin_accreditation_compiler_view.dart';
import 'admin_analytics_view.dart';
import 'admin_attendance_requests_view.dart';
import 'admin_batch_config_view.dart';
import 'admin_dashboard_view.dart';
import 'admin_manage_events_view.dart';
import 'admin_moderation_queue_view.dart';
import 'admin_report_generator_view.dart';
import 'admin_staff_provisioning_view.dart';

class _NavItem {
  final String title;
  final IconData icon;
  final bool hodOnly;
  final Widget Function() build;

  const _NavItem(this.title, this.icon, this.build, {this.hodOnly = false});
}

/// Admin portal for coordinators (own events) and the HOD (everything), spec §6.
class AdminShellScreen extends ConsumerStatefulWidget {
  const AdminShellScreen({super.key});

  @override
  ConsumerState<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends ConsumerState<AdminShellScreen> {
  int _index = 0;

  static final _items = [
    _NavItem('Dashboard', Icons.dashboard_outlined, () => const AdminDashboardView()),
    _NavItem('Events', Icons.event_outlined, () => const AdminManageEventsView()),
    _NavItem('Report Generator', Icons.summarize_outlined, () => const AdminReportGeneratorView(embedded: true)),
    _NavItem('Analytics', Icons.insights_outlined, () => const AdminAnalyticsView()),
    _NavItem('Accreditation', Icons.verified_outlined, () => const AdminAccreditationCompilerView(), hodOnly: true),
    _NavItem('Moderation', Icons.shield_outlined, () => const AdminModerationQueueView(), hodOnly: true),
    _NavItem('Attendance', Icons.fact_check_outlined, () => const AdminAttendanceRequestsView(), hodOnly: true),
    _NavItem('Batch Config', Icons.tune_rounded, () => const AdminBatchConfigView(), hodOnly: true),
    _NavItem('Staff', Icons.badge_outlined, () => const AdminStaffProvisioningView(), hodOnly: true),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDocProvider).valueOrNull;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final items = _items.where((i) => !i.hodOnly || user.role == UserRole.hod).toList();
    final index = _index.clamp(0, items.length - 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(items[index].title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: TagChip(label: user.role.label)),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.surfaceElevated,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Image.asset('assets/branding/aikya_logo_cropped.png', height: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AIKYA', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800)),
                          Text(
                            'Admin Portal · ${user.fullName}',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          leading: Icon(items[i].icon),
                          title: Text(items[i].title),
                          selected: i == index,
                          selectedColor: Colors.white,
                          selectedTileColor: AppColors.secondary,
                          shape: const StadiumBorder(),
                          onTap: () {
                            setState(() => _index = i);
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Back to app'),
                onTap: () => context.go('/home'),
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: const Text('Sign out', style: TextStyle(color: AppColors.error)),
                onTap: () => ref.read(authControllerProvider.notifier).logout(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: items[index].build(),
    );
  }
}
