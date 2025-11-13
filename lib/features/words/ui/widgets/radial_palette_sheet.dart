import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/palette_controller.dart';
import '../../application/palette_state.dart';
import '../../application/radial_palette_controller.dart';
import 'radial_palette_wheel.dart';
import 'rotary_color_ring.dart';

class RadialPaletteSheet extends ConsumerStatefulWidget {
  const RadialPaletteSheet({
    super.key,
    required this.onClose,
    required this.heroTag,
  });
  final VoidCallback onClose;
  final String heroTag;

  @override
  ConsumerState<RadialPaletteSheet> createState() => _RadialPaletteSheetState();
}

class _RadialPaletteSheetState extends ConsumerState<RadialPaletteSheet> {
  Color _activeColor = const Color(0xFFFFC66A);
  final GlobalKey<RotaryColorRingState> _ringKey =
      GlobalKey<RotaryColorRingState>();

  @override
  void initState() {
    super.initState();
    _activeColor = ref.read(paletteControllerProvider).selectedColor;
  }

  @override
  Widget build(BuildContext context) {
    final paletteState = ref.watch(paletteControllerProvider);
    final ctrl = ref.read(paletteControllerProvider.notifier);
    final radialPalette = ref.watch(radialPaletteProvider);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          ModalBarrier(
            color: Colors.black54,
            dismissible: true,
            onDismiss: widget.onClose,
          ),
          if (radialPalette.overlayVisible)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Hero(
                tag: widget.heroTag,
                child: RadialPaletteWheel(
                  ringKey: _ringKey,
                  activeColor: _activeColor,
                  activeTarget: paletteState.target,
                  isAll: paletteState.scope == ApplyScope.all,
                  onActiveColorChanged: (c) => setState(() => _activeColor = c),
                  onPickColor: (c) {
                    ctrl.setSelectedColor(c);
                    if (paletteState.scope == ApplyScope.all) {
                      ctrl.dropOn();
                    }
                  },
                  onToggleScope: ctrl.toggleScope,
                  onCenterToggleScope: ctrl.toggleScope,
                  onCenterReset: ctrl.resetToDefaults,
                  onSwitchPalette: () => _ringKey.currentState?.switchPalette(),
                  onTargetSelected: ctrl.setTarget,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
