import 'package:flutter/material.dart';

import 'foundation_choice_preview.dart';
import 'neutral_plot_marker_preview.dart';

const _compositionBackground = Color(0xFF070B12);
const _compositionPanel = Color(0xFF101A28);
const _compositionBorder = Color(0xFF4F6A7E);
const _compositionCyan = Color(0xFF5DDCFF);
const _compositionMint = Color(0xFF9FF7D5);
const _compositionViolet = Color(0xFFB36BFF);

class LocalWorldPreviewComposition extends StatelessWidget {
  const LocalWorldPreviewComposition({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: _compositionBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _compositionCyan,
        brightness: Brightness.dark,
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Theme(
        data: theme,
        child: Material(
          color: _compositionBackground,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CompositionNotice(),
                      SizedBox(height: 16),
                      _CompositionSectionHeader(
                        eyebrow: '1. Lernfokus separat',
                        title: 'Fokuswahl ist kein Bau-Menü',
                        body:
                            'Die Auswahl bleibt eine lokale Preview. Sie startet kein Gebäude und platziert nichts.',
                      ),
                      SizedBox(height: 10),
                      _PreviewDeviceFrame(
                        viewportHeight: 760,
                        child: FoundationChoicePreview(),
                      ),
                      SizedBox(height: 14),
                      _CompositionBridgeCard(),
                      SizedBox(height: 14),
                      _CompositionSectionHeader(
                        eyebrow: '2. Erster neutraler Welt-Ort',
                        title: 'Plot Marker baut noch nichts',
                        body:
                            'Der Marker zeigt nur einen möglichen Lernplatz. Kein Gebäude, kein Bauzustand, keine Speicherung.',
                      ),
                      SizedBox(height: 10),
                      _PreviewDeviceFrame(
                        viewportHeight: 560,
                        child: NeutralPlotMarkerPreview(),
                      ),
                    ],
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

class _CompositionNotice extends StatelessWidget {
  const _CompositionNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('local-world-preview-composition-notice'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: _compositionViolet.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _compositionViolet.withValues(alpha: 0.42)),
      ),
      child: const Text(
        'Lokale World Preview / keine Route / keine Speicherung',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          height: 1.25,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _CompositionSectionHeader extends StatelessWidget {
  const _CompositionSectionHeader({
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: _compositionPanel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _compositionBorder.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              color: _compositionMint,
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              height: 1.2,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              fontSize: 12,
              height: 1.32,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompositionBridgeCard extends StatelessWidget {
  const _CompositionBridgeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('local-world-preview-composition-bridge'),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: _compositionCyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _compositionCyan.withValues(alpha: 0.28)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: _compositionCyan, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Der Lernfokus schlägt später vor. Der Plot-Marker baut noch nichts.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.28,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewDeviceFrame extends StatelessWidget {
  const _PreviewDeviceFrame({
    required this.viewportHeight,
    required this.child,
  });

  final double viewportHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const viewportWidth = 390.0;
    final viewportSize = Size(viewportWidth, viewportHeight);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _compositionBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 24,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            width: viewportWidth,
            height: viewportHeight,
            child: MediaQuery(
              data: MediaQueryData(
                size: viewportSize,
                devicePixelRatio: 2,
                padding: const EdgeInsets.only(top: 24, bottom: 16),
                viewPadding: const EdgeInsets.only(top: 24, bottom: 16),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
