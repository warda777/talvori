import 'dart:math' as math;

import 'package:flutter/material.dart';

class LocalWorldPlotView extends StatelessWidget {
  const LocalWorldPlotView({super.key, required this.controller});

  static const worldAssetPath = 'assets/images/world/origin_grove_island.png';

  final TransformationController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      key: const Key('local-world-plot'),
      child: InteractiveViewer(
        key: const Key('local-world-interactive-viewer'),
        transformationController: controller,
        boundaryMargin: const EdgeInsets.all(360),
        minScale: 0.72,
        maxScale: 2.4,
        panEnabled: true,
        scaleEnabled: true,
        child: const _AssetWorldCanvas(),
      ),
    );
  }
}

class _AssetWorldCanvas extends StatelessWidget {
  const _AssetWorldCanvas();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final landscape = constraints.maxWidth > constraints.maxHeight;
        final worldWidth = math.max(
          constraints.maxWidth * (landscape ? 1.45 : 1.85),
          landscape ? 1180.0 : 980.0,
        );
        final worldHeight = math.max(
          constraints.maxHeight * (landscape ? 1.35 : 1.45),
          landscape ? 820.0 : 1180.0,
        );

        return SizedBox(
          width: worldWidth,
          height: worldHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Center(
                  child: SizedBox(
                    width: worldWidth * (landscape ? 0.82 : 0.9),
                    height: worldHeight * (landscape ? 0.98 : 0.94),
                    child: Image.asset(
                      LocalWorldPlotView.worldAssetPath,
                      key: const Key('local-world-diorama-image'),
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
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
      },
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
