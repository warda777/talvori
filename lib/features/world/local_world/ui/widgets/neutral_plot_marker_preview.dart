import 'package:flutter/material.dart';

const _markerBackground = Color(0xFF050912);
const _markerPanel = Color(0xFF0D1724);
const _markerSurface = Color(0xFF132235);
const _markerCyan = Color(0xFF5DDCFF);
const _markerMint = Color(0xFF9FF7D5);
const _markerViolet = Color(0xFFB36BFF);
const _markerGold = Color(0xFFFFD980);

class NeutralPlotMarkerPreview extends StatelessWidget {
  const NeutralPlotMarkerPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('neutral-plot-marker-preview'),
      color: _markerBackground,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _NeutralPlotMarkerNotice(),
                  SizedBox(height: 14),
                  _NeutralPlotMarkerCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NeutralPlotMarkerNotice extends StatelessWidget {
  const _NeutralPlotMarkerNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('neutral-plot-marker-notice'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _markerViolet.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _markerViolet.withValues(alpha: 0.42)),
      ),
      child: const Text(
        'Lokale Preview / kein Bauzustand / keine Platzierung',
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

class _NeutralPlotMarkerCard extends StatelessWidget {
  const _NeutralPlotMarkerCard();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Neutraler Plot Marker. Möglicher Lernplatz. Noch kein Gebäude. Keine Speicherung. Keine Platzierung.',
      child: Container(
        key: const Key('neutral-plot-marker-card'),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: _markerPanel,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: _markerCyan.withValues(alpha: 0.34)),
          boxShadow: [
            BoxShadow(
              color: _markerCyan.withValues(alpha: 0.1),
              blurRadius: 28,
              spreadRadius: -10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _NeutralPlotVisual(),
            const SizedBox(height: 16),
            const Text(
              'Möglicher Lernplatz',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Ein neutraler Ort für spätere Weltideen. Noch kein Gebäude, keine Auswahl und keine echte Platzierung.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 14),
            const Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _MarkerBadge(text: 'neutral', color: _markerMint),
                _MarkerBadge(text: 'lokal', color: _markerCyan),
                _MarkerBadge(text: 'kein Bauzustand', color: _markerGold),
              ],
            ),
            const SizedBox(height: 14),
            const _MarkerGuardrails(),
          ],
        ),
      ),
    );
  }
}

class _NeutralPlotVisual extends StatelessWidget {
  const _NeutralPlotVisual();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.55,
      child: Container(
        key: const Key('neutral-plot-marker-visual'),
        decoration: BoxDecoration(
          color: _markerSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _markerMint.withValues(alpha: 0.24)),
        ),
        child: Center(
          child: Container(
            width: 132,
            height: 94,
            decoration: BoxDecoration(
              color: _markerMint.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: _markerMint.withValues(alpha: 0.58),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.radio_button_unchecked_rounded,
                color: _markerMint,
                size: 42,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarkerBadge extends StatelessWidget {
  const _MarkerBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.82),
          fontSize: 11,
          height: 1.1,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _MarkerGuardrails extends StatelessWidget {
  const _MarkerGuardrails();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('neutral-plot-marker-guardrails'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GuardrailLine(
            icon: Icons.domain_disabled_rounded,
            text: 'Noch kein Gebäude',
          ),
          SizedBox(height: 8),
          _GuardrailLine(
            icon: Icons.save_alt_rounded,
            text: 'Keine Speicherung',
          ),
          SizedBox(height: 8),
          _GuardrailLine(icon: Icons.place_outlined, text: 'Keine Platzierung'),
        ],
      ),
    );
  }
}

class _GuardrailLine extends StatelessWidget {
  const _GuardrailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _markerCyan, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}
