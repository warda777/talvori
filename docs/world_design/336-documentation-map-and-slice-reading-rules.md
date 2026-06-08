# M16-AB: Documentation Map and Slice Reading Rules

Stand: 2026-06-08

Status: `Dokumentations-/Visual-Slice gestartet / keine Implementierung`

## 1. Zweck und Non-Goals

M16-AB erstellt eine zentrale Dokumentenlandkarte und verbindliche
Pflichtlektuere-Regeln pro Slice-Typ. Ziel ist, dass kuenftige
Codex-Prompts die richtigen Grundlagen lesen, betroffene M16-T-IDs nennen,
Stop-Regeln wiederholen und bestehende Gates nicht vergessen.

M16-AB gibt keine Implementierung frei.

Non-Goals:

- keine Implementierung,
- keine App-Integration,
- keine Route,
- keine neue Seite,
- keine Persistenz,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- kein Build-State,
- kein Build-Wheel-Code,
- keine Assets und keine Asset-Dateien unter `assets/`,
- kein `frame_started`,
- keine Bauzustaende,
- keine Tests oder Widget-Tests,
- keine Screenshots als Repo-Artefakte.

## 2. Gepruefte Grundlage

| Dokument | Rolle fuer M16-AB |
| --- | --- |
| `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrendes M16-T-Backlog, Dashboard, Statuslegende und ID-System. |
| `docs/world_design/327-talvori-learning-game-logic-readiness-review.md` | Readiness Review, Staerken, Blocker und produktive System-Gates. |
| `docs/world_design/329-talvori-product-delivery-dashboard-and-scrum-lite.md` | Scrum-lite-Modell, Definition of Ready/Done, MVP-Roadmap und Research-Gate. |
| `docs/world_design/330-minimal-playable-learning-loop-contract.md` | Produktanker, Core Loop, Event-Trennung und Learning-to-World Contract. |
| `docs/world_design/331-minimal-word-outcome-detail-gate.md` | Outcome-Definitionen, Queue-Ausgaenge und Reward/Placement/BuildState-Grenzen. |
| `docs/world_design/332-reward-budget-and-review-queue-control-gate.md` | Reward-Budget, Queue-Budget, Safe Defaults und Anti-Druck-Regeln. |
| `docs/world_design/333-minimal-semantic-profile-and-routing-priority-gate.md` | Minimal Semantic Profile, Word-Type-Routing, Confidence und Konfliktprioritaeten. |
| `docs/world_design/334-companion-and-sensitive-return-safety-gate.md` | Companion-Policy, Pause, Fehlerkommunikation und sensitive Darstellungsleiter. |
| `docs/world_design/335-learning-states-and-srs-boundary-gate.md` | Lernzustaende und strikte SRS-/`word_progress`-Boundary. |

## 3. Betroffene M16-T-IDs

| ID | M16-AB Entscheidung | Grund |
| --- | --- | --- |
| `M16T-DOC-001` | `[x]` | Dokumentationslandkarte liegt als zentrale Datei vor. |
| `M16T-DOC-002` | `[x]` | Slice-Typen mit Pflichtlektuere-Regeln sind dokumentiert. |
| `M16T-DASH-004` | `[x]` | Dashboard-Update-Regel ist operationalisiert: 328 muss nach ID-Aenderungen aktualisiert werden. |
| `M16T-META-002` | `[x]` | Jeder kuenftige Prompt muss relevante M16-T-IDs nennen. |
| `M16T-META-003` | `[x]` | Nach jedem Slice muss die Liste aktualisiert oder bewusst unveraendert berichtet werden. |
| `M16T-META-004` | `[x]` | M16-S und M16-T bleiben Pflichtgrundlage fuer Readiness-/Gate-Slices. |
| `M16T-GIT-001` | `[x]` | `git status --short` ist vor Commit und im Abschlussbericht Pflicht. |
| `M16T-GIT-002` | `[x]` | Scope-Check gegen Stop-Regeln und erwartete Dateien ist Pflicht. |

## 4. Dokumentenlandkarte

### 4.1 Readiness / Steuerung / Dashboard

| Dokument | Wann fuehrend? |
| --- | --- |
| `327-talvori-learning-game-logic-readiness-review.md` | Bei Readiness-, Audit-, Risiko- und Produktlogik-Entscheidungen. |
| `328-talvori-learning-game-readiness-todo-checklist.md` | Bei jedem Slice mit M16-T-IDs, Dashboard, Status oder Fortschritt. |
| `329-talvori-product-delivery-dashboard-and-scrum-lite.md` | Bei Scrum-lite, MVP-Roadmap, Change-/Idea-Intake und Research-Gates. |
| `336-documentation-map-and-slice-reading-rules.md` | Bei jedem neuen World-/Learning-/Semantics-/Docs-/Commit-Slice als Lese-Kompass. |

### 4.2 Minimaler Lernloop

| Dokument | Kernregel |
| --- | --- |
| `330-minimal-playable-learning-loop-contract.md` | Lernen erzeugt Moeglichkeit, keine automatische Platzierung. |
| `335-learning-states-and-srs-boundary-gate.md` | Lernzustaende bleiben fachlich und schreiben nicht SRS/`word_progress`. |

### 4.3 Word Outcomes

| Dokument | Kernregel |
| --- | --- |
| `323-word-semantics-decision-preview-scope.md` | Beispielwort-Entscheidungen zeigen sichere Representation Outcomes. |
| `331-minimal-word-outcome-detail-gate.md` | `CodexOnly`, `WorldCandidate`, `ContainerItem`, `ActionChallenge`, `ContextCard`, `SensitiveGated`, `NeedsUserChoice` sind MVP-Outcomes. |

### 4.4 Reward / Queue / Anti-Druck

| Dokument | Kernregel |
| --- | --- |
| `332-reward-budget-and-review-queue-control-gate.md` | Wenige Vorschlaege, kleine Review-Queue, Later immer erlaubt, kein Druck. |
| `334-companion-and-sensitive-return-safety-gate.md` | Tali/Vori spricht optional, ruhig und ohne Schuld oder Pflichtentscheidung. |

### 4.5 Semantik / Routing / Confidence

| Dokument | Kernregel |
| --- | --- |
| `321-global-world-semantics-consistency-audit.md` | Pflichtpipeline: Word -> Context/Sense -> Word Type -> Safety -> Representation -> User Choice -> Later Gate. |
| `333-minimal-semantic-profile-and-routing-priority-gate.md` | Safety > Sense > Word Type > Clutter > Confidence > User Choice > Capability > Reward. |
| `270-word-to-island-routing-matrix.md` | Routing macht Vorschlaege, keine automatische Platzierung. |
| `284-word-to-island-ux-flow.md` | Word-to-Island UX bleibt User-Choice- und Fallback-getrieben. |

### 4.6 Companion / Sensitive / Pause

| Dokument | Kernregel |
| --- | --- |
| `334-companion-and-sensitive-return-safety-gate.md` | Keine Schuld, keine Beratung, keine sensitive Retention-Trigger. |
| `274-sensitive-content-representation-rules.md` | Sensitive Inhalte bevorzugen Codex, ContextCard, Backlog, Later, Hide oder Policy-Gate. |

### 4.7 Learning States / SRS Boundary

| Dokument | Kernregel |
| --- | --- |
| `335-learning-states-and-srs-boundary-gate.md` | `imported`, `seen`, `practiced`, `unsure`, `contextRich`, `understood`, `reviewCandidate`, `worldFeedbackEligible`, `blockedBySafety`, `parked` sind fachliche MVP-Zustaende, keine SRS-Werte. |
| bestehende Lern-/SRS-Dokumentation spaeter | Erst mit eigenem SRS-/Migration-/Test-Gate fuehrend. |

### 4.8 World / Island / Plot / Build

| Dokument | Kernregel |
| --- | --- |
| `318-theme-island-plot-capacity-and-build-wheel-plan.md` | Thema -> Plotbedarf -> Groessenmix -> Island Capacity -> Slot-Auswahl -> spaeteres In-place Wheel. |
| `320-global-theme-island-plot-capacity-matrix.md` | Dorf ist nur ein Beispiel; Kategorien brauchen eigene Plot-Familien. |
| `272-plot-capability-derivation.md` | Plot-Capability ist Erlaubnis, keine Pflichtbelegung. |
| `317-first-world-element-slice-scope-and-visual-plan.md` | Erste World-Elemente bleiben lokale, neutrale Previews. |

### 4.9 Container / Depth

| Dokument | Kernregel |
| --- | --- |
| `256-depth-container-user-flow-preview-plan.md` | Depth/Container brauchen eigene User-Flow-Grenzen. |
| `264-multi-example-container-flow-previews.md` | Mehrere Container-Beispiele verhindern Kleinteil-Clutter in der IslandView. |
| `276-mobile-clutter-rules-small-objects.md` | Kleine Objekte bekommen nicht automatisch eigene Grundstuecke. |

### 4.10 Mobile / Clutter / Accessibility

| Dokument | Kernregel |
| --- | --- |
| `276-mobile-clutter-rules-small-objects.md` | Mobile-Dichte, Labels und TinyObjects muessen begrenzt werden. |
| `277-mobile-clutter-visual-review.md` | Visual Review fuer kleine Objekte und UI-Dichte. |
| `335-learning-states-and-srs-boundary-gate.md` | Review/World-Feedback darf Mobile nicht mit Pflichtfragen ueberladen. |

### 4.11 Assets

| Dokument | Kernregel |
| --- | --- |
| `289-asset-prioritization-scope-gate.md` | Asset-Scope braucht eigenes Gate; keine Spielassets in Planungs-Slices. |
| `assets/images/world/buildable_islands/forest_clearing/template.md` | Waldlichtung/Previews sind Starter-/Testformen, keine App-/Assetfreigabe. |

### 4.12 Datenmodell / Persistenz / Backend

| Dokument | Kernregel |
| --- | --- |
| `326-scalable-word-semantics-architecture-plan.md` | Semantic Profiles, Queues und Fallbacks sind Konzept, keine Datenstruktur. |
| `335-learning-states-and-srs-boundary-gate.md` | Kein SRS-/`word_progress`-Write, kein Provider-Call, keine ContextHint-Speicherung ohne Gate. |
| `327-talvori-learning-game-logic-readiness-review.md` | Datenmodell, Persistenz, Migration und Supabase Writes bleiben produktive Blocker. |

### 4.13 Research / Benchmark

| Dokument | Kernregel |
| --- | --- |
| `329-talvori-product-delivery-dashboard-and-scrum-lite.md` | Research-Gates leiten Prinzipien ab, kopieren aber keine Mechaniken blind. |
| `328-talvori-learning-game-readiness-todo-checklist.md` | `M16T-RESEARCH-002` und `M16T-RESEARCH-003` sind eigene Detail-Gates. |
| `345-play-first-learning-experience-doctrine.md` | Game-Patterns muessen in Play-First-Regeln uebersetzt werden, bevor Mechaniken entstehen. |

### 4.14 Play-First / Gameplay Doctrine

| Dokument | Kernregel |
| --- | --- |
| `345-play-first-learning-experience-doctrine.md` | Talvori ist kein Vokabeltrainer mit Spieldeko, sondern ein Spiel, dessen Spielhandlungen Lernnutzen erzeugen. |
| `340-gameplay-pillars-and-mvp-quest-loop-research-prep.md` | Gameplay Pillars, Quest-/Challenge-Loop und Spass ohne Lernschaden. |
| `343-habit-motivation-pressure-free-retention-research.md` | Motivation und Retention ohne Druck, Streak-Schuld oder Pflicht. |
| `344-supercell-clash-progression-social-pressure-research.md` | Aufbaufortschritt und Social/Competition-Risiken ohne MVP-Freigabe. |

### 4.15 Visual-QA / Preview-Diagramme

| Dokument | Kernregel |
| --- | --- |
| `322-next-safe-preview-slice-decision-gate.md` | Visual-QA prueft Text-Containment, Innenabstand, Kartenabstand, Footer und Contact Sheet. |
| alle M16-S bis M16-AA Preview-Ordner | Dokumentationsvisuals sind keine App-Screens, keine Screenshots, keine Assets. |

Kuenftige Visual Documentation Slices sollen bevorzugt PNG und SVG erzeugen:
PNG fuer schnelle Vorschau, SVG fuer verlustfreie Zoom- und
Dokumentationsqualitaet. Text-Containment, ausreichender Innenabstand,
lesbare Contact Sheets und keine Ueberlappungen von Karten, Labels, Pfeilen,
Titeln, Footern oder Legenden sind harte Commit-Voraussetzungen.

## 5. Slice-Typen mit Pflichtlektuere

Jeder Slice darf zusaetzliche Docs nennen. Die folgende Liste ist die
Mindest-Pflichtlektuere pro Slice-Typ.

| Slice-Typ | Pflichtlektuere |
| --- | --- |
| Learning Loop Slice | `328`, `345`, `327`, `330`, `331`, `332`, `335`, `329` |
| Word Outcome Slice | `328`, `330`, `331`, `333`, `321`, `323`, `274`, `276` |
| Reward / Queue Slice | `328`, `330`, `331`, `332`, `334`, `327`, `326` |
| Gameplay / Quest / Challenge Slice | `328`, `345`, `340`, `330`, `331`, `332`, `333`, `334`, `337` |
| Semantics / AI Slice | `328`, `321`, `323`, `326`, `333`, `335`, `274`, `276`, `284` |
| Companion / Sensitive Slice | `328`, `334`, `274`, `333`, `331`, `332`, `327` |
| Learning State / SRS Slice | `328`, `330`, `331`, `332`, `333`, `334`, `335` und spaeter SRS-/Migration-Docs |
| World / Island / Plot Slice | `328`, `345`, `321`, `318`, `320`, `272`, `273`, `276`, `331`, `333` |
| Container / Depth Slice | `328`, `331`, `333`, `276`, `256`, `257`, `264`, `265` |
| Build-Wheel Slice | `328`, `318`, `320`, `331`, `332`, `333`, `327`; Build-Wheel-Code bleibt bis eigenem Gate blockiert. |
| Mobile / Accessibility Slice | `328`, `276`, `277`, relevante Preview-/Visual-Reviews und Stop-Regeln aus `327`. |
| Asset Slice | `328`, `289`, `274`, `276`, `320`, `assets/images/world/buildable_islands/forest_clearing/template.md` |
| Data / Persistence Slice | `328`, `326`, `327`, `333`, `335`, plus eigenes Datenmodell-/Migration-/Privacy-Gate. |
| UI / MVP Screen Slice | `328`, `345`, `337`, `332`, `334`, betroffene Feature-Docs und Visual-/Accessibility-Regeln. |
| App-Integration Slice | `328`, `345`, `327`, `329`, betroffene Feature-Docs, Architecture/Boundary Gate und Route-Gate. |
| Research / Benchmark Slice | `328`, `345`, `329`, `327`, betroffene M16-T-IDs und eigene Research-Frage. |
| Visual Documentation Slice | `328`, `327`, relevante Fachdocs, Visual-QA-Regel, erwarteter Preview-Ordner; bevorzugt PNG + SVG erzeugen. |
| Commit / Review Slice | `328`, `336`, erwartete Dateien, `git status --short`, `git diff --check`, Scope-Check. |

## 6. Prompt-Regel fuer kuenftige Codex-Prompts

Jeder kuenftige Codex-Prompt fuer World, Learning, Semantics, Reward, Queue,
Companion, Sensitive, Plot, Build, Container, Assets, Data, App-Integration,
Research, Visuals oder Review muss enthalten:

- Sprint-ID,
- Ziel,
- betroffene M16-T-IDs,
- Pflichtlektuere,
- Play-First-Rule aus `345`, wenn MVP, Gameplay, Quest, Challenge, World,
  Companion, UI oder Implementierung betroffen ist,
- erwartete Dateien,
- Non-Goals,
- Stop-Regeln,
- Checks,
- klare Nicht-Commit-Regel oder separate Commit-Freigabe,
- Update von `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`,
  wenn M16-T-IDs geaendert, erledigt, teilweise erledigt, blockiert oder
  ausgelagert werden.

Wenn ein Prompt keine betroffenen M16-T-IDs nennt, muss Codex sie aus 328
ableiten und im Abschluss berichten. Wenn die ID-Lage unklar ist, bleibt der
Slice ein Planungs-/Audit-Slice und darf keine Implementierung freigeben.

## 7. Output-Regel fuer kuenftige Codex-Ausgaben

Jede kuenftige Codex-Ausgabe muss berichten:

- erstellte/geaenderte Dateien,
- geaenderte M16-T-IDs,
- neuer Fortschritt, wenn 328 geaendert wurde,
- welche IDs erledigt, teilweise erledigt, unveraendert offen, blockiert oder
  ausgelagert bleiben,
- Visual-QA-Ergebnis, wenn PNGs erzeugt wurden,
- Stop-Regel-Nachweis,
- Ergebnis von `git diff --check`,
- Ergebnis von `git status --short`,
- Scope-Check gegen `lib/`, `assets/`, `test/` und `integration_test/`, wenn
  der Slice Docs-only bleiben muss.

## 8. Dashboard-Update-Regel

`M16T-DASH-004` wird mit M16-AB operationalisiert.

Nach jedem Slice gilt:

- Wenn M16-T-IDs betroffen sind, muss 328 aktualisiert werden.
- Gesamtzahlen muessen stimmen.
- Bereichs-Dashboard muss fuer betroffene bestehende Bereiche aktualisiert
  werden.
- Neue oder geaenderte IDs muessen im Abschnitt `Aktueller Stand` sichtbar
  werden.
- `Naechste empfohlene IDs` muessen nach der neuen Lage aktualisiert werden.
- Wenn keine ID geaendert wird, muss der Abschluss explizit sagen, dass 328
  unveraendert bleibt.

## 9. Commit-/Review-Regel

`M16T-GIT-001` und `M16T-GIT-002` werden mit M16-AB operationalisiert.

Vor jedem Commit:

- `git status --short` ausfuehren und berichten.
- `git diff --check` ausfuehren und berichten.
- Scope gegen erwartete Dateien pruefen.
- Bei Docs-only-Slices pruefen, dass `lib/`, `assets/`, `test/` und
  `integration_test/` unveraendert bleiben, ausser der Prompt erlaubt eine
  genau benannte Ausnahme.
- Keine Commit-Freigabe bei unerwarteten Dateien.
- Commit erst nach separater Freigabe.

## 10. Docs sind keine Implementierungsfreigabe

Auch wenn ein Gate, Plan, Prompt-Draft oder Visual dokumentiert ist, ist
dadurch kein Code freigegeben.

Code braucht immer:

- eigenen Implementierungs-Prompt,
- ausdrueckliche Nutzerfreigabe,
- geplante Dateien,
- Stop-Regeln,
- Checks,
- Format-/Analyse-/Testregeln, falls Code betroffen ist,
- Abschlussbericht,
- kein Commit ohne separate Freigabe.

Planungsdocs duerfen Architektur, Scope, Gate-Entscheidung, Visuals und
Prompt-Drafts vorbereiten. Sie duerfen keine App-Route, Persistenz,
SRS-/`word_progress`-Aenderung, automatische Wortplatzierung, Build-State,
Assets, Tests oder App-Integration freigeben.

## 11. Visualisierungen

M16-AB erzeugt Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_ab_documentation_map/`

Visuals:

- `documentation_map_overview.png`
- `slice_type_reading_matrix.png`
- `prompt_output_contract.png`
- `dashboard_update_flow.png`
- `commit_review_guardrails.png`
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

## 12. Stop-Regeln

Aus M16-AB folgt ausdruecklich:

- Keine App-Integration.
- Keine Route.
- Keine Flutter-/Dart-Codeaenderung.
- Keine Persistenz.
- Keine Supabase/local DB Writes.
- Keine SRS-/`word_progress`-Aenderung.
- Keine automatische Wortplatzierung.
- Kein Build-Wheel-Code.
- Keine Assets oder Asset-Dateien unter `assets/`.
- Kein Build-State.
- Kein `frame_started`.
- Keine Bauzustaende.
- Keine Screenshots als Repo-Artefakte.
- Keine Tests oder Widget-Tests.
- Keine Commit-Ausfuehrung.
