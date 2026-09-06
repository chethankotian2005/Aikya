import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_doc.freezed.dart';
part 'project_doc.g.dart';

@freezed
abstract class ProjectDoc with _$ProjectDoc {
  const factory ProjectDoc({
    required String id,
    required String title,
    required String author,
    required String imageAsset,
    required List<String> tags,
    @Default(false) bool lookingForTeammate,
  }) = _ProjectDoc;

  factory ProjectDoc.fromJson(Map<String, dynamic> json) => _$ProjectDocFromJson(json);
}
