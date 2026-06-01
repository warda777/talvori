# AGENTS.md

## Current Strategic Direction

Talvori is now oriented around **Talvori Welt**.

The old public launch path as a normal vocabulary-app MVP is paused and
superseded. The existing app is the **Foundation Build** for Talvori Welt, not
throwaway work. Words, word worlds, learning mode, word games, AI/Companion
paths, DeepL/translation logic, share/import, Tali/Vori, Tagesimpuls, profile,
stats and chat paths remain valuable.

Product north star:

> Sammle Woerter aus der echten Welt. Lerne sie im Kontext. Baue deine Welt.
> Wachse mit Freunden.

Core direction:

- Talvori Welt is the product direction.
- The old vocabulary-app MVP public launch is paused.
- The current app becomes the Foundation Build for a world/city learning
  experience.
- The public product should communicate: **Meine Woerter bauen eine Welt.**

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
- Flutter remains the app/UI base.
- Early world prototypes may use Flutter widgets and `CustomPainter`.
- Flame, Rive, Tiled or JSON map tooling can come later if useful.
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

## Near-Term Roadmap

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
