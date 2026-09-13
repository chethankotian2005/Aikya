import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/render_api_service.dart';

import '../core/theme/app_tokens.dart';
import '../models/update_doc.dart';
import '../services/firebase_service.dart';
import '../features/auth/data/user_doc.dart';
import '../services/firebase_service.dart';

class CreateUpdateScreen extends ConsumerStatefulWidget {
  const CreateUpdateScreen({super.key});

  @override
  ConsumerState<CreateUpdateScreen> createState() => _CreateUpdateScreenState();
}

class _CreateUpdateScreenState extends ConsumerState<CreateUpdateScreen> {
  final TextEditingController _contentController = TextEditingController();
  DateTime? _deadline;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: AppColors.primary,
              surface: AppColors.surfaceElevated,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _deadline = date);
    }
  }

  Future<void> _postUpdate() async {
    if (_contentController.text.trim().isEmpty) return;

    final user = ref.read(currentUserDocProvider).value;
    if (user == null || (user.role != UserRole.faculty && user.role != UserRole.coordinator && user.role != UserRole.hod)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unauthorized')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final id = const Uuid().v4();
      
      // Determine designation
      String designation = 'Faculty';
      if (user.role == UserRole.coordinator) designation = 'Coordinator';
      if (user.role == UserRole.hod) designation = 'HOD';
      // Ideally this comes from user doc if stored, but fallback to role string

      final authUser = ref.read(authStateProvider).value;
      if (authUser == null) throw Exception('No auth user');
      final idToken = await authUser.getIdToken();

      final response = await http.post(
        Uri.parse('${RenderApiService.baseUrl}/messaging/updates'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'id': id,
          'content': _contentController.text.trim(),
          'deadlineDate': _deadline?.toIso8601String(),
          'authorId': user.uid,
          'authorName': user.fullName.isNotEmpty ? user.fullName : 'Faculty Member',
          'authorDesignation': designation,
          'club': user.club,
          'createdAt': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to post update: ${response.body}');
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceElevated,
        title: Text(
          'Post Update',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _postUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderRadiusSm,
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Text('Post'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _contentController,
            maxLines: 8,
            style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'What do you want to share with the students?',
              hintStyle: GoogleFonts.poppins(color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.surfaceElevated,
              border: OutlineInputBorder(
                borderRadius: AppRadius.borderRadiusMd,
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            onTap: _selectDate,
            tileColor: AppColors.surfaceElevated,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMd),
            leading: const Icon(Icons.timer_outlined, color: AppColors.accent),
            title: Text(
              'Set Deadline (Optional)',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            subtitle: _deadline != null
                ? Text(
                    '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                    style: GoogleFonts.poppins(color: AppColors.textSecondary),
                  )
                : null,
            trailing: _deadline != null
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.textTertiary, size: 20),
                    onPressed: () => setState(() => _deadline = null),
                  )
                : const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
