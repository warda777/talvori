import 'package:flutter/material.dart';
import 'arrow_fly_animation.dart';

/// Service-Klasse, die die Flug-Animation des Pfeils verwaltet
class ArrowFlyService {
  /// Startet die Flug-Animation vom Handy-Icon zur Progress Pill
  static void startArrowFlyAnimation({
    required BuildContext context,
    required GlobalKey phoneIconKey,
    required GlobalKey progressPillKey,
    VoidCallback? onComplete,
  }) {
    // Hole die Positionen der beiden Widgets
    final phoneRenderBox = phoneIconKey.currentContext?.findRenderObject() as RenderBox?;
    final pillRenderBox = progressPillKey.currentContext?.findRenderObject() as RenderBox?;

    if (phoneRenderBox == null || pillRenderBox == null) {
      onComplete?.call();
      return;
    }

    // Berechne die globalen Positionen
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

    // Erstelle Overlay-Entry für die Animation
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => ArrowFlyAnimation(
        startPosition: startPos,
        endPosition: endPos,
        duration: const Duration(milliseconds: 800),
        onComplete: () {
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
    );

    overlay.insert(overlayEntry);
  }
}

