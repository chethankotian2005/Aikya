import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_value.dart';

/// Firestore document model for top-level `attendanceRequests/{id}`.
///
/// Students create their own (always `pending`); the HOD approves or rejects
/// through the backend so the student is notified.
class AttendanceRequestDoc {
  final String id;
  final String studentId;
  final String eventId;
  final String requestDetails;
  final String status; // pending | approved | rejected
  final String? reviewNotes;
  final DateTime? createdAt;
  final DateTime? reviewedAt;

  const AttendanceRequestDoc({
    required this.id,
    required this.studentId,
    required this.eventId,
    required this.requestDetails,
    this.status = 'pending',
    this.reviewNotes,
    this.createdAt,
    this.reviewedAt,
  });

  bool get isPending => status == 'pending';

  factory AttendanceRequestDoc.fromMap(String id, Map<String, dynamic> data) {
    return AttendanceRequestDoc(
      id: id,
      studentId: data['studentId'] as String? ?? '',
      eventId: data['eventId'] as String? ?? '',
      requestDetails: data['requestDetails'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      reviewNotes: data['reviewNotes'] as String?,
      createdAt: toDateTime(data['createdAt']),
      reviewedAt: toDateTime(data['reviewedAt']),
    );
  }

  factory AttendanceRequestDoc.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) =>
      AttendanceRequestDoc.fromMap(doc.id, doc.data() ?? const {});

  static Map<String, dynamic> newRequest({
    required String studentId,
    required String eventId,
    required String requestDetails,
  }) {
    return {
      'studentId': studentId,
      'eventId': eventId,
      'requestDetails': requestDetails,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseFirestore.instance.collection('attendanceRequests');
}
