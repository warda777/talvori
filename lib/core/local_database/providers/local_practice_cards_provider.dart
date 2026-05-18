import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../srs/models/srs_stage.dart';
import '../models/local_practice_card.dart';
import 'local_bootstrap_provider.dart';

final localPracticeCardsProvider =
    FutureProvider.family<List<LocalPracticeCard>, LocalPracticeCardsRequest>((
      ref,
      request,
    ) async {
      final categoryId = request.categoryId.trim();
      if (categoryId.isEmpty) return const <LocalPracticeCard>[];

      final bootstrap = await ref.watch(localBootstrapProvider.future);
      final repositories = bootstrap.repositoryFactory;
      final words = await repositories.wordRepository.loadWordsForCategory(
        categoryId: categoryId,
      );

      final buckets = <SrsStage, List<LocalPracticeCard>>{
        for (final stage in SrsStage.values) stage: <LocalPracticeCard>[],
      };

      for (final word in words) {
        final progress = await repositories.wordProgressRepository.loadProgress(
          wordId: word.id,
          categoryId: categoryId,
          mode: request.mode,
        );
        if (progress == null) continue;
        if (!_matchesSelection(progress.stage, request.selection)) continue;
        buckets[progress.stage]!.add(
          LocalPracticeCard(
            wordId: word.id,
            term: word.term,
            translation: word.translation,
            stage: progress.stage,
          ),
        );
      }

      if (request.selection.type == LocalPracticeSelectionType.singleStage) {
        return List<LocalPracticeCard>.unmodifiable(
          buckets[request.selection.stage] ?? const <LocalPracticeCard>[],
        );
      }

      return List<LocalPracticeCard>.unmodifiable(_roundRobinStages(buckets));
    });

bool _matchesSelection(SrsStage stage, LocalPracticeSelection selection) {
  switch (selection.type) {
    case LocalPracticeSelectionType.allStages:
      return stage != SrsStage.s0;
    case LocalPracticeSelectionType.singleStage:
      return stage == selection.stage;
  }
}

List<LocalPracticeCard> _roundRobinStages(
  Map<SrsStage, List<LocalPracticeCard>> buckets,
) {
  const stages = [
    SrsStage.s1,
    SrsStage.s2,
    SrsStage.s3,
    SrsStage.s4,
    SrsStage.s5,
  ];
  final result = <LocalPracticeCard>[];
  var index = 0;
  while (true) {
    var added = false;
    for (final stage in stages) {
      final cards = buckets[stage] ?? const <LocalPracticeCard>[];
      if (index < cards.length) {
        result.add(cards[index]);
        added = true;
      }
    }
    if (!added) return result;
    index++;
  }
}
