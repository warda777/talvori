# 423: Firenze V5 Metrics / Reachability / Collision Re-Review

Stand: 2026-06-14

Status: `documentation_only` / `technical_rereview` /
`not_runtime_data` / `not_asset` / `not_engine_ready` / `no_yaml_json` /
`no_app_integration`

## 1. Ziel

Dieser Slice prueft die Firenze-V5-Handoff-Layer erneut gegen die in `422`
ergaenzten finalen `correction_metadata/`.

Er erzeugt keine Flutter-Preview, keine App-Integration, keine Runtime-Daten,
keine finalen Koordinaten, keine produktiven Polygone und keine freie neue
Firenze-Form.

Arbeitsgrundlage:

```text
docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/
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
- `docs/world_design/422-firenze-v5-final-handoff-correction-metadata.md`
- `docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/README.md`
- `docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/correction_metadata/README.md`

## 3. Methode

Geprueft wurden die vorhandenen Original-Handoff-Layer plus die neuen
planning-only Metadata-Dateien aus `correction_metadata/`.

Dieser Re-Review ist kein neuer numerischer Polygon-/GIS-Test. Er entscheidet,
welche in `419` markierten Blocker durch Metadata geklaert sind und welche
echten Geometrie-/Collision-Fragen weiterhin offen bleiben.

## 4. Metadata Re-Review

| 419-Problem | 422-Metadata | Re-Review-Ergebnis |
| --- | --- | --- |
| B1/B2/B3 fehlten als explizite Bridge-IDs | `correction_metadata/bridge_ids_b1_b2_b3.svg` / `.png` | Geloest als planning-only Metadata. B1, B2 und B3 sind eindeutig sichtbar. Es wurde keine neue Bridge-Deck-Geometrie erzeugt. |
| Future Paths waren nicht eindeutig planned/not-walkable getrennt | `correction_metadata/future_paths_planned_not_walkable.svg` / `.png` | Geloest als Metadata. Future Paths sind gestrichelt und duerfen nicht als aktuelle Street-Corridors gelesen werden. |
| Boundary Buffer war als Stroke/Ring nicht robust als Flaeche lesbar | `correction_metadata/boundary_buffer_review_area.svg` / `.png` | Geloest als Review-Lesbarkeit. Der Buffer ist als gefuellte Review-Area sichtbar, bleibt aber keine Runtime-Maske. |
| River/Core-Kandidaten waren nicht getrennt dokumentiert | `correction_metadata/parcel_river_core_correction_candidates.svg` / `.png` | Geloest als Markierung. P06/P13 River und P03/P04/P11/P12/P13/P14 Protected-Core sind sichtbar getrennt. Die Geometrie ist dadurch noch nicht korrigiert. |
| Buffer-only Naehe war mit Core-Konflikten vermischt | `correction_metadata/landmark_buffer_allowed_proximity.svg` / `.png` | Geloest als Semantik-Trennung. P02/P05/P07/P09/P10 sind als erlaubte Buffer-only Naehe mit Constraints getrennt. |

## 5. Geloeste Metadata-Blocker

Durch `422` gelten diese `419`-Blocker als metadata-seitig geloest:

- B1/B2/B3 sind als planning-only Bridge-ID-Metadaten vorhanden.
- Future Paths sind als planned/not-walkable getrennt.
- Boundary Buffer ist als Review-Area lesbar.
- River/Core-Korrekturkandidaten sind markiert.
- Erlaubte Landmark-Buffer-Naehe ist von Protected-Core-Konflikten getrennt.

Diese Loesungen geben keine Runtime-Geometrie frei.

## 6. Weiterhin offene harte Geometrie-/Collision-Fragen

Weiter offen bleiben:

| Thema | Betroffen | Status nach Re-Review |
| --- | --- | --- |
| River-Water-Konflikt | P06, P13 | Weiter harte Korrekturfrage. Metadata markiert den Konflikt, loest ihn aber nicht. |
| Landmark-Protected-Core-Konflikt | P03, P04, P11, P12, P13, P14 | Weiter harte Korrekturfrage. Protected Core bleibt `no_build`; Parcels muessen core-clear werden oder ein finaler Correction-Plan muss die Geometrie sauber anpassen. |
| Landmark-Buffer-only Naehe | P02, P05, P07, P09, P10 | Fachlich erlaubt mit Constraints, aber spaetere main/secondary/buildable Subzonen muessen im finalen Review no-build-clear bleiben. |
| Reachability Graph | alle Parcels | Noch nicht final. Access-/Anchor-Struktur ist vorhanden, aber ein expliziter Graph von Parcel-Access zu Street-Nodes ist noch nicht freigegeben. |
| Boundary Buffer | Gesamtboundary | Als Review-Area lesbar, aber keine finale Runtime-/Collision-Maske. |
| Bridge Decks | B1, B2, B3 | IDs sind geklaert; finale Bridge-Deck-Geometrie/Walkability bleibt Folgepruefung. |

## 7. Entscheidung

Die Re-Review-Entscheidung lautet:

```text
Metadata-Probleme aus 419: geloest.
Harte Geometrie-/Collision-Fragen: offen.
City Entry: weiterhin blockiert.
Finaler Geometry-Correction-Plan: erforderlich.
```

Nicht mehr blockierend als Metadata-Luecke:

- fehlende B1/B2/B3-IDs,
- fehlende Future-Path-Semantik,
- Boundary-Buffer-Lesbarkeit,
- Vermischung von Core-Konflikt und erlaubter Buffer-Naehe.

Weiter blockierend als Geometry-/Collision-Frage:

- P06/P13 gegen River,
- P03/P04/P11/P12/P13/P14 gegen Protected-Core,
- finaler Boundary-/Buffer-/Bridge-/Reachability-Abgleich.

## 8. City Entry

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

## 9. Preview

Preview-Ordner:

```text
docs/world_design/previews/firenze_v5_metrics_reachability_collision_rereview/
```

Dateien:

- `firenze_v5_metrics_reachability_collision_rereview.svg`
- `firenze_v5_metrics_reachability_collision_rereview.png`
- `README.md`

Das Visual ist ein Re-Review-Sheet. Es bettet vorhandene
`correction_metadata/`-Previews ein und ergaenzt nur Review-Text. Es zeichnet
keine neue Firenze-Karte, keine neuen Parcels, keinen neuen River, keine neuen
Streets und keine neuen Landmark-Flaechen.

## 10. 328 / 336

`328` wurde bewusst nicht aktualisiert. Die aktive Sprint-ID
`FIRENZE-LAYOUT-BLUEPRINT-V5` und die Pflicht vor City Entry reichen fuer
diesen Re-Review aus; 423 ist ein Folgeartefakt innerhalb desselben V5-
Korrekturpfads.

`336` wurde bewusst nicht aktualisiert. Es fuehrt `417-v5` und die
`handoff_layers/` bereits als Pflichtkontext fuer kommende Firenze- und
City-Entry-Slices; `417-v5` und die Handoff-README verweisen jetzt zusaetzlich
auf `correction_metadata/`.

## 11. Naechster erlaubter Slice

Naechster fachlich erlaubter Slice:

```text
Firenze V5 final geometry-correction plan
```

Dieser Slice muss weiterhin Docs-only bleiben und entscheiden, wie P06/P13
river-clear sowie P03/P04/P11/P12/P13/P14 protected-core-clear werden, ohne
Original-Handoff-Layer frei zu ueberschreiben oder City Entry zu oeffnen.
