import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'features/onboarding/providers/auth_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'router_refresh.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/profile_setup_page.dart';
import 'screens/filters_screen.dart';
import 'screens/suggestions_screen.dart';
import 'features/onboarding/screens/welcome_screen.dart';
import 'features/onboarding/screens/auth_screen.dart';
import 'features/onboarding/screens/onboarding_flow.dart';
import 'features/onboarding/screens/profile_confirmation_screen.dart';

// Shell (BottomNav)
import 'screens/main_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/boot',
  refreshListenable: RouterRefresh.instance,

  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final currentPath = state.uri.path;
    final hasCompletedOnboarding =
        profileProvider.profile?.hasCompletedOnboarding ??
            authProvider.hasCompletedOnboarding;
    final isBootRoute = currentPath == '/boot';
    final isOnboardingRoute =
        currentPath == '/welcome' ||
        currentPath == '/onboarding/welcome' ||
        currentPath == '/onboarding/auth' ||
        currentPath == '/onboarding/flow' ||
        currentPath == '/onboarding/confirmation';

    print('ROUTER CHECK');
    print('isLoading: ${profileProvider.isLoading}');
    print(
        'hasCompletedOnboarding: ${profileProvider.profile?.hasCompletedOnboarding}');
    print('currentPath: $currentPath');

    // ⏳ Attendre le chargement du profil avant toute redirection
    if (profileProvider.isLoading) {
      return isBootRoute ? null : '/boot';
    }

    // ✅ Nouvelle règle d'entrée :
    // - Tant que l'onboarding n'est pas terminé, forcer /welcome.
    // - Une fois terminé, rediriger vers /home (et éviter /login et onboarding).
    if (!hasCompletedOnboarding && !isOnboardingRoute) {
      return '/welcome';
    }

    if (hasCompletedOnboarding &&
        (currentPath == '/login' || isOnboardingRoute || isBootRoute)) {
      return '/home';
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/boot',
      builder: (context, state) => const SizedBox.shrink(),
    ),
    // ===============================
    // 🔐 AUTH
    // ===============================
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/onboarding/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/onboarding/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/onboarding/flow',
      builder: (context, state) => const OnboardingFlow(),
    ),
    GoRoute(
      path: '/onboarding/confirmation',
      builder: (context, state) => const ProfileConfirmationScreen(),
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
