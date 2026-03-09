import 'dart:async';
import 'package:flutter/material.dart';

/// Kontextueller Tooltip: kleine dunkle Sprechblase mit Pfeil zum Ziel-Element.
/// - Max. 2 Zeilen Text
/// - Auto-Dismiss nach 3–4 Sekunden
/// - Dismiss bei Tap außerhalb
/// - Keine Buttons
class ContextualTooltip {
  ContextualTooltip._();

  /// Zeigt den Tooltip als Overlay.
  static Future<void> show({
    required BuildContext context,
    required String line1,
    required String line2,
    required GlobalKey targetKey,
  }) async {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    void dismiss() {
      entry.remove();
    }

    entry = OverlayEntry(
      builder: (ctx) => _ContextualTooltipOverlay(
        line1: line1,
        line2: line2,
        targetKey: targetKey,
        onDismiss: dismiss,
      ),
    );
    overlay.insert(entry);
  }
}

class _ContextualTooltipOverlay extends StatefulWidget {
  final String line1;
  final String line2;
  final GlobalKey targetKey;
  final VoidCallback onDismiss;

  const _ContextualTooltipOverlay({
    required this.line1,
    required this.line2,
    required this.targetKey,
    required this.onDismiss,
  });

  @override
  State<_ContextualTooltipOverlay> createState() =>
      _ContextualTooltipOverlayState();
}

class _ContextualTooltipOverlayState extends State<_ContextualTooltipOverlay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 5500), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.transparent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final targetBox = widget.targetKey.currentContext?.findRenderObject()
                as RenderBox?;
            if (targetBox == null || !targetBox.hasSize) {
              return const SizedBox.shrink();
            }
            final targetPos = targetBox.localToGlobal(Offset.zero);
            final targetSize = targetBox.size;
            final targetRect = Rect.fromLTWH(
              targetPos.dx,
              targetPos.dy,
              targetSize.width,
              targetSize.height,
            );

            const bubbleBg = Color(0xFF4A3542);
            const bubbleBorder = Color(0xFFA05260);
            const padding = EdgeInsets.symmetric(horizontal: 14, vertical: 10);
            const arrowSize = 8.0;
            const borderRadius = 12.0;
            const maxWidth = 220.0;
            const estimatedBubbleH = 64.0;

            final text = widget.line2.isEmpty
                ? widget.line1
                : '${widget.line1}\n${widget.line2}';
            final textWidget = Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFF0F4F8),
                height: 1.35,
              ),
              maxLines: 3,
            );

            final targetCenter = targetRect.center;
            final targetTop = targetRect.top;
            final targetBottom = targetRect.bottom;

            final bubbleLeft = (targetCenter.dx - maxWidth / 2)
                .clamp(12.0, constraints.maxWidth - maxWidth - 12);

            double bubbleTop;
            if (targetTop - estimatedBubbleH - arrowSize - 12 > 0) {
              bubbleTop = targetTop - estimatedBubbleH - arrowSize - 12;
            } else {
              bubbleTop = targetBottom + arrowSize + 12;
            }

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: bubbleLeft,
                  top: bubbleTop,
                  child: Container(
                    width: maxWidth,
                    padding: padding,
                    decoration: BoxDecoration(
                      color: bubbleBg,
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(color: bubbleBorder, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFA05260).withOpacity(0.5),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: textWidget,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
