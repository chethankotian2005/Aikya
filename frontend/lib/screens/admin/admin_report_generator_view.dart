import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_tokens.dart';

class AdminReportGeneratorView extends StatefulWidget {
  const AdminReportGeneratorView({super.key});

  @override
  State<AdminReportGeneratorView> createState() => _AdminReportGeneratorViewState();
}

class _AdminReportGeneratorViewState extends State<AdminReportGeneratorView> {
  final TextEditingController _summaryController = TextEditingController();
  bool _imageUploaded = false;
  bool _isGenerating = false;
  bool _reportGenerated = false;

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  void _simulateImageUpload() {
    setState(() {
      _imageUploaded = true;
    });
  }

  void _generateReport() async {
    if (_summaryController.text.trim().isEmpty && !_imageUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a summary or an image first.')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    // Simulate AI generation delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isGenerating = false;
        _reportGenerated = true;
      });
    }
  }

  void _reset() {
    setState(() {
      _summaryController.clear();
      _imageUploaded = false;
      _reportGenerated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      body: _reportGenerated ? _buildResultView() : _buildInputView(),
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
                hintText: 'e.g. 50 students attended the GenAI workshop. Covered RAG architecture and embeddings. Excellent feedback...',
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
            Text(
              'Event Evidence (Photos)',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _simulateImageUpload,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: AppRadius.borderRadiusLg,
                  border: Border.all(
                    color: _imageUploaded ? AppColors.accent : AppColors.border,
                    width: _imageUploaded ? 2 : 1,
                    style: BorderStyle.solid,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _imageUploaded
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/event_hackathon.jpg',
                            fit: BoxFit.cover,
                          ),
                          Container(
                            color: Colors.black.withValues(alpha: 0.4),
                          ),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white),
                              onPressed: () => setState(() => _imageUploaded = false),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: Row(
                              children: [
                                _exifChip(Icons.location_on_rounded, '13.2541° N, 74.7865° E'),
                                const SizedBox(width: 8),
                                _exifChip(Icons.access_time_rounded, '2026-09-15 14:32:00'),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
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
                          const SizedBox(height: 4),
                          Text(
                            'JPEG, PNG (EXIF data will be extracted)',
                            style: GoogleFonts.poppins(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
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
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: AppRadius.borderRadiusSm,
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.accent),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.robotoMono(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w600,
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
                      onPressed: () {},
                      icon: const Icon(Icons.description_outlined, size: 18),
                      label: const Text('Export .MD'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                      label: const Text('Export PDF'),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Letterhead / Title
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'DEPARTMENT OF AI & ML',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black54,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'EVENT ACCREDITATION REPORT',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Generated on: Sep 15, 2026',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        
                        _docSection('1. Executive Summary', 'The Department of Artificial Intelligence & Machine Learning organized a comprehensive hands-on workshop focused on Generative AI and Retrieval-Augmented Generation (RAG) architectures. The event successfully engaged 50 active students, bridging theoretical concepts with practical implementation using modern embeddings and vector databases.'),
                        
                        _docSection('2. Event Details', '''
• Title: Introduction to GenAI & RAG
• Venue: Main Seminar Hall, SMVITM
• Date & Time: 2026-09-15 14:00:00
• Verified GPS Coordinates: 13.2541° N, 74.7865° E (Extracted via EXIF)
• Target Audience: 4th, 6th, and 8th Semester AI & ML Students
• Total Attendance: 50 Students (Verified via AIML Hub QR scans)'''),

                        _docSection('3. Key Outcomes & Feedback', 'Participants successfully built and deployed a micro-RAG pipeline locally. Feedback collected post-event indicated a 92% satisfaction rate, with students heavily requesting follow-up sessions on advanced LLM fine-tuning techniques.'),

                        const SizedBox(height: 48),
                        
                        // Sign-off
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _docSignature('Faculty Coordinator'),
                            _docSignature('Head of Department'),
                          ],
                        ),
                      ],
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

  Widget _docSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _docSignature(String role) {
    return Column(
      children: [
        Container(
          width: 150,
          height: 1,
          color: Colors.black26,
        ),
        const SizedBox(height: 8),
        Text(
          role,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
