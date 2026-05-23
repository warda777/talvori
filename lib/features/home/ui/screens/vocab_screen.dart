import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/home/application/vocab_controller.dart';
import 'package:talvori/features/home/providers.dart';
import 'package:talvori/features/home/ui/screens/boss_fight_game_screen.dart';
import 'package:talvori/features/home/ui/screens/context_challenge_game_screen.dart';
import 'package:talvori/features/home/ui/screens/daily_word_quest_game_screen.dart';
import 'package:talvori/features/home/ui/screens/gap_word_game_screen.dart';
import 'package:talvori/features/home/ui/screens/hangman_game_screen.dart';
import 'package:talvori/features/home/ui/screens/listen_and_write_game_screen.dart';
import 'package:talvori/features/home/ui/screens/word_duel_preview_screen.dart';
import 'package:talvori/features/home/ui/screens/word_recognition_game_screen.dart';
import 'package:talvori/features/home/ui/screens/speed_round_game_screen.dart';
import 'package:talvori/features/home/ui/screens/word_match_game_screen.dart';
import 'package:talvori/features/home/ui/screens/word_puzzle_game_screen.dart';
import 'package:talvori/features/home/ui/screens/word_hunt_game_screen.dart';
import 'package:talvori/features/home/ui/widgets/vocab_promo_card.dart';
import 'package:talvori/features/home/ui/widgets/vocab_tile.dart';

class VocabScreen extends ConsumerWidget {
  const VocabScreen({super.key});

  static const routeName = 'word-games';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vocabControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050912),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050912),
        elevation: 0,
        centerTitle: true,
        title: const Text('Wortspiele'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            const VocabPromoCard(),
            _GameSection(
              title: 'Schnellspiele',
              items: state.quickGames,
              onTap: (item) => _openGame(context, item),
            ),
            _GameSection(
              title: 'Wörter bauen',
              items: state.wordBuilders,
              onTap: (item) => _openGame(context, item),
            ),
            _GameSection(
              title: 'Smart Challenges',
              items: state.smartChallenges,
              onTap: (item) => _openGame(context, item),
            ),
          ],
        ),
      ),
    );
  }

  static void _openGame(BuildContext context, VocabPracticeItem item) {
    if (item.id == 'speed_round') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: SpeedRoundGameScreen.routeName),
          builder: (_) => const SpeedRoundGameScreen(),
        ),
      );
      return;
    }
    if (item.id == 'word_recognition') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: const RouteSettings(
            name: WordRecognitionGameScreen.routeName,
          ),
          builder: (_) => const WordRecognitionGameScreen(),
        ),
      );
      return;
    }
    if (item.id == 'word_duel') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: WordDuelPreviewScreen.routeName),
          builder: (_) => const WordDuelPreviewScreen(),
        ),
      );
      return;
    }
    if (item.id == 'word_hunt') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: WordHuntGameScreen.routeName),
          builder: (_) => const WordHuntGameScreen(),
        ),
      );
      return;
    }
    if (item.id == 'word_match') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: WordMatchGameScreen.routeName),
          builder: (_) => const WordMatchGameScreen(),
        ),
      );
      return;
    }
    if (item.id == 'gap_word') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: GapWordGameScreen.routeName),
          builder: (_) => const GapWordGameScreen(),
        ),
      );
      return;
    }
    if (item.id == 'word_puzzle') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: WordPuzzleGameScreen.routeName),
          builder: (_) => const WordPuzzleGameScreen(),
        ),
      );
      return;
    }
    if (item.id == 'hangman') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: HangmanGameScreen.routeName),
          builder: (_) => const HangmanGameScreen(),
        ),
      );
      return;
    }
    if (item.id == 'daily_word_quest') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: const RouteSettings(
            name: DailyWordQuestGameScreen.routeName,
          ),
          builder: (_) => const DailyWordQuestGameScreen(),
        ),
      );
      return;
    }
    if (item.id == 'boss_fight') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: BossFightGameScreen.routeName),
          builder: (_) => const BossFightGameScreen(),
        ),
      );
      return;
    }
    if (item.id == 'context_challenge') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: const RouteSettings(
            name: ContextChallengeGameScreen.routeName,
          ),
          builder: (_) => const ContextChallengeGameScreen(),
        ),
      );
      return;
    }
    if (item.id == 'listen_write') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: const RouteSettings(
            name: ListenAndWriteGameScreen.routeName,
          ),
          builder: (_) => const ListenAndWriteGameScreen(),
        ),
      );
      return;
    }
    _showPreparedHint(context);
  }

  static void _showPreparedHint(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: const Key('word-game-prepared-toast'),
          backgroundColor: const Color(0xFF061018),
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF5DDCFF), width: 1.1),
          ),
          content: const Text(
            'Dieses Wortspiel wird vorbereitet.',
            style: TextStyle(
              color: Color(0xFFF4F8FF),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
  }
}

class _GameSection extends StatelessWidget {
  const _GameSection({
    required this.title,
    required this.items,
    required this.onTap,
  });

  final String title;
  final List<VocabPracticeItem> items;
  final ValueChanged<VocabPracticeItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFFF4F8FF),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.82,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final item in items)
                VocabTile(
                  key: ValueKey('word-game-${item.id}'),
                  item: item,
                  onTap: () => onTap(item),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
