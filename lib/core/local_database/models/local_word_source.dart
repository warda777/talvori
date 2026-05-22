class LocalWordSource {
  const LocalWordSource({
    required this.id,
    required this.wordId,
    required this.sourceUrl,
    required this.createdAt,
    this.sourceTitle,
    this.sourceApp,
    this.sharedTextPreview,
  });

  final String id;
  final String wordId;
  final String sourceUrl;
  final DateTime createdAt;
  final String? sourceTitle;
  final String? sourceApp;
  final String? sharedTextPreview;
}
