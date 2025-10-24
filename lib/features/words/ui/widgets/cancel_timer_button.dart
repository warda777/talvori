import 'package:flutter/material.dart';

class CancelTimerButton extends StatelessWidget {
  final VoidCallback onTap;

  const CancelTimerButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2F),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.close_rounded, color: Colors.red, size: 24),
        ),
      ),
    );
  }
}
