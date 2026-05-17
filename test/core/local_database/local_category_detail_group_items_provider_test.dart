import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/providers/local_category_detail_group_items_provider.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('localCategoryDetailGroupItemsProvider', () {
    test('enriches_mapped_items_with_local_word_count', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_category_detail_group_items_provider_test_',
      );
      late final ProviderContainer container;

      addTearDown(() async {
        container.dispose();
        await Future<void>.delayed(Duration.zero);
        final databasePath = LocalAppDatabasePath.buildPath(tempDir.path);
        await databaseFactoryFfi.deleteDatabase(databasePath);
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      container = ProviderContainer(
        overrides: [
          localBootstrapDatabasesPathProvider.overrideWithValue(tempDir.path),
        ],
      );

      final items = await container.read(
        localCategoryDetailGroupItemsProvider('health_fitness').future,
      );

      expect(items, hasLength(1));
      expect(items.single.displayLabel, 'Health & Fitness');
      expect(items.single.localCategoryId, 'seed-category-basics');
      expect(items.single.vocabsCount, 3);
    });

    test('returns_empty_list_for_unknown_key_without_fallback_count', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final items = await container.read(
        localCategoryDetailGroupItemsProvider('unknown').future,
      );

      expect(items, isEmpty);
    });
  });
}
