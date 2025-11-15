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
    this.onToolReset,
    this.onToolResetStart,
    this.onToolResetEnd,
    this.onResetAll, // NEU: Callback für kompletten Reset
    this.onResetAllStart, // NEU: Callback für Reset-Start
    this.onResetAllEnd, // NEU: Callback für Reset-Ende
  });
  final VoidCallback onClose;
  final String heroTag;
  final ValueChanged<PaletteTool>? onToolReset;
  final void Function(VoidCallback)? onToolResetStart; // Callback erhält onComplete-Funktion
  final VoidCallback? onToolResetEnd;
  final VoidCallback? onResetAll; // NEU: Callback für kompletten Reset
  final VoidCallback? onResetAllStart; // NEU: Callback für Reset-Start
  final VoidCallback? onResetAllEnd; // NEU: Callback für Reset-Ende

  @override
  ConsumerState<RadialPaletteSheet> createState() => _RadialPaletteSheetState();
}

class _RadialPaletteSheetState extends ConsumerState<RadialPaletteSheet> {
  Color _activeColor = const Color(0xFFFFC66A);
  final GlobalKey<RotaryColorRingState> _ringKey =
      GlobalKey<RotaryColorRingState>();
  bool _isResetting = false;
  PaletteTool? _resettingTool;
  bool _isResettingAll = false; // NEU: Flag für All/One Reset

  @override
  void initState() {
    super.initState();
    _activeColor = ref.read(paletteControllerProvider).selectedColor;
  }

  String _getResetMessage(PaletteTool tool) {
    switch (tool) {
      case PaletteTool.stroke:
        return 'Die Rahmen werden jetzt vollständig gelöscht.';
      case PaletteTool.fill:
        return 'Die Hintergründe werden jetzt vollständig gelöscht.';
      case PaletteTool.text:
        return 'Die Texte werden jetzt vollständig gelöscht.';
      case PaletteTool.hubBackground:
        return 'Die Hintergründe werden jetzt vollständig gelöscht.';
      case PaletteTool.icon:
        return 'Die Icons werden jetzt vollständig gelöscht.';
      case PaletteTool.paint:
        return 'Die Custom Einstellungen werden jetzt vollständig gelöscht.';
      case PaletteTool.image:
        return '';
    }
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
          if (radialPalette.overlayVisible) ...[
            ModalBarrier(
              color: Colors.black54,
              dismissible: true,
              onDismiss: widget.onClose,
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ],
          // Nachricht oberhalb des Rads für Tool-Reset (gleiche Position wie All/One Reset)
          if (_isResetting && _resettingTool != null)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.15, // NEU: Gleiche Position wie All/One Reset
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Text(
                    _getResetMessage(_resettingTool!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          // NEU: Nachricht weiter oben für All/One Reset
          if (_isResettingAll)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.15, // Weiter oben
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: const Text(
                    'Alles wird auf Werkseinstellung zurückgesetzt.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
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
                  onToolReset: widget.onToolReset,
                  onToolResetStart: (onComplete) {
                    setState(() {
                      _isResetting = true;
                      _resettingTool = radialPalette.activeTool;
                    });
                    widget.onToolResetStart?.call(onComplete);
                  },
                  onToolResetEnd: () {
                    setState(() {
                      _isResetting = false;
                      _resettingTool = null;
                    });
                    widget.onToolResetEnd?.call();
                  },
                  onSwitchPalette: () => _ringKey.currentState?.switchPalette(),
                  onTargetSelected: ctrl.setTarget,
                  onResetAll: widget.onResetAll, // NEU: Callback für kompletten Reset
                  onResetAllStart: () {
                    setState(() {
                      _isResettingAll = true;
                    });
                    widget.onResetAllStart?.call();
                  },
                  onResetAllEnd: () {
                    setState(() {
                      _isResettingAll = false;
                    });
                    widget.onResetAllEnd?.call();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
