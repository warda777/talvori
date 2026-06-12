# Italy Macro Blockout Paths Water Build Areas Metadata

Status: `documentation_only / planning_visual / not_asset / not_runtime_data / not_engine_ready`

## Source / Reuse Check

- reused_foundation: `docs/world_design/previews/italy_shape_working_contour/italy_shape_working_contour.svg`
- source_dataset: Natural Earth Admin 0 - Countries 5.1.1 via 406 working contour
- city_source_dataset: Natural Earth Populated Places
- city_source_version: 5.1.2
- city_source_url: `https://naciscdn.org/naturalearth/10m/cultural/ne_10m_populated_places.zip`
- city_source_archive_used_temporarily: `/private/tmp/ne_10m_populated_places.zip`
- city_anchor_source_doc: `docs/world_design/408-italy-city-anchor-plan.md`
- suitability: suitable as recognizable Italy outer contour and documentation base
- license_risk: low for Natural Earth contour and Natural Earth Populated Places; OSM/ISTAT not used
- reuse_before_build_decision: reuse existing Natural-Earth-based contour, use Natural Earth Populated Places for real city anchor placement, do not import OSM, ISTAT, external packages, assets or code in this slice
- city_point_data_status: used_for_documentation_visual_only
- city_anchor_position_status: source_lon_lat_projected_to_svg_viewbox_for_review_only_not_runtime_coordinates

## Generated Documentation Files

- `italy_macro_blockout_paths_water_buildareas.svg`
- `italy_macro_blockout_paths_water_buildareas.png`
- `italy_macro_blockout_paths_water_buildareas_metadata.md`

## Blockout Content

- mainland Italy: included
- Sicily: included
- Sardinia: included
- city_anchors_visible: 13
- core_city_anchors_visible: Mailand, Venedig, Bologna, Florenz, Rom, Neapel
- reserve_city_anchors_visible: Genua, Pisa, Verona, Bari, Palermo, Catania, Cagliari
- excluded_city_anchors: Madrid
- buildable_ground_review_areas: 13 organic areas aligned to city-anchor logic
- immediate_capacity_review: 6 areas shown as solid warm build areas tied to core cities
- reserve_capacity_review: 7 areas shown as softer reserve build areas tied to reserve cities
- paths: main and branch corridors connect all visible city/build areas
- water/coast: sea, coast buffer, Venice lagoon/coast cue, Sicily water cue and two transition corridors
- transitions: Sardinia ferry planning crossing and Sicily planning crossing shown as documentation only
- no_walk_no_build: gross forest/ridge/coast/hub protection zones shown subtly

## Natural Earth City Points Used

These source lon/lat values were used only to place the documentation labels in
the SVG viewBox. They are not runtime coordinates, not final gameplay anchors
and not a city point data file.

| City label | Natural Earth name | Lon | Lat | Visual role |
| --- | --- | --- | --- | --- |
| Mailand | Milan | 9.203063 | 45.471921 | core |
| Venedig | Venice | 12.334999 | 45.438659 | core |
| Bologna | Bologna | 11.340021 | 44.500422 | core |
| Florenz | Florence | 11.250000 | 43.780001 | core |
| Rom | Rome | 12.481313 | 41.897902 | core |
| Neapel | Naples | 14.243066 | 40.841971 | core |
| Genua | Genoa | 8.930039 | 44.409988 | reserve |
| Pisa | Pisa | 10.400026 | 43.720470 | reserve |
| Verona | Verona | 10.990016 | 45.440390 | reserve |
| Bari | Bari | 16.872758 | 41.114220 | reserve |
| Palermo | Palermo | 13.348081 | 38.126969 | reserve |
| Catania | Catania | 15.079999 | 37.499971 | reserve |
| Cagliari | Cagliari | 9.103982 | 39.222398 | reserve |

## City Placement QA

- Bari: placed on the south-eastern Adriatic side.
- Genoa/Genua: placed on the north-western coast.
- Venice/Venedig: placed on the north-eastern Adriatic side.
- Palermo: placed on western/northern Sicily.
- Catania: placed on eastern Sicily.
- Cagliari: placed on Sardinia.
- Madrid: excluded.

## Boundaries

- runtime_status: not_runtime_data
- asset_status: not_asset
- engine_status: not_engine_ready
- coordinate_status: documentation_viewbox_only_not_final_coordinates
- source_coordinate_status: source_lon_lat_used_for_visual_review_only_not_runtime_data
- geometry_status: blockout_visual_only_not_productive_polygons
- app_integration: none
- route_integration: none
- build_state: none
- city_anchor_status: visual_reference_only
- madrid_status: excluded

All positions are documentation visual coordinates for review only. The source
lon/lat values are not runtime map data, final coordinates, pathfinding nodes,
collision masks, build-zone polygons or asset geometry.
