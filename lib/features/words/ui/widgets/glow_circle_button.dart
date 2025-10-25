import 'package:flutter/material.dart';

class GlowCircleButton extends StatelessWidget {
  final double size;
  final Widget child;
  final VoidCallback? onTap;
  final Color outlineColor;
  final Color glowColor;

  const GlowCircleButton({
    super.key,
    required this.size,
    required this.child,
    this.onTap,
    required this.outlineColor,
    required this.glowColor,
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
            color: const Color(0xFF2D2C2C),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: glowColor.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, -2)),
              BoxShadow(color: glowColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 4)),
              BoxShadow(color: glowColor.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 8)),
            ],
            border: Border.all(color: outlineColor, width: 1.5),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
