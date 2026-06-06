# Phase 2G-M12-B Word-to-Island Routing Previews

Stand: 2026-06-06

Status: `Dokumentations-/Previewmaterial`

Diese Preview-Dateien visualisieren die erste Word-to-Island Routing Matrix aus
`docs/world_design/270-word-to-island-routing-matrix.md`.

Sie wurden mit der lokalen Diagramm-/Preview-Toolchain ueber
`.venv-tools/bin/python` und Pillow erzeugt.

## Dateien

- `01_word_routing_pipeline.png`
  - zeigt Word intake -> semantic profile -> safety/context -> theme
    candidates -> depth candidates -> user suggestion -> user decision ->
    result.
- `02_word_type_routing_matrix.png`
  - zeigt Worttypen gegen Ziel-Ebenen: ThemeIsland, Zone/Plot, Interior,
    Container, Detail, Action und Codex/Backlog.
- `03_example_word_routing_cards.png`
  - zeigt Beispielkarten fuer spoon, pencil, watering can, compass, window,
    drive, bank und health.
- `04_multi_home_and_backlog_flow.png`
  - zeigt Multi-home und Backlog fuer apple, window, justice und server.

## Prueffazit

- Routing-Pipeline ist als Planungsfluss verstaendlich.
- Worttyp-Matrix ist fuer interne Planung brauchbar, aber keine Datenstruktur.
- Beispielkarten zeigen klare Fallbacks.
- Multi-home-Woerter brauchen Kontext oder Nutzerentscheidung.
- Backlog, Codex und Blueprint verhindern falsche Platzierung.

## Grenzen

- Keine finale Routing-Implementierung.
- Keine finale Datenstruktur.
- Keine automatische Wortplatzierung.
- Keine finale UI.
- Keine Spielassets.
- Keine App-Integration.
- Keine Assetfreigabe.
- Keine Freigabe fuer `frame_started`.

## Offene Folgeblocks

- `Phase 2G-M12-B2 Word-to-Island Routing Visual Review`
- `Phase 2G-M12-C Plot-Capability Derivation`
- `Phase 2G-M12-D Sensitive Content Representation Rules`
- `Phase 2G-M12-E Mobile And Clutter Rules For Small Objects`
