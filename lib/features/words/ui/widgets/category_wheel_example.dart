import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/category_controller.dart';
import 'package:talvori/features/words/ui/widgets/shimmer_list.dart';

/// Beispiel für die Verwendung des CategoryController im UI
class CategoryWheelExample extends ConsumerWidget {
  const CategoryWheelExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryControllerProvider);

    return categoriesAsync.when(
      loading: () => const ShimmerList(items: 5), // Shimmer während Loading
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Fehler: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(categoryControllerProvider),
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
      data: (categories) => ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            title: Text(category.name),
            subtitle: Text('${category.wordCount} Wörter'),
            trailing: Text(category.slug),
          );
        },
      ),
    );
  }
}

/// Erweiterte Verwendung mit Pull-to-Refresh
class CategoryWheelWithRefresh extends ConsumerWidget {
  const CategoryWheelWithRefresh({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryControllerProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(categoryControllerProvider.notifier).refresh(),
      child: categoriesAsync.when(
        loading: () => const ShimmerList(items: 5),
        error: (error, stack) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Fehler: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(categoryControllerProvider),
                    child: const Text('Erneut versuchen'),
                  ),
                ],
              ),
            ),
          ),
        ),
        data: (categories) => categories.isEmpty
            ? const Center(child: Text('Keine Kategorien gefunden'))
            : ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    title: Text(category.name),
                    subtitle: Text('${category.wordCount} Wörter'),
                    trailing: Text(category.slug),
                  );
                },
              ),
      ),
    );
  }
}
