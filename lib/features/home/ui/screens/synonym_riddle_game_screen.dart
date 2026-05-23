import 'package:flutter/material.dart';
import 'package:talvori/features/home/ui/screens/word_game_arcade_screen.dart';

class SynonymRiddleGameScreen extends StatelessWidget {
  const SynonymRiddleGameScreen({super.key});

  static const routeName = 'synonym-riddle-game';

  @override
  Widget build(BuildContext context) {
    return const WordGameArcadeScreen(kind: ArcadeGameKind.synonymRiddle);
  }
}
