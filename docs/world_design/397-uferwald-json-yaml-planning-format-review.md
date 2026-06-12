# M16-DN: Uferwald JSON/YAML Planning Format Review

Stand: 2026-06-12

Status: `Docs-/Review-Gate / keine JSON-YAML-Dateien / keine Runtime-Daten`

Template: `docs/world_design/prompt_templates/review_slice.md`

## 1. Zweck

M16-DN reviewt das M16-DM Uferwald JSON/YAML Planning Format Gate und
entscheidet, ob die Formatregeln ausreichend sind, um danach einen sehr engen
YAML Planning Skeleton Gate Slice vorzubereiten.

M16-DN erzeugt keine `.json`, `.yaml` oder `.yml` Datei. Das Review bleibt
Markdown-only und gibt keine Runtime-Daten, finalen Koordinaten, Polygone,
Path-Centerlines, Path-Nodes, Assets, App-Integration oder Code frei.

## 2. Review-Basis

Gelesene Pflichtdokumente:

- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/396-uferwald-json-yaml-planning-format-gate.md`
- `docs/world_design/395-uferwald-planning-schema-review.md`
- `docs/world_design/394-uferwald-technical-planning-schema-gate.md`
- `docs/world_design/393-uferwald-visual-precision-review.md`
- `docs/world_design/392-uferwald-measurement-visual-precision-pass.md`
- `docs/world_design/391-uferwald-measurement-precision-pass.md`
- `docs/world_design/390-uferwald-technical-measurement-review.md`
- `docs/world_design/389-uferwald-measurement-svg-documentation-plan.md`
- `docs/world_design/388-uferwald-measurement-source-and-vector-workspace-plan.md`
- `docs/world_design/387-uferwald-technical-measurement-and-vector-planning-gate.md`
- `docs/world_design/386-uferwald-technical-layer-manifest.md`
- `docs/world_design/385-uferwald-technical-layer-and-mask-spec.md`
- `docs/world_design/384-uferwald-playable-map-layer-and-mask-architecture.md`

Fuehrende Schutzregel:

> Sichtbares Art-Bild, Visual-Overlay, Schema-Snippet oder Planning-Skeleton ist
> nicht die technische Runtime-Spielkarte.

## 3. Kurzfazit

M16-DM ist ausreichend. Das Format-Gate entscheidet YAML nachvollziehbar als
erstes spaeteres Planning-Format, begrenzt echte Dateien auf einen separaten
Folgeprompt und schuetzt die kritischen Felder gegen Runtime-, Koordinaten-,
Polygon- und Pixelableitungsdrift.

Ein M16-DM-FIX ist nicht noetig.

Ein M16-DO YAML Planning Skeleton Gate darf vorbereitet werden, aber nur unter
enger Folgefreigabe:

- Der M16-DO-Prompt muss exakten Pfad und Dateinamen nennen.
- Der M16-DO-Prompt muss echte `.yaml`-Erzeugung ausdruecklich erlauben.
- Der M16-DO-Prompt muss Statusschutz und Datei-Check wiederholen.
- M16-DO darf maximal ein `planning_skeleton` erzeugen.
- M16-DO darf weiterhin keine Runtime-Daten, finalen Koordinaten, Polygone,
  Path-Centerlines, Path-Nodes, Build-Zonen-Polygone oder No-Walk-/No-Build-
  Unionen als echte Werte enthalten.

## 4. Fachliche Pruefung M16-DM

| Prueffeld | Status | Review |
| --- | --- | --- |
| YAML-vs-JSON-Entscheidung | ausreichend | YAML ist fuer den naechsten Skeleton-Schritt sinnvoller als JSON, weil offene Messfragen, Blockerstatus und Review-Kommentare lesbarer bleiben. JSON kann spaeter nach Review folgen, aber nicht als erster Schritt. |
| Erlaubter spaeterer Planning-Pfad | ausreichend | M16-DM nennt einen moeglichen spaeteren Pfad unter `docs/world_design/planning/uferwald/`, erzeugt ihn aber nicht. Das ist korrekt, solange M16-DO Pfad und Dateiname erneut explizit oeffnet. |
| Pflichtstatuswerte | ausreichend | `planning_skeleton`, `not_runtime_data`, `not_asset`, `not_engine_ready`, `no_geometry_values`, `no_final_coordinates`, `pixel_derivation_forbidden` und `manual_measurement_required` sind stark genug als Mindestschutz. |
| Erlaubte Feldgruppen | ausreichend | `schema_header`, `format_contract`, `status_protection`, `source_docs`, `visual_references`, `layer_definitions`, `geometry_placeholders`, `qa_requirements`, `open_measurements`, `blocked_scope` und `next_review_gate` passen zum Schema-Gate aus 394. |
| Erlaubte Layer-Felder | ausreichend | Die Felder beschreiben Rollen, Status, erlaubte Modi, Datenform-Kandidaten, QA und offene Messfragen, ohne echte Geometriewerte zu verlangen. |
| Verbotene Felder und Werte | ausreichend | M16-DM blockiert die entscheidenden Driftpunkte: `geometry_values`, `coordinate_values`, `polygon_points`, `path_centerline`, `path_nodes`, `path_edges`, `build_zone_polygons`, `plot_footprint_polygons`, echte No-Walk-/No-Build-Unionen und Runtime-/Asset-/Engine-ready-Status. |
| Erlaubte Platzhalter | ausreichend | Platzhalter wie `geometry_kind_candidate`, `measurement_question` und `blocked_until_gate` sind passend, solange sie keine Pseudo-Koordinaten oder implizite Werte enthalten. |
| Illustrative YAML-Snippets im Markdown | ausreichend mit Wachsamkeit | Die Snippets sind klar als `illustrative_schema_snippet`, `not_file`, `not_runtime_data`, `no_geometry_values` und `no_final_coordinates` markiert. Risiko bleibt, dass sie zu direkt kopiert werden. M16-DO muss deshalb eigene Skeleton-Grenzen wiederholen und keine Werte aus dem Snippet als Runtime-Struktur behandeln. |
| QA-Regeln vor echter Datei | ausreichend | Datei-Check, Statusschutz, keine Geometriewerte, kein Pixeltracing und keine Runtime-Freigabe sind als QA vor M16-DO passend. |
| Datei-Check gegen `.json`, `.yaml`, `.yml` | ausreichend | M16-DM verlangt den Check und erzeugt selbst keine echte Datei. M16-DN muss diesen Schutz bestaetigen; M16-DO darf ihn nur fuer genau die explizit erlaubte `.yaml`-Skeleton-Datei oeffnen. |

## 5. Risikopruefung

### 5.1 Wird YAML zu frueh als echte Datei geoeffnet?

Nein. M16-DM bleibt Markdown-only und sagt klar, dass eine echte Datei erst in
einem separaten Folgeprompt mit Pfad, Dateiname, Statusschutz und Datei-Check
erlaubt waere.

### 5.2 Wirkt der illustrative Snippet zu sehr wie Runtime-Struktur?

Teilweise, aber kontrolliert. Der Snippet ist kopierbar im Sinne eines
Schema-Beispiels, aber die Schutzmarker sind deutlich. M16-DO muss vermeiden,
aus dem Snippet echte Geometrie, Pfadknoten, Runtime-Werte oder finale
Koordinaten abzuleiten.

### 5.3 Sind `not_runtime_data`, `no_geometry_values` und
`no_final_coordinates` stark genug?

Ja. Zusammen mit `pixel_derivation_forbidden`, `manual_measurement_required`
und `runtime_review_required_before_use` bilden sie einen ausreichenden
Statusschutz fuer ein spaeteres Planning Skeleton.

### 5.4 Bleiben echte Geometrie und Pfadlogik blockiert?

Ja. M16-DM blockiert Koordinaten, Polygonpunkte, Path-Centerlines, Path-Nodes,
Path-Edges, Build-Zonen-Polygone, Plot-Footprint-Polygone sowie No-Walk- und
No-Build-Unionen als echte Werte. Das ist die richtige Grenze vor M16-DO.

### 5.5 Bleiben Code, Assets, Figma-Writes und App-Integration blockiert?

Ja. M16-DM bleibt ein Format-Gate und oeffnet keine Flutter-/Dart-Dateien,
keine Assets, keine Dateien unter `assets/`, keine Figma-Writes und keine App-
Integration.

## 6. Entscheidung

| Entscheidung | Ergebnis |
| --- | --- |
| M16-DM ausreichend | JA |
| M16-DM-FIX noetig | NEIN |
| M16-DO YAML Planning Skeleton Gate vorbereiten | JA |
| M16-DO darf echte `.yaml` erzeugen, wenn der Folgeprompt Pfad, Dateiname, Statusschutz und Datei-Check ausdruecklich oeffnet | JA, aber nur als `planning_skeleton` und weiterhin ohne Geometriewerte |
| M16-DO darf echte `.json` oder `.yml` erzeugen | NEIN, nicht ohne separate explizite Folgefreigabe |
| M16-DO darf Runtime-Daten erzeugen | NEIN |
| M16-DO darf finale Koordinaten, Polygone, Path-Centerlines oder Path-Nodes erzeugen | NEIN |
| M16-DO darf Assets, Code oder App-Integration erzeugen | NEIN |

## 7. Zwingende Grenzen fuer M16-DO

M16-DO muss mindestens diese Grenzen behalten:

- Exakter erlaubter Pfad und Dateiname muessen im Prompt stehen.
- Empfohlener erster Dateityp: `.yaml`, nicht `.json` und nicht `.yml`.
- Maximalstatus: `planning_skeleton`.
- Pflichtstatus am Dateianfang:
  - `runtime_status: not_runtime_data`
  - `asset_status: not_asset`
  - `engine_status: not_engine_ready`
  - `geometry_status: no_geometry_values`
  - `coordinate_status: no_final_coordinates`
  - `pixel_derivation_policy: pixel_derivation_forbidden`
  - `measurement_status: manual_measurement_required`
  - `runtime_review_requirement: runtime_review_required_before_use`
- Keine echten Koordinaten.
- Keine Polygonpunkte.
- Keine Path-Centerlines.
- Keine Path-Nodes oder Path-Edges.
- Keine Build-Zonen-Polygone.
- Keine Plot-Footprint-Polygone.
- Keine No-Walk- oder No-Build-Unionen als echte Werte.
- Keine Ableitung aus Pixeln.
- Keine Runtime-, Engine-ready-, Asset-, App- oder Persistenzfreigabe.
- Datei-Check muss berichten, dass nur die explizit erlaubte `.yaml`-Datei neu
  entstanden ist und keine `.json`-/`.yml`-Nebenprodukte erzeugt wurden.

## 8. Was M16-DO sinnvoll erzeugen duerfte

Wenn der Folgeprompt es ausdruecklich oeffnet, darf M16-DO eine einzige
YAML-Skeleton-Datei als Planungsstruktur erzeugen. Diese Datei darf enthalten:

- leere oder textuelle Feldgruppen,
- Layer-IDs,
- Statusschutz,
- Feldnamen,
- erlaubte Datenform-Kandidaten,
- offene Messfragen,
- QA-Anforderungen,
- blockierte Nutzungen,
- Platzhalter mit klarer `not_measured`-/`blocked_until_gate`-Kennzeichnung.

Sie darf nicht enthalten:

- echte Geometriewerte,
- final wirkende Normalized-Koordinaten,
- Listen von Polygonpunkten,
- Pfadgraphen,
- Collision-Werte,
- Build-Zonen als Daten,
- Runtime-Verweise,
- Asset-Pfade oder Flutter-Integrationshinweise.

## 9. Nicht-Freigaben

M16-DN gibt nicht frei:

- keinen Code,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- keinen BuildState,
- keine Runtime-Mapdaten,
- keine Tests,
- keine Bilder,
- keine SVG/PNG,
- keine `.json`,
- keine `.yaml`,
- keine `.yml`,
- keine Assets,
- keine Dateien unter `assets/`,
- keine finalen Koordinaten,
- keine Polygone,
- keine Path-Centerlines,
- keine Path-Nodes,
- keine Figma-Writes,
- keine Engine-ready Candidates,
- keine approved Assets,
- keinen Commit.

## 10. Empfohlener naechster Slice

Empfohlen:

```text
M16-DO Uferwald YAML Planning Skeleton Gate
```

M16-DO darf eine echte YAML-Datei nur erzeugen, wenn der Folgeprompt dies
ausdruecklich erlaubt und den exakten Pfad, Dateinamen, Maximalstatus,
Statusschutz und Datei-Check nennt. Ohne diese explizite Oeffnung bleibt auch
M16-DO Markdown-only.
