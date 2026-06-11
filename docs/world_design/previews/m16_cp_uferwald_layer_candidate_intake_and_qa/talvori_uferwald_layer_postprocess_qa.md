# M16-CP Uferwald Layer Postprocess QA

Status: `layer_postprocess_candidate`
QA scope: documentation intake, contact sheet review, anchor measurement,
zoom/scale review and layer-readiness assessment.

## A. Image and Candidate Status

| Check | Result | Notes |
| --- | --- | --- |
| Status is `layer_postprocess_candidate` | JA | Metadata and contact sheet use the same status. |
| Not asset | JA | Files remain under docs preview path and are not under `assets/`. |
| Not engine-ready | JA | No engine-ready export, runtime metadata or approved status exists. |
| Not production | JA | 1x/2x/3x are review/documentation copies only. |
| Not app screen | JA | No UI shell, HUD, route or app surface is present. |
| Codex did not generate a new game image | JA | Codex copied the approved source in M16-CP and regenerated only Pillow review derivatives/contact sheet in M16-CP2. |

## B. Structure and Island Review

| Check | Result | Notes |
| --- | --- | --- |
| Uferwald identity | JA | The image reads as a forested river/coast island with strong grove identity. |
| Coast/riverbank readability | JA | Ocean edge, river arms, waterfall and estuary are clearly readable. |
| Central clearing / hub | JA | A broad central open area and path/river convergence are visible. |
| Grove/no-build zone | JA | Dense north-east forest and cliff/grove areas read as natural no-build zones. |
| Organic room for later categories | JA | Multiple soft reserve meadows exist without hard category labels. |
| No visible category plots | JA | No house/market/workshop pads are drawn. Some clearings must be softened later so they do not become pad-like. |
| No visible slot markers | JA | No pins, icons or markers are present. |
| No buildings / figures / UI / text | JA | The image contains no buildings, figures, HUD, bubbles or labels. |
| Cozy 2.5D island diorama direction | JA | Warm light, elevated perspective and readable terrain fit the Art Bible direction. |

## C. Anchor, Placement and Registration QA

| Check | Result | Notes |
| --- | --- | --- |
| Canvas rule present | JA | `canvas_family: uferwald_island_base`, square 1254 x 1254 source. |
| Origin/pivot documented | JA | Top-left normalized canvas origin, `hub_center_anchor` as world origin, family pivot rule documented. |
| Anchors present | JA | Eight required anchors are documented with measured normalized coordinates. |
| Placement zones present | JA | Buildable, soft placement, reserve, no-build, no-overlap, water-only and terrain-sensitive zones are documented. |
| No-build/no-overlap zones present | JA | Water, grove, cliffs, shoreline, UI-safe edges and future Build Station protection are called out. |
| Depth/sorting logic documented | JA | Background, midground and foreground sort-bands are defined. |
| Usable for later layer registration | TEILWEISE | Good for documentation and production brief alignment; not yet enough for runtime placement or engine-ready layer registration. |

## D. Zoom and Scale QA

| Check | Result | Notes |
| --- | --- | --- |
| 1x documentation view | JA | 1254 x 1254 is readable for review and contact-sheet use. |
| Pillow scaling method documented | JA | 2x/3x were regenerated with Pillow `12.2.0` and `Image.Resampling.LANCZOS`. |
| 1x source of truth unchanged | JA | The 1254 x 1254 intake PNG was not resaved in M16-CP2. |
| 2x review copy | JA | 2508 x 2508 is useful for zoom review, but it is a Pillow LANCZOS upscale with no new detail. |
| 3x review copy | JA | 3762 x 3762 is useful for inspection, but it is a Pillow LANCZOS upscale and not a production export. |
| Zoom-out readability | JA | Overall island silhouette, water, grove and central meadow remain understandable. |
| Mid-zoom readability | JA | Main reserves, forest mass, river structure and central meadow are readable enough for documentation review. |
| Zoom-in adequacy | TEILWEISE | The basis is adequate for review and anchor discussion, but not for final detail approval. |
| Zoom-in risk | TEILWEISE | Painterly details and baked lighting/water/trees can look monolithic when inspected closely; 2x/3x do not fix that. |
| Review copy vs production export distinction | JA | Metadata, QA and contact sheet mark 1x/2x/3x as documentation only. |

## E. Layer and Export Readiness

| Check | Result | Notes |
| --- | --- | --- |
| `island_base` as flat bitmap exists | JA | The copied 1x PNG is present and documented. |
| Transparent backgrounds per layer already derivable | NEIN | Blocked / not yet available. The current PNG is RGB and monolithic; transparency per layer would require external postprocess or source-layer work. |
| Separate true layers already present | NEIN | Blocked / not yet available. `water_paths`, `terrain_layers`, `slot_markers` and other families are not separate files. |
| Measured documentation anchors present | JA | Anchor manifest contains measured normalized coordinates. |
| Production-ready layers still blocked | JA | Later external/image/postprocess work must create real layer candidates with metadata and QA. |

## Contact Sheet QA

| Check | Result | Notes |
| --- | --- | --- |
| Contact sheet created | JA | `talvori_uferwald_layer_postprocess_contact_sheet_1x.png`, regenerated with Pillow in M16-CP2. |
| Text readable | JA | Captions and status line are visible. |
| No text overlap | JA | No visible text collision. |
| No cropped captions | JA | Captions fit inside their cards. |
| Scaling method visible | JA | Header and captions show Pillow/LANCZOS review status. |
| Status visible | JA | `layer_postprocess_candidate`, `documentation only`, `not asset`, `not engine-ready`, `not production`. |

## QA Decision

- Uferwald candidate intake QA: JA
- Anchor/registration documentation QA: JA for documentation, NEIN for runtime/final anchors.
- Zoom/scale QA: JA for Pillow LANCZOS review copies, NEIN for production export.
- Transparent layer readiness: NEIN, blocked / not yet available.
- Separate layer readiness: NEIN, blocked / not yet available.
- Next sensible step: review M16-CP, then decide whether a later slice should request external postprocess/layer work with the measured anchor manifest.
