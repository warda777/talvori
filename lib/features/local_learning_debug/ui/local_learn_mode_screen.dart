import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/adapters/learnmode_card_presenter.dart';
import 'package:talvori/core/local_database/adapters/local_learn_mode_ui_adapter.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/local_database/providers/local_learning_view_model_provider.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/training_area.dart';
import 'package:talvori/features/local_learning_debug/ui/learnmode_card_view.dart';
import 'package:talvori/features/local_learning_debug/ui/local_learn_mode_action_bar.dart';
import 'package:talvori/features/local_learning_debug/ui/local_learn_mode_header.dart';
import 'package:talvori/features/local_learning_debug/ui/local_stage_panel.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import 'package:talvori/features/words/ui/theme/theme.dart';

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
    final theme = Theme.of(context);
    final colors = theme.extension<WordsColors>();
    final backgroundColor = colors?.surfaceBg ?? const Color(0xFF08080A);
    Future<void> startOrResume() async {
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
    }

    Future<void> submitCorrect() async {
      final actionNow = now();
      final callback = onSubmitCorrect;
      if (callback != null) {
        await callback(now: actionNow);
        return;
      }

      await controller.submitCorrect(now: actionNow);
    }

    Future<void> submitWrong() async {
      final actionNow = now();
      final callback = onSubmitWrong;
      if (callback != null) {
        await callback(now: actionNow);
        return;
      }

      await controller.submitWrong(now: actionNow);
    }

    Future<void> completeIfFinished() async {
      final actionNow = now();
      final callback = onCompleteIfFinished;
      if (callback != null) {
        await callback(now: actionNow);
        return;
      }

      await controller.completeIfFinished(now: actionNow);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LocalLearnModeHeader(
              categoryId: categoryId,
              modeLabel: 'Intensiv lernen',
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: WordsUIConstants.screenPadding,
                  child: _LocalLearnModeScreenBody(
                    uiState: uiState,
                    onStartOrResume: startOrResume,
                    onSubmitCorrect: submitCorrect,
                    onSubmitWrong: submitWrong,
                    onCompleteIfFinished: completeIfFinished,
                  ),
                ),
              ),
            ),
            LocalStagePanel(currentStage: uiState.currentStage),
            const SizedBox(height: WordsUIConstants.sectionSpacing),
            LocalLearnModeActionBar(
              showAnswerActions: uiState.canSubmitAnswer,
              showStartAction: !uiState.hasCard && !uiState.isCompleted,
              showCompleteAction: uiState.isCompleted,
              onStartOrResume: startOrResume,
              onCorrect: submitCorrect,
              onWrong: submitWrong,
              onCompleteIfFinished: completeIfFinished,
            ),
          ],
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
      return const _LocalLearnModeMessageCard(child: Text('Lädt...'));
    }

    final errorMessage = uiState.errorMessage;
    if (errorMessage != null) {
      return _LocalLearnModeMessageCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Fehler'),
            const SizedBox(height: 8),
            Text(errorMessage),
          ],
        ),
      );
    }

    if (!uiState.hasCard && !uiState.isCompleted) {
      return const _LocalLearnModeMessageCard(
        child: Text('Keine aktive lokale Session', textAlign: TextAlign.center),
      );
    }

    if (uiState.isCompleted) {
      return _LocalLearnModeMessageCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Session abgeschlossen', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(uiState.progressLabel, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    final cardState = const LearnModeCardPresenter().map(uiState);
    return LearnModeCardView(
      state: cardState,
      onCorrect: onSubmitCorrect,
      onWrong: onSubmitWrong,
      showActions: false,
    );
  }
}

class _LocalLearnModeMessageCard extends StatelessWidget {
  const _LocalLearnModeMessageCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<WordsColors>();
    final cardColor = colors?.cardBg ?? const Color(0xFF151518);
    final size = MediaQuery.sizeOf(context);

    return Center(
      child: Container(
        width: size.width * 0.78,
        constraints: BoxConstraints(
          minHeight: size.height * 0.34,
          maxWidth: 560,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(WordsUIConstants.borderRadius),
          border: Border.all(
            color: const Color(0xFFB16CFF).withValues(alpha: 0.48),
            width: 1.5,
          ),
          boxShadow: [
            ...WordsUIConstants.cardShadow,
            BoxShadow(
              color: const Color(0xFFB16CFF).withValues(alpha: 0.22),
              blurRadius: 72,
              spreadRadius: 18,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: DefaultTextStyle.merge(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
