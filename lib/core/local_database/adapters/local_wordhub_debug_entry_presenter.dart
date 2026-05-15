import '../models/local_category.dart';

class LocalWordHubDebugItem {
  const LocalWordHubDebugItem({required this.categoryId, required this.label});

  final String categoryId;
  final String label;
}

class LocalWordHubDebugEntryState {
  const LocalWordHubDebugEntryState({
    required this.isVisible,
    required this.items,
  });

  final bool isVisible;
  final List<LocalWordHubDebugItem> items;
}

class LocalWordHubDebugEntryPresenter {
  const LocalWordHubDebugEntryPresenter();

  LocalWordHubDebugEntryState present(List<LocalCategory> categories) {
    final items = categories
        .where((category) => !category.isArchived)
        .map(
          (category) => LocalWordHubDebugItem(
            categoryId: category.id,
            label: category.name,
          ),
        )
        .toList(growable: false);

    return LocalWordHubDebugEntryState(
      isVisible: items.isNotEmpty,
      items: items,
    );
  }
}
