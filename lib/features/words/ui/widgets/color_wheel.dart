import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/palette_controller.dart';
import '../../application/palette_state.dart';

class ColorWheel extends ConsumerStatefulWidget {
  const ColorWheel({super.key});

  @override
  ConsumerState<ColorWheel> createState() => _ColorWheelState();
}

class _ColorWheelState extends ConsumerState<ColorWheel> {
  static const _palette = <Color>[
    Color(0xFFFFC66A), Color(0xFFB1CCFE), Color(0xFFFF8A65), Color(0xFF81C784),
    Color(0xFF64B5F6), Color(0xFFBA68C8), Color(0xFFFFD54F), Color(0xFFA1887F),
    Color(0xFF4DB6AC), Color(0xFFE57373),
  ];

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(paletteControllerProvider);
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        itemBuilder: (_, i) {
          final c = _palette[i % _palette.length];
          final selected = s.selectedColor.value == c.value;
          return _Bubble(
            color: c,
            selected: selected,
            onTap: () => ref.read(paletteControllerProvider.notifier).setSelectedColor(c),
            onDragStart: () => ref.read(paletteControllerProvider.notifier).startDrag(),
            onDragEnd: () => ref.read(paletteControllerProvider.notifier).endDrag(),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: _palette.length,
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.color,
    required this.selected,
    required this.onTap,
    required this.onDragStart,
    required this.onDragEnd,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    final size = selected ? 70.0 : 58.0;
    return LongPressDraggable<Color>(
      data: color,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: onDragStart,
      onDragEnd: (_) => onDragEnd(),
      feedback: RepaintBoundary(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, color.withOpacity(.6)]),
            boxShadow: [BoxShadow(color: color.withOpacity(.55), blurRadius: 18)],
          ),
          child: const SizedBox(width: 56, height: 56),
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, color.withOpacity(.7)]),
            boxShadow: [
              if (selected) BoxShadow(color: color.withOpacity(.5), blurRadius: 16),
            ],
            border: Border.all(color: Colors.white12),
          ),
        ),
      ),
    );
  }
}
