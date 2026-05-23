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

class WordSearchGameScreen extends ConsumerStatefulWidget {
  const WordSearchGameScreen({super.key, this.random});

  static const routeName = 'word-search-game';

  final Random? random;

  @override
  ConsumerState<WordSearchGameScreen> createState() =>
      _WordSearchGameScreenState();
}

class _WordSearchGameScreenState extends ConsumerState<WordSearchGameScreen> {
  final SharedPreferencesWordGameProgressRepository _progressRepository =
      const SharedPreferencesWordGameProgressRepository();
  late final Random _random = widget.random ?? Random();
  GameWordSource _selectedSource = GameWordSource.standard(
    LocalLearningSource.allWords,
  );
  int _wordsPerRound = 10;
  List<LocalWord> _roundWords = const <LocalWord>[];
  WordSearchBox? _box;
  Set<String> _foundIds = const <String>{};
  Set<String> _hintedIds = const <String>{};
  List<int> _selection = const <int>[];
  String _roundKey = '';
  int _cursor = 0;
  int _foundCount = 0;
  int _foundWithoutHint = 0;
  int _foundWithHint = 0;
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
        title: const Text('Wortsuche'),
      ),
      body: SafeArea(
        child: wordsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF7AB6)),
          ),
          error: (_, __) => _SearchMessage(
            title: 'Wörter konnten nicht geladen werden',
            text: 'Versuche es gleich noch einmal.',
            buttonLabel: 'Zurück',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          data: (words) {
            final categories = categoriesAsync.value ?? const <LocalCategory>[];
            final playableWords = buildWordSearchWords(words);
            final sourceKey =
                '${_selectedSource.key}:${playableWords.map((word) => word.id).join('|')}';
            if (_roundKey != sourceKey) _resetForSelection(sourceKey);

            if (playableWords.isEmpty) {
              return _SearchMessage(
                title: 'Noch keine passenden Wörter',
                text: _selectedSource.categoryId == null
                    ? 'Diese Wortquelle braucht kurze Wörter ohne Leerzeichen für die Wortsuche.'
                    : 'Diese Wortwelt braucht kurze Wörter ohne Leerzeichen für die Wortsuche.',
                buttonLabel: 'Zurück',
                selectedSource: _selectedSource,
                categories: categories,
                availableIds: playableWords
                    .map((word) => word.id)
                    .toList(growable: false),
                wordsPerRound: _effectiveWordsPerRound(playableWords.length),
                onSourceSelected: _selectSource,
                onWordsPerRoundChanged: _selectWordsPerRound,
                onPressed: () => Navigator.of(context).maybePop(),
              );
            }

            if (!_hasStarted) {
              return _SearchStartView(
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
              return _SearchFinishedView(
                found: _foundCount,
                open: _roundWords.length - _foundCount,
                foundWithoutHint: _foundWithoutHint,
                foundWithHint: _foundWithHint,
                onRestart: () => setState(() => _startRound(playableWords)),
                onBack: () => Navigator.of(context).maybePop(),
              );
            }

            return _SearchPlayView(
              box: _box!,
              foundIds: _foundIds,
              hintedIds: _hintedIds,
              selection: _selection,
              foundCount: _foundCount,
              foundWithoutHint: _foundWithoutHint,
              foundWithHint: _foundWithHint,
              totalCount: _roundWords.length,
              feedback: _feedback,
              boxSolved: _boxSolved,
              onTapCell: _tapCell,
              onCheckSelection: _checkSelection,
              onClearSelection: _clearSelection,
              onHint: _showHint,
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
    _hintedIds = const <String>{};
    _selection = const <int>[];
    _cursor = 0;
    _foundCount = 0;
    _foundWithoutHint = 0;
    _foundWithHint = 0;
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
      'word-search',
      _selectedSource.key,
      _roundWords.map((word) => word.id),
    );
    _cursor = 0;
    _foundCount = 0;
    _foundWithoutHint = 0;
    _foundWithHint = 0;
    _hintedIds = const <String>{};
    _hasStarted = true;
    _isFinished = false;
    _buildBox();
  }

  void _buildBox() {
    final remaining = _roundWords.skip(_cursor).toList(growable: false);
    final maxCount = min(remaining.length, 6);
    final minCount = min(remaining.length, 3);
    final count = minCount == maxCount
        ? minCount
        : minCount + _random.nextInt(maxCount - minCount + 1);
    final words = remaining.take(count).toList(growable: false);
    _box = buildWordSearchBox(
      words,
      allRoundWords: _roundWords,
      random: _random,
    );
    _foundIds = const <String>{};
    _selection = const <int>[];
    _boxSolved = false;
    _feedback = null;
  }

  void _tapCell(int index) {
    if (_boxSolved) return;
    if (_selection.contains(index)) return;
    setState(() {
      if (_selection.isEmpty) {
        _selection = [index];
        _feedback = null;
        return;
      }
      final next = _nextStraightSelection(_selection, index, _box!.columns);
      if (next == null) {
        _feedback = 'Nicht gefunden';
        return;
      }
      _selection = next;
      _feedback = null;
    });
  }

  void _checkSelection() {
    if (_selection.isEmpty || _box == null) return;
    setState(() {
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
      if (_hintedIds.contains(match.word.id)) {
        _foundWithHint += 1;
      } else {
        _foundWithoutHint += 1;
      }
      _selection = const <int>[];
      _feedback = 'Gefunden';
      if (_foundIds.length == _box!.placements.length) {
        _boxSolved = true;
        _feedback = 'Kasten geschafft';
      }
    });
  }

  void _clearSelection() {
    if (_selection.isEmpty) return;
    setState(() {
      _selection = const <int>[];
      _feedback = null;
    });
  }

  void _showHint() {
    if (_box == null || _boxSolved) return;
    setState(() {
      for (final placement in _box!.placements) {
        final wordId = placement.word.id;
        if (!_foundIds.contains(wordId) && !_hintedIds.contains(wordId)) {
          _hintedIds = {..._hintedIds, wordId};
          final firstLetter = placement.word.term.trim()[0].toUpperCase();
          _feedback = 'Beginnt mit $firstLetter';
          return;
        }
      }
      _feedback = 'Alle Hinweise wurden genutzt.';
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

List<int>? _nextStraightSelection(List<int> selection, int index, int columns) {
  if (selection.length == 1) {
    final first = selection.first;
    final delta = _normalizedDelta(first, index, columns);
    if (delta == null) return null;
    return [first, index];
  }
  final delta = selection[1] - selection.first;
  if (index == selection.last + delta) return [...selection, index];
  if (index == selection.first - delta) return [index, ...selection];
  return null;
}

int? _normalizedDelta(int from, int to, int columns) {
  final fromRow = from ~/ columns;
  final fromCol = from % columns;
  final toRow = to ~/ columns;
  final toCol = to % columns;
  final rowDiff = toRow - fromRow;
  final colDiff = toCol - fromCol;
  if (rowDiff == 0 && colDiff.abs() == 1) return colDiff;
  if (colDiff == 0 && rowDiff.abs() == 1) return rowDiff * columns;
  if (rowDiff.abs() == 1 && colDiff.abs() == 1) {
    return rowDiff * columns + colDiff;
  }
  return null;
}

@visibleForTesting
List<LocalWord> buildWordSearchWords(List<LocalWord> words) {
  final seen = <String>{};
  return [
    for (final word in words)
      if (!word.isArchived &&
          _isWordSearchTerm(word.term) &&
          seen.add(word.term.trim().toLowerCase()))
        word,
  ];
}

bool _isWordSearchTerm(String term) {
  final clean = term.trim();
  return clean.length >= 3 &&
      clean.length <= 10 &&
      RegExp(r'^[A-Za-zÄÖÜäöü]+$').hasMatch(clean);
}

const _searchDirections = <_SearchDirection>[
  _SearchDirection(0, 1),
  _SearchDirection(1, 0),
  _SearchDirection(1, 1),
  _SearchDirection(0, -1),
  _SearchDirection(-1, 0),
  _SearchDirection(-1, -1),
  _SearchDirection(1, -1),
  _SearchDirection(-1, 1),
];

@visibleForTesting
WordSearchBox buildWordSearchBox(
  List<LocalWord> words, {
  List<LocalWord>? allRoundWords,
  Random? random,
}) {
  final effectiveRandom = random ?? Random();
  const rows = 10;
  const columns = 10;
  final activeTerms = {
    for (final word in allRoundWords ?? words)
      if (_isWordSearchTerm(word.term)) word.term.trim().toLowerCase(),
  };
  WordSearchBox? fallback;
  for (var attempt = 0; attempt < 80; attempt += 1) {
    final cells = List<String>.filled(rows * columns, '');
    final placements = <WordSearchPlacement>[];
    final candidates = words.toList()..shuffle(effectiveRandom);
    for (final word in candidates) {
      if (placements.length >= 6) break;
      final term = word.term.trim().toLowerCase();
      final direction =
          _searchDirections[placements.length % _searchDirections.length];
      final indexes = _placeTerm(
        cells,
        rows,
        columns,
        term,
        direction,
        effectiveRandom,
      );
      if (indexes == null) continue;
      placements.add(
        WordSearchPlacement(
          word: word,
          indexes: indexes,
          color: _searchColors[placements.length % _searchColors.length],
        ),
      );
    }

    _fillEmptyCells(cells, effectiveRandom);
    final box = WordSearchBox(
      rows: rows,
      columns: columns,
      cells: cells,
      placements: placements,
    );
    fallback ??= box;
    if (!_containsUnexpectedSearchWord(box, activeTerms)) return box;
  }
  return fallback!;
}

List<int>? _placeTerm(
  List<String> cells,
  int rows,
  int columns,
  String term,
  _SearchDirection direction,
  Random random,
) {
  final starts = <int>[
    for (var index = 0; index < cells.length; index += 1) index,
  ]..shuffle(random);
  for (final start in starts) {
    final startRow = start ~/ columns;
    final startCol = start % columns;
    final endRow = startRow + direction.row * (term.length - 1);
    final endCol = startCol + direction.col * (term.length - 1);
    if (endRow < 0 || endRow >= rows || endCol < 0 || endCol >= columns) {
      continue;
    }
    final indexes = <int>[];
    var fits = true;
    for (var i = 0; i < term.length; i += 1) {
      final row = startRow + direction.row * i;
      final col = startCol + direction.col * i;
      final index = row * columns + col;
      final current = cells[index];
      if (current.isNotEmpty && current != term[i]) {
        fits = false;
        break;
      }
      indexes.add(index);
    }
    if (!fits) continue;
    for (var i = 0; i < indexes.length; i += 1) {
      cells[indexes[i]] = term[i];
    }
    return indexes;
  }
  return null;
}

void _fillEmptyCells(List<String> cells, Random random) {
  for (var i = 0; i < cells.length; i += 1) {
    if (cells[i].isEmpty) {
      cells[i] = String.fromCharCode('a'.codeUnitAt(0) + random.nextInt(26));
    }
  }
}

bool _containsUnexpectedSearchWord(WordSearchBox box, Set<String> activeTerms) {
  final intendedTerms = {
    for (final placement in box.placements) placement.word.term.toLowerCase(),
  };
  final blockedTerms = activeTerms.difference(intendedTerms);
  final lines = _searchLines(box);
  for (final line in lines) {
    final reverse = line.split('').reversed.join();
    for (final term in blockedTerms) {
      if (line.contains(term) || reverse.contains(term)) return true;
    }
  }
  return false;
}

List<String> _searchLines(WordSearchBox box) {
  final lines = <String>[];
  for (var row = 0; row < box.rows; row += 1) {
    lines.add(
      [
        for (var col = 0; col < box.columns; col += 1)
          box.cells[row * box.columns + col],
      ].join(),
    );
  }
  for (var col = 0; col < box.columns; col += 1) {
    lines.add(
      [
        for (var row = 0; row < box.rows; row += 1)
          box.cells[row * box.columns + col],
      ].join(),
    );
  }
  for (var startCol = 0; startCol < box.columns; startCol += 1) {
    lines.add(_collectLine(box, 0, startCol, 1, 1));
    lines.add(_collectLine(box, box.rows - 1, startCol, -1, 1));
  }
  for (var startRow = 1; startRow < box.rows; startRow += 1) {
    lines.add(_collectLine(box, startRow, 0, 1, 1));
    lines.add(_collectLine(box, startRow, 0, -1, 1));
  }
  return lines;
}

String _collectLine(
  WordSearchBox box,
  int startRow,
  int startCol,
  int rowStep,
  int colStep,
) {
  final chars = <String>[];
  var row = startRow;
  var col = startCol;
  while (row >= 0 && row < box.rows && col >= 0 && col < box.columns) {
    chars.add(box.cells[row * box.columns + col]);
    row += rowStep;
    col += colStep;
  }
  return chars.join();
}

const _searchColors = [
  Color(0xFFFF7AB6),
  Color(0xFF5DDCFF),
  Color(0xFF9DFF7D),
  Color(0xFFFFD166),
  Color(0xFFB36BFF),
  Color(0xFFFF8A5B),
];

class _SearchDirection {
  const _SearchDirection(this.row, this.col);

  final int row;
  final int col;
}

class WordSearchBox {
  const WordSearchBox({
    required this.rows,
    required this.columns,
    required this.cells,
    required this.placements,
  });

  final int rows;
  final int columns;
  final List<String> cells;
  final List<WordSearchPlacement> placements;

  WordSearchPlacement? matchSelection(List<int> selection) {
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

class WordSearchPlacement {
  const WordSearchPlacement({
    required this.word,
    required this.indexes,
    required this.color,
  });

  final LocalWord word;
  final List<int> indexes;
  final Color color;
}

class _SearchStartView extends StatelessWidget {
  const _SearchStartView({
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
        _SearchCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Wortsuche',
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Finde Wörter waagerecht, senkrecht und diagonal.',
                style: TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              GameWordSourcePicker(
                keyPrefix: 'word-search',
                selectedSource: selectedSource,
                categories: categories,
                availableIds: availableIds,
                wordsPerRound: wordsPerRound,
                minWordsPerRound: 1,
                onSourceSelected: onSourceSelected,
                onWordsPerRoundChanged: onWordsPerRoundChanged,
                accentColor: const Color(0xFFFF7AB6),
              ),
              const SizedBox(height: 18),
              FilledButton(
                key: const ValueKey('word-search-start-button'),
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7AB6),
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

class _SearchPlayView extends StatelessWidget {
  const _SearchPlayView({
    required this.box,
    required this.foundIds,
    required this.hintedIds,
    required this.selection,
    required this.foundCount,
    required this.foundWithoutHint,
    required this.foundWithHint,
    required this.totalCount,
    required this.feedback,
    required this.boxSolved,
    required this.onTapCell,
    required this.onCheckSelection,
    required this.onClearSelection,
    required this.onHint,
    required this.onNextBox,
  });

  final WordSearchBox box;
  final Set<String> foundIds;
  final Set<String> hintedIds;
  final List<int> selection;
  final int foundCount;
  final int foundWithoutHint;
  final int foundWithHint;
  final int totalCount;
  final String? feedback;
  final bool boxSolved;
  final ValueChanged<int> onTapCell;
  final VoidCallback onCheckSelection;
  final VoidCallback onClearSelection;
  final VoidCallback onHint;
  final VoidCallback onNextBox;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        _SearchHud(
          foundCount: foundCount,
          totalCount: totalCount,
          foundWithoutHint: foundWithoutHint,
          foundWithHint: foundWithHint,
        ),
        const SizedBox(height: 12),
        _SearchCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tippe Buchstaben waagerecht, senkrecht, diagonal oder rückwärts an.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _CurrentSearchProgress(
                found: foundIds.length,
                total: box.placements.length,
              ),
              const SizedBox(height: 14),
              _SearchBoard(
                box: box,
                foundIds: foundIds,
                hintedIds: hintedIds,
                selection: selection,
                onTapCell: onTapCell,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      key: const ValueKey('word-search-check-button'),
                      onPressed: onCheckSelection,
                      child: const Text('Prüfen'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      key: const ValueKey('word-search-clear-button'),
                      onPressed: onClearSelection,
                      child: const Text('Leeren'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                key: const ValueKey('word-search-hint-button'),
                onPressed: onHint,
                icon: const Icon(Icons.lightbulb_outline_rounded),
                label: const Text('Hinweis'),
              ),
              if (feedback != null) ...[
                const SizedBox(height: 14),
                _SearchFeedback(text: feedback!),
              ],
              if (boxSolved) ...[
                const SizedBox(height: 14),
                FilledButton(
                  key: const ValueKey('word-search-next-box-button'),
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

class _SearchBoard extends StatelessWidget {
  const _SearchBoard({
    required this.box,
    required this.foundIds,
    required this.hintedIds,
    required this.selection,
    required this.onTapCell,
  });

  final WordSearchBox box;
  final Set<String> foundIds;
  final Set<String> hintedIds;
  final List<int> selection;
  final ValueChanged<int> onTapCell;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: box.columns / box.rows,
      child: GridView.builder(
        key: const ValueKey('word-search-board'),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: box.columns,
        ),
        itemCount: box.cells.length,
        itemBuilder: (context, index) {
          WordSearchPlacement? placement;
          WordSearchPlacement? hintPlacement;
          for (final candidate in box.placements) {
            if (foundIds.contains(candidate.word.id) &&
                candidate.indexes.contains(index)) {
              placement = candidate;
              break;
            }
            if (!foundIds.contains(candidate.word.id) &&
                hintedIds.contains(candidate.word.id) &&
                candidate.indexes.first == index) {
              hintPlacement = candidate;
            }
          }
          final selected = selection.contains(index);
          final hinted = hintPlacement != null;
          final color =
              placement?.color ??
              (selected
                  ? const Color(0xFFFF7AB6)
                  : hinted
                  ? const Color(0xFFFFD166)
                  : const Color(0xFF0B1220));
          return InkWell(
            key: ValueKey('word-search-cell-$index'),
            onTap: () => onTapCell(index),
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(1.2),
              decoration: BoxDecoration(
                color: color.withValues(
                  alpha: placement == null && !selected && !hinted ? 1 : 0.82,
                ),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: selected || placement != null || hinted
                      ? color
                      : const Color(0xFF26354B),
                  width: hinted ? 2 : 1,
                ),
              ),
              child: Text(
                box.cells[index].toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchHud extends StatelessWidget {
  const _SearchHud({
    required this.foundCount,
    required this.totalCount,
    required this.foundWithoutHint,
    required this.foundWithHint,
  });

  final int foundCount;
  final int totalCount;
  final int foundWithoutHint;
  final int foundWithHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF26354B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
                  color: Color(0xFFFF7AB6),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Ohne Hinweis: $foundWithoutHint · Mit Hinweis: $foundWithHint',
            style: const TextStyle(
              color: Color(0xFFB8C7D9),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentSearchProgress extends StatelessWidget {
  const _CurrentSearchProgress({required this.found, required this.total});

  final int found;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('word-search-box-progress'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFF7AB6).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFF7AB6).withValues(alpha: 0.5),
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

class _SearchFinishedView extends StatelessWidget {
  const _SearchFinishedView({
    required this.found,
    required this.open,
    required this.foundWithoutHint,
    required this.foundWithHint,
    required this.onRestart,
    required this.onBack,
  });

  final int found;
  final int open;
  final int foundWithoutHint;
  final int foundWithHint;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 28),
      children: [
        _SearchCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.grid_view_rounded,
                color: Color(0xFFFF7AB6),
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Wortsuche geschafft',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Du hast $found Wörter gefunden.\nOffen: $open\nOhne Hinweis gefunden: $foundWithoutHint\nMit Hinweis gefunden: $foundWithHint',
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

class _SearchMessage extends StatelessWidget {
  const _SearchMessage({
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
        _SearchCard(
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
                  keyPrefix: 'word-search',
                  selectedSource: selectedSource!,
                  categories: categories,
                  availableIds: availableIds,
                  wordsPerRound: wordsPerRound,
                  minWordsPerRound: 1,
                  onSourceSelected: onSourceSelected!,
                  onWordsPerRoundChanged: onWordsPerRoundChanged,
                  accentColor: const Color(0xFFFF7AB6),
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

class _SearchFeedback extends StatelessWidget {
  const _SearchFeedback({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF7AB6).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF7AB6)),
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

class _SearchCard extends StatelessWidget {
  const _SearchCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFF7AB6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7AB6).withValues(alpha: 0.14),
            blurRadius: 26,
            spreadRadius: -8,
          ),
        ],
      ),
      child: child,
    );
  }
}
