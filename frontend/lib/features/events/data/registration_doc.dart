import 'package:freezed_annotation/freezed_annotation.dart';
import '../../auth/data/user_doc.dart';

part 'registration_doc.freezed.dart';
part 'registration_doc.g.dart';

@freezed
abstract class RegistrationDoc with _$RegistrationDoc {
  const factory RegistrationDoc({
    required String eventId,
    required String studentUid,
    required Map<String, dynamic> formResponses,
    @DateTimeConverter() required DateTime registeredAt,
  }) = _RegistrationDoc;

  factory RegistrationDoc.fromJson(Map<String, dynamic> json) => _$RegistrationDocFromJson(json);
}
