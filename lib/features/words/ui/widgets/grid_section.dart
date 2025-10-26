import 'package:flutter/material.dart';
import 'package:talvori/features/words/data/word_hub_taxonomy.dart';
import 'category_card.dart';

class GridSection extends StatelessWidget {
  final String sectionKey;
  final List<HubSubcat> subs;
  final void Function(HubSubcat sub)? onTapSub;

  const GridSection({
    required this.sectionKey,
    required this.subs,
    this.onTapSub,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) => CategoryCard(
            sectionKey: sectionKey,
            sub: subs[i],
            onTap: onTapSub == null ? null : () => onTapSub!(subs[i]),
          ),
          childCount: subs.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
      ),
    );
  }
}
