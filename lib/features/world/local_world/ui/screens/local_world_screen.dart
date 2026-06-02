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

  @override
  void initState() {
    super.initState();
    _worldTransformController = TransformationController();
  }

  @override
  void dispose() {
    _worldTransformController.dispose();
    super.dispose();
  }

  void _focusMyPlot() {
    _worldTransformController.value = Matrix4.identity();
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
            LocalWorldPlotView(controller: _worldTransformController),
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
                        child: _LocalWorldHeader(compact: compact),
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
          label: 'Mein Plot',
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
  const _LocalWorldHeader({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Talvori Ursprungshain',
          key: const Key('local-world-region-title'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Dein erster lokaler Welt-Slice',
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
