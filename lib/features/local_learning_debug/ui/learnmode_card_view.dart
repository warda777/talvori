import 'package:flutter/material.dart';
import 'package:talvori/core/local_database/adapters/learnmode_card_presenter.dart';

class LearnModeCardView extends StatelessWidget {
  const LearnModeCardView({
    super.key,
    required this.state,
    this.onCorrect,
    this.onWrong,
  });

  final LearnModeCardPresenterState state;
  final Future<void> Function()? onCorrect;
  final Future<void> Function()? onWrong;

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
        if (state.canSubmitAnswer) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onWrong,
                  child: const Text('Falsch'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onCorrect,
                  child: const Text('Richtig'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
