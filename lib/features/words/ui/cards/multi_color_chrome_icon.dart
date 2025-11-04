import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:flutter/services.dart';

/// Widget, das ein SVG-Icon mit mehreren Farben einfärbt
/// Die verschiedenen Elemente des SVG werden unterschiedlich gefärbt
class MultiColorChromeIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color centerColor;      // B1CCFF
  final Color topColor;         // FAD17D (gelb/gold)
  final Color rightColor;       // A05260 (rötlich)
  final Color leftColor;        // Grün

  const MultiColorChromeIcon({
    super.key,
    required this.assetPath,
    this.size = 56,
    this.centerColor = const Color(0xFFB1CCFF),
    this.topColor = const Color(0xFFFAD17D),
    this.rightColor = const Color(0xFFA05260),
    this.leftColor = const Color(0xFF4CAF50),
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: rootBundle.loadString(assetPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(width: size, height: size, child: const Center(child: CircularProgressIndicator(strokeWidth: 2)));
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          // Fallback: normales SVG ohne Farben
          return SizedBox(
            width: size,
            height: size,
            child: SvgPicture.asset(
              assetPath,
              width: size,
              height: size,
            ),
          );
        }

        final svgString = snapshot.data!;
        
        try {
          // Ersetze die Farben im SVG-String
          String coloredSvg = _colorizeSvg(svgString);

          return SizedBox(
            width: size,
            height: size,
            child: SvgPicture.string(
              coloredSvg,
              fit: BoxFit.contain,
              width: size,
              height: size,
            ),
          );
        } catch (e) {
          // Bei Fehler: normales SVG ohne Farben
          return SizedBox(
            width: size,
            height: size,
            child: SvgPicture.asset(
              assetPath,
              width: size,
              height: size,
            ),
          );
        }
      },
    );
  }

  String _colorizeSvg(String svgString) {
    String result = svgString;
    
    // Finde alle <path> Elemente (die meisten SVG-Icons verwenden <path>)
    final pathRegex = RegExp(r'<path([^>]*)>', multiLine: true);
    final matches = pathRegex.allMatches(result).toList();
    
    if (matches.isEmpty) {
      // Falls keine <path> gefunden, suche nach <circle> oder anderen Elementen
      final circleRegex = RegExp(r'<circle([^>]*)>', multiLine: true);
      final circleMatches = circleRegex.allMatches(result).toList();
      
      if (circleMatches.isEmpty) {
        return result; // Keine färbbaren Elemente gefunden
      }
      
      return _applyColors(result, circleMatches, 'circle');
    }
    
    return _applyColors(result, matches, 'path');
  }
  
  String _applyColors(String svgString, List<RegExpMatch> matches, String tagName) {
    // Farben für die verschiedenen Elemente
    final colors = [
      centerColor, // Index 0: Mitte
      topColor,    // Index 1: Oben
      rightColor,  // Index 2: Rechts
      leftColor,   // Index 3: Links
    ];
    
    StringBuffer buffer = StringBuffer();
    int lastEnd = 0;
    
    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];
      
      // Füge Text vor dem Match hinzu
      buffer.write(svgString.substring(lastEnd, match.start));
      
      // Wähle Farbe basierend auf Index (wiederhole bei mehr als 4 Elementen)
      final color = colors[i % colors.length];
      final hexColor = '#${color.value.toRadixString(16).substring(2).padLeft(6, '0')}';
      
      // Hole den Inhalt des Tags (Attribute)
      final tagContent = match.group(1) ?? '';
      
      // Entferne vorhandene fill/stroke Attribute
      String cleanContent = tagContent
          .replaceAll(RegExp(r'\s*fill="[^"]*"'), '')
          .replaceAll(RegExp(r'\s*stroke="[^"]*"'), '');
      
      // Entferne fill aus style-Attributen
      cleanContent = cleanContent.replaceAllMapped(
        RegExp(r'style="([^"]*)"'),
        (match) {
          String styleContent = match.group(1) ?? '';
          styleContent = styleContent.replaceAll(RegExp(r'fill:\s*[^;]*;?\s*'), '');
          styleContent = styleContent.replaceAll(RegExp(r'stroke:\s*[^;]*;?\s*'), '');
          return 'style="$styleContent"';
        },
      );
      
      // Füge fill-Attribut hinzu (mit Leerzeichen falls nötig)
      final separator = cleanContent.trim().isEmpty ? '' : ' ';
      final newTag = '<$tagName$cleanContent$separator fill="$hexColor">';
      buffer.write(newTag);
      
      lastEnd = match.end;
    }
    
    // Füge den restlichen Text hinzu
    buffer.write(svgString.substring(lastEnd));
    
    return buffer.toString();
  }
}

