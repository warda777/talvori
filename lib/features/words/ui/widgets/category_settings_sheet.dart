import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/ui/talvori_snackbar.dart';
import 'package:talvori/features/words/application/category_design_preferences.dart';

import 'category_design_color_panel.dart';

Future<void> showCategorySettingsSheet({
  required BuildContext context,
  required String categoryId,
  required String categoryLabel,
}) {
  return showModalBottomSheet<void>(
    context: context,
    enableDrag: false,
    isDismissible: false,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CategorySettingsSheet(
      categoryId: categoryId,
      categoryLabel: categoryLabel,
    ),
  );
}

enum CategorySettingsTab { category, learnMode, info }

enum _DesignCloseDecision { discard, keepEditing, apply }

typedef _DesignElementSelect =
    void Function(CategoryDesignElement element, Rect globalBounds);

class _CategorySettingsSheet extends ConsumerStatefulWidget {
  const _CategorySettingsSheet({
    required this.categoryId,
    required this.categoryLabel,
  });

  final String categoryId;
  final String categoryLabel;

  @override
  ConsumerState<_CategorySettingsSheet> createState() =>
      _CategorySettingsSheetState();
}

class _CategorySettingsSheetState
    extends ConsumerState<_CategorySettingsSheet> {
  static const _defaultStyle = CategoryDesignElementStyle();
  static const _colorPanelWidth = 326.0;
  static const _colorPanelEstimatedHeight = 452.0;

  final _sheetKey = GlobalKey();
  CategorySettingsTab _activeTab = CategorySettingsTab.category;
  CategoryDesignElement? _selectedElement;
  CategoryDesignElement? _selectedCompositeElement;
  List<CategoryDesignElement> _subTargetOptions = const [];
  Offset _subTargetOffset = Offset.zero;
  Offset _colorPanelOffset = const Offset(48, 96);
  Offset _colorPanelDragStartOffset = const Offset(48, 96);
  bool _colorPanelVisible = false;
  bool _isDraggingColorPanel = false;
  bool _ignoreNextSheetTap = false;
  bool _hasUnsavedDesignChanges = false;
  bool _showSelectionOverlay = false;
  final Map<CategoryDesignElement, CategoryDesignElementStyle> _draft = {};
  List<Color> _customColors = const [];

  final _repository = const CategoryDesignPreferencesRepository();
  final _customPaletteRepository =
      const CategoryDesignCustomPaletteRepository();
  bool _loadingDesign = true;

  @override
  void initState() {
    super.initState();
    _loadSavedDesign();
  }

  Future<void> _loadSavedDesign() async {
    final preferences = await _repository.load(widget.categoryId);
    final customColors = await _customPaletteRepository.load();
    if (!mounted) return;
    setState(() {
      _draft
        ..clear()
        ..addAll(preferences.overrides);
      _hasUnsavedDesignChanges = false;
      _customColors = customColors;
      _loadingDesign = false;
    });
  }

  CategoryDesignElementStyle _styleFor(CategoryDesignElement element) {
    final style = _draft[element];
    if (style != null) return style;
    if (element == CategoryDesignElement.learnCardGlow) {
      return const CategoryDesignElementStyle(
        pulse: CategoryDesignPulseStrength.normal,
      );
    }
    return _defaultStyle;
  }

  void _selectElement(CategoryDesignElement element, Rect globalBounds) {
    final subTargets = _subTargetsFor(element);
    if (subTargets.isNotEmpty) {
      final box = _sheetKey.currentContext?.findRenderObject() as RenderBox?;
      final localTopLeft = box?.globalToLocal(globalBounds.topLeft);
      setState(() {
        _selectedCompositeElement = element;
        _subTargetOptions = subTargets;
        _subTargetOffset = _clampSubTargetOffset(
          (localTopLeft ?? globalBounds.topLeft) +
              Offset(0, globalBounds.height + 10),
        );
        _selectedElement = null;
        _colorPanelVisible = false;
        _showSelectionOverlay = true;
        _ignoreNextSheetTap = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _ignoreNextSheetTap = false;
        }
      });
      return;
    }
    _selectColorTarget(element, globalBounds);
  }

  void _selectColorTarget(CategoryDesignElement element, Rect globalBounds) {
    setState(() {
      _selectedElement = element;
      _selectedCompositeElement = null;
      _subTargetOptions = const [];
      _colorPanelVisible = true;
      _showSelectionOverlay = true;
      _colorPanelOffset = _autoPanelOffsetFor(globalBounds);
      _ignoreNextSheetTap = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _ignoreNextSheetTap = false;
      }
    });
  }

  Offset _clampSubTargetOffset(Offset offset) {
    final size =
        (_sheetKey.currentContext?.findRenderObject() as RenderBox?)?.size ??
        MediaQuery.sizeOf(context);
    const chooserWidth = 252.0;
    const chooserHeight = 180.0;
    const margin = 12.0;
    return Offset(
      offset.dx.clamp(margin, size.width - chooserWidth - margin).toDouble(),
      offset.dy.clamp(margin, size.height - chooserHeight - margin).toDouble(),
    );
  }

  void _selectSubTarget(CategoryDesignElement element) {
    final box = _sheetKey.currentContext?.findRenderObject() as RenderBox?;
    final sheetTopLeft = box?.localToGlobal(Offset.zero) ?? Offset.zero;
    final globalBounds = sheetTopLeft + _subTargetOffset & const Size(252, 44);
    _selectColorTarget(element, globalBounds);
  }

  Offset _autoPanelOffsetFor(Rect globalBounds) {
    final box = _sheetKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return _colorPanelOffset;

    final localTopLeft = box.globalToLocal(globalBounds.topLeft);
    final localBottomRight = box.globalToLocal(globalBounds.bottomRight);
    final localBounds = Rect.fromPoints(localTopLeft, localBottomRight);
    final sheetSize = box.size;
    const gap = 16.0;
    final hasRoomBelow =
        localBounds.bottom + gap + _colorPanelEstimatedHeight <
        sheetSize.height;
    final preferredTop = hasRoomBelow
        ? localBounds.bottom + gap
        : localBounds.top - _colorPanelEstimatedHeight - gap;
    final preferredLeft = localBounds.center.dx - (_colorPanelWidth / 2);

    return _clampAutoPanelOffset(
      Offset(preferredLeft, preferredTop),
      sheetSize,
    );
  }

  Offset _clampAutoPanelOffset(Offset offset, Size sheetSize) {
    const margin = 12.0;
    final maxX = (sheetSize.width - _colorPanelWidth - margin)
        .clamp(margin, double.infinity)
        .toDouble();
    final maxY = (sheetSize.height - _colorPanelEstimatedHeight - margin)
        .clamp(margin, double.infinity)
        .toDouble();

    return Offset(
      offset.dx.clamp(margin, maxX).toDouble(),
      offset.dy.clamp(margin, maxY).toDouble(),
    );
  }

  Offset _clampPanelOffset(Offset offset, [Size? sheetSize]) {
    final size =
        sheetSize ??
        (_sheetKey.currentContext?.findRenderObject() as RenderBox?)?.size ??
        MediaQuery.sizeOf(context);
    const visibleGrip = 72.0;
    final minX = -_colorPanelWidth + visibleGrip;
    final maxX = size.width - visibleGrip;
    final minY = -_colorPanelEstimatedHeight + visibleGrip;
    final maxY = size.height - visibleGrip;

    return Offset(
      offset.dx.clamp(minX, maxX).toDouble(),
      offset.dy.clamp(minY, maxY).toDouble(),
    );
  }

  void _setColor(Color color) {
    final selectedElement = _selectedElement;
    if (selectedElement == null) return;
    setState(() {
      _draft[selectedElement] = _styleFor(
        selectedElement,
      ).copyWith(color: color);
      _hasUnsavedDesignChanges = true;
      _showSelectionOverlay = false;
    });
  }

  void _setGlow(CategoryDesignGlowStrength glow) {
    final selectedElement = _selectedElement;
    if (selectedElement == null) return;
    setState(() {
      _draft[selectedElement] = _styleFor(selectedElement).copyWith(glow: glow);
      _hasUnsavedDesignChanges = true;
      _showSelectionOverlay = false;
    });
  }

  void _setPulse(CategoryDesignPulseStrength pulse) {
    final selectedElement = _selectedElement;
    if (selectedElement == null) return;
    setState(() {
      _draft[selectedElement] = _styleFor(
        selectedElement,
      ).copyWith(pulse: pulse);
      _hasUnsavedDesignChanges = true;
      _showSelectionOverlay = false;
    });
  }

  Future<void> _confirmRestoreElementDefault() async {
    final selectedElement = _selectedElement;
    if (selectedElement == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (context) => _DesignResetConfirmDialog(
        title: 'Element zurücksetzen?',
        text:
            '${selectedElement.label} wird auf die Werkseinstellung zurückgesetzt.',
        confirmLabel: 'Zurücksetzen',
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() {
      _draft.remove(selectedElement);
      _hasUnsavedDesignChanges = true;
      _showSelectionOverlay = false;
    });
  }

  Future<void> _confirmResetArea(CategoryDesignArea area) async {
    final isCategory = area == CategoryDesignArea.category;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (context) => _DesignResetConfirmDialog(
        title: isCategory
            ? 'Kategorie-Design zurücksetzen?'
            : 'Lernmodus-Design zurücksetzen?',
        text: isCategory
            ? 'Die Farben dieser Wortwelt werden auf Werkseinstellung zurückgesetzt.'
            : 'Die Lernmodus-Gestaltung dieser Wortwelt wird auf Werkseinstellung zurückgesetzt.',
        confirmLabel: 'Zurücksetzen',
      ),
    );
    if (!mounted || confirmed != true) return;
    await _repository.resetArea(widget.categoryId, area);
    if (!mounted) return;
    ref.invalidate(categoryDesignPreferencesProvider(widget.categoryId));
    setState(() {
      _draft.removeWhere((element, _) => element.area == area);
      _hasUnsavedDesignChanges = true;
      _showSelectionOverlay = false;
      _colorPanelVisible = false;
    });
  }

  Future<void> _confirmResetAllDesigns() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (context) => const _DesignResetConfirmDialog(
        title: 'Alle Designs zurücksetzen?',
        text:
            'Alle individuellen Farben und Effekte werden auf Werkseinstellung zurückgesetzt.',
        confirmLabel: 'Alles zurücksetzen',
      ),
    );
    if (!mounted || confirmed != true) return;
    await _repository.resetAllCategories();
    if (!mounted) return;
    ref.invalidate(categoryDesignPreferencesProvider);
    setState(() {
      _draft.clear();
      _hasUnsavedDesignChanges = false;
      _showSelectionOverlay = false;
      _colorPanelVisible = false;
    });
    TalvoriSnackBar.show(
      context,
      message: 'Alle Designs wurden zurückgesetzt.',
      type: TalvoriSnackBarType.success,
    );
  }

  Future<void> _saveCurrentDesign() async {
    await _repository.save(
      widget.categoryId,
      CategoryDesignPreferences(overrides: Map.unmodifiable(_draft)),
    );
    ref.invalidate(categoryDesignPreferencesProvider(widget.categoryId));
  }

  void _moveColorPanel(Offset offsetFromOrigin) {
    setState(() {
      _colorPanelOffset = _clampPanelOffset(
        _colorPanelDragStartOffset + offsetFromOrigin,
      );
    });
  }

  void _setColorPanelDragging(bool isDragging) {
    if (_isDraggingColorPanel == isDragging) return;
    if (isDragging) {
      _colorPanelDragStartOffset = _colorPanelOffset;
      HapticFeedback.mediumImpact();
    }
    setState(() => _isDraggingColorPanel = isDragging);
  }

  void _closeColorPanel() {
    setState(() {
      _colorPanelVisible = false;
      _selectedCompositeElement = null;
      _subTargetOptions = const [];
      _isDraggingColorPanel = false;
      _showSelectionOverlay = false;
    });
  }

  Future<void> _saveCustomColor(Color color) async {
    final next = await _customPaletteRepository.saveColor(color);
    if (!mounted) return;
    setState(() => _customColors = next);
  }

  void _handleSheetTap() {
    if (_ignoreNextSheetTap) {
      _ignoreNextSheetTap = false;
      return;
    }
    if (_colorPanelVisible) {
      _closeColorPanel();
    } else if (_subTargetOptions.isNotEmpty) {
      setState(() {
        _selectedCompositeElement = null;
        _subTargetOptions = const [];
        _showSelectionOverlay = false;
      });
    }
  }

  Future<void> _requestCloseSheet() async {
    if (!_hasUnsavedDesignChanges) {
      Navigator.of(context).pop();
      return;
    }

    final decision = await showDialog<_DesignCloseDecision>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (context) =>
          _DesignCloseConfirmDialog(categoryLabel: widget.categoryLabel),
    );
    if (!mounted) return;

    switch (decision) {
      case _DesignCloseDecision.discard:
        Navigator.of(context).pop();
      case _DesignCloseDecision.apply:
        await _saveCurrentDesign();
        if (!mounted) return;
        setState(() => _hasUnsavedDesignChanges = false);
        Navigator.of(context).pop();
      case _DesignCloseDecision.keepEditing:
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _requestCloseSheet();
        }
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.52,
          maxChildSize: 0.97,
          expand: false,
          builder: (context, scrollController) {
            return DecoratedBox(
              key: _sheetKey,
              decoration: BoxDecoration(
                color: const Color(0xFF07101A),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                border: Border.all(
                  color: const Color(0xFF70E4FF).withValues(alpha: 0.48),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF70E4FF).withValues(alpha: 0.18),
                    blurRadius: 34,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _handleSheetTap,
                    child: ListView(
                      controller: scrollController,
                      physics: _isDraggingColorPanel
                          ? const NeverScrollableScrollPhysics()
                          : null,
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _SheetHeader(
                          categoryLabel: widget.categoryLabel,
                          onClose: _requestCloseSheet,
                        ),
                        const SizedBox(height: 16),
                        _TabSelector(
                          activeTab: _activeTab,
                          onChanged: (tab) {
                            setState(() {
                              _activeTab = tab;
                              _selectedElement = null;
                              _colorPanelVisible = false;
                              _isDraggingColorPanel = false;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_loadingDesign)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF70E4FF),
                              ),
                            ),
                          )
                        else if (_activeTab ==
                            CategorySettingsTab.category) ...[
                          _EditorStage(
                            title: 'Kategorie-Vorschau',
                            subtitle:
                                'Tippe ein Element an und passe Farbe, Glow oder Pulsieren an.',
                            previewHeight: 666,
                            child: _CategoryDesignPreview(
                              categoryLabel: widget.categoryLabel,
                              selectedElement: _showSelectionOverlay
                                  ? (_selectedElement ??
                                        _selectedCompositeElement)
                                  : null,
                              styleFor: _styleFor,
                              onSelect: _selectElement,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _AreaResetActions(
                            areaLabel: 'Kategorie',
                            onResetArea: () =>
                                _confirmResetArea(CategoryDesignArea.category),
                            onResetAll: _confirmResetAllDesigns,
                          ),
                        ] else if (_activeTab ==
                            CategorySettingsTab.learnMode) ...[
                          _EditorStage(
                            title: 'Lernmodus-Vorschau',
                            subtitle:
                                'Wähle ein Element und passe Farbe, Glow oder Pulsieren an.',
                            previewHeight: 620,
                            child: _LearnModeDesignPreview(
                              categoryLabel: widget.categoryLabel,
                              selectedElement: _showSelectionOverlay
                                  ? (_selectedElement ??
                                        _selectedCompositeElement)
                                  : null,
                              styleFor: _styleFor,
                              onSelect: _selectElement,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _AreaResetActions(
                            areaLabel: 'Lernmodus',
                            onResetArea: () =>
                                _confirmResetArea(CategoryDesignArea.learnMode),
                            onResetAll: _confirmResetAllDesigns,
                          ),
                        ] else
                          _InfoHelpSection(onResetAll: _confirmResetAllDesigns),
                      ],
                    ),
                  ),
                  if (_subTargetOptions.isNotEmpty)
                    Positioned(
                      key: const Key('design-subtarget-chooser-positioned'),
                      left: _subTargetOffset.dx,
                      top: _subTargetOffset.dy,
                      child: _SubTargetChooser(
                        title: _selectedCompositeElement?.label ?? 'Element',
                        parent:
                            _selectedCompositeElement ??
                            CategoryDesignElement.categoryHeader,
                        options: _subTargetOptions,
                        onSelect: _selectSubTarget,
                      ),
                    ),
                  if (_colorPanelVisible && _selectedElement != null)
                    Positioned(
                      key: const Key('design-color-panel-positioned'),
                      left: _colorPanelOffset.dx,
                      top: _colorPanelOffset.dy,
                      child: CategoryDesignColorPanel(
                        selectedElementLabel: _selectedElement!.label,
                        selectedColor: _accentForElement(
                          _selectedElement!,
                          _styleFor(_selectedElement!),
                        ),
                        selectedGlowStrength: _styleFor(_selectedElement!).glow,
                        selectedPulseStrength: _styleFor(
                          _selectedElement!,
                        ).pulse,
                        onMoveStart: () => _setColorPanelDragging(true),
                        onMove: _moveColorPanel,
                        onMoveEnd: () => _setColorPanelDragging(false),
                        onClose: _closeColorPanel,
                        onColorChanged: _setColor,
                        onGlowChanged: _setGlow,
                        onPulseChanged: _setPulse,
                        customColors: _customColors,
                        onSaveCustomColor: _saveCustomColor,
                        onRestoreDefaults: _confirmRestoreElementDefault,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.categoryLabel, required this.onClose});

  final String categoryLabel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wortwelt gestalten',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                categoryLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          key: const Key('category-design-sheet-close'),
          tooltip: 'Schließen',
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded, color: Colors.white),
        ),
      ],
    );
  }
}

class _SubTargetChooser extends StatelessWidget {
  const _SubTargetChooser({
    required this.title,
    required this.parent,
    required this.options,
    required this.onSelect,
  });

  final String title;
  final CategoryDesignElement parent;
  final List<CategoryDesignElement> options;
  final ValueChanged<CategoryDesignElement> onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('design-subtarget-chooser'),
      color: Colors.transparent,
      child: Container(
        width: 252,
        constraints: const BoxConstraints(maxHeight: 210),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF07101A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF70E4FF).withValues(alpha: 0.58),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.52),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: const Color(0xFF70E4FF).withValues(alpha: 0.2),
              blurRadius: 22,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final option in options)
                      ActionChip(
                        key: Key('design-subtarget-${option.name}'),
                        label: Text(_subTargetPartLabel(parent, option)),
                        avatar: const Icon(Icons.tune_rounded, size: 16),
                        onPressed: () => onSelect(option),
                        backgroundColor: const Color(0xFF0B1724),
                        side: BorderSide(
                          color: const Color(
                            0xFF70E4FF,
                          ).withValues(alpha: 0.34),
                        ),
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesignCloseConfirmDialog extends StatelessWidget {
  const _DesignCloseConfirmDialog({required this.categoryLabel});

  final String categoryLabel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF07101A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF70E4FF).withValues(alpha: 0.56),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.58),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: const Color(0xFF70E4FF).withValues(alpha: 0.22),
              blurRadius: 34,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Änderungen übernehmen?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Möchtest du die Gestaltung für $categoryLabel übernehmen?',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.76),
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  OutlinedButton(
                    key: const Key('design-close-discard'),
                    onPressed: () =>
                        Navigator.of(context).pop(_DesignCloseDecision.discard),
                    child: const Text('Verwerfen'),
                  ),
                  OutlinedButton(
                    key: const Key('design-close-keep-editing'),
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(_DesignCloseDecision.keepEditing),
                    child: const Text('Weiter bearbeiten'),
                  ),
                  FilledButton(
                    key: const Key('design-close-apply'),
                    onPressed: () =>
                        Navigator.of(context).pop(_DesignCloseDecision.apply),
                    child: const Text('Übernehmen'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesignResetConfirmDialog extends StatelessWidget {
  const _DesignResetConfirmDialog({
    required this.title,
    required this.text,
    required this.confirmLabel,
  });

  final String title;
  final String text;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF07101A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF70E4FF).withValues(alpha: 0.56),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.58),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: const Color(0xFF70E4FF).withValues(alpha: 0.22),
              blurRadius: 34,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.76),
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  OutlinedButton(
                    key: const Key('design-factory-cancel'),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Abbrechen'),
                  ),
                  FilledButton(
                    key: const Key('design-factory-confirm'),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(confirmLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AreaResetActions extends StatelessWidget {
  const _AreaResetActions({
    required this.areaLabel,
    required this.onResetArea,
    required this.onResetAll,
  });

  final String areaLabel;
  final VoidCallback onResetArea;
  final VoidCallback onResetAll;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canUseColumns = constraints.maxWidth >= 520;
        final buttonWidth = canUseColumns
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 10,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            SizedBox(
              width: buttonWidth,
              child: _DesignResetButton(
                key: Key('design-reset-$areaLabel'),
                icon: Icons.restart_alt_rounded,
                label: '$areaLabel zurücksetzen',
                onPressed: onResetArea,
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: _DesignResetButton(
                key: const Key('design-reset-all-designs'),
                icon: Icons.delete_sweep_rounded,
                label: 'Alle zurücksetzen',
                danger: true,
                onPressed: onResetAll,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DesignResetButton extends StatelessWidget {
  const _DesignResetButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final accent = danger ? const Color(0xFFFF7186) : const Color(0xFF70E4FF);
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style:
          OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: accent.withValues(alpha: 0.58), width: 1.1),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            backgroundColor: const Color(0xFF07101A).withValues(alpha: 0.72),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ).copyWith(
            overlayColor: WidgetStatePropertyAll(accent.withValues(alpha: 0.1)),
          ),
    );
  }
}

class _TabSelector extends StatelessWidget {
  const _TabSelector({required this.activeTab, required this.onChanged});

  final CategorySettingsTab activeTab;
  final ValueChanged<CategorySettingsTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1724),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            _TabButton(
              label: 'Kategorie',
              icon: Icons.dashboard_customize_rounded,
              selected: activeTab == CategorySettingsTab.category,
              onTap: () => onChanged(CategorySettingsTab.category),
            ),
            _TabButton(
              label: 'Lernmodus',
              icon: Icons.style_rounded,
              selected: activeTab == CategorySettingsTab.learnMode,
              onTap: () => onChanged(CategorySettingsTab.learnMode),
            ),
            _TabButton(
              label: 'Info',
              icon: Icons.help_outline_rounded,
              selected: activeTab == CategorySettingsTab.info,
              onTap: () => onChanged(CategorySettingsTab.info),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        key: Key('settings-tab-$label'),
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF70E4FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? const Color(0xFF07101A) : Colors.white,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? const Color(0xFF07101A) : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorStage extends StatelessWidget {
  const _EditorStage({
    required this.title,
    required this.subtitle,
    required this.previewHeight,
    required this.child,
  });

  final String title;
  final String subtitle;
  final double previewHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1724),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFB1CCFE).withValues(alpha: 0.22),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.66),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(height: previewHeight, child: child),
          ],
        ),
      ),
    );
  }
}

class _CategoryDesignPreview extends StatelessWidget {
  const _CategoryDesignPreview({
    required this.categoryLabel,
    required this.selectedElement,
    required this.styleFor,
    required this.onSelect,
  });

  final String categoryLabel;
  final CategoryDesignElement? selectedElement;
  final CategoryDesignElementStyle Function(CategoryDesignElement) styleFor;
  final _DesignElementSelect onSelect;

  @override
  Widget build(BuildContext context) {
    final deviceRadius = _previewDeviceRadius(context);
    final backgroundAccent = _accentForElement(
      CategoryDesignElement.categoryBackground,
      styleFor(CategoryDesignElement.categoryBackground),
    );
    return FittedBox(
      alignment: Alignment.topCenter,
      fit: BoxFit.contain,
      child: _PreviewDeviceFrame(
        key: const Key('category-real-preview'),
        radius: deviceRadius,
        width: 390,
        height: 760,
        child: Stack(
          children: [
            _SelectablePreviewElement(
              element: CategoryDesignElement.categoryBackground,
              selectedElement: selectedElement,
              style: styleFor(CategoryDesignElement.categoryBackground),
              onSelect: onSelect,
              borderRadius: deviceRadius,
              showChrome: false,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.lerp(Colors.black, backgroundAccent, 0.32)!,
                      Color.lerp(
                        const Color(0xFF020307),
                        backgroundAccent,
                        0.42,
                      )!,
                      Color.lerp(Colors.black, backgroundAccent, 0.2)!,
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 18,
              top: 34,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
            ),
            Positioned(
              left: 82,
              top: 24,
              width: 250,
              height: 38,
              child: _SelectablePreviewElement(
                element: CategoryDesignElement.categoryHeader,
                selectedElement: selectedElement,
                style: styleFor(CategoryDesignElement.categoryHeader),
                onSelect: onSelect,
                borderRadius: 999,
                child: _HeaderCapsule(
                  label: categoryLabel,
                  fillColor: _accentForElement(
                    CategoryDesignElement.categoryHeaderFill,
                    styleFor(CategoryDesignElement.categoryHeaderFill),
                  ),
                  textColor: _accentForElement(
                    CategoryDesignElement.categoryHeaderText,
                    styleFor(CategoryDesignElement.categoryHeaderText),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 98,
              top: 70,
              width: 216,
              height: 24,
              child: _SelectablePreviewElement(
                element: CategoryDesignElement.categoryWheelFade,
                selectedElement: selectedElement,
                style: styleFor(CategoryDesignElement.categoryWheelFade),
                onSelect: onSelect,
                borderRadius: 999,
                showChrome: false,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _accentForElement(
                          CategoryDesignElement.categoryWheelFade,
                          styleFor(CategoryDesignElement.categoryWheelFade),
                        ).withValues(alpha: 0.16),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 28,
              top: 124,
              width: 92,
              height: 92,
              child: _SelectablePreviewElement(
                element: CategoryDesignElement.vocabsTile,
                selectedElement: selectedElement,
                style: styleFor(CategoryDesignElement.vocabsTile),
                onSelect: onSelect,
                borderRadius: 24,
                fillColorOverride: _accentForElement(
                  CategoryDesignElement.vocabsTileFill,
                  styleFor(CategoryDesignElement.vocabsTileFill),
                ),
                child: _VocabsPreviewTile(
                  textColor: _accentForElement(
                    CategoryDesignElement.vocabsTileText,
                    styleFor(CategoryDesignElement.vocabsTileText),
                  ),
                  iconColor: _accentForElement(
                    CategoryDesignElement.vocabsTileIcon,
                    styleFor(CategoryDesignElement.vocabsTileIcon),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 100,
              top: 116,
              width: 56,
              height: 32,
              child: _SelectablePreviewElement(
                element: CategoryDesignElement.vocabsCounterBadge,
                selectedElement: selectedElement,
                style: styleFor(CategoryDesignElement.vocabsCounterBadge),
                onSelect: onSelect,
                borderRadius: 999,
                child: _CountBadge(
                  label: '380',
                  fillColor: _accentForElement(
                    CategoryDesignElement.vocabsCounterFill,
                    styleFor(CategoryDesignElement.vocabsCounterFill),
                  ),
                  textColor: _accentForElement(
                    CategoryDesignElement.vocabsCounterText,
                    styleFor(CategoryDesignElement.vocabsCounterText),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 236,
              top: 130,
              width: 68,
              height: 68,
              child: _SelectablePreviewElement(
                element: CategoryDesignElement.addButton,
                selectedElement: selectedElement,
                style: styleFor(CategoryDesignElement.addButton),
                onSelect: onSelect,
                shape: BoxShape.circle,
                fillColorOverride: _accentForElement(
                  CategoryDesignElement.addButtonFill,
                  styleFor(CategoryDesignElement.addButtonFill),
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 42,
                  color: _accentForElement(
                    CategoryDesignElement.addButtonIcon,
                    styleFor(CategoryDesignElement.addButtonIcon),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 314,
              top: 130,
              width: 68,
              height: 68,
              child: _SelectablePreviewElement(
                element: CategoryDesignElement.settingsButton,
                selectedElement: selectedElement,
                style: styleFor(CategoryDesignElement.settingsButton),
                onSelect: onSelect,
                shape: BoxShape.circle,
                fillColorOverride: _accentForElement(
                  CategoryDesignElement.settingsButtonFill,
                  styleFor(CategoryDesignElement.settingsButtonFill),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  size: 34,
                  color: _accentForElement(
                    CategoryDesignElement.settingsButtonIcon,
                    styleFor(CategoryDesignElement.settingsButtonIcon),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 266,
              child: Center(
                child: SizedBox(
                  width: 258,
                  child: _SelectablePreviewElement(
                    element: CategoryDesignElement.sectionTitleRepeat,
                    selectedElement: selectedElement,
                    style: styleFor(CategoryDesignElement.sectionTitleRepeat),
                    onSelect: onSelect,
                    borderRadius: 10,
                    child: const _PreviewSectionTitle('Wiederholungsauswahl'),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 72,
              top: 314,
              width: 110,
              height: 44,
              child: _SelectablePreviewElement(
                element: CategoryDesignElement.repeatAllStagesButton,
                selectedElement: selectedElement,
                style: styleFor(CategoryDesignElement.repeatAllStagesButton),
                onSelect: onSelect,
                borderRadius: 999,
                fillColorOverride: _accentForElement(
                  CategoryDesignElement.repeatAllStagesButtonFill,
                  styleFor(CategoryDesignElement.repeatAllStagesButtonFill),
                ),
                child: _TextPill(
                  'Alle Stufen',
                  color: _accentForElement(
                    CategoryDesignElement.repeatAllStagesButtonText,
                    styleFor(CategoryDesignElement.repeatAllStagesButtonText),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 212,
              top: 314,
              width: 110,
              height: 44,
              child: _SelectablePreviewElement(
                element: CategoryDesignElement.repeatSingleStageButton,
                selectedElement: selectedElement,
                style: styleFor(CategoryDesignElement.repeatSingleStageButton),
                onSelect: onSelect,
                borderRadius: 999,
                fillColorOverride: _accentForElement(
                  CategoryDesignElement.repeatSingleStageButtonFill,
                  styleFor(CategoryDesignElement.repeatSingleStageButtonFill),
                ),
                child: _TextPill(
                  'Einzelstufe',
                  color: _accentForElement(
                    CategoryDesignElement.repeatSingleStageButtonText,
                    styleFor(CategoryDesignElement.repeatSingleStageButtonText),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 418,
              child: Center(
                child: SizedBox(
                  width: 148,
                  child: _SelectablePreviewElement(
                    element: CategoryDesignElement.sectionTitleStages,
                    selectedElement: selectedElement,
                    style: styleFor(CategoryDesignElement.sectionTitleStages),
                    onSelect: onSelect,
                    borderRadius: 10,
                    child: const _PreviewSectionTitle('Merkstufen'),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 38,
              top: 466,
              right: 28,
              child: _SelectablePreviewElement(
                element: CategoryDesignElement.stageSwitches,
                selectedElement: selectedElement,
                style: styleFor(CategoryDesignElement.stageSwitches),
                onSelect: onSelect,
                borderRadius: 22,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _StagePreviewRow(
                    elements: const [
                      CategoryDesignElement.stageSwitch0,
                      CategoryDesignElement.stageSwitch1,
                      CategoryDesignElement.stageSwitch2,
                      CategoryDesignElement.stageSwitch3,
                      CategoryDesignElement.stageSwitch4,
                      CategoryDesignElement.stageSwitch5,
                    ],
                    selectedElement: selectedElement,
                    styleFor: styleFor,
                    onSelect: onSelect,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 580,
              child: Center(
                child: SizedBox(
                  width: 140,
                  child: _SelectablePreviewElement(
                    element: CategoryDesignElement.sectionTitleMode,
                    selectedElement: selectedElement,
                    style: styleFor(CategoryDesignElement.sectionTitleMode),
                    onSelect: onSelect,
                    borderRadius: 10,
                    child: const _PreviewSectionTitle('Lernmodus'),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 628,
              width: 104,
              height: 42,
              child: _SelectablePreviewElement(
                element: CategoryDesignElement.learningModeTimeButton,
                selectedElement: selectedElement,
                style: styleFor(CategoryDesignElement.learningModeTimeButton),
                onSelect: onSelect,
                borderRadius: 999,
                fillColorOverride: _accentForElement(
                  CategoryDesignElement.learningModeTimeButtonFill,
                  styleFor(CategoryDesignElement.learningModeTimeButtonFill),
                ),
                child: _TextPill(
                  'Zeitplan',
                  color: _accentForElement(
                    CategoryDesignElement.learningModeTimeButtonText,
                    styleFor(CategoryDesignElement.learningModeTimeButtonText),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 144,
              top: 628,
              width: 104,
              height: 42,
              child: _SelectablePreviewElement(
                element: CategoryDesignElement.learningModeUnlimitedButton,
                selectedElement: selectedElement,
                style: styleFor(
                  CategoryDesignElement.learningModeUnlimitedButton,
                ),
                onSelect: onSelect,
                borderRadius: 999,
                fillColorOverride: _accentForElement(
                  CategoryDesignElement.learningModeUnlimitedButtonFill,
                  styleFor(
                    CategoryDesignElement.learningModeUnlimitedButtonFill,
                  ),
                ),
                child: _TextPill(
                  'Limitlos',
                  color: _accentForElement(
                    CategoryDesignElement.learningModeUnlimitedButtonText,
                    styleFor(
                      CategoryDesignElement.learningModeUnlimitedButtonText,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 268,
              top: 628,
              width: 104,
              height: 42,
              child: _SelectablePreviewElement(
                element: CategoryDesignElement.learningModeCombinedButton,
                selectedElement: selectedElement,
                style: styleFor(
                  CategoryDesignElement.learningModeCombinedButton,
                ),
                onSelect: onSelect,
                borderRadius: 999,
                fillColorOverride: _accentForElement(
                  CategoryDesignElement.learningModeCombinedButtonFill,
                  styleFor(
                    CategoryDesignElement.learningModeCombinedButtonFill,
                  ),
                ),
                child: _TextPill(
                  'Kombiniert',
                  color: _accentForElement(
                    CategoryDesignElement.learningModeCombinedButtonText,
                    styleFor(
                      CategoryDesignElement.learningModeCombinedButtonText,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 122,
              top: 704,
              width: 146,
              height: 48,
              child: _SelectablePreviewElement(
                element: CategoryDesignElement.startButton,
                selectedElement: selectedElement,
                style: styleFor(CategoryDesignElement.startButton),
                onSelect: onSelect,
                borderRadius: 999,
                fillColorOverride: _accentForElement(
                  CategoryDesignElement.startButtonFill,
                  styleFor(CategoryDesignElement.startButtonFill),
                ),
                child: _TextPill(
                  'Start',
                  color: _accentForElement(
                    CategoryDesignElement.startButtonText,
                    styleFor(CategoryDesignElement.startButtonText),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 38,
              top: 700,
              width: 54,
              height: 54,
              child: _SelectablePreviewElement(
                element: CategoryDesignElement.resetButton,
                selectedElement: selectedElement,
                style: styleFor(CategoryDesignElement.resetButton),
                onSelect: onSelect,
                shape: BoxShape.circle,
                fillColorOverride: _accentForElement(
                  CategoryDesignElement.resetButtonFill,
                  styleFor(CategoryDesignElement.resetButtonFill),
                ),
                child: Icon(
                  Icons.restart_alt_rounded,
                  size: 30,
                  color: _accentForElement(
                    CategoryDesignElement.resetButtonIcon,
                    styleFor(CategoryDesignElement.resetButtonIcon),
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

class _LearnModeDesignPreview extends StatelessWidget {
  const _LearnModeDesignPreview({
    required this.categoryLabel,
    required this.selectedElement,
    required this.styleFor,
    required this.onSelect,
  });

  final String categoryLabel;
  final CategoryDesignElement? selectedElement;
  final CategoryDesignElementStyle Function(CategoryDesignElement) styleFor;
  final _DesignElementSelect onSelect;

  @override
  Widget build(BuildContext context) {
    final deviceRadius = _previewDeviceRadius(context);
    final backgroundStyle = styleFor(CategoryDesignElement.learnBackground);
    final backgroundAccent = _accentForElement(
      CategoryDesignElement.learnBackground,
      backgroundStyle,
    );
    final cardGlowStyle = styleFor(CategoryDesignElement.learnCardGlow);
    return FittedBox(
      alignment: Alignment.topCenter,
      fit: BoxFit.contain,
      child: _PreviewDeviceFrame(
        key: const Key('learn-real-preview'),
        radius: deviceRadius,
        width: 390,
        height: 704,
        child: SizedBox(
          child: Stack(
            children: [
              _SelectablePreviewElement(
                element: CategoryDesignElement.learnBackground,
                selectedElement: selectedElement,
                style: styleFor(CategoryDesignElement.learnBackground),
                onSelect: onSelect,
                borderRadius: deviceRadius,
                showChrome: false,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF020204),
                        Color.lerp(
                              const Color(0xFF33244B),
                              backgroundAccent,
                              0.36,
                            ) ??
                            const Color(0xFF33244B),
                        backgroundAccent.withValues(alpha: 0.86),
                        const Color(0xFF050407),
                      ],
                    ),
                  ),
                ),
              ),
              const Positioned(
                left: 16,
                top: 34,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
              ),
              Positioned(
                left: 86,
                top: 24,
                width: 250,
                height: 38,
                child: _SelectablePreviewElement(
                  element: CategoryDesignElement.learnHeader,
                  selectedElement: selectedElement,
                  style: styleFor(CategoryDesignElement.learnHeader),
                  onSelect: onSelect,
                  borderRadius: 999,
                  child: _HeaderCapsule(
                    label: categoryLabel,
                    fillColor: _accentForElement(
                      CategoryDesignElement.learnHeaderFill,
                      styleFor(CategoryDesignElement.learnHeaderFill),
                    ),
                    textColor: _accentForElement(
                      CategoryDesignElement.learnHeaderText,
                      styleFor(CategoryDesignElement.learnHeaderText),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 35,
                top: 103,
                width: 322,
                height: 448,
                child: _SelectablePreviewElement(
                  element: CategoryDesignElement.learnCardGlow,
                  selectedElement: selectedElement,
                  style: cardGlowStyle,
                  onSelect: onSelect,
                  borderRadius: 32,
                  child: const SizedBox.expand(),
                ),
              ),
              Positioned(
                left: 44,
                top: 112,
                width: 304,
                height: 430,
                child: _SelectablePreviewElement(
                  element: CategoryDesignElement.learnCard,
                  selectedElement: selectedElement,
                  style: styleFor(CategoryDesignElement.learnCard),
                  onSelect: onSelect,
                  borderRadius: 28,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 18,
                        top: 20,
                        width: 54,
                        height: 54,
                        child: _SelectablePreviewElement(
                          element: CategoryDesignElement.audioButton,
                          selectedElement: selectedElement,
                          style: styleFor(CategoryDesignElement.audioButton),
                          onSelect: onSelect,
                          shape: BoxShape.circle,
                          fillColorOverride: _accentForElement(
                            CategoryDesignElement.audioButtonFill,
                            styleFor(CategoryDesignElement.audioButtonFill),
                          ),
                          child: Icon(
                            Icons.volume_up_rounded,
                            size: 30,
                            color: _accentForElement(
                              CategoryDesignElement.audioButtonIcon,
                              styleFor(CategoryDesignElement.audioButtonIcon),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 18,
                        top: 20,
                        width: 54,
                        height: 34,
                        child: _SelectablePreviewElement(
                          element: CategoryDesignElement.levelBadge,
                          selectedElement: selectedElement,
                          style: styleFor(CategoryDesignElement.levelBadge),
                          onSelect: onSelect,
                          borderRadius: 999,
                          fillColorOverride: _accentForElement(
                            CategoryDesignElement.levelBadgeFill,
                            styleFor(CategoryDesignElement.levelBadgeFill),
                          ),
                          child: Center(
                            child: Text(
                              'A1',
                              style: TextStyle(
                                color: _accentForElement(
                                  CategoryDesignElement.levelBadgeText,
                                  styleFor(
                                    CategoryDesignElement.levelBadgeText,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 42,
                        right: 42,
                        top: 142,
                        height: 72,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: _SelectablePreviewElement(
                              element: CategoryDesignElement.learnWordText,
                              selectedElement: selectedElement,
                              style: styleFor(
                                CategoryDesignElement.learnWordText,
                              ),
                              onSelect: onSelect,
                              borderRadius: 12,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                child: Text(
                                  'Talvori',
                                  key: const Key('learn-preview-word'),
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(
                                    color: _accentForElement(
                                      CategoryDesignElement.learnWordText,
                                      styleFor(
                                        CategoryDesignElement.learnWordText,
                                      ),
                                    ),
                                    fontSize: 31,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 18,
                        bottom: 138,
                        width: 58,
                        height: 58,
                        child: _SelectablePreviewElement(
                          element: CategoryDesignElement.favoriteButton,
                          selectedElement: selectedElement,
                          style: styleFor(CategoryDesignElement.favoriteButton),
                          onSelect: onSelect,
                          shape: BoxShape.circle,
                          fillColorOverride: _accentForElement(
                            CategoryDesignElement.favoriteButtonFill,
                            styleFor(CategoryDesignElement.favoriteButtonFill),
                          ),
                          child: Icon(
                            Icons.favorite_rounded,
                            color: _accentForElement(
                              CategoryDesignElement.favoriteButtonIcon,
                              styleFor(
                                CategoryDesignElement.favoriteButtonIcon,
                              ),
                            ),
                            size: 31,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 18,
                        bottom: 62,
                        width: 58,
                        height: 58,
                        child: _SelectablePreviewElement(
                          element: CategoryDesignElement.knownButton,
                          selectedElement: selectedElement,
                          style: styleFor(CategoryDesignElement.knownButton),
                          onSelect: onSelect,
                          shape: BoxShape.circle,
                          fillColorOverride: _accentForElement(
                            CategoryDesignElement.knownButtonFill,
                            styleFor(CategoryDesignElement.knownButtonFill),
                          ),
                          child: Icon(
                            Icons.check_circle_outline_rounded,
                            color: _accentForElement(
                              CategoryDesignElement.knownButtonIcon,
                              styleFor(CategoryDesignElement.knownButtonIcon),
                            ),
                            size: 31,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 28,
                right: 18,
                top: 590,
                child: _SelectablePreviewElement(
                  element: CategoryDesignElement.learnStages,
                  selectedElement: selectedElement,
                  style: styleFor(CategoryDesignElement.learnStages),
                  onSelect: onSelect,
                  borderRadius: 22,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _StagePreviewRow(
                      elements: const [
                        CategoryDesignElement.learnStageSwitch0,
                        CategoryDesignElement.learnStageSwitch1,
                        CategoryDesignElement.learnStageSwitch2,
                        CategoryDesignElement.learnStageSwitch3,
                        CategoryDesignElement.learnStageSwitch4,
                        CategoryDesignElement.learnStageSwitch5,
                      ],
                      selectedElement: selectedElement,
                      styleFor: styleFor,
                      onSelect: onSelect,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewDeviceFrame extends StatelessWidget {
  const _PreviewDeviceFrame({
    super.key,
    required this.radius,
    required this.width,
    required this.height,
    required this.child,
  });

  final double radius;
  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(
            color: const Color(0xFF70E4FF).withValues(alpha: 0.28),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF70E4FF).withValues(alpha: 0.14),
              blurRadius: 18,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: SizedBox(width: width, height: height, child: child),
        ),
      ),
    );
  }
}

class _SelectablePreviewElement extends StatelessWidget {
  const _SelectablePreviewElement({
    required this.element,
    required this.selectedElement,
    required this.style,
    required this.onSelect,
    required this.child,
    this.borderRadius = 18,
    this.shape = BoxShape.rectangle,
    this.showChrome = true,
    this.fillColorOverride,
  });

  final CategoryDesignElement element;
  final CategoryDesignElement? selectedElement;
  final CategoryDesignElementStyle style;
  final _DesignElementSelect onSelect;
  final Widget child;
  final double borderRadius;
  final BoxShape shape;
  final bool showChrome;
  final Color? fillColorOverride;

  @override
  Widget build(BuildContext context) {
    final selected = element == selectedElement;
    final color = _accentForElement(element, style);
    final shadow = _glowShadow(color, style.glow, style.pulse);
    final border = Border.all(
      color: selected ? const Color(0xFF70E4FF) : color.withValues(alpha: 0.68),
      width: selected ? 2.4 : _borderWidthForStyle(style),
    );
    return GestureDetector(
      key: Key('design-element-${element.name}'),
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null || !box.hasSize) return;
        final topLeft = box.localToGlobal(Offset.zero);
        onSelect(element, topLeft & box.size);
      },
      child: Stack(
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            decoration: BoxDecoration(
              shape: shape,
              color: showChrome
                  ? fillColorOverride ?? _fillColorForElement(element, color)
                  : Colors.transparent,
              borderRadius: shape == BoxShape.circle
                  ? null
                  : BorderRadius.circular(borderRadius),
              border: showChrome ? border : null,
              boxShadow: showChrome ? shadow : null,
            ),
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
              child: IconTheme(
                data: const IconThemeData(color: Colors.white),
                child: child,
              ),
            ),
          ),
          if (selected) ...[
            Positioned(
              left: -4,
              top: -4,
              child: _SelectionHandle(
                key: Key('design-selection-${element.name}'),
                color: color,
              ),
            ),
            Positioned(
              right: -4,
              top: -4,
              child: _SelectionHandle(color: color),
            ),
            Positioned(
              left: -4,
              bottom: -4,
              child: _SelectionHandle(color: color),
            ),
            Positioned(
              right: -4,
              bottom: -4,
              child: _SelectionHandle(color: color),
            ),
          ],
        ],
      ),
    );
  }
}

class _SelectionHandle extends StatelessWidget {
  const _SelectionHandle({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFF07101A),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: const Color(0xFF70E4FF), width: 1.2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 8),
        ],
      ),
    );
  }
}

class _HeaderCapsule extends StatelessWidget {
  const _HeaderCapsule({
    required this.label,
    this.fillColor = const Color(0xFF2D2C2C),
    this.textColor = Colors.white,
  });

  final String label;
  final Color fillColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fillColor.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _VocabsPreviewTile extends StatelessWidget {
  const _VocabsPreviewTile({
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
  });

  final Color textColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Vocabs', style: TextStyle(fontSize: 15, color: textColor)),
        const SizedBox(height: 14),
        Icon(Icons.menu_book_rounded, size: 30, color: iconColor),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.label,
    this.fillColor = const Color(0xFF080B12),
    this.textColor = Colors.white,
  });

  final String label;
  final Color fillColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFB5C9FF), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB5C9FF).withValues(alpha: 0.32),
            blurRadius: 13,
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _PreviewSectionTitle extends StatelessWidget {
  const _PreviewSectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      softWrap: false,
      style: TextStyle(
        color: const Color(0xFFE4DFFF).withValues(alpha: 0.74),
        fontWeight: FontWeight.w900,
        fontSize: 19,
        shadows: [
          Shadow(
            color: const Color(0xFFB891FF).withValues(alpha: 0.55),
            blurRadius: 14,
          ),
        ],
      ),
    );
  }
}

class _TextPill extends StatelessWidget {
  const _TextPill(this.label, {this.color = Colors.white});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class _StagePreviewRow extends StatelessWidget {
  const _StagePreviewRow({
    required this.elements,
    required this.selectedElement,
    required this.styleFor,
    required this.onSelect,
  });

  final List<CategoryDesignElement> elements;
  final CategoryDesignElement? selectedElement;
  final CategoryDesignElementStyle Function(CategoryDesignElement) styleFor;
  final _DesignElementSelect onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        final element = elements[index];
        final innerElement = _stageInnerElementFor(element);
        final numberElement = _stageNumberElementFor(element);
        final filled = index < 2;
        final outerColor = _accentForElement(element, styleFor(element));
        final innerColor = _accentForElement(
          innerElement,
          styleFor(innerElement),
        );
        final numberColor = _accentForElement(
          numberElement,
          styleFor(numberElement),
        );
        return _SelectablePreviewElement(
          element: element,
          selectedElement: selectedElement,
          style: styleFor(element),
          onSelect: onSelect,
          borderRadius: 999,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 64,
                decoration: BoxDecoration(
                  color: filled
                      ? outerColor
                      : outerColor.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: outerColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8DB8FF).withValues(alpha: 0.28),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 30,
                    height: 42,
                    decoration: BoxDecoration(
                      color: innerColor,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFF9D57FF),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            index == 0
                                ? '368'
                                : index == 1
                                ? '12'
                                : '0',
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: numberColor,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text('$index', style: const TextStyle(fontSize: 14)),
            ],
          ),
        );
      }),
    );
  }
}

class _InfoHelpSection extends StatelessWidget {
  const _InfoHelpSection({required this.onResetAll});

  final VoidCallback onResetAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Info & Hilfe',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        const _InfoCard(
          title: 'Lernmodi verstehen',
          body:
              'Alle Stufen mischt alles. Einzelstufe fokussiert eine Stufe. Zeitplan nutzt fällige Wörter. Limitlos läuft frei. Kombiniert verbindet Wiederholung und freie Runde.',
        ),
        const _InfoCard(
          title: 'Merkstufen 0–5',
          body:
              'Stufe 0 enthält neue oder unsichere Wörter. Stufe 1–4 werden schrittweise sicherer. Stufe 5 ist stark gefestigt.',
        ),
        const _InfoCard(
          title: 'Antippbare Stufen',
          body:
              'Stufen und Switches können angetippt werden. Dahinter liegen Details, Filter und spätere Gestaltungsmöglichkeiten.',
        ),
        const _InfoCard(
          title: 'Vocabs & pausierte Wörter',
          body:
              'Vocabs zeigt Wörter dieser Wortwelt. Pausierte Wörter bleiben sichtbar, erscheinen aber nicht im Lernmodus.',
        ),
        const _InfoCard(
          title: 'Design pro Wortwelt',
          body:
              'Änderungen gelten nur für diese Wortwelt. Kategorie-Design und Lernmodus-Design sind getrennt und werden erst mit Übernehmen gespeichert.',
        ),
        const _InfoCard(
          title: 'Zurücksetzen',
          body:
              'Kategorie zurücksetzen betrifft nur die Kategorie-Ansicht. Lernmodus zurücksetzen betrifft nur den Lernmodus. Alle Designs zurücksetzen löscht alle individuellen Gestaltungen.',
        ),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          key: const Key('design-info-reset-all-designs'),
          onPressed: onResetAll,
          icon: const Icon(Icons.delete_sweep_rounded),
          label: const Text('Alle Designs zurücksetzen'),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1724),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF70E4FF).withValues(alpha: 0.22),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        iconColor: const Color(0xFF70E4FF),
        collapsedIconColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                body,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _fillColorForElement(CategoryDesignElement element, Color color) {
  switch (element) {
    case CategoryDesignElement.categoryBackground:
      return color.withValues(alpha: 0.06);
    case CategoryDesignElement.learnBackground:
      return color.withValues(alpha: 0.18);
    case CategoryDesignElement.learnCard:
      return color == _defaultAccentForElement(element)
          ? const Color(0xFF252525)
          : color.withValues(alpha: 0.18);
    case CategoryDesignElement.learnCardGlow:
      return Colors.transparent;
    case CategoryDesignElement.learnCardBorder:
      return const Color(0xFF252525).withValues(alpha: 0.94);
    case CategoryDesignElement.levelBadge:
      return color.withValues(alpha: 0.9);
    case CategoryDesignElement.vocabsTile:
    case CategoryDesignElement.categoryHeaderReflection:
    case CategoryDesignElement.categoryWheelFade:
      return color.withValues(alpha: 0.10);
    case CategoryDesignElement.stageSwitches:
    case CategoryDesignElement.learnStages:
    case CategoryDesignElement.sectionTitleRepeat:
    case CategoryDesignElement.sectionTitleStages:
    case CategoryDesignElement.sectionTitleMode:
    case CategoryDesignElement.learnWordText:
      return Colors.transparent;
    default:
      return const Color(0xFF0C0F14).withValues(alpha: 0.84);
  }
}

String _subTargetPartLabel(
  CategoryDesignElement parent,
  CategoryDesignElement option,
) {
  if (option == parent) {
    return switch (parent) {
      CategoryDesignElement.categoryBackground ||
      CategoryDesignElement.learnBackground => 'Hintergrund',
      CategoryDesignElement.stageSwitch0 ||
      CategoryDesignElement.stageSwitch1 ||
      CategoryDesignElement.stageSwitch2 ||
      CategoryDesignElement.stageSwitch3 ||
      CategoryDesignElement.stageSwitch4 ||
      CategoryDesignElement.stageSwitch5 ||
      CategoryDesignElement.learnStageSwitch0 ||
      CategoryDesignElement.learnStageSwitch1 ||
      CategoryDesignElement.learnStageSwitch2 ||
      CategoryDesignElement.learnStageSwitch3 ||
      CategoryDesignElement.learnStageSwitch4 ||
      CategoryDesignElement.learnStageSwitch5 => 'Außenkapsel',
      CategoryDesignElement.vocabsCounterBadge ||
      CategoryDesignElement.learnCardBorder => 'Rahmen',
      CategoryDesignElement.learnCard => 'Kartenfläche',
      CategoryDesignElement.learnCardGlow => 'Glow',
      _ => 'Rahmen',
    };
  }

  return switch (option) {
    CategoryDesignElement.categoryHeaderFill ||
    CategoryDesignElement.vocabsTileFill ||
    CategoryDesignElement.vocabsCounterFill ||
    CategoryDesignElement.addButtonFill ||
    CategoryDesignElement.settingsButtonFill ||
    CategoryDesignElement.repeatAllStagesButtonFill ||
    CategoryDesignElement.repeatSingleStageButtonFill ||
    CategoryDesignElement.learningModeTimeButtonFill ||
    CategoryDesignElement.learningModeUnlimitedButtonFill ||
    CategoryDesignElement.learningModeCombinedButtonFill ||
    CategoryDesignElement.startButtonFill ||
    CategoryDesignElement.resetButtonFill ||
    CategoryDesignElement.learnHeaderFill ||
    CategoryDesignElement.audioButtonFill ||
    CategoryDesignElement.levelBadgeFill ||
    CategoryDesignElement.favoriteButtonFill ||
    CategoryDesignElement.knownButtonFill => 'Innenfläche',
    CategoryDesignElement.categoryHeaderText ||
    CategoryDesignElement.vocabsTileText ||
    CategoryDesignElement.repeatAllStagesButtonText ||
    CategoryDesignElement.repeatSingleStageButtonText ||
    CategoryDesignElement.learningModeTimeButtonText ||
    CategoryDesignElement.learningModeUnlimitedButtonText ||
    CategoryDesignElement.learningModeCombinedButtonText ||
    CategoryDesignElement.startButtonText ||
    CategoryDesignElement.learnHeaderText ||
    CategoryDesignElement.learnWordText ||
    CategoryDesignElement.levelBadgeText => 'Schrift',
    CategoryDesignElement.vocabsCounterText ||
    CategoryDesignElement.stageSwitch0Number ||
    CategoryDesignElement.stageSwitch1Number ||
    CategoryDesignElement.stageSwitch2Number ||
    CategoryDesignElement.stageSwitch3Number ||
    CategoryDesignElement.stageSwitch4Number ||
    CategoryDesignElement.stageSwitch5Number ||
    CategoryDesignElement.learnStageSwitch0Number ||
    CategoryDesignElement.learnStageSwitch1Number ||
    CategoryDesignElement.learnStageSwitch2Number ||
    CategoryDesignElement.learnStageSwitch3Number ||
    CategoryDesignElement.learnStageSwitch4Number ||
    CategoryDesignElement.learnStageSwitch5Number => 'Zahl',
    CategoryDesignElement.vocabsTileIcon ||
    CategoryDesignElement.addButtonIcon ||
    CategoryDesignElement.settingsButtonIcon ||
    CategoryDesignElement.resetButtonIcon ||
    CategoryDesignElement.audioButtonIcon ||
    CategoryDesignElement.favoriteButtonIcon ||
    CategoryDesignElement.knownButtonIcon => 'Icon',
    CategoryDesignElement.stageSwitch0Inner ||
    CategoryDesignElement.stageSwitch1Inner ||
    CategoryDesignElement.stageSwitch2Inner ||
    CategoryDesignElement.stageSwitch3Inner ||
    CategoryDesignElement.stageSwitch4Inner ||
    CategoryDesignElement.stageSwitch5Inner ||
    CategoryDesignElement.learnStageSwitch0Inner ||
    CategoryDesignElement.learnStageSwitch1Inner ||
    CategoryDesignElement.learnStageSwitch2Inner ||
    CategoryDesignElement.learnStageSwitch3Inner ||
    CategoryDesignElement.learnStageSwitch4Inner ||
    CategoryDesignElement.learnStageSwitch5Inner => 'Innenfläche',
    CategoryDesignElement.learnCardBorder => 'Rahmen',
    CategoryDesignElement.learnCardGlow => 'Glow',
    CategoryDesignElement.categoryHeaderReflection => 'Spiegelung',
    _ => option.label,
  };
}

List<CategoryDesignElement> _subTargetsFor(CategoryDesignElement element) {
  return switch (element) {
    CategoryDesignElement.categoryHeader => const [
      CategoryDesignElement.categoryHeader,
      CategoryDesignElement.categoryHeaderFill,
      CategoryDesignElement.categoryHeaderText,
    ],
    CategoryDesignElement.vocabsTile => const [
      CategoryDesignElement.vocabsTile,
      CategoryDesignElement.vocabsTileFill,
      CategoryDesignElement.vocabsTileText,
      CategoryDesignElement.vocabsTileIcon,
      CategoryDesignElement.vocabsCounterBadge,
      CategoryDesignElement.vocabsCounterFill,
      CategoryDesignElement.vocabsCounterText,
    ],
    CategoryDesignElement.vocabsCounterBadge => const [
      CategoryDesignElement.vocabsCounterBadge,
      CategoryDesignElement.vocabsCounterFill,
      CategoryDesignElement.vocabsCounterText,
    ],
    CategoryDesignElement.addButton => const [
      CategoryDesignElement.addButton,
      CategoryDesignElement.addButtonFill,
      CategoryDesignElement.addButtonIcon,
    ],
    CategoryDesignElement.settingsButton => const [
      CategoryDesignElement.settingsButton,
      CategoryDesignElement.settingsButtonFill,
      CategoryDesignElement.settingsButtonIcon,
    ],
    CategoryDesignElement.repeatAllStagesButton => const [
      CategoryDesignElement.repeatAllStagesButton,
      CategoryDesignElement.repeatAllStagesButtonFill,
      CategoryDesignElement.repeatAllStagesButtonText,
    ],
    CategoryDesignElement.repeatSingleStageButton => const [
      CategoryDesignElement.repeatSingleStageButton,
      CategoryDesignElement.repeatSingleStageButtonFill,
      CategoryDesignElement.repeatSingleStageButtonText,
    ],
    CategoryDesignElement.learningModeTimeButton => const [
      CategoryDesignElement.learningModeTimeButton,
      CategoryDesignElement.learningModeTimeButtonFill,
      CategoryDesignElement.learningModeTimeButtonText,
    ],
    CategoryDesignElement.learningModeUnlimitedButton => const [
      CategoryDesignElement.learningModeUnlimitedButton,
      CategoryDesignElement.learningModeUnlimitedButtonFill,
      CategoryDesignElement.learningModeUnlimitedButtonText,
    ],
    CategoryDesignElement.learningModeCombinedButton => const [
      CategoryDesignElement.learningModeCombinedButton,
      CategoryDesignElement.learningModeCombinedButtonFill,
      CategoryDesignElement.learningModeCombinedButtonText,
    ],
    CategoryDesignElement.startButton => const [
      CategoryDesignElement.startButton,
      CategoryDesignElement.startButtonFill,
      CategoryDesignElement.startButtonText,
    ],
    CategoryDesignElement.resetButton => const [
      CategoryDesignElement.resetButton,
      CategoryDesignElement.resetButtonFill,
      CategoryDesignElement.resetButtonIcon,
    ],
    CategoryDesignElement.learnHeader => const [
      CategoryDesignElement.learnHeader,
      CategoryDesignElement.learnHeaderFill,
      CategoryDesignElement.learnHeaderText,
    ],
    CategoryDesignElement.learnCard => const [
      CategoryDesignElement.learnCard,
      CategoryDesignElement.learnCardBorder,
      CategoryDesignElement.learnCardGlow,
      CategoryDesignElement.learnWordText,
    ],
    CategoryDesignElement.audioButton => const [
      CategoryDesignElement.audioButton,
      CategoryDesignElement.audioButtonFill,
      CategoryDesignElement.audioButtonIcon,
    ],
    CategoryDesignElement.levelBadge => const [
      CategoryDesignElement.levelBadge,
      CategoryDesignElement.levelBadgeFill,
      CategoryDesignElement.levelBadgeText,
    ],
    CategoryDesignElement.favoriteButton => const [
      CategoryDesignElement.favoriteButton,
      CategoryDesignElement.favoriteButtonFill,
      CategoryDesignElement.favoriteButtonIcon,
    ],
    CategoryDesignElement.knownButton => const [
      CategoryDesignElement.knownButton,
      CategoryDesignElement.knownButtonFill,
      CategoryDesignElement.knownButtonIcon,
    ],
    CategoryDesignElement.stageSwitch0 => const [
      CategoryDesignElement.stageSwitch0,
      CategoryDesignElement.stageSwitch0Inner,
      CategoryDesignElement.stageSwitch0Number,
    ],
    CategoryDesignElement.stageSwitch1 => const [
      CategoryDesignElement.stageSwitch1,
      CategoryDesignElement.stageSwitch1Inner,
      CategoryDesignElement.stageSwitch1Number,
    ],
    CategoryDesignElement.stageSwitch2 => const [
      CategoryDesignElement.stageSwitch2,
      CategoryDesignElement.stageSwitch2Inner,
      CategoryDesignElement.stageSwitch2Number,
    ],
    CategoryDesignElement.stageSwitch3 => const [
      CategoryDesignElement.stageSwitch3,
      CategoryDesignElement.stageSwitch3Inner,
      CategoryDesignElement.stageSwitch3Number,
    ],
    CategoryDesignElement.stageSwitch4 => const [
      CategoryDesignElement.stageSwitch4,
      CategoryDesignElement.stageSwitch4Inner,
      CategoryDesignElement.stageSwitch4Number,
    ],
    CategoryDesignElement.stageSwitch5 => const [
      CategoryDesignElement.stageSwitch5,
      CategoryDesignElement.stageSwitch5Inner,
      CategoryDesignElement.stageSwitch5Number,
    ],
    CategoryDesignElement.learnStageSwitch0 => const [
      CategoryDesignElement.learnStageSwitch0,
      CategoryDesignElement.learnStageSwitch0Inner,
      CategoryDesignElement.learnStageSwitch0Number,
    ],
    CategoryDesignElement.learnStageSwitch1 => const [
      CategoryDesignElement.learnStageSwitch1,
      CategoryDesignElement.learnStageSwitch1Inner,
      CategoryDesignElement.learnStageSwitch1Number,
    ],
    CategoryDesignElement.learnStageSwitch2 => const [
      CategoryDesignElement.learnStageSwitch2,
      CategoryDesignElement.learnStageSwitch2Inner,
      CategoryDesignElement.learnStageSwitch2Number,
    ],
    CategoryDesignElement.learnStageSwitch3 => const [
      CategoryDesignElement.learnStageSwitch3,
      CategoryDesignElement.learnStageSwitch3Inner,
      CategoryDesignElement.learnStageSwitch3Number,
    ],
    CategoryDesignElement.learnStageSwitch4 => const [
      CategoryDesignElement.learnStageSwitch4,
      CategoryDesignElement.learnStageSwitch4Inner,
      CategoryDesignElement.learnStageSwitch4Number,
    ],
    CategoryDesignElement.learnStageSwitch5 => const [
      CategoryDesignElement.learnStageSwitch5,
      CategoryDesignElement.learnStageSwitch5Inner,
      CategoryDesignElement.learnStageSwitch5Number,
    ],
    _ => const [],
  };
}

CategoryDesignElement _stageInnerElementFor(CategoryDesignElement element) {
  return switch (element) {
    CategoryDesignElement.stageSwitch0 =>
      CategoryDesignElement.stageSwitch0Inner,
    CategoryDesignElement.stageSwitch1 =>
      CategoryDesignElement.stageSwitch1Inner,
    CategoryDesignElement.stageSwitch2 =>
      CategoryDesignElement.stageSwitch2Inner,
    CategoryDesignElement.stageSwitch3 =>
      CategoryDesignElement.stageSwitch3Inner,
    CategoryDesignElement.stageSwitch4 =>
      CategoryDesignElement.stageSwitch4Inner,
    CategoryDesignElement.stageSwitch5 =>
      CategoryDesignElement.stageSwitch5Inner,
    CategoryDesignElement.learnStageSwitch0 =>
      CategoryDesignElement.learnStageSwitch0Inner,
    CategoryDesignElement.learnStageSwitch1 =>
      CategoryDesignElement.learnStageSwitch1Inner,
    CategoryDesignElement.learnStageSwitch2 =>
      CategoryDesignElement.learnStageSwitch2Inner,
    CategoryDesignElement.learnStageSwitch3 =>
      CategoryDesignElement.learnStageSwitch3Inner,
    CategoryDesignElement.learnStageSwitch4 =>
      CategoryDesignElement.learnStageSwitch4Inner,
    CategoryDesignElement.learnStageSwitch5 =>
      CategoryDesignElement.learnStageSwitch5Inner,
    _ => element,
  };
}

CategoryDesignElement _stageNumberElementFor(CategoryDesignElement element) {
  return switch (element) {
    CategoryDesignElement.stageSwitch0 =>
      CategoryDesignElement.stageSwitch0Number,
    CategoryDesignElement.stageSwitch1 =>
      CategoryDesignElement.stageSwitch1Number,
    CategoryDesignElement.stageSwitch2 =>
      CategoryDesignElement.stageSwitch2Number,
    CategoryDesignElement.stageSwitch3 =>
      CategoryDesignElement.stageSwitch3Number,
    CategoryDesignElement.stageSwitch4 =>
      CategoryDesignElement.stageSwitch4Number,
    CategoryDesignElement.stageSwitch5 =>
      CategoryDesignElement.stageSwitch5Number,
    CategoryDesignElement.learnStageSwitch0 =>
      CategoryDesignElement.learnStageSwitch0Number,
    CategoryDesignElement.learnStageSwitch1 =>
      CategoryDesignElement.learnStageSwitch1Number,
    CategoryDesignElement.learnStageSwitch2 =>
      CategoryDesignElement.learnStageSwitch2Number,
    CategoryDesignElement.learnStageSwitch3 =>
      CategoryDesignElement.learnStageSwitch3Number,
    CategoryDesignElement.learnStageSwitch4 =>
      CategoryDesignElement.learnStageSwitch4Number,
    CategoryDesignElement.learnStageSwitch5 =>
      CategoryDesignElement.learnStageSwitch5Number,
    _ => element,
  };
}

Color _accentForElement(
  CategoryDesignElement element,
  CategoryDesignElementStyle style,
) {
  return style.color ?? _defaultAccentForElement(element);
}

Color _defaultAccentForElement(CategoryDesignElement element) {
  return CategoryDesignDefaults.accentFor(element);
}

double _borderWidthForStyle(CategoryDesignElementStyle style) {
  return switch (style.pulse) {
    CategoryDesignPulseStrength.off => 1.45,
    CategoryDesignPulseStrength.subtle => 1.65,
    CategoryDesignPulseStrength.normal => 1.85,
    CategoryDesignPulseStrength.strong => 2.05,
  };
}

double _previewDeviceRadius(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  final shortest = size.shortestSide;
  if (shortest >= 700) return 34;
  if (shortest >= 430) return 42;
  if (shortest >= 390) return 38;
  return 32;
}

List<BoxShadow> _glowShadow(
  Color color,
  CategoryDesignGlowStrength glow,
  CategoryDesignPulseStrength pulse,
) {
  final blur = switch (glow) {
    CategoryDesignGlowStrength.off => 0.0,
    CategoryDesignGlowStrength.subtle => 12.0,
    CategoryDesignGlowStrength.normal => 24.0,
    CategoryDesignGlowStrength.strong => 38.0,
  };
  if (blur == 0 && pulse == CategoryDesignPulseStrength.off) {
    return const [];
  }
  final alpha = switch (glow) {
    CategoryDesignGlowStrength.off => 0.0,
    CategoryDesignGlowStrength.subtle => 0.24,
    CategoryDesignGlowStrength.normal => 0.42,
    CategoryDesignGlowStrength.strong => 0.58,
  };
  return [
    if (blur > 0)
      BoxShadow(
        color: color.withValues(alpha: alpha),
        blurRadius: blur,
        spreadRadius: glow == CategoryDesignGlowStrength.strong ? 2.4 : 0.4,
      ),
    if (pulse != CategoryDesignPulseStrength.off)
      BoxShadow(
        color: color.withValues(
          alpha: switch (pulse) {
            CategoryDesignPulseStrength.off => 0,
            CategoryDesignPulseStrength.subtle => 0.18,
            CategoryDesignPulseStrength.normal => 0.28,
            CategoryDesignPulseStrength.strong => 0.38,
          },
        ),
        blurRadius: switch (pulse) {
          CategoryDesignPulseStrength.off => 0,
          CategoryDesignPulseStrength.subtle => 18,
          CategoryDesignPulseStrength.normal => 28,
          CategoryDesignPulseStrength.strong => 40,
        },
        spreadRadius: switch (pulse) {
          CategoryDesignPulseStrength.off => 0,
          CategoryDesignPulseStrength.subtle => 0.8,
          CategoryDesignPulseStrength.normal => 1.8,
          CategoryDesignPulseStrength.strong => 3.0,
        },
      ),
  ];
}
