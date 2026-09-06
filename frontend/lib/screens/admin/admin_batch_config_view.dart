import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_tokens.dart';
import '../../features/admin/data/batch_config_doc.dart';

class AdminBatchConfigView extends StatefulWidget {
  const AdminBatchConfigView({super.key});

  @override
  State<AdminBatchConfigView> createState() => _AdminBatchConfigViewState();
}

class _AdminBatchConfigViewState extends State<AdminBatchConfigView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showAddDialog() {
    String admissionYY = '25';
    String entryType = 'regular';
    int yearOfStudy = 1;
    String label = '1st Year';
    bool graduated = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Batch Config'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Admission Year (e.g. 25)'),
                      onChanged: (val) => admissionYY = val,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: entryType,
                      decoration: const InputDecoration(labelText: 'Entry Type'),
                      items: const [
                        DropdownMenuItem(value: 'regular', child: Text('Regular')),
                        DropdownMenuItem(value: 'lateral_diploma', child: Text('Lateral Diploma')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => entryType = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: yearOfStudy,
                      decoration: const InputDecoration(labelText: 'Year of Study'),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1')),
                        DropdownMenuItem(value: 2, child: Text('2')),
                        DropdownMenuItem(value: 3, child: Text('3')),
                        DropdownMenuItem(value: 4, child: Text('4')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => yearOfStudy = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Label (e.g. 1st Year)'),
                      onChanged: (val) => label = val,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Graduated'),
                      value: graduated,
                      onChanged: (val) => setState(() => graduated = val),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final key = '${admissionYY}_$entryType';
                    _firestore.collection('academicBatchConfig').doc(key).set({
                      'yearOfStudy': yearOfStudy,
                      'label': label,
                      'graduated': graduated,
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Academic Batch Config',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage mapping from USN to Year of Study',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Row'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('academicBatchConfig').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final docs = snapshot.data?.docs ?? [];
                
                if (docs.isEmpty) {
                  return const Center(child: Text('No configurations found.'));
                }
                
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final config = BatchConfigDoc.fromJson(data);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderRadiusMd,
                        side: BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc.id,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Entry ID',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.textTertiary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<int>(
                                value: config.yearOfStudy,
                                decoration: const InputDecoration(
                                  labelText: 'Year',
                                  isDense: true,
                                ),
                                items: const [
                                  DropdownMenuItem(value: 1, child: Text('1')),
                                  DropdownMenuItem(value: 2, child: Text('2')),
                                  DropdownMenuItem(value: 3, child: Text('3')),
                                  DropdownMenuItem(value: 4, child: Text('4')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    doc.reference.update({'yearOfStudy': val});
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                initialValue: config.label,
                                decoration: const InputDecoration(
                                  labelText: 'Label',
                                  isDense: true,
                                ),
                                onFieldSubmitted: (val) {
                                  doc.reference.update({'label': val});
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: SwitchListTile(
                                title: const Text('Graduated', style: TextStyle(fontSize: 12)),
                                contentPadding: EdgeInsets.zero,
                                value: config.graduated,
                                onChanged: (val) {
                                  doc.reference.update({'graduated': val});
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Delete Config?'),
                                    content: Text('Are you sure you want to delete ${doc.id}?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          doc.reference.delete();
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
