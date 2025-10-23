// lib/features/core/reset_event.dart
import 'dart:async';

/// Globaler Event-Stream für Reset-Events
class ResetEvent {
  static final StreamController<String> _controller = StreamController<String>.broadcast();
  
  /// Stream für Reset-Events
  static Stream<String> get stream => _controller.stream;
  
  /// Sende ein Reset-Event für eine bestimmte Kategorie
  static void notifyReset(String categoryId) {
    _controller.add(categoryId);
  }
  
  /// Schließe den Stream
  static void dispose() {
    _controller.close();
  }
}
