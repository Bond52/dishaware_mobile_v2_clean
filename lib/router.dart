import 'package:go_router/go_router.dart';

import 'main.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/profile_setup_page.dart';
import 'screens/filters_screen.dart';
import 'screens/suggestions_screen.dart';

// Shell (BottomNav)
import 'screens/main_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',

  redirect: (context, state) {
    final loggedIn = globalToken != null;
    final currentPath = state.uri.path;

    // 🔐 Pas connecté → login
    if (!loggedIn && currentPath != '/login') {
      return '/login';
    }

    // ✅ Connecté → home (shell)
    if (loggedIn && currentPath == '/login') {
      return '/home';
    }

    return null;
  },

  routes: [
    // ===============================
    // 🔐 AUTH
    // ===============================
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // ===============================
    // 🧭 APP SHELL (Bottom Navigation)
    // ===============================
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainShell(),
    ),

    // ===============================
    // 🧑‍💻 PROFILE SETUP (hors tabs)
    // ===============================
    GoRoute(
      path: '/profile/setup',
      builder: (context, state) => const ProfileSetupPage(),
    ),

    // ===============================
    // 🔎 AUTRES ÉCRANS (hors tabs)
    // ===============================
    GoRoute(
      path: '/filters',
      builder: (context, state) => const FiltersScreen(),
    ),
    GoRoute(
      path: '/suggestions',
      builder: (context, state) => const SuggestionsScreen(),
    ),
  ],
);
