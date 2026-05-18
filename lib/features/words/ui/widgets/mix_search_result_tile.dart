import 'package:flutter/material.dart';
import 'package:talvori/features/words/application/mix/mix_groups.dart';

class MixSearchResultTile extends StatelessWidget {
  final MixSearchResult result;
  final VoidCallback onTap;
  const MixSearchResultTile({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF5DDCFF);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF09111C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cyan.withValues(alpha: 0.28)),
          boxShadow: [
            BoxShadow(
              color: cyan.withValues(alpha: 0.08),
              blurRadius: 18,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.item,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    result.group,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white60),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.white60,
            ),
          ],
        ),
      ),
    );
  }
}
