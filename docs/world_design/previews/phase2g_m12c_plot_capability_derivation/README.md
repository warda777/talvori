# Phase 2G-M12-C Plot-Capability Derivation Previews

Stand: 2026-06-06

Status: `Dokumentations-/Previewmaterial`

Diese Preview-Dateien visualisieren die Plot-Capability-Ableitung aus
`docs/world_design/272-plot-capability-derivation.md`.

Sie wurden mit der lokalen Diagramm-/Preview-Toolchain ueber
`.venv-tools/bin/python` und Pillow erzeugt.

## Dateien

- `01_plot_capability_pipeline.png`
  - zeigt Taxonomy -> ThemeIsland Priority -> Word Routing -> Plot Capability
    -> User Choice -> Safe Placement / Backlog.
- `02_plot_type_capability_matrix.png`
  - zeigt abstrakte Plottypen gegen `plotSize`, `allowedFunctions`, Wave,
    Depth und Risk/Stop.
- `03_early_theme_capability_cards.png`
  - zeigt erste Capability-Karten fuer Zuhause/Alltag, Schule/Lernen und
    Garten/Natur nah.
- `04_mid_late_special_plot_limits.png`
  - zeigt Grenzen fuer Mid-, Late- und Special-Themen, die eigene Regeln
    brauchen.

## Prueffazit

- Early-Plot-Capabilities sind als Planungsgrundlage verstaendlich.
- Plottypen erlauben Funktionen, erzwingen aber keine feste Belegung.
- `core_plot` bleibt flexibel und darf nicht als Pflicht-Hausstart gelesen
  werden.
- Edge-, Water-, Farm-, Travel-, Vehicle-, Digital- und Sensitive-Funktionen
  bleiben durch Folgepruefungen begrenzt.
- Text bleibt in den Karten/Rahmen/Panels.

## Grenzen

- Keine finale Plot-Datenstruktur.
- Keine Runtime-Konfiguration.
- Keine Plot-Implementierung.
- Keine ThemeIsland-Umsetzung.
- Keine automatische Wortplatzierung.
- Keine Spielassets.
- Keine App-Integration.
- Keine Asset-/Codefreigabe.
- Keine Freigabe fuer `frame_started`.

## Offene Folgeblocks

- `Phase 2G-M12-C2 Plot-Capability Visual Review`
- `Phase 2G-M12-D Sensitive Content Representation Rules`
- `Phase 2G-M12-E Mobile And Clutter Rules For Small Objects`
