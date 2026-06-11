# M16-CP Uferwald Layer Postprocess Anchor Manifest

Status: `layer_postprocess_candidate`
Anchor precision: `measured_on_current_bitmap_for_documentation_only`

## Manifest Header

| Field | Value |
| --- | --- |
| canvas_family | `uferwald_island_base` |
| canvas_origin | `top_left_normalized_0_0` |
| world_origin | `hub_center_anchor` |
| layer_pivot | `world_origin_unless_family_override` |
| coordinate_space | `normalized_0_1` |
| status | `layer_postprocess_candidate` |
| candidate_a_used_as | `structure_reference_only` |
| anchor_precision | `measured_on_current_bitmap_for_documentation_only` |
| coordinate_warning | `measured_on_candidate_bitmap_not_final_runtime_anchor` |

The coordinates below are measured against the current 1254 x 1254 bitmap by
visual inspection. They are useful for documentation, QA and later production
briefs, but they are not runtime anchors and they must be revalidated if the
image is repainted, cropped, layered or regenerated.

## Required Anchors

| Anchor | Purpose | Verbal location | normalized_x | normalized_y | Placement zone | Sort-band | No-overlap note | Risk | QA status |
| --- | --- | --- | ---: | ---: | --- | --- | --- | --- | --- |
| `main_build_area_anchor` | Main readable build reserve for the first island-base review. | Center of the broad open meadow slightly left of the river bend. | 0.41 | 0.54 | `buildable_footprint` | `midground_center` | Keep clear of river shoreline and future Build Station safety ring. | Large meadow may look too ready/final if treated as a pad. | `measured_on_candidate_bitmap_not_final_runtime_anchor` |
| `hub_center_anchor` | Documentation world origin for this candidate. | Path/river convergence near the middle of the island. | 0.49 | 0.51 | `soft_placement_zone` | `midground_center` | Do not cover central path logic or water edge. | Hub is painterly and must be clarified in later layers. | `measured_on_candidate_bitmap_not_final_runtime_anchor` |
| `house_primary_anchor` | First possible house idea reference without making a category slot. | Lower-left portion of the main meadow, still inside the central open area. | 0.38 | 0.56 | `soft_placement_zone` | `midground_center` | Keep offset from `main_build_area_anchor` and future build-station wheel. | Can be misread as fixed house slot; must stay neutral. | `measured_on_candidate_bitmap_not_final_runtime_anchor` |
| `river_entry_anchor` | Upper visible river/water entry into the island structure. | Waterfall/upper water arm entering from the north-west cliffs. | 0.31 | 0.19 | `water_only_zone` | `background_north` | No buildings, markers, UI or stations. | Current water source is visually rich but not layer-separated. | `measured_on_candidate_bitmap_not_final_runtime_anchor` |
| `river_exit_anchor` | Main lower river exit toward the sea. | Wide lower river mouth and estuary below the central meadow. | 0.58 | 0.73 | `water_only_zone` | `foreground_south` | No station or slot overlap with shoreline foam. | Exit shape must stay registered if water becomes a separate layer. | `measured_on_candidate_bitmap_not_final_runtime_anchor` |
| `grove_anchor` | Dense forest/grove identity and no-build reference. | Main pine/grove mass on the north-east/upper-middle plateau. | 0.67 | 0.31 | `no_build_zone` | `background_north` | Preserve tree canopy, cliff edge and path readability. | Dense detail may be too monolithic for later layer separation. | `measured_on_candidate_bitmap_not_final_runtime_anchor` |
| `reserve_zone_anchor_north` | Long-term neutral northern reserve. | Open high meadow behind the central ridge, below the upper cloud line. | 0.50 | 0.25 | `reserve_zone` | `background_north` | Avoid category pads; reserve only. | Far perspective makes future tap targets less readable. | `measured_on_candidate_bitmap_not_final_runtime_anchor` |
| `reserve_zone_anchor_south` | Long-term neutral southern reserve. | South-east/lower meadow near river exit and coastline. | 0.67 | 0.66 | `reserve_zone` | `foreground_south` | Keep clear of river, cliffs and future UI-safe edge. | May compete with main build area unless softened. | `measured_on_candidate_bitmap_not_final_runtime_anchor` |

## Placement and Zone Documentation

| Zone | Uferwald interpretation | Current status |
| --- | --- | --- |
| `buildable_footprint` | Main central meadow and a few broad secondary meadows that can later receive neutral slots. | Present as visual reserve, not yet real placement geometry. |
| `soft_placement_zone` | Edges around the main meadow, path junctions and lower meadow shelves where a Build Station might later be staged after its own gate. | Present as review guidance only. |
| `reserve_zone` | Northern high meadow, southern/eastern meadow and smaller quiet edge areas for long-term 16-20 slot reserve. | Present visually; not counted as final slot map. |
| `no_build_zone` | Dense grove, hard cliff faces, heavy rock outcrops and visually fragile shoreline. | Present visually; must become explicit in later layer work. |
| `no_overlap_zone` | Main river, shoreline foam, future UI-safe edges, central hub readability and future Build Station protection ring. | Documented, not encoded. |
| `water_only_zone` | Ocean, estuary, waterfall, river arms and shallow inlet water. | Visible but currently baked into one bitmap. |
| `terrain_sensitive_zone` | Cliff terraces, grove edge, waterfall edge, rocks and path transitions. | Visible; needs later layer-specific QA. |

## Depth and Sorting Bands

| Sort-band | Approximate vertical range | Rule |
| --- | --- | --- |
| `background_north` | `y <= 0.34` | Distant cliffs, high meadow, waterfall and grove must sort behind midground structures. |
| `midground_center` | `0.34 < y <= 0.63` | Main hub, buildable reserves and future slot/Build Station staging live here. |
| `foreground_south` | `y > 0.63` | Lower river exit, beach, dock area and south reserves must sort in front of midground terrain when relevant. |

## Boundary

This manifest does not create runtime anchors, code anchors, engine-ready
placement data or approved asset coordinates. It is a measured documentation
manifest for the current bitmap only.
