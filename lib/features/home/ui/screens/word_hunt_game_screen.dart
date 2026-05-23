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
import 'package:talvori/features/home/ui/widgets/game_word_source_picker.dart'
    as game_picker;

class WordHuntGameScreen extends ConsumerStatefulWidget {
  const WordHuntGameScreen({
    super.key,
    this.random,
    this.waveDuration,
    this.maxWavesPerTarget = 4,
    this.maxTargets = 9999,
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
  GameWordSource _selectedSource = GameWordSource.standard(
    LocalLearningSource.allWords,
  );
  final SharedPreferencesWordGameProgressRepository _progressRepository =
      const SharedPreferencesWordGameProgressRepository();
  WordHuntSpeed _selectedSpeed = WordHuntSpeed.medium;
  int _wordsPerRound = 10;
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
                availableIds: pairs
                    .map((pair) => pair.id)
                    .toList(growable: false),
                wordsPerRound: _effectiveWordsPerRound(pairs.length),
                onSourceSelected: _selectSource,
                onWordsPerRoundChanged: _selectWordsPerRound,
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

  void _selectSource(GameWordSource source) {
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
      maxTargets: min(widget.maxTargets, _effectiveWordsPerRound(pairs.length)),
    );
    _progressRepository.markPlayedIds(
      'word-hunt',
      _selectedSource.key,
      _roundPairs.map((pair) => pair.id),
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

  int _effectiveWordsPerRound(int available) {
    return clampWordsPerRound(
      requested: _wordsPerRound,
      minimum: 4,
      available: available,
    );
  }

  void _selectWordsPerRound(int count) {
    if (_wordsPerRound == count) return;
    setState(() {
      _waveTimer?.cancel();
      _wordsPerRound = count;
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

class GameWordSource {
  const GameWordSource._({
    required this.label,
    required this.source,
    required this.categoryId,
    required this.worldKey,
  });

  factory GameWordSource.standard(LocalLearningSource source) {
    return GameWordSource._(
      label: source.label,
      source: source,
      categoryId: null,
      worldKey: null,
    );
  }

  final String label;
  final LocalLearningSource source;
  final String? categoryId;
  final String? worldKey;

  String get key => worldKey == null ? source.id : 'word-world:$worldKey';

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
    required this.selectedSpeed,
    required this.categories,
    required this.availableIds,
    required this.wordsPerRound,
    required this.onSourceSelected,
    required this.onWordsPerRoundChanged,
    required this.onSpeedSelected,
    required this.onStart,
  });

  final GameWordSource selectedSource;
  final WordHuntSpeed selectedSpeed;
  final List<LocalCategory> categories;
  final List<String> availableIds;
  final int wordsPerRound;
  final ValueChanged<GameWordSource> onSourceSelected;
  final ValueChanged<int> onWordsPerRoundChanged;
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
                availableIds: availableIds,
                wordsPerRound: wordsPerRound,
                onSourceSelected: onSourceSelected,
                onWordsPerRoundChanged: onWordsPerRoundChanged,
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
      keyPrefix: 'word-hunt',
      selectedSource: _toSharedSource(selectedSource),
      categories: categories,
      availableIds: availableIds,
      wordsPerRound: wordsPerRound,
      minWordsPerRound: 4,
      accentColor: const Color(0xFF7DFFE3),
      secondaryAccentColor: const Color(0xFF5DDCFF),
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
      label: source.label,
      source: source.source,
      categoryId: source.categoryId,
      worldKey: source.key,
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
  final GameWordSource? selectedSource;
  final List<LocalCategory> categories;
  final ValueChanged<GameWordSource>? onSourceSelected;
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
