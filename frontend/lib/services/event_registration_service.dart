import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore/event_doc.dart';
import '../models/firestore/registration_doc.dart';

/// Handles event registration with an atomic Firestore transaction.
///
/// This replaces the Postgres `SELECT ... FOR UPDATE` pattern:
/// - Read the event doc inside the transaction (gets a consistent snapshot)
/// - Check `currentRegistrations < maxCapacity`
/// - Check the registration doc doesn't already exist (prevent duplicates)
/// - Write the registration doc + increment the counter atomically
///
/// If capacity is full or the student is already registered, the transaction
/// aborts and throws [RegistrationException].
class EventRegistrationService {
  final FirebaseFirestore _firestore;

  EventRegistrationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Register [studentUid] for event [eventId] with the given [formResponses].
  ///
  /// Returns the created [RegistrationDoc] on success.
  /// Throws [RegistrationException] if:
  /// - Event is at capacity
  /// - Student is already registered
  /// - Registration deadline has passed
  /// - Event does not exist
  Future<RegistrationDoc> registerForEvent({
    required String eventId,
    required String studentUid,
    required Map<String, dynamic> formResponses,
  }) async {
    final eventRef = EventDoc.docRef(eventId);
    final registrationRef =
        EventDoc.registrationsRef(eventId).doc(studentUid);

    return _firestore.runTransaction<RegistrationDoc>((transaction) async {
      // ── Step 1: Read the event doc (transactional read) ──────────────
      final eventSnapshot = await transaction.get(eventRef);

      if (!eventSnapshot.exists) {
        throw RegistrationException(
          RegistrationError.eventNotFound,
          'Event $eventId does not exist.',
        );
      }

      final event = EventDoc.fromFirestore(eventSnapshot);

      // ── Step 2: Validate registration window ────────────────────────
      if (DateTime.now().isAfter(event.registrationDeadline)) {
        throw RegistrationException(
          RegistrationError.deadlinePassed,
          'Registration deadline has passed.',
        );
      }

      if (event.isPast) {
        throw RegistrationException(
          RegistrationError.eventPast,
          'This event has already occurred.',
        );
      }

      // ── Step 3: Check capacity ──────────────────────────────────────
      if (event.currentRegistrations >= event.maxCapacity) {
        throw RegistrationException(
          RegistrationError.capacityFull,
          'Event is at maximum capacity '
              '(${event.currentRegistrations}/${event.maxCapacity}).',
        );
      }

      // ── Step 4: Check for duplicate registration ────────────────────
      final existingReg = await transaction.get(registrationRef);
      if (existingReg.exists) {
        throw RegistrationException(
          RegistrationError.alreadyRegistered,
          'Student $studentUid is already registered for this event.',
        );
      }

      // ── Step 5: Write registration + increment counter (atomic) ─────
      final regData = RegistrationDoc(
        studentUid: studentUid,
        formResponses: formResponses,
        registeredAt: DateTime.now(), // Server timestamp applied below
      );

      transaction.set(registrationRef, regData.toFirestore());

      transaction.update(eventRef, {
        'currentRegistrations': FieldValue.increment(1),
      });

      return regData;
    });
  }

  /// Cancel a registration — decrements the counter atomically.
  Future<void> cancelRegistration({
    required String eventId,
    required String studentUid,
  }) async {
    final eventRef = EventDoc.docRef(eventId);
    final registrationRef =
        EventDoc.registrationsRef(eventId).doc(studentUid);

    return _firestore.runTransaction((transaction) async {
      final regSnapshot = await transaction.get(registrationRef);

      if (!regSnapshot.exists) {
        throw RegistrationException(
          RegistrationError.notRegistered,
          'No registration found for student $studentUid.',
        );
      }

      transaction.delete(registrationRef);

      transaction.update(eventRef, {
        'currentRegistrations': FieldValue.increment(-1),
      });
    });
  }

  /// Check if a student is registered for an event (non-transactional).
  Future<bool> isRegistered({
    required String eventId,
    required String studentUid,
  }) async {
    final doc =
        await EventDoc.registrationsRef(eventId).doc(studentUid).get();
    return doc.exists;
  }
}

// ─── Exceptions ──────────────────────────────────────────────────────────────

enum RegistrationError {
  eventNotFound,
  capacityFull,
  alreadyRegistered,
  notRegistered,
  deadlinePassed,
  eventPast,
}

class RegistrationException implements Exception {
  final RegistrationError error;
  final String message;

  const RegistrationException(this.error, this.message);

  @override
  String toString() => 'RegistrationException(${error.name}): $message';
}
