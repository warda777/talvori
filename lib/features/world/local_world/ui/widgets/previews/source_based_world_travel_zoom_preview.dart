// Isolated Talvori Welt travel showcase preview. Manual launch only; do not
// export this file into product routes. The PNGs used here are preview
// showcase images, not final product assets, not runtime map data and not
// persistence.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(const _WorldTravelShowcasePreviewApp());

class _WorldTravelShowcasePreviewApp extends StatelessWidget {
  const _WorldTravelShowcasePreviewApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WorldTravelShowcasePreview(),
    );
  }
}

class WorldTravelShowcasePreview extends StatefulWidget {
  const WorldTravelShowcasePreview({super.key});

  @override
  State<WorldTravelShowcasePreview> createState() =>
      _WorldTravelShowcasePreviewState();
}

class _WorldTravelShowcasePreviewState extends State<WorldTravelShowcasePreview>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = _europeIndex;
  int _selectedCountryIndex = _italyCountryIndex;
  int _selectedCityIndex = _firenzeCityIndex;
  var _level = _TravelLevel.continent;
  late final AnimationController _platformController;
  Timer? _cityHintTimer;
  Timer? _cityEntryTimer;
  bool _cityHintVisible = false;
  bool _cityEntryVisible = false;

  _ContinentShowcase get _selected => _continents[_selectedIndex];

  @override
  void initState() {
    super.initState();
    _platformController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _cityHintTimer?.cancel();
    _cityEntryTimer?.cancel();
    _platformController.dispose();
    super.dispose();
  }

  void _shiftContinent(int delta) {
    setState(() {
      _selectedIndex = (_selectedIndex + delta) % _continents.length;
      if (_selectedIndex < 0) _selectedIndex += _continents.length;
    });
  }

  void _selectContinent(int index) {
    setState(() => _selectedIndex = index);
  }

  void _selectCountry(int index) {
    setState(() {
      _selectedCountryIndex = index;
      _cityHintVisible = false;
      _cityEntryVisible = false;
    });
  }

  void _selectCity(int index) {
    setState(() {
      _selectedCityIndex = index;
      _cityEntryVisible = false;
    });
  }

  void _handleSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 180) return;
    _shiftContinent(velocity < 0 ? 1 : -1);
  }

  void _handleBack() {
    if (_level == _TravelLevel.cityMap) {
      setState(() {
        _level = _TravelLevel.country;
        _cityEntryVisible = false;
      });
      return;
    }
    if (_level == _TravelLevel.country) {
      setState(() {
        _level = _TravelLevel.continent;
        _cityHintVisible = false;
      });
      return;
    }
    if (_selectedIndex == _europeIndex) return;
    setState(() => _selectedIndex = _europeIndex);
  }

  void _openSelectedContinent() {
    if (!_selected.isOpenable) return;
    setState(() {
      _level = _TravelLevel.country;
      _selectedCountryIndex = _italyCountryIndex;
      _cityHintVisible = false;
    });
  }

  void _openSelectedCountry() {
    if (_countries[_selectedCountryIndex].label == 'Italien') {
      setState(() {
        _level = _TravelLevel.cityMap;
        _selectedCityIndex = _firenzeCityIndex;
        _cityHintVisible = false;
        _cityEntryVisible = false;
      });
      return;
    }
    setState(() => _cityHintVisible = true);
    _cityHintTimer?.cancel();
    _cityHintTimer = Timer(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      setState(() => _cityHintVisible = false);
    });
  }

  void _enterSelectedCity() {
    setState(() => _cityEntryVisible = true);
    _cityEntryTimer?.cancel();
    _cityEntryTimer = Timer(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      setState(() => _cityEntryVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _TravelColors.space,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: _level == _TravelLevel.continent
            ? _handleSwipe
            : null,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _SpacePainter())),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Column(
                      children: [
                        _TopHud(
                          title: switch (_level) {
                            _TravelLevel.country => _selected.label,
                            _TravelLevel.cityMap => 'Italien',
                            _TravelLevel.continent => 'Weltreise',
                          },
                          onBack: _handleBack,
                          backEnabled:
                              _level == _TravelLevel.cityMap ||
                              _level == _TravelLevel.country ||
                              _selectedIndex != _europeIndex,
                        ),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 380),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: _level == _TravelLevel.continent
                                ? _ShowcaseStage(
                                    key: const ValueKey('continent-stage'),
                                    continent: _selected,
                                    onOpen: _openSelectedContinent,
                                  )
                                : _level == _TravelLevel.country
                                ? _CountrySelectionStage(
                                    key: const ValueKey('country-stage'),
                                    selectedIndex: _selectedCountryIndex,
                                    platformAnimation: _platformController,
                                    cityHintVisible: _cityHintVisible,
                                    onSelect: _selectCountry,
                                    onOpen: _openSelectedCountry,
                                  )
                                : _ItalyCityHotspotStage(
                                    key: const ValueKey('italy-city-map-stage'),
                                    selectedIndex: _selectedCityIndex,
                                    entryVisible: _cityEntryVisible,
                                    animation: _platformController,
                                    onSelect: _selectCity,
                                    onEnter: _enterSelectedCity,
                                  ),
                          ),
                        ),
                        if (_level == _TravelLevel.continent)
                          _ContinentDock(
                            selectedIndex: _selectedIndex,
                            onSelect: _selectContinent,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopHud extends StatelessWidget {
  const _TopHud({
    required this.title,
    required this.onBack,
    required this.backEnabled,
  });

  final String title;
  final VoidCallback onBack;
  final bool backEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleHudButton(
          icon: Icons.chevron_left_rounded,
          onTap: onBack,
          enabled: backEnabled,
        ),
        const SizedBox(width: 12),
        _TitlePill(text: title),
        const Spacer(),
        const _CompanionPill(text: 'Wohin zuerst?'),
      ],
    );
  }
}

class _ShowcaseStage extends StatelessWidget {
  const _ShowcaseStage({
    super.key,
    required this.continent,
    required this.onOpen,
  });

  final _ContinentShowcase continent;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageExtent = math.min(
          constraints.maxWidth * 1.12,
          constraints.maxHeight * 0.68,
        );
        final topGap = math.max(48.0, constraints.maxHeight * 0.12);
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: topGap),
            SizedBox(
              width: imageExtent,
              height: imageExtent,
              child: _HeroContinentImage(continent: continent),
            ),
            const SizedBox(height: 4),
            Text(
              continent.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _TravelColors.text,
                fontSize: 27,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
                shadows: [Shadow(color: Color(0xDD02050A), blurRadius: 14)],
              ),
            ),
            const SizedBox(height: 5),
            continent.isOpenable
                ? _OpenButton(label: 'Europa öffnen', onPressed: onOpen)
                : const SizedBox(height: 28),
            const Spacer(),
          ],
        );
      },
    );
  }
}

class _HeroContinentImage extends StatelessWidget {
  const _HeroContinentImage({required this.continent});

  final _ContinentShowcase continent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [_ShowcaseImageAsset(continent: continent)],
    );
  }
}

class _ShowcaseImageAsset extends StatelessWidget {
  const _ShowcaseImageAsset({required this.continent});

  final _ContinentShowcase continent;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      continent.heroAssetPath,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Text(
            'Bild fehlt',
            style: TextStyle(
              color: _TravelColors.text.withValues(alpha: 0.76),
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      },
    );
  }
}

class _ContinentDock extends StatelessWidget {
  const _ContinentDock({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 98,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        itemBuilder: (context, index) {
          final continent = _continents[index];
          return _ContinentCard(
            continent: continent,
            selected: index == selectedIndex,
            onTap: () => onSelect(index),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemCount: _continents.length,
      ),
    );
  }
}

class _ContinentCard extends StatelessWidget {
  const _ContinentCard({
    required this.continent,
    required this.selected,
    required this.onTap,
  });

  final _ContinentShowcase continent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: selected ? 92 : 82,
        decoration: BoxDecoration(
          color: selected ? const Color(0xCC0A1C2B) : const Color(0x99051018),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? _TravelColors.gold.withValues(alpha: 0.72)
                : _TravelColors.homeCyan.withValues(alpha: 0.20),
            width: selected ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: _TravelColors.gold.withValues(alpha: 0.18),
                blurRadius: 22,
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: selected ? 1.08 : 1.03,
                      child: Image.asset(
                        continent.heroAssetPath,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                        opacity: AlwaysStoppedAnimation(
                          continent.isOpenable ? 1 : 0.56,
                        ),
                      ),
                    ),
                    if (!continent.isOpenable)
                      const Positioned(
                        right: 4,
                        top: 2,
                        child: Icon(
                          Icons.lock_rounded,
                          color: Color(0xFFD6DEE8),
                          size: 13,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Text(
                continent.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? _TravelColors.text
                      : _TravelColors.text.withValues(alpha: 0.62),
                  fontSize: selected ? 11 : 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountrySelectionStage extends StatefulWidget {
  const _CountrySelectionStage({
    super.key,
    required this.selectedIndex,
    required this.platformAnimation,
    required this.cityHintVisible,
    required this.onSelect,
    required this.onOpen,
  });

  final int selectedIndex;
  final Animation<double> platformAnimation;
  final bool cityHintVisible;
  final ValueChanged<int> onSelect;
  final VoidCallback onOpen;

  @override
  State<_CountrySelectionStage> createState() => _CountrySelectionStageState();
}

class _CountrySelectionStageState extends State<_CountrySelectionStage> {
  static const _loopBasePage = 10000;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _pageForLogicalIndex(widget.selectedIndex),
      viewportFraction: 0.62,
    );
  }

  int _countryIndexForPage(int page) {
    return page % _countries.length;
  }

  int _pageForLogicalIndex(int logicalIndex) {
    return _loopBasePage + logicalIndex;
  }

  int _nearestPageForLogicalIndex(int logicalIndex) {
    final currentPage = _pageController.hasClients
        ? (_pageController.page ?? _pageController.initialPage.toDouble())
              .round()
        : _pageController.initialPage;
    final currentLogical = _countryIndexForPage(currentPage);
    var delta = (logicalIndex - currentLogical) % _countries.length;
    if (delta > _countries.length / 2) delta -= _countries.length;
    return currentPage + delta;
  }

  @override
  void didUpdateWidget(covariant _CountrySelectionStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex &&
        _pageController.hasClients) {
      _pageController.animateToPage(
        _nearestPageForLogicalIndex(widget.selectedIndex),
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCountry = _countries[widget.selectedIndex];
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 650;
        final lightHeight = math.min(
          compact ? 260.0 : 330.0,
          constraints.maxHeight * 0.78,
        );
        final stageBottom = compact ? -8.0 : -10.0;
        return Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    bottom: stageBottom,
                    child: SizedBox(
                      width: math.min(390, constraints.maxWidth * 0.94),
                      height: lightHeight,
                      child: AnimatedBuilder(
                        animation: widget.platformAnimation,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: _CountryHeroLightPainter(
                              progress: widget.platformAnimation.value,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    clipBehavior: Clip.none,
                    onPageChanged: (page) {
                      widget.onSelect(_countryIndexForPage(page));
                    },
                    itemBuilder: (context, index) {
                      final countryIndex = _countryIndexForPage(index);
                      final country = _countries[countryIndex];
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          final currentPage =
                              _pageController.hasClients &&
                                  _pageController.position.haveDimensions
                              ? _pageController.page ??
                                    _pageController.initialPage.toDouble()
                              : _pageController.initialPage.toDouble();
                          final distance = (currentPage - index).abs().clamp(
                            0.0,
                            1.0,
                          );
                          final scale = 1.02 - distance * 0.24;
                          final translateY = distance * (compact ? 64 : 86);
                          final opacity = 1.0 - distance * 0.56;
                          return Transform.translate(
                            offset: Offset(0, translateY),
                            child: Transform.scale(
                              scale: scale,
                              alignment: Alignment.center,
                              child: Opacity(opacity: opacity, child: child),
                            ),
                          );
                        },
                        child: _CountryShowcaseItem(
                          country: country,
                          selected: countryIndex == widget.selectedIndex,
                          onTap: () {
                            if (countryIndex == widget.selectedIndex) {
                              widget.onOpen();
                              return;
                            }
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 420),
                              curve: Curves.easeOutCubic,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _CountryTitle(
                key: ValueKey(selectedCountry.label),
                label: selectedCountry.label,
              ),
            ),
            SizedBox(height: compact ? 5 : 7),
            _OpenButton(
              label: selectedCountry.label == 'Italien'
                  ? 'Italien öffnen'
                  : 'Städte ansehen',
              onPressed: widget.onOpen,
            ),
            SizedBox(height: compact ? 8 : 12),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: widget.cityHintVisible ? 1 : 0,
              child: _NextLevelHint(country: selectedCountry.label),
            ),
            SizedBox(height: compact ? 8 : 14),
          ],
        );
      },
    );
  }
}

class _ItalyCityHotspotStage extends StatelessWidget {
  const _ItalyCityHotspotStage({
    super.key,
    required this.selectedIndex,
    required this.entryVisible,
    required this.animation,
    required this.onSelect,
    required this.onEnter,
  });

  final int selectedIndex;
  final bool entryVisible;
  final Animation<double> animation;
  final ValueChanged<int> onSelect;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    final selectedCity = _italyCities[selectedIndex];
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 650;
        final panelHeight = compact ? 102.0 : 116.0;
        final availableMapHeight = constraints.maxHeight - panelHeight;
        var mapWidth = math.min(
          constraints.maxWidth * 1.12,
          availableMapHeight * _italyMapAspect * 1.06,
        );
        var mapHeight = mapWidth / _italyMapAspect;
        if (mapHeight > availableMapHeight) {
          mapHeight = availableMapHeight;
          mapWidth = mapHeight * _italyMapAspect;
        }

        return Column(
          children: [
            Expanded(
              child: Center(
                child: SizedBox(
                  width: mapWidth,
                  height: mapHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: animation,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _ItalyMapAuraPainter(
                                progress: animation.value,
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned.fill(
                        child: Image.asset(
                          '$_countryAssetBase/italy_showcase.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: animation,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _ItalyCityRoutePainter(
                                selectedIndex: selectedIndex,
                                progress: animation.value,
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: animation,
                          builder: (context, _) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                for (var i = 0; i < _italyCities.length; i++)
                                  if (i != selectedIndex)
                                    _PositionedCityHotspot(
                                      city: _italyCities[i],
                                      selected: false,
                                      progress: animation.value,
                                      mapSize: Size(mapWidth, mapHeight),
                                    ),
                                _PositionedCityHotspot(
                                  city: _italyCities[selectedIndex],
                                  selected: true,
                                  progress: animation.value,
                                  mapSize: Size(mapWidth, mapHeight),
                                ),
                                _PositionedCityLabelPointer(
                                  city: selectedCity,
                                  mapSize: Size(mapWidth, mapHeight),
                                ),
                                _PositionedCityLabel(
                                  city: selectedCity,
                                  mapSize: Size(mapWidth, mapHeight),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTapDown: (details) {
                            final nearest = _nearestCityIndex(
                              details.localPosition,
                              Size(mapWidth, mapHeight),
                            );
                            if (nearest != null) onSelect(nearest);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _CityInfoPanel(
              city: selectedCity,
              entryVisible: entryVisible,
              onEnter: selectedCity.available ? onEnter : null,
            ),
            SizedBox(height: compact ? 6 : 10),
          ],
        );
      },
    );
  }

  int? _nearestCityIndex(Offset tapPosition, Size mapSize) {
    const minimumTapRadius = 54.0;
    final dynamicRadius = math.min(mapSize.width, mapSize.height) * 0.12;
    final hitRadius = math.max(minimumTapRadius, dynamicRadius);
    var nearestIndex = -1;
    var nearestDistance = double.infinity;

    for (var i = 0; i < _italyCities.length; i++) {
      final city = _italyCities[i];
      final point = Offset(
        city.position.dx * mapSize.width,
        city.position.dy * mapSize.height,
      );
      final distance = (tapPosition - point).distance;
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestIndex = i;
      }
    }

    return nearestDistance <= hitRadius ? nearestIndex : null;
  }
}

class _PositionedCityHotspot extends StatelessWidget {
  const _PositionedCityHotspot({
    required this.city,
    required this.selected,
    required this.progress,
    required this.mapSize,
  });

  final _ItalyCityHotspot city;
  final bool selected;
  final double progress;
  final Size mapSize;

  @override
  Widget build(BuildContext context) {
    final markerSize = selected ? 64.0 : 52.0;
    final paintSize = selected ? 84.0 : 66.0;
    final point = _cityPoint(city, mapSize);
    return Positioned(
      left: point.dx - paintSize / 2,
      top: point.dy - paintSize / 2,
      width: paintSize,
      height: paintSize,
      child: IgnorePointer(
        child: Center(
          child: SizedBox(
            width: markerSize,
            height: markerSize,
            child: CustomPaint(
              isComplex: true,
              painter: _CityHotspotPainter(
                selected: selected,
                available: city.available,
                kind: city.kind,
                progress: progress,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PositionedCityLabel extends StatelessWidget {
  const _PositionedCityLabel({required this.city, required this.mapSize});

  final _ItalyCityHotspot city;
  final Size mapSize;

  @override
  Widget build(BuildContext context) {
    final layout = _cityLabelLayout(city, mapSize);
    final rect = layout.rect;

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      child: IgnorePointer(
        child: _CityHotspotBadge(label: city.label, available: city.available),
      ),
    );
  }
}

class _PositionedCityLabelPointer extends StatelessWidget {
  const _PositionedCityLabelPointer({
    required this.city,
    required this.mapSize,
  });

  final _ItalyCityHotspot city;
  final Size mapSize;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _CityLabelPointerPainter(city: city, mapSize: mapSize),
        ),
      ),
    );
  }
}

Offset _cityPoint(_ItalyCityHotspot city, Size mapSize) {
  return Offset(
    city.position.dx * mapSize.width,
    city.position.dy * mapSize.height,
  );
}

class _CityLabelLayout {
  const _CityLabelLayout({required this.rect, required this.placement});

  final Rect rect;
  final _CityLabelPlacement placement;
}

_CityLabelLayout _cityLabelLayout(_ItalyCityHotspot city, Size mapSize) {
  final placements = _cityLabelPlacementOrder(city.labelPlacement);
  for (final placement in placements) {
    final rect = _cityLabelRectForPlacement(
      city,
      mapSize,
      placement,
      useFineOffset: placement == city.labelPlacement,
    );
    if (_cityLabelCandidateIsClear(city, mapSize, rect)) {
      return _CityLabelLayout(rect: rect, placement: placement);
    }
  }

  return _CityLabelLayout(
    rect: _cityLabelRectForPlacement(
      city,
      mapSize,
      city.labelPlacement,
      useFineOffset: true,
      clampToMap: true,
    ),
    placement: city.labelPlacement,
  );
}

List<_CityLabelPlacement> _cityLabelPlacementOrder(
  _CityLabelPlacement preferred,
) {
  final order = <_CityLabelPlacement>[
    preferred,
    _CityLabelPlacement.below,
    _CityLabelPlacement.above,
    _CityLabelPlacement.right,
    _CityLabelPlacement.left,
    _CityLabelPlacement.belowLeft,
    _CityLabelPlacement.belowRight,
    _CityLabelPlacement.aboveLeft,
    _CityLabelPlacement.aboveRight,
  ];
  return order.toSet().toList();
}

Rect _cityLabelRectForPlacement(
  _ItalyCityHotspot city,
  Size mapSize,
  _CityLabelPlacement placement, {
  required bool useFineOffset,
  bool clampToMap = false,
}) {
  final point = _cityPoint(city, mapSize);
  final width = _cityLabelWidthFor(city.label);
  const height = _cityLabelHeight;
  const gap = 42.0;
  const diagonalGap = 30.0;
  final baseLeft = switch (placement) {
    _CityLabelPlacement.above ||
    _CityLabelPlacement.below => point.dx - width / 2,
    _CityLabelPlacement.left => point.dx - width - gap,
    _CityLabelPlacement.right => point.dx + gap,
    _CityLabelPlacement.belowLeft ||
    _CityLabelPlacement.aboveLeft => point.dx - width - diagonalGap,
    _CityLabelPlacement.belowRight ||
    _CityLabelPlacement.aboveRight => point.dx + diagonalGap,
  };
  final baseTop = switch (placement) {
    _CityLabelPlacement.above => point.dy - gap - height,
    _CityLabelPlacement.below => point.dy + gap,
    _CityLabelPlacement.left ||
    _CityLabelPlacement.right => point.dy - height / 2,
    _CityLabelPlacement.belowLeft ||
    _CityLabelPlacement.belowRight => point.dy + diagonalGap,
    _CityLabelPlacement.aboveLeft ||
    _CityLabelPlacement.aboveRight => point.dy - diagonalGap - height,
  };
  final offset = useFineOffset ? city.labelOffset : Offset.zero;
  var left = baseLeft + offset.dx;
  var top = baseTop + offset.dy;
  if (clampToMap) {
    left = left.clamp(-6.0, mapSize.width - width + 6.0).toDouble();
    top = top.clamp(-4.0, mapSize.height - height + 4.0).toDouble();
  }
  return Rect.fromLTWH(left, top, width, height);
}

bool _cityLabelCandidateIsClear(
  _ItalyCityHotspot activeCity,
  Size mapSize,
  Rect labelRect,
) {
  final allowedBounds = Rect.fromLTWH(
    -8,
    -6,
    mapSize.width + 16,
    mapSize.height + 12,
  );
  if (!allowedBounds.contains(labelRect.topLeft) ||
      !allowedBounds.contains(labelRect.bottomRight)) {
    return false;
  }

  final activePoint = _cityPoint(activeCity, mapSize);
  if (labelRect
      .inflate(5)
      .overlaps(Rect.fromCircle(center: activePoint, radius: 30))) {
    return false;
  }

  for (final city in _italyCities) {
    if (city == activeCity) continue;
    final point = _cityPoint(city, mapSize);
    final avoidRect = Rect.fromCircle(center: point, radius: 23);
    if (labelRect.inflate(4).overlaps(avoidRect)) return false;
  }

  return true;
}

double _cityLabelWidthFor(String label) {
  return (label.runes.length * 7.2 + 23)
      .clamp(_cityLabelMinWidth, _cityLabelMaxWidth)
      .toDouble();
}

class _ItalyCityRoutePainter extends CustomPainter {
  const _ItalyCityRoutePainter({
    required this.selectedIndex,
    required this.progress,
  });

  final int selectedIndex;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final pulse = 0.5 + 0.5 * math.sin(progress * math.pi * 2);
    final routes = const [
      [3, 7, 2],
      [3, 8, 6, 1, 0, 4, 9],
      [1, 5, 7],
      [0, 10, 11],
      [8, 12],
    ];
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..color = _TravelColors.homeCyan.withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..color = _TravelColors.gold.withValues(alpha: 0.18 + pulse * 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    for (final route in routes) {
      for (var i = 0; i < route.length - 1; i++) {
        final fromIndex = route[i];
        final toIndex = route[i + 1];
        final from = _cityPoint(fromIndex, size);
        final to = _cityPoint(toIndex, size);
        final mid = Offset(
          (from.dx + to.dx) / 2,
          (from.dy + to.dy) / 2 - size.height * 0.018,
        );
        final path = Path()
          ..moveTo(from.dx, from.dy)
          ..quadraticBezierTo(mid.dx, mid.dy, to.dx, to.dy);
        canvas.drawPath(path, basePaint);
        if (fromIndex == selectedIndex || toIndex == selectedIndex) {
          canvas.drawPath(path, activePaint);
        }
      }
    }
  }

  Offset _cityPoint(int index, Size size) {
    final position = _italyCities[index].position;
    return Offset(position.dx * size.width, position.dy * size.height);
  }

  @override
  bool shouldRepaint(covariant _ItalyCityRoutePainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.progress != progress;
  }
}

class _CityLabelPointerPainter extends CustomPainter {
  const _CityLabelPointerPainter({required this.city, required this.mapSize});

  final _ItalyCityHotspot city;
  final Size mapSize;

  @override
  void paint(Canvas canvas, Size size) {
    final cityPoint = _cityPoint(city, mapSize);
    final labelLayout = _cityLabelLayout(city, mapSize);
    final labelRect = labelLayout.rect;
    final labelAnchor = switch (labelLayout.placement) {
      _CityLabelPlacement.above => Offset(
        labelRect.center.dx,
        labelRect.bottom,
      ),
      _CityLabelPlacement.below => Offset(labelRect.center.dx, labelRect.top),
      _CityLabelPlacement.left => Offset(labelRect.right, labelRect.center.dy),
      _CityLabelPlacement.right => Offset(labelRect.left, labelRect.center.dy),
      _CityLabelPlacement.belowLeft => Offset(labelRect.right, labelRect.top),
      _CityLabelPlacement.belowRight => Offset(labelRect.left, labelRect.top),
      _CityLabelPlacement.aboveLeft => Offset(
        labelRect.right,
        labelRect.bottom,
      ),
      _CityLabelPlacement.aboveRight => Offset(
        labelRect.left,
        labelRect.bottom,
      ),
    };
    final lineStart = Offset.lerp(cityPoint, labelAnchor, 0.38)!;
    final accent = city.available ? _TravelColors.gold : _TravelColors.homeCyan;

    canvas.drawLine(
      lineStart,
      labelAnchor,
      Paint()
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xC002050A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawLine(
      lineStart,
      labelAnchor,
      Paint()
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..color = accent.withValues(alpha: 0.70),
    );
    canvas.drawCircle(
      labelAnchor,
      2.8,
      Paint()..color = accent.withValues(alpha: 0.82),
    );
  }

  @override
  bool shouldRepaint(covariant _CityLabelPointerPainter oldDelegate) {
    return oldDelegate.city != city || oldDelegate.mapSize != mapSize;
  }
}

class _CityHotspotBadge extends StatelessWidget {
  const _CityHotspotBadge({required this.label, required this.available});

  final String label;
  final bool available;

  @override
  Widget build(BuildContext context) {
    final accent = available ? _TravelColors.gold : _TravelColors.homeCyan;
    final width = _cityLabelWidthFor(label);
    return Center(
      child: SizedBox(
        width: width,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xE607101A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.62)),
            boxShadow: [
              BoxShadow(color: accent.withValues(alpha: 0.16), blurRadius: 16),
              const BoxShadow(color: Color(0xB002050A), blurRadius: 10),
            ],
          ),
          child: SizedBox(
            height: _cityLabelHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _TravelColors.text,
                    fontSize: 11,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                    shadows: [Shadow(color: Color(0xEE02050A), blurRadius: 8)],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CityHotspotPainter extends CustomPainter {
  const _CityHotspotPainter({
    required this.selected,
    required this.available,
    required this.kind,
    required this.progress,
  });

  final bool selected;
  final bool available;
  final _CityBeaconKind kind;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final pulse = 0.5 + 0.5 * math.sin(progress * math.pi * 2);
    final center = Offset(size.width / 2, size.height * 0.52);
    final strength = selected
        ? 1.0
        : available
        ? 0.88
        : 0.60;
    final accent = available ? _TravelColors.gold : _TravelColors.homeCyan;
    final secondary = available
        ? _TravelColors.homeCyan
        : _TravelColors.homeViolet;
    final baseRadius = size.shortestSide * (selected ? 0.32 : 0.31);
    final baseCenter = Offset(center.dx, size.height * 0.67);
    final glowRect = Rect.fromCircle(
      center: baseCenter,
      radius: baseRadius * (selected ? 2.18 : 1.92),
    );

    canvas.drawCircle(
      baseCenter,
      baseRadius * (selected ? 1.74 : 1.58),
      Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withValues(alpha: (0.30 + pulse * 0.09) * strength),
            secondary.withValues(alpha: 0.16 * strength),
            Colors.transparent,
          ],
          stops: const [0, 0.50, 1],
        ).createShader(glowRect),
    );

    if (selected) {
      final beamRect = Rect.fromCenter(
        center: Offset(center.dx, size.height * 0.35),
        width: size.width * 0.56,
        height: size.height * 0.62,
      );
      final beam = Path()
        ..moveTo(center.dx - size.width * 0.24, baseCenter.dy)
        ..lineTo(center.dx - size.width * 0.08, size.height * 0.06)
        ..lineTo(center.dx + size.width * 0.08, size.height * 0.06)
        ..lineTo(center.dx + size.width * 0.24, baseCenter.dy)
        ..close();
      canvas.drawPath(
        beam,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              accent.withValues(alpha: 0.17 + pulse * 0.04),
              _TravelColors.homeCyan.withValues(alpha: 0.09),
              Colors.transparent,
            ],
            stops: const [0, 0.48, 1],
          ).createShader(beamRect)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, size.height * 0.83),
        width: size.width * 0.82,
        height: size.height * 0.19,
      ),
      Paint()
        ..color = const Color(0x9902050A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    final floorRect = Rect.fromCenter(
      center: baseCenter,
      width: size.width * 0.74,
      height: size.height * 0.30,
    );
    canvas.drawOval(
      floorRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withValues(alpha: (0.42 + pulse * 0.06) * strength),
            secondary.withValues(alpha: 0.23 * strength),
            Colors.transparent,
          ],
          stops: const [0, 0.56, 1],
        ).createShader(floorRect),
    );
    canvas.drawOval(
      floorRect.deflate(size.width * 0.13),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 2.4 : 1.8
        ..color = _TravelColors.text.withValues(alpha: 0.42 * strength),
    );

    final nodeRadius = size.shortestSide * (selected ? 0.19 : 0.16);
    canvas.drawCircle(
      center,
      nodeRadius * 1.42,
      Paint()
        ..color = const Color(0xCC02050A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(
      center,
      nodeRadius * 1.26,
      Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _TravelColors.text.withValues(alpha: 0.88 * strength),
                accent.withValues(alpha: 0.96 * strength),
                secondary.withValues(alpha: 0.70 * strength),
              ],
              stops: const [0, 0.46, 1],
            ).createShader(
              Rect.fromCircle(center: center, radius: nodeRadius * 1.3),
            ),
    );
    canvas.drawCircle(
      center,
      nodeRadius * 1.32,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 2.1 : 1.5
        ..color = _TravelColors.text.withValues(alpha: 0.62 * strength),
    );

    final iconRect = Rect.fromCenter(
      center: center,
      width: nodeRadius * 1.38,
      height: nodeRadius * 1.38,
    );
    _drawCityIcon(canvas, iconRect, strength);

    if (selected) {
      canvas.drawCircle(
        center,
        baseRadius * (1.44 + pulse * 0.16),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = accent.withValues(alpha: 0.54)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
      canvas.drawCircle(
        center,
        baseRadius * (1.88 + pulse * 0.24),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = _TravelColors.homeCyan.withValues(alpha: 0.26)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
  }

  void _drawCityIcon(Canvas canvas, Rect rect, double strength) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = rect.width * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF02050A).withValues(alpha: 0.86 * strength);
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF02050A).withValues(alpha: 0.82 * strength);

    switch (kind) {
      case _CityBeaconKind.culture:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              rect.left + rect.width * 0.31,
              rect.top + rect.height * 0.38,
              rect.width * 0.38,
              rect.height * 0.42,
            ),
            Radius.circular(rect.width * 0.08),
          ),
          fillPaint,
        );
        canvas.drawArc(
          Rect.fromLTWH(
            rect.left + rect.width * 0.25,
            rect.top + rect.height * 0.14,
            rect.width * 0.50,
            rect.height * 0.48,
          ),
          math.pi,
          math.pi,
          false,
          paint,
        );
      case _CityBeaconKind.hub:
        canvas.drawCircle(rect.center, rect.width * 0.16, fillPaint);
        for (final x in [0.24, 0.50, 0.76]) {
          canvas.drawLine(
            Offset(rect.left + rect.width * x, rect.top + rect.height * 0.30),
            Offset(rect.left + rect.width * x, rect.top + rect.height * 0.78),
            paint,
          );
        }
        canvas.drawLine(
          Offset(rect.left + rect.width * 0.18, rect.top + rect.height * 0.28),
          Offset(rect.left + rect.width * 0.82, rect.top + rect.height * 0.28),
          paint,
        );
      case _CityBeaconKind.water:
        for (final y in [0.35, 0.58]) {
          final path = Path()
            ..moveTo(rect.left + rect.width * 0.16, rect.top + rect.height * y)
            ..quadraticBezierTo(
              rect.left + rect.width * 0.34,
              rect.top + rect.height * (y - 0.16),
              rect.left + rect.width * 0.50,
              rect.top + rect.height * y,
            )
            ..quadraticBezierTo(
              rect.left + rect.width * 0.66,
              rect.top + rect.height * (y + 0.16),
              rect.left + rect.width * 0.84,
              rect.top + rect.height * y,
            );
          canvas.drawPath(path, paint);
        }
      case _CityBeaconKind.coast:
        final anchor = Path()
          ..moveTo(rect.center.dx, rect.top + rect.height * 0.18)
          ..lineTo(rect.center.dx, rect.top + rect.height * 0.74)
          ..moveTo(rect.left + rect.width * 0.28, rect.top + rect.height * 0.48)
          ..lineTo(
            rect.right - rect.width * 0.28,
            rect.top + rect.height * 0.48,
          );
        canvas.drawPath(anchor, paint);
        canvas.drawArc(
          Rect.fromLTWH(
            rect.left + rect.width * 0.20,
            rect.top + rect.height * 0.42,
            rect.width * 0.60,
            rect.height * 0.48,
          ),
          0,
          math.pi,
          false,
          paint,
        );
      case _CityBeaconKind.volcano:
        final volcano = Path()
          ..moveTo(
            rect.left + rect.width * 0.18,
            rect.bottom - rect.height * 0.18,
          )
          ..lineTo(rect.left + rect.width * 0.44, rect.top + rect.height * 0.24)
          ..lineTo(rect.left + rect.width * 0.56, rect.top + rect.height * 0.24)
          ..lineTo(
            rect.right - rect.width * 0.18,
            rect.bottom - rect.height * 0.18,
          );
        canvas.drawPath(volcano, paint);
        canvas.drawCircle(
          Offset(rect.center.dx, rect.top + rect.height * 0.18),
          rect.width * 0.07,
          fillPaint,
        );
      case _CityBeaconKind.tower:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              rect.left + rect.width * 0.34,
              rect.top + rect.height * 0.22,
              rect.width * 0.32,
              rect.height * 0.58,
            ),
            Radius.circular(rect.width * 0.06),
          ),
          fillPaint,
        );
        canvas.drawLine(
          Offset(rect.left + rect.width * 0.25, rect.top + rect.height * 0.32),
          Offset(rect.left + rect.width * 0.75, rect.top + rect.height * 0.32),
          paint,
        );
      case _CityBeaconKind.city:
        canvas.drawRect(
          Rect.fromLTWH(
            rect.left + rect.width * 0.18,
            rect.top + rect.height * 0.44,
            rect.width * 0.20,
            rect.height * 0.34,
          ),
          fillPaint,
        );
        canvas.drawRect(
          Rect.fromLTWH(
            rect.left + rect.width * 0.42,
            rect.top + rect.height * 0.26,
            rect.width * 0.20,
            rect.height * 0.52,
          ),
          fillPaint,
        );
        canvas.drawRect(
          Rect.fromLTWH(
            rect.left + rect.width * 0.66,
            rect.top + rect.height * 0.38,
            rect.width * 0.18,
            rect.height * 0.40,
          ),
          fillPaint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _CityHotspotPainter oldDelegate) {
    return oldDelegate.selected != selected ||
        oldDelegate.available != available ||
        oldDelegate.kind != kind ||
        oldDelegate.progress != progress;
  }
}

class _ItalyMapAuraPainter extends CustomPainter {
  const _ItalyMapAuraPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final pulse = 0.5 + 0.5 * math.sin(progress * math.pi * 2);
    final rect = Offset.zero & size;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.54, size.height * 0.53),
        width: size.width * 0.78,
        height: size.height * 0.62,
      ),
      Paint()
        ..shader = RadialGradient(
          colors: [
            _TravelColors.homeCyan.withValues(alpha: 0.10 + pulse * 0.025),
            _TravelColors.homeViolet.withValues(alpha: 0.06),
            Colors.transparent,
          ],
          stops: const [0, 0.52, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _ItalyMapAuraPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _CityInfoPanel extends StatelessWidget {
  const _CityInfoPanel({
    required this.city,
    required this.entryVisible,
    required this.onEnter,
  });

  final _ItalyCityHotspot city;
  final bool entryVisible;
  final VoidCallback? onEnter;

  @override
  Widget build(BuildContext context) {
    final accent = city.available ? _TravelColors.gold : _TravelColors.homeCyan;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xD707101A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accent.withValues(alpha: 0.48)),
          boxShadow: [
            BoxShadow(color: accent.withValues(alpha: 0.16), blurRadius: 28),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 11, 12, 11),
          child: Row(
            children: [
              _CityPanelFocusOrb(accent: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.label,
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      style: const TextStyle(
                        color: _TravelColors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      entryVisible ? 'Preview bereit' : city.role,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        color: _TravelColors.text.withValues(alpha: 0.66),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _OpenButton(
                label: city.available ? 'Stadt betreten' : 'Später',
                onPressed: onEnter,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityPanelFocusOrb extends StatelessWidget {
  const _CityPanelFocusOrb({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            _TravelColors.text.withValues(alpha: 0.94),
            accent.withValues(alpha: 0.86),
            _TravelColors.homeViolet.withValues(alpha: 0.52),
          ],
        ),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.32), blurRadius: 18),
          const BoxShadow(color: Color(0xC002050A), blurRadius: 10),
        ],
      ),
      child: const SizedBox(
        width: 31,
        height: 31,
        child: Icon(
          Icons.auto_awesome_rounded,
          color: Color(0xFF02050A),
          size: 15,
        ),
      ),
    );
  }
}

class _CountryShowcaseItem extends StatelessWidget {
  const _CountryShowcaseItem({
    required this.country,
    required this.selected,
    required this.onTap,
  });

  final _CountryShowcase country;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 0 : 12,
          vertical: selected ? 0 : 18,
        ),
        child: Transform.translate(
          offset: Offset(
            0,
            selected ? country.verticalOffset : country.verticalOffset * 0.45,
          ),
          child: Transform.scale(
            scale: selected
                ? 1.18 * country.visualScale
                : 0.90 * country.sideScale,
            child: Image.asset(
              country.assetPath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    'Bild fehlt',
                    style: TextStyle(
                      color: _TravelColors.text.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CountryTitle extends StatelessWidget {
  const _CountryTitle({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final length = label.runes.length;
    final fontSize = length >= 22
        ? 25.5
        : length >= 17
        ? 27.5
        : length >= 13
        ? 29.5
        : 31.0;

    return SizedBox(
      height: 64,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            label,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _TravelColors.text,
              fontSize: fontSize,
              height: 1.02,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
              shadows: const [Shadow(color: Color(0xEE02050A), blurRadius: 16)],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountryHeroLightPainter extends CustomPainter {
  const _CountryHeroLightPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final pulse = 0.5 + 0.5 * math.sin(progress * math.pi * 2);
    final center = Offset(size.width / 2, size.height * 0.78);
    final shadowRect = Rect.fromCenter(
      center: center.translate(0, size.height * 0.035),
      width: size.width * 0.64,
      height: size.height * 0.11,
    );
    final ambientRect = Rect.fromCenter(
      center: center.translate(0, -size.height * 0.22),
      width: size.width * 1.04,
      height: size.height * 0.95,
    );
    final floorRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.96,
      height: size.height * 0.18,
    );
    final beamRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.40),
      width: size.width * 0.88,
      height: size.height * 0.80,
    );
    final beamTop = size.height * 0.08;
    final beamBottom = center.dy + size.height * 0.03;
    final beamPath = Path()
      ..moveTo(center.dx - size.width * 0.43, beamBottom)
      ..cubicTo(
        center.dx - size.width * 0.24,
        size.height * 0.36,
        center.dx - size.width * 0.10,
        beamTop,
        center.dx,
        beamTop,
      )
      ..cubicTo(
        center.dx + size.width * 0.10,
        beamTop,
        center.dx + size.width * 0.24,
        size.height * 0.36,
        center.dx + size.width * 0.43,
        beamBottom,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy + size.height * 0.15,
        center.dx - size.width * 0.43,
        beamBottom,
      )
      ..close();
    final coreRect = Rect.fromCenter(
      center: Offset(center.dx, size.height * 0.46),
      width: size.width * 0.42,
      height: size.height * 0.78,
    );

    canvas.drawOval(
      ambientRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _TravelColors.homeCyan.withValues(alpha: 0.13 + pulse * 0.025),
            _TravelColors.homeViolet.withValues(alpha: 0.08),
            Colors.transparent,
          ],
          stops: const [0, 0.50, 1],
        ).createShader(ambientRect),
    );

    canvas.drawPath(
      beamPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            _TravelColors.homeCyan.withValues(alpha: 0.25 + pulse * 0.045),
            _TravelColors.homeViolet.withValues(alpha: 0.145),
            Colors.transparent,
          ],
          stops: const [0.0, 0.58, 1.0],
        ).createShader(beamRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(coreRect, const Radius.circular(999)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            _TravelColors.homeCyan.withValues(alpha: 0.12 + pulse * 0.025),
            _TravelColors.homeViolet.withValues(alpha: 0.075),
            Colors.transparent,
          ],
          stops: const [0.0, 0.50, 1.0],
        ).createShader(coreRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );

    canvas.drawOval(
      shadowRect,
      Paint()
        ..color = const Color(0xD002050A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    canvas.drawOval(
      floorRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _TravelColors.gold.withValues(alpha: 0.18 + pulse * 0.03),
            _TravelColors.homeCyan.withValues(alpha: 0.18),
            _TravelColors.homeViolet.withValues(alpha: 0.10),
            Colors.transparent,
          ],
          stops: const [0, 0.42, 0.70, 1],
        ).createShader(floorRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(covariant _CountryHeroLightPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _NextLevelHint extends StatelessWidget {
  const _NextLevelHint({required this.country});

  final String country;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xB607101A),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: _TravelColors.homeCyan.withValues(alpha: 0.26),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          '$country: Städte-Auswahl vorbereitet',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _TravelColors.text.withValues(alpha: 0.78),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _OpenButton extends StatelessWidget {
  const _OpenButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: onPressed == null
            ? const Color(0xFF263344)
            : _TravelColors.gold,
        foregroundColor: onPressed == null
            ? _TravelColors.text.withValues(alpha: 0.58)
            : const Color(0xFF24160A),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        shape: const StadiumBorder(),
        elevation: 0,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _CircleHudButton extends StatelessWidget {
  const _CircleHudButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : 0.54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xAA07101A),
            border: Border.all(
              color: _TravelColors.homeCyan.withValues(alpha: 0.54),
            ),
            boxShadow: [
              BoxShadow(
                color: _TravelColors.homeCyan.withValues(alpha: 0.16),
                blurRadius: 18,
              ),
            ],
          ),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: _TravelColors.text, size: 26),
          ),
        ),
      ),
    );
  }
}

class _TitlePill extends StatelessWidget {
  const _TitlePill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xB307101A),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _TravelColors.homeCyan.withValues(alpha: 0.54),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: _TravelColors.homeCyan.withValues(alpha: 0.13),
            blurRadius: 15,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _TravelColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _CompanionPill extends StatelessWidget {
  const _CompanionPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xEEF8E8C8),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: _TravelColors.gold.withValues(alpha: 0.20),
            blurRadius: 16,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFA76B1D),
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF6A4513),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_TravelColors.space, Color(0xFF061221), Color(0xFF02050A)],
          stops: [0, 0.48, 1],
        ).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            _TravelColors.homeCyan.withValues(alpha: 0.12),
            Colors.transparent,
            _TravelColors.homeViolet.withValues(alpha: 0.11),
          ],
          stops: const [0, 0.52, 1],
        ).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xF002050A), Color(0x0002050A), Color(0xAA02050A)],
          stops: [0.0, 0.46, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _SpacePainter oldDelegate) => false;
}

class _ContinentShowcase {
  const _ContinentShowcase({
    required this.label,
    required this.heroAssetPath,
    required this.isOpenable,
  });

  final String label;
  final String heroAssetPath;
  final bool isOpenable;
}

class _CountryShowcase {
  const _CountryShowcase({
    required this.label,
    required this.assetPath,
    this.visualScale = 1,
    this.verticalOffset = 0,
    this.sideScale = 1,
  });

  final String label;
  final String assetPath;
  final double visualScale;
  final double verticalOffset;
  final double sideScale;
}

class _ItalyCityHotspot {
  const _ItalyCityHotspot({
    required this.label,
    required this.role,
    required this.position,
    required this.kind,
    this.labelPlacement = _CityLabelPlacement.below,
    this.labelOffset = Offset.zero,
    this.available = false,
  });

  final String label;
  final String role;
  final Offset position;
  final _CityBeaconKind kind;
  final _CityLabelPlacement labelPlacement;
  final Offset labelOffset;
  final bool available;
}

enum _CityBeaconKind { culture, hub, water, coast, volcano, tower, city }

enum _CityLabelPlacement {
  above,
  below,
  left,
  right,
  belowLeft,
  belowRight,
  aboveLeft,
  aboveRight,
}

class _TravelColors {
  const _TravelColors._();

  static const space = Color(0xFF02050A);
  static const homeCyan = Color(0xFF00D8FF);
  static const homeViolet = Color(0xFF9B4DFF);
  static const text = Color(0xFFF4F8FF);
  static const gold = Color(0xFFFFD69A);
}

const _assetBase = 'assets/images/world/travel/continent_showcase';
const _countryAssetBase = 'assets/images/world/travel/country_showcase/cutout';
const _europeIndex = 2;
const _italyCountryIndex = 0;
const _firenzeCityIndex = 1;
const _italyMapAspect = 1214 / 1199;
const _cityLabelMinWidth = 56.0;
const _cityLabelMaxWidth = 86.0;
const _cityLabelHeight = 30.0;

enum _TravelLevel { continent, country, cityMap }

const _continents = <_ContinentShowcase>[
  _ContinentShowcase(
    label: 'Nordamerika',
    heroAssetPath: '$_assetBase/north_america_cutout.png',
    isOpenable: false,
  ),
  _ContinentShowcase(
    label: 'Südamerika',
    heroAssetPath: '$_assetBase/south_america_cutout.png',
    isOpenable: false,
  ),
  _ContinentShowcase(
    label: 'Europa',
    heroAssetPath: '$_assetBase/europe_cutout.png',
    isOpenable: true,
  ),
  _ContinentShowcase(
    label: 'Afrika',
    heroAssetPath: '$_assetBase/africa_cutout.png',
    isOpenable: false,
  ),
  _ContinentShowcase(
    label: 'Asien',
    heroAssetPath: '$_assetBase/asia_cutout.png',
    isOpenable: false,
  ),
  _ContinentShowcase(
    label: 'Australien',
    heroAssetPath: '$_assetBase/australia_cutout.png',
    isOpenable: false,
  ),
];

const _countries = <_CountryShowcase>[
  _CountryShowcase(
    label: 'Italien',
    assetPath: '$_countryAssetBase/italy_showcase.png',
    visualScale: 0.98,
  ),
  _CountryShowcase(
    label: 'Frankreich',
    assetPath: '$_countryAssetBase/france_showcase.png',
    visualScale: 0.97,
  ),
  _CountryShowcase(
    label: 'Deutschland',
    assetPath: '$_countryAssetBase/germany_showcase.png',
    visualScale: 0.98,
  ),
  _CountryShowcase(
    label: 'Spanien',
    assetPath: '$_countryAssetBase/spain_showcase.png',
    visualScale: 1.03,
  ),
  _CountryShowcase(
    label: 'Portugal',
    assetPath: '$_countryAssetBase/portugal_showcase.png',
    visualScale: 0.82,
    verticalOffset: 7,
    sideScale: 0.88,
  ),
  _CountryShowcase(
    label: 'Vereinigtes Königreich',
    assetPath: '$_countryAssetBase/united_kingdom_showcase.png',
    visualScale: 0.99,
  ),
  _CountryShowcase(
    label: 'Irland',
    assetPath: '$_countryAssetBase/ireland_showcase.png',
    visualScale: 0.98,
  ),
  _CountryShowcase(
    label: 'Island',
    assetPath: '$_countryAssetBase/iceland_showcase.png',
    visualScale: 1.1,
    verticalOffset: -4,
  ),
  _CountryShowcase(
    label: 'Norwegen',
    assetPath: '$_countryAssetBase/norway_showcase.png',
    visualScale: 1.02,
  ),
  _CountryShowcase(
    label: 'Schweden',
    assetPath: '$_countryAssetBase/sweden_showcase.png',
    visualScale: 0.86,
    verticalOffset: 8,
    sideScale: 0.9,
  ),
  _CountryShowcase(
    label: 'Finnland',
    assetPath: '$_countryAssetBase/finland_showcase.png',
    visualScale: 0.96,
  ),
  _CountryShowcase(
    label: 'Dänemark',
    assetPath: '$_countryAssetBase/denmark_showcase.png',
    visualScale: 0.98,
  ),
  _CountryShowcase(
    label: 'Niederlande',
    assetPath: '$_countryAssetBase/netherlands_showcase.png',
    visualScale: 1.02,
  ),
  _CountryShowcase(
    label: 'Belgien',
    assetPath: '$_countryAssetBase/belgium_showcase.png',
    visualScale: 0.98,
  ),
  _CountryShowcase(
    label: 'Luxemburg',
    assetPath: '$_countryAssetBase/luxembourg_showcase.png',
    visualScale: 1.05,
  ),
  _CountryShowcase(
    label: 'Schweiz',
    assetPath: '$_countryAssetBase/switzerland_showcase.png',
    visualScale: 0.99,
  ),
  _CountryShowcase(
    label: 'Österreich',
    assetPath: '$_countryAssetBase/austria_showcase.png',
    visualScale: 0.99,
  ),
  _CountryShowcase(
    label: 'Liechtenstein',
    assetPath: '$_countryAssetBase/liechtenstein_showcase.png',
    visualScale: 0.9,
    verticalOffset: 5,
    sideScale: 0.92,
  ),
  _CountryShowcase(
    label: 'Polen',
    assetPath: '$_countryAssetBase/poland_showcase.png',
    visualScale: 0.99,
  ),
  _CountryShowcase(
    label: 'Tschechien',
    assetPath: '$_countryAssetBase/czech_republic_showcase.png',
    visualScale: 1.06,
  ),
  _CountryShowcase(
    label: 'Slowakei',
    assetPath: '$_countryAssetBase/slovakia_showcase.png',
    visualScale: 1.27,
    verticalOffset: -8,
    sideScale: 1.1,
  ),
  _CountryShowcase(
    label: 'Ungarn',
    assetPath: '$_countryAssetBase/hungary_showcase.png',
    visualScale: 1.08,
  ),
  _CountryShowcase(
    label: 'Slowenien',
    assetPath: '$_countryAssetBase/slovenia_showcase.png',
    visualScale: 1.03,
  ),
  _CountryShowcase(
    label: 'Kroatien',
    assetPath: '$_countryAssetBase/croatia_showcase.png',
    visualScale: 1.0,
  ),
  _CountryShowcase(
    label: 'Bosnien & Herzegowina',
    assetPath: '$_countryAssetBase/bosnia_and_herzegovina_showcase.png',
    visualScale: 1.03,
  ),
  _CountryShowcase(
    label: 'Serbien',
    assetPath: '$_countryAssetBase/serbia_showcase.png',
    visualScale: 0.98,
  ),
  _CountryShowcase(
    label: 'Montenegro',
    assetPath: '$_countryAssetBase/montenegro_showcase.png',
    visualScale: 1.03,
  ),
  _CountryShowcase(
    label: 'Kosovo',
    assetPath: '$_countryAssetBase/kosovo_showcase.png',
    visualScale: 1.0,
  ),
  _CountryShowcase(
    label: 'Albanien',
    assetPath: '$_countryAssetBase/albania_showcase.png',
    visualScale: 0.94,
    verticalOffset: 3,
  ),
  _CountryShowcase(
    label: 'Nordmazedonien',
    assetPath: '$_countryAssetBase/north_macedonia_showcase.png',
    visualScale: 1.06,
  ),
  _CountryShowcase(
    label: 'Griechenland',
    assetPath: '$_countryAssetBase/greece_showcase.png',
    visualScale: 1.04,
  ),
  _CountryShowcase(
    label: 'Bulgarien',
    assetPath: '$_countryAssetBase/bulgaria_showcase.png',
    visualScale: 1.07,
  ),
  _CountryShowcase(
    label: 'Rumänien',
    assetPath: '$_countryAssetBase/romania_showcase.png',
    visualScale: 1.07,
  ),
  _CountryShowcase(
    label: 'Moldau',
    assetPath: '$_countryAssetBase/moldova_showcase.png',
    visualScale: 1.02,
  ),
  _CountryShowcase(
    label: 'Ukraine',
    assetPath: '$_countryAssetBase/ukraine_showcase.png',
    visualScale: 1.18,
    verticalOffset: -5,
    sideScale: 1.08,
  ),
  _CountryShowcase(
    label: 'Belarus',
    assetPath: '$_countryAssetBase/belarus_showcase.png',
    visualScale: 1.03,
  ),
  _CountryShowcase(
    label: 'Litauen',
    assetPath: '$_countryAssetBase/lithuania_showcase.png',
    visualScale: 1.11,
    verticalOffset: -4,
  ),
  _CountryShowcase(
    label: 'Lettland',
    assetPath: '$_countryAssetBase/latvia_showcase.png',
    visualScale: 1.2,
    verticalOffset: -6,
    sideScale: 1.09,
  ),
  _CountryShowcase(
    label: 'Estland',
    assetPath: '$_countryAssetBase/estonia_showcase.png',
    visualScale: 1.05,
  ),
  _CountryShowcase(
    label: 'Russland',
    assetPath: '$_countryAssetBase/russia_showcase.png',
    visualScale: 0.99,
  ),
  _CountryShowcase(
    label: 'Türkei',
    assetPath: '$_countryAssetBase/turkey_showcase.png',
    visualScale: 1.16,
    verticalOffset: -5,
    sideScale: 1.08,
  ),
  _CountryShowcase(
    label: 'Zypern',
    assetPath: '$_countryAssetBase/cyprus_showcase.png',
    visualScale: 1.07,
  ),
  _CountryShowcase(
    label: 'Malta',
    assetPath: '$_countryAssetBase/malta_showcase.png',
    visualScale: 1.04,
  ),
  _CountryShowcase(
    label: 'San Marino',
    assetPath: '$_countryAssetBase/san_marino_showcase.png',
    visualScale: 0.94,
    verticalOffset: 5,
    sideScale: 0.95,
  ),
  _CountryShowcase(
    label: 'Vatikanstadt',
    assetPath: '$_countryAssetBase/vatican_city_showcase.png',
    visualScale: 1.05,
  ),
  _CountryShowcase(
    label: 'Monaco',
    assetPath: '$_countryAssetBase/monaco_showcase.png',
    visualScale: 1.08,
  ),
  _CountryShowcase(
    label: 'Andorra',
    assetPath: '$_countryAssetBase/andorra_showcase.png',
    visualScale: 1.03,
  ),
  _CountryShowcase(
    label: 'Georgien',
    assetPath: '$_countryAssetBase/georgia_showcase.png',
    visualScale: 1.05,
  ),
  _CountryShowcase(
    label: 'Armenien',
    assetPath: '$_countryAssetBase/armenia_showcase.png',
    visualScale: 0.99,
  ),
  _CountryShowcase(
    label: 'Aserbaidschan',
    assetPath: '$_countryAssetBase/azerbaijan_showcase.png',
    visualScale: 0.98,
  ),
];

const _italyCities = <_ItalyCityHotspot>[
  _ItalyCityHotspot(
    label: 'Rom',
    role: 'Herz der Reise',
    position: Offset(0.54, 0.51),
    kind: _CityBeaconKind.hub,
    labelPlacement: _CityLabelPlacement.aboveRight,
    labelOffset: Offset(4, -2),
  ),
  _ItalyCityHotspot(
    label: 'Florenz',
    role: 'Erste Stadtreise',
    position: Offset(0.43, 0.40),
    kind: _CityBeaconKind.culture,
    labelPlacement: _CityLabelPlacement.belowLeft,
    labelOffset: Offset(0, 0),
    available: true,
  ),
  _ItalyCityHotspot(
    label: 'Venedig',
    role: 'Wasserwege später',
    position: Offset(0.64, 0.24),
    kind: _CityBeaconKind.water,
    labelPlacement: _CityLabelPlacement.right,
    labelOffset: Offset(0, -4),
  ),
  _ItalyCityHotspot(
    label: 'Mailand',
    role: 'Nord-Hub später',
    position: Offset(0.34, 0.18),
    kind: _CityBeaconKind.tower,
    labelPlacement: _CityLabelPlacement.aboveRight,
    labelOffset: Offset(0, 0),
  ),
  _ItalyCityHotspot(
    label: 'Neapel',
    role: 'Küste und Vulkan später',
    position: Offset(0.66, 0.64),
    kind: _CityBeaconKind.volcano,
    labelPlacement: _CityLabelPlacement.aboveLeft,
    labelOffset: Offset(0, 0),
  ),
  _ItalyCityHotspot(
    label: 'Bologna',
    role: 'Wegekreuz später',
    position: Offset(0.49, 0.33),
    kind: _CityBeaconKind.city,
    labelPlacement: _CityLabelPlacement.belowRight,
    labelOffset: Offset(0, 0),
  ),
  _ItalyCityHotspot(
    label: 'Pisa',
    role: 'Landmarke später',
    position: Offset(0.35, 0.41),
    kind: _CityBeaconKind.culture,
    labelPlacement: _CityLabelPlacement.left,
    labelOffset: Offset(0, 0),
  ),
  _ItalyCityHotspot(
    label: 'Verona',
    role: 'Nordost-Station später',
    position: Offset(0.52, 0.24),
    kind: _CityBeaconKind.tower,
    labelPlacement: _CityLabelPlacement.aboveLeft,
    labelOffset: Offset(0, -2),
  ),
  _ItalyCityHotspot(
    label: 'Genua',
    role: 'Nordwest-Küste später',
    position: Offset(0.30, 0.31),
    kind: _CityBeaconKind.coast,
    labelPlacement: _CityLabelPlacement.aboveLeft,
    labelOffset: Offset(0, 0),
  ),
  _ItalyCityHotspot(
    label: 'Bari',
    role: 'Adria-Südost später',
    position: Offset(0.82, 0.61),
    kind: _CityBeaconKind.coast,
    labelPlacement: _CityLabelPlacement.belowRight,
    labelOffset: Offset(-10, 0),
  ),
  _ItalyCityHotspot(
    label: 'Palermo',
    role: 'Sizilien-West später',
    position: Offset(0.42, 0.82),
    kind: _CityBeaconKind.coast,
    labelPlacement: _CityLabelPlacement.below,
    labelOffset: Offset(-10, 0),
  ),
  _ItalyCityHotspot(
    label: 'Catania',
    role: 'Sizilien-Ost später',
    position: Offset(0.54, 0.85),
    kind: _CityBeaconKind.volcano,
    labelPlacement: _CityLabelPlacement.below,
    labelOffset: Offset(10, -2),
  ),
  _ItalyCityHotspot(
    label: 'Cagliari',
    role: 'Sardinien später',
    position: Offset(0.20, 0.66),
    kind: _CityBeaconKind.coast,
    labelPlacement: _CityLabelPlacement.right,
    labelOffset: Offset(0, 0),
  ),
];
