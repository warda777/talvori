import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum VocabPracticeStatus { prepared }

class VocabPracticeItem {
  const VocabPracticeItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.badgeLabel,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String? badgeLabel;
  VocabPracticeStatus get status => VocabPracticeStatus.prepared;
}

class VocabState {
  const VocabState({
    required this.quickGames,
    required this.wordBuilders,
    required this.smartChallenges,
  });

  final List<VocabPracticeItem> quickGames;
  final List<VocabPracticeItem> wordBuilders;
  final List<VocabPracticeItem> smartChallenges;

  static VocabState initial() => const VocabState(
    quickGames: [
      VocabPracticeItem(
        id: 'speed_round',
        title: 'Blitzrunde',
        subtitle: '60 Sekunden, so viele Wörter wie möglich',
        icon: Icons.bolt_rounded,
        accent: Color(0xFFFFD166),
      ),
      VocabPracticeItem(
        id: 'word_hunt',
        title: 'Wort-Jagd',
        subtitle: 'Tippe schnell die richtige Bedeutung',
        icon: Icons.gps_fixed_rounded,
        accent: Color(0xFFFF7AB6),
      ),
      VocabPracticeItem(
        id: 'word_duel',
        title: 'Wort-Duell',
        subtitle: 'Tritt später gegen andere an',
        icon: Icons.sports_esports_rounded,
        accent: Color(0xFFB36BFF),
      ),
      VocabPracticeItem(
        id: 'audio_catch',
        title: 'Hör-Fang',
        subtitle: 'Tippe das Wort, das du hörst',
        icon: Icons.graphic_eq_rounded,
        accent: Color(0xFF7DFFE3),
      ),
      VocabPracticeItem(
        id: 'word_recognition',
        title: 'Wort erkennen',
        subtitle: 'Wähle die passende Übersetzung',
        icon: Icons.psychology_alt_rounded,
        accent: Color(0xFFFF8A5B),
      ),
    ],
    wordBuilders: [
      VocabPracticeItem(
        id: 'word_match',
        title: 'Wort-Match',
        subtitle: 'Verbinde Wort und Übersetzung',
        icon: Icons.hub_rounded,
        accent: Color(0xFF5DDCFF),
      ),
      VocabPracticeItem(
        id: 'word_puzzle',
        title: 'Wort-Puzzle',
        subtitle: 'Sortiere Buchstaben zum richtigen Wort',
        icon: Icons.extension_rounded,
        accent: Color(0xFF9DFF7D),
      ),
      VocabPracticeItem(
        id: 'gap_word',
        title: 'Lückenwort',
        subtitle: 'Ergänze fehlende Buchstaben',
        icon: Icons.edit_note_rounded,
        accent: Color(0xFF7DFFE3),
      ),
      VocabPracticeItem(
        id: 'hangman',
        title: 'Hangman',
        subtitle: 'Errate das Wort Schritt für Schritt',
        icon: Icons.lightbulb_rounded,
        accent: Color(0xFFFFE66D),
      ),
      VocabPracticeItem(
        id: 'syllable_rain',
        title: 'Silben-Regen',
        subtitle: 'Fange Silben und bilde Wörter',
        icon: Icons.water_drop_rounded,
        accent: Color(0xFF5DDCFF),
      ),
      VocabPracticeItem(
        id: 'word_path',
        title: 'Wortpfad',
        subtitle: 'Wische durch Buchstaben und bilde Wörter',
        icon: Icons.route_rounded,
        accent: Color(0xFF9DFF7D),
      ),
      VocabPracticeItem(
        id: 'word_search',
        title: 'Wortsuche',
        subtitle: 'Finde Wörter waagerecht, senkrecht und diagonal',
        icon: Icons.grid_view_rounded,
        accent: Color(0xFFFF7AB6),
      ),
    ],
    smartChallenges: [
      VocabPracticeItem(
        id: 'listen_write',
        title: 'Hör & Schreib',
        subtitle: 'Höre das Wort und schreibe es',
        icon: Icons.hearing_rounded,
        accent: Color(0xFFB36BFF),
      ),
      VocabPracticeItem(
        id: 'context_challenge',
        title: 'Kontext-Challenge',
        subtitle: 'Verstehe Wörter im KI-Satz',
        icon: Icons.auto_awesome_rounded,
        accent: Color(0xFF7DFFE3),
        badgeLabel: 'KI',
      ),
      VocabPracticeItem(
        id: 'odd_word',
        title: 'Gegenwort',
        subtitle: 'Finde das Wort, das nicht dazugehört',
        icon: Icons.category_rounded,
        accent: Color(0xFFFFD166),
        badgeLabel: 'KI',
      ),
      VocabPracticeItem(
        id: 'synonym_riddle',
        title: 'Synonym-Rätsel',
        subtitle: 'Erkenne das Wort aus ähnlichen Bedeutungen',
        icon: Icons.format_quote_rounded,
        accent: Color(0xFFFF8A5B),
        badgeLabel: 'KI',
      ),
      VocabPracticeItem(
        id: 'boss_fight',
        title: 'Boss-Fight',
        subtitle: 'Besiege deine schwierigsten Wörter',
        icon: Icons.local_fire_department_rounded,
        accent: Color(0xFFFF5F7A),
      ),
      VocabPracticeItem(
        id: 'daily_word_quest',
        title: 'Daily Word Quest',
        subtitle: 'Deine tägliche Wortmission',
        icon: Icons.flag_rounded,
        accent: Color(0xFF5DDCFF),
      ),
    ],
  );
}

class VocabController extends Notifier<VocabState> {
  @override
  VocabState build() {
    return VocabState.initial();
  }
}
