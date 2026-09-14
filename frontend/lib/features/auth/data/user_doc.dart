import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_doc.freezed.dart';
part 'user_doc.g.dart';

/// Roles from spec §5. Unknown values decode to [student] (least privilege).
enum UserRole {
  hod,
  coordinator,
  faculty,
  student;

  String get firestoreValue => name;

  String get label => switch (this) {
        UserRole.hod => 'HOD',
        UserRole.coordinator => 'Coordinator',
        UserRole.faculty => 'Faculty',
        UserRole.student => 'Student',
      };

  bool get isStaff => this != UserRole.student;

  /// Event Builder + Report Generator access (coordinators: own events only).
  bool get canBuildEvents => this == UserRole.hod || this == UserRole.coordinator;
}

@freezed
abstract class PrivacySettings with _$PrivacySettings {
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
abstract class NotificationSettings with _$NotificationSettings {
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
    @JsonKey(unknownEnumValue: UserRole.student) @Default(UserRole.student) UserRole role,
    @Default(false) bool profileComplete,
    String? phone,
    String? yearOfStudy,
    String? batch,
    String? instagramHandle,
    String? personalWebsite,
    String? profilePictureUrl,
    int? avatarId,
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

extension UserDocX on UserDoc {
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letters = parts.take(2).map((p) => p[0]).join().toUpperCase();
    return letters.isEmpty ? '?' : letters;
  }
}

class DateTimeConverter implements JsonConverter<DateTime?, dynamic> {
  const DateTimeConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is Map<String, dynamic> && json['_seconds'] != null) {
      return DateTime.fromMillisecondsSinceEpoch(json['_seconds'] * 1000);
    }
    if (json is String) return DateTime.tryParse(json);
    if (json is DateTime) return json;
    return null;
  }

  @override
  dynamic toJson(DateTime? object) => object?.toIso8601String();
}
