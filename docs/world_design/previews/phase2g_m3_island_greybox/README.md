# Phase 2G-M4 Debug-Greybox Preview

Stand: 2026-06-05

Diese Preview-Dateien sind reine Dokumentations- und Debugbilder fuer das
Talvori-Insel-Masterlayout. Sie sind keine Spielassets, keine finale Kunst und
keine Codefreigabe.

## Zweck

Die Preview macht die in Phase 2G-M2 und Phase 2G-M3 geplante
Plot-/Socket-/Footprint-Struktur sichtbar.

Sie soll pruefen:

- ob sieben Starter-/Vorbereitungsplots sichtbar und nachvollziehbar sind,
- ob 12 bis 14 Ausbau-Slots plausibel vorbereitet werden koennen,
- ob `starter_home_plot` genug Raum fuer Haus, Hof und Weg bietet,
- ob Wege, Sockets, Footprints und Sicherheitszonen als System lesbar sind,
- ob `frame_started` weiterhin blockiert bleiben muss, bis das Layout visuell
  bestaetigt oder nachgebessert ist.

## Preview-Dateien

- `01_island_plot_greybox.png`: Plotflaechen, Labels und Status.
- `02_socket_debug_overlay.png`: Socket-Punkte und Socket-Typen.
- `03_footprint_debug_overlay.png`: Wege, Gebaeude-Footprints,
  Sicherheitszonen und Deko-Zonen.
- `04_status_legend.png`: Status- und Socket-Legende mit Debug-Hinweis.

## Kurzes Prueffazit

- Sieben Starter-/Vorbereitungsplots sind sichtbar:
  `starter_home`, `garden_west`, `path_south`, `nature_north`,
  `function_seed_east`, `hub_seed_south`, `expansion_edge_se`.
- Spaetere Expansionen sind sichtbar vorbereitet:
  `neighbor_west`, `market_square`, `nature_edge_nw`, `water_edge_east`,
  `farm_southwest`.
- Die Wege sind als erstes Verbindungssystem erkennbar.
- Relevante Plots haben sichtbare Socket-Punkte.
- Der `starter_home_plot` ist als groesserer StarterCorePlot markiert.
- Gebaeude-Footprints, Wegband und Sicherheitszonen sind sichtbar pruefbar.

Vorlaeufiges Ergebnis:

```text
Debug-Greybox erzeugt / manuelle Nutzerpruefung ausstehend
```

## Sichtbare Probleme Und Risiken

- Die Struktur ist modular gut lesbar, wirkt aber noch sehr diagrammatisch.
  Das ist fuer diesen Block beabsichtigt.
- Mobile-Lesbarkeit ist noch nicht bewiesen. Die PNGs sind grosse
  Dokumentationsbilder, keine echte Mobile-Preview.
- Einige Socket-Labels in `02_socket_debug_overlay.png` sind bewusst klein,
  damit die Plotstruktur nicht komplett verdeckt wird. Eine spaetere
  Mobile-Preview muss klaeren, ob Labels, Punkte und Wege bei kleinerer
  Skalierung noch funktionieren.
- `market_square` und `hub_seed_south` brauchen spaeter besondere
  Kapazitaetspruefung, damit die Insel nicht wie ein ueberfuelltes Brettspiel
  wirkt.
- Die Preview bestaetigt noch keine organische finale Inseloptik.

## Blockierte Folgen

Diese Preview gibt nicht frei:

- `frame_started`,
- neue Spielassets,
- finale Inselkunst,
- PNGs im Asset-Ordner,
- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Persistenz,
- Supabase,
- SRS-/`word_progress`,
- Reward Bridge,
- Ressourcenlogik,
- Sound-/FX-Schicht,
- Expansion-System,
- PlacedItems,
- Interiors/ObjectDetail.

Naechster erlaubter Schritt:

- manuelle visuelle Pruefung der Debug-Greybox durch den Nutzer,
- danach Metriken/Layout bestaetigen oder nachbessern.
