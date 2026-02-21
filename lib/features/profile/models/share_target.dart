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
    final fullName = (json['fullName'] ?? '').toString();
    final composedName = fullName.isNotEmpty
        ? fullName
        : ('$firstName $lastName').trim();
    final name = (json['name'] ?? composedName).toString();
    final idRaw = json['id'] ?? json['_id'] ?? json['userId'];
    final id = idRaw == null
        ? ''
        : (idRaw is Map && idRaw['\$oid'] != null
            ? ((idRaw['\$oid'] as String?) ?? '')
            : idRaw.toString());
    return ShareTarget(
      id: id,
      name: name.isEmpty ? 'Sans nom' : name,
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
