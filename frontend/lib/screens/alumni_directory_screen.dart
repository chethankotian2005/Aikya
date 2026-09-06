import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../core/theme/app_tokens.dart';
import '../features/alumni/data/alumni_doc.dart';
import '../features/auth/data/user_doc.dart';

class AlumniPresentationData {
  final AlumniDoc alumni;
  final UserDoc? user;

  AlumniPresentationData({required this.alumni, required this.user});

  String get name => user?.fullName ?? 'Unknown Alumni';
  String get initials {
    final n = name;
    if (n.isEmpty) return 'A';
    final parts = n.split(' ');
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return n.length >= 2 ? n.substring(0, 2).toUpperCase() : n.substring(0, 1).toUpperCase();
  }
}

class AlumniDirectoryScreen extends StatefulWidget {
  const AlumniDirectoryScreen({super.key});

  @override
  State<AlumniDirectoryScreen> createState() => _AlumniDirectoryScreenState();
}

class _AlumniDirectoryScreenState extends State<AlumniDirectoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final PagingController<DocumentSnapshot?, AlumniPresentationData> _pagingController =
      PagingController(firstPageKey: null);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(DocumentSnapshot? pageKey) async {
    try {
      const pageSize = 15;
      Query query = _firestore.collection('alumni');
      
      // Usually, alumni are ordered by graduation year
      query = query.orderBy('graduationYear', descending: true).limit(pageSize);

      if (pageKey != null) {
        query = query.startAfterDocument(pageKey);
      }

      final snap = await query.get();
      final isLastPage = snap.docs.length < pageSize;

      List<AlumniPresentationData> newItems = [];
      for (var doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final alumniDoc = AlumniDoc.fromJson({'id': doc.id, ...data}); // Wait uid is in doc.id or data
        // Freezed model requires uid. If it's the document ID:
        final uid = data['uid'] ?? doc.id;
        
        final userSnap = await _firestore.collection('users').doc(uid).get();
        UserDoc? userDoc;
        if (userSnap.exists) {
          userDoc = UserDoc.fromJson({'id': userSnap.id, ...userSnap.data()!});
        }
        
        final merged = AlumniPresentationData(
          alumni: AlumniDoc.fromJson({
            ...data,
            'uid': uid,
            'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(), // Fallback if missing
          }),
          user: userDoc,
        );
        newItems.add(merged);
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        newItems = newItems.where((e) {
          return e.name.toLowerCase().contains(q) ||
                 e.alumni.currentCompany.toLowerCase().contains(q) ||
                 e.alumni.jobTitle.toLowerCase().contains(q);
        }).toList();
      }

      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        _pagingController.appendPage(newItems, snap.docs.last);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _onSearchChanged(String val) {
    setState(() => _searchQuery = val);
    _pagingController.refresh();
  }

  void _showAlumniProfile(BuildContext context, AlumniPresentationData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: AppRadius.borderRadiusFull,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      children: [
                        _Avatar(initials: data.initials, size: 80),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${data.alumni.jobTitle} @ ${data.alumni.currentCompany}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Batch of ${data.alumni.graduationYear}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        if (data.alumni.isOpenForMentorship)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: AppRadius.borderRadiusSm,
                              border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.handshake_rounded, size: 16, color: AppColors.accent),
                                const SizedBox(width: 8),
                                Text(
                                  'Open to Mentor',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        _buildInfoChip(Icons.location_on_outlined, data.alumni.location),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'About',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data.user?.bio ?? 'No bio provided.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {}, // launch url
                            icon: const Icon(Icons.link_rounded, size: 18),
                            label: Text(
                              'LinkedIn',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.borderRadiusSm,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: data.alumni.isOpenForMentorship ? () {} : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.primary,
                              disabledBackgroundColor: AppColors.primaryContainer,
                              disabledForegroundColor: AppColors.textTertiary,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.borderRadiusSm,
                              ),
                            ),
                            child: Text(
                              'Request Mentorship',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                            ),
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
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
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
          children: [
            _buildAppBar(),
            _buildSearchAndFilter(),
            Expanded(
              child: PagedListView<DocumentSnapshot?, AlumniPresentationData>.separated(
                pagingController: _pagingController,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                builderDelegate: PagedChildBuilderDelegate<AlumniPresentationData>(
                  itemBuilder: (context, data, index) {
                    return _AlumniCard(
                      data: data,
                      onTap: () => _showAlumniProfile(context, data),
                    );
                  },
                  noItemsFoundIndicatorBuilder: (_) => _buildEmptyState(),
                  firstPageErrorIndicatorBuilder: (_) => const Center(child: Text('Failed to load alumni directory.')),
                ),
              ),
            ),
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
              child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Alumni Directory',
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

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search by name, company...',
                  hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textTertiary),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textTertiary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                          child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textTertiary),
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
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: const Icon(Icons.tune_rounded, size: 20, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: AppColors.textTertiary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No alumni found',
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
}

class _AlumniCard extends StatelessWidget {
  final AlumniPresentationData data;
  final VoidCallback onTap;

  const _AlumniCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppRadius.borderRadiusLg,
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(initials: data.initials, size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data.name,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (data.alumni.isOpenForMentorship)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.12),
                            borderRadius: AppRadius.borderRadiusFull,
                            border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.handshake_rounded, size: 12, color: AppColors.accent),
                              const SizedBox(width: 4),
                              Text(
                                'Open to Mentor',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${data.alumni.jobTitle} @ ${data.alumni.currentCompany}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Batch of ${data.alumni.graduationYear}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.aiBadgeGradient,
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.poppins(
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
