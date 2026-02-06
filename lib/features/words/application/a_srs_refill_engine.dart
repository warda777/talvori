import 'dart:math';
import '../data/local_word_database.dart';
import 'a_srs_bands.dart';

class ASrsRefillEngine {
  final LocalWordDatabase db;
  final ASrsBands bands;

  ASrsRefillEngine({
    required this.db,
    required this.bands,
  });

  /// Führt einen vollständigen Refill aus und liefert deterministisch die nächste Deck-Liste zurück.
  ///
  /// Wichtig: setzt voraus, dass `word_progress` für diese Kategorie existiert (lokales Mirror/Seed).
  Future<List<String>> refillAdaptiveDeck({
    required String userId,
    required String categoryId,
    String mode = 'adaptive',
    required int pTake,     // Deck-Größe, z.B. 20
    int s5Cap = 2,          // max S5 pro Refill
  }) async {
    // 0) Deck-State sicherstellen (oder du verlässt dich auf LEFT JOIN + UPSERT)
    await db.ensureDeckStateRows(userId: userId, categoryId: categoryId, mode: mode);

    // 1) refill_counter++
    final refillCounter = await db.incrementRefillCounter(
      userId: userId,
      categoryId: categoryId,
      mode: mode,
    );

    // 2) Counts holen
    final counts = await db.getStageCounts(
      userId: userId,
      categoryId: categoryId,
      mode: mode,
    );

    // 3) Bands bestimmen (dein a_srs_bands.dart muss diese Werte liefern)
    final b = bands.forCounts(
      s0: counts.s0,
      s1: counts.s1,
      s2: counts.s2,
      s3: counts.s3,
      s4: counts.s4,
      s5: counts.s5,
      mastered: counts.mastered,
    );

    // 4) S0 -> S1 enroll, falls S1 < s1Min
    final needS1 = max(0, b.s1Min - counts.s1);
    if (needS1 > 0) {
      // limit: nicht mehr als S0 verfügbar
      final enrollN = min(needS1, counts.s0);
      await db.enrollFromS0ToS1(
        userId: userId,
        categoryId: categoryId,
        mode: mode,
        n: enrollN,
      );
    }

    // 5) Cascade
    await db.runCascadeTransaction(
      userId: userId,
      categoryId: categoryId,
      mode: mode,
      s1Min: b.s1Min, s1Max: b.s1Max,
      s2Min: b.s2Min, s2Max: b.s2Max,
      s3Min: b.s3Min, s3Max: b.s3Max,
      s4Min: b.s4Min, s4Max: b.s4Max,
      s5Min: b.s5Min, s5Max: b.s5Max,
    );

    // 6) Queue Take
    final take = await db.selectQueueTake(
      userId: userId,
      categoryId: categoryId,
      mode: mode,
      refillCounter: refillCounter,
      pTake: pTake,
      s5Cap: s5Cap,
    );

    // 7) Queue Commit (UPSERT)
    await db.commitQueueTake(
      userId: userId,
      categoryId: categoryId,
      mode: mode,
      refillCounter: refillCounter,
      wordIds: take.wordIds,
    );

    return take.wordIds;
  }

