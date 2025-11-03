import 'package:flutter/material.dart';

class VocabTile extends StatelessWidget {
  final String title;
  final bool locked;
  final VoidCallback? onTap;

  const VocabTile({
    super.key,
    required this.title,
    this.locked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D2C2C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: locked ? null : onTap,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(title, style: t.textTheme.bodyMedium),
                ),
              ),
              if (locked)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.lock_outline, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
