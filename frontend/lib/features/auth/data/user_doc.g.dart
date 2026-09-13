// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_doc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrivacySettings _$PrivacySettingsFromJson(Map<String, dynamic> json) =>
    _PrivacySettings(
      publicBio: json['publicBio'] as bool? ?? true,
      publicGithub: json['publicGithub'] as bool? ?? true,
      publicLinkedin: json['publicLinkedin'] as bool? ?? true,
      publicPersonalWebsite: json['publicPersonalWebsite'] as bool? ?? true,
      publicInstagram: json['publicInstagram'] as bool? ?? true,
      publicTwitter: json['publicTwitter'] as bool? ?? true,
    );

Map<String, dynamic> _$PrivacySettingsToJson(_PrivacySettings instance) =>
    <String, dynamic>{
      'publicBio': instance.publicBio,
      'publicGithub': instance.publicGithub,
      'publicLinkedin': instance.publicLinkedin,
      'publicPersonalWebsite': instance.publicPersonalWebsite,
      'publicInstagram': instance.publicInstagram,
      'publicTwitter': instance.publicTwitter,
    };

_NotificationSettings _$NotificationSettingsFromJson(
  Map<String, dynamic> json,
) => _NotificationSettings(
  eventsEnabled: json['eventsEnabled'] as bool? ?? true,
  updatesEnabled: json['updatesEnabled'] as bool? ?? true,
  memoriesEnabled: json['memoriesEnabled'] as bool? ?? true,
);

Map<String, dynamic> _$NotificationSettingsToJson(
  _NotificationSettings instance,
) => <String, dynamic>{
  'eventsEnabled': instance.eventsEnabled,
  'updatesEnabled': instance.updatesEnabled,
  'memoriesEnabled': instance.memoriesEnabled,
};

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
  mustResetPassword: json['mustResetPassword'] as bool? ?? false,
  facultyId: json['facultyId'] as String?,
  designation: json['designation'] as String?,
  club: json['club'] as String?,
  fcmToken: json['fcmToken'] as String?,
  privacySettings: json['privacySettings'] == null
      ? const PrivacySettings()
      : PrivacySettings.fromJson(
          json['privacySettings'] as Map<String, dynamic>,
        ),
  notificationSettings: json['notificationSettings'] == null
      ? const NotificationSettings()
      : NotificationSettings.fromJson(
          json['notificationSettings'] as Map<String, dynamic>,
        ),
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
  'mustResetPassword': instance.mustResetPassword,
  'facultyId': instance.facultyId,
  'designation': instance.designation,
  'club': instance.club,
  'fcmToken': instance.fcmToken,
  'privacySettings': instance.privacySettings,
  'notificationSettings': instance.notificationSettings,
  'createdAt': const DateTimeConverter().toJson(instance.createdAt),
};

const _$UserRoleEnumMap = {
  UserRole.hod: 'hod',
  UserRole.coordinator: 'coordinator',
  UserRole.faculty: 'faculty',
  UserRole.assistant: 'assistant',
  UserRole.student: 'student',
};
