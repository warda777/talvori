import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/application/word_game_progress_controller.dart';
import 'package:talvori/features/home/ui/widgets/game_word_source_picker.dart';

class DailyWordQuestGameScreen extends ConsumerStatefulWidget {
  const DailyWordQuestGameScreen({super.key});

  static const routeName = 'daily-word-quest-game';

  @override
  ConsumerState<DailyWordQuestGameScreen> createState() =>
      _DailyWordQuestGameScreenState();
}

class _DailyWordQuestGameScreenState
    extends ConsumerState<DailyWordQuestGameScreen> {
  final TextEditingController _gapController = TextEditingController();
  final FocusNode _gapFocusNode = FocusNode();
  GameWordSource _selectedSource = GameWordSource.standard(
    LocalLearningSource.allWords,
  );
  final SharedPreferencesWordGameProgressRepository _progressRepository =
      const SharedPreferencesWordGameProgressRepository();
  int _wordsPerRound = 10;
  List<DailyQuestPair> _roundPairs = const <DailyQuestPair>[];
  List<QuestPuzzleLetter> _puzzleLetters = const <QuestPuzzleLetter>[];
  List<int> _selectedPuzzleIndexes = const <int>[];
  String _roundKey = '';
  int _currentTaskIndex = 0;
  int _score = 0;
  bool _hasStarted = false;
  bool _isFinished = false;
  bool _resolved = false;
  String? _feedback;
  String? _selectedAnswerId;

  @override
  void dispose() {
    _gapController.dispose();
    _gapFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wordsAsync = _selectedSource.categoryId == null
        ? ref.watch(localWordsForSourceProvider(_selectedSource.source))
        : ref.watch(localWordsForCategoryProvider(_selectedSource.categoryId!));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF050912),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050912),
        elevation: 0,
        centerTitle: true,
        title: const Text('Daily Word Quest'),
      ),
      body: SafeArea(
        child: wordsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF5DDCFF)),
          ),
          error: (_, __) => _QuestMessageState(
            title: 'Wörter konnten nicht geladen werden',
            text: 'Versuche es gleich noch einmal.',
            buttonLabel: 'Zurück',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          data: (words) {
            const categories = <LocalCategory>[];
            final pairs = buildDailyQuestPairs(words);
            if (pairs.length < 5) {
              return _QuestMessageState(
                title: 'Noch nicht genug Wörter',
                text: _selectedSource.categoryId == null
                    ? 'Diese Wortquelle braucht mindestens fünf Wörter, um deine Daily Word Quest zu starten.'
                    : 'Diese Wortwelt braucht mindestens fünf Wörter, um deine Daily Word Quest zu starten.',
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
                onSourceSelected: _selectSource,
                onWordsPerRoundChanged: _selectWordsPerRound,
                onStart: _startQuest,
              );
            }

            final task = buildDailyQuestTask(
              pairs: _roundPairs,
              taskIndex: _currentTaskIndex,
            );
            return _TaskView(
              task: task,
              currentTaskIndex: _currentTaskIndex,
              totalCount: _roundPairs.length,
              score: _score,
              feedback: _feedback,
              resolved: _resolved,
              selectedAnswerId: _selectedAnswerId,
              gapController: _gapController,
              gapFocusNode: _gapFocusNode,
              puzzleLetters: _puzzleLetters,
              selectedPuzzleIndexes: _selectedPuzzleIndexes,
              onAnswer: _answerChoice,
              onCheckGap: () => _checkGap(task),
              onPuzzleLetterTap: _selectPuzzleLetter,
              onReveal: () => _reveal(task),
              onNext: _nextTask,
            );
          },
        ),
      ),
    );
  }

  void _resetForSelection(String sourceKey) {
    _roundKey = sourceKey;
    _roundPairs = const <DailyQuestPair>[];
    _puzzleLetters = const <QuestPuzzleLetter>[];
    _selectedPuzzleIndexes = const <int>[];
    _currentTaskIndex = 0;
    _score = 0;
    _hasStarted = false;
    _isFinished = false;
    _resolved = false;
    _feedback = null;
    _selectedAnswerId = null;
    _gapController.clear();
  }

  void _selectSource(GameWordSource source) {
    if (_selectedSource == source) return;
    setState(() {
      _selectedSource = source;
      _resetForSelection('');
    });
  }

  void _restartRound(List<DailyQuestPair> pairs) {
    _roundPairs = List<DailyQuestPair>.unmodifiable(
      pairs.take(_effectiveWordsPerRound(pairs.length)),
    );
    _progressRepository.markPlayedIds(
      'daily-quest',
      _selectedSource.key,
      _roundPairs.map((pair) => pair.id),
    );
    _currentTaskIndex = 0;
    _score = 0;
    _hasStarted = false;
    _isFinished = false;
    _resolved = false;
    _feedback = null;
    _selectedAnswerId = null;
    _selectedPuzzleIndexes = const <int>[];
    _puzzleLetters = buildQuestPuzzleLetters(_roundPairs.last.term);
    _gapController.clear();
  }

  int _effectiveWordsPerRound(int available) {
    return clampWordsPerRound(
      requested: _wordsPerRound,
      minimum: 5,
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

  void _startQuest() {
    setState(() {
      _hasStarted = true;
      _resetTaskState();
    });
  }

  void _answerChoice(DailyQuestAnswer answer) {
    if (_resolved) return;
    setState(() {
      _resolved = true;
      _selectedAnswerId = answer.pairId;
      if (answer.isCorrect) {
        _score += 1;
        _feedback = 'Quest-Punkt!';
      } else {
        _feedback = 'Nicht ganz.';
      }
    });
  }

  void _checkGap(DailyQuestTask task) {
    if (_resolved) return;
    final isCorrect =
        normalizeDailyQuestAnswer(_gapController.text) ==
        normalizeDailyQuestAnswer(task.pair.term);
    setState(() {
      _resolved = true;
      if (isCorrect) {
        _score += 1;
        _feedback = 'Quest-Punkt!';
      } else {
        _feedback = 'Nicht ganz.';
      }
      _gapFocusNode.unfocus();
    });
  }

  void _selectPuzzleLetter(int index) {
    if (_resolved || _selectedPuzzleIndexes.contains(index)) return;
    final nextIndexes = [..._selectedPuzzleIndexes, index];
    final answer = nextIndexes.map((i) => _puzzleLetters[i].char).join();
    final task = buildDailyQuestTask(
      pairs: _roundPairs,
      taskIndex: _currentTaskIndex,
    );
    final isComplete = nextIndexes.length == task.pair.term.trim().length;
    setState(() {
      _selectedPuzzleIndexes = nextIndexes;
      _feedback = null;
      if (isComplete) {
        _resolved = true;
        if (normalizeDailyQuestAnswer(answer) ==
            normalizeDailyQuestAnswer(task.pair.term)) {
          _score += 1;
          _feedback = 'Quest-Punkt!';
        } else {
          _feedback = 'Nicht ganz.';
        }
      }
    });
  }

  void _reveal(DailyQuestTask task) {
    if (_resolved) return;
    setState(() {
      _resolved = true;
      _feedback = 'Aufgelöst.';
      _gapFocusNode.unfocus();
    });
  }

  void _nextTask() {
    setState(() {
      if (_currentTaskIndex >= _roundPairs.length - 1) {
        _isFinished = true;
        return;
      }
      _currentTaskIndex += 1;
      _resetTaskState();
    });
  }

  void _resetTaskState() {
    _resolved = false;
    _feedback = null;
    _selectedAnswerId = null;
    _selectedPuzzleIndexes = const <int>[];
    _gapController.clear();
    if (_currentTaskIndex >= 4 && _roundPairs.isNotEmpty) {
      _puzzleLetters = buildQuestPuzzleLetters(
        _roundPairs[_currentTaskIndex % _roundPairs.length].term,
      );
    }
  }
}

const dailyQuestTaskCount = 5;

@visibleForTesting
List<DailyQuestPair> buildDailyQuestPairs(List<LocalWord> words) {
  final pairs = <DailyQuestPair>[];
  final seenTerms = <String>{};
  final seenTranslations = <String>{};

  for (final word in words) {
    final term = word.term.trim();
    final translation = word.translation.trim();
    if (word.isArchived) continue;
    if (!_isDailyQuestTerm(term)) continue;
    if (translation.isEmpty) continue;

    final normalizedTerm = normalizeDailyQuestAnswer(term);
    final normalizedTranslation = normalizeDailyQuestAnswer(translation);
    if (!seenTerms.add(normalizedTerm)) continue;
    if (!seenTranslations.add(normalizedTranslation)) continue;

    pairs.add(
      DailyQuestPair(id: word.id, term: term, translation: translation),
    );
    if (pairs.length == dailyQuestTaskCount) break;
  }

  return List<DailyQuestPair>.unmodifiable(pairs);
}

@visibleForTesting
DailyQuestTask buildDailyQuestTask({
  required List<DailyQuestPair> pairs,
  required int taskIndex,
}) {
  final pair = pairs[taskIndex % pairs.length];
  if (taskIndex < 3) {
    return DailyQuestTask.choice(
      pair: pair,
      answers: buildDailyQuestAnswers(pairs: pairs, taskIndex: taskIndex),
    );
  }
  if (taskIndex == 3) {
    return DailyQuestTask.gap(
      pair: pair,
      gapPattern: buildDailyQuestGapPattern(pair.term),
    );
  }
  return DailyQuestTask.puzzle(pair: pair);
}

@visibleForTesting
List<DailyQuestAnswer> buildDailyQuestAnswers({
  required List<DailyQuestPair> pairs,
  required int taskIndex,
}) {
  final correct = pairs[taskIndex % pairs.length];
  final distractors = <DailyQuestPair>[];
  for (var offset = 1; distractors.length < 3; offset += 1) {
    final candidate = pairs[(taskIndex + offset) % pairs.length];
    if (candidate.id == correct.id) continue;
    if (distractors.any((pair) => pair.id == candidate.id)) continue;
    distractors.add(candidate);
  }

  final rawAnswers = <DailyQuestAnswer>[
    DailyQuestAnswer(pairId: correct.id, text: correct.translation),
    for (final pair in distractors)
      DailyQuestAnswer(pairId: pair.id, text: pair.translation),
  ];
  final shift = (taskIndex + 2) % rawAnswers.length;
  final answers = <DailyQuestAnswer>[
    ...rawAnswers.skip(shift),
    ...rawAnswers.take(shift),
  ];
  return List<DailyQuestAnswer>.unmodifiable(
    answers.map(
      (answer) => DailyQuestAnswer(
        pairId: answer.pairId,
        text: answer.text,
        isCorrect: answer.pairId == correct.id,
      ),
    ),
  );
}

@visibleForTesting
String buildDailyQuestGapPattern(String term) {
  final chars = term.trim().split('');
  if (chars.isEmpty) return '';
  final removable = <int>[];
  var firstLetterSeen = false;
  for (var i = 0; i < chars.length; i += 1) {
    if (!_isDailyQuestLetter(chars[i])) continue;
    if (!firstLetterSeen) {
      firstLetterSeen = true;
      continue;
    }
    removable.add(i);
  }
  if (removable.isEmpty) return chars.join(' ');

  final hideCount = (chars.length * 0.36)
      .round()
      .clamp(1, removable.length)
      .toInt();
  final hidden = <int>{};
  var cursor = 0;
  while (hidden.length < hideCount) {
    hidden.add(removable[cursor % removable.length]);
    cursor += 2;
  }

  return [
    for (var i = 0; i < chars.length; i += 1)
      hidden.contains(i) ? '_' : chars[i],
  ].join(' ');
}

@visibleForTesting
String buildDailyQuestHiddenHint(String term, int revealedCount) {
  final chars = term.trim().split('');
  var remaining = revealedCount.clamp(0, chars.length).toInt();
  final visible = <String>[];

  for (final char in chars) {
    if (RegExp(r'\s').hasMatch(char)) {
      visible.add(' ');
      continue;
    }
    if (remaining > 0) {
      visible.add(char);
      remaining -= 1;
    } else {
      visible.add('_');
    }
  }

  return visible.join(' ');
}

@visibleForTesting
List<QuestPuzzleLetter> buildQuestPuzzleLetters(String term) {
  final chars = term.trim().split('');
  final indexed = [
    for (var i = 0; i < chars.length; i += 1)
      QuestPuzzleLetter(index: i, char: chars[i]),
  ];
  if (indexed.length <= 1) return List<QuestPuzzleLetter>.unmodifiable(indexed);

  final shuffled = List<QuestPuzzleLetter>.from(indexed);
  for (var i = 0; i < shuffled.length; i += 1) {
    final swapIndex = (i * 2 + 1) % shuffled.length;
    final item = shuffled[i];
    shuffled[i] = shuffled[swapIndex];
    shuffled[swapIndex] = item;
  }
  if (term.length > 3 &&
      shuffled.map((letter) => letter.char).join() == term.trim()) {
    final item = shuffled.first;
    shuffled[0] = shuffled[1];
    shuffled[1] = item;
  }
  return List<QuestPuzzleLetter>.unmodifiable(shuffled);
}

@visibleForTesting
String normalizeDailyQuestAnswer(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

bool _isDailyQuestTerm(String term) {
  if (term.length < 4) return false;
  if (RegExp(r'[\s\-]').hasMatch(term)) return false;
  return term.split('').every(_isDailyQuestLetter);
}

bool _isDailyQuestLetter(String char) {
  return RegExp(r'[A-Za-zÄÖÜäöü]').hasMatch(char);
}

enum DailyQuestTaskType { choice, gap, puzzle }

class DailyQuestPair {
  const DailyQuestPair({
    required this.id,
    required this.term,
    required this.translation,
  });

  final String id;
  final String term;
  final String translation;
}

class DailyQuestTask {
  const DailyQuestTask._({
    required this.type,
    required this.pair,
    this.answers = const <DailyQuestAnswer>[],
    this.gapPattern = '',
  });

  factory DailyQuestTask.choice({
    required DailyQuestPair pair,
    required List<DailyQuestAnswer> answers,
  }) {
    return DailyQuestTask._(
      type: DailyQuestTaskType.choice,
      pair: pair,
      answers: answers,
    );
  }

  factory DailyQuestTask.gap({
    required DailyQuestPair pair,
    required String gapPattern,
  }) {
    return DailyQuestTask._(
      type: DailyQuestTaskType.gap,
      pair: pair,
      gapPattern: gapPattern,
    );
  }

  factory DailyQuestTask.puzzle({required DailyQuestPair pair}) {
    return DailyQuestTask._(type: DailyQuestTaskType.puzzle, pair: pair);
  }

  final DailyQuestTaskType type;
  final DailyQuestPair pair;
  final List<DailyQuestAnswer> answers;
  final String gapPattern;
}

class DailyQuestAnswer {
  const DailyQuestAnswer({
    required this.pairId,
    required this.text,
    this.isCorrect = false,
  });

  final String pairId;
  final String text;
  final bool isCorrect;
}

@visibleForTesting
class QuestPuzzleLetter {
  const QuestPuzzleLetter({required this.index, required this.char});

  final int index;
  final String char;
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
      cacheExtent: 1400,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: _questCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.flag_rounded,
                color: Color(0xFF5DDCFF),
                size: 46,
              ),
              const SizedBox(height: 16),
              const Text(
                'Deine heutige Wortmission',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Löse eine kurze Quest mit lokalen Wörtern. Dein Lernfortschritt bleibt unverändert.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              const _QuestGoal(text: '3 Bedeutungen erkennen'),
              const _QuestGoal(text: '1 Wort ergänzen'),
              const _QuestGoal(text: '1 Wort zusammensetzen'),
              const SizedBox(height: 20),
              GameWordSourcePicker(
                keyPrefix: 'daily-quest',
                selectedSource: selectedSource,
                categories: categories,
                availableIds: availableIds,
                wordsPerRound: wordsPerRound,
                minWordsPerRound: 5,
                accentColor: const Color(0xFF5DDCFF),
                secondaryAccentColor: const Color(0xFF7DFFE3),
                onSourceSelected: onSourceSelected,
                onWordsPerRoundChanged: onWordsPerRoundChanged,
              ),
              const SizedBox(height: 22),
              FilledButton(
                key: const ValueKey('daily-quest-start-button'),
                onPressed: onStart,
                style: _primaryButtonStyle(),
                child: const Text('Quest starten'),
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
    required this.task,
    required this.currentTaskIndex,
    required this.totalCount,
    required this.score,
    required this.feedback,
    required this.resolved,
    required this.selectedAnswerId,
    required this.gapController,
    required this.gapFocusNode,
    required this.puzzleLetters,
    required this.selectedPuzzleIndexes,
    required this.onAnswer,
    required this.onCheckGap,
    required this.onPuzzleLetterTap,
    required this.onReveal,
    required this.onNext,
  });

  final DailyQuestTask task;
  final int currentTaskIndex;
  final int totalCount;
  final int score;
  final String? feedback;
  final bool resolved;
  final String? selectedAnswerId;
  final TextEditingController gapController;
  final FocusNode gapFocusNode;
  final List<QuestPuzzleLetter> puzzleLetters;
  final List<int> selectedPuzzleIndexes;
  final ValueChanged<DailyQuestAnswer> onAnswer;
  final VoidCallback onCheckGap;
  final ValueChanged<int> onPuzzleLetterTap;
  final VoidCallback onReveal;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: ValueKey('daily-quest-task-list-$currentTaskIndex'),
      cacheExtent: 1400,
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
          decoration: _questCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TaskTitle(type: task.type),
              const SizedBox(height: 8),
              _TaskHint(task: task),
              const SizedBox(height: 18),
              if (task.type == DailyQuestTaskType.choice)
                _ChoiceTask(
                  task: task,
                  resolved: resolved,
                  selectedAnswerId: selectedAnswerId,
                  onAnswer: onAnswer,
                )
              else if (task.type == DailyQuestTaskType.gap)
                _GapTask(
                  task: task,
                  controller: gapController,
                  focusNode: gapFocusNode,
                  resolved: resolved,
                )
              else
                _PuzzleTask(
                  term: task.pair.term,
                  letters: puzzleLetters,
                  selectedIndexes: selectedPuzzleIndexes,
                  resolved: resolved,
                  onLetterTap: onPuzzleLetterTap,
                ),
              if (feedback != null) ...[
                const SizedBox(height: 14),
                _FeedbackBanner(
                  text: feedback!,
                  isPositive: feedback == 'Quest-Punkt!',
                ),
              ],
              if (resolved) ...[
                const SizedBox(height: 14),
                _SolutionBox(task: task),
                const SizedBox(height: 18),
                FilledButton(
                  key: const ValueKey('daily-quest-next-button'),
                  onPressed: onNext,
                  style: _primaryButtonStyle(),
                  child: const Text('Weiter'),
                ),
              ] else if (task.type == DailyQuestTaskType.choice) ...[
                const SizedBox(height: 8),
                const Text(
                  'Wähle eine Antwort, um weiterzukommen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6F7F94),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    if (task.type == DailyQuestTaskType.gap) ...[
                      Expanded(
                        child: FilledButton(
                          key: const ValueKey('daily-quest-check-button'),
                          onPressed: onCheckGap,
                          style: _primaryButtonStyle(),
                          child: const Text('Prüfen'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: OutlinedButton(
                        key: const ValueKey('daily-quest-reveal-button'),
                        onPressed: onReveal,
                        style: _secondaryButtonStyle(),
                        child: const Text('Auflösen'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ChoiceTask extends StatelessWidget {
  const _ChoiceTask({
    required this.task,
    required this.resolved,
    required this.selectedAnswerId,
    required this.onAnswer,
  });

  final DailyQuestTask task;
  final bool resolved;
  final String? selectedAnswerId;
  final ValueChanged<DailyQuestAnswer> onAnswer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PromptCard(text: task.pair.term),
        const SizedBox(height: 16),
        for (final answer in task.answers) ...[
          _QuestAnswerButton(
            key: ValueKey('daily-quest-answer-${answer.pairId}'),
            answer: answer,
            resolved: resolved,
            selected: selectedAnswerId == answer.pairId,
            onTap: () => onAnswer(answer),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _GapTask extends StatelessWidget {
  const _GapTask({
    required this.task,
    required this.controller,
    required this.focusNode,
    required this.resolved,
  });

  final DailyQuestTask task;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool resolved;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PromptCard(text: task.gapPattern, keyValue: 'daily-quest-gap-pattern'),
        const SizedBox(height: 16),
        TextField(
          key: const ValueKey('daily-quest-gap-field'),
          controller: controller,
          focusNode: focusNode,
          enabled: !resolved,
          style: const TextStyle(
            color: Color(0xFFF4F8FF),
            fontWeight: FontWeight.w800,
          ),
          decoration: InputDecoration(
            hintText: 'Vollständiges Wort eingeben',
            hintStyle: const TextStyle(color: Color(0xFF6F7F94)),
            filled: true,
            fillColor: const Color(0xFF050912),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFF26354B)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFF5DDCFF)),
            ),
          ),
        ),
      ],
    );
  }
}

class _PuzzleTask extends StatelessWidget {
  const _PuzzleTask({
    required this.term,
    required this.letters,
    required this.selectedIndexes,
    required this.resolved,
    required this.onLetterTap,
  });

  final String term;
  final List<QuestPuzzleLetter> letters;
  final List<int> selectedIndexes;
  final bool resolved;
  final ValueChanged<int> onLetterTap;

  @override
  Widget build(BuildContext context) {
    final answer = selectedIndexes.map((index) => letters[index].char).join();
    return Column(
      children: [
        _RevealingPuzzleHint(term: term),
        const SizedBox(height: 16),
        _AnswerBox(answer: answer),
        const SizedBox(height: 16),
        Wrap(
          key: const ValueKey('daily-quest-puzzle-letters'),
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < letters.length; i += 1)
              _LetterChip(
                key: ValueKey('daily-quest-puzzle-letter-$i'),
                letter: letters[i],
                selected: selectedIndexes.contains(i),
                disabled: resolved,
                onTap: () => onLetterTap(i),
              ),
          ],
        ),
      ],
    );
  }
}

class _TaskTitle extends StatelessWidget {
  const _TaskTitle({required this.type});

  final DailyQuestTaskType type;

  @override
  Widget build(BuildContext context) {
    final text = switch (type) {
      DailyQuestTaskType.choice => 'Bedeutung erkennen',
      DailyQuestTaskType.gap => 'Wort ergänzen',
      DailyQuestTaskType.puzzle => 'Wort zusammensetzen',
    };
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFF4F8FF),
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _TaskHint extends StatelessWidget {
  const _TaskHint({required this.task});

  final DailyQuestTask task;

  @override
  Widget build(BuildContext context) {
    final text = switch (task.type) {
      DailyQuestTaskType.choice => 'Wähle die passende Übersetzung.',
      DailyQuestTaskType.gap => 'Hinweis: ${task.pair.translation}',
      DailyQuestTaskType.puzzle => 'Sortiere die Buchstaben.',
    };
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFB8C7D9),
        height: 1.35,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _RevealingPuzzleHint extends StatefulWidget {
  const _RevealingPuzzleHint({required this.term});

  final String term;

  @override
  State<_RevealingPuzzleHint> createState() => _RevealingPuzzleHintState();
}

class _RevealingPuzzleHintState extends State<_RevealingPuzzleHint> {
  int _revealedCount = 0;

  @override
  void didUpdateWidget(covariant _RevealingPuzzleHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.term != widget.term) {
      _revealedCount = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chars = widget.term.trim().split('');
    final mask = buildDailyQuestHiddenHint(widget.term, _revealedCount);

    return InkWell(
      key: const ValueKey('daily-quest-puzzle-hint'),
      borderRadius: BorderRadius.circular(18),
      onTap: _revealedCount >= chars.length
          ? null
          : () => setState(() => _revealedCount += 1),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF071523),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF26354B)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5DDCFF).withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  color: Color(0xFF5DDCFF),
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Hinweis',
                  style: TextStyle(
                    color: Color(0xFFB8C7D9),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              mask,
              key: const ValueKey('daily-quest-puzzle-hint-mask'),
              style: const TextStyle(
                color: Color(0xFFF4F8FF),
                fontSize: 24,
                height: 1.2,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tippe für den nächsten Buchstaben',
              style: TextStyle(
                color: Color(0xFF7DFFE3),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestAnswerButton extends StatelessWidget {
  const _QuestAnswerButton({
    super.key,
    required this.answer,
    required this.resolved,
    required this.selected,
    required this.onTap,
  });

  final DailyQuestAnswer answer;
  final bool resolved;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCorrect = resolved && answer.isCorrect;
    final isWrong = resolved && selected && !answer.isCorrect;
    final borderColor = isCorrect
        ? const Color(0xFF9DFF7D)
        : isWrong
        ? const Color(0xFFFFD166)
        : const Color(0xFF26354B);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: resolved ? null : onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: borderColor.withValues(alpha: isCorrect || isWrong ? 0.14 : 0),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(
              isCorrect
                  ? Icons.check_circle_rounded
                  : isWrong
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

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.text, this.keyValue});

  final String text;
  final String? keyValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: keyValue == null ? null : ValueKey(keyValue),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF050912),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF26354B)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFFF4F8FF),
          fontSize: 30,
          height: 1.2,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _AnswerBox extends StatelessWidget {
  const _AnswerBox({required this.answer});

  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('daily-quest-puzzle-answer'),
      constraints: const BoxConstraints(minHeight: 66),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF050912),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF26354B)),
      ),
      alignment: Alignment.center,
      child: Text(
        answer.isEmpty ? 'Tippe Buchstaben an' : answer,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: answer.isEmpty
              ? const Color(0xFF6F7F94)
              : const Color(0xFFF4F8FF),
          fontSize: 25,
          height: 1.2,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _LetterChip extends StatelessWidget {
  const _LetterChip({
    super.key,
    required this.letter,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final QuestPuzzleLetter letter;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: selected ? 0.36 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: selected || disabled ? null : onTap,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF101B2C) : const Color(0xFF071523),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? const Color(0xFF26354B)
                  : const Color(0xFF5DDCFF),
            ),
          ),
          child: Text(
            letter.char,
            style: const TextStyle(
              color: Color(0xFFF4F8FF),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _SolutionBox extends StatelessWidget {
  const _SolutionBox({required this.task});

  final DailyQuestTask task;

  @override
  Widget build(BuildContext context) {
    final label = task.type == DailyQuestTaskType.choice
        ? 'Richtige Bedeutung'
        : 'Lösung';
    final value = task.type == DailyQuestTaskType.choice
        ? task.pair.translation
        : task.pair.term;
    return Container(
      key: const ValueKey('daily-quest-solution'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF050912),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF9DFF7D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFB8C7D9),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
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
          const Icon(Icons.flag_rounded, color: Color(0xFF5DDCFF)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Aufgabe ${currentTaskIndex + 1} / $totalCount',
              style: const TextStyle(
                color: Color(0xFFF4F8FF),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            'Punkte: $score',
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

class _QuestGoal extends StatelessWidget {
  const _QuestGoal({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF9DFF7D),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
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
      cacheExtent: 1000,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: _questCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFFFD166),
                size: 46,
              ),
              const SizedBox(height: 16),
              const Text(
                'Quest abgeschlossen',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Du hast $score von $totalCount Quest-Punkten gesammelt.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dein SRS-Fortschritt wurde nicht verändert.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7DFFE3),
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

class _QuestMessageState extends StatelessWidget {
  const _QuestMessageState({
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
      cacheExtent: 1000,
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: _questCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.flag_outlined,
                color: Color(0xFF5DDCFF),
                size: 42,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 23,
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
              FilledButton(
                onPressed: onPressed,
                style: _primaryButtonStyle(),
                child: Text(buttonLabel),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

BoxDecoration _questCardDecoration() {
  return BoxDecoration(
    color: const Color(0xFF0B1220),
    borderRadius: BorderRadius.circular(26),
    border: Border.all(color: const Color(0xFF5DDCFF).withValues(alpha: 0.56)),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF5DDCFF).withValues(alpha: 0.12),
        blurRadius: 28,
        spreadRadius: -4,
      ),
    ],
  );
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
