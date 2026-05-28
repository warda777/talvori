import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CategoryDesignArea { category, learnMode }

enum CategoryDesignGlowStrength { off, subtle, normal, strong }

enum CategoryDesignPulseStrength { off, subtle, normal, strong }

enum CategoryDesignElement {
  categoryBackground('Kategorie-Hintergrund', CategoryDesignArea.category),
  categoryHeader('Kategorie-Header', CategoryDesignArea.category),
  categoryHeaderFill('Header-Innenfläche', CategoryDesignArea.category),
  categoryHeaderText('Header-Schrift', CategoryDesignArea.category),
  categoryHeaderReflection('Header-Spiegelung', CategoryDesignArea.category),
  categoryWheelFade('Wheel-Überblender', CategoryDesignArea.category),
  vocabsTile('Vocabs-Kachel', CategoryDesignArea.category),
  vocabsTileFill('Vocabs-Innenfläche', CategoryDesignArea.category),
  vocabsTileText('Vocabs-Schrift', CategoryDesignArea.category),
  vocabsTileIcon('Vocabs-Icon', CategoryDesignArea.category),
  vocabsCounterBadge('Vocabs-Zähler', CategoryDesignArea.category),
  vocabsCounterFill('Zähler-Innenfläche', CategoryDesignArea.category),
  vocabsCounterText('Zähler-Zahl', CategoryDesignArea.category),
  addButton('Add-Button', CategoryDesignArea.category),
  addButtonFill('Add-Innenfläche', CategoryDesignArea.category),
  addButtonIcon('Add-Icon', CategoryDesignArea.category),
  settingsButton('Settings-Button', CategoryDesignArea.category),
  settingsButtonFill('Settings-Innenfläche', CategoryDesignArea.category),
  settingsButtonIcon('Settings-Icon', CategoryDesignArea.category),
  repeatAllStagesButton('Alle-Stufen-Button', CategoryDesignArea.category),
  repeatAllStagesButtonFill(
    'Alle-Stufen-Innenfläche',
    CategoryDesignArea.category,
  ),
  repeatAllStagesButtonText('Alle-Stufen-Schrift', CategoryDesignArea.category),
  repeatSingleStageButton('Einzelstufe-Button', CategoryDesignArea.category),
  repeatSingleStageButtonFill(
    'Einzelstufe-Innenfläche',
    CategoryDesignArea.category,
  ),
  repeatSingleStageButtonText(
    'Einzelstufe-Schrift',
    CategoryDesignArea.category,
  ),
  sectionTitleRepeat('Titel Wiederholung', CategoryDesignArea.category),
  sectionTitleStages('Titel Merkstufen', CategoryDesignArea.category),
  sectionTitleMode('Titel Lernmodus', CategoryDesignArea.category),
  stageSwitches('Merkstufen', CategoryDesignArea.category),
  stageSwitch0('Merkstufe 0', CategoryDesignArea.category),
  stageSwitch0Inner('Merkstufe 0 Innenfläche', CategoryDesignArea.category),
  stageSwitch0Number('Merkstufe 0 Zahl', CategoryDesignArea.category),
  stageSwitch1('Merkstufe 1', CategoryDesignArea.category),
  stageSwitch1Inner('Merkstufe 1 Innenfläche', CategoryDesignArea.category),
  stageSwitch1Number('Merkstufe 1 Zahl', CategoryDesignArea.category),
  stageSwitch2('Merkstufe 2', CategoryDesignArea.category),
  stageSwitch2Inner('Merkstufe 2 Innenfläche', CategoryDesignArea.category),
  stageSwitch2Number('Merkstufe 2 Zahl', CategoryDesignArea.category),
  stageSwitch3('Merkstufe 3', CategoryDesignArea.category),
  stageSwitch3Inner('Merkstufe 3 Innenfläche', CategoryDesignArea.category),
  stageSwitch3Number('Merkstufe 3 Zahl', CategoryDesignArea.category),
  stageSwitch4('Merkstufe 4', CategoryDesignArea.category),
  stageSwitch4Inner('Merkstufe 4 Innenfläche', CategoryDesignArea.category),
  stageSwitch4Number('Merkstufe 4 Zahl', CategoryDesignArea.category),
  stageSwitch5('Merkstufe 5', CategoryDesignArea.category),
  stageSwitch5Inner('Merkstufe 5 Innenfläche', CategoryDesignArea.category),
  stageSwitch5Number('Merkstufe 5 Zahl', CategoryDesignArea.category),
  learningModeTimeButton('Zeitplan-Button', CategoryDesignArea.category),
  learningModeTimeButtonFill(
    'Zeitplan-Innenfläche',
    CategoryDesignArea.category,
  ),
  learningModeTimeButtonText('Zeitplan-Schrift', CategoryDesignArea.category),
  learningModeUnlimitedButton('Limitlos-Button', CategoryDesignArea.category),
  learningModeUnlimitedButtonFill(
    'Limitlos-Innenfläche',
    CategoryDesignArea.category,
  ),
  learningModeUnlimitedButtonText(
    'Limitlos-Schrift',
    CategoryDesignArea.category,
  ),
  learningModeCombinedButton('Kombiniert-Button', CategoryDesignArea.category),
  learningModeCombinedButtonFill(
    'Kombiniert-Innenfläche',
    CategoryDesignArea.category,
  ),
  learningModeCombinedButtonText(
    'Kombiniert-Schrift',
    CategoryDesignArea.category,
  ),
  startButton('Start-Button', CategoryDesignArea.category),
  startButtonFill('Start-Innenfläche', CategoryDesignArea.category),
  startButtonText('Start-Schrift', CategoryDesignArea.category),
  resetButton('Reset-Button', CategoryDesignArea.category),
  resetButtonFill('Reset-Innenfläche', CategoryDesignArea.category),
  resetButtonIcon('Reset-Icon', CategoryDesignArea.category),
  learnBackground('Lernmodus-Hintergrund', CategoryDesignArea.learnMode),
  learnHeader('Lernmodus-Header', CategoryDesignArea.learnMode),
  learnHeaderFill('Lernmodus-Header-Innenfläche', CategoryDesignArea.learnMode),
  learnHeaderText('Lernmodus-Header-Schrift', CategoryDesignArea.learnMode),
  learnCard('Lernkarte', CategoryDesignArea.learnMode),
  learnCardBorder('Kartenrand', CategoryDesignArea.learnMode),
  learnCardGlow('Karten-Glow', CategoryDesignArea.learnMode),
  learnWordText('Worttext', CategoryDesignArea.learnMode),
  audioButton('Audio-Button', CategoryDesignArea.learnMode),
  audioButtonFill('Audio-Innenfläche', CategoryDesignArea.learnMode),
  audioButtonIcon('Audio-Icon', CategoryDesignArea.learnMode),
  levelBadge('Level-Badge', CategoryDesignArea.learnMode),
  levelBadgeFill('A1-Badge-Innenfläche', CategoryDesignArea.learnMode),
  levelBadgeText('A1-Badge-Schrift', CategoryDesignArea.learnMode),
  favoriteButton('Favorit-Button', CategoryDesignArea.learnMode),
  favoriteButtonFill('Favorit-Innenfläche', CategoryDesignArea.learnMode),
  favoriteButtonIcon('Favorit-Icon', CategoryDesignArea.learnMode),
  knownButton('Kenne-ich-Button', CategoryDesignArea.learnMode),
  knownButtonFill('Kenne-ich-Innenfläche', CategoryDesignArea.learnMode),
  knownButtonIcon('Kenne-ich-Icon', CategoryDesignArea.learnMode),
  learnStages('Lernstufen', CategoryDesignArea.learnMode),
  learnStageSwitch0('Lernstufe 0', CategoryDesignArea.learnMode),
  learnStageSwitch0Inner(
    'Lernstufe 0 Innenfläche',
    CategoryDesignArea.learnMode,
  ),
  learnStageSwitch0Number('Lernstufe 0 Zahl', CategoryDesignArea.learnMode),
  learnStageSwitch1('Lernstufe 1', CategoryDesignArea.learnMode),
  learnStageSwitch1Inner(
    'Lernstufe 1 Innenfläche',
    CategoryDesignArea.learnMode,
  ),
  learnStageSwitch1Number('Lernstufe 1 Zahl', CategoryDesignArea.learnMode),
  learnStageSwitch2('Lernstufe 2', CategoryDesignArea.learnMode),
  learnStageSwitch2Inner(
    'Lernstufe 2 Innenfläche',
    CategoryDesignArea.learnMode,
  ),
  learnStageSwitch2Number('Lernstufe 2 Zahl', CategoryDesignArea.learnMode),
  learnStageSwitch3('Lernstufe 3', CategoryDesignArea.learnMode),
  learnStageSwitch3Inner(
    'Lernstufe 3 Innenfläche',
    CategoryDesignArea.learnMode,
  ),
  learnStageSwitch3Number('Lernstufe 3 Zahl', CategoryDesignArea.learnMode),
  learnStageSwitch4('Lernstufe 4', CategoryDesignArea.learnMode),
  learnStageSwitch4Inner(
    'Lernstufe 4 Innenfläche',
    CategoryDesignArea.learnMode,
  ),
  learnStageSwitch4Number('Lernstufe 4 Zahl', CategoryDesignArea.learnMode),
  learnStageSwitch5('Lernstufe 5', CategoryDesignArea.learnMode),
  learnStageSwitch5Inner(
    'Lernstufe 5 Innenfläche',
    CategoryDesignArea.learnMode,
  ),
  learnStageSwitch5Number('Lernstufe 5 Zahl', CategoryDesignArea.learnMode),
  playButton('Play-Button', CategoryDesignArea.learnMode),
  learnPlayArea('Play/Reset-Bereich', CategoryDesignArea.learnMode);

  const CategoryDesignElement(this.label, this.area);

  final String label;
  final CategoryDesignArea area;
}

class CategoryDesignElementStyle {
  const CategoryDesignElementStyle({
    this.color,
    this.glow = CategoryDesignGlowStrength.normal,
    this.pulse = CategoryDesignPulseStrength.off,
  });

  final Color? color;
  final CategoryDesignGlowStrength glow;
  final CategoryDesignPulseStrength pulse;

  CategoryDesignElementStyle copyWith({
    Color? color,
    bool clearColor = false,
    CategoryDesignGlowStrength? glow,
    CategoryDesignPulseStrength? pulse,
  }) {
    return CategoryDesignElementStyle(
      color: clearColor ? null : (color ?? this.color),
      glow: glow ?? this.glow,
      pulse: pulse ?? this.pulse,
    );
  }

  bool get isDefault =>
      color == null &&
      glow == CategoryDesignGlowStrength.normal &&
      pulse == CategoryDesignPulseStrength.off;

  Map<String, Object?> toJson() => {
    if (color != null) 'color': color!.toARGB32(),
    'glow': glow.name,
    'pulse': pulse.name,
  };

  factory CategoryDesignElementStyle.fromJson(Map<String, Object?> json) {
    final colorValue = json['color'];
    return CategoryDesignElementStyle(
      color: colorValue is int ? Color(colorValue) : null,
      glow: CategoryDesignGlowStrength.values.byName(
        json['glow'] as String? ?? CategoryDesignGlowStrength.normal.name,
      ),
      pulse: CategoryDesignPulseStrength.values.byName(
        json['pulse'] as String? ?? CategoryDesignPulseStrength.off.name,
      ),
    );
  }
}

class CategoryDesignPreferences {
  const CategoryDesignPreferences({this.overrides = const {}});

  final Map<CategoryDesignElement, CategoryDesignElementStyle> overrides;

  CategoryDesignElementStyle styleFor(CategoryDesignElement element) =>
      overrides[element] ?? const CategoryDesignElementStyle();

  CategoryDesignPreferences copyWithOverrides(
    Map<CategoryDesignElement, CategoryDesignElementStyle> next,
  ) {
    return CategoryDesignPreferences(overrides: Map.unmodifiable(next));
  }

  Map<String, Object?> toJson() => {
    'version': 1,
    'overrides': {
      for (final entry in overrides.entries)
        if (!entry.value.isDefault) entry.key.name: entry.value.toJson(),
    },
  };

  factory CategoryDesignPreferences.fromJson(Map<String, Object?> json) {
    final rawOverrides = json['overrides'];
    if (rawOverrides is! Map) return const CategoryDesignPreferences();
    final overrides = <CategoryDesignElement, CategoryDesignElementStyle>{};
    for (final entry in rawOverrides.entries) {
      if (entry.key is! String || entry.value is! Map) continue;
      final element = _tryParseElement(entry.key as String);
      if (element == null) continue;
      overrides[element] = CategoryDesignElementStyle.fromJson(
        Map<String, Object?>.from(entry.value as Map),
      );
    }
    return CategoryDesignPreferences(overrides: Map.unmodifiable(overrides));
  }

  static CategoryDesignElement? _tryParseElement(String name) {
    for (final element in CategoryDesignElement.values) {
      if (element.name == name) return element;
    }
    return null;
  }
}

class CategoryDesignDefaults {
  const CategoryDesignDefaults._();

  static Color accentFor(CategoryDesignElement element) {
    return switch (element) {
      CategoryDesignElement.categoryHeader => const Color(0xFFF5BFCB),
      CategoryDesignElement.categoryHeaderFill => const Color(0xFF2D2C2C),
      CategoryDesignElement.categoryHeaderText => Colors.white,
      CategoryDesignElement.categoryHeaderReflection => const Color(0xFFF5BFCB),
      CategoryDesignElement.categoryWheelFade => const Color(0xFF050508),
      CategoryDesignElement.vocabsTile => const Color(0xFFB8C8FF),
      CategoryDesignElement.vocabsTileFill => const Color(0xFF111216),
      CategoryDesignElement.vocabsTileText => Colors.white,
      CategoryDesignElement.vocabsTileIcon => Colors.white,
      CategoryDesignElement.vocabsCounterBadge => const Color(0xFFB8C8FF),
      CategoryDesignElement.vocabsCounterFill => const Color(0xFF0B0B0D),
      CategoryDesignElement.vocabsCounterText => Colors.white,
      CategoryDesignElement.addButton => const Color(0xFFB8C8FF),
      CategoryDesignElement.addButtonFill => const Color(0xFF101114),
      CategoryDesignElement.addButtonIcon => Colors.white,
      CategoryDesignElement.settingsButton => const Color(0xFFB8C8FF),
      CategoryDesignElement.settingsButtonFill => const Color(0xFF101114),
      CategoryDesignElement.settingsButtonIcon => Colors.white,
      CategoryDesignElement.stageSwitches => const Color(0xFF9D57FF),
      CategoryDesignElement.stageSwitch0 => const Color(0xFF8DB8FF),
      CategoryDesignElement.stageSwitch0Inner => const Color(0xFF050509),
      CategoryDesignElement.stageSwitch0Number => Colors.white,
      CategoryDesignElement.stageSwitch1 => const Color(0xFFFF6078),
      CategoryDesignElement.stageSwitch1Inner => const Color(0xFF050509),
      CategoryDesignElement.stageSwitch1Number => Colors.white,
      CategoryDesignElement.stageSwitch2 => const Color(0xFFE9EFFA),
      CategoryDesignElement.stageSwitch2Inner => const Color(0xFF050509),
      CategoryDesignElement.stageSwitch2Number => Colors.white,
      CategoryDesignElement.stageSwitch3 => const Color(0xFFE9EFFA),
      CategoryDesignElement.stageSwitch3Inner => const Color(0xFF050509),
      CategoryDesignElement.stageSwitch3Number => Colors.white,
      CategoryDesignElement.stageSwitch4 => const Color(0xFFE9EFFA),
      CategoryDesignElement.stageSwitch4Inner => const Color(0xFF050509),
      CategoryDesignElement.stageSwitch4Number => Colors.white,
      CategoryDesignElement.stageSwitch5 => const Color(0xFFE9EFFA),
      CategoryDesignElement.stageSwitch5Inner => const Color(0xFF050509),
      CategoryDesignElement.stageSwitch5Number => Colors.white,
      CategoryDesignElement.repeatAllStagesButton => const Color(0xFF9D57FF),
      CategoryDesignElement.repeatAllStagesButtonFill => const Color(
        0xFF121318,
      ),
      CategoryDesignElement.repeatAllStagesButtonText => Colors.white,
      CategoryDesignElement.repeatSingleStageButton => const Color(0xFF9D57FF),
      CategoryDesignElement.repeatSingleStageButtonFill => const Color(
        0xFF121318,
      ),
      CategoryDesignElement.repeatSingleStageButtonText => Colors.white,
      CategoryDesignElement.learningModeTimeButton => const Color(0xFFF5BFCB),
      CategoryDesignElement.learningModeTimeButtonFill => const Color(
        0xFF121318,
      ),
      CategoryDesignElement.learningModeTimeButtonText => Colors.white,
      CategoryDesignElement.learningModeUnlimitedButton => const Color(
        0xFF9D57FF,
      ),
      CategoryDesignElement.learningModeUnlimitedButtonFill => const Color(
        0xFF121318,
      ),
      CategoryDesignElement.learningModeUnlimitedButtonText => Colors.white,
      CategoryDesignElement.learningModeCombinedButton => const Color(
        0xFF9D57FF,
      ),
      CategoryDesignElement.learningModeCombinedButtonFill => const Color(
        0xFF121318,
      ),
      CategoryDesignElement.learningModeCombinedButtonText => Colors.white,
      CategoryDesignElement.sectionTitleRepeat => const Color(0xFFE4DFFF),
      CategoryDesignElement.sectionTitleStages => const Color(0xFFE4DFFF),
      CategoryDesignElement.sectionTitleMode => const Color(0xFFE4DFFF),
      CategoryDesignElement.startButton => const Color(0xFF9CFFE9),
      CategoryDesignElement.startButtonFill => const Color(0xFF121318),
      CategoryDesignElement.startButtonText => Colors.white,
      CategoryDesignElement.resetButton => const Color(0xFFF5BFCB),
      CategoryDesignElement.resetButtonFill => const Color(0xFF121318),
      CategoryDesignElement.resetButtonIcon => Colors.white,
      CategoryDesignElement.learnBackground => const Color(0xFF6F5795),
      CategoryDesignElement.learnHeader => const Color(0xFFF5BFCB),
      CategoryDesignElement.learnHeaderFill => const Color(0xFF2D2C2C),
      CategoryDesignElement.learnHeaderText => Colors.white,
      CategoryDesignElement.learnCard => const Color(0xFF262626),
      CategoryDesignElement.learnCardBorder => const Color(0xFF815DD3),
      CategoryDesignElement.learnCardGlow => const Color(0xFFB16CFF),
      CategoryDesignElement.learnWordText => Colors.white,
      CategoryDesignElement.audioButton => const Color(0xFF80E7FF),
      CategoryDesignElement.audioButtonFill => const Color(0xFF07101A),
      CategoryDesignElement.audioButtonIcon => const Color(0xFFC8FFF4),
      CategoryDesignElement.levelBadge => const Color(0xFFE8483F),
      CategoryDesignElement.levelBadgeFill => const Color(0xFFE8483F),
      CategoryDesignElement.levelBadgeText => Colors.white,
      CategoryDesignElement.favoriteButton => const Color(0xFFFF8BC8),
      CategoryDesignElement.favoriteButtonFill => const Color(0xFF07101A),
      CategoryDesignElement.favoriteButtonIcon => const Color(0xFFFF8BC8),
      CategoryDesignElement.knownButton => const Color(0xFFB7FFF2),
      CategoryDesignElement.knownButtonFill => const Color(0xFF07101A),
      CategoryDesignElement.knownButtonIcon => const Color(0xFFB7FFF2),
      CategoryDesignElement.learnStages => const Color(0xFF9D57FF),
      CategoryDesignElement.learnStageSwitch0 => const Color(0xFF8DB8FF),
      CategoryDesignElement.learnStageSwitch0Inner => const Color(0xFF050509),
      CategoryDesignElement.learnStageSwitch0Number => Colors.white,
      CategoryDesignElement.learnStageSwitch1 => const Color(0xFF8DB8FF),
      CategoryDesignElement.learnStageSwitch1Inner => const Color(0xFF050509),
      CategoryDesignElement.learnStageSwitch1Number => Colors.white,
      CategoryDesignElement.learnStageSwitch2 => const Color(0xFFE9EFFA),
      CategoryDesignElement.learnStageSwitch2Inner => const Color(0xFF050509),
      CategoryDesignElement.learnStageSwitch2Number => Colors.white,
      CategoryDesignElement.learnStageSwitch3 => const Color(0xFFE9EFFA),
      CategoryDesignElement.learnStageSwitch3Inner => const Color(0xFF050509),
      CategoryDesignElement.learnStageSwitch3Number => Colors.white,
      CategoryDesignElement.learnStageSwitch4 => const Color(0xFFE9EFFA),
      CategoryDesignElement.learnStageSwitch4Inner => const Color(0xFF050509),
      CategoryDesignElement.learnStageSwitch4Number => Colors.white,
      CategoryDesignElement.learnStageSwitch5 => const Color(0xFFE9EFFA),
      CategoryDesignElement.learnStageSwitch5Inner => const Color(0xFF050509),
      CategoryDesignElement.learnStageSwitch5Number => Colors.white,
      CategoryDesignElement.playButton => const Color(0xFF9CFFE9),
      CategoryDesignElement.learnPlayArea => const Color(0xFF9CFFE9),
      CategoryDesignElement.categoryBackground => const Color(0xFF050508),
    };
  }

  static double glowIntensityFor(CategoryDesignGlowStrength glow) {
    return switch (glow) {
      CategoryDesignGlowStrength.off => 0.0,
      CategoryDesignGlowStrength.subtle => 0.45,
      CategoryDesignGlowStrength.normal => 1.0,
      CategoryDesignGlowStrength.strong => 1.55,
    };
  }

  static double pulseSpeedFor(CategoryDesignPulseStrength pulse) {
    return switch (pulse) {
      CategoryDesignPulseStrength.off => 0.0,
      CategoryDesignPulseStrength.subtle => 0.45,
      CategoryDesignPulseStrength.normal => 1.0,
      CategoryDesignPulseStrength.strong => 1.35,
    };
  }
}

class CategoryDesignPreferencesRepository {
  const CategoryDesignPreferencesRepository();

  static const _keyPrefix = 'category_design.';

  String _key(String categoryId) => '$_keyPrefix$categoryId';

  Future<CategoryDesignPreferences> load(String categoryId) async {
    if (categoryId.isEmpty) return const CategoryDesignPreferences();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(categoryId));
    if (raw == null || raw.isEmpty) return const CategoryDesignPreferences();
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return const CategoryDesignPreferences();
    return CategoryDesignPreferences.fromJson(
      Map<String, Object?>.from(decoded),
    );
  }

  Future<void> save(
    String categoryId,
    CategoryDesignPreferences preferences,
  ) async {
    if (categoryId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(categoryId), jsonEncode(preferences.toJson()));
  }

  Future<void> resetArea(String categoryId, CategoryDesignArea area) async {
    final current = await load(categoryId);
    final next = Map<CategoryDesignElement, CategoryDesignElementStyle>.from(
      current.overrides,
    )..removeWhere((element, _) => element.area == area);
    await save(categoryId, CategoryDesignPreferences(overrides: next));
  }

  Future<void> resetAllCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
    await Future.wait(keys.map(prefs.remove));
  }
}

class CategoryDesignCustomPaletteRepository {
  const CategoryDesignCustomPaletteRepository();

  static const _key = 'category_design.custom_palette';
  static const maxColors = 48;

  Future<List<Color>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return [
      for (final value in decoded)
        if (value is int) Color(value),
    ];
  }

  Future<List<Color>> saveColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await load();
    final colorValue = color.toARGB32();
    final next = <Color>[
      color,
      for (final existing in current)
        if (existing.toARGB32() != colorValue) existing,
    ].take(maxColors).toList(growable: false);
    await prefs.setString(
      _key,
      jsonEncode([for (final item in next) item.toARGB32()]),
    );
    return next;
  }
}

final categoryDesignPreferencesRepositoryProvider =
    Provider<CategoryDesignPreferencesRepository>((ref) {
      return const CategoryDesignPreferencesRepository();
    });

final categoryDesignPreferencesProvider =
    FutureProvider.family<CategoryDesignPreferences, String>((ref, categoryId) {
      return ref
          .watch(categoryDesignPreferencesRepositoryProvider)
          .load(categoryId);
    });

Color categoryDesignAccentFor(
  CategoryDesignPreferences preferences,
  CategoryDesignElement element,
) {
  return preferences.styleFor(element).color ??
      CategoryDesignDefaults.accentFor(element);
}
