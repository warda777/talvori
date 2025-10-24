import 'package:flutter/material.dart';

class RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const RoundIcon({super.key, required this.icon, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2F),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white70),
        ),
      ),
    );
  }
}
