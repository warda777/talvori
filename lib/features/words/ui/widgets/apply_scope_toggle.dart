import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/palette_controller.dart';
import '../../application/palette_state.dart';

class ApplyScopeToggle extends ConsumerWidget {
  const ApplyScopeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(paletteControllerProvider.select((s) => s.scope));
    final isAll = scope == ApplyScope.all;
    return GestureDetector(
      onDoubleTap: () => ref.read(paletteControllerProvider.notifier).toggleScope(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isAll ? Colors.white10 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isAll ? Icons.groups_rounded : Icons.filter_1_rounded,
                size: 16, color: Colors.white70),
            const SizedBox(width: 6),
            Text(isAll ? 'Alle' : 'Einzeln',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
