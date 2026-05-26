import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/providers/supabase_words_local_import_controller_provider.dart';
import 'package:talvori/core/local_database/services/supabase_words_local_import_service.dart';
import 'package:talvori/features/home/ui/screens/supabase_words_local_import_screen.dart';

void main() {
  SupabaseWordsLocalImportReport report({required bool apply}) {
    return SupabaseWordsLocalImportReport(
        mode: apply
            ? SupabaseWordsLocalImportMode.apply
            : SupabaseWordsLocalImportMode.dryRun,
        remoteWordsRead: 1,
        generatedAt: DateTime.utc(2026, 5, 26, 12),
      )
      ..localWordsCreated = apply ? 1 : 1
      ..localWordsReused = apply ? 0 : 0
      ..membershipsCreated = apply ? 1 : 1
      ..levelsSet = apply ? 1 : 1
      ..wordProgressRowsBefore = 0
      ..wordProgressRowsAfter = 0;
  }

  Future<void> pumpImportScreen(
    WidgetTester tester, {
    required _FakeRunner runner,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseWordsLocalAdminImportControllerProvider.overrideWith((ref) {
            return SupabaseWordsLocalAdminImportController(runner: runner.run);
          }),
        ],
        child: const MaterialApp(home: SupabaseWordsLocalImportScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('preview runs dry-run and shows report', (tester) async {
    final runner = _FakeRunner((apply) async => report(apply: apply));
    await pumpImportScreen(tester, runner: runner);

    await tester.tap(find.text('Preview ausführen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('Preview abgeschlossen'), findsOneWidget);
    expect(find.text('Remote-Wörter gelesen'), findsOneWidget);
    expect(find.text('Lokal neu angelegt'), findsOneWidget);
    expect(runner.applyCalls, 0);
    expect(runner.previewCalls, 1);
  });

  testWidgets('apply is enabled after preview and asks for confirmation', (
    tester,
  ) async {
    final runner = _FakeRunner((apply) async => report(apply: apply));
    await pumpImportScreen(tester, runner: runner);

    var importButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Import starten'),
    );
    expect(importButton.onPressed, isNull);

    await tester.tap(find.text('Preview ausführen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    importButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Import starten'),
    );
    expect(importButton.onPressed, isNotNull);

    await tester.tap(find.text('Import starten'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text('Lokalen Import wirklich starten?'), findsOneWidget);
    await tester.tap(find.text('Import starten').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('Import abgeschlossen'), findsOneWidget);
    expect(runner.applyCalls, 1);
  });

  testWidgets('buttons are disabled while import is running', (tester) async {
    final completer = Completer<SupabaseWordsLocalImportReport>();
    final runner = _FakeRunner((apply) => completer.future);
    await pumpImportScreen(tester, runner: runner);

    await tester.tap(find.text('Preview ausführen'));
    await tester.pump();

    expect(
      find.text('Import läuft. Dieser Vorgang kann etwas dauern.'),
      findsOneWidget,
    );
    final previewButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Preview ausführen'),
    );
    final importButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Import starten'),
    );
    expect(previewButton.onPressed, isNull);
    expect(importButton.onPressed, isNull);

    completer.complete(report(apply: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
  });

  testWidgets('error state is shown without crashing', (tester) async {
    final runner = _FakeRunner((apply) async => throw StateError('offline'));
    await pumpImportScreen(tester, runner: runner);

    await tester.tap(find.text('Preview ausführen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('Import nicht möglich'), findsOneWidget);
    expect(find.textContaining('offline'), findsOneWidget);
  });

  testWidgets('opening screen does not import automatically', (tester) async {
    final runner = _FakeRunner((apply) async => report(apply: apply));
    await pumpImportScreen(tester, runner: runner);

    expect(runner.previewCalls, 0);
    expect(runner.applyCalls, 0);
  });
}

class _FakeRunner {
  _FakeRunner(this._handler);

  final Future<SupabaseWordsLocalImportReport> Function(bool apply) _handler;
  int previewCalls = 0;
  int applyCalls = 0;

  Future<SupabaseWordsLocalImportReport> run({
    required bool apply,
    required DateTime now,
  }) {
    if (apply) {
      applyCalls++;
    } else {
      previewCalls++;
    }
    return _handler(apply);
  }
}
