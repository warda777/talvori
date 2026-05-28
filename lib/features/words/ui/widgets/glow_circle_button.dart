import 'package:flutter/material.dart';

class GlowCircleButton extends StatelessWidget {
  final double size;
  final Widget child;
  final VoidCallback? onTap;
  final Color outlineColor;
  final Color glowColor;
  final Color? fillColor;
  final bool neonStyle;

  const GlowCircleButton({
    super.key,
    required this.size,
    required this.child,
    this.onTap,
    required this.outlineColor,
    required this.glowColor,
    this.fillColor,
    this.neonStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: fillColor ?? (neonStyle ? null : const Color(0xFF2D2C2C)),
          gradient: fillColor != null
              ? null
              : neonStyle
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF16161A), Color(0xFF050505)],
                )
              : null,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: neonStyle ? 0.1 : 0.5),
              blurRadius: neonStyle ? 6 : 8,
              offset: const Offset(0, -1),
            ),
            BoxShadow(
              color: const Color(
                0xFF8A5CFF,
              ).withValues(alpha: neonStyle ? 0.06 : 0.0),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: glowColor.withValues(alpha: neonStyle ? 0.05 : 0.4),
              blurRadius: neonStyle ? 14 : 24,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: outlineColor, width: neonStyle ? 1.8 : 1.5),
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(4.5),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: outlineColor.withValues(
                          alpha: neonStyle ? 0.72 : 0.45,
                        ),
                        width: neonStyle ? 1.15 : 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Center(child: child),
          ],
        ),
      ),
    );
  }
}
