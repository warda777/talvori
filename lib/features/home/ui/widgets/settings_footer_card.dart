import 'package:flutter/material.dart';

class SettingsFooterCard extends StatelessWidget {
  final String appVersion;
  final String userId;
  final VoidCallback? onCopy;

  const SettingsFooterCard({
    super.key,
    required this.appVersion,
    required this.userId,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = t.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceVariant.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: DefaultTextStyle(
              style: t.textTheme.bodySmall!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vocabulary app · Version $appVersion'),
                  const SizedBox(height: 6),
                  Text(
                    'User ID: $userId',
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Copy User ID',
            onPressed: onCopy,
            icon: const Icon(Icons.copy_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}
