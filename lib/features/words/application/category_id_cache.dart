import 'package:flutter_riverpod/flutter_riverpod.dart';

// label -> categoryId
final categoryIdCacheProvider = NotifierProvider<CategoryIdCache, Map<String, String>>(() => CategoryIdCache());

class CategoryIdCache extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => {};
  
  void setCategoryId(String label, String id) {
    state = {...state, label: id};
  }
  
  String? getCategoryId(String label) {
    return state[label];
  }
}

// Helper: liest/schreibt atomar in den Cache
String? getCachedCategoryId(Ref ref, String label) {
  return ref.read(categoryIdCacheProvider.notifier).getCategoryId(label);
}
void setCachedCategoryId(Ref ref, String label, String id) {
  ref.read(categoryIdCacheProvider.notifier).setCategoryId(label, id);
}
