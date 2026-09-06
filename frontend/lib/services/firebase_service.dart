import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/user_doc.dart';

/// Provides the global FirebaseService instance.
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

/// Provides the current FirebaseAuth user as a stream.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provides the current UserDoc as a stream.
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
          final data = Map<String, dynamic>.from(doc.data()!);
          data['uid'] = doc.id; // Ensure uid is always present
          return UserDoc.fromJson(data);
        } catch (e, stack) {
          print('Error parsing UserDoc: $e\n$stack');
          return null; // Return null so we don't break the stream, but print the error!
        }
      });
});

/// Provides the current user's role by looking up their Firestore document.
final userRoleProvider = FutureProvider<UserRole?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();
      
  if (!doc.exists) return null;
  final data = doc.data()!;
  return UserRole.values.byName(data['role'] as String? ?? 'student');
});

class FirebaseService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ── Auth Methods ────────────────────────────────────────────────────────  // Convert USN to dummy email for Firebase Auth
  String _usnToEmail(String usn) {
    // Sanitize USN to be safe for email (lowercase, remove spaces)
    final sanitizedUsn = usn.trim().toLowerCase().replaceAll(' ', '');
    return '$sanitizedUsn@aikya.smvitm.edu';
  }

  // --- Auth Methods ---
  
  Future<void> signInWithUsnAndPassword(String usn, String password) async {
    try {
      final email = _usnToEmail(usn);
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUpWithUsn({
    required String name,
    required String phone,
    required String usn,
    required String password,
  }) async {
    try {
      final email = _usnToEmail(usn);
      
      // 1. Create the user in Firebase Auth
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final uid = userCredential.user?.uid;
      if (uid == null) throw Exception('Failed to create user account');

      // 2. Create the UserDoc in Firestore
      final userDoc = UserDoc(
        uid: uid,
        email: email, // We store the dummy email for reference, though USN is what matters
        usn: usn.trim().toUpperCase(),
        fullName: name.trim(),
        role: UserRole.student, // Default role
        createdAt: DateTime.now(),
        // Add phone if you extend UserDoc later, currently not in UserDoc schema
      );

      await firestore.collection('users').doc(uid).set(userDoc.toJson());
      
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signIn(String email, String password) {
    return auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    return auth.signOut();
  }

  Future<UserCredential> signUp(String email, String password, String usn, String fullName) async {
    // USN regex validation (e.g. 4MW21AI042)
    final usnRegex = RegExp(r'^4MW[0-9]{2}AI[0-9]{3}$');
    if (!usnRegex.hasMatch(usn)) {
      throw Exception('Invalid USN format. Expected format: 4MW21AI042');
    }

    // 1. Create auth user
    final cred = await auth.createUserWithEmailAndPassword(email: email, password: password);
    
    // 2. Create Firestore doc
    await firestore.collection('users').doc(cred.user!.uid).set({
      'email': email,
      'usn': usn,
      'fullName': fullName,
      'role': UserRole.student.name, // Default to student
      'skills': [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    return cred;
  }
}
