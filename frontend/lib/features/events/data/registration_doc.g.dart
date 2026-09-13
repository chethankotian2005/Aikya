// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_doc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegistrationDoc _$RegistrationDocFromJson(Map<String, dynamic> json) =>
    _RegistrationDoc(
      eventId: json['eventId'] as String,
      studentUid: json['studentUid'] as String,
      formResponses: json['formResponses'] as Map<String, dynamic>,
      registeredAt: DateTime.parse(json['registeredAt'] as String),
    );

Map<String, dynamic> _$RegistrationDocToJson(_RegistrationDoc instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'studentUid': instance.studentUid,
      'formResponses': instance.formResponses,
      'registeredAt': instance.registeredAt.toIso8601String(),
    };
