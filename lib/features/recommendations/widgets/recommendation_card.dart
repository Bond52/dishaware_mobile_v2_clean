import 'package:flutter/material.dart';
import '../../../ui/components/da_card.dart';
import '../../../theme/da_colors.dart';
import '../../../utils/tag_translations.dart';
import '../domain/recommended_dish.dart';
import '../../recommendations/providers/user_dish_interactions_store.dart';

class RecommendationCard extends StatelessWidget {
  final RecommendedDish dish;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final bool isFavorite;
  final bool isFavoriteSending;
  final UserInteractionState interaction;
  final bool isFeedbackLocked;
  final bool isFeedbackSending;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final bool showExplanation;
  final bool showFeedbackActions;

  const RecommendationCard({
    super.key,
    required this.dish,
    required this.onTap,
    required this.onToggleFavorite,
    required this.isFavorite,
    required this.isFavoriteSending,
    required this.interaction,
    required this.isFeedbackLocked,
    required this.isFeedbackSending,
    required this.onLike,
    required this.onDislike,
    this.showExplanation = true,
    this.showFeedbackActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return DACard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: dish.imageUrl.isEmpty
                    ? Image.asset(
                        'assets/images/default_image.png',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        dish.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Image.asset(
                            'assets/images/default_image.png',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Material(
                  color: Colors.white.withOpacity(0.95),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: isFavoriteSending ? null : onToggleFavorite,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 160),
                        scale: isFavorite ? 1.1 : 1.0,
                        child: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                          color: isFavorite
                              ? const Color(0xFF4CAF50)
                              : DAColors.mutedForeground,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DAColors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: _buildDishTagsOverlay(dish),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DAColors.foreground,
                  ),
                ),
                if (showExplanation && dish.explanation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    dish.explanation.first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: DAColors.mutedForeground,
                    ),
                  ),
                ],
                if (showFeedbackActions) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              isFeedbackLocked || isFeedbackSending ? null : onLike,
                          icon: Icon(
                            Icons.thumb_up,
                            size: 18,
                            color: interaction == UserInteractionState.liked
                                ? Colors.green
                                : null,
                          ),
                          label: const Text('J\'aime'),
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.resolveWith<Color?>(
                              (states) => interaction ==
                                      UserInteractionState.liked
                                  ? Colors.green
                                  : DAColors.foreground,
                            ),
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color?>(
                              (states) => interaction ==
                                      UserInteractionState.liked
                                  ? const Color(0xFFE8F5E9)
                                  : null,
                            ),
                            side:
                                MaterialStateProperty.resolveWith<BorderSide?>(
                              (states) => BorderSide(
                                color: interaction ==
                                        UserInteractionState.liked
                                    ? Colors.green
                                    : DAColors.border,
                              ),
                            ),
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 10),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isFeedbackLocked || isFeedbackSending
                              ? null
                              : onDislike,
                          icon: Icon(
                            Icons.thumb_down,
                            size: 18,
                            color: interaction ==
                                    UserInteractionState.disliked
                                ? Colors.red
                                : null,
                          ),
                          label: const Text('Je n\'aime pas'),
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.resolveWith<Color?>(
                              (states) => interaction ==
                                      UserInteractionState.disliked
                                  ? Colors.red
                                  : DAColors.foreground,
                            ),
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color?>(
                              (states) => interaction ==
                                      UserInteractionState.disliked
                                  ? const Color(0xFFFFEBEE)
                                  : null,
                            ),
                            side:
                                MaterialStateProperty.resolveWith<BorderSide?>(
                              (states) => BorderSide(
                                color: interaction ==
                                        UserInteractionState.disliked
                                    ? Colors.red
                                    : DAColors.border,
                              ),
                            ),
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 10),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (dish.debug != null) ...[
                  const SizedBox(height: 8),
                  _buildDebugPanel(dish.debug!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Affiche les 3 premiers tags du plat (régimes + cuisines) sur la photo, traduits.
  Widget _buildDishTagsOverlay(RecommendedDish dish) {
    final tags = <String>[]
      ..addAll(dish.diets.where((s) => s.trim().isNotEmpty))
      ..addAll(dish.cuisines.where((s) => s.trim().isNotEmpty));
    final displayTags = tags.take(3).map((t) => translateTag(t)).toList();
    if (displayTags.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: displayTags
            .map((label) => Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: DAColors.foreground,
                  ),
                ))
            .toList(),
      ),
    );
  }

  /// Debug temporaire: affiche le détail de scoring quand `response.debug` est présent.
  Widget _buildDebugPanel(Map<String, dynamic> debug) {
    String read(List<String> path) {
      dynamic value = debug;
      for (final key in path) {
        if (value is Map<String, dynamic>) {
          value = value[key];
        } else {
          return '-';
        }
      }
      if (value == null) return '-';
      return value.toString();
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ExpansionTile(
        dense: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: const Text(
          '🔎 Score details',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        children: [
          _debugLine('Taste', read(['taste', 'contribution'])),
          _debugLine('Texture', read(['texture', 'contribution'])),
          _debugLine('Cooking', read(['cooking', 'contribution'])),
          _debugLine('Satiety', read(['satiety', 'contribution'])),
          _debugLine('Penalty', read(['penalties', 'total'])),
          const Divider(height: 16),
          _debugLine('Taste similarity', read(['taste', 'similarity'])),
          _debugLine('Texture similarity', read(['texture', 'similarity'])),
          _debugLine('Cooking similarity', read(['cooking', 'similarity'])),
          _debugLine('Satiety similarity', read(['satiety', 'similarity'])),
          const Divider(height: 16),
          _debugLine('Taste weight', read(['taste', 'weight'])),
          _debugLine('Texture weight', read(['texture', 'weight'])),
          _debugLine('Cooking weight', read(['cooking', 'weight'])),
          _debugLine('Satiety weight', read(['satiety', 'weight'])),
          _debugLine('Total score', read(['totalScore'])),
        ],
      ),
    );
  }

  Widget _debugLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 12, color: DAColors.mutedForeground),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
