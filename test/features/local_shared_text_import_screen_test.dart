import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/import/shared_text_import_result.dart';
import 'package:talvori/features/words/ui/screens/local_shared_text_import_screen.dart';

void main() {
  testWidgets('renders_input_and_import_button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: LocalSharedTextImportScreen(importText: (_) async => _empty()),
        ),
      ),
    );

    expect(find.text('Wort importieren'), findsOneWidget);
    expect(find.text('Meine Wörter'), findsOneWidget);
    expect(
      find.byKey(const Key('local-shared-text-import-input')),
      findsOneWidget,
    );
    expect(find.text('Importieren'), findsOneWidget);
  });

  testWidgets('empty_input_shows_german_error_message', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: LocalSharedTextImportScreen(importText: (_) async => _empty()),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('local-shared-text-import-button')));
    await tester.pumpAndSettle();

    expect(find.text('Leere Eingabe'), findsOneWidget);
    expect(find.text('Kein Wort zum Importieren gefunden.'), findsOneWidget);
  });

  testWidgets('valid_word_imports_and_shows_success_message', (tester) async {
    String? receivedText;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: LocalSharedTextImportScreen(
            importText: (rawText) async {
              receivedText = rawText;
              return _imported();
            },
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('local-shared-text-import-input')),
      'umbrella',
    );
    await tester.tap(find.byKey(const Key('local-shared-text-import-button')));
    await tester.pumpAndSettle();

    expect(receivedText, 'umbrella');
    expect(find.text('Erfolgreich importiert'), findsOneWidget);
    expect(
      find.text('Wort wurde in Meine Wörter gespeichert.'),
      findsOneWidget,
    );
  });

  testWidgets('duplicate_word_shows_duplicate_message', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: LocalSharedTextImportScreen(
            importText: (_) async => _duplicate(),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('local-shared-text-import-input')),
      'umbrella',
    );
    await tester.tap(find.byKey(const Key('local-shared-text-import-button')));
    await tester.pumpAndSettle();

    expect(find.text('Bereits vorhanden'), findsOneWidget);
    expect(
      find.text('Dieses Wort ist bereits in Meine Wörter.'),
      findsOneWidget,
    );
  });

  testWidgets('invalid_text_shows_invalid_message', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: LocalSharedTextImportScreen(
            importText: (_) async => _invalid(),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('local-shared-text-import-input')),
      'hello world',
    );
    await tester.tap(find.byKey(const Key('local-shared-text-import-button')));
    await tester.pumpAndSettle();

    expect(find.text('Ungültiger Text'), findsOneWidget);
    expect(
      find.text('Bitte markiere für Phase 1 nur ein einzelnes Wort.'),
      findsOneWidget,
    );
  });
}

SharedTextImportResult _empty() {
  return const SharedTextImportResult(
    status: SharedTextImportStatus.empty,
    message: 'Kein Wort zum Importieren gefunden.',
  );
}

SharedTextImportResult _imported() {
  return const SharedTextImportResult(
    status: SharedTextImportStatus.imported,
    message: 'Wort wurde in Meine Wörter gespeichert.',
  );
}

SharedTextImportResult _duplicate() {
  return const SharedTextImportResult(
    status: SharedTextImportStatus.duplicate,
    message: 'Dieses Wort ist bereits in Meine Wörter.',
  );
}

SharedTextImportResult _invalid() {
  return const SharedTextImportResult(
    status: SharedTextImportStatus.invalid,
    message: 'Bitte markiere für Phase 1 nur ein einzelnes Wort.',
  );
}
