import 'dart:async';

import 'supabase_words_local_import_service.dart';

class SupabaseWordsLocalAutoSyncService {
  SupabaseWordsLocalAutoSyncService({
    required SupabaseWordsLocalCountLoader loadLocalWordCount,
    required SupabaseWordsLocalAutoSyncImporter importWords,
    this.minimumCompleteLocalWordCount = 1000,
    this.logMessage,
  }) : _loadLocalWordCount = loadLocalWordCount,
       _importWords = importWords;

  final SupabaseWordsLocalCountLoader _loadLocalWordCount;
  final SupabaseWordsLocalAutoSyncImporter _importWords;
  final int minimumCompleteLocalWordCount;
  final void Function(String message)? logMessage;

  Future<SupabaseWordsLocalAutoSyncResult>? _inFlight;

  Future<SupabaseWordsLocalAutoSyncResult> runIfNeeded({DateTime? now}) {
    final running = _inFlight;
    if (running != null) return running;

    final future = _run(now: now ?? DateTime.now().toUtc());
    _inFlight = future;
    return future.whenComplete(() {
      if (identical(_inFlight, future)) {
        _inFlight = null;
      }
    });
  }

  Future<SupabaseWordsLocalAutoSyncResult> _run({required DateTime now}) async {
    try {
      final localWordCount = await _loadLocalWordCount();
      if (localWordCount >= minimumCompleteLocalWordCount) {
        return SupabaseWordsLocalAutoSyncResult.skipped(
          localWordCount: localWordCount,
          minimumCompleteLocalWordCount: minimumCompleteLocalWordCount,
        );
      }

      final report = await _importWords(now);
      return SupabaseWordsLocalAutoSyncResult.imported(
        localWordCountBefore: localWordCount,
        minimumCompleteLocalWordCount: minimumCompleteLocalWordCount,
        report: report,
      );
    } catch (error, stackTrace) {
      logMessage?.call('Supabase words local auto-sync failed: $error');
      return SupabaseWordsLocalAutoSyncResult.failed(
        minimumCompleteLocalWordCount: minimumCompleteLocalWordCount,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}

enum SupabaseWordsLocalAutoSyncStatus { skipped, imported, failed }

class SupabaseWordsLocalAutoSyncResult {
  const SupabaseWordsLocalAutoSyncResult._({
    required this.status,
    required this.minimumCompleteLocalWordCount,
    this.localWordCount,
    this.localWordCountBefore,
    this.report,
    this.error,
    this.stackTrace,
  });

  factory SupabaseWordsLocalAutoSyncResult.skipped({
    required int localWordCount,
    required int minimumCompleteLocalWordCount,
  }) {
    return SupabaseWordsLocalAutoSyncResult._(
      status: SupabaseWordsLocalAutoSyncStatus.skipped,
      localWordCount: localWordCount,
      minimumCompleteLocalWordCount: minimumCompleteLocalWordCount,
    );
  }

  factory SupabaseWordsLocalAutoSyncResult.imported({
    required int localWordCountBefore,
    required int minimumCompleteLocalWordCount,
    required SupabaseWordsLocalImportReport report,
  }) {
    return SupabaseWordsLocalAutoSyncResult._(
      status: SupabaseWordsLocalAutoSyncStatus.imported,
      localWordCountBefore: localWordCountBefore,
      minimumCompleteLocalWordCount: minimumCompleteLocalWordCount,
      report: report,
    );
  }

  factory SupabaseWordsLocalAutoSyncResult.failed({
    required int minimumCompleteLocalWordCount,
    required Object error,
    required StackTrace stackTrace,
  }) {
    return SupabaseWordsLocalAutoSyncResult._(
      status: SupabaseWordsLocalAutoSyncStatus.failed,
      minimumCompleteLocalWordCount: minimumCompleteLocalWordCount,
      error: error,
      stackTrace: stackTrace,
    );
  }

  final SupabaseWordsLocalAutoSyncStatus status;
  final int minimumCompleteLocalWordCount;
  final int? localWordCount;
  final int? localWordCountBefore;
  final SupabaseWordsLocalImportReport? report;
  final Object? error;
  final StackTrace? stackTrace;
}

typedef SupabaseWordsLocalCountLoader = Future<int> Function();

typedef SupabaseWordsLocalAutoSyncImporter =
    Future<SupabaseWordsLocalImportReport> Function(DateTime now);
