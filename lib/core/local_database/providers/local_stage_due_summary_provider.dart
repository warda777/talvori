import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../srs/models/learning_mode.dart';
import '../models/local_stage_due_summary.dart';
import 'local_bootstrap_provider.dart';

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
      return bootstrap.repositoryFactory.wordProgressRepository
          .loadStageDueSummaries(
            categoryId: request.categoryId,
            mode: request.mode,
            now: DateTime.now(),
          );
    });
