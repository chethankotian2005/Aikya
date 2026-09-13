// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_frame_doc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MemoryFrameDoc _$MemoryFrameDocFromJson(Map<String, dynamic> json) =>
    _MemoryFrameDoc(
      id: json['id'] as String,
      uploadedBy: json['uploadedBy'] as String,
      imageUrl: json['imageUrl'] as String,
      caption: json['caption'] as String,
      eventName: json['eventName'] as String,
      eventId: json['eventId'] as String?,
      batchYear: json['batchYear'] as String,
      status:
          $enumDecodeNullable(_$FrameStatusEnumMap, json['status']) ??
          FrameStatus.pending,
      approvedBy: json['approvedBy'] as String?,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      reportMarkdown: json['reportMarkdown'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MemoryFrameDocToJson(_MemoryFrameDoc instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uploadedBy': instance.uploadedBy,
      'imageUrl': instance.imageUrl,
      'caption': instance.caption,
      'eventName': instance.eventName,
      'eventId': instance.eventId,
      'batchYear': instance.batchYear,
      'status': _$FrameStatusEnumMap[instance.status]!,
      'approvedBy': instance.approvedBy,
      'likesCount': instance.likesCount,
      'reportMarkdown': instance.reportMarkdown,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$FrameStatusEnumMap = {
  FrameStatus.pending: 'pending',
  FrameStatus.approved: 'approved',
  FrameStatus.rejected: 'rejected',
};
