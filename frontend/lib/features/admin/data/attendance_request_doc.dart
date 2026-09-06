import 'package:freezed_annotation/freezed_annotation.dart';
import '../../auth/data/user_doc.dart';

part 'attendance_request_doc.freezed.dart';
part 'attendance_request_doc.g.dart';

enum AttendanceStatus {
  pending,
  approved,
  rejected;

  String get firestoreValue => name;
}

@freezed
abstract class AttendanceRequestDoc with _$AttendanceRequestDoc {
  const factory AttendanceRequestDoc({
    required String id,
    required String studentId,
    required String eventId,
    required String requestDetails,
    @Default(AttendanceStatus.pending) AttendanceStatus status,
    String? reviewedBy,
    String? reviewNotes,
    @DateTimeConverter() required DateTime createdAt,
    @DateTimeConverter() required DateTime updatedAt,
  }) = _AttendanceRequestDoc;

  factory AttendanceRequestDoc.fromJson(Map<String, dynamic> json) => _$AttendanceRequestDocFromJson(json);
}
