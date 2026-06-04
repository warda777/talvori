import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/local_world_plot_view.dart';
import '../widgets/local_world_resource_bar.dart';

const _localWorldSystemUiOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Color(0xFF02050A),
  systemNavigationBarIconBrightness: Brightness.light,
);

class LocalWorldScreen extends StatefulWidget {
  const LocalWorldScreen({super.key});

  static const _cyan = Color(0xFF5DDCFF);
  static const _violet = Color(0xFFB36BFF);
  static const _mint = Color(0xFF9FF7D5);

  @override
  State<LocalWorldScreen> createState() => _LocalWorldScreenState();
}

class _LocalWorldScreenState extends State<LocalWorldScreen> {
  late final TransformationController _worldTransformController;
  LocalWorldCanvasMetrics? _worldCanvasMetrics;
  LocalWorldMapObject? _selectedStarterIsland;
  LocalWorldForestClearingBuildState _forestClearingBuildState =
      LocalWorldForestClearingBuildState.empty;
  String? _activeBuildFeedbackId;
  Timer? _buildFeedbackTimer;
  bool _worldCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _worldTransformController = TransformationController();
  }

  @override
  void dispose() {
    _buildFeedbackTimer?.cancel();
    _worldTransformController.dispose();
    super.dispose();
  }

  void _focusMyPlot() {
    final selectedIsland = _selectedStarterIsland;
    if (selectedIsland == null) {
      _showWorldHint('Wähle zuerst deine Startinsel.');
      _focusWorldPoint(_worldCanvasMetrics?.showcaseCenter, scale: 0.72);
      return;
    }

    _focusWorldPoint(
      _worldCanvasMetrics?.starterCenters[selectedIsland.id],
      scale: 1.2,
    );
  }

  void _focusWorldPoint(Offset? worldPoint, {double scale = 1.05}) {
    if (worldPoint == null) return;
    final viewportSize = MediaQuery.sizeOf(context);
    final matrix = Matrix4.identity()
      ..translateByDouble(
        viewportSize.width / 2 - worldPoint.dx * scale,
        viewportSize.height / 2 - worldPoint.dy * scale,
        0,
        1,
      )
      ..scaleByDouble(scale, scale, 1, 1);
    _worldTransformController.value = matrix;
  }

  void _showWorldHint(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF07101A),
      ),
    );
  }

  void _triggerForestClearingBuildFeedback() {
    _buildFeedbackTimer?.cancel();
    _activeBuildFeedbackId = LocalWorldBuildFeedbackIds.foundationStarted;
    _buildFeedbackTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted ||
          _activeBuildFeedbackId !=
              LocalWorldBuildFeedbackIds.foundationStarted) {
        return;
      }
      setState(() {
        _activeBuildFeedbackId = null;
      });
    });
  }

  void _showStarterIslandSheet(LocalWorldMapObject island) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _StarterIslandBottomSheet(
          island: island,
          selected: _selectedStarterIsland?.id == island.id,
          onSelect: () {
            Navigator.of(context).pop();
            setState(() {
              _selectedStarterIsland = island;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _focusWorldPoint(
                _worldCanvasMetrics?.starterCenters[island.id],
                scale: 1.2,
              );
            });
          },
        );
      },
    );
  }

  void _handleForestClearingBuildAreaTap() {
    if (_selectedStarterIsland?.id != 'forest-clearing') return;

    if (_forestClearingBuildState ==
        LocalWorldForestClearingBuildState.foundationStarted) {
      _showWorldHint('Fundament begonnen');
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ForestClearingBuildBottomSheet(
          onBeginFoundation: () {
            Navigator.of(context).pop();
            setState(() {
              _forestClearingBuildState =
                  LocalWorldForestClearingBuildState.foundationStarted;
              _triggerForestClearingBuildFeedback();
            });
            _showWorldHint('Das Fundament hat begonnen.');
          },
        );
      },
    );
  }

  void _showCommunityRegionSheet(LocalWorldMapObject region) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _CommunityRegionBottomSheet(region: region);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _localWorldSystemUiOverlayStyle,
      child: Scaffold(
        key: const Key('local-world-screen'),
        backgroundColor: const Color(0xFF02050A),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _LocalWorldBackground(),
            LocalWorldPlotView(
              controller: _worldTransformController,
              selectedStarterIslandId: _selectedStarterIsland?.id,
              forestClearingBuildState: _forestClearingBuildState,
              activeBuildFeedbackId: _activeBuildFeedbackId,
              onStarterIslandTap: _showStarterIslandSheet,
              onForestClearingBuildAreaTap: _handleForestClearingBuildAreaTap,
              onCommunityRegionTap: _showCommunityRegionSheet,
              onCanvasMetricsChanged: (metrics) {
                _worldCanvasMetrics = metrics;
                if (!_worldCameraInitialized) {
                  _worldCameraInitialized = true;
                  _focusWorldPoint(metrics.showcaseCenter, scale: 0.72);
                }
              },
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, viewport) {
                  final compact = viewport.maxWidth < 700;
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        left: 14,
                        top: 10,
                        right: 14,
                        child: _LocalWorldHeader(
                          compact: compact,
                          selectedIslandName:
                              _selectedStarterIsland?.displayName,
                        ),
                      ),
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 14,
                        child: Column(
                          children: [
                            const _LocalWorldFooterHint(),
                            const SizedBox(height: 10),
                            _LocalWorldQuickActions(onMyPlotTap: _focusMyPlot),
                          ],
                        ),
                      ),
                    ],
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

class _StarterIslandBottomSheet extends StatelessWidget {
  const _StarterIslandBottomSheet({
    required this.island,
    required this.selected,
    required this.onSelect,
  });

  final LocalWorldMapObject island;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Container(
          key: const Key('local-world-starter-island-sheet'),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF07101A).withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: island.accent.withValues(alpha: 0.38)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.44),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: island.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: island.accent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      selected ? Icons.flag_rounded : Icons.terrain_rounded,
                      color: island.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          island.displayName,
                          key: const Key('local-world-starter-island-title'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          island.biome,
                          style: TextStyle(
                            color: island.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                island.shortDescription,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.74),
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('local-world-select-starter-island'),
                  style: FilledButton.styleFrom(
                    backgroundColor: island.accent,
                    foregroundColor: const Color(0xFF02050A),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onPressed: onSelect,
                  icon: Icon(
                    selected ? Icons.check_rounded : Icons.flag_rounded,
                  ),
                  label: Text(
                    selected ? 'Bereits gewählt' : 'Diese Insel wählen',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
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

class _CommunityRegionBottomSheet extends StatelessWidget {
  const _CommunityRegionBottomSheet({required this.region});

  final LocalWorldMapObject region;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Container(
          key: const Key('local-world-community-region-sheet'),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF07101A).withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: region.accent.withValues(alpha: 0.34)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.44),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: region.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: region.accent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(Icons.public_rounded, color: region.accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          region.displayName,
                          key: const Key('local-world-community-region-title'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Community-Region',
                          style: TextStyle(
                            color: region.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                region.shortDescription,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.74),
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Später als gemeinsames Ausbaugebiet verfügbar.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.62),
                  fontSize: 13,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
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

class _ForestClearingBuildBottomSheet extends StatelessWidget {
  const _ForestClearingBuildBottomSheet({required this.onBeginFoundation});

  final VoidCallback onBeginFoundation;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Container(
          key: const Key('local-world-forest-clearing-build-sheet'),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF07101A).withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: LocalWorldScreen._mint.withValues(alpha: 0.38),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.44),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: LocalWorldScreen._mint.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: LocalWorldScreen._mint.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.foundation_rounded,
                      color: LocalWorldScreen._mint,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fundament beginnen',
                          key: Key(
                            'local-world-forest-clearing-build-sheet-title',
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Waldlichtung',
                          style: TextStyle(
                            color: LocalWorldScreen._mint,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Die erste Grundlage deiner Insel entsteht.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.74),
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key(
                    'local-world-forest-clearing-begin-foundation',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: LocalWorldScreen._mint,
                    foregroundColor: const Color(0xFF02050A),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onPressed: onBeginFoundation,
                  icon: const Icon(Icons.foundation_rounded),
                  label: const Text(
                    'Fundament beginnen',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
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

class _LocalWorldQuickActions extends StatelessWidget {
  const _LocalWorldQuickActions({required this.onMyPlotTap});

  final VoidCallback onMyPlotTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _WorldOverlayAction(
          key: const Key('local-world-my-plot-action'),
          icon: Icons.my_location_rounded,
          label: 'Meine Insel',
          onTap: onMyPlotTap,
        ),
        const SizedBox(width: 12),
        _WorldOverlayAction(
          key: const Key('local-world-friends-action'),
          icon: Icons.group_rounded,
          label: 'Freunde',
          muted: true,
          onTap: () {},
        ),
      ],
    );
  }
}

class _WorldOverlayAction extends StatelessWidget {
  const _WorldOverlayAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.muted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final accent = muted
        ? Colors.white.withValues(alpha: 0.64)
        : LocalWorldScreen._cyan;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF07101A).withValues(alpha: 0.74),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: accent.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.26),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: accent, size: 17),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: muted
                      ? Colors.white.withValues(alpha: 0.64)
                      : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
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

class _LocalWorldHeader extends StatelessWidget {
  const _LocalWorldHeader({
    required this.compact,
    required this.selectedIslandName,
  });

  final bool compact;
  final String? selectedIslandName;

  @override
  Widget build(BuildContext context) {
    final subtitle = selectedIslandName == null
        ? 'Wähle deine erste Insel'
        : 'Deine Insel: $selectedIslandName';
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Talvori Welt',
          key: const Key('local-world-region-title'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          key: const Key('local-world-region-subtitle'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: LocalWorldScreen._cyan,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );

    final backButton = IconButton.filledTonal(
      key: const Key('local-world-back-button'),
      tooltip: 'Zurueck zur Home-Zentrale',
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFF07101A).withValues(alpha: 0.86),
        foregroundColor: Colors.white,
      ),
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.arrow_back_rounded),
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              backButton,
              const SizedBox(width: 12),
              Expanded(child: titleBlock),
            ],
          ),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerLeft,
            child: LocalWorldResourceBar(),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        backButton,
        const SizedBox(width: 12),
        Expanded(child: titleBlock),
        const SizedBox(width: 16),
        const LocalWorldResourceBar(),
      ],
    );
  }
}

class _LocalWorldFooterHint extends StatelessWidget {
  const _LocalWorldFooterHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF07101A).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: LocalWorldScreen._violet.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: LocalWorldScreen._mint,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Mock-Ressourcen und Gebaeude sind nur ein lokaler UI-Zustand.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.68),
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalWorldBackground extends StatelessWidget {
  const _LocalWorldBackground();

  static const assetPath =
      'assets/images/world/origin_grove_space_background.png';

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          assetPath,
          key: const Key('local-world-space-background'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF02050A).withValues(alpha: 0.16),
                Colors.transparent,
                const Color(0xFF02050A).withValues(alpha: 0.42),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
