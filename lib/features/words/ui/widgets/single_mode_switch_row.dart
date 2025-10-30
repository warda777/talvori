import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import 'stage_switch_row.dart'; // für StageDrag

Offset knobDragAnchorStrategy(Draggable<Object> draggable, BuildContext context, Offset globalPosition) {
  return const Offset(19.0, 80.0);
}

class SingleModeSwitchRow extends StatelessWidget {
  const SingleModeSwitchRow({
    super.key,
    required this.stageLabel,      // z.B. 'S2'
    required this.srcCount,
    required this.sr1Count,
    required this.sr2Count,
    required this.srPrefix,        // NEU
    this.innerStrokeColor,         // NEU
    required this.innerFillColor,  // NEU: dynamische Füllfarbe innen
    this.onBucketDrop,             // NEU
  });

  final String stageLabel;
  final int srcCount, sr1Count, sr2Count;
  // neu:
  final String srPrefix;              // z.B. 'T' / 'A' / '' (Hybrid)
  final Color? innerStrokeColor;      // Stroke-Farbe für die innere Kapsel
  final Color innerFillColor;         // Füllfarbe der inneren Kapsel
  final void Function(String fromBucket, String toBucket, int count)? onBucketDrop; // 'SRC'|'R1'|'R2'

  @override
  Widget build(BuildContext context) {
    Widget buildSwitch(String label, int count, {bool isFirst = false}) {
      // Gleiche Farben wie im S0-S5 Modus
      final Color outerColor = count > 0 
          ? (isFirst 
              ? const Color(0xFFA05260)  // Rot für den ersten Switch (S{n}) wenn aktiv
              : const Color(0xFFE4B866)) // Gold für andere aktive Switches
          : Colors.white;               // Inaktiv jetzt komplett Weiß
      
      final Color innerColor = innerFillColor; // aus Modus abgeleitet
      
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
                    child: () {
                      final Widget knobCore = AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        width: 38,
                        height: 52,
                        decoration: BoxDecoration(
                          color: innerColor,
                          borderRadius: BorderRadius.circular(21),
                          border: Border.all(color: (innerStrokeColor ?? Colors.white24), width: 1.6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$count',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      );
                      return LongPressDraggable<StageDrag>(
                        data: StageDrag(isFirst ? 0 : (label.endsWith('R1') ? 1 : 2), count: 1),
                        child: knobCore,
                        childWhenDragging: Opacity(opacity: 0.35, child: knobCore),
                        feedback: _KnobFeedback(count: count, innerColor: innerColor, stroke: innerStrokeColor),
                        dragAnchorStrategy: knobDragAnchorStrategy,
                        feedbackOffset: Offset.zero,
                        maxSimultaneousDrags: count > 0 ? 1 : 0,
                      );
                    }(),
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

    Widget _draggableBucket({required String bucket, required int count, required Widget child}) {
      final draggable = LongPressDraggable<StageDrag>(
        data: StageDrag(bucket == 'SRC' ? 0 : (bucket == 'R1' ? 1 : 2), count: 1),
        feedback: Opacity(opacity: 0.9, child: SizedBox(width: 38, height: 52, child: child)),
        childWhenDragging: Opacity(opacity: 0.35, child: child),
        dragAnchorStrategy: pointerDragAnchorStrategy,
        maxSimultaneousDrags: count > 0 ? 1 : 0,
        child: child,
      );
      return DragTarget<StageDrag>(
        onWillAccept: (d) => d != null,
        onAccept: (d) {
          final from = (d.fromStage == 0) ? 'SRC' : (d.fromStage == 1 ? 'R1' : 'R2');
          onBucketDrop?.call(from, bucket, d.count);
        },
        builder: (_, __, ___) => draggable,
      );
    }

    return Row(mainAxisSize: MainAxisSize.min, children: [
      _draggableBucket(
        bucket: 'SRC',
        count: srcCount,
        child: buildSwitch(stageLabel, srcCount, isFirst: true),
      ),
      _draggableBucket(
        bucket: 'R1',
        count: sr1Count,
        child: buildSwitch('${srPrefix}R1', sr1Count),
      ),
      _draggableBucket(
        bucket: 'R2',
        count: sr2Count,
        child: buildSwitch('${srPrefix}R2', sr2Count),
      ),
    ]);
  }
}

class _KnobFeedback extends StatelessWidget {
  final int count;
  final Color innerColor;
  final Color? stroke;
  const _KnobFeedback({required this.count, required this.innerColor, this.stroke});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: 38, height: 52,
        child: Container(
          decoration: BoxDecoration(
            color: innerColor,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: (stroke ?? Colors.white24), width: 1.6),
          ),
          alignment: Alignment.center,
          child: Text(
            '$count',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
