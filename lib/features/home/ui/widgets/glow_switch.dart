import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/home/application/application.dart';

/// Switch-Widget zum Ein-/Ausschalten des Glow-Effekts
/// Platziert oben rechts neben dem "My Words" Counter
class GlowSwitch extends ConsumerWidget {
  const GlowSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glowEnabled = ref.watch(homeControllerProvider.select((s) => s.glowEnabled));
    final controller = ref.read(homeControllerProvider.notifier);

    return Tooltip(
      message: glowEnabled ? 'Glow-Effekte aus' : 'Glow-Effekte an',
      child: Switch(
        value: glowEnabled,
        onChanged: (value) => controller.setGlowEnabled(value),
        activeColor: const Color(0xFFB0CCFE), // Word Wheel Blau
        activeTrackColor: const Color(0xFFB0CCFE).withOpacity(0.5),
        inactiveThumbColor: Colors.grey[600],
        inactiveTrackColor: Colors.grey[800],
      ),
    );
  }
}

