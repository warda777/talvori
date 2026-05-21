enum ImpulseAiStyle {
  direct('direct', 'Kurz & direkt'),
  motivating('motivating', 'Motivierend'),
  casual('casual', 'Locker'),
  trainer('trainer', 'Trainer');

  const ImpulseAiStyle(this.wireName, this.label);

  final String wireName;
  final String label;

  static ImpulseAiStyle fromWireName(Object? value) {
    final raw = value?.toString();
    return ImpulseAiStyle.values.firstWhere(
      (item) => item.wireName == raw,
      orElse: () => ImpulseAiStyle.motivating,
    );
  }
}

enum ImpulseAnswerLength {
  short('short', 'Kurz'),
  normal('normal', 'Normal'),
  detailed('detailed', 'Ausführlich');

  const ImpulseAnswerLength(this.wireName, this.label);

  final String wireName;
  final String label;

  static ImpulseAnswerLength fromWireName(Object? value) {
    final raw = value?.toString();
    return ImpulseAnswerLength.values.firstWhere(
      (item) => item.wireName == raw,
      orElse: () => ImpulseAnswerLength.normal,
    );
  }
}

enum ImpulseLearningGoal {
  everyday('everyday', 'Alltag'),
  school('school', 'Schule'),
  travel('travel', 'Reisen'),
  exam('exam', 'Prüfung'),
  work('work', 'Beruf');

  const ImpulseLearningGoal(this.wireName, this.label);

  final String wireName;
  final String label;

  static ImpulseLearningGoal fromWireName(Object? value) {
    final raw = value?.toString();
    return ImpulseLearningGoal.values.firstWhere(
      (item) => item.wireName == raw,
      orElse: () => ImpulseLearningGoal.everyday,
    );
  }
}

enum ImpulseExplanationLanguage {
  german('german', 'Deutsch'),
  english('english', 'Englisch'),
  mixed('mixed', 'Gemischt');

  const ImpulseExplanationLanguage(this.wireName, this.label);

  final String wireName;
  final String label;

  static ImpulseExplanationLanguage fromWireName(Object? value) {
    final raw = value?.toString();
    return ImpulseExplanationLanguage.values.firstWhere(
      (item) => item.wireName == raw,
      orElse: () => ImpulseExplanationLanguage.german,
    );
  }
}

class ImpulseAiProfile {
  const ImpulseAiProfile({
    this.style = ImpulseAiStyle.motivating,
    this.answerLength = ImpulseAnswerLength.normal,
    this.learningGoal = ImpulseLearningGoal.everyday,
    this.explanationLanguage = ImpulseExplanationLanguage.german,
  });

  final ImpulseAiStyle style;
  final ImpulseAnswerLength answerLength;
  final ImpulseLearningGoal learningGoal;
  final ImpulseExplanationLanguage explanationLanguage;

  static const defaults = ImpulseAiProfile();

  ImpulseAiProfile copyWith({
    ImpulseAiStyle? style,
    ImpulseAnswerLength? answerLength,
    ImpulseLearningGoal? learningGoal,
    ImpulseExplanationLanguage? explanationLanguage,
  }) {
    return ImpulseAiProfile(
      style: style ?? this.style,
      answerLength: answerLength ?? this.answerLength,
      learningGoal: learningGoal ?? this.learningGoal,
      explanationLanguage: explanationLanguage ?? this.explanationLanguage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'style': style.wireName,
      'answerLength': answerLength.wireName,
      'learningGoal': learningGoal.wireName,
      'explanationLanguage': explanationLanguage.wireName,
    };
  }

  factory ImpulseAiProfile.fromJson(Object? json) {
    if (json is! Map) return defaults;
    return ImpulseAiProfile(
      style: ImpulseAiStyle.fromWireName(json['style']),
      answerLength: ImpulseAnswerLength.fromWireName(json['answerLength']),
      learningGoal: ImpulseLearningGoal.fromWireName(json['learningGoal']),
      explanationLanguage: ImpulseExplanationLanguage.fromWireName(
        json['explanationLanguage'],
      ),
    );
  }

  Map<String, Object?> toAiContext() {
    return {
      'aiStyle': style.wireName,
      'answerLength': answerLength.wireName,
      'learningGoal': learningGoal.wireName,
      'explanationLanguage': explanationLanguage.wireName,
    };
  }
}
