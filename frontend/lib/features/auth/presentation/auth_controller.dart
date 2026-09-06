import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firebase_service.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<void> {
  late FirebaseService _firebaseService;

  @override
  FutureOr<void> build() {
    _firebaseService = ref.watch(firebaseServiceProvider);
  }

  Future<void> loginWithUsn(String usn, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _firebaseService.signInWithUsnAndPassword(usn, password);
    });
  }

  Future<void> signUpWithUsn({
    required String name,
    required String phone,
    required String usn,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _firebaseService.signUpWithUsn(
        name: name,
        phone: phone,
        usn: usn,
        password: password,
      );
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _firebaseService.signOut();
    });
  }
}
