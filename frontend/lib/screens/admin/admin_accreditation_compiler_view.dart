import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_tokens.dart';
import '../../models/firestore/event_doc.dart';
import '../../models/firestore/firestore_value.dart';
import '../../services/render_api_service.dart';
import '../../utils/friendly_error.dart';
import '../../widgets/shared_widgets.dart';
import '../events_hub_screen.dart' show formatEventDate;

final _pastEventsProvider = StreamProvider.autoDispose<List<EventDoc>>((ref) {
  return EventDoc.collection
      .where('eventDate', isLessThan: Timestamp.now())
      .orderBy('eventDate', descending: true)
      .limit(100)
      .snapshots()
      .map((snap) => snap.docs.map(EventDoc.fromFirestore).toList());
});

final _reportsProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('accreditationReports')
      .orderBy('generatedAt', descending: true)
      .limit(20)
      .snapshots()
      .map((snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList());
});

String _defaultSemester() {
  final now = DateTime.now();
  return now.month >= 7 ? '${now.year} Odd Semester' : '${now.year} Even Semester';
}

/// HOD-only Accreditation Compiler: pick past events, Gemini compiles them
/// (with each event's generated report) into one PDF via POST /api/compile-accreditation.
class AdminAccreditationCompilerView extends ConsumerStatefulWidget {
  const AdminAccreditationCompilerView({super.key});

  @override
  ConsumerState<AdminAccreditationCompilerView> createState() => _AdminAccreditationCompilerViewState();
}

class _AdminAccreditationCompilerViewState extends ConsumerState<AdminAccreditationCompilerView> {
  final _semesterController = TextEditingController(text: _defaultSemester());
  final Set<String> _selected = {};
  bool _compiling = false;

  @override
  void dispose() {
    _semesterController.dispose();
    super.dispose();
  }

  Future<void> _compile() async {
    if (_selected.isEmpty || _semesterController.text.trim().isEmpty) return;

    setState(() => _compiling = true);
    try {
      final result = await ref.read(renderApiServiceProvider).compileAccreditation(
            semesterLabel: _semesterController.text.trim(),
            eventIds: _selected.toList(),
          );
      if (!mounted) return;
      final url = result['pdfUrl'] as String?;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Accreditation report ready'),
          content: Text('Compiled ${result['eventCount']} events into a PDF.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
            if (url != null)
              ElevatedButton(
                onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
                child: const Text('Open PDF'),
              ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e)), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _compiling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(_pastEventsProvider);
    final reports = ref.watch(_reportsProvider).valueOrNull ?? const [];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Text('Accreditation Compiler', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            const AiBadge(),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Select past events to compile into one NAAC/NBA-ready PDF. Events with a generated report give Gemini more to work with.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _semesterController,
          decoration: const InputDecoration(labelText: 'Academic period'),
        ),
        const SizedBox(height: 16),
        events.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyState(icon: Icons.error_outline, message: friendlyError(e)),
          data: (list) => list.isEmpty
              ? const EmptyState(icon: Icons.event_busy_rounded, message: 'No past events to compile yet.')
              : Card(
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: Text('Select all (${list.length})', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        value: _selected.length == list.length,
                        onChanged: (v) => setState(() {
                          _selected.clear();
                          if (v == true) _selected.addAll(list.map((e) => e.id));
                        }),
                      ),
                      const Divider(height: 1),
                      for (final e in list)
                        CheckboxListTile(
                          value: _selected.contains(e.id),
                          onChanged: (v) => setState(() => v == true ? _selected.add(e.id) : _selected.remove(e.id)),
                          title: Text(e.title),
                          subtitle: Text(
                            '${formatEventDate(e.eventDate)} · ${e.filledSeats} registered'
                            '${e.reportMarkdown != null ? ' · report ready' : ''}',
                          ),
                        ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _compiling || _selected.isEmpty ? null : _compile,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          icon: _compiling
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.auto_awesome_rounded),
          label: Text(_compiling ? 'Compiling… (up to a minute)' : 'Compile ${_selected.length} events'),
        ),
        if (reports.isNotEmpty) ...[
          const SizedBox(height: 32),
          Text('Previous reports', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final r in reports)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error),
                title: Text(r['semesterLabel'] as String? ?? 'Report'),
                subtitle: Text(
                  '${(r['includedEventIds'] as List?)?.length ?? 0} events'
                  '${toDateTime(r['generatedAt']) != null ? ' · ${formatEventDate(toDateTime(r['generatedAt'])!)}' : ''}',
                ),
                trailing: const Icon(Icons.open_in_new_rounded),
                onTap: r['pdfUrl'] is String
                    ? () => launchUrl(Uri.parse(r['pdfUrl'] as String), mode: LaunchMode.externalApplication)
                    : null,
              ),
            ),
        ],
      ],
    );
  }
}
