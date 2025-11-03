import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider / Controller
import '../../application/vocab_controller.dart';
import '../../providers.dart';

// UI-Bausteine
import '../widgets/vocab_promo_card.dart';
import '../widgets/vocab_tile.dart';
import '../widgets/vocab_section_header.dart';

class VocabScreen extends ConsumerWidget {
  const VocabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final state = ref.watch(vocabControllerProvider);
    final ctrl  = ref.read(vocabControllerProvider.notifier);

    bool isLocked(String key) => state.locked.contains(key);

    return Scaffold(
      backgroundColor: t.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Vocab Practice'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          children: [

            // Promo / Shuffle
            VocabPromoCard(onStart: ctrl.startGameShuffle),
            const SizedBox(height: 16),

            // CHALLENGES
            const VocabSectionHeader(title: 'Challenges'),
            Row(
              children: [
                Expanded(
                  child: VocabTile(
                    title: 'Perfection',
                    locked: isLocked('challenge_perfection_1'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: VocabTile(
                    title: 'Perfection',
                    locked: isLocked('challenge_perfection_2'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: VocabTile(
                    title: 'Perfection',
                    locked: isLocked('challenge_perfection_3'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // PRACTICE
            const VocabSectionHeader(title: 'Practice'),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              children: [
                VocabTile(
                  title: 'Vocab classic',
                  locked: isLocked('practice_vocab_classic'),
                ),
                VocabTile(
                  title: 'Build words',
                  locked: isLocked('practice_build_words'),
                ),
                VocabTile(
                  title: 'Choose the word',
                  locked: isLocked('practice_choose_word'),
                ),
                VocabTile(
                  title: 'Guess the word',
                  locked: isLocked('practice_guess_word'),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // COMING SOON (Tap to vote)
            const VocabSectionHeader(title: 'Coming soon (tap to vote!)'),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              children: [
                for (final title in state.comingSoon)
                  VocabTile(
                    title: title,
                    onTap: () => ctrl.voteFor(title),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
