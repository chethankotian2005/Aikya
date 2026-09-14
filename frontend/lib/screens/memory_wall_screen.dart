import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_tokens.dart';
import '../models/firestore/memory_frame_doc.dart';
import '../services/firebase_service.dart';
import '../utils/friendly_error.dart';
import '../utils/image_upload.dart';
import '../widgets/shared_widgets.dart';

final approvedFramesProvider = StreamProvider.autoDispose<List<MemoryFrameDoc>>((ref) {
  return MemoryFrameDoc.collection
      .where('status', isEqualTo: FrameStatus.approved.name)
      .orderBy('createdAt', descending: true)
      .limit(60)
      .snapshots()
      .map((snap) => snap.docs.map(MemoryFrameDoc.fromFirestore).toList());
});

/// The caller's own uploads that are still pending or were rejected.
final myUnapprovedFramesProvider = StreamProvider.autoDispose<List<MemoryFrameDoc>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(const []);
  return MemoryFrameDoc.collection
      .where('uploadedBy', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .limit(30)
      .snapshots()
      .map((snap) => snap.docs
          .map(MemoryFrameDoc.fromFirestore)
          .where((f) => f.status != FrameStatus.approved)
          .toList());
});

class MemoryWallScreen extends ConsumerWidget {
  const MemoryWallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approved = ref.watch(approvedFramesProvider);
    final mine = ref.watch(myUnapprovedFramesProvider).valueOrNull ?? const [];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(title: 'Memory Wall'),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                'Snapshots of our journey. Uploads appear after HOD approval.',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
            Expanded(
              child: approved.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => EmptyState(icon: Icons.error_outline, message: friendlyError(e)),
                data: (frames) => CustomScrollView(
                  slivers: [
                    if (mine.isNotEmpty) SliverToBoxAdapter(child: _PendingStrip(frames: mine)),
                    if (frames.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          icon: Icons.photo_library_outlined,
                          message: 'No memories yet — tap Contribute to share the first photo.',
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        sliver: SliverMasonryGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childCount: frames.length,
                          itemBuilder: (context, i) => _FrameTile(
                            frame: frames[i],
                            tall: i % 3 == 0,
                            onTap: () => _openFrame(context, frames, i),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => const _UploadSheet(),
        ),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text('Contribute', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _openFrame(BuildContext context, List<MemoryFrameDoc> frames, int index) {
    final frame = frames[index];
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => frame.reportMarkdown != null
          ? _ReportReaderScreen(frame: frame)
          : _LightboxScreen(frames: frames, initialIndex: index),
    ));
  }
}

class _FrameTile extends StatelessWidget {
  final MemoryFrameDoc frame;
  final bool tall;
  final VoidCallback onTap;

  const _FrameTile({required this.frame, required this.tall, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: AppRadius.borderRadiusLg,
        child: AspectRatio(
          aspectRatio: tall ? 3 / 4 : 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                frame.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.primaryContainer,
                  child: const Icon(Icons.broken_image_outlined, color: AppColors.textTertiary),
                ),
              ),
              if (frame.reportMarkdown != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                    child: const Icon(Icons.article_rounded, size: 14, color: Colors.white),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 24, 10, 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: Text(
                    frame.uploaderName,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingStrip extends StatelessWidget {
  final List<MemoryFrameDoc> frames;
  const _PendingStrip({required this.frames});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text(
              'Your uploads awaiting review',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: frames.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final frame = frames[i];
                final rejected = frame.status == FrameStatus.rejected;
                return ClipRRect(
                  borderRadius: AppRadius.borderRadiusMd,
                  child: SizedBox(
                    width: 96,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(frame.imageUrl, fit: BoxFit.cover),
                        Positioned(
                          left: 4,
                          bottom: 4,
                          child: TagChip(
                            label: rejected ? 'Rejected' : 'Pending',
                            color: rejected ? AppColors.error : AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadSheet extends ConsumerStatefulWidget {
  const _UploadSheet();

  @override
  ConsumerState<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends ConsumerState<_UploadSheet> {
  final _captionController = TextEditingController();
  final _eventController = TextEditingController();
  XFile? _image;
  Uint8List? _preview;
  bool _uploading = false;

  @override
  void dispose() {
    _captionController.dispose();
    _eventController.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 2000);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _image = picked;
      _preview = bytes;
    });
  }

  Future<void> _submit() async {
    final image = _image;
    final user = ref.read(currentUserDocProvider).valueOrNull;
    if (image == null || user == null) return;

    setState(() => _uploading = true);
    try {
      final url = await uploadImage(image, 'memoryFrames/${user.uid}/${uniqueImageName(image)}');
      await MemoryFrameDoc.collection.add(MemoryFrameDoc.newFrame(
        uploadedBy: user.uid,
        uploaderName: user.fullName,
        imageUrl: url,
        caption: _captionController.text.trim(),
        eventName: _eventController.text.trim(),
      ));
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitted — it will appear once the HOD approves it.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e)), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Share a memory', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _uploading ? null : _pick,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppRadius.borderRadiusLg,
                border: Border.all(color: AppColors.border),
                image: _preview != null
                    ? DecorationImage(image: MemoryImage(_preview!), fit: BoxFit.cover)
                    : null,
              ),
              child: _preview == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.accent),
                        const SizedBox(height: 8),
                        Text('Tap to choose a photo', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                      ],
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _captionController,
            maxLength: 200,
            decoration: const InputDecoration(labelText: 'Caption'),
          ),
          TextField(
            controller: _eventController,
            decoration: const InputDecoration(labelText: 'Event (optional)'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _image == null || _uploading ? null : _submit,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _uploading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Submit for approval'),
          ),
        ],
      ),
    );
  }
}

class _LightboxScreen extends StatefulWidget {
  final List<MemoryFrameDoc> frames;
  final int initialIndex;

  const _LightboxScreen({required this.frames, required this.initialIndex});

  @override
  State<_LightboxScreen> createState() => _LightboxScreenState();
}

class _LightboxScreenState extends State<_LightboxScreen> {
  late final PageController _pageController = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;
  final Set<String> _liked = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _like(MemoryFrameDoc frame) async {
    if (_liked.contains(frame.id)) return;
    setState(() => _liked.add(frame.id));
    try {
      await MemoryFrameDoc.collection.doc(frame.id).update({'likesCount': FieldValue.increment(1)});
    } catch (_) {
      if (mounted) setState(() => _liked.remove(frame.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final frame = widget.frames[_index];
    final likes = frame.likesCount + (_liked.contains(frame.id) ? 1 : 0);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.frames.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => InteractiveViewer(
                child: Image.network(widget.frames[i].imageUrl, fit: BoxFit.contain),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    frame.uploaderName,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  if (frame.caption.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(frame.caption, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
                  ],
                  if (frame.eventName.isNotEmpty)
                    Text(frame.eventName, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.accent)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _like(frame),
                        style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                        icon: Icon(
                          _liked.contains(frame.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        ),
                        label: Text('$likes'),
                      ),
                      const Spacer(),
                      Text(
                        '${_index + 1} of ${widget.frames.length}',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportReaderScreen extends StatelessWidget {
  final MemoryFrameDoc frame;
  const _ReportReaderScreen({required this.frame});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(frame.eventName.isNotEmpty ? frame.eventName : 'Event report')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: AppRadius.borderRadiusLg,
            child: Image.network(frame.imageUrl, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const AiBadge(label: 'AI Report'),
              const SizedBox(width: 8),
              Text(
                'Published by ${frame.uploaderName}',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MarkdownBody(data: frame.reportMarkdown ?? ''),
        ],
      ),
    );
  }
}
