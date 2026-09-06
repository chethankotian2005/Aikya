import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore document model for `accreditationReports/{id}`.
///
/// Only the `hod` role can create and manage these reports.
class AccreditationReportDoc {
  final String id;
  final String semesterLabel;
  final String compiledBy;
  final List<String> includedEventIds;
  final String pdfUrl;
  final DateTime generatedAt;

  const AccreditationReportDoc({
    required this.id,
    required this.semesterLabel,
    required this.compiledBy,
    required this.includedEventIds,
    required this.pdfUrl,
    required this.generatedAt,
  });

  factory AccreditationReportDoc.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AccreditationReportDoc(
      id: doc.id,
      semesterLabel: data['semesterLabel'] as String,
      compiledBy: data['compiledBy'] as String,
      includedEventIds: List<String>.from(data['includedEventIds'] ?? []),
      pdfUrl: data['pdfUrl'] as String,
      generatedAt: (data['generatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'semesterLabel': semesterLabel,
      'compiledBy': compiledBy,
      'includedEventIds': includedEventIds,
      'pdfUrl': pdfUrl,
      'generatedAt': FieldValue.serverTimestamp(),
    };
  }

  static CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseFirestore.instance.collection('accreditationReports');

  static DocumentReference<Map<String, dynamic>> docRef(String id) =>
      collection.doc(id);
}
