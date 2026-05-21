import 'package:talvori/features/impuls_postfach/models/impulse_ai_profile.dart';

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
    this.isMuted = false,
    this.mutedAt,
    this.isFavorite = false,
    this.favoritedAt,
    this.aiProfileOverride = ImpulseChatAiProfileOverride.empty,
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
  final bool isMuted;
  final DateTime? mutedAt;
  final bool isFavorite;
  final DateTime? favoritedAt;
  final ImpulseChatAiProfileOverride aiProfileOverride;

  bool get hasAiProfileOverride => aiProfileOverride.hasOverrides;

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
    bool? isMuted,
    DateTime? mutedAt,
    bool clearMutedAt = false,
    bool? isFavorite,
    DateTime? favoritedAt,
    bool clearFavoritedAt = false,
    ImpulseChatAiProfileOverride? aiProfileOverride,
    bool clearAiProfileOverride = false,
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
      isMuted: isMuted ?? this.isMuted,
      mutedAt: clearMutedAt ? null : mutedAt ?? this.mutedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      favoritedAt: clearFavoritedAt ? null : favoritedAt ?? this.favoritedAt,
      aiProfileOverride: clearAiProfileOverride
          ? ImpulseChatAiProfileOverride.empty
          : aiProfileOverride ?? this.aiProfileOverride,
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
      'isMuted': isMuted,
      'mutedAt': mutedAt?.toIso8601String(),
      'isFavorite': isFavorite,
      'favoritedAt': favoritedAt?.toIso8601String(),
      'aiProfileOverride': aiProfileOverride.hasOverrides
          ? aiProfileOverride.toJson()
          : null,
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
      isMuted: json['isMuted'] as bool? ?? false,
      mutedAt: DateTime.tryParse(json['mutedAt'] as String? ?? ''),
      isFavorite: json['isFavorite'] as bool? ?? false,
      favoritedAt: DateTime.tryParse(json['favoritedAt'] as String? ?? ''),
      aiProfileOverride: ImpulseChatAiProfileOverride.fromJson(
        json['aiProfileOverride'],
      ),
    );
  }
}
