import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/application/word_game_progress_controller.dart';
import 'package:talvori/features/home/ui/widgets/game_word_source_picker.dart';

class BossFightGameScreen extends ConsumerStatefulWidget {
  const BossFightGameScreen({super.key});

  static const routeName = 'boss-fight-game';

  @override
  ConsumerState<BossFightGameScreen> createState() =>
      _BossFightGameScreenState();
}

class _BossFightGameScreenState extends ConsumerState<BossFightGameScreen> {
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();
  GameWordSource _selectedSource = GameWordSource.standard(
    LocalLearningSource.allWords,
  );
  final SharedPreferencesWordGameProgressRepository _progressRepository =
      const SharedPreferencesWordGameProgressRepository();
  int _wordsPerRound = 10;
  List<BossFightPair> _roundPairs = const <BossFightPair>[];
  String _roundKey = '';
  int _questionIndex = 0;
  int _bossHp = bossFightMaxHp;
  int _energy = bossFightMaxEnergy;
  int _hits = 0;
  bool _started = false;
  bool _resolved = false;
  BossFightEndState? _endState;
  String? _feedback;
  String? _selectedAnswerId;

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocusNode.dispose();
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
        title: const Text('Boss-Fight'),
      ),
      body: SafeArea(
        child: wordsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF5F7A)),
          ),
          error: (_, __) => _BossMessageState(
            title: 'Wörter konnten nicht geladen werden',
            text: 'Versuche es gleich noch einmal.',
            buttonLabel: 'Zurück',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          data: (words) {
            const categories = <LocalCategory>[];
            final pairs = buildBossFightPairs(words);
            if (pairs.length < 4) {
              return _BossMessageState(
                title: 'Noch nicht genug Wörter',
                text: _selectedSource.categoryId == null
                    ? 'Diese Wortquelle braucht mindestens vier Wörter mit Übersetzung, um den Boss-Fight zu starten.'
                    : 'Diese Wortwelt braucht mindestens vier Wörter mit Übersetzung, um den Boss-Fight zu starten.',
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
            if (_endState != null) {
              return _FinishedView(
                endState: _endState!,
                hits: _hits,
                onRestart: () => setState(() => _restartRound(pairs)),
                onBack: () => Navigator.of(context).maybePop(),
              );
            }
            if (!_started) {
              return _StartView(
                selectedSource: _selectedSource,
                categories: categories,
                availableIds: pairs
                    .map((pair) => pair.id)
                    .toList(growable: false),
                wordsPerRound: _effectiveWordsPerRound(pairs.length),
                onSourceSelected: _selectSource,
                onWordsPerRoundChanged: _selectWordsPerRound,
                onStart: _startFight,
              );
            }

            final question = buildBossFightQuestion(
              pairs: _roundPairs,
              questionIndex: _questionIndex,
            );
            return _FightView(
              question: question,
              questionIndex: _questionIndex,
              bossHp: _bossHp,
              energy: _energy,
              feedback: _feedback,
              resolved: _resolved,
              selectedAnswerId: _selectedAnswerId,
              answerController: _answerController,
              answerFocusNode: _answerFocusNode,
              onChoice: _answerChoice,
              onCheckInput: () => _checkInput(question),
              onReveal: () => _reveal(question),
              onNext: _nextQuestion,
            );
          },
        ),
      ),
    );
  }

  void _resetForSelection(String sourceKey) {
    _roundKey = sourceKey;
    _roundPairs = const <BossFightPair>[];
    _questionIndex = 0;
    _bossHp = bossFightMaxHp;
    _energy = bossFightMaxEnergy;
    _hits = 0;
    _started = false;
    _resolved = false;
    _endState = null;
    _feedback = null;
    _selectedAnswerId = null;
    _answerController.clear();
  }

  void _selectSource(GameWordSource source) {
    if (_selectedSource == source) return;
    setState(() {
      _selectedSource = source;
      _resetForSelection('');
    });
  }

  void _restartRound(List<BossFightPair> pairs) {
    _roundPairs = List<BossFightPair>.unmodifiable(
      pairs.take(_effectiveWordsPerRound(pairs.length)),
    );
    _progressRepository.markPlayedIds(
      'boss-fight',
      _selectedSource.key,
      _roundPairs.map((pair) => pair.id),
    );
    _questionIndex = 0;
    _bossHp = bossFightMaxHp;
    _energy = bossFightMaxEnergy;
    _hits = 0;
    _started = false;
    _resolved = false;
    _endState = null;
    _feedback = null;
    _selectedAnswerId = null;
    _answerController.clear();
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

  void _startFight() {
    setState(() {
      _started = true;
      _resetQuestionState();
    });
  }

  void _answerChoice(BossFightAnswer answer) {
    if (_resolved) return;
    setState(() {
      _resolved = true;
      _selectedAnswerId = answer.pairId;
      if (answer.isCorrect) {
        _registerHit();
      } else {
        _registerBlock();
      }
    });
  }

  void _checkInput(BossFightQuestion question) {
    if (_resolved) return;
    final isCorrect =
        normalizeBossFightAnswer(_answerController.text) ==
        normalizeBossFightAnswer(question.pair.term);
    setState(() {
      _resolved = true;
      if (isCorrect) {
        _registerHit();
      } else {
        _registerBlock();
      }
      _answerFocusNode.unfocus();
    });
  }

  void _reveal(BossFightQuestion question) {
    if (_resolved) return;
    setState(() {
      _resolved = true;
      _feedback = 'Aufgelöst.';
      _answerFocusNode.unfocus();
    });
  }

  void _registerHit() {
    _bossHp = (_bossHp - 1).clamp(0, bossFightMaxHp).toInt();
    _hits += 1;
    _feedback = 'Treffer!';
  }

  void _registerBlock() {
    _energy = (_energy - 1).clamp(0, bossFightMaxEnergy).toInt();
    _feedback = 'Der Boss blockt.';
  }

  void _nextQuestion() {
    setState(() {
      if (_bossHp <= 0) {
        _endState = BossFightEndState.defeated;
        return;
      }
      if (_energy <= 0) {
        _endState = BossFightEndState.escaped;
        return;
      }
      if (_questionIndex >= bossFightQuestionCount - 1) {
        _endState = BossFightEndState.finished;
        return;
      }
      _questionIndex += 1;
      _resetQuestionState();
    });
  }

  void _resetQuestionState() {
    _resolved = false;
    _feedback = null;
    _selectedAnswerId = null;
    _answerController.clear();
  }
}

const bossFightMaxHp = 8;
const bossFightMaxEnergy = 3;
const bossFightQuestionCount = 8;

@visibleForTesting
List<BossFightPair> buildBossFightPairs(List<LocalWord> words) {
  final pairs = <BossFightPair>[];
  final seenTerms = <String>{};
  final seenTranslations = <String>{};

  for (final word in words) {
    final term = word.term.trim();
    final translation = word.translation.trim();
    if (term.isEmpty || translation.isEmpty || word.isArchived) continue;

    final normalizedTerm = normalizeBossFightAnswer(term);
    final normalizedTranslation = normalizeBossFightAnswer(translation);
    if (!seenTerms.add(normalizedTerm)) continue;
    if (!seenTranslations.add(normalizedTranslation)) continue;

    pairs.add(BossFightPair(id: word.id, term: term, translation: translation));
  }

  return List<BossFightPair>.unmodifiable(pairs);
}

@visibleForTesting
BossFightQuestion buildBossFightQuestion({
  required List<BossFightPair> pairs,
  required int questionIndex,
}) {
  final pair = pairs[questionIndex % pairs.length];
  final type = switch (questionIndex % 3) {
    0 => BossFightQuestionType.choice,
    1 => BossFightQuestionType.gap,
    _ => BossFightQuestionType.input,
  };
  return BossFightQuestion(
    type: type,
    pair: pair,
    gapPattern: type == BossFightQuestionType.gap
        ? buildBossFightGapPattern(pair.term)
        : '',
    answers: type == BossFightQuestionType.choice
        ? buildBossFightAnswers(pairs: pairs, questionIndex: questionIndex)
        : const <BossFightAnswer>[],
  );
}

@visibleForTesting
List<BossFightAnswer> buildBossFightAnswers({
  required List<BossFightPair> pairs,
  required int questionIndex,
}) {
  final correct = pairs[questionIndex % pairs.length];
  final distractors = <BossFightPair>[];
  for (var offset = 1; distractors.length < 3; offset += 1) {
    final candidate = pairs[(questionIndex + offset) % pairs.length];
    if (candidate.id == correct.id) continue;
    if (distractors.any((pair) => pair.id == candidate.id)) continue;
    distractors.add(candidate);
  }

  final rawAnswers = <BossFightAnswer>[
    BossFightAnswer(pairId: correct.id, text: correct.translation),
    for (final pair in distractors)
      BossFightAnswer(pairId: pair.id, text: pair.translation),
  ];
  final shift = (questionIndex + 1) % rawAnswers.length;
  final answers = <BossFightAnswer>[
    ...rawAnswers.skip(shift),
    ...rawAnswers.take(shift),
  ];

  return List<BossFightAnswer>.unmodifiable(
    answers.map(
      (answer) => BossFightAnswer(
        pairId: answer.pairId,
        text: answer.text,
        isCorrect: answer.pairId == correct.id,
      ),
    ),
  );
}

@visibleForTesting
String buildBossFightGapPattern(String term) {
  final chars = term.trim().split('');
  if (chars.isEmpty) return '';
  final removable = <int>[];
  var firstLetterSeen = false;
  for (var i = 0; i < chars.length; i += 1) {
    if (RegExp(r'[\s\-]').hasMatch(chars[i])) continue;
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
String normalizeBossFightAnswer(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

enum BossFightQuestionType { choice, gap, input }

enum BossFightEndState { defeated, escaped, finished }

class BossFightPair {
  const BossFightPair({
    required this.id,
    required this.term,
    required this.translation,
  });

  final String id;
  final String term;
  final String translation;
}

class BossFightQuestion {
  const BossFightQuestion({
    required this.type,
    required this.pair,
    required this.answers,
    required this.gapPattern,
  });

  final BossFightQuestionType type;
  final BossFightPair pair;
  final List<BossFightAnswer> answers;
  final String gapPattern;
}

class BossFightAnswer {
  const BossFightAnswer({
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
      padding: const EdgeInsets.fromLTRB(20, 34, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: _bossCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFFF5F7A),
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Boss-Fight',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Stelle dich einer kurzen Runde mit besonders wichtigen Wörtern.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dein Lernfortschritt bleibt unverändert.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7DFFE3),
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              GameWordSourcePicker(
                keyPrefix: 'boss-fight',
                selectedSource: selectedSource,
                categories: categories,
                availableIds: availableIds,
                wordsPerRound: wordsPerRound,
                minWordsPerRound: 4,
                accentColor: const Color(0xFFFF5F7A),
                secondaryAccentColor: const Color(0xFF7DFFE3),
                onSourceSelected: onSourceSelected,
                onWordsPerRoundChanged: onWordsPerRoundChanged,
              ),
              const SizedBox(height: 22),
              FilledButton(
                key: const ValueKey('boss-fight-start-button'),
                onPressed: onStart,
                style: _primaryButtonStyle(),
                child: const Text('Kampf starten'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FightView extends StatelessWidget {
  const _FightView({
    required this.question,
    required this.questionIndex,
    required this.bossHp,
    required this.energy,
    required this.feedback,
    required this.resolved,
    required this.selectedAnswerId,
    required this.answerController,
    required this.answerFocusNode,
    required this.onChoice,
    required this.onCheckInput,
    required this.onReveal,
    required this.onNext,
  });

  final BossFightQuestion question;
  final int questionIndex;
  final int bossHp;
  final int energy;
  final String? feedback;
  final bool resolved;
  final String? selectedAnswerId;
  final TextEditingController answerController;
  final FocusNode answerFocusNode;
  final ValueChanged<BossFightAnswer> onChoice;
  final VoidCallback onCheckInput;
  final VoidCallback onReveal;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: ValueKey('boss-fight-question-list-$questionIndex'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _BossHeader(
          questionIndex: questionIndex,
          bossHp: bossHp,
          energy: energy,
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _bossCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _QuestionTitle(type: question.type),
              const SizedBox(height: 8),
              _QuestionHint(question: question),
              const SizedBox(height: 18),
              if (question.type == BossFightQuestionType.choice)
                _ChoiceQuestion(
                  question: question,
                  resolved: resolved,
                  selectedAnswerId: selectedAnswerId,
                  onChoice: onChoice,
                )
              else
                _InputQuestion(
                  question: question,
                  controller: answerController,
                  focusNode: answerFocusNode,
                  resolved: resolved,
                ),
              if (feedback != null) ...[
                const SizedBox(height: 14),
                _FeedbackBanner(
                  text: feedback!,
                  isPositive: feedback == 'Treffer!',
                ),
              ],
              if (resolved) ...[
                const SizedBox(height: 14),
                _SolutionBox(question: question),
                const SizedBox(height: 18),
                FilledButton(
                  key: const ValueKey('boss-fight-next-button'),
                  onPressed: onNext,
                  style: _primaryButtonStyle(),
                  child: const Text('Weiter'),
                ),
              ] else if (question.type != BossFightQuestionType.choice) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        key: const ValueKey('boss-fight-check-button'),
                        onPressed: onCheckInput,
                        style: _primaryButtonStyle(),
                        child: const Text('Prüfen'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        key: const ValueKey('boss-fight-reveal-button'),
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

class _ChoiceQuestion extends StatelessWidget {
  const _ChoiceQuestion({
    required this.question,
    required this.resolved,
    required this.selectedAnswerId,
    required this.onChoice,
  });

  final BossFightQuestion question;
  final bool resolved;
  final String? selectedAnswerId;
  final ValueChanged<BossFightAnswer> onChoice;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PromptCard(text: question.pair.term),
        const SizedBox(height: 16),
        for (final answer in question.answers) ...[
          _AnswerButton(
            key: ValueKey('boss-fight-answer-${answer.pairId}'),
            answer: answer,
            resolved: resolved,
            selected: selectedAnswerId == answer.pairId,
            onTap: () => onChoice(answer),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _InputQuestion extends StatelessWidget {
  const _InputQuestion({
    required this.question,
    required this.controller,
    required this.focusNode,
    required this.resolved,
  });

  final BossFightQuestion question;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool resolved;

  @override
  Widget build(BuildContext context) {
    final prompt = question.type == BossFightQuestionType.gap
        ? question.gapPattern
        : question.pair.translation;
    return Column(
      children: [
        _PromptCard(
          text: prompt,
          keyValue: question.type == BossFightQuestionType.gap
              ? 'boss-fight-gap-pattern'
              : 'boss-fight-translation-prompt',
        ),
        const SizedBox(height: 16),
        TextField(
          key: const ValueKey('boss-fight-input-field'),
          controller: controller,
          focusNode: focusNode,
          enabled: !resolved,
          style: const TextStyle(
            color: Color(0xFFF4F8FF),
            fontWeight: FontWeight.w800,
          ),
          decoration: InputDecoration(
            hintText: question.type == BossFightQuestionType.gap
                ? 'Vollständiges Wort eingeben'
                : 'Passendes Wort eingeben',
            hintStyle: const TextStyle(color: Color(0xFF6F7F94)),
            filled: true,
            fillColor: const Color(0xFF050912),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFF26354B)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFFF5F7A)),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionTitle extends StatelessWidget {
  const _QuestionTitle({required this.type});

  final BossFightQuestionType type;

  @override
  Widget build(BuildContext context) {
    final text = switch (type) {
      BossFightQuestionType.choice => 'Bedeutung treffen',
      BossFightQuestionType.gap => 'Lücke schließen',
      BossFightQuestionType.input => 'Wort kontern',
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

class _QuestionHint extends StatelessWidget {
  const _QuestionHint({required this.question});

  final BossFightQuestion question;

  @override
  Widget build(BuildContext context) {
    final text = switch (question.type) {
      BossFightQuestionType.choice => 'Wähle die richtige Übersetzung.',
      BossFightQuestionType.gap => 'Ergänze das Boss-Wort.',
      BossFightQuestionType.input =>
        'Tippe das Wort zur angezeigten Übersetzung.',
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

class _BossHeader extends StatelessWidget {
  const _BossHeader({
    required this.questionIndex,
    required this.bossHp,
    required this.energy,
  });

  final int questionIndex;
  final int bossHp;
  final int energy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF26354B)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        children: [
          _HeaderPill(label: 'Boss-HP', value: '$bossHp'),
          _HeaderPill(label: 'Energie', value: '$energy'),
          _HeaderPill(
            label: 'Runde',
            value: '${questionIndex + 1} / $bossFightQuestionCount',
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF050912),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFF5F7A)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Color(0xFFF4F8FF),
          fontWeight: FontWeight.w900,
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
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    super.key,
    required this.answer,
    required this.resolved,
    required this.selected,
    required this.onTap,
  });

  final BossFightAnswer answer;
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

class _SolutionBox extends StatelessWidget {
  const _SolutionBox({required this.question});

  final BossFightQuestion question;

  @override
  Widget build(BuildContext context) {
    final label = question.type == BossFightQuestionType.choice
        ? 'Richtige Bedeutung'
        : 'Lösung';
    final value = question.type == BossFightQuestionType.choice
        ? question.pair.translation
        : question.pair.term;
    return Container(
      key: const ValueKey('boss-fight-solution'),
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

class _FinishedView extends StatelessWidget {
  const _FinishedView({
    required this.endState,
    required this.hits,
    required this.onRestart,
    required this.onBack,
  });

  final BossFightEndState endState;
  final int hits;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final title = switch (endState) {
      BossFightEndState.defeated => 'Boss besiegt',
      BossFightEndState.escaped => 'Boss entkommen',
      BossFightEndState.finished => 'Kampf beendet',
    };
    final text = switch (endState) {
      BossFightEndState.defeated => 'Du hast den Boss-Fight geschafft.',
      BossFightEndState.escaped => 'Du kannst es direkt noch einmal versuchen.',
      BossFightEndState.finished => 'Du hast dem Boss $hits Treffer gegeben.',
    };
    final extra = endState == BossFightEndState.escaped
        ? 'Keine Sorge: Dein Lernfortschritt wurde nicht verändert.'
        : 'Dein SRS-Fortschritt wurde nicht verändert.';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: _bossCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFFFD166),
                size: 46,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 25,
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
              const SizedBox(height: 8),
              Text(
                extra,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF7DFFE3),
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: onRestart,
                style: _primaryButtonStyle(),
                child: const Text('Nochmal kämpfen'),
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

class _BossMessageState extends StatelessWidget {
  const _BossMessageState({
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
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: _bossCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.local_fire_department_outlined,
                color: Color(0xFFFF5F7A),
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

BoxDecoration _bossCardDecoration() {
  return BoxDecoration(
    color: const Color(0xFF0B1220),
    borderRadius: BorderRadius.circular(26),
    border: Border.all(color: const Color(0xFFFF5F7A).withValues(alpha: 0.56)),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFFFF5F7A).withValues(alpha: 0.12),
        blurRadius: 28,
        spreadRadius: -4,
      ),
    ],
  );
}

ButtonStyle _primaryButtonStyle() {
  return FilledButton.styleFrom(
    backgroundColor: const Color(0xFFFF5F7A),
    foregroundColor: const Color(0xFF041018),
    padding: const EdgeInsets.symmetric(vertical: 15),
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}

ButtonStyle _secondaryButtonStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFFF4F8FF),
    side: const BorderSide(color: Color(0xFFFF5F7A)),
    padding: const EdgeInsets.symmetric(vertical: 15),
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}
