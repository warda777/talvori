import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../srs/models/learning_mode.dart';
import '../../srs/models/srs_stage.dart';
import '../models/local_learning_source.dart';
import '../models/local_stage_due_summary.dart';
import 'local_bootstrap_provider.dart';
import 'local_words_for_source_provider.dart';

final localStageDueSummaryProvider =
    FutureProvider.family<
      List<LocalStageDueSummary>,
      LocalStageDueSummaryRequest
    >((ref, request) async {
      final supportsDueSummaries =
          request.mode == LearningMode.time ||
          request.mode == LearningMode.hybrid;
      if (request.categoryId.trim().isEmpty || !supportsDueSummaries) {
        return const <LocalStageDueSummary>[];
      }

      final bootstrap = await ref.watch(localBootstrapProvider.future);
      final repositories = bootstrap.repositoryFactory;
      final source = LocalLearningSource.fromId(request.categoryId);
      if (source != null) {
        final words = await ref.watch(
          localWordsForSourceProvider(source).future,
        );
        final summaries = List<LocalStageDueSummary>.generate(
          SrsStage.values.length,
          (index) =>
              LocalStageDueSummary(stage: index, totalCount: 0, dueCount: 0),
        );

        final now = DateTime.now();
        final totals = List<int>.filled(SrsStage.values.length, 0);
        final dueCounts = List<int>.filled(SrsStage.values.length, 0);
        final nextDueDates = List<DateTime?>.filled(
          SrsStage.values.length,
          null,
        );

        for (final word in words) {
          final progress = await repositories.wordProgressRepository
              .loadProgress(
                wordId: word.id,
                categoryId: word.categoryId,
                mode: request.mode,
              );
          if (progress == null) continue;
          final index = progress.stage.index;
          totals[index] += 1;

          final nextDueAt = progress.nextDueAt;
          if (nextDueAt == null) continue;
          if (!nextDueAt.isAfter(now)) {
            dueCounts[index] += 1;
            continue;
          }

          final existing = nextDueDates[index];
          if (existing == null || nextDueAt.isBefore(existing)) {
            nextDueDates[index] = nextDueAt;
          }
        }

        for (var index = 0; index < summaries.length; index += 1) {
          summaries[index] = LocalStageDueSummary(
            stage: index,
            totalCount: totals[index],
            dueCount: dueCounts[index],
            nextDueAt: nextDueDates[index],
          );
        }

        return summaries;
      }

      return bootstrap.repositoryFactory.wordProgressRepository
          .loadStageDueSummaries(
            categoryId: request.categoryId,
            mode: request.mode,
            now: DateTime.now(),
          );
    });
