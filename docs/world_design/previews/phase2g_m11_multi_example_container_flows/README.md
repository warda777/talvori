# Phase 2G-M11 Multi-Example Container Flow Previews

Stand: 2026-06-06

Status: `Dokumentations-/Previewmaterial / Review offen`

## Zweck

Diese Preview-Dateien pruefen, ob die Depth-/Container-Logik aus M9 bis
M10-C ueber mehrere Themen hinweg tragfaehig wirkt. M11 nutzt drei
Beispiel-Flows:

- Schule -> Federmappe -> Stifte,
- Hafen -> Bootskajute -> Kompass/Karte/Seil,
- Garten -> Beet -> Samen/Giesskanne/Pflanze.

Die Dateien sind keine Spielassets, keine finale UI und keine Code- oder
Assetfreigabe.

## Dateien

- `01_multi_flow_overview.png`
  - zeigt die drei Flows nebeneinander mit Thema, Container/Fokus,
    Objekten, Challenge-Fit, Companion-Moment und Risiko.
- `02_flow_comparison_matrix.png`
  - bewertet die Flows nach Thema, Containerlogik, Challenge-Fit,
    Companion-Eignung, Mobile-Risiko und Hauptproblem.
- `03_challenge_fit_by_flow.png`
  - zeigt, welche Challenge-Arten zu welchem Flow passen und welche
    Challenge-Progression fuer den Review-Stand empfohlen ist.
- `04_companion_moments_by_flow.png`
  - zeigt Tali/Vori-Momente fuer Curiosity Cue, sanften Hinweis, Erfolg,
    Fehlerhilfe und optionales naechstes Ziel.

## Prueffazit

Die Grundlogik wirkt ueber mehrere Themen hinweg plausibel:

- Schule/Federmappe ist ein sehr klarer Alltagscontainer fuer kleine
  Objektwoerter.
- Garten/Beet ist stark fuer Wachstum, Fortschritt und spaetere
  Mini-Sequenzen.
- Hafen/Bootskajute ist thematisch reizvoll, hat aber mehr UX-/Mobile-Risiko.

Tap-Auswahl bleibt der staerkste gemeinsame MVP-Kandidat. Audio + Tap bleibt
eine fruehe zweite Stufe mit Silent-/Accessibility-Fallback. Matching und
Sortieren sind spaetere Varianten. Mini-Sequenzen bleiben fuer Aktionen und
Progression interessant, aber nicht als erster Schritt.

## Sichtbare Risiken

- Hafen/Bootskajute kann schnell zu komplex werden, wenn zu viele
  Navigationsobjekte sichtbar sind.
- Schule/Federmappe hat viele kleine Objekte und braucht gute Gruppierung.
- Garten/Beet darf Wachstum nicht ueber manipulative Timer oder Druck
  motivieren.
- Mobile-Lesbarkeit und Bedienbarkeit bleiben separat zu pruefen.
- M11 ist noch kein finales Container-System.

## Grenzen

Diese Previews sind:

- keine finale UI,
- keine Spielassets,
- keine App-Integration,
- keine Challenge-Implementierung,
- keine Companion-Implementierung,
- keine Voice-/Audio-/Animation-/Rive-Freigabe,
- keine allgemeine Container-Systemarchitektur.

Aus M11 folgt nur: Mehrere Beispiel-Flows wurden sichtbar geplant und muessen
als naechstes visuell reviewed werden.

