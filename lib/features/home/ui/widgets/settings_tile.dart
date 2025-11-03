import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool external; // zeigt statt Chevron ein "↗" Icon

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.external = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: t.textTheme.bodyMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle!, style: t.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              Icon(
                external ? Icons.open_in_new_rounded : Icons.chevron_right_rounded,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
