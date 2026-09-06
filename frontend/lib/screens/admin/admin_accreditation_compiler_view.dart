import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_tokens.dart';

class AdminAccreditationCompilerView extends StatefulWidget {
  const AdminAccreditationCompilerView({super.key});

  @override
  State<AdminAccreditationCompilerView> createState() => _AdminAccreditationCompilerViewState();
}

class _AdminAccreditationCompilerViewState extends State<AdminAccreditationCompilerView> {
  String _selectedSemester = 'Even Semester 2026';
  
  // Mock data for available reports
  final List<Map<String, dynamic>> _reports = [
    {'id': '1', 'name': 'Introduction to GenAI & RAG', 'date': 'Sep 15, 2026', 'pages': 4, 'selected': true},
    {'id': '2', 'name': 'Alumni Talk: Career Paths in ML', 'date': 'Aug 22, 2026', 'pages': 3, 'selected': true},
    {'id': '3', 'name': 'Neural Hack 2026 (Day 1)', 'date': 'Aug 10, 2026', 'pages': 8, 'selected': false},
    {'id': '4', 'name': 'Neural Hack 2026 (Day 2)', 'date': 'Aug 11, 2026', 'pages': 6, 'selected': false},
    {'id': '5', 'name': 'Faculty Development Prog. on AI', 'date': 'Jul 05, 2026', 'pages': 5, 'selected': false},
  ];

  bool _isCompiling = false;
  bool _isCompiled = false;

  int get _selectedCount => _reports.where((r) => r['selected']).length;
  int get _totalPages => _reports.where((r) => r['selected']).fold(0, (sum, item) => sum + (item['pages'] as int)) + 2; // +2 for cover and index

  void _compileReport() async {
    if (_selectedCount == 0) return;
    
    setState(() => _isCompiling = true);
    await Future.delayed(const Duration(seconds: 2)); // Fake compile time
    
    if (mounted) {
      setState(() {
        _isCompiling = false;
        _isCompiled = true;
      });
    }
  }

  void _reset() {
    setState(() {
      _isCompiled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a more muted, formal background color compared to the rest of the app
      backgroundColor: const Color(0xFFF3F4F6),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 800;

          if (isLargeScreen) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: _buildConfigurationPanel(),
                ),
                Expanded(
                  flex: 7,
                  child: _buildPreviewPanel(),
                ),
              ],
            );
          }

          // Mobile View
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildConfigurationPanel(),
              _buildPreviewPanel(),
            ],
          );
        },
      ),
    );
  }

  // ─── Configuration Panel ──────────────────────────────────────────
  Widget _buildConfigurationPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Report Configuration',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select period and compile formal documentation for NAAC/NBA.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 32),
          
          // Semester Picker
          Text(
            'Academic Period',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              border: Border.all(color: const Color(0xFFD1D5DB)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedSemester,
                  style: GoogleFonts.poppins(color: const Color(0xFF111827), fontWeight: FontWeight.w500),
                ),
                const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF6B7280)),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Multi-select List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Approved Activity Reports',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
              Text(
                '$_selectedCount Selected',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: _reports.map((report) {
                final isSelected = report['selected'] as bool;
                return InkWell(
                  onTap: () {
                    setState(() {
                      report['selected'] = !isSelected;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: report == _reports.last ? Colors.transparent : const Color(0xFFF3F4F6),
                        ),
                      ),
                      color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFD1D5DB),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report['name'],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${report['date']} · ${report['pages']} Pages',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Verified badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'APPROVED',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF16A34A),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Preview Panel ────────────────────────────────────────────────
  Widget _buildPreviewPanel() {
    return Container(
      color: const Color(0xFFF3F4F6),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isCompiled ? 'Compilation Successful' : 'Live Document Preview',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
              if (_isCompiled)
                TextButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('New Compilation'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF6B7280)),
                )
              else
                Text(
                  '$_totalPages Est. Pages',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isCompiled ? _buildSuccessState() : _buildLivePreviewDocument(),
          ),
          const SizedBox(height: 24),
          if (!_isCompiled)
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedCount == 0 || _isCompiling ? null : _compileReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111827),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: _isCompiling
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.account_balance_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Compile NAAC/NBA Report',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLivePreviewDocument() {
    final selectedReports = _reports.where((r) => r['selected']).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  'SMVITM',
                  style: GoogleFonts.lora(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Department of Artificial Intelligence & Machine Learning',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 24),
                Container(width: 40, height: 2, color: Colors.black),
                const SizedBox(height: 24),
                Text(
                  'CONSOLIDATED ACTIVITY REPORT',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedSemester.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'TABLE OF CONTENTS',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.black12, height: 1),
          const SizedBox(height: 16),
          if (selectedReports.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Select reports from the left panel to populate the index.',
                  style: GoogleFonts.poppins(color: const Color(0xFF9CA3AF), fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: selectedReports.length,
                itemBuilder: (context, index) {
                  final r = selectedReports[index];
                  // Calculate mock starting page number
                  int startPage = 3;
                  for (int i = 0; i < index; i++) {
                    startPage += selectedReports[i]['pages'] as int;
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${index + 1}. ',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                        Expanded(
                          child: Text(
                            r['name'],
                            style: GoogleFonts.poppins(color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.black12, style: BorderStyle.solid)),
                            ),
                          ),
                        ),
                        Text(
                          startPage.toString().padLeft(2, '0'),
                          style: GoogleFonts.robotoMono(color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 4)),
            ],
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.picture_as_pdf_rounded, size: 48, color: Color(0xFFEF4444)),
                const SizedBox(height: 8),
                Text('PDF', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: const Color(0xFF9CA3AF))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Compilation Complete',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Generated $_totalPages pages spanning $_selectedCount verified events.',
          style: GoogleFonts.poppins(color: const Color(0xFF6B7280)),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text('Share with HOD'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF111827),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Download PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
