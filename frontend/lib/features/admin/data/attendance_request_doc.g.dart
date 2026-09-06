// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_request_doc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendanceRequestDoc _$AttendanceRequestDocFromJson(
  Map<String, dynamic> json,
) => _AttendanceRequestDoc(
  id: json['id'] as String,
  studentId: json['studentId'] as String,
  eventId: json['eventId'] as String,
  requestDetails: json['requestDetails'] as String,
  status:
      $enumDecodeNullable(_$AttendanceStatusEnumMap, json['status']) ??
      AttendanceStatus.pending,
  reviewedBy: json['reviewedBy'] as String?,
  reviewNotes: json['reviewNotes'] as String?,
  createdAt: const DateTimeConverter().fromJson(json['createdAt']),
  updatedAt: const DateTimeConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$AttendanceRequestDocToJson(
  _AttendanceRequestDoc instance,
) => <String, dynamic>{
  'id': instance.id,
  'studentId': instance.studentId,
  'eventId': instance.eventId,
  'requestDetails': instance.requestDetails,
  'status': _$AttendanceStatusEnumMap[instance.status]!,
  'reviewedBy': instance.reviewedBy,
  'reviewNotes': instance.reviewNotes,
  'createdAt': const DateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const DateTimeConverter().toJson(instance.updatedAt),
};

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.pending: 'pending',
  AttendanceStatus.approved: 'approved',
  AttendanceStatus.rejected: 'rejected',
};
