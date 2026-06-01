import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _worldRegionSystemUiOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Color(0xFF02050A),
  systemNavigationBarIconBrightness: Brightness.light,
);

class WorldRegionScreen extends StatelessWidget {
  const WorldRegionScreen({super.key});

  static const _cyan = Color(0xFF5DDCFF);
  static const _violet = Color(0xFFB36BFF);
  static const _mint = Color(0xFF9FF7D5);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _worldRegionSystemUiOverlayStyle,
      child: Scaffold(
        backgroundColor: const Color(0xFF02050A),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _WorldRegionBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton.filledTonal(
                      key: const Key('world-region-back-button'),
                      tooltip: 'Zurück',
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF07101A,
                        ).withValues(alpha: 0.86),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Container(
                          key: const Key('world-region-placeholder-panel'),
                          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF07101A,
                            ).withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: _cyan.withValues(alpha: 0.34),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _cyan.withValues(alpha: 0.16),
                                blurRadius: 38,
                                spreadRadius: -8,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.42),
                                blurRadius: 28,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.public_rounded,
                                color: _mint,
                                size: 42,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Talvori Welt',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Startregion-Prototyp',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: _cyan,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Deine Welt entsteht hier.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Im nächsten Schritt wachsen hier Region, Plot, '
                                'Gebäude und Ressourcen aus deinen Lernmomenten.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.66,
                                      ),
                                      height: 1.35,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        _RegionChip(icon: Icons.home_rounded, label: 'Haus'),
                        SizedBox(width: 8),
                        _RegionChip(
                          icon: Icons.storefront_rounded,
                          label: 'Markt',
                        ),
                        SizedBox(width: 8),
                        _RegionChip(
                          icon: Icons.local_library_rounded,
                          label: 'Bibliothek',
                        ),
                      ],
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

class _WorldRegionBackground extends StatelessWidget {
  const _WorldRegionBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.4),
          radius: 1.2,
          colors: [Color(0xFF102744), Color(0xFF06101C), Color(0xFF02050A)],
          stops: [0, 0.55, 1],
        ),
      ),
      child: CustomPaint(painter: _WorldRegionBackgroundPainter()),
    );
  }
}

class _WorldRegionBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.52);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = WorldRegionScreen._cyan.withValues(alpha: 0.13);
    for (var i = 0; i < 5; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center + Offset(0, i * 22.0),
          width: size.width * (0.62 + i * 0.09),
          height: 58 + i * 24.0,
        ),
        paint,
      );
    }

    final starPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.32);
    for (var i = 0; i < 44; i++) {
      final x = (i * 47) % size.width;
      final y = ((i * 83) % size.height) * 0.78;
      canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), 0.8, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RegionChip extends StatelessWidget {
  const _RegionChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF07101A).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: WorldRegionScreen._violet.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: WorldRegionScreen._mint),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
