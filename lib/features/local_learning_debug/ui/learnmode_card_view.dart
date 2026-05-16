import 'package:flutter/material.dart';
import 'package:talvori/core/local_database/adapters/learnmode_card_presenter.dart';
import 'package:talvori/features/words/ui/theme/theme.dart';

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

    final theme = Theme.of(context);
    final colors = theme.extension<WordsColors>();
    final cardColor = colors?.cardBg ?? theme.colorScheme.surface;
    final borderColor = theme.colorScheme.outlineVariant.withValues(
      alpha: 0.45,
    );
    final hasMeta = state.stageLabel != null || state.progressLabel.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasMeta)
                  _LearnModeCardMetaRow(
                    stageLabel: state.stageLabel,
                    progressLabel: state.progressLabel,
                  ),
                if (hasMeta) const SizedBox(height: 20),
                if (state.frontText != null)
                  Text(
                    state.frontText!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                if (state.backText != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    state.backText!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.82,
                      ),
                    ),
                  ),
                ],
                if (state.exampleSentence != null || state.notes != null) ...[
                  const SizedBox(height: 22),
                  const Divider(height: 1),
                  const SizedBox(height: 18),
                  if (state.exampleSentence != null)
                    _LearnModeCardDetail(text: state.exampleSentence!),
                  if (state.notes != null) ...[
                    if (state.exampleSentence != null)
                      const SizedBox(height: 10),
                    _LearnModeCardDetail(text: state.notes!),
                  ],
                ],
              ],
            ),
          ),
        ),
        if (state.canSubmitAnswer) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onWrong,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Falsch'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onCorrect,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
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

class _LearnModeCardMetaRow extends StatelessWidget {
  const _LearnModeCardMetaRow({
    required this.stageLabel,
    required this.progressLabel,
  });

  final String? stageLabel;
  final String progressLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        if (stageLabel != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              stageLabel!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        const Spacer(),
        if (progressLabel.isNotEmpty)
          Text(
            progressLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.64),
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _LearnModeCardDetail extends StatelessWidget {
  const _LearnModeCardDetail({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      textAlign: TextAlign.center,
      style: theme.textTheme.bodyLarge?.copyWith(
        height: 1.35,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
      ),
    );
  }
}
