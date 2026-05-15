import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/adapters/local_wordhub_debug_entry_presenter.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/features/local_learning_debug/routing/local_learning_debug_routes.dart';

class LocalWordHubDebugScreen extends ConsumerWidget {
  const LocalWordHubDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(localCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lokale Kategorien')),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const Center(
          child: Text('Lokale Kategorien konnten nicht geladen werden'),
        ),
        data: (categories) {
          final state = const LocalWordHubDebugEntryPresenter().present(
            categories,
          );

          if (!state.isVisible) {
            return const Center(
              child: Text('Keine lokalen Kategorien gefunden'),
            );
          }

          return ListView.builder(
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];

              return ListTile(
                title: Text(item.label),
                subtitle: Text(item.categoryId),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => buildLocalLearningDebugScreen(
                        categoryId: item.categoryId,
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
