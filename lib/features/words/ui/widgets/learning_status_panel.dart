import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/widgets/progress_ring.dart';

class LearningStatusPanel extends StatelessWidget {
  final double percent;        // daily progress 0..1
  final String percentLabel;   // e.g. "15%"
  final int newCount;
  final int repeatsCount;
  final String repeatsOfTargetLabel; // e.g. "3/20"
  final double overallPercent; // overall 0..1
  final String overallLabel;   // e.g. "150/263"

  const LearningStatusPanel({
    super.key,
    required this.percent,
    required this.percentLabel,
    required this.newCount,
    required this.repeatsCount,
    required this.repeatsOfTargetLabel,
    required this.overallPercent,
    required this.overallLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(0, 10),
                child: ProgressRing(
                  size: 120,
                  thickness: 12,
                  percent: percent,
                  center: Text(percentLabel,
                      style: t.textTheme.titleSmall?.copyWith(color: Colors.white)),
                ),
              ),
              const Spacer(),
              Transform.translate(
                offset: const Offset(0, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Transform.translate(
                      offset: const Offset(-100, -30),
                      child: Text('Daily Progress',
                          style: t.textTheme.titleSmall?.copyWith(color: Colors.white)),
                    ),
                    const SizedBox(height: 8),
                    _CounterRow(label: 'New', value: '$newCount'),
                    const SizedBox(height: 12),
                    _CounterRow(label: 'Repeats', value: repeatsOfTargetLabel),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _OverallProgressBar(percent: overallPercent, label: overallLabel),
        ],
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  final String label;
  final String value;
  const _CounterRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Colors.white)),
          const SizedBox(width: 8),
          Container(
            width: 75,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFF2C2C2C), width: 1),
            ),
            alignment: Alignment.center,
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      );
}

class _OverallProgressBar extends StatelessWidget {
  final double percent;
  final String label;
  const _OverallProgressBar({required this.percent, required this.label});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.translate(
            offset: const Offset(0, 16),
            child: Text('Overall Progress',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: Colors.white)),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: ClipRRect(                            // ⬅️ NEU
                borderRadius: BorderRadius.circular(4),    // gleiche Radius wie Hintergrund
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2F),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: percent.clamp(0.0, 1.0),
                      child: Container(
                        height: 8,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFE4B866), Color(0xFFF5D492)],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 75,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF2C2C2C)),
              ),
              alignment: Alignment.center,
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            )
          ]),
        ],
      );
}
