import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../core/theme/app_tokens.dart';
import '../features/memories/data/memory_frame_doc.dart';

class MemoryWallScreen extends StatefulWidget {
  const MemoryWallScreen({super.key});

  @override
  State<MemoryWallScreen> createState() => _MemoryWallScreenState();
}

class _MemoryWallScreenState extends State<MemoryWallScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  final PagingController<DocumentSnapshot?, MemoryFrameDoc> _pagingController =
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
      Query query = _firestore
          .collection('memories')
          .orderBy('createdAt', descending: true)
          .limit(pageSize);

      if (pageKey != null) {
        query = query.startAfterDocument(pageKey);
      }

      final snap = await query.get();
      final isLastPage = snap.docs.length < pageSize;
      
      final newItems = snap.docs.map((doc) {
        return MemoryFrameDoc.fromJson({'id': doc.id, ...doc.data() as Map<String, dynamic>});
      }).toList();

      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        _pagingController.appendPage(newItems, snap.docs.last);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
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
            _buildHeader(),
            Expanded(child: _buildGallery()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {}, // Handled elsewhere or future enhancement
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add_a_photo_outlined, color: Colors.white),
        label: Text(
          'Contribute',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Memory Wall',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Snapshots of our journey.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.filter_list_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildGallery() {
    return PagedGridView<DocumentSnapshot?, MemoryFrameDoc>(
      pagingController: _pagingController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      builderDelegate: PagedChildBuilderDelegate<MemoryFrameDoc>(
        itemBuilder: (context, photo, index) {
          // Height variation for masonry effect based on hash of id
          final isTall = photo.id.hashCode % 2 == 0;
          return GestureDetector(
            onTap: () => _openLightbox(context, index),
            child: Hero(
              tag: 'photo_${photo.id}',
              child: Container(
                height: isTall ? 220 : 160,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: AppRadius.borderRadiusLg,
                  boxShadow: AppShadows.sm,
                  image: DecorationImage(
                    image: (photo.imageUrl.startsWith('http')
                        ? NetworkImage(photo.imageUrl)
                        : AssetImage(photo.imageUrl)) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                          ),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.lg)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                photo.uploadedBy,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (photo.status == FrameStatus.pending)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.9),
                                  borderRadius: AppRadius.borderRadiusSm,
                                ),
                                child: Text(
                                  'PENDING',
                                  style: GoogleFonts.poppins(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        firstPageErrorIndicatorBuilder: (_) => const Center(child: Text('Error loading memories')),
        noItemsFoundIndicatorBuilder: (_) => const Center(child: Text('No memories found.')),
      ),
    );
  }

  void _openLightbox(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, _, __) => _LightboxScreen(
          initialIndex: initialIndex,
          photos: _pagingController.itemList ?? [],
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class _LightboxScreen extends StatefulWidget {
  final int initialIndex;
  final List<MemoryFrameDoc> photos;

  const _LightboxScreen({required this.initialIndex, required this.photos});

  @override
  State<_LightboxScreen> createState() => _LightboxScreenState();
}

class _LightboxScreenState extends State<_LightboxScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) return const SizedBox();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: widget.photos.length,
            itemBuilder: (context, index) {
              final photo = widget.photos[index];
              return InteractiveViewer(
                child: Hero(
                  tag: 'photo_${photo.id}',
                  child: photo.imageUrl.startsWith('http')
                      ? Image.network(photo.imageUrl, fit: BoxFit.contain)
                      : Image.asset(photo.imageUrl, fit: BoxFit.contain),
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(24, 64, 24, MediaQuery.of(context).padding.bottom + 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
                  stops: const [0.0, 1.0],
                ),
              ),
              child: _buildDetails(widget.photos[_currentIndex]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(MemoryFrameDoc photo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.aiBadgeGradient,
                  ),
                  child: Center(
                    child: Text(
                      photo.uploadedBy.isNotEmpty ? photo.uploadedBy.substring(0, 1).toUpperCase() : 'A',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  photo.uploadedBy,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            if (photo.status == FrameStatus.pending)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.9),
                  borderRadius: AppRadius.borderRadiusFull,
                ),
                child: Text(
                  'PENDING APPROVAL',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          photo.caption,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _interactionButton(Icons.favorite_border_rounded, '${photo.likesCount} Likes', AppColors.accent),
            const SizedBox(width: 24),
            _interactionButton(Icons.share_outlined, 'Share', Colors.white),
            const Spacer(),
            Text(
              '${_currentIndex + 1} of ${widget.photos.length}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _interactionButton(IconData icon, String label, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: iconColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
