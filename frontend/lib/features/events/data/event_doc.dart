import 'package:freezed_annotation/freezed_annotation.dart';
import '../../auth/data/user_doc.dart';

part 'event_doc.freezed.dart';
part 'event_doc.g.dart';

@freezed
abstract class EventDoc with _$EventDoc {
  const factory EventDoc({
    required String id,
    required String title,
    required String description,
    required String venue,
    @DateTimeConverter() required DateTime eventDate,
    @DateTimeConverter() DateTime? endDate,
    required int maxCapacity,
    @Default(0) int currentRegistrations,
    @DateTimeConverter() required DateTime registrationDeadline,
    Map<String, dynamic>? customFormSchema,
    required String tag,
    String? bannerUrl,
    required String createdBy,
    @DateTimeConverter() required DateTime createdAt,
  }) = _EventDoc;

  factory EventDoc.fromJson(Map<String, dynamic> json) => _$EventDocFromJson(json);
}

extension EventDocX on EventDoc {
  double get fillRatio => maxCapacity == 0 ? 0 : currentRegistrations / maxCapacity;
  bool get isNearCapacity => fillRatio >= 0.8 && fillRatio < 1.0;
  bool get isFull => fillRatio >= 1.0;
  bool get isPast => (endDate ?? eventDate).isBefore(DateTime.now());
  int get totalSeats => maxCapacity;
  int get filledSeats => currentRegistrations;
}
