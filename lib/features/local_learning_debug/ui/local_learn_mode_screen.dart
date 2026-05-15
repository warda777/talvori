import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/adapters/learnmode_card_presenter.dart';
import 'package:talvori/core/local_database/adapters/local_learn_mode_ui_adapter.dart';
import 'package:talvori/core/local_database/providers/local_learning_view_model_provider.dart';
import 'package:talvori/features/local_learning_debug/ui/learnmode_card_view.dart';

class LocalLearnModeScreen extends ConsumerWidget {
  const LocalLearnModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelState = ref.watch(localLearningViewModelProvider);
    final uiState = const LocalLearnModeUiAdapter().map(viewModelState);

    return Scaffold(
      appBar: AppBar(title: const Text('Lokaler Lernmodus')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _LocalLearnModeScreenBody(uiState: uiState),
      ),
    );
  }
}

class _LocalLearnModeScreenBody extends StatelessWidget {
  const _LocalLearnModeScreenBody({required this.uiState});

  final LocalLearnModeUiState uiState;

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
      return const Text('Keine aktive lokale Session');
    }

    if (uiState.isCompleted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Session abgeschlossen'),
          const SizedBox(height: 8),
          Text(uiState.progressLabel),
        ],
      );
    }

    final cardState = const LearnModeCardPresenter().map(uiState);
    return LearnModeCardView(state: cardState);
  }
}
