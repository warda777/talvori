import '../../srs/models/learning_mode.dart';

class LocalStageDueSummaryRequest {
  const LocalStageDueSummaryRequest({
    required this.categoryId,
    required this.mode,
  });

  final String categoryId;
  final LearningMode mode;

  @override
  bool operator ==(Object other) {
    return other is LocalStageDueSummaryRequest &&
        other.categoryId == categoryId &&
        other.mode == mode;
  }

  @override
  int get hashCode => Object.hash(categoryId, mode);
}

class LocalStageDueSummary {
  const LocalStageDueSummary({
    required this.stage,
    required this.totalCount,
    required this.dueCount,
    this.nextDueAt,
  });

  final int stage;
  final int totalCount;
  final int dueCount;
  final DateTime? nextDueAt;

  bool get isBlocked => totalCount > 0 && dueCount == 0 && nextDueAt != null;
}
