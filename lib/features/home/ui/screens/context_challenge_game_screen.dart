import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';

class ContextChallengeGameScreen extends ConsumerStatefulWidget {
  const ContextChallengeGameScreen({super.key});

  static const routeName = 'context-challenge-game';

  @override
  ConsumerState<ContextChallengeGameScreen> createState() =>
      _ContextChallengeGameScreenState();
}

class _ContextChallengeGameScreenState
    extends ConsumerState<ContextChallengeGameScreen> {
  List<ContextChallengePair> _roundPairs = const <ContextChallengePair>[];
  String _roundKey = '';
  int _currentTaskIndex = 0;
  int _score = 0;
  bool _hasStarted = false;
  bool _isFinished = false;
  bool _resolved = false;
  String? _feedback;
  String? _selectedPairId;

  @override
  Widget build(BuildContext context) {
    final wordsAsync = ref.watch(
      localWordsForSourceProvider(LocalLearningSource.allWords),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF050912),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050912),
        elevation: 0,
        centerTitle: true,
        title: const Text('Kontext-Challenge'),
      ),
      body: SafeArea(
        child: wordsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF5DDCFF)),
          ),
          error: (_, __) => _ContextMessageState(
            title: 'Wörter konnten nicht geladen werden',
            text: 'Versuche es gleich noch einmal.',
            buttonLabel: 'Zurück',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          data: (words) {
            final pairs = buildContextChallengePairs(words);
            if (pairs.length < 4) {
              return _ContextMessageState(
                title: 'Noch nicht genug Wörter',
                text:
                    'Füge mindestens vier Wörter mit Übersetzung hinzu, um die Kontext-Challenge zu starten.',
                buttonLabel: 'Zurück',
                onPressed: () => Navigator.of(context).maybePop(),
              );
            }

            _ensureRound(pairs);
            if (_isFinished) {
              return _FinishedView(
                score: _score,
                totalCount: _roundPairs.length,
                onRestart: () => setState(() => _restartRound(pairs)),
                onBack: () => Navigator.of(context).maybePop(),
              );
            }
            if (!_hasStarted) {
              return _StartView(onStart: _startChallenge);
            }

            final task = buildContextChallengeTask(
              pairs: _roundPairs,
              taskIndex: _currentTaskIndex,
            );
            return _TaskView(
              key: ValueKey('context-challenge-task-$_currentTaskIndex'),
              task: task,
              currentTaskIndex: _currentTaskIndex,
              totalCount: _roundPairs.length,
              score: _score,
              feedback: _feedback,
              resolved: _resolved,
              selectedPairId: _selectedPairId,
              onAnswer: _answer,
              onReveal: _reveal,
              onNext: _nextTask,
            );
          },
        ),
      ),
    );
  }

  void _ensureRound(List<ContextChallengePair> pairs) {
    final nextKey = pairs.map((pair) => pair.id).join('|');
    if (_roundKey == nextKey && _roundPairs.isNotEmpty) return;
    _roundKey = nextKey;
    _restartRound(pairs);
  }

  void _restartRound(List<ContextChallengePair> pairs) {
    _roundPairs = List<ContextChallengePair>.unmodifiable(pairs.take(10));
    _currentTaskIndex = 0;
    _score = 0;
    _hasStarted = false;
    _isFinished = false;
    _resolved = false;
    _feedback = null;
    _selectedPairId = null;
  }

  void _startChallenge() {
    setState(() {
      _hasStarted = true;
      _resolved = false;
      _feedback = null;
      _selectedPairId = null;
    });
  }

  void _answer(ContextChallengeAnswer answer) {
    if (_resolved) return;
    setState(() {
      _resolved = true;
      _selectedPairId = answer.pairId;
      if (answer.isCorrect) {
        _score += 1;
        _feedback = 'Passt in den Kontext!';
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

  void _nextTask() {
    setState(() {
      if (_currentTaskIndex >= _roundPairs.length - 1) {
        _isFinished = true;
        return;
      }
      _currentTaskIndex += 1;
      _resolved = false;
      _feedback = null;
      _selectedPairId = null;
    });
  }
}

const contextChallengeTemplates = [
  'Ich denke an ___.',
  'Das Wort ___ passt hier am besten.',
  'Heute übe ich ___.',
  'Kannst du ___ erkennen?',
];

@visibleForTesting
List<ContextChallengePair> buildContextChallengePairs(List<LocalWord> words) {
  final pairs = <ContextChallengePair>[];
  final seenTerms = <String>{};
  final seenTranslations = <String>{};

  for (final word in words) {
    final term = word.term.trim();
    final translation = word.translation.trim();
    if (word.isArchived || term.isEmpty || translation.isEmpty) continue;

    final normalizedTerm = normalizeContextChallengeText(term);
    final normalizedTranslation = normalizeContextChallengeText(translation);
    if (!seenTerms.add(normalizedTerm)) continue;
    if (!seenTranslations.add(normalizedTranslation)) continue;

    pairs.add(
      ContextChallengePair(id: word.id, term: term, translation: translation),
    );
  }

  return List<ContextChallengePair>.unmodifiable(pairs);
}

@visibleForTesting
ContextChallengeTask buildContextChallengeTask({
  required List<ContextChallengePair> pairs,
  required int taskIndex,
}) {
  final correct = pairs[taskIndex % pairs.length];
  final distractors = <ContextChallengePair>[];
  for (var offset = 1; distractors.length < 3; offset += 1) {
    final candidate = pairs[(taskIndex + offset) % pairs.length];
    if (candidate.id == correct.id) continue;
    if (distractors.any((pair) => pair.id == candidate.id)) continue;
    distractors.add(candidate);
  }

  final rawAnswers = <ContextChallengeAnswer>[
    ContextChallengeAnswer(pairId: correct.id, text: correct.term),
    for (final pair in distractors)
      ContextChallengeAnswer(pairId: pair.id, text: pair.term),
  ];
  final shift = (taskIndex + 2) % rawAnswers.length;
  final answers = <ContextChallengeAnswer>[
    ...rawAnswers.skip(shift),
    ...rawAnswers.take(shift),
  ];

  return ContextChallengeTask(
    correctPairId: correct.id,
    correctAnswerText: correct.term,
    hintTranslation: correct.translation,
    sentence:
        contextChallengeTemplates[taskIndex % contextChallengeTemplates.length],
    answers: List<ContextChallengeAnswer>.unmodifiable(
      answers.map(
        (answer) => ContextChallengeAnswer(
          pairId: answer.pairId,
          text: answer.text,
          isCorrect: answer.pairId == correct.id,
        ),
      ),
    ),
  );
}

@visibleForTesting
String normalizeContextChallengeText(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

class ContextChallengePair {
  const ContextChallengePair({
    required this.id,
    required this.term,
    required this.translation,
  });

  final String id;
  final String term;
  final String translation;
}

class ContextChallengeTask {
  const ContextChallengeTask({
    required this.correctPairId,
    required this.correctAnswerText,
    required this.hintTranslation,
    required this.sentence,
    required this.answers,
  });

  final String correctPairId;
  final String correctAnswerText;
  final String hintTranslation;
  final String sentence;
  final List<ContextChallengeAnswer> answers;
}

class ContextChallengeAnswer {
  const ContextChallengeAnswer({
    required this.pairId,
    required this.text,
    this.isCorrect = false,
  });

  final String pairId;
  final String text;
  final bool isCorrect;
}

class _StartView extends StatelessWidget {
  const _StartView({required this.onStart});

  final VoidCallback onStart;

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
            border: Border.all(color: const Color(0xFF5DDCFF)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5DDCFF).withValues(alpha: 0.12),
                blurRadius: 30,
                spreadRadius: -6,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.auto_stories_rounded,
                color: Color(0xFF5DDCFF),
                size: 48,
              ),
              const SizedBox(height: 18),
              const Text(
                'Kontext-Challenge',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 26,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Erkenne Wörter im Zusammenhang. Diese erste Version funktioniert lokal ohne KI.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                key: const ValueKey('context-challenge-start-button'),
                onPressed: onStart,
                style: _primaryButtonStyle(),
                child: const Text('Challenge starten'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskView extends StatelessWidget {
  const _TaskView({
    super.key,
    required this.task,
    required this.currentTaskIndex,
    required this.totalCount,
    required this.score,
    required this.feedback,
    required this.resolved,
    required this.selectedPairId,
    required this.onAnswer,
    required this.onReveal,
    required this.onNext,
  });

  final ContextChallengeTask task;
  final int currentTaskIndex;
  final int totalCount;
  final int score;
  final String? feedback;
  final bool resolved;
  final String? selectedPairId;
  final ValueChanged<ContextChallengeAnswer> onAnswer;
  final VoidCallback onReveal;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _QuestHeader(
          currentTaskIndex: currentTaskIndex,
          totalCount: totalCount,
          score: score,
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFF5DDCFF).withValues(alpha: 0.56),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5DDCFF).withValues(alpha: 0.12),
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
                'Wähle das lokale Wort, das den Satz sinnvoll ergänzt.',
                style: TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                key: const ValueKey('context-challenge-sentence-card'),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF050912),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF26354B)),
                ),
                child: Text(
                  task.sentence,
                  key: const ValueKey('context-challenge-sentence'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFF4F8FF),
                    fontSize: 24,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _HintChip(text: task.hintTranslation),
              const SizedBox(height: 18),
              for (final answer in task.answers) ...[
                _AnswerButton(
                  key: ValueKey('context-challenge-answer-${answer.pairId}'),
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
                  isPositive: feedback == 'Passt in den Kontext!',
                ),
              ],
              if (resolved) ...[
                const SizedBox(height: 14),
                _CorrectAnswer(text: task.correctAnswerText),
                const SizedBox(height: 18),
                FilledButton(
                  key: const ValueKey('context-challenge-next-button'),
                  onPressed: onNext,
                  style: _primaryButtonStyle(),
                  child: const Text('Weiter'),
                ),
              ] else ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  key: const ValueKey('context-challenge-reveal-button'),
                  onPressed: onReveal,
                  style: _secondaryButtonStyle(),
                  child: const Text('Auflösen'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _QuestHeader extends StatelessWidget {
  const _QuestHeader({
    required this.currentTaskIndex,
    required this.totalCount,
    required this.score,
  });

  final int currentTaskIndex;
  final int totalCount;
  final int score;

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
          const Icon(Icons.auto_stories_rounded, color: Color(0xFF5DDCFF)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${currentTaskIndex + 1} / $totalCount',
              style: const TextStyle(
                color: Color(0xFFF4F8FF),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            'Richtig: $score',
            style: const TextStyle(
              color: Color(0xFF5DDCFF),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HintChip extends StatelessWidget {
  const _HintChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF5DDCFF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF5DDCFF).withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        'Hinweis: $text',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFFB8C7D9),
          fontWeight: FontWeight.w800,
          height: 1.25,
        ),
      ),
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

  final ContextChallengeAnswer answer;
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
      key: const ValueKey('context-challenge-solution'),
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
            'Richtige Lösung',
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
    required this.score,
    required this.totalCount,
    required this.onRestart,
    required this.onBack,
  });

  final int score;
  final int totalCount;
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
            border: Border.all(color: const Color(0xFF5DDCFF)),
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
                'Challenge beendet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Du hast $score von $totalCount Kontext-Aufgaben richtig gelöst.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dein Lernfortschritt wurde nicht verändert.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF5DDCFF),
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: onRestart,
                style: _primaryButtonStyle(),
                child: const Text('Nochmal spielen'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
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

class _ContextMessageState extends StatelessWidget {
  const _ContextMessageState({
    required this.title,
    required this.text,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String text;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 44, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFF26354B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF5DDCFF),
                size: 42,
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onPressed,
                style: _secondaryButtonStyle(),
                child: Text(buttonLabel),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

ButtonStyle _primaryButtonStyle() {
  return FilledButton.styleFrom(
    backgroundColor: const Color(0xFF5DDCFF),
    foregroundColor: const Color(0xFF041018),
    padding: const EdgeInsets.symmetric(vertical: 15),
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}

ButtonStyle _secondaryButtonStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFFF4F8FF),
    side: const BorderSide(color: Color(0xFF5DDCFF)),
    padding: const EdgeInsets.symmetric(vertical: 15),
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}
