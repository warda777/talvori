import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/application/word_game_progress_controller.dart';
import 'package:talvori/features/home/ui/widgets/game_word_source_picker.dart';

class WordPathGameScreen extends ConsumerStatefulWidget {
  const WordPathGameScreen({super.key, this.random});

  static const routeName = 'word-path-game';

  final Random? random;

  @override
  ConsumerState<WordPathGameScreen> createState() => _WordPathGameScreenState();
}

class _WordPathGameScreenState extends ConsumerState<WordPathGameScreen> {
  final SharedPreferencesWordGameProgressRepository _progressRepository =
      const SharedPreferencesWordGameProgressRepository();
  late final Random _random = widget.random ?? Random();
  GameWordSource _selectedSource = GameWordSource.standard(
    LocalLearningSource.allWords,
  );
  int _wordsPerRound = 10;
  List<LocalWord> _roundWords = const <LocalWord>[];
  WordPathBox? _box;
  Set<String> _foundIds = const <String>{};
  List<int> _selection = const <int>[];
  String _roundKey = '';
  int _cursor = 0;
  int _foundCount = 0;
  bool _hasStarted = false;
  bool _isFinished = false;
  bool _boxSolved = false;
  String? _feedback;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(localCategoriesProvider);
    final wordsAsync = _selectedSource.categoryId == null
        ? ref.watch(localWordsForSourceProvider(_selectedSource.source))
        : ref.watch(localWordsForCategoryProvider(_selectedSource.categoryId!));

    return Scaffold(
      backgroundColor: const Color(0xFF050912),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050912),
        elevation: 0,
        centerTitle: true,
        title: const Text('Wortpfad'),
      ),
      body: SafeArea(
        child: wordsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF9DFF7D)),
          ),
          error: (_, __) => _PathMessage(
            title: 'Wörter konnten nicht geladen werden',
            text: 'Versuche es gleich noch einmal.',
            buttonLabel: 'Zurück',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          data: (words) {
            final categories = categoriesAsync.value ?? const <LocalCategory>[];
            final playableWords = buildWordPathWords(words);
            final sourceKey =
                '${_selectedSource.key}:${playableWords.map((word) => word.id).join('|')}';
            if (_roundKey != sourceKey) _resetForSelection(sourceKey);

            if (playableWords.isEmpty) {
              return _PathMessage(
                title: 'Noch keine passenden Wörter',
                text: _selectedSource.categoryId == null
                    ? 'Diese Wortquelle braucht kurze Wörter ohne Leerzeichen für den Buchstaben-Kasten.'
                    : 'Diese Wortwelt braucht kurze Wörter ohne Leerzeichen für den Buchstaben-Kasten.',
                buttonLabel: 'Zurück',
                selectedSource: _selectedSource,
                categories: categories,
                onSourceSelected: _selectSource,
                onWordsPerRoundChanged: _selectWordsPerRound,
                wordsPerRound: _effectiveWordsPerRound(playableWords.length),
                availableIds: playableWords
                    .map((word) => word.id)
                    .toList(growable: false),
                onPressed: () => Navigator.of(context).maybePop(),
              );
            }

            if (!_hasStarted) {
              return _PathStartView(
                selectedSource: _selectedSource,
                categories: categories,
                availableIds: playableWords
                    .map((word) => word.id)
                    .toList(growable: false),
                wordsPerRound: _effectiveWordsPerRound(playableWords.length),
                onSourceSelected: _selectSource,
                onWordsPerRoundChanged: _selectWordsPerRound,
                onStart: () => setState(() => _startRound(playableWords)),
              );
            }

            if (_isFinished) {
              return _PathFinishedView(
                found: _foundCount,
                open: _roundWords.length - _foundCount,
                onRestart: () => setState(() => _startRound(playableWords)),
                onBack: () => Navigator.of(context).maybePop(),
              );
            }

            return _PathPlayView(
              box: _box!,
              foundIds: _foundIds,
              selection: _selection,
              foundCount: _foundCount,
              totalCount: _roundWords.length,
              feedback: _feedback,
              boxSolved: _boxSolved,
              onSelectCell: _selectCell,
              onDragCell: _dragCell,
              onSelectionEnd: _finishSelection,
              onCheckSelection: _checkSelection,
              onClearSelection: _clearSelection,
              onNextBox: _nextBox,
            );
          },
        ),
      ),
    );
  }

  void _resetForSelection(String sourceKey) {
    _roundKey = sourceKey;
    _roundWords = const <LocalWord>[];
    _box = null;
    _foundIds = const <String>{};
    _selection = const <int>[];
    _cursor = 0;
    _foundCount = 0;
    _hasStarted = false;
    _isFinished = false;
    _boxSolved = false;
    _feedback = null;
  }

  void _selectSource(GameWordSource source) {
    if (_selectedSource == source) return;
    setState(() {
      _selectedSource = source;
      _resetForSelection('');
    });
  }

  void _selectWordsPerRound(int count) {
    if (_wordsPerRound == count) return;
    setState(() {
      _wordsPerRound = count;
      _resetForSelection('');
    });
  }

  int _effectiveWordsPerRound(int available) {
    return clampWordsPerRound(
      requested: _wordsPerRound,
      minimum: 1,
      available: available,
    );
  }

  void _startRound(List<LocalWord> playableWords) {
    _roundWords = selectWordGameRoundItemsByCount<LocalWord>(
      items: playableWords,
      idOf: (word) => word.id,
      playedIds: const <String>{},
      wordsPerRound: _effectiveWordsPerRound(playableWords.length),
      random: _random,
    );
    _progressRepository.markPlayedIds(
      'word-path',
      _selectedSource.key,
      _roundWords.map((word) => word.id),
    );
    _cursor = 0;
    _foundCount = 0;
    _hasStarted = true;
    _isFinished = false;
    _buildBox();
  }

  void _buildBox() {
    final remaining = _roundWords.skip(_cursor).toList(growable: false);
    final count = min(
      remaining.length,
      2 + _random.nextInt(min(4, remaining.length)),
    );
    final words = remaining.take(count).toList(growable: false);
    _box = buildWordPathBox(words, allRoundWords: _roundWords, random: _random);
    _foundIds = const <String>{};
    _selection = const <int>[];
    _boxSolved = false;
    _feedback = null;
  }

  void _selectCell(int index) {
    if (_boxSolved) return;
    setState(() {
      _selection = [index];
      _feedback = null;
    });
  }

  void _dragCell(int index) {
    if (_boxSolved) return;
    if (_selection.isEmpty) {
      _selectCell(index);
      return;
    }
    if (_selection.contains(index)) return;
    setState(() {
      final firstRow = _selection.first ~/ _box!.columns;
      final row = index ~/ _box!.columns;
      if (row != firstRow) {
        _feedback = 'Nur waagerecht';
        return;
      }
      final first = _selection.first;
      final last = _selection.last;
      if (index == last + 1) {
        _selection = [..._selection, index];
      } else if (index == first - 1) {
        _selection = [index, ..._selection];
      } else {
        _feedback = 'Nur zusammenhängende Buchstaben';
      }
    });
  }

  void _finishSelection() {
    // The tap-based flow checks explicitly via the "Prüfen" button.
  }

  void _checkSelection() {
    if (_selection.isEmpty || _box == null) return;
    setState(() {
      _acceptSelection();
    });
  }

  void _acceptSelection() {
    final match = _box!.matchSelection(_selection);
    if (match == null) {
      _feedback = 'Nicht gefunden';
      _selection = const <int>[];
      return;
    }
    if (_foundIds.contains(match.word.id)) {
      _feedback = 'Bereits gefunden';
      _selection = const <int>[];
      return;
    }
    _foundIds = {..._foundIds, match.word.id};
    _foundCount += 1;
    _feedback = 'Gefunden';
    _selection = const <int>[];
    if (_foundIds.length == _box!.placements.length) {
      _boxSolved = true;
      _feedback = 'Kasten gelöst';
    }
  }

  void _clearSelection() {
    if (_selection.isEmpty) return;
    setState(() {
      _selection = const <int>[];
      _feedback = null;
    });
  }

  void _nextBox() {
    setState(() {
      _cursor += _box!.placements.length;
      if (_cursor >= _roundWords.length) {
        _isFinished = true;
        return;
      }
      _buildBox();
    });
  }
}

@visibleForTesting
List<LocalWord> buildWordPathWords(List<LocalWord> words) {
  final seen = <String>{};
  return [
    for (final word in words)
      if (!word.isArchived &&
          _isWordPathTerm(word.term) &&
          seen.add(word.term.trim().toLowerCase()))
        word,
  ];
}

bool _isWordPathTerm(String term) {
  final clean = term.trim();
  return clean.length >= 3 &&
      clean.length <= 10 &&
      RegExp(r'^[A-Za-zÄÖÜäöü]+$').hasMatch(clean);
}

@visibleForTesting
WordPathBox buildWordPathBox(
  List<LocalWord> words, {
  List<LocalWord>? allRoundWords,
  Random? random,
}) {
  final effectiveRandom = random ?? Random();
  const rows = 8;
  const columns = 8;
  final activeTerms = {
    for (final word in allRoundWords ?? words)
      if (_isWordPathTerm(word.term) && word.term.length <= columns)
        word.term.trim().toLowerCase(),
  };
  WordPathBox? fallback;
  for (var attempt = 0; attempt < 60; attempt += 1) {
    final cells = List<String>.generate(
      rows * columns,
      (_) =>
          String.fromCharCode('a'.codeUnitAt(0) + effectiveRandom.nextInt(26)),
    );
    final placements = <WordPathPlacement>[];
    final usedIndexes = <int>{};
    final candidates =
        words.where((word) => word.term.length <= columns).toList()
          ..shuffle(effectiveRandom);
    final rowsOrder = List<int>.generate(rows, (index) => index)
      ..shuffle(effectiveRandom);

    for (var i = 0; i < candidates.length && placements.length < 5; i += 1) {
      final word = candidates[i];
      final term = word.term.toLowerCase();
      final reverse = placements.length.isOdd;
      final row = rowsOrder[placements.length % rowsOrder.length];
      final maxStart = columns - term.length;
      final start = maxStart <= 0 ? 0 : effectiveRandom.nextInt(maxStart + 1);
      final indexes = <int>[];
      for (var p = 0; p < term.length; p += 1) {
        indexes.add(row * columns + start + p);
      }
      if (indexes.any(usedIndexes.contains)) continue;
      final chars = reverse ? term.split('').reversed.toList() : term.split('');
      for (var p = 0; p < indexes.length; p += 1) {
        cells[indexes[p]] = chars[p];
      }
      usedIndexes.addAll(indexes);
      placements.add(
        WordPathPlacement(
          word: word,
          indexes: indexes,
          reverse: reverse,
          color: _pathColors[placements.length % _pathColors.length],
        ),
      );
    }
    final box = WordPathBox(
      rows: rows,
      columns: columns,
      cells: cells,
      placements: placements,
    );
    fallback ??= box;
    if (!_containsUnexpectedWord(box, activeTerms)) return box;
  }
  return fallback!;
}

bool _containsUnexpectedWord(WordPathBox box, Set<String> activeTerms) {
  final intendedTerms = {
    for (final placement in box.placements) placement.word.term.toLowerCase(),
  };
  final blockedTerms = activeTerms.difference(intendedTerms);
  for (var row = 0; row < box.rows; row += 1) {
    final line = [
      for (var col = 0; col < box.columns; col += 1)
        box.cells[row * box.columns + col].toLowerCase(),
    ].join();
    final reverseLine = line.split('').reversed.join();
    for (final term in blockedTerms) {
      if (line.contains(term) || reverseLine.contains(term)) return true;
    }
  }
  return false;
}

const _pathColors = [
  Color(0xFF5DDCFF),
  Color(0xFF9DFF7D),
  Color(0xFFFFD166),
  Color(0xFFFF7AB6),
  Color(0xFFB36BFF),
];

class WordPathBox {
  const WordPathBox({
    required this.rows,
    required this.columns,
    required this.cells,
    required this.placements,
  });

  final int rows;
  final int columns;
  final List<String> cells;
  final List<WordPathPlacement> placements;

  WordPathPlacement? matchSelection(List<int> selection) {
    for (final placement in placements) {
      if (_sameIndexes(selection, placement.indexes) ||
          _sameIndexes(selection, placement.indexes.reversed.toList())) {
        return placement;
      }
    }
    return null;
  }

  bool _sameIndexes(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i += 1) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class WordPathPlacement {
  const WordPathPlacement({
    required this.word,
    required this.indexes,
    required this.reverse,
    required this.color,
  });

  final LocalWord word;
  final List<int> indexes;
  final bool reverse;
  final Color color;
}

class _PathStartView extends StatelessWidget {
  const _PathStartView({
    required this.selectedSource,
    required this.categories,
    required this.availableIds,
    required this.wordsPerRound,
    required this.onSourceSelected,
    required this.onWordsPerRoundChanged,
    required this.onStart,
  });

  final GameWordSource selectedSource;
  final List<LocalCategory> categories;
  final List<String> availableIds;
  final int wordsPerRound;
  final ValueChanged<GameWordSource> onSourceSelected;
  final ValueChanged<int> onWordsPerRoundChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        _PathCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Wortpfad',
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Finde versteckte Wörter im Buchstaben-Kasten.',
                style: TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              GameWordSourcePicker(
                keyPrefix: 'word-path',
                selectedSource: selectedSource,
                categories: categories,
                availableIds: availableIds,
                wordsPerRound: wordsPerRound,
                minWordsPerRound: 1,
                onSourceSelected: onSourceSelected,
                onWordsPerRoundChanged: onWordsPerRoundChanged,
                accentColor: const Color(0xFF9DFF7D),
              ),
              const SizedBox(height: 18),
              FilledButton(
                key: const ValueKey('word-path-start-button'),
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF9DFF7D),
                  foregroundColor: const Color(0xFF041018),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
                child: const Text('Starten'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PathPlayView extends StatelessWidget {
  const _PathPlayView({
    required this.box,
    required this.foundIds,
    required this.selection,
    required this.foundCount,
    required this.totalCount,
    required this.feedback,
    required this.boxSolved,
    required this.onSelectCell,
    required this.onDragCell,
    required this.onSelectionEnd,
    required this.onCheckSelection,
    required this.onClearSelection,
    required this.onNextBox,
  });

  final WordPathBox box;
  final Set<String> foundIds;
  final List<int> selection;
  final int foundCount;
  final int totalCount;
  final String? feedback;
  final bool boxSolved;
  final ValueChanged<int> onSelectCell;
  final ValueChanged<int> onDragCell;
  final VoidCallback onSelectionEnd;
  final VoidCallback onCheckSelection;
  final VoidCallback onClearSelection;
  final VoidCallback onNextBox;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        _PathHud(foundCount: foundCount, totalCount: totalCount),
        const SizedBox(height: 12),
        _PathCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tippe Buchstaben in einer Zeile an.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFB8C7D9),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              _LetterBoard(
                box: box,
                foundIds: foundIds,
                selection: selection,
                onSelectCell: onSelectCell,
                onDragCell: onDragCell,
                onSelectionEnd: onSelectionEnd,
              ),
              const SizedBox(height: 12),
              _CurrentBoxProgress(
                found: foundIds.length,
                total: box.placements.length,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      key: const ValueKey('word-path-check-button'),
                      onPressed: onCheckSelection,
                      child: const Text('Prüfen'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      key: const ValueKey('word-path-clear-button'),
                      onPressed: onClearSelection,
                      child: const Text('Leeren'),
                    ),
                  ),
                ],
              ),
              if (feedback != null) ...[
                const SizedBox(height: 14),
                _PathFeedback(text: feedback!),
              ],
              if (boxSolved) ...[
                const SizedBox(height: 14),
                FilledButton(
                  key: const ValueKey('word-path-next-box-button'),
                  onPressed: onNextBox,
                  child: const Text('Weiter'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LetterBoard extends StatelessWidget {
  const _LetterBoard({
    required this.box,
    required this.foundIds,
    required this.selection,
    required this.onSelectCell,
    required this.onDragCell,
    required this.onSelectionEnd,
  });

  final WordPathBox box;
  final Set<String> foundIds;
  final List<int> selection;
  final ValueChanged<int> onSelectCell;
  final ValueChanged<int> onDragCell;
  final VoidCallback onSelectionEnd;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: box.columns / box.rows,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellWidth = constraints.maxWidth / box.columns;
          final cellHeight = constraints.maxHeight / box.rows;
          int? cellFromGlobal(Offset globalPosition) {
            final boxRender = context.findRenderObject() as RenderBox;
            final local = boxRender.globalToLocal(globalPosition);
            final col = (local.dx / cellWidth).floor();
            final row = (local.dy / cellHeight).floor();
            if (row < 0 || row >= box.rows || col < 0 || col >= box.columns) {
              return null;
            }
            return row * box.columns + col;
          }

          return GestureDetector(
            key: const ValueKey('word-path-board'),
            onPanStart: (details) {
              final index = cellFromGlobal(details.globalPosition);
              if (index != null) onSelectCell(index);
            },
            onPanUpdate: (details) {
              final index = cellFromGlobal(details.globalPosition);
              if (index != null) onDragCell(index);
            },
            onPanEnd: (_) => onSelectionEnd(),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: box.columns,
              ),
              itemCount: box.cells.length,
              itemBuilder: (context, index) {
                WordPathPlacement? placement;
                for (final candidate in box.placements) {
                  if (foundIds.contains(candidate.word.id) &&
                      candidate.indexes.contains(index)) {
                    placement = candidate;
                    break;
                  }
                }
                final selected = selection.contains(index);
                final color =
                    placement?.color ??
                    (selected
                        ? const Color(0xFF5DDCFF)
                        : const Color(0xFF0B1220));
                return InkWell(
                  key: ValueKey('word-path-cell-$index'),
                  onTap: () {
                    onDragCell(index);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      color: color.withValues(
                        alpha: placement == null && !selected ? 1 : 0.82,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected || placement != null
                            ? color
                            : const Color(0xFF26354B),
                      ),
                    ),
                    child: Text(
                      box.cells[index].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFF4F8FF),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CurrentBoxProgress extends StatelessWidget {
  const _CurrentBoxProgress({required this.found, required this.total});

  final int found;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('word-path-box-progress'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF9DFF7D).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF9DFF7D).withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        'Gefunden: $found / $total',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFFF4F8FF),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PathHud extends StatelessWidget {
  const _PathHud({required this.foundCount, required this.totalCount});

  final int foundCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF26354B)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Gefunden: $foundCount',
              style: const TextStyle(
                color: Color(0xFFF4F8FF),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            'Fortschritt: $foundCount / $totalCount',
            style: const TextStyle(
              color: Color(0xFF9DFF7D),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PathFinishedView extends StatelessWidget {
  const _PathFinishedView({
    required this.found,
    required this.open,
    required this.onRestart,
    required this.onBack,
  });

  final int found;
  final int open;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 28),
      children: [
        _PathCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.route_rounded,
                color: Color(0xFF9DFF7D),
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Wortpfad geschafft',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Du hast $found Wörter gefunden.\nOffen: $open',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onRestart,
                child: const Text('Nochmal spielen'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: onBack,
                child: const Text('Zurück zu Wortspiele'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PathMessage extends StatelessWidget {
  const _PathMessage({
    required this.title,
    required this.text,
    required this.buttonLabel,
    required this.onPressed,
    this.selectedSource,
    this.categories = const <LocalCategory>[],
    this.availableIds = const <String>[],
    this.wordsPerRound = 1,
    this.onSourceSelected,
    this.onWordsPerRoundChanged,
  });

  final String title;
  final String text;
  final String buttonLabel;
  final VoidCallback onPressed;
  final GameWordSource? selectedSource;
  final List<LocalCategory> categories;
  final List<String> availableIds;
  final int wordsPerRound;
  final ValueChanged<GameWordSource>? onSourceSelected;
  final ValueChanged<int>? onWordsPerRoundChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 28),
      children: [
        _PathCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (selectedSource != null && onSourceSelected != null) ...[
                const SizedBox(height: 18),
                GameWordSourcePicker(
                  keyPrefix: 'word-path',
                  selectedSource: selectedSource!,
                  categories: categories,
                  availableIds: availableIds,
                  wordsPerRound: wordsPerRound,
                  minWordsPerRound: 1,
                  onSourceSelected: onSourceSelected!,
                  onWordsPerRoundChanged: onWordsPerRoundChanged,
                  accentColor: const Color(0xFF9DFF7D),
                ),
              ],
              const SizedBox(height: 18),
              OutlinedButton(onPressed: onPressed, child: Text(buttonLabel)),
            ],
          ),
        ),
      ],
    );
  }
}

class _PathFeedback extends StatelessWidget {
  const _PathFeedback({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF9DFF7D).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9DFF7D)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFFF4F8FF),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF9DFF7D)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9DFF7D).withValues(alpha: 0.14),
            blurRadius: 26,
            spreadRadius: -8,
          ),
        ],
      ),
      child: child,
    );
  }
}
