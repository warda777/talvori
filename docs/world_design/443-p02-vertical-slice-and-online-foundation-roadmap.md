# P02 Vertical Slice and Online Foundation Roadmap

Status: Source of truth for the first Unity vertical slice roadmap, accepted
2026-06-21.

This document depends on
`442-talvori-unity-modular-district-platform-decision.md`. It does not create a
Unity project, backend, online service, production asset, or runtime code.

## 1. Goal

Build the first local Unity vertical slice around Firenze P02 before any online
world, chat, or production-scale content system is opened.

The P02 slice must prove that Talvori can work as an isometric 3D exploration
and learning game:

- a small authored district,
- coherent environment kit,
- readable fixed isometric camera,
- Explorer movement and interaction,
- fixed build/upgrade slots,
- local learning loop,
- no root-motion dependency,
- no free city builder,
- no online dependency.

## 2. P02 Vertical Slice Contract

P02 is a bounded district scene, not a full city and not a global map.

The slice should contain:

- one coherent Neo-Renaissance Firenze district scene,
- 80-90 percent prebuilt environment,
- one or more fixed build/upgrade slots,
- one Explorer character,
- camera and scale contract,
- NavMesh and movement proof,
- one local learning interaction,
- one local reward/build feedback loop,
- one entry/exit contract back to Firenze Overview,
- technical QA for mobile-readable scale and performance.

The slice should not contain:

- online sessions,
- global chat,
- public social spaces,
- open-ended city building,
- dynamic procedural city layout,
- production monetization,
- persistent backend writes.

## 3. Gate Roadmap

| Gate | Name | Required Outcome | Opens |
| --- | --- | --- | --- |
| G0 | Documentation Migration | `442` and `443` accepted; leading docs aligned. | Unity prototype planning. |
| G1 | Unity Prototype Foundation | Separate Unity 6 URP project/repo boots locally with version policy and build target. | Environment kit intake. |
| G2 | Environment Kit Intake | Coherent kit candidate approved with license/provenance, scale, pivots, prefabs, and material family. | P02 blockout/import. |
| G3 | P02 District Assembly | P02 scene assembled from kit prefabs with NavMesh, camera, entry/exit, and fixed slot placeholders. | Character/movement proof. |
| G4 | Explorer Runtime Proof | 3D Explorer moves in-place through P02 with readable camera, pivot, scale, and interaction clearance. | Local learning interaction. |
| G5 | Local Learning Loop | One learning action changes a local district/build slot without mutating legacy SRS semantics. | Adventure/content layer gate. |
| G6 | Adventure Creator Compatibility | Optional Adventure Creator layer can handle local dialogue/hotspots without owning Talvori state. | First local P02 milestone. |
| G7 | Addressables Second-District Proof | Second small district package loads separately without changing P02 contracts. | Online provider evaluation. |
| G8 | Provider Evaluation | UGS and Nakama are compared behind Talvori-owned interfaces. | Instanced online district prototype. |
| G9 | Instanced District Online Proof | Personal/public/party district instance model works with server-authoritative state. | Social and presence gates. |
| G10 | Chat Safety Gate | Auth, moderation, block, report, and logging boundaries are defined and tested. | Limited chat/social trials. |

## 4. Unity / Flutter Boundary

Unity owns the game-world runtime path from G1 onward.

Flutter remains the Foundation Build reference for:

- learning logic behavior,
- existing word/import/translation flows,
- Companion/product patterns,
- app UI references,
- old proof comparison.

Flutter does not own new Firenze street, road, or 3D world art unless a
separate Flutter Legacy Gate explicitly reopens that path.

## 5. District Packaging

Each district package should eventually include:

- Unity scene or scene bundle,
- environment prefabs,
- local lighting and camera profile,
- NavMesh data,
- fixed build/upgrade slot markers,
- interaction markers,
- entry/exit connectors,
- Addressable labels,
- provenance/license manifest,
- QA report.

Addressables are not the first task. They become mandatory when P02 has worked
locally and a second district must be loaded as a separate package.

## 6. Fixed Build / Upgrade Slots

Player-visible world growth happens through authored slots.

Slot examples:

- repair slot,
- vocabulary shrine or word station slot,
- facade upgrade slot,
- planter/market/library detail slot,
- local district helper object slot.

Slots must have:

- stable ID,
- district ownership,
- allowed upgrade states,
- visual bounds,
- interaction bounds,
- learning/reward eligibility,
- save/online ownership policy.

The player should feel agency, but the MVP city stays authored and coherent.

## 7. Environment Kit First

The first production-looking city must come mostly from a coherent kit.

Required kit intake checks:

- license and commercial use,
- provenance,
- Unity compatibility,
- URP material behavior,
- scale and unit fit,
- pivots and origins,
- prefab structure,
- collider suitability,
- LODs or mobile budget,
- texture budgets,
- visual fit with Talvori Neo-Renaissance,
- Addressables readiness.

Meshy and Sloyd are reserved for Talvori-specific special objects, variants, or
gaps after kit direction is clear.

## 8. Codex Role

Codex can:

- inspect/import assets,
- normalize scale and pivots,
- create prefabs and editor scripts,
- organize Addressables labels,
- set up NavMesh and colliders,
- configure local builds,
- generate QA reports,
- compare providers,
- implement interfaces after gates.

Codex should not:

- generate the final city art from primitives,
- choose a final environment style without human approval,
- replace art direction,
- open online before P02,
- build production chat without moderation gates.

## 9. Adventure Creator Compatibility

Adventure Creator may be evaluated after the local P02 movement and learning
loop works.

Compatibility checks:

- hotspot authoring,
- local dialogue,
- cutscene trigger,
- camera handoff,
- save-state boundaries,
- integration with Talvori-owned interaction state,
- no ownership of learning, quest, build, or online truth.

Adventure Creator is optional. If it creates ownership or integration risk, the
P02 slice can proceed without it.

## 10. Online Foundation

Online starts after G7, not before.

The future online model is small and instanced:

- personal district instances,
- public social district instances,
- party quest district instances.

Talvori-owned interfaces should hide the provider:

- auth/session service,
- player profile service,
- district instance service,
- world state service,
- inventory/resource service,
- friends/presence service,
- chat service,
- moderation/report service.

UGS and Nakama remain candidates until the provider evaluation gate.

## 11. Chat and Moderation Gates

Chat is not a default early feature.

Before chat can ship or even become a serious prototype, Talvori needs:

- authentication boundary,
- identity policy,
- friend and block model,
- report flow,
- moderation flow,
- logging/retention policy,
- parent/minor safety review if relevant,
- abuse handling,
- product scope decision for Companion vs human chat.

## 12. First Implementation Slice After Documentation

Recommended next implementation planning slice:

> Talvori Unity P02 Prototype Repository and Environment Kit Intake Plan 2B

It should decide:

- separate Unity repo/project name,
- Unity version pin,
- target platforms,
- folder conventions,
- initial environment kit search/intake criteria,
- P02 scene acceptance criteria,
- no online code,
- no Flutter street work.
