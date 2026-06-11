# M16-CP Uferwald Layer Postprocess Metadata

Status: `layer_postprocess_candidate`
Scope: documentation only, not asset, not engine-ready, not production

## Candidate Record

| Field | Value |
| --- | --- |
| asset_id | `talvori_island_base_uferwald_structure_postprocess_candidate_v1` |
| asset_family | `island_base` |
| working_name | `uferwald` |
| slice_id | `M16-CP` |
| derivative_update_slice | `M16-CP2` |
| status | `layer_postprocess_candidate` |
| candidate_a_used_as | `structure_reference_only` |
| canvas_family | `uferwald_island_base` |
| canvas_origin | `top_left_normalized_0_0` |
| world_origin | `hub_center_anchor` |
| layer_pivot | `world_origin_unless_family_override` |
| coordinate_space | `normalized_0_1` |
| source_file | `~/Downloads/talvori_island_base_uferwald_structure_postprocess_candidate_v1_1x.png` |
| intended_use | Documentation intake, anchor measurement, zoom/scale QA and layer-readiness review for later Uferwald/Uferhain island-base work. |
| generation_origin | `chatgpt_image_gen` |
| review_derivatives | `1x`, `2x`, `3x`; 1x is the unchanged source-of-truth intake file, 2x/3x are Pillow LANCZOS review copies only, not production exports. |
| scaling_tool | `Pillow 12.2.0` |
| scaling_method | `Image.Resampling.LANCZOS` |
| scaling_source_of_truth | `talvori_island_base_uferwald_structure_postprocess_candidate_v1_1x.png`; not resaved in M16-CP2. |
| scaling_note | 2x and 3x are deterministic scale-review copies with no new source detail, no true layer information and no engine-ready status. |
| allowed_scope | Copy the explicitly approved local PNG into the docs preview path, create 2x/3x review copies, create a contact sheet, document metadata, anchor manifest and QA. |
| blocked_scope | `assets/`, engine-ready candidate, approved asset, final game image, app screen, runtime export, Flutter/Dart code, route, navigation, persistence, `BuildState`, tests, external writes, repainting or new image generation by Codex. |
| not_asset_path_check | Passed: all files are under `docs/world_design/previews/m16_cp_uferwald_layer_candidate_intake_and_qa/`. |
| not_engine_ready_check | Passed: status remains `layer_postprocess_candidate`; no engine-ready metadata or asset path is assigned. |
| license_notes | Source was provided from the user's local Downloads folder after ChatGPT/image_gen generation. Production use rights, source retention and any downstream license notes must be rechecked in a later asset gate. |
| tool_role_split | ChatGPT/image_gen produced the source outside Codex; Codex copied the approved file in M16-CP, regenerated 2x/3x review-scale copies and the contact sheet with Pillow in M16-CP2, measured/documented anchors and wrote QA. Codex did not generate, repaint, trace, approve or integrate artwork. |

## Repo Files

| File | Dimensions | SHA-256 | Role |
| --- | --- | --- | --- |
| `talvori_island_base_uferwald_structure_postprocess_candidate_v1_1x.png` | 1254 x 1254 | `ce6b4d7a2386b5c4199c6d8fbd3cba3990f708ee9eff584bb34a4d5b38ef431d` | Intake copy of the approved source PNG. |
| `talvori_island_base_uferwald_structure_postprocess_candidate_v1_2x.png` | 2508 x 2508 | `79b5511718daa887d7bdca0248498b905ad323ad3a648841cdc4f0275420cb2b` | Pillow LANCZOS documentation/review copy only. |
| `talvori_island_base_uferwald_structure_postprocess_candidate_v1_3x.png` | 3762 x 3762 | `7ca464384ec0166109a0fed51952e3cfd5b8a84bd953b4cf88e1c0db665d3f49` | Pillow LANCZOS documentation/review copy only. |
| `talvori_uferwald_layer_postprocess_contact_sheet_1x.png` | 2100 x 980 | `2776cdd006fd0495d5294382177d347ad395801176a9647445bf2006ef1063b2` | Pillow-generated documentation contact sheet, not an app screen. |

## Status Boundaries

- This file does not approve the candidate as a final asset.
- This file does not approve the candidate as an app screen.
- This file does not mark the image as engine-ready.
- This file does not create transparent per-layer exports.
- This file does not create separate `island_base`, `water_paths`, `terrain_layers` or `slot_markers` layers.
- 2x and 3x are Pillow LANCZOS review copies only; they add no new source detail.
