// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_doc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDoc _$UserDocFromJson(Map<String, dynamic> json) => _UserDoc(
  uid: json['uid'] as String,
  email: json['email'] as String? ?? '',
  usn: json['usn'] as String? ?? '',
  fullName: json['fullName'] as String? ?? '',
  role:
      $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.student,
  profileComplete: json['profileComplete'] as bool? ?? false,
  phone: json['phone'] as String?,
  yearOfStudy: json['yearOfStudy'] as String?,
  batch: json['batch'] as String?,
  instagramHandle: json['instagramHandle'] as String?,
  personalWebsite: json['personalWebsite'] as String?,
  profilePictureUrl: json['profilePictureUrl'] as String?,
  bio: json['bio'] as String?,
  skills:
      (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  githubUrl: json['githubUrl'] as String?,
  linkedinUrl: json['linkedinUrl'] as String?,
  twitterHandle: json['twitterHandle'] as String?,
  discordHandle: json['discordHandle'] as String?,
  status: json['status'] as String?,
  createdAt: const DateTimeConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$UserDocToJson(_UserDoc instance) => <String, dynamic>{
  'uid': instance.uid,
  'email': instance.email,
  'usn': instance.usn,
  'fullName': instance.fullName,
  'role': _$UserRoleEnumMap[instance.role]!,
  'profileComplete': instance.profileComplete,
  'phone': instance.phone,
  'yearOfStudy': instance.yearOfStudy,
  'batch': instance.batch,
  'instagramHandle': instance.instagramHandle,
  'personalWebsite': instance.personalWebsite,
  'profilePictureUrl': instance.profilePictureUrl,
  'bio': instance.bio,
  'skills': instance.skills,
  'githubUrl': instance.githubUrl,
  'linkedinUrl': instance.linkedinUrl,
  'twitterHandle': instance.twitterHandle,
  'discordHandle': instance.discordHandle,
  'status': instance.status,
  'createdAt': _$JsonConverterToJson<dynamic, DateTime>(
    instance.createdAt,
    const DateTimeConverter().toJson,
  ),
};

const _$UserRoleEnumMap = {
  UserRole.hod: 'hod',
  UserRole.eventFaculty: 'event_faculty',
  UserRole.regularFaculty: 'regular_faculty',
  UserRole.assistant: 'assistant',
  UserRole.student: 'student',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
