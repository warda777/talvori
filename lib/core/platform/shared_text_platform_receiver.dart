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
    return _eventChannel
        .receiveBroadcastStream()
        .handleError((_) {})
        .where((event) {
          return event is String && event.trim().isNotEmpty;
        })
        .map((event) => (event as String).trim());
  }
}
