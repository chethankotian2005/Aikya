import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_exif/native_exif.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/theme/app_tokens.dart';
import '../../models/firestore/event_doc.dart';
import '../../models/firestore/memory_frame_doc.dart';
import '../../services/firebase_service.dart';
import '../../services/render_api_service.dart';
import '../../utils/friendly_error.dart';
import '../../utils/image_upload.dart';
import '../../widgets/shared_widgets.dart';
import 'admin_manage_events_view.dart' show manageableEventsProvider;

class _Photo {
  final XFile file;
  final Uint8List bytes;
  final String? gps;
  final String? takenAt;

  const _Photo(this.file, this.bytes, this.gps, this.takenAt);
}

/// Post-event Report Generator (coordinators: own events; HOD: any).
/// A brief + photo metadata goes to Gemini via POST /api/generate-report;
/// the backend also saves the report onto the event.
class AdminReportGeneratorView extends ConsumerStatefulWidget {
  final String? eventId;
  final bool embedded;

  const AdminReportGeneratorView({super.key, this.eventId, this.embedded = false});

  @override
  ConsumerState<AdminReportGeneratorView> createState() => _AdminReportGeneratorViewState();
}

class _AdminReportGeneratorViewState extends ConsumerState<AdminReportGeneratorView> {
  final _briefController = TextEditingController();
  final List<_Photo> _photos = [];
  late String? _eventId = widget.eventId;
  bool _generating = false;
  bool _publishing = false;
  String? _markdown;

  @override
  void dispose() {
    _briefController.dispose();
    super.dispose();
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? AppColors.error : AppColors.success,
    ));
  }

  Future<void> _pickPhotos() async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 80, maxWidth: 2000);
    for (final file in picked) {
      String? gps;
      String? takenAt;
      if (!kIsWeb) {
        try {
          final exif = await Exif.fromPath(file.path);
          final latLong = await exif.getLatLong();
          if (latLong != null) {
            gps = '${latLong.latitude.toStringAsFixed(4)}, ${latLong.longitude.toStringAsFixed(4)}';
          }
          takenAt = (await exif.getOriginalDate())?.toIso8601String();
          await exif.close();
        } catch (e) {
          debugPrint('EXIF unavailable for ${file.name}: $e');
        }
      }
      final bytes = await file.readAsBytes();
      if (mounted) setState(() => _photos.add(_Photo(file, bytes, gps, takenAt)));
    }
  }

  Future<void> _generate() async {
    if (_eventId == null) {
      _snack('Pick the event this report is for.', error: true);
      return;
    }
    if (_briefController.text.trim().length < 10) {
      _snack('Write a short summary of the event (at least 10 characters).', error: true);
      return;
    }

    setState(() => _generating = true);
    try {
      final context = StringBuffer('Event photos: ${_photos.length}\n');
      for (var i = 0; i < _photos.length; i++) {
        final p = _photos[i];
        context.writeln('Photo ${i + 1}: location ${p.gps ?? 'unknown'}, taken ${p.takenAt ?? 'unknown'}');
      }

      final markdown = await ref.read(renderApiServiceProvider).generateReport(
            brief: _briefController.text.trim(),
            eventId: _eventId,
            includeAttendance: true,
            additionalContext: context.toString(),
          );
      if (mounted) setState(() => _markdown = markdown);
    } catch (e) {
      if (mounted) _snack(friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _exportPdf() async {
    final markdown = _markdown;
    if (markdown == null) return;
    final pdf = pw.Document()
      ..addPage(pw.MultiPage(build: (_) => [pw.Paragraph(text: markdown.replaceAll(RegExp(r'[#*_`]'), ''))]));
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'AIKYA_Event_Report.pdf',
    );
  }

  Future<void> _publishToMemoryWall(List<EventDoc> events) async {
    final user = ref.read(currentUserDocProvider).valueOrNull;
    if (_markdown == null || user == null || _photos.isEmpty) return;
    final event = events.where((e) => e.id == _eventId).firstOrNull;

    setState(() => _publishing = true);
    try {
      for (var i = 0; i < _photos.length; i++) {
        final photo = _photos[i];
        final url = await uploadImage(photo.file, UploadFolder.memoryFrame);
        await MemoryFrameDoc.collection.add(MemoryFrameDoc.newFrame(
          uploadedBy: user.uid,
          uploaderName: user.fullName,
          imageUrl: url,
          caption: event?.title ?? 'Event memory',
          eventName: event?.title ?? '',
          eventId: _eventId,
          reportMarkdown: i == 0 ? _markdown : null,
        ));
      }
      if (mounted) _snack('Submitted to the moderation queue.');
    } catch (e) {
      if (mounted) _snack(friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(manageableEventsProvider).valueOrNull ?? const <EventDoc>[];
    final body = _markdown != null ? _buildResult(events) : _buildInput(events);

    if (widget.embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Generate Report')), body: body);
  }

  Widget _buildInput(List<EventDoc> events) {
    final hasSelected = events.any((e) => e.id == _eventId);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Text('Event report', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            const AiBadge(),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Summarise what happened and add photos. Gemini drafts a formatted report using the event\'s registration data; it is saved to the event for the accreditation compiler.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          initialValue: hasSelected ? _eventId : null,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Event'),
          hint: Text(events.isEmpty ? 'No events you can report on yet' : 'Choose an event'),
          items: [
            for (final e in events)
              DropdownMenuItem(value: e.id, child: Text(e.title, overflow: TextOverflow.ellipsis)),
          ],
          onChanged: (v) => setState(() => _eventId = v),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _briefController,
          minLines: 5,
          maxLines: 10,
          decoration: const InputDecoration(
            labelText: 'Summary notes',
            alignLabelWithHint: true,
            hintText: 'e.g. 50 students attended the GenAI workshop. We covered RAG and embeddings...',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text('Photos (${_photos.length})', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
            TextButton.icon(
              onPressed: _pickPhotos,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Add photos'),
            ),
          ],
        ),
        if (_photos.isNotEmpty)
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.borderRadiusMd,
                    child: Image.memory(_photos[i].bytes, width: 140, height: 110, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: IconButton.filledTonal(
                      tooltip: 'Remove photo',
                      iconSize: 16,
                      onPressed: () => setState(() => _photos.removeAt(i)),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _generating ? null : _generate,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          icon: _generating
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.auto_awesome_rounded),
          label: Text(_generating ? 'Generating… (can take up to a minute)' : 'Generate report'),
        ),
      ],
    );
  }

  Widget _buildResult(List<EventDoc> events) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            TextButton.icon(
              onPressed: () => setState(() => _markdown = null),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to editor'),
            ),
            OutlinedButton.icon(
              onPressed: _exportPdf,
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('Export PDF'),
            ),
            if (_photos.isNotEmpty)
              ElevatedButton.icon(
                onPressed: _publishing ? null : () => _publishToMemoryWall(events),
                icon: const Icon(Icons.publish_rounded, size: 18),
                label: Text(_publishing ? 'Publishing…' : 'Publish to Memory Wall'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(gradient: AppColors.aiBadgeGradient),
                child: Text(
                  'AI GENERATED — REVIEW BEFORE SHARING',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
              Padding(padding: const EdgeInsets.all(24), child: MarkdownBody(data: _markdown ?? '')),
            ],
          ),
        ),
      ],
    );
  }
}
