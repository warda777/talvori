import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/core/pronunciation/word_pronunciation_provider.dart';
import 'package:talvori/features/home/application/word_game_ai_provider.dart';
import 'package:talvori/features/home/application/word_game_language_pair.dart';
import 'package:talvori/features/home/application/word_game_progress_controller.dart';
import 'package:talvori/features/home/application/word_game_rewards_controller.dart';
import 'package:talvori/features/home/ui/widgets/game_word_source_picker.dart';

enum ArcadeGameKind {
  syllableRain,
  oddWord,
  audioCatch,
  wordPath,
  wordSearch,
  synonymRiddle,
}

enum ArcadeSpeed {
  relaxed('Entspannt', 2200),
  slow('Langsam', 1800),
  medium('Mittel', 1400),
  fast('Schnell', 1100);

  const ArcadeSpeed(this.label, this.milliseconds);

  final String label;
  final int milliseconds;
}

class WordGameArcadeScreen extends ConsumerStatefulWidget {
  const WordGameArcadeScreen({super.key, required this.kind});

  final ArcadeGameKind kind;

  @override
  ConsumerState<WordGameArcadeScreen> createState() =>
      _WordGameArcadeScreenState();
}

class _WordGameArcadeScreenState extends ConsumerState<WordGameArcadeScreen> {
  final SharedPreferencesWordGameProgressRepository _progressRepository =
      const SharedPreferencesWordGameProgressRepository();
  final SharedPreferencesWordGameRewardsRepository _rewardsRepository =
      const SharedPreferencesWordGameRewardsRepository();
  GameWordSource _selectedSource = GameWordSource.standard(
    LocalLearningSource.allWords,
  );
  ArcadeSpeed _speed = ArcadeSpeed.medium;
  WordGameLanguagePair _languagePair = WordGameLanguagePair.englishGerman;
  int _wordsPerRound = 10;
  List<ArcadeItem> _roundItems = const <ArcadeItem>[];
  List<String> _selectedParts = const <String>[];
  List<int> _selectedPathIndexes = const <int>[];
  String _roundKey = '';
  int _currentIndex = 0;
  int _score = 0;
  int _missed = 0;
  Timer? _audioMissTimer;
  Timer? _audioFeedbackTimer;
  Timer? _audioInstructionTimer;
  bool _audioInitialInstructionConsumed = false;
  bool _rewardRecorded = false;
  bool _hasStarted = false;
  bool _resolved = false;
  bool _isFinished = false;
  bool _isAiLoading = false;
  ArcadeAiTask? _aiTask;
  String? _feedback;

  _GameConfig get _config => _GameConfig.forKind(widget.kind);

  @override
  void dispose() {
    _audioMissTimer?.cancel();
    _audioFeedbackTimer?.cancel();
    _audioInstructionTimer?.cancel();
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
        title: Text(_config.title),
      ),
      body: SafeArea(
        child: wordsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF7DFFE3)),
          ),
          error: (_, __) => _ArcadeMessage(
            title: 'Wörter konnten nicht geladen werden',
            text: 'Versuche es gleich noch einmal.',
            buttonLabel: 'Zurück',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          data: (words) {
            final categories = categoriesAsync.value ?? const <LocalCategory>[];
            final playable = buildArcadePlayableItems(widget.kind, words);
            final availableIds = playable
                .map((item) => item.id)
                .toList(growable: false);
            final sourceKey =
                '${_selectedSource.key}:${availableIds.join('|')}:${widget.kind.name}';
            if (_roundKey != sourceKey) {
              _resetForSelection(sourceKey);
            }

            if (playable.length < _config.minimum) {
              return _ArcadeMessage(
                title: _config.emptyTitle,
                text: _selectedSource.categoryId == null
                    ? _config.emptySourceText
                    : _config.emptyWorldText,
                buttonLabel: 'Zurück',
                selectedSource: _selectedSource,
                categories: categories,
                availableIds: availableIds,
                wordsPerRound: _effectiveWordsPerRound(playable.length),
                minWordsPerRound: _config.minimum,
                onSourceSelected: _selectSource,
                onWordsPerRoundChanged: _selectWordsPerRound,
                onPressed: () => Navigator.of(context).maybePop(),
              );
            }

            if (!_hasStarted) {
              return _ArcadeStartView(
                config: _config,
                selectedSource: _selectedSource,
                categories: categories,
                availableIds: availableIds,
                wordsPerRound: _effectiveWordsPerRound(playable.length),
                minWordsPerRound: _config.minimum,
                speed: _speed,
                languagePair: _languagePair,
                onSpeedChanged: _config.usesSpeed
                    ? (speed) => setState(() => _speed = speed)
                    : null,
                onLanguagePairChanged: _config.usesAi
                    ? (pair) => setState(() => _languagePair = pair)
                    : null,
                onSourceSelected: _selectSource,
                onWordsPerRoundChanged: _selectWordsPerRound,
                onStart: () => _startRound(playable),
              );
            }

            if (_isFinished) {
              return _ArcadeFinishedView(
                config: _config,
                score: _score,
                total: _roundItems.length,
                remaining: max(0, _roundItems.length - _score),
                missed: _missed,
                onRestart: () => _startRound(playable),
                onBack: () => Navigator.of(context).maybePop(),
              );
            }

            final item = _roundItems[_currentIndex];
            return _ArcadePlayView(
              kind: widget.kind,
              config: _config,
              item: item,
              aiTask: _aiTask,
              isAiLoading: _isAiLoading,
              allItems: _roundItems,
              currentIndex: _currentIndex,
              total: _roundItems.length,
              score: _score,
              missed: _missed,
              speed: _speed,
              selectedParts: _selectedParts,
              selectedPathIndexes: _selectedPathIndexes,
              resolved: _resolved,
              feedback: _feedback,
              showInitialAudioInstruction: !_audioInitialInstructionConsumed,
              onSpeak: () => _speak(item),
              onPartTap: _selectPart,
              onAnswer: _answer,
              onPathTap: _selectPathIndex,
              onNext: _next,
            );
          },
        ),
      ),
    );
  }

  void _resetForSelection(String sourceKey) {
    _roundKey = sourceKey;
    _roundItems = const <ArcadeItem>[];
    _selectedParts = const <String>[];
    _selectedPathIndexes = const <int>[];
    _currentIndex = 0;
    _score = 0;
    _missed = 0;
    _audioMissTimer?.cancel();
    _audioFeedbackTimer?.cancel();
    _audioInstructionTimer?.cancel();
    _audioInitialInstructionConsumed = false;
    _rewardRecorded = false;
    _hasStarted = false;
    _resolved = false;
    _isFinished = false;
    _isAiLoading = false;
    _aiTask = null;
    _feedback = null;
  }

  void _selectSource(GameWordSource source) {
    if (_selectedSource == source) return;
    setState(() {
      _selectedSource = source;
      _resetForSelection('');
    });
  }

  void _selectWordsPerRound(int count) {
    if (_wordsPerRound == count) return;
    setState(() {
      _wordsPerRound = count;
      _resetForSelection('');
    });
  }

  int _effectiveWordsPerRound(int available) {
    return clampWordsPerRound(
      requested: _wordsPerRound,
      minimum: _config.minimum,
      available: available,
    );
  }

  void _startRound(List<ArcadeItem> playable) {
    setState(() => _restartRound(playable));
    _prepareAiTaskIfNeeded();
    _startAudioTargetIfNeeded();
  }

  void _restartRound(List<ArcadeItem> playable) {
    _roundItems = selectWordGameRoundItemsByCount<ArcadeItem>(
      items: playable,
      idOf: (item) => item.id,
      playedIds: const <String>{},
      wordsPerRound: _effectiveWordsPerRound(playable.length),
    );
    _progressRepository.markPlayedIds(
      _config.gameId,
      _selectedSource.key,
      _roundItems.map((item) => item.id),
    );
    _currentIndex = 0;
    _score = 0;
    _missed = 0;
    _audioFeedbackTimer?.cancel();
    _audioInstructionTimer?.cancel();
    _audioInitialInstructionConsumed = false;
    _rewardRecorded = false;
    _hasStarted = true;
    _resolved = false;
    _isFinished = false;
    _isAiLoading = false;
    _aiTask = null;
    _selectedParts = const <String>[];
    _selectedPathIndexes = const <int>[];
    _feedback = null;
  }

  void _prepareAiTaskIfNeeded() {
    if (!_config.usesAi || !_hasStarted || _roundItems.isEmpty) return;
    final item = _roundItems[_currentIndex];
    setState(() {
      _isAiLoading = true;
      _aiTask = null;
      _feedback = null;
    });
    unawaited(_loadAiTask(item));
  }

  Future<void> _loadAiTask(ArcadeItem item) async {
    try {
      final task = switch (widget.kind) {
        ArcadeGameKind.oddWord => await _buildOddWordAiTask(item),
        ArcadeGameKind.synonymRiddle => await _buildSynonymAiTask(item),
        _ => null,
      };
      if (!mounted) return;
      setState(() {
        _aiTask = task;
        _isAiLoading = false;
        if (task == null) _feedback = 'KI-Spiel momentan nicht verfügbar';
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _isAiLoading = false;
        _aiTask = null;
        _feedback = 'KI-Spiel momentan nicht verfügbar';
      });
    }
  }

  Future<ArcadeAiTask?> _buildOddWordAiTask(ArcadeItem item) async {
    final client = ref.read(wordGameAiClientProvider);
    final sourceTarget = _arcadeSourceText(item, _languagePair);
    final result = await client.sendMessage(
      AiChatRequest(
        language: _languagePair.answerCode,
        message:
            'Erzeuge fuer das Wort "$sourceTarget" in ${_languagePair.sourceLabel} drei passende Woerter aus demselben Themenfeld und ein Gegenwort, das nicht dazugehört. Verwende fuer alle Optionen die Sprache ${_languagePair.answerLabel}. Antworte nur als JSON mit den Feldern group (Liste mit 3 Strings) und odd (String).',
        context: {
          'game': 'gegenwort',
          'word': item.term,
          'translation': item.translation,
          'sourceTarget': sourceTarget,
          'sourceLanguage': _languagePair.sourceCode,
          'answerLanguage': _languagePair.answerCode,
          'languagePair': _languagePair.label,
        },
      ),
    );
    final parsed = parseGegenwortAiReply(result.reply);
    if (parsed == null) return null;
    final options = [...parsed.group, parsed.odd]..shuffle();
    return ArcadeAiTask(
      prompt:
          'Drei Wörter passen zu "$sourceTarget". Welches gehört nicht dazu? (${_languagePair.label})',
      options: options,
      correctAnswer: parsed.odd,
    );
  }

  Future<ArcadeAiTask?> _buildSynonymAiTask(ArcadeItem item) async {
    final client = ref.read(wordGameAiClientProvider);
    final sourceTarget = _arcadeSourceText(item, _languagePair);
    final result = await client.sendMessage(
      AiChatRequest(
        language: _languagePair.sourceCode,
        message:
            'Erzeuge 2 bis 3 kurze Synonyme oder Bedeutungshinweise in ${_languagePair.sourceLabel} fuer das Wort "$sourceTarget". Die Antwortoptionen sind in ${_languagePair.answerLabel}. Antworte nur mit den Hinweisen, getrennt durch Kommas. Keine langen Saetze.',
        context: {
          'game': 'synonym-riddle',
          'word': item.term,
          'translation': item.translation,
          'sourceTarget': sourceTarget,
          'sourceLanguage': _languagePair.sourceCode,
          'answerLanguage': _languagePair.answerCode,
          'languagePair': _languagePair.label,
        },
      ),
    );
    final hints = parseSynonymAiReply(result.reply);
    if (hints.length < 2) return null;
    return ArcadeAiTask(
      prompt: hints.join(', '),
      options: _answerOptionsWithCorrect(_roundItems, item, _languagePair)
        ..shuffle(),
      correctAnswer: _arcadeAnswerText(item, _languagePair),
    );
  }

  Future<void> _speak(ArcadeItem item) async {
    final result = await ref
        .read(wordPronunciationServiceProvider)
        .speakWord(item.term, languageCode: item.sourceLanguage);
    if (!mounted || result.isSuccess) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Anhören ist gerade nicht verfügbar.')),
      );
  }

  void _selectPart(String part) {
    if (_resolved) return;
    final next = [..._selectedParts, part].take(2).toList(growable: false);
    setState(() {
      _selectedParts = next;
      if (next.length == 2) {
        final correct = next.join() == _roundItems[_currentIndex].term;
        _finishAnswer(correct, correct ? 'Wort gebildet!' : 'Noch offen.');
      }
    });
  }

  void _selectPathIndex(int index) {
    if (_resolved || _selectedPathIndexes.contains(index)) return;
    final next = [..._selectedPathIndexes, index];
    final target = _roundItems[_currentIndex].term;
    final letters = target.split('');
    final answer = next.map((i) => letters[i % letters.length]).join();
    setState(() {
      _selectedPathIndexes = next;
      if (answer.length == target.length) {
        _finishAnswer(answer.toLowerCase() == target.toLowerCase(), 'Geprüft.');
      }
    });
  }

  void _answer(String answer) {
    if (_resolved) return;
    final item = _roundItems[_currentIndex];
    if (widget.kind == ArcadeGameKind.audioCatch) {
      if (answer == item.term) {
        _audioMissTimer?.cancel();
        setState(() {
          _score += 1;
        });
        _showAudioFeedback('Gefangen');
        _advanceAudioTarget();
      } else {
        _showAudioFeedback('Falsch');
      }
      return;
    }
    final correct = answer == (_aiTask?.correctAnswer ?? item.correctAnswer);
    setState(() => _finishAnswer(correct, correct ? 'Richtig' : 'Falsch'));
  }

  void _startAudioTargetIfNeeded() {
    if (widget.kind != ArcadeGameKind.audioCatch ||
        !_hasStarted ||
        _isFinished ||
        _roundItems.isEmpty) {
      return;
    }
    final item = _roundItems[_currentIndex];
    unawaited(_speak(item));
    _scheduleAudioInstructionHide();
    _audioMissTimer?.cancel();
    _audioMissTimer = Timer(
      Duration(milliseconds: _speed.milliseconds * 4),
      _missAudioTarget,
    );
  }

  void _missAudioTarget() {
    if (!mounted || widget.kind != ArcadeGameKind.audioCatch || _isFinished) {
      return;
    }
    setState(() {
      _missed += 1;
    });
    _showAudioFeedback('Verpasst');
    _advanceAudioTarget();
  }

  void _showAudioFeedback(String feedback) {
    _audioFeedbackTimer?.cancel();
    _audioInstructionTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _audioInitialInstructionConsumed = true;
      _feedback = feedback;
    });
    _audioFeedbackTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted || widget.kind != ArcadeGameKind.audioCatch) return;
      setState(() => _feedback = null);
    });
  }

  void _scheduleAudioInstructionHide() {
    if (widget.kind != ArcadeGameKind.audioCatch ||
        _audioInitialInstructionConsumed ||
        _feedback != null) {
      return;
    }
    _audioInstructionTimer?.cancel();
    _audioInstructionTimer = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted ||
          widget.kind != ArcadeGameKind.audioCatch ||
          _feedback != null) {
        return;
      }
      setState(() => _audioInitialInstructionConsumed = true);
    });
  }

  void _advanceAudioTarget() {
    if (!mounted || widget.kind != ArcadeGameKind.audioCatch) return;
    setState(() {
      if (_currentIndex >= _roundItems.length - 1) {
        _isFinished = true;
        _recordRewardOnce();
        _audioMissTimer?.cancel();
        return;
      }
      _currentIndex += 1;
    });
    _startAudioTargetIfNeeded();
  }

  void _finishAnswer(bool correct, String feedback) {
    _resolved = true;
    if (correct) _score += 1;
    _feedback = feedback;
  }

  void _recordRewardOnce() {
    if (_rewardRecorded || _roundItems.isEmpty) return;
    _rewardRecorded = true;
    unawaited(
      _rewardsRepository.recordRound(
        WordGameRoundRewardInput(
          gameId: _config.gameId,
          sourceKey: _selectedSource.key,
          wordsPerRound: _roundItems.length,
          playedWords: _roundItems.length,
          correctWithoutHint: _score,
          wrong: max(0, _roundItems.length - _score - _missed),
          missed: _missed,
          completed: true,
          isAiGame: _config.usesAi,
          isPremiumAiGame: _config.usesAi,
          roundId:
              '${_config.gameId}:${_selectedSource.key}:${_roundItems.map((item) => item.id).join(",")}:$_score:$_missed',
        ),
      ),
    );
  }

  void _next() {
    setState(() {
      if (_currentIndex >= _roundItems.length - 1) {
        _isFinished = true;
        _recordRewardOnce();
        _audioMissTimer?.cancel();
        return;
      }
      _currentIndex += 1;
      _resolved = false;
      _selectedParts = const <String>[];
      _selectedPathIndexes = const <int>[];
      _feedback = null;
      _audioFeedbackTimer?.cancel();
      _audioInstructionTimer?.cancel();
    });
    _prepareAiTaskIfNeeded();
    _startAudioTargetIfNeeded();
  }
}

@visibleForTesting
List<ArcadeItem> buildArcadePlayableItems(
  ArcadeGameKind kind,
  List<LocalWord> words,
) {
  final base = <ArcadeItem>[];
  final seen = <String>{};
  for (final word in words) {
    final term = word.term.trim();
    final translation = word.translation.trim();
    if (word.isArchived || term.isEmpty) continue;
    if (!seen.add('${term.toLowerCase()}|${translation.toLowerCase()}')) {
      continue;
    }
    base.add(
      ArcadeItem(
        id: word.id,
        term: term,
        translation: translation,
        categoryId: word.categoryId,
        sourceLanguage: word.sourceLanguage ?? 'en',
      ),
    );
  }

  return switch (kind) {
    ArcadeGameKind.syllableRain =>
      base
          .where((item) => _canSplit(item.term))
          .map((item) => item.copyWith(parts: splitArcadeWordParts(item.term)))
          .toList(growable: false),
    ArcadeGameKind.oddWord => _buildOddWordItems(base),
    ArcadeGameKind.audioCatch =>
      base
          .where((item) => item.term.length >= 2)
          .map((item) => item.copyWith(correctAnswer: item.term))
          .toList(growable: false),
    ArcadeGameKind.wordPath =>
      base
          .where((item) => _isSimpleTerm(item.term, min: 3, max: 12))
          .toList(growable: false),
    ArcadeGameKind.wordSearch =>
      base
          .where((item) => _isSimpleTerm(item.term, min: 3, max: 10))
          .toList(growable: false),
    ArcadeGameKind.synonymRiddle =>
      base
          .where((item) => item.translation.trim().isNotEmpty)
          .map((item) => item.copyWith(correctAnswer: item.term))
          .toList(growable: false),
  };
}

class ArcadeAiTask {
  const ArcadeAiTask({
    required this.prompt,
    required this.options,
    required this.correctAnswer,
  });

  final String prompt;
  final List<String> options;
  final String correctAnswer;
}

class GegenwortAiGroup {
  const GegenwortAiGroup({required this.group, required this.odd});

  final List<String> group;
  final String odd;
}

@visibleForTesting
GegenwortAiGroup? parseGegenwortAiReply(String reply) {
  final text = reply.trim();
  final quoted = RegExp(r'"([^"]+)"')
      .allMatches(text)
      .map((match) {
        return match.group(1)!.trim();
      })
      .where((value) {
        return value.isNotEmpty &&
            !{
              'group',
              'odd',
              'words',
              'gegenwort',
            }.contains(value.toLowerCase());
      })
      .toList();
  if (quoted.length >= 4) {
    return GegenwortAiGroup(
      group: quoted.take(3).toList(growable: false),
      odd: quoted[3],
    );
  }
  final lines = text
      .split(RegExp(r'[\n,;]'))
      .map((line) => line.replaceAll(RegExp(r'^[\-\*\d\.\s:]+'), '').trim())
      .where((line) => line.isNotEmpty)
      .toList();
  if (lines.length < 4) return null;
  return GegenwortAiGroup(
    group: lines.take(3).toList(growable: false),
    odd: lines[3],
  );
}

@visibleForTesting
List<String> parseSynonymAiReply(String reply) {
  return reply
      .split(RegExp(r'[\n,;]'))
      .map((part) => part.replaceAll(RegExp(r'^[\-\*\d\.\s:]+'), '').trim())
      .where((part) => part.length >= 2 && part.length <= 32)
      .take(3)
      .toList(growable: false);
}

@visibleForTesting
List<String> splitArcadeWordParts(String term) {
  final clean = term.trim();
  final middle = (clean.length / 2).floor().clamp(2, clean.length - 2);
  return [clean.substring(0, middle), clean.substring(middle)];
}

bool _canSplit(String term) {
  final clean = term.trim();
  return clean.length >= 4 && !RegExp(r'[\s\-]').hasMatch(clean);
}

bool _isSimpleTerm(String term, {required int min, required int max}) {
  final clean = term.trim();
  return clean.length >= min &&
      clean.length <= max &&
      RegExp(r'^[A-Za-zÄÖÜäöü]+$').hasMatch(clean);
}

List<ArcadeItem> _buildOddWordItems(List<ArcadeItem> items) {
  return [
    for (final item in items)
      if (item.term.trim().isNotEmpty) item.copyWith(correctAnswer: item.term),
  ];
}

class ArcadeItem {
  const ArcadeItem({
    required this.id,
    required this.term,
    required this.translation,
    required this.categoryId,
    required this.sourceLanguage,
    this.parts = const <String>[],
    this.options = const <String>[],
    this.correctAnswer,
  });

  final String id;
  final String term;
  final String translation;
  final String categoryId;
  final String sourceLanguage;
  final List<String> parts;
  final List<String> options;
  final String? correctAnswer;

  ArcadeItem copyWith({
    List<String>? parts,
    List<String>? options,
    String? correctAnswer,
  }) {
    return ArcadeItem(
      id: id,
      term: term,
      translation: translation,
      categoryId: categoryId,
      sourceLanguage: sourceLanguage,
      parts: parts ?? this.parts,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
    );
  }
}

class _GameConfig {
  const _GameConfig({
    required this.gameId,
    required this.title,
    required this.subtitle,
    required this.startButton,
    required this.emptyTitle,
    required this.emptySourceText,
    required this.emptyWorldText,
    required this.finishedTitle,
    required this.finishedText,
    required this.minimum,
    required this.accent,
    this.usesSpeed = false,
    this.usesAi = false,
  });

  final String gameId;
  final String title;
  final String subtitle;
  final String startButton;
  final String emptyTitle;
  final String emptySourceText;
  final String emptyWorldText;
  final String finishedTitle;
  final String finishedText;
  final int minimum;
  final Color accent;
  final bool usesSpeed;
  final bool usesAi;

  static _GameConfig forKind(ArcadeGameKind kind) {
    return switch (kind) {
      ArcadeGameKind.syllableRain => const _GameConfig(
        gameId: 'syllable-rain',
        title: 'Silben-Regen',
        subtitle: 'Fange Wortteile und bilde Wörter.',
        startButton: 'Regen starten',
        emptyTitle: 'Noch keine passenden Wörter',
        emptySourceText:
            'Diese Wortquelle braucht Wörter mit mindestens vier Buchstaben ohne Leerzeichen.',
        emptyWorldText:
            'Diese Wortwelt braucht Wörter mit mindestens vier Buchstaben ohne Leerzeichen.',
        finishedTitle: 'Regen vorbei',
        finishedText: 'Du hast X Wörter gebildet. Noch offen: Y.',
        minimum: 1,
        accent: Color(0xFF5DDCFF),
        usesSpeed: true,
      ),
      ArcadeGameKind.oddWord => const _GameConfig(
        gameId: 'odd-word',
        title: 'Gegenwort',
        subtitle: 'Finde das Wort, das nicht dazugehört.',
        startButton: 'Starten',
        emptyTitle: 'Mehrere Gruppen nötig',
        emptySourceText:
            'Für Gegenwort werden Wörter und KI-generierte Wortgruppen benötigt.',
        emptyWorldText:
            'Für Gegenwort werden Wörter und KI-generierte Wortgruppen benötigt.',
        finishedTitle: 'Runde beendet',
        finishedText: 'Du hast X Außenseiter gefunden.',
        minimum: 1,
        accent: Color(0xFFFFD166),
        usesAi: true,
      ),
      ArcadeGameKind.audioCatch => const _GameConfig(
        gameId: 'audio-catch',
        title: 'Hör-Fang',
        subtitle: 'Tippe das Wort, das du hörst.',
        startButton: 'Fang starten',
        emptyTitle: 'Noch nicht genug Wörter',
        emptySourceText:
            'Diese Wortquelle braucht mindestens vier Wörter, um Hör-Fang zu spielen.',
        emptyWorldText:
            'Diese Wortwelt braucht mindestens vier Wörter, um Hör-Fang zu spielen.',
        finishedTitle: 'Fang beendet',
        finishedText: 'Du hast X Wörter getroffen.',
        minimum: 4,
        accent: Color(0xFF7DFFE3),
        usesSpeed: true,
      ),
      ArcadeGameKind.wordPath => const _GameConfig(
        gameId: 'word-path',
        title: 'Wortpfad',
        subtitle: 'Wische durch Buchstaben und bilde Wörter.',
        startButton: 'Pfad starten',
        emptyTitle: 'Noch keine passenden Wörter',
        emptySourceText:
            'Diese Wortquelle braucht kurze Wörter für das Buchstabenraster.',
        emptyWorldText:
            'Diese Wortwelt braucht kurze Wörter für das Buchstabenraster.',
        finishedTitle: 'Pfad beendet',
        finishedText: 'Du hast X Wörter gebildet.',
        minimum: 1,
        accent: Color(0xFF9DFF7D),
      ),
      ArcadeGameKind.wordSearch => const _GameConfig(
        gameId: 'word-search',
        title: 'Wortsuche',
        subtitle: 'Finde versteckte Wörter im Buchstabensalat.',
        startButton: 'Suche starten',
        emptyTitle: 'Noch keine passenden Wörter',
        emptySourceText:
            'Diese Wortquelle braucht Wörter für den Buchstabensalat.',
        emptyWorldText:
            'Diese Wortwelt braucht Wörter für den Buchstabensalat.',
        finishedTitle: 'Alle gefunden',
        finishedText: 'Du hast X Wörter im Buchstabensalat gefunden.',
        minimum: 1,
        accent: Color(0xFFFF7AB6),
      ),
      ArcadeGameKind.synonymRiddle => const _GameConfig(
        gameId: 'synonym-riddle',
        title: 'Synonym-Rätsel',
        subtitle: 'Erkenne das Wort aus ähnlichen Bedeutungen.',
        startButton: 'Rätsel starten',
        emptyTitle: 'Noch keine passenden Wörter',
        emptySourceText:
            'Diese Wortquelle braucht Wörter mit Übersetzung, damit die KI Hinweise erzeugen kann.',
        emptyWorldText:
            'Diese Wortwelt braucht Wörter mit Übersetzung, damit die KI Hinweise erzeugen kann.',
        finishedTitle: 'Rätsel beendet',
        finishedText: 'Du hast X Wörter erkannt.',
        minimum: 1,
        accent: Color(0xFFFF8A5B),
        usesAi: true,
      ),
    };
  }
}

class _ArcadeStartView extends StatelessWidget {
  const _ArcadeStartView({
    required this.config,
    required this.selectedSource,
    required this.categories,
    required this.availableIds,
    required this.wordsPerRound,
    required this.minWordsPerRound,
    required this.speed,
    required this.languagePair,
    required this.onSourceSelected,
    required this.onWordsPerRoundChanged,
    this.onSpeedChanged,
    this.onLanguagePairChanged,
    this.onStart,
  });

  final _GameConfig config;
  final GameWordSource selectedSource;
  final List<LocalCategory> categories;
  final List<String> availableIds;
  final int wordsPerRound;
  final int minWordsPerRound;
  final ArcadeSpeed speed;
  final WordGameLanguagePair languagePair;
  final ValueChanged<GameWordSource> onSourceSelected;
  final ValueChanged<int> onWordsPerRoundChanged;
  final ValueChanged<ArcadeSpeed>? onSpeedChanged;
  final ValueChanged<WordGameLanguagePair>? onLanguagePairChanged;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        _ArcadeCard(
          accent: config.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                config.title,
                style: const TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                config.subtitle,
                style: const TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (config.usesAi) ...[
                const SizedBox(height: 10),
                const _AiBadgeLine(),
                const SizedBox(height: 16),
                _AiLanguagePicker(
                  selected: languagePair,
                  accent: config.accent,
                  onSelected: onLanguagePairChanged!,
                ),
              ],
              const SizedBox(height: 18),
              GameWordSourcePicker(
                keyPrefix: config.gameId,
                selectedSource: selectedSource,
                categories: categories,
                availableIds: availableIds,
                wordsPerRound: wordsPerRound,
                minWordsPerRound: minWordsPerRound,
                onSourceSelected: onSourceSelected,
                onWordsPerRoundChanged: onWordsPerRoundChanged,
                accentColor: config.accent,
              ),
              if (onSpeedChanged != null) ...[
                const SizedBox(height: 16),
                _SpeedPicker(
                  selected: speed,
                  accent: config.accent,
                  onSelected: onSpeedChanged!,
                ),
              ],
              const SizedBox(height: 18),
              FilledButton(
                key: ValueKey('${config.gameId}-start-button'),
                onPressed: onStart,
                style: _primaryStyle(config.accent),
                child: Text(config.startButton),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArcadePlayView extends StatelessWidget {
  const _ArcadePlayView({
    required this.kind,
    required this.config,
    required this.item,
    required this.aiTask,
    required this.isAiLoading,
    required this.allItems,
    required this.currentIndex,
    required this.total,
    required this.score,
    required this.missed,
    required this.speed,
    required this.selectedParts,
    required this.selectedPathIndexes,
    required this.resolved,
    required this.feedback,
    required this.showInitialAudioInstruction,
    required this.onSpeak,
    required this.onPartTap,
    required this.onAnswer,
    required this.onPathTap,
    required this.onNext,
  });

  final ArcadeGameKind kind;
  final _GameConfig config;
  final ArcadeItem item;
  final ArcadeAiTask? aiTask;
  final bool isAiLoading;
  final List<ArcadeItem> allItems;
  final int currentIndex;
  final int total;
  final int score;
  final int missed;
  final ArcadeSpeed speed;
  final List<String> selectedParts;
  final List<int> selectedPathIndexes;
  final bool resolved;
  final String? feedback;
  final bool showInitialAudioInstruction;
  final VoidCallback onSpeak;
  final ValueChanged<String> onPartTap;
  final ValueChanged<String> onAnswer;
  final ValueChanged<int> onPathTap;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isAudioCatch = kind == ArcadeGameKind.audioCatch;
    final titleText = isAudioCatch
        ? (feedback ?? (showInitialAudioInstruction ? _taskTitle : ''))
        : _taskTitle;
    final titleColor = isAudioCatch && feedback != null
        ? _audioFeedbackColor(feedback!)
        : const Color(
            0xFFF4F8FF,
          ).withValues(alpha: isAudioCatch && titleText.isEmpty ? 0.42 : 1);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _ArcadeHeader(
          current: currentIndex + 1,
          total: total,
          score: score,
          missed: missed,
          accent: config.accent,
        ),
        const SizedBox(height: 16),
        _ArcadeCard(
          accent: config.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                titleText.isEmpty ? ' ' : titleText,
                key: const ValueKey('arcade-task-title'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              _buildTask(),
              if (feedback != null && !isAudioCatch) ...[
                const SizedBox(height: 14),
                _Feedback(
                  text: feedback!,
                  positive: const {
                    'Richtig',
                    'Gefangen',
                    'Wort gebildet!',
                  }.contains(feedback),
                ),
              ],
              if (resolved) ...[
                const SizedBox(height: 16),
                FilledButton(
                  key: ValueKey('${config.gameId}-next-button'),
                  onPressed: onNext,
                  style: _primaryStyle(config.accent),
                  child: Text(currentIndex >= total - 1 ? 'Fertig' : 'Weiter'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _audioFeedbackColor(String text) {
    return switch (text) {
      'Gefangen' => const Color(0xFF9DFF7D),
      'Falsch' => const Color(0xFFFF7D9D),
      'Verpasst' => const Color(0xFFFFD166),
      _ => const Color(0xFFF4F8FF),
    };
  }

  String get _taskTitle {
    return switch (kind) {
      ArcadeGameKind.syllableRain => 'Fange zwei passende Wortteile',
      ArcadeGameKind.oddWord => 'Finde das Wort, das nicht passt',
      ArcadeGameKind.audioCatch => 'Tippe das Wort, das du hörst',
      ArcadeGameKind.wordPath => 'Bilde das gesuchte Wort',
      ArcadeGameKind.wordSearch => 'Finde das versteckte Wort',
      ArcadeGameKind.synonymRiddle => 'Erkenne das Wort',
    };
  }

  Widget _buildTask() {
    if (config.usesAi) {
      if (isAiLoading) {
        return const _AiLoadingState();
      }
      if (aiTask == null) {
        return const _AiErrorState();
      }
    }
    return switch (kind) {
      ArcadeGameKind.syllableRain => _SyllableRainTask(
        item: item,
        allItems: allItems,
        selectedParts: selectedParts,
        resolved: resolved,
        onPartTap: onPartTap,
      ),
      ArcadeGameKind.oddWord => _OptionTask(
        options: aiTask!.options,
        prompt: aiTask!.prompt,
        resolved: resolved,
        onAnswer: onAnswer,
      ),
      ArcadeGameKind.audioCatch => _AudioCatchTask(
        item: item,
        allItems: allItems,
        speed: speed,
        resolved: resolved,
        onSpeak: onSpeak,
        onAnswer: onAnswer,
      ),
      ArcadeGameKind.wordPath => _WordPathTask(
        item: item,
        selectedIndexes: selectedPathIndexes,
        resolved: resolved,
        onTap: onPathTap,
      ),
      ArcadeGameKind.wordSearch => _WordSearchTask(
        item: item,
        selectedIndexes: selectedPathIndexes,
        resolved: resolved,
        onTap: onPathTap,
      ),
      ArcadeGameKind.synonymRiddle => _OptionTask(
        options: aiTask!.options,
        prompt: aiTask!.prompt,
        resolved: resolved,
        onAnswer: onAnswer,
      ),
    };
  }
}

List<String> _optionsWithCorrect(List<ArcadeItem> items, String correct) {
  final options = <String>[correct];
  for (final item in items) {
    if (options.length >= 4) break;
    if (item.term != correct) options.add(item.term);
  }
  return options;
}

List<String> _answerOptionsWithCorrect(
  List<ArcadeItem> items,
  ArcadeItem correct,
  WordGameLanguagePair languagePair,
) {
  final correctText = _arcadeAnswerText(correct, languagePair);
  final options = <String>[correctText];
  for (final item in items) {
    if (options.length >= 4) break;
    final text = _arcadeAnswerText(item, languagePair);
    if (item.id != correct.id && text.isNotEmpty && !options.contains(text)) {
      options.add(text);
    }
  }
  return options;
}

String _arcadeSourceText(ArcadeItem item, WordGameLanguagePair languagePair) {
  return languagePair.sourceCode == 'de' ? item.translation : item.term;
}

String _arcadeAnswerText(ArcadeItem item, WordGameLanguagePair languagePair) {
  return languagePair.answerCode == 'de' ? item.translation : item.term;
}

class _SyllableRainTask extends StatelessWidget {
  const _SyllableRainTask({
    required this.item,
    required this.allItems,
    required this.selectedParts,
    required this.resolved,
    required this.onPartTap,
  });

  final ArcadeItem item;
  final List<ArcadeItem> allItems;
  final List<String> selectedParts;
  final bool resolved;
  final ValueChanged<String> onPartTap;

  @override
  Widget build(BuildContext context) {
    final distractors = allItems
        .where(
          (candidate) => candidate.id != item.id && candidate.parts.length == 2,
        )
        .expand((candidate) => candidate.parts)
        .take(4);
    final parts = <String>[...item.parts, ...distractors].toList();
    return Column(
      children: [
        _HintBox(
          text: selectedParts.isEmpty ? '_ _' : selectedParts.join(' + '),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < parts.length; i += 1)
              _ChoiceChipButton(
                key: ValueKey('syllable-rain-part-$i'),
                text: parts[i],
                disabled: resolved,
                onTap: () => onPartTap(parts[i]),
              ),
          ],
        ),
      ],
    );
  }
}

class _AudioCatchTask extends StatefulWidget {
  const _AudioCatchTask({
    required this.item,
    required this.allItems,
    required this.speed,
    required this.resolved,
    required this.onSpeak,
    required this.onAnswer,
  });

  final ArcadeItem item;
  final List<ArcadeItem> allItems;
  final ArcadeSpeed speed;
  final bool resolved;
  final VoidCallback onSpeak;
  final ValueChanged<String> onAnswer;

  @override
  State<_AudioCatchTask> createState() => _AudioCatchTaskState();
}

class _AudioCatchTaskState extends State<_AudioCatchTask>
    with SingleTickerProviderStateMixin {
  static const double _fieldHeight = 430;
  static const double _fallDistance = _fieldHeight + 148;
  static const Duration _tickerDuration = Duration(days: 1);

  late final AnimationController _controller;
  final Random _random = Random();
  List<_AudioFallingWord> _fallingWords = const <_AudioFallingWord>[];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _tickerDuration)
      ..forward();
    _fallingWords = _initialFallingWords(Duration.zero);
  }

  @override
  void didUpdateWidget(_AudioCatchTask oldWidget) {
    super.didUpdateWidget(oldWidget);
    final elapsed = _elapsed;
    if (oldWidget.item.id != widget.item.id) {
      _replaceCurrentTarget(oldWidget.item.term, elapsed);
    } else if (_fallingWords.isEmpty ||
        oldWidget.allItems.map((item) => item.id).join('|') !=
            widget.allItems.map((item) => item.id).join('|')) {
      _fallingWords = _initialFallingWords(elapsed);
    }
  }

  Duration get _duration {
    return Duration(milliseconds: widget.speed.milliseconds * 4);
  }

  Duration get _elapsed => _controller.lastElapsedDuration ?? Duration.zero;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton.icon(
          key: const ValueKey('audio-catch-listen-button'),
          onPressed: widget.onSpeak,
          icon: const Icon(Icons.volume_up_rounded),
          label: const Text('Anhören'),
        ),
        const SizedBox(height: 16),
        Container(
          key: const ValueKey('audio-catch-field'),
          height: _fieldHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF050912).withValues(alpha: 0.74),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF5DDCFF).withValues(alpha: 0.32),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(21),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    for (var i = 0; i < _fallingWords.length; i += 1)
                      Positioned(
                        top: _fallingTop(_fallingWords[i], _elapsed),
                        left: _fallingWords[i].left,
                        child: _ChoiceChipButton(
                          key: ValueKey('arcade-answer-$i'),
                          text: _fallingWords[i].text,
                          disabled: widget.resolved,
                          onTap: () => widget.onAnswer(_fallingWords[i].text),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  List<_AudioFallingWord> _initialFallingWords(Duration elapsed) {
    final options = _optionsWithCorrect(widget.allItems, widget.item.term)
      ..shuffle(_random);
    final targetIndex = options.indexOf(widget.item.term);
    if (targetIndex > 0) {
      options
        ..removeAt(targetIndex)
        ..insert(0, widget.item.term);
    }
    return [
      for (var i = 0; i < options.length; i += 1)
        _AudioFallingWord(
          text: options[i],
          left: _laneLeft(i),
          spawnAt:
              elapsed - Duration(milliseconds: i == 0 ? 1250 : 450 + (i * 980)),
        ),
    ];
  }

  void _replaceCurrentTarget(String previousTarget, Duration elapsed) {
    if (_fallingWords.isEmpty) {
      _fallingWords = _initialFallingWords(elapsed);
      return;
    }

    final next = [..._fallingWords];
    var targetIndex = next.indexWhere((word) => word.text == previousTarget);
    targetIndex = targetIndex == -1 ? 0 : targetIndex;

    for (var i = 0; i < next.length; i += 1) {
      if (i != targetIndex && next[i].text == widget.item.term) {
        next[i] = next[i].copyWith(text: _replacementDistractor(next));
      }
    }

    next[targetIndex] = next[targetIndex].copyWith(
      text: widget.item.term,
      spawnAt: elapsed + const Duration(milliseconds: 120),
      left: _laneLeft((targetIndex + 1) % 4),
    );
    _fallingWords = next;
  }

  String _replacementDistractor(List<_AudioFallingWord> current) {
    final used = current.map((word) => word.text).toSet()
      ..add(widget.item.term);
    for (final item in widget.allItems) {
      if (!used.contains(item.term)) return item.term;
    }
    return current.firstWhere((word) => word.text != widget.item.term).text;
  }

  double _laneLeft(int index) {
    return switch (index % 4) {
      0 => 14,
      1 => 178,
      2 => 34,
      _ => 154,
    };
  }

  double _fallingTop(_AudioFallingWord word, Duration elapsed) {
    final travel = max(1, _duration.inMilliseconds);
    final age = elapsed.inMilliseconds - word.spawnAt.inMilliseconds;
    final wrappedAge = age < 0 ? age : age % travel;
    final phase = wrappedAge / travel;
    return -64 + phase * _fallDistance;
  }
}

class _AudioFallingWord {
  const _AudioFallingWord({
    required this.text,
    required this.left,
    required this.spawnAt,
  });

  final String text;
  final double left;
  final Duration spawnAt;

  _AudioFallingWord copyWith({String? text, double? left, Duration? spawnAt}) {
    return _AudioFallingWord(
      text: text ?? this.text,
      left: left ?? this.left,
      spawnAt: spawnAt ?? this.spawnAt,
    );
  }
}

class _OptionTask extends StatelessWidget {
  const _OptionTask({
    required this.options,
    required this.prompt,
    required this.resolved,
    required this.onAnswer,
  });

  final List<String> options;
  final String prompt;
  final bool resolved;
  final ValueChanged<String> onAnswer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HintBox(text: prompt),
        const SizedBox(height: 16),
        _OptionGrid(options: options, resolved: resolved, onAnswer: onAnswer),
      ],
    );
  }
}

class _AiBadgeLine extends StatelessWidget {
  const _AiBadgeLine();

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
              'KI-Spiel: nutzt Talvori KI für passende Aufgaben.',
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

class _AiLoadingState extends StatelessWidget {
  const _AiLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator(color: Color(0xFF7DFFE3))),
    );
  }
}

class _AiErrorState extends StatelessWidget {
  const _AiErrorState();

  @override
  Widget build(BuildContext context) {
    return const _HintBox(
      text: 'KI-Spiel momentan nicht verfügbar. Versuch es später noch einmal.',
    );
  }
}

class _AiLanguagePicker extends StatelessWidget {
  const _AiLanguagePicker({
    required this.selected,
    required this.accent,
    required this.onSelected,
  });

  final WordGameLanguagePair selected;
  final Color accent;
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
                  'arcade-language-${pair.sourceCode}-${pair.answerCode}',
                ),
                label: Text(pair.label),
                selected: selected == pair,
                selectedColor: accent,
                backgroundColor: const Color(0xFF0B1220),
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
                key: const ValueKey('arcade-language-swap'),
                tooltip: 'Richtung wechseln',
                onPressed: () => onSelected(swapped),
                style: IconButton.styleFrom(
                  backgroundColor: accent.withValues(alpha: 0.14),
                  foregroundColor: accent,
                  side: BorderSide(color: accent.withValues(alpha: 0.42)),
                ),
                icon: const Icon(Icons.swap_horiz_rounded),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Dieses KI-Spiel nutzt die gewählte Sprachkombination.',
          style: TextStyle(
            color: const Color(0xFFB8C7D9).withValues(alpha: 0.88),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _WordPathTask extends StatelessWidget {
  const _WordPathTask({
    required this.item,
    required this.selectedIndexes,
    required this.resolved,
    required this.onTap,
  });

  final ArcadeItem item;
  final List<int> selectedIndexes;
  final bool resolved;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final chars = item.term.split('');
    return Column(
      children: [
        _HintBox(text: item.translation.isEmpty ? item.term : item.translation),
        const SizedBox(height: 16),
        _LetterGrid(
          chars: chars,
          selectedIndexes: selectedIndexes,
          resolved: resolved,
          onTap: onTap,
        ),
      ],
    );
  }
}

class _WordSearchTask extends StatelessWidget {
  const _WordSearchTask({
    required this.item,
    required this.selectedIndexes,
    required this.resolved,
    required this.onTap,
  });

  final ArcadeItem item;
  final List<int> selectedIndexes;
  final bool resolved;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final chars = item.term.split('');
    return Column(
      children: [
        _HintBox(
          text:
              'Suche: ${item.translation.isEmpty ? item.term : item.translation}',
        ),
        const SizedBox(height: 16),
        _LetterGrid(
          chars: chars,
          selectedIndexes: selectedIndexes,
          resolved: resolved,
          onTap: onTap,
        ),
      ],
    );
  }
}

class _LetterGrid extends StatelessWidget {
  const _LetterGrid({
    required this.chars,
    required this.selectedIndexes,
    required this.resolved,
    required this.onTap,
  });

  final List<String> chars;
  final List<int> selectedIndexes;
  final bool resolved;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const ValueKey('arcade-letter-grid'),
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < chars.length; i += 1)
          _ChoiceChipButton(
            key: ValueKey('arcade-letter-$i'),
            text: chars[i],
            selected: selectedIndexes.contains(i),
            disabled: resolved,
            onTap: () => onTap(i),
          ),
      ],
    );
  }
}

class _OptionGrid extends StatelessWidget {
  const _OptionGrid({
    required this.options,
    required this.resolved,
    required this.onAnswer,
  });

  final List<String> options;
  final bool resolved;
  final ValueChanged<String> onAnswer;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < options.length; i += 1)
          _ChoiceChipButton(
            key: ValueKey('arcade-answer-$i'),
            text: options[i],
            disabled: resolved,
            onTap: () => onAnswer(options[i]),
          ),
      ],
    );
  }
}

class _ChoiceChipButton extends StatelessWidget {
  const _ChoiceChipButton({
    super.key,
    required this.text,
    required this.onTap,
    this.disabled = false,
    this.selected = false,
  });

  final String text;
  final VoidCallback onTap;
  final bool disabled;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: disabled ? null : onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 86, minHeight: 54),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF173224) : const Color(0xFF0B1220),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFF9DFF7D) : const Color(0xFF26354B),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFF4F8FF),
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SpeedPicker extends StatelessWidget {
  const _SpeedPicker({
    required this.selected,
    required this.accent,
    required this.onSelected,
  });

  final ArcadeSpeed selected;
  final Color accent;
  final ValueChanged<ArcadeSpeed> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Geschwindigkeit',
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
            for (final speed in ArcadeSpeed.values)
              ChoiceChip(
                key: ValueKey('arcade-speed-${speed.name}'),
                label: Text(speed.label),
                selected: selected == speed,
                selectedColor: accent,
                backgroundColor: const Color(0xFF0B1220),
                labelStyle: TextStyle(
                  color: selected == speed
                      ? const Color(0xFF041018)
                      : const Color(0xFFF4F8FF),
                  fontWeight: FontWeight.w900,
                ),
                onSelected: (_) => onSelected(speed),
              ),
          ],
        ),
      ],
    );
  }
}

class _ArcadeHeader extends StatelessWidget {
  const _ArcadeHeader({
    required this.current,
    required this.total,
    required this.score,
    required this.missed,
    required this.accent,
  });

  final int current;
  final int total;
  final int score;
  final int missed;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF26354B)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Runde $current / $total',
              style: const TextStyle(
                color: Color(0xFFF4F8FF),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Treffer: $score',
                style: TextStyle(color: accent, fontWeight: FontWeight.w900),
              ),
              if (missed > 0) const SizedBox(height: 2),
              if (missed > 0)
                Text(
                  'Verpasst: $missed',
                  style: const TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HintBox extends StatelessWidget {
  const _HintBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF050912),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF26354B)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFFF4F8FF),
          fontSize: 21,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.text, required this.positive});

  final String text;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final color = positive ? const Color(0xFF9DFF7D) : const Color(0xFFFFD166);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _ArcadeFinishedView extends StatelessWidget {
  const _ArcadeFinishedView({
    required this.config,
    required this.score,
    required this.total,
    required this.remaining,
    required this.missed,
    required this.onRestart,
    required this.onBack,
  });

  final _GameConfig config;
  final int score;
  final int total;
  final int remaining;
  final int missed;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final text = config.finishedText
        .replaceAll('X', '$score')
        .replaceAll('Y', '$remaining');
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 28),
      children: [
        _ArcadeCard(
          accent: config.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.emoji_events_rounded, color: config.accent, size: 46),
              const SizedBox(height: 14),
              Text(
                config.finishedTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB8C7D9),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Gespielt: $score / $total',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: config.accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Serie aktualisiert',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7DFFE3),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Taler verdient: +${score * 10 + 20}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFFD166),
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (config.gameId == 'audio-catch') ...[
                const SizedBox(height: 4),
                Text(
                  'Verpasst: $missed',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFD166),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onRestart,
                style: _primaryStyle(config.accent),
                child: const Text('Nochmal spielen'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: onBack,
                child: const Text('Zurück zu Wortspiele'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArcadeMessage extends StatelessWidget {
  const _ArcadeMessage({
    required this.title,
    required this.text,
    required this.buttonLabel,
    required this.onPressed,
    this.selectedSource,
    this.categories = const <LocalCategory>[],
    this.availableIds = const <String>[],
    this.wordsPerRound = 1,
    this.minWordsPerRound = 1,
    this.onSourceSelected,
    this.onWordsPerRoundChanged,
  });

  final String title;
  final String text;
  final String buttonLabel;
  final VoidCallback onPressed;
  final GameWordSource? selectedSource;
  final List<LocalCategory> categories;
  final List<String> availableIds;
  final int wordsPerRound;
  final int minWordsPerRound;
  final ValueChanged<GameWordSource>? onSourceSelected;
  final ValueChanged<int>? onWordsPerRoundChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 44, 20, 28),
      children: [
        _ArcadeCard(
          accent: const Color(0xFF5DDCFF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              if (selectedSource != null && onSourceSelected != null) ...[
                const SizedBox(height: 18),
                GameWordSourcePicker(
                  keyPrefix: 'arcade-empty',
                  selectedSource: selectedSource!,
                  categories: categories,
                  availableIds: availableIds,
                  wordsPerRound: wordsPerRound,
                  minWordsPerRound: minWordsPerRound,
                  onSourceSelected: onSourceSelected!,
                  onWordsPerRoundChanged: onWordsPerRoundChanged,
                ),
              ],
              const SizedBox(height: 18),
              OutlinedButton(onPressed: onPressed, child: Text(buttonLabel)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArcadeCard extends StatelessWidget {
  const _ArcadeCard({required this.child, required this.accent});

  final Widget child;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.62)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.14),
            blurRadius: 28,
            spreadRadius: -8,
          ),
        ],
      ),
      child: child,
    );
  }
}

ButtonStyle _primaryStyle(Color color) {
  return FilledButton.styleFrom(
    backgroundColor: color,
    foregroundColor: const Color(0xFF041018),
    padding: const EdgeInsets.symmetric(vertical: 15),
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}
