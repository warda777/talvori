import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/category_controller.dart';
import 'package:talvori/features/words/ui/widgets/shimmer_list.dart';
import 'package:talvori/ui/common/mini_badge.dart';

/// Beispiel für die Verwendung des CategoryController im UI
class CategoryWheelExample extends ConsumerWidget {
  const CategoryWheelExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catState = ref.watch(categoryControllerProvider);

    return Column(
      children: [
        if (catState.offline) const MiniBadge(icon: Icons.cloud_off, label: 'Offline'),
        Expanded(
          child: _buildContent(catState, ref),
        ),
      ],
    );
  }

  Widget _buildContent(CategoryState catState, WidgetRef ref) {
    // Mikro-Check
    debugPrint('wheel: loading=${catState.loading} items=${catState.categories.length}');
    
    if (catState.loading && catState.categories.isEmpty) {
      return const ShimmerList(items: 5); // Shimmer während Loading
    }

    if (catState.error != null && catState.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Fehler: ${catState.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(categoryControllerProvider.notifier).refresh(),
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: catState.categories.length,
      itemBuilder: (context, index) {
        final category = catState.categories[index];
        return ListTile(
          title: Text(category.name),
          subtitle: Text('${category.wordCount} Wörter'),
          trailing: Text(category.slug),
        );
      },
    );
  }
}

/// Erweiterte Verwendung mit Pull-to-Refresh
class CategoryWheelWithRefresh extends ConsumerWidget {
  const CategoryWheelWithRefresh({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catState = ref.watch(categoryControllerProvider);

    return Column(
      children: [
        if (catState.offline) const MiniBadge(icon: Icons.cloud_off, label: 'Offline'),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(categoryControllerProvider.notifier).refresh(),
            child: _buildRefreshContent(catState, ref, context),
          ),
        ),
      ],
    );
  }

  Widget _buildRefreshContent(CategoryState catState, WidgetRef ref, BuildContext context) {
    if (catState.loading && catState.categories.isEmpty) {
      return const ShimmerList(items: 5);
    }

    if (catState.error != null && catState.categories.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Fehler: ${catState.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(categoryControllerProvider.notifier).refresh(),
                  child: const Text('Erneut versuchen'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return catState.categories.isEmpty
        ? const Center(child: Text('Keine Kategorien gefunden'))
        : ListView.builder(
            itemCount: catState.categories.length,
            itemBuilder: (context, index) {
              final category = catState.categories[index];
              return ListTile(
                title: Text(category.name),
                subtitle: Text('${category.wordCount} Wörter'),
                trailing: Text(category.slug),
              );
            },
          );
  }
}
