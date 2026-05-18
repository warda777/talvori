import '../../srs/models/srs_stage.dart';

enum LocalReviewOutcomeType {
  promoted,
  repeatedSameStage,
  demoted,
  unchangedWrong,
}

class LocalReviewVisualFeedback {
  const LocalReviewVisualFeedback({
    required this.wordId,
    required this.sourceStage,
    required this.targetStage,
    required this.outcomeType,
    required this.repeatIndex,
    required this.wasPromoted,
    required this.wasDemoted,
    required this.timestamp,
  });

  final String wordId;
  final SrsStage sourceStage;
  final SrsStage targetStage;
  final LocalReviewOutcomeType outcomeType;
  final int repeatIndex;
  final bool wasPromoted;
  final bool wasDemoted;
  final DateTime timestamp;
}
