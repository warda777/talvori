// lib/features/words/ui/widgets/card_glow_settings_popup.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:talvori/features/words/application/card_glow_settings_provider.dart';

/// Kleines Popup mit den beiden Reglern für den pochenden Glow der Karte
void showCardGlowSettingsPopup(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (context) => const _CardGlowSettingsPopup(),
  );
}

class _CardGlowSettingsPopup extends ConsumerWidget {
  const _CardGlowSettingsPopup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(cardGlowSettingsProvider);
    final notifier = ref.read(cardGlowSettingsProvider.notifier);

    return Dialog(
      backgroundColor: const Color(0xFF2D2D2F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune_rounded, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Karten-Glow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Intensität
            Text(
              'Intensität',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/low_sun-line.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    Colors.white54,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFFB16CFF),
                      inactiveTrackColor: Colors.white24,
                      thumbColor: const Color(0xFFB16CFF),
                      overlayColor: const Color(0xFFB16CFF).withOpacity(0.2),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      trackHeight: 2,
                    ),
                    child: Slider(
                      value: settings.intensity,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (v) => notifier.setIntensity(v),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(
                  'assets/icons/bright_sun-line.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    Colors.white54,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Pulsgeschwindigkeit
            Text(
              'Pulsgeschwindigkeit',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.remove, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF7B5CFF),
                      inactiveTrackColor: Colors.white24,
                      thumbColor: const Color(0xFF7B5CFF),
                      overlayColor: const Color(0xFF7B5CFF).withOpacity(0.2),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      trackHeight: 2,
                    ),
                    child: Slider(
                      value: settings.pulseSpeed,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (v) => notifier.setPulseSpeed(v),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(
                  'assets/icons/impulse.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    Colors.white54,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
