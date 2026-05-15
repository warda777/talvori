import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/local_wordhub_debug_entry_presenter.dart';
import 'package:talvori/core/local_database/models/local_category.dart';

void main() {
  group('LocalWordHubDebugEntryPresenter', () {
    test(
      'local_wordhub_debug_entry_shows_basics_when_local_category_exists',
      () {
        final now = DateTime(2026, 5, 15, 12);
        final category = LocalCategory(
          id: 'basics',
          name: 'Basics',
          sortOrder: 1,
          isArchived: false,
          createdAt: now,
          updatedAt: now,
        );
        const presenter = LocalWordHubDebugEntryPresenter();

        final state = presenter.present([category]);

        expect(state.isVisible, isTrue);
        expect(state.items, hasLength(1));
        expect(state.items.single.categoryId, 'basics');
        expect(state.items.single.label, 'Basics');
      },
    );

    test('local_wordhub_debug_entry_hidden_when_no_local_categories', () {
      final now = DateTime(2026, 5, 15, 12);
      final archivedCategory = LocalCategory(
        id: 'basics',
        name: 'Basics',
        sortOrder: 1,
        isArchived: true,
        createdAt: now,
        updatedAt: now,
      );
      const presenter = LocalWordHubDebugEntryPresenter();

      final emptyState = presenter.present(const []);
      final archivedState = presenter.present([archivedCategory]);

      expect(emptyState.isVisible, isFalse);
      expect(emptyState.items, isEmpty);
      expect(archivedState.isVisible, isFalse);
      expect(archivedState.items, isEmpty);
    });
  });
}
