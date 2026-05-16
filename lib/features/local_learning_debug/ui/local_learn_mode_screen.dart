import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/adapters/learnmode_card_presenter.dart';
import 'package:talvori/core/local_database/adapters/local_learn_mode_ui_adapter.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/local_database/providers/local_learning_view_model_provider.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/training_area.dart';
import 'package:talvori/features/local_learning_debug/ui/learnmode_card_view.dart';

typedef LocalLearnModeStartCallback =
    Future<void> Function({required String categoryId, required DateTime now});
typedef LocalLearnModeActionCallback =
    Future<void> Function({required DateTime now});

class LocalLearnModeScreen extends ConsumerWidget {
  const LocalLearnModeScreen({
    super.key,
    required this.categoryId,
    this.nowProvider,
    this.onStartOrResume,
    this.onSubmitCorrect,
    this.onSubmitWrong,
    this.onCompleteIfFinished,
  });

  final String categoryId;
  final DateTime Function()? nowProvider;
  final LocalLearnModeStartCallback? onStartOrResume;
  final LocalLearnModeActionCallback? onSubmitCorrect;
  final LocalLearnModeActionCallback? onSubmitWrong;
  final LocalLearnModeActionCallback? onCompleteIfFinished;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelState = ref.watch(localLearningViewModelProvider);
    final uiState = const LocalLearnModeUiAdapter().map(viewModelState);
    final now = nowProvider ?? DateTime.now;
    final controller = ref.read(localLearningControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Lokaler Lernmodus')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _LocalLearnModeScreenBody(
          uiState: uiState,
          onStartOrResume: () async {
            final actionNow = now();
            final callback = onStartOrResume;
            if (callback != null) {
              await callback(categoryId: categoryId, now: actionNow);
              return;
            }

            await controller.startOrResume(
              categoryId: categoryId,
              mode: LearningMode.adaptive,
              trainingArea: TrainingArea.all,
              now: actionNow,
            );
          },
          onSubmitCorrect: () async {
            final actionNow = now();
            final callback = onSubmitCorrect;
            if (callback != null) {
              await callback(now: actionNow);
              return;
            }

            await controller.submitCorrect(now: actionNow);
          },
          onSubmitWrong: () async {
            final actionNow = now();
            final callback = onSubmitWrong;
            if (callback != null) {
              await callback(now: actionNow);
              return;
            }

            await controller.submitWrong(now: actionNow);
          },
          onCompleteIfFinished: () async {
            final actionNow = now();
            final callback = onCompleteIfFinished;
            if (callback != null) {
              await callback(now: actionNow);
              return;
            }

            await controller.completeIfFinished(now: actionNow);
          },
        ),
      ),
    );
  }
}

class _LocalLearnModeScreenBody extends StatelessWidget {
  const _LocalLearnModeScreenBody({
    required this.uiState,
    required this.onStartOrResume,
    required this.onSubmitCorrect,
    required this.onSubmitWrong,
    required this.onCompleteIfFinished,
  });

  final LocalLearnModeUiState uiState;
  final Future<void> Function() onStartOrResume;
  final Future<void> Function() onSubmitCorrect;
  final Future<void> Function() onSubmitWrong;
  final Future<void> Function() onCompleteIfFinished;

  @override
  Widget build(BuildContext context) {
    if (uiState.isLoading) {
      return const Text('Lädt...');
    }

    final errorMessage = uiState.errorMessage;
    if (errorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Fehler'),
          const SizedBox(height: 8),
          Text(errorMessage),
        ],
      );
    }

    if (!uiState.hasCard && !uiState.isCompleted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Keine aktive lokale Session'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onStartOrResume,
            child: const Text('Starten/Fortsetzen'),
          ),
        ],
      );
    }

    if (uiState.isCompleted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Session abgeschlossen'),
          const SizedBox(height: 8),
          Text(uiState.progressLabel),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onCompleteIfFinished,
            child: const Text('Session abschließen'),
          ),
        ],
      );
    }

    final cardState = const LearnModeCardPresenter().map(uiState);
    return LearnModeCardView(
      state: cardState,
      onCorrect: onSubmitCorrect,
      onWrong: onSubmitWrong,
    );
  }
}
