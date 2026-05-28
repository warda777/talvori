import 'dart:async';
import 'package:flutter/material.dart';

class SlideHintController {
  _SlideHintButtonState? _s;
  void _bind(_SlideHintButtonState s) => _s = s;
  void _unbind(_SlideHintButtonState s) {
    if (identical(_s, s)) _s = null;
  }

  Future<void> open() async {
    final s = _s;
    if (s == null || s._isDisposed || !s.mounted) return;
    await s._animateTo(-s.widget.reveal);
  }

  Future<void> close() async {
    final s = _s;
    if (s == null || s._isDisposed || !s.mounted) return;

    s._lockClosedUntil = DateTime.now().add(const Duration(milliseconds: 900));
    s._suppressFor(const Duration(milliseconds: 900));
    s._freezeFor(const Duration(milliseconds: 900));
    s._userInteracted = true;
    s._closing = true;
    s._stopHints();

    if (!s._isDisposed && s.mounted && s._ac.isAnimating) s._ac.stop();

    await s._animateTo(
      0,
      d: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    if (s._isDisposed || !s.mounted) return;

    s._resetClosedPosition();

    s._hintTimer?.cancel();
    s._hintTimer = null;
    s._closing = false;
  }

  Future<void> nudge({double by = 24}) async {
    final s = _s;
    if (s == null || s._isDisposed || !s.mounted) return;
    await s._nudge(by: by);
  }

  Future<void> closeAndFreeze([
    Duration freeze = const Duration(milliseconds: 800),
  ]) async {
    final s = _s;
    if (s == null || s._isDisposed || !s.mounted) return;

    s._suppressFor(freeze);
    s._freezeFor(freeze);
    s._stopHints();

    if (!s._isDisposed && s.mounted && s._ac.isAnimating) s._ac.stop();

    await s._animateTo(
      0,
      d: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    if (s._isDisposed || !s.mounted) return;

    s._resetClosedPosition();
  }

  double get offset => _s?._offset ?? 0;
}

class SlideHintButton extends StatefulWidget {
  const SlideHintButton({
    super.key,
    required this.child,
    required this.buttonWidth,
    required this.reveal,
    this.enableDrag = false,
    this.controller,
    this.onUnderlayTap,
    // Hint-Steuerung
    this.autoHint = false,
    this.firstHintDelay = const Duration(milliseconds: 600),
    this.hintInterval = const Duration(seconds: 5),
    this.hintFraction = 2 / 3,
    this.hintOutDuration = const Duration(milliseconds: 220),
    this.hintBackDuration = const Duration(milliseconds: 520),
    this.hintOutCurve = Curves.easeOut,
    this.hintBackCurve = Curves.easeOutBack,
  });

  final Widget child;
  final double buttonWidth;
  final double reveal;
  final bool enableDrag;
  final SlideHintController? controller;
  final VoidCallback? onUnderlayTap;

  // Auto-Hint
  final bool autoHint;
  final Duration firstHintDelay;
  final Duration hintInterval;
  final double hintFraction;

  // Geschwindigkeiten/Kurven
  final Duration hintOutDuration;
  final Duration hintBackDuration;
  final Curve hintOutCurve;
  final Curve hintBackCurve;

  @override
  State<SlideHintButton> createState() => _SlideHintButtonState();
}

class _SlideHintButtonState extends State<SlideHintButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  );

  double _offset = 0.0; // 0 .. -reveal
  Timer? _hintTimer;
  bool _userInteracted = false;
  bool _hintAnimating = false;
  int _hintCount = 0; // Zähler für die Anzahl der Hints
  double _from = 0.0;
  double _to = 0.0;
  bool _closing = false;
  bool _isDisposed = false;
  DateTime? _lockClosedUntil;
  DateTime? _freezeUntil;
  DateTime? _suppressUntil;

  bool get _isLocked =>
      _lockClosedUntil != null && DateTime.now().isBefore(_lockClosedUntil!);
  bool get _isFrozen =>
      _freezeUntil != null && DateTime.now().isBefore(_freezeUntil!);
  bool get _canOpen =>
      _suppressUntil == null || DateTime.now().isAfter(_suppressUntil!);

  void _suppressFor(Duration d) => _suppressUntil = DateTime.now().add(d);
  void _freezeFor(Duration d) => _freezeUntil = DateTime.now().add(d);

  void _resetClosedPosition() {
    if (_isDisposed || !mounted) return;
    _offset = 0;
    _from = 0;
    _to = 0;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller?._bind(this);
    _ac.addListener(() {
      if (_isDisposed || !mounted) return;
      final v = _ac.value;
      final off = _from + (_to - _from) * v;
      setState(() => _offset = off);
    });
    _scheduleHints();
  }

  @override
  void didUpdateWidget(covariant SlideHintButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._unbind(this);
      widget.controller?._bind(this);
    }

    if (oldWidget.autoHint != widget.autoHint) {
      if (widget.autoHint && !_userInteracted && !_isLocked && !_isFrozen) {
        _scheduleHints();
      } else {
        _stopHints();
      }
    }

    if (_isFrozen) {
      _stopHints();
      if (_offset != 0) {
        if (!_isDisposed && mounted && _ac.isAnimating) _ac.stop();
        _offset = 0;
        _from = 0;
        _to = 0;
        setState(() {});
      }
    }

    if (_isLocked) {
      _stopHints();
      if (_offset != 0) {
        if (!_isDisposed && mounted && _ac.isAnimating) _ac.stop();
        _offset = 0;
        _from = 0;
        _to = 0;
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _hintTimer?.cancel();
    _hintTimer = null;
    widget.controller?._unbind(this);
    _ac.dispose();
    super.dispose();
  }

  Future<void> _animateTo(
    double target, {
    Duration d = const Duration(milliseconds: 240),
    Curve curve = Curves.easeOut,
  }) async {
    if (_isDisposed || !mounted) return;
    if (_ac.isAnimating) _ac.stop();

    final double t = target.clamp(-widget.reveal, 0.0);

    if ((_offset - t).abs() < 0.5) {
      if (!_isDisposed && mounted) setState(() => _offset = t);
      return;
    }

    if (_isDisposed || !mounted) return;
    _ac.stop();
    _ac.duration = d;

    _from = _offset;
    _to = t;

    bool completed = false;
    try {
      await _ac.animateTo(1.0, duration: d, curve: curve);
      completed = true;
    } catch (_) {
      completed = false;
    }
    if (_isDisposed || !mounted) return;

    final current = _from + (_to - _from) * _ac.value;
    _offset = completed ? t : current;
    if (!_isDisposed && mounted) setState(() {});
    _ac.value = 0.0;
    _from = _offset;
    _to = _offset;
  }

  Future<void> _nudge({double by = 24}) async {
    if (_isDisposed || !mounted) return;
    await _animateTo(
      (-by).clamp(-widget.reveal, 0.0),
      d: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
    );
    if (_isDisposed || !mounted) return;
    await _animateTo(
      0,
      d: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
    );
  }

  void _stopHints() {
    _userInteracted = true;
    _hintTimer?.cancel();
    _hintTimer = null;
    _hintAnimating = false;
    if (!_isDisposed && mounted && _ac.isAnimating) _ac.stop();
  }

  void _scheduleHints() {
    if (!widget.autoHint ||
        _userInteracted ||
        _closing ||
        _isFrozen ||
        !_canOpen ||
        _hintCount >= 3) {
      return;
    }
    if (_hintTimer != null) return;

    _hintTimer = Timer(widget.firstHintDelay, () async {
      if (_isDisposed || !mounted) return;
      if (!_userInteracted && _hintCount < 3) await _runOneHint();
      if (_userInteracted || _hintCount >= 3) return;

      _hintTimer?.cancel();
      _hintTimer = Timer.periodic(widget.hintInterval, (_) async {
        if (_isDisposed || !mounted) {
          _hintTimer?.cancel();
          _hintTimer = null;
          return;
        }
        if (_userInteracted || _closing || _hintCount >= 3) {
          _stopHints();
          return;
        }
        await _runOneHint();
      });
    });
  }

  Future<void> _runOneHint() async {
    if (_isDisposed ||
        !mounted ||
        _userInteracted ||
        _closing ||
        _isFrozen ||
        !_canOpen) {
      return;
    }
    if (_hintAnimating) return;
    if (_offset.abs() >= 0.5) return;

    // Stoppe nach 3 Hints
    if (_hintCount >= 3) {
      _stopHints();
      return;
    }

    _hintAnimating = true;
    try {
      final double target = -widget.reveal * widget.hintFraction;

      await _animateTo(
        target,
        d: widget.hintOutDuration,
        curve: widget.hintOutCurve,
      );

      if (_isDisposed || !mounted || _userInteracted) return;

      await _animateTo(
        0,
        d: widget.hintBackDuration,
        curve: widget.hintBackCurve,
      );
      if (_isDisposed || !mounted) return;

      // Zähler erhöhen nach erfolgreichem Hint
      _hintCount++;

      // Stoppe nach 3 Hints
      if (_hintCount >= 3) {
        _stopHints();
      }
    } finally {
      _hintAnimating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final revealPxRaw = (-_offset).clamp(0.0, widget.reveal);
    final revealPx = _isFrozen ? 0.0 : revealPxRaw;
    final progress = (revealPx / widget.reveal).clamp(0.0, 1.0);

    final core = Listener(
      onPointerDown: (_) => _stopHints(), // bei Berührung Hints stoppen
      child: SizedBox(
        width: widget.buttonWidth,
        height: 36,
        child: widget.enableDrag
            ? GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onHorizontalDragStart: (_) {
                  _stopHints();
                  if (_isFrozen || !_canOpen) return;
                },
                onHorizontalDragUpdate: (d) {
                  if (_isFrozen || !_canOpen) return;
                  setState(() {
                    _offset = (_offset + d.delta.dx).clamp(-widget.reveal, 0.0);
                  });
                },
                onHorizontalDragEnd: (d) {
                  if (_isFrozen || !_canOpen) {
                    _animateTo(0, d: const Duration(milliseconds: 200));
                    return;
                  }
                  final v = d.primaryVelocity ?? 0;
                  final open = _offset < -widget.reveal * 0.55 || v < -400;
                  _animateTo(
                    open ? -widget.reveal : 0,
                    d: const Duration(milliseconds: 240),
                    curve: open ? Curves.easeOut : Curves.easeOutBack,
                  );
                },
                child: widget.child,
              )
            : widget.child,
      ),
    );

    final moving = Transform.translate(
      offset: Offset(-revealPx, 0),
      child: Opacity(opacity: 1.0 - 0.35 * progress, child: core),
    );

    return SizedBox(
      width: widget.buttonWidth + widget.reveal,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(right: 0, top: 2, bottom: 2, child: moving),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: widget.reveal,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                _stopHints();
                _suppressFor(const Duration(milliseconds: 900));
                _freezeFor(const Duration(milliseconds: 900));
                widget.onUnderlayTap?.call();
                await _animateTo(
                  0,
                  d: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
