import 'package:cloud_firestore/cloud_firestore.dart';

/// Status values for attendance requests.
enum AttendanceStatus {
  pending,
  approved,
  rejected;

  String get firestoreValue => name;

  static AttendanceStatus fromString(String value) {
    switch (value) {
      case 'approved':
        return AttendanceStatus.approved;
      case 'rejected':
        return AttendanceStatus.rejected;
      default:
        return AttendanceStatus.pending;
    }
  }
}

/// Firestore document model for `attendanceRequests/{requestId}`.
///
/// Only `hod` and `assistant` roles can update `status`.
class AttendanceRequestDoc {
  final String id;
  final String studentId;
  final String eventId;
  final String requestDetails;
  final AttendanceStatus status;
  final String? reviewedBy;
  final String? reviewNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AttendanceRequestDoc({
    required this.id,
    required this.studentId,
    required this.eventId,
    required this.requestDetails,
    this.status = AttendanceStatus.pending,
    this.reviewedBy,
    this.reviewNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == AttendanceStatus.pending;

  factory AttendanceRequestDoc.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AttendanceRequestDoc(
      id: doc.id,
      studentId: data['studentId'] as String,
      eventId: data['eventId'] as String,
      requestDetails: data['requestDetails'] as String,
      status: AttendanceStatus.fromString(data['status'] as String),
      reviewedBy: data['reviewedBy'] as String?,
      reviewNotes: data['reviewNotes'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// For initial creation by a student.
  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'eventId': eventId,
      'requestDetails': requestDetails,
      'status': AttendanceStatus.pending.firestoreValue,
      'reviewedBy': null,
      'reviewNotes': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// For review by hod/assistant — only updates status fields.
  Map<String, dynamic> toReviewMap({
    required AttendanceStatus newStatus,
    required String reviewerUid,
    String? notes,
  }) {
    return {
      'status': newStatus.firestoreValue,
      'reviewedBy': reviewerUid,
      'reviewNotes': notes,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseFirestore.instance.collection('attendanceRequests');

  static DocumentReference<Map<String, dynamic>> docRef(String requestId) =>
      collection.doc(requestId);
}
