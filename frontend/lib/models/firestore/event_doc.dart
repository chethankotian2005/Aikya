import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore document model for `events/{eventId}`.
///
/// The `currentRegistrations` field is atomically incremented via a
/// Firestore transaction in [EventRegistrationService].
class EventDoc {
  final String id;
  final String title;
  final String description;
  final String venue;
  final DateTime eventDate;
  final DateTime? endDate;
  final int maxCapacity;
  final int currentRegistrations;
  final DateTime registrationDeadline;
  final Map<String, dynamic> customFormSchema;
  final String tag;
  final String? bannerUrl;
  final String createdBy;
  final DateTime createdAt;

  const EventDoc({
    required this.id,
    required this.title,
    required this.description,
    required this.venue,
    required this.eventDate,
    this.endDate,
    required this.maxCapacity,
    this.currentRegistrations = 0,
    required this.registrationDeadline,
    this.customFormSchema = const {},
    required this.tag,
    this.bannerUrl,
    required this.createdBy,
    required this.createdAt,
  });

  bool get isFull => currentRegistrations >= maxCapacity;
  bool get isPast => eventDate.isBefore(DateTime.now());
  bool get isRegistrationOpen =>
      !isFull &&
      !isPast &&
      DateTime.now().isBefore(registrationDeadline);
  int get seatsRemaining => maxCapacity - currentRegistrations;
  double get fillRatio =>
      maxCapacity > 0 ? currentRegistrations / maxCapacity : 0;

  factory EventDoc.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return EventDoc(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String,
      venue: data['venue'] as String,
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      maxCapacity: data['maxCapacity'] as int,
      currentRegistrations: data['currentRegistrations'] as int? ?? 0,
      registrationDeadline:
          (data['registrationDeadline'] as Timestamp).toDate(),
      customFormSchema:
          Map<String, dynamic>.from(data['customFormSchema'] ?? {}),
      tag: data['tag'] as String? ?? '',
      bannerUrl: data['bannerUrl'] as String?,
      createdBy: data['createdBy'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'venue': venue,
      'eventDate': Timestamp.fromDate(eventDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'maxCapacity': maxCapacity,
      'currentRegistrations': currentRegistrations,
      'registrationDeadline': Timestamp.fromDate(registrationDeadline),
      'customFormSchema': customFormSchema,
      'tag': tag,
      'bannerUrl': bannerUrl,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseFirestore.instance.collection('events');

  static DocumentReference<Map<String, dynamic>> docRef(String eventId) =>
      collection.doc(eventId);

  /// Reference to the registrations subcollection for this event.
  static CollectionReference<Map<String, dynamic>> registrationsRef(
          String eventId) =>
      collection.doc(eventId).collection('registrations');

  /// Reference to the comments subcollection for this event.
  static CollectionReference<Map<String, dynamic>> commentsRef(
          String eventId) =>
      collection.doc(eventId).collection('comments');
}
