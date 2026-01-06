import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/profile_service.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController caloriesController =
      TextEditingController(text: '700');

  bool lactose = true;
  bool arachides = false;
  bool fruitsDeMer = false;

  bool isSaving = false;

  Future<void> saveProfile() async {
    setState(() => isSaving = true);

    final payload = {
      "caloriesMax": int.tryParse(caloriesController.text) ?? 700,
      "allergies": [
        if (lactose) "Lactose",
        if (arachides) "Arachides",
        if (fruitsDeMer) "Fruits de mer",
      ],
    };

    try {
      await ProfileService.updateProfile(payload);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour')),
      );

      // ✅ Navigation SAFE avec go_router
      context.go('/profile');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la sauvegarde')),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier mon profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Calories max par repas'),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(suffixText: 'kcal'),
            ),

            const SizedBox(height: 24),
            const Text('Allergies'),

            CheckboxListTile(
              title: const Text('Lactose'),
              value: lactose,
              onChanged: (v) => setState(() => lactose = v ?? false),
            ),
            CheckboxListTile(
              title: const Text('Arachides'),
              value: arachides,
              onChanged: (v) => setState(() => arachides = v ?? false),
            ),
            CheckboxListTile(
              title: const Text('Fruits de mer'),
              value: fruitsDeMer,
              onChanged: (v) => setState(() => fruitsDeMer = v ?? false),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveProfile,
                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
