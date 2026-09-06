import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore document model for `alumniProfiles/{uid}`.
///
/// Doc ID = the alumni's Firebase Auth UID.
/// `verifiedByHod` can only be set to `true` by users with the `hod` role.
class AlumniProfileDoc {
  final String uid;
  final int graduationYear;
  final String currentCompany;
  final String jobTitle;
  final String location;
  final String linkedinUrl;
  final bool isOpenForMentorship;
  final bool verifiedByHod;
  final DateTime createdAt;

  const AlumniProfileDoc({
    required this.uid,
    required this.graduationYear,
    required this.currentCompany,
    required this.jobTitle,
    required this.location,
    required this.linkedinUrl,
    this.isOpenForMentorship = false,
    this.verifiedByHod = false,
    required this.createdAt,
  });

  factory AlumniProfileDoc.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AlumniProfileDoc(
      uid: doc.id,
      graduationYear: data['graduationYear'] as int,
      currentCompany: data['currentCompany'] as String,
      jobTitle: data['jobTitle'] as String,
      location: data['location'] as String,
      linkedinUrl: data['linkedinUrl'] as String,
      isOpenForMentorship: data['isOpenForMentorship'] as bool? ?? false,
      verifiedByHod: data['verifiedByHod'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'graduationYear': graduationYear,
      'currentCompany': currentCompany,
      'jobTitle': jobTitle,
      'location': location,
      'linkedinUrl': linkedinUrl,
      'isOpenForMentorship': isOpenForMentorship,
      'verifiedByHod': false, // Only HOD can set this via update
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseFirestore.instance.collection('alumniProfiles');

  static DocumentReference<Map<String, dynamic>> docRef(String uid) =>
      collection.doc(uid);
}
