import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/models/translation_status.dart';
import 'package:talvori/features/favorites/application/local_favorite_words_provider.dart';
import 'package:talvori/features/words/ui/screens/local_word_detail_screen.dart';

class LocalFavoritesListScreen extends ConsumerWidget {
  const LocalFavoritesListScreen({super.key});

  static const title = 'Favoriten';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(localFavoriteWordsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050507),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050507),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
      body: favoritesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF8ACB)),
        ),
        error: (_, __) => const _LocalFavoritesEmptyState(
          title: 'Favoriten konnten nicht geladen werden',
          subtitle: 'Bitte versuche es gleich noch einmal.',
        ),
        data: (words) {
          if (words.isEmpty) {
            return const _LocalFavoritesEmptyState(
              title: 'Noch keine Favoriten',
              subtitle: 'Markiere Wörter im Lernmodus als Favorit.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            itemCount: words.length,
            itemBuilder: (context, index) {
              final word = words[index];
              return _LocalFavoriteWordCard(
                word: word,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LocalWordDetailScreen(
                        wordId: word.id,
                        categoryId: word.categoryId,
                        title: title,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _LocalFavoriteWordCard extends StatelessWidget {
  const _LocalFavoriteWordCard({required this.word, required this.onTap});

  final LocalWord word;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final translationText = word.translation.trim().isEmpty
        ? 'Noch keine Übersetzung'
        : word.translation;
    final statusLabel = switch (word.translationStatus) {
      TranslationStatus.pending => 'Übersetzung ausstehend',
      TranslationStatus.failed => 'Übersetzung fehlgeschlagen',
      TranslationStatus.translated => null,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFF0E0F14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFF8ACB), width: 1),
              boxShadow: const [
                BoxShadow(color: Color(0x22FF8ACB), blurRadius: 18),
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF8ACB).withValues(alpha: 0.14),
                    border: Border.all(
                      color: const Color(0xFFFF8ACB),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFFF8ACB),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word.term,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        translationText,
                        style: const TextStyle(
                          color: Color(0xFFB8C4D9),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                      ),
                      if (statusLabel != null) ...[
                        const SizedBox(height: 10),
                        _FavoriteStatusBadge(label: statusLabel),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFFFC4E2),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteStatusBadge extends StatelessWidget {
  const _FavoriteStatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF59D7FF).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF59D7FF).withValues(alpha: 0.55),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF59D7FF),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _LocalFavoritesEmptyState extends StatelessWidget {
  const _LocalFavoritesEmptyState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0D12),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFFF8ACB), width: 1),
            boxShadow: const [
              BoxShadow(color: Color(0x22FF8ACB), blurRadius: 22),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite_border_rounded,
                color: Color(0xFFFF8ACB),
                size: 30,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB8C4D9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
