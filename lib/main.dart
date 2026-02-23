import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'providers/filters_provider.dart';
import 'api/api_client.dart';
import 'router.dart';
import 'features/auth/models/user.dart';
import 'features/auth/providers/user_provider.dart';
import 'features/onboarding/providers/auth_provider.dart';
import 'features/onboarding/providers/onboarding_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/recommendations/providers/user_dish_interactions_store.dart';
import 'features/favorites/providers/favorites_store.dart';
import 'features/notifications/notification_initializer.dart';

// ✅ AJOUT : thème DishAware
import 'theme/da_theme.dart';

String? globalToken;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('[flutterNotification] Firebase init skipped: $e');
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final prefs = await SharedPreferences.getInstance();
  globalToken = prefs.getString("auth_token");

  if (globalToken != null) {
    ApiClient.setToken(globalToken!);
    final existingUserId = prefs.getString('currentUserId');
    if (existingUserId == null || existingUserId.isEmpty) {
      final user = await User.loadFromPrefs();
      if (user != null) {
        await prefs.setString('currentUserId', user.userId);
      } else {
        await prefs.setString('currentUserId', globalToken!);
      }
    }
  }

  final initialUser = await User.loadFromPrefs();

  await NotificationInitializer.run();

  runApp(DishAwareApp(initialUser: initialUser));
}

class DishAwareApp extends StatelessWidget {
  const DishAwareApp({super.key, this.initialUser});

  final User? initialUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'DishAware',

      routerConfig: appRouter,

      theme: DATheme.light(),
      darkTheme: DATheme.dark(),
      themeMode: ThemeMode.system,

      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => FiltersProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => AuthProvider(
                isAuthenticated: globalToken != null,
              ),
            ),
            ChangeNotifierProvider(
              create: (_) => UserProvider(initialUser: initialUser),
            ),
            ChangeNotifierProvider(
              create: (_) => OnboardingProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => ProfileProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => UserDishInteractionsStore(),
            ),
            ChangeNotifierProvider(
              create: (_) => FavoritesStore(),
            ),
          ],
          child: child!,
        );
      },
    );
  }
}
