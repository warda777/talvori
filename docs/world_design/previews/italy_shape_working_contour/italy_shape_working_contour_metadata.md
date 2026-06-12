# Italy Shape Working Contour Metadata

Status: `documentation_only / not_asset / not_runtime_data / not_engine_ready`
Slice: Italy working contour visual gate

## Source

- source_dataset: Natural Earth Admin 0 - Countries
- source_version: 5.1.1
- source_download_url: `https://naciscdn.org/naturalearth/10m/cultural/ne_10m_admin_0_countries.zip`
- source_archive_used_temporarily: `/private/tmp/talvori_italy_shape_working_contour/ne_10m_admin_0_countries.zip`
- source_feature: Italy (`ISO_A3=ITA` / `ADMIN=Italy`)
- license_notes: Natural Earth vector data is public domain. Attribution note for documentation: Made with Natural Earth.
- disallowed_sources: no Google Maps, no Apple Maps, no Pinterest, no screenshots, no atlas images, no map tiles, no pixel tracing.

## Generated Documentation Files

- `italy_shape_working_contour.svg`
- `italy_shape_working_contour.png`
- `italy_shape_working_contour_metadata.md`

## Included Components

- mainland Italy: included as the primary recognizable boot shape
- Sicily: included as a readable separate island component
- Sardinia: included as a readable separate island component
- small minor islands: omitted or absorbed by simplification when they hurt mobile readability

## Simplification

- extraction_method: Natural Earth country feature extracted from the Admin 0 Countries vector dataset
- selected_geometry: three largest Italy polygon parts for mainland, Sicily and Sardinia
- simplification_method: Ramer-Douglas-Peucker simplification for documentation visual readability
- simplification_tolerance_degrees: `0.025`
- point_count_after_simplification: `442`
- purpose: preserve the boot silhouette and major islands while reducing coastline noise for mobile planning

## Boundaries

- runtime_status: not_runtime_data
- asset_status: not_asset
- engine_status: not_engine_ready
- coordinate_status: documentation_viewbox_only_not_final_coordinates
- geometry_status: documentation_visual_only_not_productive_polygons
- app_integration: none
- route_integration: none
- build_state: none

This SVG/PNG pair is a visible working contour for planning. It is not a runtime map, not an asset, not a final art target and not a coordinate source for gameplay.
