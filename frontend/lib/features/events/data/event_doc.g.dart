// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_doc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventDoc _$EventDocFromJson(Map<String, dynamic> json) => _EventDoc(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  venue: json['venue'] as String,
  eventDate: const DateTimeConverter().fromJson(json['eventDate']),
  endDate: const DateTimeConverter().fromJson(json['endDate']),
  maxCapacity: (json['maxCapacity'] as num).toInt(),
  currentRegistrations: (json['currentRegistrations'] as num?)?.toInt() ?? 0,
  registrationDeadline: const DateTimeConverter().fromJson(
    json['registrationDeadline'],
  ),
  customFormSchema: json['customFormSchema'] as Map<String, dynamic>?,
  tag: json['tag'] as String,
  bannerUrl: json['bannerUrl'] as String?,
  createdBy: json['createdBy'] as String,
  createdAt: const DateTimeConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$EventDocToJson(_EventDoc instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'venue': instance.venue,
  'eventDate': const DateTimeConverter().toJson(instance.eventDate),
  'endDate': _$JsonConverterToJson<dynamic, DateTime>(
    instance.endDate,
    const DateTimeConverter().toJson,
  ),
  'maxCapacity': instance.maxCapacity,
  'currentRegistrations': instance.currentRegistrations,
  'registrationDeadline': const DateTimeConverter().toJson(
    instance.registrationDeadline,
  ),
  'customFormSchema': instance.customFormSchema,
  'tag': instance.tag,
  'bannerUrl': instance.bannerUrl,
  'createdBy': instance.createdBy,
  'createdAt': const DateTimeConverter().toJson(instance.createdAt),
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
