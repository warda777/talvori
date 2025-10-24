import 'package:flutter/material.dart';

class TimerBar extends StatelessWidget {
  final double remainingMillis;
  final int timeLimitSeconds;
  final bool active;

  const TimerBar({
    super.key,
    required this.remainingMillis,
    required this.timeLimitSeconds,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        (remainingMillis / (timeLimitSeconds * 1000.0)).clamp(0.0, 1.0);
    final isLowTime = remainingMillis <= 3000;

    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: active ? Colors.black.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          children: [
            if (active)
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isLowTime
                            ? [Colors.red.shade700, Colors.red.shade400]
                            : [const Color(0xFFB1CCFE), const Color(0xFFD0E0FF)],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
