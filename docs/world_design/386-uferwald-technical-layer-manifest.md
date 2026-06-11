# M16-DC: Uferwald Technical Layer Manifest

Stand: 2026-06-11

Status: `Docs-/Technical-Manifest-Gate / keine Runtime-Daten`

Template: `docs/world_design/prompt_templates/docs_only_slice.md`

## 1. Zweck

M16-DC uebersetzt die Uferwald-Layer-/Masken-Spezifikation aus M16-DB in eine
erste maschinennahe Planungsstruktur. Das Manifest benennt die technischen
Layer-IDs, erwartete Datenformen, erlaubte Kamera-Modi, blockierte
Fehlnutzungen und offene Messfragen.

Dieses Dokument ist noch kein Runtime-Manifest. Es enthaelt keine finalen
Koordinaten, keine Pfadgeometrie, keine Kollisionsdaten, keine Build-Zonen als
spielbare Daten und keine App-Integration.

Leitregel:

> Uferwald wird zuerst als technische Karte geplant; das sichtbare Bild bleibt
> Review- und Art-Kontext, nicht die technische Quelle.

## 2. Eingangsquellen

Fuehrende Quellen:

- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/370-asset-family-and-export-spec.md`
- `docs/world_design/379-uferwald-layer-candidate-intake-and-qa.md`
- `docs/world_design/381-uferwald-anchor-zone-layer-overlay-plan.md`
- `docs/world_design/383-talvori-camera-modes-and-visit-wander-rule.md`
- `docs/world_design/384-uferwald-playable-map-layer-and-mask-architecture.md`
- `docs/world_design/385-uferwald-technical-layer-and-mask-spec.md`

M16-DC darf visuelle Review-Erkenntnisse aus 379/381 beruecksichtigen, aber
nicht als technische Wahrheit uebernehmen. Alle Layer bleiben `planned`.

## 3. Manifest-Kopf

```yaml
manifest_id: m16_dc_uferwald_technical_layer_manifest
slice_id: M16-DC
map_id: uferwald_starter_island
status: planning_manifest
runtime_status: not_runtime_data
asset_status: not_asset
coordinate_space: normalized_0_1
canvas_origin: top_left_normalized_0_0
world_origin: hub_center_anchor
layer_pivot: world_origin_unless_family_override
source_reference:
  art_candidate: m16_cp_uferwald_1x
  art_candidate_role: visual_review_context_only
  overlay_plan: m16_cr_anchor_zone_layer_overlay
  overlay_plan_role: review_geometry_only
technical_source_of_truth: this_manifest_is_planning_only
coordinate_precision: no_final_coordinates_in_this_slice
allowed_scope:
  - docs_planning
  - layer_id_definition
  - open_measurement_inventory
blocked_scope:
  - runtime_map_data
  - app_integration
  - generated_images
  - assets_path
  - engine_ready_candidate
  - approved_asset
```

## 4. Layer Manifest

### 4.1 `base_rock_shape`

```yaml
layer_id: base_rock_shape
type: polygon_or_mask_plan
purpose: Insel-Silhouette, harte Landmasse, Klippenkoerper und Aussenkante.
data_form_candidate:
  - polygon
  - multi_polygon
  - svg_path
  - figma_vector
  - raster_mask_plan
source_status: planned_from_spec_not_measured
allowed_modes:
  - Build/Map
  - Visit/Wander
  - Object Focus
  - Overview
blocked_uses:
  - walkability
  - buildability
  - fixed_slots
  - category_plots
  - pathfinding
  - runtime_collision
open_measurements:
  - Insel-Aussenkontur technisch nachzeichnen, nicht aus Pixeln automatisch ableiten.
  - Harte Klippen- und Wasserkanten als technische Grenzlinie pruefen.
  - Edge-Mask-Abstand fuer fullscreen/cover Kamera spaeter messen.
```

### 4.2 `grass_terrain_mask`

```yaml
layer_id: grass_terrain_mask
type: terrain_mask_plan
purpose: Wiesen-, Boden- und weiche Terrainflaechen als visuelle und technische
  Terrain-Grundlage.
data_form_candidate:
  - polygon
  - multi_polygon
  - raster_mask_plan
  - svg_area
  - yaml_terrain_regions
source_status: planned_from_spec_not_measured
allowed_modes:
  - Build/Map
  - Visit/Wander
  - Object Focus
  - Overview
blocked_uses:
  - automatic_walkability
  - automatic_buildability
  - fixed_plots
  - category_binding
  - collision_free_assumption
open_measurements:
  - Weiche Wiesenflaechen von Hain, Wasser und Felskanten trennen.
  - Terrain-sensitive Uebergaenge markieren, ohne sie als Bauplaetze zu lesen.
  - Pruefen, welche Flaechen nur Atmosphaere und welche technische Flaechen sind.
```

### 4.3 `water_river_mask`

```yaml
layer_id: water_river_mask
type: water_mask_plan
purpose: Meer, Flussarm, Uferarm, Wasserfall-/Eintrittsbereich, Muendung und
  harte Wasserbarrieren.
data_form_candidate:
  - polygon
  - river_polyline_with_width
  - raster_mask_plan
  - svg_area
  - yaml_water_regions
source_status: planned_from_spec_not_measured
allowed_modes:
  - Build/Map
  - Visit/Wander
  - Object Focus
  - Overview
blocked_uses:
  - bridge_permission
  - ford_permission
  - building_on_water
  - decorative_water_as_walk_path
  - category_plot_at_water
open_measurements:
  - Wo ist Wasser hart gesperrt?
  - Wo beginnt und endet der Hauptflussarm technisch?
  - Welche Uferuebergaenge brauchen Abstand fuer No-Walk und No-Build?
```

### 4.4 `walkable_path_layer`

```yaml
layer_id: walkable_path_layer
type: path_network_plan
purpose: Echte begehbare Wege, Pfadbreiten, Stationen und erlaubte
  Besucherbewegung.
data_form_candidate:
  - polyline_network
  - path_corridor_polygons
  - graph_nodes_edges
  - yaml_waypoints
  - figma_path_plan
source_status: planned_from_spec_not_measured
allowed_modes:
  - Visit/Wander
  - Object Focus
  - Overview
blocked_uses:
  - buildability
  - fixed_plots
  - category_plots
  - terrain_type_source
  - movement_without_no_walk_check
open_measurements:
  - Wo verlaufen echte Wege?
  - Welche Pfadbreite ist fuer Marker/Figur und Kamera lesbar?
  - Welche Stationen liegen auf Wegen statt nur auf optisch plausiblen Pixeln?
```

### 4.5 `tree_obstacle_layer`

```yaml
layer_id: tree_obstacle_layer
type: obstacle_layer_plan
purpose: Hain, dichte Baumgruppen, Waldkanten und Vegetationshindernisse.
data_form_candidate:
  - obstacle_polygons
  - tree_instances_with_radius
  - raster_mask_plan
  - svg_obstacle_area
  - yaml_obstacle_regions
source_status: planned_from_spec_not_measured
allowed_modes:
  - Build/Map
  - Visit/Wander
  - Object Focus
  - Overview
blocked_uses:
  - path_nodes
  - buildable_clearings_without_gate
  - automatic_depth_sorting
  - decorative_tree_equals_collision
open_measurements:
  - Wo sind Baum-/Hainbereiche harte Blocker?
  - Wo ist Wald nur Hintergrund oder weiche Atmosphaere?
  - Welche Hainkanten brauchen No-Overlap fuer Figuren/Objekte?
```

### 4.6 `rock_cliff_obstacle_layer`

```yaml
layer_id: rock_cliff_obstacle_layer
type: obstacle_layer_plan
purpose: Felsen, Klippen, harte Hoehenkanten, nicht begehbare Kanten und
  Blocker.
data_form_candidate:
  - obstacle_polygons
  - cliff_polyline_with_buffer
  - raster_mask_plan
  - svg_cliff_area
  - yaml_height_edges
source_status: planned_from_spec_not_measured
allowed_modes:
  - Build/Map
  - Visit/Wander
  - Object Focus
  - Overview
blocked_uses:
  - implicit_stairs
  - terrace_building_permission
  - path_connections_through_cliffs
  - depth_sort_without_sort_bands
open_measurements:
  - Wo sind Fels-/Klippenkanten harte No-Walk-Blocker?
  - Welche Felsen blockieren Bauen, welche sind nur Dekor?
  - Welche Hoehenlogik muss spaeter in Sort-Bands uebersetzt werden?
```

### 4.7 `buildable_zone_layer`

```yaml
layer_id: buildable_zone_layer
type: soft_zone_plan
purpose: Organische Eignungsraeume fuer freie Bauentscheidungen und
  freie Start-Baukapazitaeten.
data_form_candidate:
  - suitability_polygons
  - soft_zone_polygons_with_score
  - yaml_zone_list
  - figma_zone_plan
source_status: planned_from_spec_not_measured
allowed_modes:
  - Build/Map
  - Object Focus
  - Overview
blocked_uses:
  - fixed_slots
  - fixed_12_plots
  - category_binding
  - automatic_build_placement
  - persistence
open_measurements:
  - Wo liegen organische Build-Zonen?
  - Welche Zonen sind gross genug fuer Haus, Markt oder Werkstatt?
  - Welche Nachbarschaften bleiben fuer Garage, Garten, Terrasse oder Vorhof frei?
```

### 4.8 `plot_footprint_layer`

```yaml
layer_id: plot_footprint_layer
type: footprint_template_plan
purpose: Groessenklassen und Footprints fuer spaetere Objekte, Gebaeude und
  Attachments.
data_form_candidate:
  - footprint_polygons
  - bounding_box_classes
  - radius_classes
  - yaml_footprint_templates
  - figma_template_shapes
source_status: planned_from_spec_not_measured
allowed_modes:
  - Build/Map
  - Visit/Wander
  - Object Focus
  - Overview
blocked_uses:
  - concrete_built_objects
  - category_assignment
  - final_house_position
  - build_phase_state
  - runtime_state
open_measurements:
  - Welche Objektgroessen braucht die erste freie Baukapazitaet?
  - Welche Footprints brauchen Attachment-Raum?
  - Welche Mindestabstaende zu Wasser, Hain, Wegen und Klippen sind noetig?
```

### 4.9 `no_walk_mask`

```yaml
layer_id: no_walk_mask
type: movement_blocking_mask_plan
purpose: Harte Sperrflaechen fuer Besucherbewegung, Figuren und Wander-Marker.
data_form_candidate:
  - union_polygon
  - raster_mask_plan
  - yaml_mask_from_source_layers
  - svg_mask_plan
source_status: planned_from_spec_not_measured
allowed_modes:
  - Visit/Wander
  - Object Focus
  - Overview
blocked_uses:
  - automatic_no_build
  - buildable_zone_source
  - object_footprints
  - path_network_without_walkable_path_layer
open_measurements:
  - Welche Wasser-, Baum-, Fels- und Aussenkanten bilden harte No-Walk-Zonen?
  - Welche Bereiche sind nur langsam/terrain-sensitive statt hart gesperrt?
  - Welche Kamera-Follow-Raender muessen fuer Besucherbewegung geschuetzt werden?
```

### 4.10 `no_build_mask`

```yaml
layer_id: no_build_mask
type: build_blocking_mask_plan
purpose: Harte Sperrflaechen fuer Build/Map, Placement und spaetere
  Objekt-Footprints.
data_form_candidate:
  - union_polygon
  - raster_mask_plan
  - yaml_mask_from_source_layers
  - svg_mask_plan
source_status: planned_from_spec_not_measured
allowed_modes:
  - Build/Map
  - Object Focus
  - Overview
blocked_uses:
  - automatic_no_walk
  - fixed_slots
  - category_plots
  - capacity_counter
  - object_ownership
open_measurements:
  - Wo sind Wasser, Hain, Klippen, Hub und Wege hart fuer Bauen gesperrt?
  - Wo braucht Build Station spaeter Schutzabstand?
  - Welche Flaechen bleiben Reserve, aber noch nicht Buildable?
```

### 4.11 `depth_sort_bands`

```yaml
layer_id: depth_sort_bands
type: sorting_band_plan
purpose: Vordergrund, Mittelgrund, Hintergrund, Occlusion und spaetere
  Ueber-/Unterlagerung fuer Figuren, Objekte und HUD-nahe Weltbubbles.
data_form_candidate:
  - sort_band_polygons
  - y_band_rules
  - yaml_sort_bands
  - figma_band_plan
source_status: planned_from_spec_not_measured
allowed_modes:
  - Build/Map
  - Visit/Wander
  - Object Focus
  - Overview
blocked_uses:
  - walkability
  - buildability
  - collision
  - physics_height
  - renderer_implementation
open_measurements:
  - Welche Sort-Bands sind fuer Figuren/Objekte noetig?
  - Wo muessen Hain, Felsen, Bauobjekte oder Marker andere Elemente ueberdecken?
  - Reichen `background_north`, `midground_center`, `foreground_south` aus 381
    als erste Planung, oder braucht Uferwald feinere Baender?
```

### 4.12 `landmark_anchor_layer`

```yaml
layer_id: landmark_anchor_layer
type: anchor_manifest_plan
purpose: Benannte Landmarken, Fokus- und Stationspunkte fuer Build/Map,
  Visit/Wander, Object Focus und Overview.
data_form_candidate:
  - yaml_anchor_list
  - normalized_coordinate_pairs_later
  - svg_anchor_layer
  - figma_anchor_layer
  - markdown_manifest
source_status: planned_ids_no_final_coordinates
allowed_modes:
  - Build/Map
  - Visit/Wander
  - Object Focus
  - Overview
blocked_uses:
  - runtime_slots
  - final_paths
  - category_plots
  - ownership
  - persistence
open_measurements:
  - Welche Anchors bleiben nur Landmarken?
  - Welche Anchors werden spaeter Path-Nodes?
  - Welche Anchors duerfen Object-Focus ausloesen, ohne Runtime-State zu erzeugen?
```

## 5. Geplante Anchor-IDs

Diese Anchor-IDs sind geplant, aber noch nicht final gemessen. Sie duerfen
nicht als Runtime-Koordinaten gelesen werden.

```yaml
anchors:
  - anchor_id: startplatz_anchor
    intended_role: Visit/Wander Startpunkt und sanfter Einstieg.
    coordinate_status: not_measured
    runtime_status: not_runtime_anchor
  - anchor_id: main_build_area_anchor
    intended_role: zentrale Bau-/Eignungszone fuer Build/Map-Review.
    coordinate_status: not_measured
    runtime_status: not_runtime_anchor
  - anchor_id: hub_center_anchor
    intended_role: Welt-Ursprung und Orientierungszentrum fuer Planung.
    coordinate_status: not_measured
    runtime_status: not_runtime_anchor
  - anchor_id: river_entry_anchor
    intended_role: oberer Wasser-/Flusseintritt oder Wasserfallbezug.
    coordinate_status: not_measured
    runtime_status: not_runtime_anchor
  - anchor_id: river_exit_anchor
    intended_role: Flussmuendung oder unterer Wasserabgang.
    coordinate_status: not_measured
    runtime_status: not_runtime_anchor
  - anchor_id: grove_anchor
    intended_role: Hain-/Waldidentitaet und No-Build-/No-Walk-Kontext.
    coordinate_status: not_measured
    runtime_status: not_runtime_anchor
  - anchor_id: aussichtspunkt_anchor
    intended_role: Visit/Wander-Station und moeglicher Object-Focus-Kontext.
    coordinate_status: not_measured
    runtime_status: not_runtime_anchor
```

Hinweis: 379/381 enthalten gemessene Dokumentationsanker aus dem bestehenden
Bitmap. M16-DC uebernimmt diese Werte bewusst nicht als final. Das naechste
Mess-Gate muss entscheiden, welche Werte technische Planung werden duerfen.

## 6. Offene Messfragen

M16-DC blockiert die folgenden Fragen bewusst fuer einen spaeteren Mess- oder
Vector-Plan-Slice:

1. Wo verlaufen echte Wege?
2. Wo ist Wasser hart gesperrt?
3. Wo sind Baum-/Felsblocker?
4. Wo liegen organische Build-Zonen?
5. Welche Sort-Bands sind fuer Figuren/Objekte noetig?
6. Welche Zonen bleiben nur atmosphaerische Flaechen?
7. Welche Bereiche duerfen spaeter Attachments wie Garten, Garage, Terrasse
   oder Vorhof aufnehmen?
8. Welche Anchors sind Landmarken, welche Path-Nodes und welche Object-Focus-
   Bezugspunkte?
9. Welche Kanten brauchen Kamera-/Pan-Bounds oder Edge-Masking-Abstand?
10. Welche technischen Daten duerfen spaeter in ein Runtime-Format
    ueberfuehrt werden, und welches eigene Gate ist dafuer noetig?

## 7. M16-CY-FIX-3 als verworfener Risiko-Proof

M16-CY-FIX-3 bleibt ein wertvoller UX-Proof, aber ein verworfener technischer
Proof:

- Die Wander-Preview hatte direkte Stationstaps und einen sichtbaren Marker.
- Der Pfadverlauf blieb trotzdem aus dem fertigen Uferwald-Bild geraten.
- Es gab keine echte `walkable_path_layer`, keine `no_walk_mask`, keine
  technischen Hindernisse und keine pruefbare Sortierlogik.
- Darum darf M16-CY-FIX-3 nicht als Grundlage fuer produktionsfaehige
  Navigation, Collision, Build-Zonen oder Cloud-/Besucherlogik gelesen werden.

## 8. Folgepfad

Empfohlener naechster Slice:

```text
M16-DD Uferwald Technical Measurement and Vector Planning Gate
```

M16-DD sollte noch kein Code- oder Asset-Slice sein. Sinnvoll waere ein
Docs-/Visual-Planungs-Gate, das aus diesem Manifest erste technische
Messbereiche, Vector-Plan-Anforderungen und QA-Kriterien ableitet, ohne
Runtime-Daten, App-Integration oder Dateien unter `assets/` zu erzeugen.

## 9. Stop-Regeln

M16-DC gibt nicht frei:

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
- keine PNG/SVG,
- keine Preview-Ordner,
- keine Assets,
- keine Dateien unter `assets/`,
- keine Engine-ready Candidates,
- keine approved Assets,
- keine externen Writes,
- keinen Commit.
