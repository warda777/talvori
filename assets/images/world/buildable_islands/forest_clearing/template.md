# Buildable Forest Clearing Template Metadata

Stand: 2026-06-04

Diese Datei beschreibt das aktuelle buildable Waldlichtung-Template als
menschenlesbare Metadaten- und Planungsdatei. Sie ist noch keine technische
Runtime-Konfiguration und keine Freigabe fuer Code.

Fuehrende Dokumente:

- `docs/world_design/235-world-production-roadmap-and-checklists.md`
- `docs/world_design/236-buildable-forest-clearing-template-concept.md`
- `docs/world_design/237-buildable-forest-clearing-greybox-layout.md`
- `docs/world_design/238-multi-scale-world-and-interior-system.md`
- `docs/world_design/239-world-scale-and-dimension-rules.md`
- `docs/world_design/240-private-island-state-system.md`

## 1. Template-Identitaet

- `templateId`: `buildable_forest_clearing`
- `status`: `generiert / in Pruefung`
- `phase`: `2E-B / 2E-C`
- `role`: `Island View Core/Base with foundation_started overlay metadata`
- `assetPaths`:
  - `base`: `assets/images/world/buildable_islands/forest_clearing/base.png`
  - `foundation_started`: `assets/images/world/buildable_islands/forest_clearing/foundation_started.png`
- `codeAllowed`: `false`

Dieses Template ist nicht fuer Code freigegeben, bis Device-Check,
Overlay-Pruefung und Freigabeentscheidung erfolgt sind.

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
enthaelt dieses Overlay aber nicht selbst.

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
- Das Overlay ist noch nicht final freigegeben, weil der Device-Check fehlt.

Diese Bewertung ersetzt keinen Device-Screenshot und keine finale Freigabe.

## 4. Zonen

### `main_build_area`

- Lage: zentral / leicht vorne.
- Zweck: erstes Fundament, spaeter kleines Haus/Huette.
- Phase 2E sichtbar/interaktiv: ja.
- Platz fuer `foundation_started`: ja.
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

Technische Koordinaten werden nicht geschaetzt. Sie bleiben bis Device- und
Layout-Check offen.

- `mainBuildAreaAnchor`: TBD after device/layout check
- `foundationOverlayAnchor`: TBD after device/layout check
- `foundationOverlayScale`: TBD
- `focusCameraTarget`: TBD
- `visualBounds`: TBD
- `logicalBounds`: TBD
- `hitTestShape`: TBD
- `placementBounds`: TBD

## 6. State-/Modul-Regeln

- Base ist `IslandBaseState`, nicht vollstaendiger Ausbau.
- Gebaeude werden spaeter `PlacedWorldItemState`.
- Land-Erweiterungen werden spaeter `IslandExpansionState`.
- `foundation_started` ist als eigenes transparentes Overlay vorhanden, aber
  noch nicht final freigegeben.
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

Diese Einschaetzung muss im Device-Check bestaetigt werden.

## 9. Phase-2E-Grenzen

In diesem Template-Block gilt:

- Kein Code.
- Keine App-Integration des `foundation_started`-Overlays.
- Keine Persistenz.
- Keine Reward Bridge.
- Keine SRS-/`word_progress`-Aenderung.
- Kein echtes Expansion-System.
- Kein PlacedItem-System.
- Kein Interior/ObjectDetail.

## 10. Offene Pruefungen

- Device-Screenshot in echter App-/Mock-Ansicht fehlt.
- `foundation_started`-Overlay existiert und wurde visuell auf `base.png`
  vorgeprueft.
- Echte Device-Pruefung der Overlay-Passung fehlt weiterhin.
- Koordinaten/Anchors sind noch TBD.
- Finale Freigabeentscheidung fehlt.

## 11. Vorlaeufige Entscheidung

- `decision`: `foundation_started generated and visually pre-checked, pending device check and anchor definition`
- `codeAllowed`: `false`
- `nextAllowedStep`: `Phase 2E-D Asset-/Metadatenpruefung auf Geraet vorbereiten`

## 12. Akzeptanzkriterien Fuer Spaetere Freigabe

Das Asset darf erst freigegeben werden, wenn:

- `template.md` existiert,
- `foundation_started` existiert,
- Overlay visuell passt,
- Device-Screenshot geprueft wurde,
- `main_build_area` antippbar und lesbar wirkt,
- Docking/Expansion weiterhin plausibel bleibt,
- Roadmap in `235` aktualisiert wurde.
