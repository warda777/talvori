import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_words_local_import_service.dart';

abstract class SupabaseWordsRemoteReader {
  Future<SupabaseWordsLocalImportBundle> readBundle();
}

class SupabaseRestWordsRemoteReader implements SupabaseWordsRemoteReader {
  SupabaseRestWordsRemoteReader({required SupabaseClient client})
    : _client = client;

  final SupabaseClient _client;

  @override
  Future<SupabaseWordsLocalImportBundle> readBundle() async {
    final words = await _fetchTable('words', orderColumn: 'text');
    final categories = await _fetchTable('categories', orderColumn: 'name');
    final wordCategories = await _fetchTable(
      'word_categories',
      orderColumn: 'word_id',
    );

    return SupabaseWordsLocalImportBundle(
      words: words.map(SupabaseRemoteWord.fromJson).toList(growable: false),
      categories: categories
          .map(SupabaseRemoteCategory.fromJson)
          .toList(growable: false),
      wordCategories: wordCategories
          .map(SupabaseRemoteWordCategory.fromJson)
          .where((link) => link.wordId.isNotEmpty && link.categoryId.isNotEmpty)
          .toList(growable: false),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchTable(
    String table, {
    required String orderColumn,
  }) async {
    final allRows = <Map<String, dynamic>>[];
    const pageSize = 1000;
    var offset = 0;

    while (true) {
      final rows = await _client
          .from(table)
          .select()
          .order(orderColumn)
          .range(offset, offset + pageSize - 1);

      final typedRows = rows
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList(growable: false);
      allRows.addAll(typedRows);
      if (typedRows.length < pageSize) break;
      offset += pageSize;
    }

    return allRows;
  }
}
