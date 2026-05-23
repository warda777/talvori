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

class WordMatchGameScreen extends ConsumerStatefulWidget {
  const WordMatchGameScreen({super.key});

  static const routeName = 'word-match-game';

  @override
  ConsumerState<WordMatchGameScreen> createState() =>
      _WordMatchGameScreenState();
}

class _WordMatchGameScreenState extends ConsumerState<WordMatchGameScreen> {
  WordMatchWordSource _selectedSource = WordMatchWordSource.standard(
    LocalLearningSource.allWords,
  );
  final Random _random = Random();
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
                soundEnabled: _soundEnabled,
                onSourceSelected: _selectSource,
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

  void _selectSource(WordMatchWordSource source) {
    if (_selectedSource == source) return;
    setState(() {
      _selectedSource = source;
      _resetForSelection('');
    });
  }

  void _startNewSet(List<WordMatchPair> pairs) {
    final selected = pairs.length > 16 ? ([...pairs]..shuffle(_random)) : pairs;
    _roundPairs = List<WordMatchPair>.unmodifiable(selected.take(16));
    _beginCurrentSet();
  }

  void _replaySameSet() {
    _beginCurrentSet();
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

class WordMatchWordSource {
  const WordMatchWordSource._({
    required this.key,
    required this.label,
    required this.source,
    this.categoryId,
  });

  factory WordMatchWordSource.standard(LocalLearningSource source) {
    return WordMatchWordSource._(
      key: 'source:${source.id}',
      label: source.label,
      source: source,
    );
  }

  factory WordMatchWordSource._wordWorld(
    _WordMatchWordWorld world,
    List<LocalCategory> categories,
  ) {
    return WordMatchWordSource._(
      key: 'world:${world.key}',
      label: 'Wortwelt: ${world.name}',
      source: LocalLearningSource.allWords,
      categoryId: world.resolveCategoryId(categories),
    );
  }

  final String key;
  final String label;
  final LocalLearningSource source;
  final String? categoryId;

  @override
  bool operator ==(Object other) {
    return other is WordMatchWordSource && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}

const _standardWordMatchSources = <LocalLearningSource>[
  LocalLearningSource.allWords,
  LocalLearningSource.myWords,
  LocalLearningSource.favorites,
  LocalLearningSource.myMix,
];

const _wordMatchWordWorldGroups = <_WordMatchWordWorldGroup>[
  _WordMatchWordWorldGroup('Alltag & Leben', [
    _WordMatchWordWorld(
      key: 'health_fitness',
      name: 'Health & Fitness',
      localCategoryId: 'seed-category-basics',
    ),
    _WordMatchWordWorld(key: 'home_living', name: 'Home & Living'),
    _WordMatchWordWorld(key: 'food_cooking', name: 'Food & Cooking'),
    _WordMatchWordWorld(key: 'style_fashion', name: 'Style & Fashion'),
    _WordMatchWordWorld(key: 'money_shopping', name: 'Money & Shopping'),
    _WordMatchWordWorld(key: 'productivity', name: 'Productivity'),
  ]),
  _WordMatchWordWorldGroup('Mensch & Gesellschaft', [
    _WordMatchWordWorld(key: 'personality', name: 'Personality'),
    _WordMatchWordWorld(key: 'feelings', name: 'Feelings'),
    _WordMatchWordWorld(key: 'relationships', name: 'Relationships'),
    _WordMatchWordWorld(key: 'thoughts', name: 'Thoughts'),
    _WordMatchWordWorld(key: 'law_politics', name: 'Law & Politics'),
    _WordMatchWordWorld(key: 'environment', name: 'Environment'),
  ]),
  _WordMatchWordWorldGroup('Wissen & Bildung', [
    _WordMatchWordWorld(key: 'school_studies', name: 'School & Studies'),
    _WordMatchWordWorld(key: 'science', name: 'Science'),
    _WordMatchWordWorld(key: 'space', name: 'Space'),
    _WordMatchWordWorld(key: 'nature', name: 'Nature'),
    _WordMatchWordWorld(key: 'animals', name: 'Animals'),
    _WordMatchWordWorld(key: 'tech_innovation', name: 'Tech & Innovation'),
  ]),
  _WordMatchWordWorldGroup('Medien & Freizeit', [
    _WordMatchWordWorld(key: 'media_news', name: 'Media & News'),
    _WordMatchWordWorld(key: 'sports', name: 'Sports'),
    _WordMatchWordWorld(
      key: 'travel',
      name: 'Travel',
      localCategoryId: 'seed-category-travel',
    ),
    _WordMatchWordWorld(key: 'gaming', name: 'Gaming'),
    _WordMatchWordWorld(key: 'transport', name: 'Transport'),
    _WordMatchWordWorld(
      key: 'music_entertainment',
      name: 'Music & Entertainment',
    ),
    _WordMatchWordWorld(key: 'art_literature', name: 'Art & Literature'),
  ]),
  _WordMatchWordWorldGroup('Beruf & Sprache', [
    _WordMatchWordWorld(key: 'work_careers', name: 'Work & Careers'),
    _WordMatchWordWorld(key: 'top_500', name: 'Top 500 Words'),
    _WordMatchWordWorld(key: 'a1', name: 'A1'),
    _WordMatchWordWorld(key: 'a2', name: 'A2'),
    _WordMatchWordWorld(key: 'b1', name: 'B1'),
    _WordMatchWordWorld(key: 'b2', name: 'B2'),
    _WordMatchWordWorld(key: 'c1', name: 'C1'),
    _WordMatchWordWorld(key: 'c2', name: 'C2'),
  ]),
];

class _WordMatchWordWorldGroup {
  const _WordMatchWordWorldGroup(this.title, this.worlds);

  final String title;
  final List<_WordMatchWordWorld> worlds;
}

class _WordMatchWordWorld {
  const _WordMatchWordWorld({
    required this.key,
    required this.name,
    this.localCategoryId,
  });

  final String key;
  final String name;
  final String? localCategoryId;

  String resolveCategoryId(List<LocalCategory> categories) {
    final normalizedName = normalizeWordMatchText(name);
    for (final category in categories) {
      if (normalizeWordMatchText(category.name) == normalizedName) {
        return category.id;
      }
    }
    return localCategoryId ?? 'word-world-$key';
  }
}

class _StartView extends StatelessWidget {
  const _StartView({
    required this.selectedSource,
    required this.categories,
    required this.soundEnabled,
    required this.onSourceSelected,
    required this.onToggleSound,
    required this.onStart,
  });

  final WordMatchWordSource selectedSource;
  final List<LocalCategory> categories;
  final bool soundEnabled;
  final ValueChanged<WordMatchWordSource> onSourceSelected;
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
                onSourceSelected: onSourceSelected,
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
  final WordMatchWordSource selectedSource;
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
  final WordMatchWordSource selectedSource;
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
    required this.onSourceSelected,
  });

  final WordMatchWordSource selectedSource;
  final List<LocalCategory> categories;
  final ValueChanged<WordMatchWordSource> onSourceSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('word-match-source-picker'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF050912),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF26354B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Du spielst mit',
            style: TextStyle(
              color: Color(0xFFB8C7D9),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            selectedSource.label,
            key: const ValueKey('word-match-selected-source-label'),
            style: const TextStyle(
              color: Color(0xFFF4F8FF),
              fontSize: 18,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _PickerActionButton(
            key: const ValueKey('word-match-change-source-button'),
            icon: Icons.folder_copy_rounded,
            title: 'Wortquelle ändern',
            subtitle: 'Alle Wörter, Meine Wörter, Favoriten oder Mein Mix',
            onTap: () => _showSourceSheet(context),
          ),
          const SizedBox(height: 10),
          _PickerActionButton(
            key: const ValueKey('word-match-select-world-button'),
            icon: Icons.public_rounded,
            title: 'Wortwelt auswählen',
            subtitle: 'Spiele mit einer festen Talvori-Wortwelt',
            onTap: () => _showWordWorldSheet(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showSourceSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _WordMatchSheetFrame(
          title: 'Wortquelle ändern',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final source in _standardWordMatchSources)
                _SheetOption(
                  key: ValueKey('word-match-source-${source.id}'),
                  title: source.label,
                  selected:
                      selectedSource == WordMatchWordSource.standard(source),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSourceSelected(WordMatchWordSource.standard(source));
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showWordWorldSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _WordMatchSheetFrame(
          title: 'Wortwelt auswählen',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final group in _wordMatchWordWorldGroups) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
                  child: Text(
                    group.title,
                    style: const TextStyle(
                      color: Color(0xFF5DDCFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                for (final world in group.worlds)
                  Builder(
                    builder: (context) {
                      final source = WordMatchWordSource._wordWorld(
                        world,
                        categories,
                      );
                      return _SheetOption(
                        key: ValueKey('word-match-word-world-${world.key}'),
                        title: world.name,
                        selected: selectedSource == source,
                        onTap: () {
                          Navigator.of(context).pop();
                          onSourceSelected(source);
                        },
                      );
                    },
                  ),
              ],
            ],
          ),
        );
      },
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

class _PickerActionButton extends StatelessWidget {
  const _PickerActionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: _secondaryButtonStyle(),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WordMatchSheetFrame extends StatelessWidget {
  const _WordMatchSheetFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.82;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1220),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFF5DDCFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFF4F8FF),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(child: SingleChildScrollView(child: child)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF102837)
                  : const Color(0xFF050912),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? const Color(0xFF7DFFE3)
                    : const Color(0xFF26354B),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFF4F8FF),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF7DFFE3),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
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
  final WordMatchWordSource? selectedSource;
  final List<LocalCategory> categories;
  final ValueChanged<WordMatchWordSource>? onSourceSelected;

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
