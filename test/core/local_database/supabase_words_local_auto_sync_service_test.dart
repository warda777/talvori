import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/services/supabase_words_local_auto_sync_service.dart';
import 'package:talvori/core/local_database/services/supabase_words_local_import_service.dart';

void main() {
  final now = DateTime.utc(2026, 5, 27, 12);

  SupabaseWordsLocalImportReport report() {
    return SupabaseWordsLocalImportReport(
        mode: SupabaseWordsLocalImportMode.apply,
        remoteWordsRead: 1,
        generatedAt: now,
      )
      ..localWordsCreated = 1
      ..wordProgressRowsBefore = 0
      ..wordProgressRowsAfter = 0;
  }

  group('SupabaseWordsLocalAutoSyncService', () {
    test(
      'imports when local words are below the completeness threshold',
      () async {
        var importCalls = 0;
        final service = SupabaseWordsLocalAutoSyncService(
          minimumCompleteLocalWordCount: 1000,
          loadLocalWordCount: () async => 0,
          importWords: (_) async {
            importCalls++;
            return report();
          },
        );

        final result = await service.runIfNeeded(now: now);

        expect(result.status, SupabaseWordsLocalAutoSyncStatus.imported);
        expect(result.localWordCountBefore, 0);
        expect(result.report?.localWordsCreated, 1);
        expect(importCalls, 1);
      },
    );

    test('skips when local words already pass the threshold', () async {
      var importCalls = 0;
      final service = SupabaseWordsLocalAutoSyncService(
        minimumCompleteLocalWordCount: 1000,
        loadLocalWordCount: () async => 13629,
        importWords: (_) async {
          importCalls++;
          return report();
        },
      );

      final result = await service.runIfNeeded(now: now);

      expect(result.status, SupabaseWordsLocalAutoSyncStatus.skipped);
      expect(result.localWordCount, 13629);
      expect(importCalls, 0);
    });

    test('parallel starts share one import run', () async {
      var importCalls = 0;
      final completer = Completer<SupabaseWordsLocalImportReport>();
      final service = SupabaseWordsLocalAutoSyncService(
        minimumCompleteLocalWordCount: 1000,
        loadLocalWordCount: () async => 0,
        importWords: (_) {
          importCalls++;
          return completer.future;
        },
      );

      final first = service.runIfNeeded(now: now);
      final second = service.runIfNeeded(now: now);

      await Future<void>.delayed(Duration.zero);
      expect(importCalls, 1);
      completer.complete(report());

      final results = await Future.wait([first, second]);
      expect(results[0].status, SupabaseWordsLocalAutoSyncStatus.imported);
      expect(results[1].status, SupabaseWordsLocalAutoSyncStatus.imported);
      expect(importCalls, 1);
    });

    test('import errors are caught and returned as failed result', () async {
      final logs = <String>[];
      final service = SupabaseWordsLocalAutoSyncService(
        minimumCompleteLocalWordCount: 1000,
        loadLocalWordCount: () async => 0,
        importWords: (_) async => throw StateError('offline'),
        logMessage: logs.add,
      );

      final result = await service.runIfNeeded(now: now);

      expect(result.status, SupabaseWordsLocalAutoSyncStatus.failed);
      expect(result.error, isA<StateError>());
      expect(logs.single, contains('offline'));
    });
  });
}
