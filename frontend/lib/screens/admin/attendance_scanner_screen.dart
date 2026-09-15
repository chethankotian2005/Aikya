import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_tokens.dart';
import '../../services/render_api_service.dart';
import '../../utils/friendly_error.dart';

/// Camera-based QR attendance scanner (coordinator/faculty/HOD). Scans a
/// student's personal QR (just their uid) and records it via
/// POST /api/attendance/scan — keeps scanning continuously so a whole
/// queue of students can check in one after another.
class AttendanceScannerScreen extends ConsumerStatefulWidget {
  final String eventId;
  final String eventTitle;
  final List<String> sessions;

  const AttendanceScannerScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.sessions,
  });

  @override
  ConsumerState<AttendanceScannerScreen> createState() => _AttendanceScannerScreenState();
}

class _AttendanceScannerScreenState extends ConsumerState<AttendanceScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  late String _session = widget.sessions.first;
  bool _busy = false;
  String? _lastUid;
  DateTime? _lastScanTime;
  String? _statusMessage;
  Color _statusColor = AppColors.textSecondary;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;

    // Ignore the same code firing repeatedly while it's still in frame.
    final now = DateTime.now();
    if (code == _lastUid && _lastScanTime != null && now.difference(_lastScanTime!) < const Duration(seconds: 3)) {
      return;
    }
    _lastUid = code;
    _lastScanTime = now;

    setState(() => _busy = true);
    try {
      final result = await ref.read(renderApiServiceProvider).scanAttendance(
            eventId: widget.eventId,
            studentUid: code,
            session: _session,
          );
      final alreadyMarked = result['alreadyMarked'] == true;
      final name = result['studentName'] as String? ?? 'Student';
      final usn = result['usn'] as String?;
      setState(() {
        _statusMessage = alreadyMarked
            ? '$name${usn != null ? ' ($usn)' : ''} was already marked present.'
            : '$name${usn != null ? ' ($usn)' : ''} marked present ✓';
        _statusColor = alreadyMarked ? AppColors.warning : AppColors.success;
      });
    } catch (e) {
      setState(() {
        _statusMessage = friendlyError(e);
        _statusColor = AppColors.error;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('Scan Attendance', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          if (widget.sessions.length > 1)
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  for (final session in widget.sessions)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(session == 'morning' ? 'Morning' : 'Afternoon'),
                          selected: _session == session,
                          onSelected: (_) => setState(() => _session = session),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                MobileScanner(controller: _controller, onDetect: _onDetect),
                if (_busy) const Center(child: CircularProgressIndicator(color: Colors.white)),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.all(20),
            child: Text(
              _statusMessage ?? 'Point the camera at a student’s QR code.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: _statusMessage == null ? Colors.white70 : _statusColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
