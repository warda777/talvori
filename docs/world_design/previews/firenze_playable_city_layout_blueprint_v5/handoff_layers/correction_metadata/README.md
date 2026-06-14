# Firenze V5 Correction Metadata

Status: `documentation_only` / `handoff_correction_metadata` /
`not_runtime_data` / `not_asset` / `not_engine_ready` /
`no_app_integration` / `no_yaml_json`

Dieser Ordner enthaelt finale planning-only Korrektur-Metadaten fuer die
Firenze-v5-Handoff-Layer. Die Original-Handoff-SVGs in `boundary/`, `river/`,
`streets/`, `parcels/` und `landmarks/` werden nicht ueberschrieben.

## Dateien

| Datei | Zweck |
| --- | --- |
| `bridge_ids_b1_b2_b3.svg` / `.png` | Dauerhafte planning-only Bridge-ID-Metadaten fuer B1, B2 und B3. Nur Labels/Review-Anker, keine neue Bridge-Deck-Geometrie. |
| `future_paths_planned_not_walkable.svg` / `.png` | Trennt Future Paths als `planned_now` / `not_walkable_yet` von aktuellen Street-Corridors. |
| `boundary_buffer_review_area.svg` / `.png` | Macht den Boundary Buffer als gefuellte Review-Area sichtbar. Keine Runtime-No-Walk-/No-Build-Maske. |
| `parcel_river_core_correction_candidates.svg` / `.png` | Markiert P06/P13 gegen River sowie P03/P04/P11/P12/P13/P14 gegen Landmark-Protected-Cores als Korrekturkandidaten. |
| `landmark_buffer_allowed_proximity.svg` / `.png` | Markiert P02/P05/P07/P09/P10 als erlaubte Landmark-Buffer-Naehe mit Constraints. |
| `correction_metadata_contact_sheet.svg` / `.png` | Lesbare Uebersicht der fuenf finalen Metadata-Layer. |

## Stop-Regel

Aus diesen Dateien entsteht noch keine App-Implementierung. Kein Layer darf als
Runtime-Polygon, finale Koordinate, produktive Collision, Pathfinding,
Build-Zone, No-Walk-/No-Build-Maske, App-Route, Asset oder Persistenz gelesen
werden.

City Entry bleibt blockiert.

## Naechster erlaubter Schritt

Naechster erlaubter Schritt ist ein erneuter Metrics-/Reachability-/
Collision-Review gegen die Original-Handoff-Layer plus `correction_metadata/`.
Erst danach darf ein separater, freigegebener Folge-Slice ueber weitere
Handoff-Korrekturen entscheiden.
