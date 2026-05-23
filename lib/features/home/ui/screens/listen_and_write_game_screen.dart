import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/core/pronunciation/word_pronunciation_provider.dart';
import 'package:talvori/features/home/application/word_game_progress_controller.dart';
import 'package:talvori/features/home/ui/widgets/game_word_source_picker.dart';

class ListenAndWriteGameScreen extends ConsumerStatefulWidget {
  const ListenAndWriteGameScreen({super.key});

  static const routeName = 'listen-and-write-game';

  @override
  ConsumerState<ListenAndWriteGameScreen> createState() =>
      _ListenAndWriteGameScreenState();
}

class _ListenAndWriteGameScreenState
    extends ConsumerState<ListenAndWriteGameScreen> {
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();
  final SharedPreferencesWordGameProgressRepository _progressRepository =
      const SharedPreferencesWordGameProgressRepository();
  GameWordSource _selectedSource = GameWordSource.standard(
    LocalLearningSource.allWords,
  );
  int _wordsPerRound = 10;
  List<LocalWord> _roundWords = const <LocalWord>[];
  String _roundKey = '';
  int _currentIndex = 0;
  int _correctCount = 0;
  bool _hasStarted = false;
  bool _answeredCorrectly = false;
  bool _revealed = false;
  bool _isFinished = false;
  String? _feedback;

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
        title: const Text('Hör & Schreib'),
      ),
      body: SafeArea(
        child: wordsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF7DFFE3)),
          ),
          error: (_, __) => _GameMessageState(
            title: 'Wörter konnten nicht geladen werden',
            text: 'Versuche es gleich noch einmal.',
            buttonLabel: 'Zurück',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          data: (words) {
            const categories = <LocalCategory>[];
            final playableWords = _playableWords(words);
            if (playableWords.isEmpty) {
              return _GameMessageState(
                title: 'Noch keine Wörter verfügbar',
                text: _selectedSource.categoryId == null
                    ? 'Diese Wortquelle braucht Wörter mit einem abfragbaren Begriff, um Hör & Schreib zu spielen.'
                    : 'Diese Wortwelt braucht Wörter mit einem abfragbaren Begriff, um Hör & Schreib zu spielen.',
                buttonLabel: 'Zurück',
                selectedSource: _selectedSource,
                categories: categories,
                onSourceSelected: _selectSource,
                onPressed: () => Navigator.of(context).maybePop(),
              );
            }

            final sourceKey =
                '${_selectedSource.key}:${playableWords.map((word) => word.id).join('|')}';
            if (_roundKey != sourceKey) _resetForSelection(sourceKey);

            if (!_hasStarted) {
              return _ListenAndWriteStartView(
                selectedSource: _selectedSource,
                categories: categories,
                availableIds: playableWords
                    .map((word) => word.id)
                    .toList(growable: false),
                wordsPerRound: _effectiveWordsPerRound(playableWords.length),
                onSourceSelected: _selectSource,
                onWordsPerRoundChanged: _selectWordsPerRound,
                onStart: () => setState(() => _restartRound(playableWords)),
              );
            }

            if (_isFinished) {
              return _FinishedView(
                correctCount: _correctCount,
                totalCount: _roundWords.length,
                onRestart: () => setState(() => _restartRound(playableWords)),
                onBack: () => Navigator.of(context).maybePop(),
              );
            }

            final word = _roundWords[_currentIndex];
            return _GamePlayView(
              word: word,
              answerController: _answerController,
              answerFocusNode: _answerFocusNode,
              currentIndex: _currentIndex,
              totalCount: _roundWords.length,
              feedback: _feedback,
              answeredCorrectly: _answeredCorrectly,
              revealed: _revealed,
              onListen: () => _speak(word),
              onCheck: () => _checkAnswer(word),
              onReveal: () => _reveal(word),
              onNext: _nextWord,
            );
          },
        ),
      ),
    );
  }

  List<LocalWord> _playableWords(List<LocalWord> words) {
    final seenTerms = <String>{};
    final playable = <LocalWord>[];
    for (final word in words) {
      final term = word.term.trim();
      if (term.isEmpty || word.isArchived) continue;
      final normalized = normalizeListenAndWriteAnswer(term);
      if (normalized.isEmpty || !seenTerms.add(normalized)) continue;
      playable.add(word);
    }
    return List<LocalWord>.unmodifiable(playable);
  }

  void _resetForSelection(String sourceKey) {
    _roundKey = sourceKey;
    _roundWords = const <LocalWord>[];
    _currentIndex = 0;
    _correctCount = 0;
    _hasStarted = false;
    _answeredCorrectly = false;
    _revealed = false;
    _isFinished = false;
    _feedback = null;
    _answerController.clear();
  }

  void _selectSource(GameWordSource source) {
    if (_selectedSource == source) return;
    setState(() {
      _selectedSource = source;
      _resetForSelection('');
    });
  }

  void _restartRound(List<LocalWord> playableWords) {
    _roundWords = selectWordGameRoundItemsByCount<LocalWord>(
      items: playableWords,
      idOf: (word) => word.id,
      playedIds: const <String>{},
      wordsPerRound: _effectiveWordsPerRound(playableWords.length),
    );
    _progressRepository.markPlayedIds(
      'listen-write',
      _selectedSource.key,
      _roundWords.map((word) => word.id),
    );
    _currentIndex = 0;
    _correctCount = 0;
    _hasStarted = true;
    _answeredCorrectly = false;
    _revealed = false;
    _isFinished = false;
    _feedback = null;
    _answerController.clear();
  }

  int _effectiveWordsPerRound(int available) {
    return clampWordsPerRound(
      requested: _wordsPerRound,
      minimum: 1,
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

  Future<void> _speak(LocalWord word) async {
    final result = await ref
        .read(wordPronunciationServiceProvider)
        .speakWord(word.term, languageCode: word.sourceLanguage);
    if (!mounted || result.isSuccess) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF061018),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFFF7AB6), width: 1.1),
          ),
          content: Text(
            result.message ?? 'Aussprache konnte nicht gestartet werden.',
            style: const TextStyle(
              color: Color(0xFFF4F8FF),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
  }

  void _checkAnswer(LocalWord word) {
    final isCorrect =
        normalizeListenAndWriteAnswer(_answerController.text) ==
        normalizeListenAndWriteAnswer(word.term);
    setState(() {
      if (isCorrect) {
        if (!_answeredCorrectly) _correctCount += 1;
        _answeredCorrectly = true;
        _revealed = true;
        _feedback = 'Richtig!';
        _answerFocusNode.unfocus();
      } else {
        _feedback = 'Fast. Versuch es noch einmal.';
      }
    });
  }

  void _reveal(LocalWord word) {
    setState(() {
      _revealed = true;
      _feedback = 'Aufgelöst: ${word.term.trim()}';
      _answerFocusNode.unfocus();
    });
  }

  void _nextWord() {
    setState(() {
      if (_currentIndex >= _roundWords.length - 1) {
        _isFinished = true;
        return;
      }
      _currentIndex += 1;
      _answeredCorrectly = false;
      _revealed = false;
      _feedback = null;
      _answerController.clear();
    });
  }
}

@visibleForTesting
String normalizeListenAndWriteAnswer(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

ButtonStyle _primaryListenButtonStyle() {
  return FilledButton.styleFrom(
    backgroundColor: const Color(0xFF7DFFE3),
    foregroundColor: const Color(0xFF041018),
    padding: const EdgeInsets.symmetric(vertical: 15),
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}

class _ListenAndWriteStartView extends StatelessWidget {
  const _ListenAndWriteStartView({
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
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
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
                blurRadius: 28,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.hearing_rounded,
                color: Color(0xFF5DDCFF),
                size: 44,
              ),
              const SizedBox(height: 16),
              const Text(
                'Bereit für Hör & Schreib?',
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Höre ein Wort und schreibe, was du verstanden hast.',
                style: TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              GameWordSourcePicker(
                keyPrefix: 'listen-write',
                selectedSource: selectedSource,
                categories: categories,
                availableIds: availableIds,
                wordsPerRound: wordsPerRound,
                minWordsPerRound: 1,
                accentColor: const Color(0xFF5DDCFF),
                secondaryAccentColor: const Color(0xFF7DFFE3),
                onSourceSelected: onSourceSelected,
                onWordsPerRoundChanged: onWordsPerRoundChanged,
              ),
              const SizedBox(height: 18),
              FilledButton(
                key: const ValueKey('listen-write-start-button'),
                onPressed: onStart,
                style: _primaryListenButtonStyle(),
                child: const Text('Starten'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GamePlayView extends StatelessWidget {
  const _GamePlayView({
    required this.word,
    required this.answerController,
    required this.answerFocusNode,
    required this.currentIndex,
    required this.totalCount,
    required this.feedback,
    required this.answeredCorrectly,
    required this.revealed,
    required this.onListen,
    required this.onCheck,
    required this.onReveal,
    required this.onNext,
  });

  final LocalWord word;
  final TextEditingController answerController;
  final FocusNode answerFocusNode;
  final int currentIndex;
  final int totalCount;
  final String? feedback;
  final bool answeredCorrectly;
  final bool revealed;
  final VoidCallback onListen;
  final VoidCallback onCheck;
  final VoidCallback onReveal;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final translation = word.translation.trim();
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _RoundHeader(currentIndex: currentIndex, totalCount: totalCount),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFF7DFFE3).withValues(alpha: 0.56),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7DFFE3).withValues(alpha: 0.12),
                blurRadius: 28,
                spreadRadius: -4,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Höre genau hin',
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                translation.isEmpty
                    ? 'Tippe das Wort ein, das du hörst.'
                    : 'Hinweis: $translation',
                style: const TextStyle(
                  color: Color(0xFFB8C7D9),
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                key: const ValueKey('listen-write-listen-button'),
                onPressed: onListen,
                icon: const Icon(Icons.volume_up_rounded),
                label: const Text('Anhören'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF7DFFE3),
                  foregroundColor: const Color(0xFF041018),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                key: const ValueKey('listen-write-answer-field'),
                controller: answerController,
                focusNode: answerFocusNode,
                enabled: !answeredCorrectly && !revealed,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!answeredCorrectly && !revealed) onCheck();
                },
                style: const TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
                decoration: InputDecoration(
                  hintText: 'Was hast du gehört?',
                  hintStyle: const TextStyle(color: Color(0xFF6F7F94)),
                  filled: true,
                  fillColor: const Color(0xFF050912),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFF26354B)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Color(0xFF7DFFE3),
                      width: 1.4,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFF26354B)),
                  ),
                ),
              ),
              if (feedback != null) ...[
                const SizedBox(height: 14),
                _FeedbackBanner(
                  text: feedback!,
                  isPositive: answeredCorrectly,
                  revealed: revealed,
                ),
              ],
              if (revealed) ...[
                const SizedBox(height: 14),
                _RevealedWord(word: word.term.trim()),
              ],
              const SizedBox(height: 18),
              if (answeredCorrectly || revealed)
                FilledButton(
                  key: const ValueKey('listen-write-next-button'),
                  onPressed: onNext,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5DDCFF),
                    foregroundColor: const Color(0xFF041018),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  child: const Text('Nächstes Wort'),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        key: const ValueKey('listen-write-check-button'),
                        onPressed: onCheck,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF5DDCFF),
                          foregroundColor: const Color(0xFF041018),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        child: const Text('Prüfen'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        key: const ValueKey('listen-write-reveal-button'),
                        onPressed: onReveal,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFF4F8FF),
                          side: const BorderSide(color: Color(0xFF7DFFE3)),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        child: const Text('Auflösen'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
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
          const Icon(Icons.hearing_rounded, color: Color(0xFFB36BFF)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Lokale Runde',
              style: TextStyle(
                color: Color(0xFFF4F8FF),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            '${currentIndex + 1} / $totalCount',
            style: const TextStyle(
              color: Color(0xFF7DFFE3),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({
    required this.text,
    required this.isPositive,
    required this.revealed,
  });

  final String text;
  final bool isPositive;
  final bool revealed;

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

class _RevealedWord extends StatelessWidget {
  const _RevealedWord({required this.word});

  final String word;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF050912),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF5DDCFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gesuchtes Wort',
            style: TextStyle(
              color: Color(0xFFB8C7D9),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            word,
            style: const TextStyle(
              color: Color(0xFFF4F8FF),
              fontSize: 24,
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
            border: Border.all(color: const Color(0xFF7DFFE3)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7DFFE3).withValues(alpha: 0.14),
                blurRadius: 30,
                spreadRadius: -4,
              ),
            ],
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
                key: const ValueKey('listen-write-restart-button'),
                onPressed: onRestart,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF7DFFE3),
                  foregroundColor: const Color(0xFF041018),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
                child: const Text('Nochmal spielen'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const ValueKey('listen-write-back-button'),
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF4F8FF),
                  side: const BorderSide(color: Color(0xFF5DDCFF)),
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

class _GameMessageState extends StatelessWidget {
  const _GameMessageState({
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
            border: Border.all(color: const Color(0xFF5DDCFF)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.library_books_rounded,
                color: Color(0xFF5DDCFF),
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
                GameWordSourcePicker(
                  keyPrefix: 'listen-write',
                  selectedSource: selectedSource!,
                  categories: categories,
                  accentColor: const Color(0xFF5DDCFF),
                  secondaryAccentColor: const Color(0xFF7DFFE3),
                  onSourceSelected: onSourceSelected!,
                ),
              ],
              const SizedBox(height: 22),
              FilledButton(
                onPressed: onPressed,
                style: _primaryListenButtonStyle(),
                child: Text(buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
