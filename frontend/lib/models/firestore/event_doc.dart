import 'package:cloud_firestore/cloud_firestore.dart';

import '../event_model.dart';
import 'firestore_value.dart';

/// Firestore document model for `events/{eventId}`.
///
/// `currentRegistrations` only moves together with a registration doc write
/// (see [EventRegistrationService] and the isJoining/isLeaving rules).
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
  final List<RegistrationField> formFields;
  final String tag;
  final String? club;
  final String? bannerUrl;
  final String createdBy;
  final DateTime? createdAt;
  final String? reportMarkdown;
  final Map<String, int>? sentimentPercentages;

  /// 'pending' (coordinator-created, awaiting HOD review), 'approved', or
  /// 'rejected'. Older events written before this field existed are treated
  /// as approved (see EventDoc.status getter).
  final String? status;
  final String? reviewNotes;

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
    this.formFields = const [],
    this.tag = 'General',
    this.club,
    this.bannerUrl,
    required this.createdBy,
    this.createdAt,
    this.reportMarkdown,
    this.sentimentPercentages,
    this.status,
    this.reviewNotes,
  });

  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  bool get isFull => currentRegistrations >= maxCapacity;
  bool get isPast => (endDate ?? eventDate).isBefore(DateTime.now());
  bool get isRegistrationOpen =>
      !isFull && !isPast && DateTime.now().isBefore(registrationDeadline);
  int get seatsRemaining => (maxCapacity - currentRegistrations).clamp(0, maxCapacity);
  double get fillRatio => maxCapacity > 0 ? currentRegistrations / maxCapacity : 0;
  bool get isNearCapacity => fillRatio >= 0.8 && !isFull;
  int get filledSeats => currentRegistrations;
  int get totalSeats => maxCapacity;

  factory EventDoc.fromMap(String id, Map<String, dynamic> data) {
    final eventDate = toDateTime(data['eventDate']) ?? DateTime.now();
    final sentiment = data['sentiment'];
    final percentages = sentiment is Map ? sentiment['percentages'] : null;

    return EventDoc(
      id: id,
      title: data['title'] as String? ?? 'Untitled event',
      description: data['description'] as String? ?? '',
      venue: data['venue'] as String? ?? '',
      eventDate: eventDate,
      endDate: toDateTime(data['endDate']),
      maxCapacity: (data['maxCapacity'] as num?)?.toInt() ?? 0,
      currentRegistrations: (data['currentRegistrations'] as num?)?.toInt() ?? 0,
      registrationDeadline: toDateTime(data['registrationDeadline']) ?? eventDate,
      formFields: RegistrationField.listFromSchema(data['customFormSchema']),
      tag: data['tag'] as String? ?? 'General',
      club: data['club'] as String?,
      bannerUrl: data['bannerUrl'] as String?,
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: toDateTime(data['createdAt']),
      reportMarkdown: data['report'] is Map ? data['report']['markdown'] as String? : null,
      sentimentPercentages: percentages is Map
          ? percentages.map((k, v) => MapEntry(k as String, (v as num).toInt()))
          : null,
      status: data['status'] as String?,
      reviewNotes: data['reviewNotes'] as String?,
    );
  }

  factory EventDoc.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) =>
      EventDoc.fromMap(doc.id, doc.data() ?? const {});

  /// Payload for a new event — satisfies the `events` create rule.
  static Map<String, dynamic> newEventData({
    required String title,
    required String description,
    required String venue,
    required DateTime eventDate,
    DateTime? endDate,
    required int maxCapacity,
    required DateTime registrationDeadline,
    required List<RegistrationField> formFields,
    required String tag,
    String? club,
    String? bannerUrl,
    required String createdBy,
  }) {
    return {
      'title': title,
      'description': description,
      'venue': venue,
      'eventDate': Timestamp.fromDate(eventDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate) : null,
      'maxCapacity': maxCapacity,
      'currentRegistrations': 0,
      'registrationDeadline': Timestamp.fromDate(registrationDeadline),
      'customFormSchema': {'fields': formFields.map((f) => f.toMap()).toList()},
      'tag': tag,
      'club': club,
      'bannerUrl': bannerUrl,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseFirestore.instance.collection('events');

  static DocumentReference<Map<String, dynamic>> docRef(String eventId) =>
      collection.doc(eventId);

  static CollectionReference<Map<String, dynamic>> registrationsRef(String eventId) =>
      collection.doc(eventId).collection('registrations');

  static CollectionReference<Map<String, dynamic>> commentsRef(String eventId) =>
      collection.doc(eventId).collection('comments');
}
