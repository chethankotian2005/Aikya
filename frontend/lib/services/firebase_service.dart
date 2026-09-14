import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/user_doc.dart';

/// Student USNs must match the AI & ML pattern (spec §5), e.g. 4MW21AI042.
final usnPattern = RegExp(r'^4MW\d{2}AI\d{3}$');

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserDocProvider = StreamProvider<UserDoc?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    try {
      return UserDoc.fromJson({...doc.data()!, 'uid': doc.id});
    } catch (e, stack) {
      debugPrint('Error parsing UserDoc: $e\n$stack');
      return null;
    }
  });
});

/// The signed-in user's role, read from their own users/{uid} doc.
final userRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(currentUserDocProvider).valueOrNull?.role;
});

class FirebaseService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static String usnToEmail(String usn) =>
      '${usn.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '')}@aikya.smvitm.edu';

  static String facultyIdToEmail(String facultyId) =>
      '${facultyId.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '')}@aikya.internal';

  Future<void> signInWithUsnAndPassword(String usn, String password) {
    return auth.signInWithEmailAndPassword(email: usnToEmail(usn), password: password);
  }

  Future<void> signInWithFacultyIdAndPassword(String facultyId, String password) {
    return auth.signInWithEmailAndPassword(email: facultyIdToEmail(facultyId), password: password);
  }

  Future<void> updatePasswordAndClearResetFlag(String newPassword) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('Please sign in again.');

    await user.updatePassword(newPassword);
    await firestore.collection('users').doc(user.uid).update({'mustResetPassword': false});
  }

  /// Student self-signup (spec §5). If the profile write is rejected, the new
  /// Auth account is deleted so the student can retry with the same USN.
  Future<void> signUpWithUsn({
    required String name,
    required String phone,
    required String usn,
    required String password,
  }) async {
    final normalizedUsn = usn.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
    if (!usnPattern.hasMatch(normalizedUsn)) {
      throw Exception('Invalid USN format. Expected e.g. 4MW21AI042.');
    }

    final email = usnToEmail(normalizedUsn);
    final credential = await auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = credential.user!;

    try {
      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'usn': normalizedUsn,
        'fullName': name.trim(),
        'role': UserRole.student.firestoreValue,
        'phone': phone.trim().isEmpty ? null : phone.trim(),
        'profileComplete': false,
        'mustResetPassword': false,
        'skills': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      await user.delete();
      rethrow;
    }
  }

  Future<void> signOut() => auth.signOut();

  Future<List<UserDoc>> getStudentDirectory() async {
    final snapshot = await firestore
        .collection('users')
        .where('role', isEqualTo: UserRole.student.firestoreValue)
        .get();

    return snapshot.docs
        .map((doc) {
          try {
            return UserDoc.fromJson({...doc.data(), 'uid': doc.id});
          } catch (_) {
            return null;
          }
        })
        .whereType<UserDoc>()
        .toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));
  }
}
