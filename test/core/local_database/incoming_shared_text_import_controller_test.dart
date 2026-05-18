import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/import/shared_text_import_result.dart';
import 'package:talvori/core/local_database/services/incoming_shared_text_import_controller.dart';
import 'package:talvori/core/platform/shared_text_platform_receiver.dart';

void main() {
  final now = DateTime(2026, 5, 18, 12);

  test('imports_initial_shared_text', () async {
    final receiver = _FakeSharedTextPlatformReceiver(initialText: 'Umbrella');
    final imported = <String>[];
    final controller = IncomingSharedTextImportController(
      receiver: receiver,
      now: () => now,
      importText: ({required rawText, required now}) async {
        imported.add(rawText);
        return const SharedTextImportResult(
          status: SharedTextImportStatus.imported,
          message: 'ok',
        );
      },
    );

    final result = await controller.importInitialSharedText();

    expect(result?.status, SharedTextImportStatus.imported);
    expect(imported, ['Umbrella']);
  });

  test('ignores_missing_initial_shared_text', () async {
    final receiver = _FakeSharedTextPlatformReceiver();
    var calls = 0;
    final controller = IncomingSharedTextImportController(
      receiver: receiver,
      importText: ({required rawText, required now}) async {
        calls++;
        return const SharedTextImportResult(
          status: SharedTextImportStatus.imported,
          message: 'ok',
        );
      },
    );

    final result = await controller.importInitialSharedText();

    expect(result, isNull);
    expect(calls, 0);
  });

  test('imports_warm_shared_text_events', () async {
    final receiver = _FakeSharedTextPlatformReceiver();
    final imported = <String>[];
    final controller = IncomingSharedTextImportController(
      receiver: receiver,
      now: () => now,
      importText: ({required rawText, required now}) async {
        imported.add(rawText);
        return const SharedTextImportResult(
          status: SharedTextImportStatus.imported,
          message: 'ok',
        );
      },
    );

    final results = <SharedTextImportResult>[];
    final sub = controller.watchIncomingSharedText().listen(results.add);
    receiver.add('river');
    receiver.add('house');
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(imported, ['river', 'house']);
    expect(results.map((result) => result.status), [
      SharedTextImportStatus.imported,
      SharedTextImportStatus.imported,
    ]);
  });

  test('surfaces_duplicate_and_invalid_import_results', () async {
    final receiver = _FakeSharedTextPlatformReceiver(
      initialText: 'hello world',
    );
    final controller = IncomingSharedTextImportController(
      receiver: receiver,
      importText: ({required rawText, required now}) async {
        if (rawText.contains(' ')) {
          return const SharedTextImportResult(
            status: SharedTextImportStatus.invalid,
            message: 'invalid',
          );
        }
        return const SharedTextImportResult(
          status: SharedTextImportStatus.duplicate,
          message: 'duplicate',
        );
      },
    );

    final initial = await controller.importInitialSharedText();
    expect(initial?.status, SharedTextImportStatus.invalid);

    final results = <SharedTextImportResult>[];
    final sub = controller.watchIncomingSharedText().listen(results.add);
    receiver.add('house');
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(results.single.status, SharedTextImportStatus.duplicate);
  });
}

class _FakeSharedTextPlatformReceiver implements SharedTextPlatformReceiver {
  _FakeSharedTextPlatformReceiver({this.initialText});

  final String? initialText;
  final _events = StreamController<String>.broadcast();

  void add(String text) => _events.add(text);

  @override
  Future<String?> getInitialSharedText() async => initialText;

  @override
  Stream<String> watchSharedText() => _events.stream;
}
