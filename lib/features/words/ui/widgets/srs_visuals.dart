import 'package:flutter/material.dart';

/// UI-Helfer: rein präsentationsbezogen, liest Theme & SRS-Kind
enum SrsKind { tSrs, aSrs, neutral } // neutral für Hybrid

/// Stroke-Farbe für die innere Kapsel (S0–S5) je nach Modus:
Color innerCapsuleStrokeColor(ThemeData t, SrsKind kind) {
  final cs = t.colorScheme;
  switch (kind) {
    case SrsKind.tSrs:
      return cs.primary.withOpacity(0.70);        // ruhig, klar
    case SrsKind.aSrs:
      return cs.tertiary.withOpacity(0.70);       // harmonische Absetzung
    case SrsKind.neutral:
      return cs.outlineVariant.withOpacity(0.65); // Hybrid: neutral
  }
}

/// Optional: dezente Füllung (kannst du bei Bedarf nutzen)
Color? innerCapsuleFill(ThemeData t, SrsKind kind) {
  final cs = t.colorScheme;
  switch (kind) {
    case SrsKind.tSrs:
      return cs.primaryContainer.withOpacity(0.10);
    case SrsKind.aSrs:
      return cs.tertiaryContainer.withOpacity(0.10);
    case SrsKind.neutral:
      return cs.surfaceVariant.withOpacity(0.08);
  }
}

/// Label-Anzeige für Stages.
/// - T-SRS: "T0"–"T5"
/// - A-SRS: "A0"–"A5"
/// - Hybrid: "0"–"5" (neutral)
String stageLabel(int stage, SrsKind kind) {
  assert(stage >= 0 && stage <= 5);
  switch (kind) {
    case SrsKind.tSrs:
      return 'T$stage';
    case SrsKind.aSrs:
      return 'A$stage';
    case SrsKind.neutral:
      return '$stage';
  }
}
