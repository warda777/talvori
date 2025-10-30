import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/learning_engine_provider.dart';

class LearningEngineToggle extends ConsumerWidget {
  const LearningEngineToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(learningEngineProvider);
    final isAdaptive = engine == LearningEngine.adaptiveSRS;
    // Aktive Label-Farbe (goldener Ton mit besserem Kontrast)
    const activeC = Color(0xFFE5B966);
    const inactiveC = Colors.white70;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'T-SRS',
          style: TextStyle(
            color: engine == LearningEngine.timeSRS ? activeC : inactiveC,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            shadows: engine == LearningEngine.timeSRS
                ? [
                    Shadow(color: activeC.withOpacity(0.30), blurRadius: 6, offset: const Offset(0, 2)),
                    Shadow(color: activeC.withOpacity(0.45), blurRadius: 12, offset: const Offset(0, 6)),
                    Shadow(color: activeC.withOpacity(0.60), blurRadius: 18, offset: const Offset(0, 12)),
                  ]
                : null,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 80, height: 44,
          child: Center(
            child: Transform.scale(
              scale: 1.25,
              child: Switch(
                value: isAdaptive,
                onChanged: (v) => ref
                    .read(learningEngineProvider.notifier)
                    .state = v ? LearningEngine.adaptiveSRS
                               : LearningEngine.timeSRS,
                // Farben gemäß Vorgabe
                thumbColor: const MaterialStatePropertyAll(Color(0xFFAFCCFE)),
                trackColor: const MaterialStatePropertyAll(Color(0xFF2C2C2C)),
                trackOutlineColor: const MaterialStatePropertyAll(Color(0xFFAFCCFE)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'A-SRS',
          style: TextStyle(
            color: engine == LearningEngine.adaptiveSRS ? activeC : inactiveC,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            shadows: engine == LearningEngine.adaptiveSRS
                ? [
                    Shadow(color: activeC.withOpacity(0.30), blurRadius: 6, offset: const Offset(0, 2)),
                    Shadow(color: activeC.withOpacity(0.45), blurRadius: 12, offset: const Offset(0, 6)),
                    Shadow(color: activeC.withOpacity(0.60), blurRadius: 18, offset: const Offset(0, 12)),
                  ]
                : null,
          ),
        ),
      ],
    );
  }
}
