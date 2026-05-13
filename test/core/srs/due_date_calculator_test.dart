import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/services/due_date_calculator.dart';

void main() {
  const calculator = DueDateCalculator();
  final now = DateTime(2026, 5, 13, 10);

  group('DueDateCalculator', () {
    test('time_mode_uses_fixed_v1_intervals', () {
      expect(
        calculator.calculateNextDueAt(
          mode: LearningMode.time,
          stage: SrsStage.s1,
          now: now,
        ),
        now.add(const Duration(days: 1)),
      );
      expect(
        calculator.calculateNextDueAt(
          mode: LearningMode.time,
          stage: SrsStage.s2,
          now: now,
        ),
        now.add(const Duration(days: 3)),
      );
      expect(
        calculator.calculateNextDueAt(
          mode: LearningMode.time,
          stage: SrsStage.s3,
          now: now,
        ),
        now.add(const Duration(days: 7)),
      );
      expect(
        calculator.calculateNextDueAt(
          mode: LearningMode.time,
          stage: SrsStage.s4,
          now: now,
        ),
        now.add(const Duration(days: 14)),
      );
      expect(
        calculator.calculateNextDueAt(
          mode: LearningMode.time,
          stage: SrsStage.s5,
          now: now,
        ),
        now.add(const Duration(days: 30)),
      );
    });

    test('hybrid_mode_uses_short_v1_intervals_for_s3_to_s5', () {
      expect(
        calculator.calculateNextDueAt(
          mode: LearningMode.hybrid,
          stage: SrsStage.s3,
          now: now,
        ),
        now.add(const Duration(days: 1)),
      );
      expect(
        calculator.calculateNextDueAt(
          mode: LearningMode.hybrid,
          stage: SrsStage.s4,
          now: now,
        ),
        now.add(const Duration(days: 3)),
      );
      expect(
        calculator.calculateNextDueAt(
          mode: LearningMode.hybrid,
          stage: SrsStage.s5,
          now: now,
        ),
        now.add(const Duration(days: 5)),
      );
    });

    test('adaptive_mode_does_not_create_time_blockade', () {
      for (final stage in SrsStage.values) {
        expect(
          calculator.calculateNextDueAt(
            mode: LearningMode.adaptive,
            stage: stage,
            now: now,
          ),
          now,
        );
      }
    });

    test('s5_gets_next_due_date_and_remains_repeatable', () {
      expect(
        calculator.calculateNextDueAt(
          mode: LearningMode.time,
          stage: SrsStage.s5,
          now: now,
        ),
        now.add(const Duration(days: 30)),
      );
      expect(
        calculator.calculateNextDueAt(
          mode: LearningMode.hybrid,
          stage: SrsStage.s5,
          now: now,
        ),
        now.add(const Duration(days: 5)),
      );
    });
  });
}
