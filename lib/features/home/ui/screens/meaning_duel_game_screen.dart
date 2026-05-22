import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';

class MeaningDuelGameScreen extends ConsumerStatefulWidget {
  const MeaningDuelGameScreen({super.key});

  static const routeName = 'meaning-duel-game';

  @override
  ConsumerState<MeaningDuelGameScreen> createState() =>
      _MeaningDuelGameScreenState();
}

class _MeaningDuelGameScreenState extends ConsumerState<MeaningDuelGameScreen> {
  List<MeaningDuelPair> _roundPairs = const <MeaningDuelPair>[];
  String _roundKey = '';
  int _currentQuestionIndex = 0;
  int _correctCount = 0;
  bool _isFinished = false;
  bool _resolved = false;
  String? _selectedPairId;
  String? _feedback;

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
        title: const Text('Bedeutungs-Duell'),
      ),
      body: SafeArea(
        child: wordsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF8A5B)),
          ),
          error: (_, __) => _MeaningDuelMessageState(
            title: 'Wörter konnten nicht geladen werden',
            text: 'Versuche es gleich noch einmal.',
            buttonLabel: 'Zurück',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          data: (words) {
            final pairs = buildMeaningDuelPairs(words);
            if (pairs.length < 4) {
              return _MeaningDuelMessageState(
                title: 'Noch nicht genug Wörter',
                text:
                    'Füge mindestens vier Wörter mit Übersetzung hinzu, um Bedeutungs-Duell zu spielen.',
                buttonLabel: 'Zurück',
                onPressed: () => Navigator.of(context).maybePop(),
              );
            }

            _ensureRound(pairs);
            if (_isFinished) {
              return _FinishedView(
                correctCount: _correctCount,
                totalCount: _roundPairs.length,
                onRestart: () => setState(() => _restartRound(pairs)),
                onBack: () => Navigator.of(context).maybePop(),
              );
            }

            final question = buildMeaningDuelQuestion(
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

  void _ensureRound(List<MeaningDuelPair> pairs) {
    final nextKey = pairs.map((pair) => pair.id).join('|');
    if (_roundKey == nextKey && _roundPairs.isNotEmpty) return;
    _roundKey = nextKey;
    _restartRound(pairs);
  }

  void _restartRound(List<MeaningDuelPair> pairs) {
    _roundPairs = List<MeaningDuelPair>.unmodifiable(pairs.take(10));
    _currentQuestionIndex = 0;
    _correctCount = 0;
    _isFinished = false;
    _resolved = false;
    _selectedPairId = null;
    _feedback = null;
  }

  void _answer(MeaningDuelAnswer answer) {
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
List<MeaningDuelPair> buildMeaningDuelPairs(List<LocalWord> words) {
  final pairs = <MeaningDuelPair>[];
  final seenTerms = <String>{};
  final seenTranslations = <String>{};

  for (final word in words) {
    final term = word.term.trim();
    final translation = word.translation.trim();
    if (term.isEmpty || translation.isEmpty || word.isArchived) continue;

    final normalizedTerm = normalizeMeaningDuelText(term);
    final normalizedTranslation = normalizeMeaningDuelText(translation);
    if (!seenTerms.add(normalizedTerm)) continue;
    if (!seenTranslations.add(normalizedTranslation)) continue;

    pairs.add(
      MeaningDuelPair(id: word.id, term: term, translation: translation),
    );
  }

  return List<MeaningDuelPair>.unmodifiable(pairs);
}

@visibleForTesting
MeaningDuelQuestion buildMeaningDuelQuestion({
  required List<MeaningDuelPair> pairs,
  required int questionIndex,
}) {
  final correct = pairs[questionIndex % pairs.length];
  final distractors = <MeaningDuelPair>[];
  for (var offset = 1; distractors.length < 3; offset += 1) {
    final candidate = pairs[(questionIndex + offset) % pairs.length];
    if (candidate.id == correct.id) continue;
    if (distractors.any((pair) => pair.id == candidate.id)) continue;
    distractors.add(candidate);
  }

  final rawAnswers = <MeaningDuelAnswer>[
    MeaningDuelAnswer(pairId: correct.id, text: correct.translation),
    for (final pair in distractors)
      MeaningDuelAnswer(pairId: pair.id, text: pair.translation),
  ];
  final shift = (questionIndex + 1) % rawAnswers.length;
  final answers = <MeaningDuelAnswer>[
    ...rawAnswers.skip(shift),
    ...rawAnswers.take(shift),
  ];

  return MeaningDuelQuestion(
    correctPairId: correct.id,
    prompt: correct.term,
    correctAnswerText: correct.translation,
    answers: List<MeaningDuelAnswer>.unmodifiable(
      answers.map(
        (answer) => MeaningDuelAnswer(
          pairId: answer.pairId,
          text: answer.text,
          isCorrect: answer.pairId == correct.id,
        ),
      ),
    ),
  );
}

@visibleForTesting
String normalizeMeaningDuelText(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

class MeaningDuelPair {
  const MeaningDuelPair({
    required this.id,
    required this.term,
    required this.translation,
  });

  final String id;
  final String term;
  final String translation;
}

class MeaningDuelQuestion {
  const MeaningDuelQuestion({
    required this.correctPairId,
    required this.prompt,
    required this.correctAnswerText,
    required this.answers,
  });

  final String correctPairId;
  final String prompt;
  final String correctAnswerText;
  final List<MeaningDuelAnswer> answers;
}

class MeaningDuelAnswer {
  const MeaningDuelAnswer({
    required this.pairId,
    required this.text,
    this.isCorrect = false,
  });

  final String pairId;
  final String text;
  final bool isCorrect;
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

  final MeaningDuelQuestion question;
  final int currentIndex;
  final int totalCount;
  final String? feedback;
  final bool resolved;
  final String? selectedPairId;
  final ValueChanged<MeaningDuelAnswer> onAnswer;
  final VoidCallback onReveal;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
                'Welche Bedeutung passt?',
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Wähle ruhig und konzentriert die richtige Übersetzung.',
                style: TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                key: const ValueKey('meaning-duel-prompt-card'),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF050912),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF26354B)),
                ),
                child: Text(
                  question.prompt,
                  key: const ValueKey('meaning-duel-prompt'),
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
                  key: ValueKey('meaning-duel-answer-${answer.pairId}'),
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
                  key: const ValueKey('meaning-duel-next-button'),
                  onPressed: onNext,
                  style: _primaryButtonStyle(),
                  child: const Text('Nächste Frage'),
                ),
              ] else ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  key: const ValueKey('meaning-duel-reveal-button'),
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

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    super.key,
    required this.answer,
    required this.isResolved,
    required this.isSelected,
    required this.onTap,
  });

  final MeaningDuelAnswer answer;
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
              'Lokales Duell',
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
      key: const ValueKey('meaning-duel-correct-answer'),
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
            'Richtige Bedeutung',
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
                'Duell beendet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Du hast $correctCount von $totalCount Bedeutungen richtig erkannt.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                key: const ValueKey('meaning-duel-restart-button'),
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
                key: const ValueKey('meaning-duel-back-button'),
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

class _MeaningDuelMessageState extends StatelessWidget {
  const _MeaningDuelMessageState({
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
