import 'dart:async';
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

enum SyllableRainSpeed {
  relaxed('Entspannt', Duration(milliseconds: 18000)),
  slow('Langsam', Duration(milliseconds: 15000)),
  medium('Mittel', Duration(milliseconds: 12500)),
  fast('Schnell', Duration(milliseconds: 9800));

  const SyllableRainSpeed(this.label, this.duration);

  final String label;
  final Duration duration;
}

class SyllableRainGameScreen extends ConsumerStatefulWidget {
  const SyllableRainGameScreen({super.key, this.random});

  static const routeName = 'syllable-rain-game';

  final Random? random;

  @override
  ConsumerState<SyllableRainGameScreen> createState() =>
      _SyllableRainGameScreenState();
}

class _SyllableRainGameScreenState
    extends ConsumerState<SyllableRainGameScreen> {
  final SharedPreferencesWordGameProgressRepository _progressRepository =
      const SharedPreferencesWordGameProgressRepository();
  late final Random _random = widget.random ?? Random();
  GameWordSource _selectedSource = GameWordSource.standard(
    LocalLearningSource.allWords,
  );
  int _wordsPerRound = 10;
  SyllableRainSpeed _speed = SyllableRainSpeed.medium;
  List<LocalWord> _roundWords = const <LocalWord>[];
  List<_RainBubbleData> _bubbles = const <_RainBubbleData>[];
  Set<int> _selectedBubbleIds = const <int>{};
  Set<String> _formedWordIds = const <String>{};
  Set<int> _missedPairSpawns = const <int>{};
  String _roundKey = '';
  int _bubbleSerial = 0;
  int _pairSpawnSerial = 0;
  int _formedCount = 0;
  int _missedCount = 0;
  bool _hasStarted = false;
  bool _isFinished = false;
  String? _feedback;
  String? _lastFormedWord;

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
        title: const Text('Silben-Regen'),
      ),
      body: SafeArea(
        child: wordsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF5DDCFF)),
          ),
          error: (_, __) => _RainMessage(
            title: 'Wörter konnten nicht geladen werden',
            text: 'Versuche es gleich noch einmal.',
            buttonLabel: 'Zurück',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          data: (words) {
            final categories = categoriesAsync.value ?? const <LocalCategory>[];
            final playableWords = buildSyllableRainWords(words);
            final sourceKey =
                '${_selectedSource.key}:${playableWords.map((word) => word.id).join('|')}';
            if (_roundKey != sourceKey) _resetForSelection(sourceKey);

            if (playableWords.isEmpty) {
              return _RainMessage(
                title: 'Noch keine passenden Wörter',
                text: _selectedSource.categoryId == null
                    ? 'Diese Wortquelle braucht Wörter mit mindestens vier Buchstaben ohne Leerzeichen.'
                    : 'Diese Wortwelt braucht Wörter mit mindestens vier Buchstaben ohne Leerzeichen.',
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
              return _RainStartView(
                selectedSource: _selectedSource,
                categories: categories,
                availableIds: playableWords
                    .map((word) => word.id)
                    .toList(growable: false),
                wordsPerRound: _effectiveWordsPerRound(playableWords.length),
                speed: _speed,
                onSourceSelected: _selectSource,
                onWordsPerRoundChanged: _selectWordsPerRound,
                onSpeedChanged: (speed) => setState(() => _speed = speed),
                onStart: () => setState(() => _startRound(playableWords)),
              );
            }

            if (_isFinished) {
              return _RainFinishedView(
                formed: _formedCount,
                missed: _missedCount,
                open: _roundWords.length - _formedCount,
                onRestart: () => setState(() => _startRound(playableWords)),
                onBack: () => Navigator.of(context).maybePop(),
              );
            }

            return _RainPlayView(
              bubbles: _bubbles,
              selectedBubbleIds: _selectedBubbleIds,
              totalCount: _roundWords.length,
              formed: _formedCount,
              missed: _missedCount,
              open: _roundWords.length - _formedCount,
              speed: _speed,
              feedback: _feedback,
              lastFormedWord: _lastFormedWord,
              onBubbleTap: _tapBubble,
              onBubbleMissed: _missBubble,
            );
          },
        ),
      ),
    );
  }

  void _resetForSelection(String sourceKey) {
    _roundKey = sourceKey;
    _roundWords = const <LocalWord>[];
    _bubbles = const <_RainBubbleData>[];
    _selectedBubbleIds = const <int>{};
    _formedWordIds = const <String>{};
    _missedPairSpawns = const <int>{};
    _bubbleSerial = 0;
    _pairSpawnSerial = 0;
    _formedCount = 0;
    _missedCount = 0;
    _hasStarted = false;
    _isFinished = false;
    _feedback = null;
    _lastFormedWord = null;
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
      'syllable-rain',
      _selectedSource.key,
      _roundWords.map((word) => word.id),
    );
    _bubbleSerial = 0;
    _pairSpawnSerial = 0;
    _formedCount = 0;
    _missedCount = 0;
    _formedWordIds = const <String>{};
    _missedPairSpawns = const <int>{};
    _selectedBubbleIds = const <int>{};
    _hasStarted = true;
    _isFinished = false;
    _feedback = null;
    _lastFormedWord = null;
    _rebuildActiveBubbles();
  }

  void _rebuildActiveBubbles() {
    final openWords = _roundWords
        .where((word) => !_formedWordIds.contains(word.id))
        .toList(growable: false);
    if (openWords.isEmpty) {
      _isFinished = true;
      _bubbles = const <_RainBubbleData>[];
      return;
    }
    final activeWords = openWords.take(min(3, openWords.length)).toList();
    _bubbles = [
      for (var i = 0; i < activeWords.length; i += 1)
        ..._createWordPairBubbles(activeWords[i], pairIndex: i),
    ];
    _selectedBubbleIds = const <int>{};
  }

  List<_RainBubbleData> _createWordPairBubbles(
    LocalWord word, {
    required int pairIndex,
  }) {
    final parts = buildSyllableRainParts(word.term);
    final spawnId = _pairSpawnSerial++;
    final pattern = _rainPairPatterns[pairIndex % _rainPairPatterns.length];
    return [
      _createBubble(
        _RainPart(
          wordId: word.id,
          wordTerm: word.term.trim(),
          part: parts.first,
          partIndex: 0,
          partsCount: parts.length,
        ),
        laneIndex: pattern.firstLane,
        delayStep: pairIndex,
        verticalOffset: pattern.firstVerticalOffset,
        pairSpawnId: spawnId,
      ),
      _createBubble(
        _RainPart(
          wordId: word.id,
          wordTerm: word.term.trim(),
          part: parts.last,
          partIndex: 1,
          partsCount: parts.length,
        ),
        laneIndex: pattern.secondLane,
        delayStep: pairIndex,
        verticalOffset: pattern.secondVerticalOffset,
        pairSpawnId: spawnId,
      ),
    ];
  }

  _RainBubbleData _createBubble(
    _RainPart part, {
    required int laneIndex,
    required int delayStep,
    required double verticalOffset,
    required int pairSpawnId,
  }) {
    const lanes = [0.04, 0.22, 0.40, 0.58, 0.76, 0.94];
    final lane = lanes[laneIndex % lanes.length];
    final jitter = (_random.nextDouble() - 0.5) * 0.012;
    return _RainBubbleData(
      id: _bubbleSerial++,
      pairSpawnId: pairSpawnId,
      wordId: part.wordId,
      wordTerm: part.wordTerm,
      part: part.part,
      partIndex: part.partIndex,
      partsCount: part.partsCount,
      leftFactor: (lane + jitter).clamp(0.06, 0.9),
      size: 68,
      delay: Duration(milliseconds: 1700 * delayStep),
      verticalOffset: verticalOffset,
      laneIndex: laneIndex,
    );
  }

  void _tapBubble(_RainBubbleData bubble) {
    if (_isFinished || _formedWordIds.contains(bubble.wordId)) return;
    if (_selectedBubbleIds.contains(bubble.id)) return;
    setState(() {
      _selectedBubbleIds = {..._selectedBubbleIds, bubble.id};
      _evaluateSelection();
    });
  }

  void _evaluateSelection() {
    final selected = _bubbles
        .where((bubble) => _selectedBubbleIds.contains(bubble.id))
        .toList(growable: false);
    if (selected.isEmpty) return;
    final grouped = <String, List<_RainBubbleData>>{};
    for (final bubble in selected) {
      grouped.putIfAbsent(bubble.wordId, () => <_RainBubbleData>[]).add(bubble);
    }
    for (final entry in grouped.entries) {
      final wordParts = entry.value;
      final needed = wordParts.first.partsCount;
      final indexes = wordParts.map((bubble) => bubble.partIndex).toSet();
      if (wordParts.length == needed &&
          indexes.length == needed &&
          selected.length == needed) {
        _formedWordIds = {..._formedWordIds, entry.key};
        _formedCount += 1;
        _feedback = 'Gebildet: ${wordParts.first.wordTerm}';
        _lastFormedWord = wordParts.first.wordTerm;
        if (_formedCount >= _roundWords.length) {
          _isFinished = true;
          _bubbles = const <_RainBubbleData>[];
          _selectedBubbleIds = const <int>{};
          return;
        }
        _removeMatchedPairAndBackfill(entry.key);
        return;
      }
    }
    if (grouped.length > 1 || selected.length >= 2) {
      _feedback = 'Falsch';
      _selectedBubbleIds = const <int>{};
    } else {
      final first = selected.first;
      _feedback = '1 / ${first.partsCount} Teile gewählt';
    }
  }

  void _missBubble(_RainBubbleData bubble) {
    if (!mounted || _isFinished) return;
    setState(() {
      if (!_formedWordIds.contains(bubble.wordId) &&
          !_missedPairSpawns.contains(bubble.pairSpawnId)) {
        _missedPairSpawns = {..._missedPairSpawns, bubble.pairSpawnId};
        _missedCount += 1;
        _feedback = 'Verpasst.';
      }
      _replaceWordBubbles(bubble.wordId);
    });
  }

  void _removeMatchedPairAndBackfill(String wordId) {
    _bubbles = [
      for (final bubble in _bubbles)
        if (bubble.wordId != wordId) bubble,
    ];
    _selectedBubbleIds = const <int>{};
    final activeWordIds = _bubbles.map((bubble) => bubble.wordId).toSet();
    LocalWord? nextWord;
    for (final word in _roundWords) {
      if (!_formedWordIds.contains(word.id) &&
          !activeWordIds.contains(word.id)) {
        nextWord = word;
        break;
      }
    }
    if (nextWord != null) {
      final usedPairSlots = _bubbles
          .map((bubble) => _pairSlotForLane(bubble.laneIndex))
          .toSet();
      var nextPairIndex = 0;
      while (usedPairSlots.contains(nextPairIndex) && nextPairIndex < 2) {
        nextPairIndex += 1;
      }
      _bubbles = [
        ..._bubbles,
        ..._createWordPairBubbles(nextWord, pairIndex: nextPairIndex),
      ];
    }
  }

  void _replaceWordBubbles(String wordId) {
    final wordBubbles = _bubbles
        .where((bubble) => bubble.wordId == wordId)
        .toList(growable: false);
    if (wordBubbles.isEmpty) return;
    final selected = {..._selectedBubbleIds}
      ..removeWhere((id) => wordBubbles.any((bubble) => bubble.id == id));
    final spawnId = _pairSpawnSerial++;
    final delayStep = 1 + _random.nextInt(2);
    final replacements = {
      for (final bubble in wordBubbles)
        bubble.id: _createBubble(
          _RainPart(
            wordId: bubble.wordId,
            wordTerm: bubble.wordTerm,
            part: bubble.part,
            partIndex: bubble.partIndex,
            partsCount: bubble.partsCount,
          ),
          laneIndex: bubble.laneIndex,
          delayStep: delayStep,
          verticalOffset: bubble.verticalOffset,
          pairSpawnId: spawnId,
        ),
    };
    _bubbles = [
      for (final current in _bubbles)
        if (replacements.containsKey(current.id))
          replacements[current.id]!
        else
          current,
    ];
    _selectedBubbleIds = selected;
  }
}

const _rainPairPatterns = [
  _RainPairPattern(
    firstLane: 0,
    secondLane: 4,
    firstVerticalOffset: 0,
    secondVerticalOffset: 132,
  ),
  _RainPairPattern(
    firstLane: 2,
    secondLane: 5,
    firstVerticalOffset: 92,
    secondVerticalOffset: 0,
  ),
  _RainPairPattern(
    firstLane: 1,
    secondLane: 3,
    firstVerticalOffset: 178,
    secondVerticalOffset: 64,
  ),
];

int _pairSlotForLane(int laneIndex) {
  for (var i = 0; i < _rainPairPatterns.length; i += 1) {
    final pattern = _rainPairPatterns[i];
    if (pattern.firstLane == laneIndex || pattern.secondLane == laneIndex) {
      return i;
    }
  }
  return 0;
}

class _RainPairPattern {
  const _RainPairPattern({
    required this.firstLane,
    required this.secondLane,
    required this.firstVerticalOffset,
    required this.secondVerticalOffset,
  });

  final int firstLane;
  final int secondLane;
  final double firstVerticalOffset;
  final double secondVerticalOffset;
}

@visibleForTesting
List<LocalWord> buildSyllableRainWords(List<LocalWord> words) {
  final seen = <String>{};
  return [
    for (final word in words)
      if (!word.isArchived &&
          _canUseRainWord(word.term) &&
          seen.add(word.term.trim().toLowerCase()))
        word,
  ];
}

@visibleForTesting
List<String> buildSyllableRainParts(String term) {
  final clean = term.trim();
  final split = (clean.length / 2).floor().clamp(2, clean.length - 2);
  return [clean.substring(0, split), clean.substring(split)];
}

bool _canUseRainWord(String term) {
  final clean = term.trim();
  return clean.length >= 4 &&
      RegExp(r'^[A-Za-zÄÖÜäöü]+$').hasMatch(clean) &&
      !RegExp(r'[\s\-]').hasMatch(clean);
}

class _RainPart {
  const _RainPart({
    required this.wordId,
    required this.wordTerm,
    required this.part,
    required this.partIndex,
    required this.partsCount,
  });

  final String wordId;
  final String wordTerm;
  final String part;
  final int partIndex;
  final int partsCount;
}

class _RainBubbleData {
  const _RainBubbleData({
    required this.id,
    required this.pairSpawnId,
    required this.wordId,
    required this.wordTerm,
    required this.part,
    required this.partIndex,
    required this.partsCount,
    required this.leftFactor,
    required this.size,
    required this.delay,
    required this.verticalOffset,
    required this.laneIndex,
  });

  final int id;
  final int pairSpawnId;
  final String wordId;
  final String wordTerm;
  final String part;
  final int partIndex;
  final int partsCount;
  final double leftFactor;
  final double size;
  final Duration delay;
  final double verticalOffset;
  final int laneIndex;
}

class _RainStartView extends StatelessWidget {
  const _RainStartView({
    required this.selectedSource,
    required this.categories,
    required this.availableIds,
    required this.wordsPerRound,
    required this.speed,
    required this.onSourceSelected,
    required this.onWordsPerRoundChanged,
    required this.onSpeedChanged,
    required this.onStart,
  });

  final GameWordSource selectedSource;
  final List<LocalCategory> categories;
  final List<String> availableIds;
  final int wordsPerRound;
  final SyllableRainSpeed speed;
  final ValueChanged<GameWordSource> onSourceSelected;
  final ValueChanged<int> onWordsPerRoundChanged;
  final ValueChanged<SyllableRainSpeed> onSpeedChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        _RainCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Silben-Regen',
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fange fallende Wortteile und bilde Wörter.',
                style: TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              GameWordSourcePicker(
                keyPrefix: 'syllable-rain',
                selectedSource: selectedSource,
                categories: categories,
                availableIds: availableIds,
                wordsPerRound: wordsPerRound,
                minWordsPerRound: 1,
                onSourceSelected: onSourceSelected,
                onWordsPerRoundChanged: onWordsPerRoundChanged,
                accentColor: const Color(0xFF5DDCFF),
              ),
              const SizedBox(height: 16),
              _RainSpeedPicker(selected: speed, onChanged: onSpeedChanged),
              const SizedBox(height: 18),
              FilledButton(
                key: const ValueKey('syllable-rain-start-button'),
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF5DDCFF),
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

class _RainSpeedPicker extends StatelessWidget {
  const _RainSpeedPicker({required this.selected, required this.onChanged});

  final SyllableRainSpeed selected;
  final ValueChanged<SyllableRainSpeed> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Geschwindigkeit',
          style: TextStyle(
            color: Color(0xFFB8C7D9),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final speed in SyllableRainSpeed.values)
              ChoiceChip(
                key: ValueKey('syllable-rain-speed-${speed.name}'),
                label: Text(speed.label),
                selected: speed == selected,
                selectedColor: const Color(0xFF5DDCFF),
                backgroundColor: const Color(0xFF0B1220),
                labelStyle: TextStyle(
                  color: speed == selected
                      ? const Color(0xFF041018)
                      : const Color(0xFFF4F8FF),
                  fontWeight: FontWeight.w900,
                ),
                onSelected: (_) => onChanged(speed),
              ),
          ],
        ),
      ],
    );
  }
}

class _RainPlayView extends StatelessWidget {
  const _RainPlayView({
    required this.bubbles,
    required this.selectedBubbleIds,
    required this.totalCount,
    required this.formed,
    required this.missed,
    required this.open,
    required this.speed,
    required this.feedback,
    required this.lastFormedWord,
    required this.onBubbleTap,
    required this.onBubbleMissed,
  });

  final List<_RainBubbleData> bubbles;
  final Set<int> selectedBubbleIds;
  final int totalCount;
  final int formed;
  final int missed;
  final int open;
  final SyllableRainSpeed speed;
  final String? feedback;
  final String? lastFormedWord;
  final ValueChanged<_RainBubbleData> onBubbleTap;
  final ValueChanged<_RainBubbleData> onBubbleMissed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        _RainHud(
          totalCount: totalCount,
          formed: formed,
          missed: missed,
          open: open,
        ),
        const SizedBox(height: 12),
        _RainCard(
          child: Column(
            children: [
              const Text(
                'Tippe passende Wortteile an.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFB8C7D9),
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (lastFormedWord != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Zuletzt gebildet: $lastFormedWord',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF5DDCFF),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                key: const ValueKey('syllable-rain-field'),
                height: 420,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        for (final bubble in bubbles)
                          _FallingBubble(
                            key: ValueKey('syllable-rain-bubble-${bubble.id}'),
                            bubble: bubble,
                            selected: selectedBubbleIds.contains(bubble.id),
                            duration: speed.duration,
                            fieldSize: constraints.biggest,
                            onTap: () => onBubbleTap(bubble),
                            onMissed: () => onBubbleMissed(bubble),
                          ),
                      ],
                    );
                  },
                ),
              ),
              if (feedback != null) ...[
                const SizedBox(height: 12),
                _RainFeedback(text: feedback!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FallingBubble extends StatefulWidget {
  const _FallingBubble({
    super.key,
    required this.bubble,
    required this.selected,
    required this.duration,
    required this.fieldSize,
    required this.onTap,
    this.onMissed,
  });

  final _RainBubbleData bubble;
  final bool selected;
  final Duration duration;
  final Size fieldSize;
  final VoidCallback onTap;
  final VoidCallback? onMissed;

  @override
  State<_FallingBubble> createState() => _FallingBubbleState();
}

class _FallingBubbleState extends State<_FallingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _delayTimer;
  bool _reportedMiss = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _delayTimer = Timer(widget.bubble.delay, () {
      if (mounted) _controller.forward();
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_reportedMiss) {
        _reportedMiss = true;
        widget.onMissed?.call();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _FallingBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxLeft = max(0.0, widget.fieldSize.width - widget.bubble.size);
    final left = (widget.bubble.leftFactor * maxLeft).clamp(0.0, maxLeft);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final travelDistance =
            widget.fieldSize.height +
            widget.bubble.size +
            widget.bubble.verticalOffset;
        final top =
            -widget.bubble.size -
            widget.bubble.verticalOffset +
            _controller.value * travelDistance;
        return Positioned(left: left, top: top, child: child!);
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: widget.onTap,
        child: Container(
          width: widget.bubble.size,
          height: widget.bubble.size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.selected
                ? const Color(0xFFFFD166).withValues(alpha: 0.94)
                : const Color(0xFF5DDCFF).withValues(alpha: 0.88),
            boxShadow: [
              BoxShadow(
                color:
                    (widget.selected
                            ? const Color(0xFFFFD166)
                            : const Color(0xFF5DDCFF))
                        .withValues(alpha: 0.25),
                blurRadius: widget.selected ? 30 : 22,
              ),
            ],
          ),
          child: Text(
            widget.bubble.part,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF041018),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _RainHud extends StatelessWidget {
  const _RainHud({
    required this.totalCount,
    required this.formed,
    required this.missed,
    required this.open,
  });

  final int totalCount;
  final int formed;
  final int missed;
  final int open;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF26354B)),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Text('Gebildet: $formed / $totalCount', style: _hudStyle()),
          Text('Verpasst: $missed', style: _hudStyle()),
          Text('Offen: $open', style: _hudStyle()),
        ],
      ),
    );
  }

  TextStyle _hudStyle() {
    return const TextStyle(
      color: Color(0xFFF4F8FF),
      fontWeight: FontWeight.w900,
    );
  }
}

class _RainFinishedView extends StatelessWidget {
  const _RainFinishedView({
    required this.formed,
    required this.missed,
    required this.open,
    required this.onRestart,
    required this.onBack,
  });

  final int formed;
  final int missed;
  final int open;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 28),
      children: [
        _RainCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.water_drop_rounded,
                color: Color(0xFF5DDCFF),
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Regen beendet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Du hast $formed Wörter gebildet.\nNoch offen: $open\nVerpasst: $missed',
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

class _RainMessage extends StatelessWidget {
  const _RainMessage({
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
        _RainCard(
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
                  keyPrefix: 'syllable-rain',
                  selectedSource: selectedSource!,
                  categories: categories,
                  availableIds: availableIds,
                  wordsPerRound: wordsPerRound,
                  minWordsPerRound: 1,
                  onSourceSelected: onSourceSelected!,
                  onWordsPerRoundChanged: onWordsPerRoundChanged,
                  accentColor: const Color(0xFF5DDCFF),
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

class _RainFeedback extends StatelessWidget {
  const _RainFeedback({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF5DDCFF).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5DDCFF)),
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

class _RainCard extends StatelessWidget {
  const _RainCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF5DDCFF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5DDCFF).withValues(alpha: 0.14),
            blurRadius: 26,
            spreadRadius: -8,
          ),
        ],
      ),
      child: child,
    );
  }
}
