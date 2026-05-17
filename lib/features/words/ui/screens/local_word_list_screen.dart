import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';

class LocalWordListScreen extends ConsumerWidget {
  const LocalWordListScreen({
    super.key,
    required this.categoryId,
    required this.title,
  });

  final String categoryId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(localWordsForCategoryProvider(categoryId));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: wordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const Center(
          child: Text('Lokale Wörter konnten nicht geladen werden'),
        ),
        data: (words) {
          if (words.isEmpty) {
            return const Center(child: Text('Keine lokalen Wörter verfügbar'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: words.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final word = words[index];
              return ListTile(
                title: Text(word.term),
                subtitle: Text(word.translation),
              );
            },
          );
        },
      ),
    );
  }
}
