import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/features/home/ui/widgets/game_word_source_picker.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('category dialog shows learning levels and language tools', (
    tester,
  ) async {
    await _pumpPicker(tester);

    expect(
      find.byKey(const ValueKey('game-select-level-packages-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('game-select-language-tools-button')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('game-change-source-button')));
    await tester.pumpAndSettle();

    expect(find.text('Alle Wörter'), findsWidgets);
    expect(find.text('Meine Wörter'), findsOneWidget);
    expect(find.text('Favoriten'), findsOneWidget);
    expect(find.text('Wörter, die ich kenne'), findsOneWidget);
    expect(find.text('Mein Mix'), findsOneWidget);
    expect(find.text('Wortwelten'), findsAtLeastNWidgets(1));
    expect(find.text('Lernlevel'), findsAtLeastNWidgets(1));
    expect(find.text('Kleine Pakete von A1 bis C2'), findsAtLeastNWidgets(1));
    expect(find.text('Sprachwerkzeuge'), findsAtLeastNWidgets(1));
    expect(find.text('Phrasen, Grammatik und Verben'), findsAtLeastNWidgets(1));
    expect(find.text('Themen wie Reisen und Alltag'), findsAtLeastNWidgets(1));
  });

  testWidgets(
    'learning levels open small package groups instead of raw levels',
    (tester) async {
      await _pumpPicker(tester);

      await tester.tap(
        find.byKey(const ValueKey('game-select-level-packages-button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lernlevel'), findsAtLeastNWidgets(1));
      expect(
        find.text('Wähle ein kleines Paket statt ein ganzes Level.'),
        findsOneWidget,
      );
      expect(find.text('A1 Starter'), findsOneWidget);
      expect(find.text('A1 Alltag'), findsOneWidget);
      expect(find.text('A1 Verben'), findsOneWidget);
      expect(find.text('A2 Alltag'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('C2 Redemittel'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('B2 Diskussion'), findsOneWidget);
      expect(find.text('C1 Argumentation'), findsOneWidget);
      expect(find.text('C2 Redemittel'), findsOneWidget);
    },
  );

  testWidgets('language tools use clean German names without underscores', (
    tester,
  ) async {
    await _pumpPicker(tester);

    await tester.tap(
      find.byKey(const ValueKey('game-select-language-tools-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sprachwerkzeuge'), findsAtLeastNWidgets(1));
    expect(
      find.text('Übe besondere Wortgruppen und Sprachmuster.'),
      findsOneWidget,
    );
    expect(find.text('Top 500 Wörter'), findsOneWidget);
    expect(find.text('Redewendung'), findsOneWidget);
    expect(find.text('Unregelmäßige Verben'), findsOneWidget);
    expect(find.text('Grammatik & Satzbau'), findsOneWidget);
    expect(find.textContaining('_'), findsNothing);
  });

  testWidgets('word worlds exclude levels and language tools', (tester) async {
    await _pumpPicker(tester);

    await tester.tap(find.byKey(const ValueKey('game-select-world-button')));
    await tester.pumpAndSettle();

    expect(find.text('Travel'), findsOneWidget);
    expect(find.text('Work & Careers'), findsOneWidget);
    expect(find.text('A1'), findsNothing);
    expect(find.text('A2'), findsNothing);
    expect(find.text('B1'), findsNothing);
    expect(find.text('B2'), findsNothing);
    expect(find.text('C1'), findsNothing);
    expect(find.text('C2'), findsNothing);
    expect(find.text('Top 500 Wörter'), findsNothing);
    expect(find.text('Top 500 Words'), findsNothing);
  });

  testWidgets('selecting a learning level package sets the game source', (
    tester,
  ) async {
    await _pumpPicker(tester, stateful: true);

    await tester.tap(
      find.byKey(const ValueKey('game-select-level-packages-button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('A1 Starter'));
    await tester.pumpAndSettle();

    expect(find.text('Lernlevel: A1 Starter'), findsOneWidget);
  });

  testWidgets('selecting a language tool sets the game source', (tester) async {
    await _pumpPicker(tester, stateful: true);

    await tester.tap(
      find.byKey(const ValueKey('game-select-language-tools-button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Redewendung'));
    await tester.pumpAndSettle();

    expect(find.text('Sprachwerkzeug: Redewendung'), findsOneWidget);
  });
}

Future<void> _pumpPicker(WidgetTester tester, {bool stateful = false}) async {
  var selectedSource = GameWordSource.standard(LocalLearningSource.allWords);
  final categories = [
    _category(id: 'seed-category-travel', name: 'Travel'),
    _category(id: 'work-careers', name: 'Work & Careers'),
  ];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 390,
            child: stateful
                ? StatefulBuilder(
                    builder: (context, setState) {
                      return GameWordSourcePicker(
                        keyPrefix: 'game',
                        selectedSource: selectedSource,
                        categories: categories,
                        onSourceSelected: (source) {
                          setState(() => selectedSource = source);
                        },
                      );
                    },
                  )
                : GameWordSourcePicker(
                    keyPrefix: 'game',
                    selectedSource: selectedSource,
                    categories: categories,
                    onSourceSelected: (_) {},
                  ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

LocalCategory _category({required String id, required String name}) {
  final now = DateTime(2026, 5, 26, 10);
  return LocalCategory(
    id: id,
    name: name,
    sortOrder: 0,
    isArchived: false,
    createdAt: now,
    updatedAt: now,
  );
}
