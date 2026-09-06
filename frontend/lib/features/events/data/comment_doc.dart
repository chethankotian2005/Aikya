import 'package:freezed_annotation/freezed_annotation.dart';
import '../../auth/data/user_doc.dart';

part 'comment_doc.freezed.dart';
part 'comment_doc.g.dart';

@freezed
abstract class CommentDoc with _$CommentDoc {
  const factory CommentDoc({
    required String id,
    required String userId,
    required String commentText,
    @DateTimeConverter() required DateTime createdAt,
    String? sentimentLabel,
    double? sentimentScore,
  }) = _CommentDoc;

  factory CommentDoc.fromJson(Map<String, dynamic> json) => _$CommentDocFromJson(json);
}
