import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

/// Wrapper für mehrere Gesten: Tap, LongPress und SwipeDown
/// 
/// - Tap: wird normal durchgereicht
/// - LongPress: wird nach ~500ms ausgelöst, wenn Finger nicht bewegt wird
/// - SwipeDown: wird nur bei Strecke > 60px und Geschwindigkeit > 700px/s ausgelöst
class FireballGestureWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSwipeDown;

  const FireballGestureWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onSwipeDown,
  });

  @override
  State<FireballGestureWrapper> createState() => _FireballGestureWrapperState();
}

class _FireballGestureWrapperState extends State<FireballGestureWrapper> {
  Offset? _startPosition;
  double _totalDistance = 0.0;
  DateTime? _startTime;
  bool _longPressTriggered = false;
  bool _swipeTriggered = false;
  Timer? _longPressTimer;

  void _handlePanStart(DragStartDetails details) {
    _startPosition = details.globalPosition;
    _startTime = DateTime.now();
    _totalDistance = 0.0;
    _longPressTriggered = false;
    _swipeTriggered = false;

    // Starte LongPress-Timer (wird abgebrochen wenn Bewegung erkannt wird)
    _longPressTimer?.cancel();
    _longPressTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted && 
          _startPosition != null && 
          !_longPressTriggered && 
          !_swipeTriggered &&
          _totalDistance < 10) { // Nur wenn kaum Bewegung
        _longPressTriggered = true;
        HapticFeedback.mediumImpact();
        widget.onLongPress?.call();
      }
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_startPosition == null || _startTime == null) return;

    // Berechne Bewegung
    final currentPosition = details.globalPosition;
    final delta = currentPosition - _startPosition!;
    _totalDistance += delta.distance.abs();

    // Wenn Bewegung erkannt wird, breche LongPress-Timer ab
    if (_totalDistance > 10) {
      _longPressTimer?.cancel();
    }

    // Wenn nach unten gewischt wird (mehr als 60px)
    if (delta.dy > 0 && _totalDistance > 60) {
      // Berechne Geschwindigkeit
      final duration = DateTime.now().difference(_startTime!).inMilliseconds;
      if (duration > 0) {
        final velocity = (_totalDistance / duration) * 1000; // px/s

        // Trigger nur wenn Geschwindigkeit > 700 px/s
        if (velocity > 700 && !_swipeTriggered) {
          _swipeTriggered = true;          // Merken: Swipe ist "aktiv"
          _longPressTimer?.cancel();        // LongPress unterbinden
          HapticFeedback.mediumImpact();
          widget.onSwipeDown?.call();       // Spielmodus triggern
          // KEIN _reset() hier! -> onPanEnd übernimmt das Reset
        }
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _longPressTimer?.cancel();
    
    if (_swipeTriggered) {
      // Swipe wurde bereits behandelt
      _reset();
      return;
    }
    
    if (_longPressTriggered) {
      // LongPress wurde bereits behandelt
      _reset();
      return;
    }

    // Wenn keine Bewegung erkannt wurde, ist es ein Tap
    if (_totalDistance < 10) {
      widget.onTap?.call();
    }
    
    _reset();
  }

  void _reset() {
    _longPressTimer?.cancel();
    _startPosition = null;
    _startTime = null;
    _totalDistance = 0.0;
    _longPressTriggered = false;
    _swipeTriggered = false;
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: widget.child,
    );
  }
}
