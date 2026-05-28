import 'package:flutter/material.dart';

import 'package:talvori/features/words/application/category_design_preferences.dart';

class CategoryDesignColorPanel extends StatelessWidget {
  const CategoryDesignColorPanel({
    super.key,
    required this.selectedElementLabel,
    required this.selectedColor,
    required this.selectedGlowStrength,
    required this.selectedPulseStrength,
    this.onMoveStart,
    required this.onMove,
    this.onMoveEnd,
    required this.onClose,
    required this.onColorChanged,
    required this.onGlowChanged,
    required this.onPulseChanged,
    this.customColors = const [],
    this.onSaveCustomColor,
    this.onRestoreDefaults,
  });

  final String selectedElementLabel;
  final Color selectedColor;
  final CategoryDesignGlowStrength selectedGlowStrength;
  final CategoryDesignPulseStrength selectedPulseStrength;
  final VoidCallback? onMoveStart;
  final ValueChanged<Offset> onMove;
  final VoidCallback? onMoveEnd;
  final VoidCallback onClose;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<CategoryDesignGlowStrength> onGlowChanged;
  final ValueChanged<CategoryDesignPulseStrength> onPulseChanged;
  final List<Color> customColors;
  final ValueChanged<Color>? onSaveCustomColor;
  final VoidCallback? onRestoreDefaults;

  static int get swatchCount => _designSwatches.length;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('design-color-panel'),
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onLongPressStart: (_) => onMoveStart?.call(),
        onLongPressMoveUpdate: (details) => onMove(details.offsetFromOrigin),
        onLongPressEnd: (_) => onMoveEnd?.call(),
        onLongPressCancel: onMoveEnd,
        child: Container(
          width: 326,
          constraints: const BoxConstraints(maxHeight: 452),
          decoration: BoxDecoration(
            color: const Color(0xFF07101A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF70E4FF).withValues(alpha: 0.62),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: const Color(0xFF70E4FF).withValues(alpha: 0.25),
                blurRadius: 30,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: selectedColor.withValues(alpha: 0.22),
                blurRadius: 34,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  key: const Key('design-color-panel-drag-handle'),
                  behavior: HitTestBehavior.opaque,
                  onLongPressStart: (_) => onMoveStart?.call(),
                  onLongPressMoveUpdate: (details) =>
                      onMove(details.offsetFromOrigin),
                  onLongPressEnd: (_) => onMoveEnd?.call(),
                  onLongPressCancel: onMoveEnd,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 11, 8, 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF10293A).withValues(alpha: 0.86),
                          const Color(0xFF091421).withValues(alpha: 0.96),
                        ],
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(
                            0xFF70E4FF,
                          ).withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.drag_indicator_rounded,
                          color: const Color(
                            0xFF70E4FF,
                          ).withValues(alpha: 0.92),
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF70E4FF,
                            ).withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(
                                0xFF70E4FF,
                              ).withValues(alpha: 0.28),
                            ),
                          ),
                          child: const Text(
                            'Farbe',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            selectedElementLabel,
                            key: const Key('selected-design-element-label'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.72),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          key: const Key('design-color-panel-close'),
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Farbfenster schließen',
                          onPressed: onClose,
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: _CategoryDesignColorPanelBody(
                    selectedColor: selectedColor,
                    selectedGlowStrength: selectedGlowStrength,
                    selectedPulseStrength: selectedPulseStrength,
                    onColorChanged: onColorChanged,
                    onGlowChanged: onGlowChanged,
                    onPulseChanged: onPulseChanged,
                    customColors: customColors,
                    onSaveCustomColor: onSaveCustomColor,
                    onRestoreDefaults: onRestoreDefaults,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _ColorPanelSection { palette, custom, glow, pulse }

class _CategoryDesignColorPanelBody extends StatefulWidget {
  const _CategoryDesignColorPanelBody({
    required this.selectedColor,
    required this.selectedGlowStrength,
    required this.selectedPulseStrength,
    required this.onColorChanged,
    required this.onGlowChanged,
    required this.onPulseChanged,
    required this.customColors,
    this.onSaveCustomColor,
    this.onRestoreDefaults,
  });

  final Color selectedColor;
  final CategoryDesignGlowStrength selectedGlowStrength;
  final CategoryDesignPulseStrength selectedPulseStrength;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<CategoryDesignGlowStrength> onGlowChanged;
  final ValueChanged<CategoryDesignPulseStrength> onPulseChanged;
  final List<Color> customColors;
  final ValueChanged<Color>? onSaveCustomColor;
  final VoidCallback? onRestoreDefaults;

  @override
  State<_CategoryDesignColorPanelBody> createState() =>
      _CategoryDesignColorPanelBodyState();
}

class _CategoryDesignColorPanelBodyState
    extends State<_CategoryDesignColorPanelBody> {
  _ColorPanelSection _section = _ColorPanelSection.palette;

  void _updateFromHsv({
    double? hue,
    double? saturation,
    double? value,
    double? alpha,
  }) {
    final hsv = HSVColor.fromColor(widget.selectedColor);
    widget.onColorChanged(
      HSVColor.fromAHSV(
        alpha ?? hsv.alpha,
        hue ?? hsv.hue,
        saturation ?? hsv.saturation,
        value ?? hsv.value,
      ).toColor(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hsv = HSVColor.fromColor(widget.selectedColor);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DesignColorField(
            color: widget.selectedColor,
            hsv: hsv,
            onChanged: (saturation, value) =>
                _updateFromHsv(saturation: saturation, value: value),
          ),
          const SizedBox(height: 10),
          _ColorSlider(
            key: const Key('design-hue-slider'),
            value: hsv.hue / 360.0,
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF3434),
                Color(0xFFFFD23D),
                Color(0xFF61F26E),
                Color(0xFF49F3FF),
                Color(0xFF396DFF),
                Color(0xFFFF42D2),
                Color(0xFFFF3434),
              ],
            ),
            knobColor: widget.selectedColor,
            onChanged: (value) => _updateFromHsv(hue: value * 360.0),
          ),
          const SizedBox(height: 8),
          _ColorSlider(
            key: const Key('design-opacity-slider'),
            value: hsv.alpha,
            gradient: LinearGradient(
              colors: [
                widget.selectedColor.withValues(alpha: 0.05),
                widget.selectedColor.withValues(alpha: 1),
              ],
            ),
            knobColor: Colors.white,
            onChanged: (value) => _updateFromHsv(alpha: value),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const _PanelField(label: 'Hex'),
              const SizedBox(width: 8),
              Expanded(
                child: _PanelField(
                  key: const Key('design-hex-value'),
                  label: _hexForColor(widget.selectedColor),
                  monospace: true,
                ),
              ),
              const SizedBox(width: 8),
              _PanelField(label: '${(hsv.alpha * 100).round()} %'),
            ],
          ),
          const SizedBox(height: 10),
          _EyedropperBar(
            selectedColor: widget.selectedColor,
            onPickCurrent: widget.onSaveCustomColor == null
                ? null
                : () => widget.onSaveCustomColor!(widget.selectedColor),
          ),
          const SizedBox(height: 12),
          _SectionToggle(
            section: _section,
            onChanged: (section) => setState(() => _section = section),
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 140),
            child: switch (_section) {
              _ColorPanelSection.palette => _SwatchGrid(
                selectedColor: widget.selectedColor,
                onColorChanged: widget.onColorChanged,
              ),
              _ColorPanelSection.custom => _CustomSwatchGrid(
                customColors: widget.customColors,
                selectedColor: widget.selectedColor,
                onColorChanged: widget.onColorChanged,
                onSaveCurrent: widget.onSaveCustomColor == null
                    ? null
                    : () => widget.onSaveCustomColor!(widget.selectedColor),
              ),
              _ColorPanelSection.glow => _GlowStrengthEditor(
                selectedColor: widget.selectedColor,
                selectedGlowStrength: widget.selectedGlowStrength,
                onGlowChanged: widget.onGlowChanged,
              ),
              _ColorPanelSection.pulse => _PulseStrengthEditor(
                selectedColor: widget.selectedColor,
                selectedPulseStrength: widget.selectedPulseStrength,
                onPulseChanged: widget.onPulseChanged,
              ),
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('design-factory-defaults-button'),
              onPressed: widget.onRestoreDefaults,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Element zurücksetzen'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: const Color(0xFF70E4FF).withValues(alpha: 0.52),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesignColorField extends StatelessWidget {
  const _DesignColorField({
    required this.color,
    required this.hsv,
    required this.onChanged,
  });

  final Color color;
  final HSVColor hsv;
  final void Function(double saturation, double value) onChanged;

  void _updateFromPosition(BuildContext context, Offset globalPosition) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(globalPosition);
    final width = box.size.width;
    final height = box.size.height;
    if (width <= 0 || height <= 0) return;
    onChanged(
      (local.dx / width).clamp(0.0, 1.0),
      (1 - (local.dy / height)).clamp(0.0, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('design-color-field'),
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) =>
          _updateFromPosition(context, details.globalPosition),
      onPanStart: (details) =>
          _updateFromPosition(context, details.globalPosition),
      onPanUpdate: (details) =>
          _updateFromPosition(context, details.globalPosition),
      child: SizedBox(
        height: 126,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxLeft = (constraints.maxWidth - 24).clamp(0.0, 1000.0);
            const maxTop = 102.0;

            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.95),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: (hsv.saturation * maxLeft).clamp(0.0, maxLeft),
                      top: ((1 - hsv.value) * maxTop).clamp(0.0, maxTop),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.48),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ColorSlider extends StatelessWidget {
  const _ColorSlider({
    super.key,
    required this.value,
    required this.gradient,
    required this.knobColor,
    required this.onChanged,
  });

  final double value;
  final Gradient gradient;
  final Color knobColor;
  final ValueChanged<double> onChanged;

  void _updateFromPosition(BuildContext context, Offset globalPosition) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(globalPosition);
    final width = box.size.width;
    if (width <= 0) return;
    onChanged((local.dx / width).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) =>
          _updateFromPosition(context, details.globalPosition),
      onPanStart: (details) =>
          _updateFromPosition(context, details.globalPosition),
      onPanUpdate: (details) =>
          _updateFromPosition(context, details.globalPosition),
      child: Container(
        height: 16,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: gradient,
        ),
        child: Align(
          alignment: Alignment((value.clamp(0.0, 1.0) * 2) - 1, 0),
          child: Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.symmetric(horizontal: 7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: knobColor,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.38),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionToggle extends StatelessWidget {
  const _SectionToggle({required this.section, required this.onChanged});

  final _ColorPanelSection section;
  final ValueChanged<_ColorPanelSection> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF15181D),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          _SectionToggleButton(
            label: 'Palette',
            selected: section == _ColorPanelSection.palette,
            onTap: () => onChanged(_ColorPanelSection.palette),
          ),
          _SectionToggleButton(
            label: 'Eigene',
            selected: section == _ColorPanelSection.custom,
            onTap: () => onChanged(_ColorPanelSection.custom),
          ),
          _SectionToggleButton(
            label: 'Glow',
            selected: section == _ColorPanelSection.glow,
            onTap: () => onChanged(_ColorPanelSection.glow),
          ),
          _SectionToggleButton(
            label: 'Puls',
            selected: section == _ColorPanelSection.pulse,
            onTap: () => onChanged(_ColorPanelSection.pulse),
          ),
        ],
      ),
    );
  }
}

class _SectionToggleButton extends StatelessWidget {
  const _SectionToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          key: Key('design-section-$label'),
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? const Color(0xFF101318) : Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlowStrengthEditor extends StatelessWidget {
  const _GlowStrengthEditor({
    required this.selectedColor,
    required this.selectedGlowStrength,
    required this.onGlowChanged,
  });

  final Color selectedColor;
  final CategoryDesignGlowStrength selectedGlowStrength;
  final ValueChanged<CategoryDesignGlowStrength> onGlowChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('design-glow-section'),
      height: 120,
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        children: CategoryDesignGlowStrength.values.map((glow) {
          final selected = selectedGlowStrength == glow;
          return ChoiceChip(
            key: Key('design-glow-${glow.name}'),
            label: Text(_glowLabel(glow)),
            selected: selected,
            onSelected: (_) => onGlowChanged(glow),
            selectedColor: selectedColor,
            backgroundColor: const Color(0xFF15181D),
            labelStyle: TextStyle(
              color: selected ? const Color(0xFF07101A) : Colors.white,
              fontWeight: FontWeight.w800,
            ),
            side: BorderSide(
              color: selected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.18),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PulseStrengthEditor extends StatelessWidget {
  const _PulseStrengthEditor({
    required this.selectedColor,
    required this.selectedPulseStrength,
    required this.onPulseChanged,
  });

  final Color selectedColor;
  final CategoryDesignPulseStrength selectedPulseStrength;
  final ValueChanged<CategoryDesignPulseStrength> onPulseChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('design-pulse-section'),
      height: 120,
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        children: CategoryDesignPulseStrength.values.map((pulse) {
          final selected = selectedPulseStrength == pulse;
          return ChoiceChip(
            key: Key('design-pulse-${pulse.name}'),
            label: Text(_pulseLabel(pulse)),
            selected: selected,
            onSelected: (_) => onPulseChanged(pulse),
            selectedColor: selectedColor,
            backgroundColor: const Color(0xFF15181D),
            labelStyle: TextStyle(
              color: selected ? const Color(0xFF07101A) : Colors.white,
              fontWeight: FontWeight.w800,
            ),
            side: BorderSide(
              color: selected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.18),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EyedropperBar extends StatelessWidget {
  const _EyedropperBar({
    required this.selectedColor,
    required this.onPickCurrent,
  });

  final Color selectedColor;
  final VoidCallback? onPickCurrent;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: const Key('design-eyedropper-current-color'),
      onPressed: onPickCurrent,
      icon: Icon(Icons.colorize_rounded, color: selectedColor),
      label: const Text('Farbe aufnehmen'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: selectedColor.withValues(alpha: 0.72)),
        backgroundColor: const Color(0xFF0B1724),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _CustomSwatchGrid extends StatelessWidget {
  const _CustomSwatchGrid({
    required this.customColors,
    required this.selectedColor,
    required this.onColorChanged,
    required this.onSaveCurrent,
  });

  final List<Color> customColors;
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;
  final VoidCallback? onSaveCurrent;

  @override
  Widget build(BuildContext context) {
    if (customColors.isEmpty) {
      return SizedBox(
        key: const Key('design-custom-swatch-section'),
        height: 128,
        child: Center(
          child: OutlinedButton.icon(
            key: const Key('design-custom-save-current-empty'),
            onPressed: onSaveCurrent,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Aktuelle Farbe speichern'),
          ),
        ),
      );
    }
    return SizedBox(
      key: const Key('design-custom-swatch-section'),
      height: 128,
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            InkWell(
              key: const Key('design-custom-save-current'),
              borderRadius: BorderRadius.circular(8),
              onTap: onSaveCurrent,
              child: Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1724),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF70E4FF).withValues(alpha: 0.62),
                  ),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            for (final color in customColors)
              InkWell(
                key: Key('design-custom-swatch-${color.toARGB32()}'),
                borderRadius: BorderRadius.circular(8),
                onTap: () => onColorChanged(color),
                child: Container(
                  width: 31,
                  height: 31,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selectedColor.toARGB32() == color.toARGB32()
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.16),
                      width: selectedColor.toARGB32() == color.toARGB32()
                          ? 2.3
                          : 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SwatchGrid extends StatelessWidget {
  const _SwatchGrid({
    required this.selectedColor,
    required this.onColorChanged,
  });

  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('design-swatch-scroll-area'),
      height: 128,
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _designSwatches.map((swatch) {
            final selected =
                selectedColor.toARGB32() == swatch.color.toARGB32();
            return InkWell(
              key: Key('design-swatch-${swatch.label}'),
              borderRadius: BorderRadius.circular(8),
              onTap: () => onColorChanged(swatch.color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: swatch.color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.16),
                    width: selected ? 2.3 : 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: swatch.color.withValues(alpha: 0.55),
                            blurRadius: 15,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _PanelField extends StatelessWidget {
  const _PanelField({super.key, required this.label, this.monospace = false});

  final String label;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF343434),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontFamily: monospace ? 'monospace' : null,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DesignSwatch {
  const _DesignSwatch(this.label, this.color);

  final String label;
  final Color color;
}

final List<_DesignSwatch> _designSwatches = [
  _DesignSwatch('Standard', Color(0xFFB8C8FF)),
  _DesignSwatch('Weiss', Color(0xFFFFFFFF)),
  _DesignSwatch('Nebel', Color(0xFFE8EDF7)),
  _DesignSwatch('Silber', Color(0xFFB8C0CC)),
  _DesignSwatch('Grau', Color(0xFF6F7784)),
  _DesignSwatch('Graphit', Color(0xFF262626)),
  _DesignSwatch('Schwarz', Color(0xFF050508)),
  _DesignSwatch('Blau', Color(0xFF6EA8FF)),
  _DesignSwatch('Neonblau', Color(0xFF2E7DFF)),
  _DesignSwatch('Eisblau', Color(0xFFA9D8FF)),
  _DesignSwatch('Indigo', Color(0xFF5265FF)),
  _DesignSwatch('Türkis', Color(0xFF77E3D8)),
  _DesignSwatch('Cyan', Color(0xFF35F4FF)),
  _DesignSwatch('Mint', Color(0xFF8DF7D2)),
  _DesignSwatch('Petrol', Color(0xFF1FA8A8)),
  _DesignSwatch('Grün', Color(0xFF76F29A)),
  _DesignSwatch('Neongruen', Color(0xFF39FF88)),
  _DesignSwatch('Salbei', Color(0xFF9CCFA8)),
  _DesignSwatch('Wald', Color(0xFF2B8B57)),
  _DesignSwatch('Gelb', Color(0xFFFFEC6E)),
  _DesignSwatch('Gold', Color(0xFFFFC66A)),
  _DesignSwatch('Honig', Color(0xFFEAA642)),
  _DesignSwatch('Lila', Color(0xFF9D7AF4)),
  _DesignSwatch('Violett', Color(0xFF7F4DFF)),
  _DesignSwatch('Lavendel', Color(0xFFC7B5FF)),
  _DesignSwatch('Rosa', Color(0xFFFF73C7)),
  _DesignSwatch('Pink', Color(0xFFFF4DA6)),
  _DesignSwatch('Rose', Color(0xFFFFB6D7)),
  _DesignSwatch('Orange', Color(0xFFFFB255)),
  _DesignSwatch('Koralle', Color(0xFFFF7B6E)),
  _DesignSwatch('Rot', Color(0xFFFF6572)),
  _DesignSwatch('Neonrot', Color(0xFFFF334F)),
  _DesignSwatch('Weinrot', Color(0xFF9B2D45)),
  _DesignSwatch('Creme', Color(0xFFFFF2E8)),
  _DesignSwatch('Kakao', Color(0xFF7A5A4A)),
  ..._generatedDesignSwatches,
];

final List<_DesignSwatch> _generatedDesignSwatches = [
  for (final gray in _grayLevels)
    _DesignSwatch(
      'Grau${gray.$1}',
      Color.fromARGB(255, gray.$2, gray.$2, gray.$2),
    ),
  for (final hue in _paletteHues)
    for (var saturationStep = 0; saturationStep < 5; saturationStep++)
      for (var valueStep = 0; valueStep < 5; valueStep++)
        _DesignSwatch(
          'H${hue.round()}S$saturationStep V$valueStep',
          HSVColor.fromAHSV(
            1,
            hue,
            0.36 + saturationStep * 0.15,
            0.38 + valueStep * 0.14,
          ).toColor(),
        ),
];

const _grayLevels = [
  ('00', 8),
  ('01', 18),
  ('02', 28),
  ('03', 40),
  ('04', 54),
  ('05', 68),
  ('06', 84),
  ('07', 102),
  ('08', 122),
  ('09', 144),
  ('10', 166),
  ('11', 188),
  ('12', 210),
  ('13', 232),
  ('14', 248),
];

const _paletteHues = [0.0, 24.0, 60.0, 132.0, 180.0, 220.0, 276.0, 324.0];

String _glowLabel(CategoryDesignGlowStrength glow) {
  return switch (glow) {
    CategoryDesignGlowStrength.off => 'Aus',
    CategoryDesignGlowStrength.subtle => 'Dezent',
    CategoryDesignGlowStrength.normal => 'Normal',
    CategoryDesignGlowStrength.strong => 'Stark',
  };
}

String _pulseLabel(CategoryDesignPulseStrength pulse) {
  return switch (pulse) {
    CategoryDesignPulseStrength.off => 'Aus',
    CategoryDesignPulseStrength.subtle => 'Dezent',
    CategoryDesignPulseStrength.normal => 'Normal',
    CategoryDesignPulseStrength.strong => 'Stark',
  };
}

String _hexForColor(Color color) {
  final value = color.toARGB32() & 0xFFFFFF;
  return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
