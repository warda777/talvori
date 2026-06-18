import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firenze_flame_world_camera_game.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const FirenzeFlameWorldCameraPreviewApp());
}

class FirenzeFlameWorldCameraPreviewApp extends StatelessWidget {
  const FirenzeFlameWorldCameraPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(
        useMaterial3: true,
      ).copyWith(scaffoldBackgroundColor: const Color(0xFF02080D)),
      home: const FirenzeFlameWorldCameraPreview(),
    );
  }
}

class FirenzeFlameWorldCameraPreview extends StatefulWidget {
  const FirenzeFlameWorldCameraPreview({super.key});

  @override
  State<FirenzeFlameWorldCameraPreview> createState() =>
      _FirenzeFlameWorldCameraPreviewState();
}

class _FirenzeFlameWorldCameraPreviewState
    extends State<FirenzeFlameWorldCameraPreview> {
  late final FirenzeFlameWorldCameraGame _game;

  @override
  void initState() {
    super.initState();
    _game = FirenzeFlameWorldCameraGame();
  }

  @override
  void dispose() {
    _game.debugSnapshot.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isPortrait = constraints.maxHeight > constraints.maxWidth;
          return Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onDoubleTap: isPortrait ? null : _game.resetToOverview,
                onScaleStart: isPortrait
                    ? null
                    : (details) =>
                          _game.handleScaleStart(details.localFocalPoint),
                onScaleUpdate: isPortrait
                    ? null
                    : (details) => _game.handleScaleUpdate(
                        currentFocalPoint: details.localFocalPoint,
                        scaleFactor: details.scale,
                      ),
                onScaleEnd: isPortrait ? null : (_) => _game.handleScaleEnd(),
                child: GameWidget(game: _game),
              ),
              const Positioned(left: 16, top: 14, child: _ProofTitle()),
              if (kDebugMode)
                Positioned(right: 16, top: 14, child: _DebugChip(game: _game)),
              if (isPortrait) const _RotateDeviceOverlay(),
            ],
          );
        },
      ),
    );
  }
}

class _ProofTitle extends StatelessWidget {
  const _ProofTitle();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCC06141C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x554BEAD4)),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Florenz Flame Proof',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'World/Camera only',
              style: TextStyle(
                color: Color(0xFFB7D7D9),
                fontSize: 11,
                height: 1,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebugChip extends StatelessWidget {
  const _DebugChip({required this.game});

  final FirenzeFlameWorldCameraGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FirenzeFlameCameraDebugSnapshot>(
      valueListenable: game.debugSnapshot,
      builder: (context, snapshot, _) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0x99040B10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x334BEAD4)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            child: Text(
              'scale ${snapshot.zoom.toStringAsFixed(3)}  '
              'min ${snapshot.hardMinScale.toStringAsFixed(3)}  '
              'view ${snapshot.viewportSize.width.toStringAsFixed(0)}x'
              '${snapshot.viewportSize.height.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Color(0xFFD8F8F2),
                fontSize: 10,
                height: 1,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RotateDeviceOverlay extends StatelessWidget {
  const _RotateDeviceOverlay();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: Color(0xDD02080D)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.screen_rotation_rounded, color: Colors.white, size: 42),
            SizedBox(height: 12),
            Text(
              'Drehe dein Gerät',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                height: 1,
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
