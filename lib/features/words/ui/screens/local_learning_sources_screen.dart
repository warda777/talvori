import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
import 'package:talvori/core/local_database/services/shared_text_import_service.dart';
import 'package:talvori/features/words/ui/screens/local_learning_source_detail_screen.dart';

class LocalLearningSourcesScreen extends ConsumerWidget {
  const LocalLearningSourcesScreen({super.key});

  static const routeName = 'local-learning-sources';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(
      localWordCountProvider(localMyWordsCategoryId),
    );
    final myWordsCount = countAsync.valueOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFF050912),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050912),
        elevation: 0,
        title: const Text('Wortquellen'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(
              'Wähle aus, womit du lokal lernen möchtest.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFFB8C7D9),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.08,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _SourceTile(
                  key: const Key('local-source-all-words-tile'),
                  label: 'Alle Wörter',
                  subtitle: _countSubtitle(myWordsCount),
                  icon: Icons.auto_stories_rounded,
                  accent: const Color(0xFF5DDCFF),
                  onTap: () => _openSource(context, 'all_words'),
                ),
                _SourceTile(
                  key: const Key('local-source-favorites-tile'),
                  label: 'Favoriten',
                  icon: Icons.favorite_rounded,
                  accent: const Color(0xFFFF4B9A),
                  onTap: () => _openSource(context, 'favorites'),
                ),
                _SourceTile(
                  key: const Key('local-source-my-words-tile'),
                  label: 'Meine Wörter',
                  subtitle: _countSubtitle(myWordsCount),
                  icon: Icons.edit_note_rounded,
                  accent: const Color(0xFFB36BFF),
                  onTap: () => _openSource(context, 'my_words'),
                ),
                _SourceTile(
                  key: const Key('local-source-known-words-tile'),
                  label: 'Wörter, die ich kenne',
                  icon: Icons.verified_rounded,
                  accent: const Color(0xFF36F58A),
                  onTap: () => _openSource(context, 'known_words'),
                ),
                _SourceTile(
                  key: const Key('local-source-my-mix-tile'),
                  label: 'Mein Mix',
                  subtitle: 'Lokal vorbereitet',
                  icon: Icons.auto_awesome_rounded,
                  accent: const Color(0xFFFFC66A),
                  onTap: () => _openSource(context, 'my_mix'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String? _countSubtitle(int? count) {
    if (count == null) return null;
    return count == 1 ? '1 Wort' : '$count Wörter';
  }

  static void _openSource(BuildContext context, String sourceKey) {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: 'local-source-detail-$sourceKey'),
        builder: (_) =>
            LocalLearningSourceDetailScreen(initialSourceKey: sourceKey),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    super.key,
    required this.label,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF0C1220),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accent.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.14),
                blurRadius: 24,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: accent, size: 28),
                const Spacer(),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFF4F8FF),
                    fontWeight: FontWeight.w900,
                    height: 1.04,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFB8C7D9),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
