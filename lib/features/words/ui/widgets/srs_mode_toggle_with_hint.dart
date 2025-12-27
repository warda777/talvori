import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';
import 'package:talvori/features/words/ui/widgets/srs_mode_toggle.dart';

class SrsModeToggleWithHint extends ConsumerStatefulWidget {
  const SrsModeToggleWithHint({
    super.key,
    this.toggleHeight = 44, // sichtbare Höhe des Toggles (anpassen falls nötig)
    this.gap = 6,           // Abstand unter dem Toggle
  });

  final double toggleHeight;
  final double gap;

  @override
  ConsumerState<SrsModeToggleWithHint> createState() => _SrsModeToggleWithHintState();
}

class _SrsModeToggleWithHintState extends ConsumerState<SrsModeToggleWithHint> {
  bool _show = false;
  Timer? _timer;
  bool _hasShownInitialHint = false;

  void _flash() {
    _timer?.cancel();
    setState(() => _show = true);
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _show = false);
    });
  }

  void _showInitialHint() {
    if (_hasShownInitialHint) return;
    _hasShownInitialHint = true;
    _timer?.cancel();
    setState(() => _show = true);
    _timer = Timer(const Duration(seconds: 10), () {
      if (mounted) setState(() => _show = false);
    });
  }

  @override
  void initState() {
    super.initState();
    // Zeige den Hinweis automatisch beim ersten Betreten für 10 Sekunden
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInitialHint();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hinweis nur bei Wechsel T-SRS <-> A-SRS
    ref.listen<SrsModeState>(srsModeControllerProvider, (prev, next) {
      final f = prev?.mode, t = next.mode;
      if ((f == SrsSystem.time && t == SrsSystem.adaptive) ||
          (f == SrsSystem.adaptive && t == SrsSystem.time)) {
        _flash();
      }
    });

    // Fixe Box in Toggle-Höhe; Hint wird darunter GEMALT (ohne Layout-Shift)
    return SizedBox(
      height: widget.toggleHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          const SrsModeToggle(),
          if (_show)
            Positioned(
              top: widget.toggleHeight + widget.gap, // unter dem Toggle
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Long-press for Hybrid',
                    style: TextStyle(fontSize: 10, color: Colors.white, height: 1),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
