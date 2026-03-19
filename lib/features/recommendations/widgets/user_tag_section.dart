import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/api_client.dart';
import '../../../utils/tag_translations.dart';
import '../domain/recommended_dish.dart';
import '../models/dish_tag.dart';
import 'dish_tag_pill.dart';
import '../../../../theme/da_colors.dart';

/// Section "Mes tags pour ce plat" : pastilles colorées + ajout avec sentiment.
/// GET suggestions, GET/POST /api/dishes/:dishId/tags
class UserTagSection extends StatefulWidget {
  final RecommendedDish dish;

  const UserTagSection({super.key, required this.dish});

  @override
  State<UserTagSection> createState() => _UserTagSectionState();
}

class _UserTagSectionState extends State<UserTagSection> {
  final TextEditingController _tagController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<DishTag> _tags = [];
  List<String> _suggestions = [];
  bool _suggestionsLoading = false;
  bool _tagsLoading = true;
  Timer? _debounceTimer;
  bool _addSending = false;
  TagSentiment _pendingSentiment = TagSentiment.positive;

  static const Duration _debounceDuration = Duration(milliseconds: 300);

  /// Sentiments par libellé (GET API renvoie souvent des strings → positive par défaut).
  static const String _prefsSentimentPrefix = 'dish_user_tag_sentiment_v1_';

  String _tagKey(DishTag t) {
    if (t.type == DishTagType.system) {
      return '${t.type.name}:${t.label.toLowerCase()}';
    }
    return '${t.type.name}:${t.label.toLowerCase()}:${t.sentiment.name}';
  }

  Future<Map<String, String>> _loadSentimentStore(String dishId) async {
    if (dishId.isEmpty) return {};
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefsSentimentPrefix$dishId');
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map(
          (k, v) => MapEntry(k.toString().toLowerCase(), v.toString().toLowerCase()),
        );
      }
    } catch (_) {}
    return {};
  }

  Future<void> _saveSentimentStore(String dishId, Map<String, String> map) async {
    if (dishId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    if (map.isEmpty) {
      await prefs.remove('$_prefsSentimentPrefix$dishId');
    } else {
      await prefs.setString('$_prefsSentimentPrefix$dishId', jsonEncode(map));
    }
  }

  Future<void> _rememberTagSentiment(
    String dishId,
    String labelLower,
    TagSentiment sentiment,
  ) async {
    final map = await _loadSentimentStore(dishId);
    map[labelLower.toLowerCase()] = sentiment.name;
    await _saveSentimentStore(dishId, map);
  }

  Future<void> _forgetTagSentiment(String dishId, String labelLower) async {
    final map = await _loadSentimentStore(dishId);
    map.remove(labelLower.toLowerCase());
    await _saveSentimentStore(dishId, map);
  }

  TagSentiment? _sentimentFromName(String? name) {
    if (name == null || name.isEmpty) return null;
    for (final s in TagSentiment.values) {
      if (s.name == name) return s;
    }
    return null;
  }

  /// Réapplique le sentiment enregistré sur l’appareil (corrige le vert par défaut après navigation).
  Future<List<DishTag>> _applyStoredSentiments(
    String dishId,
    List<DishTag> tags,
  ) async {
    if (dishId.isEmpty) return tags;
    final store = await _loadSentimentStore(dishId);
    if (store.isEmpty) return tags;
    return tags.map((t) {
      if (t.type != DishTagType.user) return t;
      final stored = _sentimentFromName(store[t.label.toLowerCase()]);
      if (stored == null) return t;
      return DishTag(label: t.label, type: t.type, sentiment: stored);
    }).toList();
  }

  List<DishTag> _mergeTags(Iterable<DishTag> a, Iterable<DishTag> b) {
    final map = <String, DishTag>{};
    for (final t in a) {
      if (t.label.isNotEmpty) map[_tagKey(t)] = t;
    }
    for (final t in b) {
      if (t.label.isNotEmpty) map[_tagKey(t)] = t;
    }
    final list = map.values.toList()
      ..sort((x, y) => x.label.toLowerCase().compareTo(y.label.toLowerCase()));
    return list;
  }

  /// Retire un tag utilisateur (UI uniquement). Inclut sentiment pour distinguer les doublons de libellé.
  bool _sameTag(DishTag a, DishTag b) =>
      a.type == b.type &&
      a.label.toLowerCase() == b.label.toLowerCase() &&
      a.sentiment == b.sentiment;

  void _removeUserTag(DishTag tag) {
    if (tag.type != DishTagType.user) return;
    final dishId = widget.dish.dishId;
    final removed = DishTag(
      label: tag.label,
      type: tag.type,
      sentiment: tag.sentiment,
    );
    setState(() {
      _tags = _tags.where((t) => !_sameTag(t, removed)).toList();
    });
    unawaited(_forgetTagSentiment(dishId, removed.label));
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tag retiré'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            if (!mounted) return;
            unawaited(_rememberTagSentiment(dishId, removed.label.toLowerCase(), removed.sentiment));
            setState(() {
              _tags = _mergeTags(_tags, [removed]);
            });
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tagController.addListener(_onTagTextChanged);
    _loadTags();
  }

  Future<void> _loadTags() async {
    final dishId = widget.dish.dishId;
    if (dishId.isEmpty) {
      if (mounted) setState(() => _tagsLoading = false);
      return;
    }
    try {
      final response = await ApiClient.dio.get(
        '/dishes/$dishId/tags',
        options: await ApiClient.optionsWithUserId(),
      );
      if (!mounted) return;
      final data = response.data;
      List<dynamic> raw = [];
      if (data is List) {
        raw = data;
      } else if (data is Map && data['tags'] is List) {
        raw = data['tags'] as List<dynamic>;
      }
      final parsed = raw.map(DishTag.fromDynamic).where((t) => t.label.isNotEmpty).toList();
      final withSentiment = await _applyStoredSentiments(dishId, parsed);
      if (!mounted) return;
      setState(() {
        _tags = _mergeTags(_tags, withSentiment);
        _tagsLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _tagsLoading = false);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _tagController.removeListener(_onTagTextChanged);
    _tagController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTagTextChanged() {
    _debounceTimer?.cancel();
    final query = _tagController.text.trim();
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    _debounceTimer = Timer(_debounceDuration, () => _fetchSuggestions(query));
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) return;
    setState(() => _suggestionsLoading = true);
    try {
      final response = await ApiClient.dio.get(
        '/users/me/tag-suggestions',
        queryParameters: {'q': query},
        options: await ApiClient.optionsWithUserId(),
      );
      if (!mounted) return;
      final data = response.data;
      List<String> list = [];
      if (data is List) {
        list = data.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
      } else if (data is Map && data['suggestions'] is List) {
        list = (data['suggestions'] as List).map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
      }
      setState(() {
        _suggestions = list;
        _suggestionsLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _suggestionsLoading = false);
    }
  }

  Future<void> _addTag(String tag, TagSentiment sentiment) async {
    final normalized = tag.trim().toLowerCase();
    if (normalized.isEmpty) return;
    if (_tags.any((t) =>
        t.type == DishTagType.user &&
        t.label.toLowerCase() == normalized)) {
      return;
    }
    if (_addSending) return;
    final dishId = widget.dish.dishId;
    if (dishId.isEmpty) return;

    final optimistic = DishTag(
      label: normalized,
      type: DishTagType.user,
      sentiment: sentiment,
    );

    setState(() {
      _addSending = true;
      _tags = _mergeTags(_tags, [optimistic]);
      _tagController.clear();
      _suggestions = [];
    });

    try {
      await ApiClient.dio.post(
        '/dishes/$dishId/tags',
        data: {
          'tag': normalized,
          'type': 'user',
          'sentiment': sentiment.name,
        },
        options: await ApiClient.optionsWithUserId(),
      );
      if (!mounted) return;
      await _rememberTagSentiment(dishId, normalized, sentiment);
      if (!mounted) return;
      setState(() => _addSending = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _addSending = false;
        _tags = _tags
            .where((t) =>
                !(t.type == DishTagType.user &&
                    t.label.toLowerCase() == normalized))
            .toList();
      });
    }
  }

  void _submitTag() {
    final value = _tagController.text.trim();
    if (value.isNotEmpty) _addTag(value, _pendingSentiment);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mes tags pour ce plat :',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: DAColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '+ Ajouter un tag',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: DAColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sentiment du tag',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: DAColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _SentimentChoice(
                label: 'Positif',
                icon: Icons.thumb_up_outlined,
                selected: _pendingSentiment == TagSentiment.positive,
                selectedColor: const Color(0xFF16A34A),
                onTap: () => setState(() => _pendingSentiment = TagSentiment.positive),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SentimentChoice(
                label: 'Neutre',
                icon: Icons.remove_circle_outline,
                selected: _pendingSentiment == TagSentiment.neutral,
                selectedColor: const Color(0xFFF59E0B),
                onTap: () => setState(() => _pendingSentiment = TagSentiment.neutral),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SentimentChoice(
                label: 'Négatif',
                icon: Icons.thumb_down_outlined,
                selected: _pendingSentiment == TagSentiment.negative,
                selectedColor: const Color(0xFFDC2626),
                onTap: () => setState(() => _pendingSentiment = TagSentiment.negative),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: 'Ajouter un tag (ex: comfort, spicy...)',
                  filled: true,
                  fillColor: DAColors.inputBackground,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onSubmitted: (_) => _submitTag(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addSending ? null : _submitTag,
              icon: _addSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_rounded, size: 22),
              style: IconButton.styleFrom(
                backgroundColor: switch (_pendingSentiment) {
                  TagSentiment.positive => const Color(0xFF16A34A),
                  TagSentiment.neutral => const Color(0xFFF59E0B),
                  TagSentiment.negative => const Color(0xFFDC2626),
                },
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        if (_tagsLoading)
          const Padding(
            padding: EdgeInsets.only(top: 14),
            child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (_tags.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags
                .map(
                  (t) => DishTagPill(
                    tag: t,
                    onRemove: t.type == DishTagType.user
                        ? () => _removeUserTag(t)
                        : null,
                  ),
                )
                .toList(),
          ),
        ],
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Suggestions',
            style: TextStyle(fontSize: 12, color: DAColors.mutedForeground),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _suggestions
                .where((s) => !_tags.any(
                      (t) =>
                          t.type == DishTagType.user &&
                          t.label.toLowerCase() == s.toLowerCase(),
                    ))
                .map((s) => InkWell(
                      onTap: () => _addTag(s, _pendingSentiment),
                      borderRadius: BorderRadius.circular(16),
                      child: Chip(
                        label: Text(translateTag(s), style: const TextStyle(fontSize: 12)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ))
                .toList(),
          ),
        ],
        if (_suggestionsLoading)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          ),
      ],
    );
  }
}

class _SentimentChoice extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _SentimentChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? selectedColor.withOpacity(0.15) : DAColors.inputBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? selectedColor : DAColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: selected ? selectedColor : DAColors.mutedForeground),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? selectedColor : DAColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
