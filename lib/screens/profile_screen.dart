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
import '../ui/components/da_label.dart';
import '../ui/components/da_input.dart';
import '../ui/components/da_checkbox.dart';
import '../ui/components/da_radio_group.dart';
import '../ui/components/da_select.dart';
import '../ui/components/da_switch.dart';
import '../ui/components/da_progress.dart';
import '../ui/components/da_skeleton.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ProfileModel> profileFuture;

  // ===============================
  // 🧪 ÉTAT LOCAL (TEST UNIQUEMENT)
  // ===============================
  bool testVegetarian = false;
  String testMealTime = 'Déjeuner';

  bool testNotifications = true;
  String testLanguage = 'Français';

  double testProgress = 0.65;
  bool testLoading = false;

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
                // 👤 AVATAR
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

                const SizedBox(height: 32),

                // ===============================
                // 🧪 TEST PROGRESS & SKELETON
                // ===============================
                const Text(
                  'Tests progress & skeleton (temporaire)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                DAProgress(
                  value: testProgress,
                  label: 'Complétion du profil',
                ),

                const SizedBox(height: 16),

                DASwitch(
                  label: 'Simuler chargement',
                  value: testLoading,
                  onChanged: (v) {
                    setState(() {
                      testLoading = v;
                    });
                  },
                ),

                const SizedBox(height: 16),

                if (testLoading) ...[
                  const DASkeleton(height: 20),
                  const SizedBox(height: 8),
                  const DASkeleton(height: 20, width: 220),
                  const SizedBox(height: 8),
                  const DASkeleton(height: 80),
                ],

                const SizedBox(height: 32),

                // ===============================
                // 🛠️ ACTIONS
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
