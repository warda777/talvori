enum ImpulseChatSourceType {
  dailyImpulse,
  category,
  favorites,
  myWords,
  knownWords,
}

class ImpulseChat {
  const ImpulseChat({
    required this.id,
    required this.sourceType,
    this.sourceId,
    required this.title,
    this.avatarKey,
    this.enabled = true,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessageText,
    this.unreadCount = 0,
  });

  final String id;
  final ImpulseChatSourceType sourceType;
  final String? sourceId;
  final String title;
  final String? avatarKey;
  final bool enabled;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final String? lastMessageText;
  final int unreadCount;

  ImpulseChat copyWith({
    String? id,
    ImpulseChatSourceType? sourceType,
    String? sourceId,
    String? title,
    String? avatarKey,
    bool? enabled,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? lastMessageText,
    int? unreadCount,
  }) {
    return ImpulseChat(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      avatarKey: avatarKey ?? this.avatarKey,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceType': sourceType.name,
      'sourceId': sourceId,
      'title': title,
      'avatarKey': avatarKey,
      'enabled': enabled,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'lastMessageText': lastMessageText,
      'unreadCount': unreadCount,
    };
  }

  factory ImpulseChat.fromJson(Map<String, dynamic> json) {
    return ImpulseChat(
      id: json['id'] as String? ?? '',
      sourceType: ImpulseChatSourceType.values.firstWhere(
        (type) => type.name == json['sourceType'],
        orElse: () => ImpulseChatSourceType.dailyImpulse,
      ),
      sourceId: json['sourceId'] as String?,
      title: json['title'] as String? ?? 'Impuls',
      avatarKey: json['avatarKey'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      lastMessageAt: DateTime.tryParse(json['lastMessageAt'] as String? ?? ''),
      lastMessageText: json['lastMessageText'] as String?,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }
}
