import 'package:flutter_riverpod/flutter_riverpod.dart';

class VocabState {
  /// gesperrte Tiles (Schloss-Symbol)
  final Set<String> locked;
  /// „Coming soon“-Kandidaten (für Tap-to-vote)
  final List<String> comingSoon;

  const VocabState({
    required this.locked,
    required this.comingSoon,
  });

  VocabState copyWith({
    Set<String>? locked,
    List<String>? comingSoon,
  }) =>
      VocabState(
        locked: locked ?? this.locked,
        comingSoon: comingSoon ?? this.comingSoon,
      );

  static VocabState initial() => const VocabState(
        locked: {
          // wie im Mockup
          'challenge_perfection_1',
          'challenge_perfection_2',
          'challenge_perfection_3',
          'practice_vocab_classic',
          'practice_build_words',
          'practice_choose_word',
          'practice_guess_word',
        },
        comingSoon: [
          'Connect words',
          'Listen and spell',
          'Word wheel',
          'Complete Word',
        ],
      );
}

class VocabController extends Notifier<VocabState> {
  @override
  VocabState build() {
    // TODO: später Locks dynamisch aus Premium/Progress ableiten
    return VocabState.initial();
  }

  /// Startet den gemischten Shuffle-Mode (Platzhalter).
  void startGameShuffle() {
    // TODO: Router zur Spielauswahl / Shuffle-Session
  }

  /// Vote für ein "Coming soon"–Feature.
  void voteFor(String title) {
    // TODO: persistentes Voting (Supabase) – hier nur Platzhalter
  }
}
