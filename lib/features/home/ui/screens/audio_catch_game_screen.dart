import 'package:flutter/material.dart';
import 'package:talvori/features/home/ui/screens/word_game_arcade_screen.dart';

class AudioCatchGameScreen extends StatelessWidget {
  const AudioCatchGameScreen({super.key});

  static const routeName = 'audio-catch-game';

  @override
  Widget build(BuildContext context) {
    return const WordGameArcadeScreen(kind: ArcadeGameKind.audioCatch);
  }
}
