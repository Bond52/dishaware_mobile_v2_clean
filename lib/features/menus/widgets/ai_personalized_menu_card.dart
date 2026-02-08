import 'package:flutter/material.dart';
import '../../../theme/da_colors.dart';
import '../data/ai_menu_service.dart';
import '../domain/ai_menu.dart';
import '../screens/menu_details_page.dart';

class AiPersonalizedMenuCard extends StatefulWidget {
  const AiPersonalizedMenuCard({super.key});

  @override
  State<AiPersonalizedMenuCard> createState() =>
      _AiPersonalizedMenuCardState();
}

class _AiPersonalizedMenuCardState extends State<AiPersonalizedMenuCard>
    with TickerProviderStateMixin {
  AiMenu? _menu;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isExpanded = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final menu = await AiMenuService.generateMenu();
      if (!mounted) return;
      setState(() {
        _menu = menu;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Erreur menu IA: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F1FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _buildExpandedContent(),
            secondChild: _buildCollapsedContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE9E6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Color(0xFF6A5FD3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Menu proposé pour vous aujourd’hui',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: DAColors.foreground,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Basé sur vos préférences et vos interactions récentes',
                  style: TextStyle(
                    fontSize: 12,
                    color: DAColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: DAColors.mutedForeground,
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedContent() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        'Entrée • Plat • Dessert personnalisés',
        style: const TextStyle(
          fontSize: 13,
          color: DAColors.mutedForeground,
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_hasError) {
      return const Padding(
        padding: EdgeInsets.only(top: 16),
        child: Text(
          'Menu personnalisé indisponible aujourd’hui',
          style: TextStyle(color: DAColors.mutedForeground),
        ),
      );
    }
    if (_menu == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          _MenuItemCard(item: _menu!.entree),
          const SizedBox(height: 12),
          _MenuItemCard(item: _menu!.plat),
          const SizedBox(height: 12),
          _MenuItemCard(item: _menu!.dessert),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MenuDetailsPage(menu: _menu!),
                      ),
                    );
                  },
                  icon: const Icon(Icons.remove_red_eye),
                  label: const Text('Voir le menu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A5FD3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _IconActionButton(
                icon: Icons.refresh,
                onTap: _loadMenu,
              ),
              const SizedBox(width: 8),
              _IconActionButton(
                icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite
                    ? const Color(0xFF4CAF50)
                    : DAColors.mutedForeground,
                onTap: () => setState(() => _isFavorite = !_isFavorite),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Total estimé : ${_menu!.totalCalories} kcal',
              style: const TextStyle(
                fontSize: 12,
                color: DAColors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final AiMenuItem? item;

  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item!.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7C6FE3),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item!.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: DAColors.foreground,
                  ),
                ),
                if (item!.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item!.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: DAColors.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '≈ ${item!.calories} kcal',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6A5FD3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _IconActionButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE6E3FF)),
        ),
        child: Icon(icon, color: color ?? DAColors.mutedForeground, size: 20),
      ),
    );
  }
}
