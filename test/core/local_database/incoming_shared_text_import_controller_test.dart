import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/import/shared_text_import_result.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/repositories/category_repository.dart';
import 'package:talvori/core/local_database/repositories/word_progress_repository.dart';
import 'package:talvori/core/local_database/repositories/word_repository.dart';
import 'package:talvori/core/local_database/services/incoming_shared_text_import_controller.dart';
import 'package:talvori/core/local_database/services/shared_text_import_service.dart';
import 'package:talvori/core/platform/shared_text_platform_receiver.dart';

void main() {
  sqfliteFfiInit();

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

  test('ignores_same_ios_share_id_but_accepts_same_text_with_new_id', () async {
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
    receiver.addPayload(const SharedTextPayload(id: 'share-1', text: 'river'));
    receiver.addPayload(const SharedTextPayload(id: 'share-1', text: 'river'));
    receiver.addPayload(const SharedTextPayload(id: 'share-2', text: 'river'));
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(imported, ['river', 'river']);
    expect(results, hasLength(2));
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

  test('imports_android_style_shared_text_with_word_and_url', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    await LocalDatabaseSchema.createV1(db);
    final service = SharedTextImportService(
      categoryRepository: CategoryRepository(database: db),
      wordRepository: WordRepository(database: db),
      wordProgressRepository: WordProgressRepository(database: db),
    );
    final receiver = _FakeSharedTextPlatformReceiver(
      initialText: 'hello\nhttps://example.com/article',
    );
    final controller = IncomingSharedTextImportController(
      receiver: receiver,
      now: () => now,
      importText: service.importRawText,
    );

    final result = await controller.importInitialSharedText();

    expect(result?.status, SharedTextImportStatus.imported);
    expect(result?.word?.term, 'hello');
  });
}

class _FakeSharedTextPlatformReceiver implements SharedTextPlatformReceiver {
  _FakeSharedTextPlatformReceiver({this.initialText});

  final String? initialText;
  final _events = StreamController<SharedTextPayload>.broadcast();

  void add(String text) {
    _events.add(SharedTextPayload(id: 'legacy:${text.hashCode}', text: text));
  }

  void addPayload(SharedTextPayload payload) => _events.add(payload);

  @override
  Future<SharedTextPayload?> getInitialSharedPayload() async {
    final text = initialText;
    if (text == null) return null;
    return SharedTextPayload(id: 'initial-1', text: text);
  }

  @override
  Future<String?> getInitialSharedText() async => initialText;

  @override
  Stream<SharedTextPayload> watchSharedPayload() => _events.stream;

  @override
  Stream<String> watchSharedText() {
    return _events.stream.map((payload) => payload.text);
  }
}
