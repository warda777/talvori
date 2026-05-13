import 'learning_mode.dart';
import 'srs_stage.dart';

class WordProgress {
  const WordProgress({
    required this.wordId,
    required this.categoryId,
    required this.mode,
    required this.stage,
    required this.passCount,
    required this.wrongCount,
    this.nextDueAt,
    this.lastReviewedAt,
    this.isMastered = false,
  }) : assert(passCount >= 0),
       assert(wrongCount >= 0);

  final String wordId;
  final String categoryId;
  final LearningMode mode;
  final SrsStage stage;
  final int passCount;
  final int wrongCount;
  final DateTime? nextDueAt;
  final DateTime? lastReviewedAt;
  final bool isMastered;

  WordProgress copyWith({
    String? wordId,
    String? categoryId,
    LearningMode? mode,
    SrsStage? stage,
    int? passCount,
    int? wrongCount,
    DateTime? nextDueAt,
    DateTime? lastReviewedAt,
    bool? isMastered,
  }) {
    return WordProgress(
      wordId: wordId ?? this.wordId,
      categoryId: categoryId ?? this.categoryId,
      mode: mode ?? this.mode,
      stage: stage ?? this.stage,
      passCount: passCount ?? this.passCount,
      wrongCount: wrongCount ?? this.wrongCount,
      nextDueAt: nextDueAt ?? this.nextDueAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      isMastered: isMastered ?? this.isMastered,
    );
  }
}
