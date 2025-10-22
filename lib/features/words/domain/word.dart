class Word {
  final String id, text, translation, fromLang, toLang;
  final String? deckId;
  final bool favorite;
  final DateTime createdAt;
  final DateTime? dueAt;
  final int srsStage;

  const Word({
    required this.id,
    required this.text,
    required this.translation,
    required this.fromLang,
    required this.toLang,
    this.deckId,
    this.favorite = false,
    required this.createdAt,
    this.dueAt,
    this.srsStage = 0,
  });

  Word copyWith({
    String? id, String? text, String? translation, String? fromLang, String? toLang,
    String? deckId, bool? favorite, DateTime? createdAt, DateTime? dueAt, int? srsStage,
  }) => Word(
    id: id ?? this.id, text: text ?? this.text, translation: translation ?? this.translation,
    fromLang: fromLang ?? this.fromLang, toLang: toLang ?? this.toLang,
    deckId: deckId ?? this.deckId, favorite: favorite ?? this.favorite,
    createdAt: createdAt ?? this.createdAt, dueAt: dueAt ?? this.dueAt,
    srsStage: srsStage ?? this.srsStage,
  );

  factory Word.fromJson(Map<String, dynamic> j) => Word(
    id: j['id'], text: j['text'], translation: j['translation'],
    fromLang: j['from_lang'], toLang: j['to_lang'],
    deckId: j['deck_id'], favorite: (j['favorite'] ?? false) as bool,
    createdAt: DateTime.parse(j['created_at']), 
    dueAt: j['due_at'] != null ? DateTime.parse(j['due_at']) : null,
    srsStage: (j['srs_stage'] ?? 0) as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'text': text, 'translation': translation,
    'from_lang': fromLang, 'to_lang': toLang,
    'deck_id': deckId, 'favorite': favorite,
    'created_at': createdAt.toIso8601String(),
    'due_at': dueAt?.toIso8601String(), 'srs_stage': srsStage,
  };
}