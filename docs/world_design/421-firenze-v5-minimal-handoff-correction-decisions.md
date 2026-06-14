# 421: Firenze V5 Minimal Handoff Correction Decisions

Stand: 2026-06-14

Status: `documentation_only` / `decision_slice` / `not_runtime_data` /
`not_asset` / `not_engine_ready` / `no_yaml_json` /
`no_app_integration`

## 1. Ziel

Dieser Slice entscheidet die in `420` markierten Firenze-v5-Korrektur-
kandidaten fachlich. Er erzeugt keine neue Firenze-Karte, keine freien Formen,
keine Runtime-Daten, keine finalen Koordinaten, keine produktiven Polygone und
keine App-Preview.

Arbeitsgrundlage:

```text
docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/
```

Fuehrende Regeln:

- `417-v5` bleibt die fuehrende Blueprint-Fassung.
- `418` bestaetigt die Handoff-Layer als Strukturgrundlage.
- `419` markiert technische Risiken.
- `420` macht diese Risiken als Review-/Correction-Candidate-Layer sichtbar.
- City Entry bleibt blockiert.

## 2. Gelesene Grundlagen

- `AGENTS.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/417-firenze-playable-city-layout-blueprint-v5.md`
- `docs/world_design/418-firenze-v5-layer-consistency-review.md`
- `docs/world_design/419-firenze-v5-metrics-reachability-collision-review.md`
- `docs/world_design/420-firenze-v5-handoff-layer-correction-review.md`
- `docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/README.md`

## 3. Decision Summary

| Kandidat | Entscheidung | Folgeaktion |
| --- | --- | --- |
| B1/B2/B3 Bridge IDs | uebernehmen | Als dauerhafte planning-only Handoff-Metadaten in einem eigenen Bridge-ID-Review-Layer fuehren. |
| Future Paths | uebernehmen | Als eigene planned/not-walkable Handoff-Familie trennen. |
| Boundary Buffer | weiterfuehren, aber sauberer erzeugen | Eigene filled Review-Area ableiten; bestehende Stroke-/Ring-Datei nicht als einzige pruefbare Flaeche verwenden. |
| P06 gegen River | echte Korrektur noetig | Parcel vom River-Water/no-build-Konflikt minimal loesen oder buildable Teil clippen. |
| P13 gegen River | echte Korrektur noetig | Bridge-support Parcel darf river-adjacent bleiben, aber nicht in River-Water liegen. |
| Parcels gegen Landmark-Protected-Cores | echte Korrektur noetig | Protected Core bleibt hart `no_build`; betroffene Parcels muessen core-frei werden. |
| Parcels nur gegen Landmark-Collision-Buffer | bedingte Landmark-/Buffer-Naehe erlaubt | Erlaubt als planning-only Naehe, wenn main/secondary building zones und access keine Protected-Core-/No-Build-Regel verletzen. |

## 4. B1/B2/B3 Entscheidung

Entscheidung:

```text
B1/B2/B3 werden als dauerhafte planning-only Handoff-Metadaten uebernommen.
```

Begruendung:

- `417-v5` definiert B1, B2 und B3 als einzige Arno-Querungen.
- `419` fand keine expliziten Bridge-IDs in den Handoff-Street-SVGs.
- `420` zeigt, dass die Bridge-ID-Ergaenzung ohne neue Bridge-Geometrie als
  Review-Layer moeglich ist.

Folgeregel:

- Der finale Handoff-Correction-Slice darf einen eigenen
  `bridge_ids_b1_b2_b3`-Layer ergaenzen.
- Dieser Layer darf nur Labels/IDs/Review-Anker tragen.
- Er darf keine neuen Bridge-Decks frei zeichnen.
- Bridge Decks bleiben `walkable` + `no_build`.

## 5. Future Paths Entscheidung

Entscheidung:

```text
Future Paths werden dauerhaft als planned/not-walkable Handoff-Familie
getrennt.
```

Begruendung:

- `417-v5` definiert Future Paths als geplant, aber nicht aktuell walkable.
- `419` konnte diese Semantik in den Street-Handoff-SVGs nicht eindeutig
  erkennen.
- Ohne eigene Trennung koennten Future Paths spaeter versehentlich als aktuelle
  Walkable Paths gelesen werden.

Folgeregel:

- Future Paths brauchen einen eigenen Review-Layer mit gestrichelter Darstellung
  und Status `planned_now` / `not_walkable_yet`.
- Sie duerfen nicht in `street_corridors_area` als aktuelle Walkable Corridors
  aufgehen.
- Sie duerfen spaeter nur nach eigenem Gate aktiviert werden.

## 6. Boundary Buffer Entscheidung

Entscheidung:

```text
Der Boundary Buffer wird als eigene pruefbare Review-Flaeche weitergefuehrt,
aber die finale Handoff-Korrektur soll eine sauber benannte filled Review-Area
erzeugen.
```

Begruendung:

- `419` konnte den Boundary Buffer wegen Stroke-/Ring-Darstellung nicht robust
  als Flaeche auswerten.
- `420` zeigt eine ableitbare Review-Area aus vorhandenen Boundary-/Buffer-
  Outlines.
- Diese Richtung ist fachlich richtig, aber die finale Handoff-Korrektur muss
  den Layer klar als `review_area`, `not_runtime_data` und
  `not_final_geometry` benennen.

Folgeregel:

- Die bestehende Handoff-Stroke-Datei wird nicht ueberschrieben.
- Der finale Korrektur-Slice darf eine zusaetzliche Boundary-Buffer-
  Review-Area-Datei ergaenzen.
- Diese Datei bleibt planning-only und darf nicht als Runtime-No-Walk- oder
  No-Build-Maske gelesen werden.

## 7. P06/P13 gegen River

| Parcel | 420-Befund | Entscheidung | Minimale Korrekturrichtung |
| --- | --- | --- | --- |
| P06 | Schnittkandidat mit River-Water | echte Korrektur noetig | P06 bleibt westliches Reserve-Parcel, aber buildable area muss river-clear werden; bevorzugt Parcel-Kante/Buildable-Teil vom Wasser loesen. |
| P13 | Schnittkandidat mit River-Water | echte Korrektur noetig | P13 darf bridge-support/river-adjacent bleiben, aber buildable area darf nicht im Arno liegen; River-Water bleibt `no_walk` + `no_build`. |

Nicht zulaessig:

- River-Water als Deko interpretieren.
- P06/P13 trotz Water-Schnitt fuer City Entry freigeben.
- Parcels frei verschieben, ohne finalen Correction-Layer und Review.

## 8. Landmark Protected Core Entscheidungen

Protected Core bleibt hart geschuetzt.

Regel:

```text
Parcels duerfen landmark-adjacent sein, aber nicht in Landmark-Protected-Cores
liegen.
```

| Parcel | 420-Befund | Entscheidung | Minimale Korrekturrichtung |
| --- | --- | --- | --- |
| P03 | Protected-Core + Buffer | echte Korrektur noetig | Archive/workshop darf kultur-nah bleiben, muss aber core-frei werden. |
| P04 | Protected-Core + Buffer | echte Korrektur noetig | Market/east-arm use darf landmark-nah bleiben, muss aber protected-core-frei werden. |
| P11 | Protected-Core + Buffer | echte Korrektur noetig | River-edge practice darf landmark-adjacent bleiben, aber nicht im Core. |
| P12 | Protected-Core + Buffer | echte Korrektur noetig | Special/culture parcel darf nahe am Landmark liegen, aber Protected Core bleibt no-build. |
| P13 | Protected-Core + Buffer + River | echte Korrektur noetig | Doppelte Korrektur: River-clear und protected-core-clear. |
| P14 | Protected-Core + Buffer | echte Korrektur noetig | East landmark support darf adjacent bleiben, aber Core bleibt frei. |

Keine dieser Core-Kollisionen wird als False Positive freigegeben.

## 9. Landmark Collision Buffer Entscheidungen

Die Landmark-Collision-/No-Build-Buffer aus `419` sind breiter als die
Protected Cores. Deshalb wird zwischen Core-Konflikt und erlaubter
landmark-adjacent Naehe getrennt.

| Parcel | 420-Befund | Entscheidung |
| --- | --- | --- |
| P02 | Buffer-only | erlaubte Landmark-/Buffer-Naehe, aber Subzonen muessen no-build-clear bleiben. |
| P05 | Buffer-only | erlaubte Landmark-/Buffer-Naehe, aber main/secondary zones duerfen spaeter nicht im finalen No-Build liegen. |
| P07 | Buffer-only | erlaubte Landmark-/Buffer-Naehe fuer Reserve-/Hill-Kontext. |
| P09 | Buffer-only | erlaubte Landmark-/Buffer-Naehe fuer Bridge-/Craft-Kontext. |
| P10 | Buffer-only | erlaubte Landmark-/Buffer-Naehe fuer Reserve-Kontext. |
| P03 | Core + Buffer | echte Korrektur noetig wegen Core. |
| P04 | Core + Buffer | echte Korrektur noetig wegen Core. |
| P11 | Core + Buffer | echte Korrektur noetig wegen Core. |
| P12 | Core + Buffer | echte Korrektur noetig wegen Core. |
| P13 | River + Core + Buffer | echte Korrektur noetig wegen River und Core. |
| P14 | Core + Buffer | echte Korrektur noetig wegen Core. |

Entscheidung:

- Buffer-only ist kein automatischer Parcel-Fehler, solange die spaetere
  innere Parcel-Struktur main/secondary/buildable Subzonen aus finalen
  No-Build-Bereichen heraushaelt.
- Protected-Core-Treffer bleiben dagegen harte Korrekturkandidaten.

## 10. False Positives

Als False Positive oder Darstellungsproblem bewertet:

- Boundary Buffer als nicht pruefbare Flaeche in `419`: kein bewiesener
  Geometriekonflikt, sondern Stroke-/Ring-Representation.

Nicht als False Positive bewertet:

- B1/B2/B3-Missing-Metadata: echte Handoff-Luecke.
- Future-Path-Missing-Semantics: echte Handoff-Luecke.
- P06/P13 River-Water: echte Korrekturkandidaten.
- Protected-Core-Treffer: echte Korrekturkandidaten.

## 11. Finaler Handoff-Correction-Slice moeglich?

Ja. Nach `421` ist ein enger finaler Handoff-Correction-Slice moeglich.

Er darf:

- B1/B2/B3 als planning-only Bridge-ID-/Review-Metadata-Layer ergaenzen,
- Future Paths als planned/not-walkable Review-Layer ergaenzen,
- Boundary Buffer als filled Review-Area ergaenzen,
- River-/Core-Correction-Candidates minimal als Korrekturvorschlag markieren,
- Buffer-only Naehe als erlaubte Landmark-/Buffer-Naehe dokumentieren.

Er darf nicht:

- bestehende Handoff-SVGs ueberschreiben,
- Parcels frei verschieben,
- eine neue Firenze-Karte zeichnen,
- Runtime-Geometrie erzeugen,
- City Entry oeffnen.

## 12. Stop-Entscheidung

City Entry bleibt blockiert.

Blockiert bleiben:

- Flutter-City-Entry-Preview,
- App-Integration,
- Runtime-Koordinaten,
- finale Polygone,
- Build-Zones,
- Collision-/Pathfinding-Daten,
- YAML-/JSON-/YML-Ableitung,
- Dateien unter `assets/`.

## 13. Visual

Preview-Ordner:

```text
docs/world_design/previews/firenze_v5_minimal_handoff_correction_decisions/
```

Dateien:

- `firenze_v5_minimal_handoff_correction_decisions.svg`
- `firenze_v5_minimal_handoff_correction_decisions.png`
- `README.md`

Das Visual ist eine Decision-Matrix, keine Karte. Es zeichnet keine Firenze-
Boundary, keine Parcels, keinen Fluss, keine Wege und keine Landmark-Flächen
neu.
