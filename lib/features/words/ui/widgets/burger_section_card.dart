import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/widgets/mix_donut_toggle.dart';

class BurgerSectionCard extends StatelessWidget {
  final String title;
  final VoidCallback onSelectAll;
  final List<BurgerItem> items;
  final Color? background;
  final bool allSelected; // Ob alle Items ausgewählt sind

  const BurgerSectionCard({
    super.key,
    required this.title,
    required this.onSelectAll,
    required this.items,
    this.background,
    this.allSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = background ?? const Color(0xFF2D2D2E);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                ),
                // Nur "Pick all" anzeigen wenn mehr als 1 Item vorhanden ist
                // Verwende SizedBox mit fester Breite, um Platz zu reservieren
                if (items.length > 1)
                  TextButton(
                    onPressed: onSelectAll,
                    style: TextButton.styleFrom(
                      foregroundColor: allSelected 
                          ? Colors.white 
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    child: const Text('Pick all'),
                  )
                else
                  // Platzhalter für konsistente Höhe wenn kein "Pick all" vorhanden
                  const SizedBox(height: 40),
              ],
            ),
          ),

          // Burger
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    _BurgerRow(
                      label: items[i].label,
                      selected: items[i].selected,
                      onChanged: items[i].onChanged,
                      isTop: i == 0,
                      isBottom: i == items.length - 1,
                    ),
                    if (i != items.length - 1)
                      Divider(height: 1, thickness: 1, color: cs.outline.withOpacity(0.20)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BurgerItem {
  final String label;
  final bool selected;
  final ValueChanged<bool> onChanged;
  const BurgerItem({required this.label, required this.selected, required this.onChanged});
}

class _BurgerRow extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onChanged;
  final bool isTop;
  final bool isBottom;

  const _BurgerRow({
    required this.label,
    required this.selected,
    required this.onChanged,
    required this.isTop,
    required this.isBottom,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!selected),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2F2F3A) : Colors.transparent,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: cs.onSurface.withOpacity(0.86),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            MixDonutToggle(
              value: selected,
              onChanged: onChanged,
              activeRing: Colors.white,
              activeCore: const Color(0xFFF1C86B),
              size: 26,
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _InnerShadowPainter extends CustomPainter {
  final bool pressed;
  final bool isTop;
  final bool isBottom;
  final Color light;
  final Color dark;

  _InnerShadowPainter({
    required this.pressed,
    required this.isTop,
    required this.isBottom,
    required this.light,
    required this.dark,
  });

  @override
  void paint(Canvas c, Size size) {
    // Wir malen 4 schmale Gradients direkt am Rand der Row für Inset-Effekt.
    final double h = size.height;
    final double w = size.width;
    final double t = pressed ? 1.0 : 0.0;

    // Stärken - stärkerer Inset-Effekt wenn pressed
    final double band = ui.lerpDouble(12, 18, t)!;   // Breite/Höhe der Bänder (größer für stärkeren Effekt)
    final double topAlpha = ui.lerpDouble(0.12, 0.24, t)!;  // Stärkeres Highlight oben
    final double botAlpha = ui.lerpDouble(0.24, 0.38, t)!;  // Stärkerer Schatten unten
    final double sideLight = ui.lerpDouble(0.08, 0.16, t)!; // Stärkeres Highlight links
    final double sideDark  = ui.lerpDouble(0.18, 0.32, t)!; // Stärkerer Schatten rechts

    // TOP: Dunkler Schatten am Rand → heller nach innen (wirkt wie Einschnitt von oben)
    if (isTop || true) {
      final r = Rect.fromLTWH(0, 0, w, band);
      final p = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [
            dark.withOpacity(botAlpha * 0.8), // Dunkler Rand oben (Schatten)
            Colors.transparent,
          ],
        ).createShader(r);
      c.drawRect(r, p);
    }

    // BOTTOM: Heller Highlight am Rand → dunkler nach innen (Schatten unten wirkt tiefer)
    if (isBottom || true) {
      final r = Rect.fromLTWH(0, h - band, w, band);
      final p = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            dark.withOpacity(botAlpha), // Stärkerer Schatten unten
          ],
        ).createShader(r);
      c.drawRect(r, p);
    }

    // LEFT: Dunkler Schatten am Rand → heller nach innen (Einschnitt von links)
    {
      final r = Rect.fromLTWH(0, 0, band, h);
      final p = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft, end: Alignment.centerRight,
          colors: [
            dark.withOpacity(sideDark * 0.7), // Dunkler Rand links
            Colors.transparent,
          ],
        ).createShader(r);
      c.drawRect(r, p);
    }

    // RIGHT: Heller Highlight am Rand → dunkler nach innen (Schatten rechts wirkt tiefer)
    {
      final r = Rect.fromLTWH(w - band, 0, band, h);
      final p = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft, end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            dark.withOpacity(sideDark), // Stärkerer Schatten rechts
          ],
        ).createShader(r);
      c.drawRect(r, p);
    }
  }

  @override
  bool shouldRepaint(covariant _InnerShadowPainter old) =>
      old.pressed != pressed || old.isTop != isTop || old.isBottom != isBottom;
}


/// Leichtgewichtige „inner shadow“-Simulation mit 4 Kanten-Gradiens
class _InsetOverlay extends StatelessWidget {
  final bool pressed;
  final BorderRadius radius;
  const _InsetOverlay({required this.pressed, required this.radius});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // stärkerer Inset bei ausgewählt
    final double thick = pressed ? 18 : 14;

    return IgnorePointer(
      ignoring: true,
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(children: [
          // TOP highlight (hell → transparent)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: thick,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(pressed ? 0.20 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // BOTTOM shadow (transparent → dunkel)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: thick,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(pressed ? 0.38 : 0.30),
                  ],
                ),
              ),
            ),
          ),
          // LEFT inner gradient
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: thick,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft, end: Alignment.centerRight,
                  colors: [
                    Colors.white.withOpacity(pressed ? 0.14 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // RIGHT inner gradient
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: thick,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft, end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(pressed ? 0.28 : 0.22),
                  ],
                ),
              ),
            ),
          ),
          // feiner innerer Rand (optional, gibt „eingeschnitten")
          Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: cs.outline.withOpacity(0.18),
                width: 0.8,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
