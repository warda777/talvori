import 'dart:math' as math;

import 'package:flutter/material.dart';

const _worldLayoutCenter = Offset(0.5, 0.5);
const _worldHorizontalCompression = 0.78;
const _worldVerticalCompression = 0.74;
const _showDockingDebug = false;

double _compactWorldX(double x) {
  return _worldLayoutCenter.dx +
      (x - _worldLayoutCenter.dx) * _worldHorizontalCompression;
}

double _compactWorldY(double y) {
  return _worldLayoutCenter.dy +
      (y - _worldLayoutCenter.dy) * _worldVerticalCompression;
}

class LocalWorldPlotView extends StatelessWidget {
  const LocalWorldPlotView({
    super.key,
    required this.controller,
    required this.selectedStarterIslandId,
    required this.forestClearingBuildState,
    required this.activeBuildFeedbackId,
    required this.showForestClearingBuildGuidance,
    required this.onStarterIslandTap,
    required this.onForestClearingBuildAreaTap,
    required this.onCommunityRegionTap,
    required this.onCanvasMetricsChanged,
  });

  static const worldAssetPath = 'assets/images/world/origin_grove_island.png';

  final TransformationController controller;
  final String? selectedStarterIslandId;
  final LocalWorldForestClearingBuildState forestClearingBuildState;
  final String? activeBuildFeedbackId;
  final bool showForestClearingBuildGuidance;
  final ValueChanged<LocalWorldMapObject> onStarterIslandTap;
  final VoidCallback onForestClearingBuildAreaTap;
  final ValueChanged<LocalWorldMapObject> onCommunityRegionTap;
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
            boundaryMargin: const EdgeInsets.all(12000),
            constrained: false,
            minScale: 0.055,
            maxScale: 2.8,
            panEnabled: true,
            scaleEnabled: true,
            child: _AssetWorldCanvas(
              viewportSize: Size(constraints.maxWidth, constraints.maxHeight),
              selectedStarterIslandId: selectedStarterIslandId,
              forestClearingBuildState: forestClearingBuildState,
              activeBuildFeedbackId: activeBuildFeedbackId,
              showForestClearingBuildGuidance: showForestClearingBuildGuidance,
              onStarterIslandTap: onStarterIslandTap,
              onForestClearingBuildAreaTap: onForestClearingBuildAreaTap,
              onCommunityRegionTap: onCommunityRegionTap,
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
    required this.forestClearingBuildState,
    required this.activeBuildFeedbackId,
    required this.showForestClearingBuildGuidance,
    required this.onStarterIslandTap,
    required this.onForestClearingBuildAreaTap,
    required this.onCommunityRegionTap,
    required this.onCanvasMetricsChanged,
  });

  final Size viewportSize;
  final String? selectedStarterIslandId;
  final LocalWorldForestClearingBuildState forestClearingBuildState;
  final String? activeBuildFeedbackId;
  final bool showForestClearingBuildGuidance;
  final ValueChanged<LocalWorldMapObject> onStarterIslandTap;
  final VoidCallback onForestClearingBuildAreaTap;
  final ValueChanged<LocalWorldMapObject> onCommunityRegionTap;
  final ValueChanged<LocalWorldCanvasMetrics> onCanvasMetricsChanged;

  static const _starterIslands = [
    LocalWorldMapObject(
      id: 'forest-clearing',
      displayName: 'Waldlichtung',
      type: LocalWorldObjectType.starter,
      biome: 'Waldlichtung',
      shortDescription:
          'Eine ruhige, gruene Lichtung mit Platz fuer deinen ersten Aufbau.',
      assetPath: 'assets/images/world/starter_island_forest_clearing.png',
      centerX: 0.31,
      centerY: 0.35,
      widthFactor: 0.05,
      accent: Color(0xFF9FF7D5),
    ),
    LocalWorldMapObject(
      id: 'field',
      displayName: 'Ackerfeld',
      type: LocalWorldObjectType.starter,
      biome: 'Wiesen- und Feldinsel',
      shortDescription:
          'Eine offene Startinsel mit viel freier Flaeche und ruhiger Natur.',
      assetPath: 'assets/images/world/starter_island_field.png',
      centerX: 0.49,
      centerY: 0.34,
      widthFactor: 0.048,
      accent: Color(0xFFFFD980),
    ),
    LocalWorldMapObject(
      id: 'rock',
      displayName: 'Felseninsel',
      type: LocalWorldObjectType.starter,
      biome: 'Felsplateau',
      shortDescription:
          'Eine robuste, kantige Insel fuer einen etwas wilderen Start.',
      assetPath: 'assets/images/world/starter_island_rock.png',
      centerX: 0.7,
      centerY: 0.31,
      widthFactor: 0.047,
      accent: Color(0xFFB9C5D6),
    ),
    LocalWorldMapObject(
      id: 'desert',
      displayName: 'Wuesteninsel',
      type: LocalWorldObjectType.starter,
      biome: 'Sand und warme Erde',
      shortDescription:
          'Eine warme, offene Insel mit klaren Flaechen und wenigen Pflanzen.',
      assetPath: 'assets/images/world/starter_island_desert.png',
      centerX: 0.88,
      centerY: 0.39,
      widthFactor: 0.049,
      accent: Color(0xFFFFB86B),
    ),
    LocalWorldMapObject(
      id: 'snow-grove',
      displayName: 'Schneehain',
      type: LocalWorldObjectType.starter,
      biome: 'Winterhain',
      shortDescription:
          'Eine klare, stille Schneeinsel mit friedlicher Starter-Stimmung.',
      assetPath: 'assets/images/world/starter_island_snow_grove.png',
      centerX: 0.18,
      centerY: 0.25,
      widthFactor: 0.045,
      accent: Color(0xFFBDEBFF),
    ),
    LocalWorldMapObject(
      id: 'ash-hill',
      displayName: 'Aschekuppe',
      type: LocalWorldObjectType.starter,
      biome: 'Asche und dunkle Erde',
      shortDescription:
          'Eine seltene, steinige Startinsel mit ruhiger Vulkanstimmung.',
      assetPath: 'assets/images/world/starter_island_ash_hill.png',
      centerX: 0.56,
      centerY: 0.55,
      widthFactor: 0.047,
      accent: Color(0xFFE5A56E),
    ),
    LocalWorldMapObject(
      id: 'autumn-grove',
      displayName: 'Herbsthain',
      type: LocalWorldObjectType.starter,
      biome: 'Herbstwald',
      shortDescription:
          'Eine warme, goldene Naturinsel mit Platz fuer einen gemuetlichen Start.',
      assetPath: 'assets/images/world/starter_island_autumn_grove.png',
      centerX: 0.33,
      centerY: 0.6,
      widthFactor: 0.049,
      accent: Color(0xFFFFB06B),
    ),
    LocalWorldMapObject(
      id: 'crystal-grove',
      displayName: 'Kristallhain',
      type: LocalWorldObjectType.starter,
      biome: 'Kristallnatur',
      shortDescription:
          'Eine geheimnisvolle Insel mit cyan-lila Kristallen und freier Flaeche.',
      assetPath: 'assets/images/world/starter_island_crystal_grove.png',
      centerX: 0.66,
      centerY: 0.53,
      widthFactor: 0.047,
      accent: Color(0xFFB36BFF),
    ),
    LocalWorldMapObject(
      id: 'flower-meadow',
      displayName: 'Bluetenwiese',
      type: LocalWorldObjectType.starter,
      biome: 'Blumenwiese',
      shortDescription:
          'Eine helle, freundliche Startinsel mit weichem Gras und Blueten.',
      assetPath: 'assets/images/world/starter_island_flower_meadow.png',
      centerX: 0.5,
      centerY: 0.68,
      widthFactor: 0.048,
      accent: Color(0xFFFFA8D8),
    ),
    LocalWorldMapObject(
      id: 'gorge',
      displayName: 'Schluchtinsel',
      type: LocalWorldObjectType.starter,
      biome: 'Schlucht und Plateaus',
      shortDescription:
          'Eine abenteuerliche Insel mit Hoehenstruktur und freien Bauplaetzen.',
      assetPath: 'assets/images/world/starter_island_gorge.png',
      centerX: 0.22,
      centerY: 0.58,
      widthFactor: 0.046,
      accent: Color(0xFFD5B48A),
    ),
    LocalWorldMapObject(
      id: 'lagoon',
      displayName: 'Laguneninsel',
      type: LocalWorldObjectType.starter,
      biome: 'Lagune',
      shortDescription:
          'Eine frische, wassernahe Insel mit tropischer Starter-Stimmung.',
      assetPath: 'assets/images/world/starter_island_lagoon.png',
      centerX: 0.74,
      centerY: 0.62,
      widthFactor: 0.046,
      accent: Color(0xFF5DDCFF),
    ),
    LocalWorldMapObject(
      id: 'lava-ridge',
      displayName: 'Lavakamm',
      type: LocalWorldObjectType.starter,
      biome: 'Erkaltete Lava',
      shortDescription: 'Eine rauere, markante Insel mit warmen Glutakzenten.',
      assetPath: 'assets/images/world/starter_island_lava_ridge.png',
      centerX: 0.92,
      centerY: 0.51,
      widthFactor: 0.046,
      accent: Color(0xFFFF8B5D),
    ),
    LocalWorldMapObject(
      id: 'misty-moor',
      displayName: 'Nebelmoor',
      type: LocalWorldObjectType.starter,
      biome: 'Moorlandschaft',
      shortDescription:
          'Eine mystische, feuchte Insel mit ruhigen Wasserstellen.',
      assetPath: 'assets/images/world/starter_island_misty_moor.png',
      centerX: 0.12,
      centerY: 0.53,
      widthFactor: 0.046,
      accent: Color(0xFF8ADACD),
    ),
    LocalWorldMapObject(
      id: 'moonlit-heath',
      displayName: 'Mondlichtheide',
      type: LocalWorldObjectType.starter,
      biome: 'Verzauberte Heide',
      shortDescription:
          'Eine stille, poetische Insel mit sanfter Mondlicht-Stimmung.',
      assetPath: 'assets/images/world/starter_island_moonlit_heath.png',
      centerX: 0.39,
      centerY: 0.27,
      widthFactor: 0.045,
      accent: Color(0xFFCFD7FF),
    ),
    LocalWorldMapObject(
      id: 'moss-plateau',
      displayName: 'Moosplateau',
      type: LocalWorldObjectType.starter,
      biome: 'Moos und alte Natur',
      shortDescription:
          'Eine weiche, gruene Insel mit uriger und verwachsener Stimmung.',
      assetPath: 'assets/images/world/starter_island_moss_plateau.png',
      centerX: 0.54,
      centerY: 0.25,
      widthFactor: 0.046,
      accent: Color(0xFF8FECA9),
    ),
    LocalWorldMapObject(
      id: 'mushroom-grove',
      displayName: 'Pilzhain',
      type: LocalWorldObjectType.starter,
      biome: 'Pilzwald',
      shortDescription:
          'Eine maerchenhafte Naturinsel mit Moos und leuchtenden Pilzen.',
      assetPath: 'assets/images/world/starter_island_mushroom_grove.png',
      centerX: 0.61,
      centerY: 0.7,
      widthFactor: 0.045,
      accent: Color(0xFFDFA8FF),
    ),
    LocalWorldMapObject(
      id: 'ruin-plateau',
      displayName: 'Ruinenplateau',
      type: LocalWorldObjectType.starter,
      biome: 'Alte Ruinenspuren',
      shortDescription:
          'Eine geschichtstraechtige Insel, auf der Natur alte Steine zurueckerobert.',
      assetPath: 'assets/images/world/starter_island_ruin_plateau.png',
      centerX: 0.83,
      centerY: 0.58,
      widthFactor: 0.047,
      accent: Color(0xFFC6B092),
    ),
    LocalWorldMapObject(
      id: 'spring',
      displayName: 'Quelleninsel',
      type: LocalWorldObjectType.starter,
      biome: 'Quellen und Rinnsale',
      shortDescription:
          'Eine frische, lebendige Insel mit kleinen Quellen und gruenem Gras.',
      assetPath: 'assets/images/world/starter_island_spring.png',
      centerX: 0.58,
      centerY: 0.9,
      widthFactor: 0.045,
      accent: Color(0xFF9FF7D5),
    ),
    LocalWorldMapObject(
      id: 'thorn-steppe',
      displayName: 'Dornsteppe',
      type: LocalWorldObjectType.starter,
      biome: 'Trockene Steppe',
      shortDescription:
          'Eine wilde, robuste Insel mit Dornenpflanzen und freien Flaechen.',
      assetPath: 'assets/images/world/starter_island_thorn_steppe.png',
      centerX: 0.07,
      centerY: 0.36,
      widthFactor: 0.045,
      accent: Color(0xFFCFA26D),
    ),
    LocalWorldMapObject(
      id: 'wind-ridge',
      displayName: 'Windkamm',
      type: LocalWorldObjectType.starter,
      biome: 'Windiges Hochland',
      shortDescription:
          'Eine luftige Hochland-Insel mit klarer, rauer Starter-Stimmung.',
      assetPath: 'assets/images/world/starter_island_wind_ridge.png',
      centerX: 0.42,
      centerY: 0.86,
      widthFactor: 0.046,
      accent: Color(0xFFB9E8FF),
    ),
  ];

  static const _communityRegions = [
    LocalWorldMapObject(
      id: 'capital-hub-main',
      displayName: 'Zentralhub',
      type: LocalWorldObjectType.community,
      biome: 'Community-Region',
      shortDescription:
          'Das spaetere Herz der Talvori-Welt mit Plaetzen, Wegen und Landmarken.',
      assetPath: 'assets/images/world/community_region_capital_hub_main.png',
      centerX: 0.47,
      centerY: 0.16,
      widthFactor: 0.13,
      accent: Color(0xFFE7F7FF),
    ),
    LocalWorldMapObject(
      id: 'tropical-main',
      displayName: 'Tropen-Hauptinsel',
      type: LocalWorldObjectType.community,
      biome: 'Community-Region',
      shortDescription:
          'Eine grosse, paradiesische Region fuer spaetere gemeinsame Ausbauideen.',
      assetPath: 'assets/images/world/community_region_tropical_main.png',
      centerX: 0.15,
      centerY: 0.18,
      widthFactor: 0.12,
      accent: Color(0xFF5DDCFF),
    ),
    LocalWorldMapObject(
      id: 'water-archipelago',
      displayName: 'Wasserarchipel',
      type: LocalWorldObjectType.community,
      biome: 'Community-Region',
      shortDescription:
          'Eine grosse Wasserwelt fuer Erkundung und spaetere Verbindungen.',
      assetPath: 'assets/images/world/community_region_water_archipelago.png',
      centerX: 0.78,
      centerY: 0.18,
      widthFactor: 0.12,
      accent: Color(0xFF67F1FF),
    ),
    LocalWorldMapObject(
      id: 'alpine-village',
      displayName: 'Alpendorf-Region',
      type: LocalWorldObjectType.community,
      biome: 'Community-Region',
      shortDescription:
          'Eine grosse Bergdorf-Region mit Hoehen, Wasserfaellen und Wegen.',
      assetPath: 'assets/images/world/community_region_alpine_village.png',
      centerX: 0.28,
      centerY: 0.12,
      widthFactor: 0.108,
      accent: Color(0xFFBDEBFF),
    ),
    LocalWorldMapObject(
      id: 'tropical-bays-main',
      displayName: 'Buchten-Hauptinsel',
      type: LocalWorldObjectType.community,
      biome: 'Community-Region',
      shortDescription:
          'Eine weitlaeufige Kuestenregion mit vielen Buchten und Naturzonen.',
      assetPath: 'assets/images/world/community_region_tropical_bays_main.png',
      centerX: 0.63,
      centerY: 0.1,
      widthFactor: 0.108,
      accent: Color(0xFF8DFFE3),
    ),
    LocalWorldMapObject(
      id: 'mountain-highland',
      displayName: 'Hochlandregion',
      type: LocalWorldObjectType.community,
      biome: 'Community-Region',
      shortDescription:
          'Eine majestätische Hauptregion mit Klippen, Plateaus und Bergbaechen.',
      assetPath: 'assets/images/world/community_region_mountain_highland.png',
      centerX: 0.2,
      centerY: 0.42,
      widthFactor: 0.118,
      accent: Color(0xFFB9C5D6),
    ),
    LocalWorldMapObject(
      id: 'crystal-magic-main',
      displayName: 'Kristallregion',
      type: LocalWorldObjectType.community,
      biome: 'Community-Region',
      shortDescription:
          'Eine zentrale Magieregion mit Kristallen, Lichtungen und Energiezonen.',
      assetPath: 'assets/images/world/community_region_crystal_magic_main.png',
      centerX: 0.6,
      centerY: 0.39,
      widthFactor: 0.116,
      accent: Color(0xFFB36BFF),
    ),
    LocalWorldMapObject(
      id: 'desert-main',
      displayName: 'Wuesten-Hauptregion',
      type: LocalWorldObjectType.community,
      biome: 'Community-Region',
      shortDescription:
          'Eine grosse, warme Region mit Duenen, Oasen und freien Flaechen.',
      assetPath: 'assets/images/world/community_region_desert_main.png',
      centerX: 0.81,
      centerY: 0.45,
      widthFactor: 0.118,
      accent: Color(0xFFFFB86B),
    ),
    LocalWorldMapObject(
      id: 'forest-main',
      displayName: 'Wald-Community',
      type: LocalWorldObjectType.community,
      biome: 'Community-Region',
      shortDescription:
          'Eine grosse Naturregion mit Lichtungen, Pfaden und magischen alten Baeumen.',
      assetPath: 'assets/images/world/community_region_forest_main.png',
      centerX: 0.37,
      centerY: 0.74,
      widthFactor: 0.118,
      accent: Color(0xFF9FF7D5),
    ),
    LocalWorldMapObject(
      id: 'harbor-bridge',
      displayName: 'Hafen- und Brueckenregion',
      type: LocalWorldObjectType.community,
      biome: 'Community-Region',
      shortDescription:
          'Eine spaetere Hauptregion fuer Bruecken, Andockpunkte und Verbindungen.',
      assetPath: 'assets/images/world/community_region_harbor_bridge.png',
      centerX: 0.62,
      centerY: 0.78,
      widthFactor: 0.13,
      accent: Color(0xFF5DDCFF),
    ),
    LocalWorldMapObject(
      id: 'stadium-event',
      displayName: 'Event-Arena',
      type: LocalWorldObjectType.community,
      biome: 'Community-Region',
      shortDescription:
          'Ein spaeterer sozialer Event-Distrikt fuer gemeinsame Weltmomente.',
      assetPath: 'assets/images/world/community_region_stadium_event.png',
      centerX: 0.91,
      centerY: 0.68,
      widthFactor: 0.102,
      accent: Color(0xFFE7F7FF),
    ),
    LocalWorldMapObject(
      id: 'tower-landmark',
      displayName: 'Turm-Landmarke',
      type: LocalWorldObjectType.community,
      biome: 'Community-Region',
      shortDescription:
          'Eine ikonische Hauptregion mit hohem Talvori-Turm und offenen Plaetzen.',
      assetPath: 'assets/images/world/community_region_tower_landmark.png',
      centerX: 0.1,
      centerY: 0.73,
      widthFactor: 0.102,
      accent: Color(0xFFE7F7FF),
    ),
    LocalWorldMapObject(
      id: 'lagoon-main',
      displayName: 'Lagunenregion',
      type: LocalWorldObjectType.community,
      biome: 'Community-Region',
      shortDescription:
          'Eine offene Lagunenwelt mit Wasserarmen, Ufern und Ausbauzonen.',
      assetPath: 'assets/images/world/community_region_lagoon_main.png',
      centerX: 0.74,
      centerY: 0.86,
      widthFactor: 0.098,
      accent: Color(0xFF67F1FF),
    ),
    LocalWorldMapObject(
      id: 'tropical-coast',
      displayName: 'Tropische Kueste',
      type: LocalWorldObjectType.community,
      biome: 'Community-Region',
      shortDescription:
          'Eine helle Community-Kuestenregion mit Strand, Vegetation und Andockpunkten.',
      assetPath: 'assets/images/world/community_region_tropical_coast.png',
      centerX: 0.24,
      centerY: 0.88,
      widthFactor: 0.098,
      accent: Color(0xFF8DFFE3),
    ),
  ];

  static const _dockingPoints = [
    LocalWorldDockingPoint(
      id: 'showcase-west-bridge-anchor',
      islandId: 'showcase-origin-grove',
      localPosition: Offset(0.16, 0.62),
      direction: LocalWorldDockingDirection.west,
      type: LocalWorldDockingPointType.bridgeAnchor,
      supportedConnectorTypes: [
        LocalWorldConnectorType.short,
        LocalWorldConnectorType.medium,
        LocalWorldConnectorType.endCap,
      ],
      priority: 80,
    ),
    LocalWorldDockingPoint(
      id: 'showcase-east-bridge-anchor',
      islandId: 'showcase-origin-grove',
      localPosition: Offset(0.86, 0.62),
      direction: LocalWorldDockingDirection.east,
      type: LocalWorldDockingPointType.bridgeAnchor,
      supportedConnectorTypes: [
        LocalWorldConnectorType.short,
        LocalWorldConnectorType.medium,
        LocalWorldConnectorType.endCap,
      ],
      priority: 80,
    ),
    LocalWorldDockingPoint(
      id: 'forest-clearing-east-snap',
      islandId: 'forest-clearing',
      localPosition: Offset(0.82, 0.54),
      direction: LocalWorldDockingDirection.east,
      type: LocalWorldDockingPointType.hiddenSnapZone,
      supportedConnectorTypes: [
        LocalWorldConnectorType.short,
        LocalWorldConnectorType.endCap,
      ],
      priority: 60,
    ),
    LocalWorldDockingPoint(
      id: 'field-west-snap',
      islandId: 'field',
      localPosition: Offset(0.18, 0.55),
      direction: LocalWorldDockingDirection.west,
      type: LocalWorldDockingPointType.hiddenSnapZone,
      supportedConnectorTypes: [
        LocalWorldConnectorType.short,
        LocalWorldConnectorType.endCap,
      ],
      priority: 60,
    ),
    LocalWorldDockingPoint(
      id: 'field-east-platform',
      islandId: 'field',
      localPosition: Offset(0.82, 0.52),
      direction: LocalWorldDockingDirection.east,
      type: LocalWorldDockingPointType.platformAnchor,
      supportedConnectorTypes: [
        LocalWorldConnectorType.short,
        LocalWorldConnectorType.medium,
        LocalWorldConnectorType.smallPlatform,
      ],
      priority: 58,
    ),
    LocalWorldDockingPoint(
      id: 'rock-west-platform',
      islandId: 'rock',
      localPosition: Offset(0.18, 0.56),
      direction: LocalWorldDockingDirection.west,
      type: LocalWorldDockingPointType.platformAnchor,
      supportedConnectorTypes: [
        LocalWorldConnectorType.short,
        LocalWorldConnectorType.medium,
        LocalWorldConnectorType.smallPlatform,
      ],
      priority: 58,
    ),
    LocalWorldDockingPoint(
      id: 'capital-hub-south-platform',
      islandId: 'capital-hub-main',
      localPosition: Offset(0.5, 0.88),
      direction: LocalWorldDockingDirection.south,
      type: LocalWorldDockingPointType.platformAnchor,
      supportedConnectorTypes: [
        LocalWorldConnectorType.medium,
        LocalWorldConnectorType.long,
        LocalWorldConnectorType.smallPlatform,
      ],
      priority: 95,
    ),
    LocalWorldDockingPoint(
      id: 'capital-hub-west-bridge',
      islandId: 'capital-hub-main',
      localPosition: Offset(0.16, 0.56),
      direction: LocalWorldDockingDirection.west,
      type: LocalWorldDockingPointType.bridgeAnchor,
      supportedConnectorTypes: [
        LocalWorldConnectorType.short,
        LocalWorldConnectorType.medium,
        LocalWorldConnectorType.endCap,
      ],
      priority: 88,
    ),
    LocalWorldDockingPoint(
      id: 'alpine-village-east-bridge',
      islandId: 'alpine-village',
      localPosition: Offset(0.84, 0.6),
      direction: LocalWorldDockingDirection.east,
      type: LocalWorldDockingPointType.bridgeAnchor,
      supportedConnectorTypes: [
        LocalWorldConnectorType.short,
        LocalWorldConnectorType.medium,
        LocalWorldConnectorType.endCap,
      ],
      priority: 84,
    ),
    LocalWorldDockingPoint(
      id: 'harbor-bridge-north-platform',
      islandId: 'harbor-bridge',
      localPosition: Offset(0.48, 0.14),
      direction: LocalWorldDockingDirection.north,
      type: LocalWorldDockingPointType.platformAnchor,
      supportedConnectorTypes: [
        LocalWorldConnectorType.medium,
        LocalWorldConnectorType.long,
        LocalWorldConnectorType.smallPlatform,
      ],
      priority: 92,
    ),
    LocalWorldDockingPoint(
      id: 'harbor-bridge-west-bridge',
      islandId: 'harbor-bridge',
      localPosition: Offset(0.14, 0.58),
      direction: LocalWorldDockingDirection.west,
      type: LocalWorldDockingPointType.bridgeAnchor,
      supportedConnectorTypes: [
        LocalWorldConnectorType.medium,
        LocalWorldConnectorType.endCap,
      ],
      priority: 86,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final landscape = viewportSize.width > viewportSize.height;
    final worldWidth = math.max(
      viewportSize.width * (landscape ? 8.8 : 9.8),
      landscape ? 7800.0 : 8000.0,
    );
    final worldHeight = math.max(
      viewportSize.height * (landscape ? 7.2 : 7.8),
      landscape ? 6200.0 : 9200.0,
    );
    final showcaseSize = math.min(
      worldWidth * (landscape ? 0.086 : 0.088),
      worldHeight * (landscape ? 0.16 : 0.1),
    );
    final metrics = LocalWorldCanvasMetrics(
      size: Size(worldWidth, worldHeight),
      showcaseCenter: Offset(
        worldWidth * _compactWorldX(0.43),
        worldHeight * _compactWorldY(0.51),
      ),
      starterCenters: {
        for (final island in _starterIslands)
          island.id: Offset(
            worldWidth * _compactWorldX(island.centerX),
            worldHeight * _compactWorldY(island.centerY),
          ),
      },
      dockingPoints: _dockingPoints,
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
          for (final region in _communityRegions)
            _WorldMapObjectView(
              object: region,
              worldSize: metrics.size,
              selected: false,
              forestClearingBuildState: forestClearingBuildState,
              activeBuildFeedbackId: activeBuildFeedbackId,
              showForestClearingBuildGuidance: false,
              onForestClearingBuildAreaTap: onForestClearingBuildAreaTap,
              onTap: () => onCommunityRegionTap(region),
            ),
          _ShowcaseIsland(center: metrics.showcaseCenter, size: showcaseSize),
          for (final island in _starterIslands)
            _WorldMapObjectView(
              object: island,
              worldSize: metrics.size,
              selected: selectedStarterIslandId == island.id,
              forestClearingBuildState: forestClearingBuildState,
              activeBuildFeedbackId: activeBuildFeedbackId,
              showForestClearingBuildGuidance:
                  selectedStarterIslandId == island.id &&
                  island.id == 'forest-clearing' &&
                  showForestClearingBuildGuidance,
              onForestClearingBuildAreaTap: onForestClearingBuildAreaTap,
              onTap: () => onStarterIslandTap(island),
            ),
          if (_showDockingDebug)
            _DockingDebugLayer(
              worldSize: metrics.size,
              showcaseCenter: metrics.showcaseCenter,
              showcaseSize: showcaseSize,
              starters: _starterIslands,
              communities: _communityRegions,
              dockingPoints: _dockingPoints,
            ),
        ],
      ),
    );
  }
}

class _DockingDebugLayer extends StatelessWidget {
  const _DockingDebugLayer({
    required this.worldSize,
    required this.showcaseCenter,
    required this.showcaseSize,
    required this.starters,
    required this.communities,
    required this.dockingPoints,
  });

  final Size worldSize;
  final Offset showcaseCenter;
  final double showcaseSize;
  final List<LocalWorldMapObject> starters;
  final List<LocalWorldMapObject> communities;
  final List<LocalWorldDockingPoint> dockingPoints;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final dockingPoint in dockingPoints)
              if (_resolveDockingPointPosition(dockingPoint)
                  case final Offset position)
                Positioned(
                  left: position.dx - 5,
                  top: position.dy - 5,
                  width: 10,
                  height: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF62F7FF).withValues(alpha: 0.86),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF62F7FF).withValues(alpha: 0.5),
                          blurRadius: 12,
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

  Offset? _resolveDockingPointPosition(LocalWorldDockingPoint dockingPoint) {
    if (dockingPoint.islandId == 'showcase-origin-grove') {
      final left = showcaseCenter.dx - showcaseSize / 2;
      final top = showcaseCenter.dy - showcaseSize / 2;
      return Offset(
        left + showcaseSize * dockingPoint.localPosition.dx,
        top + showcaseSize * dockingPoint.localPosition.dy,
      );
    }

    LocalWorldMapObject? object;
    for (final candidate in [...starters, ...communities]) {
      if (candidate.id == dockingPoint.islandId) {
        object = candidate;
        break;
      }
    }
    if (object == null) {
      return null;
    }

    final width = worldSize.width * object.widthFactor;
    final height = width * 0.78;
    final center = Offset(
      worldSize.width * _compactWorldX(object.centerX),
      worldSize.height * _compactWorldY(object.centerY),
    );
    final left = center.dx - width / 2;
    final top = center.dy - height / 2;
    return Offset(
      left + width * dockingPoint.localPosition.dx,
      top + height * dockingPoint.localPosition.dy,
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

class _WorldMapObjectView extends StatelessWidget {
  const _WorldMapObjectView({
    required this.object,
    required this.worldSize,
    required this.selected,
    required this.forestClearingBuildState,
    required this.activeBuildFeedbackId,
    required this.showForestClearingBuildGuidance,
    required this.onForestClearingBuildAreaTap,
    required this.onTap,
  });

  final LocalWorldMapObject object;
  final Size worldSize;
  final bool selected;
  final LocalWorldForestClearingBuildState forestClearingBuildState;
  final String? activeBuildFeedbackId;
  final bool showForestClearingBuildGuidance;
  final VoidCallback onForestClearingBuildAreaTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = worldSize.width * object.widthFactor;
    final height = width * 0.78;
    final center = Offset(
      worldSize.width * _compactWorldX(object.centerX),
      worldSize.height * _compactWorldY(object.centerY),
    );
    final labelBottom = object.type == LocalWorldObjectType.community
        ? 2.0
        : 0.0;
    final buildableForestClearing =
        selected &&
        object.type == LocalWorldObjectType.starter &&
        object.id == 'forest-clearing';

    return Positioned(
      left: center.dx - width / 2,
      top: center.dy - height / 2,
      width: width,
      height: height + 48,
      child: Semantics(
        label: object.displayName,
        button: true,
        child: GestureDetector(
          key: Key('local-world-${object.type.keyName}-${object.id}'),
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0,
                width: width,
                height: height,
                child: buildableForestClearing
                    ? _BuildableForestClearingIsland(
                        buildState: forestClearingBuildState,
                        activeBuildFeedbackId: activeBuildFeedbackId,
                        showBuildGuidance: showForestClearingBuildGuidance,
                        imageKey: Key(
                          'local-world-${object.type.keyName}-image-${object.id}',
                        ),
                        onBuildAreaTap: onForestClearingBuildAreaTap,
                      )
                    : Image.asset(
                        object.assetPath,
                        key: Key(
                          'local-world-${object.type.keyName}-image-${object.id}',
                        ),
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
              ),
              if (selected)
                Positioned(
                  top: 8,
                  right: width * 0.16,
                  child: _OwnershipBadge(accent: object.accent),
                ),
              Positioned(
                bottom: labelBottom,
                child: _WorldMapObjectLabel(object: object, selected: selected),
              ),
            ],
          ),
        ),
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

class _BuildableForestClearingIsland extends StatelessWidget {
  const _BuildableForestClearingIsland({
    required this.buildState,
    required this.activeBuildFeedbackId,
    required this.showBuildGuidance,
    required this.imageKey,
    required this.onBuildAreaTap,
  });

  static const baseAssetPath =
      'assets/images/world/buildable_islands/forest_clearing/base.png';
  static const foundationStartedAssetPath =
      'assets/images/world/buildable_islands/forest_clearing/foundation_started.png';
  static const foundationCompleteAssetPath =
      'assets/images/world/buildable_islands/forest_clearing/foundation_complete.png';
  static const _assetAspectRatio = 1536 / 1024;
  static const _buildAreaAnchor = Offset(0.511, 0.508);
  static const _hitTestRadius = Size(0.18, 0.12);

  final LocalWorldForestClearingBuildState buildState;
  final String? activeBuildFeedbackId;
  final bool showBuildGuidance;
  final Key imageKey;
  final VoidCallback onBuildAreaTap;

  @override
  Widget build(BuildContext context) {
    final foundationStarted =
        buildState == LocalWorldForestClearingBuildState.foundationStarted;
    final foundationComplete =
        buildState == LocalWorldForestClearingBuildState.foundationComplete;
    final foundationVisible = foundationStarted || foundationComplete;
    final feedbackActive =
        activeBuildFeedbackId == LocalWorldBuildFeedbackIds.foundationStarted ||
        activeBuildFeedbackId == LocalWorldBuildFeedbackIds.foundationComplete;
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final guidanceActive = showBuildGuidance && !foundationVisible;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        final imageWidth = math.min(
          availableWidth,
          availableHeight * _assetAspectRatio,
        );
        final imageHeight = imageWidth / _assetAspectRatio;
        final imageLeft = (availableWidth - imageWidth) / 2;
        final imageTop = (availableHeight - imageHeight) / 2;
        final anchor = Offset(
          imageLeft + imageWidth * _buildAreaAnchor.dx,
          imageTop + imageHeight * _buildAreaAnchor.dy,
        );
        final radius = Size(
          imageWidth * _hitTestRadius.width,
          imageHeight * _hitTestRadius.height,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: imageLeft,
              top: imageTop,
              width: imageWidth,
              height: imageHeight,
              child: KeyedSubtree(
                key: const Key('local-world-buildable-forest-clearing-base'),
                child: Image.asset(
                  baseAssetPath,
                  key: imageKey,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ),
            if (foundationVisible)
              Positioned(
                left: imageLeft,
                top: imageTop,
                width: imageWidth,
                height: imageHeight,
                child: _ForestClearingFoundationOverlay(
                  buildState: buildState,
                  reducedMotion: reducedMotion,
                ),
              ),
            if (feedbackActive)
              Positioned(
                left: anchor.dx - radius.width * 0.95,
                top: anchor.dy - radius.height * 0.95,
                width: radius.width * 1.9,
                height: radius.height * 1.9,
                child: IgnorePointer(
                  child: _ForestClearingBuildFeedbackGlow(
                    reducedMotion: reducedMotion,
                  ),
                ),
              ),
            if (guidanceActive)
              Positioned(
                left: anchor.dx - radius.width * 0.96,
                top: anchor.dy - radius.height * 0.96,
                width: radius.width * 1.92,
                height: radius.height * 1.92,
                child: IgnorePointer(
                  child: _ForestClearingBuildGuidancePulse(
                    reducedMotion: reducedMotion,
                  ),
                ),
              ),
            Positioned(
              left: anchor.dx - radius.width,
              top: anchor.dy - radius.height,
              width: radius.width * 2,
              height: radius.height * 2,
              child: Semantics(
                label: foundationComplete
                    ? 'Fundament fertig'
                    : foundationStarted
                    ? 'Fundament fertigstellen'
                    : 'Fundament beginnen',
                button: true,
                child: GestureDetector(
                  key: const Key('local-world-forest-clearing-main-build-area'),
                  behavior: HitTestBehavior.opaque,
                  onTap: onBuildAreaTap,
                  child: foundationVisible
                      ? const SizedBox.expand()
                      : const Center(child: _ForestClearingBuildAreaHint()),
                ),
              ),
            ),
            if (foundationVisible)
              Positioned(
                left: anchor.dx - imageWidth * 0.12,
                top: anchor.dy + radius.height * 0.72,
                child: _ForestClearingBuildStatusPill(buildState: buildState),
              ),
            if (guidanceActive)
              Positioned(
                left: imageLeft + imageWidth * 0.14,
                right: availableWidth - imageLeft - imageWidth * 0.86,
                top: math.max(0, anchor.dy - radius.height * 2.75),
                child: const _ForestClearingBuildGuidanceLabel(),
              ),
          ],
        );
      },
    );
  }
}

class _ForestClearingBuildGuidancePulse extends StatelessWidget {
  const _ForestClearingBuildGuidancePulse({required this.reducedMotion});

  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: const Key('local-world-forest-clearing-build-guidance-pulse'),
      tween: Tween<double>(begin: 0, end: reducedMotion ? 0 : 1),
      duration: reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 950),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final pulse = (math.sin(value * math.pi * 2) + 1) / 2;
        return Opacity(
          opacity: reducedMotion ? 0.54 : 0.32 + pulse * 0.22,
          child: Transform.scale(
            scale: reducedMotion ? 1 : 0.96 + pulse * 0.06,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0C1026).withValues(alpha: 0.34),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: const Color(0xFF5DDCFF).withValues(alpha: 0.68),
            width: 2.6,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB36BFF).withValues(alpha: 0.46),
              blurRadius: 30,
            ),
            BoxShadow(
              color: const Color(0xFF5DDCFF).withValues(alpha: 0.24),
              blurRadius: 22,
            ),
            BoxShadow(
              color: const Color(0xFFFF5DEB).withValues(alpha: 0.28),
              blurRadius: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _ForestClearingBuildGuidanceLabel extends StatelessWidget {
  const _ForestClearingBuildGuidanceLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('local-world-forest-clearing-build-guidance-label'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF07101A).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF5DDCFF).withValues(alpha: 0.42),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB36BFF).withValues(alpha: 0.24),
            blurRadius: 16,
          ),
        ],
      ),
      child: const Text(
        'Tippe auf die Lichtung, um dein Fundament zu beginnen.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          height: 1.2,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _ForestClearingFoundationOverlay extends StatelessWidget {
  const _ForestClearingFoundationOverlay({
    required this.buildState,
    required this.reducedMotion,
  });

  final LocalWorldForestClearingBuildState buildState;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    final foundationComplete =
        buildState == LocalWorldForestClearingBuildState.foundationComplete;
    return TweenAnimationBuilder<double>(
      key: Key(
        foundationComplete
            ? 'local-world-buildable-forest-clearing-foundation-complete-animation'
            : 'local-world-buildable-forest-clearing-foundation-started-animation',
      ),
      tween: Tween<double>(begin: 0, end: 1),
      duration: reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final easedValue = value.clamp(0.0, 1.0).toDouble();
        return Opacity(
          opacity: easedValue,
          child: Transform.scale(
            scale: reducedMotion ? 1 : 0.96 + easedValue * 0.04,
            child: child,
          ),
        );
      },
      child: Image.asset(
        foundationComplete
            ? _BuildableForestClearingIsland.foundationCompleteAssetPath
            : _BuildableForestClearingIsland.foundationStartedAssetPath,
        key: Key(
          foundationComplete
              ? 'local-world-buildable-forest-clearing-foundation-complete'
              : 'local-world-buildable-forest-clearing-foundation-started',
        ),
        fit: BoxFit.contain,
        alignment: Alignment.center,
      ),
    );
  }
}

class _ForestClearingBuildFeedbackGlow extends StatelessWidget {
  const _ForestClearingBuildFeedbackGlow({required this.reducedMotion});

  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: const Key('local-world-forest-clearing-build-feedback-glow'),
      tween: Tween<double>(begin: 1, end: 0),
      duration: reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final fade = value.clamp(0.0, 1.0).toDouble();
        return Opacity(
          opacity: fade,
          child: Transform.scale(
            scale: reducedMotion ? 1 : 0.92 + (1 - fade) * 0.14,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFD980).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: const Color(0xFFFFD980).withValues(alpha: 0.24),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD980).withValues(alpha: 0.22),
              blurRadius: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _ForestClearingBuildAreaHint extends StatelessWidget {
  const _ForestClearingBuildAreaHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('local-world-forest-clearing-build-area-hint'),
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF07101A).withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF5DDCFF).withValues(alpha: 0.58),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB36BFF).withValues(alpha: 0.32),
            blurRadius: 22,
          ),
          BoxShadow(
            color: const Color(0xFFFF5DEB).withValues(alpha: 0.18),
            blurRadius: 14,
          ),
        ],
      ),
    );
  }
}

class _ForestClearingBuildStatusPill extends StatelessWidget {
  const _ForestClearingBuildStatusPill({required this.buildState});

  final LocalWorldForestClearingBuildState buildState;

  @override
  Widget build(BuildContext context) {
    final foundationComplete =
        buildState == LocalWorldForestClearingBuildState.foundationComplete;
    return Container(
      key: Key(
        foundationComplete
            ? 'local-world-forest-clearing-foundation-complete-label'
            : 'local-world-forest-clearing-foundation-started-label',
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF07101A).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFFFD980).withValues(alpha: 0.36),
        ),
      ),
      child: Text(
        foundationComplete ? 'Fundament fertig' : 'Fundament begonnen',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _WorldMapObjectLabel extends StatelessWidget {
  const _WorldMapObjectLabel({required this.object, required this.selected});

  final LocalWorldMapObject object;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final text = switch (object.type) {
      LocalWorldObjectType.starter =>
        selected
            ? '${object.displayName} · Meine Insel'
            : '${object.displayName} · frei',
      LocalWorldObjectType.community => object.displayName,
      LocalWorldObjectType.showcase => object.displayName,
    };
    final icon = switch (object.type) {
      LocalWorldObjectType.starter =>
        selected ? Icons.flag_rounded : Icons.add_circle_outline_rounded,
      LocalWorldObjectType.community => Icons.public_rounded,
      LocalWorldObjectType.showcase => Icons.auto_awesome_rounded,
    };
    final community = object.type == LocalWorldObjectType.community;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: community ? 9 : 11,
        vertical: community ? 6 : 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF07101A).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: object.accent.withValues(alpha: selected ? 0.68 : 0.34),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: object.accent, size: community ? 13 : 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: community ? 10 : 11,
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

enum LocalWorldObjectType {
  showcase('showcase'),
  starter('starter-island'),
  community('community-region');

  const LocalWorldObjectType(this.keyName);

  final String keyName;
}

class LocalWorldBuildFeedbackIds {
  const LocalWorldBuildFeedbackIds._();

  static const foundationStarted = 'build.foundation.started';
  static const foundationComplete = 'build.foundation.complete';
}

enum LocalWorldForestClearingBuildState {
  empty,
  foundationStarted,
  foundationComplete,
}

class LocalWorldMapObject {
  const LocalWorldMapObject({
    required this.id,
    required this.displayName,
    required this.type,
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
  final LocalWorldObjectType type;
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
    required this.dockingPoints,
  });

  final Size size;
  final Offset showcaseCenter;
  final Map<String, Offset> starterCenters;
  final List<LocalWorldDockingPoint> dockingPoints;
}

enum LocalWorldDockingDirection {
  north,
  south,
  east,
  west,
  northeast,
  northwest,
  southeast,
  southwest,
}

enum LocalWorldDockingPointType { bridgeAnchor, platformAnchor, hiddenSnapZone }

enum LocalWorldConnectorType {
  short,
  medium,
  long,
  cornerLeft,
  cornerRight,
  endCap,
  smallPlatform,
}

class LocalWorldDockingPoint {
  const LocalWorldDockingPoint({
    required this.id,
    required this.islandId,
    required this.localPosition,
    required this.direction,
    required this.type,
    required this.supportedConnectorTypes,
    required this.priority,
    this.isOccupied = false,
  });

  final String id;
  final String islandId;
  final Offset localPosition;
  final LocalWorldDockingDirection direction;
  final LocalWorldDockingPointType type;
  final bool isOccupied;
  final List<LocalWorldConnectorType> supportedConnectorTypes;
  final int priority;
}
