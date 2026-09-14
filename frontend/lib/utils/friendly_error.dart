import 'package:firebase_auth/firebase_auth.dart';

import '../services/event_registration_service.dart';
import '../services/render_api_service.dart';

/// Turns Firebase/API errors into a sentence a student can act on, instead
/// of raw strings like "[firebase_auth/invalid-credential] ...".
String friendlyError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-email':
        return 'Incorrect ID or password.';
      case 'email-already-in-use':
        return 'An account with this USN already exists. Please log in instead.';
      case 'weak-password':
        return 'Password is too weak — use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a minute and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      case 'requires-recent-login':
        return 'For security, please log out, log in again and retry.';
      case 'user-disabled':
        return 'This account has been disabled. Contact the HOD office.';
    }
    return error.message ?? 'Sign-in failed. Please try again.';
  }

  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return "You don't have permission to do that.";
      case 'unavailable':
        return 'Service unavailable. Check your connection and try again.';
      case 'failed-precondition':
        return 'This list is still being set up. Please try again in a few minutes.';
    }
    return error.message ?? 'Something went wrong. Please try again.';
  }

  if (error is ApiException) return error.message;
  if (error is RegistrationException) return error.message;

  final text = error.toString();
  return text.startsWith('Exception: ') ? text.substring('Exception: '.length) : text;
}
