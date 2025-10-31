import 'package:flutter/material.dart';

class MixTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onMore;
  const MixTopBar({super.key, required this.onBack, required this.onMore});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: onBack,
            style: IconButton.styleFrom(
              foregroundColor: cs.onSurface,
              backgroundColor: Colors.transparent,
            ),
          ),
          const SizedBox(width: 8),
          Text('Make your own mix',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
            onPressed: onMore,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF2C2C2E),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
