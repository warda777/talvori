import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';

class VerticalStageSwitch extends StatelessWidget {
  final int count;
  final Color outerColor;
  final Color innerColor;
  final bool highlight;
  final bool completed;
  final String label; // "S1" / "New" (nur für Semantik)
  final String note;  // "0".."5"
  final bool isFirst;
  final bool glow; // NEU: für Blink-Effekt
  final Animation<double>? pulseAnimation; // NEU: für sanftes Pulsieren
  final bool selectedHighlight; // NEU: für Single-Modus Hervorhebung
  final Color? innerStrokeColor; // NEU: injizierbarer Stroke der inneren Kapsel

  const VerticalStageSwitch({
    super.key,
    required this.count,
    required this.outerColor,
    required this.innerColor,
    required this.highlight,
    required this.completed,
    required this.label,
    required this.note,
    this.isFirst = false,
    this.glow = false, // NEU: Standard false
    this.pulseAnimation, // NEU: für sanftes Pulsieren
    this.selectedHighlight = false, // NEU: für Single-Modus Hervorhebung
    this.innerStrokeColor,
  });

  double _getSwitchPosition() => count > 0 ? 2.0 : 18.0;

  @override
  Widget build(BuildContext context) {
    final badgeGlow = highlight
        ? [BoxShadow(color: outerColor.withOpacity(0.8), blurRadius: 14, spreadRadius: 1)]
        : const <BoxShadow>[];

    return Padding(
      padding: EdgeInsets.only(left: isFirst ? 6 : 0, right: isFirst ? 4 : 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: WordsUIConstants.stageSwitchWidth,
            height: WordsUIConstants.stageSwitchHeight,
            decoration: BoxDecoration(
              color: outerColor,
              borderRadius: BorderRadius.circular(WordsUIConstants.stageSwitchRadius),
              boxShadow: badgeGlow,
              border: Border.all(color: Colors.black.withOpacity(0.2), width: 1),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  left: 2,
                  right: 2,
                  top: _getSwitchPosition(),
                  child: pulseAnimation != null
                      ? AnimatedBuilder(
                          animation: pulseAnimation!,
                          builder: (context, child) {
                            final double soft = 0.15 + 0.35 * pulseAnimation!.value; // 0.15..0.5
                            final Color glowColor = const Color(0xFF00FF88);
                            final Color accentColor = const Color(0xFF6FD3FF); // hellblau für "gewählt"
                            final List<BoxShadow>? boxShadow = glow
                                ? [
                                    BoxShadow(
                                      color: glowColor.withOpacity(0.85),
                                      blurRadius: 16,
                                      spreadRadius: 1.5,
                                    ),
                                  ]
                                : (selectedHighlight
                                    ? [
                                        BoxShadow(
                                          color: accentColor.withOpacity(0.5),
                                          blurRadius: 14,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: glowColor.withOpacity(soft),
                                          blurRadius: 18,
                                          spreadRadius: 2.0,
                                        ),
                                      ]);

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              width: 38,
                              height: 52,
                              decoration: BoxDecoration(
                                color: innerColor,
                                borderRadius: BorderRadius.circular(21),
                                border: glow
                                    ? Border.all(color: glowColor, width: 1)
                                    : (selectedHighlight
                                        ? Border.all(color: accentColor, width: 1)
                                        : Border.all(color: innerStrokeColor ?? Colors.white24, width: 1.6)),
                                boxShadow: boxShadow,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        )
                      : AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          width: 38,
                          height: 52,
                          decoration: BoxDecoration(
                            color: innerColor,
                            borderRadius: BorderRadius.circular(21),
                            border: glow
                                ? Border.all(color: const Color(0xFF00FF88), width: 1)
                                : (selectedHighlight
                                    ? Border.all(color: const Color(0xFF6FD3FF), width: 1)
                                    : Border.all(color: innerStrokeColor ?? Colors.white24, width: 1.6)),
                            boxShadow: glow
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF00FF88).withOpacity(0.85), // Grün-Glow
                                      blurRadius: 16,
                                      spreadRadius: 1.5,
                                    ),
                                  ]
                                : (selectedHighlight
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF6FD3FF).withOpacity(0.5),
                                          blurRadius: 14,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 42,
            child: Text(
              note,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
