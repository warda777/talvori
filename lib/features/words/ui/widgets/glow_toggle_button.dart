import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlowToggleButton extends StatelessWidget {
  final bool glowEnabled;
  final VoidCallback onToggle;
  final double width;

  const GlowToggleButton({
    super.key,
    required this.glowEnabled,
    required this.onToggle,
    this.width = 86,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = glowEnabled
        ? const Color(0xFFFFC66A)
        : const Color(0xFF3B2E1A);

    final List<BoxShadow> shadow = glowEnabled
        ? [
            BoxShadow(
              color: const Color(0xFFFFC66A).withOpacity(0.35),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.55),
              blurRadius: 16,
              spreadRadius: -3,
            ),
          ];

    final Gradient gradient = glowEnabled
        ? const RadialGradient(
            center: Alignment.center,
            radius: 0.9,
            colors: [Color(0xFFFFF5D6), Color(0xFFFFCB73), Color(0x00FFC66A)],
            stops: [0.0, 0.48, 1.0],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B140A), Color(0xFF15110A)],
          );

    final Color iconColor = glowEnabled
        ? const Color(0xFF4A320B)
        : const Color(0xFF8C7A5C);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onToggle();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: width,
        height: 36,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFF0E0A05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.6),
          boxShadow: shadow,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: gradient,
          ),
          child: Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.power_settings_new_rounded,
              size: 18,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
