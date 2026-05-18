import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../srs/models/learning_mode.dart';
import '../../srs/models/training_area.dart';
import '../models/local_time_replay_card.dart';
import 'local_bootstrap_provider.dart';

class LocalReplayCardsRequest {
  const LocalReplayCardsRequest({required this.categoryId, required this.mode});

  final String categoryId;
  final LearningMode mode;

  @override
  bool operator ==(Object other) {
    return other is LocalReplayCardsRequest &&
        other.categoryId == categoryId &&
        other.mode == mode;
  }

  @override
  int get hashCode => Object.hash(categoryId, mode);
}

final localReplayCardsProvider =
    FutureProvider.family<List<LocalReplayCard>, LocalReplayCardsRequest>((
      ref,
      request,
    ) async {
      final categoryId = request.categoryId;
      if (categoryId.trim().isEmpty) return const <LocalReplayCard>[];
      if (request.mode == LearningMode.adaptive) {
        return const <LocalReplayCard>[];
      }

      final bootstrap = await ref.watch(localBootstrapProvider.future);
      final repositories = bootstrap.repositoryFactory;
      final sessions = await repositories.learningSessionRepository
          .loadSessionsWithItemsForContext(
            categoryId: categoryId,
            mode: request.mode,
            trainingArea: TrainingArea.all,
          );
      if (sessions.isEmpty) return const <LocalReplayCard>[];

      final latestSession = sessions.first;
      final replaySessions =
          sessions
              .where(
                (session) =>
                    _isSameLocalDay(session.startedAt, latestSession.startedAt),
              )
              .toList()
            ..sort((a, b) {
              final startedCompare = a.startedAt.compareTo(b.startedAt);
              if (startedCompare != 0) return startedCompare;
              return a.updatedAt.compareTo(b.updatedAt);
            });

      final seenWordIds = <String>{};
      final cards = <LocalReplayCard>[];
      for (final session in replaySessions) {
        final items = await repositories.learningSessionRepository
            .loadSessionItems(session.id);
        for (final item in items) {
          if (!seenWordIds.add(item.wordId)) continue;
          final word = await repositories.wordRepository.loadWordById(
            item.wordId,
          );
          if (word == null) continue;
          cards.add(
            LocalReplayCard(
              wordId: word.id,
              term: word.term,
              translation: word.translation,
            ),
          );
        }
      }

      return cards;
    });

bool _isSameLocalDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

final localTimeReplayCardsProvider =
    FutureProvider.family<List<LocalTimeReplayCard>, String>((
      ref,
      categoryId,
    ) async {
      return ref.watch(
        localReplayCardsProvider(
          LocalReplayCardsRequest(
            categoryId: categoryId,
            mode: LearningMode.time,
          ),
        ).future,
      );
    });
