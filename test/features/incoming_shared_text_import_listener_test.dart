import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/import/shared_text_import_result.dart';
import 'package:talvori/core/local_database/providers/incoming_shared_text_import_controller_provider.dart';
import 'package:talvori/core/local_database/services/incoming_shared_text_import_controller.dart';
import 'package:talvori/core/platform/shared_text_platform_receiver.dart';
import 'package:talvori/features/words/ui/widgets/incoming_shared_text_import_listener.dart';

void main() {
  testWidgets('shows_compact_success_feedback_with_my_words_action', (
    tester,
  ) async {
    await _pumpListener(
      tester,
      result: const SharedTextImportResult(
        status: SharedTextImportStatus.imported,
        message: 'ok',
      ),
    );

    expect(find.text('Wort importiert'), findsOneWidget);
    expect(find.text('Gespeichert in Meine Wörter'), findsOneWidget);
    expect(find.text('Meine Wörter öffnen'), findsOneWidget);
    expect(
      find.byKey(const Key('incoming-share-open-my-words-action')),
      findsOneWidget,
    );
  });

  testWidgets('shows_duplicate_feedback_with_my_words_action', (tester) async {
    await _pumpListener(
      tester,
      result: const SharedTextImportResult(
        status: SharedTextImportStatus.duplicate,
        message: 'duplicate',
      ),
    );

    expect(find.text('Bereits vorhanden'), findsOneWidget);
    expect(
      find.text('Dieses Wort ist bereits in Meine Wörter.'),
      findsOneWidget,
    );
    expect(find.text('Meine Wörter öffnen'), findsOneWidget);
  });

  testWidgets('shows_invalid_feedback_without_my_words_action', (tester) async {
    await _pumpListener(
      tester,
      result: const SharedTextImportResult(
        status: SharedTextImportStatus.invalid,
        message: 'Bitte markiere für Phase 1 nur ein einzelnes Wort.',
      ),
    );

    expect(find.text('Import nicht möglich'), findsOneWidget);
    expect(
      find.text('Bitte markiere für Phase 1 nur ein einzelnes Wort.'),
      findsOneWidget,
    );
    expect(find.text('Meine Wörter öffnen'), findsNothing);
  });
}

Future<void> _pumpListener(
  WidgetTester tester, {
  required SharedTextImportResult result,
}) async {
  final receiver = _FakeSharedTextPlatformReceiver(initialText: 'hello');
  final controller = IncomingSharedTextImportController(
    receiver: receiver,
    importText: ({required rawText, required now}) async => result,
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        incomingSharedTextImportControllerProvider.overrideWith(
          (ref) async => controller,
        ),
      ],
      child: const MaterialApp(
        home: IncomingSharedTextImportListener(
          child: Scaffold(body: SizedBox.expand()),
        ),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}

class _FakeSharedTextPlatformReceiver implements SharedTextPlatformReceiver {
  _FakeSharedTextPlatformReceiver({this.initialText});

  final String? initialText;
  final _events = StreamController<String>.broadcast();

  @override
  Future<String?> getInitialSharedText() async => initialText;

  @override
  Stream<String> watchSharedText() => _events.stream;
}
