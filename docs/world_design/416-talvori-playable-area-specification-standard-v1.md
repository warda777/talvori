# 416: Talvori Playable Area Specification Standard v1

Stand: 2026-06-14

Status: `documentation_only` / `planning_standard` / `not_runtime_data` /
`not_asset` / `not_engine_ready` / `no_yaml_json` / `no_app_integration`

## 1. Bestandspruefung

Dieses Dokument schliesst die Luecke zwischen bestehenden Layer-/Anchor-Regeln
und einer professionellen, wiederholbaren Area-Spec fuer spielbare Stadt-,
Insel-, District- oder Plot-Fokus-Flaechen.

### 1.1 Bereits vorhandene Regeln

| Bereich | Bereits vorhanden | Fuehrende Quelle |
| --- | --- | --- |
| Boundary / Aussenform | Sichtbares Bild ist nicht technische Spielkarte; Boundary darf nicht aus Pixeln geraten werden. | `384`, `385`, `403`, `404`, `410`, `411`, `415` |
| Buildable Areas | Buildable Zones sind Eignungsraeume, keine festen Slots, keine Kategorieplaetze und kein BuildState. | `376`, `377`, `384`, `385`, `403`, `411`, `415` |
| Anchors | Anchors brauchen ID, Zweck, Layerbezug, Koordinaten-/Statusschutz, Placement-Zone und No-Overlap-Hinweis. | `376`, `377`, `385`, `415` |
| Placement-Zonen | Anchor ist Punkt, Zone ist Flaeche; Buildable, Reserve, No-Build, No-Overlap, Water-only und Terrain-sensitive bleiben getrennt. | `376`, `377` |
| No-Walk / No-Build | No-Walk und No-Build sind getrennte Familien; keine automatische Gleichsetzung. | `384`, `385`, `403`, `411`, `415` |
| Path Layer | Wege duerfen nicht Deko sein; sie muessen Orte, Slots, Start, Bridges und Anchors logisch verbinden. | `384`, `385`, `403`, `415` |
| Water Layer | Wasser ist Barriere, Struktur- und No-Build-Kontext; Bridges/Furten brauchen eigene Anchors. | `384`, `385`, `403`, `415` |
| Visual-QA | Planungsvisuals muessen Statusschutz, lesbare Labels, getrennte Layer und keine App-/GIS-/Dashboard-Optik zeigen. | `336`, `410`, `411`, `415` |

### 1.2 Regeln, die bereits fuer Firenze gelten

- Firenze ist laut `412` die erste Stadt-Greybox; Roma und Bologna bleiben
  Reserve.
- Firenze kommt laut `410` aus ISTAT Comuni 2026, `COMUNE=Firenze`,
  `PRO_COM_T=048017`.
- Der ISTAT-Footprint und die `411`-`playable_city_area` sind nur Source- und
  Review-Kontext, keine Runtime-Polygone.
- `415` stoppt freie City-Entry-UI und fordert zuerst:
  `firenze_city_ground_shape`, `firenze_playable_city_area`,
  `firenze_path_network_layer`, `firenze_river_bridge_layer`,
  `firenze_buildable_ground_candidates`, `firenze_reserved_ground`,
  `firenze_no_walk_layer`, `firenze_no_build_layer`,
  `firenze_landmark_anchor_layer` und `firenze_start_anchor`.
- Das aktuelle `415`-Visual ist ein Gate-Diagramm, nicht die finale
  Firenze-Ground-Shape.

### 1.3 Fehlende professionelle Bausteine

Vor diesem Standard fehlten verbindlich:

- eine gemeinsame Area-Identitaet mit Review-Status,
- ein explizites Koordinatensystem fuer Dokumentationsarbeit,
- Planungsmetriken fuer Spielerbreite, Pfade, Bridges, Slots, Abstaende,
  Collision-Ranges und Mobile-Tap-Targets,
- ein Build-Slot-Vertrag mit Footprint, Access Path, Occupancy, Collision,
  Visual Bounds, Clearance und No-Overlap,
- eine Occupancy-Familie, die nicht mit BuildState oder Persistenz verwechselt
  wird,
- klare Beziehung zwischen Collision, No-Walk und No-Build,
- Navigation-/Walkability-Reviews mit Reachability- und Connectivity-Checks,
- Source-Traceability fuer jede Shape-, Zone-, Slot- und Anchor-Familie,
- ein Pflicht-Visual-Debug-Overlay fuer Area-Spec-Slices.

## 2. Zweck des Standards

`Talvori playable area specification standard v1` ist der verbindliche
Planungsstandard fuer jede spielbare Talvori-Flaeche, bevor daraus eine
spielnahe City-, Island-, District- oder Plot-Fokus-Preview entstehen darf.

Der Standard erzeugt:

- eine gemeinsame Sprache fuer Area-Specs,
- eine Mindeststruktur fuer Review-Dokumente und Visuals,
- Stop-Regeln gegen freie UI-Orte, freie Bauplaetze und geratenes Pathing,
- eine Bruecke zwischen Dokumentationsvisual, Greybox und spaeterem Runtime-Gate.

Der Standard erzeugt nicht:

- Runtime-Daten,
- finale Koordinaten,
- produktive Polygone,
- YAML/JSON/YML,
- Flutter-/Dart-Code,
- Assets,
- App-Integration,
- Persistenz,
- BuildState.

## 3. Pflichtfamilie: `area_identity`

Jede Area-Spec muss mindestens diese Identitaetsfelder dokumentieren:

| Feld | Zweck | Regel |
| --- | --- | --- |
| `area_id` | stabile Planungs-ID | sprechend, eindeutig, nicht automatisch Runtime-ID |
| `area_type` | Flaechentyp | erlaubt: `island`, `city`, `district`, `plot_focus` |
| `source_basis` | Quelle oder Herleitung | echte Quelle, vorhandenes Gate oder begruendete Abstraktion nennen |
| `abstraction_level` | Naehe zur Quelle | z. B. source-derived, abstracted, greybox-candidate |
| `review_status` | Reifegrad | candidate_only, review_needed, accepted_for_next_visual, blocked |

Pflichtregel:

- Eine Area ohne `area_identity` darf nicht als City-/Island-/Build-Preview
  fortgesetzt werden.

## 4. Pflichtfamilie: `coordinate_system`

Jede Area-Spec braucht einen Dokumentations-Koordinatenraum.

| Feld | Zweck | Regel |
| --- | --- | --- |
| `canvas_width` | Review-Canvas-Breite | nur Dokumentationsmass, nicht Runtime |
| `canvas_height` | Review-Canvas-Hoehe | nur Dokumentationsmass, nicht Runtime |
| `unit` | Einheit | `review_px` oder `normalized_0_1` |
| `origin` | Ursprung | bevorzugt top-left fuer Review; Runtime-Origin eigenes Gate |
| `scale_notes` | Skalierungsnotizen | Mobile-/Lesbarkeitsgruende dokumentieren |

Regeln:

- `normalized_0_1` ist fuer fruehe Review-Arbeit bevorzugt.
- `review_px` darf fuer Visuals genutzt werden, wenn Canvasgroesse sichtbar
  genannt ist.
- Keine Koordinate aus diesem Standard ist Runtime-Koordinate.
- Runtime-Koordinaten brauchen ein eigenes Engine-/Integration-Gate.

## 5. Pflichtfamilie: `metrics_v1`

Jede Area-Spec muss die folgenden Metriken als Planungsfelder fuehren. Werte
duerfen in einem konkreten Area-Slice gesetzt werden, bleiben aber bis zu einem
Runtime-Gate Review-Metrics.

| Metric | Zweck |
| --- | --- |
| `player_width` | grobe Figur-/Companion-/Marker-Breite fuer Durchgaenge |
| `minimum_footpath_width` | kleinster noch lesbarer und begehbarer Pfad |
| `main_path_width` | Hauptweg-Breite fuer klare Orientierung |
| `bridge_min_width` | Mindestbreite fuer Bridge-/Crossing-Kandidaten |
| `small_build_slot_size` | kleine Bau- oder Lernort-Footprint-Klasse |
| `medium_build_slot_size` | mittlere Bau- oder Lernort-Footprint-Klasse |
| `large_build_slot_size` | grosse Bau- oder Landmark-Footprint-Klasse |
| `min_distance_to_water` | Schutzabstand zu Wasser/Kuesten/Fluss |
| `min_distance_to_path` | Abstand zwischen Slot/Obstacle und Weg |
| `collision_radius_ranges` | Planungsbereiche fuer kleine/mittlere/grosse Hindernisse |
| `mobile_tap_target_minimum` | Mindestziel fuer Touchbarkeit auf Mobile |

Regeln:

- Metrics sind Planungsmetriken, keine Runtime-Konstanten.
- Keine Build-Slot-Ableitung ohne passende Metrics-Notiz.
- Metrics muessen mit Visual-QA, Tapbarkeit und Lesbarkeit zusammenpassen.

## 6. Pflichtfamilie: `playable_boundary`

`playable_boundary` beschreibt die aeussere oder innere Grenze der spielbaren
Flaeche.

Pflichtfelder:

- boundary_id,
- boundary_role,
- source_kind: source-derived oder abstracted_from_source,
- source_or_reason,
- simplification_notes,
- review_status.

Regeln:

- Boundary darf nicht frei erfunden sein, wenn eine offene Source-Grundlage
  vorhanden ist.
- Boundary darf nicht 1:1 als Runtime-Polygon gelesen werden.
- Bei Firenze muss die Boundary erkennbar aus ISTAT-/Firenze-Kontext und `411`
  abstrahiert werden.
- Eine runde, generische oder austauschbare Fantasieform ist fuer Firenze nicht
  ausreichend.

## 7. Pflichtfamilie: `terrain_zones`

Jede Area-Spec muss relevante Terrain-Zonen nennen und getrennt bewerten.

Pflichttypen:

- `urban_core`,
- `river_corridor`,
- `hill_edge`,
- `forest_or_green_edge`,
- `reserve_zone`,
- `landmark_protection_zone`,
- `semantic_zone`.

Regeln:

- Terrain-Zonen inspirieren Gameplay, aber platzieren keine Objekte
  automatisch.
- Terrain darf Kategorie-Vorschlaege machen, aber keine Kategoriepflicht
  erzeugen.
- Terrain-Zonen duerfen No-Walk oder No-Build begruenden, muessen diese
  Beziehung aber explizit nennen.

## 8. Pflichtfamilie: `water_layer`

Wasser kann als Flaeche oder als Spline/Polyline mit Breite geplant werden.

Pflichtfelder:

- water_id,
- geometry_kind: area, spline_or_polyline_with_width, corridor,
- walkable: false,
- buildable: false,
- crossing_policy,
- related_bridge_anchors,
- no_walk_reason,
- no_build_reason.

Regeln:

- Wasser ist nie automatisch begehbar.
- Wasser ist nie automatisch bebaubar.
- Crossing ist nur an Bridge- oder Crossing-Anchors erlaubt.
- Ein Fluss darf nicht Deko sein, wenn er Walkability oder No-Build
  beeinflusst.

## 9. Pflichtfamilie: `path_road_layer`

Pfad- und Weglogik ist die fuehrende Struktur fuer Bewegung und Slot-Zugang.

Pflichttypen:

- `footpath`,
- `main_path`,
- `road_optional`,
- `plaza_walkable_area`.

Pflichtfelder:

- path_id,
- path_type,
- path_width,
- walkable,
- drivable optional,
- connected_to,
- source_or_reason,
- review_status.

Regeln:

- Wege muessen Start, zentrale Orte, Build-Slots, Bridges und Landmark-Anchors
  logisch verbinden.
- Wege duerfen keine reine Dekoration sein.
- Ein Slot ohne Access Path ist nicht commitfaehig.

## 10. Pflichtfamilie: `build_slots`

Build-Slots sind Kandidaten fuer spaetere Bau-/Lernort-Interaktion. Sie sind
keine fertigen Gebaeude, keine Persistenz und kein BuildState.

Jeder Build-Slot braucht:

| Feld | Regel |
| --- | --- |
| `id` | eindeutige Planungs-ID |
| `anchor` | Bezugspunkt, meist `build_slot_anchor` |
| `footprint` | Review-Footprint oder Footprint-Klasse |
| `size_class` | small, medium oder large |
| `allowed_categories` | neutral oder begruendete Vorschlagsmenge; keine harte UI-Kategoriepflicht |
| `access_path` | Pfad oder Platz, der den Slot erreicht |
| `current_state` | placeholder, keine Persistenz |
| `occupied_by` | placeholder, keine Persistenz |
| `collision_bounds` | Radius oder Polygon-Kandidat fuer Review |
| `visual_bounds` | Lesbarkeits- und Tapbereich |
| `no_build_clearance` | Abstand zu Wasser, Wegen, Landmarken, Boundary oder Obstacles |
| `no_overlap_check` | Pruefung gegen Nachbar-Slots, Anchors, UI und Obstacles |
| `status` | `candidate_only` bis zu eigenem Slot-Gate |

Regeln:

- Slots duerfen nicht frei gesetzt werden.
- Slots muessen aus Boundary, Terrain, Paths, No-Build und No-Overlap
  abgeleitet sein.
- Slots bleiben neutral, solange kein eigener BuildChoice-/Build-Station-Slice
  anderes freigibt.

## 11. Pflichtfamilie: `anchor_points`

Alle Anchors brauchen Zweck, Bezugslayer und Status.

Pflichttypen:

- `start_anchor`,
- `landmark_anchor`,
- `bridge_anchor`,
- `build_slot_anchor`,
- `path_node_candidate`,
- `camera_focus_anchor`,
- `reserve_anchor`.

Pflichtfelder:

- anchor_id,
- anchor_type,
- purpose,
- reference_layer,
- coordinate_space,
- source_or_reason,
- placement_zone,
- no_overlap_radius,
- review_status.

Regeln:

- Ein Anchor ist kein BuildState.
- Ein Anchor ist keine automatische UI-Position.
- Ein Anchor ohne Zweck, Bezugslayer und Status blockiert den Folge-Slice.

## 12. Pflichtfamilie: `occupancy_state`

Occupancy ist eine Planungsfamilie, kein BuildState und keine Persistenz.

Erlaubte Planungszustaende:

- `empty`,
- `reserved`,
- `occupied`,
- `blocked`,
- `candidate_only`.

Regeln:

- `occupied` darf in Dokumentationsvisuals nur als Review-Lesbarkeit dienen.
- `reserved` darf keine Unlock-Logik erzeugen.
- `blocked` muss Grund und Bezugslayer nennen.
- Kein Occupancy-State darf in App-Daten, Persistenz oder Runtime ohne eigenes
  Gate uebernommen werden.

## 13. Pflichtfamilie: `collision_obstacles`

Collision beschreibt physische oder lesbare Hindernisse. Collision ist nicht
automatisch No-Build und nicht automatisch No-Walk.

Pflichttypen:

- `trees`,
- `rocks`,
- `buildings`,
- `water`,
- `cliff_or_edge`,
- `landmark_core`,
- `bridge_edges`.

Pflichtfelder:

- obstacle_id,
- obstacle_type,
- collision_radius oder obstacle_polygon,
- affects_walkability,
- affects_buildability,
- related_no_walk_zone,
- related_no_build_zone,
- source_or_reason,
- review_status.

Regeln:

- Ein Baum kann Collision sein, ohne komplett No-Walk zu werden.
- Wasser ist in der Regel Collision, No-Walk und No-Build, aber die Beziehung
  muss trotzdem dokumentiert werden.
- Landmark-Core kann No-Build sein, aber Umgebung kann walkable bleiben.

## 14. Pflichtfamilie: `navigation_walkable_area`

Vor City-Entry muss theoretisch pruefbar sein, ob relevante Orte erreichbar
sind.

Pflichtpruefungen:

- walkable polygon/mask candidate,
- connected_components_check,
- reachability_check,
- bridge_connectivity_check,
- dead_end_review,
- inaccessible_slot_check.

Regeln:

- Jeder wichtige Slot und Anchor muss theoretisch erreichbar sein.
- Bridges muessen zwei Walkable-Flaechen verbinden.
- Dead Ends duerfen existieren, muessen aber als absichtliche Sackgasse oder
  Review-Risiko markiert sein.
- Eine Stadtansicht ohne Walkability-/Reachability-Review ist nicht
  commitfaehig.

## 15. Pflichtfamilie: `no_walk_zones`

No-Walk-Zonen blockieren Bewegung.

Standardgruende:

- `water`,
- `outer_boundary_buffer`,
- `steep_edge`,
- `dense_obstacle`,
- `protected_landmark_core`.

Regeln:

- No-Walk ersetzt kein No-Build.
- No-Walk muss mit Navigation-/Walkability-Review geprueft werden.
- No-Walk-Zonen muessen im Visual-Debug-Overlay getrennt sichtbar sein.

## 16. Pflichtfamilie: `no_build_zones`

No-Build-Zonen blockieren Bauen oder Platzierung.

Standardgruende:

- `water`,
- `path`,
- `bridge`,
- `landmark_core`,
- `occupied_slot`,
- `collision_obstacle`,
- `boundary_buffer`,
- `protected_visual_area`.

Regeln:

- No-Build ersetzt kein No-Walk.
- Wege sind in der Regel No-Build, bleiben aber walkable.
- Landmark-Core ist in der Regel No-Build, kann aber als Fokus- oder
  Lernort-Anker dienen.
- No-Build-Zonen muessen im Visual-Debug-Overlay getrennt sichtbar sein.

## 17. Pflichtfamilie: `semantic_zones`

Semantik steuert Vorschlaege, erzeugt aber keine automatische Platzierung.

Standardzonen:

- Kulturkern,
- Handwerk/Archiv,
- ruhiger Startbereich,
- Markt/Platz,
- Natur/Reserve,
- Lernort-Kontext.

Regeln:

- Semantik darf Copy, Lernort-Ideen und BuildChoice-Vorschlaege inspirieren.
- Semantik darf keine Build-Slots setzen.
- Semantik darf keine Kategoriepflicht erzeugen.
- Semantik muss hinter Boundary, Paths, No-Build und Reachability zurueckstehen.

## 18. Pflichtfamilie: `source_traceability`

Jede Shape-, Zone-, Slot- und Anchor-Familie braucht Source-Traceability.

Pflichtfelder:

- `source_or_reason`,
- `derived_from`,
- `abstraction_reason`,
- `status`,
- `blocked_uses`.

Regeln:

- Keine schoene Form ohne Quelle oder Abstraktionsgrund.
- Keine Runtime-Nutzung, wenn `blocked_uses` sie ausschliesst.
- Jede Vereinfachung muss Mobile-Lesbarkeit, Spielbarkeit oder 2.5D-Diorama
  begruenden.

## 19. Pflichtfamilie: `visual_debug_overlay`

Jeder Area-Spec-Slice braucht ein lesbares Dokumentationsvisual oder Overlay.

Pflichtinhalte:

- Boundary sichtbar,
- Wasser sichtbar,
- Wege sichtbar,
- Buildable Slots sichtbar,
- Reserved/Occupied sichtbar, falls vorhanden,
- No-Walk und No-Build getrennt sichtbar,
- Anchors sichtbar,
- Collision-Radien/Obstacles sichtbar,
- Legende,
- Statushinweis: planning only, not runtime data.

Stilregeln:

- keine App-UI,
- keine GIS-/Atlas-/Dashboard-Optik,
- keine abgeschnittenen Woerter,
- keine ueberlappenden Labels,
- keine technische Layernamen-Flut im Hauptbild, wenn ein spielnahes Visual
  gemeint ist,
- fuer Gate-Diagramme sind technische Labels erlaubt, muessen aber lesbar und
  klar in Legende/Panels organisiert sein.

## 20. Pflichtmodul: Area Layout Blueprint

Jeder konkrete Area-Spec-Slice muss zusaetzlich zu den Pflichtfamilien einen
`Area Layout Blueprint` liefern. Dieses Blueprint ist der Masterplan fuer
Grundstuecke, Wege, Zugaenge, Subflaechen, Future Paths und Pruefregeln.

Ohne Area Layout Blueprint darf eine Flaeche nicht als konkret spielbar,
betretbar oder baubar beschrieben werden.

### 20.1 `buildable_parcel_count`

Jede Area muss eine geplante Anzahl an Grundstuecksflaechen nennen.

Planungswert fuer Stadt-/City-Greyboxes:

- 12 bis 16 `buildable_parcel_candidates`,
- davon 6 bis 8 `early_use_candidates`,
- 3 bis 5 `reserve_or_expansion_candidates`,
- 2 bis 3 `special_or_landmark_adjacent_candidates`.

Regeln:

- Abweichungen muessen begruendet werden.
- Die Anzahl ist Planung, kein BuildState.
- Die Anzahl darf keine automatische Sichtbarkeit oder Freischaltung erzeugen.
- Eine Area ohne geplante Parcel-Anzahl ist nicht bereit fuer City Entry oder
  Build-Preview.

### 20.2 `parcel_structure`

Jede Grundstuecksflaeche braucht eine innere Aufteilung.

Pflichtfelder:

- `parcel_id`,
- `parcel_role`,
- `main_building_footprint`,
- `secondary_footprint`, z. B. Garage, Werkstatt oder Nebengebaeude,
- `garden_or_open_space`,
- `access_point`,
- `path_connection`,
- `expansion_reserve`,
- `no_build_clearance`,
- `collision_bounds`,
- `visual_bounds`,
- `allowed_category_families`,
- `blocked_category_families`,
- `status: candidate_only`.

Regeln:

- Haus, Garage, Garten, Werkstatt oder Nebengebaeude werden nicht automatisch
  gebaut.
- Die Grundstuecksflaeche muss aber von Anfang an so geplant sein, dass solche
  Elemente spaeter logisch passen.
- Ein Parcel ohne innere Struktur ist nur eine Flaeche, noch kein
  build-faehiger Kandidat.

### 20.3 `complete_path_network_plan`

Das komplette Wegenetz muss bereits im Plan definiert werden.

Pflichtfamilien:

- `main_path_spine`,
- `secondary_paths`,
- `parcel_access_paths`,
- `bridge_connections`,
- `landmark_paths`,
- `reserve_paths`,
- `hidden_or_future_paths`.

Regeln:

- Auch spaeter noch nicht sichtbare oder noch nicht ausgebaute Wege muessen als
  `future_path` oder `reserve_path` geplant sein.
- Future Paths duerfen nicht als sichtbare Runtime-Wege gelesen werden.
- Future Paths schuetzen Erweiterungen davor, spaeter frei erfunden zu werden.
- Kein Parcel ist gueltig, wenn es keinen vorhandenen, Reserve- oder Future
  Access Path hat.

### 20.4 `parcel_access_rule`

Kein Grundstueck ist gueltig ohne:

- Zugang vom Wegenetz,
- Abstand zu Wasser,
- Abstand zu Bruecke,
- Abstand zu Landmark,
- No-Build-Pruefung,
- No-Walk-Pruefung,
- Collision-/No-Overlap-Pruefung,
- Reachability-Pruefung.

Regeln:

- Early-Use-Parcels muessen ueber sichtbare oder eindeutig geplante Wege
  erreichbar sein.
- Reserve-Parcels muessen mindestens ueber Future Paths erreichbar geplant
  sein.
- Special-/Landmark-adjacent-Parcels brauchen zusaetzliche Landmark-Clearance.

### 20.5 `future_visibility_rule`

Jede Flaeche und jeder Pfad braucht eine Sichtbarkeitsfamilie.

Erlaubte Status:

- `planned_now`,
- `visible_now`,
- `hidden_until_unlock`,
- `reserve_only`,
- `blocked_until_gate`.

Regeln:

- Eine Flaeche darf geplant sein, auch wenn sie spaeter im Spiel noch nicht
  sichtbar ist.
- Unsichtbarkeit darf nicht bedeuten, dass der Pfad oder das Parcel spaeter
  frei erfunden wird.
- `blocked_until_gate` braucht eine klare Blocker-Begruendung.

### 20.6 `city_shape_recognition_rule`

Fuer echte Staedte gilt:

- Die aeussere Grundform muss erkennbar aus der echten Stadt-/Gemeindeform
  abstrahiert sein.
- Kreise, Ovale oder generische Inseln sind keine zulaessige Ersatzform.
- Source-Naehe und Abstraktionsgrund muessen dokumentiert werden.

Fuer Firenze muss die Form ungefaehr aufnehmen:

- westlicher Auslaeufer,
- kompakter Kern,
- noerdliche Ausbuchtung,
- oestlicher Arm,
- suedliche Huegelkante,
- Arno-Korridor.

### 20.7 `visual_blueprint_requirement`

Jeder konkrete Area-Slice braucht ein Blueprint-Visual.

Pflichtinhalte:

- echte oder abstrahierte Aussenform,
- Grundstuecksanzahl,
- Grundstuecksrollen,
- innere Parcel-Struktur,
- alle Wege,
- Future-/Reserve-Wege,
- Wasser und Bruecken,
- No-Walk und No-Build getrennt,
- Collision und No-Overlap,
- Anchors,
- Legende,
- Statushinweis: planning only, not runtime data.

Regeln:

- Grundstuecksnummern muessen lesbar sein.
- Wege muessen sichtbar sein.
- Das Visual darf kein App-Screen und kein GIS-/Atlas-/Dashboard-Bild sein.
- Das Visual muss zeigen, warum die Area spaeter erweiterbar bleibt.

## 21. Stop-Regeln

Ein City-, Island-, District-, Plot-Focus-, Build- oder Playable-Area-Slice ist
nicht commitfaehig, wenn:

- eine spielbare Stadt-/Insel-Preview ohne Area Specification entsteht,
- Build-Slots ohne Boundary, Path Access und No-Build-Check gesetzt werden,
- eine Stadtansicht ohne Walkability-/Reachability-Review entsteht,
- eine Bauflaeche ohne Occupancy-, Collision- und No-Overlap-Pruefung
  erscheint,
- eine Grundstuecksflaeche ohne innere Parcel-Struktur aus
  `main_building_footprint`, `secondary_footprint`, `garden_or_open_space`,
  `access_point` und `expansion_reserve` erscheint,
- ein Wegenetz nur sichtbare Startwege zeigt und Future-/Reserve-Pfade fuer
  spaetere Erweiterungen nicht plant,
- eine Bruecke keine Verbindung zwischen zwei Walkable-Flaechen nachweist,
- ein Fluss nur Deko ist, obwohl er Walkability oder No-Build beeinflusst,
- Anchors ohne Zweck, Bezugslayer und Status entstehen,
- schoene Shapes ohne Source-/Abstraction-Traceability entstehen,
- No-Walk und No-Build vermischt oder automatisch gleichgesetzt werden,
- aus diesem Standard Runtime-Daten, YAML/JSON/YML, Flutter-Code, Assets,
  Persistenz, BuildState oder App-Integration abgeleitet werden.

## 22. Anwendung auf Firenze im naechsten Slice

Firenze muss ab dem naechsten Slice nach diesem Standard aufgebaut werden.

Festlegung:

- Das aktuelle `415`-Visual ist als Gate-Diagramm zulaessig, aber die darin
  gezeigte runde Fantasieform ist fuer die naechste Firenze-Ground-Shape
  visuell zu korrigieren.
- Die neue Firenze-Ground-Shape muss unregelmaessig und erkennbar
  Florenz-orientiert sein.
- Firenze darf nicht als Kreis, generische Insel, freie Blob-Stadt oder
  beliebige UI-Buehne starten.
- Die neue Planung muss sich nachvollziehbar auf ISTAT Comuni 2026,
  `PRO_COM_T=048017`, den `411`-Firenze-Kandidaten und die `412`-Entscheidung
  beziehen.

Verbindliche Reihenfolge fuer Firenze:

1. Boundary.
2. Metrics.
3. Terrain Zones.
4. Arno/Bridge Layer.
5. Path Layer.
6. Area Layout Blueprint mit 14 Parcel Candidates.
7. Build Slot Candidates mit innerer Parcel-Struktur.
8. Anchors.
9. No-Walk/No-Build.
10. Collision/Navigation Review.
11. Visual QA.

Bis diese Reihenfolge als Dokumentationsdiagramm oder Greybox-Review sichtbar
geprueft ist, bleibt City-Entry-App-Preview blockiert.

## 23. Dokumentationsvisual

Erlaubter Preview-Pfad:

```text
docs/world_design/previews/talvori_playable_area_specification_standard_v1/
```

Erzeugt:

- `talvori_playable_area_specification_standard_v1.svg`
- `talvori_playable_area_specification_standard_v1.png`

Visual-Grenze:

Das Visual erklaert den Standard allgemein. Es ist kein Florenz-Screen, kein
App-UI, kein Asset, keine Runtime-Geometrie und keine Engine-ready Map.

Das vorhandene Standardvisual ist kein ausreichender konkreter Area-Plan fuer
Firenze oder irgendeine andere Stadt. Es erklaert nur den Vertrag. Ein
konkreter Area-Slice braucht zusaetzlich ein eigenes Blueprint-Visual mit
Grundstuecksanzahl, Parcel-Struktur, vollstaendigem Wegenetz, Future Paths,
No-Walk/No-Build, Collision, Anchors und Reachability-Review.

## 24. Naechster erlaubter Folgeslice

Nach Review dieses Standards ist der naechste fachlich passende Slice:

```text
Firenze playable city layout blueprint v5
```

Dieser Folge-Slice muss `416` anwenden und zuerst eine korrigierte,
source-orientierte Firenze-Ground-Shape mit Boundary, Metrics, Arno/Bridges,
vollstaendigem Path Network, 14 Parcel Candidates, Parcel-Strukturen, Anchors,
No-Walk/No-Build, Collision, Navigation-Review und Visual-QA liefern.
`417-firenze-playable-city-layout-blueprint-v5.md` ist dafuer das konkrete
Beispiel fuer eine Area-Anwendung mit groesserer Florence-shaped Flaeche,
Vegetationspuffern, organischem Wegenetz, Landmark-Ankern und No-Overlap-QA;
es bleibt trotzdem `documentation_only` und ist keine Runtime-Geometrie.
