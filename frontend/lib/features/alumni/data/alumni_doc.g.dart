// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alumni_doc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AlumniDoc _$AlumniDocFromJson(Map<String, dynamic> json) => _AlumniDoc(
  uid: json['uid'] as String,
  graduationYear: (json['graduationYear'] as num).toInt(),
  currentCompany: json['currentCompany'] as String,
  jobTitle: json['jobTitle'] as String,
  location: json['location'] as String,
  linkedinUrl: json['linkedinUrl'] as String,
  isOpenForMentorship: json['isOpenForMentorship'] as bool? ?? false,
  verifiedByHod: json['verifiedByHod'] as bool? ?? false,
  createdAt: const DateTimeConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$AlumniDocToJson(_AlumniDoc instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'graduationYear': instance.graduationYear,
      'currentCompany': instance.currentCompany,
      'jobTitle': instance.jobTitle,
      'location': instance.location,
      'linkedinUrl': instance.linkedinUrl,
      'isOpenForMentorship': instance.isOpenForMentorship,
      'verifiedByHod': instance.verifiedByHod,
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
    };
