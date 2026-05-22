import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/local_word_source.dart';

class WordSourceRepository {
  WordSourceRepository({required Database database, Uuid uuid = const Uuid()})
    : _database = database,
      _uuid = uuid;

  final Database _database;
  final Uuid _uuid;

  Future<LocalWordSource?> saveSource({
    required String wordId,
    required String sourceUrl,
    String? sourceTitle,
    String? sourceApp,
    String? sharedTextPreview,
    required DateTime createdAt,
  }) async {
    final normalizedUrl = _normalizeUrl(sourceUrl);
    if (!_isOpenableWebUrl(normalizedUrl)) return null;

    final existing = await _loadByWordAndUrl(wordId, normalizedUrl);
    if (existing != null) return existing;

    final id = _uuid.v4();
    await _database.insert('word_sources', {
      'id': id,
      'word_id': wordId,
      'source_url': normalizedUrl,
      'source_title': _trimOrNull(sourceTitle),
      'source_app': _trimOrNull(sourceApp),
      'shared_text_preview': _trimOrNull(sharedTextPreview),
      'created_at': createdAt.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    return _loadByWordAndUrl(wordId, normalizedUrl);
  }

  Future<List<LocalWordSource>> loadSourcesForWord(String wordId) async {
    final rows = await _database.query(
      'word_sources',
      where: 'word_id = ?',
      whereArgs: [wordId],
      orderBy: 'created_at DESC',
    );
    return rows.map(_mapSource).toList(growable: false);
  }

  Future<LocalWordSource?> loadLatestSource() async {
    final rows = await _database.query(
      'word_sources',
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _mapSource(rows.single);
  }

  Future<LocalWordSource?> _loadByWordAndUrl(
    String wordId,
    String sourceUrl,
  ) async {
    final rows = await _database.query(
      'word_sources',
      where: 'word_id = ? AND source_url = ?',
      whereArgs: [wordId, sourceUrl],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _mapSource(rows.single);
  }

  LocalWordSource _mapSource(Map<String, Object?> row) {
    return LocalWordSource(
      id: row['id']! as String,
      wordId: row['word_id']! as String,
      sourceUrl: row['source_url']! as String,
      sourceTitle: row['source_title'] as String?,
      sourceApp: row['source_app'] as String?,
      sharedTextPreview: row['shared_text_preview'] as String?,
      createdAt: DateTime.parse(row['created_at']! as String),
    );
  }

  String _normalizeUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('www.')) return 'https://$trimmed';
    return trimmed;
  }

  bool _isOpenableWebUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  String? _trimOrNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
