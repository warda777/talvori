# Firenze V5 Correction Candidates

Status: `documentation_only` / `correction_candidate_layers` /
`not_runtime_data` / `not_asset` / `not_engine_ready` /
`no_app_integration` / `no_yaml_json`

Dieser Ordner enthaelt additive planning-only Correction-Candidate-Layer fuer
Firenze V5. Sie setzen die Entscheidungen aus `424` sichtbar um, ohne Original-
Handoff-SVGs zu ueberschreiben.

## Dateien

| Datei | Zweck |
| --- | --- |
| `parcel_river_clear_candidates.svg` / `.png` | Markiert P06 und P13 als river-clear Buildable-/Subzone-Korrekturkandidaten. River bleibt `no_walk` + `no_build`. |
| `parcel_protected_core_clear_candidates.svg` / `.png` | Markiert P03, P04, P11, P12, P13 und P14 als protected-core-clear Kandidaten. Landmark Core bleibt hart `no_build`. |
| `parcel_buildable_subzone_clip_candidates.svg` / `.png` | Dokumentiert das bevorzugte Clip-Prinzip: Buildable Area/Subzonen korrigieren, Parcel-Envelopes nur `candidate_only` halten. |
| `correction_candidates_combined_review.svg` / `.png` | Trennt River-clear, Core-clear und allowed-buffer-only in einem Review-Sheet. |
| `correction_candidates_contact_sheet.svg` / `.png` | Lesbare Uebersicht aller Candidate-Layer und Stop-Regeln. |

## Grenzen

Die Dateien sind keine Runtime-Koordinaten, keine produktiven Polygone, keine
Build-Zones, keine App-Preview und keine Engine-ready Daten. Sie enthalten
keine finale Geometrie-Korrektur, sondern sichtbare Korrekturkandidaten fuer
den naechsten Review.

Nicht erlaubt:

- Original-Handoff-SVGs ueberschreiben,
- River oder Landmark Core verkleinern,
- Parcels frei verschieben,
- YAML/JSON/YML ableiten,
- Dateien unter `assets/` erzeugen,
- City Entry oeffnen.

## Naechster erlaubter Schritt

Naechster erlaubter Schritt ist ein erneuter
Metrics-/Reachability-/Collision-Review gegen Original-Handoff-Layer,
`correction_metadata/` und diese `correction_candidates/`.

City Entry bleibt blockiert.
