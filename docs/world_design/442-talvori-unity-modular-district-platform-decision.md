# Talvori Unity Modular District Platform Decision

Status: Source of truth for platform direction, accepted 2026-06-21.

This document supersedes Flutter/Flame street-world production as the primary
runtime path. It does not create a Unity project, runtime code, assets, or an
online backend. Implementation remains gated by `443-p02-vertical-slice-and-online-foundation-roadmap.md`.

## 1. Decision

Talvori's primary game runtime direction is Unity 6 URP.

The first Unity prototype is built as a separate project or repository. The
existing Flutter application remains valuable as the Foundation Build and as a
domain/app reference for learning, words, import, Companion, UI flows, and
existing product logic, but no further Firenze street or 3D world art should be
built in Flutter/Flame without a dedicated legacy gate.

Talvori becomes an isometric 3D exploration and learning game. Cities are made
from modular, separately loadable district scenes. Firenze Overview remains a
map and orientation layer; the playable district is a distinct 3D scene.

P02 is the first Unity vertical slice.

## 2. Product Model

- The player explores coherent, authored city districts rather than a freely
  generated open world.
- Districts are 80-90 percent prebuilt.
- Player agency happens through fixed build, repair, learning, and upgrade
  slots.
- The MVP is not a free city builder.
- The MVP is not a seamless MMO.
- The MVP is not a globally and freely buildable city.
- The local P02 slice must work before online play is opened.

The intended player promise remains:

> Sammle Woerter aus der echten Welt. Lerne sie im Kontext. Baue deine Welt.

## 3. Technical Architecture

### Unity Runtime

Unity 6 URP is the primary runtime for the game world, district scenes, 3D
characters, lighting, camera, interaction hotspots, NavMesh, prefabs,
Addressables, local builds, and QA.

### Flutter Boundary

Flutter is frozen as the existing Foundation Build and domain/app reference.
It may remain useful for learning flows, Companion flows, import/translation
logic, vocabulary reference behavior, and product comparison, but it is not the
primary runtime for Firenze street playfields or 3D world art.

No new Flutter/Flame Firenze street, road-skin, or 3D-world proof should be
started without a named Flutter Legacy Gate.

### District Packages

Each city district is treated as a package with:

- a Unity scene or scene group,
- environment kit prefabs,
- district-specific props,
- entry and exit contracts,
- fixed build/upgrade slots,
- navigation contracts,
- local interaction/hotspot contracts,
- provenance and license records,
- later Addressable labels.

City and district content is modularized through Addressables after the first
local P02 slice proves the shape.

## 4. Firenze Direction

Firenze Overview remains a map and orientation layer. It can show districts,
plot numbers, boundaries, Arno, bridges, roads, and route intent, but it is not
automatically detailed Unity street geometry.

P01-P14 become district definitions and planning anchors. Entry/exit and
neighborhood contracts from the Firenze technical documents remain valuable.
The Unity district scene decides what the player actually sees and walks on.

P02 is the first vertical slice because it gives the team a small, bounded
district target for scale, camera, kit intake, navigation, interaction, and
learning loops.

## 5. Asset Strategy

Talvori uses a coherent environment-kit-first strategy.

Most visible city structure should come from a stylistically coherent kit:
streets, curbs, facades, stairs, arches, market edges, planters, lighting,
vegetation, wall trims, plaza parts, and district dressing. Meshy and Sloyd are
used for Talvori-specific special objects, variants, or gaps, not as the
primary source for complete city topology.

Codex is the Technical Environment Assembler:

- import,
- prefab organization,
- editor scripts,
- scale and pivot QA,
- NavMesh setup,
- collider setup,
- Addressables labels,
- configuration,
- build checks,
- technical QA.

Codex is not the autonomous art director and should not build the final city
from primitives.

## 6. Adventure Creator Role

Adventure Creator is an optional content layer for:

- dialogue,
- hotspots,
- cutscenes,
- local adventure flow,
- scene-specific authored interactions.

Adventure Creator is not the source of truth for:

- learning state,
- vocabulary state,
- quest ownership,
- build state,
- online state,
- economy or rewards,
- server authority.

Those domains remain owned by Talvori systems behind explicit interfaces.

## 7. Online Direction

Online opens only after a working local P02 slice.

The online model uses small instanced districts:

- personal district instances,
- public social district instances,
- party quest district instances.

Online services are abstracted behind Talvori-owned interfaces. UGS and Nakama
remain provider candidates until a comparison gate. Chat requires separate
auth, moderation, block, report, and safety gates before it becomes a product
feature.

## 8. Source-of-Truth Hierarchy

The documentation hierarchy is now:

1. `AGENTS.md`
2. `docs/world_design/442-talvori-unity-modular-district-platform-decision.md`
3. `docs/world_design/443-p02-vertical-slice-and-online-foundation-roadmap.md`
4. `docs/world_design/talvori_game_bible.md`
5. `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
6. domain-specific docs and historical proof docs

When older documents conflict with this decision, this document wins.

## 9. Impact Audit

| Document | Action | Reason |
| --- | --- | --- |
| `AGENTS.md` | Update | Repository rules must name Unity 6 URP, Flutter freeze, asset-kit-first, and no online before local P02. |
| `336-documentation-map-and-slice-reading-rules.md` | Update | Routing must include Unity platform, district slices, environment kit intake, Adventure Creator, provider evaluation, online/chat, and Flutter legacy gates. |
| `328-talvori-learning-game-readiness-todo-checklist.md` | Update | Checklist needs Unity, packaging, migration, online, chat, and licensing gates without marking implementation as done. |
| `talvori_game_bible.md` | Update | Product model changes to isometric 3D exploration with prebuilt districts and fixed slots. |
| `366-ai-art-production-pipeline-and-style-consistency-gate.md` | Update | AI pipeline must become environment-kit-first with provenance requirements and AI only for controlled gaps. |
| `367-talvori-art-bible-v1.md` | Update | Art bible remains useful, but must lead into Unity realtime 3D, isometric camera, mobile readability, and material/light families. |
| `370-asset-family-and-export-spec.md` | Update | Export spec must include Unity units, pivots, colliders, LODs, prefabs, texture budgets, Addressable labels, and license manifest. |
| `426-firenze-master-technical-layout-readiness-check.md` | Update | Firenze Overview remains map/orientation; graph is not direct Unity street geometry. |
| `431-firenze-area-specification-metrics-and-reachability-review-v1.md` | Update | P01-P14 become district definitions; entry/exit contracts remain. |
| `438-talvori-modern-2d-25d-character-sprite-style-decision.md` | Supersede partially | 3D Explorer is primary Unity prototype character; 8-direction sprites remain fallback/overview/legacy proof. |
| `439-talvori-firenze-visual-era-and-environment-style-direction-gate.md` | Update | Neo-Renaissance direction remains valid for Unity kit/district production. |
| `440-talvori-firenze-neo-renaissance-visual-direction-board.md` | Update | Visual board remains style source, now for Unity environment kit intake. |
| `441-talvori-firenze-road-infrastructure-kit-architecture.md` | Supersede partially | Blender-first road-kit work was a proof. Production starts with coherent kit/prefab roads, with custom Blender work for controlled gaps. |
| Flutter Street Proofs 1T-1X | Historical | Technically useful, no longer primary visual/runtime path. |
| Reset 1Y | Historical but valid | Its distinction between Overview and Street Scene remains part of the Unity direction. |

## 10. Superseded Paths

The following are not deleted and remain useful historical evidence:

- Flutter/Flame Firenze road-skin overlays as final world presentation.
- Flutter-drawn street playfields as the route-scene art pipeline.
- Blender-first full road kit production as the primary production plan.
- 8-direction character sprites as the primary character runtime.

They are replaced by:

- Unity 6 URP as primary game runtime.
- coherent environment kit intake first,
- modular district scenes,
- fixed build/upgrade slots,
- Unity technical assembly and QA,
- P02 local vertical slice before online.

## 11. Non-Goals

- No Unity project is created by this decision.
- No app code changes are implied.
- No production assets are imported.
- No online provider is selected.
- No chat feature is opened.
- No historical proof is deleted.
