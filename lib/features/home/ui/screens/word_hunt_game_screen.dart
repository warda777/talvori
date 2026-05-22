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

class WordHuntGameScreen extends ConsumerStatefulWidget {
  const WordHuntGameScreen({
    super.key,
    this.random,
    this.waveDuration,
    this.maxWavesPerTarget = 4,
    this.maxTargets = 20,
  });

  static const routeName = 'word-hunt-game';

  final Random? random;
  final Duration? waveDuration;
  final int maxWavesPerTarget;
  final int maxTargets;

  @override
  ConsumerState<WordHuntGameScreen> createState() => _WordHuntGameScreenState();
}

class _WordHuntGameScreenState extends ConsumerState<WordHuntGameScreen> {
  WordHuntWordSource _selectedSource = WordHuntWordSource.standard(
    LocalLearningSource.allWords,
  );
  WordHuntSpeed _selectedSpeed = WordHuntSpeed.medium;
  List<WordHuntPair> _roundPairs = const <WordHuntPair>[];
  List<int> _answerShifts = const <int>[];
  String _roundKey = '';
  int _currentQuestionIndex = 0;
  int _waveIndex = 0;
  int _hitCount = 0;
  int _lives = 10;
  bool _started = false;
  bool _finished = false;
  String? _feedback;
  _WordHuntFinishReason _finishReason = _WordHuntFinishReason.completed;
  Timer? _waveTimer;

  @override
  void dispose() {
    _waveTimer?.cancel();
    super.dispose();
  }

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
        title: const Text('Wort-Jagd'),
      ),
      body: SafeArea(
        child: wordsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF7AB6)),
          ),
          error: (_, __) => _WordHuntMessageState(
            title: 'Wörter konnten nicht geladen werden',
            text: 'Versuche es gleich noch einmal.',
            buttonLabel: 'Zurück',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          data: (words) {
            final categories = categoriesAsync.value ?? const <LocalCategory>[];
            final pairs = buildWordHuntPairs(words);
            if (pairs.length < 4) {
              return _WordHuntMessageState(
                title: 'Noch nicht genug Wörter',
                text: _selectedSource.categoryId == null
                    ? 'Diese Wortquelle braucht mindestens vier Wörter mit Übersetzung, um Wort-Jagd zu spielen.\n\nWähle eine andere Wortquelle oder füge neue Wörter hinzu.'
                    : 'Diese Wortwelt braucht mindestens vier Wörter mit Übersetzung, um Wort-Jagd zu spielen.\n\nWähle eine andere Auswahl oder füge neue Wörter hinzu.',
                buttonLabel: 'Zurück',
                selectedSource: _selectedSource,
                categories: categories,
                onSourceSelected: _selectSource,
                onPressed: () => Navigator.of(context).maybePop(),
              );
            }

            _ensureRound(pairs);
            if (_finished) {
              return _FinishedView(
                hitCount: _hitCount,
                totalCount: _roundPairs.length,
                finishReason: _finishReason,
                onRestart: () => setState(() => _restartRound(pairs)),
                onBack: () => Navigator.of(context).maybePop(),
              );
            }

            if (!_started) {
              return _StartView(
                selectedSource: _selectedSource,
                selectedSpeed: _selectedSpeed,
                categories: categories,
                onSourceSelected: _selectSource,
                onSpeedSelected: _selectSpeed,
                onStart: _startRound,
              );
            }

            final question = buildWordHuntQuestion(
              pairs: _roundPairs,
              questionIndex: _currentQuestionIndex,
              waveIndex: _waveIndex,
              answerShift: _answerShifts[_currentQuestionIndex],
            );
            return _QuestionView(
              question: question,
              currentIndex: _currentQuestionIndex,
              totalCount: _roundPairs.length,
              hitCount: _hitCount,
              lives: _lives,
              feedback: _feedback,
              onAnswer: _answer,
            );
          },
        ),
      ),
    );
  }

  void _ensureRound(List<WordHuntPair> pairs) {
    final nextKey =
        '${_selectedSource.key}:${pairs.map((pair) => pair.id).join('|')}';
    if (_roundKey == nextKey && _roundPairs.isNotEmpty) return;
    _roundKey = nextKey;
    _restartRound(pairs);
  }

  void _selectSource(WordHuntWordSource source) {
    if (_selectedSource == source) return;
    setState(() {
      _waveTimer?.cancel();
      _selectedSource = source;
      _roundPairs = const <WordHuntPair>[];
      _answerShifts = const <int>[];
      _roundKey = '';
      _currentQuestionIndex = 0;
      _waveIndex = 0;
      _hitCount = 0;
      _lives = 10;
      _started = false;
      _finished = false;
      _feedback = null;
      _finishReason = _WordHuntFinishReason.completed;
    });
  }

  void _selectSpeed(WordHuntSpeed speed) {
    if (_selectedSpeed == speed) return;
    setState(() {
      _selectedSpeed = speed;
    });
  }

  void _restartRound(List<WordHuntPair> pairs) {
    _waveTimer?.cancel();
    final random = widget.random ?? Random();
    _roundPairs = selectWordHuntRoundPairs(
      pairs,
      random: random,
      maxTargets: widget.maxTargets,
    );
    _answerShifts = List<int>.unmodifiable(
      List<int>.generate(_roundPairs.length, (_) => random.nextInt(4)),
    );
    _currentQuestionIndex = 0;
    _waveIndex = 0;
    _hitCount = 0;
    _lives = 10;
    _started = false;
    _finished = false;
    _feedback = null;
    _finishReason = _WordHuntFinishReason.completed;
  }

  void _startRound() {
    setState(() {
      _started = true;
      _finished = false;
      _currentQuestionIndex = 0;
      _waveIndex = 0;
      _hitCount = 0;
      _lives = 10;
      _feedback = null;
      _finishReason = _WordHuntFinishReason.completed;
    });
    _startWaveTimer();
  }

  void _startWaveTimer() {
    _waveTimer?.cancel();
    _waveTimer = Timer.periodic(_activeWaveDuration, (_) {
      if (!mounted || !_started || _finished) return;
      setState(() {
        if (_waveIndex >= widget.maxWavesPerTarget - 1) {
          _feedback = 'Entwischt.';
          _lives = max(0, _lives - 1);
          _advanceAfterResult(wasLifeLost: true);
          return;
        }
        _waveIndex += 1;
      });
    });
  }

  void _answer(WordHuntAnswer answer) {
    if (!_started || _finished) return;
    setState(() {
      if (answer.isCorrect) {
        _hitCount += 1;
        _lives = min(10, _lives + 1);
        _feedback = 'Treffer!';
      } else {
        _lives = max(0, _lives - 1);
        _feedback = 'Daneben.';
      }
      _advanceAfterResult(wasLifeLost: !answer.isCorrect);
    });
  }

  void _advanceAfterResult({required bool wasLifeLost}) {
    _waveTimer?.cancel();
    if (wasLifeLost && _lives <= 0) {
      _finishRound(_WordHuntFinishReason.noLives);
      return;
    }
    if (_currentQuestionIndex >= _roundPairs.length - 1) {
      _finishRound(_WordHuntFinishReason.completed);
      return;
    }
    _currentQuestionIndex += 1;
    _waveIndex = 0;
    _startWaveTimer();
  }

  void _finishRound(_WordHuntFinishReason reason) {
    _waveTimer?.cancel();
    _started = false;
    _finished = true;
    _finishReason = reason;
  }

  Duration get _activeWaveDuration =>
      widget.waveDuration ?? _selectedSpeed.duration;
}

@visibleForTesting
List<WordHuntPair> buildWordHuntPairs(List<LocalWord> words) {
  final pairs = <WordHuntPair>[];
  final seenTerms = <String>{};
  final seenTranslations = <String>{};

  for (final word in words) {
    final term = word.term.trim();
    final translation = word.translation.trim();
    if (term.isEmpty || translation.isEmpty || word.isArchived) continue;

    final normalizedTerm = normalizeWordHuntText(term);
    final normalizedTranslation = normalizeWordHuntText(translation);
    if (!seenTerms.add(normalizedTerm)) continue;
    if (!seenTranslations.add(normalizedTranslation)) continue;

    pairs.add(WordHuntPair(id: word.id, term: term, translation: translation));
  }

  return List<WordHuntPair>.unmodifiable(pairs);
}

@visibleForTesting
List<WordHuntPair> selectWordHuntRoundPairs(
  List<WordHuntPair> pairs, {
  required Random random,
  int maxTargets = 20,
}) {
  final shuffled = List<WordHuntPair>.of(pairs)..shuffle(random);
  return List<WordHuntPair>.unmodifiable(shuffled.take(maxTargets));
}

@visibleForTesting
WordHuntQuestion buildWordHuntQuestion({
  required List<WordHuntPair> pairs,
  required int questionIndex,
  int waveIndex = 0,
  int answerShift = 0,
}) {
  final correct = pairs[questionIndex % pairs.length];
  final distractors = <WordHuntPair>[];
  for (var offset = waveIndex + 1; distractors.length < 3; offset += 1) {
    final candidate = pairs[(questionIndex + offset) % pairs.length];
    if (candidate.id == correct.id) continue;
    if (distractors.any((pair) => pair.id == candidate.id)) continue;
    distractors.add(candidate);
  }

  final rawAnswers = <WordHuntAnswer>[
    WordHuntAnswer(pairId: correct.id, text: correct.translation),
    for (final pair in distractors)
      WordHuntAnswer(pairId: pair.id, text: pair.translation),
  ];
  final shift = (answerShift + waveIndex) % rawAnswers.length;
  final answers = <WordHuntAnswer>[
    ...rawAnswers.skip(shift),
    ...rawAnswers.take(shift),
  ];

  return WordHuntQuestion(
    correctPairId: correct.id,
    prompt: correct.term,
    answers: List<WordHuntAnswer>.unmodifiable(
      answers.map(
        (answer) => WordHuntAnswer(
          pairId: answer.pairId,
          text: answer.text,
          isCorrect: answer.pairId == correct.id,
        ),
      ),
    ),
  );
}

@visibleForTesting
String normalizeWordHuntText(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

class WordHuntPair {
  const WordHuntPair({
    required this.id,
    required this.term,
    required this.translation,
  });

  final String id;
  final String term;
  final String translation;
}

class WordHuntQuestion {
  const WordHuntQuestion({
    required this.correctPairId,
    required this.prompt,
    required this.answers,
  });

  final String correctPairId;
  final String prompt;
  final List<WordHuntAnswer> answers;
}

class WordHuntAnswer {
  const WordHuntAnswer({
    required this.pairId,
    required this.text,
    this.isCorrect = false,
  });

  final String pairId;
  final String text;
  final bool isCorrect;
}

enum _WordHuntFinishReason { completed, noLives }

enum WordHuntSpeed {
  relaxed('Entspannt', Duration(milliseconds: 2200)),
  slow('Langsam', Duration(milliseconds: 1800)),
  medium('Mittel', Duration(milliseconds: 1400)),
  fast('Schnell', Duration(milliseconds: 1100));

  const WordHuntSpeed(this.label, this.duration);

  final String label;
  final Duration duration;
}

class WordHuntWordSource {
  const WordHuntWordSource._({
    required this.label,
    required this.source,
    required this.categoryId,
    required this.worldKey,
  });

  factory WordHuntWordSource.standard(LocalLearningSource source) {
    return WordHuntWordSource._(
      label: source.label,
      source: source,
      categoryId: null,
      worldKey: null,
    );
  }

  factory WordHuntWordSource._wordWorld(
    _WordHuntWordWorld world,
    List<LocalCategory> categories,
  ) {
    return WordHuntWordSource._(
      label: 'Wortwelt: ${world.name}',
      source: LocalLearningSource.allWords,
      categoryId: world.resolveCategoryId(categories),
      worldKey: world.key,
    );
  }

  final String label;
  final LocalLearningSource source;
  final String? categoryId;
  final String? worldKey;

  String get key => worldKey == null ? source.id : 'word-world:$worldKey';

  @override
  bool operator ==(Object other) {
    return other is WordHuntWordSource && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}

const _standardWordHuntSources = <LocalLearningSource>[
  LocalLearningSource.allWords,
  LocalLearningSource.myWords,
  LocalLearningSource.favorites,
  LocalLearningSource.myMix,
];

const _wordHuntWordWorldGroups = <_WordHuntWordWorldGroup>[
  _WordHuntWordWorldGroup('Alltag & Leben', [
    _WordHuntWordWorld(
      key: 'health_fitness',
      name: 'Health & Fitness',
      localCategoryId: 'seed-category-basics',
    ),
    _WordHuntWordWorld(key: 'home_living', name: 'Home & Living'),
    _WordHuntWordWorld(key: 'food_cooking', name: 'Food & Cooking'),
    _WordHuntWordWorld(key: 'style_fashion', name: 'Style & Fashion'),
    _WordHuntWordWorld(key: 'money_shopping', name: 'Money & Shopping'),
    _WordHuntWordWorld(key: 'productivity', name: 'Productivity'),
  ]),
  _WordHuntWordWorldGroup('Mensch & Gesellschaft', [
    _WordHuntWordWorld(key: 'personality', name: 'Personality'),
    _WordHuntWordWorld(key: 'feelings', name: 'Feelings'),
    _WordHuntWordWorld(key: 'relationships', name: 'Relationships'),
    _WordHuntWordWorld(key: 'thoughts', name: 'Thoughts'),
    _WordHuntWordWorld(key: 'law_politics', name: 'Law & Politics'),
    _WordHuntWordWorld(key: 'environment', name: 'Environment'),
  ]),
  _WordHuntWordWorldGroup('Wissen & Bildung', [
    _WordHuntWordWorld(key: 'school_studies', name: 'School & Studies'),
    _WordHuntWordWorld(key: 'science', name: 'Science'),
    _WordHuntWordWorld(key: 'space', name: 'Space'),
    _WordHuntWordWorld(key: 'nature', name: 'Nature'),
    _WordHuntWordWorld(key: 'animals', name: 'Animals'),
    _WordHuntWordWorld(key: 'tech_innovation', name: 'Tech & Innovation'),
  ]),
  _WordHuntWordWorldGroup('Medien & Freizeit', [
    _WordHuntWordWorld(key: 'media_news', name: 'Media & News'),
    _WordHuntWordWorld(key: 'sports', name: 'Sports'),
    _WordHuntWordWorld(
      key: 'travel',
      name: 'Travel',
      localCategoryId: 'seed-category-travel',
    ),
    _WordHuntWordWorld(key: 'gaming', name: 'Gaming'),
    _WordHuntWordWorld(key: 'transport', name: 'Transport'),
    _WordHuntWordWorld(
      key: 'music_entertainment',
      name: 'Music & Entertainment',
    ),
    _WordHuntWordWorld(key: 'art_literature', name: 'Art & Literature'),
  ]),
  _WordHuntWordWorldGroup('Beruf & Sprache', [
    _WordHuntWordWorld(key: 'work_careers', name: 'Work & Careers'),
    _WordHuntWordWorld(key: 'top_500', name: 'Top 500 Words'),
    _WordHuntWordWorld(key: 'a1', name: 'A1'),
    _WordHuntWordWorld(key: 'a2', name: 'A2'),
    _WordHuntWordWorld(key: 'b1', name: 'B1'),
    _WordHuntWordWorld(key: 'b2', name: 'B2'),
    _WordHuntWordWorld(key: 'c1', name: 'C1'),
    _WordHuntWordWorld(key: 'c2', name: 'C2'),
  ]),
];

class _WordHuntWordWorldGroup {
  const _WordHuntWordWorldGroup(this.title, this.worlds);

  final String title;
  final List<_WordHuntWordWorld> worlds;
}

class _WordHuntWordWorld {
  const _WordHuntWordWorld({
    required this.key,
    required this.name,
    this.localCategoryId,
  });

  final String key;
  final String name;
  final String? localCategoryId;

  String resolveCategoryId(List<LocalCategory> categories) {
    if (localCategoryId != null) return localCategoryId!;

    final normalizedName = normalizeWordHuntText(name);
    for (final category in categories) {
      if (normalizeWordHuntText(category.name) == normalizedName) {
        return category.id;
      }
    }

    return key;
  }
}

class _StartView extends StatelessWidget {
  const _StartView({
    required this.selectedSource,
    required this.selectedSpeed,
    required this.categories,
    required this.onSourceSelected,
    required this.onSpeedSelected,
    required this.onStart,
  });

  final WordHuntWordSource selectedSource;
  final WordHuntSpeed selectedSpeed;
  final List<LocalCategory> categories;
  final ValueChanged<WordHuntWordSource> onSourceSelected;
  final ValueChanged<WordHuntSpeed> onSpeedSelected;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFFF7AB6)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF7AB6).withValues(alpha: 0.14),
                blurRadius: 30,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.gps_fixed_rounded,
                color: Color(0xFFFF7AB6),
                size: 46,
              ),
              const SizedBox(height: 16),
              const Text(
                'Bereit für die Wort-Jagd?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tippe die richtige Bedeutung, sobald sie auftaucht.',
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
              _SpeedPicker(
                selectedSpeed: selectedSpeed,
                onSpeedSelected: onSpeedSelected,
              ),
              const SizedBox(height: 22),
              FilledButton(
                key: const ValueKey('word-hunt-start-button'),
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

  final WordHuntWordSource selectedSource;
  final List<LocalCategory> categories;
  final ValueChanged<WordHuntWordSource> onSourceSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('word-hunt-source-picker'),
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
            key: const ValueKey('word-hunt-selected-source-label'),
            style: const TextStyle(
              color: Color(0xFFF4F8FF),
              fontSize: 18,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _PickerActionButton(
            key: const ValueKey('word-hunt-change-source-button'),
            icon: Icons.folder_copy_rounded,
            title: 'Wortquelle ändern',
            subtitle: 'Alle Wörter, Meine Wörter, Favoriten oder Mein Mix',
            onTap: () => _showSourceSheet(context),
          ),
          const SizedBox(height: 10),
          _PickerActionButton(
            key: const ValueKey('word-hunt-select-world-button'),
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
        return _WordHuntSheetFrame(
          title: 'Wortquelle ändern',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final source in _standardWordHuntSources)
                _SheetOption(
                  key: ValueKey('word-hunt-source-${source.id}'),
                  title: source.label,
                  selected:
                      selectedSource == WordHuntWordSource.standard(source),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSourceSelected(WordHuntWordSource.standard(source));
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
        return _WordHuntSheetFrame(
          title: 'Wortwelt auswählen',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final group in _wordHuntWordWorldGroups) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
                  child: Text(
                    group.title,
                    style: const TextStyle(
                      color: Color(0xFFFF7AB6),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                for (final world in group.worlds)
                  Builder(
                    builder: (context) {
                      final source = WordHuntWordSource._wordWorld(
                        world,
                        categories,
                      );
                      return _SheetOption(
                        key: ValueKey('word-hunt-word-world-${world.key}'),
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

class _SpeedPicker extends StatelessWidget {
  const _SpeedPicker({
    required this.selectedSpeed,
    required this.onSpeedSelected,
  });

  final WordHuntSpeed selectedSpeed;
  final ValueChanged<WordHuntSpeed> onSpeedSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('word-hunt-speed-picker'),
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
            'Geschwindigkeit',
            style: TextStyle(
              color: Color(0xFFF4F8FF),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Wähle, wie schnell die Bedeutungen wechseln.',
            style: TextStyle(
              color: Color(0xFFB8C7D9),
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final speed in WordHuntSpeed.values)
                _SpeedChip(
                  speed: speed,
                  selected: speed == selectedSpeed,
                  onTap: () => onSpeedSelected(speed),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpeedChip extends StatelessWidget {
  const _SpeedChip({
    required this.speed,
    required this.selected,
    required this.onTap,
  });

  final WordHuntSpeed speed;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? const Color(0xFFFF7AB6)
        : const Color(0xFF26354B);
    final fillColor = selected
        ? const Color(0xFFFF7AB6).withValues(alpha: 0.16)
        : const Color(0xFF0B1220);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('word-hunt-speed-${speed.name}'),
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            speed.label,
            style: TextStyle(
              color: selected
                  ? const Color(0xFFFF7AB6)
                  : const Color(0xFFF4F8FF),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF26354B)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF7DFFE3), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFF4F8FF),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFB8C7D9),
                        fontSize: 12,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFFF7AB6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordHuntSheetFrame extends StatelessWidget {
  const _WordHuntSheetFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.84,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF050912),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFF7AB6)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF7AB6).withValues(alpha: 0.14),
                  blurRadius: 32,
                  spreadRadius: -6,
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF26354B),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFF4F8FF),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  child,
                ],
              ),
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
    final borderColor = selected
        ? const Color(0xFFFF7AB6)
        : const Color(0xFF26354B);
    final fillColor = selected
        ? const Color(0xFFFF7AB6).withValues(alpha: 0.16)
        : const Color(0xFF0B1220);
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
              color: fillColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFFFF7AB6)
                          : const Color(0xFFF4F8FF),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFFFF7AB6),
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

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.question,
    required this.currentIndex,
    required this.totalCount,
    required this.hitCount,
    required this.lives,
    required this.feedback,
    required this.onAnswer,
  });

  final WordHuntQuestion question;
  final int currentIndex;
  final int totalCount;
  final int hitCount;
  final int lives;
  final String? feedback;
  final ValueChanged<WordHuntAnswer> onAnswer;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatusPill(
                icon: Icons.favorite_rounded,
                label: 'Leben: $lives',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatusPill(
                icon: Icons.my_location_rounded,
                label: 'Treffer: $hitCount',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _StatusPill(
          icon: Icons.route_rounded,
          label: '${currentIndex + 1} / $totalCount',
        ),
        if (feedback != null) ...[
          const SizedBox(height: 14),
          _FeedbackBanner(text: feedback!, isPositive: feedback == 'Treffer!'),
        ],
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFFFF7AB6).withValues(alpha: 0.62),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF7AB6).withValues(alpha: 0.12),
                blurRadius: 28,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Zielwort',
                style: TextStyle(
                  color: Color(0xFFB8C7D9),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                question.prompt,
                key: const ValueKey('word-hunt-prompt'),
                style: const TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 30,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Tippe, sobald die richtige Bedeutung erscheint:',
                style: TextStyle(
                  color: Color(0xFFB8C7D9),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              for (final answer in question.answers) ...[
                _AnswerCard(answer: answer, onTap: () => onAnswer(answer)),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF26354B)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFFF7AB6), size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFF4F8FF),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.answer, required this.onTap});

  final WordHuntAnswer answer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('word-hunt-answer-${answer.pairId}'),
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF050912),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF26354B)),
          ),
          child: Container(
            constraints: const BoxConstraints(minHeight: 62),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.touch_app_rounded,
                  color: Color(0xFFFF7AB6),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    answer.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF4F8FF),
                      fontSize: 16,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.text, required this.isPositive});

  final String text;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final color = isPositive
        ? const Color(0xFF9DFF7D)
        : const Color(0xFFFF6B7A);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.48)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FinishedView extends StatelessWidget {
  const _FinishedView({
    required this.hitCount,
    required this.totalCount,
    required this.finishReason,
    required this.onRestart,
    required this.onBack,
  });

  final int hitCount;
  final int totalCount;
  final _WordHuntFinishReason finishReason;
  final VoidCallback onRestart;
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
            border: Border.all(color: const Color(0xFFFF7AB6)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF7AB6).withValues(alpha: 0.14),
                blurRadius: 30,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.flag_rounded,
                color: Color(0xFFFF7AB6),
                size: 44,
              ),
              const SizedBox(height: 16),
              Text(
                finishReason == _WordHuntFinishReason.noLives
                    ? 'Jagd beendet'
                    : 'Jagd geschafft',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                finishReason == _WordHuntFinishReason.noLives
                    ? 'Du hast $hitCount Wörter getroffen, bevor dir die Leben ausgegangen sind.'
                    : 'Du hast $hitCount von $totalCount Wörtern getroffen.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                key: const ValueKey('word-hunt-restart-button'),
                onPressed: onRestart,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7AB6),
                  foregroundColor: const Color(0xFF041018),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
                child: const Text('Nochmal jagen'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const ValueKey('word-hunt-back-button'),
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF4F8FF),
                  side: const BorderSide(color: Color(0xFFFF7AB6)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
                child: const Text('Zurück zu Wortspiele'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WordHuntMessageState extends StatelessWidget {
  const _WordHuntMessageState({
    required this.title,
    required this.text,
    required this.buttonLabel,
    this.selectedSource,
    this.categories = const <LocalCategory>[],
    this.onSourceSelected,
    required this.onPressed,
  });

  final String title;
  final String text;
  final String buttonLabel;
  final WordHuntWordSource? selectedSource;
  final List<LocalCategory> categories;
  final ValueChanged<WordHuntWordSource>? onSourceSelected;
  final VoidCallback onPressed;

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
            border: Border.all(color: const Color(0xFFFF7AB6)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.gps_fixed_rounded,
                color: Color(0xFFFF7AB6),
                size: 40,
              ),
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
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7AB6),
                  foregroundColor: const Color(0xFF041018),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
                child: Text(buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
