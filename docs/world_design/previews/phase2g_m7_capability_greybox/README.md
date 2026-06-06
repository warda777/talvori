# Phase 2G-M7-B Capability Greybox Preview

Status: `Debug-/Dokumentationspreview mit erweiterter Toolchain neu erzeugt`

## Zweck

Diese Preview prueft, ob die naechste Waldlichtung-/Starter-Testform ohne feste
Gebaeude-Rollenlabels als abstrakte Capability-Greybox lesbar ist.

Die Dateien sind:

- keine Spielassets,
- keine finale Kunst,
- kein finales Inselbild,
- keine Codefreigabe,
- keine Assetfreigabe.

## Toolchain

Die Preview-PNGs wurden mit der erweiterten lokalen Diagramm-/Bildtoolchain
neu erzeugt.

Verfuegbar und geprueft:

- Pillow
- matplotlib
- networkx
- svgwrite
- Graphviz / `dot`

`cairosvg` ist als Python-Paket installiert, konnte in dieser Umgebung aber
nicht genutzt werden, weil die native Cairo-Bibliothek beim Import nicht
aufgeloest wurde. Fuer diese Preview wurde deshalb Pillow als finaler
PNG-Renderer verwendet. NetworkX wurde fuer die feste Graphstruktur validiert;
es wurde kein zufaelliges Layout genutzt.

Technische Bilddaten:

- Format: PNG / RGB
- Groesse: `2400 x 1700`
- Layout: feste Plot-Positionen, keine automatische Zufallsanordnung

## Dateien

- `01_capability_plot_overview.png`
  - zeigt abstrakte Plotnamen, `plotSize`, `unlockState` und
    `isUserSelectable`.
- `02_allowed_functions_overlay.png`
  - zeigt `allowedFunctions` pro Plot und macht sichtbar, dass mehrere
    Funktionen moeglich sind.
- `03_anchor_socket_overlay.png`
  - zeigt `pathSockets`, `objectAnchors` und `buildingFootprints` als
    technische Debugansicht.
- `04_user_choice_flow_overlay.png`
  - zeigt den Grundfluss: Nutzer waehlt Plot, System zeigt kompatible
    BuildOptions, Nutzer bestaetigt, erst dann entsteht `BuildInstance`,
    `BlueprintEntry`, `CodexEntry` oder `PlacementCandidate`.

## Prueffazit

- Alte feste Gebaeude-Rollenlabels wurden in den Preview-Bildern entfernt.
- Abstrakte Plotnamen sind sichtbar.
- `plotSize`, `unlockState` und `isUserSelectable` sind pruefbar.
- `allowedFunctions` sind sichtbar, ohne eine Funktion als bereits gewaehlt
  darzustellen.
- Anchors, Sockets und Footprints sind technisch pruefbar.
- Der Nutzerwahl-Flow zeigt klar, dass keine automatische Platzierung
  stattfindet.
- Die zweite Version ist gegenueber der ersten schnellen Preview groesser,
  ruhiger und lesbarer.
- Legenden, Statusfarben und `userSelectable`-Unterscheidung sind
  konsistenter.

## Sichtbare Risiken

- Die technische Vollansicht ist dicht und eher fuer interne Pruefung als fuer
  Nutzerkommunikation geeignet.
- `allowedFunctions` koennen bei vielen Plots schnell ueberladen wirken.
- Fuer spaetere Produkt-/UX-Pruefung wird wahrscheinlich eine vereinfachte
  Nutzeransicht neben der technischen Vollansicht benoetigt.
- Die organische Inselwirkung bleibt nur schematisch angedeutet; diese Preview
  bestaetigt keine finale Layout- oder Inselkunst.

## Weiterhin Blockiert

- `frame_started`
- neue Spielassets
- PNGs im Asset-Ordner
- finales Inselbild
- Flutter-/Dart-Code
- App-Integration
- Bauzustaende
- Persistenz
- Supabase
- SRS-/`word_progress`
- Reward Bridge
- Ressourcenlogik
- Sound-/FX-Schicht
