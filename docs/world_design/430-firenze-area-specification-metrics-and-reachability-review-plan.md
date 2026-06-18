# 430: Firenze Area-Specification Metrics and Reachability Review Plan

Stand: 2026-06-18

Status: `documentation_only` / `metrics_reachability_review_plan` /
`planning_only` / `not_runtime_data` / `no_json_yaml` / `no_flutter` /
`no_collision` / `no_pathfinding` / `no_coordinates` /
`no_app_integration` / `no_assets` / `no_commit`

## 1. Ziel

Dieser Slice plant den naechsten engen Review nach `429`.

Ziel:

- definieren, welche Metrics- und Reachability-Fragen vor einer spielbaren
  Firenze-City-Preview beantwortet werden muessen,
- klaeren, welche fachlichen Checks noetig sind, damit eine Figur spaeter
  glaubwuerdig laufen kann,
- Stop-Regeln fuer den spaeteren Review setzen,
- verhindern, dass Planning-Registries aus `428` versehentlich zu Runtime-,
  Flutter-, Collision-, Pathfinding- oder JSON/YAML-Daten werden.

Dieser Slice berechnet keine Metriken und prueft keine Reachability.

## 2. Non-Goals

- keine Metrikberechnung,
- keine Koordinatenextraktion,
- keine Reachability-Pruefung,
- kein Pathfinding,
- keine Collision-Pruefung,
- keine Runtime-Daten,
- keine finalen Koordinaten,
- keine produktiven Polygone,
- keine SVG-`path d`-Werte,
- keine Punktlisten,
- keine Weglaengen oder Gewichte,
- keine Runtime-Adjacency,
- keine JSON-/YAML-/YML-Datei,
- kein Flutter-/Dart-Code,
- keine Aenderungen an `lib/`, `pubspec.yaml` oder `assets/`,
- kein Commit.

## 3. Gelesene Grundlagen

- `AGENTS.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/416-talvori-playable-area-specification-standard-v1.md`
- `docs/world_design/426-firenze-master-technical-layout-readiness-check.md`
- `docs/world_design/427-firenze-area-specification-extraction-plan.md`
- `docs/world_design/428-firenze-area-specification-planning-extraction-v1.md`
- `docs/world_design/429-firenze-area-specification-planning-extraction-review-v1.md`

## 4. Ausgangspunkt aus `429`

`429` akzeptiert `428` als planning-only Extraction.

| Grundlage | Status fuer 430 |
| --- | --- |
| Master-SVG Source/SHA/ViewBox | PASS in `429` |
| Registry-Counts | PASS in `429` |
| Navigation-Edges aufloesbar | `221/221` in `429` |
| Bridge-Ketten B01-B08 | `8/8` in `429` |
| Parcel Access-/Entry-Paare P01-P14 | `28/28` in `429` |
| `city_spawn_start` | angebunden in `429` |
| `D001_internal_road_end` | angebunden in `429` |
| Runtime-Freigabe | NO |
| JSON/YAML-Freigabe | NO |
| Flutter-Preview-Freigabe | NO |

430 baut auf diesem PASS auf, erzeugt aber keine neuen Daten aus der SVG.

## 5. Ziel des spaeteren Metrics-/Reachability-Reviews

Der spaetere Review muss vor einer spielbaren City-Preview klaeren:

- ob die aus `428` dokumentierte Topologie als Planungsgrundlage fuer Bewegung
  vollstaendig genug ist,
- ob alle Parcels P01-P14 fachlich erreichbar sind,
- ob alle Bridge-Ketten B01-B08 als einzige Arno-Querungen plausibel pruefbar
  sind,
- ob Dead-Ends bewusst geplant und als solche markiert sind,
- ob die Trennung von Roads, Bridges, Parcels, Landmarks, Urban Blocks, River
  und Green Areas fuer No-Walk/No-Build-Reviews ausreicht,
- welche Review-Metriken spaeter benoetigt werden, ohne daraus Runtime-Werte
  abzuleiten.

Fachlich noetig fuer glaubwuerdige Figurenbewegung:

- zusammenhaengendes begehbares Road-/Bridge-Netz,
- keine isolierten relevanten Start-, Bridge-, Parcel- oder Landmark-Nodes,
- klare Trennung zwischen begehbaren Wegen und blockierenden Flaechen,
- River-Crossing nur ueber Bridge-Ketten,
- Parcels nur ueber Access-/Entry-Beziehungen betreten,
- Dead-Ends als bewusstes Navigationsende statt als kaputte Verbindung,
- No-Walk/No-Build-Konflikte sichtbar reviewbar, aber noch nicht als Runtime
  berechnet.

## 6. Erlaubte Review-Fragen

Der spaetere Review darf nur Fragen planen oder beantworten, die aus den
Planning-Registries und IDs ableitbar sind.

| Review-Frage | Erlaubter Status im spaeteren Review | Nicht erlaubt |
| --- | --- | --- |
| Sind alle Parcels P01-P14 ueber Access-/Entry-Paare erreichbar? | topology review / planning-only | keine Weglaengen, kein Pathfinding |
| Sind alle Bridge-Ketten B01-B08 logisch vollstaendig? | chain completeness review | keine Bridge-Deck-Geometrie als Runtime |
| Ist der Arno nur ueber Bruecken querbar? | crossing-policy review | keine Collision- oder River-Maske |
| Gibt es Dead-Ends und sind sie bewusst? | terminal/dead-end classification | keine automatischen Loeschungen |
| Gibt es isolierte Nodes? | connectivity risk review | keine Runtime-Adjacency |
| Gibt es No-Walk-/No-Build-Konflikte? | conflict-question list | keine Schnittberechnung ohne Gate |
| Sind Roads, Bridges, Parcels, Landmarks und Urban Blocks getrennt? | family separation review | keine produktive Layer-Maske |
| Welche Review-Werte waeren spaeter noetig? | metrics readiness list | keine Werte berechnen |

## 7. Spaeter benoetigte Review-Werte

Der spaetere Review darf vorbereiten, welche Werte benoetigt werden, ohne sie
in 430 zu berechnen.

| Wertfamilie | Zweck | Status |
| --- | --- | --- |
| `minimum_footpath_width_review` | pruefen, ob Wege fuer Figur/Companion plausibel breit sind | planned_only |
| `main_path_width_review` | Hauptwege von Nebenwegen unterscheiden | planned_only |
| `bridge_min_width_review` | Bridge-Ketten gegen plausible Querung pruefen | planned_only |
| `parcel_access_clearance_review` | Zugangspunkte gegen Blocker und Wege pruefen | planned_only |
| `min_distance_to_water_review` | River-Nahe als Warn- oder Schutzbereich bewerten | planned_only |
| `min_distance_to_landmark_core_review` | Landmark-Kerne schuetzen | planned_only |
| `dead_end_intent_review` | Sackgassen als bewusst oder Risiko klassifizieren | planned_only |
| `isolated_node_review` | nicht angebundene Punkte erkennen | planned_only |

Alle Werte bleiben Review-Werte. Keine Zahl aus einem spaeteren Review wird
ohne eigenes Runtime-Gate zu Engine-, Collision-, Flutter- oder Map-Daten.

## 8. Verbotene Inhalte

Der spaetere Metrics-/Reachability-Review darf nicht enthalten:

- produktive Koordinaten,
- Polygonpunkte,
- SVG-`path d`-Werte,
- Punktlisten,
- Weglaengen,
- Pfadgewichte,
- Runtime-Adjacency,
- Collision-Masks,
- Pathfinding-Daten,
- Flutter-/Dart-Daten,
- JSON-/YAML-/YML-Dateien,
- Dateien unter `assets/`,
- Aenderungen an `lib/` oder `pubspec.yaml`.

Wenn eine dieser Datenfamilien verlangt wird, muss der Review stoppen oder auf
ein eigenes Gate ausgelagert werden.

## 9. Geplanter Review-Aufbau

### 9.1 Source Consistency

Prueffragen:

- Ist die Master-SVG vorhanden?
- Stimmt die SHA mit `428`/`429`?
- Stimmen Canvas und ViewBox?
- Stimmen die erwarteten Counts weiterhin?

Stop bei Abweichung.

### 9.2 Metrics Readiness

Prueffragen:

- Welche Review-Metriken aus `416` sind fuer Firenze zuerst relevant?
- Welche Metriken werden nur als Frage notiert?
- Welche Metriken brauchen spaeter ein eigenes Mess-/Werte-Gate?

Nicht tun:

- keine Werte berechnen,
- keine Koordinaten lesen,
- keine Pfadbreiten aus SVG-Geometrie ableiten.

### 9.3 Reachability Readiness

Prueffragen:

- Sind Start, Bridge-Ketten, Parcels und relevante Road Nodes als Topologie
  vollstaendig genug beschrieben?
- Gibt es isolierte Nodes oder bewusst endende Wege?
- Welche Reachability-Risiken muessen spaeter visuell oder strukturell
  geprueft werden?

Nicht tun:

- kein Pathfinding,
- keine Laufwege berechnen,
- keine Runtime-Graphdaten erzeugen.

### 9.4 Bridge Crossing Review

Prueffragen:

- Sind B01-B08 vollstaendig dokumentiert?
- Gibt es fuer jede Bridge eine N/M/S-Kette?
- Ist die Arno-Querungsregel an Bridge-Ketten gebunden?
- Bleiben andere River-Crossings blockiert, bis ein Review sie freigibt?

### 9.5 Parcel Access Review

Prueffragen:

- Sind P01-P14 vollstaendig?
- Sind alle Access-/Entry-Paare vorhanden?
- Sind Parcels als Portale/Detail-Map-Einstiege geplant, nicht als direkte
  City-Build-Slots?
- Welche spaeteren Clearance- und No-Overlap-Fragen muessen vor City-Preview
  offen bleiben?

### 9.6 No-Walk/No-Build Separation Review

Prueffragen:

- River bleibt `no_walk_candidate` und `no_build_candidate`?
- Roads/Bridges bleiben `walk_candidate` und `no_build_candidate`?
- Landmarks bleiben protected core candidates?
- Urban Blocks bleiben blocked/no_build context candidates?
- Green Areas bleiben Kontext, nicht automatisch Walk- oder Build-Freigabe?

### 9.7 Dead-End Review

Prueffragen:

- Welche Road-End- und Internal-Dead-End-Nodes sind bewusst?
- Gibt es Sackgassen, die fachlich als Stadtstruktur plausibel sind?
- Gibt es Enden, die manuell nachgeprueft werden muessen?

### 9.8 Runtime Blocker Review

Prueffragen:

- Sind alle Review-Ergebnisse weiterhin `blocked_for_runtime`?
- Gibt es irgendeinen Output, der wie Engine-, JSON/YAML-, Flutter- oder
  Collision-Daten gelesen werden koennte?
- Muss ein eigenes Gate vor Werte-, Format- oder Flutter-Arbeit erstellt
  werden?

## 10. Stop-Regeln fuer den spaeteren Review

Der spaetere Metrics-/Reachability-Review muss stoppen, wenn:

- die Master-SVG fehlt,
- die SHA der Master-SVG abweicht,
- Canvas oder ViewBox abweichen,
- erwartete Counts abweichen,
- Edge-Endpunkte nicht aufloesbar sind,
- P01-P14 nicht vollstaendig sind,
- B01-B08 nicht vollstaendig sind,
- Access-/Entry-Paare nicht vollstaendig sind,
- `city_spawn_start` nicht angebunden ist,
- `D001_internal_road_end` nicht angebunden ist,
- Koordinaten, Pathfinding oder Collision ohne eigenes Gate verlangt werden,
- JSON/YAML/YML verlangt wird,
- `lib/`, `pubspec.yaml`, `assets/` oder Runtime-Dateien geaendert werden
  muessten.

## 11. Entscheidung

| Entscheidung | Ergebnis |
| --- | --- |
| Metrics-/Reachability-Review-Plan | PASS |
| Runtime-Freigabe | NO |
| JSON/YAML-Freigabe | NO |
| Flutter-Preview-Freigabe | NO |

430 gibt nur den Plan fuer den spaeteren Review frei. Es gibt keine Freigabe
fuer Messwerte, Runtime-Daten, JSON/YAML, Flutter, Collision oder Pathfinding.

## 12. Naechster engster Slice

Empfehlung:

```text
Firenze Area-Specification Metrics and Reachability Review v1
```

Grenzen fuer diesen naechsten Slice:

- weiterhin planning-only,
- keine produktiven Koordinaten,
- keine Polygonpunkte oder SVG-`path d`-Werte,
- keine Weglaengen oder Gewichte,
- keine Runtime-Adjacency,
- keine Collision-Masks,
- kein Pathfinding,
- keine JSON-/YAML-/YML-Datei,
- kein Flutter-/Dart-Code,
- keine Aenderungen an `lib/`, `pubspec.yaml` oder `assets/`.

Der naechste Slice darf nur die in Abschnitt 9 geplanten Review-Bloecke gegen
`428`/`429` bewerten.

## 13. Dokumentationsvisual

Erzeugt:

- `docs/world_design/previews/firenze_area_specification_metrics_and_reachability_review_plan/firenze_area_specification_metrics_and_reachability_review_plan.svg`
- `docs/world_design/previews/firenze_area_specification_metrics_and_reachability_review_plan/firenze_area_specification_metrics_and_reachability_review_plan.png`

Das Visual zeigt nur:

```text
429 Review PASS -> Metrics/Reachability Plan -> spaetere Review-Bloecke -> Runtime bleibt gesperrt
```

Es ist kein App-Screen, kein Asset und keine Runtime-Map.

## 14. Checks

| Check | Ergebnis |
| --- | --- |
| `git diff --check` | PASS |
| keine `.json`-/`.yaml`-/`.yml`-Dateien erzeugt | PASS |
| keine Aenderungen an `lib/` | PASS |
| keine Aenderungen an `pubspec.yaml` | PASS |
| keine Aenderungen an `assets/` | PASS |
| Visual-QA PNG/SVG | PASS |
| finaler `git status --short` zeigt nur Report 430 und Preview-Ordner | PASS |
