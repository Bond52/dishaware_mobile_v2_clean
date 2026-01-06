import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'providers/filters_provider.dart';
import 'api/api_client.dart';
import 'router.dart';

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
      routerConfig: appRouter,

      // ✅ PROVIDERS AU BON ENDROIT
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => FiltersProvider(),
            ),
          ],
          child: child!,
        );
      },
    );
  }
}
