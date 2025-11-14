import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../application/radial_palette_controller.dart';

/// Widget das einen gebogenen Text oben im Farbring anzeigt
class CurvedToolLabel extends StatelessWidget {
  const CurvedToolLabel({
    super.key,
    required this.size,
    required this.radius,
    required this.tool,
  });

  final double size;
  final double radius;
  final PaletteTool? tool;

  String _getToolLabel(PaletteTool tool) {
    return switch (tool) {
      PaletteTool.stroke => 'STROKE',
      PaletteTool.fill => 'FILL',
      PaletteTool.text => 'TEXT',
      PaletteTool.hubBackground => 'BACKGROUND',
      PaletteTool.glow => 'GLOW',
      PaletteTool.icon => 'ICON',
      PaletteTool.image => 'IMAGE',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (tool == null) return const SizedBox.shrink();

    return CustomPaint(
      size: Size(size, size),
      painter: _CurvedTextPainter(
        text: _getToolLabel(tool!),
        radius: radius,
      ),
    );
  }
}

class _CurvedTextPainter extends CustomPainter {
  _CurvedTextPainter({
    required this.text,
    required this.radius,
  });

  final String text;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Text unten unterhalb des Rings positionieren (bei 90 Grad = unten)
    final startAngle = math.pi / 2; // Unten starten
    
    // Winkel-Bereich für den Text (etwa 100 Grad für bessere Lesbarkeit)
    final arcLength = 100 * math.pi / 180; // ~100 Grad
    final anglePerChar = arcLength / (text.length - 1); // -1 damit letzter Buchstabe am Ende ist
    
    final textStyle = TextStyle(
      color: Colors.grey.shade400, // Grau statt weiß
      fontSize: 20,
      fontWeight: FontWeight.w200, // Dünner (vorher w500)
      letterSpacing: 3,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.7),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    );
    
    final textPainter = TextPainter(
      text: TextSpan(text: '', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    
    // Jeden Buchstaben einzeln zeichnen (von rechts nach links für Spiegelung um Y-Achse)
    for (int i = 0; i < text.length; i++) {
      // Buchstaben-Reihenfolge umkehren für Spiegelung um Y-Achse
      final reversedIndex = text.length - 1 - i;
      final char = text[reversedIndex];
      // Text zentriert um unten (startAngle)
      final charAngle = startAngle + (i - (text.length - 1) / 2) * anglePerChar;
      
      // Position auf dem Kreis
      final x = center.dx + radius * math.cos(charAngle);
      final y = center.dy + radius * math.sin(charAngle);
      
      // Text-Painter für diesen Buchstaben
      textPainter.text = TextSpan(
        text: char,
        style: textStyle,
      );
      textPainter.layout();
      
      // Rotation: Text steht tangential zum Kreis (wie vorher)
      canvas.save();
      canvas.translate(x, y);
      // Text tangential zum Kreis ausrichten
      canvas.rotate(charAngle + math.pi / 2); // +90° damit Text tangential steht
      // Schriftzug um X-Achse spiegeln (nur der Text, nicht die Position)
      canvas.scale(1.0, -1.0);
      // Jeden Buchstaben um seine eigene Y-Achse spiegeln (horizontal spiegeln)
      canvas.scale(-1.0, 1.0);
      
      // Text zentriert zeichnen
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CurvedTextPainter oldDelegate) =>
      oldDelegate.text != text || oldDelegate.radius != radius;
}

