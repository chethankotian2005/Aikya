import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore document model for `events/{eventId}/comments/{commentId}`.
///
/// `sentimentLabel` and `sentimentScore` are nullable — populated later
/// by the sentiment analysis endpoint (server-side / Cloud Function).
class CommentDoc {
  final String id;
  final String userId;
  final String commentText;
  final DateTime createdAt;
  final String? sentimentLabel;
  final double? sentimentScore;

  const CommentDoc({
    required this.id,
    required this.userId,
    required this.commentText,
    required this.createdAt,
    this.sentimentLabel,
    this.sentimentScore,
  });

  factory CommentDoc.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CommentDoc(
      id: doc.id,
      userId: data['userId'] as String,
      commentText: data['commentText'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      sentimentLabel: data['sentimentLabel'] as String?,
      sentimentScore: (data['sentimentScore'] as num?)?.toDouble(),
    );
  }

  /// Client-side creation — sentiment fields are omitted (server populates).
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'commentText': commentText,
      'createdAt': FieldValue.serverTimestamp(),
      // sentimentLabel and sentimentScore intentionally omitted —
      // written by the server-side sentiment endpoint only.
    };
  }
}
