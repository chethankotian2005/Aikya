import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore/firestore_value.dart';

/// Firestore document model for `projects/{projectId}` (spec §4).
class ProjectDoc {
  final String id;
  final String title;
  final String description;
  final List<String> techStack;
  final List<String> images;
  final String ownerUid;
  final String ownerName;
  final List<String> contributors;
  final bool lookingForTeammate;
  final String? repoUrl;
  final DateTime? createdAt;

  const ProjectDoc({
    required this.id,
    required this.title,
    required this.description,
    this.techStack = const [],
    this.images = const [],
    required this.ownerUid,
    this.ownerName = '',
    this.contributors = const [],
    this.lookingForTeammate = false,
    this.repoUrl,
    this.createdAt,
  });

  factory ProjectDoc.fromMap(String id, Map<String, dynamic> data) {
    return ProjectDoc(
      id: id,
      title: data['title'] as String? ?? 'Untitled project',
      description: data['description'] as String? ?? '',
      techStack: toStringList(data['techStack']),
      images: toStringList(data['images']),
      ownerUid: data['ownerUid'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? '',
      contributors: toStringList(data['contributors']),
      lookingForTeammate: data['lookingForTeammate'] as bool? ?? false,
      repoUrl: data['repoUrl'] as String?,
      createdAt: toDateTime(data['createdAt']),
    );
  }

  factory ProjectDoc.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) =>
      ProjectDoc.fromMap(doc.id, doc.data() ?? const {});

  /// Payload for a new project — satisfies the `projects` create rule.
  static Map<String, dynamic> newProject({
    required String title,
    required String description,
    required List<String> techStack,
    required List<String> images,
    required String ownerUid,
    required String ownerName,
    required bool lookingForTeammate,
    String? repoUrl,
  }) {
    return {
      'title': title,
      'description': description,
      'techStack': techStack,
      'images': images,
      'ownerUid': ownerUid,
      'ownerName': ownerName,
      'contributors': <String>[],
      'lookingForTeammate': lookingForTeammate,
      'repoUrl': repoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseFirestore.instance.collection('projects');
}
