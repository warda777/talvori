import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';

class MeaningFinderGameScreen extends ConsumerStatefulWidget {
  const MeaningFinderGameScreen({super.key});

  static const routeName = 'meaning-finder-game';

  @override
  ConsumerState<MeaningFinderGameScreen> createState() =>
      _MeaningFinderGameScreenState();
}

class _MeaningFinderGameScreenState
    extends ConsumerState<MeaningFinderGameScreen> {
  MeaningFinderWordSource _selectedSource = MeaningFinderWordSource.standard(
    LocalLearningSource.allWords,
  );
  List<MeaningFinderPair> _roundPairs = const <MeaningFinderPair>[];
  String _roundKey = '';
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
        title: const Text('Bedeutung finden'),
      ),
      body: SafeArea(
        child: wordsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF8A5B)),
          ),
          error: (_, __) => _MeaningFinderMessageState(
            title: 'Wörter konnten nicht geladen werden',
            text: 'Versuche es gleich noch einmal.',
            buttonLabel: 'Zurück',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          data: (words) {
            final categories = categoriesAsync.value ?? const <LocalCategory>[];
            final pairs = buildMeaningFinderPairs(words);
            if (pairs.length < 4) {
              return _MeaningFinderMessageState(
                title: 'Noch nicht genug Wörter',
                text: _selectedSource.categoryId == null
                    ? 'Diese Wortquelle braucht mindestens vier Wörter mit Übersetzung, um Bedeutung finden zu spielen.'
                    : 'Diese Wortwelt braucht mindestens vier Wörter mit Übersetzung, um Bedeutung finden zu spielen.',
                buttonLabel: 'Zurück',
                selectedSource: _selectedSource,
                categories: categories,
                onSourceSelected: _selectSource,
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

            final question = buildMeaningFinderQuestion(
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
              selectedSource: _selectedSource,
              categories: categories,
              onSourceSelected: _selectSource,
            );
          },
        ),
      ),
    );
  }

  void _ensureRound(List<MeaningFinderPair> pairs) {
    final nextKey =
        '${_selectedSource.key}:${pairs.map((pair) => pair.id).join('|')}';
    if (_roundKey == nextKey && _roundPairs.isNotEmpty) return;
    _roundKey = nextKey;
    _restartRound(pairs);
  }

  void _selectSource(MeaningFinderWordSource source) {
    if (_selectedSource == source) return;
    setState(() {
      _selectedSource = source;
      _roundPairs = const <MeaningFinderPair>[];
      _roundKey = '';
      _currentQuestionIndex = 0;
      _correctCount = 0;
      _isFinished = false;
      _resolved = false;
      _selectedPairId = null;
      _feedback = null;
    });
  }

  void _restartRound(List<MeaningFinderPair> pairs) {
    _roundPairs = List<MeaningFinderPair>.unmodifiable(pairs.take(10));
    _currentQuestionIndex = 0;
    _correctCount = 0;
    _isFinished = false;
    _resolved = false;
    _selectedPairId = null;
    _feedback = null;
  }

  void _answer(MeaningFinderAnswer answer) {
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
List<MeaningFinderPair> buildMeaningFinderPairs(List<LocalWord> words) {
  final pairs = <MeaningFinderPair>[];
  final seenTerms = <String>{};
  final seenTranslations = <String>{};

  for (final word in words) {
    final term = word.term.trim();
    final translation = word.translation.trim();
    if (term.isEmpty || translation.isEmpty || word.isArchived) continue;

    final normalizedTerm = normalizeMeaningFinderText(term);
    final normalizedTranslation = normalizeMeaningFinderText(translation);
    if (!seenTerms.add(normalizedTerm)) continue;
    if (!seenTranslations.add(normalizedTranslation)) continue;

    pairs.add(
      MeaningFinderPair(id: word.id, term: term, translation: translation),
    );
  }

  return List<MeaningFinderPair>.unmodifiable(pairs);
}

@visibleForTesting
MeaningFinderQuestion buildMeaningFinderQuestion({
  required List<MeaningFinderPair> pairs,
  required int questionIndex,
}) {
  final correct = pairs[questionIndex % pairs.length];
  final distractors = <MeaningFinderPair>[];
  for (var offset = 1; distractors.length < 3; offset += 1) {
    final candidate = pairs[(questionIndex + offset) % pairs.length];
    if (candidate.id == correct.id) continue;
    if (distractors.any((pair) => pair.id == candidate.id)) continue;
    distractors.add(candidate);
  }

  final rawAnswers = <MeaningFinderAnswer>[
    MeaningFinderAnswer(pairId: correct.id, text: correct.translation),
    for (final pair in distractors)
      MeaningFinderAnswer(pairId: pair.id, text: pair.translation),
  ];
  final shift = (questionIndex + 1) % rawAnswers.length;
  final answers = <MeaningFinderAnswer>[
    ...rawAnswers.skip(shift),
    ...rawAnswers.take(shift),
  ];

  return MeaningFinderQuestion(
    correctPairId: correct.id,
    prompt: correct.term,
    hint: buildMeaningFinderHint(correct.term, questionIndex),
    correctAnswerText: correct.translation,
    answers: List<MeaningFinderAnswer>.unmodifiable(
      answers.map(
        (answer) => MeaningFinderAnswer(
          pairId: answer.pairId,
          text: answer.text,
          isCorrect: answer.pairId == correct.id,
        ),
      ),
    ),
  );
}

@visibleForTesting
String buildMeaningFinderHint(String term, int questionIndex) {
  final templates = <String>[
    'Gesucht ist die Bedeutung, die im Deutschen am besten zu "$term" passt.',
    'Wähle die Bedeutung, die zu diesem Wort gehört.',
    'Achte auf die Grundbedeutung dieses Wortes.',
    'Welche Antwort beschreibt dieses Wort am besten?',
  ];
  return templates[questionIndex % templates.length];
}

@visibleForTesting
String normalizeMeaningFinderText(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

class MeaningFinderPair {
  const MeaningFinderPair({
    required this.id,
    required this.term,
    required this.translation,
  });

  final String id;
  final String term;
  final String translation;
}

class MeaningFinderQuestion {
  const MeaningFinderQuestion({
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
  final List<MeaningFinderAnswer> answers;
}

class MeaningFinderAnswer {
  const MeaningFinderAnswer({
    required this.pairId,
    required this.text,
    this.isCorrect = false,
  });

  final String pairId;
  final String text;
  final bool isCorrect;
}

class MeaningFinderWordSource {
  const MeaningFinderWordSource._({
    required this.label,
    required this.source,
    required this.categoryId,
    required this.worldKey,
  });

  factory MeaningFinderWordSource.standard(LocalLearningSource source) {
    return MeaningFinderWordSource._(
      label: source.label,
      source: source,
      categoryId: null,
      worldKey: null,
    );
  }

  factory MeaningFinderWordSource._wordWorld(
    _MeaningFinderWordWorld world,
    List<LocalCategory> categories,
  ) {
    return MeaningFinderWordSource._(
      label: 'Wortwelt: ${world.name}',
      source: LocalLearningSource.allWords,
      categoryId: world.resolveCategoryId(categories),
      worldKey: world.key,
    );
  }

  final String label;
  final LocalLearningSource source;
  final String? categoryId;
  final String? worldKey;

  String get key => worldKey == null ? source.id : 'word-world:$worldKey';

  @override
  bool operator ==(Object other) {
    return other is MeaningFinderWordSource && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}

const _standardMeaningFinderSources = <LocalLearningSource>[
  LocalLearningSource.allWords,
  LocalLearningSource.myWords,
  LocalLearningSource.favorites,
  LocalLearningSource.myMix,
];

const _meaningFinderWordWorldGroups = <_MeaningFinderWordWorldGroup>[
  _MeaningFinderWordWorldGroup('Alltag & Leben', [
    _MeaningFinderWordWorld(
      key: 'health_fitness',
      name: 'Health & Fitness',
      localCategoryId: 'seed-category-basics',
    ),
    _MeaningFinderWordWorld(key: 'home_living', name: 'Home & Living'),
    _MeaningFinderWordWorld(key: 'food_cooking', name: 'Food & Cooking'),
    _MeaningFinderWordWorld(key: 'style_fashion', name: 'Style & Fashion'),
    _MeaningFinderWordWorld(key: 'money_shopping', name: 'Money & Shopping'),
    _MeaningFinderWordWorld(key: 'productivity', name: 'Productivity'),
  ]),
  _MeaningFinderWordWorldGroup('Mensch & Gesellschaft', [
    _MeaningFinderWordWorld(key: 'personality', name: 'Personality'),
    _MeaningFinderWordWorld(key: 'feelings', name: 'Feelings'),
    _MeaningFinderWordWorld(key: 'relationships', name: 'Relationships'),
    _MeaningFinderWordWorld(key: 'thoughts', name: 'Thoughts'),
    _MeaningFinderWordWorld(key: 'law_politics', name: 'Law & Politics'),
    _MeaningFinderWordWorld(key: 'environment', name: 'Environment'),
  ]),
  _MeaningFinderWordWorldGroup('Wissen & Bildung', [
    _MeaningFinderWordWorld(key: 'school_studies', name: 'School & Studies'),
    _MeaningFinderWordWorld(key: 'science', name: 'Science'),
    _MeaningFinderWordWorld(key: 'space', name: 'Space'),
    _MeaningFinderWordWorld(key: 'nature', name: 'Nature'),
    _MeaningFinderWordWorld(key: 'animals', name: 'Animals'),
    _MeaningFinderWordWorld(key: 'tech_innovation', name: 'Tech & Innovation'),
  ]),
  _MeaningFinderWordWorldGroup('Medien & Freizeit', [
    _MeaningFinderWordWorld(key: 'media_news', name: 'Media & News'),
    _MeaningFinderWordWorld(key: 'sports', name: 'Sports'),
    _MeaningFinderWordWorld(
      key: 'travel',
      name: 'Travel',
      localCategoryId: 'seed-category-travel',
    ),
    _MeaningFinderWordWorld(key: 'gaming', name: 'Gaming'),
    _MeaningFinderWordWorld(key: 'transport', name: 'Transport'),
    _MeaningFinderWordWorld(
      key: 'music_entertainment',
      name: 'Music & Entertainment',
    ),
    _MeaningFinderWordWorld(key: 'art_literature', name: 'Art & Literature'),
  ]),
  _MeaningFinderWordWorldGroup('Beruf & Sprache', [
    _MeaningFinderWordWorld(key: 'work_careers', name: 'Work & Careers'),
    _MeaningFinderWordWorld(key: 'top_500', name: 'Top 500 Words'),
    _MeaningFinderWordWorld(key: 'a1', name: 'A1'),
    _MeaningFinderWordWorld(key: 'a2', name: 'A2'),
    _MeaningFinderWordWorld(key: 'b1', name: 'B1'),
    _MeaningFinderWordWorld(key: 'b2', name: 'B2'),
    _MeaningFinderWordWorld(key: 'c1', name: 'C1'),
    _MeaningFinderWordWorld(key: 'c2', name: 'C2'),
  ]),
];

class _MeaningFinderWordWorldGroup {
  const _MeaningFinderWordWorldGroup(this.title, this.worlds);

  final String title;
  final List<_MeaningFinderWordWorld> worlds;
}

class _MeaningFinderWordWorld {
  const _MeaningFinderWordWorld({
    required this.key,
    required this.name,
    this.localCategoryId,
  });

  final String key;
  final String name;
  final String? localCategoryId;

  String resolveCategoryId(List<LocalCategory> categories) {
    if (localCategoryId != null) return localCategoryId!;

    final normalizedName = normalizeMeaningFinderText(name);
    for (final category in categories) {
      if (normalizeMeaningFinderText(category.name) == normalizedName) {
        return category.id;
      }
    }

    return key;
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
    required this.selectedSource,
    required this.categories,
    required this.onSourceSelected,
  });

  final MeaningFinderQuestion question;
  final int currentIndex;
  final int totalCount;
  final String? feedback;
  final bool resolved;
  final String? selectedPairId;
  final ValueChanged<MeaningFinderAnswer> onAnswer;
  final VoidCallback onReveal;
  final VoidCallback onNext;
  final MeaningFinderWordSource selectedSource;
  final List<LocalCategory> categories;
  final ValueChanged<MeaningFinderWordSource> onSourceSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _RoundHeader(currentIndex: currentIndex, totalCount: totalCount),
        const SizedBox(height: 12),
        _WordSourcePicker(
          selectedSource: selectedSource,
          categories: categories,
          onSourceSelected: onSourceSelected,
        ),
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
              _MeaningHint(text: question.hint),
              const SizedBox(height: 14),
              Container(
                key: const ValueKey('meaning-finder-prompt-card'),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF050912),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF26354B)),
                ),
                child: Text(
                  question.prompt,
                  key: const ValueKey('meaning-finder-prompt'),
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
                  key: ValueKey('meaning-finder-answer-${answer.pairId}'),
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
                  key: const ValueKey('meaning-finder-next-button'),
                  onPressed: onNext,
                  style: _primaryButtonStyle(),
                  child: const Text('Nächste Frage'),
                ),
              ] else ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  key: const ValueKey('meaning-finder-reveal-button'),
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

class _MeaningHint extends StatelessWidget {
  const _MeaningHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('meaning-finder-hint'),
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
    required this.onSourceSelected,
  });

  final MeaningFinderWordSource selectedSource;
  final List<LocalCategory> categories;
  final ValueChanged<MeaningFinderWordSource> onSourceSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('meaning-finder-source-picker'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
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
            key: const ValueKey('meaning-finder-selected-source-label'),
            style: const TextStyle(
              color: Color(0xFFF4F8FF),
              fontSize: 18,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _PickerActionButton(
            key: const ValueKey('meaning-finder-change-source-button'),
            icon: Icons.folder_copy_rounded,
            title: 'Wortquelle ändern',
            subtitle: 'Alle Wörter, Meine Wörter, Favoriten oder Mein Mix',
            onTap: () => _showSourceSheet(context),
          ),
          const SizedBox(height: 10),
          _PickerActionButton(
            key: const ValueKey('meaning-finder-select-world-button'),
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
        return _MeaningFinderSheetFrame(
          title: 'Wortquelle ändern',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final source in _standardMeaningFinderSources)
                _SheetOption(
                  key: ValueKey('meaning-finder-source-${source.id}'),
                  title: source.label,
                  selected:
                      selectedSource ==
                      MeaningFinderWordSource.standard(source),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSourceSelected(MeaningFinderWordSource.standard(source));
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
        return _MeaningFinderSheetFrame(
          title: 'Wortwelt auswählen',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final group in _meaningFinderWordWorldGroups) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
                  child: Text(
                    group.title,
                    style: const TextStyle(
                      color: Color(0xFFFF8A5B),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                for (final world in group.worlds)
                  Builder(
                    builder: (context) {
                      final source = MeaningFinderWordSource._wordWorld(
                        world,
                        categories,
                      );
                      return _SheetOption(
                        key: ValueKey('meaning-finder-word-world-${world.key}'),
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
            color: const Color(0xFF050912),
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
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFFF8A5B)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeaningFinderSheetFrame extends StatelessWidget {
  const _MeaningFinderSheetFrame({required this.title, required this.child});

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
              border: Border.all(color: const Color(0xFFFF8A5B)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8A5B).withValues(alpha: 0.14),
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
        ? const Color(0xFFFF8A5B)
        : const Color(0xFF26354B);
    final fillColor = selected
        ? const Color(0xFFFF8A5B).withValues(alpha: 0.16)
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
                          ? const Color(0xFFFF8A5B)
                          : const Color(0xFFF4F8FF),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFFFF8A5B),
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
  const _AnswerButton({
    super.key,
    required this.answer,
    required this.isResolved,
    required this.isSelected,
    required this.onTap,
  });

  final MeaningFinderAnswer answer;
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
              'Bedeutung finden',
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
      key: const ValueKey('meaning-finder-correct-answer'),
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
                key: const ValueKey('meaning-finder-restart-button'),
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
                key: const ValueKey('meaning-finder-back-button'),
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

class _MeaningFinderMessageState extends StatelessWidget {
  const _MeaningFinderMessageState({
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
  final MeaningFinderWordSource? selectedSource;
  final List<LocalCategory> categories;
  final ValueChanged<MeaningFinderWordSource>? onSourceSelected;
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
