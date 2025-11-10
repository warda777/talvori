import 'dart:async';
import 'package:flutter/material.dart';

class SlideHintController {
  _SlideHintButtonState? _s;
  void _bind(_SlideHintButtonState s) => _s = s;

  Future<void> open() async => _s!._animateTo(-_s!.widget.reveal);
  Future<void> close() async => _s!._animateTo(0);
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
  });

  final Widget child; // dein Front-Button
  final double buttonWidth; // z.B. 168
  final double reveal; // wie weit nach links aufschieben (z.B. 168)
  final bool enableDrag; // optionales Drag nach links/rechts
  final SlideHintController? controller;

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

  @override
  void initState() {
    super.initState();
    widget.controller?._bind(this);
    _ac.addListener(() {
      if (_anim != null) setState(() => _offset = _anim!.value);
    });
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  Future<void> _animateTo(
    double target, {
    Duration d = const Duration(milliseconds: 240),
    Curve curve = Curves.easeOut,
  }) async {
    final t = target.clamp(-widget.reveal, 0.0);
    _ac.stop();
    _ac.duration = d;
    _anim = Tween<double>(
      begin: _offset,
      end: t,
    ).chain(CurveTween(curve: curve)).animate(_ac);
    final c = Completer<void>();
    void l(AnimationStatus s) {
      if (s == AnimationStatus.completed || s == AnimationStatus.dismissed) {
        _ac.removeStatusListener(l);
        _anim = null;
        c.complete();
      }
    }

    _ac.addStatusListener(l);
    _ac.forward(from: 0);
    await c.future;
  }

  Future<void> _nudge({double by = 24}) async {
    if (!mounted) return;
    await _animateTo(
      (-by).clamp(-widget.reveal, 0.0),
      d: const Duration(milliseconds: 160),
    );
    await _animateTo(
      0,
      d: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
    );
  }

  @override
  Widget build(BuildContext context) {
    final revealPx = (-_offset).clamp(0.0, widget.reveal);
    final progress = (revealPx / widget.reveal).clamp(0.0, 1.0);

    Widget moving = Transform.translate(
      offset: Offset(-revealPx, 0),
      child: Opacity(
        opacity: 1.0 - 0.35 * progress,
        child: SizedBox(
          width: widget.buttonWidth,
          height: 36,
          child: widget.enableDrag
              ? GestureDetector(
                  behavior: HitTestBehavior.deferToChild,
                  onHorizontalDragUpdate: (d) {
                    setState(() {
                      _offset = (_offset + d.delta.dx).clamp(
                        -widget.reveal,
                        0.0,
                      );
                    });
                  },
                  onHorizontalDragEnd: (d) {
                    final v = d.primaryVelocity ?? 0;
                    final open = _offset < -widget.reveal * 0.55 || v < -400;
                    _animateTo(open ? -widget.reveal : 0);
                  },
                  child: widget.child,
                )
              : widget.child,
        ),
      ),
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
