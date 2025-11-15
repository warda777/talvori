import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // für HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/radial_palette_controller.dart';
import '../../application/word_hub_tile_overrides_provider.dart';
import 'rotary_color_ring.dart';
import 'custom_color_picker_dialog.dart';
import 'icon_picker_dialog.dart';

class _CenterToolButton extends ConsumerStatefulWidget {
  final PaletteTool tool;
  final Widget? centerWidget;
  final IconData? icon;
  final RadialPaletteController ctrl;
  final GlobalKey<RotaryColorRingState>? ringKey;
  final ValueChanged<PaletteTool>? onToolReset;
  final void Function(VoidCallback)? onToolResetStart; // Callback erhält onComplete-Funktion
  final VoidCallback? onToolResetEnd;

  const _CenterToolButton({
    required this.tool,
    this.centerWidget,
    this.icon,
    required this.ctrl,
    this.ringKey,
    this.onToolReset,
    this.onToolResetStart,
    this.onToolResetEnd,
  });

  @override
  ConsumerState<_CenterToolButton> createState() => _CenterToolButtonState();
}

class _CenterToolButtonState extends ConsumerState<_CenterToolButton> {
  bool _isLongPressing = false;

  void _handleLongPressStart() {
    setState(() {
      _isLongPressing = true;
    });
    HapticFeedback.mediumImpact();
    // Starte visuellen Effekt am ScopeSwitchButton mit Callback für automatischen Reset
    widget.onToolResetStart?.call(() {
      // Wird aufgerufen, wenn Animation bei 100% ist
      if (_isLongPressing) {
        setState(() {
          _isLongPressing = false;
        });
        
        // Reset durchführen
        widget.ctrl.resetTool(widget.tool);
        ref.read(wordHubTileOverridesProvider.notifier)
            .resetToolOverrides(widget.tool);
        
        // Header-Elemente zurücksetzen über Callback
        widget.onToolReset?.call(widget.tool);
        
        // Stoppe visuellen Effekt am ScopeSwitchButton
        widget.onToolResetEnd?.call();
        
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _handleLongPressEnd() {
    if (_isLongPressing) {
      setState(() {
        _isLongPressing = false;
      });
      
      // Stoppe visuellen Effekt am ScopeSwitchButton
      widget.onToolResetEnd?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.ctrl.selectTool(widget.tool),
      onLongPressStart: (_) => _handleLongPressStart(),
      onLongPressEnd: (_) => _handleLongPressEnd(),
      onLongPressCancel: () {
        setState(() {
          _isLongPressing = false;
        });
        widget.onToolResetEnd?.call();
      },
      child: widget.centerWidget != null
          ? Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
              ),
              child: widget.centerWidget,
            )
          : _RoundIcon(
              icon: widget.icon!,
              isActive: true,
              onTap: () => widget.ctrl.selectTool(widget.tool),
              ringKey: widget.ringKey,
              hasStroke: widget.tool == PaletteTool.icon,
            ),
    );
  }
}

class RadialTools extends ConsumerWidget {
  const RadialTools({
    super.key,
    required this.ringKey,
    required this.discSize,
    this.onPickColor,
    this.activeColor,
    this.onToolReset,
    this.onToolResetStart,
    this.onToolResetEnd,
  });

  final GlobalKey<RotaryColorRingState> ringKey;
  final double discSize;
  final ValueChanged<Color>? onPickColor;
  final Color? activeColor;
  final ValueChanged<PaletteTool>? onToolReset;
  final void Function(VoidCallback)? onToolResetStart; // Callback erhält onComplete-Funktion
  final VoidCallback? onToolResetEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(radialPaletteProvider);
    final ctrl = ref.read(radialPaletteProvider.notifier);

    // NEU: RadialTools nimmt die ganze Fläche des Wheels ein
    return SizedBox.expand(
      child: palette.activeTool == null
          ? Stack(
              children: [
                _toolAtAngle(
                  context,
                  icon: Icons.border_all,
                  tool: PaletteTool.stroke,
                  angleDeg: -90,
                  palette: palette,
                  ctrl: ctrl,
                  ringKey: ringKey,
                ),
                _toolAtAngle(
                  context,
                  icon: Icons.crop_square,
                  tool: PaletteTool.fill,
                  angleDeg: -38,
                  palette: palette,
                  ctrl: ctrl,
                  ringKey: ringKey,
                ),
                _toolAtAngle(
                  context,
                  icon: Icons.text_fields,
                  tool: PaletteTool.text,
                  angleDeg: 14,
                  palette: palette,
                  ctrl: ctrl,
                  ringKey: ringKey,
                ),
                _toolAtAngle(
                  context,
                  icon: Icons.layers,
                  tool: PaletteTool.hubBackground,
                  angleDeg: 66,
                  palette: palette,
                  ctrl: ctrl,
                  ringKey: ringKey,
                ),
                _toolAtAngle(
                  context,
                  icon: Icons.palette,
                  tool: PaletteTool.paint,
                  angleDeg: 118,
                  palette: palette,
                  ctrl: ctrl,
                  ringKey: ringKey,
                ),
                _toolAtAngle(
                  context,
                  icon: Icons.star,
                  tool: PaletteTool.icon,
                  angleDeg: 170,
                  palette: palette,
                  ctrl: ctrl,
                  ringKey: ringKey,
                  onLongPress: () {
                    // Longpress-Funktion für Icon Tool-Button - öffnet Icon-Picker
                    HapticFeedback.mediumImpact();
                    showDialog(
                      context: context,
                      builder: (context) => IconPickerDialog(
                        selectedIcon: palette.selectedIcon,
                        selectedEmoji: palette.selectedEmoji,
                        onIconSelected: (icon) {
                          ctrl.selectIcon(icon);
                        },
                        onEmojiSelected: (emoji) {
                          ctrl.selectEmoji(emoji);
                        },
                      ),
                    );
                  },
                ),
                _toolAtAngle(
                  context,
                  icon: Icons.image,
                  tool: PaletteTool.image,
                  angleDeg: 222,
                  palette: palette,
                  ctrl: ctrl,
                  ringKey: ringKey,
                ),
              ],
            )
          : _buildActiveToolMode(
              context,
              palette,
              ctrl,
              ringKey,
              discSize,
              onPickColor: onPickColor,
              activeColor: activeColor,
              onToolReset: onToolReset,
              onToolResetStart: onToolResetStart,
              onToolResetEnd: onToolResetEnd,
            ),
    );
  }

  Widget _toolAtAngle(
    BuildContext context, {
    required IconData icon,
    required PaletteTool tool,
    required double angleDeg,
    required RadialPaletteState palette,
    required RadialPaletteController ctrl,
    required GlobalKey<RotaryColorRingState> ringKey,
    VoidCallback? onLongPress,
  }) {
    final rad = angleDeg * 3.1415926535 / 180;
    const r = 110.0;

    final offset = Offset(
      r * math.cos(rad),
      r * math.sin(rad),
    );

    return Align(
      alignment: Alignment.center, // 🔹 Basis ist die Mitte
      child: Transform.translate(
        offset: offset, // 🔹 von der Mitte weg verschieben
        child: _RoundIcon(
          icon: icon,
          isActive: palette.activeTool == tool,
          onTap: () => ctrl.selectTool(tool),
          ringKey: ringKey,
          onLongPress: onLongPress,
          hasStroke: tool == PaletteTool.icon,
        ),
      ),
    );
  }

  Widget _buildActiveToolMode(
    BuildContext context,
    RadialPaletteState palette,
    RadialPaletteController ctrl,
    GlobalKey<RotaryColorRingState> ringKey,
    double discSize, {
    ValueChanged<Color>? onPickColor,
    Color? activeColor,
    ValueChanged<PaletteTool>? onToolReset,
    void Function(VoidCallback)? onToolResetStart,
    VoidCallback? onToolResetEnd,
  }) {
    final tool = palette.activeTool!;

    // Wenn Icon Tool aktiv ist und ein Icon/Emoji ausgewählt wurde, dieses anzeigen
    Widget? centerWidget;
    if (tool == PaletteTool.icon) {
      if (palette.selectedEmoji != null) {
        // Emoji anzeigen
        centerWidget = Center(
          child: Text(
            palette.selectedEmoji!,
            style: const TextStyle(fontSize: 32),
          ),
        );
      } else if (palette.selectedIcon != null) {
        // Icon anzeigen
        centerWidget = Icon(
          palette.selectedIcon,
          color: Colors.white,
          size: 32,
        );
      }
    }

    // Fallback: Standard-Icon für das Tool
    final icon = centerWidget == null ? (switch (tool) {
      PaletteTool.stroke => Icons.border_all,
      PaletteTool.fill => Icons.crop_square,
      PaletteTool.text => Icons.text_fields,
      PaletteTool.hubBackground => Icons.layers,
      PaletteTool.paint => Icons.palette,
      PaletteTool.icon => Icons.star,
      PaletteTool.image => Icons.image,
    }) : null;

    return Center(
      child: SizedBox(
        width: discSize,
        height: discSize,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // 🔹 Dünner Ring mit Kugel, der durch die Targets steppt
            // Dieser leitet die Gesten an den RotaryColorRing weiter, wenn Icons/Emojis angezeigt werden
            _FocusSelectorRing(
              size: discSize,
              ringKey: ringKey,
              onPickColor: onPickColor,
              activeColor: activeColor,
            ),

            // 🔹 Mittleres Tool-Icon/Emoji zum Abwählen mit Longpress-Reset
            _CenterToolButton(
              tool: tool,
              centerWidget: centerWidget,
              icon: icon,
              ctrl: ctrl,
              ringKey: ringKey,
              onToolReset: onToolReset,
              onToolResetStart: onToolResetStart,
              onToolResetEnd: onToolResetEnd,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.ringKey,
    this.onLongPress,
    this.hasStroke = false,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final GlobalKey<RotaryColorRingState>? ringKey;
  final VoidCallback? onLongPress;
  final bool hasStroke;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent, // Ändere zu translucent, damit Pan-Gesten durchgehen
      onPanStart: ringKey != null
          ? (d) => ringKey!.currentState?.handleExternalPanStart(d)
          : null,
      onPanUpdate: ringKey != null
          ? (d) => ringKey!.currentState?.handleExternalPanUpdate(d)
          : null,
      onPanEnd: ringKey != null
          ? (d) => ringKey!.currentState?.handleExternalPanEnd(d)
          : null,
      onLongPress: onLongPress,
      child: Material(
        type: MaterialType.transparency,
        child: InkResponse(
          onTap: onTap,
          onLongPress: onLongPress,
          containedInkWell: true,
          customBorder: const CircleBorder(),
          radius: 28,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isActive ? const Color(0x33FFFFFF) : const Color(0x151FFFFFF),
              shape: BoxShape.circle,
              border: Border.all(
                color: hasStroke 
                    ? Colors.white 
                    : (isActive ? Colors.white70 : Colors.white24),
                width: hasStroke 
                    ? 2.0 
                    : (isActive ? 1.6 : 1.0),
              ),
              boxShadow: isActive
                  ? [
                      const BoxShadow(
                        color: Colors.white24,
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: SizedBox(
              width: 56,
              height: 56,
              child: Center(child: Icon(icon, color: Colors.white, size: 24)),
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusSelectorRing extends ConsumerStatefulWidget {
  const _FocusSelectorRing({
    super.key,
    required this.size,
    this.ringKey,
    this.onPickColor,
    this.activeColor,
  });

  // size: normalerweise die Größe deines Wheels (z. B. discSize)
  final double size;
  final GlobalKey<RotaryColorRingState>? ringKey;
  final ValueChanged<Color>? onPickColor;
  final Color? activeColor;

  @override
  ConsumerState<_FocusSelectorRing> createState() => _FocusSelectorRingState();
}

class _FocusSelectorRingState extends ConsumerState<_FocusSelectorRing> {
  double? _dragAngle; // aktueller, kontinuierlicher Winkel des Balls
  int? _lastSnappedIndex; // letzter gesnappter Index
  double? _lastSnappedAngle; // letzter gesnappter Winkel (normalisiert auf [0, 2*PI))

  @override
  Widget build(BuildContext context) {
    final ctrl = ref.read(radialPaletteProvider.notifier);
    final state = ref.watch(radialPaletteProvider);

    // 🎨 PAINT-Modus: Ring komplett mit Kugeln füllen (eine pro Farbe im Ring)
    // WICHTIG: Wenn Paint aktiv ist, KEINE normale Navigation-Kugel anzeigen!
    if (state.activeTool == PaletteTool.paint) {
      // Wenn Paint aktiv ist, KEINE normale Navigation-Kugel anzeigen
      // Warte auf ringState, wenn es noch nicht verfügbar ist
      if (widget.ringKey != null) {
        final ringState = widget.ringKey!.currentState;
        if (ringState != null) {
          // Anzahl der Kugeln: 12 (wie vorher)
          final colorCount = 12;
          final ringRadius = widget.size / 2 - 80;
          final angleStep = (2 * math.pi) / colorCount;
          
          // State einmal außerhalb der Schleife lesen
          final customColors = state.customColors;
          final isCustomPaletteActive = state.isCustomPaletteActive;
          final activeCustomBallIndex = state.activeCustomBallIndex;

          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _FocusRingPainter(ringRadius: ringRadius),
              child: Stack(
                alignment: Alignment.center, // 🔴 Zentrieren!
                children: List.generate(colorCount, (index) {
                  final angle = -math.pi / 2 + angleStep * index; // Start oben (-90°)
                  final ballOffset = Offset(
                    ringRadius * math.cos(angle),
                    ringRadius * math.sin(angle),
                  );
                  
                  // 🔴 Index 0 = Custom-Ball (12 Uhr), Index 1 = Roter Ball (1 Uhr), Index 2-11 = Custom-Bälle
                  final isCustomBall = index == 0 || index >= 2; // Alle außer Index 1 (roter Ball)
                  final isRedBall = index == 1; // Roter Ball auf 1 Uhr bleibt normal
                  
                  // Für normale Bälle: Palette-Index berechnen (nur für roten Ball)
                  final paletteIndex = isRedBall ? 0 : ((index - 1) % ringState.paletteCount);
                  
                  // Custom-Ball zeigt seine individuelle gewählte Farbe, sonst schwarz
                  final ballCustomColor = customColors[index]; // Individuelle Farbe für diesen Ball
                  final ballColor = isCustomBall 
                      ? (ballCustomColor ?? Colors.black)
                      : (isRedBall 
                          ? Colors.redAccent // Roter Ball auf 1 Uhr
                          : ringState.getPaletteColor(paletteIndex));
                  
                  // 🔴 Aktive Palette hat weißen Rand
                  // Wenn Custom-Palette aktiv ist, sind normale Bälle nicht aktiv
                  final isActive = isRedBall && 
                      !isCustomPaletteActive && 
                      ringState.currentPaletteIndex == paletteIndex;
                  // Custom-Ball ist nur aktiv, wenn Custom-Palette aktiv ist und dieser Ball aktiv ist
                  final isCustomActive = isCustomBall && 
                      isCustomPaletteActive && 
                      activeCustomBallIndex == index;

                  return Transform.translate(
                    offset: ballOffset,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // 🔴 Custom-Ball: Normaler Tap = nur selektieren (wie andere Bälle)
                        if (isCustomBall) {
                          // Custom-Palette für diesen spezifischen Ball aktivieren
                          // Wenn keine Custom-Farbe für diesen Ball gesetzt ist, öffne Dialog
                          if (ballCustomColor == null && widget.onPickColor != null) {
                            final currentColor = widget.activeColor ?? const Color(0xFFFFC66A);
                            showDialog(
                              context: context,
                              builder: (dialogContext) => CustomColorPickerDialog(
                                initialColor: currentColor,
                                onColorChanged: (color) {
                                  widget.onPickColor!(color);
                                  // Custom-Farbe für diesen spezifischen Ball speichern
                                  final ctrl = ref.read(radialPaletteProvider.notifier);
                                  ctrl.setCustomColorForBall(index, color);
                                  // Farbe auch direkt auf das Target anwenden (verzögert, um Provider-Fehler zu vermeiden)
                                  Future.microtask(() {
                                    ctrl.applyColorToCurrentTarget(color);
                                  });
                                },
                              ),
                            );
                          } else {
                            // Custom-Farbe für diesen Ball ist gesetzt → Custom-Palette aktivieren
                            final ctrl = ref.read(radialPaletteProvider.notifier);
                            // Aktiviere Custom-Palette für diesen spezifischen Ball (Farbkreis zeigt Custom-Verlauf)
                            ctrl.setCustomPaletteActive(true, ballIndex: index);
                            if (ballCustomColor != null) {
                              widget.onPickColor?.call(ballCustomColor);
                            }
                            HapticFeedback.selectionClick();
                          }
                        } else if (isRedBall) {
                          // 🔴 Roter Ball: Normale Palette auf dem Ring setzen
                          // Custom-Palette deaktivieren, damit normale Palette angezeigt wird
                          final ctrl = ref.read(radialPaletteProvider.notifier);
                          ctrl.setCustomPaletteActive(false);
                          ringState.setPaletteIndex(paletteIndex);
                          HapticFeedback.selectionClick();
                        }
                      },
                      onLongPress: () {
                        // 🔴 Custom-Ball: Longpress = Custom-Dialog öffnen für diesen spezifischen Ball
                        if (isCustomBall && widget.onPickColor != null) {
                          final currentColor = ballCustomColor ?? widget.activeColor ?? const Color(0xFFFFC66A);
                          HapticFeedback.mediumImpact();
                          showDialog(
                            context: context,
                            builder: (dialogContext) => CustomColorPickerDialog(
                              initialColor: currentColor,
                              onColorChanged: (color) {
                                widget.onPickColor!(color);
                                // Custom-Farbe für diesen spezifischen Ball speichern
                                final ctrl = ref.read(radialPaletteProvider.notifier);
                                ctrl.setCustomColorForBall(index, color);
                                // Farbe auch direkt auf das Target anwenden (verzögert, um Provider-Fehler zu vermeiden)
                                Future.microtask(() {
                                  ctrl.applyColorToCurrentTarget(color);
                                });
                              },
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCustomBall 
                              ? (ballCustomColor ?? Colors.black)
                              : ballColor,
                          border: Border.all(
                            color: isCustomActive || isActive
                                ? Colors.white 
                                : Colors.white.withOpacity(0.4),
                            width: (isCustomActive || isActive) ? 2.5 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                            if (isCustomActive || isActive)
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            BoxShadow(
                              color: (isCustomBall ? (ballCustomColor ?? Colors.black) : ballColor).withOpacity(0.6),
                              blurRadius: 10,
                              spreadRadius: 1.5,
                            ),
                          ],
                        ),
                        // Kein "C" mehr, da alle Bälle außer dem roten Custom-Bälle sind
                        child: null,
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        } else {
          // WICHTIG: Auch wenn ringState null ist, KEINE normale Navigation-Kugel anzeigen!
          return SizedBox(width: widget.size, height: widget.size);
        }
      } else {
        // WICHTIG: Auch wenn ringKey null ist, KEINE normale Navigation-Kugel anzeigen!
        return SizedBox(width: widget.size, height: widget.size);
      }
    }

    // Normale Navigation-Modus: Eine weiße Kugel für Target-Navigation
    // WICHTIG: Diese Kugel wird NUR angezeigt, wenn Paint NICHT aktiv ist!
    
    final visible = ctrl.visibleTargets;
    final total = visible.isNotEmpty ? visible.length : 12;

    // sichtbarer Index (nicht globaler Index!)
    final visibleIndex = ctrl.currentVisibleIndex.clamp(0, total - 1);

    final isLocked = state.isBallLocked;
    
    // 🔴 Kugel-Farbe:
    // - Wenn gelockt UND auf gelockter Kachel UND Farbe gepickt → gepickte Farbe
    // - Sonst immer weiß (nur der Rahmen wird rot, nicht die Kugel)
    Color ballColor = Colors.white; // Immer weiß, nur Rahmen wird rot
    if (isLocked && state.lockedIndex != null) {
      // Prüfe, ob das gelockte Target das aktuell fokussierte ist
      final lockedTargetId = state.targets.isNotEmpty && state.lockedIndex! < state.targets.length
          ? state.targets[state.lockedIndex!].id
          : null;
      final currentTargetId = visible.isNotEmpty && visibleIndex < visible.length
          ? visible[visibleIndex].id
          : null;
      
      // Wenn auf gelockter Kachel UND Farbe gepickt → gepickte Farbe
      if (lockedTargetId != null && currentTargetId == lockedTargetId && state.lastPickedColor != null) {
        ballColor = state.lastPickedColor!;
      }
      // Sonst bleibt ballColor = Colors.white
    }

    final angleStep = (2 * math.pi) / total;

    // Wenn gerade gezogen wird, verwenden wir _dragAngle (smooth),
    // sonst den gesnappten Winkel des aktuellen Fokus.
    final angle = _dragAngle ??
        (-math.pi / 2 + angleStep * visibleIndex); // Start oben (-90°)

    final ringRadius = widget.size / 2 - 80;

    final ballOffset = Offset(
      ringRadius * math.cos(angle),
      ringRadius * math.sin(angle),
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        if (isLocked) return; // Kugel eingerastet → nicht bewegen
        if (state.scope == PaletteScope.all) return; // Navigation deaktiviert im ALL-Modus
        // Hysterese zurücksetzen, damit der aktuelle Fokus sofort gesnappt wird
        setState(() {
          _lastSnappedIndex = null;
          _lastSnappedAngle = null;
        });
        _updateFromPosition(context, details.globalPosition, total, ctrl);
      },
      onPanUpdate: (details) {
        if (isLocked) return;
        if (state.scope == PaletteScope.all) return; // Navigation deaktiviert im ALL-Modus
        _updateFromPosition(context, details.globalPosition, total, ctrl);
      },
      onPanEnd: (_) {
        setState(() {
          _dragAngle = null;
          _lastSnappedIndex = null;
          _lastSnappedAngle = null;
        });
      },
      onPanCancel: () {
        setState(() {
          _dragAngle = null;
          _lastSnappedIndex = null;
          _lastSnappedAngle = null;
        });
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _FocusRingPainter(ringRadius: ringRadius),
          child: Transform.translate(
            offset: ballOffset,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // 🔴 Kugel ein-/ausrasten
                ctrl.toggleFocusLock();
                // optional: kleines Haptic
                HapticFeedback.selectionClick();
              },
              child: SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ballColor,
                        border: Border.all(
                          color: isLocked ? Colors.redAccent : Colors.transparent,
                          width: isLocked ? 3 : 0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.6),
                            blurRadius: 12,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                    ),
                    // 🔼 animierter Pfeil IN der Kugel, zeigt zum Ring
                    if (isLocked)
                      IgnorePointer(
                        child: Center(
                          child: Transform.rotate(
                            angle: angle + math.pi / 2, // Pfeil zeigt radial nach außen
                            child: _ArrowToRing(ballColor: ballColor),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateFromPosition(
    BuildContext context,
    Offset globalPos,
    int total,
    RadialPaletteController ctrl,
  ) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final local = box.globalToLocal(globalPos);
    final center = Offset(box.size.width / 2, box.size.height / 2);
    final offset = local - center;

    final ringRadius = widget.size / 2 - 80;
    final distance = offset.distance;
    final minRadius = ringRadius - 40;
    final maxRadius = ringRadius + 40;

    // nur reagieren, wenn Finger in der Nähe des Rings ist
    if (distance < minRadius || distance > maxRadius) return;

    // Winkel berechnen (–PI..PI)
    var angle = math.atan2(offset.dy, offset.dx);

    setState(() {
      _dragAngle = angle; // Ball folgt dem Finger SMOOTH
    });

    // jetzt auf [0, 2*PI) normalisieren und "oben" als Start definieren
    angle += math.pi / 2;
    angle = angle % (2 * math.pi);
    if (angle < 0) angle += 2 * math.pi;

    final angleStep = (2 * math.pi) / total;
    
    // Hysterese: Nur wechseln, wenn sich der Winkel um mindestens 60% eines Slots geändert hat
    final hysteresisThreshold = angleStep * 0.6;
    
    // Initialisierung beim ersten Mal
    if (_lastSnappedAngle == null || _lastSnappedIndex == null) {
      final visibleIndex = (angle / angleStep).round().clamp(0, total - 1);
      _lastSnappedIndex = visibleIndex;
      _lastSnappedAngle = angle;
      ctrl.moveFocusToVisibleIndex(visibleIndex);
      return;
    }
    
    // Berechne die Winkel-Differenz (berücksichtige Überlauf bei 0/2*PI)
    var angleDiff = angle - _lastSnappedAngle!;
    if (angleDiff > math.pi) {
      angleDiff -= 2 * math.pi;
    } else if (angleDiff < -math.pi) {
      angleDiff += 2 * math.pi;
    }
    
    // Nur wechseln, wenn die Differenz den Schwellenwert überschreitet
    if (angleDiff.abs() >= hysteresisThreshold) {
      final visibleIndex = (angle / angleStep).round().clamp(0, total - 1);
      
      // Nur aktualisieren, wenn sich der Index wirklich geändert hat
      if (visibleIndex != _lastSnappedIndex) {
        _lastSnappedIndex = visibleIndex;
        _lastSnappedAngle = angle;
        ctrl.moveFocusToVisibleIndex(visibleIndex);
      }
    }
  }
}

class _FocusRingPainter extends CustomPainter {
  _FocusRingPainter({required this.ringRadius});

  final double ringRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.35);

    canvas.drawCircle(center, ringRadius, paint);
  }

  @override
  bool shouldRepaint(covariant _FocusRingPainter oldDelegate) =>
      oldDelegate.ringRadius != ringRadius;
}

class _ArrowToRing extends StatefulWidget {
  final Color ballColor;
  
  const _ArrowToRing({required this.ballColor});
  
  @override
  State<_ArrowToRing> createState() => _ArrowToRingState();
}

class _ArrowToRingState extends State<_ArrowToRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        // Animation: bewegt sich von unten nach oben (zum Ring hin)
        // _c.value geht von 0.0 bis 1.0 und zurück (wegen reverse: true)
        final progress = _c.value;
        // Bewegt sich von +10px (unten) nach -10px (oben) - größerer Bereich
        final yOffset = 10.0 - (progress * 20.0);
        
        // Farbwechsel für bessere Sichtbarkeit während Animation
        final opacity = 0.7 + (progress * 0.3); // von 0.7 bis 1.0
        
        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Icon(
            Icons.arrow_upward,
            // Wenn Kugel hell ist, verwende dunklere Farbe für Kontrast
            color: widget.ballColor.computeLuminance() > 0.5
                ? Colors.black87.withOpacity(opacity)
                : Colors.white.withOpacity(opacity),
            size: 20,
          ),
        );
      },
    );
  }
}

class RadialDebugBanner extends ConsumerWidget {
  const RadialDebugBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(radialPaletteProvider);

    final toolLabel = switch (state.activeTool) {
      PaletteTool.stroke => 'Rahmen',
      PaletteTool.fill => 'Kachel-Hintergrund',
      PaletteTool.text => 'Text',
      PaletteTool.hubBackground => 'WordHub-Background',
      PaletteTool.paint => 'Paint',
      PaletteTool.icon => 'Icon',
      PaletteTool.image => 'Bild',
      null => 'kein Tool aktiv',
    };

    final total = state.targets.length;
    final index = state.focusedIndex.clamp(0, total == 0 ? 0 : total - 1);

    return Positioned(
      left: 16,
      bottom: 16,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'Tool: $toolLabel\nFokus: $index / ${total == 0 ? 0 : total - 1}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
