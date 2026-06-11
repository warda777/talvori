# M16-CG Uferhain Island Base Candidate Metadata

Stand: 2026-06-11

Status: `asset_candidate / documentation review only`

Diese Datei dokumentiert die in M16-CG erzeugten `island_base`-
Dokumentationscandidates fuer Uferhain. Die PNGs sind keine finalen
Spielbilder, keine App-Screens, keine Engine-ready Candidates und keine
approved Assets. Sie duerfen nicht nach `assets/` kopiert oder in Flutter
integriert werden.

Erlaubter Dokumentationspfad:

```text
docs/world_design/previews/m16_cg_starter_island_base_candidate_generation/
```

Pflichtsatz aus M16-CF/372:

> This is a documentation candidate for art/structure review only, not a final
> game asset, not an app screen, not engine-ready, and not for production use.

Negative Prompt fuer alle Candidates:

```text
photorealistic, realistic 3D render, flat editor map, city builder UI,
app screen, dashboard, worksheet, school exercise, menu UI, bottom sheet,
labels, text, logo, characters, buildings, market, house, workshop,
roads as rigid grid, category plots, pins, icons, final game asset,
production asset, pixel-art mismatch, dark grim mood, generic tropical island,
copied reference image, screenshot look, watermark, low-resolution blur,
cluttered tiny details.
```

## Candidate A

```text
asset_id: talvori_island_base_uferhain_candidate_a_1x
asset_family: island_base
working_name: Uferhain broad grove island
intended_use: documentation_candidate_only
slice_id: M16-CG
status: asset_candidate
source_tool: OpenAI image_gen built-in image tool, invoked under explicit M16-CG documentation-candidate permission
source_file: /Users/andreaswarda/.codex/generated_images/019e20cf-705b-7c22-a2b7-98560dce7598/ig_0af7d1320112d491016a2a823b202c8193a870019cfc85fb47.png
prompt: Generate a square PNG documentation candidate for art/structure review only. Candidate A: Talvori Uferhain starter island base. Warm 2.5D cozy island diorama, slightly elevated isometric-like perspective, soft stylized hand-painted game concept look, island-first and object-first. A coastal grove / riverbank starter island base with a readable island contour near water, one gentle river arm or shore inlet, a central open clearing / hub, grove and forest-edge areas, slight height changes and calm edge areas. The terrain should imply enough broad neutral open areas for about 12 future visible building slots and long-term reserve for 16-20 slots, but show only rough buildable reserve areas, no final slot markers. No buildings, no characters, no HUD, no speech bubbles, no labels, no text, no app UI, no roads as rigid grid, no pins, no icons. High-level structure reference, not final art. Required status sentence: This is a documentation candidate for art/structure review only, not a final game asset, not an app screen, not engine-ready, and not for production use.
negative_prompt: see shared negative prompt above
style_reference: docs/world_design/367-talvori-art-bible-v1.md
structure_reference: docs/world_design/368-starter-island-master-reference-set.md
master_reference: docs/world_design/368-starter-island-master-reference-set.md
asset_spec: docs/world_design/370-asset-family-and-export-spec.md
candidate_gate: docs/world_design/371-starter-island-asset-candidate-gate.md
generation_gate: docs/world_design/372-starter-island-base-candidate-generation-gate.md
seed_or_generation_id: 019e20cf-705b-7c22-a2b7-98560dce7598 / ig_0af7d1320112d491016a2a823b202c8193a870019cfc85fb47
postprocess_tool: copied unchanged into allowed docs preview path; no candidate pixel edits
license_notes: generated as local documentation material; license and usage rights must be rechecked before any later asset gate
export_format: PNG
pixel_size: 1254x1254
scale_variant: 1x
layer_notes: flattened documentation candidate; useful for structure review only; not separated into engine layers
qa_status: candidate_ready_for_asset_gate
approved_by: none
blocked_reason: none for documentation review; still not an approved asset
allowed_scope: documentation_candidate_only
uferhain_identity_check: pass - strong coastal grove / riverbank starter island identity
coast_or_riverarm_check: pass - visible shore and river/inlet system
grove_check: pass - clear forest and grove areas
central_clearing_check: pass - large central clearing / hub is readable
slot_capacity_12_check: pass - many broad neutral reserve meadows are plausible
reserve_capacity_16_20_check: pass - long-term reserve remains plausible through terraces and edge spaces
neutral_slot_reserve_check: pass - reserves are terrain clearings, not category plots
perspective_check: pass - warm 2.5D elevated diorama perspective
mobile_readability_check: pass - main landmass, water, grove and open areas stay readable at contact-sheet scale
layer_separation_check: caution - flattened concept, not layer-separated
no_text_or_ui_check: pass - no intentional text, labels, pins, HUD or app UI
not_asset_path_check: pass - stored only under docs/world_design/previews/m16_cg_starter_island_base_candidate_generation/
not_engine_ready_check: pass - explicitly documentation candidate only
```

## Candidate B

```text
asset_id: talvori_island_base_uferhain_candidate_b_1x
asset_family: island_base
working_name: Uferhain riverarm terraces
intended_use: documentation_candidate_only
slice_id: M16-CG
status: asset_candidate
source_tool: OpenAI image_gen built-in image tool, invoked under explicit M16-CG documentation-candidate permission
source_file: /Users/andreaswarda/.codex/generated_images/019e20cf-705b-7c22-a2b7-98560dce7598/ig_0af7d1320112d491016a2a82fbf8988193a267b692c3057367.png
prompt: Generate a square PNG documentation candidate for art/structure review only. Candidate B: Talvori Uferhain starter island base. Warm 2.5D cozy island diorama, slightly elevated perspective, cohesive stylized mobile-game art direction, soft readable shapes. Create a riverbank/coastal grove starter island with a crescent shore, one river arm curling through or beside the island, a central open clearing / hub, clustered grove and forest-edge zones, mild slopes and quiet reserve edges. The island should feel like a place a player can later shape freely, with broad neutral meadows and terraces that could hold about 12 future visible slots and reserve for 16-20 long-term slots. Only imply rough building reserve areas through terrain clearings; no final slot markers. No buildings, no characters, no HUD, no bubbles, no labels, no text, no app UI, no icons, no pins, no grid roads. Cozy, alive, island-first, not a finished runtime asset. Required status sentence: This is a documentation candidate for art/structure review only, not a final game asset, not an app screen, not engine-ready, and not for production use.
negative_prompt: see shared negative prompt above
style_reference: docs/world_design/367-talvori-art-bible-v1.md
structure_reference: docs/world_design/368-starter-island-master-reference-set.md
master_reference: docs/world_design/368-starter-island-master-reference-set.md
asset_spec: docs/world_design/370-asset-family-and-export-spec.md
candidate_gate: docs/world_design/371-starter-island-asset-candidate-gate.md
generation_gate: docs/world_design/372-starter-island-base-candidate-generation-gate.md
seed_or_generation_id: 019e20cf-705b-7c22-a2b7-98560dce7598 / ig_0af7d1320112d491016a2a82fbf8988193a267b692c3057367
postprocess_tool: copied unchanged into allowed docs preview path; no candidate pixel edits
license_notes: generated as local documentation material; license and usage rights must be rechecked before any later asset gate
export_format: PNG
pixel_size: 1254x1254
scale_variant: 1x
layer_notes: flattened documentation candidate; useful for structure review only; not separated into engine layers
qa_status: needs_postprocess
approved_by: none
blocked_reason: slightly map-like terrace edges should be reviewed before promotion
allowed_scope: documentation_candidate_only
uferhain_identity_check: pass - riverarm and grove identity are clear
coast_or_riverarm_check: pass - riverarm is the strongest structural feature
grove_check: pass - forest edge and mixed trees are present
central_clearing_check: pass - central open area is readable
slot_capacity_12_check: pass - visible terraces can plausibly host 12 later slots
reserve_capacity_16_20_check: pass with caution - shape allows expansion, but future reserve depends on later layer planning
neutral_slot_reserve_check: pass with caution - open terraces are neutral but could be mistaken for fixed pads if overused
perspective_check: pass - elevated 2.5D diorama perspective
mobile_readability_check: pass - large shapes remain readable
layer_separation_check: caution - flattened concept, not layer-separated
no_text_or_ui_check: pass - no intentional text, labels, pins, HUD or app UI
not_asset_path_check: pass - stored only under docs/world_design/previews/m16_cg_starter_island_base_candidate_generation/
not_engine_ready_check: pass - explicitly documentation candidate only
```

## Candidate C

```text
asset_id: talvori_island_base_uferhain_candidate_c_1x
asset_family: island_base
working_name: Uferhain expansion-rich island
intended_use: documentation_candidate_only
slice_id: M16-CG
status: asset_candidate
source_tool: OpenAI image_gen built-in image tool, invoked under explicit M16-CG documentation-candidate permission
source_file: /Users/andreaswarda/.codex/generated_images/019e20cf-705b-7c22-a2b7-98560dce7598/ig_0af7d1320112d491016a2a81a9dd808193ae8e19334ee65911.png
prompt: Generate a square PNG documentation candidate for art/structure review only. Candidate C: Talvori Uferhain starter island base. Warm high-quality 2.5D cozy island diorama, slightly elevated unified perspective, mobile-game art direction, soft readable terrain. Design a quiet coastal-grove and river-shore starter island called Uferhain: water around the island, a calm river arm or inlet cutting into the land, a central light clearing / hub, grove and woodland edge, small height terraces, rocky shore and calm reserve edges. Leave broad neutral open terrain patches that plausibly support about 12 later visible slots and long-term expansion to 16-20 slots, but do not draw any slot markers or category plots. No buildings, no characters, no HUD, no bubbles, no labels, no text, no app UI, no pins, no icons, no rigid grid roads. It should be structure-review material with a strong Uferhain identity, not a finished runtime asset. Required status sentence: This is a documentation candidate for art/structure review only, not a final game asset, not an app screen, not engine-ready, and not for production use.
negative_prompt: see shared negative prompt above
style_reference: docs/world_design/367-talvori-art-bible-v1.md
structure_reference: docs/world_design/368-starter-island-master-reference-set.md
master_reference: docs/world_design/368-starter-island-master-reference-set.md
asset_spec: docs/world_design/370-asset-family-and-export-spec.md
candidate_gate: docs/world_design/371-starter-island-asset-candidate-gate.md
generation_gate: docs/world_design/372-starter-island-base-candidate-generation-gate.md
seed_or_generation_id: 019e20cf-705b-7c22-a2b7-98560dce7598 / ig_0af7d1320112d491016a2a81a9dd808193ae8e19334ee65911
postprocess_tool: copied unchanged into allowed docs preview path; no candidate pixel edits
license_notes: generated as local documentation material; license and usage rights must be rechecked before any later asset gate
export_format: PNG
pixel_size: 1254x1254
scale_variant: 1x
layer_notes: flattened documentation candidate; useful for structure review only; not separated into engine layers
qa_status: needs_postprocess
approved_by: none
blocked_reason: strong reserve shape, but waterfall/height emphasis and satellite-islet feel need art-direction review
allowed_scope: documentation_candidate_only
uferhain_identity_check: pass - coastal grove and river-shore read are strong
coast_or_riverarm_check: pass - water surrounds island and riverarm/inlet is visible
grove_check: pass - dense grove and woodland edge are readable
central_clearing_check: pass - broad central hub area is readable
slot_capacity_12_check: pass - broad open reserve fields are plausible
reserve_capacity_16_20_check: pass - long-term reserve is strongest in this candidate
neutral_slot_reserve_check: pass - open areas remain location-based, not category-specific
perspective_check: pass with caution - elevated 2.5D perspective works, but height drama may need calmer Uferhain tuning
mobile_readability_check: pass - island silhouette and open fields stay readable
layer_separation_check: caution - flattened concept, not layer-separated
no_text_or_ui_check: pass - no intentional text, labels, pins, HUD or app UI
not_asset_path_check: pass - stored only under docs/world_design/previews/m16_cg_starter_island_base_candidate_generation/
not_engine_ready_check: pass - explicitly documentation candidate only
```

## Contact Sheet

```text
asset_id: talvori_island_base_uferhain_contact_sheet_1x
intended_use: candidate_review_contact_sheet
slice_id: M16-CG
status: documentation_visual
source_tool: bundled Python/Pillow layout script run locally by Codex
source_file: docs/world_design/previews/m16_cg_starter_island_base_candidate_generation/talvori_island_base_uferhain_contact_sheet_1x.png
export_format: PNG
pixel_size: 1740x900
qa_status: candidate_ready_for_asset_gate
allowed_scope: documentation_candidate_review_only
notes: Contact sheet labels are documentation annotations; candidate images themselves remain text/UI-free.
```

## Slice QA Summary

| Check | Result |
| --- | --- |
| Uferhain identity | Pass: all candidates show water/shore plus grove/forest identity. |
| Island base only | Pass: no buildings, characters, HUD, bubbles, labels or final slot markers. |
| Perspective | Pass with review notes: all are elevated 2.5D; Candidate C is most height-dramatic. |
| Slot reserve | Pass: all imply ca. 12 neutral future reserve areas; C has strongest 16-20 reserve. |
| Neutrality | Pass with caution for B: some terraces could be mistaken for fixed pads if promoted unchanged. |
| Layerability | Caution: all candidates are flattened documentation images and need later layer planning. |
| Mobile readability | Pass: silhouettes, water, grove and open areas read at contact-sheet scale. |
| Game DNA | Pass: cozy, island-first and not worksheet/dashboard/app-screen. |
| Reference protection | Pass: no direct reference image tracing intended or claimed; v2 board is not used as target. |
| Metadata | Pass: required M16-CF/372 fields are present. |
| Path protection | Pass: files are under the allowed docs preview path, not `assets/`. |
| Status protection | Pass: max candidate status is `asset_candidate`; no Engine-ready or approved Asset status. |

Empfohlene Review-Reihenfolge:

1. Candidate A als staerkste erste Struktur fuer Uferhain pruefen.
2. Candidate C fuer langfristige Reserve und groessere Inselkapazitaet pruefen.
3. Candidate B nur weiterverfolgen, wenn die etwas map-artigen Terrassen
   weicher und weniger pad-artig werden.
