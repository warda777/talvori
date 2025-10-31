import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mix_groups.dart';

final mixIsSearchModeProvider = StateProvider<bool>((_) => false);
final mixSearchTextProvider = StateProvider<String>((_) => '');

final mixSearchResultsProvider = Provider<List<MixSearchResult>>((ref) {
  final query = ref.watch(mixSearchTextProvider).trim().toLowerCase();
  if (query.isEmpty) return const [];
  final res = <MixSearchResult>[];
  for (final g in mixGroups) {
    for (final item in g.items) {
      if (item.toLowerCase().contains(query)) {
        res.add(MixSearchResult(group: g.title, item: item));
      }
    }
  }
  return res;
});
