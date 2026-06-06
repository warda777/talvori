# Phase 2G-M12-D Sensitive Content Rules Preview

Stand: 2026-06-06

Status: `Preview erzeugt / visuelle Pruefung offen`

## Zweck

Diese Preview-Dateien visualisieren erste Sensitive Content Representation
Rules fuer Talvori. Sie zeigen, wie sensible, abstrakte oder gesellschaftlich
heikle Lerninhalte sicher geroutet werden koennen, ohne sie automatisch als
Gebaeude, Symbol, Objekt, Insel, Reward oder Companion-Drama darzustellen.

Die Dateien sind:

- Dokumentationsmaterial,
- Debug-/Planungsmaterial,
- keine finale UI,
- keine Spielassets,
- keine App-Integration,
- keine Safety-Implementierung,
- keine Moderations-Implementierung,
- keine Assetfreigabe,
- keine Freigabe fuer `frame_started`.

## Dateien

1. `01_sensitive_content_decision_pipeline.png`
   - zeigt Word Intake, Sensitivity Check, Context/Sense, Safe
     Representation, User Choice und sichere Fallbacks.
2. `02_sensitive_category_matrix.png`
   - zeigt sensible Kategorien gegen erlaubte oder blockierte
     Darstellungsarten.
3. `03_safe_representation_examples.png`
   - zeigt Beispielkarten fuer `health`, `hospital`, `justice`, `police`,
     `church`, `fear`, `war` und `death`.
4. `04_blocked_until_rules_map.png`
   - trennt erlaubte neutrale Wege, aktuell blockierte Wege und spaetere
     eigene Safety-/UX-Regeln.

## Prueffazit

Die Previews machen sichtbar:

- sensible Begriffe werden nicht automatisch sichtbar platziert,
- Codex, ContextCard, CompanionDialog, Backlog und RequiresUserChoice sind die
  sicheren Standardwege,
- automatische Gebaeude, Symbole, Assets, Rewards oder Retention-Druck bleiben
  blockiert,
- Gesundheits-, Politik-, Rechts-, Polizei-, Religions-, Kriegs-, Tod-,
  Identitaets- und Krisenthemen brauchen spaetere eigene Safety-/UX-Regeln.

## Sichtbare Risiken

- Die Matrix ist fuer interne Planung gedacht und nicht als Nutzeransicht.
- Die Begriffe brauchen spaeter Sprache, Alters-/Familienmodus,
  Satzkontext, Privacy und Import-Regeln.
- Companion-Texte fuer sensible Themen brauchen eigene Tonalitaetspruefung.
- Gesundheits-, Rechts- und Politikbegriffe duerfen keine Beratung erzeugen.
- Sensitive ThemeIslands bleiben blockiert, bis eigene Safety-/UX-Konzepte
  existieren.

## Grenzen

Nicht ableiten:

- keine finale Safety-Implementierung,
- keine Moderations-Implementierung,
- keine finale Datenstruktur,
- keine App-Integration,
- keine ThemeIsland-Umsetzung,
- keine Gebaeude-/Symbol-/Assetproduktion,
- keine automatische Visualisierung sensibler Begriffe,
- keine medizinische, juristische oder politische Beratung,
- kein `frame_started`.

## Naechster Schritt

Erlaubt:

- M12-D visuell pruefen,
- M12-D bei Bedarf nachbessern,
- M12-E Mobile And Clutter Rules planen,
- spaeter ContextCard-/Companion-Regeln fuer sensible Themen visualisieren.
