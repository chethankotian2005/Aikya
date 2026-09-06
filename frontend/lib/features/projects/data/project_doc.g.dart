// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_doc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectDoc _$ProjectDocFromJson(Map<String, dynamic> json) => _ProjectDoc(
  id: json['id'] as String,
  title: json['title'] as String,
  author: json['author'] as String,
  imageAsset: json['imageAsset'] as String,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  lookingForTeammate: json['lookingForTeammate'] as bool? ?? false,
);

Map<String, dynamic> _$ProjectDocToJson(_ProjectDoc instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'author': instance.author,
      'imageAsset': instance.imageAsset,
      'tags': instance.tags,
      'lookingForTeammate': instance.lookingForTeammate,
    };
