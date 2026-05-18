import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_word_detail_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_edit_controller_provider.dart';
import 'package:talvori/features/words/ui/screens/local_word_edit_screen.dart';

class _FakeLocalWordEditController extends LocalWordEditController {
  static String? lastTerm;
  static String? lastTranslation;

  static void reset() {
    lastTerm = null;
    lastTranslation = null;
  }

  @override
  LocalWordEditControllerState build() {
    return const LocalWordEditControllerState();
  }

  @override
  Future<LocalWord?> updateWord({
    required String wordId,
    required String categoryId,
    required String term,
    required String translation,
    required DateTime updatedAt,
  }) async {
    lastTerm = term;
    lastTranslation = translation;
    return LocalWord(
      id: wordId,
      categoryId: categoryId,
      term: term,
      translation: translation,
      sortOrder: 0,
      isArchived: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: updatedAt,
    );
  }
}

void main() {
  final now = DateTime(2026, 1, 1);

  LocalWord word() {
    return LocalWord(
      id: 'seed-basics-hello',
      categoryId: 'seed-category-basics',
      term: 'hello',
      translation: 'hallo',
      sortOrder: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> pumpEdit(WidgetTester tester) async {
    _FakeLocalWordEditController.reset();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordDetailProvider.overrideWith(
            (ref, request) async =>
                LocalWordDetailData(word: word(), progress: null),
          ),
          localWordEditControllerProvider.overrideWith(
            _FakeLocalWordEditController.new,
          ),
        ],
        child: const MaterialApp(
          home: LocalWordEditScreen(
            wordId: 'seed-basics-hello',
            categoryId: 'seed-category-basics',
            title: 'Health & Fitness',
          ),
        ),
      ),
    );

    await tester.pump();
  }

  testWidgets('local_word_edit_screen_validates_empty_fields', (tester) async {
    await pumpEdit(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Wort'), '');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Übersetzung'),
      '',
    );
    await tester.tap(find.text('Speichern'));
    await tester.pump();

    expect(find.text('Wort darf nicht leer sein'), findsOneWidget);
    expect(find.text('Übersetzung darf nicht leer sein'), findsOneWidget);
    expect(_FakeLocalWordEditController.lastTerm, isNull);
  });

  testWidgets('local_word_edit_screen_saves_valid_changes', (tester) async {
    await pumpEdit(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Wort'), 'hi');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Übersetzung'),
      'servus',
    );
    await tester.tap(find.text('Speichern'));
    await tester.pump();

    expect(_FakeLocalWordEditController.lastTerm, 'hi');
    expect(_FakeLocalWordEditController.lastTranslation, 'servus');
  });
}
