import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_tokens.dart';
import '../features/auth/data/user_doc.dart';
import '../models/project_model.dart';
import '../services/firebase_service.dart';
import '../utils/friendly_error.dart';
import '../widgets/project_tile.dart';
import '../widgets/shared_widgets.dart';
import 'student_directory_screen.dart';

final projectsProvider = StreamProvider.autoDispose<List<ProjectDoc>>((ref) {
  return ProjectDoc.collection
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((snap) => snap.docs.map(ProjectDoc.fromFirestore).toList());
});

/// Projects showcase (masonry grid, tech-stack filter) + student directory.
class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  String _selectedTag = 'All';

  @override
  Widget build(BuildContext context) {
    final isStudent = ref.watch(userRoleProvider) == UserRole.student;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const ScreenHeader(title: 'Projects'),
              const SizedBox(height: 12),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildShowcase(),
                    const StudentDirectoryScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: isStudent
            ? FloatingActionButton.extended(
                onPressed: () => context.push('/projects/new'),
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add_rounded),
                label: Text('Submit Project', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              )
            : null,
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusFull,
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        indicator: BoxDecoration(borderRadius: AppRadius.borderRadiusFull, color: AppColors.secondary),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: const [Tab(text: 'Showcase'), Tab(text: 'Directory')],
      ),
    );
  }

  Widget _buildShowcase() {
    final projects = ref.watch(projectsProvider);

    return projects.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(icon: Icons.error_outline, message: friendlyError(e)),
      data: (list) {
        final tags = {for (final p in list) ...p.techStack}.toList()..sort();
        final filtered =
            _selectedTag == 'All' ? list : list.where((p) => p.techStack.contains(_selectedTag)).toList();

        return Column(
          children: [
            if (tags.isNotEmpty)
              SizedBox(
                height: 56,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  scrollDirection: Axis.horizontal,
                  itemCount: tags.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final tag = i == 0 ? 'All' : tags[i - 1];
                    return ChoiceChip(
                      label: Text(tag),
                      selected: tag == _selectedTag,
                      onSelected: (_) => setState(() => _selectedTag = tag),
                      shape: const StadiumBorder(),
                      showCheckmark: false,
                    );
                  },
                ),
              ),
            Expanded(
              child: filtered.isEmpty
                  ? EmptyState(
                      icon: Icons.folder_off_outlined,
                      message: list.isEmpty
                          ? 'No projects yet. Students can submit theirs with the button below.'
                          : 'No projects use "$_selectedTag".',
                    )
                  : MasonryGridView.count(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => ProjectTile(project: filtered[i]),
                    ),
            ),
          ],
        );
      },
    );
  }
}
