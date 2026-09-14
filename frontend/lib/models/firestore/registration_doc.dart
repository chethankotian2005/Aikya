import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_value.dart';

/// Firestore document model for `events/{eventId}/registrations/{studentUid}`.
///
/// The doc ID is the student's UID (uniqueness for free). `studentUid` and
/// `eventId` are also stored as fields for the "My registrations" query.
class RegistrationDoc {
  final String studentUid;
  final String eventId;
  final Map<String, dynamic> formResponses;
  final DateTime? registeredAt;

  const RegistrationDoc({
    required this.studentUid,
    required this.eventId,
    required this.formResponses,
    this.registeredAt,
  });

  factory RegistrationDoc.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return RegistrationDoc(
      studentUid: doc.id,
      eventId: data['eventId'] as String? ?? doc.reference.parent.parent?.id ?? '',
      formResponses: Map<String, dynamic>.from(data['formResponses'] ?? {}),
      registeredAt: toDateTime(data['registeredAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentUid': studentUid,
      'eventId': eventId,
      'formResponses': formResponses,
      'registeredAt': FieldValue.serverTimestamp(),
    };
  }
}
