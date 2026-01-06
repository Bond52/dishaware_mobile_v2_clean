import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Accueil DishAware")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Bienvenue dans DishAware !",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),

            // 👉 Profil
            ElevatedButton(
              onPressed: () => context.go('/profile'),
              child: const Text("Créer / Modifier mon profil alimentaire"),
            ),

            const SizedBox(height: 16),

            // 👉 Accès FiltersScreen
            ElevatedButton.icon(
              icon: const Icon(Icons.restaurant_menu),
              label: const Text("Choisir mon dîner"),
              onPressed: () => context.go('/filters'),
            ),
          ],
        ),
      ),
    );
  }
}
