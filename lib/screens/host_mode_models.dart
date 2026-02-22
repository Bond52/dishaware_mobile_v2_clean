/// Profil invité pour le Mode Hôte (affichage + id pour l'API).
class HostGuestProfile {
  final String userId;
  /// Id du document profil en base (MongoDB _id). Prioritaire pour POST /menu/consensus/group.
  final String? profileId;
  final String fullName;
  final String initials;
  final List<String> allergies;
  final List<String> diets;
  /// Cuisines préférées (pour intersection "préférences communes").
  final List<String> favoriteCuisines;

  const HostGuestProfile({
    required this.userId,
    this.profileId,
    required this.fullName,
    required this.initials,
    this.allergies = const [],
    this.diets = const [],
    this.favoriteCuisines = const [],
  });
}

/// État du groupe pour le flow Mode Hôte.
class HostGroupState {
  final List<HostGuestProfile> selectedProfiles;
  final bool isAnalyzing;
  final bool isGeneratingMenu;

  const HostGroupState({
    this.selectedProfiles = const [],
    this.isAnalyzing = false,
    this.isGeneratingMenu = false,
  });

  HostGroupState copyWith({
    List<HostGuestProfile>? selectedProfiles,
    bool? isAnalyzing,
    bool? isGeneratingMenu,
  }) {
    return HostGroupState(
      selectedProfiles: selectedProfiles ?? this.selectedProfiles,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isGeneratingMenu: isGeneratingMenu ?? this.isGeneratingMenu,
    );
  }
}

/// Plat retourné par POST /menu/consensus/group.
class GroupConsensusDish {
  final String id;
  final String name;
  final int calories;
  final String? imageUrl;
  final int compatibilityPercent;
  final List<GroupConsensusCriterion> criteria;

  const GroupConsensusDish({
    required this.id,
    required this.name,
    required this.calories,
    this.imageUrl,
    required this.compatibilityPercent,
    this.criteria = const [],
  });

  factory GroupConsensusDish.fromJson(Map<String, dynamic> json) {
    final criteriaList = json['criteria'] ?? json['reasons'] ?? json['notes'];
    List<GroupConsensusCriterion> list = [];
    if (criteriaList is List) {
      for (final e in criteriaList) {
        if (e is Map<String, dynamic>) {
          list.add(GroupConsensusCriterion.fromJson(e));
        } else if (e is String) {
          list.add(GroupConsensusCriterion(text: e, isWarning: false));
        }
      }
    }
    return GroupConsensusDish(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? json['label'] ?? '').toString(),
      calories: _parseInt(json['calories'] ?? json['caloriesCount'], 0),
      imageUrl: json['imageUrl'] ?? json['image'] ?? json['photo'],
      compatibilityPercent: _parseInt(
        json['compatibilityPercent'] ?? json['compatibility'] ?? json['compatibilityScore'],
        100,
      ),
      criteria: list,
    );
  }

  static int _parseInt(dynamic v, int def) {
    if (v == null) return def;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString()) ?? def;
  }
}

class GroupConsensusCriterion {
  final String text;
  final bool isWarning;

  const GroupConsensusCriterion({required this.text, this.isWarning = false});

  factory GroupConsensusCriterion.fromJson(Map<String, dynamic> json) {
    final text = (json['text'] ?? json['label'] ?? json['reason'] ?? '').toString();
    final isWarning = (json['isWarning'] ?? json['warning'] ?? json['type'] == 'warning') as bool? ?? false;
    return GroupConsensusCriterion(text: text, isWarning: isWarning);
  }
}

/// Réponse de POST /menu/consensus/group.
class GroupConsensusMenuResponse {
  final List<GroupConsensusDish> dishes;
  final int totalParticipants;

  const GroupConsensusMenuResponse({
    this.dishes = const [],
    this.totalParticipants = 0,
  });

  factory GroupConsensusMenuResponse.fromJson(Map<String, dynamic> json) {
    final list = json['dishes'] ?? json['items'] ?? json['plats'] ?? json['menu'];
    List<GroupConsensusDish> dishList = [];
    if (list is List) {
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          dishList.add(GroupConsensusDish.fromJson(e));
        }
      }
    }
    final total = json['totalParticipants'] ?? json['participantsCount'];
    int totalParticipants = 0;
    if (total != null) {
      if (total is int) totalParticipants = total;
      else if (total is double) totalParticipants = total.round();
      else totalParticipants = int.tryParse(total.toString()) ?? 0;
    }
    return GroupConsensusMenuResponse(
      dishes: dishList,
      totalParticipants: totalParticipants,
    );
  }
}

/// Réponse complète POST /menu/consensus/group : { menu, explanation, adjustments }.
class GroupMenuResult {
  final GroupMenuResultMenu menu;
  final String explanation;
  final List<String> adjustments;

  const GroupMenuResult({
    required this.menu,
    this.explanation = '',
    this.adjustments = const [],
  });

  /// Nombre de champs non vides dans menu (starter, main, alternative, dessert).
  int get totalPlats {
    int count = 0;
    if (menu.starter != null && menu.starter!.trim().isNotEmpty) count++;
    if (menu.main != null && menu.main!.trim().isNotEmpty) count++;
    if (menu.alternative != null && menu.alternative!.trim().isNotEmpty) count++;
    if (menu.dessert != null && menu.dessert!.trim().isNotEmpty) count++;
    return count;
  }

  factory GroupMenuResult.fromJson(Map<String, dynamic> json) {
    final menuMap = json['menu'];
    final menu = menuMap is Map<String, dynamic>
        ? GroupMenuResultMenu.fromJson(menuMap)
        : const GroupMenuResultMenu();
    final explanation = (json['explanation'] ?? json['explication'] ?? '').toString().trim();
    final rawAdj = json['adjustments'] ?? json['ajustements'];
    List<String> adjustments = [];
    if (rawAdj is List) {
      for (final e in rawAdj) {
        if (e != null && e.toString().trim().isNotEmpty) {
          adjustments.add(e.toString().trim());
        }
      }
    }
    return GroupMenuResult(
      menu: menu,
      explanation: explanation,
      adjustments: adjustments,
    );
  }
}

/// Objet menu dans la réponse groupe (starter, main, alternative?, dessert).
class GroupMenuResultMenu {
  final String? starter;
  final String? main;
  final String? alternative;
  final String? dessert;

  const GroupMenuResultMenu({
    this.starter,
    this.main,
    this.alternative,
    this.dessert,
  });

  factory GroupMenuResultMenu.fromJson(Map<String, dynamic> json) {
    String? str(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }
    return GroupMenuResultMenu(
      starter: str(json['starter'] ?? json['entree'] ?? json['entrée']),
      main: str(json['main'] ?? json['plat'] ?? json['platPrincipal']),
      alternative: str(json['alternative'] ?? json['alternatif']),
      dessert: str(json['dessert']),
    );
  }
}
