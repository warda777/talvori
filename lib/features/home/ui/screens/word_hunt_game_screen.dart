import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';

class WordHuntGameScreen extends ConsumerStatefulWidget {
  const WordHuntGameScreen({super.key});

  static const routeName = 'word-hunt-game';

  @override
  ConsumerState<WordHuntGameScreen> createState() => _WordHuntGameScreenState();
}

class _WordHuntGameScreenState extends ConsumerState<WordHuntGameScreen> {
  List<WordHuntPair> _roundPairs = const <WordHuntPair>[];
  String _roundKey = '';
  int _currentQuestionIndex = 0;
  int _hitCount = 0;
  bool _started = false;
  bool _finished = false;
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
            final pairs = buildWordHuntPairs(words);
            if (pairs.length < 4) {
              return _WordHuntMessageState(
                title: 'Noch nicht genug Wörter',
                text:
                    'Füge mindestens vier Wörter mit Übersetzung hinzu, um Wort-Jagd zu spielen.',
                buttonLabel: 'Zurück',
                onPressed: () => Navigator.of(context).maybePop(),
              );
            }

            _ensureRound(pairs);
            if (_finished) {
              return _FinishedView(
                hitCount: _hitCount,
                totalCount: _roundPairs.length,
                onRestart: () => setState(() => _restartRound(pairs)),
                onBack: () => Navigator.of(context).maybePop(),
              );
            }

            if (!_started) {
              return _StartView(onStart: _startRound);
            }

            final question = buildWordHuntQuestion(
              pairs: _roundPairs,
              questionIndex: _currentQuestionIndex,
            );
            return _QuestionView(
              question: question,
              currentIndex: _currentQuestionIndex,
              totalCount: _roundPairs.length,
              hitCount: _hitCount,
              feedback: _feedback,
              onAnswer: _answer,
            );
          },
        ),
      ),
    );
  }

  void _ensureRound(List<WordHuntPair> pairs) {
    final nextKey = pairs.map((pair) => pair.id).join('|');
    if (_roundKey == nextKey && _roundPairs.isNotEmpty) return;
    _roundKey = nextKey;
    _restartRound(pairs);
  }

  void _restartRound(List<WordHuntPair> pairs) {
    _roundPairs = List<WordHuntPair>.unmodifiable(pairs.take(10));
    _currentQuestionIndex = 0;
    _hitCount = 0;
    _started = false;
    _finished = false;
    _feedback = null;
  }

  void _startRound() {
    setState(() {
      _started = true;
      _finished = false;
      _currentQuestionIndex = 0;
      _hitCount = 0;
      _feedback = null;
    });
  }

  void _answer(WordHuntAnswer answer) {
    if (!_started || _finished) return;
    setState(() {
      if (answer.isCorrect) {
        _hitCount += 1;
        _feedback = 'Treffer!';
      } else {
        _feedback = 'Daneben.';
      }

      if (_currentQuestionIndex >= _roundPairs.length - 1) {
        _started = false;
        _finished = true;
        return;
      }
      _currentQuestionIndex += 1;
    });
  }
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
WordHuntQuestion buildWordHuntQuestion({
  required List<WordHuntPair> pairs,
  required int questionIndex,
}) {
  final correct = pairs[questionIndex % pairs.length];
  final distractors = <WordHuntPair>[];
  for (var offset = 1; distractors.length < 3; offset += 1) {
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
  final shift = (questionIndex + 2) % rawAnswers.length;
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

class _StartView extends StatelessWidget {
  const _StartView({required this.onStart});

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
                'Tippe schnell die richtige Bedeutung an.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
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

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.question,
    required this.currentIndex,
    required this.totalCount,
    required this.hitCount,
    required this.feedback,
    required this.onAnswer,
  });

  final WordHuntQuestion question;
  final int currentIndex;
  final int totalCount;
  final int hitCount;
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
                icon: Icons.route_rounded,
                label: '${currentIndex + 1} / $totalCount',
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
                'Finde die Bedeutung',
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
    required this.hitCount,
    required this.totalCount,
    required this.onRestart,
    required this.onBack,
  });

  final int hitCount;
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
              const Text(
                'Jagd beendet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Du hast $hitCount von $totalCount Bedeutungen richtig getroffen.',
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
                child: const Text('Nochmal spielen'),
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
