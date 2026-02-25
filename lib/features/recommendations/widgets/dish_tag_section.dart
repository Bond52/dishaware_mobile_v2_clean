import 'package:flutter/material.dart';

import '../../../api/api_client.dart';
import '../domain/recommended_dish.dart';
import '../../../../theme/da_colors.dart';

/// Section tags dynamiques : chips avec score (vert / rouge / gris) et actions 👍 / 👎.
/// POST /api/dishes/:dishId/tags pour renforcer ou diminuer un tag.
class DishTagSection extends StatefulWidget {
  final RecommendedDish dish;

  const DishTagSection({super.key, required this.dish});

  @override
  State<DishTagSection> createState() => _DishTagSectionState();
}

class _DishTagSectionState extends State<DishTagSection> {
  late Map<String, int> _scores;
  final Set<String> _sending = {};

  @override
  void initState() {
    super.initState();
    final tags = <String>{}
      ..addAll(widget.dish.cuisines.where((s) => s.trim().isNotEmpty))
      ..addAll(widget.dish.diets.where((s) => s.trim().isNotEmpty));
    _scores = {for (final t in tags) t: 0};
  }

  Future<void> _sendTagAction(String tag, String action) async {
    if (_sending.contains(tag)) return;
    final dishId = widget.dish.dishId;
    if (dishId.isEmpty) return;

    setState(() => _sending.add(tag));
    try {
      await ApiClient.dio.post(
        '/dishes/$dishId/tags',
        data: {'tag': tag, 'action': action},
        options: await ApiClient.optionsWithUserId(),
      );
      if (!mounted) return;
      setState(() {
        _sending.remove(tag);
        final delta = action == 'reinforce' ? 1 : -1;
        _scores[tag] = (_scores[tag] ?? 0) + delta;
      });
    } catch (_) {
      if (mounted) setState(() => _sending.remove(tag));
    }
  }

  Color _chipColor(int score) {
    if (score > 0) return const Color(0xFF4CAF50);
    if (score < 0) return const Color(0xFFE53935);
    return DAColors.muted;
  }

  @override
  Widget build(BuildContext context) {
    if (_scores.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DAColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _scores.entries.map((e) {
            final tag = e.key;
            final score = e.value;
            final sending = _sending.contains(tag);
            final color = _chipColor(score);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tag,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: sending ? null : () => _sendTagAction(tag, 'reinforce'),
                    icon: Icon(Icons.thumb_up, size: 18, color: sending ? DAColors.mutedForeground : const Color(0xFF4CAF50)),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: sending ? null : () => _sendTagAction(tag, 'diminish'),
                    icon: Icon(Icons.thumb_down, size: 18, color: sending ? DAColors.mutedForeground : const Color(0xFFE53935)),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
