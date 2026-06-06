# Buildable Forest Clearing Template Metadata

Stand: 2026-06-05

Diese Datei beschreibt das aktuelle buildable Waldlichtung-Template als
menschenlesbare Metadaten- und Planungsdatei. Sie ist noch keine technische
Runtime-Konfiguration. Sie dokumentiert die begrenzte Freigabe fuer den sehr
kleinen Phase-2E-E-Code-Slice und die formale Freigabe fuer den engen lokalen
Phase-2F-Mock-Slice `foundation_complete` sowie den Start der Phase-2G-Planung,
Asset-Prompt-Vorbereitung und Anchor-/Alignment-Definition fuer
`frame_started` / Rohbau. Phase 2G ist inzwischen vollstaendig gestoppt, bis
das Waldlichtung-Masterlayout mit modularen Plot-Flaechen, Anchors, Sockets und
Footprints geplant ist. Phase 2G-M1 startet die Greybox-/Scale-/Plot-
Messplanung. Phase 2G-M2 konkretisiert erste logische Plot-Metriken und eine
Koordinaten-Greybox. Phase 2G-M3 plant die sichtbare Greybox-Preview und
Layout-Pruefung fuer das Insel-Masterlayout. Phase 2G-M4 erzeugt diese
Debug-Greybox-Previews als Dokumentationsmaterial. Phase 2G-M5 bewertet diese
Preview visuell und empfiehlt eine nachgebesserte Layoutvariante. Phase
2G-M5-B erzeugt diese Variante-B-Debug-Greybox als Dokumentationsmaterial.
Phase 2G-M5-C bereitet die manuelle Sichtpruefung vor; Nutzerentscheidung und
Layoutbestaetigung bleiben offen. Phase 2G-M6 stoppt jede Bestaetigung von
Variante B als feste Gebaeudeanordnung und startet die Planung fuer flexible
Plot-Faehigkeiten und Lernwort-Semantik. Phase 2G-M6-B vertieft diese Planung
mit Placement Decision Pipeline, Capability Matrix, Word Placement
Requirements, Visual Representation Tiers, User Choice, Ambiguity Handling,
Visual Clutter und Rebuild/Move/Personalization. Phase 2G-M6-C vertieft die
Planung mit abstrakten Datenmodell-Skizzen, Trennung von Lernfortschritt und
Baufortschritt, Browser-/Real-World-Import, Representation Priority,
Sensitive/Abstract Handling und Learning Mode Integration. Phase 2G-M6-D
vertieft die Planung mit Progression ohne feste Baureihenfolge, freier
Erstwahl, Import-Governance/Privacy/Safety, Nutzerziel-/Kategorie-
Priorisierung und Anforderungen an die naechste Capability-Greybox. Phase
2G-M6-E erweitert die Planung um Themeninseln und das Personal Learning
Archipelago; die Waldlichtung bleibt Starter-/Testform und muss nicht alle
Lernwelten aufnehmen. Phase 2G-M6-F vertieft die Verbindungen zwischen
mehreren Inseln: Archipel-Navigation, Shared Codex/Blueprint/Backlog,
Cross-Island Word Routing, Island Slot Lifecycle, Ownership/Identity und
UX-Komplexitaetsschutz. Phase 2G-M7 plant eine abstrakte Capability-Greybox,
in der feste Variante-B-Rollenlabels durch neutrale Plot-Slots mit
Capabilities ersetzt werden. Phase 2G-M7-B erzeugt die geplanten
Debug-Capability-Greybox-Previews als Dokumentationsmaterial. Phase 2G-M7-C
bewertet diese Previews visuell: M7-B ist als technische Debug-Greybox
brauchbar, aber nicht als Nutzeransicht. Phase 2G-M8 startet den Research- und
Planungsblock fuer World Depth, Zoom-/Container-System, Gameplay-Motivation,
Retention und faire Monetarisierungsgrundlagen. M8 klaert, dass
`objectAnchors` optionale technische Moeglichkeiten sind und nicht als
Pflichtobjekte gelesen werden duerfen.

Fuehrende Dokumente:

- `docs/world_design/235-world-production-roadmap-and-checklists.md`
- `docs/world_design/236-buildable-forest-clearing-template-concept.md`
- `docs/world_design/237-buildable-forest-clearing-greybox-layout.md`
- `docs/world_design/238-multi-scale-world-and-interior-system.md`
- `docs/world_design/239-world-scale-and-dimension-rules.md`
- `docs/world_design/240-private-island-state-system.md`
- `docs/world_design/245-build-alignment-and-anchor-system.md`
- `docs/world_design/246-island-master-layout-and-modular-plot-system.md`
- `docs/world_design/247-island-greybox-scale-and-plot-metrics.md`
- `docs/world_design/248-island-plot-metrics-and-greybox-layout.md`
- `docs/world_design/249-island-greybox-preview-plan.md`
- `docs/world_design/250-island-greybox-layout-review.md`
- `docs/world_design/252-flexible-plot-placement-and-learning-semantics.md`
- `docs/world_design/253-capability-greybox-plan.md`
- `docs/world_design/254-capability-greybox-visual-review.md`
- `docs/world_design/255-world-depth-gameplay-retention-research.md`

## 1. Template-Identitaet

- `templateId`: `buildable_forest_clearing`
- `status`: `2E-E bestanden / 2F bestanden / 2G gestoppt / 2G-M8 World Depth Research gestartet`
- `phase`: `2E-B / 2E-C / 2E-D / 2E-E / 2F abgeschlossen / 2G gestoppt / 2G-M6 flexible Plot Placement`
- `role`: `Island View Core/Base with foundation_started and foundation_complete overlay metadata; current forest clearing is StarterCorePlot, not full island master layout`
- `assetPaths`:
  - `base`: `assets/images/world/buildable_islands/forest_clearing/base.png`
  - `foundation_started`: `assets/images/world/buildable_islands/forest_clearing/foundation_started.png`
  - `foundation_complete`: `assets/images/world/buildable_islands/forest_clearing/foundation_complete.png`
  - `frame_started`: nicht vorhanden / nicht freigegeben / geloeschter Kandidat
- `codeAllowed`:
  - `phase2EE`: `true`, nur fuer den abgeschlossenen sehr kleinen
    Phase-2E-E-Code-Slice
  - `phase2F`: `true`, nur fuer den engen lokalen Phase-2F-Mock-Slice
    `foundation_started -> foundation_complete`
  - `phase2G`: `false`, Phase 2G ist gestoppt; Code und weitere
    Asset-Erzeugung bleiben bis IslandMasterLayout, Plot-Typ, Anchor,
    Footprint, Socket-/Anschlusskonzept, Preview, Device-Check und Freigabe
    blockiert.
  - `phase2GM1`: `false` fuer Code/Assets; erlaubt nur weitere
    Greybox-/Scale-/Plot-Messplanung.
  - `phase2GM2`: `false` fuer Code/Assets; erlaubt nur logische
    Plot-Metrik- und Greybox-Planung.
  - `phase2GM3`: `false` fuer Code/Assets; erlaubt nur Planung einer
    sichtbaren Debug-Greybox-Preview und Layout-Pruefung.
  - `phase2GM4`: `false` fuer Code/Assets; erlaubt nur
    Dokumentations-/Debug-Preview-Dateien ausserhalb des Asset-Ordners.
  - `phase2GM5`: `false` fuer Code/Assets; erlaubt nur visuelle
    Greybox-Bewertung, Layout-Nachbesserungsplanung und Variantenvergleich.
  - `phase2GM5B`: `false` fuer Code/Assets; erlaubt nur die erzeugten
    Variante-B-Dokumentations-/Debug-Preview-Dateien ausserhalb des
    Asset-Ordners und die manuelle visuelle Pruefung.
  - `phase2GM5C`: `false` fuer Code/Assets; erlaubt nur das
    Pruefprotokoll zur manuellen Variante-B-Sichtpruefung und die spaetere
    Nutzerentscheidung.
  - `phase2GM6`: `false` fuer Code/Assets; erlaubt nur Planung von
    flexiblen Plot-Faehigkeiten, Nutzerplatzierung, Lernwort-Semantik,
    Blueprints, Backlogs und spaeteren Greybox-Umbenennungen.
  - `phase2GM6B`: `false` fuer Code/Assets; erlaubt nur
    Entscheidungslogik fuer Placement Pipeline, Capability Matrix,
    Word Placement Requirements, Representation Tiers, User Choice,
    Ambiguity, Visual Clutter und Rebuild/Move-Fragen.
  - `phase2GM6C`: `false` fuer Code/Assets; erlaubt nur abstrakte
    Datenmodell-Skizzen, Learning-vs-Build-Trennung, Import-Workflow,
    Representation Priority, Sensitive/Abstract Handling und
    Learning-Mode-Integration.
  - `phase2GM6D`: `false` fuer Code/Assets; erlaubt nur Progression ohne
    Zwangsreihenfolge, Free-Start-Onboarding, Import-Governance/Privacy/Safety,
    Nutzerziel-/Kategorie-Priorisierung und Anforderungen an eine spaetere
    abstrakte Capability-Greybox.
  - `phase2GM6E`: `false` fuer Code/Assets; erlaubt nur Planung von
    Themeninseln, Personal Learning Archipelago, Word-to-Island Routing,
    Free/Paid-Prinzipien und Production Scope Control.
  - `phase2GM6F`: `false` fuer Code/Assets; erlaubt nur Planung von
    Archipel-Navigation, Shared Codex/Blueprint/Backlog, Cross-Island Word
    Routing, Island Slot Lifecycle, Ownership/Identity und UX-Komplexitaet.
  - `phase2GM7`: `false` fuer Code/Assets; erlaubt nur Planung einer
    abstrakten Capability-Greybox mit neutralen Plot-Slots,
    `allowedFunctions`, `isUserSelectable`, `unlockState`, Anchors, Sockets
    und Footprints. Preview-PNGs wurden in diesem Block nicht erzeugt.
  - `phase2GM7B`: `false` fuer Code/Assets; erlaubt nur
    Dokumentations-/Debug-Preview-Dateien unter
    `docs/world_design/previews/phase2g_m7_capability_greybox/`.
    Die Dateien sind keine Spielassets und geben keine Code- oder
    Assetfreigabe.
  - `phase2GM7C`: `false` fuer Code/Assets; erlaubt nur visuelle
    Dokumentationspruefung der M7-B-Capability-Greybox und Planung einer
    moeglichen vereinfachten Nutzer-/Produktansicht.
  - `phase2GM8`: `false` fuer Code/Assets; erlaubt nur Research und Planung
    fuer World Depth, Zoom-/Container-System, Gameplay-Motivation, Retention
    und faire Monetarisierungsgrundlagen.

Dieses Template ist code-freigegeben fuer:

- den abgeschlossenen kleinen lokalen Phase-2E-E-Mock-Slice,
- den abgeschlossenen engen lokalen Phase-2F-Mock-Slice `foundation_started ->
  foundation_complete`.

Jede Nutzung ausserhalb dieser Scopes braucht eine neue Freigabeentscheidung.
`frame_started` / Rohbau ist aktuell gestoppt. Der fruehere lokale
`frame_started.png`-Kandidat war nicht freigegeben und wurde geloescht. Vor
weiterer Rohbau-Asset-Arbeit sind das Anchor-/Alignment-System aus
`docs/world_design/245-build-alignment-and-anchor-system.md` und das
Island-Masterlayout aus
`docs/world_design/246-island-master-layout-and-modular-plot-system.md`
fuehrend. Die Plot-Metrik-Planung aus
`docs/world_design/247-island-greybox-scale-and-plot-metrics.md` definiert die
aktuelle Waldlichtung als `StarterCorePlot` und blockiert weitere Assets, bis
Plotgroesse, Sockets, Footprints und Sicherheitszonen konkreter sind.
`docs/world_design/248-island-plot-metrics-and-greybox-layout.md`
konkretisiert diese Planung mit `P = 100 x 72gu`, `starter_home_plot = 1.5P`
und einer ersten Koordinaten-Greybox. Diese Werte sind keine finalen
Asset-Pixel. `docs/world_design/249-island-greybox-preview-plan.md` definiert
als naechsten Schritt eine sichtbare Debug-Greybox mit Plot-Status, Socket-,
Weg-, Footprint- und Sicherheitszonen-Overlays. In diesem Template-Block
wurden keine Preview-PNGs erzeugt. Phase 2G-M4 erzeugt die geplanten
Debug-Greybox-Previews unter
`docs/world_design/previews/phase2g_m3_island_greybox/`; diese Dateien sind
Dokumentationsmaterial, keine Spielassets und keine Codefreigabe.
`docs/world_design/250-island-greybox-layout-review.md` bewertet M4 als
technisch pruefbar, aber visuell noch nicht bestaetigt. Die aktuelle Struktur
wirkt zu linear/rasterhaft; `market_square` haengt zu stark unter
`hub_seed_south`, und `water_edge_east` ist zu lang diagonal angebunden.
Die Variante-B-Debug-Greybox wurde daraufhin unter
`docs/world_design/previews/phase2g_m5_island_greybox_variant_b/` erzeugt.
Sie ist Dokumentationsmaterial, keine Spielasset-Erzeugung und keine
Freigabe. Sie soll manuell visuell geprueft werden, bevor das Masterlayout
bestaetigt oder erneut nachgebessert wird. Das Pruefprotokoll fuer diese
manuelle Sichtpruefung liegt in
`docs/world_design/251-island-greybox-variant-b-manual-review.md`.
Nach der Nutzerpruefung darf Variante B nicht als starre Gebaeudeanordnung
bestaetigt werden. Die fuehrende Planung fuer flexible Plot-Faehigkeiten und
Lernwort-Semantik liegt in
`docs/world_design/252-flexible-plot-placement-and-learning-semantics.md`.
Die visuelle M7-C-Pruefung liegt in
`docs/world_design/254-capability-greybox-visual-review.md`; M7-B ist nur als
technische Debug-Greybox brauchbar. Die M8-Planung in
`docs/world_design/255-world-depth-gameplay-retention-research.md` ergaenzt,
dass `objectAnchors` optionale technische Anker sind und dass kleinere
Woerter, Container und Interaktionen ueber Depth-/Zoom-Ebenen statt ueber eine
ueberladene Island View geloest werden muessen.

## 2. Zweck Des Assets

Das Base-Asset zeigt nur den Core/`IslandBaseState`.

Es enthaelt:

- eine natuerliche Waldlichtung als Island-View-Core,
- eine vorbereitete zentrale Bauflaeche,
- plausible Randbereiche fuer spaetere Erweiterung und Docking.

Es enthaelt nicht:

- Gebaeude,
- Innenraeume,
- Object Detail Views,
- `foundation_started` im Base-Asset,
- `foundation_complete` im Base-Asset,
- fertige Wege,
- Placed Items.

Wachstum kommt spaeter ueber:

- `IslandExpansionState`,
- `PlacedWorldItemState`,
- `BuildAreaState`,
- `Docking/ConnectorState`,
- `InteriorState`,
- `ObjectDetailState`.

Das Base-Asset ist Grundlage fuer das separate `foundation_started`-Overlay,
und das separate `foundation_complete`-Overlay, enthaelt diese Overlays aber
nicht selbst.

## 3. Visuelle Bewertung

Vorlaeufige Sichtpruefung:

- `main_build_area` ist zentral und ruhig erkennbar.
- `future_expansion_area` oben/rechts ist plausibel.
- `dockingCandidates` links und unten/rechts sind plausibel.
- Groessenverhaeltnisse wirken fuer Island View brauchbar.
- Keine fertigen Gebaeude sichtbar.
- Keine UI-/Marker-Optik sichtbar.
- `foundation_started` existiert als separates transparentes Overlay.
- Das Overlay sitzt vorlaeufig sauber auf der `main_build_area`.
- Das Overlay wirkt wie ein frueher Fundamentansatz, nicht wie UI oder Marker.
- Das Overlay ist fuer den kleinen lokalen Phase-2E-E-Mock-Slice freigegeben.
- `foundation_complete` existiert als separates transparentes Overlay.
- `foundation_complete` wurde lokal mit drei Preview-Zustaenden geprueft:
  Base allein, Base + `foundation_started`, Base + `foundation_complete`.
- `foundation_complete` sitzt plausibel auf der `main_build_area`.
- `foundation_complete` wirkt als plausibler naechster Zustand nach
  `foundation_started`: vollstaendiger Sockel / vollstaendiges Fundament,
  aber weiterhin kein Gebaeudeaufbau.
- `foundation_complete` enthaelt kein Haus, keine Waende und kein Dach.
- `foundation_complete` zeigt keine UI-/Marker-Optik, hat transparente Ecken
  und keine sichtbaren Chroma-Key-Reste.
- `foundation_complete` ist formal fuer den engen lokalen Phase-2F-Mock-Slice
  freigegeben.
- `frame_started` ist gestoppt und nicht vorhanden/freigegeben.
- Grund: Einzelne Bauzustaende koennen nicht sinnvoll weitergebaut werden,
  solange Inselgroesse, Plot-Typ, Anchors, Sockets, Footprints und
  Anschlussregeln nicht als Gesamtsystem definiert sind.
- Die aktuelle Waldlichtung wird fuer die Masterlayout-Planung nur als
  `StarterCorePlot` bewertet, nicht als vollstaendige private Insel.

Diese Bewertung wurde durch eine isolierte App-/Preview-Harness-Pruefung
ergaenzt und stuetzt die dokumentierten Freigabeentscheidungen fuer Phase 2E-E
und Phase 2F.

## 4. Zonen

### `main_build_area`

- Lage: zentral / leicht vorne.
- Zweck: erstes Fundament, spaeter kleines Haus/Huette.
- Phase 2E sichtbar/interaktiv: ja.
- Platz fuer `foundation_started`: ja.
- Platz fuer `foundation_complete`: ja, lokal vorgeprueft.
- Hinweise: nicht durch Baeume oder Felsen blockiert.

### `future_expansion_area`

- Lage: oben/rechts erhoehte offene Plateauflaeche.
- Zweck: spaetere zweite BuildZone, Bibliothek, Kategoriegebaeude oder
  Land-Erweiterung.
- Phase 2E sichtbar/interaktiv: nein.

### `docking_candidate_left`

- Lage: linke flache Fels-/Graskante.
- Zweck: spaeterer Connector-/Docking-Anschluss.
- Phase 2E sichtbar/interaktiv: nein.

### `docking_candidate_lower_right`

- Lage: untere/rechte offene Kante.
- Zweck: spaeterer Connector-/Docking-Anschluss oder Erweiterungsweg.
- Phase 2E sichtbar/interaktiv: nein.

### `decoration_areas`

- Lage: Randbereiche mit Gras, Bueschen, Blumen, Wurzeln und Steinen.
- Zweck: spaetere Deko ohne Blockade der Hauptbauflaeche.
- Phase 2E sichtbar/interaktiv: nein.

### `blocked_areas`

- Lage: Felskanten, Baumgruppen, Unterbau, dicht bewachsene Raender.
- Zweck: Schutz vor falscher Platzierung.
- Phase 2E sichtbar/interaktiv: nein.

### `path_candidates`

- Lage: vom Zentrum Richtung links und unten/rechts denkbar.
- Zweck: spaetere Wege, Lichtpunkte oder Verbindung zu Docking.
- Phase 2E sichtbar/interaktiv: nein.

## 5. Anker-Felder

Alle Werte sind relativ zum Template-Asset mit `1536 x 1024` Pixeln gedacht.
Screen-Pixel werden daraus erst durch den Renderer abgeleitet.

- `mainBuildAreaAnchor`:
  - asset local: `(785, 520)`
  - normalized: `(0.511, 0.508)`
  - Begruendung: Mittelpunkt der ruhigen zentralen Bauflaeche.
- `foundationOverlayAnchor`:
  - asset local: `(785, 520)`
  - normalized: `(0.511, 0.508)`
  - Begruendung: Mittelpunkt des sichtbaren `foundation_started`-Overlays.
- `foundationOverlayScale`:
  - `1.0` bei identischem Base-/Overlay-Canvas `1536 x 1024`
  - keine separate Bildstreckung noetig
  - sichtbarer Overlay-Bereich: asset local `(575, 422)` bis `(995, 618)`,
    normalized `(0.374, 0.412)` bis `(0.648, 0.604)`
- `foundationCompleteOverlayAnchor`:
  - asset local: `(785, 520)`
  - normalized: `(0.511, 0.508)`
  - lokale Preview: Overlay sitzt plausibel auf derselben `main_build_area`
    und nutzt denselben `1536 x 1024` Canvas
  - fuer den engen lokalen Phase-2F-Mock-Slice darf derselbe
    `mainBuildAreaAnchor` / `foundationOverlayAnchor` als lokaler Mock-Anker
    genutzt werden
- `foundationCompleteOverlayScale`:
  - `TBD` fuer spaetere praezise Runtime-Konfiguration
  - lokale Preview: keine Bildstreckung noetig, da gleicher Canvas
  - fuer den engen lokalen Phase-2F-Mock-Slice ist Canvas-Scale `1.0` erlaubt
- `focusCameraTarget`:
  - asset local: `(785, 520)`
  - normalized: `(0.511, 0.508)`
  - Begruendung: haelt `main_build_area` in der Island-View-Fokusansicht
    zentral sichtbar.
- `visualBounds`:
  - asset local: `(48, 29)` bis `(1475, 971)`
  - normalized: `(0.031, 0.028)` bis `(0.960, 0.948)`
  - gemessen aus der sichtbaren Alpha-Bounding-Box von `base.png`
- `logicalBounds`:
  - vorlaeufig identisch mit `visualBounds`
  - normalized: `(0.031, 0.028)` bis `(0.960, 0.948)`
  - spaetere polygonale Insel-/Alpha-Hitshape kann diese Grobbounds ersetzen,
    ist fuer Phase 2E aber nicht noetig.
- `hitTestShape`:
  - shape: `ellipse`
  - center: `(0.511, 0.508)`
  - radius: `(0.180, 0.120)`
  - Full-Portrait-Preview-Tapziel: ca. `148 x 66` Screen-Pixel bei 410 px
    Inselbreite, also groesser als ein kleines Mindest-Tapziel.
- `placementBounds`:
  - shape: `rect`
  - asset local ca. `(545, 394)` bis `(1029, 650)`
  - normalized: `(0.355, 0.385)` bis `(0.670, 0.635)`
  - Zweck: erster Fundament-/Haus-/Vorplatz-Bereich innerhalb der
    `main_build_area`.

### Phase-2G Anchor-/Footprint-Ergaenzung Fuer `foundation_complete`

Diese Werte gelten fuer Asset-Prompts, Debug-Overlays und spaetere
Template-Metadaten. Sie sind Asset-lokale Pixelwerte im `1536 x 1024` Canvas.

- `foundationCompleteReferenceVisibleBounds`: `(525, 386)` bis `(1045, 653)`
- `foundationCompleteReferenceCenter`: `(785, 519.5)`
- `build_center`: `(785, 520)`
- `foundation_complete_outer_polygon`:
  - `(785, 386)`
  - `(950, 420)`
  - `(1045, 505)`
  - `(1015, 585)`
  - `(900, 650)`
  - `(785, 653)`
  - `(650, 650)`
  - `(545, 585)`
  - `(525, 515)`
  - `(610, 425)`
- `safe_inner_build_polygon`:
  - `(785, 445)`
  - `(895, 470)`
  - `(930, 545)`
  - `(875, 610)`
  - `(785, 620)`
  - `(695, 610)`
  - `(640, 545)`
  - `(675, 470)`
- `max_frame_footprint_polygon`:
  - `(785, 420)`
  - `(925, 455)`
  - `(970, 545)`
  - `(905, 630)`
  - `(785, 640)`
  - `(665, 630)`
  - `(600, 545)`
  - `(645, 455)`
- `supportAnchors`:
  - `rear_left_support`: `(690, 475)`
  - `rear_right_support`: `(880, 475)`
  - `front_left_support`: `(690, 585)`
  - `front_right_support`: `(880, 585)`
  - `mid_support_center`: `(785, 520)`
  - `mid_support_rear`: `(785, 465)`
  - `mid_support_front`: `(785, 600)`
- `supportTolerance`: `+/- 16 px` horizontal, `+/- 12 px` vertical
- `contactPointRadius`: maximal ca. `18 x 12 px` fuer kleine Fussplatten
- `frameStartedMaxSilhouetteBounds`: grob `(600, 315)` bis `(970, 705)`

Regel:

- `frame_started`-Pfosten/Fuesse muessen auf diesen Support-Ankern oder
  innerhalb des `safe_inner_build_polygon` sitzen.
- Sichtbare Fussplatten duerfen nicht ausserhalb des
  `max_frame_footprint_polygon` auf Gras/Erde landen.
- Zentrum-Alignment allein ist fuer `frame_started` nicht ausreichend.
- Vor Freigabe ist eine Debug-Overlay-Pruefung mit
  `foundation_complete + frame_started` Pflicht.

## 6. State-/Modul-Regeln

- Base ist `IslandBaseState`, nicht vollstaendiger Ausbau.
- Gebaeude werden spaeter `PlacedWorldItemState`.
- Land-Erweiterungen werden spaeter `IslandExpansionState`.
- `foundation_started` ist als eigenes transparentes Overlay vorhanden und nur
  fuer den kleinen lokalen Phase-2E-E-Mock-Slice freigegeben.
- `foundation_complete` ist als eigenes transparentes Overlay vorhanden und
  fuer den engen lokalen Phase-2F-Mock-Slice freigegeben.
- Geplante `BuildAreaState`-Reihenfolge fuer diesen Buildplatz:
  `empty -> foundation_started -> foundation_complete -> frame_started`.
- `foundation_complete` ersetzt `foundation_started` visuell, statt dauerhaft
  darueber gestapelt zu werden.
- `frame_started` ist nur geplant: erster Rohbauzustand nach
  `foundation_complete`, weiterhin als `BuildAreaState`/Overlay, nicht als
  `PlacedWorldItem`.
- `frame_started` hat einen vorbereiteten Asset-Prompt in
  `docs/world_design/244-frame-started-asset-prompt.md`.
- Der lokale `frame_started.png`-Kandidat wurde nicht freigegeben und
  geloescht.
- Weitere `frame_started`-Arbeit ist blockiert, bis die
  Masterlayout-/Plot-Regeln aus
  `docs/world_design/246-island-master-layout-and-modular-plot-system.md` und
  die Anchor-/Footprint-Regeln aus
  `docs/world_design/245-build-alignment-and-anchor-system.md` angewendet
  wurden.
- Empfohlene Materialrichtung fuer `frame_started`: leichter Holzrahmen mit
  hoechstens kleinen Stein-/Erdkontaktpunkten auf dem Fundament.
- `frame_started` braucht vor weiterer Asset-Erzeugung oder Asset-
  Nachbesserung einen definierten Plot-Typ, Anchor, Footprint,
  Anschluss-/Socket-Konzept und einen Bezug auf die Anchor-/Footprint-Regeln
  aus `245`; vor Code braucht es einen eigenen Preview-/Device-Check mit
  dokumentierter Freigabe.
- Innenraeume sind eigene `InteriorState`.
- Objektansichten sind eigene `ObjectDetailState`.
- Keine spaeteren Items duerfen in Base eingebrannt werden.

## 7. Kategorie-Kompatibilitaet

- `categoryNeutral`: true
- Keine harte Kategoriebindung.
- Geeignet fuer allgemeines erstes Lernen.

Spaetere Kategorien laufen ueber Templates/Varianten:

- Reisen
- Gesundheit
- Alltag
- Business
- Schule
- Essen
- Technik
- Kultur

## 8. Scale-/Dimension-Check

Vorlaeufige Einschaetzung:

- Genug Platz fuer kleines Haus/Huette: ja.
- Genug Platz fuer Hof/Vorplatz: ja.
- Genug Platz fuer ersten Weg/Lichtpunkt: ja.
- Genug Platz fuer spaetere Deko-/Naturflaechen: ja.
- Auto wird nicht in Phase 2E gebaut, aber die Insel wirkt nicht grundsaetzlich
  zu klein fuer spaetere Aussenobjekte.
- Interior-/Object-Detail-Objekte gehoeren nicht in Island View.
- Kleine Objektwoerter gehoeren je nach Semantik eher in `InteriorView`,
  `ObjectView`, `ContainerOpenView` oder `DetailInteractionView` als dauerhaft
  in die Island View.
- `objectAnchors` sind optionale moegliche Objekt-, Container- oder
  Interaktionspunkte. Sie erzeugen keine Pflicht fuer sichtbare Objekte.
- `foundation_complete` wirkt im lokalen Preview groesser/stabiler als
  `foundation_started`, blockiert aber weiterhin nicht grundsaetzlich
  Haus/Huette, Hof/Vorplatz, ersten Weg oder Expansion.

Diese Einschaetzung wurde in einer isolierten App-/Preview-Harness-Pruefung
und einer temporaeren visuellen PNG-Komposition bestaetigt. Die formale
Phase-2F-Freigabe fuer den engen lokalen Mock-Slice ist in Abschnitt 12
dokumentiert; jede groessere produktive Nutzung bleibt eine getrennte
Entscheidung.

## 9. Phase-2E-/2F-/2G-Grenzen

In diesem Template-Block gilt:

- Kein Code.
- Keine App-Integration des `foundation_started`-Overlays.
- Keine App-Integration des `foundation_complete`-Overlays.
- Keine Persistenz.
- Keine Reward Bridge.
- Keine SRS-/`word_progress`-Aenderung.
- Kein echtes Expansion-System.
- Kein PlacedItem-System.
- Kein Interior/ObjectDetail.
- Keine Phase-2G-Asset-Erzeugung.
- Keine Phase-2G-App-Integration.
- Keine `frame_started`-Freigabe ohne Anchor-/Footprint- und
  Debug-Overlay-Check.
- Kein neues Bauasset ohne Plot-Typ, Anchor, Footprint und
  Anschluss-/Socket-Konzept.
- Kein neues Inselasset ohne Masterlayout.
- Kein Plot-Asset ohne Plotgroesse.
- Kein Gebaeudeasset ohne Gebaeude-Footprint.
- Kein Wegasset ohne Socket-Kompatibilitaet.
- Kein Dekoasset ohne Deko-Sicherheitszone.
- Kein `objectAnchor` als Pflichtobjekt interpretieren.
- Keine sichtbare Ueberfuellung durch zu viele Objekte auf einer Ebene.
- Keine technische Anchor-/Capability-Ansicht als Nutzeransicht verwenden.
- Keine Container-/Zoom-Logik ohne Depth-System.
- Keine reine Museumsansicht ohne Interaktion oder Challenge.
- Keine Retention-Mechanik ohne Fairness-/Ethikpruefung.
- Keine Monetarisierung ohne eigenes Dokument.
- Keine manipulative Pay-to-Win- oder Dark-Pattern-Mechanik.

## 10. Device-/Preview-Check

- `devicePreviewCheckDone`: ja, als lokale Device-Mock-Preview.
- `method`: isolierter Widget-Test-Harness plus temporaere visuelle
  PNG-Komposition.
- `widgetHarness`: `test/world_design/buildable_forest_clearing_template_preview_test.dart`
- `widgetHarnessChecks`:
  - PNG-Dateien existieren und melden `1536 x 1024` im Header.
  - `mainBuildAreaAnchor`, `foundationOverlayAnchor`, `visualBounds`,
    `logicalBounds`, `placementBounds` und `hitTestShape` sind relativ zum
    Template pruefbar.
  - Full-Portrait- und Island-View-Fokuslayout blockieren die
    `placementBounds` nicht durch reservierte UI-Zonen.
- `visualMethod`: temporaere PNG-Komposition mit 430 x 932 Portrait-Frame,
  dezent reservierten UI-Zonen, Base allein, Base + `foundation_started`,
  Debug-Bounds und naeherem Island-View-Fokus.
- `previewFiles`:
  - `/private/tmp/talvori_2e_d_forest_clearing/app_preview_base.png`
  - `/private/tmp/talvori_2e_d_forest_clearing/app_preview_foundation_bounds.png`
  - `/private/tmp/talvori_2e_d_forest_clearing/app_preview_focus_bounds.png`
  - `/private/tmp/talvori_2e_d_forest_clearing/app_preview_anchor_contact_sheet.png`
- `repoHarnessFilesCreated`: ja,
  `test/world_design/buildable_forest_clearing_template_preview_test.dart`.
- `repoPreviewFilesCreated`: nein, Preview-PNGs bleiben temporaer.
- `result`: freigegeben fuer Phase 2E-E.
- `begruendung`: Das Overlay sitzt in der Mock-Preview sauber auf der zentralen
  `main_build_area`, wirkt wie ein frueher Fundamentansatz und nicht wie UI
  oder Marker. Die Bauflaeche bleibt in Portrait lesbar, Standard-UI-Zonen
  wuerden den Bauplatz in dieser Mock-Komposition nicht verdecken, und Raum fuer
  spaeteres kleines Haus, Hof, Weg, Deko und Erweiterung bleibt plausibel.
  Die Anker-/Bounds-Werte sind fuer Phase 2E ausreichend dokumentiert. Die
  Freigabe gilt nur fuer den kleinen lokalen Phase-2E-E-Mock-Slice.

Phase-2F-Preview-Ergaenzung:

- `foundation_completePreviewDone`: ja, als lokale Vergleichs-Preview.
- `foundationCompleteVisualMethod`: temporaere PNG-Kompositionen mit
  Base allein, Base + `foundation_started`, Base + `foundation_complete` und
  Contact Sheet.
- `foundationCompletePreviewFiles`:
  - `/private/tmp/talvori_phase2f_foundation_complete_preview/01_base_only.png`
  - `/private/tmp/talvori_phase2f_foundation_complete_preview/02_base_plus_foundation_started.png`
  - `/private/tmp/talvori_phase2f_foundation_complete_preview/03_base_plus_foundation_complete.png`
  - `/private/tmp/talvori_phase2f_foundation_complete_preview/contact_sheet_base_started_complete.png`
- `foundationCompletePreviewResult`: `passt`
- `foundationCompletePreviewDecision`: formal freigegeben fuer den engen
  lokalen Phase-2F-Mock-Slice.
- `foundationCompleteDeviceCheck`: ja, Geraetepruefung nach Umsetzung
  bestanden.
- `foundationCompleteImplementationCommit`:
  `b13d2162 fix: refine foundation complete guidance flow`
- `foundationCompleteImplementationResult`: `fertig / lokaler Mock-Slice
  bestanden`

## 11. Offene Pruefungen

- Isolierter Widget-Test-Harness wurde durchgefuehrt.
- Temporaere visuelle Preview-Dateien wurden erzeugt.
- `foundation_started`-Overlay existiert und wurde visuell auf `base.png`
  vorgeprueft.
- `foundation_complete`-Overlay existiert und wurde lokal mit
  Vergleichs-Previews vorgeprueft.
- Lokales 2F-Prueffazit fuer `foundation_complete`: `passt`.
- `foundation_complete` ist fuer den engen lokalen Phase-2F-Mock-Slice
  umgesetzt und bestanden.
- Praezise `foundationCompleteOverlayAnchor`- und
  `foundationCompleteOverlayScale`-Werte bleiben fuer spaetere
  Runtime-/Produktionskonfiguration offen; der lokale 2F-Mock-Slice darf den
  identischen Canvas und den vorhandenen BuildArea-Anker verwenden.
- Eine echte physische Geraetepruefung kann optional spaeter ergaenzt werden,
  ist aber nicht Teil dieses isolierten Preview-Harness.
- Exakte Docking-, Expansion- und Path-Anker bleiben ausserhalb von Phase 2E-D.
- Freigabe- und Abschlussentscheidungen fuer Phase 2E-E und Phase 2F sind
  dokumentiert.
- `frame_started` / Rohbau ist geplant und als Asset-Prompt vorbereitet, aber
  vollstaendig gestoppt.
- Der lokale `frame_started.png`-Kandidat wurde nicht freigegeben und
  geloescht.
- Anchor-/Footprint-Regeln fuer den Aufbau auf `foundation_complete` sind in
  `docs/world_design/245-build-alignment-and-anchor-system.md` dokumentiert.
- Das Waldlichtung-Masterlayout und modulare Plot-System sind in
  `docs/world_design/246-island-master-layout-and-modular-plot-system.md`
  gestartet.
- Der Greybox-/Scale-/Plot-Messblock ist in
  `docs/world_design/247-island-greybox-scale-and-plot-metrics.md` gestartet.
- Der konkrete Plot-Metrik-/Koordinaten-Greybox-Block ist in
  `docs/world_design/248-island-plot-metrics-and-greybox-layout.md`
  gestartet.
- Der sichtbare Greybox-Preview-/Layout-Pruefblock ist in
  `docs/world_design/249-island-greybox-preview-plan.md` gestartet.
- Der Debug-Greybox-Preview-Erzeugungsblock hat die geplanten Preview-Dateien
  unter `docs/world_design/previews/phase2g_m3_island_greybox/` erzeugt.
- Preview-Dateien: `01_island_plot_greybox.png`,
  `02_socket_debug_overlay.png`, `03_footprint_debug_overlay.png`,
  `04_status_legend.png` und `README.md`.
- Die Preview-Dateien sind Dokumentationsmaterial, keine Spielassets, keine
  finale Kunst und keine Codefreigabe.
- Der visuelle Greybox-Layout-Review ist in
  `docs/world_design/250-island-greybox-layout-review.md` gestartet.
- Ergebnis: M4 ist technisch brauchbar, aber nicht visuell bestaetigt.
- Sichtbare Hauptprobleme: zu lineare `path_south -> hub_seed_south ->
  market_square`-Achse, langer Markt-Schwanz, unnatuerlich diagonale
  `water_edge_east`-Anbindung und zu rasterhafte Gesamtform.
- Empfehlung: M4 nachbessern und eine neue M5-Greybox-Variante erzeugen,
  bevorzugt Variante B aus `250`.
- Die Variante-B-Debug-Greybox wurde unter
  `docs/world_design/previews/phase2g_m5_island_greybox_variant_b/` erzeugt.
- Variante-B-Preview-Dateien: `01_island_plot_greybox_variant_b.png`,
  `02_socket_debug_overlay_variant_b.png`,
  `03_footprint_debug_overlay_variant_b.png`,
  `04_status_legend_variant_b.png` und `README.md`.
- Sichtbare Verbesserung gegenueber M4: weniger lineare Markt-/Hub-Achse,
  `market_square` naeher am Hub, `water_edge_east` klarer als Randzone,
  Starterbereich organischer durch `garden_west` und `nature_north` gerahmt.
- Variante B ist noch nicht bestaetigt; manuelle visuelle Pruefung,
  Mobile-Lesbarkeit, Footprint-/Safety-Dichte und finale Layoutentscheidung
  bleiben offen.
- Die manuelle Variante-B-Sichtpruefung wurde in
  `docs/world_design/251-island-greybox-variant-b-manual-review.md`
  vorbereitet.
- Die Sichtpruefung hat ergeben: Variante B darf nicht als finale feste
  Gebaeudeanordnung bestaetigt werden.
- Bisherige Debug-Labels wie `starter_home`, `garden_west`,
  `market_square`, `water_edge_east` oder `farm_southwest` muessen als
  flexible Plot-Slots mit Capabilities umgedeutet werden.
- Die flexible Plot-/Learning-Semantics-Planung wurde in
  `docs/world_design/252-flexible-plot-placement-and-learning-semantics.md`
  gestartet.
- Die Planung wurde in Phase 2G-M6-B vertieft: Placement Decision Pipeline,
  Plot Capability Matrix, Word Placement Requirements, Visual Representation
  Tiers, User Choice Regeln, Ambiguity Handling, Visual Clutter Regeln und
  Rebuild/Move/Personalization-Entscheidungen sind dokumentiert.
- Die Planung wurde in Phase 2G-M6-C vertieft: Abstract Data Model Sketch,
  Learning Progress vs. Build Progress, Browser Import / Real-World Word
  Intake, Representation Priority, Sensitive And Abstract Concept Handling und
  Learning Mode Integration sind dokumentiert.
- Die Planung wurde in Phase 2G-M6-D vertieft: Progression Without Forced
  Build Order, First Session And Free Start Choice, Import Governance,
  Privacy And Safety, User Goal And Category Priority und Next Greybox
  Renaming Requirements sind dokumentiert.
- Die Planung wurde in Phase 2G-M6-E vertieft: Thematic Island And
  Archipelago Strategy, Candidate Theme Islands, First Island Choice And
  Island Slots, Island Roadmap And Learning Path, Theme Islands With Flexible
  Plot Slots, Word To Island Routing, Free And Paid Island Access Principles
  und Production Scope Control sind dokumentiert.
- Die Planung wurde in Phase 2G-M6-F vertieft: Archipelago Navigation And
  World Map, Shared Codex Blueprint And Backlog Across Islands,
  Cross-Island Word Routing And Multi-Home Words, Island Slot Lifecycle,
  Island Ownership And Identity und Archipelago UX Complexity Control sind
  dokumentiert.
- Vor weiterer Asset-Freigabe fehlen: Plot-Typ, Plot-Groesse,
  Plot-Capabilities, Placement Decision Pipeline, Word Placement
  Requirements, Visual Representation Tiers, Nutzerplatzierung,
  Lernwort-Semantik, abstrakte Datenmodell-Entscheidungen, Import-/Sense-/
  Safety-Pruefung, Import-Governance/Privacy-Regeln, Onboarding fuer freie
  Erstwahl, Nutzerziel-/Kategorie-Priorisierung, Representation Priority,
  Themeninsel-/Archipel-Strategie, Word-to-Island Routing,
  Cross-Island-Routing, gemeinsamer Codex-/Blueprint-/Backlog-Plan,
  Island-Slot-Lifecycle, Ownership-/Identity-Logik,
  World Depth, Container-/Zoom-System, ObjectAnchor-Semantik,
  Interaction-/Challenge-Loop, Retention-Fairness,
  Visual-Clutter-Grenzen, Rebuild/Move-Regeln, Anschluss-/Socket-Konzept,
  visuell bestaetigte oder nachgebesserte Greybox mit abstrakten
  Capability-Labels, ThemeIsland-Roadmap, Anchor-basierte Nachbesserung,
  Alignment-Preview, Device-Check und Freigabe.

## 12. Freigabeentscheidung

- `phase2EEDecision`: `released for Phase 2E-E local mock code slice`
- `phase2EECodeAllowed`: `true`, nur fuer den abgeschlossenen kleinen lokalen
  Phase-2E-E-Mock-Slice
- `phase2FDecision`: `completed narrow Phase 2F local mock code slice`
- `phase2FCodeAllowed`: `true`, nur fuer den engen lokalen Phase-2F-Mock-Slice
- `phase2FCompletionCommit`: `b13d2162 fix: refine foundation complete guidance flow`
- `phase2GPlanningStatus`: `started in docs/world_design/243-frame-started-plan.md`
- `phase2GPromptStatus`: `prepared in docs/world_design/244-frame-started-asset-prompt.md; review open`
- `phase2GAlignmentStatus`: `required in docs/world_design/245-build-alignment-and-anchor-system.md`
- `phase2GMasterLayoutStatus`: `started in docs/world_design/246-island-master-layout-and-modular-plot-system.md`
- `phase2GM1PlotMetricsStatus`: `started in docs/world_design/247-island-greybox-scale-and-plot-metrics.md`
- `phase2GM2ConcreteMetricsStatus`: `started in docs/world_design/248-island-plot-metrics-and-greybox-layout.md`
- `phase2GM3PreviewPlanStatus`: `started in docs/world_design/249-island-greybox-preview-plan.md`
- `phase2GM4PreviewFilesStatus`: `created under docs/world_design/previews/phase2g_m3_island_greybox/`
- `phase2GM4PreviewFilesAreGameAssets`: `false`
- `phase2GM4VisualReviewStatus`: `reviewed in docs/world_design/250-island-greybox-layout-review.md; not confirmed`
- `phase2GM5LayoutReviewStatus`: `started; M4 nachbessern empfohlen`
- `phase2GM5RecommendedNextVariant`: `Variante B`
- `phase2GM5BPreviewFilesStatus`: `created under docs/world_design/previews/phase2g_m5_island_greybox_variant_b/`
- `phase2GM5BPreviewFilesAreGameAssets`: `false`
- `phase2GM5BManualReviewStatus`: `open`
- `phase2GM5CManualReviewPreparation`: `prepared in docs/world_design/251-island-greybox-variant-b-manual-review.md`
- `phase2GM5CUserDecisionStatus`: `evaluated; do not confirm Variant B as fixed building layout`
- `phase2GM6FlexiblePlotSemanticsStatus`: `started in docs/world_design/252-flexible-plot-placement-and-learning-semantics.md`
- `phase2GM6BDecisionLogicStatus`: `deepened in docs/world_design/252-flexible-plot-placement-and-learning-semantics.md sections 15-22`
- `phase2GM6CDataImportSafetyLearningStatus`: `deepened in docs/world_design/252-flexible-plot-placement-and-learning-semantics.md sections 23-28`
- `phase2GM6DProgressionOnboardingGovernanceGreyboxStatus`: `deepened in docs/world_design/252-flexible-plot-placement-and-learning-semantics.md sections 29-33`
- `phase2GM6EThemeIslandArchipelagoStatus`: `deepened in docs/world_design/252-flexible-plot-placement-and-learning-semantics.md sections 34-41`
- `phase2GM6FArchipelagoConnectionStatus`: `deepened in docs/world_design/252-flexible-plot-placement-and-learning-semantics.md sections 42-47`
- `phase2GM7CapabilityGreyboxPlanStatus`: `started in docs/world_design/253-capability-greybox-plan.md; no preview PNGs generated`
- `phase2GM7BPreviewFilesStatus`: `created under docs/world_design/previews/phase2g_m7_capability_greybox/`
- `phase2GM7BPreviewFilesAreGameAssets`: `false`
- `phase2GM7CVisualReviewStatus`: `started in docs/world_design/254-capability-greybox-visual-review.md; M7-B usable as technical debug greybox; simplified product view recommended`
- `phase2GM8WorldDepthGameplayRetentionStatus`: `started in docs/world_design/255-world-depth-gameplay-retention-research.md; objectAnchors are optional technical anchors, not required visible objects`
- `phase2GFrameStartedCandidateStatus`: `deleted, not released`
- `phase2GAssetAllowed`: `false`
- `phase2GCodeAllowed`: `false`
- `nextAllowedStep`: `M7-C-/M8-Empfehlungen pruefen; danach M7-B technisch bestaetigen/nachbessern, M7-D/M8 als vereinfachte Nutzer-/Produktansicht mit Depth-/Container-Flow planen oder Gameplay-/Retention weiter vertiefen`

Phase-2E-E-Freigabe gilt nur fuer:

- lokale Anzeige von `base.png` + `foundation_started.png`,
- `main_build_area` auf der Waldlichtung,
- lokalen Mock-Zustand `empty -> foundation_started`.

Die lokale Vorpruefung von `foundation_complete` gilt nur fuer:

- Dokumentation und Metadaten,
- lokalen visuellen Vergleich `base`, `base + foundation_started`,
  `base + foundation_complete`,
- Vorbereitung und Umsetzung des engen lokalen Phase-2F-Mock-Slices.

Die Phase-2F-Freigabe gilt ausschliesslich fuer:

- lokale Mock-Erweiterung `foundation_started -> foundation_complete`,
- Anzeige `base.png + foundation_complete.png`,
- `foundation_complete` ersetzt `foundation_started` visuell,
- kein dauerhaftes Stapeln von `foundation_started` und
  `foundation_complete`,
- direkter Tap auf den sichtbaren Folgehinweis / Fokusbereich,
- sichtbarer Folgehinweis im Zustand `foundation_started`:
  `Tippe auf das begonnene Fundament, um es fertigzustellen.`,
- visueller Fokus / Glow auf dem begonnenen Fundament oder der
  `main_build_area`,
- kurzes In-World-Feedback ohne grosse Snackbar,
- sichtbarer Abstand zwischen Fokusrahmen/Glow, Bauobjekt, In-World-Label,
  Buttons und Hinweisboxen,
- vorbereitete Feedback-ID `build.foundation.complete`,
- keine echte Audio-/FX-Implementierung.

Phase 2F ist als lokaler Proof-of-Concept bestanden. Der Slice beweist nur:

- Asset-Layering mit `base.png` + `foundation_complete.png`,
- lokale BuildState-Umschaltung `foundation_started -> foundation_complete`,
- direkten Tap-Flow ohne doppelte Bestaetigung,
- kleine In-World-Labels ohne grosse Snackbar,
- verbesserten Abstand zwischen Fokusrahmen, Bauobjekt und Label.

Der Slice beweist noch nicht:

- Rohbau / `frame_started`,
- vollstaendige Bauarchitektur,
- Balancing,
- Reward Bridge,
- Persistenz,
- Ressourcenlogik,
- Sound-/FX-Schicht,
- Expansion, PlacedItems oder Interiors/ObjectDetail.

Phase-2G-Planung gilt nur fuer:

- Definition von `frame_started` / Rohbau als naechster geplanter
  `BuildAreaState`,
- Abgrenzung zu `foundation_complete` und `building_level_1`,
- UX-, Asset-, Scope- und Stop-Regeln fuer einen spaeteren Freigabeblock.

Phase-2G-Prompt-Vorbereitung gilt nur fuer:

- Materialentscheidung und Prompt fuer einen spaeteren `frame_started`-Asset,
- Pruefung des Prompts durch den Nutzer,
- Nachbesserung des Prompts, falls noetig.

Phase-2G-Anchor-Definition gilt nur fuer:

- exakte Support-Anker auf `foundation_complete`,
- `safe_inner_build_polygon`,
- `max_frame_footprint_polygon`,
- Debug-Overlay-Gates fuer spaetere Asset-Freigabe,
- Stopp der aktuellen `frame_started`-Freigabe.

Phase-2G-Masterlayout-Planung gilt nur fuer:

- Bewertung der aktuellen Waldlichtung als `StarterCorePlot`,
- Definition von Plot-Typen,
- Definition von Plot-Sockets,
- Definition von Build-/Path-/Deko-/Expansion-Ankern,
- Stoppen weiterer Einzelassets ohne Plot-/Socket-System.

Phase-2G-M1-Plot-Messplanung gilt nur fuer:

- relative Plotgroessen,
- Mindestkapazitaet der privaten Insel,
- Bewertung der aktuellen Waldlichtung als `StarterCorePlot`,
- Socket-Typen und Kompatibilitaetsregeln,
- erste Text-Greybox,
- Definition der naechsten Messwerte.

Phase-2G-M2-Plot-Metrikplanung gilt nur fuer:

- `P = 100 x 72gu` als logische Greybox-Einheit,
- vorlaeufige Plot-, Weg-, Socket- und Sicherheitsmetriken,
- `starter_home_plot = 1.5P`,
- erste Koordinaten-Greybox,
- Trennung von Starter- und Expansion-Plots.

Phase-2G-M3-Greybox-Preview-Planung gilt nur fuer:

- sichtbare Debug-Greybox-Elemente,
- Plot-Status `visible_start`, `reserved_hidden`, `future_unlock` und
  `expansion_edge`,
- Socket-, Weg-, Footprint- und Sicherheitszonen-Overlays,
- Status-Legende,
- Pruefkriterien fuer sieben Starter-/Vorbereitungsplots und 12 bis 14
  geplante Ausbau-Slots,
- Mobile-Lesbarkeitsfragen.

Phase-2G-M4-Debug-Preview-Erzeugung gilt nur fuer:

- Dokumentations-PNGs im Ordner
  `docs/world_design/previews/phase2g_m3_island_greybox/`,
- sichtbare Plot-Greybox,
- Socket-Debug-Overlay,
- Footprint-/Safety-Overlay,
- Status- und Socket-Legende,
- README mit Prueffazit und Risiken.

Phase-2G-M5-Layout-Review gilt nur fuer:

- visuelle Bewertung der M4-Debug-Greybox,
- Benennung sichtbarer Layout-Schwaechen,
- Nachbesserungsprinzipien,
- Variantenvergleich,
- Empfehlung fuer eine neue M5-Debug-Greybox.

Phase-2G-M5-B-Debug-Preview gilt nur fuer:

- Dokumentations-/Debug-Preview-Dateien unter
  `docs/world_design/previews/phase2g_m5_island_greybox_variant_b/`,
- sichtbare Pruefung einer organischeren Variante-B-Plotstruktur,
- README-Prueffazit und Risiken,
- manuelle visuelle Pruefung als naechsten Schritt.

Phase-2G-M5-C-Sichtpruefungs-Vorbereitung gilt nur fuer:

- Pruefprotokoll in
  `docs/world_design/251-island-greybox-variant-b-manual-review.md`,
- Prueffragen und Bewertungskriterien,
- Entscheidungsmoeglichkeiten fuer die spaetere Nutzerentscheidung,
- Festhalten weiterhin blockierter Systeme.

Phase-2G-M6-Flexible-Plot-/Learning-Semantics-Planung gilt nur fuer:

- Stoppen einer finalen Variante-B-Bestaetigung als feste Gebaeudeanordnung,
- Definition flexibler Plot-Slots mit `plotSize`, `allowedFunctions`,
  Anchors, Sockets, Footprints und Nutzerwahl,
- Planung, wie Lernwoerter in Objekte, Bauteile, Szenen, Blueprints,
  Backlogs, Companion-Vorschlaege oder Codex-Eintraege uebersetzt werden,
- Vorbereitung spaeterer Greybox-Umbenennung von festen Debug-Rollen zu
  Capability-Labels.

Phase-2G-M6-B-Entscheidungslogik gilt nur fuer:

- Placement Decision Pipeline,
- Plot Capability Matrix,
- Word Placement Requirements,
- Visual Representation Tiers,
- User Choice und Suggestions,
- Ambiguity und Context Handling,
- Visual Clutter Rules,
- offene Rebuild/Move/Personalization-Regeln.

Phase-2G-M6-C-Vertiefung gilt nur fuer:

- abstrakte Datenmodell-Skizzen,
- Trennung von Learning Progress und Build Progress,
- Browser-/Real-World-Import-Workflow,
- Representation Priority und Conflict Resolution,
- Sensitive And Abstract Concept Handling,
- Learning Mode Integration,
- Stop-Regeln fuer Import, Sense-Auswahl, Safety und Lernmodus-Massenerzeugung.

Phase-2G-M6-D-Vertiefung gilt nur fuer:

- Progression ohne feste Baureihenfolge,
- freie Erstwahl in der ersten Session,
- Import Governance, Privacy und Safety,
- Nutzerziel-/Kategorie-Priorisierung,
- Anforderungen an die naechste Debug-Greybox mit abstrakten
  Capability-Labels,
- Stop-Regeln fuer Onboarding, Progression, Import, sensitive Kategorien und
  Capability-Greybox.

Phase-2G-M6-E-Vertiefung gilt nur fuer:

- Thematic Island And Archipelago Strategy,
- Candidate Theme Islands,
- First Island Choice And Island Slots,
- Island Roadmap And Learning Path,
- Theme Islands With Flexible Plot Slots,
- Word To Island Routing,
- Free And Paid Island Access Principles,
- Production Scope Control,
- Stop-Regeln gegen Alles-auf-eine-Insel, Pay-to-Win und Multi-Island-Scope-
  Explosion.

Phase-2G-M6-F-Vertiefung gilt nur fuer:

- Archipelago Navigation And World Map,
- Shared Codex Blueprint And Backlog Across Islands,
- Cross-Island Word Routing And Multi-Home Words,
- Island Slot Lifecycle,
- Island Ownership And Identity,
- Archipelago UX Complexity Control,
- Stop-Regeln fuer Archipel-Navigation, gemeinsamen Backlog, Island Slots,
  Ownership/Identity und Social-/Privacy-Trennung.

Phase-2G-M7-Capability-Greybox-Planung gilt nur fuer:

- Planung der abstrakten Capability-Greybox in
  `docs/world_design/253-capability-greybox-plan.md`,
- Umbenennung alter Variante-B-Rollenlabels in neutrale Plot-Slots,
- Definition von `plotSize`, `allowedFunctions`, `isUserSelectable`,
  `unlockState`, `pathSockets`, `objectAnchors`, `buildingFootprint`,
  `requiredAdjacency` und Hinweisen,
- Planung spaeterer Debug-Preview-Dateien unter
  `docs/world_design/previews/phase2g_m7_capability_greybox/`,
- Stop-Regeln gegen feste Gebaeude-Rollenlabels, Asset-Ableitung und
  Codefreigabe aus der Capability-Greybox.

Phase-2G-M7-B-Debug-Preview-Erzeugung gilt nur fuer:

- Dokumentations-/Debug-Preview-Dateien unter
  `docs/world_design/previews/phase2g_m7_capability_greybox/`,
- `01_capability_plot_overview.png`,
- `02_allowed_functions_overlay.png`,
- `03_anchor_socket_overlay.png`,
- `04_user_choice_flow_overlay.png`,
- `README.md`,
- visuelle Pruefung, ob abstrakte Plot-Slots, `allowedFunctions`,
  `isUserSelectable`, Anchors, Sockets, Footprints und Nutzerwahl-Flow
  verstaendlich sind.

Phase-2G-M7-C-Visual-Review gilt nur fuer:

- Review-Dokument in
  `docs/world_design/254-capability-greybox-visual-review.md`,
- Bewertung der M7-B-Previews als technische Debug-Greybox,
- Festhalten, dass M7-B nicht als Nutzeransicht verwendet werden darf,
- Empfehlung, spaeter M7-D als vereinfachte Nutzer-/Produktansicht zu planen,
- Stop-Regeln gegen Asset-/Codefreigabe aus M7-B und gegen Weiterarbeit an
  `frame_started`, solange Capability-Greybox und Nutzeransicht nicht
  geklaert sind.

Phase-2G-M8-World-Depth-/Gameplay-/Retention-Research gilt nur fuer:

- Research- und Planungsdokument in
  `docs/world_design/255-world-depth-gameplay-retention-research.md`,
- Klaerung von `IslandView`, `PlotView`, `BuildingView`, `InteriorView`,
  `ObjectView`, `ContainerOpenView` und `DetailInteractionView`,
- Klaerung, dass `objectAnchors` optionale technische Moeglichkeiten sind,
  keine Pflichtobjekte,
- Planung von Container-Objekten, Container-Entry-Ankern und inneren
  Objektankern,
- Planung von Interaction-/Challenge-Loops statt reiner Museumsansicht,
- Research-informed Ableitungen aus erfolgreichen Spielen fuer faire
  Motivation, Retention und spaetere Monetarisierungsgrundlagen.

Phase-2G-Planung und Prompt-Vorbereitung erlauben noch nicht:

- Asset-Freigabe,
- Asset-Erzeugung,
- PNG-Aenderungen,
- App-Integration,
- Code,
- Tests oder neue Runtime-Logik.

Freigabe gilt nicht fuer:

- Persistenz,
- Supabase,
- Reward Bridge,
- SRS-/`word_progress`,
- echtes Expansion-System,
- PlacedItem-System,
- Interior/ObjectDetail,
- produktive Bau-/Lernlogik,
- Ressourcenlogik,
- Audio/Sounddateien,
- Sound-/FX-Schicht.

## 13. Akzeptanzkriterien Fuer Freigabe Und Spaetere Erweiterungen

Die dokumentierte 2E-/2F-Freigabe basiert darauf, dass:

- `template.md` existiert,
- `foundation_started` existiert,
- `foundation_complete` existiert,
- Overlay visuell passt,
- Device-Screenshot geprueft wurde,
- `main_build_area` antippbar und lesbar wirkt,
- Docking/Expansion weiterhin plausibel bleibt,
- Roadmap in `235` aktualisiert wurde.

Fuer Phase 2F zusaetzlich:

- `foundation_complete` muss klar weiter als `foundation_started` wirken,
- `foundation_complete` darf weiterhin kein Haus, keine Waende und kein Dach
  enthalten,
- `foundation_complete` darf nicht wie UI, Marker oder moderne Plattform
  wirken,
- Phase 2F bleibt auf den abgeschlossenen engen lokalen Mock-Slice begrenzt.
