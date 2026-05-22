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
  SpeedRoundWordSource _selectedSource = SpeedRoundWordSource.standard(
    LocalLearningSource.allWords,
  );
  List<SpeedRoundPair> _roundPairs = const <SpeedRoundPair>[];
  List<int> _answerShifts = const <int>[];
  String _roundKey = '';
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _secondsLeft = 60;
  bool _started = false;
  bool _finished = false;
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
                onSourceSelected: _selectSource,
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

  void _selectSource(SpeedRoundWordSource source) {
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
      _feedback = null;
    });
  }

  void _restartRound(List<SpeedRoundPair> pairs) {
    _timer?.cancel();
    final random = widget.random ?? Random();
    _roundPairs = selectSpeedRoundRoundPairs(pairs, random: random);
    _answerShifts = List<int>.unmodifiable(
      List<int>.generate(_roundPairs.length, (_) => random.nextInt(4)),
    );
    _currentQuestionIndex = 0;
    _score = 0;
    _secondsLeft = widget.roundDuration.inSeconds.clamp(1, 60);
    _started = false;
    _finished = false;
    _feedback = null;
  }

  void _startRound() {
    setState(() {
      _started = true;
      _finished = false;
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

class SpeedRoundWordSource {
  const SpeedRoundWordSource._({
    required this.label,
    required this.shortLabel,
    required this.source,
    required this.categoryId,
    required this.worldKey,
  });

  factory SpeedRoundWordSource.standard(LocalLearningSource source) {
    return SpeedRoundWordSource._(
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

  factory SpeedRoundWordSource._wordWorld(
    _SpeedRoundWordWorld world,
    List<LocalCategory> categories,
  ) {
    return SpeedRoundWordSource._(
      label: 'Wortwelt: ${world.name}',
      shortLabel: world.name,
      source: LocalLearningSource.allWords,
      categoryId: world.resolveCategoryId(categories),
      worldKey: world.key,
    );
  }

  factory SpeedRoundWordSource.category(LocalCategory category) {
    return SpeedRoundWordSource._(
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
    return other is SpeedRoundWordSource && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}

const _standardSpeedRoundSources = <LocalLearningSource>[
  LocalLearningSource.allWords,
  LocalLearningSource.myWords,
  LocalLearningSource.favorites,
  LocalLearningSource.myMix,
];

const _speedRoundWordWorldGroups = <_SpeedRoundWordWorldGroup>[
  _SpeedRoundWordWorldGroup('Alltag & Leben', [
    _SpeedRoundWordWorld(
      key: 'health_fitness',
      name: 'Health & Fitness',
      localCategoryId: 'seed-category-basics',
    ),
    _SpeedRoundWordWorld(key: 'home_living', name: 'Home & Living'),
    _SpeedRoundWordWorld(key: 'food_cooking', name: 'Food & Cooking'),
    _SpeedRoundWordWorld(key: 'style_fashion', name: 'Style & Fashion'),
    _SpeedRoundWordWorld(key: 'money_shopping', name: 'Money & Shopping'),
    _SpeedRoundWordWorld(key: 'productivity', name: 'Productivity'),
  ]),
  _SpeedRoundWordWorldGroup('Mensch & Gesellschaft', [
    _SpeedRoundWordWorld(key: 'personality', name: 'Personality'),
    _SpeedRoundWordWorld(key: 'feelings', name: 'Feelings'),
    _SpeedRoundWordWorld(key: 'relationships', name: 'Relationships'),
    _SpeedRoundWordWorld(key: 'thoughts', name: 'Thoughts'),
    _SpeedRoundWordWorld(key: 'law_politics', name: 'Law & Politics'),
    _SpeedRoundWordWorld(key: 'environment', name: 'Environment'),
  ]),
  _SpeedRoundWordWorldGroup('Wissen & Bildung', [
    _SpeedRoundWordWorld(key: 'school_studies', name: 'School & Studies'),
    _SpeedRoundWordWorld(key: 'science', name: 'Science'),
    _SpeedRoundWordWorld(key: 'space', name: 'Space'),
    _SpeedRoundWordWorld(key: 'nature', name: 'Nature'),
    _SpeedRoundWordWorld(key: 'animals', name: 'Animals'),
    _SpeedRoundWordWorld(key: 'tech_innovation', name: 'Tech & Innovation'),
  ]),
  _SpeedRoundWordWorldGroup('Medien & Freizeit', [
    _SpeedRoundWordWorld(key: 'media_news', name: 'Media & News'),
    _SpeedRoundWordWorld(key: 'sports', name: 'Sports'),
    _SpeedRoundWordWorld(
      key: 'travel',
      name: 'Travel',
      localCategoryId: 'seed-category-travel',
    ),
    _SpeedRoundWordWorld(key: 'gaming', name: 'Gaming'),
    _SpeedRoundWordWorld(key: 'transport', name: 'Transport'),
    _SpeedRoundWordWorld(
      key: 'music_entertainment',
      name: 'Music & Entertainment',
    ),
    _SpeedRoundWordWorld(key: 'art_literature', name: 'Art & Literature'),
  ]),
  _SpeedRoundWordWorldGroup('Beruf & Sprache', [
    _SpeedRoundWordWorld(key: 'work_careers', name: 'Work & Careers'),
    _SpeedRoundWordWorld(key: 'top_500', name: 'Top 500 Words'),
    _SpeedRoundWordWorld(key: 'a1', name: 'A1'),
    _SpeedRoundWordWorld(key: 'a2', name: 'A2'),
    _SpeedRoundWordWorld(key: 'b1', name: 'B1'),
    _SpeedRoundWordWorld(key: 'b2', name: 'B2'),
    _SpeedRoundWordWorld(key: 'c1', name: 'C1'),
    _SpeedRoundWordWorld(key: 'c2', name: 'C2'),
  ]),
];

class _SpeedRoundWordWorldGroup {
  const _SpeedRoundWordWorldGroup(this.title, this.worlds);

  final String title;
  final List<_SpeedRoundWordWorld> worlds;
}

class _SpeedRoundWordWorld {
  const _SpeedRoundWordWorld({
    required this.key,
    required this.name,
    this.localCategoryId,
  });

  final String key;
  final String name;
  final String? localCategoryId;

  String resolveCategoryId(List<LocalCategory> categories) {
    if (localCategoryId != null) return localCategoryId!;

    final normalizedName = _normalizeSpeedRoundText(name);
    for (final category in categories) {
      if (_normalizeSpeedRoundText(category.name) == normalizedName) {
        return category.id;
      }
    }

    return key;
  }
}

class _StartView extends StatelessWidget {
  const _StartView({
    required this.selectedSource,
    required this.categories,
    required this.onSourceSelected,
    required this.onStart,
  });

  final SpeedRoundWordSource selectedSource;
  final List<LocalCategory> categories;
  final ValueChanged<SpeedRoundWordSource> onSourceSelected;
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
                onSourceSelected: onSourceSelected,
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
    required this.onSourceSelected,
  });

  final SpeedRoundWordSource selectedSource;
  final List<LocalCategory> categories;
  final ValueChanged<SpeedRoundWordSource> onSourceSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('speed-round-source-picker'),
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
            key: const ValueKey('speed-round-selected-source-label'),
            style: const TextStyle(
              color: Color(0xFFF4F8FF),
              fontSize: 18,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _PickerActionButton(
            key: const ValueKey('speed-round-change-source-button'),
            icon: Icons.folder_copy_rounded,
            title: 'Wortquelle ändern',
            subtitle: 'Alle Wörter, Meine Wörter, Favoriten oder Mein Mix',
            onTap: () => _showSourceSheet(context),
          ),
          const SizedBox(height: 10),
          _PickerActionButton(
            key: const ValueKey('speed-round-select-world-button'),
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
        return _SpeedRoundSheetFrame(
          title: 'Wortquelle ändern',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final source in _standardSpeedRoundSources)
                _SheetOption(
                  key: ValueKey('speed-round-source-${source.id}'),
                  title: source.label,
                  selected:
                      selectedSource == SpeedRoundWordSource.standard(source),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSourceSelected(SpeedRoundWordSource.standard(source));
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
        return _SpeedRoundSheetFrame(
          title: 'Wortwelt auswählen',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final group in _speedRoundWordWorldGroups) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
                  child: Text(
                    group.title,
                    style: const TextStyle(
                      color: Color(0xFFFFD166),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                for (final world in group.worlds)
                  Builder(
                    builder: (context) {
                      final source = SpeedRoundWordSource._wordWorld(
                        world,
                        categories,
                      );
                      return _SheetOption(
                        key: ValueKey('speed-round-word-world-${world.key}'),
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
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFFFD166)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeedRoundSheetFrame extends StatelessWidget {
  const _SpeedRoundSheetFrame({required this.title, required this.child});

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
              border: Border.all(color: const Color(0xFFFFD166)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD166).withValues(alpha: 0.14),
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
        ? const Color(0xFFFFD166)
        : const Color(0xFF26354B);
    final fillColor = selected
        ? const Color(0xFFFFD166).withValues(alpha: 0.16)
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
                          ? const Color(0xFFFFD166)
                          : const Color(0xFFF4F8FF),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFFFFD166),
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
  final SpeedRoundWordSource? selectedSource;
  final List<LocalCategory> categories;
  final ValueChanged<SpeedRoundWordSource>? onSourceSelected;
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
