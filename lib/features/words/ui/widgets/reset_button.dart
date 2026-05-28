import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talvori/core/ui/talvori_snackbar.dart';

/// Reset-Button mit Hold-to-Confirm:
/// - Langes Drücken startet einen 3s-Countdown im Fullscreen-Overlay.
/// - Haptik bei Start & Abschluss.
/// - Finger loslassen → Abbruch.
/// - Nach Ablauf wird [onResetComplete] aufgerufen.
class ResetButton extends StatefulWidget {
  final Future<void> Function() onResetComplete;
  final VoidCallback? onBeforeLongPressStart;
  final VoidCallback? onTap;
  final Key? tooltipKey;

  const ResetButton({
    super.key,
    required this.onResetComplete,
    this.onBeforeLongPressStart,
    this.onTap,
    this.tooltipKey,
  });

  @override
  State<ResetButton> createState() => _ResetButtonState();
}

class _ResetButtonState extends State<ResetButton> {
  bool _isPressed = false;
  int _countdown = 3;
  OverlayEntry? _overlayEntry;

  void _onLongPressStart(LongPressStartDetails details) {
    widget.onBeforeLongPressStart?.call();
    setState(() {
      _isPressed = true;
      _countdown = 3;
    });

    HapticFeedback.mediumImpact();
    _showOverlay();
    _startCountdown();
  }

  void _onLongPressEnd(LongPressEndDetails details) => _cancel();
  void _onLongPressCancel() => _cancel();

  void _cancel() {
    setState(() {
      _isPressed = false;
      _countdown = 3;
    });
    _removeOverlay();
    HapticFeedback.lightImpact();
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (_) => Material(
        // Deutlich dunkler, damit darunter fast nichts mehr sichtbar ist.
        color: Colors.black.withOpacity(0.97),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Header bleibt oben
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Reset',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Lernfortschritt?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Countdown-Zahl exakt in die Mitte
              Center(
                child: Text(
                  '$_countdown',
                  style: const TextStyle(
                    color: Color(0xFFA05260),
                    fontSize: 80,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // Hint bleibt unten
              const Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Text(
                    'Finger gedrückt halten...',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _startCountdown() async {
    for (int i = 3; i > 0; i--) {
      if (!_isPressed) {
        _removeOverlay();
        return;
      }
      setState(() => _countdown = i);
      _overlayEntry?.markNeedsBuild();
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!_isPressed) {
      _removeOverlay();
      return;
    }

    _removeOverlay();
    HapticFeedback.heavyImpact();

    await widget.onResetComplete();

    if (mounted) {
      TalvoriSnackBar.show(
        context,
        message: 'Lernfortschritt wurde zurückgesetzt',
        type: TalvoriSnackBarType.success,
        duration: const Duration(seconds: 2),
      );
    }

    setState(() {
      _isPressed = false;
      _countdown = 3;
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.tooltipKey,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPressStart: _onLongPressStart,
        onLongPressEnd: _onLongPressEnd,
        onLongPressCancel: _onLongPressCancel,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _isPressed
                ? const Color(0xFFA05260)
                : const Color(0xFF2D2D2F),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.refresh_rounded,
            color: _isPressed ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}
