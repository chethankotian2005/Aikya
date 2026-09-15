import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_tokens.dart';
import '../../features/auth/data/user_doc.dart';
import '../../services/firebase_service.dart';
import '../../utils/friendly_error.dart';
import '../../widgets/shared_widgets.dart';

typedef _Stat = (String label, IconData icon, Color color, int value);

final adminStatsProvider = FutureProvider.autoDispose<List<_Stat>>((ref) async {
  final user = ref.watch(currentUserDocProvider).valueOrNull;
  if (user == null) return const [];

  final db = FirebaseFirestore.instance;
  final now = Timestamp.now();
  Future<int> count(Query<Map<String, dynamic>> q) async => (await q.count().get()).count ?? 0;

  if (user.role == UserRole.hod) {
    final c = await Future.wait([
      count(db.collection('events').where('status', isEqualTo: 'approved').where('eventDate', isGreaterThanOrEqualTo: now)),
      count(db.collection('events').where('status', isEqualTo: 'pending')),
      count(db.collection('memoryFrames').where('status', isEqualTo: 'pending')),
      count(db.collection('users').where('role', isEqualTo: 'student')),
      count(db.collection('users').where('status', isEqualTo: 'pending_batch_review')),
      count(db.collection('projects')),
    ]);
    return [
      ('Upcoming events', Icons.event_available_rounded, AppColors.accent, c[0]),
      ('Event approvals', Icons.rate_review_outlined, AppColors.error, c[1]),
      ('Moderation queue', Icons.shield_outlined, AppColors.error, c[2]),
      ('Students', Icons.people_outline_rounded, AppColors.success, c[3]),
      ('Batch reviews', Icons.flag_outlined, AppColors.warning, c[4]),
      ('Projects', Icons.folder_outlined, AppColors.secondary, c[5]),
    ];
  }

  final mine = db.collection('events').where('createdBy', isEqualTo: user.uid);
  final c = await Future.wait([
    count(mine),
    count(mine.where('eventDate', isGreaterThanOrEqualTo: now)),
  ]);
  return [
    ('My events', Icons.event_note_rounded, AppColors.accent, c[0]),
    ('Upcoming', Icons.event_available_rounded, AppColors.success, c[1]),
  ];
});

class AdminDashboardView extends ConsumerWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminStatsProvider),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Overview', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            'Live department status. Pull down to refresh.',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          stats.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            error: (e, _) => EmptyState(icon: Icons.error_outline, message: friendlyError(e)),
            data: (list) => GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [for (final s in list) _StatCard(stat: s)],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Use the menu to create events, generate AI reports and review requests.',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final _Stat stat;
  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final (label, icon, color, value) = stat;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$value', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w800, height: 1.1)),
                Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
