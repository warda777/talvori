import 'package:flutter/material.dart';
import 'arrow_fly_animation.dart';
import 'package:talvori/features/common/widgets/sparkle_particle_effect.dart';

/// Service-Klasse, die die Flug-Animation des Pfeils verwaltet
class ArrowFlyService {
  /// Startet die Flug-Animation vom Handy-Icon zur Progress Pill
  static void startArrowFlyAnimation({
    required BuildContext context,
    required GlobalKey phoneIconKey,
    required GlobalKey progressPillKey,
    GlobalKey? counterKey, // <-- NEU: Optionaler Key für den Counter
    VoidCallback? onComplete,
  }) {
    // Hole die Positionen der beiden Widgets
    final phoneRenderBox = phoneIconKey.currentContext?.findRenderObject() as RenderBox?;
    final pillRenderBox = progressPillKey.currentContext?.findRenderObject() as RenderBox?;

    if (phoneRenderBox == null || pillRenderBox == null) {
      onComplete?.call();
      return;
    }

    // Berechne die globalen Positionen (Overlay verwendet globale Koordinaten)
    final phonePosition = phoneRenderBox.localToGlobal(Offset.zero);
    final pillPosition = pillRenderBox.localToGlobal(Offset.zero);
    
    // Start-Position: Mitte des Handy-Icons (oben rechts, wo der Pfeil ist)
    final startPos = Offset(
      phonePosition.dx + phoneRenderBox.size.width * 0.8, // Rechts im Icon
      phonePosition.dy + phoneRenderBox.size.height * 0.2, // Oben im Icon
    );
    
    // End-Position: Share-Icon (ganz links in der Progress Pill)
    // Das Icon hat eine Größe von 16px und ist links positioniert
    // Mit horizontal padding von 12px ist das Icon-Zentrum bei etwa 12 + 8 = 20px von links
    const iconSize = 16.0;
    const horizontalPadding = 12.0;
    final iconCenterX = horizontalPadding + (iconSize / 2);
    
    // Vertikal: Mitte der Pill (Icon ist vertikal zentriert)
    final endPos = Offset(
      pillPosition.dx + iconCenterX,
      pillPosition.dy + pillRenderBox.size.height / 2,
    );
    
    debugPrint('📍 ArrowFly: Start=$startPos, End=$endPos');

    // Erstelle Overlay-Entry für die Animation
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          ArrowFlyAnimation(
            startPosition: startPos,
            endPosition: endPos,
            duration: const Duration(milliseconds: 800),
            onComplete: () {
              // Zauberpulver-Effekt an der Zahl in der Progress Pill
              _showSparkleEffect(
                context: context,
                progressPillKey: progressPillKey,
                counterKey: counterKey, // <-- NEU: Counter Key übergeben
                overlay: overlay,
              );
              
              overlayEntry.remove();
              onComplete?.call();
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_downward,
                size: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(overlayEntry);
  }

  /// Zeigt den Zauberpulver-Effekt an der Zahl in der Progress Pill
  static void _showSparkleEffect({
    required BuildContext context,
    required GlobalKey progressPillKey,
    GlobalKey? counterKey, // <-- NEU: Optionaler Key für den Counter
    required OverlayState overlay,
  }) {
    // Warte einen Frame, damit der Counter gerendert ist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Offset sparklePosition;
      
      // Wenn counterKey vorhanden ist, verwende die exakte Position des Counter-Texts
      // Overlays in Flutter verwenden globale Koordinaten (Screen-Koordinaten)
      if (counterKey != null) {
        final counterRenderBox = counterKey.currentContext?.findRenderObject() as RenderBox?;
        if (counterRenderBox != null) {
          // Globale Position des Counters
          final counterGlobalPos = counterRenderBox.localToGlobal(Offset.zero);
          // Mitte des Counter-Texts (horizontal und vertikal)
          sparklePosition = Offset(
            counterGlobalPos.dx + counterRenderBox.size.width / 2,
            counterGlobalPos.dy + counterRenderBox.size.height / 2,
          );
          debugPrint('✨ Sparkle-Effekt: Counter-Key gefunden!');
          debugPrint('   Counter Global: $counterGlobalPos');
          debugPrint('   Counter Size: ${counterRenderBox.size}');
          debugPrint('   Sparkle Position (global): $sparklePosition');
        } else {
          debugPrint('⚠️ Sparkle-Effekt: Counter-Key vorhanden, aber RenderBox null!');
          // Fallback: Berechne Position basierend auf der Progress Pill
          final pillRenderBox = progressPillKey.currentContext?.findRenderObject() as RenderBox?;
          if (pillRenderBox == null) return;
          final pillGlobalPos = pillRenderBox.localToGlobal(Offset.zero);
          const horizontalPadding = 12.0;
          const iconSize = 16.0;
          const spacing = 6.0;
          const textOffsetX = horizontalPadding + iconSize + spacing + 15.0;
          const textOffsetY = 12.0;
          sparklePosition = Offset(
            pillGlobalPos.dx + textOffsetX,
            pillGlobalPos.dy + textOffsetY,
          );
        }
      } else {
        // Fallback: Berechne Position basierend auf der Progress Pill
        final pillRenderBox = progressPillKey.currentContext?.findRenderObject() as RenderBox?;
        if (pillRenderBox == null) return;
        final pillGlobalPos = pillRenderBox.localToGlobal(Offset.zero);
        const horizontalPadding = 12.0;
        const iconSize = 16.0;
        const spacing = 6.0;
        const textOffsetX = horizontalPadding + iconSize + spacing + 15.0;
        const textOffsetY = 12.0;
        sparklePosition = Offset(
          pillGlobalPos.dx + textOffsetX,
          pillGlobalPos.dy + textOffsetY,
        );
      }

      // Erstelle Overlay-Entry für den Zauberpulver-Effekt
      // Positioned benötigt einen Stack als Parent
      late OverlayEntry sparkleEntry;
      sparkleEntry = OverlayEntry(
        builder: (context) => Stack(
          children: [
            SparkleParticleEffect(
              position: sparklePosition,
              color: const Color(0xFFF1C86B), // Goldene Farbe
              particleCount: 25,
              duration: const Duration(milliseconds: 1200),
              spreadRadius: 50.0,
              onComplete: () {
                sparkleEntry.remove();
              },
            ),
          ],
        ),
      );

      overlay.insert(sparkleEntry);
    });
  }
}

