import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../../profile/services/profile_api_service.dart';
import '../../profile/providers/profile_provider.dart';
import '../../favorites/providers/favorites_store.dart';

class ProfileConfirmationScreen extends StatelessWidget {
  const ProfileConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = context.watch<OnboardingProvider>();
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final data = onboardingProvider.data;

    return Scaffold(
      backgroundColor: const Color(0xFFE9FAF4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00A57A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                  Positioned(
                    right: -6,
                    top: 14,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7C948),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 18,
                        color: Color(0xFF9A6B00),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Votre profil est prêt !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B1B2B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bienvenue ${data.firstName.isEmpty ? 'dans DishAware' : data.firstName}, votre expérience personnalisée vous attend',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Color(0xFF5A6A78),
                ),
              ),
              const SizedBox(height: 24),
              _InfoCard(
                icon: Icons.track_changes,
                iconColor: const Color(0xFF00A57A),
                iconBackground: const Color(0xFFDFF8EF),
                title: 'Objectif journalier',
                subtitle: '${data.dailyCalories} kcal / jour',
              ),
              const SizedBox(height: 14),
              _InfoCard(
                icon: Icons.public,
                iconColor: const Color(0xFF00A57A),
                iconBackground: const Color(0xFFDFF8EF),
                title: 'Cuisines favorites',
                subtitle:
                    '${data.cuisinePreferences.length} sélectionnée(s)',
              ),
              const SizedBox(height: 14),
              _InfoCard(
                icon: Icons.local_fire_department_outlined,
                iconColor: const Color(0xFF00A57A),
                iconBackground: const Color(0xFFDFF8EF),
                title: 'Profil gustatif',
                subtitle: 'Intensité & textures personnalisées',
              ),
              const SizedBox(height: 14),
              _InfoCard(
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFEF4444),
                iconBackground: const Color(0xFFFEE2E2),
                title: 'Allergies',
                subtitle:
                    '${data.allergies.length} allergie(s) enregistrée(s)',
                borderColor: data.allergies.isNotEmpty
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFFBEEAD9),
              ),
              const SizedBox(height: 14),
              _InfoCard(
                icon: Icons.auto_awesome,
                iconColor: const Color(0xFF00A57A),
                iconBackground: const Color(0xFFDFF8EF),
                title:
                    'Notre IA analyse vos préférences pour vous proposer des recommandations parfaitement adaptées à vos goûts et à vos besoins nutritionnels.',
                subtitle: null,
                isMessage: true,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final payload = {
                      'firstName': data.firstName,
                      'lastName': data.lastName,
                      'dailyCalories': data.dailyCalories,
                      'allergies': data.allergies,
                      'diets': data.dietaryPreferences,
                      'favoriteCuisines': data.cuisinePreferences,
                      'favoriteIngredients': data.favoriteIngredients,
                      'activityLevel': data.activityLevel,
                      'orderFrequency': data.orderFrequency,
                      'tasteIntensity': data.tasteIntensity,
                      'tasteProfile': data.tasteProfile,
                      'texturePreference': data.texturePreference,
                      'satietyAfterMeal': data.satietyAfterMeal,
                      'diningContext': data.diningContext,
                      'explorationAttitude': data.explorationAttitude,
                      'hasCompletedOnboarding': true,
                    };

                    try {
                      final profile =
                          await ProfileApiService.createProfile(payload);
                      profileProvider.setProfile(profile);
                      authProvider.completeOnboarding();
                      onboardingProvider.reset();
                      await context.read<FavoritesStore>().loadFavorites();
                      if (context.mounted) context.go('/home');
                    } catch (e, st) {
                      debugPrint('Erreur sauvegarde profil: $e');
                      debugPrint('$st');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e is Exception && e.toString().contains('UserId')
                                  ? 'Session invalide. Veuillez vous reconnecter.'
                                  : 'Erreur lors de la sauvegarde du profil. Réessayez.',
                            ),
                            backgroundColor: const Color(0xFFEF4444),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009E73),
                    elevation: 8,
                    shadowColor: const Color(0x33009E73),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Découvrir mes recommandations',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String? subtitle;
  final bool isMessage;
  final Color? borderColor;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    this.subtitle,
    this.isMessage = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? const Color(0xFFBEEAD9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B1B2B),
                  ),
                ),
                if (!isMessage && subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5A6A78),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
