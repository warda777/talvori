import 'package:flutter/material.dart';

class GlowRectTile extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final String title;
  final Widget icon;
  final VoidCallback? onTap;
  final Color outlineColor;
  final Color glowColor;
  final String? badgeText;
  final bool neonStyle;

  const GlowRectTile({
    super.key,
    required this.width,
    required this.height,
    required this.radius,
    required this.title,
    required this.icon,
    this.onTap,
    this.outlineColor = Colors.white,
    this.glowColor = Colors.white,
    this.badgeText,
    this.neonStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderR = BorderRadius.circular(radius);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: neonStyle ? null : const Color(0xFF2D2C2C),
            gradient: neonStyle
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF16161A), Color(0xFF050505)],
                  )
                : null,
            borderRadius: borderR,
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
                offset: const Offset(0, 4),
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
                  borderRadius: borderR,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                    width: 0.7,
                  ),
                )
              : null,
          child: Material(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: borderR),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: borderR,
              onTap: onTap,
              child: Stack(
                children: [
                  if (neonStyle)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                radius > 4 ? radius - 4 : radius,
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                                width: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        icon,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (badgeText != null && badgeText!.isNotEmpty)
          Positioned(
            top: -8,
            right: -30,
            child: _CountBadge(
              text: badgeText!,
              outlineColor: outlineColor,
              glowColor: glowColor,
              neonStyle: neonStyle,
            ),
          ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final String text;
  final Color outlineColor;
  final Color glowColor;
  final bool neonStyle;

  const _CountBadge({
    required this.text,
    required this.outlineColor,
    required this.glowColor,
    required this.neonStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: neonStyle ? const Color(0xFF0B0B0D) : const Color(0xFF2D2C2C),
        borderRadius: BorderRadius.circular(neonStyle ? 16 : 12),
        border: Border.all(color: outlineColor, width: neonStyle ? 1.7 : 1.5),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: neonStyle ? 0.12 : 0.7),
            blurRadius: neonStyle ? 4 : 3,
            offset: const Offset(0, -1),
          ),
          BoxShadow(
            color: const Color(
              0xFF8A5CFF,
            ).withValues(alpha: neonStyle ? 0.07 : 0.0),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.fade,
        softWrap: false,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
