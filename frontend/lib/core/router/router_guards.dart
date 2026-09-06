import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/firebase_service.dart';
import '../../features/auth/data/user_doc.dart';

/// Helper to guard routes based on the current user's role.
/// Returns null if access is allowed, or a redirect path if denied.
FutureOr<String?> roleGuard(ProviderRef ref, List<String> allowedRoles) async {
  // Read the role synchronously if possible, or await it
  final roleAsync = ref.read(userRoleProvider);
  
  if (roleAsync.isLoading) {
    // Optionally return a loading path, or null to let it resolve
    return null; 
  }
  
  final role = roleAsync.value;
  
  if (role == null) {
    // Not logged in or role not found -> deny
    return '/home'; 
  }
  
  if (!allowedRoles.contains(role.name) && !allowedRoles.contains(role.firestoreValue)) {
    // Access denied -> redirect to a safe fallback
    return '/home';
  }
  
  // Access allowed
  return null;
}
