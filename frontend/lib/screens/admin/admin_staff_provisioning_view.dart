import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_tokens.dart';
import '../../features/auth/data/user_doc.dart';
import '../../services/firebase_service.dart';
import '../../services/render_api_service.dart';
import '../../utils/friendly_error.dart';
import '../../widgets/shared_widgets.dart';

/// The five clubs a coordinator can lead (spec §5).
const kClubs = ['Aikya', 'IEEE', 'ISTE', 'Co-curricular', 'Extra-curricular'];

final _staffProvider = StreamProvider.autoDispose<List<UserDoc>>((ref) {
  return ref
      .read(firebaseServiceProvider)
      .firestore
      .collection('users')
      .where('role', whereIn: ['faculty', 'coordinator', 'hod'])
      .snapshots()
      .map((snap) => snap.docs.map((d) => UserDoc.fromJson({...d.data(), 'uid': d.id})).toList()
        ..sort((a, b) => a.fullName.compareTo(b.fullName)));
});

/// HOD-only Staff Provisioning via POST /api/admin/provision-staff.
class AdminStaffProvisioningView extends ConsumerStatefulWidget {
  const AdminStaffProvisioningView({super.key});

  @override
  ConsumerState<AdminStaffProvisioningView> createState() => _AdminStaffProvisioningViewState();
}

class _AdminStaffProvisioningViewState extends ConsumerState<AdminStaffProvisioningView> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _designationController = TextEditingController();
  UserRole _role = UserRole.faculty;
  String? _club;
  bool _saving = false;

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _provision() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final facultyId = _idController.text.trim();
      final result = await ref.read(renderApiServiceProvider).provisionStaff([
        {
          'facultyId': facultyId,
          'fullName': _nameController.text.trim(),
          'designation': _designationController.text.trim(),
          'role': _role.firestoreValue,
          if (_role == UserRole.coordinator) 'club': _club,
        },
      ]);

      if (!mounted) return;
      final errors = (result['errors'] as List?) ?? const [];
      if (errors.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text((errors.first as Map)['error']?.toString() ?? 'Provisioning failed.'),
          backgroundColor: AppColors.error,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Account ready. Faculty ID $facultyId, first password $facultyId@ml.'),
          backgroundColor: AppColors.success,
        ));
        _formKey.currentState!.reset();
        _idController.clear();
        _nameController.clear();
        _designationController.clear();
        setState(() {
          _role = UserRole.faculty;
          _club = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e)), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(_staffProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Staff provisioning', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(
          'New faculty and coordinators log in with their Faculty ID. The first password is {FacultyID}@ml and they must change it on first login.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _idController,
                    decoration: const InputDecoration(labelText: 'Faculty ID', hintText: 'e.g. 0544'),
                    validator: (v) => RegExp(r'^[A-Za-z0-9]{3,20}$').hasMatch((v ?? '').trim())
                        ? null
                        : '3–20 letters or digits',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _designationController,
                    decoration: const InputDecoration(labelText: 'Designation (optional)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<UserRole>(
                    initialValue: _role,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: const [
                      DropdownMenuItem(value: UserRole.faculty, child: Text('Faculty')),
                      DropdownMenuItem(value: UserRole.coordinator, child: Text('Coordinator')),
                    ],
                    onChanged: (v) => setState(() => _role = v ?? UserRole.faculty),
                  ),
                  if (_role == UserRole.coordinator) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _club,
                      decoration: const InputDecoration(labelText: 'Club'),
                      items: [for (final c in kClubs) DropdownMenuItem(value: c, child: Text(c))],
                      onChanged: (v) => setState(() => _club = v),
                      validator: (v) => v == null ? 'Coordinators need a club' : null,
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _provision,
                      child: _saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Create account'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Current staff', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        staff.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(friendlyError(e)),
          data: (list) => Column(
            children: [
              for (final s in list)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(s.fullName),
                    subtitle: Text(
                      [s.role.label, if (s.club != null) s.club, if (s.facultyId != null) 'ID ${s.facultyId}'].join(' · '),
                    ),
                    trailing: s.mustResetPassword
                        ? const TagChip(label: 'Awaiting first login', color: AppColors.warning)
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
