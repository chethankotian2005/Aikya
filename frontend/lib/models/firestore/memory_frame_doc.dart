import 'package:cloud_firestore/cloud_firestore.dart';

/// Content moderation status for memory wall uploads.
enum FrameStatus {
  pending,
  approved,
  rejected;

  String get firestoreValue => name;

  static FrameStatus fromString(String value) {
    switch (value) {
      case 'approved':
        return FrameStatus.approved;
      case 'rejected':
        return FrameStatus.rejected;
      default:
        return FrameStatus.pending;
    }
  }
}

/// Firestore document model for `memoryFrames/{id}`.
///
/// Students can create; only `hod` and `assistant` can approve/reject.
/// `likesCount` is incremented atomically via `FieldValue.increment(1)`.
class MemoryFrameDoc {
  final String id;
  final String uploadedBy;
  final String imageUrl;
  final String caption;
  final String eventName;
  final String batchYear;
  final FrameStatus status;
  final String? approvedBy;
  final int likesCount;
  final DateTime createdAt;

  const MemoryFrameDoc({
    required this.id,
    required this.uploadedBy,
    required this.imageUrl,
    required this.caption,
    required this.eventName,
    required this.batchYear,
    this.status = FrameStatus.pending,
    this.approvedBy,
    this.likesCount = 0,
    required this.createdAt,
  });

  bool get isApproved => status == FrameStatus.approved;

  factory MemoryFrameDoc.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return MemoryFrameDoc(
      id: doc.id,
      uploadedBy: data['uploadedBy'] as String,
      imageUrl: data['imageUrl'] as String,
      caption: data['caption'] as String,
      eventName: data['eventName'] as String,
      batchYear: data['batchYear'] as String,
      status: FrameStatus.fromString(data['status'] as String),
      approvedBy: data['approvedBy'] as String?,
      likesCount: data['likesCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uploadedBy': uploadedBy,
      'imageUrl': imageUrl,
      'caption': caption,
      'eventName': eventName,
      'batchYear': batchYear,
      'status': FrameStatus.pending.firestoreValue,
      'approvedBy': null,
      'likesCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseFirestore.instance.collection('memoryFrames');

  static DocumentReference<Map<String, dynamic>> docRef(String id) =>
      collection.doc(id);
}
