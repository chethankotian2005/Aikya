import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore document model for `events/{eventId}/registrations/{studentUid}`.
///
/// The document ID is the student's UID, which gives us the unique-registration
/// constraint for free — a second write to the same doc ID would overwrite,
/// so the [EventRegistrationService] uses a transaction with exists-check.
class RegistrationDoc {
  final String studentUid;
  final Map<String, dynamic> formResponses;
  final DateTime registeredAt;

  const RegistrationDoc({
    required this.studentUid,
    required this.formResponses,
    required this.registeredAt,
  });

  factory RegistrationDoc.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return RegistrationDoc(
      studentUid: doc.id,
      formResponses: Map<String, dynamic>.from(data['formResponses'] ?? {}),
      registeredAt: (data['registeredAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'formResponses': formResponses,
      'registeredAt': FieldValue.serverTimestamp(),
    };
  }
}
