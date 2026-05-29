import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/models/translation_status.dart';
import 'package:talvori/core/local_database/providers/local_translation_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/pronunciation/word_pronunciation_provider.dart';
import 'package:talvori/core/ui/talvori_snackbar.dart';
import 'package:talvori/features/words/application/category_vocabulary/category_vocabulary_controller.dart';
import 'package:talvori/features/words/ui/screens/local_word_detail_screen.dart';

enum _LocalWordSortMode {
  termAz('A–Z nach Wort'),
  termZa('Z–A nach Wort'),
  translationAz('A–Z nach Übersetzung'),
  translationZa('Z–A nach Übersetzung');

  const _LocalWordSortMode(this.label);

  final String label;
}

class LocalWordListScreen extends ConsumerStatefulWidget {
  const LocalWordListScreen({
    super.key,
    required this.categoryId,
    required this.title,
  });

  final String categoryId;
  final String title;

  @override
  ConsumerState<LocalWordListScreen> createState() =>
      _LocalWordListScreenState();
}

class _LocalWordListScreenState extends ConsumerState<LocalWordListScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  _LocalWordSortMode _sortMode = _LocalWordSortMode.termAz;
  bool _isProcessingTranslations = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wordsAsync = ref.watch(
      localWordsForCategoryProvider(widget.categoryId),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF050507),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050507),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
      body: wordsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF8DBBFF)),
        ),
        error: (error, stackTrace) => const _LocalWordListEmptyState(
          title: 'Lokale Wörter konnten nicht geladen werden',
          subtitle: 'Bitte versuche es gleich noch einmal.',
        ),
        data: (words) {
          if (words.isEmpty) {
            final source = LocalLearningSource.fromId(widget.categoryId);
            return _LocalWordListEmptyState(
              title: _emptyTitleForSource(source),
              subtitle: _emptySubtitleForSource(source),
            );
          }

          final visibleWords = _sortWords(_filterWords(words));
          final pendingCount = words
              .where(
                (word) => word.translationStatus == TranslationStatus.pending,
              )
              .length;
          final failedCount = words
              .where(
                (word) => word.translationStatus == TranslationStatus.failed,
              )
              .length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: _NeonSearchField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _NeonSortControl(
                  value: _sortMode,
                  onChanged: (mode) {
                    if (mode == null) return;
                    setState(() => _sortMode = mode);
                  },
                ),
              ),
              if (pendingCount + failedCount > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: _TranslationProcessButton(
                    pendingCount: pendingCount,
                    failedCount: failedCount,
                    isLoading: _isProcessingTranslations,
                    onPressed: _processPendingTranslations,
                  ),
                ),
              Expanded(
                child: visibleWords.isEmpty
                    ? const _LocalWordListEmptyState(
                        title: 'Keine passenden Wörter gefunden',
                        subtitle: 'Passe deine Suche an oder lösche sie.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 2, 20, 28),
                        itemCount: visibleWords.length,
                        itemBuilder: (context, index) {
                          final word = visibleWords[index];
                          return _LocalWordCard(
                            word: word,
                            categoryId: widget.categoryId,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LocalWordDetailScreen(
                                    wordId: word.id,
                                    categoryId: word.categoryId,
                                    title: widget.title,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<LocalWord> _filterWords(List<LocalWord> words) {
    final normalizedQuery = _query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return words;
    }

    return words
        .where(
          (word) =>
              word.term.toLowerCase().contains(normalizedQuery) ||
              word.translation.toLowerCase().contains(normalizedQuery),
        )
        .toList(growable: false);
  }

  List<LocalWord> _sortWords(List<LocalWord> words) {
    final sorted = [...words];
    int compareText(String left, String right) {
      return left.toLowerCase().compareTo(right.toLowerCase());
    }

    sorted.sort((left, right) {
      return switch (_sortMode) {
        _LocalWordSortMode.termAz => compareText(left.term, right.term),
        _LocalWordSortMode.termZa => compareText(right.term, left.term),
        _LocalWordSortMode.translationAz => compareText(
          left.translation,
          right.translation,
        ),
        _LocalWordSortMode.translationZa => compareText(
          right.translation,
          left.translation,
        ),
      };
    });

    return sorted;
  }

  Future<void> _processPendingTranslations() async {
    if (_isProcessingTranslations) return;

    setState(() => _isProcessingTranslations = true);
    try {
      final runner = await ref.read(
        pendingAndFailedTranslationRunnerProvider.future,
      );
      final result = await runner(categoryId: widget.categoryId);
      if (!mounted) return;

      ref.invalidate(localWordsForCategoryProvider(widget.categoryId));
      TalvoriSnackBar.show(
        context,
        message: result.failed > 0
            ? 'Übersetzungen verarbeitet: ${result.translated} erfolgreich, ${result.failed} fehlgeschlagen.'
            : 'Übersetzungen verarbeitet: ${result.translated} erfolgreich.',
        type: result.failed > 0
            ? TalvoriSnackBarType.warning
            : TalvoriSnackBarType.success,
      );
    } catch (_) {
      if (!mounted) return;
      TalvoriSnackBar.show(
        context,
        message: 'Übersetzungen konnten nicht verarbeitet werden.',
        type: TalvoriSnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessingTranslations = false);
      }
    }
  }
}

class _NeonSearchField extends StatelessWidget {
  const _NeonSearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _NeonFieldShell(
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        cursorColor: const Color(0xFF8DBBFF),
        decoration: const InputDecoration(
          hintText: 'Suchen',
          hintStyle: TextStyle(
            color: Color(0xFF7F8494),
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(Icons.search, color: Color(0xFF8DBBFF)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _NeonSortControl extends StatelessWidget {
  const _NeonSortControl({required this.value, required this.onChanged});

  final _LocalWordSortMode value;
  final ValueChanged<_LocalWordSortMode?> onChanged;

  @override
  Widget build(BuildContext context) {
    return _NeonFieldShell(
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<_LocalWordSortMode>(
          initialValue: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF101116),
          iconEnabledColor: const Color(0xFF8DBBFF),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          decoration: const InputDecoration(
            labelText: 'Sortierung',
            labelStyle: TextStyle(
              color: Color(0xFF8DBBFF),
              fontWeight: FontWeight.w700,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          items: _LocalWordSortMode.values
              .map(
                (mode) => DropdownMenuItem(
                  value: mode,
                  child: Text(
                    mode.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _NeonFieldShell extends StatelessWidget {
  const _NeonFieldShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C0D12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF8DBBFF), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x223A8DFF), blurRadius: 18, spreadRadius: 1),
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TranslationProcessButton extends StatelessWidget {
  const _TranslationProcessButton({
    required this.pendingCount,
    required this.failedCount,
    required this.isLoading,
    required this.onPressed,
  });

  final int pendingCount;
  final int failedCount;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF0B1218),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF59D7FF), width: 1),
          boxShadow: const [
            BoxShadow(color: Color(0x2259D7FF), blurRadius: 18),
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
            _label,
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

  String get _label {
    if (isLoading) {
      return 'Übersetzungen laufen...';
    }
    if (failedCount == 0) {
      return 'Ausstehende Übersetzungen starten ($pendingCount)';
    }

    final total = pendingCount + failedCount;
    return 'Übersetzungen starten / erneut versuchen ($total)';
  }
}

class _LocalWordCard extends ConsumerWidget {
  const _LocalWordCard({
    required this.word,
    required this.categoryId,
    required this.onTap,
  });

  final LocalWord word;
  final String categoryId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationText = word.translation.trim().isEmpty
        ? 'Noch keine Übersetzung'
        : word.translation;
    final statusBadge = _TranslationStatusBadgeData.fromStatus(
      word.translationStatus,
    );
    final isDisabled = word.isDisabledForCategory;
    final isKnown = word.isKnownForCategory;
    final isReviewedForLearning =
        categoryId == LocalLearningSource.reviewedForLearning.id;
    final isInactive = isDisabled || isKnown;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: isInactive
                  ? const Color(0xFF0A0A0D)
                  : const Color(0xFF0E0F14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isKnown
                    ? const Color(0xFF91F7B5)
                    : isDisabled
                    ? const Color(0xFF555A66)
                    : const Color(0xFF2F557D),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F8DBBFF),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: Offset(0, 8),
                ),
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word.term,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        translationText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFB8C4D9),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                      ),
                      if (statusBadge != null) ...[
                        const SizedBox(height: 10),
                        _TranslationStatusBadge(data: statusBadge),
                      ],
                      if (isKnown) ...[
                        const SizedBox(height: 10),
                        const _WordKnownBadge(),
                      ],
                      if (isDisabled && !isKnown) ...[
                        const SizedBox(height: 10),
                        const _WordDisabledBadge(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFF101827),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF8DBBFF),
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Color(0x338DBBFF), blurRadius: 12),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFFBFD5FF),
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    IconButton(
                      key: ValueKey('local-word-list-active-toggle-${word.id}'),
                      tooltip: isKnown
                          ? 'Wieder lernen'
                          : isReviewedForLearning
                          ? 'Wieder prüfen'
                          : isDisabled
                          ? 'Für Lernmodus aktivieren'
                          : 'Im Lernmodus pausieren',
                      onPressed: () => _toggleActive(context, ref),
                      icon: Icon(
                        isKnown
                            ? Icons.school_rounded
                            : isReviewedForLearning
                            ? Icons.restart_alt_rounded
                            : isDisabled
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: isKnown
                            ? const Color(0xFF91F7B5)
                            : isReviewedForLearning
                            ? const Color(0xFF82EAFF)
                            : isDisabled
                            ? const Color(0xFFFFD166)
                            : const Color(0xFF91F7B5),
                        size: 22,
                      ),
                      style: IconButton.styleFrom(
                        fixedSize: const Size(38, 38),
                        backgroundColor: const Color(0xFF0B1820),
                        side: BorderSide(
                          color: isKnown
                              ? const Color(0xFF91F7B5)
                              : isReviewedForLearning
                              ? const Color(0xFF82EAFF)
                              : isDisabled
                              ? const Color(0xFFFFD166)
                              : const Color(0xFF91F7B5),
                          width: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    IconButton(
                      key: ValueKey('local-word-list-pronunciation-${word.id}'),
                      tooltip: 'Wort aussprechen',
                      onPressed: () => _speakWord(context, ref, word),
                      icon: const Icon(
                        Icons.volume_up_rounded,
                        color: Color(0xFFB8FFF6),
                        size: 22,
                      ),
                      style: IconButton.styleFrom(
                        fixedSize: const Size(38, 38),
                        backgroundColor: const Color(0xFF0B1820),
                        side: const BorderSide(
                          color: Color(0xFF59D7FF),
                          width: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleActive(BuildContext context, WidgetRef ref) async {
    try {
      final controller = ref.read(
        categoryVocabularyControllerProvider.notifier,
      );
      if (word.isKnownForCategory) {
        if (categoryId == LocalLearningSource.knownWords.id) {
          await controller.restoreKnownEverywhere(word: word);
        } else {
          await controller.restoreKnown(categoryId: categoryId, word: word);
        }
      } else if (categoryId == LocalLearningSource.reviewedForLearning.id) {
        await controller.restoreReviewedForLearningEverywhere(word: word);
      } else {
        final disabled = !word.isDisabledForCategory;
        await controller.setDisabled(
          categoryId: categoryId,
          word: word,
          disabled: disabled,
        );
      }
      if (!context.mounted) return;
      TalvoriSnackBar.show(
        context,
        message: categoryId == LocalLearningSource.reviewedForLearning.id
            ? 'Wort ist wieder im Prüfmodus offen.'
            : word.isKnownForCategory
            ? 'Wort ist wieder im Lernmodus aktiv.'
            : !word.isDisabledForCategory
            ? 'Wort im Lernmodus pausiert.'
            : 'Wort ist wieder im Lernmodus aktiv.',
        type: TalvoriSnackBarType.success,
      );
    } catch (_) {
      if (!context.mounted) return;
      TalvoriSnackBar.show(
        context,
        message: 'Status konnte nicht geändert werden.',
        type: TalvoriSnackBarType.error,
      );
    }
  }

  Future<void> _speakWord(
    BuildContext context,
    WidgetRef ref,
    LocalWord word,
  ) async {
    HapticFeedback.selectionClick();
    final result = await ref
        .read(wordPronunciationServiceProvider)
        .speakWord(word.term, languageCode: word.sourceLanguage);
    if (!context.mounted || result.isSuccess) return;
    TalvoriSnackBar.show(
      context,
      message: result.message ?? 'Aussprache nicht verfügbar.',
      type: TalvoriSnackBarType.warning,
    );
  }
}

class _WordKnownBadge extends StatelessWidget {
  const _WordKnownBadge();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 120.0;
        return SizedBox(
          width: maxWidth,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF91F7B5).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFF91F7B5).withValues(alpha: 0.55),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.school_rounded, color: Color(0xFF91F7B5), size: 14),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Kenn ich',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF91F7B5),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
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
}

class _WordDisabledBadge extends StatelessWidget {
  const _WordDisabledBadge();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 120.0;
        return SizedBox(
          width: maxWidth,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD166).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFFFFD166).withValues(alpha: 0.55),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.pause_circle_outline,
                  color: Color(0xFFFFD166),
                  size: 14,
                ),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Pausiert',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFFFFD166),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
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
}

class _TranslationStatusBadgeData {
  const _TranslationStatusBadgeData({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  static _TranslationStatusBadgeData? fromStatus(TranslationStatus status) {
    return switch (status) {
      TranslationStatus.pending => const _TranslationStatusBadgeData(
        label: 'Übersetzung ausstehend',
        color: Color(0xFF59D7FF),
        icon: Icons.schedule,
      ),
      TranslationStatus.failed => const _TranslationStatusBadgeData(
        label: 'Übersetzung fehlgeschlagen',
        color: Color(0xFFFF5F7A),
        icon: Icons.error_outline,
      ),
      TranslationStatus.translated => null,
    };
  }
}

class _TranslationStatusBadge extends StatelessWidget {
  const _TranslationStatusBadge({required this.data});

  final _TranslationStatusBadgeData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: data.color.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(color: data.color.withValues(alpha: 0.18), blurRadius: 12),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, color: data.color, size: 14),
          const SizedBox(width: 6),
          Text(
            data.label,
            style: TextStyle(
              color: data.color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

String _emptyTitleForSource(LocalLearningSource? source) {
  switch (source) {
    case LocalLearningSource.favorites:
      return 'Noch keine Favoriten';
    case LocalLearningSource.knownWords:
      return 'Noch keine bekannten Wörter';
    case LocalLearningSource.reviewedForLearning:
      return 'Noch keine Wörter zum Weiterlernen';
    case LocalLearningSource.myMix:
      return 'Noch kein Mix verfügbar';
    case LocalLearningSource.allWords:
    case LocalLearningSource.myWords:
    case null:
      return 'Noch keine Wörter';
  }
}

String _emptySubtitleForSource(LocalLearningSource? source) {
  switch (source) {
    case LocalLearningSource.favorites:
      return 'Markiere lokale Wörter als Favorit, damit sie hier erscheinen.';
    case LocalLearningSource.knownWords:
      return 'Bekannte Wörter erscheinen hier, sobald sie lokal gelernt sind.';
    case LocalLearningSource.reviewedForLearning:
      return 'Wörter erscheinen hier, sobald du sie in „Wörter prüfen“ weiterlernen lässt.';
    case LocalLearningSource.myMix:
      return 'Füge Favoriten hinzu oder importiere weitere Wörter.';
    case LocalLearningSource.allWords:
      return 'Importierte und lokale Wörter erscheinen hier.';
    case LocalLearningSource.myWords:
    case null:
      return 'Geteilte Wörter erscheinen hier.';
  }
}

class _LocalWordListEmptyState extends StatelessWidget {
  const _LocalWordListEmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0D12),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF2F557D), width: 1),
            boxShadow: const [
              BoxShadow(color: Color(0x223A8DFF), blurRadius: 22),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_stories_outlined,
                color: Color(0xFF8DBBFF),
                size: 30,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF9E9EA6),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
