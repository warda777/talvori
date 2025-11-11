import 'dart:async';
import 'package:flutter/material.dart';

class SlideHintController {
  _SlideHintButtonState? _s;
  void _bind(_SlideHintButtonState s) => _s = s;

  Future<void> open() async => _s!._animateTo(-_s!.widget.reveal);
  Future<void> close() async {
    final s = _s;
    if (s == null) return;

    s._closing = true;
    s._stopHints();

    if (s._ac.isAnimating) s._ac.stop();

    if (s._offset < -0.5) {
      await s._animateTo(
        0,
        d: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      s._offset = 0;
      s._from = 0;
      s._to = 0;
      s.setState(() {});
    }

    s._userInteracted = true;
    s._hintTimer?.cancel();
    s._hintTimer = null;
    await Future<void>.delayed(const Duration(milliseconds: 80));
    s._closing = false;
  }

  Future<void> nudge({double by = 24}) async => _s!._nudge(by: by);

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

  Animation<double>? _anim;
  double _offset = 0.0; // 0 .. -reveal
  Timer? _hintTimer;
  bool _userInteracted = false;
  bool _hintAnimating = false;
  double _from = 0.0;
  double _to = 0.0;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._bind(this);
    _ac.addListener(() {
      final v = _ac.value;
      final off = _from + (_to - _from) * v;
      if (mounted) setState(() => _offset = off);
    });
    _scheduleHints();
  }

  @override
  void didUpdateWidget(covariant SlideHintButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller &&
        widget.controller != null) {
      widget.controller!._bind(this);
    }

    if (oldWidget.autoHint != widget.autoHint) {
      if (widget.autoHint) {
        if (!_userInteracted) _scheduleHints();
      } else {
        _stopHints();
      }
    }
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    if (widget.controller?._s == this) {
      widget.controller?._s = null;
    }
    _ac.dispose();
    super.dispose();
  }

  Future<void> _animateTo(
    double target, {
    Duration d = const Duration(milliseconds: 240),
    Curve curve = Curves.easeOut,
  }) async {
    if (_ac.isAnimating) _ac.stop();

    final double t = target.clamp(-widget.reveal, 0.0);

    if ((_offset - t).abs() < 0.5) {
      if (mounted) setState(() => _offset = t);
      return;
    }

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

    final current = _from + (_to - _from) * _ac.value;
    _offset = completed ? t : current;
    if (mounted) setState(() {});
    _ac.value = 0.0;
    _from = _offset;
    _to = _offset;
  }

  Future<void> _nudge({double by = 24}) async {
    if (!mounted) return;
    await _animateTo(
      (-by).clamp(-widget.reveal, 0.0),
      d: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
    );
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
    if (_ac.isAnimating) _ac.stop();
  }

  void _scheduleHints() {
    if (!widget.autoHint || _userInteracted || _closing) return;
    if (_hintTimer != null) return;

    _hintTimer = Timer(widget.firstHintDelay, () async {
      if (!_userInteracted) await _runOneHint();
      if (_userInteracted) return;

      _hintTimer?.cancel();
      _hintTimer = Timer.periodic(widget.hintInterval, (_) async {
        if (!mounted || _userInteracted || _closing) {
          _stopHints();
          return;
        }
        await _runOneHint();
      });
    });
  }

  Future<void> _runOneHint() async {
    if (!mounted || _userInteracted || _closing) return;
    if (_hintAnimating) return;
    if (_offset.abs() >= 0.5) return;

    _hintAnimating = true;
    try {
      final double target = -widget.reveal * widget.hintFraction;

      await _animateTo(
        target,
        d: widget.hintOutDuration,
        curve: widget.hintOutCurve,
      );

      if (!mounted || _userInteracted) return;

      await _animateTo(
        0,
        d: widget.hintBackDuration,
        curve: widget.hintBackCurve,
      );
    } finally {
      _hintAnimating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final revealPx = (-_offset).clamp(0.0, widget.reveal);
    final progress = (revealPx / widget.reveal).clamp(0.0, 1.0);

    final core = Listener(
      onPointerDown: (_) => _stopHints(), // bei Berührung Hints stoppen
      child: SizedBox(
        width: widget.buttonWidth,
        height: 36,
        child: widget.enableDrag
            ? GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onHorizontalDragStart: (_) => _stopHints(),
                onHorizontalDragUpdate: (d) {
                  setState(() {
                    _offset = (_offset + d.delta.dx).clamp(-widget.reveal, 0.0);
                  });
                },
                onHorizontalDragEnd: (d) {
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
        children: [Positioned(right: 0, top: 2, bottom: 2, child: moving)],
      ),
    );
  }
}
