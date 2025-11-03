import 'package:flutter/material.dart';

class ProfileTile extends StatelessWidget {
  final String label;
  final bool locked;
  final VoidCallback? onTap;

  const ProfileTile({
    super.key,
    required this.label,
    this.locked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: t.colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.colorScheme.outlineVariant),
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
                  child: Text(label, style: t.textTheme.bodyMedium),
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
