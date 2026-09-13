import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'update_doc.freezed.dart';
part 'update_doc.g.dart';

@freezed
class UpdateDoc with _$UpdateDoc {
  const factory UpdateDoc({
    required String id,
    required String content,
    String? imageUrl,
    @DateTimeConverter() DateTime? deadlineDate,
    required String authorId,
    required String authorName,
    required String authorDesignation,
    String? club,
    @DateTimeConverter() required DateTime createdAt,
  }) = _UpdateDoc;

  factory UpdateDoc.fromJson(Map<String, dynamic> json) => _$UpdateDocFromJson(json);
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
    if (json is DateTime) return json;
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime object) {
    return object.toIso8601String();
  }
}
