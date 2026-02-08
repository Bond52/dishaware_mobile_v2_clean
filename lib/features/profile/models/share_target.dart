enum ShareTargetType { user, event }

class ShareTarget {
  final String id;
  final String name;
  final ShareTargetType type;
  final String subtitle;

  const ShareTarget({
    required this.id,
    required this.name,
    required this.type,
    required this.subtitle,
  });

  factory ShareTarget.fromJson(Map<String, dynamic> json) {
    final typeRaw = (json['type'] ?? json['targetType'] ?? json['kind'] ?? '')
        .toString();
    final type =
        typeRaw == 'event' ? ShareTargetType.event : ShareTargetType.user;
    final firstName = (json['firstName'] ?? '').toString();
    final lastName = (json['lastName'] ?? '').toString();
    final composedName = ('$firstName $lastName').trim();
    return ShareTarget(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? composedName).toString(),
      type: type,
      subtitle: (json['subtitle'] ??
              json['description'] ??
              (type == ShareTargetType.user
                  ? 'Utilisateur DishAware'
                  : 'Événement public'))
          .toString(),
    );
  }
}
