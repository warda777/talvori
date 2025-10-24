import 'package:flutter/material.dart';
import 'package:talvori/core/ui/widgets/progress_bar.dart';
import 'package:talvori/features/words/application/learn_mode_controller.dart';

class TimerBar extends StatelessWidget {
  final LearnModeState s;
  const TimerBar({super.key, required this.s});

  @override
  Widget build(BuildContext context) {
    final progress = (s.remainingMillis / (s.timeLimit * 1000.0))
        .clamp(0.0, 1.0);
    final isLowTime = s.remainingMillis <= 3000;


    if (!s.timerActive) {
      return ProgressBar(value: 0.0, background: Colors.white10);
    }

    return ProgressBar(
      value: progress,
      background: Colors.black.withOpacity(0.15),
      gradient: LinearGradient(
        colors: isLowTime
            ? [Colors.red.shade700, Colors.red.shade400]
            : const [Color(0xFFB1CCFE), Color(0xFFD0E0FF)],
      ),
    );
  }
}
