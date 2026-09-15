import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/theme/app_tokens.dart';

/// A student's personal check-in QR — just their uid, generated entirely
/// on-device (no network call, no expiry). A coordinator/faculty/HOD scans
/// it during an event; POST /api/attendance/scan validates and records it
/// server-side, so this code being static/shareable doesn't matter — only
/// staff scanning it (and the student being registered for that event)
/// produces an attendance record.
class MyQrCode extends StatelessWidget {
  final String uid;
  final double size;

  const MyQrCode({super.key, required this.uid, this.size = 220});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: QrImageView(
        data: uid,
        size: size,
        backgroundColor: Colors.white,
        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.primary),
        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppColors.primary),
      ),
    );
  }
}
