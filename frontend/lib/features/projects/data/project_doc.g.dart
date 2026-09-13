// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_doc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectDoc _$ProjectDocFromJson(Map<String, dynamic> json) => _ProjectDoc(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  author: json['author'] as String,
  ownerId: json['ownerId'] as String,
  contributorIds:
      (json['contributorIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  lookingForTeammate: json['lookingForTeammate'] as bool? ?? false,
);

Map<String, dynamic> _$ProjectDocToJson(_ProjectDoc instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'author': instance.author,
      'ownerId': instance.ownerId,
      'contributorIds': instance.contributorIds,
      'imageUrls': instance.imageUrls,
      'tags': instance.tags,
      'lookingForTeammate': instance.lookingForTeammate,
    };
