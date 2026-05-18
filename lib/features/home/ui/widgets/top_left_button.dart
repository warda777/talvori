import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/home/application/v_icon_controller.dart';
import 'package:talvori/features/home/application/application.dart';
import 'package:talvori/features/home/ui/widgets/tap_flash.dart';

class TopLeftButton extends ConsumerStatefulWidget {
  final Widget icon;
  final double size;
  final VoidCallback onTap;

  const TopLeftButton({
    super.key,
    required this.icon,
    this.size = 52.0,
    required this.onTap,
  });

  // konstante Farben müssen static const sein
  static const Color gold = Color(0xFF5DDCFF);
  static const Color buttonColor = Color(0xFF07101A);

  @override
  ConsumerState<TopLeftButton> createState() => _TopLeftButtonState();
}

class _TopLeftButtonState extends ConsumerState<TopLeftButton>
    with TickerProviderStateMixin {
  final VIconController _c = VIconController();

  @override
  void initState() {
    super.initState();
    _c.init(vsync: this);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dim = widget.size;
    final glowEnabled = ref.watch(
      homeControllerProvider.select((s) => s.glowEnabled),
    );

    return SizedBox.square(
      dimension: dim,
      child: GestureDetector(
        onVerticalDragEnd: (d) => _c.handleVerticalDragEnd(d, context),
        child: TapFlash(
          color: TopLeftButton.gold,
          shape: BoxShape.circle,
          maxOpacity: 1.0,
          blur: 28,
          spread: 6,
          duration: const Duration(milliseconds: 220),
          onTapAfter: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: TopLeftButton.buttonColor,
              shape: BoxShape.circle,
              border: Border.all(color: TopLeftButton.gold, width: 2),
              boxShadow: glowEnabled
                  ? [
                      BoxShadow(
                        color: TopLeftButton.gold.withValues(alpha: 0.42),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: AnimatedBuilder(
              animation: _c.rotation,
              builder: (_, child) =>
                  Transform.rotate(angle: _c.angleRad, child: child),
              child: widget.icon,
            ),
          ),
        ),
      ),
    );
  }
}
