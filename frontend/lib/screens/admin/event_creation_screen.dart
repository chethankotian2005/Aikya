import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_tokens.dart';

class EventCreationScreen extends StatefulWidget {
  const EventCreationScreen({super.key});

  @override
  State<EventCreationScreen> createState() => _EventCreationScreenState();
}

class _EventCreationScreenState extends State<EventCreationScreen> {
  int _currentStep = 0;

  // Basic Info
  final _titleController = TextEditingController(text: 'Introduction to GenAI');
  final _venueController = TextEditingController(text: 'Main Seminar Hall');
  String _selectedDate = 'Oct 15, 2026';
  String _selectedTime = '10:00 AM';

  // Capacity & Deadline
  double _seatCap = 50;
  String _deadlineDate = 'Oct 12, 2026';

  // Dynamic Form Builder
  List<Map<String, dynamic>> _formFields = [
    {'type': 'short_text', 'label': 'Full Name', 'required': true},
    {'type': 'short_text', 'label': 'USN', 'required': true},
    {'type': 'dropdown', 'label': 'Semester', 'options': ['4th', '6th', '8th'], 'required': true},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  void _addFormField() {
    setState(() {
      _formFields.add({
        'type': 'short_text',
        'label': 'New Question',
        'required': false,
      });
    });
  }

  String get _liveJsonPreview {
    final Map<String, dynamic> schema = {
      'event_title': _titleController.text,
      'venue': _venueController.text,
      'datetime': '$_selectedDate $_selectedTime',
      'capacity': _seatCap.toInt(),
      'deadline': _deadlineDate,
      'registration_schema': _formFields,
    };
    return const JsonEncoder.withIndent('  ').convert(schema);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      appBar: AppBar(
        backgroundColor: AppColors.primarySurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'Create New Event',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 800;
          
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Stepper Area
              Expanded(
                flex: 2,
                child: Stepper(
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep < 2) {
                      setState(() => _currentStep += 1);
                    } else {
                      // Submit event
                      Navigator.of(context).pop();
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep -= 1);
                    }
                  },
                  controlsBuilder: (context, details) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              _currentStep == 2 ? 'Publish Event' : 'Continue',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (_currentStep > 0)
                            TextButton(
                              onPressed: details.onStepCancel,
                              child: Text(
                                'Back',
                                style: GoogleFonts.poppins(color: AppColors.textSecondary),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  steps: [
                    Step(
                      title: Text('Basic Info', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      content: _buildStep1BasicInfo(),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                    ),
                    Step(
                      title: Text('Capacity & Deadline', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      content: _buildStep2Capacity(),
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                    ),
                    Step(
                      title: Text('Dynamic Form Builder', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      content: _buildStep3FormBuilder(),
                      isActive: _currentStep >= 2,
                    ),
                  ],
                ),
              ),
              
              // JSON Preview Panel for Large Screens
              if (isLargeScreen)
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: AppRadius.borderRadiusLg,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: AppColors.border)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.code_rounded, color: AppColors.accent, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Live JSON Schema',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _liveJsonPreview,
                              style: GoogleFonts.robotoMono(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ─── Step 1: Basic Info ───────────────────────────────────────────
  Widget _buildStep1BasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Event Title', _titleController),
        const SizedBox(height: 16),
        _buildTextField('Venue', _venueController),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMockPicker('Date', _selectedDate, Icons.calendar_today_rounded)),
            const SizedBox(width: 16),
            Expanded(child: _buildMockPicker('Time', _selectedTime, Icons.access_time_rounded)),
          ],
        ),
        const SizedBox(height: 24),
        Text('Banner Image', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: AppRadius.borderRadiusMd,
            border: Border.all(color: AppColors.border, style: BorderStyle.solid),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_upload_outlined, color: AppColors.accent, size: 32),
                const SizedBox(height: 8),
                Text('Tap to upload banner (16:9)', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Step 2: Capacity & Deadline ──────────────────────────────────
  Widget _buildStep2Capacity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Seat Capacity', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary)),
            Text('${_seatCap.toInt()} Seats', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.accent)),
          ],
        ),
        Slider(
          value: _seatCap,
          min: 10,
          max: 200,
          divisions: 19,
          activeColor: AppColors.accent,
          inactiveColor: AppColors.primaryContainer,
          onChanged: (v) => setState(() => _seatCap = v),
        ),
        const SizedBox(height: 24),
        _buildMockPicker('Registration Deadline', _deadlineDate, Icons.event_busy_rounded),
      ],
    );
  }

  // ─── Step 3: Dynamic Form Builder ─────────────────────────────────
  Widget _buildStep3FormBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Drag to reorder questions. These will be presented to students when they register.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: AppRadius.borderRadiusMd,
            color: AppColors.surfaceElevated,
          ),
          child: ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _formFields.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = _formFields.removeAt(oldIndex);
                _formFields.insert(newIndex, item);
              });
            },
            itemBuilder: (context, index) {
              final field = _formFields[index];
              return _buildFormBlock(
                key: ValueKey(field),
                index: index,
                field: field,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _addFormField,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add Question'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accent,
            side: const BorderSide(color: AppColors.accent),
          ),
        ),
      ],
    );
  }

  Widget _buildFormBlock({required Key key, required int index, required Map<String, dynamic> field}) {
    IconData typeIcon;
    switch (field['type']) {
      case 'dropdown':
        typeIcon = Icons.arrow_drop_down_circle_outlined;
        break;
      case 'checkbox':
        typeIcon = Icons.check_box_outlined;
        break;
      default:
        typeIcon = Icons.short_text_rounded;
    }

    return Container(
      key: key,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator_rounded, color: AppColors.textTertiary, size: 20),
          const SizedBox(width: 12),
          Icon(typeIcon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field['label'],
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  field['type'].toString().toUpperCase(),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textTertiary, fontSize: 10, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
          Switch(
            value: field['required'],
            onChanged: (v) {
              setState(() {
                field['required'] = v;
              });
            },
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.accent,
            inactiveTrackColor: AppColors.primaryContainer,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
            onPressed: () {
              setState(() {
                _formFields.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────
  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceElevated,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: AppRadius.borderRadiusSm, borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: AppRadius.borderRadiusSm, borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: AppRadius.borderRadiusSm, borderSide: const BorderSide(color: AppColors.accent)),
          ),
        ),
      ],
    );
  }

  Widget _buildMockPicker(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: AppRadius.borderRadiusSm,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14)),
              Icon(icon, size: 18, color: AppColors.textTertiary),
            ],
          ),
        ),
      ],
    );
  }
}
