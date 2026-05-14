import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/local_database/controllers/local_learning_controller.dart';
import '../../../core/local_database/providers/local_debug_import_controller_provider.dart';
import '../../../core/local_database/providers/local_learning_screen_contract_provider.dart';
import '../../../core/local_database/providers/local_learning_view_model_provider.dart';
import '../../../core/srs/models/learning_mode.dart';
import '../../../core/srs/models/srs_stage.dart';
import '../../../core/srs/models/training_area.dart';

typedef LocalLearningStartAction =
    Future<void> Function({
      required String categoryId,
      required LearningMode mode,
      required TrainingArea trainingArea,
      required DateTime now,
    });

typedef LocalLearningSubmitAction =
    Future<void> Function({required DateTime now});

typedef LocalLearningImportAction =
    Future<void> Function({required DateTime now});

class LocalLearningTestScreen extends ConsumerWidget {
  const LocalLearningTestScreen({
    super.key,
    required this.categoryId,
    this.onStartOrResume,
    this.onSubmitCorrect,
    this.onSubmitWrong,
    this.onCompleteIfFinished,
    this.onImportDefaultWords,
    this.nowProvider,
  });

  final String categoryId;
  final LocalLearningStartAction? onStartOrResume;
  final LocalLearningSubmitAction? onSubmitCorrect;
  final LocalLearningSubmitAction? onSubmitWrong;
  final LocalLearningSubmitAction? onCompleteIfFinished;
  final LocalLearningImportAction? onImportDefaultWords;
  final DateTime Function()? nowProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelState = ref.watch(localLearningViewModelProvider);
    final contract = ref.watch(localLearningScreenContractProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Intensiv lernen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Intensiv lernen'),
            const SizedBox(height: 8),
            const Text('Alles lernen'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _importDefaultWords(ref),
              child: const Text('Debug-Daten importieren'),
            ),
            const SizedBox(height: 24),
            if (contract.isInitial) ...[
              const Text('Noch keine Session'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _startOrResume(ref),
                child: const Text('Starten/Fortsetzen'),
              ),
            ],
            if (contract.isLoading) ...[const Text('Lädt...')],
            if (contract.hasError) ...[
              const Text('Etwas ist schiefgelaufen'),
              if (viewModelState.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(viewModelState.errorMessage!),
              ],
            ],
            if (contract.hasActiveCard) ...[
              Text(viewModelState.term ?? ''),
              const SizedBox(height: 8),
              if (viewModelState.translation != null) ...[
                Text(viewModelState.translation!),
                const SizedBox(height: 8),
              ],
              if (viewModelState.exampleSentence != null) ...[
                Text(viewModelState.exampleSentence!),
                const SizedBox(height: 8),
              ],
              if (viewModelState.notes != null) ...[
                Text(viewModelState.notes!),
                const SizedBox(height: 8),
              ],
              if (viewModelState.currentStage != null) ...[
                Text(_stageLabel(viewModelState.currentStage!)),
                const SizedBox(height: 8),
              ],
              Text(
                'Fortschritt: '
                '${viewModelState.answeredCount} / ${viewModelState.totalItems}',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: contract.canShowSubmitActions
                    ? () => _submitCorrect(ref)
                    : null,
                child: const Text('Richtig'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: contract.canShowSubmitActions
                    ? () => _submitWrong(ref)
                    : null,
                child: const Text('Falsch'),
              ),
            ],
            if (!contract.isCompleted && viewModelState.canCompleteSession) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _completeIfFinished(ref),
                child: const Text('Session abschließen'),
              ),
            ],
            if (contract.isCompleted) ...[
              const Text('Session abgeschlossen'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: null,
                child: const Text('Weitere Session starten'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _importDefaultWords(WidgetRef ref) async {
    final importAction = onImportDefaultWords;
    final now = nowProvider?.call() ?? DateTime.now();

    if (importAction == null) {
      await ref.read(localDebugImportControllerProvider.future);
      await ref
          .read(localDebugImportControllerProvider.notifier)
          .importDefaultWords(now: now);
      return;
    }

    await importAction(now: now);
  }

  Future<void> _startOrResume(WidgetRef ref) async {
    final now = nowProvider?.call() ?? DateTime.now();
    const mode = LearningMode.adaptive;
    const trainingArea = TrainingArea.all;
    final startAction = onStartOrResume;

    if (startAction != null) {
      await startAction(
        categoryId: categoryId,
        mode: mode,
        trainingArea: trainingArea,
        now: now,
      );
      return;
    }

    await ref
        .read(localLearningControllerProvider.notifier)
        .startOrResume(
          categoryId: categoryId,
          mode: mode,
          trainingArea: trainingArea,
          now: now,
        );
  }

  Future<void> _submitCorrect(WidgetRef ref) async {
    final now = nowProvider?.call() ?? DateTime.now();
    final submitAction = onSubmitCorrect;

    if (submitAction != null) {
      await submitAction(now: now);
      return;
    }

    await ref
        .read(localLearningControllerProvider.notifier)
        .submitCorrect(now: now);
  }

  Future<void> _submitWrong(WidgetRef ref) async {
    final now = nowProvider?.call() ?? DateTime.now();
    final submitAction = onSubmitWrong;

    if (submitAction != null) {
      await submitAction(now: now);
      return;
    }

    await ref
        .read(localLearningControllerProvider.notifier)
        .submitWrong(now: now);
  }

  Future<void> _completeIfFinished(WidgetRef ref) async {
    final now = nowProvider?.call() ?? DateTime.now();
    final completeAction = onCompleteIfFinished;

    if (completeAction != null) {
      await completeAction(now: now);
      return;
    }

    await ref
        .read(localLearningControllerProvider.notifier)
        .completeIfFinished(now: now);
  }

  String _stageLabel(SrsStage stage) {
    return switch (stage) {
      SrsStage.s0 => 'Neu',
      SrsStage.s1 => 'Begonnen',
      SrsStage.s2 => 'Im Aufbau',
      SrsStage.s3 => 'Gefestigt',
      SrsStage.s4 => 'Sicher',
      SrsStage.s5 => 'Langzeit',
    };
  }
}
