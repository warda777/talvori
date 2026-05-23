import 'package:flutter/material.dart';
import 'package:talvori/features/home/ui/screens/word_game_arcade_screen.dart';

class OddWordGameScreen extends StatelessWidget {
  const OddWordGameScreen({super.key});

  static const routeName = 'odd-word-game';

  @override
  Widget build(BuildContext context) {
    return const WordGameArcadeScreen(kind: ArcadeGameKind.oddWord);
  }
}
