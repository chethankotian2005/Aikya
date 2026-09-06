import 'package:cloud_firestore/cloud_firestore.dart';

/// One-time seeder for academicBatchConfig collection.
/// Call this from any screen (e.g., a button press) while logged in.
class AcademicBatchSeeder {
  static Future<void> seed() async {
    final db = FirebaseFirestore.instance;

    final configs = [
      // Alumni (graduated)
      {'key': '20_regular',         'yearOfStudy': 4, 'label': 'Alumni',      'graduated': true},
      {'key': '20_lateral_diploma', 'yearOfStudy': 4, 'label': 'Alumni',      'graduated': true},
      {'key': '21_regular',         'yearOfStudy': 4, 'label': 'Alumni',      'graduated': true},
      {'key': '21_lateral_diploma', 'yearOfStudy': 4, 'label': 'Alumni',      'graduated': true},
      {'key': '22_regular',         'yearOfStudy': 4, 'label': 'Alumni',      'graduated': true},
      {'key': '22_lateral_diploma', 'yearOfStudy': 4, 'label': 'Alumni',      'graduated': true},
      // Current students (2026-27 academic year)
      {'key': '23_regular',         'yearOfStudy': 4, 'label': 'Final Year',  'graduated': false},
      {'key': '23_lateral_diploma', 'yearOfStudy': 4, 'label': 'Final Year',  'graduated': false},
      {'key': '24_regular',         'yearOfStudy': 3, 'label': '3rd Year',    'graduated': false},
      {'key': '24_lateral_diploma', 'yearOfStudy': 3, 'label': '3rd Year',    'graduated': false},
      {'key': '25_regular',         'yearOfStudy': 2, 'label': '2nd Year',    'graduated': false},
      {'key': '25_lateral_diploma', 'yearOfStudy': 2, 'label': '2nd Year',    'graduated': false},
      {'key': '26_regular',         'yearOfStudy': 1, 'label': '1st Year',    'graduated': false},
    ];

    final batch = db.batch();
    for (final config in configs) {
      final key = config.remove('key') as String;
      batch.set(db.collection('academicBatchConfig').doc(key), config);
    }
    await batch.commit();
  }
}
