import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers.dart';
import '../features/about/about_screen.dart';
import '../features/auth/auth_gate_screen.dart';
import '../features/downloads/downloads_screen.dart';
import '../features/home/home_screen.dart';
import '../features/library/saved_conversations_screen.dart';
import '../features/library/saved_drafts_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/sources/sources_library_screen.dart';
import '../features/startup/startup_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/startup',
    redirect: (context, state) {
      final user = ref.read(authRepositoryProvider).currentUser;
      final isAuth = state.matchedLocation == '/auth';
      final isStartup = state.matchedLocation == '/startup';

      if (user == null && !isAuth && !isStartup) {
        return '/auth';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/startup',
        builder: (context, state) => const StartupScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthGateScreen(),
      ),
      GoRoute(
        path: '/conversations',
        builder: (context, state) => const SavedConversationsScreen(),
      ),
      GoRoute(
        path: '/drafts',
        builder: (context, state) => const SavedDraftsScreen(),
      ),
      GoRoute(
        path: '/sources',
        builder: (context, state) => const SourcesLibraryScreen(),
      ),
      GoRoute(
        path: '/downloads',
        builder: (context, state) => const DownloadsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
});
