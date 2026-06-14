# 422: Firenze V5 Final Handoff Correction Metadata

Stand: 2026-06-14

Status: `documentation_only` / `handoff_correction_metadata` /
`not_runtime_data` / `not_asset` / `not_engine_ready` / `no_yaml_json` /
`no_app_integration`

## 1. Ziel

Dieser Slice legt die finalen planning-only Korrektur-Metadaten fuer Firenze V5
ab. Er baut keine Flutter-Preview, erzeugt keine Runtime-Daten, keine finalen
Koordinaten, keine produktiven Polygone und keine freie neue Firenze-Form.

Arbeitsgrundlage:

```text
docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/
```

Die Original-Handoff-SVGs bleiben unveraendert. Die neuen Dateien liegen
ausschliesslich unter:

```text
docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/correction_metadata/
```

## 2. Gelesene Grundlagen

- `AGENTS.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/417-firenze-playable-city-layout-blueprint-v5.md`
- `docs/world_design/418-firenze-v5-layer-consistency-review.md`
- `docs/world_design/419-firenze-v5-metrics-reachability-collision-review.md`
- `docs/world_design/420-firenze-v5-handoff-layer-correction-review.md`
- `docs/world_design/421-firenze-v5-minimal-handoff-correction-decisions.md`
- `docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/README.md`

## 3. Erzeugte Correction-Metadata-Layer

| Datei | Entscheidung aus 421 | Ergebnis |
| --- | --- | --- |
| `bridge_ids_b1_b2_b3.svg` / `.png` | B1/B2/B3 als dauerhafte planning-only Handoff-Metadaten uebernehmen. | B1, B2 und B3 sind als Labels/Review-Anker sichtbar. Es wurde keine neue Bridge-Deck-Geometrie erzeugt. |
| `future_paths_planned_not_walkable.svg` / `.png` | Future Paths dauerhaft von aktuellen Corridors trennen. | Future Paths sind gestrichelt als `planned_now` / `not_walkable_yet` dargestellt und duerfen nicht als aktuelle Walkable Paths gelesen werden. |
| `boundary_buffer_review_area.svg` / `.png` | Boundary Buffer als pruefbare Review-Area weiterfuehren. | Der Buffer ist als gefuellte Review-Area sichtbar, bleibt aber keine Runtime-No-Walk-/No-Build-Maske. |
| `parcel_river_core_correction_candidates.svg` / `.png` | River- und Protected-Core-Treffer als echte Korrekturkandidaten fuehren. | P06/P13 gegen River und P03/P04/P11/P12/P13/P14 gegen Protected-Core sind getrennt markiert. Parcels wurden nicht verschoben. |
| `landmark_buffer_allowed_proximity.svg` / `.png` | Buffer-only Naehe bedingt erlauben. | P02/P05/P07/P09/P10 sind als erlaubte Landmark-Buffer-Naehe mit Constraints sichtbar. |
| `correction_metadata_contact_sheet.svg` / `.png` | Finale Metadata-Layer lesbar zusammenfassen. | Contact Sheet zeigt alle fuenf Metadata-Layer plus Stop-Regel. |

## 4. B1/B2/B3

`bridge_ids_b1_b2_b3` ist ein reiner Metadata-Layer.

Regeln:

- B1/B2/B3 sind die einzigen erlaubten Arno-Querungen.
- Der Layer ergaenzt nur Labels und Review-Anker.
- Er erzeugt keine neue Bridge-Deck-Geometrie.
- Bridge Decks bleiben `walkable` und `no_build`.

## 5. Future Paths

`future_paths_planned_not_walkable` trennt geplante spaetere Wege von
aktuellen Street-Corridors.

Regeln:

- Future Paths sind `planned_now`.
- Future Paths sind `not_walkable_yet`.
- Future Paths duerfen keine aktuelle Parcel-Reachability begruenden.
- Future Paths duerfen erst nach eigenem Gate aktiviert werden.

## 6. Boundary Buffer Review Area

`boundary_buffer_review_area` macht den Randpuffer als Review-Flaeche sichtbar.

Regeln:

- Der Layer ist aus vorhandenen Boundary-/Buffer-Outlines abgeleitet.
- Er ist eine Review-Area, keine finale Maske.
- Er darf nicht als Runtime-No-Walk oder Runtime-No-Build gelesen werden.

## 7. River/Core Correction Candidates

`parcel_river_core_correction_candidates` trennt harte Korrekturkandidaten von
erlaubter Landmark-Naehe.

Harte Kandidaten:

| Risikofamilie | Kandidaten | Entscheidung |
| --- | --- | --- |
| River-Water | P06, P13 | Echte Korrektur noetig; River-Water bleibt `no_walk` + `no_build`. |
| Landmark-Protected-Core | P03, P04, P11, P12, P13, P14 | Echte Korrektur noetig; Protected Core bleibt hart `no_build`. |

Nicht erlaubt:

- Parcels frei verschieben,
- River als Deko interpretieren,
- Protected-Core-Konflikte als Buffer-only Naehe freigeben,
- aus diesem Layer City Entry ableiten.

## 8. Landmark Buffer Allowed Proximity

`landmark_buffer_allowed_proximity` dokumentiert nur Buffer-only Naehe.

Erlaubt mit Constraints:

| Parcel | Entscheidung |
| --- | --- |
| P02 | Buffer-only Naehe erlaubt, solange spaetere main/secondary Subzonen no-build-clear bleiben. |
| P05 | Buffer-only Naehe erlaubt, solange finaler Buildbereich clear bleibt. |
| P07 | Buffer-only Naehe fuer Hill-/Reserve-Kontext erlaubt. |
| P09 | Buffer-only Naehe fuer Bridge-/Craft-Kontext erlaubt. |
| P10 | Buffer-only Naehe fuer Reserve-Kontext erlaubt. |

Diese Erlaubnis gilt nicht fuer Protected-Core-Treffer und nicht fuer
River-Water-Treffer.

## 9. Original-Handoff-Layer

Nicht ueberschrieben:

- `boundary/`
- `river/`
- `streets/`
- `parcels/`
- `landmarks/`

Die neuen SVGs sind zusaetzliche Metadata-Layer. Sie sind keine neue Firenze-
Karte und keine freien neuen Formen.

## 10. Stop-Regeln

City Entry bleibt blockiert.

Nicht freigegeben:

- Flutter-City-Entry-Preview,
- App-Integration,
- Runtime-Koordinaten,
- produktive Polygone,
- Collision-/Pathfinding-Daten,
- Build-Zones,
- YAML-/JSON-/YML-Ableitung,
- Dateien unter `assets/`,
- Persistenz oder BuildState.

## 11. Naechster erlaubter Schritt

Naechster sinnvoller Slice:

```text
Firenze V5 metrics/reachability/collision re-review with correction metadata
```

Dieser Folgeslice muss die Original-Handoff-Layer plus `correction_metadata/`
gemeinsam pruefen. Er bleibt ebenfalls Docs-only, bis die Korrektur-Metadaten
akzeptiert sind.
