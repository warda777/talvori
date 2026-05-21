import 'dart:async';

import 'package:flutter/foundation.dart';

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
  final Set<String> _processedPayloadIds = <String>{};

  Future<SharedTextImportResult?> importInitialSharedText() async {
    final payload = await _receiver.getInitialSharedPayload();
    if (payload == null) return null;
    return importSharedPayload(payload);
  }

  Stream<SharedTextImportResult> watchIncomingSharedText() {
    return _receiver
        .watchSharedPayload()
        .asyncMap(importSharedPayload)
        .where((result) => result != null)
        .cast<SharedTextImportResult>();
  }

  Future<SharedTextImportResult> importSharedText(String rawText) {
    return _importText(rawText: rawText, now: _now());
  }

  Future<SharedTextImportResult?> importSharedPayload(
    SharedTextPayload payload,
  ) async {
    if (!payload.id.startsWith('legacy:') &&
        !_processedPayloadIds.add(payload.id)) {
      debugPrint('Talvori Flutter ignored duplicate share id=${payload.id}');
      return null;
    }
    return importSharedText(payload.text);
  }
}
