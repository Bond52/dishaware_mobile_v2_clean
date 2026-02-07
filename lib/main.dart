import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'providers/filters_provider.dart';
import 'api/api_client.dart';
import 'router.dart';
import 'features/onboarding/providers/auth_provider.dart';
import 'features/onboarding/providers/onboarding_provider.dart';
import 'features/profile/providers/profile_provider.dart';

// ✅ AJOUT : thème DishAware
import 'theme/da_theme.dart';

String? globalToken;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  globalToken = prefs.getString("auth_token");

  if (globalToken != null) {
    ApiClient.setToken(globalToken!);
  }

  runApp(const DishAwareApp());
}

class DishAwareApp extends StatelessWidget {
  const DishAwareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'DishAware',

      // ✅ ROUTER INCHANGÉ
      routerConfig: appRouter,

      // ✅ THÈMES AJOUTÉS (AUCUN IMPACT SUR LE ROUTING)
      theme: DATheme.light(),
      darkTheme: DATheme.dark(),
      themeMode: ThemeMode.system,

      // ✅ PROVIDERS AU BON ENDROIT (INCHANGÉ)
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
              create: (_) => OnboardingProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => ProfileProvider(),
            ),
          ],
          child: child!,
        );
      },
    );
  }
}
