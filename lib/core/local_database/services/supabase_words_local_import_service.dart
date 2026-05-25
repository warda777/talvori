import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:sqflite_common/sqlite_api.dart';

const Set<String> supabaseLocalImportLevelLabels = {
  'A1',
  'A2',
  'B1',
  'B2',
  'C1',
  'C2',
};

class SupabaseWordsLocalImportService {
  const SupabaseWordsLocalImportService();

  static const int maxRemoteWords = 20000;
  static const String importFallbackCategoryId = 'local-category-remote-import';
  static const String importFallbackCategoryName = 'Importierte Wörter';

  Future<SupabaseWordsLocalImportReport> preview({
    required Database database,
    required SupabaseWordsLocalImportBundle bundle,
    required DateTime now,
  }) {
    return _run(executor: database, bundle: bundle, now: now, apply: false);
  }

  Future<SupabaseWordsLocalImportReport> apply({
    required Database database,
    required SupabaseWordsLocalImportBundle bundle,
    required DateTime now,
  }) {
    return database.transaction(
      (transaction) =>
          _run(executor: transaction, bundle: bundle, now: now, apply: true),
    );
  }

  Future<SupabaseWordsLocalImportReport> _run({
    required DatabaseExecutor executor,
    required SupabaseWordsLocalImportBundle bundle,
    required DateTime now,
    required bool apply,
  }) async {
    if (bundle.words.length > maxRemoteWords) {
      throw StateError(
        'Remote import aborted: ${bundle.words.length} words exceeds '
        '$maxRemoteWords.',
      );
    }

    final report = SupabaseWordsLocalImportReport(
      mode: apply
          ? SupabaseWordsLocalImportMode.apply
          : SupabaseWordsLocalImportMode.dryRun,
      remoteWordsRead: bundle.words.length,
      generatedAt: now,
    );

    final categoryById = {
      for (final category in bundle.categories) category.id: category,
    };
    final categoryIdsByWordId = <String, List<String>>{};
    for (final link in bundle.wordCategories) {
      categoryIdsByWordId
          .putIfAbsent(link.wordId, () => <String>[])
          .add(link.categoryId);
    }

    final localCategories = await _loadLocalCategories(executor);
    final localCategoryIdByNameKey = <String, String>{};
    final localCategoryIds = <String>{};
    for (final row in localCategories) {
      final id = row['id']?.toString();
      final name = row['name']?.toString();
      if (id == null || id.isEmpty) continue;
      localCategoryIds.add(id);
      localCategoryIdByNameKey[_categoryKey(name)] = id;
    }

    final localWords = await _loadLocalWords(executor);
    final localWordIds = <String>{};
    final wordsByExactKey = <String, Map<String, Object?>>{};
    final wordsByTermWithBlankLanguages = <String, Map<String, Object?>>{};
    for (final row in localWords) {
      final id = row['id']?.toString();
      if (id != null && id.isNotEmpty) localWordIds.add(id);

      final termKey = normalizeWordPart(row['term']?.toString());
      final source = normalizeLanguage(row['source_language']?.toString());
      final target = normalizeLanguage(row['target_language']?.toString());
      if (termKey.isEmpty) continue;

      final exactKey = _wordKey(
        term: termKey,
        sourceLanguage: source,
        targetLanguage: target,
      );
      wordsByExactKey.putIfAbsent(exactKey, () => row);
      if (source.isEmpty && target.isEmpty) {
        wordsByTermWithBlankLanguages.putIfAbsent(termKey, () => row);
      }
    }

    final membershipKeys = await _loadMembershipKeys(executor);
    final progressBefore = await _countRows(executor, 'word_progress');

    final plannedLocalCategoryIdsByRemoteCategoryId = <String, String>{};
    final plannedLocalCategoryIdsByNameKey = Map<String, String>.from(
      localCategoryIdByNameKey,
    );
    final plannedMembershipKeys = Set<String>.from(membershipKeys);
    final plannedWordIds = Set<String>.from(localWordIds);

    for (final word in bundle.words) {
      final term = word.text.trim();
      final translation = word.translation.trim();
      if (term.isEmpty) {
        report.warnings.add(
          'Remote word ${word.id} skipped because text is empty.',
        );
        continue;
      }

      final sourceLanguage = normalizeLanguage(word.fromLang);
      final targetLanguage = normalizeLanguage(word.toLang);
      final exactKey = _wordKey(
        term: normalizeWordPart(term),
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
      final linkedCategories =
          (categoryIdsByWordId[word.id] ?? const <String>[])
              .map((id) => categoryById[id])
              .whereType<SupabaseRemoteCategory>()
              .toList(growable: false);

      final thematicCategories = linkedCategories
          .where((category) => isThematicWordWorldName(category.name))
          .toList(growable: false);
      final skippedCategories = linkedCategories
          .where((category) => !isThematicWordWorldName(category.name))
          .toList(growable: false);
      for (final category in skippedCategories) {
        report.skippedCategoryNames.add(category.name);
      }

      final resolvedLevel = _resolveLevel(word, linkedCategories);
      final localWord =
          wordsByExactKey[exactKey] ??
          wordsByTermWithBlankLanguages[normalizeWordPart(term)];

      if (localWord == null) {
        final categoryId = thematicCategories.isNotEmpty
            ? await _ensureLocalCategory(
                executor: executor,
                remoteCategory: thematicCategories.first,
                now: now,
                apply: apply,
                report: report,
                localCategoryIdByNameKey: plannedLocalCategoryIdsByNameKey,
                localCategoryIdsByRemoteId:
                    plannedLocalCategoryIdsByRemoteCategoryId,
              )
            : await _ensureImportFallbackCategory(
                executor: executor,
                now: now,
                apply: apply,
                report: report,
                localCategoryIdByNameKey: plannedLocalCategoryIdsByNameKey,
              );
        final wordId = _localWordIdForRemoteWord(word.id, plannedWordIds);
        plannedWordIds.add(wordId);
        report.localWordsCreated++;

        if (apply) {
          await executor.insert('words', {
            'id': wordId,
            'category_id': categoryId,
            'term': term,
            'translation': translation,
            'translation_status': translation.isEmpty
                ? 'pending'
                : 'translated',
            'source_language': sourceLanguage.isEmpty ? null : sourceLanguage,
            'target_language': targetLanguage.isEmpty ? null : targetLanguage,
            'translation_error': null,
            'level': resolvedLevel,
            'example_sentence': word.exampleSentence,
            'notes': word.notes,
            'sort_order': 0,
            'is_archived': 0,
            'created_at': _encodeDateTime(now),
            'updated_at': _encodeDateTime(now),
          });
        }

        if (resolvedLevel != null) report.levelsSet++;
        for (final category in thematicCategories) {
          final membershipCategoryId = await _ensureLocalCategory(
            executor: executor,
            remoteCategory: category,
            now: now,
            apply: apply,
            report: report,
            localCategoryIdByNameKey: plannedLocalCategoryIdsByNameKey,
            localCategoryIdsByRemoteId:
                plannedLocalCategoryIdsByRemoteCategoryId,
          );
          await _ensureMembership(
            executor: executor,
            wordId: wordId,
            categoryId: membershipCategoryId,
            now: now,
            apply: apply,
            report: report,
            plannedMembershipKeys: plannedMembershipKeys,
          );
        }
        if (thematicCategories.isEmpty) {
          report.wordsWithoutThematicWordWorld++;
        }
        continue;
      }

      final localWordId = localWord['id']!.toString();
      report.localWordsReused++;

      final localTranslation = (localWord['translation']?.toString() ?? '')
          .trim();
      if (localTranslation.isNotEmpty &&
          translation.isNotEmpty &&
          normalizeTranslation(localTranslation) !=
              normalizeTranslation(translation)) {
        report.translationConflicts.add(
          SupabaseLocalImportConflict(
            remoteWordId: word.id,
            remoteText: term,
            remoteTranslation: translation,
            localWordId: localWordId,
            localTerm: localWord['term']?.toString() ?? '',
            localTranslation: localTranslation,
            issueType: 'translation_conflict',
            notes: 'Lokale Übersetzung wurde nicht überschrieben.',
          ),
        );
      }

      final updates = <String, Object?>{};
      if ((localWord['level']?.toString().trim() ?? '').isEmpty &&
          resolvedLevel != null) {
        updates['level'] = resolvedLevel;
      }
      if ((localWord['source_language']?.toString().trim() ?? '').isEmpty &&
          sourceLanguage.isNotEmpty) {
        updates['source_language'] = sourceLanguage;
      }
      if ((localWord['target_language']?.toString().trim() ?? '').isEmpty &&
          targetLanguage.isNotEmpty) {
        updates['target_language'] = targetLanguage;
      }
      if ((localWord['translation']?.toString().trim() ?? '').isEmpty &&
          translation.isNotEmpty) {
        updates['translation'] = translation;
        updates['translation_status'] = 'translated';
      }
      if (updates.isNotEmpty) {
        if (updates.containsKey('level')) report.levelsSet++;
        report.localWordsUpdated++;
        if (apply) {
          updates['updated_at'] = _encodeDateTime(now);
          await executor.update(
            'words',
            updates,
            where: 'id = ?',
            whereArgs: [localWordId],
          );
        }
      }

      if (thematicCategories.isEmpty) {
        report.wordsWithoutThematicWordWorld++;
      }
      for (final category in thematicCategories) {
        final categoryId = await _ensureLocalCategory(
          executor: executor,
          remoteCategory: category,
          now: now,
          apply: apply,
          report: report,
          localCategoryIdByNameKey: plannedLocalCategoryIdsByNameKey,
          localCategoryIdsByRemoteId: plannedLocalCategoryIdsByRemoteCategoryId,
        );
        await _ensureMembership(
          executor: executor,
          wordId: localWordId,
          categoryId: categoryId,
          now: now,
          apply: apply,
          report: report,
          plannedMembershipKeys: plannedMembershipKeys,
        );
      }
    }

    final progressAfter = await _countRows(executor, 'word_progress');
    report.wordProgressRowsBefore = progressBefore;
    report.wordProgressRowsAfter = progressAfter;
    if (progressBefore != progressAfter) {
      report.warnings.add(
        'word_progress row count changed from $progressBefore to '
        '$progressAfter. This should not happen.',
      );
    }

    return report;
  }

  Future<List<Map<String, Object?>>> _loadLocalCategories(
    DatabaseExecutor executor,
  ) {
    return executor.query('categories');
  }

  Future<List<Map<String, Object?>>> _loadLocalWords(
    DatabaseExecutor executor,
  ) {
    return executor.query('words');
  }

  Future<Set<String>> _loadMembershipKeys(DatabaseExecutor executor) async {
    final rows = await executor.query('word_world_memberships');
    return rows
        .map(
          (row) =>
              '${row['word_id']?.toString() ?? ''}|${row['category_id']?.toString() ?? ''}',
        )
        .where((key) => key != '|')
        .toSet();
  }

  Future<int> _countRows(DatabaseExecutor executor, String table) async {
    final rows = await executor.rawQuery(
      'SELECT COUNT(*) AS count FROM $table',
    );
    return rows.single['count'] as int? ?? 0;
  }

  Future<String> _ensureLocalCategory({
    required DatabaseExecutor executor,
    required SupabaseRemoteCategory remoteCategory,
    required DateTime now,
    required bool apply,
    required SupabaseWordsLocalImportReport report,
    required Map<String, String> localCategoryIdByNameKey,
    required Map<String, String> localCategoryIdsByRemoteId,
  }) async {
    final existingByRemote = localCategoryIdsByRemoteId[remoteCategory.id];
    if (existingByRemote != null) return existingByRemote;

    final nameKey = _categoryKey(remoteCategory.name);
    final existingByName = localCategoryIdByNameKey[nameKey];
    if (existingByName != null) {
      localCategoryIdsByRemoteId[remoteCategory.id] = existingByName;
      return existingByName;
    }

    final categoryId = 'word-world-$nameKey';
    localCategoryIdByNameKey[nameKey] = categoryId;
    localCategoryIdsByRemoteId[remoteCategory.id] = categoryId;
    report.localCategoriesCreated++;

    if (apply) {
      await executor.insert('categories', {
        'id': categoryId,
        'name': remoteCategory.name,
        'description': remoteCategory.description,
        'sort_order': _sortOrderForWordWorld(remoteCategory.name),
        'is_archived': 0,
        'created_at': _encodeDateTime(now),
        'updated_at': _encodeDateTime(now),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    return categoryId;
  }

  Future<String> _ensureImportFallbackCategory({
    required DatabaseExecutor executor,
    required DateTime now,
    required bool apply,
    required SupabaseWordsLocalImportReport report,
    required Map<String, String> localCategoryIdByNameKey,
  }) async {
    final nameKey = _categoryKey(importFallbackCategoryName);
    final existingByName = localCategoryIdByNameKey[nameKey];
    if (existingByName != null) return existingByName;
    localCategoryIdByNameKey[nameKey] = importFallbackCategoryId;
    report.localCategoriesCreated++;

    if (apply) {
      await executor.insert('categories', {
        'id': importFallbackCategoryId,
        'name': importFallbackCategoryName,
        'description': 'Lokal importierte Wörter ohne thematische Wortwelt.',
        'sort_order': 10000,
        'is_archived': 0,
        'created_at': _encodeDateTime(now),
        'updated_at': _encodeDateTime(now),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    return importFallbackCategoryId;
  }

  Future<void> _ensureMembership({
    required DatabaseExecutor executor,
    required String wordId,
    required String categoryId,
    required DateTime now,
    required bool apply,
    required SupabaseWordsLocalImportReport report,
    required Set<String> plannedMembershipKeys,
  }) async {
    final key = '$wordId|$categoryId';
    if (!plannedMembershipKeys.add(key)) return;
    report.membershipsCreated++;
    if (!apply) return;
    await executor.insert('word_world_memberships', {
      'word_id': wordId,
      'category_id': categoryId,
      'created_at': _encodeDateTime(now),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  String? _resolveLevel(
    SupabaseRemoteWord word,
    List<SupabaseRemoteCategory> linkedCategories,
  ) {
    final directLevel = normalizeLevel(word.level);
    if (directLevel != null) return directLevel;
    for (final category in linkedCategories) {
      final level = normalizeLevel(category.name);
      if (level != null) return level;
    }
    return null;
  }

  String _localWordIdForRemoteWord(String remoteId, Set<String> localWordIds) {
    if (!localWordIds.contains(remoteId)) return remoteId;
    return 'remote-$remoteId';
  }
}

class SupabaseWordsLocalImportBundle {
  const SupabaseWordsLocalImportBundle({
    required this.words,
    required this.categories,
    required this.wordCategories,
  });

  final List<SupabaseRemoteWord> words;
  final List<SupabaseRemoteCategory> categories;
  final List<SupabaseRemoteWordCategory> wordCategories;
}

class SupabaseRemoteWord {
  const SupabaseRemoteWord({
    required this.id,
    required this.text,
    required this.translation,
    required this.fromLang,
    required this.toLang,
    this.level,
    this.tags,
    this.domain,
    this.pos,
    this.exampleSentence,
    this.notes,
  });

  factory SupabaseRemoteWord.fromJson(Map<String, dynamic> json) {
    return SupabaseRemoteWord(
      id: json['id']?.toString() ?? '',
      text: (json['text'] ?? json['term'] ?? '').toString(),
      translation: json['translation']?.toString() ?? '',
      fromLang: json['from_lang']?.toString() ?? '',
      toLang: json['to_lang']?.toString() ?? '',
      level: json['level']?.toString(),
      tags: _encodeFlexibleValue(json['tags']),
      domain: json['domain']?.toString(),
      pos: json['pos']?.toString(),
      exampleSentence: (json['example_sentence'] ?? json['example'])
          ?.toString(),
      notes: (json['notes'] ?? json['note'])?.toString(),
    );
  }

  final String id;
  final String text;
  final String translation;
  final String fromLang;
  final String toLang;
  final String? level;
  final String? tags;
  final String? domain;
  final String? pos;
  final String? exampleSentence;
  final String? notes;
}

class SupabaseRemoteCategory {
  const SupabaseRemoteCategory({
    required this.id,
    required this.name,
    this.slug,
    this.type,
    this.groupSlug,
    this.groupName,
    this.description,
  });

  factory SupabaseRemoteCategory.fromJson(Map<String, dynamic> json) {
    return SupabaseRemoteCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      type: json['type']?.toString(),
      groupSlug: json['group_slug']?.toString(),
      groupName: json['group_name']?.toString(),
      description: json['description']?.toString(),
    );
  }

  final String id;
  final String name;
  final String? slug;
  final String? type;
  final String? groupSlug;
  final String? groupName;
  final String? description;
}

class SupabaseRemoteWordCategory {
  const SupabaseRemoteWordCategory({
    required this.wordId,
    required this.categoryId,
  });

  factory SupabaseRemoteWordCategory.fromJson(Map<String, dynamic> json) {
    return SupabaseRemoteWordCategory(
      wordId: json['word_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
    );
  }

  final String wordId;
  final String categoryId;
}

enum SupabaseWordsLocalImportMode { dryRun, apply }

class SupabaseWordsLocalImportReport {
  SupabaseWordsLocalImportReport({
    required this.mode,
    required this.remoteWordsRead,
    required this.generatedAt,
  });

  final SupabaseWordsLocalImportMode mode;
  final int remoteWordsRead;
  final DateTime generatedAt;
  int localWordsCreated = 0;
  int localWordsReused = 0;
  int localWordsUpdated = 0;
  int localCategoriesCreated = 0;
  int membershipsCreated = 0;
  int levelsSet = 0;
  int wordsWithoutThematicWordWorld = 0;
  int wordProgressRowsBefore = 0;
  int wordProgressRowsAfter = 0;
  final Set<String> skippedCategoryNames = <String>{};
  final List<SupabaseLocalImportConflict> translationConflicts =
      <SupabaseLocalImportConflict>[];
  final List<String> warnings = <String>[];

  bool get isDryRun => mode == SupabaseWordsLocalImportMode.dryRun;

  String toMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Local Supabase Word Import Report')
      ..writeln()
      ..writeln('- Modus: ${isDryRun ? 'Dry-Run / Preview' : 'Apply'}')
      ..writeln('- Erstellt: ${generatedAt.toIso8601String()}')
      ..writeln('- Remote-Wörter gelesen: $remoteWordsRead')
      ..writeln('- Lokal neu angelegt: $localWordsCreated')
      ..writeln('- Lokale Wörter wiederverwendet: $localWordsReused')
      ..writeln('- Lokale Wörter ergänzt: $localWordsUpdated')
      ..writeln('- Lokale Kategorien angelegt: $localCategoriesCreated')
      ..writeln('- Memberships angelegt: $membershipsCreated')
      ..writeln('- Level gesetzt: $levelsSet')
      ..writeln('- Wörter ohne echte Wortwelt: $wordsWithoutThematicWordWorld')
      ..writeln('- Übersetzungskonflikte: ${translationConflicts.length}')
      ..writeln(
        '- word_progress vor/nach Import: '
        '$wordProgressRowsBefore / $wordProgressRowsAfter',
      )
      ..writeln(
        '- SRS unverändert: ${wordProgressRowsBefore == wordProgressRowsAfter ? 'ja' : 'nein'}',
      )
      ..writeln();

    if (skippedCategoryNames.isNotEmpty) {
      buffer
        ..writeln('## Übersprungene Kategorien / Pakete / Level')
        ..writeln();
      for (final name in skippedCategoryNames.toList()..sort()) {
        buffer.writeln('- $name');
      }
      buffer.writeln();
    }

    if (translationConflicts.isNotEmpty) {
      buffer
        ..writeln('## Übersetzungskonflikte')
        ..writeln()
        ..writeln(
          'Lokale Übersetzungen wurden bei Konflikten nicht überschrieben.',
        )
        ..writeln();
      for (final conflict in translationConflicts.take(25)) {
        buffer.writeln(
          '- ${conflict.remoteText}: remote "${conflict.remoteTranslation}" '
          'vs. lokal "${conflict.localTranslation}" '
          '(${conflict.localWordId})',
        );
      }
      if (translationConflicts.length > 25) {
        buffer.writeln('- ... weitere Konflikte in der CSV.');
      }
      buffer.writeln();
    }

    if (warnings.isNotEmpty) {
      buffer
        ..writeln('## Warnungen')
        ..writeln();
      for (final warning in warnings) {
        buffer.writeln('- $warning');
      }
      buffer.writeln();
    }

    buffer
      ..writeln('## Sicherheitsnotiz')
      ..writeln()
      ..writeln(
        'Der Import liest Supabase nur lesend. Im Dry-Run werden keine '
        'lokalen Daten geschrieben. Im Apply-Modus werden nur lokale '
        'Wörter, Kategorien, Level und Wortwelt-Memberships ergänzt. '
        '`word_progress` und SRS-Felder bleiben unangetastet.',
      );

    return buffer.toString();
  }
}

class SupabaseLocalImportConflict {
  const SupabaseLocalImportConflict({
    required this.remoteWordId,
    required this.remoteText,
    required this.remoteTranslation,
    required this.localWordId,
    required this.localTerm,
    required this.localTranslation,
    required this.issueType,
    required this.notes,
  });

  final String remoteWordId;
  final String remoteText;
  final String remoteTranslation;
  final String localWordId;
  final String localTerm;
  final String localTranslation;
  final String issueType;
  final String notes;
}

bool isThematicWordWorldName(String? name) {
  final normalized = _categoryKey(name);
  if (normalized.isEmpty) return false;
  if (_excludedWordWorldNames.contains(normalized)) return false;
  return _thematicWordWorldOrder.contains(normalized);
}

String normalizeWordPart(String? value) {
  return (value ?? '').trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

String normalizeTranslation(String? value) {
  return normalizeWordPart(value);
}

String normalizeLanguage(String? value) {
  return (value ?? '').trim().toLowerCase();
}

String? normalizeLevel(String? value) {
  final candidate = (value ?? '').trim().toUpperCase();
  if (supabaseLocalImportLevelLabels.contains(candidate)) return candidate;
  return null;
}

String _wordKey({
  required String term,
  required String sourceLanguage,
  required String targetLanguage,
}) {
  return '$term|$sourceLanguage|$targetLanguage';
}

String _categoryKey(String? name) {
  return (name ?? '')
      .trim()
      .toLowerCase()
      .replaceAll('&', 'and')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

int _sortOrderForWordWorld(String name) {
  final key = _categoryKey(name);
  final index = _thematicWordWorldOrder.indexOf(key);
  if (index < 0) return 9000;
  return 100 + index;
}

String _encodeDateTime(DateTime value) => value.toIso8601String();

String? _encodeFlexibleValue(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  return jsonEncode(value);
}

const List<String> _thematicWordWorldOrder = [
  'health-and-fitness',
  'home-and-living',
  'food-and-cooking',
  'style-and-fashion',
  'money-and-shopping',
  'productivity',
  'personality',
  'feelings',
  'relationships',
  'thoughts',
  'law-and-politics',
  'environment',
  'school-and-studies',
  'science',
  'space',
  'nature',
  'animals',
  'tech-and-innovation',
  'media-and-news',
  'sports',
  'travel',
  'gaming',
  'transport',
  'music-and-entertainment',
  'art-and-literature',
  'work-and-careers',
];

const Set<String> _excludedWordWorldNames = {
  'a1',
  'a2',
  'b1',
  'b2',
  'c1',
  'c2',
  'top-500-words',
  'phrases-and-idioms',
  'irregular-verbs',
  'grammar-and-syntax',
  'basics',
  'exam-practice',
  'meine-worter',
  'meine-woerter',
  'favoriten',
};
