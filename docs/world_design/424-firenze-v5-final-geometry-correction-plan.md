# 424: Firenze V5 Final Geometry-Correction Plan

Stand: 2026-06-14

Status: `documentation_only` / `geometry_correction_plan` /
`not_runtime_data` / `not_asset` / `not_engine_ready` / `no_yaml_json` /
`no_app_integration`

## 1. Ziel

Dieser Slice entscheidet den finalen minimalen Korrekturplan fuer die in
`423` offen gebliebenen Firenze-V5-Geometrie-/Collision-Fragen.

Er baut keine Flutter-Preview, erzeugt keine Runtime-Daten, keine finalen
Koordinaten, keine produktiven Polygone und ueberschreibt keine Original-
Handoff-SVGs.

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
- `docs/world_design/423-firenze-v5-metrics-reachability-collision-rereview.md`
- `docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/README.md`
- `docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/correction_metadata/README.md`

## 3. Korrekturprinzip

Die Korrekturen sollen minimal sein:

- keine freie Verschiebung von Parcels,
- keine neue Firenze-Karte,
- keine Veraenderung der Original-Handoff-SVGs in diesem Slice,
- keine Landmark-Core-Verkleinerung als Abkuerzung,
- keine River-Reinterpretation als Deko,
- keine Runtime-Koordinaten oder finalen Polygone.

Wenn ein spaeterer Correction-Layer-Slice folgt, muss er additive
`candidate_only`-Layer erzeugen. Erst nach erneutem Metrics-/Reachability-/
Collision-Review duerfen Original-Handoff-Layer ueberhaupt zur Korrektur
vorgeschlagen werden.

## 4. P06 gegen River

Entscheidung:

```text
P06 braucht eine river-clear Buildable-Area-Korrektur.
```

Minimale Strategie:

- P06 bleibt `west_river_reserve_parcel`.
- P06 wird nicht frei verschoben.
- Die wassernahe Buildable-Area-Kante wird in einem spaeteren Candidate-Layer
  zurueckgenommen oder geclippt.
- Falls ein separates Parcel-Envelope spaeter erhalten bleibt, muss der
  rivernahe Anteil als `no_build_clearance` / `reserved_ground` markiert
  werden.
- River-Water bleibt `no_walk` + `no_build`.

Nicht ausreichend:

- River-Clearance nur anders zu interpretieren.
- P06 trotz Water-Schnitt fuer City Entry freizugeben.

## 5. P13 gegen River

Entscheidung:

```text
P13 braucht eine doppelte Korrektur: river-clear und protected-core-clear.
```

Minimale Strategie:

- P13 bleibt `bridge_support_parcel`.
- P13 darf bridge-support / river-adjacent bleiben.
- Die Buildable Area darf nicht im Arno liegen.
- Der rivernahe Anteil wird in einem spaeteren Candidate-Layer aus der
  Buildable Area herausgenommen und als `river_clearance` / `no_build` gelesen.
- Access zum Bridge-/Path-Kontext bleibt Planungsziel, aber keine Runtime-
  Reachability-Freigabe.
- Zusaetzlich muss P13 aus Landmark-Protected-Core herausgehalten werden.

Nicht ausreichend:

- P13 als Sonderfall im Wasser zu erlauben.
- Bridge-Nahe als automatische Water-Ausnahme zu behandeln.

## 6. Protected-Core-Korrekturen

Protected Core bleibt hart `no_build`. Die Korrektur darf nicht ueber
Landmark-Core-Verkleinerung geloest werden, solange kein eigener
Landmark-Core-Review diese Aenderung freigibt.

| Parcel | Entscheidung | Parcel-Outline? | Buildable/Subzone-Korrektur | Landmark-Core-Interpretation |
| --- | --- | --- | --- | --- |
| P03 | `archive_workshop_parcel` darf kultur-nah bleiben, muss aber core-clear werden. | Keine freie Verschiebung. Envelope nur behalten, wenn der core-nahe Teil nicht buildable ist. | Main/secondary/garden-open und Buildable Area muessen aus dem Core herausgeclippt werden. | Core bleibt hart protected/no_build. |
| P04 | `market_plaza_parcel` / east-arm use darf landmark-nah bleiben, muss aber core-clear werden. | Keine freie Verschiebung. Nur eine minimale core-facing Kante darf spaeter als Candidate gekuerzt werden. | Buildable Area und Subzonen muessen core-clear werden. | Core bleibt unveraendert protected/no_build. |
| P11 | `river_edge_practice_parcel` darf river-/landmark-adjacent bleiben, aber nicht im Core liegen. | Outline nur anpassen, wenn Buildable Area sonst nicht core-clear werden kann. | Primaere Loesung ist Subzone-/Buildable-Area-Clip. | Core bleibt hart; keine Buffer-only-Ausnahme. |
| P12 | `culture_landmark_support_parcel` bleibt special/landmark-adjacent. | Envelope kann als special-adjacent Review-Flaeche bleiben, aber nicht als komplett buildable gelesen werden. | Core-Anteil wird zu protected clearance/reserved ground; buildable Subzonen liegen ausserhalb. | Core bleibt hart protected/no_build. |
| P13 | `bridge_support_parcel` braucht core-clear plus river-clear. | Keine freie Verschiebung; spaeterer Candidate muss die nutzbare Flaeche kleiner machen. | Buildable Area aus River und Core herausclippen; Zugang/Bridge-Bezug behalten. | Core bleibt hart, keine Sonderfreigabe wegen Bridge-Support. |
| P14 | `east_landmark_support_parcel` bleibt east landmark support. | Keine freie Verschiebung; nur minimaler core-facing Clip als Candidate. | Buildable Area und Subzonen ausserhalb Protected Core halten. | Core bleibt unveraendert protected/no_build. |

## 7. Buffer-only Allowed Proximity

Diese Parcels bleiben als erlaubte Landmark-/Buffer-Naehe bestaetigt:

| Parcel | Entscheidung | Constraint |
| --- | --- | --- |
| P02 | erlaubt | Main/secondary/buildable Subzonen muessen im finalen Review no-build-clear bleiben. |
| P05 | erlaubt | East-arm-Naehe bleibt moeglich, aber finaler Buildbereich darf nicht in protected/no-build liegen. |
| P07 | erlaubt | Reserve-/Hill-Kontext bleibt moeglich; Buffer-Naehe ist kein Core-Konflikt. |
| P09 | erlaubt | Bridge-/Craft-Kontext bleibt moeglich; Access und Subzonen brauchen finalen No-Build-Check. |
| P10 | erlaubt | Reserve-Kontext bleibt moeglich; Subzonen muessen clear bleiben. |

Regel:

```text
Buffer-only ist keine automatische Ablehnung, aber auch keine Build-Freigabe.
```

## 8. Bridge, Future Paths und Boundary

| Thema | Entscheidung |
| --- | --- |
| B1/B2/B3 | Metadata-seitig geloest. IDs sind planning-only vorhanden. Keine neue Bridge-Deck-Geometrie ist dadurch freigegeben. |
| Future Paths | Metadata-seitig geloest. Sie sind `planned_now` / `not_walkable_yet` und duerfen keine aktuelle Reachability begruenden. |
| Boundary Buffer | Review-seitig lesbar. Die Review-Area bleibt keine Runtime-No-Walk-/No-Build-Maske und kein finaler Collision-Layer. |

## 9. Erlaubter enger Folge-Slice

Nach diesem Plan ist ein enger finaler Correction-Layer-Slice moeglich.

Er darf:

- additive `candidate_only`-Korrekturlayer erzeugen,
- P06/P13 als river-clear Candidate zeigen,
- P03/P04/P11/P12/P13/P14 als protected-core-clear Candidate zeigen,
- P02/P05/P07/P09/P10 als allowed-buffer-only kontrolliert belassen,
- die Original-Handoff-Layer weiterhin unangetastet lassen.

Er darf nicht:

- Original-Handoff-SVGs ueberschreiben,
- Runtime-Daten erzeugen,
- finale Koordinaten oder produktive Polygone erzeugen,
- Flutter-Code, App-Preview, Assets oder YAML/JSON/YML erzeugen,
- City Entry oeffnen.

## 10. City Entry

City Entry bleibt blockiert.

Blockiert bleiben:

- Flutter-City-Entry-Preview,
- App-Integration,
- Runtime-Koordinaten,
- produktive Polygone,
- Collision-/Pathfinding-Daten,
- Build-Zones,
- YAML-/JSON-/YML-Ableitung,
- Dateien unter `assets/`,
- Persistenz oder BuildState.

## 11. Preview

Preview-Ordner:

```text
docs/world_design/previews/firenze_v5_final_geometry_correction_plan/
```

Dateien:

- `firenze_v5_final_geometry_correction_plan.svg`
- `firenze_v5_final_geometry_correction_plan.png`
- `README.md`

Das Visual ist eine Decision-/Correction-Matrix mit bestehenden
`correction_metadata/`-Previews als Beleg. Es zeichnet keine neue
Firenze-Karte, keine neuen Parcel-Formen, keinen neuen River und keine neuen
Landmark-Flaechen.

## 12. 328 / 336

`328` wurde bewusst nicht aktualisiert. Die aktive Sprint-ID
`FIRENZE-LAYOUT-BLUEPRINT-V5` bleibt korrekt; 424 ist ein enger Folgeplan
innerhalb desselben Korrekturpfads.

`336` wurde bewusst nicht aktualisiert. Die bestehenden Leseregeln fuer
Firenze-/City-Entry-Slices fuehren bereits auf `417-v5`, `handoff_layers/` und
die neueren Correction-/Review-Slices.

## 13. Naechster erlaubter Slice

Naechster fachlich erlaubter Slice:

```text
Firenze V5 final correction-candidate layers
```

Dieser Slice muss docs-only bleiben und additive Candidate-Layer erzeugen, die
die in diesem Plan entschiedenen river-clear- und protected-core-clear-
Korrekturen sichtbar machen, ohne Original-Handoff-SVGs zu ueberschreiben.
