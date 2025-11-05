import 'package:flutter/material.dart';
import 'package:talvori/core/ui/effects/fireworks_overlay.dart';

class FireworksService {
  static void show(BuildContext context, {Duration duration = const Duration(seconds: 2)}) {
    Fireworks.show(context, duration: duration);
  }
}
