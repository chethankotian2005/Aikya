import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_doc.freezed.dart';
part 'user_doc.g.dart';

enum UserRole {
  hod,
  @JsonValue('event_faculty') eventFaculty,
  @JsonValue('regular_faculty') regularFaculty,
  assistant,
  student;

  String get firestoreValue {
    switch (this) {
      case UserRole.hod:
        return 'hod';
      case UserRole.eventFaculty:
        return 'event_faculty';
      case UserRole.regularFaculty:
        return 'regular_faculty';
      case UserRole.assistant:
        return 'assistant';
      case UserRole.student:
        return 'student';
    }
  }
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
    @DateTimeConverter() DateTime? createdAt,
  }) = _UserDoc;

  factory UserDoc.fromJson(Map<String, dynamic> json) => _$UserDocFromJson(json);
}

class DateTimeConverter implements JsonConverter<DateTime, dynamic> {
  const DateTimeConverter();

  @override
  DateTime fromJson(dynamic json) {
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
  dynamic toJson(DateTime object) {
    return object.toIso8601String();
  }
}
