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
  final String? subNote; // optional: z.B. Timer/Countdown unterhalb des Labels
  final Color? subNoteColor; // optional: Farbe für subNote (z.B. grün wenn Timer läuft)
  final bool isFirst;
  final bool glow; // NEU: für Blink-Effekt
  final Animation<double>? pulseAnimation; // NEU: für sanftes Pulsieren
  final bool selectedHighlight; // NEU: für Single-Modus Hervorhebung
  final Color? innerStrokeColor; // NEU: injizierbarer Stroke der inneren Kapsel
  final Widget Function(Widget knob)? knobWrapper; // optionaler Wrapper nur um den Knopf
  final bool isLocked;              // ← NEU: nur für Opacity (Switch ausgrauen)
  final int? learnedCount; // optionaler zweiter Counter (z.B. "gelernt" in S5)
  final bool showLearnedCount; // explizites Feature-Flag, damit andere Screens nicht beeinflusst werden

  final Key? containerKey; // Key für den äußeren Container (für Plasma-Link Positionierung)
  
  const VerticalStageSwitch({
    super.key,
    this.containerKey,
    required this.count,
    required this.outerColor,
    required this.innerColor,
    required this.highlight,
    required this.completed,
    required this.label,
    required this.note,
    this.subNote,
    this.subNoteColor,
    this.isFirst = false,
    this.glow = false, // NEU: Standard false
    this.pulseAnimation, // NEU: für sanftes Pulsieren
    this.selectedHighlight = false, // NEU: für Single-Modus Hervorhebung
    this.innerStrokeColor,
    this.knobWrapper,
    this.isLocked = false,          // ← NEU (Default)
    this.learnedCount,
    this.showLearnedCount = false,
  });

  /// Bei S0+Lock: Knopf unten (deaktiviert). Sonst: oben wenn count>0, unten wenn leer.
  double _getSwitchPosition() =>
      (isLocked && isFirst) ? 18.0 : (count > 0 ? 2.0 : 18.0);

  @override
  Widget build(BuildContext context) {
    final badgeGlow = highlight
        ? [BoxShadow(color: outerColor.withOpacity(0.8), blurRadius: 14, spreadRadius: 1)]
        : const <BoxShadow>[];

    // Learned-Counter nur anzeigen, wenn S5 auch tatsächlich Wörter hat (count > 0)
    final bool canShowLearnedBadge = showLearnedCount && learnedCount != null && count > 0;
    const double knobHeight = 52.0;
    const double learnedBadgeHeight = 16.0;
    // "Unterhalb des Knobs" (bei count>0 liegt der Knob oben; darunter ist Platz).
    // Clamp verhindert Overflow, falls sich Switch-Height in Zukunft ändert.
    final double learnedBadgeTop = (_getSwitchPosition() + knobHeight + 4.0)
        .clamp(4.0, WordsUIConstants.stageSwitchHeight - learnedBadgeHeight - 4.0);

    return Padding(
      padding: EdgeInsets.only(left: isFirst ? 6 : 0, right: isFirst ? 4 : 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Die Switch selbst: Bei S0+Lock → X statt Count; sonst ggf. ausgegraut
          Opacity(
            opacity: (isLocked && isFirst) ? 1.0 : (isLocked ? 0.45 : 1.0),
            child: Container(
              key: containerKey ?? key, // Key auf dem äußeren Container (für Plasma-Link Positionierung)
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

                              final Widget knobCore = AnimatedContainer(
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
                                child: (isLocked && isFirst)
                                    ? const Icon(Icons.close, size: 32, color: Colors.white)
                                    : Text(
                                        '$count',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              );
                              final Widget knob = knobWrapper != null ? knobWrapper!(knobCore) : knobCore;
                              return knob;
                            },
                          )
                        : () {
                            final Widget knobCore = AnimatedContainer(
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
                            child: (isLocked && isFirst)
                                ? const Icon(Icons.close, size: 32, color: Colors.white)
                                : Text(
                                    '$count',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                            );
                            final Widget knob = knobWrapper != null ? knobWrapper!(knobCore) : knobCore;
                            return knob;
                          }(),
                  ),
                  if (canShowLearnedBadge)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: learnedBadgeTop,
                      child: Center(
                        child: SizedBox(
                          height: learnedBadgeHeight,
                          child: Text(
                            '${learnedCount!}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 42,
            child: Stack(
              clipBehavior: Clip.none, // ✅ Timer darf rausmalen, ohne Layout zu vergrößern
              alignment: Alignment.topCenter,
              children: [
                Text(
                  note,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                ),
                if (subNote != null && subNote!.isNotEmpty)
                  Positioned(
                    top: 14, // direkt unter dem Label, ohne die Switch-Höhe zu verändern
                    left: -6,
                    right: -6,
                    child: Text(
                      subNote!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: (subNoteColor ?? Colors.white).withOpacity(0.9),
                        height: 1.0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
