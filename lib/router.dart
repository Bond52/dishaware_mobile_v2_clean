import 'package:go_router/go_router.dart';

import 'main.dart';
import 'screens/login_screen.dart';
import 'screens/home_page.dart';
import 'screens/profile_screen.dart';
import 'screens/profile_setup_page.dart';
import 'screens/filters_screen.dart';
import 'screens/suggestions_screen.dart';


final GoRouter appRouter = GoRouter(
  initialLocation: '/login',

  redirect: (context, state) {
    final loggedIn = globalToken != null;
    final currentPath = state.uri.path;

    if (!loggedIn && currentPath != '/login') {
      return '/login';
    }

    if (loggedIn && currentPath == '/login') {
      return '/home';
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/filters',
      builder: (context, state) => const FiltersScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/profile/setup',
      builder: (context, state) => const ProfileSetupPage(),
    ),

    GoRoute(
  path: '/suggestions',
  builder: (context, state) => const SuggestionsScreen(),
),

  ],
);
