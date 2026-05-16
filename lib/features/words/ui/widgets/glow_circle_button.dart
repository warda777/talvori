import 'package:flutter/material.dart';

class GlowCircleButton extends StatelessWidget {
  final double size;
  final Widget child;
  final VoidCallback? onTap;
  final Color outlineColor;
  final Color glowColor;
  final bool neonStyle;

  const GlowCircleButton({
    super.key,
    required this.size,
    required this.child,
    this.onTap,
    required this.outlineColor,
    required this.glowColor,
    this.neonStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: neonStyle ? null : const Color(0xFF2D2C2C),
            gradient: neonStyle
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
            border: Border.all(
              color: outlineColor,
              width: neonStyle ? 1.8 : 1.5,
            ),
          ),
          foregroundDecoration: neonStyle
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                    width: 0.7,
                  ),
                )
              : null,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (neonStyle)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(
                              0xFF8DBBFF,
                            ).withValues(alpha: 0.26),
                            width: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF8DBBFF,
                              ).withValues(alpha: 0.05),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
