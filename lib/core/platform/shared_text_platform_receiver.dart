import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SharedTextPlatformReceiver {
  SharedTextPlatformReceiver({
    MethodChannel methodChannel = const MethodChannel('talvori/share'),
    EventChannel eventChannel = const EventChannel('talvori/share/events'),
  }) : _methodChannel = methodChannel,
       _eventChannel = eventChannel;

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  Future<String?> getInitialSharedText() async {
    final String? text;
    try {
      text = await _methodChannel.invokeMethod<String>('getInitialSharedText');
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
    final normalized = text?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  Stream<String> watchSharedText() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const Stream.empty();
    }
    return _watchSharedText();
  }

  Stream<String> _watchSharedText() async* {
    try {
      await for (final event in _eventChannel.receiveBroadcastStream()) {
        if (event is! String) continue;
        final normalized = event.trim();
        if (normalized.isEmpty) continue;
        yield normalized;
      }
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }
}
