# M16-R: Scalable Word Semantics Architecture Plan

Stand: 2026-06-07

Status: `Architekturplanung/Visualisierung gestartet / keine Implementierung`

## 1. Ziel

M16-R klaert, dass `WordSemanticsDecisionPreview` mit acht Beispielwoertern
nur ein lokaler Architektur-Prototyp ist. Die Preview macht Guardrails
sichtbar, ist aber nicht die spaetere Wortverwaltung fuer tausende oder
20.000+ Woerter.

M16-R ist nur Dokumentation und Visualisierung. Daraus folgen keine Flutter-/
Dart-Dateien, keine App-Integration, keine Route, keine neue Seite, keine
Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine
Supabase Writes, keine lokalen DB-Writes, keine SRS-/`word_progress`-
Aenderung, keine Reward Bridge, keine automatische Wortplatzierung, keine
Build-Wheel-Implementierung, keine Assets, keine Asset-Dateien unter
`assets/`, kein Build-State, kein `frame_started` und keine Bauzustaende.

## 2. Gepruefte Grundlage

| Dokument | Bedeutung fuer M16-R |
| --- | --- |
| `docs/world_design/325-word-semantics-preview-implementation-prompt-draft.md` | Dokumentiert den freigegebenen Mini-Slice als isolierte Preview, nicht als Massensystem. |
| `docs/world_design/324-word-semantics-preview-implementation-gate.md` | Gate: spaeterer Code-Slice war nur lokal und minimal. |
| `docs/world_design/323-word-semantics-decision-preview-scope.md` | Definiert die Beispielwort-Pipeline und sichere Ausgaenge. |
| `docs/world_design/322-next-safe-preview-slice-decision-gate.md` | Empfiehlt Semantics Preview, um automatische Wortplatzierung zu verhindern. |
| `docs/world_design/321-global-world-semantics-consistency-audit.md` | Pflichtfilter fuer Context/Sense, Word-Type, Safety, Representation Decision und User Choice. |
| `docs/world_design/270-word-to-island-routing-matrix.md` | Routing macht Vorschlaege; Codex, Blueprint und Backlog sind legitime Ausgaenge. |
| `docs/world_design/272-plot-capability-derivation.md` | Plot-Capabilities sind Erlaubnisse, keine Pflichtbelegung. |
| `docs/world_design/274-sensitive-content-representation-rules.md` | Sensitive/abstract Begriffe brauchen neutrale Fallbacks und Policy Gates. |
| `docs/world_design/276-mobile-clutter-rules-small-objects.md` | TinyObjects und ContainerItems duerfen nicht dauerhaft in IslandView landen. |
| `docs/world_design/284-word-to-island-ux-flow.md` | User Choice, Sense und sichere Fallbacks stehen vor sichtbarer Platzierung. |
| `docs/world_design/235-world-production-roadmap-and-checklists.md` | Roadmap-Stop-Regeln gegen Code, Assets, Persistenz und `frame_started`. |
| `assets/images/world/buildable_islands/forest_clearing/template.md` | Waldlichtung/Previews bleiben Starter-/Testformen ohne Asset-/Appfreigabe. |

## 3. Zentrale Skalierungsregel

Nicht:

```text
20.000 Woerter -> 20.000 sichtbare Weltobjekte
```

Sondern:

```text
20.000 Woerter
-> 20.000 moegliche Semantic Profiles
-> gefilterte Vorschlaege
-> nur relevante Entscheidungen sichtbar
```

Kernprinzipien:

- Jedes Wort kann ein internes Semantic Profile bekommen.
- Nicht jedes Wort wird sichtbar.
- Nicht jedes Wort bekommt ein Grundstueck.
- Nicht jedes Wort wird gebaut.
- Nicht jedes Wort braucht sofort Nutzerentscheidung.
- Viele Woerter gehen in `Codex`, `Blueprint`, `Backlog`, `ContainerItem`,
  `ActionChallenge` oder `ContextCard`.
- Nur mehrdeutige, sensible, unsichere oder aktuell relevante Woerter werden
  aktiv als Entscheidung gezeigt.
- Sichtbare Weltobjekte bleiben stark begrenzt und kuratiert.

## 4. `WordSemanticProfile` als spaeteres Konzept

`WordSemanticProfile` ist in M16-R nur ein Konzept. Es ist keine finale
Datenstruktur, keine Runtime-Konfiguration und keine Persistenzfreigabe.

Planungsfelder:

| Feld | Zweck |
| --- | --- |
| `wordId` | Verweis auf das Wort, keine neue Persistenzfreigabe. |
| `normalizedText` | Normalisierte Schreibweise fuer Vergleich und Suche. |
| `language` | Sprache des Wortes. |
| `wordType` | Nomen, Verb, Adjektiv, Emotion, Abstract, Sensitive, TinyObject usw. |
| `senseCandidates` | Moegliche Bedeutungen oder Kontexte. |
| `primarySense` | Spaeter optionaler aktueller Favorit, nicht automatisch final. |
| `themeIslandCandidates` | Moegliche ThemeIslands, keine feste Zuordnung. |
| `plotFamilyCandidates` | Moegliche Plot-Familien, nur Kandidaten. |
| `depthCandidates` | IslandView, Plot, Interior, Container, Detail, Codex usw. |
| `representationCandidates` | PlacementCandidate, Blueprint, Codex, Backlog, ContextCard, ActionChallenge, ContainerItem. |
| `safetyFlags` | Hinweise fuer Sensitive, Safety, Water, Medical, Public Institution usw. |
| `clutterRisk` | Risiko fuer Mobile-/TinyObject-Clutter. |
| `sensitiveRisk` | Risiko fuer sensible oder persoenliche Inhalte. |
| `multiHomeRisk` | Risiko, dass ein Wort mehrere Theme-Kontexte hat. |
| `requiresUserChoice` | Ob aktive Nutzerentscheidung noetig ist. |
| `confidence` | Planungswert fuer Sicherheit der Vorschlaege. |
| `status` | Bearbeitungs-/Routingstatus. |
| `source` | Import, manuelle Eingabe, DeepL, KI-Spark oder anderes. |
| `lastReviewedAt` | Spaeterer Review-Zeitpunkt, nicht in M16-R umgesetzt. |
| `userDecision` | Spaetere Nutzerentscheidung, nur nach eigenem Gate. |
| `fallbackTarget` | Sicherer Ausgang: Codex, Blueprint, Backlog, ContextCard usw. |

## 5. Statuswerte fuer viele Woerter

Planungsstatuswerte:

| Status | Bedeutung |
| --- | --- |
| `unprocessed` | Wort ist aufgenommen, aber noch nicht klassifiziert. |
| `auto_profiled` | Automatische Analyse hat ein internes Profil vorbereitet. |
| `needs_context` | Satz, Nutzerziel oder Sense fehlt. |
| `needs_user_choice` | Nutzerentscheidung ist noetig, bevor sichtbar vorgeschlagen wird. |
| `safe_codex` | Sicherer Codex-/Erklaerweg, keine sichtbare Platzierung. |
| `blueprint_candidate` | Spaetere Planung moeglich, aber kein Bauzustand. |
| `placement_candidate` | Sichtbare Option nur nach Kontext und User Choice. |
| `container_candidate` | Eher Container/Depth statt IslandView. |
| `action_candidate` | Verb/Aktion, eher Challenge/Sequenz/ContextCard. |
| `sensitive_gated` | Sensitive-/Policy-Gate erforderlich. |
| `clutter_gated` | Mobile-/Clutter-Gate erforderlich. |
| `backlog` | Warten auf Kontext, Insel, Depth, Gate oder Nutzerentscheidung. |
| `blocked_until_rules` | Blockiert bis eigene Regeln definiert sind. |
| `user_confirmed` | Nutzer hat spaeter eine Entscheidung bestaetigt. |
| `discarded_or_hidden` | Nicht aktiv anzeigen, aber optional intern behalten. |

## 6. Batch-/Pipeline-Logik

Spaetere Pipeline als Planungsmodell:

```text
Word intake
-> Normalize
-> Basic word type classification
-> Sense / context candidates
-> Safety / sensitive check
-> ThemeIsland candidate scoring
-> Plot / depth candidate scoring
-> Representation candidate scoring
-> Confidence decision
-> Auto-safe fallback or user choice queue
-> Preview / decision only when needed
-> Later gate before placement / build / persistence
```

Wichtig:

- Automatische Analyse darf nur Vorschlaege vorbereiten.
- Automatische Analyse darf nicht sichtbar platzieren.
- Automatische Analyse darf keinen Build-State erzeugen.
- Automatische Analyse darf kein `frame_started` erzeugen.
- Automatische Analyse darf keine Assets erzeugen.
- Automatische Analyse darf keine Persistenz oder Runtime-Konfiguration
  freigeben.

## 7. Nutzer-UI-Strategie fuer grosse Wortmengen

Nicht:

- Liste mit 20.000 Entscheidungen,
- 20.000 sichtbare Karten,
- 20.000 Island-Objekte,
- 20.000 Grundstuecke oder Gebaeude.

Sondern:

- Inbox fuer neue oder unklare Woerter,
- kleine Review-Queue,
- Filter nach Risiko:
  - Multi-Home,
  - Sensitive,
  - Clutter,
  - Action,
  - Container,
  - Blueprint,
  - Backlog,
- Tali/Vori schlaegt nur relevante Entscheidungen vor,
- Nutzer kann spaeter aendern,
- Safe Defaults:
  - `Codex`,
  - `Backlog`,
  - `Blueprint`,
  - `ContextCard`,
- Bulk/Batch nur fuer sichere Gruppen, nie fuer sichtbare Platzierung.

## 8. Planungsannahmen fuer Schwellenwerte

Diese Zahlen sind Annahmen, keine finalen Runtime-Werte:

| Annahme | Konsequenz |
| --- | --- |
| 20.000 Woerter koennen im System existieren. | Profile/Queues statt 20.000 Karten. |
| Viele Woerter bleiben Codex/Backlog. | Sichtbare Welt bleibt kuratiert. |
| Sichtbare Weltobjekte pro Insel bleiben stark begrenzt. | Keine Objektflut und kein Mobile-Clutter. |
| Pro Screen gibt es nur wenige aktive Fokusobjekte. | Device-/Accessibility-Pruefung bleibt machbar. |
| Pro Session erscheinen nur wenige Semantikentscheidungen. | Nutzer wird nicht mit Review-Arbeit ueberladen. |
| Sensible/mehrdeutige Woerter bleiben immer gated. | Keine automatische Visualisierung. |
| TinyObjects gehen meistens in Container/Codex/Backlog. | IslandView bleibt lesbar. |

## 9. Verhaeltnis zur bestehenden Preview

`WordSemanticsDecisionPreview` ist ein Mini-Prototyp mit acht Beispielwoertern:
`Haus`, `Garage`, `Baum`, `schwimmen`, `Angst`, `lernen`, `Messer` und
`Polizei`.

Die Preview beweist:

- Context/Sense muss sichtbar vor Kategorie stehen.
- Word-Type unterscheidet Nomen, Verb, Emotion, TinyObject und Sensitive.
- Sichere Ausgaenge wie `Codex`, `Blueprint`, `Backlog`, `ContextCard`,
  `ActionChallenge` und `ContainerItem` sind normale Ergebnisse.
- Guardrails gegen Speicherung, Platzierung, Build-State und automatische
  Wortplatzierung koennen in der UI sichtbar sein.

Die Preview beweist nicht:

- Massendatenverwaltung,
- finale Datenstruktur,
- Persistenz,
- Performance,
- AI-/Classification-Provider,
- User Review Queue,
- App-Integration.

Spaeter braucht das System Semantic Profiles, Queues, Filter, Fallbacks,
Batch-Verarbeitung und eigene Gates. Die aktuelle Preview bleibt trotzdem
wichtig, weil sie Fehlableitungen sichtbar macht.

## 10. Architektur-Gates vor echter Umsetzung

Vor echter Massensemantik braucht es eigene Gates fuer:

- Datenmodell,
- Speicherung/Persistenz,
- lokale DB/Supabase,
- Migration,
- Performance,
- Offline-Strategie,
- AI/Classification Provider,
- Confidence Scoring,
- User Review Queue,
- Privacy,
- Sensitive Review,
- App-Integration,
- Testing,
- Device/Accessibility,
- Import-Workflow,
- Sync-Konflikte,
- Undo/Aenderbarkeit,
- keine automatische Platzierung.

## 11. Dokumentationsvisualisierungen

M16-R ergaenzt echte PNG-Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_r_scalable_word_semantics_architecture/`

Erzeugte Visuals:

- `01_many_words_to_semantic_profiles_pipeline.png`
- `02_word_profile_status_lifecycle.png`
- `03_mass_word_ui_strategy.png`
- `04_allowed_vs_blocked_scalable_semantics_scope.png`
- optional `00_contact_sheet.png`

Diese PNGs sind Dokumentationspreviews. Sie sind keine Screenshots, keine
App-Screens, keine finalen UI-PNGs, keine Spielassets und keine Dateien unter
`assets/`.

Visual-Quality-Regel:

Alle M16-R-Visuals muessen Text-Containment, Innenabstand, Kartenabstand,
ueberlappungsfreie Karten, Labels, Pfeile, Titel, Footer und Legenden,
lesbares Contact Sheet sowie nicht abgeschnittene Inhalte pruefen.

## 12. Stop-Regeln

Aus M16-R folgt ausdruecklich:

- Keine Implementierung.
- Keine Flutter-/Dart-Dateien.
- Keine App-Integration.
- Keine Route.
- Keine neue Seite.
- Keine Tests und keine Widget-Tests.
- Keine Screenshots.
- Keine Runtime-Konfiguration.
- Keine Persistenz.
- Keine Supabase Writes.
- Keine lokalen DB-Writes.
- Keine SRS-/`word_progress`-Aenderung.
- Keine Reward Bridge.
- Keine automatische Wortplatzierung.
- Keine Build-Wheel-Implementierung.
- Keine Assets.
- Keine Asset-Dateien unter `assets/`.
- Kein Build-State.
- Kein `frame_started`.
- Keine Bauzustaende.
