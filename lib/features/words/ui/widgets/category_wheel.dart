import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talvori/features/words/application/sort/category_stroke_colors.dart';

const double kWheelWidth = 280.0;
const double kWheelHeight = 72.0;
const double kWheelItemExtent = 34.0;
const double kWheelPillWidth = 240.0;
const double kWheelPillRadius = 14.0;

const double kWheelActiveOpacity = 1.0;
const double kWheelNeighborOpacity = 0.55;
const double kWheelFarOpacity = 0.30;

const double kWheelActiveScale = 1.00;
const double kWheelNeighborScale = 0.94;
const double kWheelFarScale = 0.88;

const double kWheelGlowBlur = 18.0;
const double kWheelGlowOpacity = 0.35;

const double kWheelEdgeFadeHeight = 24.0;

const double kWheelArrowRightOut = 22.0;
const int kWheelArrowAutoHideMs = 800;
const double kWheelArrowNudge = 0.0;

/// Reine UI-Komponente – liefert den gedimmten Wheel-Selector.
/// `onChanged(index, label)` wird bei Auswahl aufgerufen.
class CategoryWheel extends StatefulWidget {
  final List<String> categories;
  final int initialIndex;
  final void Function(int index, String label) onChanged;
  final Color? activeStrokeColor;
  final Color? activeFillColor;
  final Color? activeTextColor;
  final Color? edgeFadeColor;
  final bool showEdgeFade;

  const CategoryWheel({
    super.key,
    required this.categories,
    required this.initialIndex,
    required this.onChanged,
    this.activeStrokeColor,
    this.activeFillColor,
    this.activeTextColor,
    this.edgeFadeColor,
    this.showEdgeFade = true,
  });

  @override
  State<CategoryWheel> createState() => _CategoryWheelState();
}

class _CategoryWheelState extends State<CategoryWheel>
    with SingleTickerProviderStateMixin {
  Timer? _notifyDebounce;
  late FixedExtentScrollController _ctrl;
  late int _current;
  bool _showArrows = false;
  bool _flashUp = false;
  bool _flashDown = false;
  DateTime _lastMove = DateTime.now();

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex.clamp(
      0,
      (widget.categories.length - 1).clamp(0, 9999),
    );
    _ctrl = FixedExtentScrollController(initialItem: _current);
  }

  @override
  void dispose() {
    _notifyDebounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CategoryWheel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.categories.length != oldWidget.categories.length) {
      _current = _current.clamp(
        0,
        (widget.categories.length - 1).clamp(0, 9999),
      );
    }

    if (widget.initialIndex != oldWidget.initialIndex &&
        !_ctrl.position.isScrollingNotifier.value) {
      final newIndex = widget.initialIndex.clamp(
        0,
        (widget.categories.length - 1).clamp(0, 9999),
      );
      _current = newIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ctrl.jumpToItem(_current);
      });
    }
  }

  void _onChanged(int idx) {
    if (idx == _current) return;
    final oldCurrent = _current;
    setState(() {
      _flashUp = idx < oldCurrent;
      _flashDown = idx > oldCurrent;
      _showArrows = true;
      _current = idx;
      _lastMove = DateTime.now();
    });

    HapticFeedback.lightImpact();

    Future.delayed(const Duration(milliseconds: kWheelArrowAutoHideMs), () {
      if (mounted &&
          DateTime.now().difference(_lastMove).inMilliseconds >=
              kWheelArrowAutoHideMs) {
        setState(() => _showArrows = false);
      }
    });

    widget.onChanged(idx, widget.categories[idx]);
  }

  @override
  Widget build(BuildContext context) {
    final cats = widget.categories;
    if (cats.isEmpty) {
      return Container(
        width: kWheelWidth,
        height: kWheelHeight,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('Loading...', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return SizedBox(
      width: kWheelWidth,
      height: kWheelHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          (widget.showEdgeFade
              ? _EdgeFade(
                  fadeHeight: kWheelEdgeFadeHeight,
                  fadeColor: widget.edgeFadeColor,
                  child: _CategoryWheelScrollView(
                    controller: _ctrl,
                    cats: cats,
                    current: _current,
                    activeStrokeColor: widget.activeStrokeColor,
                    activeFillColor: widget.activeFillColor,
                    activeTextColor: widget.activeTextColor,
                    onChanged: _onChanged,
                  ),
                )
              : _CategoryWheelScrollView(
                  controller: _ctrl,
                  cats: cats,
                  current: _current,
                  activeStrokeColor: widget.activeStrokeColor,
                  activeFillColor: widget.activeFillColor,
                  activeTextColor: widget.activeTextColor,
                  onChanged: _onChanged,
                )),

          // rechte Pfeile + Counter dazwischen
          Positioned.fill(
            right: -kWheelArrowRightOut,
            child: IgnorePointer(
              ignoring: false,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: kWheelArrowNudge),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _showArrows ? 1.0 : 0.0,
                        child: _ArrowIcon(
                          up: true,
                          flash: _flashUp,
                          onTap: () => _ctrl.animateToItem(
                            (_current - 1).clamp(0, cats.length - 1),
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _showArrows ? 1.0 : 0.0,
                        child: _ArrowIcon(
                          up: false,
                          flash: _flashDown,
                          onTap: () => _ctrl.animateToItem(
                            (_current + 1).clamp(0, cats.length - 1),
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryWheelScrollView extends StatelessWidget {
  const _CategoryWheelScrollView({
    required this.controller,
    required this.cats,
    required this.current,
    required this.activeStrokeColor,
    required this.activeFillColor,
    required this.activeTextColor,
    required this.onChanged,
  });

  final FixedExtentScrollController controller;
  final List<String> cats;
  final int current;
  final Color? activeStrokeColor;
  final Color? activeFillColor;
  final Color? activeTextColor;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: kWheelItemExtent,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onChanged,
      diameterRatio: 2.2,
      perspective: 0.002,
      overAndUnderCenterOpacity: 1,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: cats.length,
        builder: (context, index) {
          final dist = (index - current).abs();

          final opacity = dist == 0
              ? kWheelActiveOpacity
              : (dist == 1 ? kWheelNeighborOpacity : kWheelFarOpacity);

          final scale = dist == 0
              ? kWheelActiveScale
              : (dist == 1 ? kWheelNeighborScale : kWheelFarScale);

          final strokeColor = dist == 0 && activeStrokeColor != null
              ? activeStrokeColor!
              : CategoryStrokeColors.getWheelStrokeColor(cats[index]);

          return Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 120),
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: _AdaptivePill(
                  text: cats[index],
                  width: kWheelPillWidth,
                  height: kWheelItemExtent - 6,
                  radius: kWheelPillRadius,
                  active: dist == 0,
                  strokeColor: strokeColor,
                  fillColor: dist == 0 ? activeFillColor : null,
                  textColor: dist == 0 ? activeTextColor : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AdaptivePill extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final double radius;
  final bool active;
  final Color strokeColor;
  final Color? fillColor;
  final Color? textColor;

  const _AdaptivePill({
    required this.text,
    required this.width,
    required this.height,
    required this.radius,
    required this.active,
    required this.strokeColor,
    this.fillColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: fillColor ?? const Color(0xFF2D2C2C),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: strokeColor, width: 1.5),
        boxShadow: active && kWheelGlowBlur > 0
            ? [
                BoxShadow(
                  color: strokeColor.withValues(alpha: kWheelGlowOpacity),
                  blurRadius: kWheelGlowBlur,
                ),
              ]
            : const [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _EdgeFade extends StatelessWidget {
  final double fadeHeight;
  final Color? fadeColor;
  final Widget child;
  const _EdgeFade({
    required this.fadeHeight,
    required this.child,
    this.fadeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: fadeHeight,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (fadeColor ?? Theme.of(context).scaffoldBackgroundColor)
                        .withValues(alpha: 0.95),
                    (fadeColor ?? Theme.of(context).scaffoldBackgroundColor)
                        .withValues(alpha: 0.7),
                    (fadeColor ?? Theme.of(context).scaffoldBackgroundColor)
                        .withValues(alpha: 0.4),
                    (fadeColor ?? Theme.of(context).scaffoldBackgroundColor)
                        .withValues(alpha: 0.1),
                    (fadeColor ?? Theme.of(context).scaffoldBackgroundColor)
                        .withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: fadeHeight,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    (fadeColor ?? Theme.of(context).scaffoldBackgroundColor)
                        .withValues(alpha: 0.95),
                    (fadeColor ?? Theme.of(context).scaffoldBackgroundColor)
                        .withValues(alpha: 0.7),
                    (fadeColor ?? Theme.of(context).scaffoldBackgroundColor)
                        .withValues(alpha: 0.4),
                    (fadeColor ?? Theme.of(context).scaffoldBackgroundColor)
                        .withValues(alpha: 0.1),
                    (fadeColor ?? Theme.of(context).scaffoldBackgroundColor)
                        .withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArrowIcon extends StatelessWidget {
  final bool up;
  final bool flash;
  final VoidCallback onTap;
  const _ArrowIcon({
    required this.up,
    required this.flash,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: 0.7,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
          ),
          alignment: Alignment.center,
          child: Icon(
            up
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}
