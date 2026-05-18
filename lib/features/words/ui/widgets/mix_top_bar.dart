import 'package:flutter/material.dart';

class MixTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onMore;
  const MixTopBar({super.key, required this.onBack, required this.onMore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: onBack,
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF0C1622),
              side: BorderSide(
                color: const Color(0xFF5DDCFF).withValues(alpha: 0.32),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Eigenen Mix erstellen',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 56),
        ],
      ),
    );
  }
}
