# Firenze V5 Metrics / Reachability / Collision Re-Review

Status: `documentation_only` / `technical_rereview` /
`not_runtime_data` / `not_asset` / `not_engine_ready` /
`no_app_integration` / `no_yaml_json`

Dieser Ordner enthaelt den Re-Review von Firenze V5 gegen die Original-
Handoff-Layer plus:

```text
docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/correction_metadata/
```

## Dateien

| Datei | Zweck |
| --- | --- |
| `firenze_v5_metrics_reachability_collision_rereview.svg` / `.png` | Re-Review-Sheet mit Metadata-Loesungen, offenen Geometrie-/Collision-Fragen und City-Entry-Stop-Regel. |

## Ergebnis

Geloest als Metadata:

- B1/B2/B3 Bridge IDs,
- Future Paths als planned/not-walkable,
- Boundary Buffer als Review-Area,
- River/Core-Kandidaten markiert,
- erlaubte Landmark-Buffer-Naehe getrennt.

Weiter offen als harte Geometrie-/Collision-Frage:

- P06/P13 gegen River,
- P03/P04/P11/P12/P13/P14 gegen Protected-Core,
- finaler Reachability-/Bridge-/Boundary-/Buffer-Abgleich.

## Grenzen

- keine App-Preview,
- kein Flutter-Code,
- keine Runtime-Daten,
- keine finalen Koordinaten,
- keine produktiven Polygone,
- keine YAML-/JSON-/YML-Dateien,
- keine Dateien unter `assets/`,
- keine freie neue Firenze-Karte.

City Entry bleibt blockiert.
