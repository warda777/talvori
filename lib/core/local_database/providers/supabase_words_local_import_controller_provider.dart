import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_words_local_auto_sync_service.dart';
import '../services/supabase_words_local_import_service.dart';
import '../services/supabase_words_remote_reader.dart';
import 'local_bootstrap_provider.dart';

final supabaseWordsRemoteReaderProvider = Provider<SupabaseWordsRemoteReader>((
  ref,
) {
  return SupabaseRestWordsRemoteReader(client: Supabase.instance.client);
});

final supabaseWordsLocalImportServiceProvider =
    Provider<SupabaseWordsLocalImportService>((ref) {
      return const SupabaseWordsLocalImportService();
    });

final supabaseWordsLocalAutoSyncServiceProvider =
    Provider<SupabaseWordsLocalAutoSyncService>((ref) {
      return SupabaseWordsLocalAutoSyncService(
        loadLocalWordCount: () async {
          final bootstrap = await ref.read(localBootstrapProvider.future);
          return bootstrap.repositoryFactory.wordRepository.countAllWords();
        },
        importWords: (now) async {
          final bootstrap = await ref.read(localBootstrapProvider.future);
          final reader = ref.read(supabaseWordsRemoteReaderProvider);
          final service = ref.read(supabaseWordsLocalImportServiceProvider);
          final bundle = await reader.readBundle();
          return service.apply(
            database: bootstrap.database,
            bundle: bundle,
            now: now,
          );
        },
        logMessage: debugPrint,
      );
    });

final supabaseWordsLocalAdminImportControllerProvider =
    StateNotifierProvider<
      SupabaseWordsLocalAdminImportController,
      SupabaseWordsLocalAdminImportState
    >((ref) {
      return SupabaseWordsLocalAdminImportController.fromRef(ref);
    });

enum SupabaseWordsLocalAdminImportAction { none, preview, apply, failed }

class SupabaseWordsLocalAdminImportState {
  const SupabaseWordsLocalAdminImportState({
    this.isLoading = false,
    this.hasSuccessfulPreview = false,
    this.report,
    this.errorMessage,
    this.lastAction = SupabaseWordsLocalAdminImportAction.none,
  });

  final bool isLoading;
  final bool hasSuccessfulPreview;
  final SupabaseWordsLocalImportReport? report;
  final String? errorMessage;
  final SupabaseWordsLocalAdminImportAction lastAction;

  bool get canApply => hasSuccessfulPreview && !isLoading;

  SupabaseWordsLocalAdminImportState copyWith({
    bool? isLoading,
    bool? hasSuccessfulPreview,
    SupabaseWordsLocalImportReport? report,
    bool clearReport = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    SupabaseWordsLocalAdminImportAction? lastAction,
  }) {
    return SupabaseWordsLocalAdminImportState(
      isLoading: isLoading ?? this.isLoading,
      hasSuccessfulPreview: hasSuccessfulPreview ?? this.hasSuccessfulPreview,
      report: clearReport ? null : (report ?? this.report),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      lastAction: lastAction ?? this.lastAction,
    );
  }
}

class SupabaseWordsLocalAdminImportController
    extends StateNotifier<SupabaseWordsLocalAdminImportState> {
  SupabaseWordsLocalAdminImportController({
    required SupabaseWordsLocalImportRunner runner,
  }) : _runner = runner,
       super(const SupabaseWordsLocalAdminImportState());

  factory SupabaseWordsLocalAdminImportController.fromRef(Ref ref) {
    return SupabaseWordsLocalAdminImportController(
      runner: ({required apply, required now}) async {
        final reader = ref.read(supabaseWordsRemoteReaderProvider);
        final service = ref.read(supabaseWordsLocalImportServiceProvider);
        final bootstrap = await ref.read(localBootstrapProvider.future);
        final bundle = await reader.readBundle();
        return apply
            ? service.apply(
                database: bootstrap.database,
                bundle: bundle,
                now: now,
              )
            : service.preview(
                database: bootstrap.database,
                bundle: bundle,
                now: now,
              );
      },
    );
  }

  final SupabaseWordsLocalImportRunner _runner;

  Future<void> runPreview({DateTime? now}) {
    return _run(apply: false, now: now ?? DateTime.now().toUtc());
  }

  Future<void> runApply({DateTime? now}) {
    if (!state.hasSuccessfulPreview) {
      state = state.copyWith(
        errorMessage: 'Bitte zuerst eine Preview ausführen.',
        lastAction: SupabaseWordsLocalAdminImportAction.failed,
      );
      return Future.value();
    }
    return _run(apply: true, now: now ?? DateTime.now().toUtc());
  }

  Future<void> _run({required bool apply, required DateTime now}) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      lastAction: apply
          ? SupabaseWordsLocalAdminImportAction.apply
          : SupabaseWordsLocalAdminImportAction.preview,
    );

    try {
      final report = await _runner(apply: apply, now: now);

      state = state.copyWith(
        isLoading: false,
        hasSuccessfulPreview: apply ? state.hasSuccessfulPreview : true,
        report: report,
        clearErrorMessage: true,
        lastAction: apply
            ? SupabaseWordsLocalAdminImportAction.apply
            : SupabaseWordsLocalAdminImportAction.preview,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
        lastAction: SupabaseWordsLocalAdminImportAction.failed,
      );
    }
  }
}

typedef SupabaseWordsLocalImportRunner =
    Future<SupabaseWordsLocalImportReport> Function({
      required bool apply,
      required DateTime now,
    });
