import 'package:flutter/material.dart';

import '../theme/da_colors.dart';

class _DishItem {
  final String title;
  final int calories;
  final int compatibility;
  final String imagePath;
  final List<String> notes;
  final List<String> warningNotes;

  const _DishItem({
    required this.title,
    required this.calories,
    required this.compatibility,
    required this.imagePath,
    required this.notes,
    this.warningNotes = const [],
  });
}

class HostModeMenuScreen extends StatelessWidget {
  const HostModeMenuScreen({super.key});

  static const List<_DishItem> _dishes = [
    _DishItem(
      title: 'Bowl Méditerranéen au Quinoa',
      calories: 420,
      compatibility: 100,
      imagePath: 'assets/images/bowl.jpg',
      notes: [
        'Sans allergènes pour tous',
        'Végétarien (Marie & Sophie)',
        'Sans gluten naturellement (Sophie)',
        'Protéines équilibrées (Thomas)',
      ],
    ),
    _DishItem(
      title: 'Légumes Grillés, Sauce Tahini',
      calories: 280,
      compatibility: 100,
      imagePath: 'assets/images/bowl.jpg',
      notes: [
        'Convient à tous les régimes',
        'Sans lactose (Thomas)',
        'Végétarien (Marie & Sophie)',
      ],
    ),
    _DishItem(
      title: 'Poulet Rôti aux Herbes',
      calories: 380,
      compatibility: 67,
      imagePath: 'assets/images/salmon.jpg',
      notes: ['Sans allergènes', 'Riche en protéines (Thomas)'],
      warningNotes: ['Pas végétarien (compromis pour Marie & Sophie)'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mode Hôte',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              'Menu pour plusieurs invités',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMenuGeneratedCard(),
                  const SizedBox(height: 24),
                  ..._dishes.map((dish) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _DishCard(dish: dish),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildBottomActions(context),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: DAColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StepIndicator(
            number: 1,
            label: 'Invités',
            isActive: false,
            isCompleted: true,
          ),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: const Color(0xFF4CAF50),
            ),
          ),
          _StepIndicator(
            number: 2,
            label: 'Analyse',
            isActive: false,
            isCompleted: true,
          ),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: const Color(0xFF4CAF50),
            ),
          ),
          _StepIndicator(
            number: 3,
            label: 'Menu',
            isActive: true,
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGeneratedCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Menu généré',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: DAColors.foreground,
                  ),
                ),
                Text(
                  '3 plats compatibles avec votre groupe',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: DAColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4CAF50),
                side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Modifier le groupe'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Confirmer le menu'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int number;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepIndicator({
    required this.number,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive || isCompleted
                ? const Color(0xFF4CAF50)
                : const Color(0xFFE0E0E0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    number.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isActive || isCompleted
                          ? Colors.white
                          : const Color(0xFF9E9E9E),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive || isCompleted
                ? const Color(0xFF4CAF50)
                : const Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }
}

class _DishCard extends StatelessWidget {
  final _DishItem dish;

  const _DishCard({required this.dish});

  @override
  Widget build(BuildContext context) {
    final compatibilityColor = dish.compatibility == 100
        ? const Color(0xFF4CAF50)
        : const Color(0xFFFFC107);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DAColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  dish.imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DAColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${dish.calories} kcal',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: DAColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: compatibilityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: compatibilityColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${dish.compatibility}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: compatibilityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...dish.notes.map((note) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: DAColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          ...dish.warningNotes.map((note) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Color(0xFFFFC107),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: DAColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
