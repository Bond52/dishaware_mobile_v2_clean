class ReceivedShareProfile {
  final String userId;
  final String firstName;
  final String initials;

  const ReceivedShareProfile({
    required this.userId,
    required this.firstName,
    required this.initials,
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
    return ReceivedShareProfile(
      userId: (json['userId'] ??
              json['ownerUserId'] ??
              owner?['userId'] ??
              owner?['_id'] ??
              json['id'] ??
              json['_id'] ??
              '')
          .toString(),
      firstName: composedName.isEmpty ? 'Utilisateur' : composedName,
      initials:
          initials.isEmpty ? _buildInitials(composedName) : initials,
    );
  }

  static String _buildInitials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
