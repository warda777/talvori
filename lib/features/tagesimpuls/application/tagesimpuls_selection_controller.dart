import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/tagesimpuls_selection_repository.dart';
import '../models/tagesimpuls_selection_item.dart';

enum TagesimpulsSelectionAddResult { ok, duplicate, full, invalid }

class TagesimpulsSelectionState {
  const TagesimpulsSelectionState({
    required this.items,
    this.maxCount = 5,
    this.isLoading = false,
  });

  const TagesimpulsSelectionState.initial()
    : items = const [],
      maxCount = 5,
      isLoading = true;

  final List<TagesimpulsSelectionItem> items;
  final int maxCount;
  final bool isLoading;

  int get count => items.length;
  bool get isFull => count >= maxCount;

  TagesimpulsSelectionState copyWith({
    List<TagesimpulsSelectionItem>? items,
    int? maxCount,
    bool? isLoading,
  }) {
    return TagesimpulsSelectionState(
      items: items ?? this.items,
      maxCount: maxCount ?? this.maxCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TagesimpulsSelectionController
    extends StateNotifier<TagesimpulsSelectionState> {
  TagesimpulsSelectionController({
    required TagesimpulsSelectionRepository repository,
    int maxCount = 5,
  }) : _repository = repository,
       super(
         TagesimpulsSelectionState(
           items: const [],
           maxCount: maxCount,
           isLoading: true,
         ),
       );

  final TagesimpulsSelectionRepository _repository;

  Future<void> load() async {
    final items = await _repository.loadItems();
    state = state.copyWith(
      items: _dedupe(items).take(state.maxCount).toList(growable: false),
      isLoading: false,
    );
  }

  Future<TagesimpulsSelectionAddResult> add(
    TagesimpulsSelectionItem item,
  ) async {
    await _ensureLoaded();
    final normalizedText = item.normalizedText;
    if (normalizedText.isEmpty) return TagesimpulsSelectionAddResult.invalid;
    if (contains(item)) return TagesimpulsSelectionAddResult.duplicate;
    if (state.isFull) return TagesimpulsSelectionAddResult.full;

    final next = [
      ...state.items,
      TagesimpulsSelectionItem(
        wordId: item.wordId.trim(),
        text: item.text.trim(),
        translation: item.translation?.trim(),
        categoryId: item.categoryId?.trim(),
        addedAt: item.addedAt,
      ),
    ];
    state = state.copyWith(items: next, isLoading: false);
    await _repository.saveItems(next);
    return TagesimpulsSelectionAddResult.ok;
  }

  Future<bool> remove(TagesimpulsSelectionItem item) async {
    await _ensureLoaded();
    final next = state.items
        .where((candidate) => !_matches(candidate, item))
        .toList(growable: false);
    if (next.length == state.items.length) return false;

    state = state.copyWith(items: next, isLoading: false);
    await _repository.saveItems(next);
    return true;
  }

  Future<void> clear() async {
    await _ensureLoaded();
    state = state.copyWith(items: const [], isLoading: false);
    await _repository.clear();
  }

  bool contains(TagesimpulsSelectionItem item) {
    return state.items.any((candidate) => _matches(candidate, item));
  }

  Future<void> _ensureLoaded() async {
    if (!state.isLoading) return;
    await load();
  }

  List<TagesimpulsSelectionItem> _dedupe(List<TagesimpulsSelectionItem> items) {
    final result = <TagesimpulsSelectionItem>[];
    for (final item in items) {
      if (item.normalizedText.isEmpty) continue;
      if (result.any((candidate) => _matches(candidate, item))) continue;
      result.add(item);
    }
    return result;
  }

  bool _matches(TagesimpulsSelectionItem left, TagesimpulsSelectionItem right) {
    final leftId = left.wordId.trim();
    final rightId = right.wordId.trim();
    if (leftId.isNotEmpty && rightId.isNotEmpty && leftId == rightId) {
      return true;
    }
    return left.normalizedText == right.normalizedText;
  }
}
