import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_tokens.dart';
import '../models/firestore/alumni_profile.dart';
import '../utils/friendly_error.dart';
import '../widgets/shared_widgets.dart';

final alumniProvider = StreamProvider.autoDispose<List<AlumniProfileDoc>>((ref) {
  return AlumniProfileDoc.collection.snapshots().map((snap) => snap.docs
      .map((d) => AlumniProfileDoc.fromMap(d.id, d.data()))
      .toList()
    ..sort((a, b) => (b.graduationYear ?? 0).compareTo(a.graduationYear ?? 0)));
});

class AlumniDirectoryScreen extends ConsumerStatefulWidget {
  const AlumniDirectoryScreen({super.key});

  @override
  ConsumerState<AlumniDirectoryScreen> createState() => _AlumniDirectoryScreenState();
}

class _AlumniDirectoryScreenState extends ConsumerState<AlumniDirectoryScreen> {
  String _query = '';
  bool _mentorsOnly = false;

  List<AlumniProfileDoc> _filter(List<AlumniProfileDoc> alumni) {
    final q = _query.toLowerCase();
    return alumni.where((a) {
      if (_mentorsOnly && !a.isOpenForMentorship) return false;
      if (q.isEmpty) return true;
      return a.fullName.toLowerCase().contains(q) ||
          a.currentCompany.toLowerCase().contains(q) ||
          a.jobTitle.toLowerCase().contains(q) ||
          a.location.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final alumni = ref.watch(alumniProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ScreenHeader(title: 'Alumni Directory'),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v.trim()),
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Search by name, company, role or city...',
                  prefixIcon: Icon(Icons.search_rounded, size: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FilterChip(
                  label: const Text('Open to mentor'),
                  avatar: const Icon(Icons.handshake_outlined, size: 16),
                  selected: _mentorsOnly,
                  onSelected: (v) => setState(() => _mentorsOnly = v),
                  shape: const StadiumBorder(),
                ),
              ),
            ),
            Expanded(
              child: alumni.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => EmptyState(icon: Icons.error_outline, message: friendlyError(e)),
                data: (list) {
                  final filtered = _filter(list);
                  if (filtered.isEmpty) {
                    return EmptyState(
                      icon: Icons.school_outlined,
                      message: list.isEmpty ? 'No alumni profiles yet.' : 'No alumni match your search.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _AlumniCard(
                      alumni: filtered[i],
                      onTap: () => _showProfile(filtered[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfile(AlumniProfileDoc alumni) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Avatar(initials: alumni.initials, size: 64),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alumni.fullName, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800)),
                      if (alumni.roleLine.isNotEmpty)
                        Text(alumni.roleLine, style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                      if (alumni.graduationYear != null)
                        Text(
                          'Batch of ${alumni.graduationYear}',
                          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textTertiary),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (alumni.isOpenForMentorship) const _MentorBadge(),
                if (alumni.verifiedByHod) const TagChip(label: 'Verified by HOD', color: AppColors.success),
                if (alumni.location.isNotEmpty) TagChip(label: alumni.location, color: AppColors.secondary),
              ],
            ),
            if (alumni.bio != null && alumni.bio!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(alumni.bio!, style: GoogleFonts.poppins(color: AppColors.textSecondary, height: 1.5)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: alumni.linkedinUrl == null || alumni.linkedinUrl!.isEmpty
                    ? null
                    : () => launchUrl(Uri.parse(alumni.linkedinUrl!), mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.link_rounded),
                label: Text(alumni.isOpenForMentorship ? 'Ask for mentorship on LinkedIn' : 'Connect on LinkedIn'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlumniCard extends StatelessWidget {
  final AlumniProfileDoc alumni;
  final VoidCallback onTap;

  const _AlumniCard({required this.alumni, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderRadiusLg,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppRadius.borderRadiusLg,
          border: Border.all(
            color: alumni.isOpenForMentorship ? AppColors.accent.withValues(alpha: 0.5) : AppColors.border,
          ),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(initials: alumni.initials, size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          alumni.fullName,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (alumni.verifiedByHod) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, size: 16, color: AppColors.accent),
                      ],
                    ],
                  ),
                  if (alumni.roleLine.isNotEmpty)
                    Text(
                      alumni.roleLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    [
                      if (alumni.graduationYear != null) 'Batch of ${alumni.graduationYear}',
                      if (alumni.location.isNotEmpty) alumni.location,
                    ].join(' · '),
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textTertiary),
                  ),
                  if (alumni.isOpenForMentorship) ...[
                    const SizedBox(height: 8),
                    const _MentorBadge(),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

/// Solid accent pill — deliberately high-contrast so mentors stand out.
class _MentorBadge extends StatelessWidget {
  const _MentorBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.accent, borderRadius: AppRadius.borderRadiusFull),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.handshake_rounded, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            'Open to mentor',
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final double size;

  const _Avatar({required this.initials, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.aiBadgeGradient),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.poppins(fontSize: size * 0.35, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}
