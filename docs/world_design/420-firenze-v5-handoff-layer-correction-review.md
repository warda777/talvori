# 420: Firenze V5 Handoff Layer Correction Review

Stand: 2026-06-14

Status: `documentation_only` / `handoff_correction_review` /
`not_runtime_data` / `not_asset` / `not_engine_ready` / `no_yaml_json` /
`no_app_integration`

## 1. Ziel

Dieser Slice korrigiert die offenen Review-Punkte aus `419` als
planning-only Handoff-Review. Er erzeugt keine neue Firenze-Karte und keine
freie Geometrie. Die neuen Dateien sind Review-/Correction-Candidate-Layer
ueber den bestehenden Firenze-v5-Handoff-SVGs.

Arbeitsgrundlage:

```text
docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/
```

Fuehrende Regeln:

- `416` verlangt vor City Entry Boundary, Metrics, Wege, Parcel-Struktur,
  No-Walk/No-Build, Collision, Reachability und Visual-QA.
- `417-v5` bleibt die fuehrende Firenze-Blueprint-Fassung.
- `418` bestaetigt die Handoff-Layer als Strukturgrundlage.
- `419` markiert offene technische Risiken, gibt aber keine Runtime-Geometrie
  frei.

## 2. Gelesene Grundlagen

- `AGENTS.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/415-firenze-playable-city-ground-layer-and-anchors-gate.md`
- `docs/world_design/416-talvori-playable-area-specification-standard-v1.md`
- `docs/world_design/417-firenze-playable-city-layout-blueprint-v5.md`
- `docs/world_design/418-firenze-v5-layer-consistency-review.md`
- `docs/world_design/419-firenze-v5-metrics-reachability-collision-review.md`
- `docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/README.md`

## 3. 419-Befunde: echt, offen oder False Positive

| 419-Befund | Bewertung in 420 | Entscheidung |
| --- | --- | --- |
| B1/B2/B3 fehlen als explizite Bridge IDs in den Handoff-Street-SVGs | echtes Handoff-Layer-/Metadata-Problem | `bridge_ids_b1_b2_b3.svg` macht B1-B3 als Review-Layer explizit pruefbar. |
| Future Paths sind in den Handoff-Street-SVGs nicht eindeutig als planned/not-walkable getrennt | echtes Handoff-Layer-/Metadata-Problem | `future_paths_planned_not_walkable.svg` macht Future Paths als getrennten Review-Layer sichtbar. |
| Boundary Buffer war in `419` nicht als pruefbare Flaeche auswertbar | Darstellungs-/Stroke-Problem, kein bewiesener Geometriekonflikt | `boundary_buffer_review_area.svg` erzeugt aus vorhandenen Boundary-/Buffer-Outlines eine pruefbare Review-Area. |
| P06 und P13 gegen River-Water | echter Correction-Candidate in aktueller Layerinterpretation | `collision_issue_candidates.svg` markiert P06/P13. Keine freie Verschiebung. |
| Parcels gegen Landmark-Protected-Cores | echter Correction-Candidate in aktueller Layerinterpretation | P03, P04, P11, P12, P13 und P14 muessen im naechsten Korrektur-/Metrics-Slice entschieden werden. |
| Parcels gegen Landmark-Collision-Buffer | echter Buffer-/Clearance-Candidate in aktueller Layerinterpretation | P02, P03, P04, P05, P07, P09, P10, P11, P12, P13 und P14 brauchen Pufferentscheidung oder begruendete Sonderregel. |

Interpretationsgrenze:

- Diese Bewertung ist eine technische Planungsbewertung der Handoff-SVGs, keine
  Runtime-Schnittpruefung.
- Kollisionen bedeuten: Die aktuellen Review-Layer sind nicht eindeutig genug
  fuer City Entry.
- Kollisionen bedeuten nicht: Parcels duerfen frei verschoben werden.

## 4. Neue Review-Layer

Preview-Ordner:

```text
docs/world_design/previews/firenze_v5_handoff_layer_correction_review/
```

Erzeugt:

- `firenze_v5_handoff_layer_correction_review.svg`
- `firenze_v5_handoff_layer_correction_review.png`
- `bridge_ids_b1_b2_b3.svg`
- `bridge_ids_b1_b2_b3.png`
- `future_paths_planned_not_walkable.svg`
- `future_paths_planned_not_walkable.png`
- `boundary_buffer_review_area.svg`
- `boundary_buffer_review_area.png`
- `collision_issue_candidates.svg`
- `collision_issue_candidates.png`
- `README.md`

### 4.1 Bridge IDs B1-B3

`bridge_ids_b1_b2_b3.svg` legt B1, B2 und B3 als explizite
Review-Beschriftung ueber die vorhandenen River-/Street-Handoff-Layer.

Wichtig:

- Es wurde keine neue Bridge-Deck-Geometrie erzeugt.
- Die Labels leiten sich aus `417-v5` ab.
- Der Layer ist ein Correction-Candidate-Layer.
- Ein spaeterer Slice muss entscheiden, ob diese IDs in die Handoff-Familie als
  eigene Dokumentations-/Metadata-Ebene uebernommen werden.

### 4.2 Future Paths

`future_paths_planned_not_walkable.svg` zeigt Future Paths getrennt von den
aktuellen Street-Corridors.

Regel:

- Future Paths sind `planned_now`.
- Future Paths sind `not_walkable_yet`.
- Future Paths duerfen nicht mit `PATH-N`, `PATH-S`, Connector Paths oder
  Parcel Branch Paths verwechselt werden.

### 4.3 Boundary Buffer Review Area

`boundary_buffer_review_area.svg` leitet aus den vorhandenen
Boundary-/Buffer-Outlines eine pruefbare Review-Flaeche ab.

Bewertung:

- Der 419-Befund war hier vor allem ein Stroke-/Darstellungsproblem.
- Das neue Visual macht den Buffer als Review-Area sichtbar.
- Die Review-Area ist keine finale Buffer-Geometrie und keine Runtime-Maske.

### 4.4 Collision Issue Candidates

`collision_issue_candidates.svg` markiert die in `419` gemeldeten Risiken.

Kandidaten:

| Risiko | Kandidaten |
| --- | --- |
| River-Water | P06, P13 |
| Landmark-Protected-Core | P03, P04, P11, P12, P13, P14 |
| Landmark-Collision-/No-Build-Buffer | P02, P03, P04, P05, P07, P09, P10, P11, P12, P13, P14 |

Korrekturregel:

- Nicht frei verschieben.
- Keine neue Karte zeichnen.
- Im naechsten Slice minimale Korrekturentscheidung treffen:
  - Parcel anpassen,
  - Landmark-Core/-Buffer anpassen,
  - River-/Clearance-Interpretation korrigieren,
  - oder eine klar begruendete planning-only Ausnahme dokumentieren.

## 5. Layer, die verwendet wurden

Die Review-Layer nutzen diese vorhandenen Handoff-Dateien:

- `boundary/florenz_playable_boundary_area.svg`
- `boundary/florenz_boundary_buffer_no_walk_no_build.svg`
- `river/fluss_geschlossene_flaeche.svg`
- `streets/street_corridors_area.svg`
- `parcels/parcel_buildable_areas.svg`
- `landmarks/landmark_protected_core_areas.svg`
- `landmarks/landmark_collision_no_build_buffer.svg`

B1-B3 und Future-Path-Semantik wurden aus `417-v5` und dem v5-Blueprint
uebernommen, weil sie in den separaten Handoff-Street-SVGs nicht explizit
vorhanden sind. Das ist genau der zu korrigierende Handoff-Gap.

## 6. Stop-Regeln

City Entry bleibt blockiert.

Nicht erlaubt:

- keine Flutter-City-Entry-Preview,
- keine App-Integration,
- keine Runtime-Daten,
- keine finalen Koordinaten,
- keine produktiven Polygone,
- keine YAML-/JSON-/YML-Dateien,
- keine Dateien unter `assets/`,
- keine freie Parcel-, River-, Street-, Landmark- oder Boundary-Korrektur,
- keine Build-Slots oder Wege aus diesen Review-Layern als Runtime lesen.

## 7. Naechster erlaubter Slice

Naechster fachlich erlaubter Slice:

```text
Firenze V5 minimal handoff layer correction candidates
```

Dieser Slice darf nur die in `420` markierten Kandidaten fachlich entscheiden:

- B1/B2/B3 als explizite Handoff-Review-Metadaten,
- Future Paths als eigene planned/not-walkable Handoff-Familie,
- Boundary Buffer als pruefbare Flaeche,
- minimale Korrekturentscheidung fuer P06/P13 gegen River,
- minimale Korrekturentscheidung fuer Parcel-vs-Landmark-Core/-Buffer.

Auch dieser Folgeslice bleibt Docs-only, bis ein separater Metrics-,
Reachability- und Collision-Review akzeptiert ist.

## 8. Visual-QA

Geprueft:

- SVG und PNG wurden fuer alle Review-Layer erzeugt.
- B1/B2/B3 sind im Bridge-Review-Layer sichtbar.
- Future Paths sind gestrichelt und als not-walkable markiert.
- Boundary Buffer ist als abgeleitete Review-Area sichtbar.
- Collision Candidates sind farblich getrennt.
- Keine neue Firenze-Ground-Shape wurde frei gezeichnet.
- Keine vorhandenen Handoff-SVGs wurden ueberschrieben.
- Die Visuals sind Dokumentationsvisuals, keine App-Screens.

Offen:

- Numerische Flaechen-/Schnittmessung bleibt Folgearbeit.
- Korrekturen an Handoff-Layern sind noch nicht erfolgt.
- City Entry bleibt blockiert.
