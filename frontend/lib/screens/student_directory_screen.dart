import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_tokens.dart';
import '../services/firebase_service.dart';
import '../features/auth/data/user_doc.dart';

class StudentDirectoryScreen extends ConsumerStatefulWidget {
  const StudentDirectoryScreen({super.key});

  @override
  ConsumerState<StudentDirectoryScreen> createState() => _StudentDirectoryScreenState();
}

class _StudentDirectoryScreenState extends ConsumerState<StudentDirectoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _buildStudentList(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search by name or skills...',
          hintStyle: GoogleFonts.poppins(color: AppColors.textTertiary, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
          filled: true,
          fillColor: AppColors.surfaceElevated,
          border: OutlineInputBorder(
            borderRadius: AppRadius.borderRadiusSm,
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderRadiusSm,
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderRadiusSm,
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    return FutureBuilder<List<UserDoc>>(
      future: ref.read(firebaseServiceProvider).getStudentDirectory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.accent));
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading directory.',
              style: GoogleFonts.poppins(color: AppColors.error),
            ),
          );
        }
        
        final users = snapshot.data ?? [];
        
        final filtered = users.where((u) {
          final q = _searchQuery.toLowerCase();
          final nameMatches = u.fullName.toLowerCase().contains(q);
          final skillsMatches = u.skills.any((s) => s.toLowerCase().contains(q));
          return nameMatches || skillsMatches;
        }).toList();
        
        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_off_rounded, size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 16),
                Text(
                  'No students found',
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }
        
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = filtered[index];
            return _buildStudentCard(user);
          },
        );
      },
    );
  }
  
  Widget _buildStudentCard(UserDoc user) {
    final initials = user.fullName.isNotEmpty
        ? user.fullName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '??';
        
    return InkWell(
      onTap: () {
        context.push('/directory/profile/${user.uid}');
      },
      borderRadius: AppRadius.borderRadiusLg,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppRadius.borderRadiusLg,
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.aiBadgeGradient,
                image: user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty
                    ? DecorationImage(image: NetworkImage(user.profilePictureUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: user.profilePictureUrl == null || user.profilePictureUrl!.isEmpty
                  ? Center(
                      child: Text(
                        initials,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.yearOfStudy ?? '-'} Year, ${user.batch ?? '-'}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (user.skills.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: user.skills.take(3).map((s) => _buildSkillChip(s)).toList(),
                    ),
                  ]
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppRadius.borderRadiusXs,
      ),
      child: Text(
        skill,
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
