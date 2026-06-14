# 415: Firenze Playable City Ground Layer And Anchors Gate

Stand: 2026-06-14

Status: `documentation_only` / `planning_visual` / `not_asset` /
`not_runtime_data` / `not_engine_ready` / `no_yaml_json` /
`no_app_integration`

## 1. Ziel des Gates

Dieses Gate stoppt die freie Florenz-City-Entry-Umsetzung und definiert die
naechste saubere Grundlage fuer die erste betretbare Stadt.

Ziel:

- Firenze bleibt die erste Stadt-Greybox aus `412`.
- Die Stadt darf erst betreten werden, wenn Ground, Layer und Anchors als
  nachvollziehbare Planung vorliegen.
- Bau-/Lernorte muessen aus einer Stadtgrundflaeche, inneren Spielbereichen,
  Pfaden, Blockern und Ankern abgeleitet werden.
- Dieses Gate erzeugt nur Dokumentation und ein Planungsvisual.

Nicht-Ziele:

- keine City-Entry-App-Preview,
- keine neue Flutter-/Dart-Implementierung,
- keine App-Integration,
- keine Route,
- keine Persistenz,
- kein BuildState,
- keine Assets,
- keine Dateien unter `assets/`,
- keine Runtime-Daten,
- keine finalen Koordinaten,
- keine produktiven Polygone,
- keine YAML-/JSON-/YML-Dateien,
- kein Commit.

## 2. Gepruefte Grundlagen

| Grundlage | Relevanz fuer dieses Gate |
| --- | --- |
| `AGENTS.md` | Talvori Welt, Reuse-before-build, Stop-Regeln, keine Persistenz/App-Daten ohne Freigabe. |
| `328-talvori-learning-game-readiness-todo-checklist.md` | M16T-WORLD-Folgepfad, Firenze als erster City-Zoom, Commit-/Gate-Hygiene. |
| `336-documentation-map-and-slice-reading-rules.md` | Pflichtlektuere fuer World-/City-/Build-/Preview-Slices. |
| `409-europe-country-city-zoom-architecture-gate.md` | Europa -> Land -> Stadtanker -> Stadtgrundform -> Stadtbereich -> Bauflaechen/Wege. |
| `410-italy-city-footprints-istat-comuni-gate.md` | ISTAT-Comuni-Quelle fuer Firenze, `PRO_COM_T=048017`, keine Runtime-Polygone. |
| `411-italy-playable-city-areas-from-footprints.md` | Abstrahierter Firenze-`playable_city_area`-Kandidat, noch keine Layerdaten. |
| `412-italy-playable-city-area-review-and-first-city-decision.md` | Firenze ist erste Stadt-Greybox; Roma und Bologna bleiben Reserve. |
| `413-world-travel-zoom-navigation-gameflow-gate.md` | Firenze ist erster City-Zoom, aber 411/412 bleiben Backstage-Dokumentation. |
| `414-world-travel-preview-fail-review-and-source-based-rebuild-plan.md` | Keine frei erfundenen Stadtformen, wenn Source-Grundlagen vorhanden sind. |
| `384-uferwald-playable-map-layer-and-mask-architecture.md` | Sichtbares Bild ist nicht technische Spielkarte; Layer/Masks vor Interaktion. |
| `385-uferwald-technical-layer-and-mask-spec.md` | Buildable, Path, No-Walk, No-Build und Landmark-Anchors muessen getrennt werden. |
| `416-talvori-playable-area-specification-standard-v1.md` | Allgemeiner Area-Spec-Standard fuer Boundary, Metrics, Build Slots, Occupancy, Collision, Navigation, No-Walk/No-Build, Anchors und Visual-QA. |
| `417-firenze-playable-city-layout-blueprint-v5.md` | Gueltiger Folgepfad nach 416: Expanded Florence Shape and Landmark-Aware Infrastructure Review mit groesserer Florenz-orientierter Ground-Shape, 14 Parcel Candidates, B1-B3 als einzigen Arno-Querungen, organischem Wegenetz, Vegetationspuffern, L1-L5 Landmark-Ankern, Depth-/Sorting-Bands, No-Walk/No-Build, Anchors und Reachability-Review. |
| `221-talvori-world-build-and-expansion-architecture.md` | Keine freie Pixelplatzierung; BuildZones, PathNodes, blockedAreas und Anchors sind logische Schicht. |
| `272-plot-capability-derivation.md` | Plot-Capabilities sind Erlaubnisse, keine Pflichtbelegung oder Auto-Placement. |
| `318-theme-island-plot-capacity-and-build-wheel-plan.md` | Grundstuecke entstehen aus Bedarf, bleiben austauschbar und ohne BuildState. |
| `403-uferwald-island-build-blueprint-rule.md` | Uferwald-Regeln werden auf Italien/Stadt-Greybox uebertragen: Layer zuerst, Spielgefuehl danach. |

## 3. Warum die freie City-Entry-WIP nicht zulaessig war

Die abgelehnte WIP in der isolierten World-Travel-Preview hatte bereits eine
frei gezeichnete Florenz-Stadtflaeche, frei gesetzte Orte und lokale
Bau-/Lernpunkte erzeugt.

Problem:

- Die Grundflaeche war nicht aus dem ISTAT-Footprint und dem `411`-Kandidaten
  als freigegebener Ground-Layer abgeleitet.
- Fluss, Bruecke, Wege und Dachcluster wurden frei im Flutter-Painter gesetzt.
- Bauplaetze wie `Bauflaeche Nord`, `Bauflaeche Arno` und
  `Bauflaeche Garten` waren nicht aus `buildable_ground_candidates` abgeleitet.
- Piazza, Atelier, Archiv und Lernort hatten keine Landmark-/Anchor-Logik.
- No-Walk und No-Build waren nicht getrennt.
- Es gab keine Start-Anker, keine Path-Kandidaten, keine Bridge-Anker und keine
  Visual-QA gegen Layer-Grenzen.
- Der Slice sprang von Stadtentscheidung direkt zu City-Entry-UI und ueberging
  die Produktionsreihenfolge aus `384`, `385` und `404`.

Entscheidung:

```text
Die freie City-Entry-WIP wird nicht als Implementierungsrichtung weitergefuehrt.
```

## 4. Firenze als erste Stadt

`412` legt Firenze als erste Stadt fuer den naechsten Greybox-Pfad fest.

Begruendung aus `412`:

- starke Kultur- und Lernortidentitaet,
- kleiner und kontrollierbarer als Roma,
- emotional staerker als ein rein technischer Milano-Test,
- weniger wasser-/brueckenlastig als Venezia,
- geeignet fuer Stadtkern, ruhige Reserve, Start-Bauplatz, Wege, Lernorte und
  No-Build-Rand.

Reserve-Kandidaten:

- Roma,
- Bologna.

Dieses Gate uebernimmt nur die Entscheidung. Es erzeugt keine spielbare
Stadtkarte und keine App-Ansicht.

## 5. Source-Grundlage

Firenze kommt aus der ISTAT-Comuni-Quelle aus `410`.

| Feld | Wert |
| --- | --- |
| source_owner | Istat - Istituto nazionale di statistica |
| source_dataset | Confini delle unita amministrative a fini statistici |
| source_year | 2026 |
| source_variant | version generalizzata |
| source_level | `comuni` / municipality boundaries |
| ISTAT `COMUNE` | `Firenze` |
| ISTAT `PRO_COM_T` | `048017` |
| license_model | CC BY 4.0, sofern auf der Istat-Seite nicht anders angegeben |
| status | documentation source only |

Grenze:

Der ISTAT-Footprint ist Quellenform fuer Review und Ableitung. Er ist kein
Runtime-Polygon, keine Collision, keine Build-Zone, kein Pathfinding und keine
App-Datenstruktur.

## 6. Abgeleiteter Playable-City-Area-Kontext

`411` beschreibt Firenze als:

- Kulturkern,
- Handwerk-/Archiv-Raum,
- ruhiger Startbereich,
- weicher Reservebereich,
- Rand-/No-Build-Kontext.

Dieses Gate fuehrt diese Idee nicht als finale Geometrie fort. Es verlangt
zuerst eine explizite Ground-/Layer-/Anchor-Planung.

## 7. Benoetigte Layer

Der naechste Florenz-Plan muss mindestens diese Layer/Ankerfamilien liefern:

| Layer / Anchor | Zweck | Nicht freigegeben |
| --- | --- | --- |
| `firenze_city_ground_shape` | abstrahierte aeussere Stadtgrundflaeche aus ISTAT/411-Kontext | kein Runtime-Polygon |
| `firenze_playable_city_area` | innerer betretbarer Review-Bereich | keine Collision |
| `firenze_path_network_layer` | grobe Pfad-/Wege-Kandidaten zu allen Orten | keine Path-Nodes fuer Runtime |
| `firenze_river_bridge_layer` | Arno-/Fluss-Korridor und Bruecken-Anker als Pruef-Layer | keine Wasser-/Brueckenlogik im Code |
| `firenze_buildable_ground_candidates` | organische Bauflaechen-Kandidaten, aus Ground/Paths abgeleitet | keine finalen Slots |
| `firenze_reserved_ground` | spaetere Reserveflaechen | keine Unlock-Logik |
| `firenze_no_walk_layer` | Bewegungs-Blocker fuer Wasser, Rand, enge Kanten, Landmark-Schutz | keine Runtime-Maske |
| `firenze_no_build_layer` | Bau-Blocker fuer Wasser, Wege, Landmarken, Randbereiche | keine Runtime-Maske |
| `firenze_landmark_anchor_layer` | benannte Bezugspunkte fuer Kultur, Archiv, Piazza, Bruecke, Lernort | keine UI-Orte ohne Gate |
| `firenze_start_anchor` | erster Start-/Ankunftsanker fuer die Stadt-Greybox | kein Spawn-/Routing-Code |

Diese Namen sind Planungsbegriffe. Sie duerfen spaeter in einem eigenen
Format-Gate praezisiert werden, aber dieses Dokument erzeugt keine YAML/JSON.

## 8. Dokumentationsvisual

Erlaubter Preview-Pfad:

```text
docs/world_design/previews/firenze_playable_city_ground_layer_and_anchors_gate/
```

Erzeugt:

- `firenze_playable_city_ground_layer_and_anchors_gate.svg`
- `firenze_playable_city_ground_layer_and_anchors_gate.png`

Visual-Inhalt:

- aeussere Florenz-Ground-Shape als abstrakte Quellebene,
- `playable_city_area`,
- Arno-/Fluss-Korridor als zu pruefender Layer,
- Bruecken-Anker als Kandidaten,
- Pfadnetz-Kandidaten,
- Bauflaechen-Kandidaten,
- Reserve-Ground,
- No-Walk- und No-Build-Zonen,
- Landmark- und Start-Anker.

Visual-Grenze:

Das Visual ist ein Gate-/Planungsdiagramm. Es ist keine App-UI, kein
Spielscreen, kein Asset, kein Runtime-Map-Datensatz und keine finale Greybox.

## 9. Stop-Regeln

Ein kommender Firenze-/City-Entry-/Build-/Lernort-Slice ist nicht commitfaehig,
wenn:

- eine City-Entry-App-Preview vor freigegebenem Ground-/Layer-/Anchor-Gate
  entsteht,
- Bauplaetze frei gesetzt werden,
- Piazza, Atelier, Archiv, Lernort oder andere UI-Orte ohne
  Landmark-/Anchor-Logik erscheinen,
- Fluss, Bruecke oder Wege frei gemalt werden,
- `firenze_no_walk_layer` und `firenze_no_build_layer` vermischt werden,
- das ISTAT-Footprint-Visual 1:1 als Runtime-Polygon gelesen wird,
- aus Dokumentationsannahmen Runtime-Daten, YAML/JSON, App-Code, Assets,
  Persistenz oder BuildState entstehen,
- die Darstellung wie GIS, Atlas, Debug-Tool, Dashboard oder Tabellenansicht
  wirkt,
- Lernorte als Liste statt als Orte in der Stadtstruktur geplant werden.

## 10. Entscheidung

| Frage | Entscheidung |
| --- | --- |
| Bleibt Firenze die erste Stadt-Greybox? | Ja, aus `412`. |
| War die freie City-Entry-WIP freigegeben? | Nein. |
| Darf eine neue App-City-Entry-Preview entstehen? | Nein, erst nach Folge-Gate. |
| Sind Ground, Layer und Anchors jetzt als Pflichtfamilien definiert? | Ja, als Planungsfamilien. |
| Ist das runde 415-Visual eine gueltige Firenze-Planung? | Nein. Es war nur ein zu generischer Erstentwurf und muss durch 417 v5 ersetzt werden. |
| Entstehen Runtime-Daten, Assets, YAML/JSON oder App-Integration? | Nein. |

## 11. Naechster erlaubter Folgeslice

Naechster gueltiger Folgeslice nach 416:

```text
Firenze playable city layout blueprint v5
```

Dieser Slice ersetzt die runde, zu generische 415-Form sowie die v3-/v4-
Zwischenrichtungen durch einen groesseren, landmark-aware Blueprint nach `416`.
City Entry bleibt blockiert, bis `417` v5 reviewed ist.
Der 417-Folgepfad muss weiterhin dokumentieren:

- wie `416` angewendet wird,
- warum die runde Gate-Form aus dem aktuellen 415-Visual korrigiert wird,
- wie die neue Firenze-Ground-Shape unregelmaessig und erkennbar
  Florenz-orientiert bleibt,
- wie Vegetationspuffer und Freiraum No-Overlap und spaetere Laufbarkeit
  unterstuetzen,
- wie PATH-N, PATH-S, Connector Paths und Future Paths organischer verlaufen,
- welche 14 Parcel Candidates, fruehen Nutzflaechen, Reserveflaechen und
  Landmark-nahe Sonderflaechen geplant sind,
- wie die innere Parcel-Struktur mit Hauptflaeche, Nebenflaeche,
  Garten-/Freiraum, Zugang und Reserve entsteht,
- welche Ground-Shape fuehrend ist,
- welche Area-Metrics, Collision- und Reachability-Pruefungen gelten,
- welche Wege/Fluss/Bruecken als Kandidaten gelten,
- welche future/reserve paths bereits geplant sind,
- welche Bauflaechen aus welchen Layern abgeleitet sind,
- welche No-Walk-/No-Build-Grenzen gelten,
- welche Landmark-/Start-Anker verwendet werden,
- warum noch keine Runtime-, Asset-, App- oder Persistenzfreigabe entsteht.
