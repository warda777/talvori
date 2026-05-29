import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/features/words/application/local_known_review_controller.dart';
import 'package:talvori/features/words/ui/screens/local_word_list_screen.dart';
import 'package:talvori/features/words/ui/widgets/category_wheel.dart';

class LocalKnownReviewScreen extends ConsumerWidget {
  const LocalKnownReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(localKnownReviewControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: stateAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF5DDCFF)),
          ),
          error: (_, _) => const _ReviewEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Wörter konnten nicht geladen werden',
            subtitle: 'Bitte versuche es gleich noch einmal.',
          ),
          data: (state) => _LocalVocabSortBody(state: state),
        ),
      ),
    );
  }
}

class _LocalVocabSortBody extends ConsumerWidget {
  const _LocalVocabSortBody({required this.state});

  final LocalKnownReviewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(localKnownReviewControllerProvider.notifier);
    final selectedCategoryIndex = state.categories.indexWhere(
      (category) => category.id == state.selectedCategoryId,
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF07101A), Color(0xFF02050A)],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Wörter prüfen',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Kennst du sie schon?',
                      style: TextStyle(
                        color: Color(0xFF82EAFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF101722),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                state.source != LocalKnownReviewSource.wordWorlds ||
                    state.categories.isEmpty
                ? Center(
                    child: _ReviewEmptyState(
                      icon: state.source == LocalKnownReviewSource.wordWorlds
                          ? Icons.verified_rounded
                          : Icons.tune_rounded,
                      title: state.source == LocalKnownReviewSource.wordWorlds
                          ? 'Keine aktiven Wörter zum Prüfen.'
                          : '${state.source.label} ist vorbereitet.',
                      subtitle:
                          state.source == LocalKnownReviewSource.wordWorlds
                          ? 'Sobald eine Wortwelt lernbare Wörter enthält, erscheint sie hier.'
                          : 'Diese lokale Quelle bekommt später eigene Review-Daten. Wortwelten funktionieren bereits lokal.',
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final centerY = constraints.maxHeight / 2;
                      final lineTop = centerY;

                      return Stack(
                        key: const Key('local-known-review-vocab-sort-layout'),
                        children: [
                          Positioned(
                            top: lineTop - 48,
                            left: 34,
                            child: IgnorePointer(
                              child: Icon(
                                Icons.arrow_upward_rounded,
                                size: 20,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                          Positioned(
                            top: lineTop - 24,
                            left: 16,
                            right: 16,
                            height: 48,
                            child: IgnorePointer(
                              child: Container(
                                key: const Key(
                                  'local-known-review-overlay-counter',
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF5DDCFF,
                                    ).withValues(alpha: 0.8),
                                    width: 1.4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF5DDCFF,
                                      ).withValues(alpha: 0.18),
                                      blurRadius: 24,
                                      spreadRadius: -4,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                child: state.isCompleted
                                    ? const Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Alles geprüft.',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Icon(
                                            Icons.done_all_rounded,
                                            color: Color(0xFF82EAFF),
                                            size: 22,
                                          ),
                                        ],
                                      )
                                    : Text(
                                        '${state.remainingUnreviewedCountForCurrentCategory}',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: lineTop + 28,
                            left: 34,
                            child: IgnorePointer(
                              child: Icon(
                                Icons.arrow_downward_rounded,
                                size: 20,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                          if (state.words.isEmpty || state.isCompleted)
                            Positioned(
                              top: lineTop + 64,
                              left: 52,
                              right: 52,
                              child: const _WheelEmptyMessage(),
                            )
                          else
                            Positioned(
                              top: lineTop - 210,
                              left: 0,
                              right: 0,
                              height: 420,
                              child: _LocalWordDecisionWheel(
                                key: const Key('local-known-review-word-wheel'),
                                words: state.words,
                                selectedIndex: state.currentIndex,
                                onCenterChange: controller.setCurrentWord,
                                onCompleted:
                                    controller.completeCurrentCategoryReview,
                                onCrossUp: (word) {
                                  controller.markKeepLearning(word);
                                },
                                onCrossDown: (word) {
                                  controller.unmarkKeepLearning(word);
                                },
                              ),
                            ),
                          Positioned(
                            top: lineTop - 190,
                            left: 20,
                            child: _CounterLinkButton(
                              key: const Key(
                                'local-known-review-keep-learning-button',
                              ),
                              label: 'Noch lernen',
                              value: state.keepLearningCount,
                              labelColor: const Color(0xFF82EAFF),
                              icon: Icons.school_rounded,
                              valueKey: const Key(
                                'local-known-review-keep-learning-count',
                              ),
                              onTap: () => _openFilterList(
                                context,
                                controller,
                                LocalLearningSource.reviewedForLearning,
                              ),
                            ),
                          ),
                          Positioned(
                            top: lineTop + 150,
                            left: 20,
                            child: _CounterLinkButton(
                              key: const Key('local-known-review-known-button'),
                              label: 'Kenn ich',
                              value: state.knownCount,
                              labelColor: const Color(0xFFB36BFF),
                              icon: Icons.verified_rounded,
                              valueKey: const Key(
                                'local-known-review-known-count',
                              ),
                              onTap: () => _openFilterList(
                                context,
                                controller,
                                LocalLearningSource.knownWords,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  if (state.categories.isNotEmpty &&
                      state.source == LocalKnownReviewSource.wordWorlds)
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: _IconCircleButton(
                            key: const Key(
                              'local-known-review-reset-category-button',
                            ),
                            icon: Icons.restore_rounded,
                            color: const Color(0xFFFFD166),
                            enabled: state.selectedCategoryId != null,
                            onTap: () =>
                                _confirmResetCategory(context, controller),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: CategoryWheel(
                              key: const Key(
                                'local-known-review-category-wheel',
                              ),
                              categories: state.categories
                                  .map((category) => category.name)
                                  .toList(growable: false),
                              completed: state.categories
                                  .map((category) => category.isCompleted)
                                  .toList(growable: false),
                              initialIndex: selectedCategoryIndex < 0
                                  ? 0
                                  : selectedCategoryIndex,
                              activeStrokeColor: const Color(0xFF5DDCFF),
                              activeFillColor: const Color(0xFF08121F),
                              activeTextColor: Colors.white,
                              onChanged: (index, _) {
                                controller.selectCategory(
                                  state.categories[index],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: _SourceModeButton(
                          source: state.source,
                          onSelected: controller.setReviewSource,
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _IconCircleButton(
                              key: const Key('local-known-review-undo-button'),
                              icon: Icons.undo_rounded,
                              color: const Color(0xFF82EAFF),
                              enabled: state.canUndo,
                              onTap: controller.undoLastKnown,
                            ),
                            const SizedBox(width: 12),
                            _IconCircleButton(
                              key: const Key(
                                'local-known-review-mark-known-button',
                              ),
                              icon: Icons.add_rounded,
                              color: const Color(0xFFB36BFF),
                              enabled:
                                  !state.isProcessing &&
                                  state.currentWord != null &&
                                  state.source ==
                                      LocalKnownReviewSource.wordWorlds,
                              onTap: controller.markCurrentKnown,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmResetCategory(
    BuildContext context,
    LocalKnownReviewController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF07101A),
        title: const Text(
          'Kategorie zurücksetzen?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Alle Prüfmarkierungen dieser Wortwelt werden entfernt. Wörter, die du als „Kenn ich“ markiert hast, werden wieder aktiv.',
          style: TextStyle(
            color: Color(0xFFCFE8FF),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Zurücksetzen'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.resetSelectedCategoryReview();
    }
  }

  Future<void> _openFilterList(
    BuildContext context,
    LocalKnownReviewController controller,
    LocalLearningSource source,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: 'local-word-list-${source.wordHubKey}'),
        builder: (_) =>
            LocalWordListScreen(categoryId: source.id, title: source.label),
      ),
    );
    await controller.refreshCurrentCategory();
  }
}

class _LocalWordDecisionWheel extends StatefulWidget {
  const _LocalWordDecisionWheel({
    super.key,
    required this.words,
    required this.selectedIndex,
    required this.onCenterChange,
    required this.onCompleted,
    required this.onCrossUp,
    required this.onCrossDown,
  });

  final List<LocalWord> words;
  final int selectedIndex;
  final ValueChanged<LocalWord> onCenterChange;
  final VoidCallback onCompleted;
  final ValueChanged<LocalWord> onCrossUp;
  final ValueChanged<LocalWord> onCrossDown;

  @override
  State<_LocalWordDecisionWheel> createState() =>
      _LocalWordDecisionWheelState();
}

class _LocalWordDecisionWheelState extends State<_LocalWordDecisionWheel> {
  late FixedExtentScrollController _controller;
  late int _center;
  final Map<String, bool> _wasAboveCenter = {};

  @override
  void initState() {
    super.initState();
    _center = widget.selectedIndex.clamp(0, _lastIndex);
    _controller = FixedExtentScrollController(initialItem: _center);
    _resetAboveCenterMap();
  }

  @override
  void didUpdateWidget(covariant _LocalWordDecisionWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wordsChanged =
        _wordSignature(widget.words) != _wordSignature(oldWidget.words);
    if (wordsChanged) {
      _center = widget.selectedIndex.clamp(0, _lastIndex);
      _resetAboveCenterMap();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.words.isNotEmpty) {
          _controller.jumpToItem(_center);
        }
      });
      return;
    }

    final selectedIndex = widget.selectedIndex.clamp(0, _lastIndex);
    if (selectedIndex != _center) {
      _center = selectedIndex;
      _resetAboveCenterMap();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.words.isNotEmpty) {
          _controller.jumpToItem(_center);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _lastIndex => widget.words.length.clamp(0, 1 << 30);

  String _wordSignature(List<LocalWord> words) {
    return words.map((word) => word.id).join('|');
  }

  void _resetAboveCenterMap() {
    _wasAboveCenter
      ..clear()
      ..addEntries([
        for (var i = 0; i < widget.words.length; i++)
          MapEntry(widget.words[i].id, i < _center),
      ]);
  }

  void _syncCenter(int rawIndex) {
    if (widget.words.isEmpty) return;
    final index = rawIndex.clamp(0, _lastIndex);
    if (index == _center) return;

    _center = index;
    HapticFeedback.selectionClick();
    if (index < widget.words.length) {
      widget.onCenterChange(widget.words[index]);
    } else {
      widget.onCompleted();
    }
    for (var i = 0; i < widget.words.length; i++) {
      final word = widget.words[i];
      final nowAbove = i < _center;
      final prevAbove = _wasAboveCenter[word.id] ?? false;
      if (!prevAbove && nowAbove) {
        widget.onCrossUp(word);
      } else if (prevAbove && !nowAbove) {
        widget.onCrossDown(word);
      }
      _wasAboveCenter[word.id] = nowAbove;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.words;
    if (items.isEmpty) return const SizedBox.shrink();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        if (metrics is FixedExtentMetrics) {
          _syncCenter(metrics.itemIndex);
        }
        return false;
      },
      child: ListWheelScrollView.useDelegate(
        controller: _controller,
        physics: const FixedExtentScrollPhysics(
          parent: BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
        ),
        itemExtent: 42,
        perspective: 0.002,
        diameterRatio: 2.2,
        onSelectedItemChanged: _syncCenter,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: items.length + 1,
          builder: (context, index) {
            if (index == items.length) {
              return const SizedBox.shrink();
            }
            final passedUp = index < _center;
            return LayoutBuilder(
              builder: (context, constraints) {
                const numberAreaWidth = 102.0;
                const rightPadding = 34.0;
                final maxWidth =
                    constraints.maxWidth - numberAreaWidth - rightPadding;

                return Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: rightPadding),
                    child: SizedBox(
                      width: maxWidth,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          items[index].term,
                          key: Key('local-known-review-wheel-word-$index'),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: index == _center ? 24 : 20,
                            fontWeight: index == _center
                                ? FontWeight.w800
                                : FontWeight.w700,
                            color: index == _center
                                ? const Color(0xFFB8FFF6)
                                : passedUp
                                ? const Color(
                                    0xFFB36BFF,
                                  ).withValues(alpha: 0.82)
                                : const Color(
                                    0xFFCFE8FF,
                                  ).withValues(alpha: 0.82),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SourceModeButton extends StatelessWidget {
  const _SourceModeButton({required this.source, required this.onSelected});

  final LocalKnownReviewSource source;
  final ValueChanged<LocalKnownReviewSource> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<LocalKnownReviewSource>(
      key: const Key('local-known-review-source-menu'),
      tooltip: 'Quelle wechseln',
      onSelected: onSelected,
      color: const Color(0xFF07101A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: const Color(0xFF5DDCFF).withValues(alpha: 0.7)),
      ),
      itemBuilder: (context) => LocalKnownReviewSource.values
          .map(
            (item) => PopupMenuItem<LocalKnownReviewSource>(
              value: item,
              child: Text(
                item.label,
                style: TextStyle(
                  color: item == source
                      ? const Color(0xFF82EAFF)
                      : Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          )
          .toList(growable: false),
      child: Container(
        constraints: const BoxConstraints(minWidth: 142),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF08121F),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF5DDCFF), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5DDCFF).withValues(alpha: 0.16),
              blurRadius: 22,
              spreadRadius: -5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune_rounded, color: Color(0xFF82EAFF), size: 18),
            const SizedBox(width: 8),
            Text(
              source.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterLinkButton extends StatelessWidget {
  const _CounterLinkButton({
    super.key,
    required this.label,
    required this.value,
    required this.labelColor,
    required this.icon,
    required this.valueKey,
    required this.onTap,
  });

  final String label;
  final int value;
  final Color labelColor;
  final IconData icon;
  final Key valueKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formattedValue = _formatGermanInt(value);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 146,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF07101A).withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: labelColor.withValues(alpha: 0.78)),
            boxShadow: [
              BoxShadow(
                color: labelColor.withValues(alpha: 0.18),
                blurRadius: 20,
                spreadRadius: -6,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: labelColor, size: 15),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: labelColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formattedValue,
                    key: valueKey,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatGermanInt(int number) {
    final raw = number.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final remaining = raw.length - i;
      buffer.write(raw[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }
}

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }
}

class _WheelEmptyMessage extends StatelessWidget {
  const _WheelEmptyMessage();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Diese Wortwelt hat aktuell keine weiteren aktiven Wörter zum Prüfen.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: const Color(0xFFB8C7D9),
        height: 1.24,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ReviewEmptyState extends StatelessWidget {
  const _ReviewEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF5DDCFF), size: 38),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFB8C7D9),
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
