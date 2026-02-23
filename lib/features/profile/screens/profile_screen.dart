import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../notifications/notification_settings_widget.dart';
import '../providers/profile_provider.dart';
import 'profile_comparison_screen.dart';
import 'share_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    if (profileProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profile == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  profileProvider.error ?? 'Aucun profil trouvé',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF5A6A78)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => profileProvider.loadMyProfile(),
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Réessayez'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A57A),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final fullName =
        '${profile.firstName} ${profile.lastName}'.trim().isEmpty
            ? 'Utilisateur'
            : '${profile.firstName} ${profile.lastName}'.trim();
    final initials = _initials(fullName);
    final isComplete = profile.hasCompletedOnboarding;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Mon Profil',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0B1B2B),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _openGlobalEdit(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F9F2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Color(0xFF00A57A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Gérez vos préférences alimentaires',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5A6A78),
                ),
              ),
              const SizedBox(height: 16),
              _ProfileCard(
                initials: initials,
                fullName: fullName,
                isComplete: isComplete,
                onShare: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShareProfileScreen(),
                    ),
                  );
                },
                onCompare: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileComparisonScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _NotificationsSection(),
              const SizedBox(height: 16),
              const Text(
                'Contraintes de santé',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B1B2B),
                ),
              ),
              const SizedBox(height: 8),
              _ChipsCard(
                title: 'Allergies alimentaires',
                chips: profile.allergies,
                chipColor: const Color(0xFFFEE2E2),
                chipTextColor: const Color(0xFFEF4444),
                emptyLabel: 'Non renseigné',
                actionLabel: 'Ajouter une allergie',
                onAction: () => _editAllergies(context, profile.allergies),
                leadingIcon: Icons.warning_amber_rounded,
                leadingColor: const Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),
              const Text(
                'Préférences alimentaires',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B1B2B),
                ),
              ),
              const SizedBox(height: 8),
              _PreferenceListCard(
                items: profile.diets,
                emptyLabel: 'Non renseigné',
                actionLabel: 'Ajouter une préférence',
                onAction: () => _editDiets(context, profile.diets),
                iconResolver: _dietIcon,
              ),
              const SizedBox(height: 16),
              const Text(
                'Objectif calorique',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B1B2B),
                ),
              ),
              const SizedBox(height: 8),
              _CalorieGoalCard(
                calories: profile.dailyCalories,
                onEdit: () => _editCalories(context, profile.dailyCalories),
              ),
              const SizedBox(height: 16),
              _SectionHeader(
                icon: Icons.local_fire_department_outlined,
                title: 'Goûts dominants',
              ),
              const SizedBox(height: 8),
              _TasteCard(
                intensity: _valueOrEmpty(profile.tasteIntensity),
                profile: _valueOrEmpty(profile.tasteProfile),
                texture: _valueOrEmpty(profile.texturePreference),
                onEdit: () => _editTasteGroup(context, profile),
              ),
              const SizedBox(height: 16),
              _SectionHeader(
                icon: Icons.bolt,
                title: 'Satiété recherchée',
              ),
              const SizedBox(height: 8),
              _SingleValueCard(
                value: _valueOrEmpty(profile.satietyAfterMeal),
                onEdit: () =>
                    _editSatiety(context, profile.satietyAfterMeal),
              ),
              const SizedBox(height: 16),
              _SectionHeader(
                icon: Icons.location_on_outlined,
                title: 'Contexte de repas',
              ),
              const SizedBox(height: 8),
              _SingleValueCard(
                value: _valueOrEmpty(profile.diningContext),
                onEdit: () => _editDiningContext(context, profile.diningContext),
              ),
              const SizedBox(height: 16),
              _SectionHeader(
                icon: Icons.explore_outlined,
                title: 'Attitude face à la nouveauté',
              ),
              const SizedBox(height: 8),
              _SingleValueCard(
                value: _valueOrEmpty(profile.explorationAttitude),
                onEdit: () =>
                    _editExploration(context, profile.explorationAttitude),
              ),
              const SizedBox(height: 24),
              _TasteProfileSummaryCard(
                explanations: profile.profileExplanation,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editCalories(BuildContext context, int current) async {
    final controller = TextEditingController(
      text: current > 0 ? current.toString() : '',
    );
    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Objectif nutritionnel',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text('Calories par jour'),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '2000',
                  filled: true,
                  fillColor: const Color(0xFFF4F5F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final value = int.tryParse(controller.text.trim());
                    if (value != null) Navigator.pop(context, value);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009E73),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Enregistrer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );

    if (result != null) {
      await _updateProfile(context, {'dailyCalories': result});
    }
  }

  Future<void> _editTasteIntensity(BuildContext context, String current) async {
    final selection = await _showSingleChoiceSheet(
      context,
      title: 'Goûts dominants',
      subtitle: 'Intensité',
      options: const [
        _Option('Doux', 'Saveurs délicates', '🌸'),
        _Option('Bien relevés', 'Avec du caractère', '🌶️'),
        _Option('Très relevés', 'Épicé et intense', '🔥'),
      ],
      selected: current,
    );
    if (selection != null) {
      await _updateProfile(context, {'tasteIntensity': selection});
    }
  }

  Future<void> _editTasteProfile(BuildContext context, String current) async {
    final selection = await _showSingleChoiceSheet(
      context,
      title: 'Goûts dominants',
      subtitle: 'Profil',
      options: const [
        _Option('Frais / acide', 'Vivifiant et léger', '🍋'),
        _Option('Crémeux / riche', 'Onctueux et gourmand', '🧈'),
        _Option('Ça dépend', 'Selon l’humeur', '🎭'),
      ],
      selected: current,
    );
    if (selection != null) {
      await _updateProfile(context, {'tasteProfile': selection});
    }
  }

  Future<void> _editTexturePreference(
      BuildContext context, String current) async {
    final selection = await _showSingleChoiceSheet(
      context,
      title: 'Goûts dominants',
      subtitle: 'Texture préférée',
      options: const [
        _Option('Fondant', 'Qui fond en bouche', '🍫'),
        _Option('Croustillant', 'Croquant et texturé', '🥐'),
        _Option('Crémeux', 'Doux et onctueux', '🍮'),
        _Option('Léger', 'Aérien et subtil', '🪶'),
        _Option('Équilibré', 'Harmonieux', '⚖️'),
      ],
      selected: current,
    );
    if (selection != null) {
      await _updateProfile(context, {'texturePreference': selection});
    }
  }

  Future<void> _editSatiety(BuildContext context, String current) async {
    final selection = await _showSingleChoiceSheet(
      context,
      title: 'Satiété recherchée',
      subtitle: 'Après un bon repas',
      options: const [
        _Option('Léger', 'Juste ce qu’il faut', '🦋'),
        _Option('Bien rassasié', 'Pleinement satisfait', '😊'),
        _Option('Plein d’énergie', 'Revitalisé', '⚡'),
      ],
      selected: current,
    );
    if (selection != null) {
      await _updateProfile(context, {'satietyAfterMeal': selection});
    }
  }

  Future<void> _editDiningContext(BuildContext context, String current) async {
    final selection = await _showSingleChoiceSheet(
      context,
      title: 'Contexte de repas',
      subtitle: 'Vous mangez plutôt',
      options: const [
        _Option('Pressé', 'Rapide et efficace', '⏱️'),
        _Option('Détendu', 'Prendre son temps', '☕'),
        _Option('En déplacement', 'En mouvement', '🚶'),
        _Option('En groupe', 'Convivial', '👥'),
      ],
      selected: current,
    );
    if (selection != null) {
      await _updateProfile(context, {'diningContext': selection});
    }
  }

  Future<void> _editExploration(BuildContext context, String current) async {
    final selection = await _showSingleChoiceSheet(
      context,
      title: 'Attitude face à la nouveauté',
      subtitle: 'Nouveau restaurant',
      options: const [
        _Option('Prudent', 'Valeurs sûres', '🛡️'),
        _Option('Curieux', 'Ouvert à la découverte', '🔎'),
        _Option('Aventurier', 'Toujours prêt à tester', '🚀'),
      ],
      selected: current,
    );
    if (selection != null) {
      await _updateProfile(context, {'explorationAttitude': selection});
    }
  }

  Future<void> _editAllergies(BuildContext context, List<String> current) async {
    final selection = await _showMultiChoiceSheet(
      context,
      title: 'Allergies',
      options: const [
        'Arachides',
        'Fruits à coque',
        'Lait',
        'Œufs',
        'Poisson',
        'Soja',
        'Gluten',
        'Sésame',
        'Moutarde',
        'Sulfites',
      ],
      selected: current,
    );
    if (selection != null) {
      await _updateProfile(context, {'allergies': selection});
    }
  }

  Future<void> _editDiets(BuildContext context, List<String> current) async {
    final selection = await _showMultiChoiceSheet(
      context,
      title: 'Régimes',
      options: const [
        'Végétarien',
        'Végan',
        'Pescétarien',
        'Sans gluten',
        'Sans lactose',
        'Pauvre en glucides',
        'Keto',
        'Halal',
        'Casher',
      ],
      selected: current,
    );
    if (selection != null) {
      await _updateProfile(context, {'diets': selection});
    }
  }

  Future<void> _editTasteGroup(BuildContext context, profile) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Goûts dominants',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _ActionRow(
                label: 'Intensité',
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() =>
                      _editTasteIntensity(context, profile.tasteIntensity));
                },
              ),
              _ActionRow(
                label: 'Profil gustatif',
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(
                      () => _editTasteProfile(context, profile.tasteProfile));
                },
              ),
              _ActionRow(
                label: 'Texture préférée',
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() => _editTexturePreference(
                      context, profile.texturePreference));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openGlobalEdit(BuildContext context) async {
    final profile = context.read<ProfileProvider>().profile;
    final rootContext = context;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Modifier une section',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _ActionRow(
                label: 'Objectif nutritionnel',
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() => _editCalories(
                      rootContext, profile?.dailyCalories ?? 0));
                },
              ),
              _ActionRow(
                label: 'Goûts dominants',
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(
                      () => _editTasteGroup(rootContext, profile));
                },
              ),
              _ActionRow(
                label: 'Satiété recherchée',
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() => _editSatiety(
                      rootContext, profile?.satietyAfterMeal ?? ''));
                },
              ),
              _ActionRow(
                label: 'Contexte de repas',
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() => _editDiningContext(
                      rootContext, profile?.diningContext ?? ''));
                },
              ),
              _ActionRow(
                label: 'Attitude face à la nouveauté',
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() => _editExploration(
                      rootContext, profile?.explorationAttitude ?? ''));
                },
              ),
              _ActionRow(
                label: 'Contraintes alimentaires',
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() => _editAllergies(
                      rootContext, profile?.allergies ?? const []));
                },
              ),
              _ActionRow(
                label: 'Régimes',
                onTap: () {
                  Navigator.pop(context);
                  Future.microtask(() => _editDiets(
                      rootContext, profile?.diets ?? const []));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateProfile(
    BuildContext context,
    Map<String, dynamic> payload,
  ) async {
    final provider = context.read<ProfileProvider>();
    final updated = await provider.updateProfile(payload);
    if (updated == null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la mise à jour')),
      );
    }
  }

  Future<String?> _showSingleChoiceSheet(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<_Option> options,
    required String selected,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Color(0xFF5A6A78)),
              ),
              const SizedBox(height: 16),
              ...options.map(
                (option) => _SelectableCard(
                  title: option.title,
                  subtitle: option.subtitle,
                  emoji: option.emoji,
                  selected: selected == option.title,
                  onTap: () => Navigator.pop(context, option.title),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<String>?> _showMultiChoiceSheet(
    BuildContext context, {
    required String title,
    required List<String> options,
    required List<String> selected,
  }) {
    final current = selected.toSet();
    return showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final maxHeight = MediaQuery.of(context).size.height * 0.75;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (current.contains(option)) {
                                  current.remove(option);
                                } else {
                                  current.add(option);
                                }
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFE1E4E8)),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: current.contains(option),
                                    onChanged: (_) {
                                      setState(() {
                                        if (current.contains(option)) {
                                          current.remove(option);
                                        } else {
                                          current.add(option);
                                        }
                                      });
                                    },
                                    activeColor: const Color(0xFF00A57A),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0B1B2B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, current.toList()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF009E73),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Enregistrer',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _valueOrEmpty(String value) =>
      value.isEmpty ? 'Non renseigné' : value;

  IconData _dietIcon(String diet) {
    switch (diet.toLowerCase()) {
      case 'végétarien':
        return Icons.eco;
      case 'végan':
        return Icons.spa;
      case 'pescétarien':
        return Icons.set_meal;
      case 'sans gluten':
        return Icons.no_food;
      case 'sans lactose':
        return Icons.icecream;
      case 'pauvre en glucides':
        return Icons.rice_bowl;
      case 'keto':
        return Icons.local_fire_department;
      case 'halal':
        return Icons.nights_stay;
      case 'casher':
        return Icons.star;
      default:
        return Icons.restaurant;
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'DA';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _ProfileCard extends StatelessWidget {
  final String initials;
  final String fullName;
  final bool isComplete;
  final VoidCallback onShare;
  final VoidCallback onCompare;

  const _ProfileCard({
    required this.initials,
    required this.fullName,
    required this.isComplete,
    required this.onShare,
    required this.onCompare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E4E8)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFF00A57A),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            fullName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B1B2B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Membre depuis mars 2024',
            style: TextStyle(fontSize: 13, color: Color(0xFF5A6A78)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Partager mon profil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009E73),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: onCompare,
              icon: const Icon(Icons.people, size: 18),
              label: const Text('Comparer avec un autre profil'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0B1B2B),
                side: const BorderSide(color: Color(0xFFE1E4E8)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isComplete ? const Color(0xFFE8F9F2) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBEEAD9)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF00A57A), size: 16),
                const SizedBox(width: 6),
                Text(
                  isComplete ? 'Profil complet !' : 'Profil incomplet',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B1B2B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF00A57A)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0B1B2B),
          ),
        ),
      ],
    );
  }
}

class _PreferenceListCard extends StatelessWidget {
  final List<String> items;
  final String emptyLabel;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData Function(String) iconResolver;

  const _PreferenceListCard({
    required this.items,
    required this.emptyLabel,
    required this.actionLabel,
    required this.onAction,
    required this.iconResolver,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E4E8)),
      ),
      child: Column(
        children: [
          if (items.isEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                emptyLabel,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7A88)),
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F9F2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        iconResolver(item),
                        size: 18,
                        color: const Color(0xFF00A57A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0B1B2B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          GestureDetector(
            onTap: onAction,
            child: Text(
              '+ $actionLabel',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00A57A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsSection extends StatelessWidget {
  const _NotificationsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E4E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notifications intelligentes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B1B2B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Recevez des suggestions lorsque vous restez quelques minutes près d\'un restaurant compatible avec votre profil.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7A88),
            ),
          ),
          const SizedBox(height: 12),
          const NotificationSettingsWidget(),
        ],
      ),
    );
  }
}

class _CalorieGoalCard extends StatelessWidget {
  final int calories;
  final VoidCallback onEdit;

  const _CalorieGoalCard({
    required this.calories,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E4E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Objectif journalier',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0B1B2B),
                ),
              ),
              const Spacer(),
              Text(
                calories > 0 ? '${calories} kcal' : 'Non renseigné',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00A57A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Basé sur votre profil et vos objectifs de bien-être',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7A88)),
          ),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: onEdit,
              child: const Text(
                "Modifier l'objectif",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00A57A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TasteCard extends StatelessWidget {
  final String intensity;
  final String profile;
  final String texture;
  final VoidCallback onEdit;

  const _TasteCard({
    required this.intensity,
    required this.profile,
    required this.texture,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E4E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TasteRow(label: 'Intensité', value: intensity),
          const SizedBox(height: 8),
          _TasteRow(label: 'Profil', value: profile),
          const SizedBox(height: 8),
          _TasteRow(label: 'Texture préférée', value: texture),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: onEdit,
              child: const Text(
                'Modifier',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00A57A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TasteRow extends StatelessWidget {
  final String label;
  final String value;

  const _TasteRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final display = value.isEmpty ? 'Non renseigné' : value;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7A88)),
          ),
        ),
        Expanded(
          child: Text(
            display,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0B1B2B),
            ),
          ),
        ),
      ],
    );
  }
}

class _SingleValueCard extends StatelessWidget {
  final String value;
  final VoidCallback onEdit;

  const _SingleValueCard({required this.value, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final display = value.isEmpty ? 'Non renseigné' : value;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E4E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            display,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0B1B2B),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: GestureDetector(
              onTap: onEdit,
              child: const Text(
                'Modifier',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00A57A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipsCard extends StatelessWidget {
  final String title;
  final List<String> chips;
  final Color chipColor;
  final Color chipTextColor;
  final String emptyLabel;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData? leadingIcon;
  final Color? leadingColor;

  const _ChipsCard({
    required this.title,
    required this.chips,
    required this.chipColor,
    required this.chipTextColor,
    required this.emptyLabel,
    required this.actionLabel,
    required this.onAction,
    this.leadingIcon,
    this.leadingColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E4E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leadingIcon != null)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (leadingColor ?? const Color(0xFF00A57A))
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    leadingIcon,
                    size: 16,
                    color: leadingColor ?? const Color(0xFF00A57A),
                  ),
                ),
              if (leadingIcon != null) const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0B1B2B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (chips.isEmpty)
            Text(
              emptyLabel,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7A88)),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips
                  .map(
                    (chip) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: chipColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        chip,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: chipTextColor,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onAction,
            child: Text(
              '+ $actionLabel',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00A57A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _Option {
  final String title;
  final String subtitle;
  final String emoji;

  const _Option(this.title, this.subtitle, this.emoji);
}

class _SelectableCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8F9F2) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF00A57A) : const Color(0xFFE1E4E8),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE1E4E8)),
                color: selected ? const Color(0xFF00A57A) : Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B1B2B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7A88),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TasteProfileSummaryCard extends StatefulWidget {
  final List<String> explanations;

  const _TasteProfileSummaryCard({
    required this.explanations,
  });

  @override
  State<_TasteProfileSummaryCard> createState() =>
      _TasteProfileSummaryCardState();
}

class _TasteProfileSummaryCardState extends State<_TasteProfileSummaryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final items = widget.explanations;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6DFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE7FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.psychology_outlined,
                    size: 18,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comment DishAware te comprend',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3B2B6D),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Analyse basée sur ton profil gustatif',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B5BA6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF6B5BA6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text(
              'Analyse bientôt disponible.',
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: Color(0xFF4A3F78),
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '•',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.3,
                        color: Color(0xFF6B5BA6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: Color(0xFF4A3F78),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_expanded) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.auto_awesome, size: 14, color: Color(0xFF7C3AED)),
                  SizedBox(width: 6),
                  Text(
                    "Voir l’analyse complète",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
