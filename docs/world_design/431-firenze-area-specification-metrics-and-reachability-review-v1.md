# 431: Firenze Area-Specification Metrics and Reachability Review v1

Stand: 2026-06-18

Status: `documentation_only` / `metrics_reachability_review_v1` /
`planning_only` / `not_runtime_data` / `no_json_yaml` / `no_flutter` /
`no_collision` / `no_pathfinding` / `no_coordinates` /
`no_app_integration` / `no_assets` / `no_commit`

## 1. Ziel

Dieser Slice prueft den in `430` geplanten Metrics-/Reachability-Review gegen
die planning-only Extraction aus `428` und den Review aus `429`.

Ergebnisziel:

- pruefen, ob Source/SHA/Canvas/ViewBox weiterhin stabil sind,
- pruefen, ob die erwarteten Registry-Counts weiterhin vollstaendig sind,
- pruefen, ob die Topologie fuer eine erste planning-only Firenze-City-Preview
  ausreichend geschlossen ist,
- klaeren, ob vor einer ersten Preview noch ein struktureller Blocker bleibt.

Dieser Slice berechnet keine Metriken und erzeugt keine Runtime-Daten.

## 2. Non-Goals

- keine Koordinatenextraktion,
- keine Metrikberechnung,
- keine SVG-`path d`-Werte,
- keine Punktlisten,
- keine Weglaengen oder Gewichte,
- kein Pathfinding,
- keine Collision,
- keine Runtime-Adjacency,
- keine JSON-/YAML-/YML-Datei,
- kein Flutter-/Dart-Code,
- keine Aenderungen an `lib/`, `pubspec.yaml` oder `assets/`,
- keine neue Plan-Dokumentationsschleife,
- kein Commit.

## 3. Gelesene Routing-Grundlagen

- `AGENTS.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/428-firenze-area-specification-planning-extraction-v1.md`
- `docs/world_design/429-firenze-area-specification-planning-extraction-review-v1.md`
- `docs/world_design/430-firenze-area-specification-metrics-and-reachability-review-plan.md`

## 4. Start-Gate

| Check | Ergebnis |
| --- | --- |
| Arbeitsbaum vor Start | sauber |
| erwarteter HEAD | `8e1f69af docs: update firenze reading rules` |
| tatsaechlicher HEAD | `8e1f69af docs: update firenze reading rules` |
| Master-SVG vorhanden | PASS |
| Scope `lib/` | nicht geaendert |
| Scope `pubspec.yaml` | nicht geaendert |
| Scope `assets/` | nicht geaendert |

## 5. Source-/SHA-/Canvas-/ViewBox-Review

| Pruefung | Erwartet aus 428/429 | Aktuell | Status |
| --- | --- | --- | --- |
| Source-Pfad | `docs/world_design/previews/firenze_master_technical_layout/firenze_city_exploration_master.svg` | vorhanden | PASS |
| SHA-256 | `58d7f5cf0d6d09d8d42dbe03f74d0439b7f231787e1d0b8acad84002eaa733d3` | `58d7f5cf0d6d09d8d42dbe03f74d0439b7f231787e1d0b8acad84002eaa733d3` | PASS |
| Canvas width | `1672` | `1672` | PASS |
| Canvas height | `941` | `941` | PASS |
| ViewBox | `0 0 442.38333 248.97292` | `0 0 442.38333 248.97292` | PASS |

Ergebnis: `PASS`.

## 6. Count-Review

| Familie | Erwartet | Aktuell | Status |
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

## 7. Topology-/Reachability-Review

Die Pruefung ist ID- und Topologie-basiert. Sie nutzt nur Objekt-IDs aus
`11_navigation_nodes`, `10_anchor_points` und `12_navigation_edges`, wie in
`428` dokumentiert. Es wurden keine Koordinaten, Pfadpunkte, Weglaengen,
Gewichte, Collision-Masken oder Runtime-Graphdaten extrahiert.

| Pruefung | Ergebnis | Status |
| --- | --- | --- |
| Navigation-Edges aufloesbar | 221/221 | PASS |
| Nicht aufloesbare Edges | 0 | PASS |
| Mehrdeutige Edges | 0 | PASS |
| Offene `E_needs_manual_review`-Edges | 0 | PASS |
| Zusammenhaengender Topologie-Graph fuer beruehrte Endpunkte | 1 Komponente | PASS |
| Isolierte Navigation-Nodes | 0 | PASS |
| Riskante, nicht klassifizierte Dead-Ends | 0 | PASS |

Hinweis: `city_spawn_start` liegt als Start-Anchor in `10_anchor_points` und
nicht als Child von `11_navigation_nodes`. `428` behandelt ihn dennoch bewusst
als Topologie-Endpunkt; die zwei zugehoerigen Edges sind eindeutig aufloesbar.
Das ist fuer diesen planning-only Review kein Blocker. Vor Runtime-Nahe muss
ein eigenes Gate klaeren, ob Start-Anker als Graph-Endpoint-Familie oder als
separater Spawn-Typ gefuehrt werden.

## 8. Parcel Access Review

| Pruefung | Ergebnis | Status |
| --- | --- | --- |
| Parcels P01-P14 vorhanden | 14/14 | PASS |
| Access-/Entry-Paare vorhanden | 28/28 | PASS |
| Access-/Entry-Paare verbunden | 28/28 | PASS |
| Access-Nodes an Road-/Bridge-Topologie angebunden | 28/28 | PASS |
| Parcel-Erreichbarkeit als planning-only Topologie | P01-P14 erreichbar | PASS |

Bewertung: Alle Parcels sind fuer eine planning-only Preview ueber ihre
Access-/Entry-Paare fachlich erreichbar. Das ist keine Build-Slot- oder
Runtime-Freigabe; Parcels bleiben `portal_candidate` /
`detail_map_entry_candidate`.

## 9. Bridge- und Arno-Crossing Review

| Pruefung | Ergebnis | Status |
| --- | --- | --- |
| Bridge Decks B01-B08 vorhanden | 8/8 | PASS |
| Bridge-Nodes B01-B08 mit N/M/S vorhanden | 8/8 | PASS |
| Bridge-Ketten N -> M -> S vollstaendig | 8/8 | PASS |
| N-/S-Enden an Road-Topologie angebunden | 8/8 | PASS |
| Arno-Crossing-Policy an Bridge-Ketten gebunden | ja, planning-only | PASS |

Bewertung: Die Arno-Querungsregel ist fuer diesen Review an die Bridge-Ketten
B01-B08 gebunden. Eine geometrische Schnittpruefung, ob eine Linie den River
kreuzt, wurde bewusst nicht berechnet und bleibt fuer Runtime-/Collision-Nahe
gesperrt.

## 10. Start- und Dead-End Review

| Pruefung | Ergebnis | Status |
| --- | --- | --- |
| `city_spawn_start` angebunden | 2 Edges | PASS |
| `D001_internal_road_end` angebunden | 1 Edge, bewusstes internes Ende | PASS |
| Boundary-Road-End-Nodes | als `T###_road_end` klassifiziert | PASS |
| Parcel-Entry-Enden | als Parcel-Entry-Enden klassifiziert | PASS |
| riskante Dead-Ends | 0 | PASS |

Bewertung: Es gibt keine isolierten Nodes und keine unklassifizierten
Sackgassen. `D001_internal_road_end` bleibt ein bewusstes internes
Sackgassen-Ende, kein Boundary-Ausgang.

## 11. No-Walk-/No-Build-Rollen

| Familie | Rolle aus 428/430 | Review-Ergebnis |
| --- | --- | --- |
| River | `no_walk_candidate` + `no_build_candidate` | sauber getrennt, PASS |
| Roads | `walk_candidate` + `no_build_candidate` | sauber getrennt, PASS |
| Bridges | `walk_candidate` + `no_build_candidate` | sauber getrennt, PASS |
| Parcels | `portal_candidate` / `detail_map_entry_candidate` | keine direkte City-Build-Freigabe, PASS |
| Landmarks | `protected_core_candidate` | no-build/protection bleibt planning-only, PASS |
| Urban Blocks | `blocked_context_candidate` / `no_build_candidate` | sauber getrennt, PASS |
| Green Areas | `context_candidate` | keine automatische Walk-/Build-Freigabe, PASS |

Bewertung: Die Rollen sind ausreichend getrennt fuer eine erste
planning-only Preview. Sie sind keine Runtime-Masks, keine Collision-Masks und
keine Engine-Regeln.

## 12. Blocker vor erster Firenze-City-Preview

| Frage | Ergebnis |
| --- | --- |
| Struktureller Blocker fuer eine erste planning-only City-Preview | `NO` |
| Runtime-City-Entry freigegeben | `NO` |
| JSON/YAML-Freigabe | `NO` |
| Flutter-Code in diesem Slice | `NO` |

Es gibt keinen strukturellen Blocker mehr fuer einen engen ersten
Firenze-City-Preview-Slice, sofern dieser ausdruecklich planning-only bleibt.
Diese Preview darf nur die Master-SVG bzw. daraus abgeleitete Review-IDs als
Quelle lesen und keine Runtime-Geometrie, keine finalen Koordinaten, kein
Pathfinding, keine Collision, keine Build-Logik und keine Persistenz erzeugen.

## 13. Ergebnisentscheidung

| Entscheidung | Ergebnis |
| --- | --- |
| Metrics-/Reachability-Review v1 | `PASS` |
| Planning-only Topologie ausreichend fuer ersten Preview-Slice | `PASS` |
| Runtime-Freigabe | NO |
| JSON/YAML-Freigabe | NO |
| Collision-/Pathfinding-Freigabe | NO |

## 14. Naechster konkreter Ergebnis-Slice

Empfehlung:

```text
Firenze City Entry Planning Preview v1
```

Scope fuer diesen naechsten Slice:

- eine erste visuelle, planning-only Firenze-City-Preview,
- Quelle: `firenze_city_exploration_master.svg` und die dortigen
  Layer-/Objekt-IDs,
- sichtbare Boundary, River, Bridges, Roads, Parcels, Landmarks und
  einfache Start-/Graph-Hinweise,
- keine Runtime-Geometrie,
- keine JSON-/YAML-/YML-Datei,
- keine finalen Koordinaten,
- keine Collision,
- kein Pathfinding,
- keine Build-Slots als Spielzustand,
- keine Persistenz.

Vor Runtime- oder Area-Spec-Dateien bleibt ein eigenes Gate erforderlich.

## 15. Optionales Visual

Kein neues Visual erzeugt. Der Review ist absichtlich eng und tabellarisch;
das optionale Visual waere fuer diesen PASS kein zusaetzlicher Erkenntniswert
und wuerde die gerade beendete Dokumentationsschleife unnoetig verlaengern.

## 16. Checks

| Check | Ergebnis |
| --- | --- |
| `git diff --check` | PASS |
| keine `.json`-/`.yaml`-/`.yml`-Dateien erzeugt | PASS |
| keine Aenderungen an `lib/` | PASS |
| keine Aenderungen an `pubspec.yaml` | PASS |
| keine Aenderungen an `assets/` | PASS |
| finaler `git status --short` | zeigt nur Report 431 |
