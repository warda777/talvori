# 419: Firenze V5 Metrics / Reachability / Collision Review

Stand: 2026-06-14

Status: `documentation_only` / `technical_review` / `metrics_review` /
`not_runtime_data` / `not_asset` / `not_engine_ready` / `no_yaml_json` /
`no_app_integration`

## 1. Ziel

Dieser Review prueft die Firenze-V5-Handoff-Layer technisch, aber weiterhin
planning-only:

```text
docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/
```

Geprueft werden Metrics-, Reachability-, Collision- und No-Overlap-Risiken
fuer:

- Boundary,
- River,
- Streets,
- Parcels,
- Landmarks,
- No-Walk / No-Build / Collision-Puffer.

Dieser Review erzeugt keine Runtime-Daten, keine finalen Koordinaten, keine
produktiven Polygone, keine YAML/JSON/YML-Datei, keine App-Integration und
keine Flutter-Preview.

## 2. Gelesene Grundlagen

- `AGENTS.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/415-firenze-playable-city-ground-layer-and-anchors-gate.md`
- `docs/world_design/416-talvori-playable-area-specification-standard-v1.md`
- `docs/world_design/417-firenze-playable-city-layout-blueprint-v5.md`
- `docs/world_design/418-firenze-v5-layer-consistency-review.md`
- `docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/README.md`

Fuehrende Regeln:

- `416` verlangt vor City Entry Boundary, Metrics, Water, Paths, Build Slots,
  Anchors, Occupancy, Collision, Navigation, No-Walk/No-Build,
  Source-Traceability und Visual-QA.
- `417-v5` ist die fuehrende Firenze-Blueprint-Fassung.
- `418` bestaetigt die Layer-Struktur nur als Handoff-Grundlage; es ersetzt
  keinen technischen Schnitt-, Reachability- oder Collision-Review.

## 3. Methode

Verwendet wurden ausschliesslich vorhandene Handoff-SVGs.

Zusaetzlich wurde eine lokale, standardbibliotheksbasierte SVG-Sanity-Pruefung
ausgefuehrt. Sie liest vorhandene SVG-Polygone, Pfade und Kreise, prueft
einfach:

- Parcel-Vertices innerhalb der Playable Boundary,
- Parcel-zu-Parcel-Schnittfreiheit,
- Parcel-Schnitte mit River-Water,
- Parcel-Schnitte mit Landmark-Protected-Cores,
- Parcel-Schnitte mit Landmark-Collision-Buffern,
- vorhandene Parcel-Center- und Parcel-Entry-Anker,
- vorhandene Street-Centerlines, Street-Corridors und Street-Nodes.

Grenze:

- Die Pruefung ist ein Planning-Sanity-Check, keine Engine-Topologie.
- Sie erzeugt keine Dateien und keine Runtime-Koordinaten.
- Da keine robuste GIS-/Topology-Bibliothek verwendet wurde, bleiben alle
  Schnittbefunde Review-Hinweise, keine produktiven Geometrieentscheidungen.
- Bei Buffern, die nur als Stroke/Ring vorliegen, ist keine verlaessliche
  Flaechenpruefung moeglich, bis ein eigener Review-Area-Layer existiert.

## 4. Gepruefte Layer

| Layer | Verwendete Handoff-Dateien |
| --- | --- |
| Boundary | `florenz_playable_boundary_area.svg`, `florenz_boundary_outline.svg`, `florenz_boundary_buffer_no_walk_no_build.svg` |
| River | `fluss_geschlossene_flaeche.svg`, `fluss_mittellinie.svg`, `fluss_seitenlinien.svg` |
| Streets | `street_corridors_area.svg`, `street_centerlines.svg`, `street_nodes.svg`, `street_combined_preview.svg` |
| Parcels | `parcel_buildable_areas.svg`, `parcel_inner_zones.svg`, `parcel_clearance_no_build_buffer.svg`, `parcel_anchors.svg` |
| Landmarks | `landmark_reserve_outlines.svg`, `landmark_protected_core_areas.svg`, `landmark_collision_no_build_buffer.svg`, `landmark_interaction_zones.svg`, `landmark_anchors.svg` |

## 5. Sanity-Check-Ergebnisse

| Pruefung | Ergebnis | Review-Notiz |
| --- | --- | --- |
| P01-P14 vorhanden | Bestanden | 14 Parcel-Polygone wurden gefunden. |
| Parcel-Center-Anker | Bestanden | 14/14 Parcel-Center-Anker wurden gefunden. |
| Parcel-Entry-/Access-Anker | Bestanden | 14/14 Parcel-Entry-Anker wurden gefunden. |
| Parcels innerhalb Boundary | Bestanden als Vertex-Test | Kein Parcel-Vertex lag ausserhalb der Playable Boundary. |
| Parcels untereinander getrennt | Bestanden | Kein Parcel-to-Parcel-Schnitt wurde gefunden. |
| Streets als Reachability-Basis | Bestanden mit Risiko | Street-Centerlines, Corridor-Area und Nodes sind vorhanden; der Layer ist als Reachability-Quelle geeignet. |
| Isolierte Parcels | Nicht offensichtlich | Alle Parcels haben Entry-Anker. Eine echte Graph-Reachability braucht aber explizite Edges zwischen Entry-Anker, Branch Path und Street-Node. |
| Parcels vs River-Water | Risiko / nicht bestanden | Die Sanity-Pruefung markiert `P06` und `P13` als Schnittkandidaten mit der geschlossenen Arno-Wasserflaeche. |
| Parcels vs Landmark-Protected-Cores | Risiko / nicht bestanden | Schnittkandidaten wurden fuer `P03`, `P04`, `P11`, `P12`, `P13` und `P14` gefunden. |
| Parcels vs Landmark-Collision-Buffer | Risiko / nicht bestanden | Schnittkandidaten wurden fuer `P02`, `P03`, `P04`, `P05`, `P07`, `P09`, `P10`, `P11`, `P12`, `P13` und `P14` gefunden. |
| Parcels vs Boundary-Buffer | Offen | Der Boundary-Buffer liegt als Stroke-/Ring-Visual vor; fuer eine robuste Schnittpruefung braucht er einen expliziten Flaechenlayer. |
| B1/B2/B3 als einzige Arno-Querungen | Offen | `417-v5` definiert B1-B3, aber die Street-Handoff-SVGs enthalten keine expliziten `B1`/`B2`/`B3`-IDs oder Bridge-Anchor-Layer. |
| Future Paths nicht walkable | Offen | `417-v5` definiert Future Paths als geplant und nicht walkable; in den Street-Handoff-SVGs ist keine eindeutige Future-Path-ID oder Dash-Semantik erkennbar. |
| No-Walk und No-Build getrennt | Bestanden mit Folgepruefung | River, Boundary-Buffer, Parcel-Clearance und Landmark-Collision/No-Build sind getrennte Layer-Familien. Ihre spaetere Union darf nicht automatisch Walkability ersetzen. |

## 6. Bewertung

Die Firenze-V5-Handoff-Layer bestehen den Inventar- und Strukturteil des
technischen Reviews:

- Boundary, River, Streets, Parcels und Landmarks liegen getrennt vor.
- 14/14 Parcel Candidates sind vorhanden.
- 14/14 Parcel-Center- und 14/14 Parcel-Entry-Anker sind vorhanden.
- Parcels liegen nach Vertex-Test innerhalb der Playable Boundary.
- Parcels schneiden einander im einfachen Polygoncheck nicht.
- Street-Corridors, Centerlines und Nodes liefern eine brauchbare Grundlage
  fuer einen Reachability-Graphen.

Der Collision-/No-Overlap-Teil ist noch nicht freigegeben:

- `P06` und `P13` muessen gegen den River-Water-Layer geprueft oder korrigiert
  werden.
- Mehrere Parcels liegen nach Sanity-Check in Landmark-Protected-Core- oder
  Landmark-Collision-Buffer-Zonen. Diese Befunde muessen entweder als
  absichtlich landmark-adjacent mit sauberer No-Build-Ausnahme dokumentiert
  oder als Layer-Fehler korrigiert werden.
- B1/B2/B3 muessen als eigene Bridge-Anker/Querungs-IDs in den Handoff-Layern
  explizit pruefbar werden.
- Future Paths brauchen eine eindeutige Layer-/Style-/ID-Trennung, damit sie
  nicht versehentlich als aktuelle Walkable Paths gelesen werden.
- Der Boundary-Buffer braucht fuer technische Schnittpruefung eine echte
  Flaeche oder ein eigenes Buffer-Review-Layer, nicht nur ein Stroke-Visual.

## 7. Stop-Entscheidung

City Entry bleibt blockiert.

Nicht erlaubt aus diesem Review:

- keine Flutter-City-Entry-Preview,
- keine Runtime-Koordinaten,
- keine finalen Polygone,
- keine Build-Zones,
- keine Collision- oder Pathfinding-Daten,
- keine YAML-/JSON-/YML-Ableitung,
- keine Dateien unter `assets/`,
- keine App-Integration.

Vor einem City-Entry- oder Greybox-Folgeschritt braucht Firenze mindestens:

- explizite B1/B2/B3-Bridge-Anker in den Handoff-Layern,
- eindeutige Future-Path-Trennung,
- Korrektur oder dokumentierte Ausnahme fuer Parcel/River- und
  Parcel/Landmark-Buffer-Schnittkandidaten,
- eine echte Reachability-Graph-Pruefung von Parcel-Entry zu Street-Node,
- einen klaren Boundary-Buffer-Flaechenlayer oder eine dokumentierte
  Alternative fuer Buffer-Pruefung.

## 8. Review-Visual

Preview-Ordner:

```text
docs/world_design/previews/firenze_v5_metrics_reachability_collision_review/
```

Dateien:

- `firenze_v5_metrics_reachability_collision_review.svg`
- `firenze_v5_metrics_reachability_collision_review.png`
- `README.md`

Das Visual ist ein Review-Contact-Sheet aus vorhandenen Handoff-Layer-Previews.
Es zeichnet keine neue Firenze-Geometrie, keine neuen Parcels, keine neuen
Strassen, keinen neuen Fluss und keine neuen Landmark-Flaechen.

## 9. 328 / 336

`328` wurde bewusst nicht aktualisiert. Die aktive Sprint-ID ist bereits
`FIRENZE-LAYOUT-BLUEPRINT-V5`, und 419 ist ein technischer Folge-Review
innerhalb dieses freigegebenen V5-Folgepfads.

`336` wurde bewusst nicht aktualisiert. Es verlangt bereits `416`, `417-v5`
und die `handoff_layers/` fuer kommende Firenze-/City-Entry-Slices.

## 10. Naechster korrekter Slice

Empfohlener naechster Slice:

```text
Firenze V5 handoff layer correction: bridge IDs, future paths and collision buffers
```

Dieser Slice sollte weiterhin docs-only bleiben und zuerst die Handoff-Layer so
praezisieren, dass B1-B3, Future Paths, Landmark-Buffer, Boundary-Buffer und
Parcel-Collision-Pruefungen eindeutig nachvollziehbar sind.
