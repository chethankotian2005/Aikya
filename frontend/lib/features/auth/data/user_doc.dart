import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_doc.freezed.dart';
part 'user_doc.g.dart';

enum UserRole {
  hod,
  @JsonValue('coordinator') coordinator,
  @JsonValue('faculty') faculty,
  assistant,
  student;

  String get firestoreValue {
    switch (this) {
      case UserRole.hod:
        return 'hod';
      case UserRole.coordinator:
        return 'coordinator';
      case UserRole.faculty:
        return 'faculty';
      case UserRole.assistant:
        return 'assistant';
      case UserRole.student:
        return 'student';
    }
  }
}

@freezed
class PrivacySettings with _$PrivacySettings {
  const factory PrivacySettings({
    @Default(true) bool publicBio,
    @Default(true) bool publicGithub,
    @Default(true) bool publicLinkedin,
    @Default(true) bool publicPersonalWebsite,
    @Default(true) bool publicInstagram,
    @Default(true) bool publicTwitter,
  }) = _PrivacySettings;

  factory PrivacySettings.fromJson(Map<String, dynamic> json) => _$PrivacySettingsFromJson(json);
}

@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    @Default(true) bool eventsEnabled,
    @Default(true) bool updatesEnabled,
    @Default(true) bool memoriesEnabled,
  }) = _NotificationSettings;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) => _$NotificationSettingsFromJson(json);
}

@freezed
abstract class UserDoc with _$UserDoc {
  const factory UserDoc({
    required String uid,
    @Default('') String email,
    @Default('') String usn,
    @Default('') String fullName,
    @Default(UserRole.student) UserRole role,
    @Default(false) bool profileComplete,
    String? phone,
    String? yearOfStudy,
    String? batch,
    String? instagramHandle,
    String? personalWebsite,
    String? profilePictureUrl,
    String? bio,
    @Default([]) List<String> skills,
    String? githubUrl,
    String? linkedinUrl,
    String? twitterHandle,
    String? discordHandle,
    String? status, // e.g. pending_batch_review
    @Default(false) bool mustResetPassword,
    String? facultyId,
    String? designation,
    String? club,
    String? fcmToken,
    @Default(PrivacySettings()) PrivacySettings privacySettings,
    @Default(NotificationSettings()) NotificationSettings notificationSettings,
    @DateTimeConverter() DateTime? createdAt,
  }) = _UserDoc;

  factory UserDoc.fromJson(Map<String, dynamic> json) => _$UserDocFromJson(json);
}
class DateTimeConverter implements JsonConverter<DateTime?, dynamic> {
  const DateTimeConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) {
      return json.toDate();
    }
    if (json is Map<String, dynamic> && json['_seconds'] != null) {
      return DateTime.fromMillisecondsSinceEpoch(json['_seconds'] * 1000);
    }
    if (json is String) {
      return DateTime.parse(json);
    }
    // Fallback if the timestamp is already a DateTime (e.g. from local cache)
    if (json is DateTime) return json;
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime? object) {
    if (object == null) return null;
    return object.toIso8601String();
  }
}
