import 'package:talvori/core/assets/talvori_mascot_assets.dart';

enum CompanionDiscoveryTipType {
  browserShare,
  wordGames,
  dailyImpulse,
  myWords,
  favorites,
  learningLevels,
  languageTools,
  wordWorlds,
  motivation,
}

class CompanionDiscoveryTip {
  const CompanionDiscoveryTip({
    required this.type,
    required this.title,
    required this.message,
    required this.mood,
    required this.priority,
  });

  final CompanionDiscoveryTipType type;
  final String title;
  final String message;
  final TalvoriMascotMood mood;
  final int priority;
}

abstract final class CompanionDiscoveryTips {
  static const browserShare = CompanionDiscoveryTip(
    type: CompanionDiscoveryTipType.browserShare,
    title: 'Talvori',
    message: 'Markiere ein Wort im Browser und teile es mit Talvori.',
    mood: TalvoriMascotMood.greeting,
    priority: 100,
  );

  static const wordGames = CompanionDiscoveryTip(
    type: CompanionDiscoveryTipType.wordGames,
    title: 'Talvori',
    message: 'Probier mal die Wortspiele aus. Eine kurze Runde reicht.',
    mood: TalvoriMascotMood.happy,
    priority: 90,
  );

  static const dailyImpulse = CompanionDiscoveryTip(
    type: CompanionDiscoveryTipType.dailyImpulse,
    title: 'Talvori',
    message: 'Erstell dir heute einen kleinen Tagesimpuls.',
    mood: TalvoriMascotMood.thinkingChin,
    priority: 80,
  );

  static const wordWorlds = CompanionDiscoveryTip(
    type: CompanionDiscoveryTipType.wordWorlds,
    title: 'Talvori',
    message: 'Such dir eine Wortwelt aus und starte mit einem Thema.',
    mood: TalvoriMascotMood.greeting,
    priority: 70,
  );

  static const learningLevels = CompanionDiscoveryTip(
    type: CompanionDiscoveryTipType.learningLevels,
    title: 'Talvori',
    message: 'Teste ein Lernlevel und starte mit einem kleinen Paket.',
    mood: TalvoriMascotMood.proud,
    priority: 60,
  );

  static const languageTools = CompanionDiscoveryTip(
    type: CompanionDiscoveryTipType.languageTools,
    title: 'Talvori',
    message:
        'Schau dir die Sprachwerkzeuge an. Dort findest du extra Übungssets.',
    mood: TalvoriMascotMood.thinkingSkeptical,
    priority: 50,
  );

  static const motivation = CompanionDiscoveryTip(
    type: CompanionDiscoveryTipType.motivation,
    title: 'Talvori',
    message: 'Fünf Minuten reichen. Hauptsache, du bleibst dran.',
    mood: TalvoriMascotMood.happyHighThumb,
    priority: 10,
  );
}
