import 'package:flutter/material.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/features/home/application/word_game_progress_controller.dart';

class GameWordSource {
  const GameWordSource._({
    required this.key,
    required this.label,
    required this.source,
    this.categoryId,
  });

  factory GameWordSource.standard(LocalLearningSource source) {
    return GameWordSource._(
      key: 'source:${source.id}',
      label: source.label,
      source: source,
    );
  }

  factory GameWordSource.wordWorld(
    GameWordWorld world,
    List<LocalCategory> categories,
  ) {
    return GameWordSource._(
      key: 'world:${world.key}',
      label: 'Wortwelt: ${world.name}',
      source: LocalLearningSource.allWords,
      categoryId: world.resolveCategoryId(categories),
    );
  }

  factory GameWordSource.custom({
    required String key,
    required String label,
    required LocalLearningSource source,
    String? categoryId,
  }) {
    return GameWordSource._(
      key: key,
      label: label,
      source: source,
      categoryId: categoryId,
    );
  }

  final String key;
  final String label;
  final LocalLearningSource source;
  final String? categoryId;

  @override
  bool operator ==(Object other) {
    return other is GameWordSource && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}

const gameStandardWordSources = <LocalLearningSource>[
  LocalLearningSource.allWords,
  LocalLearningSource.myWords,
  LocalLearningSource.favorites,
  LocalLearningSource.myMix,
];

const gameWordWorldGroups = <GameWordWorldGroup>[
  GameWordWorldGroup('Alltag & Leben', [
    GameWordWorld(
      key: 'health_fitness',
      name: 'Health & Fitness',
      localCategoryId: 'seed-category-basics',
    ),
    GameWordWorld(key: 'home_living', name: 'Home & Living'),
    GameWordWorld(key: 'food_cooking', name: 'Food & Cooking'),
    GameWordWorld(key: 'style_fashion', name: 'Style & Fashion'),
    GameWordWorld(key: 'money_shopping', name: 'Money & Shopping'),
    GameWordWorld(key: 'productivity', name: 'Productivity'),
  ]),
  GameWordWorldGroup('Mensch & Gesellschaft', [
    GameWordWorld(key: 'personality', name: 'Personality'),
    GameWordWorld(key: 'feelings', name: 'Feelings'),
    GameWordWorld(key: 'relationships', name: 'Relationships'),
    GameWordWorld(key: 'thoughts', name: 'Thoughts'),
    GameWordWorld(key: 'law_politics', name: 'Law & Politics'),
    GameWordWorld(key: 'environment', name: 'Environment'),
  ]),
  GameWordWorldGroup('Wissen & Bildung', [
    GameWordWorld(key: 'school_studies', name: 'School & Studies'),
    GameWordWorld(key: 'science', name: 'Science'),
    GameWordWorld(key: 'space', name: 'Space'),
    GameWordWorld(key: 'nature', name: 'Nature'),
    GameWordWorld(key: 'animals', name: 'Animals'),
    GameWordWorld(key: 'tech_innovation', name: 'Tech & Innovation'),
  ]),
  GameWordWorldGroup('Medien & Freizeit', [
    GameWordWorld(key: 'media_news', name: 'Media & News'),
    GameWordWorld(key: 'sports', name: 'Sports'),
    GameWordWorld(
      key: 'travel',
      name: 'Travel',
      localCategoryId: 'seed-category-travel',
    ),
    GameWordWorld(key: 'gaming', name: 'Gaming'),
    GameWordWorld(key: 'transport', name: 'Transport'),
    GameWordWorld(key: 'music_entertainment', name: 'Music & Entertainment'),
    GameWordWorld(key: 'art_literature', name: 'Art & Literature'),
  ]),
  // Level-Filter A1-C2 wird später separat ergänzt.
  GameWordWorldGroup('Beruf', [
    GameWordWorld(key: 'work_careers', name: 'Work & Careers'),
  ]),
];

class GameWordWorldGroup {
  const GameWordWorldGroup(this.title, this.worlds);

  final String title;
  final List<GameWordWorld> worlds;
}

class GameWordWorld {
  const GameWordWorld({
    required this.key,
    required this.name,
    this.localCategoryId,
  });

  final String key;
  final String name;
  final String? localCategoryId;

  String resolveCategoryId(List<LocalCategory> categories) {
    final normalizedName = _normalizeSourceLabel(name);
    for (final category in categories) {
      if (_normalizeSourceLabel(category.name) == normalizedName) {
        return category.id;
      }
    }
    return localCategoryId ?? 'word-world-$key';
  }
}

class GameWordSourcePicker extends StatefulWidget {
  const GameWordSourcePicker({
    super.key,
    required this.keyPrefix,
    required this.selectedSource,
    required this.categories,
    required this.onSourceSelected,
    this.roundSize = WordGameRoundSize.ten,
    this.onRoundSizeSelected,
    this.wordsPerRound = 10,
    this.minWordsPerRound = 1,
    this.onWordsPerRoundChanged,
    this.availableIds,
    this.availableCount,
    this.playedCount,
    this.onResetProgress,
    this.accentColor = const Color(0xFF7DFFE3),
    this.secondaryAccentColor = const Color(0xFF5DDCFF),
  });

  final String keyPrefix;
  final GameWordSource selectedSource;
  final List<LocalCategory> categories;
  final ValueChanged<GameWordSource> onSourceSelected;
  final WordGameRoundSize roundSize;
  final ValueChanged<WordGameRoundSize>? onRoundSizeSelected;
  final int wordsPerRound;
  final int minWordsPerRound;
  final ValueChanged<int>? onWordsPerRoundChanged;
  final List<String>? availableIds;
  final int? availableCount;
  final int? playedCount;
  final VoidCallback? onResetProgress;
  final Color accentColor;
  final Color secondaryAccentColor;

  @override
  State<GameWordSourcePicker> createState() => _GameWordSourcePickerState();
}

class _GameWordSourcePickerState extends State<GameWordSourcePicker> {
  final SharedPreferencesWordGameProgressRepository _repository =
      const SharedPreferencesWordGameProgressRepository();
  bool _loadedInitialSettings = false;
  WordGameRoundSize? _persistedRoundSize;
  int? _persistedWordsPerRound;
  Set<String> _playedIds = const <String>{};
  String? _loadedPlayedSourceKey;

  @override
  void initState() {
    super.initState();
    _loadPersistedSettings();
  }

  @override
  void didUpdateWidget(GameWordSourcePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.keyPrefix != widget.keyPrefix ||
        oldWidget.categories != widget.categories) {
      _loadedInitialSettings = false;
      _loadPersistedSettings();
    }
    if (oldWidget.selectedSource.key != widget.selectedSource.key ||
        oldWidget.availableIds != widget.availableIds) {
      _loadPlayedIds();
    }
  }

  Future<void> _loadPersistedSettings() async {
    if (_loadedInitialSettings) return;
    _loadedInitialSettings = true;
    final sourceKey = await _repository.loadSourceKey(widget.keyPrefix);
    final roundSize = await _repository.loadRoundSize(widget.keyPrefix);
    final wordsPerRound = await _repository.loadWordsPerRound(widget.keyPrefix);
    if (!mounted) return;

    final source = _sourceFromKey(sourceKey);
    if (source != null && source != widget.selectedSource) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onSourceSelected(source);
      });
    }
    setState(() {
      _persistedRoundSize = roundSize;
      _persistedWordsPerRound = wordsPerRound;
    });
    if (widget.onRoundSizeSelected != null && roundSize != widget.roundSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onRoundSizeSelected!(roundSize);
      });
    }
    if (widget.onWordsPerRoundChanged != null &&
        wordsPerRound != widget.wordsPerRound) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onWordsPerRoundChanged!(wordsPerRound);
      });
    }
    await _loadPlayedIds();
  }

  Future<void> _loadPlayedIds() async {
    final availableIds = widget.availableIds;
    if (availableIds == null) return;
    final sourceKey = widget.selectedSource.key;
    if (_loadedPlayedSourceKey == sourceKey && _playedIds.isNotEmpty) return;
    final playedIds = await _repository.loadPlayedIds(
      widget.keyPrefix,
      sourceKey,
    );
    if (!mounted) return;
    setState(() {
      _loadedPlayedSourceKey = sourceKey;
      _playedIds = playedIds;
    });
  }

  GameWordSource? _sourceFromKey(String? key) {
    if (key == null || key.trim().isEmpty) return null;
    if (key.startsWith('source:')) {
      final sourceId = key.substring('source:'.length);
      final source = LocalLearningSource.fromId(sourceId);
      if (source != null) return GameWordSource.standard(source);
      return null;
    }
    if (key.startsWith('world:')) {
      final worldKey = key.substring('world:'.length);
      for (final group in gameWordWorldGroups) {
        for (final world in group.worlds) {
          if (world.key == worldKey) {
            return GameWordSource.wordWorld(world, widget.categories);
          }
        }
      }
    }
    return null;
  }

  Future<void> _selectSource(GameWordSource source) async {
    widget.onSourceSelected(source);
    await _repository.saveSourceKey(widget.keyPrefix, source.key);
  }

  Future<void> _selectRoundSize(WordGameRoundSize size) async {
    setState(() => _persistedRoundSize = size);
    widget.onRoundSizeSelected?.call(size);
    await _repository.saveRoundSize(widget.keyPrefix, size);
  }

  Future<void> _selectWordsPerRound(int value) async {
    final effectiveValue = _effectiveWordsPerRound(value);
    setState(() => _persistedWordsPerRound = effectiveValue);
    widget.onWordsPerRoundChanged?.call(effectiveValue);
    await _repository.saveWordsPerRound(widget.keyPrefix, effectiveValue);
  }

  int _effectiveWordsPerRound([int? requested]) {
    final availableIds = widget.availableIds;
    final availableCount = widget.availableCount ?? availableIds?.length ?? 0;
    return clampWordsPerRound(
      requested: requested ?? _persistedWordsPerRound ?? widget.wordsPerRound,
      minimum: widget.minWordsPerRound,
      available: availableCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedRoundSize = widget.onRoundSizeSelected == null
        ? (_persistedRoundSize ?? widget.roundSize)
        : widget.roundSize;
    final availableIds = widget.availableIds;
    final availableCount = widget.availableCount ?? availableIds?.length;
    final playedCount =
        widget.playedCount ??
        availableIds?.where(_playedIds.contains).toSet().length;
    final effectiveWordsPerRound = _effectiveWordsPerRound();
    return Container(
      key: ValueKey('${widget.keyPrefix}-source-picker'),
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
            widget.selectedSource.label,
            key: ValueKey('${widget.keyPrefix}-selected-source-label'),
            style: const TextStyle(
              color: Color(0xFFF4F8FF),
              fontSize: 18,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _PickerActionButton(
            key: ValueKey('${widget.keyPrefix}-change-source-button'),
            icon: Icons.folder_copy_rounded,
            title: 'Wortquelle ändern',
            subtitle: 'Alle Wörter, Meine Wörter, Favoriten oder Mein Mix',
            accentColor: widget.accentColor,
            onTap: () => _showSourceSheet(context),
          ),
          const SizedBox(height: 10),
          _PickerActionButton(
            key: ValueKey('${widget.keyPrefix}-select-world-button'),
            icon: Icons.public_rounded,
            title: 'Wortwelt auswählen',
            subtitle: 'Spiele mit einer festen Talvori-Wortwelt',
            accentColor: widget.accentColor,
            onTap: () => _showWordWorldSheet(context),
          ),
          if (widget.onRoundSizeSelected != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Rundengröße',
              style: TextStyle(
                color: Color(0xFFB8C7D9),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final size in WordGameRoundSize.values)
                  _RoundSizeChip(
                    key: ValueKey(
                      '${widget.keyPrefix}-round-size-${size.name}',
                    ),
                    label: size.label,
                    selected: selectedRoundSize == size,
                    accentColor: widget.accentColor,
                    onTap: () => _selectRoundSize(size),
                  ),
              ],
            ),
          ],
          if (widget.onWordsPerRoundChanged != null) ...[
            const SizedBox(height: 16),
            _WordsPerRoundControl(
              keyPrefix: widget.keyPrefix,
              value: effectiveWordsPerRound,
              minValue: widget.minWordsPerRound,
              maxValue: availableCount ?? effectiveWordsPerRound,
              accentColor: widget.accentColor,
              onChanged: _selectWordsPerRound,
            ),
          ],
          if (availableCount != null && playedCount != null) ...[
            const SizedBox(height: 8),
            _ProgressSummary(
              playedCount: playedCount,
              availableCount: availableCount,
              wordsPerRound: effectiveWordsPerRound,
              accentColor: widget.secondaryAccentColor,
            ),
          ],
          if (availableIds != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              key: ValueKey('${widget.keyPrefix}-reset-progress-button'),
              onPressed: () => _showResetProgressDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFF4F8FF),
                side: BorderSide(color: widget.secondaryAccentColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
              icon: Icon(
                Icons.restart_alt_rounded,
                color: widget.secondaryAccentColor,
              ),
              label: const Text('Fortschritt zurücksetzen'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showSourceSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _GameWordSourceSheetFrame(
          title: 'Wortquelle ändern',
          maxHeightFactor: 0.48,
          accentColor: widget.secondaryAccentColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final source in gameStandardWordSources)
                _SheetOption(
                  key: ValueKey('${widget.keyPrefix}-source-${source.id}'),
                  title: source.label,
                  selected:
                      widget.selectedSource == GameWordSource.standard(source),
                  accentColor: widget.accentColor,
                  onTap: () {
                    Navigator.of(context).pop();
                    _selectSource(GameWordSource.standard(source));
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
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _GameWordSourceSheetFrame(
          title: 'Wortwelt auswählen',
          maxHeightFactor: 0.68,
          accentColor: widget.secondaryAccentColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final group in gameWordWorldGroups) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
                  child: Text(
                    group.title,
                    style: TextStyle(
                      color: widget.secondaryAccentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                for (final world in group.worlds)
                  Builder(
                    builder: (context) {
                      final source = GameWordSource.wordWorld(
                        world,
                        widget.categories,
                      );
                      return _SheetOption(
                        key: ValueKey(
                          '${widget.keyPrefix}-word-world-${world.key}',
                        ),
                        title: world.name,
                        selected: widget.selectedSource == source,
                        accentColor: widget.accentColor,
                        onTap: () {
                          Navigator.of(context).pop();
                          _selectSource(source);
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

  Future<void> _showResetProgressDialog(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _GameWordSourceSheetFrame(
          title: 'Fortschritt zurücksetzen?',
          maxHeightFactor: 0.46,
          accentColor: widget.secondaryAccentColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Dadurch wird nur der Wortspiel-Fortschritt für diese Auswahl zurückgesetzt. Dein Lernfortschritt bleibt unverändert.',
                style: TextStyle(
                  color: Color(0xFFB8C7D9),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Abbrechen'),
              ),
              const SizedBox(height: 10),
              FilledButton(
                key: ValueKey('${widget.keyPrefix}-confirm-reset-progress'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetProgress();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: widget.secondaryAccentColor,
                  foregroundColor: const Color(0xFF041018),
                ),
                child: const Text('Zurücksetzen'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _resetProgress() async {
    await _repository.resetProgress(
      widget.keyPrefix,
      widget.selectedSource.key,
    );
    if (!mounted) return;
    setState(() => _playedIds = const <String>{});
    widget.onResetProgress?.call();
  }
}

class _RoundSizeChip extends StatelessWidget {
  const _RoundSizeChip({
    super.key,
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF041018) : const Color(0xFFF4F8FF),
        fontWeight: FontWeight.w900,
      ),
      selectedColor: accentColor,
      backgroundColor: const Color(0xFF0B1220),
      side: BorderSide(color: selected ? accentColor : const Color(0xFF26354B)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}

class _WordsPerRoundControl extends StatelessWidget {
  const _WordsPerRoundControl({
    required this.keyPrefix,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.accentColor,
    required this.onChanged,
  });

  final String keyPrefix;
  final int value;
  final int minValue;
  final int maxValue;
  final Color accentColor;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final effectiveMax = maxValue < minValue ? minValue : maxValue;
    final canDecrease = value > minValue;
    final canIncrease = value < effectiveMax;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF26354B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Wörter pro Runde',
                  style: TextStyle(
                    color: Color(0xFFB8C7D9),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '$value ${value == 1 ? 'Wort' : 'Wörter'}',
                key: ValueKey('$keyPrefix-words-per-round-label'),
                style: const TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _RoundStepButton(
                key: ValueKey('$keyPrefix-words-per-round-minus'),
                icon: Icons.remove_rounded,
                enabled: canDecrease,
                accentColor: accentColor,
                onTap: () => onChanged(value - 1),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      for (final preset in const [10, 20, 40])
                        _RoundSizeChip(
                          key: ValueKey('$keyPrefix-words-preset-$preset'),
                          label: '$preset',
                          selected: value == preset,
                          accentColor: accentColor,
                          onTap: () => onChanged(preset),
                        ),
                      _RoundSizeChip(
                        key: ValueKey('$keyPrefix-words-preset-all'),
                        label: 'Alle',
                        selected: value == effectiveMax,
                        accentColor: accentColor,
                        onTap: () => onChanged(effectiveMax),
                      ),
                    ],
                  ),
                ),
              ),
              _RoundStepButton(
                key: ValueKey('$keyPrefix-words-per-round-plus'),
                icon: Icons.add_rounded,
                enabled: canIncrease,
                accentColor: accentColor,
                onTap: () => onChanged(value + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundStepButton extends StatelessWidget {
  const _RoundStepButton({
    super.key,
    required this.icon,
    required this.enabled,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: enabled ? onTap : null,
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFF050912),
        disabledBackgroundColor: const Color(0xFF050912),
        foregroundColor: accentColor,
        disabledForegroundColor: const Color(0xFF536175),
        side: BorderSide(
          color: enabled ? accentColor : const Color(0xFF26354B),
        ),
        minimumSize: const Size(44, 44),
      ),
      icon: Icon(icon),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({
    required this.playedCount,
    required this.availableCount,
    required this.wordsPerRound,
    required this.accentColor,
  });

  final int playedCount;
  final int availableCount;
  final int wordsPerRound;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF26354B)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_graph_rounded, color: accentColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gespielt: $playedCount / $availableCount Wörter',
                  key: const ValueKey('word-game-progress-summary'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF4F8FF),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Diese Runde: $wordsPerRound ${wordsPerRound == 1 ? 'Wort' : 'Wörter'}',
                  key: const ValueKey('word-game-current-round-summary'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFB8C7D9),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerActionButton extends StatelessWidget {
  const _PickerActionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(16, 13, 13, 13),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF26354B)),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 2, right: 12),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
              Icon(Icons.chevron_right_rounded, color: accentColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameWordSourceSheetFrame extends StatelessWidget {
  const _GameWordSourceSheetFrame({
    required this.title,
    required this.maxHeightFactor,
    required this.accentColor,
    required this.child,
  });

  final String title;
  final double maxHeightFactor;
  final Color accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * maxHeightFactor;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF050912),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: accentColor),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.14),
                  blurRadius: 32,
                  spreadRadius: -6,
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF26354B),
                        borderRadius: BorderRadius.circular(999),
                      ),
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
    required this.accentColor,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? accentColor : const Color(0xFF26354B);
    final fillColor = selected
        ? accentColor.withValues(alpha: 0.14)
        : const Color(0xFF0B1220);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      color: selected ? accentColor : const Color(0xFFF4F8FF),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: accentColor,
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

String _normalizeSourceLabel(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
