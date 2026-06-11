# M16-CP Uferwald Layer Candidate Intake and QA

Status: `layer_postprocess_candidate`
Slice type: visual documentation / candidate intake
Commit status: no commit in this slice

## 1. Purpose

M16-CP takes one already generated Uferwald `island_base` image from the
explicitly approved local Downloads file, copies it into the repo as
documentation material, creates 1x/2x/3x review copies, creates a contact sheet,
measures documentation anchors and records QA.

This is not a new image-generation slice. Codex does not generate, repaint,
trace or approve artwork here.

## 2. Inputs and Boundaries

Approved local source:

```text
~/Downloads/talvori_island_base_uferwald_structure_postprocess_candidate_v1_1x.png
```

Repo intake path:

```text
docs/world_design/previews/m16_cp_uferwald_layer_candidate_intake_and_qa/
```

The source file was copied, not moved. The copied 1x PNG is kept as the intake
copy. 2x and 3x files are upscaled review derivatives only.

Blocked in this slice:

- no files under `assets/`
- no engine-ready candidate
- no approved asset
- no production asset
- no final game image
- no app screen
- no Flutter/Dart code
- no route, navigation, persistence or `BuildState`
- no tests
- no repainting, tracing or new image generation by Codex
- no commit

## 3. Why the Working Name Is Uferwald

The source file uses `uferwald`, and the current image visually emphasizes a
river/coastal island with a strong forest/grove mass. M16-CP therefore tracks
this specific layer-postprocess candidate as `uferwald`.

This does not rename the product concept or replace Uferhain documentation.
Uferwald is a candidate working name for this intake file so it can be reviewed
without confusing it with M16-CG Candidate A or an approved Uferhain asset.

## 4. Files Created

| File | Role | Status |
| --- | --- | --- |
| `talvori_island_base_uferwald_structure_postprocess_candidate_v1_1x.png` | Copied source intake | `layer_postprocess_candidate`, documentation only |
| `talvori_island_base_uferwald_structure_postprocess_candidate_v1_2x.png` | 2x review copy | Documentation only, not asset |
| `talvori_island_base_uferwald_structure_postprocess_candidate_v1_3x.png` | 3x review copy | Documentation only, not asset |
| `talvori_uferwald_layer_postprocess_contact_sheet_1x.png` | Contact sheet | Documentation visual, not app screen |
| `talvori_uferwald_layer_postprocess_metadata.md` | Metadata | Source, scope, status and tool-role documentation |
| `talvori_uferwald_layer_postprocess_anchor_manifest.md` | Anchor manifest | Measured documentation anchors, not runtime anchors |
| `talvori_uferwald_layer_postprocess_qa.md` | QA | Candidate, anchor, zoom/scale and layer-readiness QA |

## 5. What Was Already Checked

- Source file exists and was copied into the allowed preview path.
- 1x source dimensions: 1254 x 1254.
- 2x review copy dimensions: 2508 x 2508.
- 3x review copy dimensions: 3762 x 3762.
- Contact sheet dimensions: 2100 x 980 after M16-CP2.
- Contact sheet is readable and marks all copies as documentation only.
- The image has no visible buildings, figures, HUD, labels or app UI.
- Uferwald identity, coast/riverbank, central clearing, grove/no-build area and broad reserve areas are readable.
- Anchor manifest contains measured normalized coordinates from the current bitmap.
- Transparent per-layer exports are not present.
- Separate true layers are not present.

## 5.1 M16-CP2 Pillow Scaling Addendum

M16-CP2 keeps the existing repo 1x PNG as the Source of Truth:

```text
docs/world_design/previews/m16_cp_uferwald_layer_candidate_intake_and_qa/talvori_island_base_uferwald_structure_postprocess_candidate_v1_1x.png
```

The 1x file was not resaved or repainted. It remains the copied intake file
from M16-CP.

M16-CP2 replaced the 2x, 3x and contact-sheet files with a reproducible local
Pillow pipeline:

- tool: Pillow `12.2.0`
- scaling method: `Image.Resampling.LANCZOS`
- 2x target: 2508 x 2508
- 3x target: 3762 x 3762
- contact sheet: regenerated from the existing 1x, 2x and 3x files
- contact sheet labels: mark 1x as source of truth and 2x/3x as Pillow review
  copies

The LANCZOS copies are better documented and reproducible, but they are still
not detail upgrades. They are scale-review copies only. They do not create
new structure, new pixels with reliable art information, transparency, true
layers or engine-ready exports.

## 6. What 1x / 2x / 3x Can and Cannot Prove

1x is sufficient for documentation review, contact-sheet comparison and broad
mobile readability checks.

2x and 3x are useful for zoom inspection. They now come from Pillow
`Image.Resampling.LANCZOS`, but they still do not add source detail and must
not be treated as production exports. They are upscaled review copies only.

Mobile zoom can be judged at a high level:

- zoom-out: island silhouette, water, grove and central clearing remain clear
- medium zoom: build reserves and river structure are readable
- zoom-in: the basis is readable enough for documentation review, anchor
  discussion and broad layer planning, but painterly monolith risk appears;
  real layers still need external postprocess/source-layer work

## 7. Anchor and Placement Result

The anchor manifest records:

- `main_build_area_anchor`
- `hub_center_anchor`
- `house_primary_anchor`
- `river_entry_anchor`
- `river_exit_anchor`
- `grove_anchor`
- `reserve_zone_anchor_north`
- `reserve_zone_anchor_south`

All coordinates are marked as
`measured_on_candidate_bitmap_not_final_runtime_anchor`. They help align later
production briefs, but they are not runtime placement data.

Placement zones are documented for buildable footprint, soft placement,
reserve, no-build, no-overlap, water-only and terrain-sensitive areas.

## 8. Layer Readiness

Current state:

- `island_base` as flat bitmap: JA
- real transparent per-layer backgrounds: NEIN
- true separate `water_paths`, `terrain_layers`, `slot_markers` layers: NEIN
- measured documentation anchors: JA
- production-ready layers: NEIN, still blocked

The current RGB PNG is useful for structure and QA, but it is not enough to
derive clean transparent layers. Any claim of real layer separation would be
false at this point.

## 9. Decision Block

| Decision | Result |
| --- | --- |
| Uferwald-Candidate-Intake erfolgreich | JA |
| Anchor-Manifest erfolgreich | JA |
| Zoom-/Scale-QA als Dokumentation erfolgreich | JA |
| Echte transparente Layer schon vorhanden | NEIN |
| Echte separate Layer schon vorhanden | NEIN |
| Candidate status remains `layer_postprocess_candidate` | JA |
| Asset / engine-ready / production approval | NEIN |

## 10. Follow Path

Next sensible slice:

```text
M16-CQ Uferwald Layer Candidate Review and Postprocess Decision
```

That review should decide whether the Uferwald intake is good enough as a
structure/postprocess reference, whether external layer work should continue,
and whether the name Uferwald remains a candidate working name or folds back
into the Uferhain line.

No Flutter code, `assets/` writes or engine-ready export should start from
M16-CP directly.
