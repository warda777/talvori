import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_review_history_timeline_item.dart';
import 'package:talvori/core/local_database/providers/local_word_detail_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_review_history_provider.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/word_progress.dart';
import 'package:talvori/features/words/ui/screens/local_word_edit_screen.dart';

class LocalWordDetailScreen extends ConsumerWidget {
  const LocalWordDetailScreen({
    super.key,
    required this.wordId,
    required this.categoryId,
    required this.title,
    this.mode = LearningMode.adaptive,
  });

  final String wordId;
  final String categoryId;
  final String title;
  final LearningMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      localWordDetailProvider(
        LocalWordDetailRequest(
          wordId: wordId,
          categoryId: categoryId,
          mode: mode,
        ),
      ),
    );
    final historyAsync = ref.watch(
      localWordReviewHistoryProvider(
        LocalWordReviewHistoryRequest(
          wordId: wordId,
          categoryId: categoryId,
          mode: mode,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF050507),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050507),
        foregroundColor: Colors.white,
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Bearbeiten',
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => LocalWordEditScreen(
                    wordId: wordId,
                    categoryId: categoryId,
                    title: title,
                  ),
                ),
              );

              if (updated == true) {
                ref.invalidate(
                  localWordDetailProvider(
                    LocalWordDetailRequest(
                      wordId: wordId,
                      categoryId: categoryId,
                      mode: mode,
                    ),
                  ),
                );
                ref.invalidate(
                  localWordReviewHistoryProvider(
                    LocalWordReviewHistoryRequest(
                      wordId: wordId,
                      categoryId: categoryId,
                      mode: mode,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const Center(
          child: Text(
            'Lokales Wort konnte nicht geladen werden',
            style: TextStyle(color: Colors.white),
          ),
        ),
        data: (detail) {
          if (detail == null) {
            return const Center(
              child: Text(
                'Lokales Wort nicht gefunden',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _NeonPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.word.term,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      detail.word.translation,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFFA8C7FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _InfoRow(label: 'Kategorie', value: title),
                    if (detail.word.exampleSentence != null) ...[
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Beispiel',
                        value: detail.word.exampleSentence!,
                      ),
                    ],
                    if (detail.word.notes != null) ...[
                      const SizedBox(height: 12),
                      _InfoRow(label: 'Notiz', value: detail.word.notes!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _NeonPanel(
                child: _LearningStatusSection(progress: detail.progress),
              ),
              const SizedBox(height: 18),
              _NeonPanel(
                child: _ReviewHistorySection(historyAsync: historyAsync),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReviewHistorySection extends StatelessWidget {
  const _ReviewHistorySection({required this.historyAsync});

  final AsyncValue<List<LocalReviewHistoryTimelineItem>> historyAsync;

  @override
  Widget build(BuildContext context) {
    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const Text(
        'Lernverlauf konnte nicht geladen werden',
        style: TextStyle(color: Color(0xFF9E9EA6)),
      ),
      data: (items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verlauf',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const Text(
              'Noch kein Lernverlauf vorhanden',
              style: TextStyle(color: Color(0xFF9E9EA6)),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ReviewHistoryTile(item: item),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReviewHistoryTile extends StatelessWidget {
  const _ReviewHistoryTile({required this.item});

  final LocalReviewHistoryTimelineItem item;

  @override
  Widget build(BuildContext context) {
    final color = Color(item.colorValue);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF101014),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _LearningStatusSection._formatDateTime(item.reviewedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9E9EA6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StageBadge(
            sourceStage: item.sourceStage.index,
            targetStage: item.targetStage.index,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _StageBadge extends StatelessWidget {
  const _StageBadge({
    required this.sourceStage,
    required this.targetStage,
    required this.color,
  });

  final int sourceStage;
  final int targetStage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        'S$sourceStage -> S$targetStage',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LearningStatusSection extends StatelessWidget {
  const _LearningStatusSection({required this.progress});

  final WordProgress? progress;

  @override
  Widget build(BuildContext context) {
    final progress = this.progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lernstatus',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        if (progress == null)
          const Text(
            'Noch kein Lernfortschritt',
            style: TextStyle(color: Color(0xFF9E9EA6)),
          )
        else ...[
          _InfoRow(label: 'Merkstufe', value: '${progress.stage.index}'),
          const SizedBox(height: 10),
          _InfoRow(label: 'Richtig-Serie', value: '${progress.passCount}'),
          const SizedBox(height: 10),
          _InfoRow(label: 'Fehler', value: '${progress.wrongCount}'),
          if (progress.lastReviewedAt != null) ...[
            const SizedBox(height: 10),
            _InfoRow(
              label: 'Zuletzt gelernt',
              value: _formatDateTime(progress.lastReviewedAt!),
            ),
          ],
          if (progress.nextDueAt != null) ...[
            const SizedBox(height: 10),
            _InfoRow(
              label: 'Naechste Wiederholung',
              value: _formatDateTime(progress.nextDueAt!),
            ),
          ],
        ],
      ],
    );
  }

  static String _formatDateTime(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');

    return '${twoDigits(value.day)}.${twoDigits(value.month)}.${value.year} '
        '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: const Color(0xFF9E9EA6),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _NeonPanel extends StatelessWidget {
  const _NeonPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF18181C), Color(0xFF0B0B0D)],
        ),
        border: Border.all(color: const Color(0xFF8DBBFF), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x338DBBFF), blurRadius: 18, spreadRadius: 1),
        ],
      ),
      child: child,
    );
  }
}
