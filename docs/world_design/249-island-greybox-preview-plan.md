# Phase 2G-M3: Island Greybox Preview Plan

Stand: 2026-06-05

Dieses Dokument startet Phase 2G-M3 als reinen Planungsblock fuer eine
sichtbare Greybox-Preview und Layout-Pruefung des Talvori-Insel-
Masterlayouts.

Fuehrende Dokumente:

- `docs/world_design/248-island-plot-metrics-and-greybox-layout.md`
- `docs/world_design/247-island-greybox-scale-and-plot-metrics.md`
- `docs/world_design/246-island-master-layout-and-modular-plot-system.md`
- `docs/world_design/245-build-alignment-and-anchor-system.md`
- `docs/world_design/235-world-production-roadmap-and-checklists.md`
- `assets/images/world/buildable_islands/forest_clearing/template.md`

## 1. Zweck

Die Greybox-Preview soll sichtbar pruefen, ob das in Phase 2G-M2 definierte
Insel-Masterlayout als modulare private Talvori-Insel funktioniert.

Sie klaert vor weiterer Asset-Produktion:

- ob die Starter-Insel genug funktionale Plot-Slots traegt,
- ob die erste Ausbauinsel plausibel vorbereitet ist,
- ob Plots, Wege, Sockets, Footprints und Sicherheitszonen zusammenpassen,
- ob die aktuelle Waldlichtung als `StarterCorePlot` in ein groesseres
  Layout eingebettet werden kann,
- ob das Layout in Mobile-Island-View lesbar bleibt.

Die Preview ist kein finales Inselbild. Sie ist ein Debug-/Planungsdiagramm.
Sie darf nicht als Spielasset, finale Kunst oder `frame_started`-Freigabe
missverstanden werden.

Nicht-Ziele:

- kein Flutter-/Dart-Code,
- keine App-Integration,
- keine Tests,
- keine Spielassets,
- keine PNGs im Asset-Ordner,
- kein finales Inselbild,
- kein `frame_started`,
- keine Bauzustands-Fortsetzung,
- kein Commit.

## 2. Sichtbare Greybox-Elemente

Eine spaetere sichtbare Greybox-Preview soll zeigen:

- Plot-Flaechen als einfache geometrische Formen,
- Plot-Labels,
- Plot-Status,
- Socket-Punkte,
- Wege als einfache Linien oder Baender,
- Gebaeude-Footprints als kleinere Polygone,
- Deko-Sicherheitszonen als dezente Markierungen,
- Expansion-Kanten,
- den `StarterCorePlot` deutlich markiert.

Die Greybox soll nicht huebsch sein. Sie soll pruefbar sein.

### Plot-Status

Die Preview muss folgende Status sichtbar unterscheiden:

| Status | Bedeutung | Darstellungsidee |
| --- | --- | --- |
| `visible_start` | Sofort sichtbarer Starterbereich. | Solide helle Plot-Flaeche. |
| `reserved_hidden` | Vorbereitete, aber noch nicht voll ausgespielte Flaeche. | Gestrichelte oder halbtransparente Flaeche. |
| `future_unlock` | Spaetere Expansion. | Deutlich zurueckgenommene Outline. |
| `expansion_edge` | Andock-/Erweiterungskante. | Randmarkierung mit Expansion-Sockets. |

### Socket-Typen

Die Preview muss diese Socket-Typen markieren koennen:

- `path_socket`
- `terrain_socket`
- `residential_socket`
- `market_socket`
- `nature_socket`
- `water_socket`
- `expansion_socket`

Socket-Markierungen muessen sichtbar, aber klar als Debug-Hilfe erkennbar
sein.

## 3. Zu Pruefende M2-Greybox-Struktur

Phase 2G-M3 uebernimmt die M2-Koordinatenstruktur als zu pruefendes Layout:

```text
              [nature_edge_nw] -- [nature_north] ---- [water_edge_east*]
                    |                  |                    |
[neighbor_west*] -- [garden_west] -- [starter_home] -- [function_seed_east]
                    |                  |                    |
              [farm_southwest*] -- [path_south] ----- [expansion_edge_se]
                                       |
                                [hub_seed_south]
                                       |
                                [market_square*]
```

`*` markiert spaetere Expansion.

### Status-Zuordnung Fuer Die Preview

| PlotId | Status | Begruendung |
| --- | --- | --- |
| `starter_home` | `visible_start` | Aktuelle Waldlichtung / `StarterCorePlot`. |
| `garden_west` | `visible_start` | Frueher Hof-/Garten- und Wohnrandbereich. |
| `path_south` | `visible_start` | Erster Weg- und Verbindungsanker. |
| `nature_north` | `visible_start` | Ruhiger Naturpuffer hinter dem Startergrundstueck. |
| `function_seed_east` | `reserved_hidden` | Vorbereiteter Funktionsplot, noch nicht voll aktiv. |
| `hub_seed_south` | `reserved_hidden` | Spaeterer Hub-Ansatz, fuer Wegeplanung sichtbar reserviert. |
| `expansion_edge_se` | `expansion_edge` | Sichtbarer Andock-/Erweiterungsrand. |
| `neighbor_west` | `future_unlock` | Spaetere Nachbarschaft/Freunde. |
| `market_square` | `future_unlock` | Groesserer Markt-/Hub-Bereich spaeter. |
| `nature_edge_nw` | `future_unlock` | Spaetere Naturerweiterung. |
| `water_edge_east` | `future_unlock` | Optionaler Ufer-/Reisebereich. |
| `farm_southwest` | `future_unlock` | Spaetere Farm-/Essen-Erweiterung. |

Diese Zuordnung macht sieben Starter-/Vorbereitungsplots sichtbar:

- `starter_home`
- `garden_west`
- `path_south`
- `nature_north`
- `function_seed_east`
- `hub_seed_south`
- `expansion_edge_se`

Die restlichen Plots pruefen, ob 12 bis 14 Ausbau-Slots plausibel vorbereitet
werden koennen.

## 4. Geplante Preview-Dateien

In diesem Block werden keine Preview-Dateien erzeugt.

Eine spaetere reine Dokumentations-/Debug-Preview darf unter folgendem Ordner
liegen:

```text
docs/world_design/previews/phase2g_m3_island_greybox/
```

Erlaubte geplante Dateien:

- `01_island_plot_greybox.png`
- `02_socket_debug_overlay.png`
- `03_footprint_debug_overlay.png`
- `04_status_legend.png`

Regeln:

- keine Datei unter `assets/`,
- keine finale Kunst,
- keine Spielassets,
- klare Debug-Beschriftung,
- sichtbare Status-Legende,
- Preview darf geloescht oder ersetzt werden, wenn Metriken nachgebessert
  werden.

## 5. Pruefkriterien

Die sichtbare Greybox muss beantworten:

- Traegt die Starter-Insel wirklich sieben funktionale Plot-Slots?
- Sind 12 bis 14 Ausbau-Plots plausibel vorbereitbar?
- Wirkt `starter_home_plot` gross genug fuer Haus, Hof und Weg?
- Sind Wege logisch verbunden?
- Haben alle relevanten Plots sichtbare Anschluss-Sockets?
- Sind Expansion-Kanten logisch und nicht zufaellig?
- Wird die Insel zu klein oder zu ueberladen?
- Gibt es genug Abstand zwischen Haus, Weg, Deko und Plotrand?
- Bleibt die Struktur organisch genug, obwohl sie intern modular ist?
- Sind spaetere Kategorien anschliessbar, ohne das Layout zu brechen?

Zusatzpruefung fuer Bauassets:

- Kein Gebaeude-Footprint darf ohne Sicherheitsabstand zur Plotkante liegen.
- Kein Weg darf ohne kompatiblen `path_socket` ueber eine Plotgrenze laufen.
- Kein Plot darf ohne mindestens einen sichtbaren Socket bewertet werden.
- `starter_home` muss als Basis fuer spaetere BuildAreaState-Assets lesbar
  bleiben.

## 6. Mobile-Lesbarkeit

Eine spaetere mobile Preview muss klaeren:

- Sind Plot-Labels in Mobile-Ansicht ueberhaupt lesbar?
- Sind Wege bei erwarteter Island-View-Skalierung sichtbar?
- Sind Gebaeude-Footprints nicht zu klein?
- Werden `micro_plot`-Flaechen zu klein?
- Wie stark darf die Kamera herauszoomen?
- Braucht die Insel mehrere Zoomstufen?
- Muss die Gesamtinsel groesser sein als ein einzelner Bildschirm?
- Wie wird verhindert, dass die Insel wie ein ueberfuelltes Brettspiel wirkt?
- Welche Informationen gehoeren in World View, Island View und spaetere
  Detailansichten?

Entscheidung:

- M3 erzeugt noch keine mobile Runtime-Preview.
- M3 definiert die Fragen, die eine spaetere Debug-Greybox beantworten muss.

## 7. Warum Dies Kein Finales Inselbild Ist

Die Greybox ist nur eine Produktionshilfe.

Sie darf:

- Metriken pruefen,
- Sockets sichtbar machen,
- Footprints vergleichen,
- Status und Expansion kontrollieren,
- Mobile-Lesbarkeit vorbereiten.

Sie darf nicht:

- als fertiges Inselbild gelten,
- als Style-Referenz fuer finale Kunst missverstanden werden,
- `frame_started` oder andere Bauassets freigeben,
- Asset-Produktion ersetzen,
- Code-Freigabe ausloesen.

## 8. Naechster Erlaubter Schritt

Nach diesem Planungsblock ist erlaubt:

- eine tatsaechliche sichtbare Debug-Greybox-Preview erzeugen und pruefen,
- oder Metriken/Layout nachbessern, falls die Planung bereits offene Probleme
  zeigt.

Weiterhin nicht erlaubt:

- finales Inselbild,
- neue Spielassets,
- PNGs im Asset-Ordner,
- `frame_started`,
- Bauzustands-Fortsetzung,
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

## 9. Stop-Regeln

Stoppen, wenn:

- aus einer Debug-Greybox ein finales Inselbild abgeleitet werden soll,
- eine Greybox ohne Status-Legende entsteht,
- ein Plot ohne sichtbaren Socket bewertet werden soll,
- ein Weg ohne pruefbare Verbindung entsteht,
- ein Gebaeude-Footprint ohne Sicherheitsabstand eingezeichnet wird,
- das Starterlayout weniger als sieben funktionale Slots zeigt,
- die Ausbauinsel nicht mindestens 12 geplante Slots plausibel vorbereitet,
- Asset-Produktion gestartet wird, bevor die Greybox visuell geprueft wurde,
- `frame_started` wieder aufgenommen wird,
- Code geschrieben wird,
- PNGs im Asset-Ordner veraendert werden.

## 10. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- Zweck und Grenzen der Greybox-Preview klar sind,
- alle sichtbaren Debug-Elemente definiert sind,
- die M2-Plotstruktur uebernommen wurde,
- Plot-Status eindeutig zugeordnet sind,
- Preview-Dateien nur geplant und nicht als Spielassets behandelt werden,
- Pruefkriterien fuer Kapazitaet, Sockets, Wege, Footprints und
  Sicherheitszonen vorhanden sind,
- Mobile-Lesbarkeitsfragen dokumentiert sind,
- Assets und Code weiterhin blockiert bleiben.
