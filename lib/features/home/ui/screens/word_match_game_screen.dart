import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';

class WordMatchGameScreen extends ConsumerStatefulWidget {
  const WordMatchGameScreen({super.key});

  static const routeName = 'word-match-game';

  @override
  ConsumerState<WordMatchGameScreen> createState() =>
      _WordMatchGameScreenState();
}

class _WordMatchGameScreenState extends ConsumerState<WordMatchGameScreen> {
  List<WordMatchPair> _roundPairs = const <WordMatchPair>[];
  List<WordMatchPair> _translationPairs = const <WordMatchPair>[];
  String _roundKey = '';
  String? _selectedWordId;
  final Set<String> _matchedIds = <String>{};
  String? _feedback;

  bool get _isFinished =>
      _roundPairs.isNotEmpty && _matchedIds.length == _roundPairs.length;

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
        title: const Text('Wort-Match'),
      ),
      body: SafeArea(
        child: wordsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF5DDCFF)),
          ),
          error: (_, __) => _WordMatchMessageState(
            title: 'Wörter konnten nicht geladen werden',
            text: 'Versuche es gleich noch einmal.',
            buttonLabel: 'Zurück',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          data: (words) {
            final pairs = buildWordMatchPairs(words);
            if (pairs.length < 3) {
              return _WordMatchMessageState(
                title: 'Noch nicht genug Wörter',
                text:
                    'Füge mindestens drei Wörter mit Übersetzung hinzu, um Wort-Match zu spielen.',
                buttonLabel: 'Zurück',
                onPressed: () => Navigator.of(context).maybePop(),
              );
            }

            _ensureRound(pairs);
            if (_isFinished) {
              return _FinishedView(
                totalCount: _roundPairs.length,
                onRestart: () => setState(() => _restartRound(pairs)),
                onBack: () => Navigator.of(context).maybePop(),
              );
            }

            return _MatchPlayView(
              wordPairs: _roundPairs,
              translationPairs: _translationPairs,
              selectedWordId: _selectedWordId,
              matchedIds: _matchedIds,
              feedback: _feedback,
              onWordTap: _selectWord,
              onTranslationTap: _selectTranslation,
            );
          },
        ),
      ),
    );
  }

  void _ensureRound(List<WordMatchPair> pairs) {
    final nextKey = pairs.map((pair) => pair.id).join('|');
    if (_roundKey == nextKey && _roundPairs.isNotEmpty) return;
    _roundKey = nextKey;
    _restartRound(pairs);
  }

  void _restartRound(List<WordMatchPair> pairs) {
    _roundPairs = List<WordMatchPair>.unmodifiable(pairs.take(6));
    _translationPairs = mixWordMatchTranslations(_roundPairs);
    _selectedWordId = null;
    _matchedIds.clear();
    _feedback = null;
  }

  void _selectWord(WordMatchPair pair) {
    if (_matchedIds.contains(pair.id)) return;
    setState(() {
      _selectedWordId = pair.id;
      _feedback = null;
    });
  }

  void _selectTranslation(WordMatchPair pair) {
    final selectedId = _selectedWordId;
    if (selectedId == null || _matchedIds.contains(pair.id)) return;

    setState(() {
      if (selectedId == pair.id) {
        _matchedIds.add(pair.id);
        _selectedWordId = null;
        _feedback = 'Passt!';
      } else {
        _feedback = 'Nicht ganz. Versuch es nochmal.';
      }
    });
  }
}

@visibleForTesting
List<WordMatchPair> buildWordMatchPairs(List<LocalWord> words) {
  final pairs = <WordMatchPair>[];
  final seenTerms = <String>{};
  final seenTranslations = <String>{};

  for (final word in words) {
    final term = word.term.trim();
    final translation = word.translation.trim();
    if (term.isEmpty || translation.isEmpty || word.isArchived) continue;

    final normalizedTerm = _normalizeMatchText(term);
    final normalizedTranslation = _normalizeMatchText(translation);
    if (!seenTerms.add(normalizedTerm)) continue;
    if (!seenTranslations.add(normalizedTranslation)) continue;

    pairs.add(WordMatchPair(id: word.id, term: term, translation: translation));
    if (pairs.length == 6) break;
  }

  return List<WordMatchPair>.unmodifiable(pairs);
}

@visibleForTesting
List<WordMatchPair> mixWordMatchTranslations(List<WordMatchPair> pairs) {
  if (pairs.length <= 2) {
    return List<WordMatchPair>.unmodifiable(pairs.reversed);
  }
  final mixed = <WordMatchPair>[...pairs.skip(1), pairs.first];
  return List<WordMatchPair>.unmodifiable(mixed);
}

String _normalizeMatchText(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

class WordMatchPair {
  const WordMatchPair({
    required this.id,
    required this.term,
    required this.translation,
  });

  final String id;
  final String term;
  final String translation;
}

class _MatchPlayView extends StatelessWidget {
  const _MatchPlayView({
    required this.wordPairs,
    required this.translationPairs,
    required this.selectedWordId,
    required this.matchedIds,
    required this.feedback,
    required this.onWordTap,
    required this.onTranslationTap,
  });

  final List<WordMatchPair> wordPairs;
  final List<WordMatchPair> translationPairs;
  final String? selectedWordId;
  final Set<String> matchedIds;
  final String? feedback;
  final ValueChanged<WordMatchPair> onWordTap;
  final ValueChanged<WordMatchPair> onTranslationTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _ProgressHeader(
          doneCount: matchedIds.length,
          totalCount: wordPairs.length,
        ),
        if (feedback != null) ...[
          const SizedBox(height: 14),
          _FeedbackBanner(text: feedback!, isPositive: feedback == 'Passt!'),
        ],
        const SizedBox(height: 18),
        _MatchColumn(
          title: 'Wörter',
          pairs: wordPairs,
          matchedIds: matchedIds,
          selectedWordId: selectedWordId,
          textForPair: (pair) => pair.term,
          keyForPair: (pair) => ValueKey('word-match-term-${pair.id}'),
          onTap: onWordTap,
        ),
        const SizedBox(height: 18),
        _MatchColumn(
          title: 'Übersetzungen',
          pairs: translationPairs,
          matchedIds: matchedIds,
          selectedWordId: null,
          textForPair: (pair) => pair.translation,
          keyForPair: (pair) => ValueKey('word-match-translation-${pair.id}'),
          onTap: onTranslationTap,
        ),
      ],
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.doneCount, required this.totalCount});

  final int doneCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF26354B)),
      ),
      child: Row(
        children: [
          const Icon(Icons.hub_rounded, color: Color(0xFF5DDCFF)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Verbinde passende Paare',
              style: TextStyle(
                color: Color(0xFFF4F8FF),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            '$doneCount / $totalCount',
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

class _MatchColumn extends StatelessWidget {
  const _MatchColumn({
    required this.title,
    required this.pairs,
    required this.matchedIds,
    required this.selectedWordId,
    required this.textForPair,
    required this.keyForPair,
    required this.onTap,
  });

  final String title;
  final List<WordMatchPair> pairs;
  final Set<String> matchedIds;
  final String? selectedWordId;
  final String Function(WordMatchPair pair) textForPair;
  final Key Function(WordMatchPair pair) keyForPair;
  final ValueChanged<WordMatchPair> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF5DDCFF).withValues(alpha: 0.44),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5DDCFF).withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFF4F8FF),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          for (final pair in pairs) ...[
            _MatchOptionCard(
              key: keyForPair(pair),
              text: textForPair(pair),
              isSelected: selectedWordId == pair.id,
              isMatched: matchedIds.contains(pair.id),
              onTap: () => onTap(pair),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _MatchOptionCard extends StatelessWidget {
  const _MatchOptionCard({
    super.key,
    required this.text,
    required this.isSelected,
    required this.isMatched,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final bool isMatched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isMatched
        ? const Color(0xFF9DFF7D)
        : isSelected
        ? const Color(0xFF7DFFE3)
        : const Color(0xFF26354B);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: isMatched ? 0.54 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isMatched ? null : onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF102837)
                  : const Color(0xFF050912),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 1.4 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isMatched
                          ? const Color(0xFF9DFF7D)
                          : const Color(0xFFF4F8FF),
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                ),
                if (isMatched) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF9DFF7D),
                    size: 20,
                  ),
                ],
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
    required this.totalCount,
    required this.onRestart,
    required this.onBack,
  });

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
                'Runde geschafft',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Du hast alle $totalCount Wortpaare gefunden.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                key: const ValueKey('word-match-restart-button'),
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
                key: const ValueKey('word-match-back-button'),
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

class _WordMatchMessageState extends StatelessWidget {
  const _WordMatchMessageState({
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
            border: Border.all(color: const Color(0xFF5DDCFF)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.hub_rounded, color: Color(0xFF5DDCFF), size: 40),
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
