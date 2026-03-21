import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'features/auth/providers/user_provider.dart';
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
import 'screens/restaurant_detail_screen.dart';

// Shell (BottomNav)
import 'screens/main_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/boot',
  refreshListenable: RouterRefresh.instance,

  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final currentPath = state.uri.path;
    final profile = profileProvider.profile;
    final isBootRoute = currentPath == '/boot';
    final isOnboardingRoute =
        currentPath == '/welcome' ||
        currentPath == '/onboarding/welcome' ||
        currentPath == '/onboarding/auth' ||
        currentPath == '/onboarding/flow' ||
        currentPath == '/onboarding/confirmation';

    final isAuthenticated = authProvider.isAuthenticated;
    final lastKnownOnboardingComplete =
        profileProvider.lastKnownOnboardingComplete;
    final hasCompletedOnboarding = profile?.hasCompletedOnboarding == true;
    /// Session : flag mis à jour au login (AuthProvider) + persisté sur [User] (redémarrage).
    final sessionSaysOnboardingComplete = authProvider.hasCompletedOnboarding ||
        userProvider.currentUser?.hasCompletedOnboarding == true;

    /// Accès /home : profil OK **ou** session indique onboarding terminé (évite renvoi /welcome
    /// juste après login alors que [ProfileProvider] n’a pas encore rechargé).
    final canAccessHome = hasCompletedOnboarding ||
        (isAuthenticated && sessionSaysOnboardingComplete);

    // ⏳ Attendre le chargement du profil avant toute redirection
    if (profileProvider.isLoading) {
      if (kDebugMode) {
        debugPrint('Routing debug (loading → /boot): path=$currentPath');
      }
      return isBootRoute ? null : '/boot';
    }

    if (kDebugMode) {
      debugPrint('Routing debug:');
      debugPrint('  path: $currentPath');
      debugPrint('  isAuthenticated: $isAuthenticated');
      debugPrint('  profile: ${profile != null ? "loaded" : "null"}');
      if (profile != null) {
        debugPrint(
          '  hasCompletedOnboarding (from profile): $hasCompletedOnboarding',
        );
      } else {
        debugPrint(
          '  hasCompletedOnboarding: false (no profile object)',
        );
      }
      debugPrint(
        '  sessionSaysOnboardingComplete: $sessionSaysOnboardingComplete',
      );
      debugPrint(
        '  lastKnownOnboardingComplete: $lastKnownOnboardingComplete',
      );
      debugPrint('  canAccessHome: $canAccessHome');
    }

    // Éviter la boucle « connecté mais profil null » uniquement si la **session** dit déjà
    // onboarding terminé (sinon on casse l’inscription : token + profil pas encore créé).
    if (isAuthenticated &&
        profile == null &&
        sessionSaysOnboardingComplete &&
        currentPath == '/onboarding/flow') {
      return '/welcome';
    }

    if (canAccessHome) {
      if (currentPath == '/login' || isOnboardingRoute || isBootRoute) {
        return '/home';
      }
      return null;
    }

    // Accès refusé à /home : renvoi onboarding (nouveau compte) ou welcome (hors session).
    if (currentPath == '/home') {
      if (!isAuthenticated) {
        return '/welcome';
      }
      if (canAccessHome) {
        return null;
      }
      if (profile != null && !profile.hasCompletedOnboarding) {
        return '/onboarding/flow';
      }
      // Authentifié, pas d’accès home : profil null + session sans onboarding terminé → flow.
      return '/onboarding/flow';
    }

    if (!isOnboardingRoute) {
      if (!isAuthenticated) {
        return '/welcome';
      }
      if (canAccessHome) {
        return null;
      }
      if (profile != null && !profile.hasCompletedOnboarding) {
        return '/onboarding/flow';
      }
      return '/onboarding/flow';
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
    GoRoute(
      path: '/restaurant/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return RestaurantDetailScreen(restaurantId: id);
      },
    ),
  ],
);
