import 'package:freezed_annotation/freezed_annotation.dart';
import '../../auth/data/user_doc.dart';

part 'memory_frame_doc.freezed.dart';
part 'memory_frame_doc.g.dart';

enum FrameStatus {
  pending,
  approved,
  rejected;

  String get firestoreValue => name;
}

@freezed
abstract class MemoryFrameDoc with _$MemoryFrameDoc {
  const factory MemoryFrameDoc({
    required String id,
    required String uploadedBy,
    required String imageUrl,
    required String caption,
    required String eventName,
    required String batchYear,
    @Default(FrameStatus.pending) FrameStatus status,
    String? approvedBy,
    @Default(0) int likesCount,
    @DateTimeConverter() required DateTime createdAt,
  }) = _MemoryFrameDoc;

  factory MemoryFrameDoc.fromJson(Map<String, dynamic> json) => _$MemoryFrameDocFromJson(json);
}
