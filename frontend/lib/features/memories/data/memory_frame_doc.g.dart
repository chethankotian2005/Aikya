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
      batchYear: json['batchYear'] as String,
      status:
          $enumDecodeNullable(_$FrameStatusEnumMap, json['status']) ??
          FrameStatus.pending,
      approvedBy: json['approvedBy'] as String?,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      createdAt: const DateTimeConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$MemoryFrameDocToJson(_MemoryFrameDoc instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uploadedBy': instance.uploadedBy,
      'imageUrl': instance.imageUrl,
      'caption': instance.caption,
      'eventName': instance.eventName,
      'batchYear': instance.batchYear,
      'status': _$FrameStatusEnumMap[instance.status]!,
      'approvedBy': instance.approvedBy,
      'likesCount': instance.likesCount,
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
    };

const _$FrameStatusEnumMap = {
  FrameStatus.pending: 'pending',
  FrameStatus.approved: 'approved',
  FrameStatus.rejected: 'rejected',
};
