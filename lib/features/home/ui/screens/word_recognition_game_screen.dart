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

class WordRecognitionGameScreen extends ConsumerStatefulWidget {
  const WordRecognitionGameScreen({super.key});

  static const routeName = 'word-recognition-game';

  @override
  ConsumerState<WordRecognitionGameScreen> createState() =>
      _WordRecognitionGameScreenState();
}

class _WordRecognitionGameScreenState
    extends ConsumerState<WordRecognitionGameScreen> {
  GameWordSource _selectedSource = GameWordSource.standard(
    LocalLearningSource.allWords,
  );
  final SharedPreferencesWordGameProgressRepository _progressRepository =
      const SharedPreferencesWordGameProgressRepository();
  int _wordsPerRound = 10;
  List<WordRecognitionPair> _roundPairs = const <WordRecognitionPair>[];
  String _roundKey = '';
  bool _hasStarted = false;
  int _currentQuestionIndex = 0;
  int _correctCount = 0;
  bool _isFinished = false;
  bool _resolved = false;
  String? _selectedPairId;
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
        title: const Text('Wort erkennen'),
      ),
      body: SafeArea(
        child: wordsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF8A5B)),
          ),
          error: (_, __) => _WordRecognitionMessageState(
            title: 'Wörter konnten nicht geladen werden',
            text: 'Versuche es gleich noch einmal.',
            buttonLabel: 'Zurück',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          data: (words) {
            final categories = categoriesAsync.value ?? const <LocalCategory>[];
            final pairs = buildWordRecognitionPairs(words);
            if (pairs.length < 4) {
              return _WordRecognitionMessageState(
                title: 'Noch nicht genug Wörter',
                text: _selectedSource.categoryId == null
                    ? 'Diese Wortquelle braucht mindestens vier Wörter mit Übersetzung, um Wort erkennen zu spielen.'
                    : 'Diese Wortwelt braucht mindestens vier Wörter mit Übersetzung, um Wort erkennen zu spielen.',
                buttonLabel: 'Zurück',
                selectedSource: _selectedSource,
                categories: categories,
                onSourceSelected: _selectSource,
                onPressed: () => Navigator.of(context).maybePop(),
              );
            }

            if (!_hasStarted) {
              return _StartView(
                selectedSource: _selectedSource,
                categories: categories,
                availableIds: pairs
                    .map((pair) => pair.id)
                    .toList(growable: false),
                wordsPerRound: _effectiveWordsPerRound(pairs.length),
                onSourceSelected: _selectSource,
                onWordsPerRoundChanged: _selectWordsPerRound,
                onStart: () => setState(() => _startRound(pairs)),
              );
            }

            _ensureRound(pairs);
            if (_isFinished) {
              return _FinishedView(
                correctCount: _correctCount,
                totalCount: _roundPairs.length,
                onRestart: () => setState(() => _startRound(pairs)),
                onBack: () => Navigator.of(context).maybePop(),
              );
            }

            final question = buildWordRecognitionQuestion(
              pairs: _roundPairs,
              questionIndex: _currentQuestionIndex,
            );
            return _QuestionView(
              question: question,
              currentIndex: _currentQuestionIndex,
              totalCount: _roundPairs.length,
              feedback: _feedback,
              resolved: _resolved,
              selectedPairId: _selectedPairId,
              onAnswer: _answer,
              onReveal: _reveal,
              onNext: _nextQuestion,
            );
          },
        ),
      ),
    );
  }

  void _ensureRound(List<WordRecognitionPair> pairs) {
    final nextKey =
        '${_selectedSource.key}:${pairs.map((pair) => pair.id).join('|')}';
    if (_roundKey == nextKey && _roundPairs.isNotEmpty) return;
    _roundKey = nextKey;
    _restartRound(pairs);
  }

  void _selectSource(GameWordSource source) {
    if (_selectedSource == source) return;
    setState(() {
      _selectedSource = source;
      _roundPairs = const <WordRecognitionPair>[];
      _roundKey = '';
      _hasStarted = false;
      _currentQuestionIndex = 0;
      _correctCount = 0;
      _isFinished = false;
      _resolved = false;
      _selectedPairId = null;
      _feedback = null;
    });
  }

  void _restartRound(List<WordRecognitionPair> pairs) {
    _roundPairs = List<WordRecognitionPair>.unmodifiable(
      pairs.take(_effectiveWordsPerRound(pairs.length)),
    );
    _progressRepository.markPlayedIds(
      'word-recognition',
      _selectedSource.key,
      _roundPairs.map((pair) => pair.id),
    );
    _currentQuestionIndex = 0;
    _correctCount = 0;
    _isFinished = false;
    _resolved = false;
    _selectedPairId = null;
    _feedback = null;
  }

  void _startRound(List<WordRecognitionPair> pairs) {
    _hasStarted = true;
    _roundKey =
        '${_selectedSource.key}:${pairs.map((pair) => pair.id).join('|')}';
    _restartRound(pairs);
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
      _wordsPerRound = count;
      _roundPairs = const <WordRecognitionPair>[];
      _roundKey = '';
      _hasStarted = false;
      _currentQuestionIndex = 0;
      _correctCount = 0;
      _isFinished = false;
      _resolved = false;
      _selectedPairId = null;
      _feedback = null;
    });
  }

  void _answer(WordRecognitionAnswer answer) {
    if (_resolved) return;
    setState(() {
      _resolved = true;
      _selectedPairId = answer.pairId;
      if (answer.isCorrect) {
        _correctCount += 1;
        _feedback = 'Richtig!';
      } else {
        _feedback = 'Nicht ganz.';
      }
    });
  }

  void _reveal() {
    if (_resolved) return;
    setState(() {
      _resolved = true;
      _selectedPairId = null;
      _feedback = 'Aufgelöst.';
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex >= _roundPairs.length - 1) {
        _isFinished = true;
        return;
      }
      _currentQuestionIndex += 1;
      _resolved = false;
      _selectedPairId = null;
      _feedback = null;
    });
  }
}

@visibleForTesting
List<WordRecognitionPair> buildWordRecognitionPairs(List<LocalWord> words) {
  final pairs = <WordRecognitionPair>[];
  final seenTerms = <String>{};
  final seenTranslations = <String>{};

  for (final word in words) {
    final term = word.term.trim();
    final translation = word.translation.trim();
    if (term.isEmpty || translation.isEmpty || word.isArchived) continue;

    final normalizedTerm = normalizeWordRecognitionText(term);
    final normalizedTranslation = normalizeWordRecognitionText(translation);
    if (!seenTerms.add(normalizedTerm)) continue;
    if (!seenTranslations.add(normalizedTranslation)) continue;

    pairs.add(
      WordRecognitionPair(id: word.id, term: term, translation: translation),
    );
  }

  return List<WordRecognitionPair>.unmodifiable(pairs);
}

@visibleForTesting
WordRecognitionQuestion buildWordRecognitionQuestion({
  required List<WordRecognitionPair> pairs,
  required int questionIndex,
}) {
  final correct = pairs[questionIndex % pairs.length];
  final distractors = <WordRecognitionPair>[];
  for (var offset = 1; distractors.length < 3; offset += 1) {
    final candidate = pairs[(questionIndex + offset) % pairs.length];
    if (candidate.id == correct.id) continue;
    if (distractors.any((pair) => pair.id == candidate.id)) continue;
    distractors.add(candidate);
  }

  final rawAnswers = <WordRecognitionAnswer>[
    WordRecognitionAnswer(pairId: correct.id, text: correct.translation),
    for (final pair in distractors)
      WordRecognitionAnswer(pairId: pair.id, text: pair.translation),
  ];
  final shift = (questionIndex + 1) % rawAnswers.length;
  final answers = <WordRecognitionAnswer>[
    ...rawAnswers.skip(shift),
    ...rawAnswers.take(shift),
  ];

  return WordRecognitionQuestion(
    correctPairId: correct.id,
    prompt: correct.term,
    hint: buildWordRecognitionHint(correct.term, questionIndex),
    correctAnswerText: correct.translation,
    answers: List<WordRecognitionAnswer>.unmodifiable(
      answers.map(
        (answer) => WordRecognitionAnswer(
          pairId: answer.pairId,
          text: answer.text,
          isCorrect: answer.pairId == correct.id,
        ),
      ),
    ),
  );
}

@visibleForTesting
String buildWordRecognitionHint(String term, int questionIndex) {
  final templates = <String>[
    'Welches deutsche Wort passt zu "$term"?',
    'Wähle die passende Übersetzung.',
    'Erkenne das Wort anhand der passenden Übersetzung.',
    'Welche Übersetzung gehört zu diesem Wort?',
  ];
  return templates[questionIndex % templates.length];
}

@visibleForTesting
String normalizeWordRecognitionText(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

class WordRecognitionPair {
  const WordRecognitionPair({
    required this.id,
    required this.term,
    required this.translation,
  });

  final String id;
  final String term;
  final String translation;
}

class WordRecognitionQuestion {
  const WordRecognitionQuestion({
    required this.correctPairId,
    required this.prompt,
    required this.hint,
    required this.correctAnswerText,
    required this.answers,
  });

  final String correctPairId;
  final String prompt;
  final String hint;
  final String correctAnswerText;
  final List<WordRecognitionAnswer> answers;
}

class WordRecognitionAnswer {
  const WordRecognitionAnswer({
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
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFFFF8A5B).withValues(alpha: 0.58),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF8A5B).withValues(alpha: 0.12),
                blurRadius: 28,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.psychology_alt_rounded,
                color: Color(0xFFFF8A5B),
                size: 46,
              ),
              const SizedBox(height: 16),
              const Text(
                'Wort erkennen',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Wähle die passende Übersetzung.',
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
              const SizedBox(height: 22),
              FilledButton(
                key: const ValueKey('word-recognition-start-button'),
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A5B),
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

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.question,
    required this.currentIndex,
    required this.totalCount,
    required this.feedback,
    required this.resolved,
    required this.selectedPairId,
    required this.onAnswer,
    required this.onReveal,
    required this.onNext,
  });

  final WordRecognitionQuestion question;
  final int currentIndex;
  final int totalCount;
  final String? feedback;
  final bool resolved;
  final String? selectedPairId;
  final ValueChanged<WordRecognitionAnswer> onAnswer;
  final VoidCallback onReveal;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RoundHeader(currentIndex: currentIndex, totalCount: totalCount),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1220),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: const Color(0xFFFF8A5B).withValues(alpha: 0.56),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8A5B).withValues(alpha: 0.12),
                  blurRadius: 28,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Welches Wort passt?',
                  style: TextStyle(
                    color: Color(0xFFF4F8FF),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Wähle ruhig und konzentriert die passende Übersetzung.',
                  style: TextStyle(
                    color: Color(0xFFB8C7D9),
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                _MeaningHint(text: question.hint),
                const SizedBox(height: 14),
                Container(
                  key: const ValueKey('word-recognition-prompt-card'),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF050912),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF26354B)),
                  ),
                  child: Text(
                    question.prompt,
                    key: const ValueKey('word-recognition-prompt'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFF4F8FF),
                      fontSize: 30,
                      height: 1.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                for (final answer in question.answers) ...[
                  _AnswerButton(
                    key: ValueKey('word-recognition-answer-${answer.pairId}'),
                    answer: answer,
                    isResolved: resolved,
                    isSelected: selectedPairId == answer.pairId,
                    onTap: () => onAnswer(answer),
                  ),
                  const SizedBox(height: 10),
                ],
                if (feedback != null) ...[
                  const SizedBox(height: 4),
                  _FeedbackBanner(
                    text: feedback!,
                    isPositive: feedback == 'Richtig!',
                  ),
                ],
                if (resolved) ...[
                  const SizedBox(height: 14),
                  _CorrectAnswer(text: question.correctAnswerText),
                  const SizedBox(height: 18),
                  FilledButton(
                    key: const ValueKey('word-recognition-next-button'),
                    onPressed: onNext,
                    style: _primaryButtonStyle(),
                    child: const Text('Nächste Frage'),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  OutlinedButton(
                    key: const ValueKey('word-recognition-reveal-button'),
                    onPressed: onReveal,
                    style: _secondaryButtonStyle(),
                    child: const Text('Auflösen'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: const Color(0xFFFF8A5B),
      foregroundColor: const Color(0xFF041018),
      padding: const EdgeInsets.symmetric(vertical: 15),
      textStyle: const TextStyle(fontWeight: FontWeight.w900),
    );
  }

  ButtonStyle _secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFFF4F8FF),
      side: const BorderSide(color: Color(0xFFFF8A5B)),
      padding: const EdgeInsets.symmetric(vertical: 15),
      textStyle: const TextStyle(fontWeight: FontWeight.w900),
    );
  }
}

class _MeaningHint extends StatelessWidget {
  const _MeaningHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('word-recognition-hint'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8A5B).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFF8A5B).withValues(alpha: 0.42),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFF4F8FF),
          height: 1.35,
          fontWeight: FontWeight.w800,
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
      keyPrefix: 'word-recognition',
      selectedSource: _toSharedSource(selectedSource),
      categories: categories,
      availableIds: availableIds,
      wordsPerRound: wordsPerRound,
      minWordsPerRound: 4,
      accentColor: const Color(0xFFB56DFF),
      secondaryAccentColor: const Color(0xFF5DDCFF),
      onWordsPerRoundChanged: onWordsPerRoundChanged,
      onSourceSelected: (source) => onSourceSelected(_fromSharedSource(source)),
    );
  }

  game_picker.GameWordSource _toSharedSource(GameWordSource source) {
    if (source.categoryId == null) {
      return game_picker.GameWordSource.standard(source.source);
    }
    return game_picker.GameWordSource.custom(
      key: source.key,
      label: source.label,
      source: source.source,
      categoryId: source.categoryId,
    );
  }

  GameWordSource _fromSharedSource(game_picker.GameWordSource source) {
    if (source.categoryId == null) {
      return GameWordSource.standard(source.source);
    }
    return GameWordSource._(
      label: source.label,
      source: source.source,
      categoryId: source.categoryId,
      worldKey: source.key,
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    super.key,
    required this.answer,
    required this.isResolved,
    required this.isSelected,
    required this.onTap,
  });

  final WordRecognitionAnswer answer;
  final bool isResolved;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCorrect = isResolved && answer.isCorrect;
    final isWrongSelection = isResolved && isSelected && !answer.isCorrect;
    final borderColor = isCorrect
        ? const Color(0xFF9DFF7D)
        : isWrongSelection
        ? const Color(0xFFFFD166)
        : const Color(0xFF26354B);
    final fillColor = isCorrect
        ? const Color(0xFF9DFF7D).withValues(alpha: 0.16)
        : isWrongSelection
        ? const Color(0xFFFFD166).withValues(alpha: 0.14)
        : const Color(0xFF050912);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: isResolved ? null : onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: isCorrect ? 1.4 : 1),
        ),
        child: Row(
          children: [
            Icon(
              isCorrect
                  ? Icons.check_circle_rounded
                  : isWrongSelection
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: borderColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                answer.text,
                style: const TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 16,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundHeader extends StatelessWidget {
  const _RoundHeader({required this.currentIndex, required this.totalCount});

  final int currentIndex;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF26354B)),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology_alt_rounded, color: Color(0xFFFF8A5B)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Wort erkennen',
              style: TextStyle(
                color: Color(0xFFF4F8FF),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            '${currentIndex + 1} / $totalCount',
            style: const TextStyle(
              color: Color(0xFFFF8A5B),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
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

class _CorrectAnswer extends StatelessWidget {
  const _CorrectAnswer({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('word-recognition-correct-answer'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF050912),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF9DFF7D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Passende Übersetzung',
            style: TextStyle(
              color: Color(0xFFB8C7D9),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFF4F8FF),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinishedView extends StatelessWidget {
  const _FinishedView({
    required this.correctCount,
    required this.totalCount,
    required this.onRestart,
    required this.onBack,
  });

  final int correctCount;
  final int totalCount;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      cacheExtent: 1000,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFFF8A5B)),
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
                'Runde beendet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Du hast $correctCount von $totalCount Wörtern richtig erkannt.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                key: const ValueKey('word-recognition-restart-button'),
                onPressed: onRestart,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A5B),
                  foregroundColor: const Color(0xFF041018),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
                child: const Text('Nochmal spielen'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const ValueKey('word-recognition-back-button'),
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF4F8FF),
                  side: const BorderSide(color: Color(0xFFFF8A5B)),
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

class _WordRecognitionMessageState extends StatelessWidget {
  const _WordRecognitionMessageState({
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
            border: Border.all(color: const Color(0xFFFF8A5B)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.psychology_alt_rounded,
                color: Color(0xFFFF8A5B),
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
                  backgroundColor: const Color(0xFFFF8A5B),
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
