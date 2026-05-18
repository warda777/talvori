import '../../srs/models/learning_mode.dart';
import '../../srs/models/srs_stage.dart';

enum LocalPracticeSelectionType { allStages, singleStage }

class LocalPracticeSelection {
  const LocalPracticeSelection.allStages()
    : type = LocalPracticeSelectionType.allStages,
      stage = null;

  const LocalPracticeSelection.singleStage(this.stage)
    : type = LocalPracticeSelectionType.singleStage;

  final LocalPracticeSelectionType type;
  final SrsStage? stage;

  @override
  bool operator ==(Object other) {
    return other is LocalPracticeSelection &&
        other.type == type &&
        other.stage == stage;
  }

  @override
  int get hashCode => Object.hash(type, stage);
}

class LocalPracticeCardsRequest {
  const LocalPracticeCardsRequest({
    required this.categoryId,
    required this.mode,
    required this.selection,
  });

  final String categoryId;
  final LearningMode mode;
  final LocalPracticeSelection selection;

  @override
  bool operator ==(Object other) {
    return other is LocalPracticeCardsRequest &&
        other.categoryId == categoryId &&
        other.mode == mode &&
        other.selection == selection;
  }

  @override
  int get hashCode => Object.hash(categoryId, mode, selection);
}

class LocalPracticeCard {
  const LocalPracticeCard({
    required this.wordId,
    required this.term,
    required this.translation,
    required this.stage,
  });

  final String wordId;
  final String term;
  final String translation;
  final SrsStage stage;
}
