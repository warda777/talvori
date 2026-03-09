import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';

class SrsModeToggle extends ConsumerWidget {
  const SrsModeToggle({super.key, this.onUserTap});

  final VoidCallback? onUserTap;

  static const _size = Size(80, 44);
  static const _gold = Color(0xFFE5B966);
  static const _track = Color(0xFF2C2C2C);
  static const _thumb = _gold;
  static const _outline = Color(0xFFAFCCFE); // blau: Stroke/Outline
  static const _activeTxt = _gold;
  static const _inactiveTxt = Colors.white70;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(srsModeControllerProvider);
    final ctrl = ref.read(srsModeControllerProvider.notifier);
    final mode = state.mode;
    final isHybrid = mode == SrsSystem.hybrid;
    final isAdaptive = mode == SrsSystem.adaptive;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        ctrl.tap();
        onUserTap?.call();
      },
      onLongPress: () {
        ctrl.longPress();
        onUserTap?.call();
      },
      child: SizedBox(
        width: _size.width,
        height: _size.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!isHybrid) _buildTA(ref, isAdaptive),
            if (isHybrid)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ctrl.tap();
                  onUserTap?.call();
                },
                child: _buildHybridButton(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTA(WidgetRef ref, bool isAdaptive) {
    // Stack lässt uns außerhalb der 80×44 zeichnen, ohne Layout zu verbreitern.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Switch zentriert
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 36,
            height: 30,
            child: Transform.scale(
              scale: 1.0,
              child: AbsorbPointer(
                absorbing: true,
                child: Switch(
                  value: isAdaptive, // bewegt die Kugel visuell
                  onChanged: (_) {},
                  thumbColor: const MaterialStatePropertyAll(_thumb),
                  trackColor: const MaterialStatePropertyAll(_track),
                  trackOutlineColor: const MaterialStatePropertyAll(_outline),
                ),
              ),
            ),
          ),
        ),

        // T-SRS links, vertikal mittig
        Align(
          alignment: Alignment.centerLeft,
          child: Transform.translate(
            offset: const Offset(-46, 0),
            child: Container(
              decoration: !isAdaptive
                  ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: _activeTxt.withOpacity(0.20), blurRadius: 16, spreadRadius: 3, offset: const Offset(0, 6)),
                        BoxShadow(color: _activeTxt.withOpacity(0.10), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 6)),
                      ],
                    )
                  : null,
              child: Text(
                'T-SRS',
                style: TextStyle(
                  color: !isAdaptive ? _activeTxt : _inactiveTxt,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  shadows: !isAdaptive
                      ? [Shadow(color: _activeTxt.withOpacity(0.25), blurRadius: 14, offset: const Offset(0, 10))]
                      : null,
                ),
              ),
            ),
          ),
        ),

        // A-SRS rechts, vertikal mittig
        Align(
          alignment: Alignment.centerRight,
          child: Transform.translate(
            offset: const Offset(46, 0),
            child: Container(
              decoration: isAdaptive
                  ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: _activeTxt.withOpacity(0.20), blurRadius: 16, spreadRadius: 1, offset: const Offset(0, 6)),
                        BoxShadow(color: _activeTxt.withOpacity(0.10), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 6)),
                      ],
                    )
                  : null,
              child: Text(
                'A-SRS',
                style: TextStyle(
                  color: isAdaptive ? _activeTxt : _inactiveTxt,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  shadows: isAdaptive
                      ? [Shadow(color: _activeTxt.withOpacity(0.25), blurRadius: 14, offset: const Offset(0, 10))]
                      : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHybridButton() {
    return Container(
      width: _size.width,
      height: _size.height,
      decoration: BoxDecoration(
        color: _gold,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(color: _gold.withOpacity(0.55), blurRadius: 20, spreadRadius: 1),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        'Hybrid',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Colors.black,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
