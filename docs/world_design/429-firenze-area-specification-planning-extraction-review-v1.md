# 429: Firenze Area-Specification Planning Extraction Review v1

Stand: 2026-06-18

Status: `documentation_only` / `planning_extraction_review_v1` /
`planning_only` / `not_runtime_data` / `no_json_yaml` / `no_flutter` /
`no_collision` / `no_pathfinding` / `no_app_integration` / `no_assets` /
`no_commit`

## 1. Ziel

Dieser Slice reviewt `428` als erste planning-only Extraktion aus der
bereinigten Firenze-Master-SVG. Er kopiert die Extraction nicht erneut und gibt
keine vollstaendige Edge- oder Objektliste aus.

Review-Ziel:

- pruefen, ob `428` gegen die aktuelle Master-SVG konsistent ist,
- pruefen, ob die Registry-Zaehler und Topologie weiterhin passen,
- pruefen, ob `428` planning-only bleibt und keine Runtime-nahe Datenfamilie
  einschleicht,
- entscheiden, ob `428` als planning-only Extraction akzeptiert wird.

Nicht-Ziele:

- keine Runtime-Area-Spec,
- keine JSON-/YAML-/YML-Datei,
- keine Flutter-Preview,
- keine produktiven Koordinaten,
- keine finalen Polygone,
- keine Collision- oder Pathfinding-Daten,
- keine Aenderungen an `lib/`, `pubspec.yaml` oder `assets/`,
- kein Commit.

## 2. Gelesene Grundlagen

- `AGENTS.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/415-firenze-playable-city-ground-layer-and-anchors-gate.md`
- `docs/world_design/416-talvori-playable-area-specification-standard-v1.md`
- `docs/world_design/417-firenze-playable-city-layout-blueprint-v5.md`
- `docs/world_design/426-firenze-master-technical-layout-readiness-check.md`
- `docs/world_design/427-firenze-area-specification-extraction-plan.md`
- `docs/world_design/428-firenze-area-specification-planning-extraction-v1.md`
- `docs/world_design/previews/firenze_master_technical_layout/firenze_city_exploration_master.svg`

## 3. Start- und Scope-Gate

| Check | Ergebnis |
| --- | --- |
| Arbeitsbaum vor Start | sauber |
| Start-HEAD | `e4f5b5c9 docs: add firenze area specification planning extraction` |
| `428` vorhanden | PASS |
| Master-SVG vorhanden | PASS |
| Scope `lib/` | nicht geaendert |
| Scope `pubspec.yaml` | nicht geaendert |
| Scope `assets/` | nicht geaendert |
| JSON/YAML/YML im Slice | nicht erzeugt |

## 4. Source- und SHA-Konsistenz

| Pruefung | Erwartet | Gefunden | Status |
| --- | --- | --- | --- |
| Source-Pfad in `428` | `docs/world_design/previews/firenze_master_technical_layout/firenze_city_exploration_master.svg` | gefunden | PASS |
| SHA-256 aktuelle Master-SVG | `58d7f5cf0d6d09d8d42dbe03f74d0439b7f231787e1d0b8acad84002eaa733d3` | `58d7f5cf0d6d09d8d42dbe03f74d0439b7f231787e1d0b8acad84002eaa733d3` | PASS |
| SHA-256 in `428` | identisch zur aktuellen Datei | identisch | PASS |
| Canvas width | `1672` | `1672` | PASS |
| Canvas height | `941` | `941` | PASS |
| ViewBox | `0 0 442.38333 248.97292` | `0 0 442.38333 248.97292` | PASS |
| Canvas/ViewBox in `428` | vollstaendig genannt | ja | PASS |

Ergebnis: `PASS`.

## 5. Vollstaendigkeit der Registries

| Familie | Erwartet | Aktuelle SVG | Status |
| --- | ---: | ---: | --- |
| Boundary | 1 | 1 | PASS |
| River | 1 | 1 | PASS |
| Bridges | 8 | 8 | PASS |
| Main Roads | 7 | 7 | PASS |
| Side Roads | 42 | 42 | PASS |
| Parcels | 14 | 14 | PASS |
| Landmarks | 6 | 6 | PASS |
| Green Areas | 48 | 48 | PASS |
| Urban Blocks | 37 | 37 | PASS |
| Anchor Points | 48 | 48 | PASS |
| Navigation Nodes | 181 | 181 | PASS |
| Navigation Edges | 221 | 221 | PASS |

Ergebnis: `PASS`.

## 6. Planning-only Safety Review

| Verbotene Naehe | Ergebnis |
| --- | --- |
| produktive Koordinaten | PASS, nur Canvas/ViewBox als Source-Metadaten |
| finale Polygone | PASS |
| SVG-`path d`-Werte oder SVG-Payload im Markdown | PASS |
| Punktlisten | PASS |
| Runtime-Adjacency | PASS, nur Edge-Endpunkte als Review-Topologie |
| Collision-Daten | PASS, nur Rollen-/Blocker-Kandidaten |
| Pathfinding-Gewichte | PASS |
| Flutter-/Dart-Daten | PASS |
| JSON-/YAML-/YML-Dateien | PASS, keine erzeugt |
| Aenderungen an `lib/`, `pubspec.yaml`, `assets/` | PASS, keine erzeugt |

Hinweis: Begriffe wie `Collision`, `Pathfinding`, `Runtime` und
`E_needs_manual_review` erscheinen in `428` nur als Verbots-, Stop- oder
Null-Ergebnis-Kontext. Es wurde kein Runtime-naher Datensatz gefunden.

## 7. Topology Review

| Pruefung | Ergebnis | Status |
| --- | --- | --- |
| Navigation-Edges aufloesbar | 221/221 | PASS |
| Nicht aufloesbare Edges | 0 | PASS |
| Bridge-Ketten B01-B08 | 8/8 | PASS |
| Parcel Access-/Entry-Paare P01-P14 | 28/28 | PASS |
| `city_spawn_start` angebunden | YES | PASS |
| `D001_internal_road_end` angebunden | YES | PASS |
| offene `needs_review`-Faelle | 0 explizite `true`-Faelle | PASS |
| offene `E_needs_manual_review`-Faelle | 0, nur Null-Ergebnis-Erwaehnung | PASS |

Ergebnis: `PASS`.

## 8. Rollen- und Flag-Review

| Familie | Erwartete Rolle / Flags aus `428` | Status |
| --- | --- | --- |
| River | `no_walk_candidate` + `no_build_candidate` | PASS |
| Roads | `walk_candidate` + `no_build_candidate` | PASS |
| Bridges | `walk_candidate` + `no_build_candidate` | PASS |
| Parcels | `portal_candidate` / `detail_map_entry_candidate` | PASS |
| Landmarks | `protected_core_candidate` | PASS |
| Urban Blocks | `blocked_context_candidate` / `no_build_candidate` | PASS |
| Green Areas | `context_candidate` | PASS |
| alle Eintraege | `blocked_for_runtime` | PASS |

Bewertung: Die Rollen bleiben Review- und Planungsflags. Sie erzeugen keine
Build-Slots, keine Walkability-Maske, keine Collision-Maske und keine
App-Datenstruktur.

## 9. Ergebnisentscheidung

| Entscheidung | Ergebnis |
| --- | --- |
| `428` als planning-only Extraction | `PASS` |
| Runtime-Freigabe | NO |
| JSON/YAML-Freigabe | NO |
| Flutter-Preview-Freigabe | NO |

`428` ist als planning-only Extraction ausreichend reviewt. Die naechste Arbeit
darf weiterhin nur ein Review-/Planungs-Gate sein.

## 10. Naechster engster Slice

Empfehlung:

```text
Firenze Area-Specification Metrics and Reachability Review Plan
```

Begruendung:

- Die Source-/Registry-/Topology-Schicht aus `428` ist stabil genug fuer den
  naechsten Review-Schritt.
- `416` fordert vor einer spielbaren City-Preview zuerst Metrics,
  Walkability-/Reachability-, No-Walk-/No-Build- und Collision-Review.
- Der naechste Slice soll deshalb planen, welche Metriken und
  Reachability-Pruefungen aus der planning-only Extraction bewertet werden
  duerfen.
- Auch dieser Folgeslice darf noch keine Runtime-Daten, JSON/YAML, Flutter,
  Pathfinding oder Collision-Implementierung erzeugen.

## 11. Dokumentationsvisual

Erzeugt:

- `docs/world_design/previews/firenze_area_specification_planning_extraction_review_v1/firenze_area_specification_planning_extraction_review_v1.svg`
- `docs/world_design/previews/firenze_area_specification_planning_extraction_review_v1/firenze_area_specification_planning_extraction_review_v1.png`

Das Visual zeigt nur:

```text
428 Planning Extraction -> Review Checks -> PASS/BLOCKED -> Runtime bleibt gesperrt -> naechster Review-/Metrics-Slice
```

Es ist kein App-Screen, kein Asset und keine Runtime-Map.

## 12. Checks

| Check | Ergebnis |
| --- | --- |
| `git diff --check` | PASS |
| keine `.json`-/`.yaml`-/`.yml`-Dateien erzeugt | PASS |
| keine Aenderungen an `lib/` | PASS |
| keine Aenderungen an `pubspec.yaml` | PASS |
| keine Aenderungen an `assets/` | PASS |
| Visual-QA PNG/SVG | PASS |
| finaler `git status --short` zeigt nur Report 429 und Preview-Ordner | PASS |
