import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/application/word_game_progress_controller.dart';
import 'package:talvori/features/home/ui/widgets/game_word_source_picker.dart'
    as game_picker;

class WordMatchGameScreen extends ConsumerStatefulWidget {
  const WordMatchGameScreen({super.key});

  static const routeName = 'word-match-game';

  @override
  ConsumerState<WordMatchGameScreen> createState() =>
      _WordMatchGameScreenState();
}

class _WordMatchGameScreenState extends ConsumerState<WordMatchGameScreen> {
  GameWordSource _selectedSource = GameWordSource.standard(
    LocalLearningSource.allWords,
  );
  final Random _random = Random();
  final SharedPreferencesWordGameProgressRepository _progressRepository =
      const SharedPreferencesWordGameProgressRepository();
  int _wordsPerRound = 10;
  List<WordMatchPair> _roundPairs = const <WordMatchPair>[];
  List<String> _visibleIds = const <String>[];
  List<String> _translationIds = const <String>[];
  Set<String> _matchedIds = <String>{};
  String _roundSourceKey = '';
  bool _hasStarted = false;
  bool _soundEnabled = true;
  String? _feedback;

  bool get _isFinished =>
      _hasStarted &&
      _roundPairs.isNotEmpty &&
      _matchedIds.length == _roundPairs.length;

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
        title: const Text('Wort-Match'),
      ),
      body: SafeArea(
        child: wordsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF5DDCFF)),
          ),
          error: (_, __) => _WordMatchMessageState(
            title: 'Wörter konnten nicht geladen werden',
            text: 'Versuche es gleich noch einmal.',
            buttonLabel: 'Zurück',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          data: (words) {
            final categories = categoriesAsync.value ?? const <LocalCategory>[];
            final pairs = buildWordMatchPairs(words);
            if (pairs.length < 6) {
              return _WordMatchMessageState(
                title: 'Noch nicht genug Wörter',
                text: _selectedSource.categoryId == null
                    ? 'Diese Wortquelle braucht mindestens sechs Wörter mit Übersetzung, um Wort-Match zu spielen.'
                    : 'Diese Wortwelt braucht mindestens sechs Wörter mit Übersetzung, um Wort-Match zu spielen.',
                buttonLabel: 'Zurück',
                selectedSource: _selectedSource,
                categories: categories,
                onSourceSelected: _selectSource,
                onPressed: () => Navigator.of(context).maybePop(),
              );
            }

            final sourceKey =
                '${_selectedSource.key}:${pairs.map((pair) => pair.id).join('|')}';
            if (_roundSourceKey != sourceKey) {
              _resetForSelection(sourceKey);
            }

            if (!_hasStarted) {
              return _StartView(
                selectedSource: _selectedSource,
                categories: categories,
                availableIds: pairs
                    .map((pair) => pair.id)
                    .toList(growable: false),
                wordsPerRound: _effectiveWordsPerRound(pairs.length),
                soundEnabled: _soundEnabled,
                onSourceSelected: _selectSource,
                onWordsPerRoundChanged: _selectWordsPerRound,
                onToggleSound: () {
                  setState(() => _soundEnabled = !_soundEnabled);
                },
                onStart: () => setState(() => _startNewSet(pairs)),
              );
            }

            if (_isFinished) {
              return _FinishedView(
                solvedCount: _matchedIds.length,
                totalCount: _roundPairs.length,
                onReplay: () => setState(_replaySameSet),
                onNewSet: () => setState(() => _startNewSet(pairs)),
                onBack: () => Navigator.of(context).maybePop(),
              );
            }

            return _MatchPlayView(
              wordPairs: _visibleWordPairs,
              translationPairs: _visibleTranslationPairs,
              doneCount: _matchedIds.length,
              totalCount: _roundPairs.length,
              selectedSource: _selectedSource,
              soundEnabled: _soundEnabled,
              feedback: _feedback,
              onDragStarted: () {
                HapticFeedback.selectionClick();
              },
              onAccept: _matchPair,
            );
          },
        ),
      ),
    );
  }

  List<WordMatchPair> get _visibleWordPairs {
    return [
      for (final id in _visibleIds)
        if (!_matchedIds.contains(id)) _pairById(id),
    ];
  }

  List<WordMatchPair> get _visibleTranslationPairs {
    return [
      for (final id in _translationIds)
        if (!_matchedIds.contains(id)) _pairById(id),
    ];
  }

  WordMatchPair _pairById(String id) {
    return _roundPairs.firstWhere((pair) => pair.id == id);
  }

  void _resetForSelection(String sourceKey) {
    _roundSourceKey = sourceKey;
    _roundPairs = const <WordMatchPair>[];
    _visibleIds = const <String>[];
    _translationIds = const <String>[];
    _matchedIds = <String>{};
    _hasStarted = false;
    _feedback = null;
  }

  void _selectSource(GameWordSource source) {
    if (_selectedSource == source) return;
    setState(() {
      _selectedSource = source;
      _resetForSelection('');
    });
  }

  void _startNewSet(List<WordMatchPair> pairs) {
    final selected = pairs.length > 16 ? ([...pairs]..shuffle(_random)) : pairs;
    _roundPairs = List<WordMatchPair>.unmodifiable(
      selected.take(_effectiveWordsPerRound(pairs.length)),
    );
    _progressRepository.markPlayedIds(
      'word-match',
      _selectedSource.key,
      _roundPairs.map((pair) => pair.id),
    );
    _beginCurrentSet();
  }

  void _replaySameSet() {
    _beginCurrentSet();
  }

  int _effectiveWordsPerRound(int available) {
    return clampWordsPerRound(
      requested: _wordsPerRound,
      minimum: 6,
      available: available,
    );
  }

  void _selectWordsPerRound(int count) {
    if (_wordsPerRound == count) return;
    setState(() {
      _wordsPerRound = count;
      _resetForSelection('');
    });
  }

  void _beginCurrentSet() {
    _matchedIds = <String>{};
    _visibleIds = List<String>.unmodifiable(
      _roundPairs.take(6).map((pair) => pair.id),
    );
    _translationIds = mixWordMatchTranslations(_visibleIds, random: _random);
    _feedback = null;
    _hasStarted = true;
  }

  void _matchPair(
    WordMatchDragData data,
    WordMatchPair target,
    WordMatchCardSide targetSide,
  ) {
    if (_matchedIds.contains(data.pairId) ||
        _matchedIds.contains(target.id) ||
        data.side == targetSide) {
      return;
    }

    if (data.pairId != target.id) {
      HapticFeedback.lightImpact();
      setState(() => _feedback = 'Falsch');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _matchedIds = {..._matchedIds, target.id};
      _feedback = 'Richtig';
      _replenishVisiblePair();
    });
  }

  void _replenishVisiblePair() {
    final nextPair = _roundPairs.where((pair) {
      return !_visibleIds.contains(pair.id) && !_matchedIds.contains(pair.id);
    }).firstOrNull;
    if (nextPair == null) {
      _translationIds = mixWordMatchTranslations(
        _visibleIds.where((id) => !_matchedIds.contains(id)).toList(),
        random: _random,
      );
      return;
    }

    final nextVisible = [
      for (final id in _visibleIds)
        if (!_matchedIds.contains(id)) id,
      nextPair.id,
    ];
    _visibleIds = List<String>.unmodifiable(nextVisible);
    _translationIds = mixWordMatchTranslations(nextVisible, random: _random);
  }
}

@visibleForTesting
List<WordMatchPair> buildWordMatchPairs(List<LocalWord> words) {
  final pairs = <WordMatchPair>[];
  final seenTerms = <String>{};
  final seenTranslations = <String>{};

  for (final word in words) {
    final term = word.term.trim();
    final translation = word.translation.trim();
    if (term.isEmpty || translation.isEmpty || word.isArchived) continue;

    final normalizedTerm = normalizeWordMatchText(term);
    final normalizedTranslation = normalizeWordMatchText(translation);
    if (!seenTerms.add(normalizedTerm)) continue;
    if (!seenTranslations.add(normalizedTranslation)) continue;

    pairs.add(WordMatchPair(id: word.id, term: term, translation: translation));
  }

  return List<WordMatchPair>.unmodifiable(pairs);
}

@visibleForTesting
List<String> mixWordMatchTranslations(List<String> ids, {Random? random}) {
  final mixed = [...ids];
  if (mixed.length <= 1) return List<String>.unmodifiable(mixed);
  mixed.shuffle(random);
  if (mixed.length > 2 && _listEquals(mixed, ids)) {
    mixed
      ..removeAt(0)
      ..add(ids.first);
  }
  return List<String>.unmodifiable(mixed);
}

bool _listEquals<T>(List<T> left, List<T> right) {
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) return false;
  }
  return true;
}

@visibleForTesting
String normalizeWordMatchText(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

class WordMatchPair {
  const WordMatchPair({
    required this.id,
    required this.term,
    required this.translation,
  });

  final String id;
  final String term;
  final String translation;
}

class WordMatchDragData {
  const WordMatchDragData({required this.pairId, required this.side});

  final String pairId;
  final WordMatchCardSide side;
}

enum WordMatchCardSide { term, translation }

class GameWordSource {
  const GameWordSource._({
    required this.key,
    required this.label,
    required this.source,
    this.categoryId,
  });

  factory GameWordSource.standard(LocalLearningSource source) {
    return GameWordSource._(
      key: 'source:${source.id}',
      label: source.label,
      source: source,
    );
  }

  final String key;
  final String label;
  final LocalLearningSource source;
  final String? categoryId;

  @override
  bool operator ==(Object other) {
    return other is GameWordSource && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}

class _StartView extends StatelessWidget {
  const _StartView({
    required this.selectedSource,
    required this.categories,
    required this.availableIds,
    required this.wordsPerRound,
    required this.soundEnabled,
    required this.onSourceSelected,
    required this.onWordsPerRoundChanged,
    required this.onToggleSound,
    required this.onStart,
  });

  final GameWordSource selectedSource;
  final List<LocalCategory> categories;
  final List<String> availableIds;
  final int wordsPerRound;
  final bool soundEnabled;
  final ValueChanged<GameWordSource> onSourceSelected;
  final ValueChanged<int> onWordsPerRoundChanged;
  final VoidCallback onToggleSound;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF5DDCFF)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5DDCFF).withValues(alpha: 0.16),
                blurRadius: 34,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.hub_rounded, color: Color(0xFF5DDCFF), size: 46),
              const SizedBox(height: 16),
              const Text(
                'Wort-Match',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Ziehe Wörter auf die passende Übersetzung.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              _WordSourcePicker(
                selectedSource: selectedSource,
                categories: categories,
                availableIds: availableIds,
                wordsPerRound: wordsPerRound,
                onSourceSelected: onSourceSelected,
                onWordsPerRoundChanged: onWordsPerRoundChanged,
              ),
              const SizedBox(height: 14),
              _SoundToggle(soundEnabled: soundEnabled, onToggle: onToggleSound),
              const SizedBox(height: 22),
              FilledButton(
                key: const ValueKey('word-match-start-button'),
                onPressed: onStart,
                style: _primaryButtonStyle(),
                child: const Text('Starten'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MatchPlayView extends StatelessWidget {
  const _MatchPlayView({
    required this.wordPairs,
    required this.translationPairs,
    required this.doneCount,
    required this.totalCount,
    required this.selectedSource,
    required this.soundEnabled,
    required this.feedback,
    required this.onDragStarted,
    required this.onAccept,
  });

  final List<WordMatchPair> wordPairs;
  final List<WordMatchPair> translationPairs;
  final int doneCount;
  final int totalCount;
  final GameWordSource selectedSource;
  final bool soundEnabled;
  final String? feedback;
  final VoidCallback onDragStarted;
  final void Function(
    WordMatchDragData data,
    WordMatchPair target,
    WordMatchCardSide targetSide,
  )
  onAccept;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _ProgressHeader(
          doneCount: doneCount,
          totalCount: totalCount,
          selectedSource: selectedSource,
          soundEnabled: soundEnabled,
        ),
        const SizedBox(height: 18),
        _FloatingBoard(
          wordPairs: wordPairs,
          translationPairs: translationPairs,
          feedback: feedback,
          onDragStarted: onDragStarted,
          onAccept: onAccept,
        ),
      ],
    );
  }
}

class _FloatingBoard extends StatelessWidget {
  const _FloatingBoard({
    required this.wordPairs,
    required this.translationPairs,
    required this.feedback,
    required this.onDragStarted,
    required this.onAccept,
  });

  final List<WordMatchPair> wordPairs;
  final List<WordMatchPair> translationPairs;
  final String? feedback;
  final VoidCallback onDragStarted;
  final void Function(
    WordMatchDragData data,
    WordMatchPair target,
    WordMatchCardSide targetSide,
  )
  onAccept;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('word-match-board'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07111F), Color(0xFF0D1828)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF5DDCFF).withValues(alpha: 0.48),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Spielfeld',
            style: TextStyle(
              color: Color(0xFFF4F8FF),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Halte eine Karte und ziehe sie auf ihr passendes Gegenstück.',
            style: TextStyle(
              color: Color(0xFFB8C7D9),
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          const _BoardLabel(text: 'Wörter'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: [
              for (var i = 0; i < wordPairs.length; i++)
                Transform.translate(
                  offset: Offset(i.isEven ? 0 : 8, 0),
                  child: _MatchDraggableTargetCard(
                    pair: wordPairs[i],
                    side: WordMatchCardSide.term,
                    onDragStarted: onDragStarted,
                    onAccept: onAccept,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _BoardFeedbackPill(feedback: feedback),
          const SizedBox(height: 16),
          const _BoardLabel(text: 'Übersetzungen'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: [
              for (var i = 0; i < translationPairs.length; i++)
                Transform.translate(
                  offset: Offset(i.isEven ? 8 : 0, 0),
                  child: _MatchDraggableTargetCard(
                    pair: translationPairs[i],
                    side: WordMatchCardSide.translation,
                    onDragStarted: onDragStarted,
                    onAccept: onAccept,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatchDraggableTargetCard extends StatelessWidget {
  const _MatchDraggableTargetCard({
    required this.pair,
    required this.side,
    required this.onDragStarted,
    required this.onAccept,
  });

  final WordMatchPair pair;
  final WordMatchCardSide side;
  final VoidCallback onDragStarted;
  final void Function(
    WordMatchDragData data,
    WordMatchPair target,
    WordMatchCardSide targetSide,
  )
  onAccept;

  @override
  Widget build(BuildContext context) {
    final isTerm = side == WordMatchCardSide.term;
    final cardKey = ValueKey(
      isTerm
          ? 'word-match-term-${pair.id}'
          : 'word-match-translation-${pair.id}',
    );
    final text = isTerm ? pair.term : pair.translation;
    final baseColor = isTerm
        ? const Color(0xFF5DDCFF)
        : const Color(0xFFFFD166);
    final baseIcon = isTerm
        ? Icons.drag_indicator_rounded
        : Icons.flag_circle_rounded;

    Widget buildCard({required bool highlighted, required bool lifted}) {
      return _FloatingCard(
        key: cardKey,
        text: text,
        icon: highlighted ? Icons.ads_click_rounded : baseIcon,
        color: highlighted ? const Color(0xFF9DFF7D) : baseColor,
        target: !isTerm,
        lifted: lifted,
      );
    }

    return DragTarget<WordMatchDragData>(
      onWillAcceptWithDetails: (details) => details.data.side != side,
      builder: (context, candidateData, rejectedData) {
        final child = buildCard(
          highlighted: candidateData.isNotEmpty,
          lifted: false,
        );
        return LongPressDraggable<WordMatchDragData>(
          data: WordMatchDragData(pairId: pair.id, side: side),
          dragAnchorStrategy: childDragAnchorStrategy,
          onDragStarted: onDragStarted,
          feedback: Material(
            color: Colors.transparent,
            child: buildCard(highlighted: false, lifted: true),
          ),
          childWhenDragging: child,
          child: child,
        );
      },
      onAcceptWithDetails: (details) => onAccept(details.data, pair, side),
    );
  }
}

class _FloatingCard extends StatelessWidget {
  const _FloatingCard({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    this.target = false,
    this.lifted = false,
  });

  final String text;
  final IconData icon;
  final Color color;
  final bool target;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 148,
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: target ? const Color(0xFF100F1A) : const Color(0xFF061527),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.72), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: lifted ? 0.32 : 0.12),
            blurRadius: lifted ? 24 : 14,
            spreadRadius: lifted ? -1 : -4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 8),
          Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFF4F8FF),
              fontWeight: FontWeight.w900,
              height: 1.12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardLabel extends StatelessWidget {
  const _BoardLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF7DFFE3),
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.doneCount,
    required this.totalCount,
    required this.selectedSource,
    required this.soundEnabled,
  });

  final int doneCount;
  final int totalCount;
  final GameWordSource selectedSource;
  final bool soundEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF26354B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.hub_rounded, color: Color(0xFF5DDCFF)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$doneCount / $totalCount verbunden',
                  style: const TextStyle(
                    color: Color(0xFFF4F8FF),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                soundEnabled ? 'Sound: An' : 'Sound: Aus',
                style: const TextStyle(
                  color: Color(0xFF7DFFE3),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            selectedSource.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFB8C7D9),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _WordSourcePicker extends StatelessWidget {
  const _WordSourcePicker({
    required this.selectedSource,
    required this.categories,
    this.availableIds = const <String>[],
    this.wordsPerRound = 10,
    required this.onSourceSelected,
    this.onWordsPerRoundChanged,
  });

  final GameWordSource selectedSource;
  final List<LocalCategory> categories;
  final List<String> availableIds;
  final int wordsPerRound;
  final ValueChanged<GameWordSource> onSourceSelected;
  final ValueChanged<int>? onWordsPerRoundChanged;

  @override
  Widget build(BuildContext context) {
    return game_picker.GameWordSourcePicker(
      keyPrefix: 'word-match',
      selectedSource: _toSharedSource(selectedSource),
      categories: categories,
      availableIds: availableIds,
      wordsPerRound: wordsPerRound,
      minWordsPerRound: 6,
      accentColor: const Color(0xFF7DFFE3),
      secondaryAccentColor: const Color(0xFFFFD166),
      onWordsPerRoundChanged: onWordsPerRoundChanged,
      onSourceSelected: (source) => onSourceSelected(_fromSharedSource(source)),
    );
  }

  game_picker.GameWordSource _toSharedSource(GameWordSource source) {
    return game_picker.GameWordSource.custom(
      key: source.key,
      label: source.label,
      source: source.source,
      categoryId: source.categoryId,
    );
  }

  GameWordSource _fromSharedSource(game_picker.GameWordSource source) {
    return GameWordSource._(
      key: source.key,
      label: source.label,
      source: source.source,
      categoryId: source.categoryId,
    );
  }
}

class _SoundToggle extends StatelessWidget {
  const _SoundToggle({required this.soundEnabled, required this.onToggle});

  final bool soundEnabled;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: const ValueKey('word-match-sound-toggle'),
      onPressed: onToggle,
      style: _secondaryButtonStyle(),
      icon: Icon(soundEnabled ? Icons.volume_up_rounded : Icons.volume_off),
      label: Text(soundEnabled ? 'Sound: An' : 'Sound: Aus'),
    );
  }
}

class _BoardFeedbackPill extends StatelessWidget {
  const _BoardFeedbackPill({required this.feedback});

  final String? feedback;

  @override
  Widget build(BuildContext context) {
    final text = feedback ?? 'Ziehe eine Karte auf ihr Gegenstück';
    final isPositive = feedback == 'Richtig';
    final color = isPositive
        ? const Color(0xFF9DFF7D)
        : feedback == 'Falsch'
        ? const Color(0xFFFF7A8A)
        : const Color(0xFF7DFFE3);
    return AnimatedContainer(
      key: const ValueKey('word-match-feedback'),
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: feedback == null ? 0.08 : 0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: feedback == null ? 0.28 : 0.52),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPositive
                ? Icons.check_circle_rounded
                : feedback == 'Falsch'
                ? Icons.cancel_rounded
                : Icons.touch_app_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinishedView extends StatelessWidget {
  const _FinishedView({
    required this.solvedCount,
    required this.totalCount,
    required this.onReplay,
    required this.onNewSet,
    required this.onBack,
  });

  final int solvedCount;
  final int totalCount;
  final VoidCallback onReplay;
  final VoidCallback onNewSet;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFF7DFFE3)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7DFFE3).withValues(alpha: 0.14),
                blurRadius: 30,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFFFD166),
                size: 44,
              ),
              const SizedBox(height: 16),
              const Text(
                'Set geschafft',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Du hast $solvedCount von $totalCount Wortpaaren verbunden.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                key: const ValueKey('word-match-replay-button'),
                onPressed: onReplay,
                style: _primaryButtonStyle(),
                child: const Text('Gleiches Set wiederholen'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const ValueKey('word-match-new-set-button'),
                onPressed: onNewSet,
                style: _secondaryButtonStyle(),
                child: const Text('Neues Set'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const ValueKey('word-match-back-button'),
                onPressed: onBack,
                style: _secondaryButtonStyle(),
                child: const Text('Zurück zu Wortspiele'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WordMatchMessageState extends StatelessWidget {
  const _WordMatchMessageState({
    required this.title,
    required this.text,
    required this.buttonLabel,
    required this.onPressed,
    this.selectedSource,
    this.categories = const <LocalCategory>[],
    this.onSourceSelected,
  });

  final String title;
  final String text;
  final String buttonLabel;
  final VoidCallback onPressed;
  final GameWordSource? selectedSource;
  final List<LocalCategory> categories;
  final ValueChanged<GameWordSource>? onSourceSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF5DDCFF)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.hub_rounded, color: Color(0xFF5DDCFF), size: 40),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 22,
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
                _WordSourcePicker(
                  selectedSource: selectedSource!,
                  categories: categories,
                  onSourceSelected: onSourceSelected!,
                ),
              ],
              const SizedBox(height: 22),
              FilledButton(
                onPressed: onPressed,
                style: _primaryButtonStyle(),
                child: Text(buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

ButtonStyle _primaryButtonStyle() {
  return FilledButton.styleFrom(
    backgroundColor: const Color(0xFF7DFFE3),
    foregroundColor: const Color(0xFF041018),
    padding: const EdgeInsets.symmetric(vertical: 15),
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}

ButtonStyle _secondaryButtonStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFFF4F8FF),
    side: const BorderSide(color: Color(0xFF5DDCFF)),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    textStyle: const TextStyle(fontWeight: FontWeight.w800),
  );
}
