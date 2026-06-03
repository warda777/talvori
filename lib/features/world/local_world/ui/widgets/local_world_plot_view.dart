import 'dart:math' as math;

import 'package:flutter/material.dart';

class LocalWorldPlotView extends StatelessWidget {
  const LocalWorldPlotView({
    super.key,
    required this.controller,
    required this.selectedStarterIslandId,
    required this.onStarterIslandTap,
    required this.onCanvasMetricsChanged,
  });

  static const worldAssetPath = 'assets/images/world/origin_grove_island.png';

  final TransformationController controller;
  final String? selectedStarterIslandId;
  final ValueChanged<LocalWorldStarterIsland> onStarterIslandTap;
  final ValueChanged<LocalWorldCanvasMetrics> onCanvasMetricsChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      key: const Key('local-world-plot'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return InteractiveViewer(
            key: const Key('local-world-interactive-viewer'),
            transformationController: controller,
            boundaryMargin: const EdgeInsets.all(1600),
            constrained: false,
            minScale: 0.24,
            maxScale: 2.8,
            panEnabled: true,
            scaleEnabled: true,
            child: _AssetWorldCanvas(
              viewportSize: Size(constraints.maxWidth, constraints.maxHeight),
              selectedStarterIslandId: selectedStarterIslandId,
              onStarterIslandTap: onStarterIslandTap,
              onCanvasMetricsChanged: onCanvasMetricsChanged,
            ),
          );
        },
      ),
    );
  }
}

class _AssetWorldCanvas extends StatelessWidget {
  const _AssetWorldCanvas({
    required this.viewportSize,
    required this.selectedStarterIslandId,
    required this.onStarterIslandTap,
    required this.onCanvasMetricsChanged,
  });

  final Size viewportSize;
  final String? selectedStarterIslandId;
  final ValueChanged<LocalWorldStarterIsland> onStarterIslandTap;
  final ValueChanged<LocalWorldCanvasMetrics> onCanvasMetricsChanged;

  static const _starterIslands = [
    LocalWorldStarterIsland(
      id: 'forest-clearing',
      displayName: 'Waldlichtung',
      biome: 'Waldlichtung',
      shortDescription:
          'Eine ruhige, gruene Lichtung mit Platz fuer deinen ersten Aufbau.',
      assetPath: 'assets/images/world/starter_island_forest_clearing.png',
      centerX: 0.24,
      centerY: 0.3,
      widthFactor: 0.14,
      accent: Color(0xFF9FF7D5),
    ),
    LocalWorldStarterIsland(
      id: 'field',
      displayName: 'Ackerfeld',
      biome: 'Wiesen- und Feldinsel',
      shortDescription:
          'Eine offene Startinsel mit viel freier Flaeche und ruhiger Natur.',
      assetPath: 'assets/images/world/starter_island_field.png',
      centerX: 0.76,
      centerY: 0.3,
      widthFactor: 0.13,
      accent: Color(0xFFFFD980),
    ),
    LocalWorldStarterIsland(
      id: 'rock',
      displayName: 'Felseninsel',
      biome: 'Felsplateau',
      shortDescription:
          'Eine robuste, kantige Insel fuer einen etwas wilderen Start.',
      assetPath: 'assets/images/world/starter_island_rock.png',
      centerX: 0.25,
      centerY: 0.76,
      widthFactor: 0.13,
      accent: Color(0xFFB9C5D6),
    ),
    LocalWorldStarterIsland(
      id: 'desert',
      displayName: 'Wuesteninsel',
      biome: 'Sand und warme Erde',
      shortDescription:
          'Eine warme, offene Insel mit klaren Flaechen und wenigen Pflanzen.',
      assetPath: 'assets/images/world/starter_island_desert.png',
      centerX: 0.76,
      centerY: 0.75,
      widthFactor: 0.13,
      accent: Color(0xFFFFB86B),
    ),
    LocalWorldStarterIsland(
      id: 'snow-grove',
      displayName: 'Schneehain',
      biome: 'Winterhain',
      shortDescription:
          'Eine klare, stille Schneeinsel mit friedlicher Starter-Stimmung.',
      assetPath: 'assets/images/world/starter_island_snow_grove.png',
      centerX: 0.5,
      centerY: 0.19,
      widthFactor: 0.12,
      accent: Color(0xFFBDEBFF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final landscape = viewportSize.width > viewportSize.height;
    final worldWidth = math.max(
      viewportSize.width * (landscape ? 3.25 : 4.0),
      landscape ? 2600.0 : 2600.0,
    );
    final worldHeight = math.max(
      viewportSize.height * (landscape ? 3.05 : 3.6),
      landscape ? 1900.0 : 3600.0,
    );
    final metrics = LocalWorldCanvasMetrics(
      size: Size(worldWidth, worldHeight),
      showcaseCenter: Offset(worldWidth * 0.5, worldHeight * 0.54),
      starterCenters: {
        for (final island in _starterIslands)
          island.id: Offset(
            worldWidth * island.centerX,
            worldHeight * island.centerY,
          ),
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onCanvasMetricsChanged(metrics);
    });

    return SizedBox(
      width: worldWidth,
      height: worldHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _ShowcaseIsland(
            center: metrics.showcaseCenter,
            size: math.min(
              worldWidth * (landscape ? 0.36 : 0.42),
              worldHeight * (landscape ? 0.52 : 0.32),
            ),
          ),
          for (final island in _starterIslands)
            _StarterIslandObject(
              island: island,
              worldSize: metrics.size,
              selected: selectedStarterIslandId == island.id,
              onTap: () => onStarterIslandTap(island),
            ),
        ],
      ),
    );
  }
}

class _ShowcaseIsland extends StatelessWidget {
  const _ShowcaseIsland({required this.center, required this.size});

  final Offset center;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Image.asset(
              LocalWorldPlotView.worldAssetPath,
              key: const Key('local-world-diorama-image'),
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: _HotspotLayer(
              onTap: (title, body) => _showWorldInfo(context, title, body),
            ),
          ),
        ],
      ),
    );
  }

  void _showWorldInfo(BuildContext context, String title, String body) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title · $body'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF07101A),
      ),
    );
  }
}

class _StarterIslandObject extends StatelessWidget {
  const _StarterIslandObject({
    required this.island,
    required this.worldSize,
    required this.selected,
    required this.onTap,
  });

  final LocalWorldStarterIsland island;
  final Size worldSize;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = worldSize.width * island.widthFactor;
    final height = width * 0.78;
    final center = Offset(
      worldSize.width * island.centerX,
      worldSize.height * island.centerY,
    );

    return Positioned(
      left: center.dx - width / 2,
      top: center.dy - height / 2,
      width: width,
      height: height + 44,
      child: Semantics(
        label: island.displayName,
        button: true,
        child: GestureDetector(
          key: Key('local-world-starter-island-${island.id}'),
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (selected)
                Positioned(
                  top: height * 0.12,
                  width: width * 0.72,
                  height: height * 0.62,
                  child: IgnorePointer(
                    child: _SelectedIslandRing(accent: island.accent),
                  ),
                ),
              Positioned(
                top: 0,
                width: width,
                height: height,
                child: Image.asset(
                  island.assetPath,
                  key: Key('local-world-starter-island-image-${island.id}'),
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
              if (selected)
                Positioned(
                  top: 8,
                  right: width * 0.16,
                  child: _OwnershipBadge(accent: island.accent),
                ),
              Positioned(
                bottom: 0,
                child: _StarterIslandLabel(
                  name: island.displayName,
                  selected: selected,
                  accent: island.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedIslandRing extends StatelessWidget {
  const _SelectedIslandRing({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.7), width: 1.5),
      ),
    );
  }
}

class _OwnershipBadge extends StatelessWidget {
  const _OwnershipBadge({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('local-world-selected-island-badge'),
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFF07101A).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.36), blurRadius: 20),
        ],
      ),
      child: Icon(Icons.flag_rounded, size: 18, color: accent),
    );
  }
}

class _StarterIslandLabel extends StatelessWidget {
  const _StarterIslandLabel({
    required this.name,
    required this.selected,
    required this.accent,
  });

  final String name;
  final bool selected;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF07101A).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accent.withValues(alpha: selected ? 0.68 : 0.34),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? Icons.flag_rounded : Icons.add_circle_outline_rounded,
            color: accent,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            selected ? '$name · Meine Insel' : '$name · frei',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _HotspotLayer extends StatelessWidget {
  const _HotspotLayer({required this.onTap});

  final void Function(String title, String body) onTap;

  static const _hotspots = [
    _WorldHotspot(
      key: Key('local-world-building-house'),
      label: 'Haus',
      body: 'Dein Startpunkt im Ursprungshain.',
      x: 0.28,
      y: 0.35,
      width: 0.18,
      height: 0.18,
      accent: Color(0xFF9FF7D5),
      icon: Icons.home_rounded,
      visibleMarker: true,
    ),
    _WorldHotspot(
      key: Key('local-world-building-market'),
      label: 'Markt',
      body: 'Rohmaterial aus Woertern und Importen.',
      x: 0.5,
      y: 0.34,
      width: 0.18,
      height: 0.15,
      accent: Color(0xFF5DDCFF),
      icon: Icons.storefront_rounded,
      visibleMarker: true,
    ),
    _WorldHotspot(
      key: Key('local-world-building-library'),
      label: 'Bibliothek',
      body: 'Wissen, Saetze und Satzfunken.',
      x: 0.72,
      y: 0.42,
      width: 0.2,
      height: 0.2,
      accent: Color(0xFFB36BFF),
      icon: Icons.local_library_rounded,
      visibleMarker: true,
    ),
    _WorldHotspot(
      key: Key('local-world-free-plot-west'),
      label: 'Freier Bauplatz',
      body: 'Ein spaeterer Platz fuer neue Weltobjekte.',
      x: 0.36,
      y: 0.56,
      width: 0.16,
      height: 0.12,
      accent: Color(0xFFFFD980),
      icon: Icons.add_rounded,
    ),
    _WorldHotspot(
      key: Key('local-world-free-plot-center'),
      label: 'Freier Bauplatz',
      body: 'Hier kann spaeter ein neues Gebaeude entstehen.',
      x: 0.58,
      y: 0.48,
      width: 0.15,
      height: 0.12,
      accent: Color(0xFFFFD980),
      icon: Icons.add_rounded,
    ),
    _WorldHotspot(
      key: Key('local-world-free-plot-south'),
      label: 'Freier Bauplatz',
      body: 'Eine freie Flaeche fuer spaetere Erweiterungen.',
      x: 0.62,
      y: 0.67,
      width: 0.16,
      height: 0.12,
      accent: Color(0xFFFFD980),
      icon: Icons.add_rounded,
    ),
    _WorldHotspot(
      key: Key('local-world-bridge-anchor-west'),
      label: 'Brueckenanker',
      body: 'Ein Anschluss fuer spaetere Nachbarlandschaften.',
      x: 0.14,
      y: 0.64,
      width: 0.12,
      height: 0.12,
      accent: Color(0xFF5DDCFF),
      icon: Icons.cable_rounded,
    ),
    _WorldHotspot(
      key: Key('local-world-bridge-anchor-east'),
      label: 'Brueckenanker',
      body: 'Ein Anschluss fuer spaetere Freunde oder Regionen.',
      x: 0.86,
      y: 0.62,
      width: 0.12,
      height: 0.12,
      accent: Color(0xFFB36BFF),
      icon: Icons.cable_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final hotspot in _hotspots)
          _PositionedHotspot(
            hotspot: hotspot,
            onTap: () => onTap(hotspot.label, hotspot.body),
          ),
      ],
    );
  }
}

class _PositionedHotspot extends StatelessWidget {
  const _PositionedHotspot({required this.hotspot, required this.onTap});

  final _WorldHotspot hotspot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
      child: FractionallySizedBox(
        alignment: Alignment(hotspot.x * 2 - 1, hotspot.y * 2 - 1),
        widthFactor: hotspot.width,
        heightFactor: hotspot.height,
        child: Semantics(
          label: hotspot.label,
          button: true,
          child: GestureDetector(
            key: hotspot.key,
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Center(child: _HotspotMarker(hotspot: hotspot)),
          ),
        ),
      ),
    );
  }
}

class _HotspotMarker extends StatelessWidget {
  const _HotspotMarker({required this.hotspot});

  final _WorldHotspot hotspot;

  @override
  Widget build(BuildContext context) {
    final markerSize = hotspot.visibleMarker ? 42.0 : 30.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: markerSize,
      height: markerSize,
      decoration: BoxDecoration(
        color: const Color(
          0xFF07101A,
        ).withValues(alpha: hotspot.visibleMarker ? 0.58 : 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: hotspot.accent.withValues(alpha: 0.42)),
        boxShadow: [
          BoxShadow(
            color: hotspot.accent.withValues(alpha: 0.18),
            blurRadius: hotspot.visibleMarker ? 20 : 12,
          ),
        ],
      ),
      child: Icon(
        hotspot.icon,
        color: hotspot.accent.withValues(
          alpha: hotspot.visibleMarker ? 0.9 : 0.7,
        ),
        size: hotspot.visibleMarker ? 20 : 16,
      ),
    );
  }
}

class _WorldHotspot {
  const _WorldHotspot({
    required this.key,
    required this.label,
    required this.body,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.accent,
    required this.icon,
    this.visibleMarker = false,
  });

  final Key key;
  final String label;
  final String body;
  final double x;
  final double y;
  final double width;
  final double height;
  final Color accent;
  final IconData icon;
  final bool visibleMarker;
}

class LocalWorldStarterIsland {
  const LocalWorldStarterIsland({
    required this.id,
    required this.displayName,
    required this.biome,
    required this.shortDescription,
    required this.assetPath,
    required this.centerX,
    required this.centerY,
    required this.widthFactor,
    required this.accent,
  });

  final String id;
  final String displayName;
  final String biome;
  final String shortDescription;
  final String assetPath;
  final double centerX;
  final double centerY;
  final double widthFactor;
  final Color accent;
}

class LocalWorldCanvasMetrics {
  const LocalWorldCanvasMetrics({
    required this.size,
    required this.showcaseCenter,
    required this.starterCenters,
  });

  final Size size;
  final Offset showcaseCenter;
  final Map<String, Offset> starterCenters;
}
