# Phase 2G-M7: Capability Greybox Plan

Status: `Planung gestartet / keine Preview-PNGs erzeugt`

## 1. Zweck

Dieses Dokument plant die naechste Debug-Greybox fuer das Talvori-
Insel-Masterlayout. Die Greybox darf keine festen Gebaeudeplaetze mehr
zeigen. Sie soll abstrakte Plot-Slots mit Capabilities, Unlock-Status,
Nutzerwaehlbarkeit, Anchors, Sockets und Footprints sichtbar pruefbar machen.

Die Capability-Greybox ist:

- Dokumentations- und Debugmaterial,
- kein Spielasset,
- kein finales Inselbild,
- keine Codefreigabe,
- keine Asset-Freigabe.

## 2. Ziel Der Capability-Greybox

Die Capability-Greybox ersetzt die feste Variante-B-Lesart.

Variante B bleibt hoechstens eine raeumliche Testform. Ihre alten Labels wie
`starter_home`, `garden_west` oder `market_square` duerfen nicht mehr als
feste Bauplaetze gelesen werden. Stattdessen zeigt M7 neutrale Plot-Slots,
die mehrere kompatible Nutzungen tragen koennen.

Die Greybox soll pruefen:

- ob flexible Plot-Capabilities visuell planbar sind,
- ob Nutzerwahl statt fester Gebaeudeabfolge sichtbar wird,
- ob mehrere kompatible Funktionen pro Plot verstaendlich bleiben,
- ob technische Debugdaten lesbar bleiben, ohne die Ansicht zu ueberladen,
- ob spaetere Asset-Prompts nicht wieder von festen Rollen ausgehen.

## 3. Umbenennung Alter Debug-Labels

Die folgende Umbenennung ist Pflicht fuer die naechste Capability-Greybox.

| Altes Debug-Label | Neues Capability-Label |
| --- | --- |
| `starter_home` | `core_plot_a` |
| `garden_west` | `core_plot_b` |
| `nature_north` | `core_edge_plot_a` |
| `path_south` | `connector_plot_a` |
| `function_seed_east` | `core_plot_c` |
| `hub_seed_south` | `hub_capable_plot_a` |
| `market_square` | `hub_capable_plot_b` |
| `water_edge_east` | `edge_water_capable_plot_a` |
| `farm_southwest` | `edge_farm_capable_plot_a` |
| `neighbor_west` | `residential_capable_unlock_plot_a` |
| `nature_edge_nw` | `edge_nature_capable_plot_a` |
| `expansion_edge_se` | `expansion_socket_plot_a` |

Diese Namen sagen nicht, was dort gebaut wird. Sie sagen nur, welche
Faehigkeiten ein Plot besitzen kann.

Stop-Regel:

Keine neue Greybox mit festen Gebaeude-Rollenlabels.

## 4. Gemeinsame Plot-Metadaten

Jeder Plot in der Capability-Greybox braucht mindestens:

- `plotId`
- `plotSize`
- `allowedFunctions`
- `isUserSelectable`
- `unlockState`
- `pathSockets`
- `objectAnchors`
- `buildingFootprint`
- `requiredAdjacency`
- `notes`

Die Werte bleiben Planungs-/Debugdaten. Sie sind keine finalen Datenmodelle
und keine Implementierung.

## 5. Plot-Metadaten Fuer M7

### `core_plot_a`

- `plotSize`: `starter_medium`
- `allowedFunctions`: `home`, `garden`, `workshop`, `learningHub`,
  `decoration`
- `isUserSelectable`: `true`
- `unlockState`: `visible_start`
- `pathSockets`: `south`, `west`, `east`
- `objectAnchors`: `front_yard_anchor`, `decoration_anchor_a`,
  `decoration_anchor_b`
- `buildingFootprint`: `medium_building_footprint`
- `requiredAdjacency`: kompatibler `path` oder `connector` in Reichweite
- `notes`: erster zentraler, aber nicht vorgeschriebener Start-Plot; der
  Nutzer muss hier nicht zwingend ein Haus bauen.

### `core_plot_b`

- `plotSize`: `small_medium`
- `allowedFunctions`: `garden`, `nature`, `decoration`, `farm`, `path`,
  `home`
- `isUserSelectable`: `true`
- `unlockState`: `visible_start`
- `pathSockets`: `east`, `south`, optional `north`
- `objectAnchors`: `garden_anchor_a`, `object_anchor_a`,
  `decoration_anchor_a`
- `buildingFootprint`: `small_building_or_garden_footprint`
- `requiredAdjacency`: kompatibler Core- oder Connector-Plot
- `notes`: organischer Nachbarplot fuer Garten, kleine Struktur, Natur oder
  Deko; nicht fest als Garten verdrahten.

### `core_edge_plot_a`

- `plotSize`: `edge`
- `allowedFunctions`: `nature`, `decoration`, `path`, `garden`,
  `expansion`
- `isUserSelectable`: `true`
- `unlockState`: `visible_start`
- `pathSockets`: `south`, `west`, `east`
- `objectAnchors`: `tree_anchor_a`, `decoration_anchor_a`,
  `nature_object_anchor_a`
- `buildingFootprint`: `none_or_micro_footprint`
- `requiredAdjacency`: Natur- oder Core-Randlogik
- `notes`: sichtbarer Natur-/Randplot; er kann Starterbereich rahmen, ohne
  eine feste Naturzone zu erzwingen.

### `connector_plot_a`

- `plotSize`: `small`
- `allowedFunctions`: `path`, `decoration`, `social`, `garden`,
  `learningHub`
- `isUserSelectable`: `true`
- `unlockState`: `visible_start`
- `pathSockets`: `north`, `east`, `west`, `south`
- `objectAnchors`: `sign_anchor_a`, `decoration_anchor_a`
- `buildingFootprint`: `micro_or_none`
- `requiredAdjacency`: mindestens zwei kompatible `path_socket`-Nachbarn
- `notes`: Weg- und Verbindungsplot; darf kleine soziale oder Lernanker
  tragen, aber kein grosses Gebaeude.

### `core_plot_c`

- `plotSize`: `medium`
- `allowedFunctions`: `workshop`, `garage`, `home`, `garden`,
  `learningHub`, `decoration`, `path`
- `isUserSelectable`: `true`
- `unlockState`: `reserved_hidden`
- `pathSockets`: `west`, `south`, optional `east`
- `objectAnchors`: `object_anchor_a`, `tool_anchor_a`,
  `decoration_anchor_a`
- `buildingFootprint`: `medium_building_footprint`
- `requiredAdjacency`: `core_plot_a` oder kompatibler Connector
- `notes`: frueher Funktionsplot; kann Werkstatt, Garage, kleines Haus oder
  Lernhub tragen, sobald freigeschaltet.

### `hub_capable_plot_a`

- `plotSize`: `hub`
- `allowedFunctions`: `market`, `social`, `learningHub`, `path`,
  `decoration`, `workshop`
- `isUserSelectable`: `true`
- `unlockState`: `reserved_hidden`
- `pathSockets`: `north`, `west`, `east`, `south`
- `objectAnchors`: `social_anchor_a`, `market_anchor_a`,
  `decoration_anchor_a`
- `buildingFootprint`: `hub_building_or_square_footprint`
- `requiredAdjacency`: zentrale Wegverbindung, mindestens zwei
  `path_socket`-Nachbarn
- `notes`: hubfaehiger Plot fuer Markt, Forum, Lernzentrum oder Treffpunkt;
  nicht fest als Markt lesen.

### `hub_capable_plot_b`

- `plotSize`: `hub`
- `allowedFunctions`: `market`, `social`, `learningHub`, `food`,
  `decoration`, `path`
- `isUserSelectable`: `false`
- `unlockState`: `future_unlock`
- `pathSockets`: `north`, `west`, optional `east`
- `objectAnchors`: `market_anchor_a`, `food_anchor_a`,
  `decoration_anchor_a`
- `buildingFootprint`: `hub_building_or_square_footprint`
- `requiredAdjacency`: `hub_capable_plot_a` oder spaeterer Markt-/Social-
  Pfad
- `notes`: spaeterer hubfaehiger Ausbau, kein langer isolierter
  Marktschwanz.

### `edge_water_capable_plot_a`

- `plotSize`: `edge`
- `allowedFunctions`: `water`, `nature`, `travel`, `decoration`, `path`
- `isUserSelectable`: `false`
- `unlockState`: `future_unlock`
- `pathSockets`: `west`, optional `south`
- `objectAnchors`: `water_object_anchor_a`, `dock_anchor_a`,
  `decoration_anchor_a`
- `buildingFootprint`: `edge_micro_or_dock_footprint`
- `requiredAdjacency`: Inselrand oder spaetere Kuesten-/Wasserlogik
- `notes`: nur Wasser-/Randfaehigkeit in der Starter-Testform; echte
  Kuesten- oder Meerproduktion gehoert spaeter eher zu Theme Islands.

### `edge_farm_capable_plot_a`

- `plotSize`: `large_edge`
- `allowedFunctions`: `farm`, `garden`, `nature`, `food`, `decoration`,
  `path`
- `isUserSelectable`: `false`
- `unlockState`: `future_unlock`
- `pathSockets`: `north`, `east`
- `objectAnchors`: `field_anchor_a`, `tool_anchor_a`,
  `decoration_anchor_a`
- `buildingFootprint`: `large_open_footprint`
- `requiredAdjacency`: Rand- oder Naturuebergang
- `notes`: spaeterer Farm-/Naturuebergang, nicht als feste Farm starten.

### `residential_capable_unlock_plot_a`

- `plotSize`: `medium`
- `allowedFunctions`: `home`, `social`, `garden`, `decoration`, `path`
- `isUserSelectable`: `false`
- `unlockState`: `future_unlock`
- `pathSockets`: `east`, optional `south`
- `objectAnchors`: `front_yard_anchor`, `social_anchor_a`,
  `decoration_anchor_a`
- `buildingFootprint`: `medium_building_footprint`
- `requiredAdjacency`: Wohn-/Core- oder Connector-Nachbarschaft
- `notes`: spaeterer Wohn-/Nachbarschaftsfaehiger Plot; keine feste
  Nachbarperson oder Social-Funktion ohne eigenes Social-/Privacy-Konzept.

### `edge_nature_capable_plot_a`

- `plotSize`: `edge`
- `allowedFunctions`: `nature`, `decoration`, `path`, `expansion`
- `isUserSelectable`: `false`
- `unlockState`: `future_unlock`
- `pathSockets`: `east`, `south`
- `objectAnchors`: `tree_anchor_a`, `nature_object_anchor_a`,
  `decoration_anchor_a`
- `buildingFootprint`: `none_or_micro_footprint`
- `requiredAdjacency`: Natur- oder Randuebergang
- `notes`: spaeterer Naturrahmen fuer organische Inselwirkung.

### `expansion_socket_plot_a`

- `plotSize`: `edge`
- `allowedFunctions`: `expansion`, `path`, `nature`, `decoration`
- `isUserSelectable`: `false`
- `unlockState`: `expansion_edge`
- `pathSockets`: `west`, `north`
- `objectAnchors`: `expansion_marker_anchor`, `decoration_anchor_a`
- `buildingFootprint`: `none`
- `requiredAdjacency`: kompatibler Rand- oder Pfadanschluss
- `notes`: Anschlussstelle fuer spaetere Insel- oder Plot-Erweiterung; kein
  Gebaeudeplot.

## 6. Geplante Debug-Preview-Dateien

Geplanter Ordner:

`docs/world_design/previews/phase2g_m7_capability_greybox/`

Geplante Dateien:

1. `01_capability_plot_overview.png`
   - abstrakte Plotnamen,
   - `plotSize`,
   - `unlockState`,
   - `isUserSelectable`.
2. `02_allowed_functions_overlay.png`
   - `allowedFunctions` pro Plot sichtbar.
3. `03_anchor_socket_overlay.png`
   - `pathSockets`,
   - `objectAnchors`,
   - `buildingFootprints`.
4. `04_user_choice_flow_overlay.png`
   - Nutzer waehlt Plot,
   - System zeigt kompatible BuildOptions,
   - Nutzer bestaetigt,
   - erst dann entsteht `BuildInstance`, `Blueprint` oder `Codex`-Eintrag.
5. `README.md`
   - Zweck,
   - keine Spielassets,
   - keine finale Kunst,
   - keine Codefreigabe,
   - Pruefkriterien.

In diesem M7-Planungsblock werden keine Preview-Dateien erzeugt.

## 7. Pruefkriterien Fuer Die Capability-Greybox

Die spaetere Capability-Greybox muss pruefen:

- Sind die alten Rollenlabels vollstaendig entfernt?
- Sind Plot-Capabilities verstaendlich?
- Ist sichtbar, dass der Nutzer mehrere Optionen pro Plot haben kann?
- Ist `isUserSelectable` klar erkennbar?
- Sind `allowedFunctions` lesbar genug?
- Sind `pathSockets`, `objectAnchors` und `buildingFootprints` pruefbar?
- Gibt es weiterhin genug organische Inselwirkung?
- Wird die Ansicht durch zu viele technische Labels ueberladen?
- Braucht es zwei Versionen:
  - technische Vollansicht,
  - einfache Nutzer-/Produktansicht?
- Bleibt klar, dass Debugdaten keine finalen App-Labels sind?

## 8. Bezug Zum Personal Learning Archipelago

Diese Capability-Greybox betrifft zuerst nur die Starter-/Waldlichtung-
Testform. Sie ist kein vollstaendiges Archipel.

Sie muss aber kompatibel mit spaeteren ThemeIsland-Capabilities sein.

Spaetere Themeninseln muessen dasselbe Grundprinzip nutzen:

- Plot-Slots statt feste Gebaeudeplaetze,
- `allowedFunctions` statt harter Gebaeuderollen,
- `isUserSelectable` und `unlockState`,
- Word-to-Island Routing,
- shared Codex/Blueprint/Backlog,
- Anchors, Sockets und Footprints vor Asset-Produktion.

Beispiele:

- Eine Kuesteninsel kann `water`, `dock`, `travel`, `weather` und
  `decoration` erlauben, ohne einen festen Bootssteg zu erzwingen.
- Eine Stadtinsel kann `market`, `residential`, `transport`, `office` und
  `social` erlauben, ohne festzulegen, ob zuerst Cafe, Shop, Wohnung oder
  Station entsteht.
- Eine Farm-/Naturinsel kann `farm`, `garden`, `animals`, `tools` und
  `food` erlauben, ohne jedes Objekt sofort sichtbar zu platzieren.

## 9. Nutzerwahl-Fluss Fuer Die Greybox

Die Capability-Greybox soll den spaeteren Entscheidungsfluss pruefbar machen:

1. Nutzer waehlt einen verfuegbaren Plot.
2. System zeigt kompatible Funktionen und BuildOptions.
3. Tali/Vori kann passende Wort-/Blueprint-/Backlog-Bezuege erklaeren.
4. Nutzer entscheidet.
5. Erst danach entsteht `BuildInstance`, `BlueprintEntry`, `CodexEntry` oder
   `PlacementCandidate`.

Regel:

Wenn ein Plot mehrere Funktionen erlaubt, darf die Greybox nicht so aussehen,
als sei eine davon bereits gesetzt.

## 10. Stop-Regeln

Stoppen, wenn:

- eine neue Greybox feste Gebaeude-Rollenlabels nutzt,
- eine Capability-Greybox ohne `allowedFunctions` entsteht,
- eine Capability-Greybox ohne `isUserSelectable` entsteht,
- `unlockState` fehlt oder unklar ist,
- technische Debuglabels als spaetere Nutzerlabels gelesen werden koennen,
- keine klare Trennung zwischen technischer Debugansicht und spaeterer
  Nutzeransicht besteht,
- aus der Capability-Greybox Asset-Produktion abgeleitet wird,
- aus der Capability-Greybox Codefreigabe abgeleitet wird,
- die Greybox Word-to-Island Routing oder shared Backlog ignoriert,
- die Greybox wieder implizit Haus/Garten/Markt als feste Reihenfolge setzt.

## 11. Naechster Erlaubter Schritt

Nach diesem Dokument ist erlaubt:

- M7 fachlich pruefen,
- Plot-Metadaten nachbessern,
- danach eine tatsaechliche Debug-Capability-Greybox als Dokumentationsmaterial
  planen oder erzeugen.

Weiterhin nicht erlaubt:

- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Spielassets,
- PNGs im Asset-Ordner,
- finales Inselbild,
- `frame_started`,
- neue Bauzustaende,
- Persistenz,
- Supabase,
- SRS-/`word_progress`,
- Reward Bridge,
- Ressourcenlogik,
- Sound-/FX-Schicht.
