import 'package:flutter/material.dart';
import '../../../ui/components/da_card.dart';
import '../../../ui/components/da_badge.dart';
import '../../../theme/da_colors.dart';
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
                child: DABadge(
                  label: '${_formatScore(dish.score)}% compatible',
                  variant: DABadgeVariant.success,
                ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _formatScore(double score) {
    if (score <= 1) {
      return (score * 100).round();
    }
    return score.round();
  }
}
