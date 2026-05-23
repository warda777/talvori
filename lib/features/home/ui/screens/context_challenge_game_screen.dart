import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/application/word_game_ai_provider.dart';
import 'package:talvori/features/home/application/word_game_language_pair.dart';
import 'package:talvori/features/home/application/word_game_progress_controller.dart';
import 'package:talvori/features/home/ui/widgets/game_word_source_picker.dart';

class ContextChallengeGameScreen extends ConsumerStatefulWidget {
  const ContextChallengeGameScreen({super.key});

  static const routeName = 'context-challenge-game';

  @override
  ConsumerState<ContextChallengeGameScreen> createState() =>
      _ContextChallengeGameScreenState();
}

class _ContextChallengeGameScreenState
    extends ConsumerState<ContextChallengeGameScreen> {
  GameWordSource _selectedSource = GameWordSource.standard(
    LocalLearningSource.allWords,
  );
  final SharedPreferencesWordGameProgressRepository _progressRepository =
      const SharedPreferencesWordGameProgressRepository();
  int _wordsPerRound = 10;
  WordGameLanguagePair _languagePair = WordGameLanguagePair.englishGerman;
  List<ContextChallengePair> _roundPairs = const <ContextChallengePair>[];
  String _roundKey = '';
  int _currentTaskIndex = 0;
  int _score = 0;
  bool _hasStarted = false;
  bool _isFinished = false;
  bool _resolved = false;
  bool _isAiLoading = false;
  String? _aiSentence;
  String? _feedback;
  String? _selectedPairId;

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
            final categories = categoriesAsync.value ?? const <LocalCategory>[];
            final pairs = buildContextChallengePairs(words);
            if (pairs.length < 4) {
              return _ContextMessageState(
                title: 'Noch nicht genug Wörter',
                text: _selectedSource.categoryId == null
                    ? 'Diese Wortquelle braucht mindestens vier Wörter mit Übersetzung, um die Kontext-Challenge zu starten.'
                    : 'Diese Wortwelt braucht mindestens vier Wörter mit Übersetzung, um die Kontext-Challenge zu starten.',
                buttonLabel: 'Zurück',
                onPressed: () => Navigator.of(context).maybePop(),
              );
            }

            final sourceKey =
                '${_selectedSource.key}:${pairs.map((pair) => pair.id).join('|')}';
            if (_roundKey != sourceKey) {
              _roundKey = sourceKey;
              _restartRound(pairs);
            }
            if (_isFinished) {
              return _FinishedView(
                score: _score,
                totalCount: _roundPairs.length,
                onRestart: () => setState(() => _restartRound(pairs)),
                onBack: () => Navigator.of(context).maybePop(),
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
                languagePair: _languagePair,
                onSourceSelected: _selectSource,
                onWordsPerRoundChanged: _selectWordsPerRound,
                onLanguagePairChanged: (pair) {
                  setState(() => _languagePair = pair);
                },
                onStart: _startChallenge,
              );
            }

            final task = buildContextChallengeTask(
              pairs: _roundPairs,
              taskIndex: _currentTaskIndex,
              languagePair: _languagePair,
              sentenceOverride: _aiSentence,
            );
            return _TaskView(
              key: ValueKey('context-challenge-task-$_currentTaskIndex'),
              task: task,
              currentTaskIndex: _currentTaskIndex,
              totalCount: _roundPairs.length,
              score: _score,
              isAiLoading: _isAiLoading,
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

  void _resetForSelection(String sourceKey) {
    _roundKey = sourceKey;
    _roundPairs = const <ContextChallengePair>[];
    _currentTaskIndex = 0;
    _score = 0;
    _hasStarted = false;
    _isFinished = false;
    _resolved = false;
    _isAiLoading = false;
    _aiSentence = null;
    _feedback = null;
    _selectedPairId = null;
  }

  void _selectSource(GameWordSource source) {
    if (_selectedSource == source) return;
    setState(() {
      _selectedSource = source;
      _resetForSelection('');
    });
  }

  void _restartRound(List<ContextChallengePair> pairs) {
    _roundPairs = List<ContextChallengePair>.unmodifiable(
      pairs.take(_effectiveWordsPerRound(pairs.length)),
    );
    _progressRepository.markPlayedIds(
      'context-challenge',
      _selectedSource.key,
      _roundPairs.map((pair) => pair.id),
    );
    _currentTaskIndex = 0;
    _score = 0;
    _hasStarted = false;
    _isFinished = false;
    _resolved = false;
    _isAiLoading = false;
    _aiSentence = null;
    _feedback = null;
    _selectedPairId = null;
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
      _resetForSelection('');
    });
  }

  void _startChallenge() {
    setState(() {
      _hasStarted = true;
      _resolved = false;
      _isAiLoading = true;
      _aiSentence = null;
      _feedback = null;
      _selectedPairId = null;
    });
    _loadAiSentence();
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
      _isAiLoading = true;
      _aiSentence = null;
      _feedback = null;
      _selectedPairId = null;
    });
    _loadAiSentence();
  }

  Future<void> _loadAiSentence() async {
    if (_roundPairs.isEmpty) return;
    final pair = _roundPairs[_currentTaskIndex];
    final sourceTarget = _contextSourceText(pair, _languagePair);
    try {
      final result = await ref
          .read(wordGameAiClientProvider)
          .sendMessage(
            AiChatRequest(
              language: _languagePair.sourceCode,
              message:
                  'Erzeuge einen kurzen Kontextsatz in ${_languagePair.sourceLabel} mit genau einer Luecke ___ fuer das Zielwort "$sourceTarget". Nenne das Zielwort nicht im Satz. Die Antwortoptionen sind in ${_languagePair.answerLabel}. Antworte nur mit dem Satz.',
              context: {
                'game': 'context-challenge',
                'word': pair.term,
                'translation': pair.translation,
                'sourceTarget': sourceTarget,
                'sourceLanguage': _languagePair.sourceCode,
                'answerLanguage': _languagePair.answerCode,
                'languagePair': _languagePair.label,
              },
            ),
          );
      final sentence = sanitizeContextChallengeAiSentence(
        result.reply,
        sourceTarget,
      );
      if (!mounted) return;
      setState(() {
        _aiSentence = sentence;
        _isAiLoading = false;
        if (sentence == null) {
          _feedback =
              'KI-Kontext momentan nicht verfügbar. Lokale Vorlage aktiv.';
        }
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _aiSentence = null;
        _isAiLoading = false;
        _feedback =
            'KI-Kontext momentan nicht verfügbar. Lokale Vorlage aktiv.';
      });
    }
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
  WordGameLanguagePair languagePair = WordGameLanguagePair.englishGerman,
  String? sentenceOverride,
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
    ContextChallengeAnswer(
      pairId: correct.id,
      text: _contextAnswerText(correct, languagePair),
    ),
    for (final pair in distractors)
      ContextChallengeAnswer(
        pairId: pair.id,
        text: _contextAnswerText(pair, languagePair),
      ),
  ];
  final shift = (taskIndex + 2) % rawAnswers.length;
  final answers = <ContextChallengeAnswer>[
    ...rawAnswers.skip(shift),
    ...rawAnswers.take(shift),
  ];

  return ContextChallengeTask(
    correctPairId: correct.id,
    correctAnswerText: _contextAnswerText(correct, languagePair),
    hintTranslation: correct.translation,
    hintTerm: _contextSourceText(correct, languagePair),
    sentence:
        sentenceOverride ??
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

String _contextAnswerText(
  ContextChallengePair pair,
  WordGameLanguagePair languagePair,
) {
  return languagePair.answerCode == 'de' ? pair.translation : pair.term;
}

String _contextSourceText(
  ContextChallengePair pair,
  WordGameLanguagePair languagePair,
) {
  return languagePair.sourceCode == 'de' ? pair.translation : pair.term;
}

@visibleForTesting
String? sanitizeContextChallengeAiSentence(String reply, String targetWord) {
  final sentence = reply.trim().replaceAll(RegExp(r'^["“”]|["“”]$'), '');
  if (sentence.isEmpty || !sentence.contains('___')) return null;
  if (sentence.toLowerCase().contains(targetWord.trim().toLowerCase())) {
    return null;
  }
  return sentence.length <= 180 ? sentence : null;
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
    required this.hintTerm,
    required this.sentence,
    required this.answers,
  });

  final String correctPairId;
  final String correctAnswerText;
  final String hintTranslation;
  final String hintTerm;
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
  const _StartView({
    required this.selectedSource,
    required this.categories,
    required this.availableIds,
    required this.wordsPerRound,
    required this.languagePair,
    required this.onSourceSelected,
    required this.onWordsPerRoundChanged,
    required this.onLanguagePairChanged,
    required this.onStart,
  });

  final GameWordSource selectedSource;
  final List<LocalCategory> categories;
  final List<String> availableIds;
  final int wordsPerRound;
  final WordGameLanguagePair languagePair;
  final ValueChanged<GameWordSource> onSourceSelected;
  final ValueChanged<int> onWordsPerRoundChanged;
  final ValueChanged<WordGameLanguagePair> onLanguagePairChanged;
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
                'Dieses KI-Spiel erzeugt kurze Kontextsätze mit Talvori KI.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const _ContextAiBadge(),
              const SizedBox(height: 16),
              _ContextLanguagePicker(
                selected: languagePair,
                onSelected: onLanguagePairChanged,
              ),
              const SizedBox(height: 20),
              GameWordSourcePicker(
                keyPrefix: 'context-challenge',
                selectedSource: selectedSource,
                categories: categories,
                availableIds: availableIds,
                wordsPerRound: wordsPerRound,
                minWordsPerRound: 4,
                accentColor: const Color(0xFF5DDCFF),
                secondaryAccentColor: const Color(0xFF7DFFE3),
                onSourceSelected: onSourceSelected,
                onWordsPerRoundChanged: onWordsPerRoundChanged,
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
    required this.isAiLoading,
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
  final bool isAiLoading;
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
              if (isAiLoading) ...[
                const _ContextAiLoading(),
                const SizedBox(height: 12),
              ],
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
              _RevealingHintChip(term: task.hintTerm),
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

class _ContextAiBadge extends StatelessWidget {
  const _ContextAiBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF7DFFE3).withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF7DFFE3).withValues(alpha: 0.38),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 16, color: Color(0xFF7DFFE3)),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'KI-Spiel: keine Speicherung im Lernfortschritt.',
              style: TextStyle(
                color: Color(0xFFF4F8FF),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextLanguagePicker extends StatelessWidget {
  const _ContextLanguagePicker({
    required this.selected,
    required this.onSelected,
  });

  final WordGameLanguagePair selected;
  final ValueChanged<WordGameLanguagePair> onSelected;

  @override
  Widget build(BuildContext context) {
    final pairs = availableWordGameLanguagePairs();
    final swapped = selected.swapped();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sprachen',
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
            for (final pair in pairs)
              ChoiceChip(
                key: ValueKey(
                  'context-challenge-language-${pair.sourceCode}-${pair.answerCode}',
                ),
                label: Text(pair.label),
                selected: selected == pair,
                selectedColor: const Color(0xFF5DDCFF),
                backgroundColor: const Color(0xFF050912),
                labelStyle: TextStyle(
                  color: selected == pair
                      ? const Color(0xFF041018)
                      : const Color(0xFFF4F8FF),
                  fontWeight: FontWeight.w900,
                ),
                onSelected: (_) => onSelected(pair),
              ),
            if (swapped != null)
              IconButton(
                key: const ValueKey('context-challenge-language-swap'),
                tooltip: 'Richtung wechseln',
                onPressed: () => onSelected(swapped),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF5DDCFF,
                  ).withValues(alpha: 0.14),
                  foregroundColor: const Color(0xFF5DDCFF),
                  side: BorderSide(
                    color: const Color(0xFF5DDCFF).withValues(alpha: 0.42),
                  ),
                ),
                icon: const Icon(Icons.swap_horiz_rounded),
              ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Dieses KI-Spiel nutzt die gewählte Sprachkombination.',
          style: TextStyle(
            color: Color(0xFFB8C7D9),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ContextAiLoading extends StatelessWidget {
  const _ContextAiLoading();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: Color(0xFF7DFFE3),
          ),
        ),
        SizedBox(width: 10),
        Text(
          'KI-Kontext wird vorbereitet',
          style: TextStyle(
            color: Color(0xFFB8C7D9),
            fontWeight: FontWeight.w800,
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

@visibleForTesting
String buildContextChallengeHiddenHint(String term, int revealedCount) {
  final chars = term.trim().split('');
  if (chars.isEmpty) return '';

  var revealedLetters = 0;
  return chars
      .map((char) {
        if (char.trim().isEmpty) return ' ';
        if (revealedLetters < revealedCount) {
          revealedLetters += 1;
          return char;
        }
        return '_';
      })
      .join(' ');
}

class _RevealingHintChip extends StatefulWidget {
  const _RevealingHintChip({required this.term});

  final String term;

  @override
  State<_RevealingHintChip> createState() => _RevealingHintChipState();
}

class _RevealingHintChipState extends State<_RevealingHintChip> {
  int _revealedCount = 0;

  @override
  void didUpdateWidget(_RevealingHintChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.term != widget.term) {
      _revealedCount = 0;
    }
  }

  void _revealNextLetter() {
    final letterCount = widget.term
        .trim()
        .split('')
        .where((char) => char.trim().isNotEmpty)
        .length;
    if (_revealedCount >= letterCount) return;
    setState(() => _revealedCount += 1);
  }

  @override
  Widget build(BuildContext context) {
    final hint = buildContextChallengeHiddenHint(widget.term, _revealedCount);
    return InkWell(
      key: const ValueKey('context-challenge-hidden-hint'),
      borderRadius: BorderRadius.circular(16),
      onTap: _revealNextLetter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF5DDCFF).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF5DDCFF).withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          children: [
            const Text(
              'Hinweis antippen',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFB8C7D9),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hint,
              key: const ValueKey('context-challenge-hidden-hint-text'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFF4F8FF),
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
                height: 1.25,
              ),
            ),
          ],
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
