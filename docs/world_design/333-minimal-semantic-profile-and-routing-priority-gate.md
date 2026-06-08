# M16-Y: Minimal Semantic Profile and Routing Priority Gate

Stand: 2026-06-08

Status: `Dokumentations-/Visual-Slice gestartet / keine Implementierung`

## 1. Zweck und Non-Goals

M16-Y definiert, welche minimalen Semantikdaten ein Wort im MVP als Konzept
braucht und in welcher Reihenfolge Sense, Safety, Word Type, Clutter,
Confidence, User Choice und Safe Defaults entscheiden.

M16-Y ist ein Gate. Es gibt keine Implementierung frei.

Non-Goals:

- keine Implementierung,
- keine finale Datenstruktur,
- keine App-Integration,
- keine Route,
- keine neue Seite,
- keine Persistenz,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- kein Build-State,
- kein Build-Wheel,
- keine Assets und keine Asset-Dateien unter `assets/`,
- kein `frame_started`,
- keine Bauzustaende,
- keine Tests oder Widget-Tests,
- keine Screenshots als Repo-Artefakte.

## 2. Gepruefte Grundlage

| Dokument | Bedeutung fuer M16-Y |
| --- | --- |
| `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrende M16-T-ID- und Dashboard-Liste. |
| `docs/world_design/330-minimal-playable-learning-loop-contract.md` | Minimaler Learning-to-World Contract: Lernen erzeugt Moeglichkeit, keine Platzierung. |
| `docs/world_design/331-minimal-word-outcome-detail-gate.md` | Outcome-Regeln, Queue-Ausgaenge und Reward-/BuildState-Trennung. |
| `docs/world_design/332-reward-budget-and-review-queue-control-gate.md` | Session-Budgets, Safe Defaults und Queue-Priorisierung. |
| `docs/world_design/327-talvori-learning-game-logic-readiness-review.md` | Produktive Systeme bleiben gated; lokale Gates duerfen Regeln schaerfen. |
| `docs/world_design/326-scalable-word-semantics-architecture-plan.md` | Semantic Profiles sind Konzept fuer viele Woerter, nicht 20.000 sichtbare Objekte. |
| `docs/world_design/323-word-semantics-decision-preview-scope.md` | Beispielwort-Pipeline und sichere Representation Decisions. |
| `docs/world_design/321-global-world-semantics-consistency-audit.md` | Pflichtpipeline: Context/Sense, Word Type, Safety, Representation, User Choice. |
| `docs/world_design/284-word-to-island-ux-flow.md` | UX-Routing: kein sichtbares Placement ohne Sense, Safety, Depth und Nutzerentscheidung. |
| `docs/world_design/274-sensitive-content-representation-rules.md` | Sensitive Inhalte gewinnen gegen sichtbare Platzierung und Reward-Druck. |
| `docs/world_design/276-mobile-clutter-rules-small-objects.md` | TinyObjects und ContainerItems duerfen keine Mobile-Clutter-Flut erzeugen. |

## 3. Betroffene M16-T-IDs

| ID | M16-Y Entscheidung | Grund |
| --- | --- | --- |
| `M16T-SEM-001` | `[x]` | MVP-Mindestfelder fuer ein Minimal Semantic Profile sind als Konzept definiert. |
| `M16T-SEM-002` | `[x]` | Context/Sense-Regeln, Multi-Home und Low-confidence-Fallbacks sind dokumentiert. |
| `M16T-SEM-003` | `[x]` | Word-Type-Routing fuer relevante MVP-Worttypen ist Pflichtfilter. |
| `M16T-SEM-004` | `[x]` | Konfliktprioritaeten sind verbindlich geordnet. |
| `M16T-AI-001` | `[x]` | Confidence-Bands und erlaubte Ausgaenge sind definiert. |
| `M16T-AI-003` | `[x]` | Low confidence landet in `NeedsUserChoice`, `Backlog`, `CodexOnly` oder `ContextCard`, nie in Placement. |

## 4. Minimal Semantic Profile als Konzept

Das Minimal Semantic Profile ist in M16-Y nur ein MVP-Konzept. Es ist keine
finale Datenstruktur, keine Runtime-Konfiguration und keine Persistenzfreigabe.

MVP-Mindestfelder:

| Feld | Zweck | Erlaubte Wertgruppen | Darf nicht bewirken | Spaetere Gates |
| --- | --- | --- | --- | --- |
| `wordId` oder `localWordRef` | Verweis auf vorhandenes Wort oder lokale Preview-Referenz. | vorhandene ID, lokale Referenz, leer bei reiner Beispielkarte | neue Persistenz, DB Write, SRS-Mutation | Datenmodell, Privacy |
| `normalizedText` | Vergleichbare Schreibweise fuer Semantikpruefung. | normalisierte Textform | finale Suche/Indexierung als Produktentscheidung | Datenmodell, Import |
| `displayText` | Nutzerlesbarer Worttext. | Originalwort oder sichere Anzeigeform | finale UI/Copy-Freigabe | UX, Accessibility |
| `language` | Sprache des Wortes. | Sprachcode oder "unknown" | automatische Translation/Provider-Aufruf | AI/Provider, Privacy |
| `contextHint` | Satz, Quelle, Nutzerziel oder kurzer Kontext. | none, sentence, userGoal, importSource, companionHint | Speicherung privater Saetze ohne Gate | Privacy, Persistence |
| `primaryWordType` | Erster Worttypfilter. | noun, verb, adjective, emotion, abstract, tinyObject, institution, placeBuilding, processEvent, unknown | direkte ThemeIsland- oder Plot-Zuordnung | Semantik, Confidence |
| `senseStatus` | Klarheit der Bedeutung. | clear, multiHome, ambiguous, contextMissing, userNeeded, unknown | Default-Sense als finale Platzierung | Review Queue, Undo |
| `safetyStatus` | Sensitive-/Safety-Lage. | clear, sensitive, safetyReview, policyGated, unknown | Safety durch Reward oder User Choice ueberstimmen | Sensitive, Privacy |
| `clutterRisk` | Mobile-/TinyObject-Risiko. | low, medium, high, unknown | sichtbare Platzierung erzwingen | Mobile, Depth |
| `confidenceBand` | Sicherheit der Klassifikation. | high, medium, low, unknown | automatische Platzierung oder Persistenz | AI Governance |
| `candidateOutcomes` | Sichere moegliche Ausgaenge. | CodexOnly, WorldCandidate, ContainerItem, ActionChallenge, ContextCard, SensitiveGated, NeedsUserChoice | BuildState, Asset, Route | Outcome, Queue |
| `selectedOutcome` | Aktueller MVP-Ausgang. | einer der MVP-Outcomes oder none | irreversible Entscheidung | Undo, Persistence |
| `requiresUserChoice` | Ob Review noetig sein kann. | yes, no, maybe | Pflichtentscheidung oder Review-Spam | Queue Budget |
| `fallbackTarget` | Sicherer Ausgang, wenn nicht weltreif. | CodexOnly, Backlog, ContextCard, Later, Hide, ContainerItem, SensitiveGated | versteckte Platzierung | Safe Defaults |
| `reviewEligibility` | Ob eine Queue-Karte ueberhaupt erscheinen darf. | eligible, budgetBlocked, safeDefault, sensitiveBlocked, lowPriority | Entscheidung nach jedem Wort | Queue Budget |
| `notes` / `explanation` | Kurze menschliche Begruendung. | knappe Guardrail-Erklaerung | Companion-Beratung, Druck oder sensitive Dramatisierung | Companion Copy, Safety |

## 5. Feldregeln

| Feldgruppe | Wann benoetigt | Pflichtregel | Nicht erlaubt |
| --- | --- | --- | --- |
| Identitaet und Anzeige | jedes Wort oder jede Beispielkarte | nur Verweis/Anzeige, keine neue Datenhaltung | DB Write, Migration, SRS-Aenderung |
| Kontext und Sense | sobald ein Wort mehrdeutig, multi-home, sensibel oder weltreif wirkt | Kontext schlaegt Oberflaeche | Default-Sense als finale Platzierung |
| Word Type | vor ThemeIsland, Plot oder Outcome | Worttyp bestimmt erlaubte Outcome-Familien | Ein-Weg-Routing fuer alle Woerter |
| Safety | vor Reward, Weltfeedback, Theme/Plot und User Choice | Safety gewinnt gegen Weltwunsch | User Choice ueberstimmt Safety |
| Clutter | vor sichtbarem Weltfeedback | Mobile und Depth gewinnen gegen sichtbare Kleinteile | TinyObject in IslandView |
| Confidence | vor Review und Vorschlag | Low/unknown confidence geht in Safe Default oder Queue | PlacementCandidate, BuildState, Persistenz |
| Outcomes und Fallbacks | bei jedem Semantikereignis | Safe Defaults bleiben normale Ausgaenge | Build, Route, Asset |
| Review Eligibility | nur wenn Budget, Relevanz und Risiko passen | wenige Entscheidungen, Later immer erlaubt | Pflichtreview, 20.000-Wort-Inbox |

## 6. Context/Sense-Regeln

Pflichtregeln:

- Kontext schlaegt Oberflaeche.
- Ein Wort ohne klaren Sense darf nicht sichtbar platziert werden.
- Multi-Home-Woerter gehen in `NeedsUserChoice` oder `ContextCard`.
- Low confidence geht in `Backlog`, `CodexOnly`, `NeedsUserChoice` oder
  `ContextCard`.
- Kein Default-Sense darf eine finale Platzierung, Persistenz oder
  `BuildState` erzeugen.
- Nutzerziel ist ein Signal, aber kein Safety-Override.
- Satzkontext darf nur nach Privacy-/Persistence-Gate dauerhaft gespeichert
  werden.

Beispiele:

| Wort | Sense-Problem | Sicherer MVP-Ausgang |
| --- | --- | --- |
| `Haus` | Zuhause, Stadt, Land/Farm, Kueste/Strand | `NeedsUserChoice`, spaeter `WorldCandidate` nur nach Gate |
| `Bank` | Sitzbank, Geldinstitut, Flussufer | `NeedsUserChoice` oder `ContextCard` |
| `Schluessel` | TinyObject, Symbol, Zugang/Sequence | `ContainerItem`, `ContextCard` oder `Backlog` |
| `Polizei` | Institution, Sicherheit, sensitive/public | `SensitiveGated`, `ContextCard`, `CodexOnly` |

## 7. Word-Type-Routing

| Word Type | Bevorzugte Outcomes | Blockierte Outcomes | Beispiele |
| --- | --- | --- | --- |
| Nomen | `WorldCandidate`, `ContainerItem`, `CodexOnly`, `NeedsUserChoice` je nach Groesse/Sense | automatisches Placement, BuildState | `Haus`, `Baum`, `Garage` |
| Verb / Aktion | `ActionChallenge`, `ContextCard`, `CodexOnly`, `Backlog` | statisches Objekt, Gebaeude, Pflichtquest | `schwimmen`, `lernen`, `kochen` |
| Adjektiv / Eigenschaft | `ContextCard`, `CodexOnly`, spaeter modifier candidate | eigenes Objekt, Gebaeude, Plot | `schnell`, `gruen`, `alt` |
| Emotion / abstrakt | `ContextCard`, `CodexOnly`, `SensitiveGated` bei Risiko | Symbolzwang, Reward, Deko | `Angst`, `Freiheit` |
| TinyObject | `ContainerItem`, `CodexOnly`, `Backlog`, `NeedsUserChoice` | eigenes Grundstueck, IslandView-Dauerobjekt | `Schluessel`, `Messer`, `Loeffel` |
| Institution / sensitive | `SensitiveGated`, `ContextCard`, `CodexOnly`, `Backlog`, `Hide` | Gebaeude, Asset, Reward, Autoritaetsfantasie | `Polizei`, `Gericht`, `Krankenhaus` |
| Ort / Gebaeude | `NeedsUserChoice`, `WorldCandidate`, `ContextCard`, `Backlog` | Pflicht-Theme, finale Route ohne Sense | `Haus`, `Schule`, `Garage` |
| Prozess / Ereignis | `ActionChallenge`, `ContextCard`, `Backlog`, `CodexOnly` | BuildState, Timer, automatische Quest | `kochen`, `lernen`, `Reise` |

## 8. Konfliktprioritaeten

Verbindliche Reihenfolge:

```text
Safety / Sensitive
-> Context / Sense
-> Word Type
-> Clutter / Mobile
-> Confidence
-> User Choice
-> Theme / Plot Capability
-> Reward / World Feedback
```

Konsequenzen:

- Safety darf nie von Reward, Weltwunsch, User Choice oder ThemeIsland-Fit
  ueberstimmt werden.
- Context/Sense entscheidet vor ThemeIsland und Plot.
- Word Type entscheidet, ob ein Wort Ding, Aktion, Emotion, TinyObject,
  Institution, Ort oder Prozess ist.
- Clutter/Mobile kann sichtbare Weltreaktion stoppen, auch wenn Sense und
  Theme passen.
- Confidence begrenzt Sichtbarkeit und Review-Prioritaet.
- User Choice darf keine Safety-Regel und kein Clutter-Gate ueberstimmen.
- Capability ist Erlaubnis, keine Pflicht.
- Reward/World Feedback steht zuletzt und darf nie BuildState, Persistenz oder
  automatische Platzierung erzeugen.

## 9. Confidence-Bands

Confidence-Bands sind Planungswerte. Sie sind keine finale AI-/Provider-Logik
und keine Runtime-Konfiguration.

| Band | Bedeutung | Erlaubte Reaktion | Blockierte Reaktion | Queue-/Fallback-Regel |
| --- | --- | --- | --- | --- |
| `high` | Sense, Word Type, Safety und Outcome wirken klar. | Safe Default, knapper Vorschlag, optional Review wenn relevant. | automatische Platzierung, Persistenz, BuildState. | Nur zeigen, wenn Budget und Nutzerwert passen. |
| `medium` | plausibel, aber Kontext oder Outcome koennte anders sein. | `ContextCard`, `NeedsUserChoice`, `Backlog`, spaeter Review. | finale Kategorie, sichtbares Placement als Default. | Review nur bei hoher Relevanz/Risiko. |
| `low` | unsicher, mehrdeutig oder riskant. | `NeedsUserChoice`, `Backlog`, `CodexOnly`, `ContextCard`. | `WorldCandidate` erzwingen, PlacementCandidate, BuildState, Persistenz. | Nicht aktiv draengen; Safe Default gewinnt. |
| `unknown` | keine ausreichende Klassifikation. | `CodexOnly`, `Backlog`, `ContextCard`, `Later`. | sichtbare Weltreaktion, Review-Zwang. | Erst Kontext/Sense sammeln oder parken. |

## 10. Low-confidence-Regel

Low confidence landet in:

- `NeedsUserChoice`,
- `Backlog`,
- `CodexOnly`,
- `ContextCard`.

Low confidence darf nie:

- `WorldCandidate` als sichtbaren Vorschlag erzwingen,
- `PlacementCandidate` erzeugen,
- `BuildState` erzeugen,
- Persistenz erzeugen,
- SRS-/`word_progress` veraendern,
- Reward-Druck ausloesen,
- `frame_started` oder einen Bauzustand beruehren.

Wenn Low confidence und Sensitive-Risiko zusammenfallen, gewinnt
`SensitiveGated`.

Wenn Low confidence und Clutter-Risiko zusammenfallen, gewinnt `ContainerItem`,
`CodexOnly` oder `Backlog`.

## 11. Beispiele

| Wort | Minimalprofile-Signal | Prioritaet / Konflikt | Sicherer MVP-Ausgang | Blockiert |
| --- | --- | --- | --- | --- |
| `Haus` | noun, multiHome, placeBuilding | Sense vor Theme; User Choice vor WorldCandidate | `NeedsUserChoice`, `ContextCard`, spaeter `WorldCandidate` | Pflicht-Hausstart, Auto-Placement |
| `Bank` | noun, ambiguous | Sense vor Word Type Detail; Confidence meist medium/low | `NeedsUserChoice`, `ContextCard`, `Backlog` | Default Bank-Gebaeude |
| `Baum` | noun, natural object, clutter medium | Clutter/Mobile vor Deko; Theme erst nach Sense | `WorldCandidate` mit Gate oder `Backlog` | Deko-Masse, Auto-Asset |
| `schwimmen` | verb/action, water/safety | Word Type vor Theme; Water/Safety Gate | `ActionChallenge`, `ContextCard`, `Backlog` | Gebaeude, Wasserlogik ohne Gate |
| `Angst` | emotion/abstract, sensitive | Safety vor Reward; Companion optional neutral | `SensitiveGated`, `ContextCard`, `CodexOnly`, `Hide` | Objekt, Reward, Retention-Druck |
| `Messer` | tinyObject/tool, safety possible | Safety und Clutter vor Sichtbarkeit | `ContainerItem`, `ContextCard`, `SensitiveGated` je Kontext | sichtbares Tool ohne Gate |
| `Polizei` | institution/sensitive | Safety vor User Choice; Policy Gate | `SensitiveGated`, `ContextCard`, `CodexOnly` | Polizeiwache, Autoritaetsfantasie |
| `Freiheit` | abstract | Context/Sense vor Symbol; no object pressure | `CodexOnly`, `ContextCard` | Symbolpflicht, Gebaeude |
| `Schluessel` | tinyObject, possible sequence | Clutter/Depth vor IslandView | `ContainerItem`, `Backlog`, `NeedsUserChoice` | Minipixel auf Insel |
| `lernen` | verb/action, school possible | Word Type vor Schule; Schule nicht automatisch | `ActionChallenge`, `CodexOnly`, `ContextCard` | automatisches Schulgebaeude |
| `kochen` | verb/process, food/kitchen | Action before object; no quest start | `ActionChallenge`, `ContextCard`, `Backlog` | statisches Objekt, Pflichtquest |
| `Garage` | noun/place utility, multiHome | Sense/User Choice vor Zuhause/Verkehr/Stadt | `NeedsUserChoice`, `WorldCandidate` spaeter, `Backlog` | automatisch Zuhause oder Fahrzeuglogik |

## 12. Gate-Entscheidung

M16-Y entscheidet:

- Ein Minimal Semantic Profile ist als MVP-Konzept sinnvoll und noetig.
- Die Felder bleiben Planungsfelder, keine finale Datenstruktur.
- Context/Sense, Word Type, Safety, Clutter und Confidence muessen vor
  Theme/Plot/Reward/World Feedback stehen.
- `M16T-SEM-001` bis `M16T-SEM-004` koennen als erledigt markiert werden.
- `M16T-AI-001` und `M16T-AI-003` koennen als erledigt markiert werden.

Weiterhin offen:

- AI-/Classification-Provider-Governance,
- Privacy-Regeln fuer Wort-/Kontextklassifikation,
- Datenmodell,
- Persistenz,
- Review-Queue-UI,
- App-Integration,
- Tests/Accessibility/Performance.

## 13. Dokumentationsvisualisierungen

M16-Y erzeugt Dokumentationsvisuals unter:

`docs/world_design/previews/m16_y_semantic_profile_routing/`

Geplante Visuals:

- `minimal_semantic_profile_fields.png`
- `routing_priority_stack.png`
- `confidence_band_outcomes.png`
- `word_type_to_outcome_map.png`
- `conflict_resolution_flow.png`
- optional `00_contact_sheet.png`

Diese PNGs sind Dokumentationsmaterial, keine App-Screens, keine Screenshots,
keine Spielassets und keine Dateien unter `assets/`.

Visual-QA:

- Text bleibt in Karten/Rahmen/Panels.
- Ausreichender Innenabstand.
- Kartenabstaende.
- Keine Ueberlappung von Karten, Labels, Pfeilen, Titeln, Footern oder
  Legenden.
- Contact Sheet vollstaendig lesbar, falls erzeugt.
- Keine abgeschnittenen Inhalte.

## 14. Stop-Regeln

M16-Y gibt nicht frei:

- App-Integration,
- Route,
- Flutter-/Dart-Codeaenderung,
- Persistenz,
- Supabase/local DB Writes,
- SRS-/`word_progress`-Aenderung,
- automatische Wortplatzierung,
- Build-Wheel-Code,
- Assets oder Asset-Dateien unter `assets/`,
- Build-State,
- `frame_started`,
- Bauzustaende,
- Screenshots als Repo-Artefakte,
- Tests oder Widget-Tests.

