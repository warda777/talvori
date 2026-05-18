import 'dart:async';

import '../../platform/shared_text_platform_receiver.dart';
import '../import/shared_text_import_result.dart';

typedef SharedTextImporter =
    Future<SharedTextImportResult> Function({
      required String rawText,
      required DateTime now,
    });

typedef NowFactory = DateTime Function();

class IncomingSharedTextImportController {
  IncomingSharedTextImportController({
    required SharedTextPlatformReceiver receiver,
    required SharedTextImporter importText,
    NowFactory now = DateTime.now,
  }) : _receiver = receiver,
       _importText = importText,
       _now = now;

  final SharedTextPlatformReceiver _receiver;
  final SharedTextImporter _importText;
  final NowFactory _now;

  Future<SharedTextImportResult?> importInitialSharedText() async {
    final text = await _receiver.getInitialSharedText();
    if (text == null) return null;
    return importSharedText(text);
  }

  Stream<SharedTextImportResult> watchIncomingSharedText() {
    return _receiver.watchSharedText().asyncMap(importSharedText);
  }

  Future<SharedTextImportResult> importSharedText(String rawText) {
    return _importText(rawText: rawText, now: _now());
  }
}
