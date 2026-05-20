enum ImpulseMessageSource { ai, system, user }

class ImpulseMessage {
  const ImpulseMessage({
    required this.id,
    required this.chatId,
    required this.text,
    this.usedWords = const [],
    required this.createdAt,
    this.readAt,
    this.source = ImpulseMessageSource.ai,
    this.notificationId,
    this.slot,
  });

  final String id;
  final String chatId;
  final String text;
  final List<String> usedWords;
  final DateTime createdAt;
  final DateTime? readAt;
  final ImpulseMessageSource source;
  final int? notificationId;
  final String? slot;

  ImpulseMessage copyWith({
    String? id,
    String? chatId,
    String? text,
    List<String>? usedWords,
    DateTime? createdAt,
    DateTime? readAt,
    ImpulseMessageSource? source,
    int? notificationId,
    String? slot,
  }) {
    return ImpulseMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      text: text ?? this.text,
      usedWords: usedWords ?? this.usedWords,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      source: source ?? this.source,
      notificationId: notificationId ?? this.notificationId,
      slot: slot ?? this.slot,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'text': text,
      'usedWords': usedWords,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'source': source.name,
      'notificationId': notificationId,
      'slot': slot,
    };
  }

  factory ImpulseMessage.fromJson(Map<String, dynamic> json) {
    final rawWords = json['usedWords'];
    return ImpulseMessage(
      id: json['id'] as String? ?? '',
      chatId: json['chatId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      usedWords: rawWords is List
          ? rawWords.whereType<String>().toList(growable: false)
          : const [],
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      readAt: DateTime.tryParse(json['readAt'] as String? ?? ''),
      source: ImpulseMessageSource.values.firstWhere(
        (source) => source.name == json['source'],
        orElse: () => ImpulseMessageSource.ai,
      ),
      notificationId: json['notificationId'] as int?,
      slot: json['slot'] as String?,
    );
  }
}
