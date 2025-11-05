import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:talvori/core/ui/effects/fireworks_service.dart';

class VIconController {
  late final AnimationController _ctrl;
  late final Animation<double> rotation; // 0..1 (=> 0..360°)

  void init({required TickerProvider vsync}) {
    _ctrl = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 900));
    rotation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
  }

  void dispose() => _ctrl.dispose();

  Future<void> _spin() async {
    await _ctrl.animateTo(0.35, duration: const Duration(milliseconds: 180), curve: Curves.linear);
    await _ctrl.animateTo(1.0, duration: const Duration(milliseconds: 720), curve: Curves.easeOutQuart);
    _ctrl.value = 0;
  }

  Future<void> handleVerticalDragEnd(DragEndDetails d, BuildContext context) async {
    if (d.velocity.pixelsPerSecond.dy > 200) {
      FireworksService.show(context, duration: const Duration(seconds: 15));
      await _spin();
    }
  }

  double get angleRad => rotation.value * 2 * math.pi;
}
