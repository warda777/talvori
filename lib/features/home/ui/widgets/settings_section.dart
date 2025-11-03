import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Überschrift wie im Mockup (Kapitälchen-Feeling)
          Text(
            title.toUpperCase(),
            style: t.textTheme.labelMedium?.copyWith(
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          // Burger-Style Grouping
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2E),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < children.length; i++) ...[
                    children[i],
                    if (i != children.length - 1)
                      Divider(height: 1, thickness: 1, color: cs.outline.withOpacity(0.20)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
