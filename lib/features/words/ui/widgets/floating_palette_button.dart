import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/palette_controller.dart';
import 'color_wheel.dart';
import 'apply_scope_toggle.dart';
import 'radial_palette_sheet.dart';

class FloatingPaletteButton extends StatefulWidget {
  const FloatingPaletteButton({
    super.key,
    this.scrollController,
    this.heroTag = 'floating-palette',
  });

  final ScrollController? scrollController;
  final String heroTag;

  @override
  State<FloatingPaletteButton> createState() => _FloatingPaletteButtonState();
}

class _FloatingPaletteButtonState extends State<FloatingPaletteButton>
    with TickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  )..value = 1;

  OverlayEntry? _entry;
  double _lastOffset = 0;
  bool _hidden = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }

  void _onScroll() {
    final dy = widget.scrollController!.position.pixels;
    final goingDown = dy > _lastOffset;
    _lastOffset = dy;
    if (goingDown && !_hidden) {
      _hidden = true;
      _fade.reverse();
    } else if (!goingDown && _hidden) {
      _hidden = false;
      _fade.forward();
    }
  }

  void _openOverlay() {
    if (_entry != null) return;
    final overlay = Overlay.of(context);
    _entry = OverlayEntry(
      builder: (_) =>
          RadialPaletteSheet(onClose: _closeOverlay, heroTag: widget.heroTag),
    );
    overlay.insert(_entry!);
  }

  void _closeOverlay() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _pulse.dispose();
    _fade.dispose();
    _closeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _fade.drive(Tween(begin: .95, end: 1)),
        child: RepaintBoundary(
          child: Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 24),
            child: GestureDetector(
              onTap: _entry == null ? _openOverlay : _closeOverlay,
              child: Hero(
                tag: widget.heroTag,
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) {
                    final t = CurvedAnimation(
                      parent: _pulse,
                      curve: Curves.easeInOut,
                    ).value;
                    final glow = 6 + 6 * t;
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          center: Alignment(-.2, -.25),
                          radius: .9,
                          colors: [Color(0xFFFFC66A), Color(0xFFB1CCFE)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: glow,
                            color: Colors.black.withOpacity(.55),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipOval(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                                child: const SizedBox(),
                              ),
                            ),
                            const Center(
                              child: Icon(
                                Icons.palette_rounded,
                                size: 26,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
