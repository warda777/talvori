# 425: Firenze V5 Final Correction-Candidate Layers

Stand: 2026-06-14

Status: `documentation_only` / `correction_candidate_layers` /
`not_runtime_data` / `not_asset` / `not_engine_ready` / `no_yaml_json` /
`no_app_integration`

## 1. Ziel

Dieser Slice erzeugt additive planning-only Correction-Candidate-Layer fuer die
in `424` entschiedenen Firenze-V5-Korrekturen.

Er baut keine Flutter-Preview, erzeugt keine Runtime-Daten, keine finalen
Koordinaten, keine produktiven Polygone und ueberschreibt keine Original-
Handoff-SVGs.

Arbeitsgrundlage:

```text
docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/
```

Neuer Ordner:

```text
docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/correction_candidates/
```

## 2. Gelesene Grundlagen

- `AGENTS.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/417-firenze-playable-city-layout-blueprint-v5.md`
- `docs/world_design/422-firenze-v5-final-handoff-correction-metadata.md`
- `docs/world_design/423-firenze-v5-metrics-reachability-collision-rereview.md`
- `docs/world_design/424-firenze-v5-final-geometry-correction-plan.md`
- `docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/README.md`
- `docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/correction_metadata/README.md`

## 3. Methode

Die neuen Dateien sind additive Candidate-Sheets. Sie verwenden vorhandene
Handoff- und `correction_metadata/`-Previews als Beleg und fuegen nur
planning-only Korrekturentscheidungen hinzu.

Nicht erzeugt wurden:

- neue freie Firenze-Karte,
- neue Parcel-Formen,
- neue River-Formen,
- neue Landmark-Core-Formen,
- final geclippte Buildable-Areas,
- Runtime-Koordinaten oder produktive Polygone.

Wenn exaktes Clipping spaeter noetig ist, muss es in einem separaten
Geometry-Correction-Slice als `candidate_only` erzeugt und danach erneut
reviewt werden.

## 4. Erzeugte Candidate-Layer

| Datei | Zweck | Status |
| --- | --- | --- |
| `parcel_river_clear_candidates.svg` / `.png` | Markiert P06 und P13 als river-clear Kandidaten. | visible correction candidate, not final geometry |
| `parcel_protected_core_clear_candidates.svg` / `.png` | Markiert P03, P04, P11, P12, P13 und P14 als protected-core-clear Kandidaten. | visible correction candidate, not final geometry |
| `parcel_buildable_subzone_clip_candidates.svg` / `.png` | Dokumentiert, dass bevorzugt Buildable Area und Subzonen geclippt werden, nicht freie Parcel-Verschiebung. | candidate_only |
| `correction_candidates_combined_review.svg` / `.png` | Trennt River-clear, Core-clear und allowed-buffer-only in einem Review-Sheet. | combined planning review |
| `correction_candidates_contact_sheet.svg` / `.png` | Uebersicht aller Candidate-Layer mit Stop-Regeln. | contact sheet |

## 5. River-clear Candidates

River bleibt `no_walk` + `no_build`.

| Parcel | Candidate-Entscheidung | Nicht erlaubt |
| --- | --- | --- |
| P06 | Rivernahe Buildable-Area/Subzone als Korrekturkandidat markieren; river-facing Anteil spaeter aus Buildable Area herausclippen oder als `no_build_clearance` lesen. | P06 frei verschieben oder River-Clearance nur anders interpretieren. |
| P13 | Rivernahe Buildable-Area/Subzone als Korrekturkandidat markieren; P13 bleibt bridge-support/river-adjacent, aber Buildable Area darf nicht im Arno liegen. | Bridge-Nahe als Water-Ausnahme behandeln. |

## 6. Protected-Core-clear Candidates

Landmark-Protected-Core bleibt hart `no_build` und wird nicht verkleinert.

| Parcel | Candidate-Entscheidung |
| --- | --- |
| P03 | Buildable Area und Subzonen muessen aus Protected Core herausgeclippt werden; Kultur-Naehe bleibt erlaubt. |
| P04 | Core-facing Buildable/Subzone-Anteil wird als Korrekturkandidat markiert; east-arm/market role bleibt. |
| P11 | Primaere Loesung ist Buildable-/Subzone-Clip; Outline nur spaeter minimal, falls anders nicht core-clear. |
| P12 | Special/landmark-adjacent Envelope darf reviewbar bleiben, aber Core-Anteil wird protected clearance/reserved ground. |
| P13 | Muss sowohl river-clear als auch core-clear werden; nutzbare Flaeche darf spaeter kleiner werden. |
| P14 | East-landmark support bleibt; Buildable/Subzonen muessen ausserhalb Protected Core liegen. |

## 7. Buildable-/Subzone-Clip Candidates

Bevorzugtes Korrekturprinzip:

```text
Buildable Area/Subzonen korrigieren > Parcel frei verschieben.
```

Regeln:

- Parcel-Envelopes bleiben hoechstens `candidate_only`.
- Main-, secondary- und garden/open Subzonen duerfen nicht in River-Water oder
  Landmark-Protected-Core liegen.
- River- und Core-nahe Anteile werden als `no_build_clearance`,
  `reserved_ground` oder `protected clearance` vorgeschlagen.
- Kein Candidate-Layer ist ein finales produktives Polygon.

## 8. Allowed Buffer-only bleibt getrennt

Diese Parcels bleiben als erlaubte Landmark-Buffer-only Naehe mit Constraints
getrennt:

- P02
- P05
- P07
- P09
- P10

Sie sind keine harten Protected-Core-Konflikte und keine automatische
Build-Freigabe. Spaetere Main-/Secondary-/Buildable-Subzonen brauchen dennoch
einen finalen No-Build-/Collision-Check.

## 9. Original-Handoff-Layer

Nicht ueberschrieben:

- `boundary/`
- `river/`
- `streets/`
- `parcels/`
- `landmarks/`
- `correction_metadata/`

Die neuen SVGs liegen nur unter `correction_candidates/`.

## 10. City Entry

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

## 11. Naechster erlaubter Slice

Nach diesem Slice ist ein erneuter Metrics-/Reachability-/Collision-Review
moeglich:

```text
Firenze V5 correction-candidate metrics/reachability/collision review
```

Dieser Review muss pruefen, ob die Candidate-Layer die in `424` geplanten
Korrekturen ausreichend sichtbar machen und ob daraus spaeter ein enger,
weiterhin planning-only Geometry-Correction-Slice abgeleitet werden darf.

## 12. 328 / 336 / 417

`328` wurde bewusst nicht aktualisiert. Die aktive Sprint-ID
`FIRENZE-LAYOUT-BLUEPRINT-V5` bleibt korrekt; 425 ist ein enger
Correction-Candidate-Folgeslice innerhalb desselben V5-Pfads.

`336` wurde bewusst nicht aktualisiert. Die bestehenden Leseregeln fuer
Firenze-/City-Entry-Slices fuehren bereits auf `417-v5`, `handoff_layers/`,
`correction_metadata/` und die neueren Correction-/Review-Slices.

`417` wurde nicht geaendert. Der neue Ordner ist im Handoff-README ergaenzt und
bleibt ein planning-only Zusatz unterhalb der v5-Handoff-Familie.
