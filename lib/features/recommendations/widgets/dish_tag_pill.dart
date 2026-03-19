import 'package:flutter/material.dart';

import '../../../utils/tag_translations.dart';
import '../models/dish_tag.dart';

/// Pastille (pill) pour un tag plat : système (bleu) ou utilisateur (vert / orange / rouge).
/// [onRemove] : si fourni et que le tag est utilisateur, affiche un « X » pour retirer le tag.
class DishTagPill extends StatelessWidget {
  final DishTag tag;
  final VoidCallback? onRemove;

  const DishTagPill({super.key, required this.tag, this.onRemove});

  static const Color _systemBlue = Color(0xFF2196F3);
  static const Color _positiveGreen = Color(0xFF16A34A);
  static const Color _neutralOrange = Color(0xFFF59E0B);
  static const Color _negativeRed = Color(0xFFDC2626);

  Color get _background {
    if (tag.isSystem) return _systemBlue;
    switch (tag.sentiment) {
      case TagSentiment.positive:
        return _positiveGreen;
      case TagSentiment.neutral:
        return _neutralOrange;
      case TagSentiment.negative:
        return _negativeRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tag.label.isEmpty) return const SizedBox.shrink();
    final showRemove = !tag.isSystem && onRemove != null;
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: showRemove ? 6 : 12,
        top: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _background.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              translateTag(tag.label),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showRemove) ...[
            const SizedBox(width: 4),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.close_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
