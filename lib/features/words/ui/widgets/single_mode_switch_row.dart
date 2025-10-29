import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';

class SingleModeSwitchRow extends StatelessWidget {
  const SingleModeSwitchRow({
    super.key,
    required this.stageLabel,      // z.B. 'S2'
    required this.srcCount,
    required this.sr1Count,
    required this.sr2Count,
  });

  final String stageLabel;
  final int srcCount, sr1Count, sr2Count;

  @override
  Widget build(BuildContext context) {
    Widget buildSwitch(String label, int count, {bool isFirst = false}) {
      // Gleiche Farben wie im S0-S5 Modus
      final Color outerColor = count > 0 
          ? (isFirst 
              ? const Color(0xFFA05260)  // Rot für den ersten Switch (S{n}) wenn aktiv
              : const Color(0xFFE4B866)) // Gold für andere aktive Switches
          : Colors.grey;                // Grau für inaktive Switches
      
      final Color innerColor = const Color(0xFF2D2C2C); // Immer dunkelgrau für die innere Kapsel
      
      final bool highlight = count > 0 && count < 100; // Glow nur wenn 1-99 Karten
      
      // Glow nur für den äußeren Container (Gold oder Rot), nicht für die innere Kapsel
      final List<BoxShadow>? boxShadow = highlight
          ? [BoxShadow(color: outerColor.withOpacity(0.8), blurRadius: 14, spreadRadius: 1)]
          : null;

      return Container(
        margin: const EdgeInsets.only(right: 8), // WordsUIConstants.switchGap
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: WordsUIConstants.stageSwitchWidth,
              height: WordsUIConstants.stageSwitchHeight,
              decoration: BoxDecoration(
                color: outerColor,
                borderRadius: BorderRadius.circular(WordsUIConstants.stageSwitchRadius),
                boxShadow: boxShadow,
                border: Border.all(color: Colors.black.withOpacity(0.2), width: 1),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    left: 2,
                    right: 2,
                    top: count > 0 ? 2.0 : 18.0, // _getSwitchPosition()
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: 38,
                      height: 52,
                      decoration: BoxDecoration(
                        color: innerColor,
                        borderRadius: BorderRadius.circular(21),
                        border: Border.all(color: Colors.white24, width: 1),
                        // KEIN Glow für die innere Kapsel - nur für den äußeren Container
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
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Row(mainAxisSize: MainAxisSize.min, children: [
      buildSwitch(stageLabel, srcCount, isFirst: true), // ← S{n} (Quelle) mit roter Farbe
      buildSwitch('SR1', sr1Count),
      buildSwitch('SR2', sr2Count),
    ]);
  }
}
