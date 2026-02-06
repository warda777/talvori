// lib/features/words/application/a_srs_bands.dart

class BandResult {
  final int s1Min, s1Max;
  final int s2Min, s2Max;
  final int s3Min, s3Max;
  final int s4Min, s4Max;
  final int s5Min, s5Max;
  const BandResult({
    required this.s1Min,
    required this.s1Max,
    required this.s2Min,
    required this.s2Max,
    required this.s3Min,
    required this.s3Max,
    required this.s4Min,
    required this.s4Max,
    required this.s5Min,
    required this.s5Max,
  });
}

abstract class ASrsBands {
  BandResult forCounts({
    required int s0,
    required int s1,
    required int s2,
    required int s3,
    required int s4,
    required int s5,
    required int mastered,
  });
}

class ASrsBandsImpl implements ASrsBands {
  @override
  BandResult forCounts({
    required int s0,
    required int s1,
    required int s2,
    required int s3,
    required int s4,
    required int s5,
    required int mastered,
  }) {
    final counts = StageCounts(
      s0: s0,
      s1: s1,
      s2: s2,
      s3: s3,
      s4: s4,
      s5: s5,
      mastered: mastered,
    );
    final bands = ASrsBandsStatic.compute(counts);
    return BandResult(
      s1Min: bands.s1.min,
      s1Max: bands.s1.max,
      s2Min: bands.s2.min,
      s2Max: bands.s2.max,
      s3Min: bands.s3.min,
      s3Max: bands.s3.max,
      s4Min: bands.s4.min,
      s4Max: bands.s4.max,
      s5Min: bands.s5.min,
      s5Max: bands.s5.max,
    );
  }
}

class StageCounts {
  final int s0; // stage=0 AND ever_enrolled=false AND is_mastered=false
  final int s1;
  final int s2;
  final int s3;
  final int s4;
  final int s5;
  final int mastered;

  const StageCounts({
    required this.s0,
    required this.s1,
    required this.s2,
    required this.s3,
    required this.s4,
    required this.s5,
    required this.mastered,
  });

  int get reviewPool => s1 + s2 + s3 + s4 + s5;
  int get categoryTotalActive => s0 + reviewPool; // S0..S5, ohne mastered
}

class Band {
  final int min;
  final int max;
  const Band({required this.min, required this.max});
}

class EffectiveBands {
  final bool pipelineMode; // category_total_active <= 6
  final Band s1;
  final Band s2;
  final Band s3;
  final Band s4;
  final Band s5;

  const EffectiveBands({
    required this.pipelineMode,
    required this.s1,
    required this.s2,
    required this.s3,
    required this.s4,
    required this.s5,
  });

  Band bandForStage(int stage) {
    return switch (stage) {
      1 => s1,
      2 => s2,
      3 => s3,
      4 => s4,
      5 => s5,
      _ => const Band(min: 0, max: 0),
    };
  }
}

class ASrsBandsStatic {
  // Shares (Summe = 1.0)
  static const double _shS1 = 0.40;
  static const double _shS2 = 0.25;
  static const double _shS3 = 0.20;
  static const double _shS4 = 0.10;
  static const double _shS5 = 0.05;

  static EffectiveBands compute(StageCounts c) {
    final total = c.categoryTotalActive;

    // 6A.3 Pipeline-Mode
    if (total <= 6) {
      return const EffectiveBands(
        pipelineMode: true,
        s1: Band(min: 0, max: 999999),
        s2: Band(min: 0, max: 999999),
        s3: Band(min: 0, max: 999999),
        s4: Band(min: 0, max: 999999),
        s5: Band(min: 0, max: 999999),
      );
    }

    // 6A.1 Große Kategorien (>40 aktive Wörter)
    if (total > 40) {
      return const EffectiveBands(
        pipelineMode: false,
        s1: Band(min: 10, max: 20),
        s2: Band(min: 8, max: 16),
        s3: Band(min: 6, max: 12),
        s4: Band(min: 4, max: 8),
        s5: Band(min: 2, max: 6),
      );
    }

    // 6A.2 Kleine Kategorien (<=40): proportional
    // target_i = round(share_i * total)
    // Si_max_effective = max(1, target_i) (außer total==0)
    // Si_min_effective = floor(0.5 * Si_max_effective)
    if (total == 0) {
      return const EffectiveBands(
        pipelineMode: false,
        s1: Band(min: 0, max: 0),
        s2: Band(min: 0, max: 0),
        s3: Band(min: 0, max: 0),
        s4: Band(min: 0, max: 0),
        s5: Band(min: 0, max: 0),
      );
    }

    int max1 = _maxEff((_shS1 * total).round());
    int max2 = _maxEff((_shS2 * total).round());
    int max3 = _maxEff((_shS3 * total).round());
    int max4 = _maxEff((_shS4 * total).round());
    int max5 = _maxEff((_shS5 * total).round());

    // Zusatzregel: falls Summe Max > total, von S5 rückwärts kürzen
    var sum = max1 + max2 + max3 + max4 + max5;
    if (sum > total) {
      int overflow = sum - total;

      int cut(int v) {
        final take = overflow < v ? overflow : v;
        overflow -= take;
        return v - take;
      }

      max5 = cut(max5);
      if (overflow > 0) max4 = cut(max4);
      if (overflow > 0) max3 = cut(max3);
      if (overflow > 0) max2 = cut(max2);
      if (overflow > 0) max1 = cut(max1);

      // Sicherstellen: nicht negativ
      max1 = max1 < 0 ? 0 : max1;
      max2 = max2 < 0 ? 0 : max2;
      max3 = max3 < 0 ? 0 : max3;
      max4 = max4 < 0 ? 0 : max4;
      max5 = max5 < 0 ? 0 : max5;
    }

    final min1 = (0.5 * max1).floor();
    final min2 = (0.5 * max2).floor();
    final min3 = (0.5 * max3).floor();
    final min4 = (0.5 * max4).floor();
    final min5 = (0.5 * max5).floor();

    return EffectiveBands(
      pipelineMode: false,
      s1: Band(min: min1, max: max1),
      s2: Band(min: min2, max: max2),
      s3: Band(min: min3, max: max3),
      s4: Band(min: min4, max: max4),
      s5: Band(min: min5, max: max5),
    );
  }

  static int _maxEff(int target) => target < 1 ? 1 : target;
}