enum ImpulseChatSourceType {
  dailyImpulse,
  category,
  customAi,
  favorites,
  myWords,
  knownWords,
}

extension ImpulseChatSourceTypeWireName on ImpulseChatSourceType {
  String get wireName {
    return switch (this) {
      ImpulseChatSourceType.dailyImpulse => 'daily_impulse',
      ImpulseChatSourceType.category => 'category',
      ImpulseChatSourceType.customAi => 'custom_ai',
      ImpulseChatSourceType.favorites => 'favorites',
      ImpulseChatSourceType.myWords => 'my_words',
      ImpulseChatSourceType.knownWords => 'known_words',
    };
  }

  static ImpulseChatSourceType parse(Object? value) {
    final raw = value?.toString().trim();
    return switch (raw) {
      'daily_impulse' || 'dailyImpulse' => ImpulseChatSourceType.dailyImpulse,
      'category' => ImpulseChatSourceType.category,
      'custom_ai' || 'customAi' || 'custom' => ImpulseChatSourceType.customAi,
      'favorites' => ImpulseChatSourceType.favorites,
      'my_words' || 'myWords' => ImpulseChatSourceType.myWords,
      'known_words' || 'knownWords' => ImpulseChatSourceType.knownWords,
      _ => ImpulseChatSourceType.dailyImpulse,
    };
  }
}

class ImpulseChat {
  const ImpulseChat({
    required this.id,
    required this.sourceType,
    this.sourceId,
    required this.title,
    this.avatarKey,
    this.avatarImagePath,
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
  final String? avatarImagePath;
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
    String? avatarImagePath,
    bool clearAvatarImagePath = false,
    bool? enabled,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? lastMessageText,
    bool clearLastMessage = false,
    int? unreadCount,
  }) {
    return ImpulseChat(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      avatarKey: avatarKey ?? this.avatarKey,
      avatarImagePath: clearAvatarImagePath
          ? null
          : avatarImagePath ?? this.avatarImagePath,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: clearLastMessage
          ? null
          : lastMessageAt ?? this.lastMessageAt,
      lastMessageText: clearLastMessage
          ? null
          : lastMessageText ?? this.lastMessageText,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceType': sourceType.wireName,
      'sourceId': sourceId,
      'title': title,
      'avatarKey': avatarKey,
      'avatarImagePath': avatarImagePath,
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
      sourceType: ImpulseChatSourceTypeWireName.parse(json['sourceType']),
      sourceId: json['sourceId'] as String?,
      title: json['title'] as String? ?? 'Impuls',
      avatarKey: json['avatarKey'] as String?,
      avatarImagePath: json['avatarImagePath'] as String?,
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
