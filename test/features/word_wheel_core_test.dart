import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/features/words/ui/widgets/word_wheel_core.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('word wheel empty state uses German browser copy', (
    tester,
  ) async {
    await _pumpEmptyWordWheel(tester, const Locale('de'));

    expect(
      find.text('Markiere ein Wort im Browser und teile es mit Talvori.'),
      findsOneWidget,
    );
    expect(find.text('Mark your first word\nin the browser'), findsNothing);

    await tester.pump(const Duration(seconds: 10));
    await tester.pump();

    expect(
      find.text('Markiere ein Wort im Browser und teile es mit Talvori.'),
      findsNothing,
    );
  });

  test('word wheel empty state label helper supports German and English', () {
    expect(
      wordWheelBrowserEmptyLabel(const Locale('de')),
      'Markiere ein Wort im Browser und teile es mit Talvori.',
    );
    expect(
      wordWheelBrowserEmptyLabel(const Locale('en')),
      'Mark your first word\nin the browser',
    );
  });
}

Future<void> _pumpEmptyWordWheel(WidgetTester tester, Locale locale) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localWordsForCategoryProvider.overrideWith(
          (ref, categoryId) async => const [],
        ),
        localWordCountProvider.overrideWith((ref, categoryId) async => 0),
      ],
      child: MaterialApp(
        locale: locale,
        home: const Scaffold(body: WordWheelCore()),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}
