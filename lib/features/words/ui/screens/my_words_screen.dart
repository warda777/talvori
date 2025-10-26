import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/word_providers.dart';
import 'package:talvori/features/words/ui/widgets/empty_state.dart';
import 'package:talvori/features/words/ui/screens/word_hub_screen.dart';

class MyWordsScreen extends ConsumerStatefulWidget {
  const MyWordsScreen({super.key});

  @override
  ConsumerState<MyWordsScreen> createState() => _MyWordsScreenState();
}

class _MyWordsScreenState extends ConsumerState<MyWordsScreen> {
  @override
  void initState() {
    super.initState();
    // ersten Load starten
    Future.microtask(() => ref.read(myWordsControllerProvider.notifier).init());
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(myWordsControllerProvider);
    final c = ref.read(myWordsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Meine Wörter')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => c.searchDebounced(v.trim()),
              onSubmitted: (_) => c.init(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Suchen in „Meine Wörter“',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          Expanded(
            child: vm.loadingFirst && vm.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => c.init(),
                    child: vm.items.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 120),
                              EmptyState(
                                icon: Icons.bookmark_add_outlined,
                                title: 'Noch keine Wörter gemerkt',
                                message: 'Markiere Wörter im Word Hub oder in Kategorien, um sie hier zu sehen.',
                                cta: 'Zum Word Hub',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const WordHubScreen()),
                                ),
                              ),
                            ],
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (n) {
                              if (n.metrics.extentAfter < 400) c.loadMore();
                              return false;
                            },
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: vm.items.length + ((vm.loadingMore || vm.hasMore) ? 1 : 0),
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, i) {
                                if (i >= vm.items.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                final w = vm.items[i];
                                return ListTile(
                                  title: Text(w.text),
                                  subtitle: Text(w.translation),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    tooltip: 'Aus „Meine Wörter" entfernen',
                                    onPressed: () async {
                                      final messenger = ScaffoldMessenger.of(context);
                                      await c.removeWord(w.id);
                                      messenger.showSnackBar(SnackBar(content: Text('Entfernt: ${w.text}')));
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
