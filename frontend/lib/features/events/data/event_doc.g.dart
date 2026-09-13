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
  eventDate: DateTime.parse(json['eventDate'] as String),
  endDate: const DateTimeConverter().fromJson(json['endDate']),
  maxCapacity: (json['maxCapacity'] as num).toInt(),
  currentRegistrations: (json['currentRegistrations'] as num?)?.toInt() ?? 0,
  registrationDeadline: DateTime.parse(json['registrationDeadline'] as String),
  customFormSchema: json['customFormSchema'] as Map<String, dynamic>?,
  tag: json['tag'] as String,
  bannerUrl: json['bannerUrl'] as String?,
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$EventDocToJson(_EventDoc instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'venue': instance.venue,
  'eventDate': instance.eventDate.toIso8601String(),
  'endDate': const DateTimeConverter().toJson(instance.endDate),
  'maxCapacity': instance.maxCapacity,
  'currentRegistrations': instance.currentRegistrations,
  'registrationDeadline': instance.registrationDeadline.toIso8601String(),
  'customFormSchema': instance.customFormSchema,
  'tag': instance.tag,
  'bannerUrl': instance.bannerUrl,
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt.toIso8601String(),
};
