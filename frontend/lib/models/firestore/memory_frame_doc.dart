import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_value.dart';

/// Content moderation status for memory wall uploads.
enum FrameStatus {
  pending,
  approved,
  rejected;

  static FrameStatus parse(Object? value) =>
      FrameStatus.values.firstWhere((s) => s.name == value, orElse: () => FrameStatus.pending);
}

/// Firestore document model for `memoryFrames/{id}`.
///
/// Anyone signed in may upload (always `pending`); only the HOD approves or
/// rejects, through the backend so the uploader gets a push notification.
class MemoryFrameDoc {
  final String id;
  final String uploadedBy; // uid — the rules check this against the caller
  final String uploaderName;
  final String imageUrl;
  final String caption;
  final String eventName;
  final String? eventId;
  final FrameStatus status;
  final int likesCount;
  final String? reportMarkdown;
  final DateTime? createdAt;

  const MemoryFrameDoc({
    required this.id,
    required this.uploadedBy,
    required this.uploaderName,
    required this.imageUrl,
    this.caption = '',
    this.eventName = '',
    this.eventId,
    this.status = FrameStatus.pending,
    this.likesCount = 0,
    this.reportMarkdown,
    this.createdAt,
  });

  factory MemoryFrameDoc.fromMap(String id, Map<String, dynamic> data) {
    return MemoryFrameDoc(
      id: id,
      uploadedBy: data['uploadedBy'] as String? ?? '',
      uploaderName: data['uploaderName'] as String? ?? 'AIKYA member',
      imageUrl: data['imageUrl'] as String? ?? '',
      caption: data['caption'] as String? ?? '',
      eventName: data['eventName'] as String? ?? '',
      eventId: data['eventId'] as String?,
      status: FrameStatus.parse(data['status']),
      likesCount: (data['likesCount'] as num?)?.toInt() ?? 0,
      reportMarkdown: data['reportMarkdown'] as String?,
      createdAt: toDateTime(data['createdAt']),
    );
  }

  factory MemoryFrameDoc.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) =>
      MemoryFrameDoc.fromMap(doc.id, doc.data() ?? const {});

  /// Payload for a new upload — satisfies the `memoryFrames` create rule.
  static Map<String, dynamic> newFrame({
    required String uploadedBy,
    required String uploaderName,
    required String imageUrl,
    String caption = '',
    String eventName = '',
    String? eventId,
    String? reportMarkdown,
  }) {
    return {
      'uploadedBy': uploadedBy,
      'uploaderName': uploaderName,
      'imageUrl': imageUrl,
      'caption': caption,
      'eventName': eventName,
      'eventId': eventId,
      'status': FrameStatus.pending.name,
      'likesCount': 0,
      'reportMarkdown': reportMarkdown,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseFirestore.instance.collection('memoryFrames');
}
