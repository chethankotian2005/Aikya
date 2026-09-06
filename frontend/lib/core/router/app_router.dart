import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_view.dart';
import '../../features/auth/presentation/signup_view.dart';
import '../../features/auth/presentation/profile_setup_screen.dart';
import '../../features/auth/presentation/profile_edit_screen.dart';
import '../../services/firebase_service.dart';
import '../../screens/home_screen.dart';
import '../../screens/splash_screen.dart';
import '../../screens/events_hub_screen.dart';
import '../../screens/projects_screen.dart';
import '../../screens/alumni_directory_screen.dart';
import '../../screens/profile_screen.dart';
import 'router_guards.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
    _ref.listen(currentUserDocProvider, (_, __) => notifyListeners());
  }
}

final routerNotifierProvider = Provider((ref) => RouterNotifier(ref));

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);
  
  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final path = state.uri.toString();
      final isSplash = path == '/splash';
      final isLogin = path == '/login';
      final isSignup = path == '/signup';
      final isSetup = path == '/setup';
      
      // ── Phase 1: Auth still loading → stay on splash ──
      if (authState.isLoading) {
        return isSplash ? null : '/splash';
      }

      final isAuth = authState.valueOrNull != null;

      // ── Phase 2: Not authenticated → go to login ──
      if (!isAuth) {
        if (isLogin || isSignup) return null; // already there
        return '/login';
      }

      // ── Phase 3: Authenticated — check user doc ──
      final userDocAsync = ref.read(currentUserDocProvider);
      
      // User doc still loading → stay on splash (RouterNotifier will
      // call notifyListeners when it resolves, re-triggering redirect)
      if (userDocAsync.isLoading) {
        return isSplash ? null : '/splash';
      }

      if (userDocAsync.hasError) {
        print("Router caught error in userDocProvider: ${userDocAsync.error}");
      }
      
      final userDoc = userDocAsync.valueOrNull;

      // ── Phase 4: No Firestore doc yet (first-time signup) ──
      // Treat as profile-incomplete — send to setup
      print("ROUTER DEBUG: userDoc is ${userDoc != null ? 'NOT null' : 'NULL'}, profileComplete is ${userDoc?.profileComplete}");
      if (userDoc == null || !userDoc.profileComplete) {
        return isSetup ? null : '/setup';
      }

      // ── Phase 5: Profile complete — go to app ──
      // If they're on a pre-auth screen, redirect to home
      if (isLogin || isSplash || isSignup) return '/home';
      
      // If they're on setup but profile is done, go home
      if (isSetup) return '/home';

      // Otherwise, they're navigating to a valid app route — allow it
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupView(),
      ),
      GoRoute(
        path: '/setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/events',
        builder: (context, state) => const EventsHubScreen(),
      ),
      GoRoute(
        path: '/projects',
        builder: (context, state) => const ProjectsScreen(),
      ),
      GoRoute(
        path: '/alumni',
        builder: (context, state) => const AlumniDirectoryScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => const ProfileEditScreen(),
          ),
        ],
      ),
      // Add other routes here...
      
      // Admin shell
      ShellRoute(
        builder: (context, state, child) {
          // This would wrap admin routes with an Admin Layout (sidebar/appbar)
          return child;
        },
        routes: [
          GoRoute(
            path: '/admin',
            redirect: (context, state) => roleGuard(ref, ['hod', 'event_faculty', 'regular_faculty', 'assistant']),
            builder: (context, state) => const Scaffold(body: Center(child: Text('Admin Dashboard'))),
            routes: [
              GoRoute(
                path: 'accreditation',
                redirect: (context, state) => roleGuard(ref, ['hod']),
                builder: (context, state) => const Scaffold(body: Center(child: Text('Accreditation Compiler'))),
              ),
              GoRoute(
                path: 'events',
                redirect: (context, state) => roleGuard(ref, ['hod', 'event_faculty']),
                builder: (context, state) => const Scaffold(body: Center(child: Text('Event Builder'))),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
