enum ImpulseMessageSource { ai, system, user }

enum ImpulseMessageStatus { sending, sent, failed }

enum ImpulseMessageContentType { text, audio }

class ImpulseMessage {
  const ImpulseMessage({
    required this.id,
    required this.chatId,
    required this.text,
    this.contentType = ImpulseMessageContentType.text,
    this.localAudioPath,
    this.audioDurationMs,
    this.waveformSeed,
    String? audioTranscript,
    String? transcriptionText,
    this.audioLanguage,
    this.usedWords = const [],
    required this.createdAt,
    this.readAt,
    this.source = ImpulseMessageSource.ai,
    this.status = ImpulseMessageStatus.sent,
    this.errorMessage,
    this.notificationId,
    this.slot,
    this.reaction,
    this.isStarred = false,
    this.isPinned = false,
    this.replyToMessageId,
    this.replyPreviewText,
    this.replyPreviewSource,
  }) : audioTranscript = audioTranscript ?? transcriptionText;

  final String id;
  final String chatId;
  final String text;
  final ImpulseMessageContentType contentType;
  final String? localAudioPath;
  final int? audioDurationMs;
  final int? waveformSeed;
  final String? audioTranscript;
  final String? audioLanguage;
  final List<String> usedWords;
  final DateTime createdAt;
  final DateTime? readAt;
  final ImpulseMessageSource source;
  final ImpulseMessageStatus status;
  final String? errorMessage;
  final int? notificationId;
  final String? slot;
  final String? reaction;
  final bool isStarred;
  final bool isPinned;
  final String? replyToMessageId;
  final String? replyPreviewText;
  final ImpulseMessageSource? replyPreviewSource;

  ImpulseMessage copyWith({
    String? id,
    String? chatId,
    String? text,
    ImpulseMessageContentType? contentType,
    String? localAudioPath,
    int? audioDurationMs,
    int? waveformSeed,
    String? audioTranscript,
    String? transcriptionText,
    String? audioLanguage,
    List<String>? usedWords,
    DateTime? createdAt,
    DateTime? readAt,
    ImpulseMessageSource? source,
    ImpulseMessageStatus? status,
    String? errorMessage,
    int? notificationId,
    String? slot,
    String? reaction,
    bool clearReaction = false,
    bool? isStarred,
    bool? isPinned,
    String? replyToMessageId,
    String? replyPreviewText,
    ImpulseMessageSource? replyPreviewSource,
    bool clearReply = false,
  }) {
    return ImpulseMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      text: text ?? this.text,
      contentType: contentType ?? this.contentType,
      localAudioPath: localAudioPath ?? this.localAudioPath,
      audioDurationMs: audioDurationMs ?? this.audioDurationMs,
      waveformSeed: waveformSeed ?? this.waveformSeed,
      audioTranscript:
          audioTranscript ?? transcriptionText ?? this.audioTranscript,
      audioLanguage: audioLanguage ?? this.audioLanguage,
      usedWords: usedWords ?? this.usedWords,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      source: source ?? this.source,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      notificationId: notificationId ?? this.notificationId,
      slot: slot ?? this.slot,
      reaction: clearReaction ? null : reaction ?? this.reaction,
      isStarred: isStarred ?? this.isStarred,
      isPinned: isPinned ?? this.isPinned,
      replyToMessageId: clearReply
          ? null
          : replyToMessageId ?? this.replyToMessageId,
      replyPreviewText: clearReply
          ? null
          : replyPreviewText ?? this.replyPreviewText,
      replyPreviewSource: clearReply
          ? null
          : replyPreviewSource ?? this.replyPreviewSource,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'text': text,
      'contentType': contentType.name,
      'messageType': contentType.name,
      'localAudioPath': localAudioPath,
      'audioPath': localAudioPath,
      'audioDurationMs': audioDurationMs,
      'waveformSeed': waveformSeed,
      'audioTranscript': audioTranscript,
      'transcriptionText': audioTranscript,
      'audioLanguage': audioLanguage,
      'usedWords': usedWords,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'source': source.name,
      'role': source.name == 'ai' ? 'assistant' : source.name,
      'status': status.name,
      'errorMessage': errorMessage,
      'notificationId': notificationId,
      'slot': slot,
      'reaction': reaction,
      'isStarred': isStarred,
      'isPinned': isPinned,
      'replyToMessageId': replyToMessageId,
      'replyPreviewText': replyPreviewText,
      'replyPreviewSource': replyPreviewSource?.name,
    };
  }

  factory ImpulseMessage.fromJson(Map<String, dynamic> json) {
    final rawWords = json['usedWords'];
    return ImpulseMessage(
      id: json['id'] as String? ?? '',
      chatId: json['chatId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      contentType: _contentTypeFromJson(json),
      localAudioPath:
          json['localAudioPath'] as String? ?? json['audioPath'] as String?,
      audioDurationMs: json['audioDurationMs'] as int?,
      waveformSeed: json['waveformSeed'] as int?,
      audioTranscript:
          json['audioTranscript'] as String? ??
          json['transcriptionText'] as String?,
      audioLanguage: json['audioLanguage'] as String?,
      usedWords: rawWords is List
          ? rawWords.whereType<String>().toList(growable: false)
          : const [],
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      readAt: DateTime.tryParse(json['readAt'] as String? ?? ''),
      source: _sourceFromJson(json),
      status: ImpulseMessageStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => ImpulseMessageStatus.sent,
      ),
      errorMessage: json['errorMessage'] as String?,
      notificationId: json['notificationId'] as int?,
      slot: json['slot'] as String?,
      reaction: json['reaction'] as String?,
      isStarred: json['isStarred'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      replyToMessageId: json['replyToMessageId'] as String?,
      replyPreviewText: json['replyPreviewText'] as String?,
      replyPreviewSource: _optionalSourceFromJson(json['replyPreviewSource']),
    );
  }

  static ImpulseMessageSource _sourceFromJson(Map<String, dynamic> json) {
    final source = json['source'];
    if (source is String && source.trim().isNotEmpty) {
      return ImpulseMessageSource.values.firstWhere(
        (value) => value.name == source,
        orElse: () => ImpulseMessageSource.ai,
      );
    }

    final role = json['role'];
    if (role is String) {
      return switch (role) {
        'user' => ImpulseMessageSource.user,
        'system' => ImpulseMessageSource.system,
        'assistant' || 'ai' => ImpulseMessageSource.ai,
        _ => ImpulseMessageSource.ai,
      };
    }

    return ImpulseMessageSource.ai;
  }

  static ImpulseMessageContentType _contentTypeFromJson(
    Map<String, dynamic> json,
  ) {
    final raw = json['contentType'] ?? json['messageType'];
    if (raw is String && raw.trim().isNotEmpty) {
      return ImpulseMessageContentType.values.firstWhere(
        (value) => value.name == raw,
        orElse: () => ImpulseMessageContentType.text,
      );
    }
    if (json['localAudioPath'] is String || json['audioPath'] is String) {
      return ImpulseMessageContentType.audio;
    }
    return ImpulseMessageContentType.text;
  }

  static ImpulseMessageSource? _optionalSourceFromJson(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return ImpulseMessageSource.values.firstWhere(
      (source) => source.name == value,
      orElse: () => ImpulseMessageSource.ai,
    );
  }
}
