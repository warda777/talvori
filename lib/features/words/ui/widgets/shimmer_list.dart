import 'package:flutter/material.dart';

class ShimmerList extends StatefulWidget {
  final int items;
  const ShimmerList({super.key, this.items = 8});

  @override
  State<ShimmerList> createState() => _ShimmerListState();
}

class _ShimmerListState extends State<ShimmerList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final highlight = Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);

    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: widget.items,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, __) => _ShimmerTile(
            t: _c.value,
            base: base,
            highlight: highlight,
          ),
        );
      },
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  final double t;
  final Color base;
  final Color highlight;

  const _ShimmerTile({required this.t, required this.base, required this.highlight});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: base,
      ),
      child: ShaderMask(
        shaderCallback: (rect) {
          final width = rect.width;
          final gradX = (t * (width + 200)) - 200; // wandernde Bande
          return LinearGradient(
            begin: Alignment(-1.0 + (gradX / width), 0.0),
            end: Alignment(1.0 + (gradX / width), 0.0),
            colors: [base, highlight, base],
            stops: const [0.35, 0.5, 0.65],
          ).createShader(rect);
        },
        blendMode: BlendMode.srcATop,
        child: Row(
          children: [
            const SizedBox(width: 12),
            _bar(width: 56, height: 12, radius: 6),
            const SizedBox(width: 12),
            Expanded(child: _bar(width: double.infinity, height: 12, radius: 6)),
          ],
        ),
      ),
    );
  }

  Widget _bar({required double width, required double height, double radius = 8}) {
    return Container(
      width: width == double.infinity ? null : width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
