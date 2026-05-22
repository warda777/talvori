import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';

class WordPuzzleGameScreen extends ConsumerStatefulWidget {
  const WordPuzzleGameScreen({super.key});

  static const routeName = 'word-puzzle-game';

  @override
  ConsumerState<WordPuzzleGameScreen> createState() =>
      _WordPuzzleGameScreenState();
}

class _WordPuzzleGameScreenState extends ConsumerState<WordPuzzleGameScreen> {
  List<LocalWord> _roundWords = const <LocalWord>[];
  List<PuzzleLetter> _letters = const <PuzzleLetter>[];
  List<int> _selectedIndexes = const <int>[];
  String _roundKey = '';
  int _currentIndex = 0;
  int _correctCount = 0;
  bool _answeredCorrectly = false;
  bool _revealed = false;
  bool _isFinished = false;
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
        title: const Text('Wort-Puzzle'),
      ),
      body: SafeArea(
        child: wordsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF7DFFE3)),
          ),
          error: (_, __) => _WordPuzzleMessageState(
            title: 'Wörter konnten nicht geladen werden',
            text: 'Versuche es gleich noch einmal.',
            buttonLabel: 'Zurück',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          data: (words) {
            final playableWords = buildWordPuzzleRoundWords(words);
            if (playableWords.isEmpty) {
              return _WordPuzzleMessageState(
                title: 'Noch keine passenden Wörter',
                text:
                    'Füge Wörter mit mindestens drei Buchstaben hinzu, um Wort-Puzzle zu spielen.',
                buttonLabel: 'Zurück',
                onPressed: () => Navigator.of(context).maybePop(),
              );
            }

            _ensureRound(playableWords);
            if (_isFinished) {
              return _FinishedView(
                correctCount: _correctCount,
                totalCount: _roundWords.length,
                onRestart: () => setState(() => _restartRound(playableWords)),
                onBack: () => Navigator.of(context).maybePop(),
              );
            }

            final word = _roundWords[_currentIndex];
            return _WordPuzzlePlayView(
              word: word,
              letters: _letters,
              selectedIndexes: _selectedIndexes,
              currentIndex: _currentIndex,
              totalCount: _roundWords.length,
              feedback: _feedback,
              answeredCorrectly: _answeredCorrectly,
              revealed: _revealed,
              onLetterTap: _selectLetter,
              onUndo: _undoLetter,
              onReset: _resetAnswer,
              onCheck: () => _checkAnswer(word),
              onReveal: () => _reveal(word),
              onNext: _nextWord,
            );
          },
        ),
      ),
    );
  }

  void _ensureRound(List<LocalWord> playableWords) {
    final nextKey = playableWords.map((word) => word.id).join('|');
    if (_roundKey == nextKey && _roundWords.isNotEmpty) return;
    _roundKey = nextKey;
    _restartRound(playableWords);
  }

  void _restartRound(List<LocalWord> playableWords) {
    _roundWords = List<LocalWord>.unmodifiable(playableWords.take(10));
    _currentIndex = 0;
    _correctCount = 0;
    _answeredCorrectly = false;
    _revealed = false;
    _isFinished = false;
    _feedback = null;
    _selectedIndexes = const <int>[];
    _letters = buildWordPuzzleLetters(_roundWords.first.term);
  }

  void _selectLetter(int index) {
    if (_answeredCorrectly || _revealed || _selectedIndexes.contains(index)) {
      return;
    }
    setState(() {
      _selectedIndexes = [..._selectedIndexes, index];
      _feedback = null;
    });
  }

  void _undoLetter() {
    if (_answeredCorrectly || _revealed || _selectedIndexes.isEmpty) return;
    setState(() {
      _selectedIndexes = _selectedIndexes
          .take(_selectedIndexes.length - 1)
          .toList(growable: false);
      _feedback = null;
    });
  }

  void _resetAnswer() {
    if (_answeredCorrectly || _revealed || _selectedIndexes.isEmpty) return;
    setState(() {
      _selectedIndexes = const <int>[];
      _feedback = null;
    });
  }

  void _checkAnswer(LocalWord word) {
    final answer = _selectedIndexes.map((index) => _letters[index].char).join();
    final isCorrect =
        normalizeWordPuzzleAnswer(answer) ==
        normalizeWordPuzzleAnswer(word.term);
    setState(() {
      if (isCorrect) {
        if (!_answeredCorrectly) _correctCount += 1;
        _answeredCorrectly = true;
        _revealed = true;
        _feedback = 'Richtig!';
      } else {
        _feedback = 'Nicht ganz. Versuch es nochmal.';
      }
    });
  }

  void _reveal(LocalWord word) {
    setState(() {
      _revealed = true;
      _feedback = 'Aufgelöst: ${word.term.trim()}';
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
      _selectedIndexes = const <int>[];
      _letters = buildWordPuzzleLetters(_roundWords[_currentIndex].term);
    });
  }
}

@visibleForTesting
List<LocalWord> buildWordPuzzleRoundWords(List<LocalWord> words) {
  final seen = <String>{};
  final playable = <LocalWord>[];
  for (final word in words) {
    final term = word.term.trim();
    if (word.isArchived || !_isPuzzleTerm(term)) continue;
    final normalized = normalizeWordPuzzleAnswer(term);
    if (normalized.isEmpty || !seen.add(normalized)) continue;
    playable.add(word);
    if (playable.length == 10) break;
  }
  return List<LocalWord>.unmodifiable(playable);
}

@visibleForTesting
List<PuzzleLetter> buildWordPuzzleLetters(String term) {
  final chars = term.trim().split('');
  final indexed = [
    for (var i = 0; i < chars.length; i += 1)
      PuzzleLetter(index: i, char: chars[i]),
  ];
  if (indexed.length <= 1) return List<PuzzleLetter>.unmodifiable(indexed);

  final shuffled = List<PuzzleLetter>.from(indexed);
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
  return List<PuzzleLetter>.unmodifiable(shuffled);
}

@visibleForTesting
String normalizeWordPuzzleAnswer(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

bool _isPuzzleTerm(String term) {
  if (term.length < 3) return false;
  if (RegExp(r'[\s\-]').hasMatch(term)) return false;
  return term.split('').where((char) => char.trim().isNotEmpty).length >= 3;
}

@visibleForTesting
class PuzzleLetter {
  const PuzzleLetter({required this.index, required this.char});

  final int index;
  final String char;
}

class _WordPuzzlePlayView extends StatelessWidget {
  const _WordPuzzlePlayView({
    required this.word,
    required this.letters,
    required this.selectedIndexes,
    required this.currentIndex,
    required this.totalCount,
    required this.feedback,
    required this.answeredCorrectly,
    required this.revealed,
    required this.onLetterTap,
    required this.onUndo,
    required this.onReset,
    required this.onCheck,
    required this.onReveal,
    required this.onNext,
  });

  final LocalWord word;
  final List<PuzzleLetter> letters;
  final List<int> selectedIndexes;
  final int currentIndex;
  final int totalCount;
  final String? feedback;
  final bool answeredCorrectly;
  final bool revealed;
  final ValueChanged<int> onLetterTap;
  final VoidCallback onUndo;
  final VoidCallback onReset;
  final VoidCallback onCheck;
  final VoidCallback onReveal;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final translation = word.translation.trim();
    final answer = selectedIndexes.map((index) => letters[index].char).join();
    return ListView(
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
                'Sortiere die Buchstaben',
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                translation.isEmpty
                    ? 'Baue aus den Chips das richtige Wort.'
                    : 'Hinweis: $translation',
                style: const TextStyle(
                  color: Color(0xFFB8C7D9),
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              _AnswerBox(answer: answer),
              const SizedBox(height: 18),
              Wrap(
                key: const ValueKey('word-puzzle-letter-wrap'),
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  for (var i = 0; i < letters.length; i += 1)
                    _LetterChip(
                      key: ValueKey('word-puzzle-letter-$i'),
                      letter: letters[i],
                      isSelected: selectedIndexes.contains(i),
                      onTap: () => onLetterTap(i),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const ValueKey('word-puzzle-undo-button'),
                      onPressed: selectedIndexes.isEmpty ? null : onUndo,
                      style: _secondaryButtonStyle(),
                      child: const Text('Zurücknehmen'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      key: const ValueKey('word-puzzle-reset-button'),
                      onPressed: selectedIndexes.isEmpty ? null : onReset,
                      style: _secondaryButtonStyle(),
                      child: const Text('Zurücksetzen'),
                    ),
                  ),
                ],
              ),
              if (feedback != null) ...[
                const SizedBox(height: 14),
                _FeedbackBanner(text: feedback!, isPositive: answeredCorrectly),
              ],
              if (revealed) ...[
                const SizedBox(height: 14),
                _RevealedWord(word: word.term.trim()),
              ],
              const SizedBox(height: 18),
              if (answeredCorrectly || revealed)
                FilledButton(
                  key: const ValueKey('word-puzzle-next-button'),
                  onPressed: onNext,
                  style: _primaryButtonStyle(),
                  child: const Text('Nächstes Wort'),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        key: const ValueKey('word-puzzle-check-button'),
                        onPressed: onCheck,
                        style: _primaryButtonStyle(),
                        child: const Text('Prüfen'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        key: const ValueKey('word-puzzle-reveal-button'),
                        onPressed: onReveal,
                        style: _secondaryButtonStyle(),
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
      disabledForegroundColor: const Color(0xFF607086),
      side: const BorderSide(color: Color(0xFF7DFFE3)),
      padding: const EdgeInsets.symmetric(vertical: 15),
      textStyle: const TextStyle(fontWeight: FontWeight.w900),
    );
  }
}

class _AnswerBox extends StatelessWidget {
  const _AnswerBox({required this.answer});

  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('word-puzzle-answer-box'),
      constraints: const BoxConstraints(minHeight: 68),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF050912),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF26354B)),
      ),
      alignment: Alignment.center,
      child: Text(
        answer.isEmpty ? 'Tippe Buchstaben an' : answer,
        key: const ValueKey('word-puzzle-answer-text'),
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
    required this.isSelected,
    required this.onTap,
  });

  final PuzzleLetter letter;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isSelected ? 0.36 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isSelected ? null : onTap,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF101B2C)
                : const Color(0xFF071523),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF26354B)
                  : const Color(0xFF7DFFE3),
            ),
            boxShadow: isSelected
                ? const []
                : [
                    BoxShadow(
                      color: const Color(0xFF7DFFE3).withValues(alpha: 0.12),
                      blurRadius: 18,
                      spreadRadius: -6,
                    ),
                  ],
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
          const Icon(Icons.extension_rounded, color: Color(0xFF7DFFE3)),
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
            'Vollständiges Wort',
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
                'Puzzle geschafft',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Du hast $correctCount von $totalCount Wörtern richtig zusammengesetzt.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                key: const ValueKey('word-puzzle-restart-button'),
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
                key: const ValueKey('word-puzzle-back-button'),
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

class _WordPuzzleMessageState extends StatelessWidget {
  const _WordPuzzleMessageState({
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
            border: Border.all(color: const Color(0xFF7DFFE3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.extension_rounded,
                color: Color(0xFF7DFFE3),
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
                  backgroundColor: const Color(0xFF7DFFE3),
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
