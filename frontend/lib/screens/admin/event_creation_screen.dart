import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_tokens.dart';
import '../../features/auth/data/user_doc.dart';
import '../../models/event_model.dart';
import '../../models/firestore/event_doc.dart';
import '../../services/firebase_service.dart';
import '../../services/render_api_service.dart';
import '../../utils/friendly_error.dart';
import '../../utils/image_upload.dart';
import '../events_hub_screen.dart' show formatEventDate;
import 'admin_staff_provisioning_view.dart' show kClubs;

const _eventTags = ['Workshop', 'Hackathon', 'Seminar', 'Talk', 'Competition', 'Cultural', 'General'];

/// Event Builder (coordinators + HOD): details, schedule, capacity, banner
/// and a custom registration form. Pass [eventId] to edit an existing event.
class EventCreationScreen extends ConsumerStatefulWidget {
  final String? eventId;
  const EventCreationScreen({super.key, this.eventId});

  @override
  ConsumerState<EventCreationScreen> createState() => _EventCreationScreenState();
}

class _EventCreationScreenState extends ConsumerState<EventCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _capacityController = TextEditingController(text: '50');

  String _tag = _eventTags.first;
  String? _club;
  DateTime? _start;
  DateTime? _end;
  DateTime? _deadline;
  Set<String> _targetYears = {}; // empty = open to every year
  List<RegistrationField> _fields = const [
    RegistrationField(label: 'Full Name'),
    RegistrationField(label: 'Phone', type: FieldType.phone),
  ];

  XFile? _banner;
  Uint8List? _bannerPreview;
  String? _existingBannerUrl;
  int _currentRegistrations = 0;

  bool _loading = false;
  bool _saving = false;

  bool get _isEdit => widget.eventId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _loadEvent();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _loadEvent() async {
    setState(() => _loading = true);
    try {
      final snap = await EventDoc.docRef(widget.eventId!).get();
      if (!snap.exists) throw Exception('Event not found.');
      final event = EventDoc.fromFirestore(snap);
      setState(() {
        _titleController.text = event.title;
        _descriptionController.text = event.description;
        _venueController.text = event.venue;
        _capacityController.text = '${event.maxCapacity}';
        _tag = _eventTags.contains(event.tag) ? event.tag : 'General';
        _club = event.club;
        _start = event.eventDate;
        _end = event.endDate;
        _deadline = event.registrationDeadline;
        _fields = event.formFields;
        _existingBannerUrl = event.bannerUrl;
        _currentRegistrations = event.currentRegistrations;
        _targetYears = event.targetYears.toSet();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e)), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? now.add(const Duration(days: 7)),
      firstDate: _isEdit ? DateTime(now.year - 1) : now,
      lastDate: now.add(const Duration(days: 730)),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? DateTime(date.year, date.month, date.day, 10)),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickBanner() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 2000);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _banner = picked;
      _bannerPreview = bytes;
    });
  }

  Future<void> _save(UserDoc user) async {
    if (!_formKey.currentState!.validate()) return;

    String? problem;
    if (_start == null) {
      problem = 'Pick the event start date and time.';
    } else if (_end != null && !_end!.isAfter(_start!)) {
      problem = 'The end time must be after the start time.';
    } else if ((_deadline ?? _start!).isAfter(_start!)) {
      problem = 'Registration must close before the event starts.';
    } else if (_fields.any((f) => f.label.trim().isEmpty)) {
      problem = 'Every registration question needs a label.';
    } else if (_fields.any((f) => f.type == FieldType.dropdown && f.options.isEmpty)) {
      problem = 'Dropdown questions need at least one option.';
    }
    if (problem != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(problem), backgroundColor: AppColors.error));
      return;
    }

    setState(() => _saving = true);
    try {
      final banner = _banner;
      final bannerUrl = banner == null ? _existingBannerUrl : await uploadImage(banner, UploadFolder.eventBanners);
      final club = user.role == UserRole.coordinator ? user.club : _club;

      String successMessage;
      if (_isEdit) {
        // Never touch ownership, the live registration counter or the
        // review status on edit — a coordinator can't self-approve.
        final data = EventDoc.newEventData(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          venue: _venueController.text.trim(),
          eventDate: _start!,
          endDate: _end,
          maxCapacity: int.parse(_capacityController.text.trim()),
          registrationDeadline: _deadline ?? _start!,
          formFields: _fields,
          tag: _tag,
          club: club,
          bannerUrl: bannerUrl,
          createdBy: user.uid,
          targetYears: _targetYears.toList(),
        )
          ..remove('createdBy')
          ..remove('currentRegistrations')
          ..remove('createdAt');
        await EventDoc.docRef(widget.eventId!).update(data);
        successMessage = 'Event updated';
      } else {
        // Goes through the backend so a coordinator's event notifies the
        // HOD for approval in the same request (an HOD's own event is
        // auto-approved).
        final result = await ref.read(renderApiServiceProvider).createEvent({
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'venue': _venueController.text.trim(),
          'eventDate': _start!.toIso8601String(),
          'endDate': _end?.toIso8601String(),
          'maxCapacity': int.parse(_capacityController.text.trim()),
          'registrationDeadline': (_deadline ?? _start!).toIso8601String(),
          'formFields': _fields.map((f) => f.toMap()).toList(),
          'tag': _tag,
          'club': club,
          'bannerUrl': bannerUrl,
          'targetYears': _targetYears.toList(),
        });
        successMessage =
            result['status'] == 'pending' ? 'Submitted — the HOD will review it shortly' : 'Event published';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage), backgroundColor: AppColors.success),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e)), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDocProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Event' : 'Create Event')),
      body: user == null || _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  _section('Basic info'),
                  TextFormField(
                    controller: _titleController,
                    maxLength: 120,
                    decoration: const InputDecoration(labelText: 'Event title'),
                    validator: (v) => (v ?? '').trim().length < 3 ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: 8,
                    maxLength: 3000,
                    decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
                    validator: (v) => (v ?? '').trim().isEmpty ? 'Description is required' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _venueController,
                    decoration: const InputDecoration(labelText: 'Venue'),
                    validator: (v) => (v ?? '').trim().isEmpty ? 'Venue is required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _tag,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [for (final t in _eventTags) DropdownMenuItem(value: t, child: Text(t))],
                    onChanged: (v) => setState(() => _tag = v ?? _tag),
                  ),
                  const SizedBox(height: 16),
                  if (user.role == UserRole.hod)
                    DropdownButtonFormField<String?>(
                      initialValue: _club,
                      decoration: const InputDecoration(labelText: 'Club (optional)'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Department (no club)')),
                        for (final c in kClubs) DropdownMenuItem(value: c, child: Text(c)),
                      ],
                      onChanged: (v) => setState(() => _club = v),
                    )
                  else
                    Text(
                      'Organised by ${user.club ?? 'your club'}',
                      style: GoogleFonts.poppins(color: AppColors.textSecondary),
                    ),
                  const SizedBox(height: 24),
                  _section('Schedule & capacity'),
                  _dateTile('Starts', _start, required: true, onPick: (d) => setState(() => _start = d)),
                  _dateTile('Ends (optional)', _end, onPick: (d) => setState(() => _end = d),
                      onClear: () => setState(() => _end = null)),
                  _dateTile('Registration closes', _deadline ?? _start,
                      onPick: (d) => setState(() => _deadline = d)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Seat capacity'),
                    validator: (v) {
                      final n = int.tryParse((v ?? '').trim());
                      if (n == null || n < 1) return 'Enter a capacity of at least 1';
                      if (n < _currentRegistrations) return '$_currentRegistrations students already registered';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _section('Who is this for?'),
                  Text(
                    'Leave everything unselected for an event open to all years.',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final entry in const {
                        '1': '1st Year',
                        '2': '2nd Year',
                        '3': '3rd Year',
                        '4': 'Final Year',
                      }.entries)
                        FilterChip(
                          label: Text(entry.value),
                          selected: _targetYears.contains(entry.key),
                          onSelected: (selected) => setState(() {
                            if (selected) {
                              _targetYears.add(entry.key);
                            } else {
                              _targetYears.remove(entry.key);
                            }
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _section('Banner (optional)'),
                  GestureDetector(
                    onTap: _pickBanner,
                    child: SizedBox(
                      height: 320,
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: AppRadius.borderRadiusLg,
                          border: Border.all(color: AppColors.border),
                          image: _bannerPreview != null
                              ? DecorationImage(image: MemoryImage(_bannerPreview!), fit: BoxFit.contain)
                              : _existingBannerUrl != null
                                  ? DecorationImage(image: NetworkImage(_existingBannerUrl!), fit: BoxFit.contain)
                                  : null,
                        ),
                        child: _bannerPreview == null && _existingBannerUrl == null
                            ? const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.cloud_upload_outlined, color: AppColors.accent, size: 32),
                                    SizedBox(height: 8),
                                    Text('Tap to upload a poster — any size works'),
                                  ],
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _section('Registration form'),
                  Text(
                    'Questions students answer when they register.',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < _fields.length; i++) _FieldEditor(
                    key: ValueKey('field_$i'),
                    field: _fields[i],
                    onChanged: (f) => setState(() => _fields = [..._fields]..[i] = f),
                    onRemove: () => setState(() => _fields = [..._fields]..removeAt(i)),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _fields = [..._fields, const RegistrationField(label: '')]),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add question'),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saving ? null : () => _save(user),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_isEdit ? 'Save changes' : 'Publish event'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
    );
  }

  Widget _dateTile(
    String label,
    DateTime? value, {
    bool required = false,
    required ValueChanged<DateTime> onPick,
    VoidCallback? onClear,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.calendar_today_outlined, color: AppColors.accent),
        title: Text(label),
        subtitle: Text(
          value == null ? (required ? 'Required — tap to choose' : 'Not set') : formatEventDate(value),
          style: TextStyle(color: value == null && required ? AppColors.error : null),
        ),
        trailing: value != null && onClear != null
            ? IconButton(tooltip: 'Clear', icon: const Icon(Icons.clear), onPressed: onClear)
            : const Icon(Icons.chevron_right_rounded),
        onTap: () async {
          final picked = await _pickDateTime(value);
          if (picked != null) onPick(picked);
        },
      ),
    );
  }
}

class _FieldEditor extends StatelessWidget {
  final RegistrationField field;
  final ValueChanged<RegistrationField> onChanged;
  final VoidCallback onRemove;

  const _FieldEditor({super.key, required this.field, required this.onChanged, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: field.label,
                    decoration: const InputDecoration(labelText: 'Question', isDense: true),
                    onChanged: (v) => onChanged(field.copyWith(label: v)),
                  ),
                ),
                IconButton(
                  tooltip: 'Remove question',
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<FieldType>(
                    initialValue: field.type,
                    isDense: true,
                    decoration: const InputDecoration(labelText: 'Answer type', isDense: true),
                    items: [
                      for (final t in FieldType.values)
                        DropdownMenuItem(value: t, child: Text(t.name[0].toUpperCase() + t.name.substring(1))),
                    ],
                    onChanged: (t) => onChanged(field.copyWith(type: t)),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Required'),
                Switch(value: field.isRequired, onChanged: (v) => onChanged(field.copyWith(isRequired: v))),
              ],
            ),
            if (field.type == FieldType.dropdown) ...[
              const SizedBox(height: 8),
              TextFormField(
                initialValue: field.options.join(', '),
                decoration: const InputDecoration(labelText: 'Options (comma separated)', isDense: true),
                onChanged: (v) => onChanged(field.copyWith(
                  options: v.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                )),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
