import 'dart:async';

import 'package:flutter/material.dart';

import '../../../api/api_client.dart';
import '../../../utils/tag_translations.dart';
import '../domain/recommended_dish.dart';
import '../../../../theme/da_colors.dart';

/// Section "Mes tags pour ce plat" : liste de chips + champ d'ajout avec autosuggestion.
/// GET /api/users/me/tag-suggestions?q=... (debounce), POST /api/dishes/:dishId/tags pour ajouter.
class UserTagSection extends StatefulWidget {
  final RecommendedDish dish;

  const UserTagSection({super.key, required this.dish});

  @override
  State<UserTagSection> createState() => _UserTagSectionState();
}

class _UserTagSectionState extends State<UserTagSection> {
  final TextEditingController _tagController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<String> _tags = [];
  List<String> _suggestions = [];
  bool _suggestionsLoading = false;
  bool _tagsLoading = true;
  Timer? _debounceTimer;
  bool _addSending = false;

  static const Duration _debounceDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _tagController.addListener(_onTagTextChanged);
    _loadTags();
  }

  /// Charge les tags déjà enregistrés pour ce plat (persistance).
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
      List<String> list = [];
      if (data is List) {
        list = data.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
      } else if (data is Map && data['tags'] is List) {
        list = (data['tags'] as List).map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
      }
      // Fusionner avec les tags déjà affichés pour ne pas écraser un ajout local (race condition).
      final merged = <String>{..._tags, ...list};
      final sorted = merged.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      setState(() {
        _tags = sorted;
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

  Future<void> _addTag(String tag) async {
    final normalized = tag.trim().toLowerCase();
    if (normalized.isEmpty) return;
    if (_tags.any((t) => t.toLowerCase() == normalized)) return;
    if (_addSending) return;
    final dishId = widget.dish.dishId;
    if (dishId.isEmpty) return;

    // Mise à jour optimiste : afficher le tag tout de suite.
    setState(() {
      _addSending = true;
      _tags = [..._tags, normalized]..sort((a, b) => a.compareTo(b));
      _tagController.clear();
      _suggestions = [];
    });
    try {
      await ApiClient.dio.post(
        '/dishes/$dishId/tags',
        data: {'tag': normalized},
        options: await ApiClient.optionsWithUserId(),
      );
      if (!mounted) return;
      setState(() => _addSending = false);
    } catch (_) {
      if (!mounted) return;
      // En cas d'erreur API, retirer le tag affiché.
      setState(() {
        _addSending = false;
        _tags = _tags.where((t) => t.toLowerCase() != normalized).toList();
      });
    }
  }

  void _submitTag() {
    final value = _tagController.text.trim();
    if (value.isNotEmpty) _addTag(value);
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
        if (_tagsLoading)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (_tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) => _buildTagChip(tag)).toList(),
          ),
        ],
        const SizedBox(height: 16),
        const Text(
          '+ Ajouter un tag',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: DAColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 8),
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
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.thumb_up, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Suggestions',
            style: TextStyle(fontSize: 12, color: DAColors.mutedForeground),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _suggestions
                .where((s) => !_tags.any((t) => t.toLowerCase() == s.toLowerCase()))
                .map((s) => InkWell(
                      onTap: () => _addTag(s),
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

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DAColors.muted.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DAColors.border),
      ),
      child: Text(
        translateTag(tag),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: DAColors.foreground),
      ),
    );
  }
}
