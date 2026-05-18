import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_database/models/local_review_visual_feedback.dart';
import '../../../../core/local_database/models/local_stage_inspector_item.dart';
import '../../../../core/local_database/providers/local_stage_adjustment_controller_provider.dart';
import '../../../../core/local_database/providers/local_stage_inspector_provider.dart';
import '../../../../core/srs/models/learning_mode.dart';
import '../../../../core/srs/models/srs_stage.dart';

Future<void> showLocalStageInspectorSheet({
  required BuildContext context,
  required String categoryId,
  required LearningMode mode,
  required SrsStage stage,
  String? categoryLabel,
  String? modeLabel,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => LocalStageInspectorSheet(
      categoryId: categoryId,
      mode: mode,
      stage: stage,
      categoryLabel: categoryLabel,
      modeLabel: modeLabel,
    ),
  );
}

class LocalStageInspectorSheet extends ConsumerWidget {
  const LocalStageInspectorSheet({
    super.key,
    required this.categoryId,
    required this.mode,
    required this.stage,
    this.categoryLabel,
    this.modeLabel,
  });

  final String categoryId;
  final LearningMode mode;
  final SrsStage stage;
  final String? categoryLabel;
  final String? modeLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = LocalStageInspectorRequest(
      categoryId: categoryId,
      mode: mode,
      stage: stage,
    );
    final itemsAsync = ref.watch(localStageInspectorProvider(request));

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.42,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF08080A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: Color(0xFF8DBBFF), width: 1.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x553A8DFF),
                blurRadius: 28,
                spreadRadius: 1,
              ),
            ],
          ),
          child: itemsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF8DBBFF)),
            ),
            error: (error, _) => Center(
              child: Text(
                'Merkstufe konnte nicht geladen werden',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
            data: (items) => ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                _Handle(),
                const SizedBox(height: 16),
                _Header(
                  stage: stage,
                  count: items.length,
                  categoryLabel: categoryLabel,
                  modeLabel: modeLabel ?? _modeLabel(mode),
                ),
                const SizedBox(height: 18),
                const _Legend(),
                const SizedBox(height: 18),
                if (items.isEmpty)
                  const _EmptyState()
                else
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _WordStageRow(
                        item: item,
                        onDemoteTo: (targetStage) async {
                          await ref
                              .read(localStageAdjustmentControllerProvider)
                              .demoteWordToStage(
                                wordId: item.wordId,
                                categoryId: item.categoryId,
                                mode: item.mode,
                                targetStage: targetStage,
                                now: DateTime.now(),
                              );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _modeLabel(LearningMode mode) {
    return switch (mode) {
      LearningMode.time => 'Zeitplan',
      LearningMode.adaptive => 'Limitlos',
      LearningMode.hybrid => 'Kombination',
    };
  }
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.stage,
    required this.count,
    this.categoryLabel,
    this.modeLabel,
  });

  final SrsStage stage;
  final int count;
  final String? categoryLabel;
  final String? modeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Merkstufe ${stage.index}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _CountPill(count: count),
          ],
        ),
        if (categoryLabel != null || modeLabel != null) ...[
          const SizedBox(height: 6),
          Text(
            [
              if (categoryLabel != null) categoryLabel,
              if (modeLabel != null) modeLabel,
            ].join(' · '),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF9E9EA6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0xFF101116),
        border: Border.all(color: const Color(0xFF8DBBFF), width: 1),
      ),
      child: Text(
        '$count Wörter',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: const [
        _LegendChip(color: Color(0xFF36F58A), label: 'hochgestuft'),
        _LegendChip(color: Color(0xFFFF4B6E), label: 'falsch/zurück'),
        _LegendChip(color: Color(0xFF5DDCFF), label: '1. Wiederholung'),
        _LegendChip(color: Color(0xFFB36BFF), label: '2. Wiederholung'),
        _LegendChip(color: Color(0xFFFFB84A), label: '3. Wiederholung'),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF101116),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.72), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _WordStageRow extends StatelessWidget {
  const _WordStageRow({required this.item, required this.onDemoteTo});

  final LocalStageInspectorItem item;
  final ValueChanged<SrsStage> onDemoteTo;

  @override
  Widget build(BuildContext context) {
    final feedback = item.lastFeedback;
    final badgeColor = feedback == null
        ? const Color(0xFF34343A)
        : _feedbackColor(feedback);
    final repeatIndex =
        feedback?.outcomeType == LocalReviewOutcomeType.repeatedSameStage
        ? feedback!.repeatIndex.clamp(1, 3)
        : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101116),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF34343A), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusBadge(color: badgeColor, label: repeatIndex?.toString()),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.term,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.translation,
                  style: const TextStyle(
                    color: Color(0xFFB9BAC4),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'S${item.currentStage.index} · pass ${item.passCount} · falsch ${item.wrongCount}'
                  '${feedback == null ? ' · Noch kein Lernfortschritt' : ' · ${_feedbackLabel(feedback)}'}',
                  style: const TextStyle(
                    color: Color(0xFF8D8E98),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (item.currentStage.index > 0)
            PopupMenuButton<SrsStage>(
              tooltip: 'Zurückstufen',
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              color: const Color(0xFF15161C),
              onSelected: onDemoteTo,
              itemBuilder: (context) {
                return SrsStage.values
                    .where((stage) => stage.index < item.currentStage.index)
                    .map(
                      (stage) => PopupMenuItem<SrsStage>(
                        value: stage,
                        child: Text(
                          'Auf S${stage.index} zurückstufen',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(growable: false);
              },
            ),
        ],
      ),
    );
  }

  static Color _feedbackColor(LocalReviewVisualFeedback feedback) {
    return switch (feedback.outcomeType) {
      LocalReviewOutcomeType.promoted => const Color(0xFF36F58A),
      LocalReviewOutcomeType.demoted ||
      LocalReviewOutcomeType.unchangedWrong => const Color(0xFFFF4B6E),
      LocalReviewOutcomeType.repeatedSameStage => switch (feedback.repeatIndex
          .clamp(1, 3)) {
        1 => const Color(0xFF5DDCFF),
        2 => const Color(0xFFB36BFF),
        _ => const Color(0xFFFFB84A),
      },
    };
  }

  static String _feedbackLabel(LocalReviewVisualFeedback feedback) {
    return switch (feedback.outcomeType) {
      LocalReviewOutcomeType.promoted => 'hochgestuft',
      LocalReviewOutcomeType.demoted => 'zurückgestuft',
      LocalReviewOutcomeType.unchangedWrong => 'falsch',
      LocalReviewOutcomeType.repeatedSameStage =>
        '${feedback.repeatIndex}. Wiederholung',
    };
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.color, this.label});

  final Color color;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.4),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.28), blurRadius: 12),
        ],
      ),
      child: label == null
          ? const SizedBox.shrink()
          : Text(
              label!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF101116),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF34343A), width: 1),
      ),
      child: const Text(
        'Keine Wörter in dieser Merkstufe',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFFB9BAC4), fontWeight: FontWeight.w600),
      ),
    );
  }
}
