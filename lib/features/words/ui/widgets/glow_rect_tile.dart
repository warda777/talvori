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
            color: const Color(0xFF2D2C2C),
            borderRadius: borderR,
            boxShadow: [
              BoxShadow(color: glowColor.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, -2)),
              BoxShadow(color: glowColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 4)),
              BoxShadow(color: glowColor.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 8)),
            ],
            border: Border.all(color: outlineColor, width: 1.5),
          ),
          child: Material(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: borderR),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: borderR,
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    icon,
                  ],
                ),
              ),
            ),
          ),
        ),
        if (badgeText != null && badgeText!.isNotEmpty)
          Positioned(
            top: -8,
            right: -30,
            child: _CountBadge(text: badgeText!, outlineColor: outlineColor, glowColor: glowColor),
          ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final String text;
  final Color outlineColor;
  final Color glowColor;

  const _CountBadge({
    required this.text,
    required this.outlineColor,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2C2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outlineColor, width: 1.5),
        boxShadow: [
          BoxShadow(color: glowColor.withOpacity(0.7), blurRadius: 3, offset: const Offset(0, -1)),
          BoxShadow(color: glowColor.withOpacity(0.7), blurRadius: 15, offset: const Offset(0, 5)),
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
