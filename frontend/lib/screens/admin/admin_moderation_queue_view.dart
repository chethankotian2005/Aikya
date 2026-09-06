import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_tokens.dart';

class AdminModerationQueueView extends StatefulWidget {
  const AdminModerationQueueView({super.key});

  @override
  State<AdminModerationQueueView> createState() => _AdminModerationQueueViewState();
}

class _AdminModerationQueueViewState extends State<AdminModerationQueueView> {
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  final List<Map<String, dynamic>> _queue = [
    {
      'id': 'm1',
      'image': 'assets/images/event_hackathon.jpg',
      'uploader': 'Aarav Sharma',
      'event': 'Neural Hack 2026',
      'time': '2 hrs ago',
    },
    {
      'id': 'm2',
      'image': 'assets/images/proj_drone.jpg',
      'uploader': 'Priya Patel',
      'event': 'Project Showcase',
      'time': '4 hrs ago',
    },
    {
      'id': 'm3',
      'image': 'assets/images/mem_hackathon.jpg',
      'uploader': 'Karan Singh',
      'event': 'Neural Hack 2026',
      'time': '5 hrs ago',
    },
    {
      'id': 'm4',
      'image': 'assets/images/event_seminar.jpg',
      'uploader': 'Neha Gupta',
      'event': 'GenAI Workshop',
      'time': 'Yesterday',
    },
    {
      'id': 'm5',
      'image': 'assets/images/mem_speaker.jpg',
      'uploader': 'Rahul Verma',
      'event': 'Alumni Talk',
      'time': 'Yesterday',
    },
  ];

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(id);
        _isSelectionMode = true;
      }
    });
  }

  void _approveSelected() {
    setState(() {
      _queue.removeWhere((item) => _selectedIds.contains(item['id']));
      _selectedIds.clear();
      _isSelectionMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected memories approved.')));
  }

  void _rejectSelected() {
    setState(() {
      _queue.removeWhere((item) => _selectedIds.contains(item['id']));
      _selectedIds.clear();
      _isSelectionMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected memories rejected.')));
  }

  void _handleSingleAction(String id, bool approve) {
    setState(() {
      _queue.removeWhere((item) => item['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(approve ? 'Memory approved.' : 'Memory rejected.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      body: Column(
        children: [
          // Action Bar
          _buildActionBar(),
          
          // Queue Grid
          Expanded(
            child: _queue.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 64, color: AppColors.success),
                        const SizedBox(height: 16),
                        Text('Queue is clear!', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        Text('All pending memory frames have been reviewed.', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 350,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                    ),
                    itemCount: _queue.length,
                    itemBuilder: (context, index) {
                      final item = _queue[index];
                      final isSelected = _selectedIds.contains(item['id']);
                      return _buildQueueCard(item, isSelected);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _isSelectionMode ? 72 : 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: _isSelectionMode ? AppColors.accent.withValues(alpha: 0.1) : AppColors.primarySurface,
        border: Border(bottom: BorderSide(color: _isSelectionMode ? AppColors.accent.withValues(alpha: 0.3) : Colors.transparent)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_isSelectionMode) ...[
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
                  onPressed: () {
                    setState(() {
                      _selectedIds.clear();
                      _isSelectionMode = false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  '${_selectedIds.length} Selected',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ],
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _rejectSelected,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _approveSelected,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            )
          ] else ...[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Moderation Queue',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Long-press a card to select multiple.',
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: AppRadius.borderRadiusSm,
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Text(
                '${_queue.length} PENDING',
                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.warning, letterSpacing: 0.5),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildQueueCard(Map<String, dynamic> item, bool isSelected) {
    return GestureDetector(
      onLongPress: () => _toggleSelection(item['id']),
      onTap: () {
        if (_isSelectionMode) {
          _toggleSelection(item['id']);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppRadius.borderRadiusLg,
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.2), blurRadius: 16)] : AppShadows.md,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(item['image'], fit: BoxFit.cover),
                  if (isSelected)
                    Container(color: AppColors.accent.withValues(alpha: 0.2)),
                  if (isSelected)
                    const Positioned(
                      top: 12,
                      left: 12,
                      child: Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 28),
                    ),
                ],
              ),
            ),
            
            // Meta Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['uploader'],
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item['time'],
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.tag_rounded, size: 12, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        item['event'],
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: AppColors.accent, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions (only show if not in selection mode to avoid confusion)
            if (!_isSelectionMode)
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _handleSingleAction(item['id'], false),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Icon(Icons.close_rounded, color: AppColors.error, size: 28),
                        ),
                      ),
                    ),
                    Container(width: 1, height: 60, color: AppColors.border),
                    Expanded(
                      child: InkWell(
                        onTap: () => _handleSingleAction(item['id'], true),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Icon(Icons.check_rounded, color: AppColors.success, size: 28),
                        ),
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
