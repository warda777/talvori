import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';

const int hangmanMaxAttempts = 6;

class HangmanGameScreen extends ConsumerStatefulWidget {
  const HangmanGameScreen({super.key});

  static const routeName = 'hangman-game';

  @override
  ConsumerState<HangmanGameScreen> createState() => _HangmanGameScreenState();
}

class _HangmanGameScreenState extends ConsumerState<HangmanGameScreen> {
  List<LocalWord> _roundWords = const <LocalWord>[];
  String _roundKey = '';
  int _currentIndex = 0;
  int _solvedCount = 0;
  int _attemptsLeft = hangmanMaxAttempts;
  Set<String> _guessedLetters = const <String>{};
  bool _wordSolved = false;
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
        title: const Text('Hangman'),
      ),
      body: SafeArea(
        child: wordsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFE66D)),
          ),
          error: (_, __) => _HangmanMessageState(
            title: 'Wörter konnten nicht geladen werden',
            text: 'Versuche es gleich noch einmal.',
            buttonLabel: 'Zurück',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          data: (words) {
            final playableWords = buildHangmanRoundWords(words);
            if (playableWords.isEmpty) {
              return _HangmanMessageState(
                title: 'Noch keine passenden Wörter',
                text:
                    'Füge Wörter mit mindestens drei Buchstaben hinzu, um Hangman zu spielen.',
                buttonLabel: 'Zurück',
                onPressed: () => Navigator.of(context).maybePop(),
              );
            }

            _ensureRound(playableWords);
            if (_isFinished) {
              return _FinishedView(
                solvedCount: _solvedCount,
                totalCount: _roundWords.length,
                onRestart: () => setState(() => _restartRound(playableWords)),
                onBack: () => Navigator.of(context).maybePop(),
              );
            }

            final word = _roundWords[_currentIndex];
            return _HangmanPlayView(
              word: word,
              maskedWord: buildHangmanMask(word.term, _guessedLetters),
              currentIndex: _currentIndex,
              totalCount: _roundWords.length,
              attemptsLeft: _attemptsLeft,
              guessedLetters: _guessedLetters,
              feedback: _feedback,
              resolved: _wordSolved || _revealed || _attemptsLeft <= 0,
              wordSolved: _wordSolved,
              onGuess: (letter) => _guessLetter(word, letter),
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
    _solvedCount = 0;
    _isFinished = false;
    _resetCurrentWord();
  }

  void _resetCurrentWord() {
    _attemptsLeft = hangmanMaxAttempts;
    _guessedLetters = const <String>{};
    _wordSolved = false;
    _revealed = false;
    _feedback = null;
  }

  void _guessLetter(LocalWord word, String letter) {
    if (_wordSolved || _revealed || _attemptsLeft <= 0) return;
    final normalizedLetter = normalizeHangmanLetter(letter);
    if (_guessedLetters.contains(normalizedLetter)) return;

    final wordLetters = normalizedHangmanLetters(word.term).toSet();
    final isHit = wordLetters.contains(normalizedLetter);
    setState(() {
      _guessedLetters = {..._guessedLetters, normalizedLetter};
      if (isHit) {
        final solved = wordLetters.difference(_guessedLetters).isEmpty;
        if (solved) {
          _wordSolved = true;
          _solvedCount += 1;
          _feedback = 'Wort gelöst!';
        } else {
          _feedback = 'Guter Treffer!';
        }
        return;
      }

      _attemptsLeft -= 1;
      if (_attemptsLeft <= 0) {
        _revealed = true;
        _feedback = 'Aufgelöst.';
      } else {
        _feedback = 'Der Buchstabe ist nicht dabei.';
      }
    });
  }

  void _reveal(LocalWord word) {
    if (_wordSolved || _revealed) return;
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
      _resetCurrentWord();
    });
  }
}

@visibleForTesting
List<LocalWord> buildHangmanRoundWords(List<LocalWord> words) {
  final seen = <String>{};
  final playable = <LocalWord>[];
  for (final word in words) {
    final term = word.term.trim();
    if (word.isArchived || !isHangmanTerm(term)) continue;
    final normalized = normalizeHangmanWord(term);
    if (normalized.isEmpty || !seen.add(normalized)) continue;
    playable.add(word);
    if (playable.length == 10) break;
  }
  return List<LocalWord>.unmodifiable(playable);
}

@visibleForTesting
bool isHangmanTerm(String term) {
  if (term.length < 3) return false;
  if (RegExp(r'[\s\-]').hasMatch(term)) return false;
  return term.split('').every(_isSupportedHangmanLetter);
}

@visibleForTesting
String buildHangmanMask(String term, Set<String> guessedLetters) {
  return term
      .trim()
      .split('')
      .map((char) {
        final normalized = normalizeHangmanLetter(char);
        return guessedLetters.contains(normalized) ? char : '_';
      })
      .join(' ');
}

@visibleForTesting
List<String> normalizedHangmanLetters(String term) {
  return term.trim().split('').map(normalizeHangmanLetter).toList();
}

@visibleForTesting
String normalizeHangmanLetter(String value) {
  return value.trim().toUpperCase();
}

@visibleForTesting
String normalizeHangmanWord(String value) {
  return normalizedHangmanLetters(value).join();
}

bool _isSupportedHangmanLetter(String char) {
  return RegExp(r'[A-Za-zÄÖÜäöü]').hasMatch(char);
}

const _hangmanAlphabet = <String>[
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  'Ä',
  'Ö',
  'Ü',
];

class _HangmanPlayView extends StatelessWidget {
  const _HangmanPlayView({
    required this.word,
    required this.maskedWord,
    required this.currentIndex,
    required this.totalCount,
    required this.attemptsLeft,
    required this.guessedLetters,
    required this.feedback,
    required this.resolved,
    required this.wordSolved,
    required this.onGuess,
    required this.onReveal,
    required this.onNext,
  });

  final LocalWord word;
  final String maskedWord;
  final int currentIndex;
  final int totalCount;
  final int attemptsLeft;
  final Set<String> guessedLetters;
  final String? feedback;
  final bool resolved;
  final bool wordSolved;
  final ValueChanged<String> onGuess;
  final VoidCallback onReveal;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _RoundHeader(
          currentIndex: currentIndex,
          totalCount: totalCount,
          attemptsLeft: attemptsLeft,
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFFFFE66D).withValues(alpha: 0.62),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFE66D).withValues(alpha: 0.12),
                blurRadius: 28,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Errate das Wort Schritt für Schritt',
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (word.translation.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Hinweis: ${word.translation.trim()}',
                  style: const TextStyle(
                    color: Color(0xFFB8C7D9),
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Container(
                key: const ValueKey('hangman-mask-card'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF050912),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF26354B)),
                ),
                child: Text(
                  resolved ? word.term.trim() : maskedWord,
                  key: const ValueKey('hangman-mask'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFF4F8FF),
                    fontSize: 30,
                    height: 1.18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (feedback != null) ...[
                const SizedBox(height: 14),
                _FeedbackBanner(
                  text: feedback!,
                  isPositive: wordSolved || feedback == 'Guter Treffer!',
                ),
              ],
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final letter in _hangmanAlphabet)
                    _LetterChip(
                      letter: letter,
                      selected: guessedLetters.contains(letter),
                      disabled: resolved || guessedLetters.contains(letter),
                      onTap: () => onGuess(letter),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              if (resolved)
                FilledButton(
                  key: const ValueKey('hangman-next-button'),
                  onPressed: onNext,
                  style: _primaryButtonStyle(),
                  child: const Text('Nächstes Wort'),
                )
              else
                OutlinedButton(
                  key: const ValueKey('hangman-reveal-button'),
                  onPressed: onReveal,
                  style: _secondaryButtonStyle(),
                  child: const Text('Auflösen'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: const Color(0xFFFFE66D),
      foregroundColor: const Color(0xFF041018),
      padding: const EdgeInsets.symmetric(vertical: 15),
      textStyle: const TextStyle(fontWeight: FontWeight.w900),
    );
  }

  ButtonStyle _secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFFF4F8FF),
      side: const BorderSide(color: Color(0xFFFFE66D)),
      padding: const EdgeInsets.symmetric(vertical: 15),
      textStyle: const TextStyle(fontWeight: FontWeight.w900),
    );
  }
}

class _RoundHeader extends StatelessWidget {
  const _RoundHeader({
    required this.currentIndex,
    required this.totalCount,
    required this.attemptsLeft,
  });

  final int currentIndex;
  final int totalCount;
  final int attemptsLeft;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatusPill(
            icon: Icons.auto_awesome_rounded,
            label: '${currentIndex + 1} / $totalCount',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatusPill(
            icon: Icons.favorite_rounded,
            label: 'Versuche übrig: $attemptsLeft',
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
          Icon(icon, color: const Color(0xFFFFE66D), size: 18),
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

class _LetterChip extends StatelessWidget {
  const _LetterChip({
    required this.letter,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final String letter;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('hangman-letter-$letter'),
          borderRadius: BorderRadius.circular(14),
          onTap: disabled ? null : onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFFFE66D).withValues(alpha: 0.18)
                  : const Color(0xFF050912),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? const Color(0xFFFFE66D)
                    : const Color(0xFF26354B),
              ),
            ),
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  color: disabled && !selected
                      ? const Color(0xFF6D7886)
                      : const Color(0xFFF4F8FF),
                  fontWeight: FontWeight.w900,
                ),
              ),
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
    required this.solvedCount,
    required this.totalCount,
    required this.onRestart,
    required this.onBack,
  });

  final int solvedCount;
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
            border: Border.all(color: const Color(0xFFFFE66D)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFE66D).withValues(alpha: 0.14),
                blurRadius: 30,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.lightbulb_rounded,
                color: Color(0xFFFFE66D),
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
                'Du hast $solvedCount von $totalCount Wörtern gelöst.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                key: const ValueKey('hangman-restart-button'),
                onPressed: onRestart,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFE66D),
                  foregroundColor: const Color(0xFF041018),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
                child: const Text('Nochmal spielen'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const ValueKey('hangman-back-button'),
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF4F8FF),
                  side: const BorderSide(color: Color(0xFFFFE66D)),
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

class _HangmanMessageState extends StatelessWidget {
  const _HangmanMessageState({
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
            border: Border.all(color: const Color(0xFFFFE66D)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.lightbulb_rounded,
                color: Color(0xFFFFE66D),
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
                  backgroundColor: const Color(0xFFFFE66D),
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
