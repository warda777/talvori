// lib/features/words/data/local_word_database.dart

import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../application/a_srs_bands.dart';

class LocalWordDatabase {
  LocalWordDatabase._();
  static final LocalWordDatabase instance = LocalWordDatabase._();

  static const String _dbName = 'word_progress.db';
  static const int _dbVersion = 1;

  Database? _db;
  final Uuid _uuid = const Uuid();

  /// Öffnet die Datenbank (erstellt sie falls nötig)
  Future<Database> get database async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return _db!;
  }

  /// Erstellt die Tabellen beim ersten Start
  Future<void> _onCreate(Database db, int version) async {
    // Haupttabelle: word_progress
    await db.execute('''
      CREATE TABLE IF NOT EXISTS word_progress (
        user_id TEXT NOT NULL,
        category_id TEXT NOT NULL,
        word_id TEXT NOT NULL,
        mode TEXT NOT NULL DEFAULT 'adaptive',
        stage INTEGER NOT NULL DEFAULT 0,
        ever_enrolled INTEGER NOT NULL DEFAULT 0,
        is_mastered INTEGER NOT NULL DEFAULT 0,
        streak_in_stage INTEGER NOT NULL DEFAULT 0,
        added_to_category_at INTEGER NOT NULL,
        updated_at TEXT NOT NULL,
        device_id TEXT NOT NULL,
        device_seq INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (user_id, category_id, word_id, mode)
      )
    ''');

    // Deck-State Tabelle (lokal-only)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS word_progress_deck_state (
        user_id TEXT NOT NULL,
        category_id TEXT NOT NULL,
        word_id TEXT NOT NULL,
        mode TEXT NOT NULL,
        last_queued_counter INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (user_id, category_id, word_id, mode)
      )
    ''');

    // Refill-State Tabelle (lokal-only)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS category_refill_state (
        user_id TEXT NOT NULL,
        category_id TEXT NOT NULL,
        mode TEXT NOT NULL,
        refill_counter INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (user_id, category_id, mode)
      )
    ''');

    // Performance-Indizes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_progress_stage
        ON word_progress(user_id, category_id, mode, is_mastered, stage)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_progress_added
        ON word_progress(added_to_category_at)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_deck_state
        ON word_progress_deck_state(user_id, category_id, mode, last_queued_counter, word_id)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migrationen hier implementieren
  }

  /// Schließt die Datenbank
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  // ------------------------------------------------------------
  // 11.3 Step 1: refill_counter++ (lokal-only)
  // ------------------------------------------------------------
  Future<int> incrementRefillCounter({
    required String userId,
    required String categoryId,
    required String mode,
  }) async {
    final db = await database;

    return await db.transaction<int>((txn) async {
      // ensure row
      await txn.rawInsert('''
        INSERT OR IGNORE INTO category_refill_state (user_id, category_id, mode, refill_counter)
        VALUES (?, ?, ?, 0)
      ''', [userId, categoryId, mode]);

      await txn.rawUpdate('''
        UPDATE category_refill_state
        SET refill_counter = refill_counter + 1
        WHERE user_id=? AND category_id=? AND mode=?
      ''', [userId, categoryId, mode]);

      final rows = await txn.rawQuery('''
        SELECT refill_counter FROM category_refill_state
        WHERE user_id=? AND category_id=? AND mode=?
        LIMIT 1
      ''', [userId, categoryId, mode]);

      return (rows.first['refill_counter'] as int);
    });
  }

  // ------------------------------------------------------------
  // Debug-Helper: Prüft ob word_progress lokal gespiegelt ist
  // ------------------------------------------------------------
  Future<int> getWordProgressCount({
    required String userId,
    required String categoryId,
    String mode = 'adaptive',
  }) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT COUNT(*) AS c
      FROM word_progress
      WHERE user_id=? AND category_id=? AND mode=?
    ''', [userId, categoryId, mode]);
    return (rows.first['c'] as int?) ?? 0;
  }

  // ------------------------------------------------------------
  // 11.3 Aggregat-Query (hart, 1 roundtrip)
  // ------------------------------------------------------------
  Future<StageCounts> getStageCounts({
    required String userId,
    required String categoryId,
    required String mode,
  }) async {
    final db = await database;

    final rows = await db.rawQuery('''
      SELECT
        SUM(CASE WHEN stage=0 AND ever_enrolled=0 AND is_mastered=0 THEN 1 ELSE 0 END) AS s0,
        SUM(CASE WHEN stage=1 AND is_mastered=0 THEN 1 ELSE 0 END) AS s1,
        SUM(CASE WHEN stage=2 AND is_mastered=0 THEN 1 ELSE 0 END) AS s2,
        SUM(CASE WHEN stage=3 AND is_mastered=0 THEN 1 ELSE 0 END) AS s3,
        SUM(CASE WHEN stage=4 AND is_mastered=0 THEN 1 ELSE 0 END) AS s4,
        SUM(CASE WHEN stage=5 AND is_mastered=0 THEN 1 ELSE 0 END) AS s5,
        SUM(CASE WHEN is_mastered=1 THEN 1 ELSE 0 END) AS mastered
      FROM word_progress
      WHERE user_id=? AND category_id=? AND mode=?;
    ''', [userId, categoryId, mode]);

    final r = rows.first;
    int _i(Object? v) => (v == null) ? 0 : (v as int);

    return StageCounts(
      s0: _i(r['s0']),
      s1: _i(r['s1']),
      s2: _i(r['s2']),
      s3: _i(r['s3']),
      s4: _i(r['s4']),
      s5: _i(r['s5']),
      mastered: _i(r['mastered']),
    );
  }

  // ------------------------------------------------------------
  // Punkt 12: deterministische Auswahl + Progress-Event (Enroll)
  // - stage:0->1, ever_enrolled=true, streak=0
  // - updated_at/device_seq++ (Progress Event)
  // ------------------------------------------------------------
  Future<void> enrollFromS0ToS1({
    required String userId,
    required String categoryId,
    required String mode,
    required int n,
  }) async {
    if (n <= 0) return;
    final db = await database;

    await db.transaction((txn) async {
      // Selektiere n eligible deterministisch
      // ORDER BY added_to_category_at ASC, word_id ASC
      final ids = await txn.rawQuery('''
        SELECT word_id
        FROM word_progress
        WHERE user_id=? AND category_id=? AND mode=?
          AND stage=0 AND ever_enrolled=0 AND is_mastered=0
        ORDER BY added_to_category_at ASC, word_id ASC
        LIMIT ?;
      ''', [userId, categoryId, mode, n]);

      if (ids.isEmpty) return;

      // Für jedes Wort: Progress-Event (updated_at/device_seq) muss gesetzt werden.
      // Wir benutzen deine vorhandenen Helpers (_nextDeviceSeq/_nextLogicalTime).
      // Falls du sie schon hast: ersetze die TODO calls unten durch deine Implementierung.
      for (final row in ids) {
        final wordId = row['word_id'] as String;

        final deviceSeq = await _nextDeviceSeq(txn);
        final updatedAt = _nextLogicalTimeIso();

        await txn.rawUpdate('''
          UPDATE word_progress
          SET stage=1,
              ever_enrolled=1,
              streak_in_stage=0,
              updated_at=?,
              device_seq=?,
              device_id=?
          WHERE user_id=? AND category_id=? AND mode=? AND word_id=?
        ''', [updatedAt, deviceSeq, await _getOrCreateDeviceId(txn), userId, categoryId, mode, wordId]);
      }
    });
  }

  // ------------------------------------------------------------
  // 6A.4 Cascade Transaction:
  // - shift S1->S2 bis S2_max, solange S1_count > S1_min
  // - shift S2->S3 bis S3_max, solange S2_count > S2_min
  // - shift S3->S4 bis S4_max, solange S3_count > S3_min
  // - shift S4->S5 bis S5_max, solange S4_count > S4_min
  // - deterministische Auswahl innerhalb Stage:
  //   ORDER BY added_to_category_at ASC, word_id ASC
  // - JEDER Shift ist Progress-Event (updated_at/device_seq++)
  // ------------------------------------------------------------
  Future<CascadeResult> runCascadeTransaction({
    required String userId,
    required String categoryId,
    required String mode,
    required int s1Min,
    required int s1Max,
    required int s2Min,
    required int s2Max,
    required int s3Min,
    required int s3Max,
    required int s4Min,
    required int s4Max,
    required int s5Min,
    required int s5Max,
  }) async {
    final db = await database;

    return await db.transaction<_CascadeResult>((txn) async {
      // counts einmal laden (innerhalb txn)
      Future<List<int>> _counts() async {
        final r = await txn.rawQuery('''
          SELECT
            SUM(CASE WHEN stage=1 AND is_mastered=0 THEN 1 ELSE 0 END) AS s1,
            SUM(CASE WHEN stage=2 AND is_mastered=0 THEN 1 ELSE 0 END) AS s2,
            SUM(CASE WHEN stage=3 AND is_mastered=0 THEN 1 ELSE 0 END) AS s3,
            SUM(CASE WHEN stage=4 AND is_mastered=0 THEN 1 ELSE 0 END) AS s4,
            SUM(CASE WHEN stage=5 AND is_mastered=0 THEN 1 ELSE 0 END) AS s5
          FROM word_progress
          WHERE user_id=? AND category_id=? AND mode=?;
        ''', [userId, categoryId, mode]);
        int _i(Object? v) => v == null ? 0 : v as int;
        final row = r.first;
        return [_i(row['s1']), _i(row['s2']), _i(row['s3']), _i(row['s4']), _i(row['s5'])];
      }

      int shift12 = 0, shift23 = 0, shift34 = 0, shift45 = 0;

      // helper shift i->i+1
      Future<int> _shift(int from, int to, int fromMin, int toMax) async {
        final cs = await _counts();
        final fromCount = cs[from - 1]; // stage 1..5 -> index 0..4
        final toCount = cs[to - 1];

        final give = max(0, fromCount - fromMin);
        final need = max(0, toMax - toCount);
        final k = min(give, need);
        if (k <= 0) return 0;

        final ids = await txn.rawQuery('''
          SELECT word_id
          FROM word_progress
          WHERE user_id=? AND category_id=? AND mode=?
            AND is_mastered=0 AND stage=?
          ORDER BY added_to_category_at ASC, word_id ASC
          LIMIT ?;
        ''', [userId, categoryId, mode, from, k]);

        if (ids.isEmpty) return 0;

        for (final row in ids) {
          final wordId = row['word_id'] as String;
          final deviceSeq = await _nextDeviceSeq(txn);
          final updatedAt = _nextLogicalTimeIso();

          await txn.rawUpdate('''
            UPDATE word_progress
            SET stage=?,
                streak_in_stage=0,
                ever_enrolled=1,
                updated_at=?,
                device_seq=?,
                device_id=?
            WHERE user_id=? AND category_id=? AND mode=? AND word_id=? AND is_mastered=0
          ''', [to, updatedAt, deviceSeq, await _getOrCreateDeviceId(txn), userId, categoryId, mode, wordId]);
        }

        return ids.length;
      }

      // Reihenfolge wie 11.3 Schritt 5
      shift12 = await _shift(1, 2, s1Min, s2Max);
      shift23 = await _shift(2, 3, s2Min, s3Max);
      shift34 = await _shift(3, 4, s3Min, s4Max);
      shift45 = await _shift(4, 5, s4Min, s5Max);

      return CascadeResult(shift12: shift12, shift23: shift23, shift34: shift34, shift45: shift45);
    });
  }

  // ------------------------------------------------------------
  // Queue-Take (8A.4 + 9.1 + 11.3 Schritt 6)
  //
  // Availability:
  //  - is_mastered=0
  //  - stage in 1..5
  //  - last_queued_counter < refill_counter
  //
  // Deterministische Auswahl innerhalb einer Stage:
  // ORDER BY deck.last_queued_counter ASC, progress.added_to_category_at ASC, progress.word_id ASC
  //
  // Queue-Build Policy v1.0 (hart, testbar):
  // - Wir ziehen in fester Stage-Reihenfolge: 2 → 3 → 1 → 4 → 5
  // - S5 ist zusätzlich durch s5Cap begrenzt (max 2 pro Refill)
  // - Wir ziehen bis pTake erfüllt oder nichts mehr verfügbar.
  // ------------------------------------------------------------
  Future<QueueTake> selectQueueTake({
    required String userId,
    required String categoryId,
    required String mode,
    required int refillCounter,
    required int pTake,
    required int s5Cap,
  }) async {
    final db = await database;
    if (pTake <= 0) return const QueueTake(wordIds: [], s5Included: 0);

    final stagesOrder = <int>[2, 3, 1, 4, 5];
    final result = <String>[];
    int s5Included = 0;

    // lokale helper: hole max K aus einer Stage mit availability, deterministisch
    // LEFT JOIN + COALESCE für robuste Behandlung fehlender deck_state Einträge
    Future<List<String>> _takeFromStage(int stage, int k) async {
      if (k <= 0) return const [];
      final rows = await db.rawQuery('''
        SELECT p.word_id
        FROM word_progress p
        LEFT JOIN word_progress_deck_state d
          ON d.user_id=p.user_id AND d.category_id=p.category_id AND d.word_id=p.word_id AND d.mode=p.mode
        WHERE p.user_id=? AND p.category_id=? AND p.mode=?
          AND p.is_mastered=0
          AND p.stage=?
          AND COALESCE(d.last_queued_counter, 0) < ?
        ORDER BY COALESCE(d.last_queued_counter, 0) ASC, p.added_to_category_at ASC, p.word_id ASC
        LIMIT ?;
      ''', [userId, categoryId, mode, stage, refillCounter, k]);

      return rows.map((r) => r['word_id'] as String).toList(growable: false);
    }

    int remaining = pTake;

    for (final st in stagesOrder) {
      if (remaining <= 0) break;

      int cap = remaining;
      if (st == 5) {
        cap = min(cap, max(0, s5Cap - s5Included));
        if (cap <= 0) continue;
      }

      final ids = await _takeFromStage(st, cap);
      if (ids.isEmpty) continue;

      result.addAll(ids);
      remaining -= ids.length;
      if (st == 5) s5Included += ids.length;
    }

    return QueueTake(wordIds: result, s5Included: s5Included);
  }

  // ------------------------------------------------------------
  // Queue-Commit (8A.4.B):
  // - last_queued_counter setzen (lokal-only)
  // - KEIN updated_at/device_seq (kein Progress-Event)
  // - UPSERT: Falls Eintrag nicht existiert, wird er erstellt
  // ------------------------------------------------------------
  Future<void> commitQueueTake({
    required String userId,
    required String categoryId,
    required String mode,
    required int refillCounter,
    required List<String> wordIds,
  }) async {
    if (wordIds.isEmpty) return;
    final db = await database;

    await db.transaction((txn) async {
      for (final wordId in wordIds) {
        await txn.rawInsert('''
          INSERT INTO word_progress_deck_state
            (user_id, category_id, word_id, mode, last_queued_counter)
          VALUES (?, ?, ?, ?, ?)
          ON CONFLICT(user_id, category_id, word_id, mode)
          DO UPDATE SET last_queued_counter=excluded.last_queued_counter
        ''', [userId, categoryId, wordId, mode, refillCounter]);
      }
    });
  }

  // ------------------------------------------------------------
  // Helpers: Device-ID, Device-Sequenz, Logical Time
  // ------------------------------------------------------------

  /// Holt oder erstellt eine Device-ID (persistent über SharedPreferences)
  Future<String> _getOrCreateDeviceId(Transaction txn) async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString('local_db_device_id');
    if (deviceId != null) return deviceId;

    final newDeviceId = _uuid.v4();
    await prefs.setString('local_db_device_id', newDeviceId);
    return newDeviceId;
  }

  /// Atomar erhöht die Device-Sequenz (pro User, persistent über SharedPreferences)
  Future<int> _nextDeviceSeq(Transaction txn) async {
    final prefs = await SharedPreferences.getInstance();
    final currentSeq = prefs.getInt('local_db_device_seq') ?? 0;
    final nextSeq = currentSeq + 1;
    await prefs.setInt('local_db_device_seq', nextSeq);
    return nextSeq;
  }

  /// Gibt die nächste logische Timestamp zurück (ISO String, monoton steigend)
  String _nextLogicalTimeIso() {
    return DateTime.now().toUtc().toIso8601String();
  }

  // ------------------------------------------------------------
  // Backfill: word_progress_deck_state (INSERT OR IGNORE)
  // ------------------------------------------------------------

  /// Erstellt fehlende Einträge in word_progress_deck_state für alle Wörter
  /// in word_progress (INSERT OR IGNORE)
  Future<void> ensureDeckStateRows({
    required String userId,
    required String categoryId,
    required String mode,
  }) async {
    final db = await database;

    await db.transaction((txn) async {
      // Hole alle word_ids aus word_progress, die noch nicht in deck_state sind
      final missingRows = await txn.rawQuery('''
        SELECT p.word_id
        FROM word_progress p
        LEFT JOIN word_progress_deck_state d
          ON d.user_id = p.user_id
          AND d.category_id = p.category_id
          AND d.word_id = p.word_id
          AND d.mode = p.mode
        WHERE p.user_id = ?
          AND p.category_id = ?
          AND p.mode = ?
          AND d.word_id IS NULL
      ''', [userId, categoryId, mode]);

      if (missingRows.isEmpty) return;

      // INSERT OR IGNORE für alle fehlenden Einträge
      for (final row in missingRows) {
        final wordId = row['word_id'] as String;
        await txn.rawInsert('''
          INSERT OR IGNORE INTO word_progress_deck_state
            (user_id, category_id, word_id, mode, last_queued_counter)
          VALUES (?, ?, ?, ?, 0)
        ''', [userId, categoryId, wordId, mode]);
      }
    });
  }

  /// Batch-Backfill: Erstellt deck_state Einträge für eine Liste von word_ids
  Future<void> ensureDeckStateRowsForWords({
    required String userId,
    required String categoryId,
    required String mode,
    required List<String> wordIds,
  }) async {
    if (wordIds.isEmpty) return;
    final db = await database;

    await db.transaction((txn) async {
      for (final wordId in wordIds) {
        await txn.rawInsert('''
          INSERT OR IGNORE INTO word_progress_deck_state
            (user_id, category_id, word_id, mode, last_queued_counter)
          VALUES (?, ?, ?, ?, 0)
        ''', [userId, categoryId, wordId, mode]);
      }
    });
  }
}

/// Ergebnis einer Cascade-Transaktion
class CascadeResult {
  final int shift12;
  final int shift23;
  final int shift34;
  final int shift45;

  const CascadeResult({
    required this.shift12,
    required this.shift23,
    required this.shift34,
    required this.shift45,
  });
}

/// Ergebnis einer Queue-Take Operation
class QueueTake {
  final List<String> wordIds;
  final int s5Included;
  const QueueTake({required this.wordIds, required this.s5Included});
}