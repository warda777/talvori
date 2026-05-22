import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class SharedTextPayload {
  const SharedTextPayload({
    required this.id,
    required this.text,
    this.createdAt,
    this.source,
    this.type,
    this.platform,
    this.sourceUrl,
    this.sourceTitle,
    this.sourceApp,
    this.sharedTextPreview,
  });

  final String id;
  final String text;
  final DateTime? createdAt;
  final String? source;
  final String? type;
  final String? platform;
  final String? sourceUrl;
  final String? sourceTitle;
  final String? sourceApp;
  final String? sharedTextPreview;
}

class SharedTextPlatformReceiver {
  SharedTextPlatformReceiver({
    MethodChannel methodChannel = const MethodChannel('talvori/share'),
  }) : _methodChannel = methodChannel;

  final MethodChannel _methodChannel;
  final Set<String> _deliveredPayloadIds = <String>{};

  Future<SharedTextPayload?> getInitialSharedPayload() async {
    return _readPendingSharedPayload(reason: 'initial');
  }

  Future<SharedTextPayload?> _readPendingSharedPayload({
    required String reason,
  }) async {
    debugPrint('Talvori SharedTextReceiver $reason check');
    final Object? payload;
    try {
      payload = await _methodChannel.invokeMethod<Object>(
        'getInitialSharedText',
      );
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
    final parsedPayload = _payloadFromPlatformValue(payload);
    return _takePayloadIfNew(parsedPayload, reason: reason);
  }

  Future<String?> getInitialSharedText() async {
    return (await getInitialSharedPayload())?.text;
  }

  Stream<String> watchSharedText() {
    return watchSharedPayload().map((payload) => payload.text);
  }

  Stream<SharedTextPayload> watchSharedPayload() {
    final supportsNativeShareStream =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    if (kIsWeb || !supportsNativeShareStream) {
      return const Stream.empty();
    }
    return _watchSharedPayloadWithResumeChecks();
  }

  Stream<SharedTextPayload> _watchSharedPayloadWithResumeChecks() {
    late final _SharedTextLifecycleObserver lifecycleObserver;
    final controller = StreamController<SharedTextPayload>();

    Future<void> pullPendingPayload(String reason) async {
      try {
        final payload = await _readPendingSharedPayload(reason: reason);
        if (payload != null && !controller.isClosed) {
          controller.add(payload);
        }
      } on Object catch (error, stackTrace) {
        debugPrint('Talvori SharedTextReceiver $reason failed: $error');
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      }
    }

    controller.onListen = () {
      lifecycleObserver = _SharedTextLifecycleObserver(
        onResume: () => pullPendingPayload('resume'),
      );
      WidgetsBinding.instance.addObserver(lifecycleObserver);
      unawaited(pullPendingPayload('watch-start'));
    };

    controller.onCancel = () {
      WidgetsBinding.instance.removeObserver(lifecycleObserver);
    };

    return controller.stream;
  }

  SharedTextPayload? _takePayloadIfNew(
    SharedTextPayload? payload, {
    required String reason,
  }) {
    if (payload == null) return null;
    if (payload.id.startsWith('legacy:')) {
      debugPrint(
        'Talvori SharedTextReceiver emitted legacy shared text '
        'length=${payload.text.length} reason=$reason',
      );
      return payload;
    }
    if (!_deliveredPayloadIds.add(payload.id)) {
      debugPrint(
        'Talvori SharedTextReceiver ignored already processed '
        'shareId=${payload.id} reason=$reason',
      );
      return null;
    }
    debugPrint(
      'Talvori SharedTextReceiver emitted shareId=${payload.id} '
      'length=${payload.text.length} reason=$reason',
    );
    return payload;
  }

  SharedTextPayload? _payloadFromPlatformValue(Object? value) {
    if (value is String) {
      final text = value.trim();
      if (text.isEmpty) return null;
      return SharedTextPayload(id: 'legacy:${text.hashCode}', text: text);
    }
    if (value is! Map) return null;
    final rawText = value['text'];
    if (rawText is! String) return null;
    final text = rawText.trim();
    if (text.isEmpty) return null;

    final rawId = value['id'];
    final id = rawId is String && rawId.trim().isNotEmpty
        ? rawId.trim()
        : 'legacy:${text.hashCode}';
    final rawCreatedAt = value['createdAt'];
    final createdAt = switch (rawCreatedAt) {
      final int seconds => DateTime.fromMillisecondsSinceEpoch(seconds * 1000),
      final double seconds => DateTime.fromMillisecondsSinceEpoch(
        (seconds * 1000).round(),
      ),
      _ => null,
    };
    final rawSource = value['source'];
    final rawType = value['type'];
    final rawPlatform = value['platform'];
    final rawSourceUrl = value['sourceUrl'];
    final rawSourceTitle = value['sourceTitle'];
    final rawSourceApp = value['sourceApp'];
    final rawBrowserHint = value['browserHint'];
    final rawSharedTextPreview = value['sharedTextPreview'];

    final sourceUrl = _trimmedStringOrNull(rawSourceUrl);
    debugPrint(
      'Talvori Flutter received shared text id=$id '
      'hasSourceUrl=${sourceUrl != null}',
    );
    return SharedTextPayload(
      id: id,
      text: text,
      createdAt: createdAt,
      source: _trimmedStringOrNull(rawSource),
      type: _trimmedStringOrNull(rawType),
      platform: _trimmedStringOrNull(rawPlatform),
      sourceUrl: sourceUrl,
      sourceTitle: _trimmedStringOrNull(rawSourceTitle),
      sourceApp:
          _trimmedStringOrNull(rawSourceApp) ??
          _trimmedStringOrNull(rawBrowserHint),
      sharedTextPreview: _trimmedStringOrNull(rawSharedTextPreview),
    );
  }

  String? _trimmedStringOrNull(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _SharedTextLifecycleObserver extends WidgetsBindingObserver {
  _SharedTextLifecycleObserver({required this.onResume});

  final VoidCallback onResume;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResume();
    }
  }
}
