# 432: Firenze City Entry Planning Preview v1

Stand: 2026-06-18

Status: `documentation_only` / `planning_only` / `not_runtime_data` /
`no_json_yaml` / `no_flutter` / `no_collision` / `no_pathfinding` /
`no_coordinates` / `no_assets` / `no_commit`

## Ergebnis

Erstellt wurde die erste sichtbare, planning-only Firenze-City-Preview als
Dokumentationsvisual.

Dateien:

- `docs/world_design/previews/firenze_city_entry_planning_preview_v1/firenze_city_entry_planning_preview_v1.svg`
- `docs/world_design/previews/firenze_city_entry_planning_preview_v1/firenze_city_entry_planning_preview_v1.png`

Die Preview ist ein spielnah gestylter technischer Stadtblick. Sie ist kein
App-Screen, keine Runtime-Map und keine Area-Spec-Datei.

## Quelle

Verbindliche Quelle:

- `docs/world_design/previews/firenze_master_technical_layout/firenze_city_exploration_master.svg`

Der Preview-Slice nutzt die vorhandenen Master-SVG-Layer und Objekt-IDs als
Darstellungsquelle. Es wurden keine neuen Runtime-Geometrien, finalen
Koordinaten, Pathfinding-Daten oder Collision-Daten erzeugt.

## Sichtbare Layer

Die Preview zeigt:

- Boundary / spielbare Stadtgrenze
- Arno
- Bridges B01-B08
- Main Roads und Side Roads
- Parcels P01-P14
- Landmarks L01-L06
- `city_spawn_start`
- dezente Access-/Entry-Hinweise
- kompakte Leseschluessel fuer Boundary, Arno, Bridges, Parcels, Landmarks und
  Access/Entry

Labels wurden auf Parcels, Bridges, Landmarks und Start priorisiert, damit die
Karte die Hauptflaeche bleibt und nicht wie ein technisches Board wirkt.

## Grenzen

Nicht erzeugt:

- keine JSON-/YAML-/YML-Datei
- keine Flutter-Preview
- keine Runtime-Geometrie
- keine finalen Koordinaten
- keine Metriken
- kein Pathfinding
- keine Collision
- keine Build-Logik
- keine Persistenz
- keine Aenderungen an `lib/`, `pubspec.yaml` oder `assets/`

## Visual-QA

| Check | Ergebnis |
| --- | --- |
| PNG erzeugt | PASS |
| SVG erzeugt | PASS |
| Karte bleibt Hauptflaeche | PASS |
| keine abgeschnittenen Labels | PASS |
| keine ueberfuellte Legende | PASS |
| Text bleibt lesbar | PASS |
| kein Tabellen-/Debug-/GIS-Look als Hauptwirkung | PASS |

## Entscheidung

| Entscheidung | Ergebnis |
| --- | --- |
| Planning Preview v1 | PASS |
| Runtime-Freigabe | NO |
| JSON/YAML-Freigabe | NO |
| Flutter-Freigabe aus diesem Slice | NO |

## Naechste Empfehlung

Naechster konkreter Ergebnis-Slice:

```text
Firenze City Entry visual-only Flutter Preview v1
```

Dieser Folgeslice darf nur nach expliziter Code-Scope-Freigabe starten. Er
duerfte die Master-SVG bzw. dieses Preview-Visual nur visuell laden und bleibt
weiterhin ohne Runtime-Geometrie, finale Koordinaten, JSON/YAML, Pathfinding,
Collision, Build-State oder Persistenz.

## Checks

| Check | Ergebnis |
| --- | --- |
| `git diff --check` | PASS |
| keine `.json`-/`.yaml`-/`.yml`-Dateien erzeugt | PASS |
| keine Aenderungen an `lib/` | PASS |
| keine Aenderungen an `pubspec.yaml` | PASS |
| keine Aenderungen an `assets/` | PASS |
| finaler `git status --short` | zeigt nur Report 432 und Preview-Ordner |
