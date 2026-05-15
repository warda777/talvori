import 'package:flutter/material.dart';
import 'package:talvori/core/local_database/adapters/learnmode_card_presenter.dart';

class LearnModeCardView extends StatelessWidget {
  const LearnModeCardView({super.key, required this.state});

  final LearnModeCardPresenterState state;

  @override
  Widget build(BuildContext context) {
    if (!state.hasCard) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.frontText != null) Text(state.frontText!),
        if (state.backText != null) ...[
          const SizedBox(height: 8),
          Text(state.backText!),
        ],
        if (state.exampleSentence != null) ...[
          const SizedBox(height: 8),
          Text(state.exampleSentence!),
        ],
        if (state.notes != null) ...[
          const SizedBox(height: 8),
          Text(state.notes!),
        ],
        if (state.stageLabel != null) ...[
          const SizedBox(height: 8),
          Text(state.stageLabel!),
        ],
        const SizedBox(height: 8),
        Text(state.progressLabel),
      ],
    );
  }
}
