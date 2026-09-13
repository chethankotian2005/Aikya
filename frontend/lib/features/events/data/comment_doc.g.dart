// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_doc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommentDoc _$CommentDocFromJson(Map<String, dynamic> json) => _CommentDoc(
  id: json['id'] as String,
  userId: json['userId'] as String,
  commentText: json['commentText'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  sentimentLabel: json['sentimentLabel'] as String?,
  sentimentScore: (json['sentimentScore'] as num?)?.toDouble(),
);

Map<String, dynamic> _$CommentDocToJson(_CommentDoc instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'commentText': instance.commentText,
      'createdAt': instance.createdAt.toIso8601String(),
      'sentimentLabel': instance.sentimentLabel,
      'sentimentScore': instance.sentimentScore,
    };
