import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/user_doc.dart';
import '../../features/auth/presentation/force_password_reset_screen.dart';
import '../../features/auth/presentation/login_view.dart';
import '../../features/auth/presentation/profile_edit_screen.dart';
import '../../features/auth/presentation/profile_setup_screen.dart';
import '../../features/auth/presentation/signup_view.dart';
import '../../screens/admin/admin_report_generator_view.dart';
import '../../screens/admin/admin_shell_screen.dart';
import '../../screens/admin/event_creation_screen.dart';
import '../../screens/alumni_directory_screen.dart';
import '../../screens/create_update_screen.dart';
import '../../screens/event_detail_screen.dart';
import '../../screens/events_hub_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/memory_wall_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/project_detail_screen.dart';
import '../../screens/project_submit_screen.dart';
import '../../screens/projects_screen.dart';
import '../../screens/public_profile_screen.dart';
import '../../screens/splash_screen.dart';
import '../../services/firebase_service.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(currentUserDocProvider, (_, __) => notifyListeners());
  }
}

final routerNotifierProvider = Provider((ref) => RouterNotifier(ref));

const _publicPaths = {'/login', '/signup'};
const _onboardingPaths = {'/splash', '/setup', '/force-password-reset'};

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/splash',
    redirect: (context, state) {
      final path = state.matchedLocation;
      final authState = ref.read(authStateProvider);

      if (authState.isLoading) return path == '/splash' ? null : '/splash';

      if (authState.valueOrNull == null) {
        return _publicPaths.contains(path) ? null : '/login';
      }

      final userDocAsync = ref.read(currentUserDocProvider);
      if (userDocAsync.isLoading) return path == '/splash' ? null : '/splash';

      final user = userDocAsync.valueOrNull;

      if (user != null && user.mustResetPassword) {
        return path == '/force-password-reset' ? null : '/force-password-reset';
      }

      // No profile doc yet (signup is still writing it) or first-run setup pending.
      if (user == null || !user.profileComplete) {
        return path == '/setup' ? null : '/setup';
      }

      if (_publicPaths.contains(path) || _onboardingPaths.contains(path)) return '/home';

      // Client-side role gates — Firestore rules and the backend enforce the same.
      final role = user.role;
      if (path.startsWith('/admin') && !role.canBuildEvents) return '/home';
      if (path == '/create_update' && !role.isStaff) return '/home';
      if (path == '/projects/new' && role != UserRole.student) return '/projects';

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginView()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupView()),
      GoRoute(path: '/setup', builder: (_, __) => const ProfileSetupScreen()),
      GoRoute(path: '/force-password-reset', builder: (_, __) => const ForcePasswordResetScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/events', builder: (_, __) => const EventsHubScreen()),
      GoRoute(
        path: '/events/:id',
        builder: (_, state) => EventDetailScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/projects', builder: (_, __) => const ProjectsScreen()),
      GoRoute(path: '/projects/new', builder: (_, __) => const ProjectSubmitScreen()),
      GoRoute(
        path: '/projects/detail/:id',
        builder: (_, state) => ProjectDetailScreen(projectId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/directory/profile/:uid',
        builder: (_, state) => PublicProfileScreen(uid: state.pathParameters['uid']!),
      ),
      GoRoute(path: '/alumni', builder: (_, __) => const AlumniDirectoryScreen()),
      GoRoute(path: '/memory', builder: (_, __) => const MemoryWallScreen()),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
        routes: [
          GoRoute(path: 'edit', builder: (_, __) => const ProfileEditScreen()),
        ],
      ),
      GoRoute(path: '/create_update', builder: (_, __) => const CreateUpdateScreen()),
      GoRoute(path: '/admin', builder: (_, __) => const AdminShellScreen()),
      GoRoute(path: '/admin/events/new', builder: (_, __) => const EventCreationScreen()),
      GoRoute(
        path: '/admin/events/edit/:id',
        builder: (_, state) => EventCreationScreen(eventId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/admin/report',
        builder: (_, state) => AdminReportGeneratorView(eventId: state.extra as String?),
      ),
    ],
  );
});
