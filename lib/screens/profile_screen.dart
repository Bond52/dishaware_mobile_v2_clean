import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/profile_model.dart';
import '../services/profile_service.dart';
import 'orders_screen.dart';

// ✅ UI DishAware
import '../ui/components/da_card.dart';
import '../ui/components/da_button.dart';
import '../ui/components/da_badge.dart';
import '../ui/components/da_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ProfileModel> profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    profileFuture = ProfileService.getProfile();
  }

  Future<void> _goToEditProfile(BuildContext context) async {
    await context.push('/profile/setup');

    // 🔄 Rechargement du profil au retour
    setState(() {
      _loadProfile();
    });
  }

  void _goToOrders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OrdersScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        centerTitle: true,
        // ⛔️ PAS DE leading → pas de bug GoRouter
      ),
      body: FutureBuilder<ProfileModel>(
        future: profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Erreur : ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("Aucun profil trouvé"));
          }

          final profile = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===============================
                // 👤 AVATAR (TEST DAAvatar)
                // ===============================
                Center(
                  child: Column(
                    children: [
                      DAAvatar(
                        name: profile.name,
                        size: 72,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ===============================
                // 👤 INFOS PERSONNELLES
                // ===============================
                const Text(
                  'Informations personnelles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                DACard(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(profile.name),
                    subtitle: const Text('Adresse principale'),
                  ),
                ),

                const SizedBox(height: 24),

                // ===============================
                // 🔥 OBJECTIF NUTRITIONNEL
                // ===============================
                const Text(
                  'Objectif nutritionnel',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                DACard(
                  child: ListTile(
                    leading: const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                    ),
                    title: const Text('Calories max par repas'),
                    subtitle: Text('${profile.caloriesMax} kcal'),
                    trailing: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ===============================
                // 🧬 CONTRAINTES SANTÉ (TEST DABadge)
                // ===============================
                const Text(
                  'Contraintes de santé',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                const Text('Allergies'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.allergies
                      .map(
                        (a) => DABadge(
                          label: a,
                          variant: DABadgeVariant.destructive,
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 12),

                const Text('Ingrédients interdits'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.forbiddenIngredients
                      .map(
                        (i) => DABadge(
                          label: i,
                          variant: DABadgeVariant.outline,
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 24),

                // ===============================
                // 🍽️ PRÉFÉRENCES ALIMENTAIRES
                // ===============================
                const Text(
                  'Préférences alimentaires',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                const Text('Types de cuisine'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.cuisines
                      .map(
                        (c) => DABadge(
                          label: c,
                          variant: DABadgeVariant.secondary,
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 12),

                const Text('Types de plats'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.dishes
                      .map(
                        (d) => DABadge(
                          label: d,
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 32),

                // ===============================
                // 🛠️ ACTIONS (TEST DAButton)
                // ===============================
                DAButton(
                  label: 'Modifier mon profil',
                  fullWidth: true,
                  onPressed: () => _goToEditProfile(context),
                ),

                const SizedBox(height: 12),

                DAButton(
                  label: 'Mon historique',
                  variant: DAButtonVariant.outline,
                  fullWidth: true,
                  onPressed: () => _goToOrders(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
