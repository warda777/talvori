import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_review_history_timeline_item.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/models/translation_status.dart';
import 'package:talvori/core/local_database/providers/local_translation_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_detail_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_review_history_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/review_answer.dart';
import 'package:talvori/core/srs/models/word_progress.dart';
import 'package:talvori/features/words/ui/screens/local_word_edit_screen.dart';

class LocalWordDetailScreen extends ConsumerStatefulWidget {
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
  ConsumerState<LocalWordDetailScreen> createState() =>
      _LocalWordDetailScreenState();
}

class _LocalWordDetailScreenState extends ConsumerState<LocalWordDetailScreen> {
  bool _isProcessingTranslation = false;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(
      localWordDetailProvider(
        LocalWordDetailRequest(
          wordId: widget.wordId,
          categoryId: widget.categoryId,
          mode: widget.mode,
        ),
      ),
    );
    final historyAsync = ref.watch(
      localWordReviewHistoryProvider(
        LocalWordReviewHistoryRequest(
          wordId: widget.wordId,
          categoryId: widget.categoryId,
          mode: widget.mode,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF050507),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050507),
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Bearbeiten',
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => LocalWordEditScreen(
                    wordId: widget.wordId,
                    categoryId: widget.categoryId,
                    title: widget.title,
                  ),
                ),
              );

              if (updated == true) {
                ref.invalidate(
                  localWordDetailProvider(
                    LocalWordDetailRequest(
                      wordId: widget.wordId,
                      categoryId: widget.categoryId,
                      mode: widget.mode,
                    ),
                  ),
                );
                ref.invalidate(
                  localWordReviewHistoryProvider(
                    LocalWordReviewHistoryRequest(
                      wordId: widget.wordId,
                      categoryId: widget.categoryId,
                      mode: widget.mode,
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
                      _translationDisplayText(detail.word),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFFA8C7FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _InfoRow(label: 'Kategorie', value: widget.title),
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
                child: _TranslationStatusSection(
                  word: detail.word,
                  isLoading: _isProcessingTranslation,
                  onTranslate: _processWordTranslation,
                ),
              ),
              const SizedBox(height: 18),
              _NeonPanel(
                child: _LearningStatusSection(progress: detail.progress),
              ),
              const SizedBox(height: 18),
              _NeonPanel(
                child: _ReviewHistorySection(
                  historyAsync: historyAsync,
                  progress: detail.progress,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _processWordTranslation() async {
    if (_isProcessingTranslation) return;

    setState(() => _isProcessingTranslation = true);
    try {
      final runner = await ref.read(singleWordTranslationRunnerProvider.future);
      final result = await runner(wordId: widget.wordId);
      if (!mounted) return;

      ref.invalidate(
        localWordDetailProvider(
          LocalWordDetailRequest(
            wordId: widget.wordId,
            categoryId: widget.categoryId,
            mode: widget.mode,
          ),
        ),
      );
      ref.invalidate(localWordsForCategoryProvider(widget.categoryId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.translated > 0
                ? 'Übersetzung aktualisiert.'
                : 'Übersetzung konnte nicht abgeschlossen werden.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Übersetzung konnte nicht starten.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessingTranslation = false);
      }
    }
  }
}

String _translationDisplayText(LocalWord word) {
  return word.translation.trim().isEmpty
      ? 'Noch keine Übersetzung'
      : word.translation;
}

class _TranslationStatusSection extends StatelessWidget {
  const _TranslationStatusSection({
    required this.word,
    required this.isLoading,
    required this.onTranslate,
  });

  final LocalWord word;
  final bool isLoading;
  final VoidCallback onTranslate;

  @override
  Widget build(BuildContext context) {
    final data = _TranslationStatusPresentation.fromWord(word);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Übersetzungsstatus',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
                border: Border.all(color: data.color.withValues(alpha: 0.6)),
                boxShadow: [
                  BoxShadow(
                    color: data.color.withValues(alpha: 0.2),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Icon(data.icon, color: data.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    data.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFB8C4D9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (word.translationError?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 10),
                    _InfoRow(
                      label: 'Fehlerhinweis',
                      value: word.translationError!.trim(),
                    ),
                  ],
                  if (word.translationStatus !=
                      TranslationStatus.translated) ...[
                    const SizedBox(height: 14),
                    _SingleWordTranslationButton(
                      status: word.translationStatus,
                      isLoading: isLoading,
                      onPressed: onTranslate,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SingleWordTranslationButton extends StatelessWidget {
  const _SingleWordTranslationButton({
    required this.status,
    required this.isLoading,
    required this.onPressed,
  });

  final TranslationStatus status;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = isLoading
        ? 'Übersetzung läuft...'
        : switch (status) {
            TranslationStatus.failed => 'Erneut übersetzen',
            _ => 'Jetzt übersetzen',
          };

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF0B1218),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF59D7FF), width: 1),
          boxShadow: const [
            BoxShadow(color: Color(0x2259D7FF), blurRadius: 16),
          ],
        ),
        child: TextButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF59D7FF),
                  ),
                )
              : const Icon(Icons.translate, color: Color(0xFF59D7FF)),
          label: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            foregroundColor: Colors.white,
            disabledForegroundColor: const Color(0xFF7F8494),
          ),
        ),
      ),
    );
  }
}

class _TranslationStatusPresentation {
  const _TranslationStatusPresentation({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
  });

  final String title;
  final String description;
  final Color color;
  final IconData icon;

  static _TranslationStatusPresentation fromWord(LocalWord word) {
    return switch (word.translationStatus) {
      TranslationStatus.pending => const _TranslationStatusPresentation(
        title: 'Übersetzung ausstehend',
        description: 'Starte die Übersetzung manuell, sobald du online bist.',
        color: Color(0xFF59D7FF),
        icon: Icons.schedule,
      ),
      TranslationStatus.failed => const _TranslationStatusPresentation(
        title: 'Übersetzung fehlgeschlagen',
        description:
            'Die automatische Übersetzung konnte nicht abgeschlossen werden.',
        color: Color(0xFFFF5F7A),
        icon: Icons.error_outline,
      ),
      TranslationStatus.translated => _TranslationStatusPresentation(
        title: 'Übersetzung verfügbar',
        description: word.translation.trim().isEmpty
            ? 'Noch keine Übersetzung hinterlegt.'
            : 'Die Übersetzung ist verfügbar.',
        color: const Color(0xFF36F58A),
        icon: Icons.check_circle_outline,
      ),
    };
  }
}

class _ReviewHistorySection extends StatelessWidget {
  const _ReviewHistorySection({
    required this.historyAsync,
    required this.progress,
  });

  final AsyncValue<List<LocalReviewHistoryTimelineItem>> historyAsync;
  final WordProgress? progress;

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
          else ...[
            _ReviewHistorySummary(items: items, progress: progress),
            const SizedBox(height: 14),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ReviewHistoryTile(item: item),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewHistorySummary extends StatelessWidget {
  const _ReviewHistorySummary({required this.items, required this.progress});

  final List<LocalReviewHistoryTimelineItem> items;
  final WordProgress? progress;

  @override
  Widget build(BuildContext context) {
    final correctCount = items
        .where((item) => item.answer == ReviewAnswer.correct)
        .length;
    final wrongCount = items
        .where((item) => item.answer == ReviewAnswer.wrong)
        .length;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _SummaryPill(label: 'Insgesamt richtig', value: '$correctCount'),
        _SummaryPill(label: 'Insgesamt falsch', value: '$wrongCount'),
        _SummaryPill(label: 'Reviews gesamt', value: '${items.length}'),
        _SummaryPill(
          label: 'Aktuelle Merkstufe',
          value: progress == null ? '-' : 'S${progress!.stage.index}',
        ),
      ],
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF101014),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2B3C5F), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFF9E9EA6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
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
