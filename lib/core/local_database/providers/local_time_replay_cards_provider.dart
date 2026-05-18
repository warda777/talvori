import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../srs/models/learning_mode.dart';
import '../../srs/models/training_area.dart';
import '../models/local_time_replay_card.dart';
import 'local_bootstrap_provider.dart';

final localTimeReplayCardsProvider =
    FutureProvider.family<List<LocalTimeReplayCard>, String>((
      ref,
      categoryId,
    ) async {
      if (categoryId.trim().isEmpty) return const <LocalTimeReplayCard>[];

      final bootstrap = await ref.watch(localBootstrapProvider.future);
      final repositories = bootstrap.repositoryFactory;
      final session = await repositories.learningSessionRepository
          .findLatestSessionWithItems(
            categoryId: categoryId,
            mode: LearningMode.time,
            trainingArea: TrainingArea.all,
          );
      if (session == null) return const <LocalTimeReplayCard>[];

      final items = await repositories.learningSessionRepository
          .loadSessionItems(session.id);
      final seenWordIds = <String>{};
      final cards = <LocalTimeReplayCard>[];
      for (final item in items) {
        if (!seenWordIds.add(item.wordId)) continue;
        final word = await repositories.wordRepository.loadWordById(
          item.wordId,
        );
        if (word == null) continue;
        cards.add(
          LocalTimeReplayCard(
            wordId: word.id,
            term: word.term,
            translation: word.translation,
          ),
        );
      }

      return cards;
    });
