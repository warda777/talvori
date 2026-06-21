# AGENTS.md

## Current Strategic Direction

Talvori is now oriented around **Talvori Welt**.

The old public launch path as a normal vocabulary-app MVP is paused and
superseded. The existing app is the **Foundation Build** for Talvori Welt, not
throwaway work. Words, word worlds, learning mode, word games, AI/Companion
paths, DeepL/translation logic, share/import, Tali/Vori, Tagesimpuls, profile,
stats and chat paths remain valuable.

Product north star:

> Baue deine Welt. Lerne Sprache im Kontext. Sammle Wörter, Sätze und echte
> Sprachmomente. Wachse mit Tali, Vori und Freunden.

Core direction:

- Talvori Welt is the product direction.
- The old vocabulary-app MVP public launch is paused.
- The current app becomes the Foundation Build for a world/city learning
  experience.
- Unity 6 URP is the primary game-runtime direction for Talvori Welt.
- The first Unity prototype is built as a separate project/repository after
  documentation approval, not inside this Flutter Foundation Build by default.
- Flutter is frozen as the existing domain/app reference for learning,
  Companion, import, words and product flows; no further Firenze Street or 3D
  world art is built in Flutter/Flame without a dedicated legacy gate.
- The public product should communicate that building creates context, learning
  uses context, and language grows from words into sentences, pronunciation and
  conversations.

## Work Protocol

- Work in large but controlled blocks.
- First analyze, then implement.
- Planning and review blocks may be docs-only.
- Each implementation block must have:
  - goal
  - non-goals
  - planned files/areas
  - tests/checks
  - `git status`
  - commit and push if appropriate and explicitly requested
- Do not change production data as part of planning blocks.
- Do not write Supabase data without explicit approval.
- Do not run imports without explicit approval.
- Do not touch SQLite vocabulary data, SRS data or `word_progress` unless a
  block explicitly asks for it and includes tests/migration safety.
- Do not commit secrets, keystores, certificates, provisioning profiles,
  passwords or generated release artifacts.
- If a rule becomes too complex, propose a simpler safer alternative.

## Primary Product Documents

For non-trivial Talvori work, AGENTS.md is only the short constitution. Load the
relevant product docs before deciding:

- `docs/world_design/442-talvori-unity-modular-district-platform-decision.md`
- `docs/world_design/443-p02-vertical-slice-and-online-foundation-roadmap.md`
- `docs/world_design/talvori_game_bible.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- the latest relevant slice, gate or decision docs for the affected topic.

## Short Prompt Rule for Talvori World Slices

Short prompts are preferred when they clearly name the slice type, goal,
expected files or file scope, special boundaries and commit status. The prompt
does not need to repeat every standing rule from AGENTS.md, 328, 336 or the
relevant gates.

For every Talvori World, Island, Map, Build or Italy slice, Codex must do the
missing routing work itself:

- read `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`,
- read `docs/world_design/336-documentation-map-and-slice-reading-rules.md`,
- read the mandatory documents named there for the affected slice type,
- name affected M16T IDs when they matter,
- check stop rules and scope boundaries,
- run the appropriate status, diff and scope checks,
- provide a concise Abschlussbericht.

For Italy slices, these documents are currently leading whenever Italy shape,
blockout, greybox, paths, water, buildable areas or technical layers are
affected:

- `docs/world_design/404-italy-prototype-production-plan.md`,
- `docs/world_design/405-italy-shape-source-of-truth-gate.md`,
- `docs/world_design/406-italy-working-contour-visual-gate.md`,
- `docs/world_design/previews/italy_shape_working_contour/`.

Avoid documentation loops. Once the repo has enough gate context to move
visually or technically, prefer the next productive slice inside the approved
boundaries: only as much documentation as needed, visible result when useful,
greybox or preview before long theory, and code only when a slice explicitly
opens the code scope.

Current Italy world path:

```text
Italy working contour -> macro blockout with paths, water and buildable areas
-> technical layers/masks -> game-like greybox -> later interaction
```

## Reuse-before-build Rule

Before expensive custom World, Map, Flutter, Game Asset or Visual slice work,
Codex should briefly check whether suitable open foundations already exist.
Examples include Flutter packages, open SVG/vector data, Natural Earth,
OpenGameArt, GitHub repositories, Figma/design resources and licensed or
appropriate toolchains.

The result must be reported: what was checked, whether it is suitable, license
risk, and the decision to reuse, adapt or build in-house.

Do not import or copy external assets, code or data before license,
attribution, commercial usability and Talvori repo boundaries are checked.
Reuse is welcome only when it fits Talvori's game feel, license requirements
and technical architecture.

## Context Loading and Decision Rules

- First identify affected areas: world design, learning logic, reward,
  onboarding, UI/UX, assets/animation, visual docs, content/import/translation,
  DeepL/KI/Companion, data/storage, Supabase, SQLite, SRS, `word_progress` and
  app architecture.
- Do not rely only on AGENTS.md when a task touches specialized product docs.
- Read relevant docs and feature folders before changing files.
- Stop and report conflicts between AGENTS.md, Game Bible, M16 docs, code or
  user instructions.
- For visual, flow, world, UI and architecture tasks, decide whether PNG, SVG,
  preview, screenshot or diagram verification would reduce risk.
- Do not implement directly if SRS, `word_progress`, SQLite, Supabase,
  category extensibility, Visual-QA or the Talvori Welt direction could be
  harmed.

## Core Talvori Design Rules

Core formula:

```text
Building creates context.
Learning uses context.
Language grows from words into sentences, pronunciation and conversations.
```

- Internal Corpus Primary Rule: Talvori must work with curated internal
  content; user imports are optional personal additions.
- Construction Without Lexical Gate Rule: world building must not require that
  every visible object word has already been learned.
- Context Before Vocabulary Rule: scenes, objects and actions create meaning
  before vocabulary is formally practiced.
- Object-Anchor Rule: language anchors attach to objects, rooms, scenes,
  containers, signs, dialogue or Companion moments.
- Known Word Escalation Rule: already-known words should escalate into
  phrases, listening, speaking, dialogue or richer context, not obvious basics.
- Speakability Rule: Talvori should grow toward saying, hearing and using
  language, not just recognizing cards.
- Companion-Guided Language Rule: Tali/Vori may guide, adapt, model and
  correct language, but must stay bound to scene, level and known content.
- Optional Capture Rule: captured/imported/shared words are personal optional
  discoveries, not the only source of world or language progress.

## Language Layer Rules

- World progress and language progress are separate systems.
- The visible world is the context layer.
- Each target language has its own language layer/profile.
- Normal gameplay uses one active target language.
- Do not freely mix multiple target languages in normal gameplay.
- UI language, target language and Companion language are separate choices.
- Use a Language Passport/profile per target language.
- The same world object may carry several language anchors across languages.
- Beginners, advanced users and very advanced users need different scaffolding.
- Advanced users must not be forced through obvious basics like hello, home,
  door or window.

## Automatic Plugin and Skill Routing

Codex should proactively use available plugins, MCP connectors and local skills
when they fit the task. The user should not need to remind Codex to use Browser,
Figma, Supabase, GitHub, documents, design or analysis tools. If a named tool is
not available in the current session, Codex should say so briefly and continue
with the safest local fallback.

General rules:

- Use plugins and skills for analysis, verification and artifact quality when
  they reduce risk or improve the result.
- Prefer read-only or local-preview use by default.
- Ask for explicit approval before any plugin writes to external services,
  production data, cloud projects, issue trackers, design files, hosting,
  analytics, error monitoring, API keys or databases.
- Supabase writes, local/remote production data changes, SQLite vocabulary
  data changes, SRS or `word_progress` changes and API-key creation,
  rotation, deletion or storage are allowed only after explicit approval.
- For visual tasks, always consider whether a PNG, SVG, preview, screenshot,
  diagram, contact sheet or browser verification would make the work safer or
  clearer.
- Codex prompts should name goals, files, checks and stop rules instead of
  hard-coding git command recipes. Codex is responsible for running the
  appropriate `git status`, diff, scope and verification commands.
- Do not use plugin output as a production source of truth without checking it
  against repository rules and the relevant Talvori docs.

| Plugin / Skill | Use When | Do Not Use When | Write Permission |
| --- | --- | --- | --- |
| Browser / `browser:browser` | Inspecting local previews, localhost UI, rendered pages, screenshots, responsive layout and visual QA. | The task is docs-only and no visual/runtime check is needed. | Local navigation/screenshots are okay; no external account actions without approval. |
| Documents | Creating, editing, rendering or verifying `.docx`, Word-style docs or long formatted document artifacts. | Plain Markdown in the repo is enough. | Writing repo docs is okay when requested; external document sync needs approval. |
| Presentations | Building or reviewing decks, pitch material, roadmap slides or visual strategy presentations. | A short Markdown summary is enough. | Local deck files only unless external publish/share is approved. |
| Spreadsheets | CSV/XLSX analysis, planning matrices, backlogs, dashboards or structured calculations. | A simple Markdown table is enough. | Local files only unless external sheet sync is approved. |
| `imagegen` | Generating or editing bitmap visuals, concept art, mood images, game mockups, textures or illustrative references. | Repo-native SVG/CSS/Flutter drawing is more appropriate, or no visual asset is needed. | Generated images must not enter `assets/` or product code without explicit asset-scope approval. |
| `openai-docs` / OpenAI Developers | OpenAI API, model, SDK, key, prompt or platform questions requiring current official docs. | The task is unrelated to OpenAI platform usage. | API-key creation, storage, rotation or deletion needs explicit approval. |
| `plugin-creator` | Designing or scaffolding a Codex plugin. | A normal repo change or skill proposal is enough. | Creating plugin files only when requested; installation/publishing needs approval. |
| `skill-creator` | Designing or updating a Codex skill such as a Talvori workflow skill. | The need is one-off and can stay in AGENTS.md. | Create/update skill files only after explicit approval. |
| `skill-installer` | Listing or installing curated/external Codex skills. | The user only asks for a proposal. | Installation always needs explicit approval. |
| GitHub | Reading repo issues, PRs, checks, branches or release context; preparing PR text. | Local git/repo context is enough. | Creating/updating issues, PRs, branches, reviews or comments needs approval. |
| Notion | Reading or drafting product docs, specs, tasks or decision logs stored in Notion. | Repo docs are the source of truth for the task. | Creating/updating pages or databases needs approval. |
| Linear | Reading or drafting issue/roadmap/task context. | The task is fully local or docs-only. | Creating/updating issues, status, comments or assignments needs approval. |
| Figma | Reading designs, creating UI mockups, syncing screens, inspecting visual specs or preparing editable design work. | Flutter/CSS/code inspection is enough. | Editing Figma files or publishing design changes needs approval. |
| Canva | Creating marketing/social visuals or editable brand materials. | Product UI, repo-native diagrams or Figma is more suitable. | Creating/updating shared Canva designs needs approval. |
| Shutterstock | Searching licensed stock images, video, music or SFX candidates. | Placeholder/local/generated visuals are enough. | Downloads, licensing or asset addition needs approval. |
| PostHog | Analytics planning, event taxonomy review or reading existing product analytics. | No analytics question is involved. | Creating/updating events, dashboards, feature flags or data exports needs approval. |
| Game Studio | Game-feel prototyping, mechanics exploration or playable concept planning. | Existing Flutter/local preview work is enough. | Generated production assets or project changes need approval. |
| Sentry | Reading error reports, release health or crash context. | Local analyzer/test output is enough. | Changing projects, alerts, releases, issue state or DSNs needs approval. |
| CodeRabbit | PR/code review assistance and review summaries. | No PR/review context exists or local review is enough. | Posting reviews/comments or changing PR state needs approval. |
| Hostinger | Hosting, domain, deployment or public site operations. | Work is local preview or repo-only. | Deploys, DNS, hosting config or billing changes need approval. |
| Supabase | Reading schema, policies, logs or planning backend/data changes. | Local docs/code answer the question. | Any write, migration, SQL mutation, auth/storage change, Edge Function deploy or production data access/change needs explicit approval. |
| Codex Security | Security review, dependency risk, secret scanning, auth/data boundary review or threat modeling. | The task has no security/privacy surface. | Remediation writes are local only unless separately approved; external security system changes need approval. |

Plugins that should normally be analysis/planning-only unless explicitly
approved to write: GitHub, Notion, Linear, Figma, Canva, Shutterstock, PostHog,
Game Studio, Sentry, CodeRabbit, Hostinger, Supabase, OpenAI Developers and
Codex Security.

### Proposed Talvori Skill

A dedicated Codex skill named `talvori-development-orchestrator` would be
useful, but it should not be installed or scaffolded until explicitly approved.

Suggested purpose:

- Load Talvori's strategic direction, stop rules, M16 documentation workflow
  and plugin-routing policy.
- Decide which docs, skills, plugins and checks are required for a requested
  slice.
- Enforce no-write boundaries for Supabase, SRS, `word_progress`, API keys,
  app integration, routes, assets and production data.
- Suggest whether a task should be Code, Docs-Gate, Visual-Gate, Review,
  Research or Commit/PR work.
- Produce standard Abschlussbericht sections for Talvori slices.

Suggested structure:

```text
talvori-development-orchestrator/
  SKILL.md
  references/
    talvori_stop_rules.md
    m16_slice_type_routing.md
    plugin_routing.md
    report_templates.md
  scripts/
    optional_check_scope.sh
```

Suggested `SKILL.md` content:

- when to use the skill,
- required first checks,
- Talvori slice-type decision tree,
- required docs per slice type,
- plugin/skill routing table,
- write-permission rules,
- standard checks,
- final-report template,
- escalation rules for blocked or risky work.

## Product Rules

- The current Home screen becomes the **Talvori-Welt-Zentrale**.
- Keep and strengthen the dark space/neon look.
- Keep top status elements where useful.
- Remove or strongly reduce the upper image frame.
- The old Play button must no longer be the main action.
- A large rotating/pulsing globe becomes the central action.
- Tapping the globe should later lead to a region/city/world prototype.
- The Home-Zentrale currently uses one central Plus-Hub at the bottom. Closed
  state shows only the Plus. Open state reveals an icon-only rotating wheel with
  Chat/Friends, Profile, Learn, Words/Import, Satzfunken/Tagesimpuls, Games,
  World/Hub and Progress/Stats so the globe stays the visual hero.
- Tali or Vori is the selected active Companion, not two permanent parallel
  systems.
- Companion tap flow: small avatar -> focus/bubble -> Companion chat sheet.
- Human chat/friends stays separate from Tali/Vori Companion chat.
- Learning must visibly build the world.
- The Reward Bridge connects learning results to world resources without
  corrupting existing SRS or `word_progress`.
- The public world stays beautiful. Private learning overlays may show fog,
  repair, comeback or soft-reminder states.
- Social starts with friends, reactions and showcase, not global public chat.
- Monetization must not block the first wow moment.

## Architecture Rules

- Keep learning logic, world logic, Companion logic, social logic and rendering
  separated.
- Unity 6 URP is the primary runtime direction for game-world exploration,
  district scenes, 3D characters, camera, NavMesh, prefabs, Addressables and
  world QA.
- Do not create or modify a Unity project before the relevant documentation,
  repository and implementation gates are approved.
- The Unity prototype starts as a separate project/repository.
- Flutter remains the Foundation Build and domain/app reference, not the
  primary runtime for new Firenze Street or 3D world art.
- No further Flutter/Flame Firenze-Street-/3D-World-Art-Code without a named
  Flutter Legacy Gate.
- Firenze Overview remains a map/orientation layer. Playable districts are
  separate Unity scenes.
- P02 is the first Unity vertical slice.
- Cities are modular, separately loadable district scenes.
- Districts are mostly prebuilt; player changes happen through fixed build and
  upgrade slots.
- Do not build a free city builder for the MVP.
- Do not build a seamless MMO or globally freely buildable world.
- Use an asset-kit-first environment strategy. A coherent kit should provide
  most visible city structure before bespoke object generation fills gaps.
- Meshy and Sloyd may provide Talvori-specific special objects and variants,
  not complete city topology.
- Codex is the Technical Environment Assembler: import, prefabs, editor
  scripts, scale, pivots, NavMesh, colliders, Addressables, configuration,
  builds and QA.
- Codex is not an autonomous art director and must not assemble final city art
  from primitives as a production solution.
- Adventure Creator is optional for dialogue, hotspots, cutscenes and local
  adventure flow, but it is not source of truth for learning, quest, build,
  online or world state.
- Online code waits until a local P02 Unity slice works.
- Online services must be abstracted behind Talvori-owned interfaces. UGS and
  Nakama remain provider candidates until a comparison gate.
- Chat requires auth, moderation, block and report gates before product use.
- Cloud is later; local prototype first.
- AI may generate sentences, explanations and action suggestions.
- Deterministic app/backend logic controls rewards, ownership, premium and
  saved world state.
- UI knows no Supabase RPC details and no database internals.
- SRS/learning logic remains testable domain logic.
- SQLite access remains in the data layer.
- Do not mutate existing SRS or `word_progress` semantics without a dedicated
  migration plan and tests.
- Do not directly couple learning logic into the renderer.
- Supabase remains strategically important, but no Supabase writes are allowed
  without explicit approval.

## Foundation Build / Legacy App Roadmap

This roadmap describes Foundation-Build, legacy app and product-flow ideas that
remain valuable as reference material. It is not the primary Unity game-runtime
roadmap. For the primary Unity/P02 game-runtime sequence, follow
`docs/world_design/442-talvori-unity-modular-district-platform-decision.md` and
`docs/world_design/443-p02-vertical-slice-and-online-foundation-roadmap.md`.
No new Firenze Street or 3D world work should be built in Flutter/Flame without
a named Flutter Legacy Gate. Unity P02 gates G1-G10 in `443` lead the new
game-runtime order.

### Phase 0: Foundation Sichern

- Preserve current learning, word, import, translation, Companion and game
  foundations.
- Reorient docs and planning around Talvori Welt.
- Keep old release/store work as future compliance and Foundation Build
  material.

### Phase 1: Home-Zentrale

- Build the Talvori-Welt-Zentrale.
- Add rotating/pulsing globe as main action.
- Keep top status where useful.
- Use the globe itself for World entry.
- Use the bottom Plus-Hub wheel for Learn, Words/Import, Games,
  Satzfunken/Tagesimpuls, Chat/Friends, Profile, World/Hub and Progress/Stats.
- Avoid a permanent bottom bar in the current Home direction; closed state
  should stay visually quiet with the central Plus only.
- Add selected Companion states and tap flow.

### Phase 2: Local World Entry

- Local region entry.
- One user plot.
- A few example plots.
- Three buildings: house, market, library.
- Three levels each.
- Terrace/forecourt and pond/tree group.
- Local save only.

### Phase 3: Reward Bridge

- Existing exercise completion emits a `LearningResult`.
- Reward Bridge maps results to resources.
- Resources visibly grow buildings or unlock build options.
- Existing SRS/`word_progress` semantics remain unchanged.

### Phase 4: Import/DeepL/KI Sparks

- Web import, DeepL translation and AI sentence sparks become world/Companion
  quest material.
- 3-5 collected words can create one sentence spark or mini quest.

### Phase 5: Social Minimum

- Prepare friends, showcase and reactions.
- Keep human chat separate from Companion chat.
- No full social backend until the local wow moment works.

Cloud, chat sync and monetization come only after the local wow moment.

## Anti-Goals / Not Now

- No old public vocabulary MVP launch.
- No global public chat in V1.
- No GPS-based user location.
- No real-money plot auctions.
- No pay-to-win.
- No loot boxes.
- No 3D Minecraft clone.
- No public ugly decay or ruin punishment.
- No direct coupling of learning logic into renderer.
- No Supabase writes without explicit approval.

## Existing Foundation Rules That Still Matter

- Flutter/Dart is the app technology.
- Offline-first remains important.
- Local data and user progress must be protected.
- Existing UI, engine and database boundaries should stay separated.
- Existing debug/admin/import paths should remain protected from release users.
- Existing release/store/legal/data-safety work is preserved as future
  compliance material.
