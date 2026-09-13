// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_doc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateDoc _$UpdateDocFromJson(Map<String, dynamic> json) => _UpdateDoc(
  id: json['id'] as String,
  content: json['content'] as String,
  imageUrl: json['imageUrl'] as String?,
  deadlineDate: const DateTimeConverter().fromJson(json['deadlineDate']),
  authorId: json['authorId'] as String,
  authorName: json['authorName'] as String,
  authorDesignation: json['authorDesignation'] as String,
  club: json['club'] as String?,
  createdAt: const DateTimeConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$UpdateDocToJson(_UpdateDoc instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'deadlineDate': _$JsonConverterToJson<dynamic, DateTime>(
        instance.deadlineDate,
        const DateTimeConverter().toJson,
      ),
      'authorId': instance.authorId,
      'authorName': instance.authorName,
      'authorDesignation': instance.authorDesignation,
      'club': instance.club,
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
