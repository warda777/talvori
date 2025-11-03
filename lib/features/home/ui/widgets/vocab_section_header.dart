import 'package:flutter/material.dart';

class VocabSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const VocabSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: t.textTheme.labelMedium?.copyWith(letterSpacing: 1.0)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: t.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
