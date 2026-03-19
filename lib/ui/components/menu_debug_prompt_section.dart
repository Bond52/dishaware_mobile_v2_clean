import 'package:flutter/material.dart';

/// Clés API possibles pour le prompt de debug (génération de menu).
const List<String> kMenuDebugPromptKeys = [
  'debugPrompt',
  'debug_prompt',
  'aiPrompt',
  'ai_prompt',
  'promptDebug',
  'prompt_debug',
  'generationPrompt',
  'generation_prompt',
  'prompt',
  'fullPrompt',
  'full_prompt',
  'inputPrompt',
  'input_prompt',
  'llmPrompt',
  'llm_prompt',
  'openaiPrompt',
  'openai_prompt',
  'systemPrompt',
  'system_prompt',
  'userPrompt',
  'user_prompt',
];

/// Maps souvent utilisées par les API pour ranger le prompt hors du corps « menu ».
const List<String> kMenuDebugPromptContainerKeys = [
  'debug',
  'metadata',
  'meta',
  '_debug',
  'generation',
  'generationMeta',
  'ai',
  'llm',
];

String? _trimmedString(dynamic v) {
  if (v == null) return null;
  if (v is String) {
    final s = v.trim();
    return s.isEmpty ? null : s;
  }
  return null;
}

/// Extrait le texte de prompt depuis une map JSON (racine ou imbriquée).
String? parseMenuDebugPrompt(Map<String, dynamic>? map, [int depth = 0]) {
  if (map == null || depth > 6) return null;

  // Combinaison fréquente côté backends (system + user).
  final system = _trimmedString(map['systemPrompt'] ?? map['system_prompt']);
  final user = _trimmedString(map['userPrompt'] ?? map['user_prompt']);
  if (system != null && user != null) {
    return '$system\n\n$user';
  }
  if (system != null) return system;
  if (user != null) return user;

  for (final k in kMenuDebugPromptKeys) {
    final v = map[k];
    if (v == null) continue;
    if (v is Map) {
      final nested = parseMenuDebugPrompt(Map<String, dynamic>.from(v), depth + 1);
      if (nested != null) return nested;
      continue;
    }
    final s = _trimmedString(v);
    if (s != null) return s;
  }

  for (final ck in kMenuDebugPromptContainerKeys) {
    final sub = map[ck];
    if (sub is Map) {
      final nested = parseMenuDebugPrompt(Map<String, dynamic>.from(sub), depth + 1);
      if (nested != null) return nested;
    }
  }

  return null;
}

/// Section repliable (debug) : prompt IA utilisé pour générer le menu.
class MenuDebugPromptSection extends StatelessWidget {
  final String? debugPrompt;

  const MenuDebugPromptSection({super.key, this.debugPrompt});

  @override
  Widget build(BuildContext context) {
    final text = debugPrompt?.trim();
    if (text == null || text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: const Color(0xFFF3EDFA),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: false,
              tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              iconColor: const Color(0xFF6B5BA6),
              collapsedIconColor: const Color(0xFF6B5BA6),
              title: const Text(
                'How DishAware generated this menu',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B2B6D),
                ),
              ),
              children: [
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.38,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E0F0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD4C4E8)),
                  ),
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      child: SelectableText(
                        text,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          height: 1.45,
                          color: Color(0xFF2D2640),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
