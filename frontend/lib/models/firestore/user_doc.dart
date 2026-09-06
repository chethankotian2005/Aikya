import 'package:cloud_firestore/cloud_firestore.dart';

/// 5-tier role hierarchy for AIKYA RBAC.
enum UserRole {
  hod,
  eventFaculty,
  regularFaculty,
  assistant,
  student;

  /// Firestore string ↔ enum conversion.
  String get firestoreValue {
    switch (this) {
      case UserRole.hod:
        return 'hod';
      case UserRole.eventFaculty:
        return 'event_faculty';
      case UserRole.regularFaculty:
        return 'regular_faculty';
      case UserRole.assistant:
        return 'assistant';
      case UserRole.student:
        return 'student';
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'hod':
        return UserRole.hod;
      case 'event_faculty':
        return UserRole.eventFaculty;
      case 'regular_faculty':
        return UserRole.regularFaculty;
      case 'assistant':
        return UserRole.assistant;
      case 'student':
        return UserRole.student;
      default:
        return UserRole.student;
    }
  }

  /// Whether this role can create/edit events.
  bool get canManageEvents =>
      this == UserRole.hod || this == UserRole.eventFaculty;

  /// Whether this role can approve/reject attendance requests.
  bool get canReviewAttendance =>
      this == UserRole.hod || this == UserRole.assistant;

  /// Whether this role can approve memory wall uploads.
  bool get canModerateContent =>
      this == UserRole.hod || this == UserRole.assistant;

  /// Whether this role can compile accreditation reports.
  bool get canCompileReports => this == UserRole.hod;

  /// Whether this role can verify alumni profiles.
  bool get canVerifyAlumni => this == UserRole.hod;
}

/// Firestore document model for `users/{uid}`.
///
/// USN is validated on create via security rules:
/// `^4MW[0-9]{2}AI[0-9]{3}$`
class UserDoc {
  final String uid;
  final String email;
  final String usn;
  final String fullName;
  final UserRole role;
  final String? bio;
  final List<String> skills;
  final String? githubUrl;
  final DateTime createdAt;

  const UserDoc({
    required this.uid,
    required this.email,
    required this.usn,
    required this.fullName,
    required this.role,
    this.bio,
    this.skills = const [],
    this.githubUrl,
    required this.createdAt,
  });

  /// Deserialize from a Firestore document snapshot.
  factory UserDoc.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserDoc(
      uid: doc.id,
      email: data['email'] as String,
      usn: data['usn'] as String,
      fullName: data['fullName'] as String,
      role: UserRole.fromString(data['role'] as String),
      bio: data['bio'] as String?,
      skills: List<String>.from(data['skills'] ?? []),
      githubUrl: data['githubUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Serialize to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'usn': usn,
      'fullName': fullName,
      'role': role.firestoreValue,
      'bio': bio,
      'skills': skills,
      'githubUrl': githubUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// For updates — excludes immutable fields (email, usn, createdAt).
  Map<String, dynamic> toUpdateMap() {
    return {
      'fullName': fullName,
      'role': role.firestoreValue,
      'bio': bio,
      'skills': skills,
      'githubUrl': githubUrl,
    };
  }

  /// Firestore collection reference.
  static CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseFirestore.instance.collection('users');

  /// Get a specific user document reference.
  static DocumentReference<Map<String, dynamic>> docRef(String uid) =>
      collection.doc(uid);
}
