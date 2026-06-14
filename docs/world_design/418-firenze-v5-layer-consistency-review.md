# 418: Firenze V5 Layer Consistency Review

Stand: 2026-06-14

Status: `documentation_only` / `layer_review` / `not_runtime_data` /
`not_asset` / `not_engine_ready` / `no_yaml_json` / `no_app_integration`

## 1. Ziel

Dieser Review prueft die planning-only Handoff-Layer aus:

```text
docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/
```

Geprueft werden die Layer-Familien:

- `boundary/`
- `river/`
- `streets/`
- `parcels/`
- `landmarks/`

Der Review entscheidet nur, ob die Layer grundsaetzlich zusammenpassen und ob
sie als Grundlage fuer einen naechsten Metrics-/Reachability-/Collision-Review
taugen. Er erzeugt keine Runtime-Geometrie, keine finalen Koordinaten, keine
produktiven Polygone, keine App-Integration und keine Engine-ready Daten.

Das Review-Visual basiert ausschliesslich auf den vorhandenen Handoff-SVGs.
Es zeichnet keine eigene Firenze-Form, keine eigenen Parcels, keine eigenen
Strassen, keinen eigenen Fluss und keine frei gesetzten Landmark-Flaechen.

## 2. Gelesene Grundlagen

- `AGENTS.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/415-firenze-playable-city-ground-layer-and-anchors-gate.md`
- `docs/world_design/416-talvori-playable-area-specification-standard-v1.md`
- `docs/world_design/417-firenze-playable-city-layout-blueprint-v5.md`
- `docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/README.md`

Fuehrende Regeln:

- `416` erzwingt Boundary, Metrics, Terrain, Water, Paths, Parcels,
  Occupancy, Collision, Navigation, No-Walk/No-Build, Anchors,
  Source-Traceability und Visual-QA vor City Entry.
- `417-v5` ist die fuehrende Firenze-Blueprint-Fassung.
- City Entry bleibt blockiert, bis v5 reviewed und danach Metrics,
  Reachability und Collision geprueft sind.

## 3. Layer-Inventar

| Layer | Gefundene Dateien | Review-Bedeutung |
| --- | --- | --- |
| Boundary | playable boundary area, outline, boundary buffer | Prueft Firenze-Ground-Shape, sichtbare Stadtgrenze und aeusseren No-Walk-/No-Build-Puffer. |
| River | Arno-Seitenlinien, geschlossene Wasserflaeche, Mittellinie | Prueft Wasser als `no_walk` + `no_build` und Grundlage fuer Bruecken-/Uferlogik. |
| Streets | Centerlines, Corridors, Nodes, Combined Preview | Prueft PATH-N/PATH-S, Connector Paths, Branch Paths, Future Paths und Knoten. |
| Parcels | Outlines, Buildable Areas, Inner Zones, Clearance Buffers, Anchors | Prueft P01-P14, Subzonen, Access Points, Puffer und candidate-only Parcel-Struktur. |
| Landmarks | Reserve Outlines, Protected Cores, Interaction Zones, Collision Buffers, Anchors | Prueft L1-L5 als reserved-only/no-build Identitaetsanker. |

Alle geprueften SVG-Familien liegen als Dokumentationslayer vor. Die PNGs sind
Preview-Bilder zum Lesen der Layer, keine Assets.

## 3.1 Verwendete Handoff-SVGs

Das Review-Visual verwendet diese vorhandenen Dateien als gerenderte
Source-Layer-Thumbnails:

- `boundary/florenz_playable_boundary_area.svg`
- `boundary/florenz_boundary_outline.svg`
- `boundary/florenz_boundary_buffer_no_walk_no_build.svg`
- `river/fluss_geschlossene_flaeche.svg`
- `river/fluss_mittellinie.svg`
- `streets/street_corridors_area.svg`
- `streets/street_centerlines.svg`
- `streets/street_nodes.svg`
- `parcels/parcel_buildable_areas.svg`
- `parcels/parcel_clearance_no_build_buffer.svg`
- `parcels/parcel_anchors.svg`
- `landmarks/landmark_reserve_outlines.svg`
- `landmarks/landmark_protected_core_areas.svg`
- `landmarks/landmark_collision_no_build_buffer.svg`
- `landmarks/landmark_anchors.svg`

Es wurden keine neuen Karten-/Stadt-/Parcel-/River-/Street-/Landmark-Shapes
erzeugt.

## 4. Konsistenzreview

| Pruefung | Ergebnis | Begruendung |
| --- | --- | --- |
| Boundary enthaelt alle relevanten Layer | Bestanden | Die Boundary-Familie liefert spielbare Flaeche, Outline und Randpuffer. Die Layer-Familien verwenden denselben Review-Canvas und sind fuer eine gemeinsame Ueberlagerung vorbereitet. |
| River liegt innerhalb der Boundary | Bestanden | Die Arno-Familie zeigt Seitenlinien, Mittellinie und geschlossene Wasserflaeche. Im v5-Blueprint verlaeuft der Arno zentral innerhalb der Ground Shape. |
| Streets verbinden Nord-/Suedseite | Bestanden mit Folgepruefung | Streets liefern Corridors, Centerlines, Nodes und Combined Preview. PATH-N/PATH-S und Connector-Logik sind vorhanden. Die exakte Bruecken-ID-Zuordnung B1-B3 gehoert in den naechsten Metrics-/Reachability-Review. |
| Keine freie Arno-Querung ausserhalb B1-B3 | Bestanden mit Folgepruefung | `417-v5` legt B1-B3 als einzige Arno-Querungen fest. Im Layer-Set sind keine separaten erlaubten Zusatzquerungen dokumentiert. Der naechste Review muss die Crossing-Topologie numerisch gegen River/Bridge-Layer pruefen. |
| Parcels P01-P14 liegen innerhalb der Boundary | Bestanden | Parcel Outlines zeigen P01-P14 als getrennte Kandidaten und `417-v5` bestaetigt 14/14 innerhalb der Boundary. Kein Parcel ist als Runtime-Polygon freigegeben. |
| Parcels ueberschneiden River, Landmark-Kerne und Boundary-Buffer nicht offensichtlich | Bestanden mit Folgepruefung | Im v5-Visual liegen Parcels mit sichtbaren Puffern ausserhalb Arno und Landmark-Kernen. Exakte Schnittpruefung von Parcel-, River-, Landmark- und Buffer-Polylines bleibt Aufgabe des Metrics-/Collision-Reviews. |
| Parcels haben Access-/Anchor-Struktur | Bestanden | Parcel Anchors, Inner Zones, Buildable Areas und Clearance Buffer sind getrennt vorhanden. `417-v5` fordert Branch Paths und Access Points fuer jedes Parcel. |
| L1-L5 bleiben reserved-only/no-build | Bestanden | Landmark-Layer trennen Reserve Outlines, Protected Core Areas, Interaction Zones, Collision/No-Build Buffer und Anchors. Die Kerne bleiben geschuetzt. |
| No-Walk/No-Build/Collision-Puffer getrennt | Bestanden | Boundary Buffer, River-Water, Parcel-Clearance und Landmark-Collision/No-Build Buffer sind getrennte Layer-Familien. |
| Keine Runtime-Interpretation | Bestanden | README, `417-v5` und dieser Review markieren alle Handoff-Layer als planning-only, not runtime data und not engine ready. |

## 5. Review-Entscheidung

Die V5-Handoff-Layer passen als Dokumentations- und Review-Grundlage
grundsaetzlich zusammen.

Bestanden:

- Boundary, River, Streets, Parcels und Landmarks sind als getrennte
  Layer-Familien vorhanden.
- River ist als `no_walk` + `no_build` dokumentiert.
- Streets planen PATH-N/PATH-S, Knoten, Corridors und Future Paths.
- Parcels P01-P14 sind getrennt, candidate-only und mit Access-/Anchor-
  Familien vorbereitet.
- Landmark L1-L5 sind als reserved/protected/no-build Familien angelegt.
- No-Walk, No-Build, Clearance und Collision sind nicht zu einem einzigen
  unklaren Layer vermischt.

Nicht freigegeben:

- keine App-City-Entry-Preview,
- keine Flutter-Umsetzung,
- keine Runtime-Koordinaten,
- keine finalen Polygone,
- keine Pathfinding- oder Collision-Daten,
- keine Build-Zones,
- keine YAML-/JSON-/YML-Ableitung,
- keine Dateien unter `assets/`.

## 6. Risiken und offene Punkte

Die Layer bestehen den Strukturreview, aber noch keinen technischen
Geometrie-Review.

Offen fuer den naechsten Slice:

- B1/B2/B3 muessen als einzige River-Crossing-Knoten gegen River- und
  Street-Layer numerisch geprueft werden.
- Parcel-Outlines, Parcel-Clearance, Landmark-Protected-Cores,
  Landmark-Collision-Buffer und River-Water muessen auf echte
  Schnittfreiheit geprueft werden.
- Walkable Components und Reachability muessen gegen PATH-N/PATH-S,
  Branch Paths und Bridge Connections geprueft werden.
- No-Build darf nicht automatisch No-Walk bedeuten; die Layerbeziehung muss
  pro Zone bestaetigt werden.
- Future Paths sind geplant, aber nicht walkable; diese Trennung muss im
  Metrics-Review erhalten bleiben.
- Collision-Radien, mobile Tap Targets, Parcel-Abstaende und Wegbreiten sind
  noch Planungsmetriken, keine Runtime-Werte.

## 7. Review-Visual

Preview-Ordner:

```text
docs/world_design/previews/firenze_v5_layer_consistency_review/
```

Dateien:

- `firenze_v5_layer_consistency_exact_layer_stack.svg`
- `firenze_v5_layer_consistency_exact_layer_stack.png`
- `README.md`

Das Visual ist eine Contact-/Stack-Sheet-Komposition aus den vorhandenen
Handoff-SVGs. Die Quelldateien werden als Thumbnails gerendert und in der
Review-Grafik gezeigt. Das Visual ist kein schematisches Nachzeichnen, kein
App-Screen, kein Runtime-Overlay und keine final vermessene Geometrie.

## 8. 328 / 336

`328` wurde bewusst nicht aktualisiert. Die Checklist fuehrt bereits
`FIRENZE-LAYOUT-BLUEPRINT-V5` als aktuellen Firenze-Status. Dieser Review ist
ein Folgeartefakt innerhalb der in `417-v5` bereits angekuendigten
Layer-Konsistenzpruefung, kein neuer strategischer Sprintanker.

`336` wurde bewusst nicht aktualisiert. Es nennt `417-v5` und die
`handoff_layers/` bereits als Pflichtgrundlage fuer kommende Firenze- und
City-Entry-Slices.

## 9. Naechster erlaubter Slice

Naechster fachlich erlaubter Slice:

```text
Firenze V5 metrics / reachability / collision review
```

Dieser Folgeslice darf die Handoff-Layer gegen Area-Spec-Metrics,
Reachability, No-Overlap, Bridge Connectivity, Collision und No-Walk/No-Build
pruefen. Er darf weiterhin keine App-Preview und keine Runtime-Daten erzeugen.
