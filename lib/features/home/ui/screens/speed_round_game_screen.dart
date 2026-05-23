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
import 'package:talvori/features/home/application/word_game_rewards_controller.dart';
import 'package:talvori/features/home/ui/widgets/game_word_source_picker.dart'
    as game_picker;

class SpeedRoundGameScreen extends ConsumerStatefulWidget {
  const SpeedRoundGameScreen({
    super.key,
    this.roundDuration = const Duration(seconds: 60),
    this.random,
  });

  static const routeName = 'speed-round-game';

  final Duration roundDuration;
  final Random? random;

  @override
  ConsumerState<SpeedRoundGameScreen> createState() =>
      _SpeedRoundGameScreenState();
}

class _SpeedRoundGameScreenState extends ConsumerState<SpeedRoundGameScreen> {
  GameWordSource _selectedSource = GameWordSource.standard(
    LocalLearningSource.allWords,
  );
  final SharedPreferencesWordGameProgressRepository _progressRepository =
      const SharedPreferencesWordGameProgressRepository();
  final SharedPreferencesWordGameRewardsRepository _rewardsRepository =
      const SharedPreferencesWordGameRewardsRepository();
  int _wordsPerRound = 10;
  List<SpeedRoundPair> _roundPairs = const <SpeedRoundPair>[];
  List<int> _answerShifts = const <int>[];
  String _roundKey = '';
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _secondsLeft = 60;
  bool _started = false;
  bool _finished = false;
  bool _rewardRecorded = false;
  String? _feedback;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
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
        title: const Text('Blitzrunde'),
      ),
      body: SafeArea(
        child: wordsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFD166)),
          ),
          error: (_, __) => _SpeedRoundMessageState(
            title: 'Wörter konnten nicht geladen werden',
            text: 'Versuche es gleich noch einmal.',
            buttonLabel: 'Zurück',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          data: (words) {
            final categories = categoriesAsync.value ?? const <LocalCategory>[];
            final pairs = buildSpeedRoundPairs(words);
            if (pairs.length < 4) {
              return _SpeedRoundMessageState(
                title: 'Noch nicht genug Wörter',
                text: _selectedSource.categoryId == null
                    ? 'Diese Wortquelle braucht mindestens vier Wörter mit Übersetzung, um Blitzrunde zu spielen.\n\nWähle eine andere Wortquelle oder füge neue Wörter hinzu.'
                    : 'Diese Wortwelt braucht mindestens vier Wörter mit Übersetzung, um Blitzrunde zu spielen.\n\nWähle eine andere Wortquelle oder füge neue Wörter hinzu.',
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
                score: _score,
                onRestart: () => setState(() => _restartRound(pairs)),
                onBack: () => Navigator.of(context).maybePop(),
              );
            }

            if (!_started) {
              return _StartView(
                selectedSource: _selectedSource,
                categories: categories,
                wordsPerRound: _effectiveWordsPerRound(pairs.length, 4),
                minWordsPerRound: 4,
                availableIds: pairs
                    .map((pair) => pair.id)
                    .toList(growable: false),
                onSourceSelected: _selectSource,
                onWordsPerRoundChanged: _selectWordsPerRound,
                onStart: _startRound,
              );
            }

            final question = buildSpeedRoundQuestion(
              pairs: _roundPairs,
              questionIndex: _currentQuestionIndex,
              answerShift: _answerShifts[_currentQuestionIndex],
            );

            return _QuestionView(
              secondsLeft: _secondsLeft,
              score: _score,
              question: question,
              feedback: _feedback,
              onAnswer: _answer,
            );
          },
        ),
      ),
    );
  }

  void _ensureRound(List<SpeedRoundPair> pairs) {
    final nextKey =
        '${_selectedSource.key}:${pairs.map((pair) => pair.id).join('|')}';
    if (_roundKey == nextKey && _roundPairs.isNotEmpty) return;
    _roundKey = nextKey;
    _restartRound(pairs);
  }

  void _selectSource(GameWordSource source) {
    if (_selectedSource == source) return;
    setState(() {
      _timer?.cancel();
      _selectedSource = source;
      _roundPairs = const <SpeedRoundPair>[];
      _answerShifts = const <int>[];
      _roundKey = '';
      _currentQuestionIndex = 0;
      _score = 0;
      _secondsLeft = widget.roundDuration.inSeconds.clamp(1, 60);
      _started = false;
      _finished = false;
      _rewardRecorded = false;
      _feedback = null;
    });
  }

  void _restartRound(List<SpeedRoundPair> pairs) {
    _timer?.cancel();
    final random = widget.random ?? Random();
    _roundPairs = selectSpeedRoundRoundPairs(
      pairs,
      random: random,
      maxQuestions: _effectiveWordsPerRound(pairs.length, 4),
    );
    _progressRepository.markPlayedIds(
      'speed-round',
      _selectedSource.key,
      _roundPairs.map((pair) => pair.id),
    );
    _answerShifts = List<int>.unmodifiable(
      List<int>.generate(_roundPairs.length, (_) => random.nextInt(4)),
    );
    _currentQuestionIndex = 0;
    _score = 0;
    _secondsLeft = widget.roundDuration.inSeconds.clamp(1, 60);
    _started = false;
    _finished = false;
    _rewardRecorded = false;
    _feedback = null;
  }

  int _effectiveWordsPerRound(int available, int minimum) {
    return clampWordsPerRound(
      requested: _wordsPerRound,
      minimum: minimum,
      available: available,
    );
  }

  void _selectWordsPerRound(int count) {
    if (_wordsPerRound == count) return;
    setState(() {
      _timer?.cancel();
      _wordsPerRound = count;
      _roundPairs = const <SpeedRoundPair>[];
      _answerShifts = const <int>[];
      _roundKey = '';
      _currentQuestionIndex = 0;
      _score = 0;
      _secondsLeft = widget.roundDuration.inSeconds.clamp(1, 60);
      _started = false;
      _finished = false;
      _rewardRecorded = false;
      _feedback = null;
    });
  }

  void _startRound() {
    setState(() {
      _started = true;
      _finished = false;
      _rewardRecorded = false;
      _score = 0;
      _currentQuestionIndex = 0;
      _secondsLeft = widget.roundDuration.inSeconds.clamp(1, 60);
      _feedback = null;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft <= 1) {
          _secondsLeft = 0;
          _finishRound();
          return;
        }
        _secondsLeft -= 1;
      });
    });
  }

  void _finishRound() {
    _timer?.cancel();
    _started = false;
    _finished = true;
    _feedback = null;
    _recordRewardOnce();
  }

  void _recordRewardOnce() {
    if (_rewardRecorded || _roundPairs.isEmpty) return;
    _rewardRecorded = true;
    unawaited(
      _rewardsRepository.recordRound(
        WordGameRoundRewardInput(
          gameId: wordGameIdSpeedRound,
          sourceKey: _selectedSource.key,
          wordsPerRound: _roundPairs.length,
          playedWords: _roundPairs.length,
          correctWithoutHint: _score,
          wrong: max(0, _roundPairs.length - _score),
          completed: true,
          roundId:
              '$wordGameIdSpeedRound:${_selectedSource.key}:${_roundPairs.map((pair) => pair.id).join(",")}:$_score',
        ),
      ),
    );
  }

  void _answer(SpeedRoundAnswer answer) {
    if (_finished || !_started) return;
    setState(() {
      if (answer.isCorrect) {
        _score += 1;
        _feedback = 'Richtig!';
      } else {
        _feedback = 'Nicht ganz.';
      }
      _currentQuestionIndex = (_currentQuestionIndex + 1) % _roundPairs.length;
    });
  }
}

@visibleForTesting
List<SpeedRoundPair> buildSpeedRoundPairs(List<LocalWord> words) {
  final pairs = <SpeedRoundPair>[];
  final seenTerms = <String>{};
  final seenTranslations = <String>{};

  for (final word in words) {
    final term = word.term.trim();
    final translation = word.translation.trim();
    if (term.isEmpty || translation.isEmpty || word.isArchived) continue;

    final normalizedTerm = _normalizeSpeedRoundText(term);
    final normalizedTranslation = _normalizeSpeedRoundText(translation);
    if (!seenTerms.add(normalizedTerm)) continue;
    if (!seenTranslations.add(normalizedTranslation)) continue;

    pairs.add(
      SpeedRoundPair(id: word.id, term: term, translation: translation),
    );
  }

  return List<SpeedRoundPair>.unmodifiable(pairs);
}

@visibleForTesting
List<SpeedRoundPair> selectSpeedRoundRoundPairs(
  List<SpeedRoundPair> pairs, {
  required Random random,
  int maxQuestions = 10,
}) {
  final shuffled = List<SpeedRoundPair>.of(pairs)..shuffle(random);
  return List<SpeedRoundPair>.unmodifiable(shuffled.take(maxQuestions));
}

@visibleForTesting
SpeedRoundQuestion buildSpeedRoundQuestion({
  required List<SpeedRoundPair> pairs,
  required int questionIndex,
  int? answerShift,
}) {
  final correct = pairs[questionIndex % pairs.length];
  final distractors = <SpeedRoundPair>[];
  for (var offset = 1; distractors.length < 3; offset += 1) {
    final candidate = pairs[(questionIndex + offset) % pairs.length];
    if (candidate.id == correct.id) continue;
    if (distractors.any((pair) => pair.id == candidate.id)) continue;
    distractors.add(candidate);
  }

  final rawAnswers = <SpeedRoundAnswer>[
    SpeedRoundAnswer(pairId: correct.id, text: correct.translation),
    for (final pair in distractors)
      SpeedRoundAnswer(pairId: pair.id, text: pair.translation),
  ];
  final shift = (answerShift ?? questionIndex) % rawAnswers.length;
  final answers = <SpeedRoundAnswer>[
    ...rawAnswers.skip(shift),
    ...rawAnswers.take(shift),
  ];

  return SpeedRoundQuestion(
    correctPairId: correct.id,
    prompt: correct.term,
    answers: List<SpeedRoundAnswer>.unmodifiable(
      answers.map(
        (answer) => SpeedRoundAnswer(
          pairId: answer.pairId,
          text: answer.text,
          isCorrect: answer.pairId == correct.id,
        ),
      ),
    ),
  );
}

String _normalizeSpeedRoundText(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

class SpeedRoundPair {
  const SpeedRoundPair({
    required this.id,
    required this.term,
    required this.translation,
  });

  final String id;
  final String term;
  final String translation;
}

class SpeedRoundQuestion {
  const SpeedRoundQuestion({
    required this.correctPairId,
    required this.prompt,
    required this.answers,
  });

  final String correctPairId;
  final String prompt;
  final List<SpeedRoundAnswer> answers;
}

class SpeedRoundAnswer {
  const SpeedRoundAnswer({
    required this.pairId,
    required this.text,
    this.isCorrect = false,
  });

  final String pairId;
  final String text;
  final bool isCorrect;
}

class GameWordSource {
  const GameWordSource._({
    required this.label,
    required this.shortLabel,
    required this.source,
    required this.categoryId,
    required this.worldKey,
  });

  factory GameWordSource.standard(LocalLearningSource source) {
    return GameWordSource._(
      label: source.label,
      shortLabel: switch (source) {
        LocalLearningSource.allWords => 'Alle',
        LocalLearningSource.myWords => 'Meine',
        LocalLearningSource.favorites => 'Favoriten',
        LocalLearningSource.myMix => 'Mix',
        LocalLearningSource.knownWords => 'Bekannte',
      },
      source: source,
      categoryId: null,
      worldKey: null,
    );
  }

  factory GameWordSource.category(LocalCategory category) {
    return GameWordSource._(
      label: 'Wortwelt: ${category.name}',
      shortLabel: category.name,
      source: LocalLearningSource.allWords,
      categoryId: category.id,
      worldKey: category.id,
    );
  }

  final String label;
  final String shortLabel;
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
    required this.categories,
    required this.wordsPerRound,
    required this.minWordsPerRound,
    required this.availableIds,
    required this.onSourceSelected,
    required this.onWordsPerRoundChanged,
    required this.onStart,
  });

  final GameWordSource selectedSource;
  final List<LocalCategory> categories;
  final int wordsPerRound;
  final int minWordsPerRound;
  final List<String> availableIds;
  final ValueChanged<GameWordSource> onSourceSelected;
  final ValueChanged<int> onWordsPerRoundChanged;
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
            border: Border.all(color: const Color(0xFFFFD166)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD166).withValues(alpha: 0.14),
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
                Icons.bolt_rounded,
                color: Color(0xFFFFD166),
                size: 46,
              ),
              const SizedBox(height: 16),
              const Text(
                'Bereit für die Blitzrunde?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Du hast 60 Sekunden. Wähle so viele richtige Bedeutungen wie möglich.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              _WordSourcePicker(
                selectedSource: selectedSource,
                categories: categories,
                wordsPerRound: wordsPerRound,
                minWordsPerRound: minWordsPerRound,
                availableIds: availableIds,
                onSourceSelected: onSourceSelected,
                onWordsPerRoundChanged: onWordsPerRoundChanged,
              ),
              const SizedBox(height: 22),
              FilledButton(
                key: const ValueKey('speed-round-start-button'),
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD166),
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

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.secondsLeft,
    required this.score,
    required this.question,
    required this.feedback,
    required this.onAnswer,
  });

  final int secondsLeft;
  final int score;
  final SpeedRoundQuestion question;
  final String? feedback;
  final ValueChanged<SpeedRoundAnswer> onAnswer;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatusPill(
                icon: Icons.timer_rounded,
                label: 'Zeit: ${secondsLeft}s',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatusPill(
                icon: Icons.check_circle_rounded,
                label: 'Richtig: $score',
              ),
            ),
          ],
        ),
        if (feedback != null) ...[
          const SizedBox(height: 14),
          _FeedbackBanner(text: feedback!, isPositive: feedback == 'Richtig!'),
        ],
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFFFFD166).withValues(alpha: 0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD166).withValues(alpha: 0.11),
                blurRadius: 28,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welche Bedeutung passt?',
                style: TextStyle(
                  color: Color(0xFFB8C7D9),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                question.prompt,
                key: const ValueKey('speed-round-prompt'),
                style: const TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 30,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 22),
              for (final answer in question.answers) ...[
                _AnswerButton(answer: answer, onTap: () => onAnswer(answer)),
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
          Icon(icon, color: const Color(0xFF7DFFE3), size: 18),
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

class _WordSourcePicker extends StatelessWidget {
  const _WordSourcePicker({
    required this.selectedSource,
    required this.categories,
    this.wordsPerRound = 10,
    this.minWordsPerRound = 1,
    this.availableIds = const <String>[],
    required this.onSourceSelected,
    this.onWordsPerRoundChanged,
  });

  final GameWordSource selectedSource;
  final List<LocalCategory> categories;
  final int wordsPerRound;
  final int minWordsPerRound;
  final List<String> availableIds;
  final ValueChanged<GameWordSource> onSourceSelected;
  final ValueChanged<int>? onWordsPerRoundChanged;

  @override
  Widget build(BuildContext context) {
    return game_picker.GameWordSourcePicker(
      keyPrefix: 'speed-round',
      selectedSource: _toSharedSource(selectedSource),
      categories: categories,
      wordsPerRound: wordsPerRound,
      minWordsPerRound: minWordsPerRound,
      availableIds: availableIds,
      accentColor: const Color(0xFFFFD166),
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
      label: source.label,
      shortLabel: source.label.replaceFirst('Wortwelt: ', ''),
      source: source.source,
      categoryId: source.categoryId,
      worldKey: source.key,
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({required this.answer, required this.onTap});

  final SpeedRoundAnswer answer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('speed-round-answer-${answer.pairId}'),
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF050912),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF26354B)),
          ),
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
        : const Color(0xFFFFD166);
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
    required this.score,
    required this.onRestart,
    required this.onBack,
  });

  final int score;
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
            border: Border.all(color: const Color(0xFFFFD166)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD166).withValues(alpha: 0.14),
                blurRadius: 30,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.timer_off_rounded,
                color: Color(0xFFFFD166),
                size: 44,
              ),
              const SizedBox(height: 16),
              const Text(
                'Zeit vorbei',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Du hast $score Wörter richtig erkannt.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Taler verdient: +${score * 10 + 20}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFFD166),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                key: const ValueKey('speed-round-restart-button'),
                onPressed: onRestart,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD166),
                  foregroundColor: const Color(0xFF041018),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
                child: const Text('Nochmal spielen'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const ValueKey('speed-round-back-button'),
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF4F8FF),
                  side: const BorderSide(color: Color(0xFFFFD166)),
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

class _SpeedRoundMessageState extends StatelessWidget {
  const _SpeedRoundMessageState({
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
            border: Border.all(color: const Color(0xFFFFD166)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.bolt_rounded,
                color: Color(0xFFFFD166),
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
                  backgroundColor: const Color(0xFFFFD166),
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
