import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/repositories/local_import_settings_repository.dart';

void main() {
  sqfliteFfiInit();

  final fixedNow = DateTime(2026, 5, 14, 10);

  Future<Database> openSchemaDatabase() async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await LocalDatabaseSchema.createV1(db);
    return db;
  }

  group('LocalImportSettingsRepository', () {
    test('import_settings_repository_saves_and_loads_marker', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final repository = LocalImportSettingsRepository(database: db);

      await repository.saveSuccessMarker(
        importedAt: fixedNow,
        assetKey: 'assets/local_import/default_words_v1.json',
        importVersion: 'default_words_v1',
      );

      final marker = await repository.loadMarker();

      expect(marker, isNotNull);
      expect(marker!.importedAt, fixedNow);
      expect(marker.assetKey, 'assets/local_import/default_words_v1.json');
      expect(marker.importVersion, 'default_words_v1');
      expect(marker.lastAttemptAt, isNull);
      expect(marker.lastError, isNull);

      final settings = await db.query('settings', orderBy: 'key ASC');
      expect(settings, hasLength(3));
      expect(settings.map((row) => row['key']), [
        LocalImportSettingsRepository.assetKeyKey,
        LocalImportSettingsRepository.importVersionKey,
        LocalImportSettingsRepository.importedAtKey,
      ]);
      expect(
        settings.firstWhere(
          (row) => row['key'] == LocalImportSettingsRepository.importedAtKey,
        )['value_type'],
        'datetime',
      );

      expect(await db.query('categories'), isEmpty);
      expect(await db.query('words'), isEmpty);
      expect(await db.query('word_progress'), isEmpty);
      expect(await db.query('learning_sessions'), isEmpty);
      expect(await db.query('review_history'), isEmpty);
    });

    test('import_settings_repository_saves_last_attempt', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final repository = LocalImportSettingsRepository(database: db);

      await repository.saveLastAttempt(attemptedAt: fixedNow);

      final marker = await repository.loadMarker();

      expect(marker, isNotNull);
      expect(marker!.lastAttemptAt, fixedNow);
      expect(marker.importedAt, isNull);
      expect(marker.assetKey, isNull);
      expect(marker.importVersion, isNull);
      expect(marker.lastError, isNull);

      final settings = await db.query('settings');
      expect(settings, hasLength(1));
      expect(
        settings.single['key'],
        LocalImportSettingsRepository.lastAttemptAtKey,
      );
      expect(settings.single['value'], fixedNow.toIso8601String());
      expect(settings.single['value_type'], 'datetime');

      expect(await db.query('categories'), isEmpty);
      expect(await db.query('words'), isEmpty);
      expect(await db.query('word_progress'), isEmpty);
      expect(await db.query('learning_sessions'), isEmpty);
      expect(await db.query('review_history'), isEmpty);
    });

    test('import_settings_repository_saves_and_clears_last_error', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final repository = LocalImportSettingsRepository(database: db);
      final attemptedAt = fixedNow.add(const Duration(minutes: 1));

      await repository.saveSuccessMarker(
        importedAt: fixedNow,
        assetKey: 'assets/local_import/default_words_v1.json',
        importVersion: 'default_words_v1',
      );
      await repository.saveLastAttempt(attemptedAt: attemptedAt);
      await repository.saveLastError(errorMessage: 'boom');

      final markerWithError = await repository.loadMarker();

      expect(markerWithError, isNotNull);
      expect(markerWithError!.lastError, 'boom');
      expect(markerWithError.importedAt, fixedNow);
      expect(
        markerWithError.assetKey,
        'assets/local_import/default_words_v1.json',
      );
      expect(markerWithError.importVersion, 'default_words_v1');
      expect(markerWithError.lastAttemptAt, attemptedAt);

      await repository.clearLastError();

      final markerAfterClear = await repository.loadMarker();

      expect(markerAfterClear, isNotNull);
      expect(markerAfterClear!.lastError, isNull);
      expect(markerAfterClear.importedAt, fixedNow);
      expect(
        markerAfterClear.assetKey,
        'assets/local_import/default_words_v1.json',
      );
      expect(markerAfterClear.importVersion, 'default_words_v1');
      expect(markerAfterClear.lastAttemptAt, attemptedAt);

      final settings = await db.query('settings');
      expect(
        settings.any(
          (row) => row['key'] == LocalImportSettingsRepository.lastErrorKey,
        ),
        isFalse,
      );

      expect(await db.query('categories'), isEmpty);
      expect(await db.query('words'), isEmpty);
      expect(await db.query('word_progress'), isEmpty);
      expect(await db.query('learning_sessions'), isEmpty);
      expect(await db.query('review_history'), isEmpty);
    });
  });
}
