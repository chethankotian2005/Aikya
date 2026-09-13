import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_exif/native_exif.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/theme/app_tokens.dart';
import '../../services/firebase_service.dart';
import '../../features/memories/data/memory_frame_doc.dart';

class PhotoWithMetadata {
  final File file;
  final String? gps;
  final String? timestamp;

  PhotoWithMetadata(this.file, this.gps, this.timestamp);
}

class AdminReportGeneratorView extends ConsumerStatefulWidget {
  final String? eventId;
  const AdminReportGeneratorView({super.key, this.eventId});

  @override
  ConsumerState<AdminReportGeneratorView> createState() => _AdminReportGeneratorViewState();
}

class _AdminReportGeneratorViewState extends ConsumerState<AdminReportGeneratorView> {
  final TextEditingController _summaryController = TextEditingController();
  final List<PhotoWithMetadata> _photos = [];
  bool _isGenerating = false;
  String? _generatedMarkdown;
  bool _isPublishing = false;

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      for (var pickedFile in pickedFiles) {
        final file = File(pickedFile.path);
        String? gpsData;
        String? timestampData;

        try {
          final exif = await Exif.fromPath(file.path);
          final latLong = await exif.getLatLong();
          if (latLong != null) {
            gpsData = '${latLong.latitude.toStringAsFixed(4)}° N, ${latLong.longitude.toStringAsFixed(4)}° E';
          }
          final date = await exif.getOriginalDate();
          if (date != null) {
            timestampData = date.toIso8601String();
          }
          await exif.close();
        } catch (e) {
          debugPrint('Error reading EXIF: $e');
        }

        setState(() {
          _photos.add(PhotoWithMetadata(file, gpsData, timestampData));
        });
      }
    }
  }

  Future<void> _generateReport() async {
    if (_summaryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a summary.')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();

      String additionalContext = 'Uploaded Photos Metadata:\n';
      for (var i = 0; i < _photos.length; i++) {
        final p = _photos[i];
        additionalContext += 'Photo ${i + 1}: ${p.gps ?? "No GPS"}, ${p.timestamp ?? "No Timestamp"}\n';
      }

      final response = await http.post(
        Uri.parse('http://localhost:3000/api/generate-report'), // Update this with correct backend URL if needed
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'brief': _summaryController.text.trim(),
          'eventId': widget.eventId,
          'includeAttendance': true,
          'additionalContext': additionalContext,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _generatedMarkdown = data['markdown'];
        });
      } else {
        throw Exception('Failed to generate report: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _reset() {
    setState(() {
      _summaryController.clear();
      _photos.clear();
      _generatedMarkdown = null;
    });
  }

  Future<void> _exportPdf() async {
    if (_generatedMarkdown == null) return;
    
    final pdf = pw.Document();
    
    // Convert markdown to PDF. For a basic implementation, we just print the raw text, 
    // but in a production app you'd use a Markdown to PDF parser or convert to widgets.
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Text(_generatedMarkdown!);
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Event_Report_${widget.eventId ?? 'Unknown'}.pdf',
    );
  }

  Future<void> _publishToMemoryFrame() async {
    if (_generatedMarkdown == null) return;

    final user = ref.read(currentUserDocProvider).value;
    if (user == null) return;

    setState(() => _isPublishing = true);

    try {
      final storage = FirebaseStorage.instance;
      final firestore = FirebaseFirestore.instance;

      for (var i = 0; i < _photos.length; i++) {
        final photo = _photos[i];
        final id = const Uuid().v4();
        
        // Upload image
        final ref = storage.ref().child('memories/$id.jpg');
        await ref.putFile(photo.file);
        final url = await ref.getDownloadURL();

        // Include the report markdown on the first photo, so it acts as the primary report frame
        final markdown = (i == 0) ? _generatedMarkdown : null;

        final doc = MemoryFrameDoc(
          id: id,
          uploadedBy: user.fullName,
          imageUrl: url,
          caption: 'Event Memory', // Could ask user for custom caption per photo
          eventName: 'Event ${widget.eventId ?? 'Unknown'}', // Could fetch actual event name
          eventId: widget.eventId,
          batchYear: '2026', // Ideally from event or user
          status: FrameStatus.pending,
          reportMarkdown: markdown,
          createdAt: DateTime.now(),
        );

        await firestore.collection('memories').doc(id).set(doc.toJson());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully submitted to moderation queue!'), backgroundColor: AppColors.success),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error publishing: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
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
          'Generate Report',
          style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _generatedMarkdown != null ? _buildResultView() : _buildInputView(),
    );
  }

  // ─── Input View ───────────────────────────────────────────────────
  Widget _buildInputView() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Generate Event Report',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Provide a brief summary and upload event photos. Our AI will automatically extract metadata and compile a comprehensive accreditation report.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // Text Area
            Text(
              'Event Summary Notes',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _summaryController,
              maxLines: 5,
              style: GoogleFonts.poppins(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. 50 students attended the GenAI workshop. Covered RAG architecture and embeddings...',
                hintStyle: GoogleFonts.poppins(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.borderRadiusMd,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.borderRadiusMd,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.borderRadiusMd,
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Image Upload Zone
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Event Evidence (Photos)',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Add Photos'),
                )
              ],
            ),
            const SizedBox(height: 8),
            
            if (_photos.isEmpty)
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: AppRadius.borderRadiusLg,
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo_outlined, size: 48, color: AppColors.textTertiary),
                      const SizedBox(height: 16),
                      Text(
                        'Tap to upload event photos',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length,
                  itemBuilder: (context, index) {
                    final photo = _photos[index];
                    return Container(
                      width: 250,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.borderRadiusMd,
                        image: DecorationImage(
                          image: FileImage(photo.file),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (photo.gps != null) _exifChip(Icons.location_on_rounded, photo.gps!),
                                if (photo.timestamp != null) ...[
                                  const SizedBox(height: 4),
                                  _exifChip(Icons.access_time_rounded, photo.timestamp!.substring(0, 16)),
                                ],
                              ],
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _photos.removeAt(index);
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            
            const SizedBox(height: 48),
            
            // Generate Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                ),
                child: _isGenerating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome_rounded),
                          const SizedBox(width: 8),
                          Text(
                            'Generate Accreditation Report',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _exifChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.robotoMono(
              fontSize: 9,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Result View ──────────────────────────────────────────────────
  Widget _buildResultView() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary),
                  label: Text('Back to Editor', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _exportPdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                      label: const Text('Export PDF'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isPublishing ? null : _publishToMemoryFrame,
                      icon: _isPublishing 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.publish_rounded, size: 18),
                      label: const Text('Publish to Memory Frame'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.borderRadiusLg,
                boxShadow: AppShadows.md,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // AI Badge Header
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      gradient: AppColors.aiBadgeGradient,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'AI GENERATED — REVIEW BEFORE EXPORT',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Document Content
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: MarkdownBody(
                      data: _generatedMarkdown ?? '',
                      styleSheet: MarkdownStyleSheet(
                        h1: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                        h2: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
                        p: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, height: 1.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
