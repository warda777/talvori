import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';

class GapWordGameScreen extends ConsumerStatefulWidget {
  const GapWordGameScreen({super.key});

  static const routeName = 'gap-word-game';

  @override
  ConsumerState<GapWordGameScreen> createState() => _GapWordGameScreenState();
}

class _GapWordGameScreenState extends ConsumerState<GapWordGameScreen> {
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();
  List<LocalWord> _roundWords = const <LocalWord>[];
  String _roundKey = '';
  int _currentIndex = 0;
  int _correctCount = 0;
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
    final wordsAsync = ref.watch(
      localWordsForSourceProvider(LocalLearningSource.allWords),
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF050912),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050912),
        elevation: 0,
        centerTitle: true,
        title: const Text('Lückenwort'),
      ),
      body: SafeArea(
        child: wordsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF7DFFE3)),
          ),
          error: (_, __) => _GapWordMessageState(
            title: 'Wörter konnten nicht geladen werden',
            text: 'Versuche es gleich noch einmal.',
            buttonLabel: 'Zurück',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          data: (words) {
            final playableWords = buildGapWordRoundWords(words);
            if (playableWords.isEmpty) {
              return _GapWordMessageState(
                title: 'Noch keine passenden Wörter',
                text:
                    'Füge Wörter mit mindestens vier Buchstaben hinzu, um Lückenwort zu spielen.',
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
            return _GapWordPlayView(
              word: word,
              gapPattern: buildGapWordPattern(word.term),
              answerController: _answerController,
              answerFocusNode: _answerFocusNode,
              currentIndex: _currentIndex,
              totalCount: _roundWords.length,
              feedback: _feedback,
              answeredCorrectly: _answeredCorrectly,
              revealed: _revealed,
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
    _answerController.clear();
  }

  void _checkAnswer(LocalWord word) {
    final isCorrect =
        normalizeGapWordAnswer(_answerController.text) ==
        normalizeGapWordAnswer(word.term);
    setState(() {
      if (isCorrect) {
        if (!_answeredCorrectly) _correctCount += 1;
        _answeredCorrectly = true;
        _revealed = true;
        _feedback = 'Richtig!';
        _answerFocusNode.unfocus();
      } else {
        _feedback = 'Fast. Versuch es nochmal.';
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
List<LocalWord> buildGapWordRoundWords(List<LocalWord> words) {
  final seen = <String>{};
  final playable = <LocalWord>[];
  for (final word in words) {
    final term = word.term.trim();
    if (word.isArchived || _letterCount(term) < 4) continue;
    final normalized = normalizeGapWordAnswer(term);
    if (normalized.isEmpty || !seen.add(normalized)) continue;
    playable.add(word);
    if (playable.length == 10) break;
  }
  return List<LocalWord>.unmodifiable(playable);
}

@visibleForTesting
String buildGapWordPattern(String term) {
  final chars = term.trim().split('');
  if (chars.isEmpty) return '';

  final removable = <int>[];
  var firstLetterSeen = false;
  for (var i = 0; i < chars.length; i += 1) {
    final char = chars[i];
    if (!_isGapLetter(char)) continue;
    if (!firstLetterSeen) {
      firstLetterSeen = true;
      continue;
    }
    removable.add(i);
  }

  if (removable.isEmpty) return chars.join(' ');
  final letterCount = _letterCount(term);
  final target = (letterCount * 0.38)
      .round()
      .clamp(1, removable.length)
      .toInt();
  final maxHidden = (letterCount - 2).clamp(1, letterCount).toInt();
  final hideCount = target.clamp(1, maxHidden).toInt();
  final hidden = <int>{};
  var cursor = 0;
  while (hidden.length < hideCount && hidden.length < removable.length) {
    hidden.add(removable[cursor % removable.length]);
    cursor += 2;
    if (cursor >= removable.length && hidden.length < hideCount) {
      cursor = (cursor + 1) % removable.length;
    }
  }

  return [
    for (var i = 0; i < chars.length; i += 1)
      hidden.contains(i) ? '_' : chars[i],
  ].join(' ');
}

@visibleForTesting
String normalizeGapWordAnswer(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

bool _isGapLetter(String char) {
  return RegExp(r'[^\s\-]').hasMatch(char);
}

int _letterCount(String value) {
  return value.split('').where(_isGapLetter).length;
}

class _GapWordPlayView extends StatelessWidget {
  const _GapWordPlayView({
    required this.word,
    required this.gapPattern,
    required this.answerController,
    required this.answerFocusNode,
    required this.currentIndex,
    required this.totalCount,
    required this.feedback,
    required this.answeredCorrectly,
    required this.revealed,
    required this.onCheck,
    required this.onReveal,
    required this.onNext,
  });

  final LocalWord word;
  final String gapPattern;
  final TextEditingController answerController;
  final FocusNode answerFocusNode;
  final int currentIndex;
  final int totalCount;
  final String? feedback;
  final bool answeredCorrectly;
  final bool revealed;
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
                'Ergänze die Lücken',
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                translation.isEmpty
                    ? 'Tippe das vollständige Wort ein.'
                    : 'Hinweis: $translation',
                style: const TextStyle(
                  color: Color(0xFFB8C7D9),
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                key: const ValueKey('gap-word-pattern-card'),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF050912),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF26354B)),
                ),
                child: Text(
                  gapPattern,
                  key: const ValueKey('gap-word-pattern-text'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFF4F8FF),
                    fontSize: 30,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                key: const ValueKey('gap-word-answer-field'),
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
                  hintText: 'Vollständiges Wort eingeben',
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
                _FeedbackBanner(text: feedback!, isPositive: answeredCorrectly),
              ],
              if (revealed) ...[
                const SizedBox(height: 14),
                _RevealedWord(word: word.term.trim()),
              ],
              const SizedBox(height: 18),
              if (answeredCorrectly || revealed)
                FilledButton(
                  key: const ValueKey('gap-word-next-button'),
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
                        key: const ValueKey('gap-word-check-button'),
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
                        key: const ValueKey('gap-word-reveal-button'),
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
          const Icon(Icons.edit_note_rounded, color: Color(0xFF7DFFE3)),
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
                'Du hast $correctCount von $totalCount Wörtern richtig ergänzt.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                key: const ValueKey('gap-word-restart-button'),
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
                key: const ValueKey('gap-word-back-button'),
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

class _GapWordMessageState extends StatelessWidget {
  const _GapWordMessageState({
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
                Icons.edit_note_rounded,
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
