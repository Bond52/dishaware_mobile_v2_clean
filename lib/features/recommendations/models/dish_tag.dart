/// Tag associé à un plat (système DishAware ou utilisateur).
enum DishTagType {
  system,
  user,
}

/// Sentiment pour un tag utilisateur (ignoré pour les tags système).
enum TagSentiment {
  positive,
  neutral,
  negative,
}

class DishTag {
  final String label;
  final DishTagType type;
  final TagSentiment sentiment;

  const DishTag({
    required this.label,
    required this.type,
    this.sentiment = TagSentiment.positive,
  });

  /// Tags système : pas de sentiment métier (affichage bleu).
  bool get isSystem => type == DishTagType.system;

  static DishTagType _parseType(dynamic v) {
    final s = v?.toString().toLowerCase().trim();
    if (s == 'system') return DishTagType.system;
    return DishTagType.user;
  }

  static TagSentiment _parseSentiment(dynamic v) {
    if (v == null) return TagSentiment.positive;
    final s = v.toString().toLowerCase().trim();
    if (s.isEmpty) return TagSentiment.positive;
    switch (s) {
      case 'neutral':
      case 'neutre':
      case '0':
        return TagSentiment.neutral;
      case 'negative':
      case 'negatif':
      case 'négatif':
      case '-1':
        return TagSentiment.negative;
      case 'positive':
      case 'positif':
      case '1':
      default:
        return TagSentiment.positive;
    }
  }

  /// Sentiment depuis un objet JSON (plusieurs clés possibles selon le backend).
  static TagSentiment sentimentFromMap(Map<String, dynamic> m) {
    dynamic v = m['sentiment'] ??
        m['tone'] ??
        m['polarity'] ??
        m['sentimentLabel'] ??
        m['sentiment_label'];
    if (v == null && m['meta'] is Map) {
      final meta = Map<String, dynamic>.from(m['meta'] as Map);
      v = meta['sentiment'] ?? meta['tone'];
    }
    return _parseSentiment(v);
  }

  factory DishTag.fromDynamic(dynamic e) {
    if (e is String) {
      final t = e.trim();
      if (t.isEmpty) {
        return const DishTag(label: '', type: DishTagType.user, sentiment: TagSentiment.positive);
      }
      return DishTag(label: t, type: DishTagType.user, sentiment: TagSentiment.positive);
    }
    if (e is Map) {
      final m = Map<String, dynamic>.from(e);
      final label = (m['label'] ?? m['tag'] ?? m['name'] ?? '').toString().trim();
      final type = _parseType(m['type']);
      final sentiment = type == DishTagType.system
          ? TagSentiment.positive
          : sentimentFromMap(m);
      return DishTag(label: label, type: type, sentiment: sentiment);
    }
    final s = e.toString().trim();
    return DishTag(label: s, type: DishTagType.user, sentiment: TagSentiment.positive);
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'type': type.name,
        'sentiment': sentiment.name,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DishTag &&
          runtimeType == other.runtimeType &&
          label.toLowerCase() == other.label.toLowerCase() &&
          type == other.type;

  @override
  int get hashCode => Object.hash(label.toLowerCase(), type);
}
