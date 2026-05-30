import 'package:flutter/material.dart';

class WordDuelPreviewScreen extends StatelessWidget {
  const WordDuelPreviewScreen({super.key});

  static const routeName = 'word-duel-preview';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050912),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050912),
        elevation: 0,
        centerTitle: true,
        title: const Text('Wort-Duell'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1220),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFFF8A5B)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8A5B).withValues(alpha: 0.14),
                    blurRadius: 30,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.sports_esports_rounded,
                    color: Color(0xFFFF8A5B),
                    size: 46,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Wort-Duell',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFF4F8FF),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Ein vorbereiteter Mehrspieler-Modus für schnelle Worterkennung. Im MVP bleibt das Duell als Ausblick sichtbar, ohne Punkte oder Lernfortschritt zu verändern.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFB8C7D9),
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _PreviewFeatureGrid(),
                  const SizedBox(height: 22),
                  OutlinedButton(
                    key: const ValueKey('word-duel-preview-back-button'),
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF4F8FF),
                      side: const BorderSide(color: Color(0xFFFF8A5B)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    child: const Text('Zurück zu Wortspiele'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewFeatureGrid extends StatelessWidget {
  const _PreviewFeatureGrid();

  static const _features = <({IconData icon, String title})>[
    (icon: Icons.person_add_alt_1_rounded, title: 'Spieler einladen'),
    (icon: Icons.mark_email_unread_rounded, title: 'Duell-Anfrage'),
    (icon: Icons.leaderboard_rounded, title: 'Live-Ranking'),
    (icon: Icons.timer_rounded, title: 'Antwortzeit'),
    (icon: Icons.emoji_events_rounded, title: 'Gewinner'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final feature in _features)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF050912),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF26354B)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(feature.icon, color: const Color(0xFFFF8A5B), size: 18),
                const SizedBox(width: 8),
                Text(
                  feature.title,
                  style: const TextStyle(
                    color: Color(0xFFF4F8FF),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
