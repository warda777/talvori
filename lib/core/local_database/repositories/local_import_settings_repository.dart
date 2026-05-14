import 'package:sqflite/sqflite.dart';

class LocalImportSettingsMarker {
  const LocalImportSettingsMarker({
    this.importedAt,
    this.assetKey,
    this.importVersion,
    this.lastAttemptAt,
    this.lastError,
  });

  final DateTime? importedAt;
  final String? assetKey;
  final String? importVersion;
  final DateTime? lastAttemptAt;
  final String? lastError;
}

class LocalImportSettingsRepository {
  LocalImportSettingsRepository({required Database database})
    : _database = database;

  static const importedAtKey = 'default_words_v1_imported_at';
  static const assetKeyKey = 'default_words_v1_asset_key';
  static const importVersionKey = 'default_words_v1_import_version';
  static const lastAttemptAtKey = 'default_words_v1_last_attempt_at';
  static const lastErrorKey = 'default_words_v1_last_error';

  final Database _database;

  Future<void> saveSuccessMarker({
    required DateTime importedAt,
    required String assetKey,
    required String importVersion,
  }) async {
    await _database.transaction((txn) async {
      await _upsertSetting(
        txn,
        key: importedAtKey,
        value: _encodeDateTime(importedAt),
        valueType: 'datetime',
        updatedAt: importedAt,
      );
      await _upsertSetting(
        txn,
        key: assetKeyKey,
        value: assetKey,
        valueType: 'string',
        updatedAt: importedAt,
      );
      await _upsertSetting(
        txn,
        key: importVersionKey,
        value: importVersion,
        valueType: 'string',
        updatedAt: importedAt,
      );
    });
  }

  Future<void> saveLastAttempt({required DateTime attemptedAt}) async {
    await _database.transaction((txn) async {
      await _upsertSetting(
        txn,
        key: lastAttemptAtKey,
        value: _encodeDateTime(attemptedAt),
        valueType: 'datetime',
        updatedAt: attemptedAt,
      );
    });
  }

  Future<void> saveLastError({required String errorMessage}) async {
    final now = DateTime.now();

    await _database.transaction((txn) async {
      await _upsertSetting(
        txn,
        key: lastErrorKey,
        value: errorMessage,
        valueType: 'string',
        updatedAt: now,
      );
    });
  }

  Future<void> clearLastError() async {
    await _database.delete(
      'settings',
      where: 'key = ?',
      whereArgs: [lastErrorKey],
    );
  }

  Future<LocalImportSettingsMarker?> loadMarker() async {
    final rows = await _database.query(
      'settings',
      where: 'key IN (?, ?, ?, ?, ?)',
      whereArgs: [
        importedAtKey,
        assetKeyKey,
        importVersionKey,
        lastAttemptAtKey,
        lastErrorKey,
      ],
    );

    final settings = {
      for (final row in rows) row['key']! as String: row['value']! as String,
    };

    final importedAt = settings[importedAtKey];
    final assetKey = settings[assetKeyKey];
    final importVersion = settings[importVersionKey];
    final lastAttemptAt = settings[lastAttemptAtKey];
    final lastError = settings[lastErrorKey];

    if (importedAt == null &&
        assetKey == null &&
        importVersion == null &&
        lastAttemptAt == null &&
        lastError == null) {
      return null;
    }

    return LocalImportSettingsMarker(
      importedAt: importedAt == null ? null : _decodeDateTime(importedAt),
      assetKey: assetKey,
      importVersion: importVersion,
      lastAttemptAt: lastAttemptAt == null
          ? null
          : _decodeDateTime(lastAttemptAt),
      lastError: lastError,
    );
  }

  Future<void> _upsertSetting(
    Transaction txn, {
    required String key,
    required String value,
    required String valueType,
    required DateTime updatedAt,
  }) async {
    await txn.insert('settings', {
      'key': key,
      'value': value,
      'value_type': valueType,
      'updated_at': _encodeDateTime(updatedAt),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  String _encodeDateTime(DateTime value) {
    return value.toIso8601String();
  }

  DateTime _decodeDateTime(String value) {
    return DateTime.parse(value);
  }
}
