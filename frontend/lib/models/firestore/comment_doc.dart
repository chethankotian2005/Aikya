import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_value.dart';

/// Firestore document model for `events/{eventId}/comments/{id}`.
/// Sentiment fields are written only by the backend's sentiment rollup.
class CommentDoc {
  final String id;
  final String userId;
  final String userName;
  final String commentText;
  final String? sentimentLabel;
  final DateTime? createdAt;

  const CommentDoc({
    required this.id,
    required this.userId,
    required this.userName,
    required this.commentText,
    this.sentimentLabel,
    this.createdAt,
  });

  factory CommentDoc.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return CommentDoc(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Member',
      commentText: data['commentText'] as String? ?? '',
      sentimentLabel: data['sentimentLabel'] as String?,
      createdAt: toDateTime(data['createdAt']),
    );
  }

  static Map<String, dynamic> newComment({
    required String userId,
    required String userName,
    required String commentText,
  }) {
    return {
      'userId': userId,
      'userName': userName,
      'commentText': commentText,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
