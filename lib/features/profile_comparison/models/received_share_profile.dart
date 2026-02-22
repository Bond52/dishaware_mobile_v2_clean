class ReceivedShareProfile {
  final String userId;
  /// Id du document profil (MongoDB _id) si renvoyé par l'API.
  final String? profileId;
  final String firstName;
  final String initials;
  final List<String> allergies;
  final List<String> diets;
  final List<String> favoriteCuisines;

  const ReceivedShareProfile({
    required this.userId,
    this.profileId,
    required this.firstName,
    required this.initials,
    this.allergies = const [],
    this.diets = const [],
    this.favoriteCuisines = const [],
  });

  factory ReceivedShareProfile.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>?;
    final user = json['user'] as Map<String, dynamic>?;
    final firstName = (json['firstName'] ??
            json['ownerFirstName'] ??
            owner?['firstName'] ??
            user?['firstName'] ??
            '')
        .toString();
    final lastName = (json['lastName'] ??
            json['ownerLastName'] ??
            owner?['lastName'] ??
            user?['lastName'] ??
            '')
        .toString();
    final initials = (json['initials'] ??
            owner?['initials'] ??
            user?['initials'] ??
            '')
        .toString();
    final composedName = ('$firstName $lastName').trim();
    final userId = (json['userId'] ??
            json['ownerUserId'] ??
            owner?['userId'] ??
            owner?['_id'] ??
            json['id'] ??
            json['_id'] ??
            '')
        .toString();
    final profileId = (json['profileId'] ?? json['profile_id'] ?? owner?['profileId'] ?? user?['profileId'] ?? json['_id'])?.toString();
    return ReceivedShareProfile(
      userId: userId,
      profileId: profileId,
      firstName: composedName.isEmpty ? 'Utilisateur' : composedName,
      initials: initials.isEmpty ? _buildInitials(composedName) : initials,
      allergies: _stringList(json['allergies'] ?? owner?['allergies'] ?? user?['allergies']),
      diets: _stringList(json['diets'] ?? owner?['diets'] ?? user?['diets']),
      favoriteCuisines: _stringList(json['favoriteCuisines'] ?? json['favoriteCuisine'] ?? owner?['favoriteCuisines'] ?? user?['favoriteCuisines']),
    );
  }

  static List<String> _stringList(dynamic v) {
    if (v == null) return [];
    if (v is! List) return [];
    return v.map((e) => e.toString()).where((s) => s.trim().isNotEmpty).toList();
  }

  static String _buildInitials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
