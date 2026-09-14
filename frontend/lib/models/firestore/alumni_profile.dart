import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore document model for `alumniProfiles/{uid}`.
class AlumniProfileDoc {
  final String uid;
  final String fullName;
  final int? graduationYear;
  final String currentCompany;
  final String jobTitle;
  final String location;
  final String? linkedinUrl;
  final String? bio;
  final bool isOpenForMentorship;
  final bool verifiedByHod;

  const AlumniProfileDoc({
    required this.uid,
    required this.fullName,
    this.graduationYear,
    this.currentCompany = '',
    this.jobTitle = '',
    this.location = '',
    this.linkedinUrl,
    this.bio,
    this.isOpenForMentorship = false,
    this.verifiedByHod = false,
  });

  String get initials {
    final letters = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0])
        .join()
        .toUpperCase();
    return letters.isEmpty ? 'A' : letters;
  }

  String get roleLine {
    if (jobTitle.isNotEmpty && currentCompany.isNotEmpty) return '$jobTitle @ $currentCompany';
    return jobTitle.isNotEmpty ? jobTitle : currentCompany;
  }

  factory AlumniProfileDoc.fromMap(String uid, Map<String, dynamic> data) {
    return AlumniProfileDoc(
      uid: uid,
      fullName: data['fullName'] as String? ?? 'AIKYA Alumni',
      graduationYear: (data['graduationYear'] as num?)?.toInt(),
      currentCompany: data['currentCompany'] as String? ?? '',
      jobTitle: data['jobTitle'] as String? ?? '',
      location: data['location'] as String? ?? '',
      linkedinUrl: data['linkedinUrl'] as String?,
      bio: data['bio'] as String?,
      isOpenForMentorship: data['isOpenForMentorship'] as bool? ?? false,
      verifiedByHod: data['verifiedByHod'] as bool? ?? false,
    );
  }

  static CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseFirestore.instance.collection('alumniProfiles');
}
