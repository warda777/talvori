# M16-T: Talvori Learning Game Readiness ToDo Checklist

Stand: 2026-06-12

Status: `fortlaufende ToDo-/Gate-Liste gestartet / keine Implementierung`

## 0. Product Delivery Dashboard

Letzte Aktualisierung: 2026-06-12

Aktive Sprint-ID: `M16-DM`

Sprint Goal:

> Uferwald bekommt das JSON/YAML Planning Format Gate: YAML wird als erstes
> spaeteres Planning-Format bevorzugt, aber M16-DM erzeugt nur Markdown-
> Formatregeln; echte `.json`-/`.yaml`-/`.yml`-Dateien, Runtime-Daten,
> Koordinaten, Polygone, Path-Centerlines, Assets und Code bleiben blockiert.

### 0.1 Gesamtfortschritt

| Kennzahl | Wert |
| --- | --- |
| Gesamtanzahl M16-T-Items | 311 |
| Offen `[ ]` | 0 |
| Teilweise erledigt `[~]` | 12 |
| Erledigt `[x]` | 287 |
| Blockiert `[!]` | 12 |
| Ausgelagert `[>]` | 0 |
| Gewichteter Fortschritt | 94.2 % |
| Fortschrittsbalken | `███████████████████░` |

Naechste empfohlene IDs:

- M16T-PROD-003
- M16T-CORE-003
- M16T-L2W-003
- M16T-WORLD-002
- M16T-WHEEL-003
- M16T-SCALE-001
- M16T-ARCH-001
- M16T-ARCH-002
- M16T-ARCH-003
- M16T-ARCH-004
- M16T-DOC-003
- M16T-GIT-003
- M16T-LEARN-002
- M16T-AI-002
- M16T-AI-004

### 0.2 Progress-Formel

| Status | Gewicht |
| --- | --- |
| `[x]` | 100 % |
| `[~]` | 50 % |
| `[ ]` | 0 % |
| `[!]` | 0 %, aber separat als Blocker sichtbar |
| `[>]` | ausgelagert, zaehlt erst nach Detail-Gate |

Formel:

```text
gewichteter Fortschritt =
  ((Anzahl [x] * 100) + (Anzahl [~] * 50)) / Gesamtanzahl Items
```

Lesart fuer `[>]`:

Ausgelagerte Items bleiben in der Gesamtzahl sichtbar, tragen aber erst nach
ihrem Detail-Gate Fortschritt bei.

### 0.3 Bereichs-Dashboard fuer 32 Bereiche

| Bereich | ID-Gruppe | Items | Erledigt | Teilweise | Offen | Blockiert | Prozent | Balken | Naechste empfohlene Aktion |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Meta-/Prozess-Gates | M16T-META | 4 | 4 | 0 | 0 | 0 | 100.0 % | `██████████` | ID-, Prompt- und Output-Regeln in jedem kuenftigen Slice anwenden. |
| Produktanker / Spielziel | M16T-PROD | 3 | 2 | 1 | 0 | 0 | 83.3 % | `████████░░` | Welt-dient-Lernen-Regel in kommenden World-Slices anwenden. |
| Core Loop | M16T-CORE | 3 | 2 | 1 | 0 | 0 | 83.3 % | `████████░░` | UI-Event-Regel in spaeteren Implementierungs-Slices als Stop-Regel fuehren. |
| Learning-to-World Contract | M16T-L2W | 3 | 2 | 1 | 0 | 0 | 83.3 % | `████████░░` | Weltreif-Kriterien spaeter mit Daten-/Review-Gate operationalisieren. |
| Lernzustaende / Lernloop | M16T-LEARN | 2 | 1 | 1 | 0 | 0 | 75.0 % | `████████░░` | Eigenes SRS-/Migration-/Test-Gate fuer produktive Lernstandslogik planen. |
| Minimal Word Outcome Taxonomy | M16T-WOT | 8 | 8 | 0 | 0 | 0 | 100.0 % | `██████████` | Outcome-Regeln in kuenftigen Semantik-/Preview-Slices anwenden. |
| Semantik-System | M16T-SEM | 4 | 4 | 0 | 0 | 0 | 100.0 % | `██████████` | Semantik-Regeln in kuenftigen Word-/World-Slices anwenden. |
| 20.000+-Wort-Skalierung | M16T-SCALE | 4 | 3 | 1 | 0 | 0 | 87.5 % | `█████████░` | Confidence-/Privacy-Folgeregeln fuer Massensemantik klaeren. |
| Reward ohne Druck | M16T-REWARD | 5 | 5 | 0 | 0 | 0 | 100.0 % | `██████████` | Reward-Regeln in kuenftigen MVP-/Companion-Slices anwenden. |
| World / Island / Plot | M16T-WORLD | 7 | 6 | 1 | 0 | 0 | 92.9 % | `█████████░` | Kamera-Modi, Visit-/Wander-Abgrenzung und freie Plot-/Capacity-Regeln in konkreten spaeteren Slices anwenden. |
| Container / Depth | M16T-DEPTH | 3 | 3 | 0 | 0 | 0 | 100.0 % | `██████████` | TinyObject-/Container-Regeln in kuenftigen World-/UI-Slices als Stop-Regel anwenden. |
| Build-Wheel | M16T-WHEEL | 4 | 2 | 1 | 0 | 1 | 62.5 % | `██████░░░░` | Wheel-Code weiter blockiert halten; In-place-Regeln erst mit eigenem Gate anwenden. |
| Undo / Reversibility | M16T-UNDO | 3 | 3 | 0 | 0 | 0 | 100.0 % | `██████████` | Undo-/Resizing-Regeln in spaeteren Persistenz- und World-Slices anwenden. |
| Tali/Vori Companion | M16T-COMP | 4 | 4 | 0 | 0 | 0 | 100.0 % | `██████████` | Companion-Regeln in kuenftigen Copy-/Review-Slices anwenden. |
| Mobile / Clutter / Accessibility | M16T-MOBILE | 4 | 4 | 0 | 0 | 0 | 100.0 % | `██████████` | Dichte-, Overlay- und A11y-Regeln in kuenftigen MVP-Screens anwenden. |
| Sensitive / Policy | M16T-SENS | 3 | 2 | 1 | 0 | 0 | 83.3 % | `████████░░` | Sensitive-no-deco/no-reward-Regel spaeter mit Asset-/World-Gates abschliessen. |
| Asset Scope | M16T-ASSET | 93 | 91 | 1 | 0 | 1 | 98.4 % | `██████████` | M16-DM bevorzugt YAML als spaeteres Planning-Format, definiert aber nur Markdown-Formatregeln; echte `.json`-/`.yaml`-/`.yml`-Dateien, Runtime-Daten, Koordinaten, Polygone, Assets und Code bleiben blockiert. |
| AI Art / Asset Pipeline | M16T-ART | 17 | 17 | 0 | 0 | 0 | 100.0 % | `██████████` | Art Bible v1, Starter Island Master Reference Set, KI-Art-Pipeline, Style-Metadaten und QA gegen Stilbruch vor Asset-Spec, High-Fidelity oder Code anwenden. |
| Datenmodell / Persistenz / Backend | M16T-DATA | 5 | 1 | 0 | 0 | 4 | 20.0 % | `██░░░░░░░░` | Offline-/Sync-Konfliktregeln anwenden; echte Datenmodell-/Persistenz-Gates bleiben blockiert. |
| Confidence Scoring / AI Governance | M16T-AI | 4 | 2 | 2 | 0 | 0 | 75.0 % | `████████░░` | AI-/Privacy-Regeln in eigenem Provider-Governance-Gate vertiefen. |
| Review Queue | M16T-QUEUE | 4 | 4 | 0 | 0 | 0 | 100.0 % | `██████████` | Queue-Regeln in kuenftigen Semantik-/MVP-Slices anwenden. |
| Play-First Learning | M16T-PLAY | 9 | 9 | 0 | 0 | 0 | 100.0 % | `██████████` | Play-First- und Island-First-Regeln in MVP-/Gameplay-/UI-/Implementierungs-Slices weiter als harte Stop-Regeln anwenden. |
| Interaction Patterns | M16T-INTERACT | 6 | 6 | 0 | 0 | 0 | 100.0 % | `██████████` | Interaction Pattern Decision Matrix und Research-/Benchmark-Check in kuenftigen UI-/World-/Gameplay-/Implementierungs-Slices anwenden. |
| Starter Island Infrastructure | M16T-INFRA | 12 | 12 | 0 | 0 | 0 | 100.0 % | `██████████` | Starter-Insel-Infrastruktur, Uferhain-Identitaet und user-facing Kategorie-/BuildChoice-Regeln aus 351/353 anwenden. |
| Core Construction Spine | M16T-SPINE | 15 | 15 | 0 | 0 | 0 | 100.0 % | `██████████` | Game-like Island Showcase / Camera Flow aus 357 fuer M16-BM anwenden. |
| Fun / Adventure / Curiosity | M16T-FUN | 19 | 19 | 0 | 0 | 0 | 100.0 % | `██████████` | Fun-/Hook-/Reward-Regeln aus 358, object-first Bauplatzregeln aus 359, character-assisted Action-Regeln aus 360 und Flow-Rejoin-Grenzen aus 361 in kommenden Gameplay-/World-/Build-/Learning-Slices anwenden. |
| Language Layer / Game Bible | M16T-LANGUAGE | 6 | 6 | 0 | 0 | 0 | 100.0 % | `██████████` | Talvori Game Bible, Language Layer, Language Passport, Internal Corpus und Context-before-Vocabulary-Regeln in kuenftigen World-/Learning-/Onboarding-/Language-Slices anwenden. |
| Project Management / External Tool Sync | M16T-MGMT | 4 | 4 | 0 | 0 | 0 | 100.0 % | `██████████` | Repo bleibt Source of Truth; Notion/Linear/GitHub duerfen nur Spiegel, Aufgaben oder technische Review-Strukturen nach Freigabe sein. |
| Professional Design / UX Gates | M16T-DESIGN | 8 | 8 | 0 | 0 | 0 | 100.0 % | `██████████` | Cozy Island Diorama Builder als M16-BY-Richtung und M16-BZ-Art-Pipeline vor komplexem Island-/World-/BuildChoice-Code anwenden. |
| Technische Architektur / App-Integration | M16T-ARCH | 4 | 0 | 0 | 0 | 4 | 0.0 % | `░░░░░░░░░░` | Boundaries klaeren, App-Integration blockiert halten. |
| Dokumentations- und Visual-QA | M16T-DOC | 7 | 5 | 1 | 0 | 1 | 78.6 % | `████████░░` | Prompt-Templates, Reading Rules und Visual-QA-Regel anwenden; Screenshots bleiben blockiert. |
| Commit-/Review-Hygiene | M16T-GIT | 4 | 3 | 0 | 0 | 1 | 75.0 % | `████████░░` | Template-basierte Status-, Diff- und Scope-Checks vor Commit weiter anwenden. |

## 1. Zweck

Diese Datei ist die fortlaufende ToDo-/Gate-Liste aus M16-S. Sie ueberfuehrt
das Readiness Review in versionierte, abhackbare Punkte, damit keine offenen
Themen aus dem Lernspiel-, Welt-, Semantik-, Reward-, Build-, Island-, Plot-,
Container-, Sensitive-, Asset-, Persistence- oder App-Integration-Konzept
verloren gehen.

Arbeitsregel:

- Kein neuer World-/Semantik-/Reward-/Build-/Island-/Plot-/Container-/
  Sensitive-/Asset-/Persistence-/App-Integration-Slice ohne Abgleich mit
  dieser Liste.
- Nach jedem Slice muss diese Liste aktualisiert werden.
- Jede neue Entscheidung muss vorhandene M16-T-IDs abarbeiten, vertiefen,
  auslagern oder bewusst offen lassen.
- M16-T ist keine Implementierungsfreigabe, keine Testfreigabe, keine
  Persistenzfreigabe und keine App-Integrationsfreigabe.

## 2. Status-Legende

| Status | Bedeutung |
| --- | --- |
| `[ ]` | offen |
| `[~]` | teilweise erledigt |
| `[x]` | erledigt |
| `[!]` | blockiert |
| `[>]` | ausgelagert in eigenes Detail-Gate |

## 3. Arbeitsregel fuer kuenftige Prompts

Jeder kuenftige Codex-Prompt muss relevante offene M16-T-IDs nennen.

Jede kuenftige Codex-Ausgabe muss berichten:

- welche M16-T-IDs erledigt wurden,
- welche M16-T-IDs teilweise erledigt wurden,
- welche M16-T-IDs unveraendert offen bleiben,
- welche M16-T-IDs neu entstanden sind,
- ob ein Item in ein eigenes Detail-Gate ausgelagert wurde.

Commit erst nach separater Pruefung und ausdruecklicher Freigabe.

Code-Spalte:

`Darf Code erzeugen` bedeutet in dieser Datei nicht, dass M16-T Code freigibt.
M16-T selbst erzeugt keinen Code. Wenn ein spaeteres Item Code braucht, muss
vorher ein eigenes Detail-Gate oder ein separater Implementierungs-Prompt
ausdruecklich freigegeben werden.

## 4. Meta-/Prozess-Gates

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-META-001 | [x] | Readiness-ToDo-Liste als verbindliche Folge-Liste | M16-S darf nicht als einmaliges Review versanden. | Diese Datei existiert und wird als Folge-Liste referenziert. | Kein Folge-Slice ohne Abgleich. | nein |
| M16T-META-002 | [x] | Jeder neue Prompt muss offene IDs nennen | Offene Gates sollen nicht unsichtbar bleiben. | Prompt-Vorlagen verlangen relevante M16-T-IDs. | Prompts ohne ID-Abgleich. | nein |
| M16T-META-003 | [x] | Nach jedem Slice muss die Liste aktualisiert werden | Fortschritt und neue Risiken bleiben nachvollziehbar. | Jeder Slice berichtet geaenderte, erledigte und neue IDs. | Commits ohne Checklisten-Update. | nein |
| M16T-META-004 | [x] | M16-S + M16-T gemeinsam pruefen | Review und ToDo-Liste gehoeren zusammen. | Kuenftige Readiness-/Gate-Prompts nennen beide Dokumente. | Slices, die nur alte Einzelregeln lesen. | nein |

## 5. Produktanker / Spielziel

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-PROD-001 | [x] | Produktanker formulieren | "Meine Woerter bauen eine Welt" muss in Systementscheidungen uebersetzt werden. | Ein kurzer verbindlicher Produktanker fuer World-/Learning-Slices dokumentiert ist. | Produkt-Slices ohne klaren North Star. | nein |
| M16T-PROD-002 | [x] | Unterschied Lernziel/Spielziel | Lernen darf nicht vom Spielziel verschluckt werden. | Lernziel, Spielziel und gemeinsame Schnittmenge getrennt beschrieben sind. | Weltfortschritt als Ersatz fuer Lernen. | nein |
| M16T-PROD-003 | [~] | Welt dient dem Lernen, ersetzt den Lernloop nicht | Die Welt soll Motivation und Kontext geben, nicht SRS/Training ersetzen. | Jeder World-Slice seinen Bezug zum Lernloop und seine Grenzen nennt. | Renderer oder World UI erzeugt Lernfortschritt. | nein |

## 6. Core Loop

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-CORE-001 | [x] | Core Loop dokumentieren | Lernen, Vorschlag, Entscheidung und Weltfeedback brauchen eine gemeinsame Reihenfolge. | Ein verbindlicher Loop als Dokument/Diagramm mit Stop-Regeln existiert. | Produktive Loop-Implementierung. | nein |
| M16T-CORE-002 | [x] | Lernereignis/Semantikereignis/Reward-Ereignis/Welt-Ereignis/Persistenz-Ereignis trennen | Ereignistypen duerfen nicht heimlich dasselbe werden. | Ein Event-Kontrakt die fuenf Ereignisarten und erlaubte Uebergaenge trennt. | UI-Events, die Fortschritt oder Persistenz ausloesen. | nein |
| M16T-CORE-003 | [~] | UI-Events duerfen keinen Fortschritt erzeugen | Tap, Hover oder Preview duerfen kein Lernen, Reward oder Build-State schreiben. | UI-Event-Regel als Stop-Regel in relevanten Slices steht. | Jede produktive Fortschrittsmutation aus UI-only Code. | nein |

## 7. Learning-to-World Contract

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-L2W-001 | [x] | Learning-to-World Contract ausarbeiten | Lernereignisse brauchen sichere, begrenzte Weltreaktionen. | Ein eigener Contract Lernereignis, Semantikvorschlag, Reward-Vorschlag und Weltreaktion trennt. | Reward Bridge, Build-State, Persistenz. | nein |
| M16T-L2W-002 | [x] | Lernfortschritt erzeugt Moeglichkeit, keine automatische Platzierung | Lernen soll Vorschlaege oeffnen, keine Objekte setzen. | Contract sagt explizit: Lernfortschritt erzeugt Candidate/Fallback, nicht Placement. | Automatische Wortplatzierung. | nein |
| M16T-L2W-003 | [~] | "weltreif" definieren | Nicht jedes Wort darf Weltwirkung haben. | Kriterien fuer weltreif dokumentiert sind: Sense, Safety, User Choice, Clutter, Gate. | Sichtbare Weltreaktion ohne Weltreife. | nein |

## 8. Lernzustaende / Lernloop

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-LEARN-001 | [x] | Minimale Lernzustaende definieren | Lernfortschritt muss sauber von Weltfortschritt getrennt bleiben. | Min-Zustaende fuer gelernt, wiederholt, unsicher, importiert, kontextreich dokumentiert sind. | Reward-/World-Mutation ohne Lernzustandsvertrag. | nein |
| M16T-LEARN-002 | [~] | Keine SRS-/`word_progress`-Aenderung ohne Gate | Bestehende Lernlogik bleibt geschuetzt. | Ein eigenes SRS-/`word_progress`-Gate mit Migration/Testplan existiert. | Jede SRS-/`word_progress`-Aenderung. | nein |

## 9. Minimal Word Outcome Taxonomy

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-WOT-001 | [x] | Minimal Word Outcome Taxonomy finalisieren | Woerter brauchen begrenzte, sichere Ausgaenge. | Outcome-Liste als fuehrende Taxonomy freigegeben ist. | Produktive Routing-Ausgaenge. | nein |
| M16T-WOT-002 | [x] | `CodexOnly` | Viele Woerter sollen neutral lernbar bleiben. | CodexOnly-Kriterium mit Beispielen und UI-Regeln dokumentiert ist. | Sichtbare Platzierung fuer CodexOnly. | nein |
| M16T-WOT-003 | [x] | `WorldCandidate` | Weltkandidaten duerfen nicht automatisch gebaut werden. | WorldCandidate User Choice, Gate und Fallback nennt. | Auto-Placement. | nein |
| M16T-WOT-004 | [x] | `ContainerItem` | Kleinteile brauchen Depth/Container statt Inselplatzierung. | ContainerItem-Grenzen, Clutter-Regeln und Fallbacks dokumentiert sind. | TinyObjects in IslandView. | nein |
| M16T-WOT-005 | [x] | `ActionChallenge` | Verben und Aktionen sind keine statischen Objekte. | ActionChallenge als eigener Ausgang mit Beispielen dokumentiert ist. | Verb als Gebaeude/Objekt. | nein |
| M16T-WOT-006 | [x] | `ContextCard` | Abstrakte oder kontextarme Begriffe brauchen Erklaerraum. | ContextCard-Regeln fuer Sense, Beispiel und Fallback dokumentiert sind. | Symbolpflicht fuer abstrakte Begriffe. | nein |
| M16T-WOT-007 | [x] | `SensitiveGated` | Sensitive Inhalte brauchen Policy und Opt-in. | SensitiveGated mit Policy- und Privacy-Gates dokumentiert ist. | Sensitive Visualisierung ohne Gate. | nein |
| M16T-WOT-008 | [x] | `NeedsUserChoice` | Multi-Home und Unsicherheit brauchen aktive Entscheidung. | NeedsUserChoice-Kriterien und Queue-Ausgang dokumentiert sind. | Falsche Default-Kategorie. | nein |

## 10. Semantik-System

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-SEM-001 | [x] | Minimal Semantic Profile definieren | Profile sind noetig, aber noch keine Datenstruktur. | Minimalfelder und Nicht-Ziele als Konzept freigegeben sind. | Persistenz oder finale Datenstruktur. | nein |
| M16T-SEM-002 | [x] | Context/Sense-Regeln | Woerter koennen mehrere Bedeutungen haben. | Satzkontext, Nutzerziel, Multi-Home und Unsicherheit priorisiert sind. | Sichtbare Route ohne Sense. | nein |
| M16T-SEM-003 | [x] | Word-Type-Routing | Nomen, Verb, Emotion, TinyObject und Sensitive brauchen unterschiedliche Wege. | Word-Type-Routing als Pflichtfilter vor ThemeIsland/Plot dokumentiert ist. | Ein-Weg-Routing fuer alle Woerter. | nein |
| M16T-SEM-004 | [x] | Konfliktprioritaeten | Safety, Clutter, Sense und User Choice koennen kollidieren. | Prioritaet Safety > Sense > Word Type > Clutter > Confidence > User Choice > Capability > Reward dokumentiert ist. | Falsche Reihung bei Konflikten. | nein |

## 11. 20.000+-Wort-Skalierung

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-SCALE-001 | [~] | 20.000+-Skalierungsprinzip | Viele Woerter duerfen nicht viele sichtbare Objekte werden. | M16-R-Prinzip in kuenftige Semantik-/World-Gates uebernommen ist. | 20.000 Karten/Objekte/Plots. | nein |
| M16T-SCALE-002 | [x] | Review-Queue-Budget | Nutzer darf nicht mit Entscheidungen ueberlastet werden. | Pro Session/Tag ein Planungsbudget fuer Reviewentscheidungen existiert. | Pflichtentscheidung nach jedem Wort. | nein |
| M16T-SCALE-003 | [x] | Safe Defaults | Sichere Standardausgaenge verhindern Druck und Fehlplatzierung. | CodexOnly, Backlog, ContextCard, Later, Hide, ContainerItem und SensitiveGated als Defaults definiert sind. | Sichtbarkeit als Default. | nein |
| M16T-SCALE-004 | [x] | Queue-Priorisierung | Nur relevante/risikoreiche Woerter sollen aktiv auftauchen. | Priorisierung nach Risiko, Lernrelevanz, Confidence und Nutzerziel dokumentiert ist. | FIFO-Massenreview. | nein |

## 12. Reward ohne Druck

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-REWARD-001 | [x] | Reward-Prinzip ohne Druck | Motivation darf nicht in Schuld oder Zwang kippen. | Reward-Regeln keine Strafe, kein Verfall, keine Pflichtentscheidung enthalten. | Produktive Reward Bridge. | nein |
| M16T-REWARD-002 | [x] | Reward-Budget | Weltfeedback soll dosiert und nicht manipulativ sein. | Pro Session/Loop Grenzen fuer Vorschlaege und Feedback dokumentiert sind. | Dauer-Belohnung oder Druck. | nein |
| M16T-REWARD-003 | [x] | Trennung Reward/Vorschlag/PlacementCandidate/BuildState | Reward darf kein Bauen ausloesen. | Begriffe und erlaubte Uebergaenge getrennt sind. | Reward -> BuildState. | nein |
| M16T-REWARD-004 | [x] | Rueckkehr-nach-Pause-Regel | Pausen sollen sanft aufgefangen werden. | Comeback-Regeln ohne Strafe, Schuld oder Weltverfall dokumentiert sind. | Retention-Druck. | nein |
| M16T-REWARD-005 | [x] | Sensitive-Themen nicht als Retention-Trigger | Emotionale/sensible Inhalte duerfen nicht manipulativ wirken. | Sensitive/Emotion-Woerter fuer Retention explizit blockiert sind. | Sensitive Reward/Druck. | nein |

## 13. World / Island / Plot

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-WORLD-001 | [x] | World/Island Loop | Weltfortschritt braucht einen eigenen Loop. | Island/Plot/Preview/Build/Persist-Schritte getrennt dokumentiert sind. | Build-State ohne Loop-Gate. | nein |
| M16T-WORLD-002 | [~] | ThemeIsland-/Plot-Capacity-Regeln | Inselgroesse entsteht aus Theme-Bedarf, nicht aus fixer Mini-Insel. | M16-I/K-Regeln in spaetere Preview-/Code-Gates uebernommen sind. | Dorf als globale Grundlage. | nein |
| M16T-WORLD-003 | [x] | Generische Plot-Familien | Kategorien brauchen wiederverwendbare Plot-Familien. | Plot-Familien fuer Water, Path, Residential, Garden, Hub, Container, Edge usw. dokumentiert sind. | Feste Gebaeudelisten. | nein |
| M16T-WORLD-004 | [x] | Plot-Capability ist Erlaubnis, keine Pflichtbelegung | Capabilities duerfen keine automatische Belegung erzeugen. | Jeder Plot-Slice diese Regel als Stop-Regel nennt. | Capability -> Placement. | nein |
| M16T-WORLD-005 | [x] | Camera modes gate for world decisions | World-/Map-/Build-/UI-/Asset-Entscheidungen duerfen nicht nur eine Kamera annehmen. | `383-talvori-camera-modes-and-visit-wander-rule.md` definiert Build/Map, Overview, Visit/Wander und Object Focus als Pflichtpruefung. | Architektur nur fuer eine statische Map-Kamera. | nein |
| M16T-WORLD-006 | [x] | Visit/Wander is separate from Build/Map | Spaetere Cloud-/Besucheransichten duerfen nicht nachtraeglich an eine reine Build-Karte angeklebt werden. | 383 dokumentiert: Uferwald Map-/Build-Modus ist nicht automatisch Wander-/Besucher-Modus; Nutzerinseln muessen individuell begehbar/besuchbar bleiben. | Build-Preview wird als Besuchsmodus gelesen. | nein |
| M16T-WORLD-007 | [x] | Overview and Object Focus camera boundaries | Vollstaendige Inselansicht und Objektfokus brauchen eigene Regeln statt Poster- oder Bottom-Sheet-Logik. | 383 trennt Overview als bewussten Ueberblick und Object Focus fuer Build Station, Haus, Worker, Raum, Moebel oder Container mit Rueckweg zur Welt. | Komplettansicht als Default oder Objektfokus als Route/Formular. | nein |

## 14. Container / Depth

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-DEPTH-001 | [x] | Container-/Depth-Modell | Kleine Objekte und Interiors brauchen Ebenen. | Depth-Modell fuer Island, Plot, Interior, Container, Detail dokumentiert ist. | Container-Implementierung. | nein |
| M16T-DEPTH-002 | [x] | Suchbarkeit versteckter/verschachtelter Objekte | Versteckte Woerter duerfen nicht verloren wirken. | Such-/Codex-/Backlog-Regeln fuer verschachtelte Objekte existieren. | Unsichtbare Lernobjekte ohne Auffindbarkeit. | nein |
| M16T-DEPTH-003 | [x] | Kleine Objekte bekommen nicht automatisch eigene Grundstuecke | Clutter und Plot-Inflation werden verhindert. | TinyObject/ContainerItem-Regel in allen Plot-Slices genutzt wird. | TinyObject-Plot. | nein |

## 15. Build-Wheel

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-WHEEL-001 | [!] | Build-Wheel weiter blockiert halten | Wheel wirkt schnell wie Bau- oder Assetfreigabe. | Kein Wheel-Code entsteht, bis Plot/Semantik/BuildChoice-Gates erledigt sind. | Build-Wheel-Code. | nein |
| M16T-WHEEL-002 | [x] | `BuildChoice`-Begriff definieren | Wahl, Preview, Candidate und Build duerfen nicht verschwimmen. | BuildChoice als nicht-persistente Auswahl vor Build-State dokumentiert ist. | Candidate -> BuildState. | nein |
| M16T-WHEEL-003 | [~] | In-Place-Wheel-Regeln | Wheel soll Overlay sein, keine Route oder neue Seite. | In-place, cancel, deselect, no-route-Regeln als Detail-Gate dokumentiert sind. | Route/neue Seite. | nein |
| M16T-WHEEL-004 | [x] | Undo-/Reversibility-Anforderung fuer Build-Entscheidungen | Bauentscheidungen muessen spaeter korrigierbar sein. | BuildChoice/BuildState braucht Undo- und Aenderbarkeitsregeln. | Irreversible Builds. | nein |

## 16. Undo / Reversibility

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-UNDO-001 | [x] | Undo-/Reversibility-Modell | Semantik- und Weltentscheidungen koennen spaeter falsch sein. | Undo/Aendern fuer Sense, Theme, Plot, Outcome und Preview dokumentiert ist. | Persistente Entscheidungen ohne Undo. | nein |
| M16T-UNDO-002 | [x] | Geaenderte Semantik | Nutzer oder Kontext kann Bedeutung aendern. | Reclassification-Regeln ohne Datenverlust beschrieben sind. | Einmalige finale Sense. | nein |
| M16T-UNDO-003 | [x] | ThemeIsland-Resizing | Theme-Bedarf kann wachsen oder sich aendern. | Resize/Reserve/Move-Regeln fuer ThemeIslands geplant sind. | Fixe Inselkapazitaet. | nein |

## 17. Tali/Vori Companion

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-COMP-001 | [x] | Companion-Policy | Tali/Vori darf helfen, aber nicht entscheiden oder draengen. | Companion Policy fuer Vorschlaege, Fallbacks und Grenzen dokumentiert ist. | Companion erzwingt Entscheidungen. | nein |
| M16T-COMP-002 | [x] | Companion-Sprechmomente | Zu viele Hinweise stoeren Lernen und Weltgefuehl. | Sprechmomente fuer Kontext, Unsicherheit, Erfolg, Pause und Sensitive definiert sind. | Permanente Companion-Texte. | nein |
| M16T-COMP-003 | [x] | Companion-Regeln fuer Fehler/Pausen | Fehler und Pausen brauchen sanfte Sprache. | Keine Schuld, keine Angst, keine Weltstrafe als Copy-Regel dokumentiert ist. | Retention-Druck. | nein |
| M16T-COMP-004 | [x] | Companion-Regeln fuer sensitive/abstrakte Woerter | Tali/Vori darf sensible Themen nicht dramatisieren. | Neutrale ContextCard/Codex/Backlog-Sprache dokumentiert ist. | Sensitive Drama/Advice. | nein |

## 18. Mobile / Clutter / Accessibility

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-MOBILE-001 | [x] | Mobile-Dichtebudgets | Kleine Screens begrenzen Objekte, Labels und Entscheidungen. | Dichtebudgets pro Ebene/Screen als Planungswerte dokumentiert sind. | Objekt-/Labelwolken. | nein |
| M16T-MOBILE-002 | [x] | Landmarken-vor-Kleinteilen | Weltlesbarkeit braucht grosse Orientierungspunkte. | Landmark-/Focus-Regel vor Detailobjekten dokumentiert ist. | TinyObject-first UI. | nein |
| M16T-MOBILE-003 | [x] | Text-/Overlay-Regeln | Overlays duerfen Welt und Interaktion nicht verdecken. | Text-Containment, Tap-Ziele, Footer/Legend/Overlay-Regeln dokumentiert sind. | Unlesbare Mobile-UI. | nein |
| M16T-MOBILE-004 | [x] | Accessibility Gate | Produktive UI braucht A11y-Pruefung. | Accessibility-Gate fuer Textgroesse, Kontrast, Semantics, Tap-Ziele existiert. | Produktive UI ohne A11y. | nein |

## 19. Sensitive / Policy

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-SENS-001 | [x] | Sensitive-Darstellungsleiter | Sensitive Inhalte brauchen abgestufte sichere Ausgaenge. | Codex, ContextCard, CompanionDialog, Backlog, BlockedUntilRules priorisiert sind. | Sensitive Objekt/Gebaeude. | nein |
| M16T-SENS-002 | [x] | Sensitive-Opt-in-Regel | Nutzer muss sensible Themen freiwillig behandeln koennen. | Opt-in, Later und Backlog als Optionen dokumentiert sind. | Pflichtquest fuer sensitive Inhalte. | nein |
| M16T-SENS-003 | [~] | Sensitive Inhalte sind keine Deko und kein Reward | Kein sensibles Thema als Belohnung oder Stimmungsmittel. | Reward/Asset/World-Regeln sensitive Inhalte blockieren. | Sensitive Reward/Deko. | nein |

## 20. Asset Scope

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-ASSET-001 | [!] | Asset-Scope-Gate | Echte Spielassets brauchen eigenes Gate. | Asset-Familien, Quellen, Qualitaet und Verwendung separat freigegeben sind. | Asset-Dateien unter `assets/`. | nein |
| M16T-ASSET-002 | [~] | Kein Wort erzeugt automatisch ein Asset | Semantik ist kein Asset-Generator. | Jeder Word-/World-Slice diese Regel nennt. | Auto-Asset aus Wort. | nein |
| M16T-ASSET-003 | [x] | Sensitive-safe Asset-Regeln | Sensitive Themen brauchen besonders neutrale Visualisierung. | Sensitive Asset Policy dokumentiert ist. | Symbolik ohne Policy. | nein |
| M16T-ASSET-004 | [x] | Lizenz-/Quelle-/Benennung-Regeln | Assets muessen rechtlich und strukturell sauber bleiben. | Naming, Quellen, Lizenzen und Review fuer Assets dokumentiert sind. | Unklare Asset-Herkunft. | nein |
| M16T-ASSET-005 | [x] | Asset Family and Export Spec | Asset-Produktion braucht vor Dateien eine gemeinsame Spezifikation. | `370-asset-family-and-export-spec.md` definiert Asset-Familien, Exportregeln, Layer, Groessen, Namen, Metadaten, QA und Folge-Gate. | Echte Dateien entstehen ohne Spec. | nein |
| M16T-ASSET-006 | [x] | Asset family taxonomy | Insel, Terrain, Slots, Stationen, Gebaeude, Figuren, Effekte und HUD brauchen getrennte Familien. | Erste Talvori-Asset-Familien mit Zweck, Master-Reference-Bezug und Noch-nicht-erlaubt-Status dokumentiert sind. | Unstrukturierte Einzelbilder oder Familienmix. | nein |
| M16T-ASSET-007 | [x] | Layer and composition boundaries | Spaetere Flutter-Komposition braucht getrennte Layer statt monolithischer Weltbilder. | Layer-Reihenfolge fuer Insel, Terrain, Wege, Slots, Build Station, Gebaeudephase, Figuren, Reaktionen und HUD steht. | Riesige Gesamtbilder, UI in Weltlayern oder untrennbare Effekte. | nein |
| M16T-ASSET-008 | [x] | Export formats and transparency rules | Schoene Bilder muessen spaeter technisch nutzbar sein. | PNG/WebP/SVG/Source-Datei-Regeln und Verbote gegen JPEG, Screenshots, Monolithen und kopierte Referenzbilder stehen. | Ungeeignete Formate oder unklare Exportquelle. | nein |
| M16T-ASSET-009 | [x] | Size, scale and mobile density rules | Assets muessen auf Smartphone-Groesse lesbar und konsistent skalierbar bleiben. | Basisskala, 1x/2x/3x-Planbarkeit, relative Groessen und mobile Lesbarkeitsregeln dokumentiert sind. | Zufallsstretching, unlesbare Slots/Figuren oder ueberdeckende HUDs. | nein |
| M16T-ASSET-010 | [x] | Naming and directory planning rules | Spaetere Dateien brauchen stabile maschinenlesbare Namen. | Namensschema `talvori_<family>_<subject>_<state>_<variant>_<size>.<ext>` und ASCII-/Metadaten-Regeln stehen. | Generatornamen, Leerzeichen, Umlaute oder unklare Varianten. | nein |
| M16T-ASSET-011 | [x] | Source/prompt/reference metadata and QA status | Jeder Candidate braucht nachvollziehbare Quelle, Prompt, Referenz, Lizenz und QA. | Pflichtmetadaten und QA-Statusleiter von `not_checked` bis `approved_after_asset_gate` dokumentiert sind. | Kandidaten ohne Quelle, Lizenz, Reference oder QA. | nein |
| M16T-ASSET-012 | [x] | Asset gate before assets and product integration | Spec darf nicht als Asset-Freigabe missverstanden werden. | 370 definiert, dass echte Dateien, Engine-ready Candidates, `assets/`-Writes und Produktintegration erst nach eigenem Asset-Gate erlaubt sind. | Dateien unter `assets/` oder App-Code ohne Asset-Gate. | nein |
| M16T-ASSET-013 | [x] | Starter Island Asset Candidate Gate | Der erste Asset-Candidate-Schritt braucht eine eng begrenzte Gate-Entscheidung. | `371-starter-island-asset-candidate-gate.md` definiert Scope, Non-Goals, Quellen, QA, Pfadgrenzen und Folgeentscheidung. | Candidate-Erzeugung ohne Gate. | nein |
| M16T-ASSET-014 | [x] | First candidate family decision: island_base | Die erste Familie muss Perspektive, Silhouette und Uferhain-Identitaet stabilisieren. | `island_base` als erste Candidate-Familie gegen `terrain_layers`, `slot_markers`, `build_stations` und `building_phases` begruendet entschieden ist. | Falsche Reihenfolge oder UI-/Slot-/Station-Assets ohne Inselbasis. | nein |
| M16T-ASSET-015 | [x] | Starter island candidate source and metadata requirements | Jeder spaetere Kandidat braucht nachvollziehbare Quelle, Prompt, Reference, Lizenz und Status. | M16-CF-Pflichtfelder und starter-island-spezifische Checks fuer Uferhain, Slotkapazitaet, Perspektive, Layer und Pfad dokumentiert sind. | Candidate ohne Source-/Prompt-/Reference-Metadaten. | nein |
| M16T-ASSET-016 | [x] | Starter island candidate QA and path boundaries | Candidate-Visuals duerfen nicht als Asset, App-Screen oder Engine-ready Export gelesen werden. | QA-Kriterien und Pfadgrenzen ausserhalb `assets/` fuer M16-CF dokumentiert sind. | Bilder unter `assets/`, fehlende QA oder App-Screen-Missverstaendnis. | nein |
| M16T-ASSET-017 | [x] | M16-CF candidate generation permission boundary | Der naechste Slice muss wissen, ob Bildgenerierung erlaubt werden darf. | M16-CF darf nur mit expliziter Bild-/Tool-/Pfad-/Metadaten-/QA-Freigabe `island_base`-Candidates erzeugen; Engine-ready und Produktintegration bleiben blockiert. | M16-CF startet Bilder oder Integration ohne ausdruecklichen Scope. | nein |
| M16T-ASSET-018 | [x] | Starter Island Base Candidate Generation Gate | Der erste moegliche Bildgenerierungs-Slice braucht eine konkrete Freigabeplanung. | `372-starter-island-base-candidate-generation-gate.md` definiert M16-CG als eng begrenztes `island_base`-Candidate-Gate ohne aktuelle Bild-/Asset-Erzeugung. | Bildgenerierung ohne Pfad-, Tool-, Metadata- und QA-Grenzen. | nein |
| M16T-ASSET-019 | [x] | Candidate documentation path and filenames | Candidate-Dateien brauchen erlaubte Pfade und stabile Namen, bevor sie entstehen. | M16-CG-Dokumentationspfad und erlaubte Dateinamenmuster fuer 2-3 `island_base`-Candidates, Contact Sheet und Metadata-Datei sind definiert. | Zufallsnamen, falsche Pfade oder Dateien unter `assets/`. | nein |
| M16T-ASSET-020 | [x] | Candidate tool roles and prompt requirements | Bildgenerierung braucht klare Rollen und Promptgrenzen. | Rollen fuer ChatGPT, KI-Bildtool, Figma/Photopea/Aseprite/Artist und Codex sowie Prompt-/Negative-Prompt-Anforderungen sind dokumentiert. | Freie Einzelprompts oder Codex als Bildgenerator. | nein |
| M16T-ASSET-021 | [x] | Island base metadata schema | Jeder Candidate muss Source, Prompt, Reference, Lizenz, Status und QA nachvollziehbar machen. | Pflichtmetadaten fuer `island_base`, M16-CG, Style/Structure/Master/Gate-References und Uferhain-spezifische Checks sind definiert. | Candidate ohne Metadaten oder Status. | nein |
| M16T-ASSET-022 | [x] | Uferhain island_base QA checklist | Uferhain-Candidates brauchen harte Review-Kriterien gegen generische Inseln. | QA-Checkliste fuer Uferhain-Identitaet, Perspektive, Slotreserve, Layerbarkeit, Mobile-Lesbarkeit, Referenzschutz, Pfadschutz und Statusschutz steht. | Generische Insel, Kategorieplaetze, UI-/Worksheet-Look oder Referenzkopie. | nein |
| M16T-ASSET-023 | [x] | M16-CG image generation permission boundary | Der naechste Slice darf nur klar begrenzt Bilder erzeugen. | M16-CG darf maximal 2-3 `island_base`-Dokumentationscandidates erzeugen; `engine_ready_candidate`, `approved_asset`, `assets/` und Flutter/App-Integration bleiben blockiert. | M16-CG oeffnet Engine-ready, Assets oder Produktintegration. | nein |
| M16T-ASSET-024 | [x] | Uferhain island_base documentation candidates | Der erste echte Candidate-Satz muss eng begrenzt und nachvollziehbar bleiben. | M16-CG erzeugt 2-3 `island_base`-Dokumentationscandidates nur im erlaubten Preview-Pfad. | Kandidaten ausserhalb des Preview-Pfads oder unter `assets/`. | nein |
| M16T-ASSET-025 | [x] | Uferhain candidate contact sheet | Kandidaten muessen vergleichbar und visuell reviewbar sein. | Ein Contact Sheet zeigt alle M16-CG-Candidates mit Status- und Scope-Hinweis. | Unlesbares oder ueberlappendes Contact Sheet. | nein |
| M16T-ASSET-026 | [x] | Uferhain candidate metadata file | Bilddateien ohne Source-/Prompt-/QA-Metadaten waeren nicht pruefbar. | `talvori_island_base_uferhain_candidate_metadata.md` dokumentiert Pflichtfelder, Prompts, Negative Prompt, Quellen, Referenzen, Status und QA. | Candidate ohne vollstaendige Metadaten. | nein |
| M16T-ASSET-027 | [x] | Uferhain candidate QA results | Kandidaten duerfen nicht als ungepruefte Spielbilder weiterwandern. | Jeder Candidate ist gegen Uferhain-Identitaet, Fluss/Ufer, Hain, zentrale Lichtung, Slotreserve, Perspektive, Mobile-Lesbarkeit, Layerbarkeit und No-Text/UI geprueft. | QA fehlt oder markiert keine Risiken. | nein |
| M16T-ASSET-028 | [x] | M16-CG path and status protection | Der erste Bildgenerierungs-Slice darf keine Asset-Freigabe suggerieren. | M16-CG dokumentiert Status `asset_candidate`, erlaubten Preview-Pfad, kein `assets/`, kein Engine-ready und kein approved Asset. | Status driftet zu Engine-ready, approved oder Runtime-Asset. | nein |
| M16T-ASSET-029 | [x] | Candidate review recommendation | Der naechste Schritt braucht eine geordnete Auswahl statt sofortiger Produktion. | M16-CG empfiehlt eine Review-Reihenfolge und markiert A, B und C mit QA-Status. | Direkter Sprung zu High-Fidelity, Export oder Produktintegration. | nein |
| M16T-ASSET-030 | [x] | Candidate A primary structure reference lock | Der beste Candidate darf nicht als Pixelziel missverstanden werden. | `373-candidate-a-structure-lock-and-postprocess-brief.md` sperrt Candidate A nur als primaere Uferhain-Strukturreferenz. | Candidate A wird als finales Zielbild oder Asset gelesen. | nein |
| M16T-ASSET-031 | [x] | Candidate A not-asset and not-engine-ready boundary | Die erste Candidate-Entscheidung muss Asset-Drift verhindern. | 373 sagt explizit: Candidate A ist kein Asset, kein finales Zielbild, kein Engine-ready Candidate, kein approved Asset und keine Produktdatei. | Bild wandert nach `assets/` oder wird Runtime-Grundlage. | nein |
| M16T-ASSET-032 | [x] | Candidate A postprocess rules | Die brauchbare Struktur muss in eine layerbare Richtung korrigiert werden. | 373 definiert Postprocess-Regeln gegen monolithisches/fertiges Bild, feste Pads, Kategorieplaetze, UI/Text/Gebaeude/Figuren und Stilbruch. | Naechster Schritt kopiert Candidate A statt ihn strukturell zu ueberarbeiten. | nein |
| M16T-ASSET-033 | [x] | Uferhain layer separation brief | Inselbasis, Terrain, Wasser, Slots, Station, Figuren und HUD muessen getrennt bleiben. | 373 ordnet Candidate-A-Struktur den spaeteren Familien `island_base`, `terrain_layers`, `water_paths`, `slot_markers`, `build_stations`, `building_phases`, `workers_companions` und `ui_hud_bubbles` zu. | Monolithisches Gesamtbild oder eingebackte Slots/Stationen. | nein |
| M16T-ASSET-034 | [x] | Candidate B/C secondary reference boundary | Sekundaere Kandidaten duerfen die Primary-Struktur nicht verwischen. | 373 haelt B nur als Riverarm-/Terrassen-Vergleich und C nur als Reserve-/Groessenvergleich, aber nicht als Primary. | Uneindeutige Candidate-Auswahl oder Sprung zu B/C ohne Review. | nein |
| M16T-ASSET-035 | [x] | Layer/postprocess plan before code | Nach Candidate-Review darf nicht direkt Flutter-Code starten. | 373 empfiehlt M16-CJ Candidate A Layer and Postprocess Plan vor neuen Bildern, Engine-ready, Assets oder Code. | Direkter Sprung zu High-Fidelity, Engine-ready Export oder Implementierung. | nein |
| M16T-ASSET-036 | [x] | Candidate A layer and postprocess plan | Der Structure-Lock muss in konkrete Folgearbeit uebersetzt werden. | `374-candidate-a-layer-and-postprocess-plan.md` definiert Layer-Zielbild, Familien, Postprocess-Regeln, QA und Folgepfad fuer Candidate A. | Sprung von Structure-Lock direkt zu Bildproduktion oder Code. | nein |
| M16T-ASSET-037 | [x] | island_base layer plan before pixels | Die Inselbasis darf nicht als monolithisches Candidate-Bild uebernommen werden. | 374 definiert `island_base` als Basisform/Silhouette mit getrenntem Wasser, Terrain, Slots, Stationen, Figuren und HUD. | Candidate A wird ausgeschnitten, kopiert oder als Runtime-Basis gelesen. | nein |
| M16T-ASSET-038 | [x] | water_paths and terrain_layers separation plan | Uferhain braucht Wasserarm und Hain, aber beides muss layerbar bleiben. | 374 trennt `water_paths` und `terrain_layers` mit eigenen Postprocess-Regeln fuer Ufer, Hain, Lichtung, Felsen und Hoehen. | Wasser, Baeume und Felsen bleiben untrennbar im Basisbild. | nein |
| M16T-ASSET-039 | [x] | Neutral slot marker planning after terrain | Slot-Reserven muessen neutral bleiben und duerfen nicht Kategorieplaetze werden. | 374 plant `slot_markers` erst nach `island_base`, `water_paths` und `terrain_layers`, mit ca. 12 neutralen Reserven und 16-20 Langfristreserve. | Hausplatz, Marktplatz, Pins, Icons oder feste Kategoriepads. | nein |
| M16T-ASSET-040 | [x] | Build Station and later families sequencing | Station, Bauphasen, Figuren und HUD duerfen nicht vor Basis/Layerlogik entstehen. | 374 legt die Reihenfolge `build_stations` -> `building_phases` -> `workers_companions` -> `ui_hud_bubbles` nach Basis-, Wasser-, Terrain- und Slotplanung fest. | Build Station, Figuren oder HUD werden in die Inselbasis eingebacken. | nein |
| M16T-ASSET-041 | [x] | Candidate A postprocess QA criteria | Folgearbeit braucht pruefbare Kriterien gegen Monolith, Pads und Stilbruch. | 374 definiert QA fuer Strukturreferenz, Uferhain-Identitaet, Layertrennung, Slotreserve, mobile Lesbarkeit, Statusschutz und Pfadschutz. | Postprocess ohne QA oder mit verlorenem Uferhain-Charakter. | nein |
| M16T-ASSET-042 | [x] | No image/code/asset generation in M16-CJ | Der Layer-Plan darf keine stillschweigende Produktionsfreigabe werden. | 374 sagt explizit: keine neuen Bilder, keine PNG/SVG, kein Preview-Ordner, kein `assets/`, kein Engine-ready, kein Code und kein Commit. | M16-CJ erzeugt Bilder, Assets, Engine-ready Candidates oder Flutter-Code. | nein |
| M16T-ASSET-043 | [x] | Candidate A external postprocess brief | Spaetere Bild-/Designarbeit braucht einen klaren Arbeitsauftrag. | `375-candidate-a-external-postprocess-and-layer-production-brief.md` beschreibt externe Postprocess- und Layer-Production-Arbeit fuer Candidate A. | Externe Arbeit startet ohne Brief oder mit Candidate A als Pixelziel. | nein |
| M16T-ASSET-044 | [x] | External layer production role boundaries | Codex, ChatGPT/image_gen, Design-Tools und Artist duerfen nicht vermischt werden. | 375 trennt Rollen: ChatGPT/image_gen nur nach Freigabe, Design-Tools/Artist fuer Layering/Paintover, Codex fuer Metadaten/QA/Checks. | Codex erzeugt Bilder, zeichnet nach oder gibt Assets frei. | nein |
| M16T-ASSET-045 | [x] | Future layer candidate paths and filenames | Spaetere Dateien brauchen Pfad- und Namensgrenzen vor Produktion. | 375 schlaegt nur Dokumentationspfade unter `docs/world_design/previews/` und stabile Dateinamen fuer Layer-Candidates und Metadata/Contact Sheet vor. | Dateien entstehen unter `assets/`, mit Zufallsnamen oder ohne Slice-Pfad. | nein |
| M16T-ASSET-046 | [x] | Layer target briefs for Uferhain | `island_base`, Wasser, Terrain und Slots brauchen getrennte Produktionsanforderungen. | 375 definiert fuer `island_base`, `water_paths`, `terrain_layers`, `slot_markers` und optional spaeter `build_stations` Zweck, Uebernahme, Neuzeichnung, Verbote, Exportidee, Metadaten und QA. | Ein monolithisches Gesamtbild ersetzt die Layerfamilien. | nein |
| M16T-ASSET-047 | [x] | Layer postprocess metadata and QA standard | Spaetere Layer-Candidates muessen pruefbar bleiben. | 375 definiert Pflichtmetadaten, Maximalstatus `layer_postprocess_candidate`, QA fuer Uferhain, Candidate-A-Struktur, Layertrennung, Neutralitaet, Mobile-Lesbarkeit, Pfadschutz und Statusschutz. | Layer-Candidates ohne Source, Lizenz, QA oder Statusschutz. | nein |
| M16T-ASSET-048 | [x] | No production permission in M16-CK | Der externe Brief darf keine Bild-, Asset- oder Code-Freigabe werden. | 375 sagt explizit: keine neuen Bilder, keine PNG/SVG, kein Preview-Ordner, kein `assets/`, kein Engine-ready, kein approved Asset, kein Code und kein Commit. | M16-CK wird als Produktions- oder Integrationsfreigabe gelesen. | nein |
| M16T-ASSET-049 | [x] | Anchor registration and placement gate | Spaetere Layer muessen reproduzierbar ueberlagerbar sein. | `376-anchor-registration-and-placement-logic-gate.md` definiert Anchor-, Registration-, Placement-, Layer- und Sorting-Standard vor weiterer Bild-/Layerarbeit. | Layer passen nur visuell ungefaehr zusammen. | nein |
| M16T-ASSET-050 | [x] | Fixed canvas and framing rules | Layer duerfen nicht frei im Crop driften. | 376 definiert feste Canvas-, Ratio-, Framing-, Crop-, Kamera- und Padding-Regeln fuer verwandte Layerfamilien. | Bildvarianten haben unterschiedliche Ausschnitte oder Perspektiven. | nein |
| M16T-ASSET-051 | [x] | Origin and pivot logic | Platzierung braucht stabile Bezugspunkte. | 376 trennt `canvas_origin`, `world_origin`, `layer_pivot` und `placement_pivot` inklusive Pivot-Regeln je Layer-Familie. | Objektpositionen beziehen sich auf Auge-Mass oder Bildmitte. | nein |
| M16T-ASSET-052 | [x] | Anchor point naming and documentation standard | Spaetere Anchors muessen benannt und pruefbar sein. | 376 definiert Pflicht-Anchors wie `main_build_area_anchor`, `house_primary_anchor`, `hub_center_anchor`, River-, Grove- und Reserve-Anchors plus Dokumentationsfelder. | Anchors fehlen oder sind unbenannt. | nein |
| M16T-ASSET-053 | [x] | Placement zone taxonomy | Reserve, Build-Footprint und No-Build duerfen nicht vermischt werden. | 376 definiert Buildable Footprints, Soft Placement Zones, Reserve Zones, No-Build Zones, No-Overlap Zones, Water-only und terrain-sensitive areas. | Neutrale Reserve wird zu echter Platzierung oder Kategorieplatz. | nein |
| M16T-ASSET-054 | [x] | Layer order and depth sorting standard | Ueber-/Unterlagerung darf nicht aus Pixeln geraten werden. | 376 definiert feste Layer-Reihenfolge, Sort-Bands, Sort-Anchor, Sort-Offset und Occlusion-Regeln fuer spaetere Candidates. | Implizite Sortierung aus dem Bild oder verdeckte Figuren/Stationen. | nein |
| M16T-ASSET-055 | [x] | Candidate A anchor and zone derivation | Candidate A ist ohne Anchors nicht produktionsreif. | 376 beschreibt, welche Anchors und Zonen aus Candidate A abgeleitet werden sollen und was weiterhin nicht uebernommen werden darf. | Candidate A wird ohne Registration als Layergrundlage genutzt. | nein |
| M16T-ASSET-056 | [x] | Anchor QA before image/layer progress | Bild- und Layer-Slices brauchen Commitfaehigkeitskriterien. | 376 definiert QA: Canvas, Framing, Origin/Pivot, Anchors, Placement-Zonen, No-Build/No-Overlap, Layer-Reihenfolge, Sorting und Ueberlagerbarkeit muessen JA sein. | Bildfreigabe ohne Anchor-/Registration-Pruefung. | nein |
| M16T-ASSET-057 | [x] | Candidate A anchor manifest | Der Registration-Standard muss fuer Candidate A konkret werden. | `377-candidate-a-anchor-manifest-and-layer-generation-brief.md` definiert Manifest-ID, Canvas-Family, Canvas-Origin, World-Origin, Layer-Pivot, Coordinate Space, Framing Lock und Statusschutz. | Candidate A bleibt nur visuelle Bauchentscheidung ohne Manifest. | nein |
| M16T-ASSET-058 | [x] | Rough anchor map from structure | Spaetere Layerarbeit braucht benannte Bezugspunkte, darf aber keine ungemessenen Werte als produktiv nutzen. | 377 dokumentiert Pflicht-Anchors wie `main_build_area_anchor`, `house_primary_anchor`, `hub_center_anchor`, River-, Grove- und Reserve-Anchors mit `rough_from_structure`-Status. | Grobe Koordinaten werden als Runtime- oder Engine-ready-Werte gelesen. | nein |
| M16T-ASSET-059 | [x] | Placement and no-build/no-overlap manifest | Reserve, Build-Footprint, Wasser, Hain, Klippen und Safe Areas muessen getrennt bleiben. | 377 definiert `buildable_footprint`, `soft_placement_zone`, `reserve_zone`, `no_build_zone`, `no_overlap_zone`, `water_only_zone` und `terrain_sensitive_zone`. | Kategorieplaetze, Build Stations oder Slotmarker entstehen ohne Zonenlogik. | nein |
| M16T-ASSET-060 | [x] | Layer generation anchor requirements | Spaetere Layer-Candidates muessen dieselbe Uferhain-Struktur registrierbar halten. | 377 beschreibt fuer `island_base`, `water_paths`, `terrain_layers`, `slot_markers` und blockierte `build_stations`, welche Anchors und Zonen erhalten bleiben muessen. | Layer driften auseinander oder Build Stations entstehen zu frueh. | nein |
| M16T-ASSET-061 | [x] | Build stations remain blocked after anchor manifest | Anchor-Regeln duerfen nicht als Build-Station-Assetfreigabe gelesen werden. | 377 sagt explizit, dass `build_stations` noch nicht erzeugt werden und ein eigenes Visual-/Asset-Gate brauchen. | Build Station wird aus Candidate A oder Anchor-Manifest direkt produziert. | nein |
| M16T-ASSET-062 | [x] | Anchor metadata extension standard | Spaetere Layer-Metadaten brauchen Registration-Felder. | 377 ergaenzt Pflichtfelder wie `anchor_manifest`, `anchor_manifest_version`, `canvas_family`, `world_origin`, `required_anchors_present`, Placement-/No-Build-/No-Overlap-Status und Registration-QA. | Layer-Candidates ohne Anchor-/Registration-Metadaten. | nein |
| M16T-ASSET-063 | [x] | Image/layer slice commitability via manifest | Kuenftige Bild-/Layer-Slices duerfen nur mit vollstaendiger Registration commitfaehig sein. | 377 definiert Commitfaehigkeitsregeln: kein Anchor-Manifest, keine Placement-Zonen, keine No-Build-/No-Overlap-Zonen oder kein Depth-/Sorting = nicht commitfaehig. | Bildarbeit wird trotz fehlender Registration akzeptiert. | nein |
| M16T-ASSET-064 | [x] | No image/asset/code generation in M16-CM | Der Manifest-Slice darf nicht zur stillen Produktion werden. | 377 bleibt reiner Anchor-Manifest-/Layer-Generation-Brief ohne neue Bilder, PNG/SVG, Preview-Ordner, `assets/`, Engine-ready, Code oder Commit. | M16-CM erzeugt Bilder, Assets, Engine-ready Candidates oder Flutter-Code. | nein |
| M16T-ASSET-065 | [x] | First Uferhain layer postprocess permission gate | Der erste echte Layer-Postprocess-Schritt braucht eine separate Bildarbeitsentscheidung. | `378-first-uferhain-layer-postprocess-candidate-permission-gate.md` klaert, dass M16-CN selbst keine Bilder erzeugt, aber M16-CO unter engen Bedingungen vorbereiten darf. | Bildarbeit startet ohne Permission Gate. | nein |
| M16T-ASSET-066 | [x] | M16-CO documentation path and filenames | Spaetere Layer-Dateien brauchen vor Produktion erlaubte Pfade und Namen. | 378 definiert den einzigen spaeteren M16-CO-Dokumentationspfad sowie erlaubte Dateinamen fuer `island_base`, optional `water_paths`, Metadata, Anchor-Manifest und Contact Sheet. | Zufallspfade, Dateien unter `assets/` oder unklare Namen. | nein |
| M16T-ASSET-067 | [x] | First layer family decision: island_base postprocess | Die erste Bildarbeit muss die Inselbasis stabilisieren, nicht Terrain, Slots oder Stationen vorziehen. | 378 erlaubt fuer M16-CO bevorzugt nur `island_base`; `water_paths` nur optional fuer Registration; `terrain_layers`, `slot_markers` als Bild und `build_stations` bleiben blockiert. | Terrain-/Slot-/Build-Station-Bilder entstehen zu frueh. | nein |
| M16T-ASSET-068 | [x] | Layer postprocess max status protection | Der erste Postprocess-Candidate darf nicht zu Engine-ready oder approved Asset driften. | 378 setzt Maximalstatus `layer_postprocess_candidate` und blockiert `engine_ready_candidate`, `approved_asset`, `production_asset`, `runtime_asset` und `app_asset`. | Status wird zu hoch gesetzt oder als Produktdatei gelesen. | nein |
| M16T-ASSET-069 | [x] | Anchor registration mandatory for M16-CO | Bildarbeit darf nur mit Canvas-, Origin-, Pivot-, Framing- und Anchor-Pflicht weitergehen. | 378 verlangt `canvas_family`, `canvas_origin`, `world_origin`, `layer_pivot`, `framing_lock`, 377-Anchor-Manifest, Placement-Zonen, No-Build-/No-Overlap-Zonen und Sort-Bands. | Layer-Candidate ohne Registration, Anchors oder Zonen. | nein |
| M16T-ASSET-070 | [x] | Future image tool role boundary | Codex darf auch nach Permission Gate nicht zum Bildgenerator werden. | 378 trennt Folgearbeit: ChatGPT/image_gen oder benanntes externes Tool darf nur im M16-CO-Folgeprompt Bilder erzeugen; Codex bleibt bei Intake, Metadaten, QA, Dateieinordnung und Checks. | Codex startet KI-Bildtools, zeichnet Candidate A nach oder gibt Assets frei. | nein |
| M16T-ASSET-071 | [x] | First layer prompt and negative constraints | Spaetere Bildprompts brauchen klare Grenzen gegen Pixelkopie, UI, Figuren, Kategorieplaetze und Build Stations. | 378 dokumentiert Pflichtsatz, positive Uferhain-/2.5D-Diorama-Richtung und Negative-Grenzen fuer M16-CO. | Freie Einzelprompts oder Bilder mit Text, UI, Slots, Gebaeuden, Figuren oder Build Stations. | nein |
| M16T-ASSET-072 | [x] | M16-CO QA and commitability guard | Der Folge-Slice braucht harte Blocker gegen fehlende Metadaten, falschen Pfad und Statusdrift. | 378 definiert QA: fehlende Anchor-/Registration-Logik, fehlende Metadaten, `assets/`-Pfad, zu hoher Status oder Candidate-A-Pixelziel machen M16-CO nicht commitfaehig. | M16-CO akzeptiert Bilddateien ohne QA oder mit falschem Scope. | nein |
| M16T-ASSET-073 | [x] | Uferwald layer candidate intake | Der erste externe Uferwald-Candidate muss sauber in Docs uebernommen werden. | `379-uferwald-layer-candidate-intake-and-qa.md` dokumentiert Quelle, Pfad, Status, Name, Scope, Grenzen und Folgepfad. | Lokale Datei wird verschoben, falsch eingeordnet oder als Asset gelesen. | nein |
| M16T-ASSET-074 | [x] | Uferwald 1x/2x/3x review copies | Zoom-/Scale-QA braucht pruefbare Dokumentationskopien, aber keine Produktions-Exporte. | M16-CP legt 1x, 2x und 3x PNGs im erlaubten Preview-Pfad an und markiert 2x/3x als Review-Kopien. | Upscales werden als Engine-ready oder echte Asset-Exports gelesen. | nein |
| M16T-ASSET-075 | [x] | Uferwald contact sheet | Review-Kopien muessen schnell visuell pruefbar sein. | `talvori_uferwald_layer_postprocess_contact_sheet_1x.png` zeigt 1x/2x/3x mit Status `layer_postprocess_candidate`, documentation only, not asset, not engine-ready und not production. | Unlesbares Contact Sheet oder App-Screen-Missverstaendnis. | nein |
| M16T-ASSET-076 | [x] | Uferwald metadata record | Jeder uebernommene Candidate braucht Quelle, Status, Scope, Tool-Rollen und Lizenznotiz. | `talvori_uferwald_layer_postprocess_metadata.md` dokumentiert Pflichtfelder, Hashes, Dateigroessen, erlaubten Scope, blockierten Scope und Tool-Rollen. | Candidate ohne nachvollziehbare Quelle, Status oder Rolle. | nein |
| M16T-ASSET-077 | [x] | Uferwald measured anchor manifest | Die Bildarbeit braucht echte gemessene Doku-Anker, aber keine Runtime-Koordinaten. | `talvori_uferwald_layer_postprocess_anchor_manifest.md` dokumentiert Canvas, Origin, Pivot, Coordinate Space, acht Anchors, Zonen und Sort-Bands mit `measured_on_candidate_bitmap_not_final_runtime_anchor`. | Anker fehlen oder werden als final/runtime gelesen. | nein |
| M16T-ASSET-078 | [x] | Uferwald placement and zone QA | Uferwald braucht klare Trennung von Build-Reserve, Wasser, Hain, Klippen und No-Overlap. | M16-CP dokumentiert Buildable Footprint, Soft Placement, Reserve, No-Build, No-Overlap, Water-only und Terrain-sensitive Zones. | Kategorieplaetze, UI-Safe-Areas oder Build Stations entstehen implizit. | nein |
| M16T-ASSET-079 | [x] | Uferwald zoom and scale QA | Review muss klaeren, was 1x/2x/3x bereits zeigen und was nicht. | `talvori_uferwald_layer_postprocess_qa.md` prueft Zoom-out, Mid-Zoom, Zoom-in-Risiko und markiert 2x/3x als Review-Kopien ohne neue Source-Details. | Upscales werden mit echter Detail- oder Produktionsqualitaet verwechselt. | nein |
| M16T-ASSET-080 | [x] | Uferwald layer readiness assessment | Der Slice darf nicht vortaeuschen, dass echte Layer schon existieren. | M16-CP dokumentiert: flaches `island_base`-Bitmap vorhanden, transparente Einzel-Layer NEIN, separate echte Layer NEIN, produktionsreife Layer blockiert. | Monolithisches RGB-PNG wird als transparente Layer- oder Engine-ready-Basis verkauft. | nein |
| M16T-ASSET-081 | [x] | Playable map layer and mask architecture before rendering | Spielbare Karten duerfen nicht aus fertigen Gesamtbildern geraten werden. | `384-uferwald-playable-map-layer-and-mask-architecture.md` definiert technische Layer, Masks, Zonen, Pfade, Hindernisse, Build-Footprints, Sort-Bands und Landmark-Anchors als Pflicht vor Rendering, Build/Map oder Visit/Wander-Interaktion. | Gameplay-Pfade, Collision, Grundstuecke oder Build-Zonen werden aus Pixelbildern geraten. | nein |
| M16T-ASSET-082 | [x] | Uferwald technical layer and mask spec | Die Architekturregel braucht konkrete Ebenen, Datenformen, Nutzer und Grenzen. | `385-uferwald-technical-layer-and-mask-spec.md` definiert `base_rock_shape`, `grass_terrain_mask`, `water_river_mask`, `walkable_path_layer`, `tree_obstacle_layer`, `rock_cliff_obstacle_layer`, `buildable_zone_layer`, `plot_footprint_layer`, `no_walk_mask`, `no_build_mask`, `depth_sort_bands` und `landmark_anchor_layer` inklusive Modus-Nutzung und Nicht-Ableitungsregeln. | Pfade, Hindernisse, Bauzonen oder Sortierung bleiben unkonkret oder werden weiter aus Pixeln geraten. | nein |
| M16T-ASSET-083 | [x] | Uferwald technical layer manifest | Die Spec braucht eine erste maschinennahe, aber noch nicht runtime-faehige Manifeststruktur. | `386-uferwald-technical-layer-manifest.md` definiert `map_id: uferwald_starter_island`, `coordinate_space: normalized_0_1`, alle Pflicht-Layer-IDs, geplante Anchor-IDs, `allowed_modes`, `blocked_uses` und offene Messfragen ohne finale Koordinaten oder Runtime-Daten. | Technische Folgearbeit startet ohne Layer-IDs, offene Messfragen oder klare Grenze gegen Runtime-/Asset-Status. | nein |
| M16T-ASSET-084 | [x] | Uferwald technical measurement and vector planning gate | Layer/Masks/Zonen brauchen eine Mess- und Vector-Planungsregel, bevor daraus technische Daten entstehen duerfen. | `387-uferwald-technical-measurement-and-vector-planning-gate.md` definiert Messreihenfolge, erlaubte Ableitungen zwischen technischen Ebenen, Pixel-Ableitungsverbote, moegliche Tools wie Figma/SVG/JSON/YAML/manuelle Polygonplanung und QA vor einem Runtime-Manifest. | Messung, Vector-Planung oder Runtime-Manifest startet ohne Reihenfolge, QA oder Schutz gegen Pixeltracing. | nein |
| M16T-ASSET-085 | [x] | Uferwald measurement workspace format decision | Vor echten Vector-/Polygon-Dateien braucht der naechste Schritt eine klare Formatentscheidung. | `388-uferwald-measurement-source-and-vector-workspace-plan.md` vergleicht Markdown-only, SVG-Plan, Figma-Plan und JSON/YAML-Planungsstruktur und entscheidet Markdown + SVG-Dokumentationsvisual als naechsten Weg, ohne Figma-Write, JSON/YAML-Runtime-Daten, Koordinaten oder Datei-Erzeugung. | Vector-, Figma-, SVG- oder JSON/YAML-Arbeit startet ohne Formatentscheidung und Scope-Grenzen. | nein |
| M16T-ASSET-086 | [x] | Uferwald measurement SVG documentation visual | Die Formatentscheidung braucht einen ersten visuellen Messplan, ohne Runtime-Daten zu erzeugen. | `389-uferwald-measurement-svg-documentation-plan.md` und der M16-DF-Preview-Ordner erzeugen SVG und PNG als `documentation_only`, `not_runtime_data`, `not_asset` und `not_engine_ready`; Layer/Masks/Zonen sind sichtbar pruefbar, aber keine finalen Koordinaten, keine Runtime-Mapdaten und keine Assets. | SVG/PNG wird als Runtime-Geometrie, Asset, Figma-Ersatz oder finale Koordinatenquelle gelesen. | nein |
| M16T-ASSET-087 | [x] | Uferwald technical measurement review | Der SVG-Messplan muss fachlich bewertet werden, bevor daraus praezisere Mess- oder Schemaarbeit entsteht. | `390-uferwald-technical-measurement-review.md` prueft M16-DF gegen Pfadbreiten, Baum-/Wasser-/Felsblocker, No-Walk, No-Build, organische Build-Zonen, Sort-Bands, Landmark-Anker und Pfad-gegen-Blocker-Konflikte und empfiehlt einen Measurement Precision Pass vor JSON/YAML oder Runtime-Daten. | Direkter Sprung zu JSON/YAML, Runtime-Mapdaten, Flutter-Logik oder Asset-Arbeit trotz unklarer Messbasis. | nein |
| M16T-ASSET-088 | [x] | Uferwald measurement precision pass | Der Review braucht verbindliche Praezisionsregeln, bevor ein weiterer Visual- oder Schema-Schritt entsteht. | `391-uferwald-measurement-precision-pass.md` definiert relative Pfadbreiten, Planungskorridor-vs-Runtime-Pfad, Wassergrenzen, Uferpuffer, Baum-/Hainrollen, Fels-/Klippenrollen, No-Walk-/No-Build-Unionen, Pfad-gegen-Blocker-QA, Sort-/Occlusion-Regeln und Anchor-Rollen ohne neue Bilder, SVG/PNG, JSON/YAML, Runtime-Daten, Assets oder Code. | Visual-/JSON/YAML-/Runtime-Folgearbeit startet ohne Praezisionsregeln und verwechselt Review-Geometrie mit technischer Karte. | nein |
| M16T-ASSET-089 | [x] | Uferwald measurement visual precision pass | Die M16-DH-Regeln muessen sichtbar pruefbar werden, bevor Schema-/Runtime-Arbeit startet. | `392-uferwald-measurement-visual-precision-pass.md` und der M16-DI-Preview-Ordner zeigen Pfadbreiten, Wasser-/Uferpuffer, Baum-/Hainrollen, Fels-/Klippenrollen, No-Walk-/No-Build-Unionen, Pfad-gegen-Blocker-QA, Sort-/Occlusion-Kanten und Anchor-Rollen als `documentation_only`, `planning_visual`, `not_runtime_data`, `not_asset` und `not_engine_ready`. | Visual-/JSON/YAML-/Runtime-Folgearbeit startet ohne sichtbare Precision-QA oder liest das Visual als Runtime-Daten. | nein |
| M16T-ASSET-090 | [x] | Uferwald visual precision review | Der M16-DI-Visual-Pass muss fachlich entschieden werden, bevor Schema-/Planungsarbeit startet. | `393-uferwald-visual-precision-review.md` bewertet die vier Detailansichten, Contact Sheet, Overview-SVG/PNG und README; entscheidet, dass ein Docs-only Schema-/Planungs-Gate sinnvoll ist und M16-DI-FIX-2 nicht noetig ist; JSON/YAML, Runtime-Daten, finale Koordinaten, Assets und Code bleiben blockiert. | Schema-/Planungsarbeit startet ohne Review-Entscheidung oder liest die M16-DI-Visuals als Runtime-Geometrie. | nein |
| M16T-ASSET-091 | [x] | Uferwald technical planning schema gate | Vor JSON/YAML- oder Runtime-naeherer Planung braucht Uferwald ein Feldschema, das Werte, Koordinaten und Polygone weiterhin blockiert. | `394-uferwald-technical-planning-schema-gate.md` definiert Layer-IDs, Layer-Rollen, gemeinsame Pflichtfelder, Geometry-Placeholder, Rollen-/Status-Enums, QA-Felder, offene Messfragen, Pixelableitungsverbote, manuelle Messpflichten, Runtime-Review-Pflichten und Blockerstatus als Markdown-Schema ohne echte JSON/YAML-Datei, Runtime-Daten, finale Koordinaten, Visuals, Assets oder Code. | JSON/YAML-, Runtime- oder Vector-Folgearbeit startet ohne Feldschema oder liest Schemafelder als echte Daten. | nein |
| M16T-ASSET-092 | [x] | Uferwald planning schema review | Das M16-DK-Feldschema muss fachlich reviewt werden, bevor ein JSON/YAML-Planning-Format-Gate vorbereitet wird. | `395-uferwald-planning-schema-review.md` bestaetigt M16-DK als ausreichend, verneint M16-DK-FIX und erlaubt M16-DM nur als enges Planning-Format-Gate ohne Runtime-Daten, finale Koordinaten, Polygone, Assets oder Code. | JSON/YAML-Formatarbeit startet ohne Review oder liest Schemafelder als echte Daten. | nein |
| M16T-ASSET-093 | [x] | Uferwald JSON/YAML planning format gate | Vor einer echten Planungsdatei braucht Uferwald eine Formatentscheidung und harte Datei-/Runtime-Grenzen. | `396-uferwald-json-yaml-planning-format-gate.md` bevorzugt YAML als spaeteres Planning-Format, definiert erlaubte Feldgruppen, Pflichtstatuswerte, verbotene Felder, Platzhalter und QA-Regeln, erzeugt aber keine `.json`, `.yaml`, `.yml`, Runtime-Daten, Koordinaten, Polygone, Assets oder Code. | Skeleton-Datei oder Runtime-naeheres Format entsteht ohne Format-Gate, Review und Statusschutz. | nein |

## 21. Datenmodell / Persistenz / Backend

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-DATA-001 | [!] | Datenmodell-Gate | Konzepte wie SemanticProfile sind noch keine Datenstruktur. | Eigenes Datenmodell-Gate mit Non-Goals und Tests existiert. | Finale Datenstruktur. | nein |
| M16T-DATA-002 | [!] | Persistence-Gate | Speicherung betrifft Datenschutz, Undo und Migration. | Persistenz-Gate mit lokaler/remote Strategie existiert. | Jede Persistenz. | nein |
| M16T-DATA-003 | [!] | Migration-Gate | Bestehende Daten duerfen nicht beschaedigt werden. | Migration- und Rollback-Plan inklusive Tests existiert. | DB-/SRS-Migration. | nein |
| M16T-DATA-004 | [x] | Offline/Sync-Konfliktregeln | Offline-first und spaetere Cloud brauchen Konfliktmodell. | Konfliktloesung fuer lokale und remote Entscheidungen dokumentiert ist. | Sync ohne Konfliktregel. | nein |
| M16T-DATA-005 | [!] | Supabase-Writes weiter blockieren | Backend-Writes brauchen explizite Freigabe. | Supabase-Write-Gate separat eroeffnet und freigegeben ist. | Supabase Writes. | nein |

## 22. Confidence Scoring / AI Governance

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-AI-001 | [x] | Confidence-Bands | Automatische Klassifikation braucht Unsicherheitsausgaenge. | Confidence-Bands und Ausgaenge dokumentiert sind. | Auto-Entscheidung bei Unsicherheit. | nein |
| M16T-AI-002 | [~] | AI-/Classification-Provider-Governance | Provider duerfen Privacy, Bias und Kosten nicht ungeplant beeinflussen. | Provider-, Privacy-, Bias- und Fallback-Regeln dokumentiert sind. | Produktive AI-Klassifikation. | nein |
| M16T-AI-003 | [x] | Low confidence landet in `NeedsUserChoice`/`Backlog`/`Codex` | Unsicherheit darf nicht sichtbar platzieren. | Low-confidence-Regel in Semantik-Gates uebernommen ist. | Low-confidence Placement. | nein |
| M16T-AI-004 | [~] | Privacy-Regeln fuer Wort-/Kontextklassifikation | Satz- und Importkontext kann privat sein. | Welche Daten lokal bleiben und was spaeter gesendet werden darf dokumentiert ist. | Klassifikation ohne Privacy-Gate. | nein |

## 23. Review Queue

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-QUEUE-001 | [x] | Review-Queue-Konzept | Viele Woerter brauchen geordnete Entscheidungspfade. | Queue-Typen, Filter, Prioritaeten und Ausgaenge dokumentiert sind. | Massenentscheidungs-UI. | nein |
| M16T-QUEUE-002 | [x] | Session-Budget | Nutzer darf nur wenige Entscheidungen pro Sitzung sehen. | Session-Budget als Planungsregel existiert. | Review-Zwang. | nein |
| M16T-QUEUE-003 | [x] | Queue-Ausgaenge | Review muss sichere Ausgaenge haben. | Confirm, Change, Later, Codex, Backlog, Blueprint, Hide dokumentiert sind. | Sackgassen-Review. | nein |
| M16T-QUEUE-004 | [x] | Queue-Prioritaet nach Risiko und Lernrelevanz | Nicht jedes Wort ist gleich wichtig. | Risiko/Lernrelevanz/Confidence/Nutzerziel priorisiert sind. | FIFO ohne Risiko. | nein |

## 24. Technische Architektur / App-Integration

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-ARCH-001 | [!] | Architecture/Boundary Gate | Lern-, Welt-, Companion-, Social- und Rendering-Logik muessen getrennt bleiben. | Boundaries und erlaubte Abhaengigkeiten dokumentiert sind. | Direkte Kopplung Learning -> Renderer. | nein |
| M16T-ARCH-002 | [!] | App-Integration weiter blockieren | Lokale Previews sind keine produktiven Screens. | App-Integration-Gate separat freigegeben ist. | Home/World/Onboarding-Integration. | nein |
| M16T-ARCH-003 | [!] | Route-Gate | Neue Routen koennen Produktfluss veraendern. | Route-Gate mit UX, Guardrails und Tests existiert. | Route/neue Seite. | nein |
| M16T-ARCH-004 | [!] | Test-/Performance-/Accessibility-Gate | Produktive Systeme brauchen technische Pruefung. | Test-, Perf- und A11y-Plan freigegeben ist. | Produktive Implementierung ohne Pruefung. | nein |

## 25. Dokumentations- und Visual-QA

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-DOC-001 | [x] | Dokumentationslandkarte | Die vielen Docs muessen auffindbar bleiben. | Dokumentenkarte M16-S/T und relevante Gates verlinkt. | Prompts lesen falsche Grundlage. | nein |
| M16T-DOC-002 | [x] | Pflichtlektuere-Regel pro Slice-Typ | Unterschiedliche Slice-Typen brauchen andere Pflichtdocs. | Slice-Typen mit Pflichtlektuerelisten dokumentiert sind. | Unvollstaendige Quellenlage. | nein |
| M16T-DOC-003 | [~] | Visual-QA-Regel | Diagramme muessen lesbar und ueberlappungsfrei bleiben. | Text-Containment, Innenabstand, Kartenabstand, Footer, Contact Sheet geprueft werden. | Unlesbare Visuals. | nein |
| M16T-DOC-004 | [!] | Keine Screenshots als Repo-Artefakte | Screenshots koennen App-Screens oder falsche Freigabe suggerieren. | Dokumentationsvisuals bleiben generiert/gezeichnet, nicht Screenshot-Artefakte. | Screenshot-Dateien. | nein |
| M16T-DOC-005 | [x] | Codex prompt compression gate | Lange Prompts sollen kuerzer werden, ohne Sicherheitsregeln zu verlieren. | `369-codex-prompt-compression-and-slice-template-gate.md` definiert AGENTS.md/328/336/Templates-Rollen, Kurzprompt-Pflichtfelder, geerbte Regeln, Risiken und Stop-Regeln. | Kurzprompts ohne Repo-verankerte Regeln. | nein |
| M16T-DOC-006 | [x] | Slice prompt templates | Wiederkehrende Slice-Arbeit braucht robuste Vorlagen statt Prompt-Flut. | `docs/world_design/prompt_templates/` enthaelt README sowie Templates fuer Docs-only, Review, Art/Master-Reference, Visual Documentation und Implementation Slices. | Template-Flut, fehlende Templates oder Templates als Implementierungsfreigabe. | nein |
| M16T-DOC-007 | [x] | Short prompt workflow with template inheritance | Kuerzere Prompts duerfen nicht vage werden. | Kurzprompt-Regel verlangt Slice-ID, Template, Ziel, erwartete Dateien/Bereiche, besondere Grenzen und Commit-Status; 336 und Templates liefern Pflichtlektuere, Stop-Regeln, Checks und Output-Regeln. | Kurzprompt ohne Ziel, Dateien, Grenzen oder Commit-Status. | nein |

## 26. Commit-/Review-Hygiene

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-GIT-001 | [x] | `git status` vor Commit | Unbeabsichtigte Dateien sollen sichtbar bleiben. | Jeder Abschluss `git status --short` berichtet. | Commit ohne Status. | nein |
| M16T-GIT-002 | [x] | Scope gegen Stop-Regeln pruefen | Stop-Regeln verhindern Drift. | Jede Abschlussausgabe Stop-Regeln bestaetigt. | Drift in App/Assets/Persistenz. | nein |
| M16T-GIT-003 | [!] | Commit erst nach separater Freigabe | Review kann vor Commit noch korrigieren. | Nutzer gibt Commit explizit frei. | Automatischer Commit. | nein |
| M16T-GIT-004 | [x] | Template-based standard checks remain mandatory | Prompt-Kompression darf Checks nicht optional machen. | 369, 336 und Templates erben `git status --short`, `git diff --check`, Scope-Check und Abschlussbericht; Review-/Docs-/Art-/Visual-/Implementation-Templates nennen ihre Standardchecks. | Kurzprompt laesst Status, Diff, Scope oder Commit-Grenze fallen. | nein |

## 27. Aktueller Stand nach Erstellung

M16-T selbst erledigt:

- M16T-META-001

Teilweise vorbereitet durch M16-S/M16-R/M16-L und fruehere Dokumente:

- M16T-SCALE-001
- M16T-WORLD-002
- M16T-WHEEL-003
- M16T-SENS-003
- M16T-ASSET-002
- M16T-AI-003
- M16T-DOC-003

M16-U selbst erledigt:

- M16T-DASH-001
- M16T-DASH-002
- M16T-DASH-003
- M16T-SCRUM-001
- M16T-SCRUM-002
- M16T-SCRUM-003
- M16T-SCRUM-004
- M16T-SCRUM-005
- M16T-MVP-001
- M16T-MVP-002
- M16T-MVP-003
- M16T-CHANGE-001
- M16T-CHANGE-002
- M16T-CHANGE-003
- M16T-RESEARCH-001

M16-U teilweise vorbereitet (historisch, durch M16-V abgeschlossen):

- M16T-MVP-004

M16-V erledigt:

- M16T-MVP-004
- M16T-PROD-001
- M16T-PROD-002
- M16T-CORE-001
- M16T-CORE-002
- M16T-L2W-001
- M16T-L2W-002
- M16T-WOT-001
- M16T-REWARD-001
- M16T-QUEUE-001

M16-V teilweise vorbereitet:

- M16T-PROD-003
- M16T-CORE-003
- M16T-L2W-003

M16-W erledigt:

- M16T-WOT-002
- M16T-WOT-003
- M16T-WOT-004
- M16T-WOT-005
- M16T-WOT-006
- M16T-WOT-007
- M16T-WOT-008
- M16T-QUEUE-003
- M16T-REWARD-003

M16-X erledigt:

- M16T-REWARD-002
- M16T-QUEUE-002
- M16T-QUEUE-004
- M16T-SCALE-002
- M16T-SCALE-003
- M16T-SCALE-004

M16-Y erledigt:

- M16T-SEM-001
- M16T-SEM-002
- M16T-SEM-003
- M16T-SEM-004
- M16T-AI-001
- M16T-AI-003

M16-Z erledigt:

- M16T-REWARD-004
- M16T-REWARD-005
- M16T-COMP-001
- M16T-COMP-002
- M16T-COMP-003
- M16T-COMP-004
- M16T-SENS-001
- M16T-SENS-002

M16-AA erledigt:

- M16T-LEARN-001

M16-AA teilweise vorbereitet:

- M16T-LEARN-002
- M16T-AI-002
- M16T-AI-004

M16-AB erledigt:

- M16T-DOC-001
- M16T-DOC-002
- M16T-DASH-004
- M16T-META-002
- M16T-META-003
- M16T-META-004
- M16T-GIT-001
- M16T-GIT-002

M16-AC erledigt:

- M16T-MOBILE-001
- M16T-MOBILE-002
- M16T-MOBILE-003
- M16T-MOBILE-004
- M16T-DEPTH-001
- M16T-DEPTH-002

M16-AD erledigt:

- M16T-WORLD-001
- M16T-WORLD-003
- M16T-WHEEL-002
- M16T-WHEEL-004
- M16T-UNDO-001
- M16T-UNDO-002

M16-AE erledigt:

- M16T-WORLD-004
- M16T-UNDO-003
- M16T-DEPTH-003
- M16T-ASSET-003

M16-AF erledigt:

- M16T-GAME-001
- M16T-GAME-002
- M16T-GAME-003
- M16T-GAME-004

M16-AF teilweise vorbereitet:

- M16T-RESEARCH-004

M16-AG erledigt:

- M16T-SOCIAL-001

M16-AG teilweise vorbereitet:

- M16T-SOCIAL-002
- M16T-SOCIAL-003
- M16T-METRICS-001
- M16T-METRICS-002
- M16T-METRICS-003

M16-AG vertieft, bleibt aber teilweise vorbereitet:

- M16T-RESEARCH-004

M16-AH erledigt:

- M16T-ASSET-004
- M16T-DATA-004

M16-AI erledigt:

- M16T-RESEARCH-002
- M16T-RESEARCH-004
- M16T-METRICS-001
- M16T-METRICS-002
- M16T-METRICS-003

M16-AI bewusst unveraendert teilweise vorbereitet:

- M16T-LEARN-002
- M16T-AI-002
- M16T-AI-004

M16-AJ erledigt:

- M16T-RESEARCH-003
- M16T-SOCIAL-002
- M16T-SOCIAL-003

M16-AJ bewusst unveraendert:

- M16T-GAME-003
- M16T-GAME-004
- M16T-WORLD-002
- M16T-WHEEL-003

M16-AK erledigt:

- M16T-PLAY-001
- M16T-PLAY-002
- M16T-PLAY-003
- M16T-PLAY-004
- M16T-PLAY-005
- M16T-PLAY-007

M16-AK teilweise vorbereitet:

- M16T-PLAY-006
- M16T-PLAY-008

M16-AL erledigt:

- M16T-PLAY-006

M16-AL vertieft, bleibt teilweise vorbereitet:

- M16T-PLAY-008

M16-AM konkretisiert, bleibt teilweise vorbereitet:

- M16T-PLAY-008
- M16T-PROD-003
- M16T-CORE-003
- M16T-L2W-003
- M16T-SCALE-001
- M16T-WORLD-002
- M16T-WHEEL-003
- M16T-SENS-003
- M16T-ASSET-002

M16-AN konkretisiert, bleibt unveraendert teilweise/blockiert:

- M16T-PLAY-008
- M16T-CORE-003
- M16T-L2W-003
- M16T-ARCH-001
- M16T-ARCH-002
- M16T-ARCH-003
- M16T-ARCH-004
- M16T-DOC-003
- M16T-GIT-003

M16-AO angewendet und durch M16-AP als erledigt nachgewiesen:

- M16T-PLAY-008

M16-AP konkretisiert, bleibt blockiert/teilweise:

- M16T-ARCH-001
- M16T-ARCH-002
- M16T-ARCH-003
- M16T-ARCH-004
- M16T-DOC-003
- M16T-GIT-003

M16-AS erledigt:

- M16T-PLAY-009

M16-AS wendet weiter an:

- M16T-PLAY-008

M16-AX erledigt:

- M16T-INTERACT-001
- M16T-INTERACT-002
- M16T-INTERACT-003
- M16T-INTERACT-004
- M16T-INTERACT-005

M16-AX operationalisiert fuer kuenftige Slices:

- UI-Art pro Aktion nennen.
- Passung zu Aktion, Risiko, Informationsmenge und Spielkontext begruenden.
- Bewusst nicht gewaehlte Alternative nennen, z. B. kein Wheel, kein Drag,
  kein Popup oder keine neue Seite.

M16-AZ erledigt:

- M16T-INTERACT-006

M16-AZ operationalisiert fuer kuenftige Slices:

- Bei unklarer UI-/Spielaufbau-Entscheidung vor Umsetzung kurzen
  Benchmark-/Research-Check durchfuehren.
- Gepruefte Muster, gewaehltes Muster, passende Spiel-/UI-Logik und bewusst
  verworfene Alternativen berichten.

M16-BA erledigt:

- M16T-INFRA-001
- M16T-INFRA-002
- M16T-INFRA-003
- M16T-INFRA-004
- M16T-INFRA-005
- M16T-INFRA-006

M16-BA operationalisiert fuer kuenftige Slices:

- Starter-Insel-Grundform, freie Slots, Kategorie-Templates,
  Terrain-Varianten, Unlocks und BuildChoice als getrennte Ebenen behandeln.
- Fixe Infrastruktur darf Orientierung geben, aber Kategorien nicht hart
  blockieren.
- 8-12 sichtbare freie Slots, 4-6 sofort nutzbare Slots und 4-6 spaeter
  sichtbare Erweiterungsslots als Starter-Planungswert verwenden.
- Muenzen/Unlocks bleiben fachlich und druckfrei; keine Economy-, Timer-,
  Pay-to-Win- oder BuildState-Freigabe.

M16-BD erledigt:

- M16T-INFRA-007
- M16T-INFRA-008
- M16T-INFRA-009
- M16T-INFRA-010
- M16T-INFRA-011

M16-BD operationalisiert fuer kuenftige Slices:

- Die erste Starter-Insel traegt den Arbeitstitel `Uferhain`.
- Fuehrende Identitaet ist eine Kuestenhain-/Flussufer-Starterinsel mit
  Kueste, Flussarm, Hain, zentraler Lichtung, leichten Hoehen und ruhigen
  Randbereichen.
- Starter-Kategorie-Templates bleiben Zuhause, Garten, Markt, Werkstatt,
  Lager/Container, Wissen, Archiv/Wortarchiv, Spaeter/Ablage/Ruheort und
  Ufer/Wasser.
- Terrain erzeugt lokale Varianten wie `Markt am Ufer` oder `Zuhause im
  Hain`, blockiert Kategorien aber nicht hart.
- Future Island Families wie Wueste, Berg/Schnee, Hafen/Meer, Wald/Natur,
  Stadt/Dorf, Wissen/Archiv und Werkstatt/Technik bleiben nach MVP oder eigene
  Gates.

M16-BF erledigt:

- M16T-INFRA-012

M16-BF operationalisiert fuer kuenftige Slices:

- Sichtbare Nutzerkategorien verwenden Archiv/Wortarchiv statt Codex und
  Spaeter/Ablage/Ruheort statt Safe/Later/Backlog.
- Garage, Vorhof, Terrasse, Pool, Teich, Outdoor-Sauna und aehnliche
  Unterideen bleiben BuildChoice-/Showcase-Kandidaten unter Hauptkategorien,
  nicht Eintraege im ersten Kategorie-Wheel.

M16-BI erledigt:

- M16T-SPINE-001
- M16T-SPINE-002
- M16T-SPINE-003
- M16T-SPINE-004
- M16T-SPINE-005

M16-BI operationalisiert fuer kuenftige Slices:

- Talvori ist ein Aufbau-Spiel, dessen sichtbares Ziel Welt-, Grundstuecks-,
  Gebaeude-, Raum-, Container- und Detailausbau ist.
- Lernen ist der Motor des Aufbaus, aber nicht das sichtbare Pflichtgefuehl.
- Jeder kuenftige Lernspiel-Slice muss nennen, welche Bau-/Ausbau-/Welt-,
  Raum- oder Containeraktion die Lernhandlung unterstuetzt.
- Isolierte Lernmomente ohne Welt-/Bauzweck sind ab jetzt keine ausreichende
  Slice-Begruendung.
- Erstes empfohlenes Vertical Slice: Uferhain -> Startslot -> Kategorie
  Zuhause -> BuildChoice Haus -> Grundstueckszoom -> Fundament-Candidate ->
  spielerische Lernaufgabe -> lokales Feedback, ohne Persistenz.

M16-BJ erledigt:

- M16T-SPINE-006
- M16T-SPINE-007
- M16T-SPINE-008
- M16T-SPINE-009
- M16T-SPINE-010

M16-BJ operationalisiert fuer kuenftige Slices:

- Erster lokaler Vertical Slice ist verbindlich: Uferhain -> Startslot nahe
  zentraler Lichtung/Hub -> Kategorie Zuhause -> BuildChoice Haus ->
  Grundstueckszoom -> Fundament-Candidate -> Bauteile-sortieren-Lernhandlung
  -> lokales Fundament-Feedback.
- Grundstueckszoom ist nur lokale Preview-Ebene, keine Route, keine neue App-
  Seite, keine Navigation und kein Persistenzwechsel.
- Haus und Fundament bleiben Candidates/Previews; kein BuildState, kein
  `foundation_started`, keine Assets und keine Persistenz.
- Bank wird als isolierter naechster Code-Slice geparkt, bis der Moment in
  einen Bau-, Ufer-, Terrassen- oder Gartenauftrag eingebettet ist.
- Empfohlener Folge-Code-Slice ist M16-BK First Local Foundation Construction
  Preview, bevorzugt als isolierte lokale Preview-Datei statt weiterer
  Ueberladung des Starter-Island-Boards.

M16-BL erledigt:

- M16T-SPINE-011
- M16T-SPINE-012
- M16T-SPINE-013
- M16T-SPINE-014
- M16T-SPINE-015

M16-BL operationalisiert fuer kuenftige Slices:

- M16-BK hat den Spine technisch pruefbar gemacht, war aber visuell zu
  UI-lastig; die Preview wird nicht als naechste Richtung committet oder
  weitergefuehrt.
- Fuehrender Game-Flow ist jetzt: Insel-Showcase -> Insel betreten ->
  Grundstueck im Weltbild antippen -> Kamera/Fokus ins Grundstueck ->
  BuildChoice visuell waehlen -> Bauabschnitt im Grundstueck -> Lernhandlung
  als Bauaktion -> lokales Baufeedback.
- BuildChoice wie Haus/Garage/Terrasse/Teich braucht visuelle Vorschau,
  nicht ein kleines Wheel als Hauptentscheidung.
- Die erste Fundament-Lernhandlung muss am Bauplatz stattfinden; Text hilft
  nur, das Spielfeld traegt die Aufgabe.
- Empfohlener Folge-Code-Slice ist M16-BM Game-like Island Showcase to
  Foundation Camera Preview mit neuer isolierter Preview-Datei.

M16-BN erledigt:

- M16T-FUN-001
- M16T-FUN-002
- M16T-FUN-003
- M16T-FUN-004
- M16T-FUN-005
- M16T-FUN-006

M16-BN operationalisiert fuer kuenftige Slices:

- Jeder Gameplay-, World-, UI-, BuildChoice-, Learning- oder
  Implementierungs-Slice muss Player Hook, kleine Huerde, Spielhandlung,
  Belohnung/neue Moeglichkeit und naechsten freiwilligen Hook nennen.
- Erfolgreiche Spielmuster duerfen als Prinzipien uebertragen werden, aber
  nicht blind kopiert werden.
- Druckmuster wie Timer, Streak-Schuld, FOMO, Pay-to-Win, Lootbox/Gacha,
  Pflichtreview, Verlustangst und PvP/Leaderboard im MVP bleiben blockiert.
- Belohnung bedeutet in Talvori primaer neue Moeglichkeit: neuer Bauabschnitt,
  Blueprint-Idee, Fundstueck, Container, Tali/Vori-Hilfe, Archiv-Eintrag oder
  lokale Faehigkeit als Preview.
- M16-BM-FIX wird als technische Basis gelesen, braucht aber vor Commit oder
  naechstem Gate M16-BO Game-like Construction Hook Polish.

M16-BP erledigt:

- M16T-FUN-007
- M16T-FUN-008
- M16T-FUN-009
- M16T-FUN-010
- M16T-FUN-011

M16-BP operationalisiert fuer kuenftige Slices:

- Erfolgreiche Spielmuster werden konkret uebersetzt: Puzzle-Feld,
  Tactile-Order, Aufbau/Ownership, Sammeln/Oeffnen, Perspektivraetsel,
  Bedeutung-durch-Kontext, Mission/Action und Showcase/Identitaet.
- Object-first gilt fuer Bau-/Lernmomente: erst sichtbares Problem, Objekt und
  Ort, dann Text.
- Eine Foundation-Aufgabe muss ein Bauplatzproblem zeigen und durch die
  richtige Handlung sichtbar veraendern.
- Belohnung ist der naechste sichtbare Moeglichkeits-Hook, z. B.
  Aussenwand-Schatten statt Punkte/XP/Muenzen.
- Empfohlener Folge-Code-Slice ist M16-BQ Object-Based Foundation Buildsite
  Puzzle Preview, bevorzugt als neue isolierte Preview-Datei statt weiterer
  Ueberladung des M16-BM Multi-Island-Flows.

M16-BR erledigt:

- M16T-FUN-012
- M16T-FUN-013
- M16T-FUN-014
- M16T-FUN-015
- M16T-FUN-016

M16-BR operationalisiert fuer kuenftige Slices:

- Character-assisted World Actions sind als Pflichtpruefung fuer passende
  Bau-, Reparatur-, Sammel-, Container-, Werkstatt-, Objekt- und Weltaktionen
  dokumentiert.
- MVP-Default ist indirekte Steuerung: Spieler waehlt Ziel, Werkzeug,
  Material, Reihenfolge oder Objekt; Figur/Worker fuehrt sichtbar aus.
- Direkte Avatar-/Joystick-Steuerung bleibt bis eigenem UX-/Control-Gate
  blockiert.
- Worker-Loop ist definiert: Auftrag sichtbar -> Figur laeuft zum Ort ->
  sichtbare Arbeit -> Weltveraenderung -> neue Moeglichkeit -> naechster Hook.
- M16-BQ-FIX ist in der richtigen Richtung, braucht aber vor Commit die
  Pruefung, ob Worker-Bewegung und Arbeitsgeste wirklich Arbeitsloop und
  sichtbaren Construction Progress erzeugen.
- Empfohlener Folge-Code-Fix ist M16-BQ-FIX-2 Worker Task Loop and Visible
  Construction Progress.

M16-BS erledigt:

- M16T-FUN-017
- M16T-FUN-018
- M16T-FUN-019

M16-BS operationalisiert fuer kuenftige Slices:

- M16-BQ ist als object-based Worker-Bauplatz-Proof gut genug und committed;
  weiterer BQ-Polish ist nicht der naechste Produktbeweis.
- Der naechste Produktbeweis ist Flow-Rejoin: Uferhain -> Startslot ->
  Zuhause -> Haus -> Kamera/Fokus -> object-based Foundation Worker Moment ->
  lokales Fundament-Feedback -> `Aussenwaende spaeter`.
- Rejoin bedeutet nur lokale Preview-Verbindung, nicht App-Integration,
  Route, Navigation, Persistenz, BuildState, Provider, Shared Service oder
  produktive BuildChoice-Implementierung.
- BQ bleibt Muster und Referenz; es darf nicht automatisch als Produktmodul
  in den App-Flow gezogen werden.
- Empfohlener Folge-Code-Slice ist M16-BT Local Uferhain-to-Buildsite Rejoin
  Preview mit neuer isolierter Preview-Datei.

M16-BU erledigt:

- M16T-LANGUAGE-001
- M16T-LANGUAGE-002
- M16T-LANGUAGE-003
- M16T-LANGUAGE-004
- M16T-LANGUAGE-005
- M16T-LANGUAGE-006

M16-BU operationalisiert fuer kuenftige Slices:

- `AGENTS.md` ist die kurze Codex-Verfassung; ausfuehrliche Produkt-, Game-,
  Lern- und Sprachlogik lebt in `docs/world_design/talvori_game_bible.md`.
- Neue North Star: "Baue deine Welt. Lerne Sprache im Kontext. Sammle
  Woerter, Saetze und echte Sprachmomente. Wachse mit Tali, Vori und
  Freunden."
- Building creates context; learning uses context; language grows from words
  into sentences, pronunciation and conversations.
- World progress und language progress bleiben getrennte Systeme.
- Jede normale Session hat eine aktive Zielsprache; UI language, target
  language und Companion language sind getrennt.
- Interner kuratierter Content ist primaer; importierte/geteilte Woerter sind
  optionale persoenliche Entdeckungen.
- Kuenftige World-/Learning-/Onboarding-/Language-/App-Integration-Slices
  muessen die Game Bible lesen, wenn Produktidentitaet, Sprachschicht,
  Language Passport, Level/Scaffolding, Internal Corpus, Optional Capture oder
  Context Before Vocabulary betroffen sind.

M16-BV erledigt:

- M16T-MGMT-001
- M16T-MGMT-002
- M16T-MGMT-003
- M16T-MGMT-004

M16-BV operationalisiert fuer kuenftige Slices:

- `docs/world_design/362-notion-linear-project-management-mapping.md`
  definiert Repo, Notion, Linear und GitHub als getrennte Projektmanagement-
  Rollen.
- Das Repository bleibt Source of Truth fuer AGENTS.md, Game Bible,
  M16-Dokumente, Code, technische Entscheidungen, Stop-Regeln und Commits.
- Notion ist ein lesbarer Produkt-/Roadmap-/Research-/Decision-Spiegel, aber
  kein Ersatz fuer 328, 336 oder Repo-Gates.
- Linear ist ein Arbeits- und Slice-Tracking-Spiegel fuer Sprints, Bugs,
  Reviews, Visual-QA und Blocker, aber keine Produktfreigabe.
- GitHub traegt Code, Commits, Branches, PRs, technische Issues und spaetere
  Releases.
- Externe Writes in Notion, Linear, GitHub, Supabase, API-Key-Systemen oder
  anderen Plugins bleiben explizit freigabepflichtig.
- Empfohlener Produktschritt war M16-BT Local Uferhain-to-Buildsite Rejoin
  Preview; nach dem gestoppten M16-BT-WIP gilt M16-BW nun als professionelles
  Design-Gate vor weiterem Code. Ein spaeterer Notion Project Dashboard Draft
  bleibt sinnvoll, sobald externer Management-Sync wirklich gestartet werden
  soll.

M16-BW erledigt:

- M16T-DESIGN-001
- M16T-DESIGN-002
- M16T-DESIGN-003
- M16T-DESIGN-004

M16-BW operationalisiert fuer kuenftige Slices:

- M16-BT wurde gestoppt und als `wip m16-bt rejoin preview iterations`
  gestashed, weil direkter Code-Polish ohne freigegebenes Flow-/Layout-/
  UX-Modell zu unproduktiven Wiederholungen fuehrte.
- `docs/world_design/363-professional-island-build-flow-design-gate.md`
  definiert den professionellen Prozess Research/Benchmark -> schriftlicher
  Flow -> Low-Fidelity-Wireflow -> visuelle PNG/SVG- oder Figma-Konzeptphase
  -> Interaktionsregeln -> Visual-QA -> erst danach Code.
- Der Ziel-Flow bleibt Insel auswaehlen -> Insel betreten -> Map mit nativen
  Gesten bewegen/zoomen -> neutralen Slot frei waehlen -> BuildChoice direkt
  am Slot -> Grundstueck fokussieren -> Bauphase -> spaetere Tiefe in Haus,
  Raum, Moebel und Container.
- Starter-Insel-Designwert: ca. 12 sichtbare Slots im MVP, 6 sofort nutzbar,
  6 spaeter, langfristige Reserve ca. 16-20 Slots; Slots bleiben neutral und
  Terrain blockiert Kategorien nicht hart.
- Empfohlener naechster Schritt war M16-BX Low-Fidelity Island Build Flow
  Wireflow; dieser Stand wurde spaeter als
  `wip m16-bx low fidelity wireflow not accepted` gestashed, weil er formal
  korrekt, aber visuell zu schwach und zu arbeitsblattartig war.

M16-BY erledigt:

- M16T-DESIGN-007
- M16T-DESIGN-008
- M16T-DESIGN-009
- M16T-DESIGN-010

M16-BY operationalisiert fuer kuenftige Slices:

- `docs/world_design/365-modern-mobile-game-direction-board.md` definiert die
  moderne Talvori Game-DNA als cozy adventure construction world:
  island-first, object-first, character-assisted, context-based language
  learning, ohne Schul-/Worksheet- oder Menue-first-Gefuehl.
- Das Direction Board unter
  `docs/world_design/previews/m16_by_modern_mobile_game_direction_board/`
  setzt eine hochwertigere visuelle Grundlage als M16-BX: Hero-Phone,
  Game-DNA, Flow-Pillars, empfohlenes Pattern, Avoid-Liste und naechstes
  Konzeptziel.
- M16-BY macht `Cozy Island Diorama Builder` zur inhaltlichen Richtung:
  grosses 2.5D-Insel-Diorama, sichtbare Slots als Orte, Build Station am Slot
  als Weltobjekt, Worker/Tali/Vori als emotionale Spielbegleitung und klare
  Avoid-Liste gegen Schulblatt-, Corporate- und Menue-Optik.
- Das konkrete `modern_mobile_game_direction_board_v2.*` ist kein
  akzeptierter visueller Zielzustand. Es bleibt nur als abgelehnte
  Zwischenvorschau nachvollziehbar.
- Fuehrendes BuildChoice-Pattern ist nun `Build Station am Slot` mit
  fokussierter Auswahl; ein Wheel darf nur noch als kleiner Teil dieser
  Station dienen, nicht als alleinige Label-Wolke.
- Urspruenglich empfohlener naechster Schritt war M16-BZ High-Fidelity Island
  Build Flow Concept auf Basis der M16-BY-Richtung; der folgende M16-BZ-Nachtrag
  schiebt davor ein Art-Pipeline-Gate, damit High-Fidelity nicht wieder ohne
  Produktions- und Style-Konsistenz entsteht.

Nachtrag M16-BZ:

Der naechste Schritt wurde bewusst vorgeschaltet: Statt direkt High-Fidelity-
Screens zu bauen, klaert M16-BZ zuerst die KI-Art-Produktionspipeline und
Style-Konsistenz. High-Fidelity-Flow und Spielassets bleiben blockiert, bis
Art Bible, Master References und Asset-Family-Spec folgen.

M16-BZ erledigt:

- M16T-ART-001
- M16T-ART-002
- M16T-ART-003
- M16T-ART-004

M16-BZ operationalisiert fuer kuenftige Slices:

- `docs/world_design/366-ai-art-production-pipeline-and-style-consistency-gate.md`
  definiert die Rollen von ChatGPT, Codex, KI-Bildtool,
  Nachbearbeitungswerkzeugen und spaeterem Artist.
- Das starke M16-BY-Referenzbild ist Art-Direction-Reference und
  Dokumentationsmaterial, aber kein App-Screen und kein finales Asset.
- Codex darf Art Direction, Pipeline, Datei- und QA-Regeln dokumentieren, aber
  keine hochwertigen Spielbilder nachzeichnen oder als Produktionsbildgenerator
  auftreten.
- Talvori nutzt kuenftig kontrollierte Style-/Structure-Reference-Pipelines,
  ggf. LoRA/ControlNet, manuelle Nachbearbeitung und strenge Asset-QA statt
  freier Einzelprompts.
- Empfohlener Folgepfad ist M16-CA Talvori Art Bible v1 -> M16-CB Starter
  Island Master Reference Set -> M16-CC Asset Family and Export Spec.

M16-CA erledigt:

- M16T-ART-005
- M16T-ART-006
- M16T-ART-007
- M16T-ART-008
- M16T-ART-009
- M16T-ART-010

M16-CA operationalisiert fuer kuenftige Slices:

- `docs/world_design/367-talvori-art-bible-v1.md` definiert die Talvori Art
  Bible v1 als Style-System-Gate, nicht als Asset- oder Code-Freigabe.
- Fuehrende visuelle Sprache ist ein warmes, hochwertiges 2.5D-Cozy-Island-
  Diorama mit island-first, object-first, character-assisted und
  context-based language learning.
- Kamera, Perspektive, Insel-/Diorama-Proportionen, Licht, Farbpalette,
  Formensprache, Detailgrad, Kanten, Schatten und Materialgefuehl sind als
  gemeinsame Style-Regeln vor Master References festgelegt.
- Tali, Vori und Worker muessen zur Inselperspektive gehoeren und duerfen
  nicht wie fremde Sticker wirken.
- Build Station am Slot bleibt das fuehrende BuildChoice-Pattern; Wheel,
  Karten oder Listen duerfen nur untergeordnet helfen.
- UI, HUD und Bubbles muessen wie Spiel-HUD wirken, nicht wie Web-App,
  Dashboard, Worksheet oder Tutorial-Panel.
- Prompt-, Source- und Reference-Metadaten sowie QA-Regeln gegen Stilbruch
  sind Pflicht fuer spaetere Bild- oder Asset-Kandidaten.
- Der Folgepfad bleibt M16-CB Starter Island Master Reference Set -> M16-CC
  Asset Family and Export Spec -> erst danach High-Fidelity Flow oder
  Flutter-Code.

M16-CB erledigt:

- M16T-ART-011
- M16T-ART-012
- M16T-ART-013
- M16T-ART-014
- M16T-ART-015
- M16T-ART-016
- M16T-ART-017

M16-CB operationalisiert fuer kuenftige Slices:

- `docs/world_design/368-starter-island-master-reference-set.md` definiert
  Master-Reference-Briefs, nicht Assets, Bilddateien, App-Screens oder Code.
- Uferhain ist als Kuestenhain-/Flussufer-Starterinsel mit Kueste, Flussarm,
  Hain, zentraler Lichtung/Hub, leichten Hoehen, ruhigen Randbereichen,
  12 sichtbaren Slots, 6 freien Slots, 6 spaeteren Slots, Reserve 16-20 und
  neutralen Slots eingegrenzt.
- Build Station am Slot bleibt das fuehrende BuildChoice-Pattern als
  Weltobjekt: Haus als Hauptidee, Garten/Werkstatt/Garage als ruhigere
  Alternativen, Wheel nur untergeordnet, kein Menue, kein Shop, kein Bottom
  Sheet, keine Label-Wolke.
- Haus-Bauphasen, Worker/Tali/Vori, UI/HUD/Bubbles und
  Slot/Marker/Layer-Erwartungen sind als Reference-Briefs fuer M16-CC
  vorbereitet.
- Der Folgepfad bleibt M16-CC Asset Family and Export Spec -> danach erst
  High-Fidelity Flow oder Flutter-Code pruefen.

M16-CD erledigt:

- M16T-DOC-005
- M16T-DOC-006
- M16T-DOC-007
- M16T-GIT-004

M16-CD operationalisiert fuer kuenftige Slices:

- `docs/world_design/369-codex-prompt-compression-and-slice-template-gate.md`
  definiert das Zielmodell fuer kuerzere Codex-Prompts ohne Verlust von
  Pflichtlektuere, Stop-Regeln, M16-T-ID-Abgleich, Checks, Output-Regeln,
  Commit-Grenzen oder External-Write-Grenzen.
- `docs/world_design/prompt_templates/` enthaelt wiederverwendbare
  Arbeitsvertraege fuer Docs-only, Review, Art/Master-Reference, Visual
  Documentation und Implementation Slices.
- Kurzprompts muessen kuenftig mindestens Slice-ID, Template, Ziel, erwartete
  Dateien oder Bereiche, besondere Grenzen und Commit-Status nennen.
- Templates ersetzen 336 nicht, sondern erben Routing, Pflichtlektuere und
  Standardchecks aus 336.
- Der Folgepfad bleibt: M16-CC kann danach mit Kurzprompt und Template
  `art_master_reference_slice` gestartet werden.

M16-CC erledigt:

- M16T-ASSET-005
- M16T-ASSET-006
- M16T-ASSET-007
- M16T-ASSET-008
- M16T-ASSET-009
- M16T-ASSET-010
- M16T-ASSET-011
- M16T-ASSET-012

M16-CC operationalisiert fuer kuenftige Slices:

- `docs/world_design/370-asset-family-and-export-spec.md` definiert
  Asset-Familien, Layer-Erwartungen, Exportformate, Groessen-/Skalierung,
  Benennung, Source-/Prompt-/Reference-Metadaten und QA-Status.
- 370 klaert, was spaeter ueberhaupt nach `assets/` darf, aber nur nach
  eigenem Asset-Gate.
- `reference_note`, `style_reference`, `structure_reference`,
  `master_reference`, `asset_candidate`, `engine_ready_candidate`,
  `approved_asset` und `blocked_asset` sind als getrennte Statusstufen
  dokumentiert.
- M16T-ASSET-001 bleibt blockiert: echte Asset-Dateien, Engine-ready
  Candidates, Produktintegration und App-Code brauchen weiterhin ein eigenes
  Asset-Gate.
- Der Folgepfad bleibt: Review/Commit von M16-CD + M16-CC -> danach erst ein
  einzelnes Asset-Gate wie M16-CE Starter Island Asset Candidate Gate.

M16-CE erledigt:

- M16T-ASSET-013
- M16T-ASSET-014
- M16T-ASSET-015
- M16T-ASSET-016
- M16T-ASSET-017

M16-CE operationalisiert fuer kuenftige Slices:

- `docs/world_design/371-starter-island-asset-candidate-gate.md` entscheidet
  `island_base` als erste Starter-Island-Candidate-Familie.
- `terrain_layers`, `slot_markers`, `build_stations` und `building_phases`
  bleiben nachgelagert, weil sie eine stabile Inselbasis, Perspektive und
  Uferhain-Silhouette brauchen.
- M16-CF darf echte `asset_candidate`-Erzeugung nur dann oeffnen, wenn der
  Folgeprompt Bildgenerierung, Dokumentationspfad, Tool-Rolle, Metadaten,
  Lizenz-/Source-Grenzen und QA ausdruecklich erlaubt.
- Dateien unter `assets/`, Engine-ready Candidates, approved Assets,
  App-Integration und Flutter-Code bleiben weiterhin blockiert.

M16-CF erledigt:

- M16T-ASSET-018
- M16T-ASSET-019
- M16T-ASSET-020
- M16T-ASSET-021
- M16T-ASSET-022
- M16T-ASSET-023

M16-CF operationalisiert fuer kuenftige Slices:

- `docs/world_design/372-starter-island-base-candidate-generation-gate.md`
  definiert den einzigen spaeter erlaubten Dokumentationspfad fuer M16-CG,
  ohne ihn jetzt zu erzeugen.
- M16-CG darf spaeter nur 2-3 `island_base`-Dokumentationscandidates,
  Contact Sheet und Metadata-Datei erzeugen, wenn der Folgeprompt Bilder
  ausdruecklich erlaubt.
- Prompt, Negative Prompt, Tool-Rollen, Dateinamen, Metadaten und Uferhain-QA
  sind vor der ersten Bildgenerierung festgelegt.
- Maximalstatus fuer M16-CG bleibt `asset_candidate`; `engine_ready_candidate`,
  `approved_asset`, Dateien unter `assets/`, Flutter-Code und App-Integration
  bleiben blockiert.

M16-CG erledigt:

- M16T-ASSET-024
- M16T-ASSET-025
- M16T-ASSET-026
- M16T-ASSET-027
- M16T-ASSET-028
- M16T-ASSET-029

M16-CG operationalisiert fuer kuenftige Slices:

- `docs/world_design/previews/m16_cg_starter_island_base_candidate_generation/`
  enthaelt drei `island_base`-Dokumentationscandidates fuer Uferhain, ein
  Contact Sheet und eine Metadata-/QA-Datei.
- Die Candidate-PNGs sind Dokumentationsmaterial mit Maximalstatus
  `asset_candidate`: keine finalen Spielbilder, keine App-Screens, keine
  Engine-ready Candidates und keine approved Assets.
- Die Kandidaten bleiben ausserhalb von `assets/` und duerfen nicht ohne
  eigenes Asset-/Layer-/Engine-ready-Gate in Flutter oder Produktlogik
  ueberfuehrt werden.
- Candidate A ist die staerkste erste Struktur fuer Uferhain; Candidate B
  braucht wegen pad-/kartenartiger Terrassen Review; Candidate C braucht wegen
  starker Hoehen-/Wasserfallbetonung Review.
- Der Folgepfad bleibt: Review/Commit von M16-CG -> Entscheidung, ob ein
  Candidate verworfen, ueberarbeitet oder in ein spaeteres Asset-/Layer-/
  Engine-ready-Gate ueberfuehrt wird.

M16-CI erledigt:

- M16T-ASSET-030
- M16T-ASSET-031
- M16T-ASSET-032
- M16T-ASSET-033
- M16T-ASSET-034
- M16T-ASSET-035

M16-CI operationalisiert fuer kuenftige Slices:

- `docs/world_design/373-candidate-a-structure-lock-and-postprocess-brief.md`
  sperrt Candidate A als primaere Uferhain-`island_base`-Strukturreferenz.
- Candidate A wird nicht als Asset, finales Zielbild, Engine-ready Candidate,
  approved Asset, App-Screen, Produktdatei oder Flutter-/Runtime-Grundlage
  uebernommen.
- Candidate-A-Strukturregeln beschreiben Silhouette, Wasser-/Kuestenbezug,
  Flussarm, zentrale Lichtung, Hainzone, ruhige Randbereiche, Hoehenlogik,
  ca. 12 neutrale Slot-Reserven und langfristige 16-20-Slot-Reserve.
- 373 definiert Postprocess-Regeln gegen monolithisches Bild, feste Pads,
  Kategorieplaetze, eingebackte Slots/Stationen, UI/Texte/Gebaeude/Figuren
  und gegen Verlust von Mobile-Lesbarkeit oder 2.5D-Diorama-Perspektive.
- Candidate B und Candidate C bleiben sekundaere Review-Referenzen, aber nicht
  Primary.
- Der Folgepfad bleibt: M16-CJ Candidate A Layer and Postprocess Plan vor neuen
  Bildern, Engine-ready, Assets oder Flutter-Code.

M16-CJ erledigt:

- M16T-ASSET-036
- M16T-ASSET-037
- M16T-ASSET-038
- M16T-ASSET-039
- M16T-ASSET-040
- M16T-ASSET-041
- M16T-ASSET-042

M16-CJ operationalisiert fuer kuenftige Slices:

- `docs/world_design/374-candidate-a-layer-and-postprocess-plan.md`
  uebersetzt Candidate A in einen konkreten Layer- und Postprocess-Plan, ohne
  das Pixelbild als Asset, Zielbild, Engine-ready Candidate oder Runtime-Basis
  zu uebernehmen.
- Die verbindliche Layer-Reihenfolge lautet: `island_base`, `water_paths`,
  `terrain_layers`, neutrale `slot_markers`, danach `build_stations`,
  `building_phases`, `workers_companions` und `ui_hud_bubbles`.
- 374 trennt, was aus Candidate A strukturell uebernommen wird
  (Silhouette, Wasserbezug, Flussarm, Lichtung, Hain, ruhige Randbereiche,
  Hoehenlogik und Slot-Reserve) und was nicht uebernommen wird
  (Pixelqualitaet, monolithisches Gesamtbild, feste Pads, Kategorieplaetze,
  eingebackene Wege, UI, Figuren oder Gebaeude).
- Neue Bildgenerierung bleibt fuer M16-CJ ausgeschlossen. Spaetere visuelle
  Arbeit braucht ein eigenes Freigabe-Gate mit Rollen, Pfaden, Metadaten und
  QA.
- Der Folgepfad bleibt: M16-CK Candidate A External Postprocess and Layer
  Production Brief vor Engine-ready, `assets/` oder Flutter-Code.

M16-CK erledigt:

- M16T-ASSET-043
- M16T-ASSET-044
- M16T-ASSET-045
- M16T-ASSET-046
- M16T-ASSET-047
- M16T-ASSET-048

M16-CK operationalisiert fuer kuenftige Slices:

- `docs/world_design/375-candidate-a-external-postprocess-and-layer-production-brief.md`
  beschreibt, wie spaetere externe Bild-/Figma-/Artist-Arbeit Candidate A nur
  als Strukturreferenz nutzt und nicht als Pixelziel uebernimmt.
- 375 trennt Rollen: ChatGPT/image_gen darf spaeter nur nach separater
  Freigabe Bildvarianten erzeugen; Figma/Photopea/Photoshop/Aseprite/Artist
  duerfen spaeter Layering, Zuschnitt, Paintover und Strukturkorrektur
  vorbereiten; Codex bleibt bei Metadaten, QA, Dateinamen, Repo-Doku und
  Checks.
- 375 definiert externe Ziel-Layer fuer `island_base`, `water_paths`,
  `terrain_layers`, `slot_markers` und optional spaeter `build_stations`.
- 375 schlaegt spaetere Dokumentationspfade nur unter
  `docs/world_design/previews/` und stabile Dateinamen fuer Layer-Candidates,
  Metadata und Contact Sheet vor, erstellt diese Dateien aber nicht.
- Der erlaubte Maximalstatus fuer solche spaeteren Layer-Vorschlaege ist
  `layer_postprocess_candidate`; `engine_ready_candidate`, `approved_asset`,
  `assets/`, Flutter/App-Integration und Produktivmechanik bleiben blockiert.

M16-CL erledigt:

- M16T-ASSET-049
- M16T-ASSET-050
- M16T-ASSET-051
- M16T-ASSET-052
- M16T-ASSET-053
- M16T-ASSET-054
- M16T-ASSET-055
- M16T-ASSET-056

M16-CL operationalisiert fuer kuenftige Slices:

- `docs/world_design/376-anchor-registration-and-placement-logic-gate.md`
  macht Canvas, Framing, Origin/Pivot, Anchor Points, Placement-Zonen,
  No-Build-/No-Overlap-Zonen, Layer-Reihenfolge und Depth-/Sorting zu
  Pflichtpruefungen vor weiterer Bild-/Layerarbeit.
- Pflicht-Anchors fuer Uferhain sind u. a. `main_build_area_anchor`,
  `house_primary_anchor`, `hub_center_anchor`, `river_entry_anchor`,
  `river_exit_anchor`, `grove_anchor`, `reserve_zone_anchor_north` und
  `reserve_zone_anchor_south`.
- 376 trennt Anchor Points von Placement-Zonen und stellt klar: neutrale
  Reserve ist noch keine echte Platzierung, kein BuildState und keine
  Persistenz.
- Kuenftige Bild-/Layer-/Candidate-Slices sind nicht commitfaehig, wenn
  Canvas-Regel, Framing, Origin/Pivot, Anchors, Placement-Zonen,
  No-Build-/No-Overlap-Zonen, Layer-Reihenfolge, Sorting oder
  Ueberlagerbarkeit fehlen.
- 376 ist keine Bild-, Asset-, Code-, App-, Engine-ready- oder
  `assets/`-Freigabe.

M16-CM erledigt:

- M16T-ASSET-057
- M16T-ASSET-058
- M16T-ASSET-059
- M16T-ASSET-060
- M16T-ASSET-061
- M16T-ASSET-062
- M16T-ASSET-063
- M16T-ASSET-064

M16-CM operationalisiert fuer kuenftige Slices:

- `docs/world_design/377-candidate-a-anchor-manifest-and-layer-generation-brief.md`
  uebersetzt Candidate A in ein konkretes Anchor-/Placement-/Registration-
  Manifest mit Canvas-Family, Canvas-Origin, World-Origin, Layer-Pivot,
  Coordinate Space, Framing Lock und `rough_from_structure`-Status.
- 377 dokumentiert Pflicht-Anchors wie `main_build_area_anchor`,
  `house_primary_anchor`, `hub_center_anchor`, `river_entry_anchor`,
  `river_exit_anchor`, `grove_anchor`, `reserve_zone_anchor_north` und
  `reserve_zone_anchor_south` sowie optionale Zusatz-Anchors fuer Uferhain.
- 377 trennt Placement-Zonen, No-Build-Zonen, No-Overlap-Zonen,
  Water-only-Zonen und terrain-sensitive Bereiche, damit Reserveflaechen
  neutral bleiben und nicht als Kategorieplaetze gelesen werden.
- 377 beschreibt fuer `island_base`, `water_paths`, `terrain_layers`,
  `slot_markers` und blockierte `build_stations`, welche Anchors und Zonen
  spaetere Layer-Candidates erhalten oder respektieren muessen.
- Kuenftige Bild-/Layer-Slices sind nicht commitfaehig, wenn Anchor-Manifest,
  Placement-Zonen, No-Build-/No-Overlap-Zonen, Depth-/Sorting oder
  Candidate-A-Strukturreferenzschutz fehlen.
- 377 ist keine Bild-, Asset-, Code-, App-, Engine-ready- oder
  `assets/`-Freigabe; Candidate A bleibt Strukturreferenz, kein Pixelziel.

M16-CN erledigt:

- M16T-ASSET-065
- M16T-ASSET-066
- M16T-ASSET-067
- M16T-ASSET-068
- M16T-ASSET-069
- M16T-ASSET-070
- M16T-ASSET-071
- M16T-ASSET-072

M16-CN operationalisiert fuer kuenftige Slices:

- `docs/world_design/378-first-uferhain-layer-postprocess-candidate-permission-gate.md`
  entscheidet: In M16-CN selbst entstehen keine Bilder; ein spaeterer
  M16-CO-Folgeprompt darf aber unter engen Bedingungen erste
  Uferhain-`island_base`-Layer-Postprocess-Bildarbeit oeffnen.
- Erste erlaubte Familie fuer M16-CO ist `island_base`; `water_paths` ist nur
  optional, wenn es fuer Registration noetig ist. `terrain_layers`,
  `slot_markers` als Bild, `build_stations`, `building_phases`,
  `workers_companions` und `ui_hud_bubbles` bleiben blockiert.
- Erlaubter spaeterer Pfad ist ausschliesslich
  `docs/world_design/previews/m16_co_first_uferhain_layer_postprocess_candidate/`.
  Dateien unter `assets/` bleiben blockiert.
- Maximalstatus fuer M16-CO ist `layer_postprocess_candidate`. Engine-ready,
  approved Asset, production/runtime/app asset und Produktintegration bleiben
  blockiert.
- M16-CO ist nicht commitfaehig, wenn Anchor-/Registration-Logik,
  Placement-Zonen, No-Build-/No-Overlap-Zonen, Sort-Bands, Metadaten,
  Anchor-Manifest oder Pfad-/Statusschutz fehlen.
- Codex bleibt auch nach dem Permission Gate bei Intake, Metadaten, QA,
  Dateieinordnung und Checks; Bildgenerierung muss im Folgeprompt explizit
  fuer ChatGPT/image_gen oder ein extern benanntes Tool geoeffnet werden.

M16-CP erledigt:

- M16T-ASSET-073
- M16T-ASSET-074
- M16T-ASSET-075
- M16T-ASSET-076
- M16T-ASSET-077
- M16T-ASSET-078
- M16T-ASSET-079
- M16T-ASSET-080

M16-CP operationalisiert fuer kuenftige Slices:

- `docs/world_design/379-uferwald-layer-candidate-intake-and-qa.md`
  uebernimmt genau eine freigegebene lokale Uferwald-`island_base`-Datei aus
  Downloads in den Docs-Preview-Pfad und dokumentiert sie als
  `layer_postprocess_candidate`.
- Der M16-CP-Preview-Ordner enthaelt 1x/2x/3x-Review-Kopien, ein Contact
  Sheet, Metadata, gemessene Doku-Anker und QA. Diese Dateien sind
  Dokumentationsmaterial, keine Assets, keine App-Screens, keine
  Engine-ready Candidates und keine Produktionsdateien.
- Die gemessenen Anchor-Koordinaten gelten nur fuer das aktuelle Kandidaten-
  Bitmap: `measured_on_candidate_bitmap_not_final_runtime_anchor`.
- 1x/2x/3x sind Review-Kopien. 2x und 3x sind Upscales ohne neue
  Source-Details und duerfen nicht als produktive Exportqualitaet gelesen
  werden.
- Echte transparente Einzel-Layer und separate Familien wie `water_paths`,
  `terrain_layers` oder `slot_markers` sind weiterhin nicht vorhanden und
  blockiert, bis ein eigener externer/Layer-Postprocess-Slice sie erzeugt und
  prueft.

M16-CQ Review-/Decision-Folge ohne neue M16-T-IDs:

- `docs/world_design/380-uferwald-layer-candidate-review-and-postprocess-decision.md`
  entscheidet, dass Uferwald als Arbeitsname fuer diesen Candidate und als
  fuehrende Struktur-/Postprocess-Referenz weitergefuehrt wird.
- Uferhain bleibt als bestehende Design-/Docs-Linie erhalten; M16-CQ trifft
  keine finale Produkt- oder Inselbenennung.
- Der Candidate wird nicht als Pixelziel, Asset, Engine-ready Basis,
  approved Asset oder Produktdatei uebernommen.
- Fuer spaetere externe Layerarbeit ist Uferwald nur teilweise geeignet:
  stark als Struktur-/Stimmungs-/Registration-Referenz, aber nicht als direkt
  zerschneidbare Produktionsgrafik.
- Naechster empfohlener Slice ist M16-CR Uferwald Anchor, Zone and Layer
  Overlay Plan. Erst danach sollte Paintover, Layer-Separation, Water-Paths
  oder Terrain-/No-Build-Folgearbeit geoeffnet werden.

M16-CR Visual-Documentation-Folge ohne neue M16-T-IDs:

- `docs/world_design/381-uferwald-anchor-zone-layer-overlay-plan.md`
  dokumentiert den visuellen Overlay-Plan fuer Uferwald-Anchors,
  Buildable/Soft/Reserve-Zonen, No-Build/No-Overlap/Water-only/
  Terrain-sensitive-Zonen, grobe Sort-Bands und spaetere Layer-Reihenfolge.
- Der neue M16-CR-Preview-Ordner enthaelt PNG und SVG als
  Dokumentationsvisuals ueber dem M16-CP-1x-Bild.
- Die Overlays sind Planungsgeometrie und keine Runtime-Anchor-Daten, keine
  separaten Layer, keine transparenten Layer, keine Assets und keine
  Engine-ready Candidates.
- Naechster empfohlener Slice ist M16-CS Uferwald External Layer Separation
  Brief, bevor externe Paintover-/Layerarbeit oder echte Layer-Candidates
  geoeffnet werden.

M16-CV erledigt:

- M16T-WORLD-005
- M16T-WORLD-006
- M16T-WORLD-007

M16-CV operationalisiert fuer kuenftige Slices:

- `docs/world_design/383-talvori-camera-modes-and-visit-wander-rule.md`
  definiert Build/Map Camera, Overview Camera, Visit/Wander Camera und Object
  Focus Camera als Pflichtpruefung fuer kuenftige World-/Map-/Build-/UI-/
  Asset-Entscheidungen.
- Uferwald Map-/Build-Modus ist nicht automatisch Wander-/Besucher-Modus.
  Spaetere Cloud-/Besucheransichten und individuell begehbare Nutzerinseln
  muessen von Anfang an mitgedacht werden.
- Keine Architektur darf nur auf ein statisches Posterbild oder eine einzige
  Map-Kamera ausgelegt werden. Overview und Object Focus sind eigene Modi und
  keine impliziten Defaults.
- 383 ist ein Docs-Gate: kein Code, keine Bilder, keine Assets, keine Route,
  keine Persistenz, kein BuildState und keine App-Integration.
- Naechster sinnvoller Folge-Slice ist M16-CW Uferwald Camera Modes Preview
  Toggle, falls weiterhin isoliert und ohne App-/Asset-/Persistenzfreigabe.

M16-DA erledigt:

- M16T-ASSET-081

M16-DA operationalisiert fuer kuenftige Slices:

- `docs/world_design/384-uferwald-playable-map-layer-and-mask-architecture.md`
  definiert: sichtbares Art-Bild ist nicht die technische Spielkarte.
- Visit/Wander darf Wege, Walkability, Hindernisse oder Sortierung nicht aus
  einem fertigen Bild erraten.
- Build/Map darf Grundstuecke, Build-Zonen, Footprints oder No-Build-Masks
  nicht aus einem fertigen Bild erraten.
- Vor Rendering, Layer-Art oder simulierter Navigation muessen technische
  Layer/Masks/Zonen wie `walkable_path_layer`, `buildable_zone_layer`,
  `no_walk_mask`, `no_build_mask`, `depth_sort_bands` und
  `landmark_anchor_layer` definiert sein.
- M16-CY-FIX-3 bleibt ein gutes UX-Risiko-Beispiel: schoener Look und
  spielerische Stationen reichen nicht fuer produktionsfaehige Navigation,
  solange der Pfadverlauf aus Pixeln interpretiert werden muss.
- 384 ist ein Docs-/Architecture-Gate: kein Code, keine Bilder, keine Assets,
  keine Runtime-Mapdaten, keine App-Integration, keine Persistenz und kein
  BuildState.
- Naechster sinnvoller Folge-Slice ist M16-DB Uferwald Technical Layer and
  Mask Spec.

M16-DB erledigt:

- M16T-ASSET-082

M16-DB operationalisiert fuer kuenftige Slices:

- `docs/world_design/385-uferwald-technical-layer-and-mask-spec.md`
  konkretisiert die technischen Uferwald-Ebenen aus M16-DA.
- Die Spec definiert Zweck, spaetere Datenform, Nutzer-Modi und
  Nicht-Ableitungsregeln fuer `base_rock_shape`, `grass_terrain_mask`,
  `water_river_mask`, `walkable_path_layer`, `tree_obstacle_layer`,
  `rock_cliff_obstacle_layer`, `buildable_zone_layer`,
  `plot_footprint_layer`, `no_walk_mask`, `no_build_mask`,
  `depth_sort_bands` und `landmark_anchor_layer`.
- M16-CY-FIX-3 bleibt als verworfener Risiko-Proof dokumentiert:
  spielerische Stationen und ein sichtbarer Marker reichen nicht, wenn Wege,
  Walkability und Kollision weiter aus einem fertigen Bild geraten werden.
- Der naechste sinnvolle Folge-Slice ist M16-DC Uferwald Technical Layer
  Manifest, noch ohne App-Integration, Assets, Bilder, Runtime-Mapdaten oder
  Code.

M16-DC erledigt:

- M16T-ASSET-083

M16-DC operationalisiert fuer kuenftige Slices:

- `docs/world_design/386-uferwald-technical-layer-manifest.md` definiert
  `map_id: uferwald_starter_island` und `coordinate_space: normalized_0_1`
  als erste maschinennahe Planungsstruktur.
- Das Manifest listet alle technischen Layer-IDs mit `type`, `purpose`,
  `data_form_candidate`, `source_status`, `allowed_modes`, `blocked_uses`
  und `open_measurements`.
- Geplante Anchor-IDs wie `startplatz_anchor`, `main_build_area_anchor`,
  `hub_center_anchor`, `river_entry_anchor`, `river_exit_anchor`,
  `grove_anchor` und `aussichtspunkt_anchor` sind benannt, aber ohne finale
  Koordinaten und ohne Runtime-Status.
- Offene Messfragen zu echten Wegen, Wassergrenzen, Baum-/Felsblockern,
  organischen Build-Zonen und Sort-Bands sind nun explizit blockiert, bis ein
  eigener Mess-/Vector-Plan-Slice sie klaert.
- Der naechste sinnvolle Folge-Slice ist M16-DD Uferwald Technical Measurement
  and Vector Planning Gate, weiterhin ohne Code, Assets, Bilder,
  Runtime-Mapdaten oder App-Integration.

M16-DD erledigt:

- M16T-ASSET-084

M16-DD operationalisiert fuer kuenftige Slices:

- `docs/world_design/387-uferwald-technical-measurement-and-vector-planning-gate.md`
  definiert die Mess-/Vector-Reihenfolge fuer `base_rock_shape`,
  `water_river_mask`, `tree_obstacle_layer`, `rock_cliff_obstacle_layer`,
  `walkable_path_layer`, `landmark_anchor_layer`, `buildable_zone_layer`,
  `plot_footprint_layer`, `no_walk_mask`, `no_build_mask` und
  `depth_sort_bands`.
- Composite-Masks duerfen spaeter nur aus technischen Source-Layern abgeleitet
  werden; automatische Ableitung aus Pixelbildern bleibt blockiert.
- Figma, SVG, JSON/YAML und manuelle Polygonplanung sind nur als moegliche
  spaetere Planungsformen genannt; M16-DD erzeugt keine solchen Dateien.
- M16-CY-FIX-3 bleibt Risiko-Proof: schoener Look und intuitive Stationen
  reichen nicht, wenn Mess-/Vector-Planung fehlt.
- Der naechste sinnvolle Folge-Slice ist M16-DE Uferwald Measurement Source
  and Vector Workspace Plan, weiterhin ohne Code, Assets, Bilder,
  Runtime-Mapdaten oder App-Integration, sofern nicht separat freigegeben.

M16-DE erledigt:

- M16T-ASSET-085

M16-DE operationalisiert fuer kuenftige Slices:

- `docs/world_design/388-uferwald-measurement-source-and-vector-workspace-plan.md`
  entscheidet Markdown + SVG-Plan als naechsten Mess-/Vector-Weg.
- Markdown bleibt fuehrendes Entscheidungs- und QA-Dokument.
- Ein SVG-Plan darf erst in einem eigenen Folge-Slice als
  Dokumentationsvisual entstehen und muss klar `documentation_only`,
  `not_runtime_data`, `not_asset` und `not_engine_ready` bleiben.
- Figma-Writes bleiben geschlossen, bis ein eigenes Tool-/Write-Gate sie
  oeffnet.
- JSON/YAML bleibt vorerst Schema-/Feldidee und darf noch nicht als Runtime-
  oder Manifest-Datenquelle entstehen.
- Der naechste sinnvolle Folge-Slice ist M16-DF Uferwald Measurement SVG
  Documentation Plan.

M16-DF erledigt:

- M16T-ASSET-086

M16-DF operationalisiert fuer kuenftige Slices:

- `docs/world_design/389-uferwald-measurement-svg-documentation-plan.md`
  dokumentiert den ersten Uferwald-Messplan als SVG-/PNG-
  Dokumentationsvisual.
- Der Preview-Ordner
  `docs/world_design/previews/m16_df_uferwald_measurement_svg_documentation_plan/`
  enthaelt SVG und PNG mit sichtbarem Status `documentation_only`,
  `not_runtime_data`, `not_asset` und `not_engine_ready`.
- `base_rock_shape`, `water_river_mask`, `tree_obstacle_layer`,
  `rock_cliff_obstacle_layer`, `walkable_path_layer`,
  `buildable_zone_layer`, `no_walk_mask`, `no_build_mask`,
  `depth_sort_bands` und `landmark_anchor_layer` sind jetzt visuell
  reviewbar.
- Die Formen bleiben grobe Review-Geometrie: keine finalen Koordinaten,
  keine Runtime-Mapdaten, keine App-Integration, kein Figma-Write, kein
  JSON/YAML und keine Assets.
- Der naechste sinnvolle Folge-Slice ist M16-DG Uferwald Technical
  Measurement Review.

M16-DG erledigt:

- M16T-ASSET-087

M16-DG operationalisiert fuer kuenftige Slices:

- `docs/world_design/390-uferwald-technical-measurement-review.md` bewertet
  den M16-DF-Messplan als ausreichend fuer Review, aber nicht ausreichend fuer
  JSON/YAML-, Runtime-, Flutter- oder Asset-Folgearbeit.
- Ausreichend sind: sichtbare Pflicht-Layer, getrennte No-Walk-/No-Build-
  Konzepte, organische Build-Zonen ohne feste Slots und benannte Landmark-
  Anker.
- Vor maschinennaeheren Daten muessen Pfadbreiten, harte Wassergrenzen,
  dekorative-vs-harte Baum-/Hainblocker, Fels-/Klippenblocker, genaue
  No-Walk-/No-Build-Union-Regeln, Pfad-gegen-Blocker-QA, Sort-/Occlusion-
  Regeln und Anchor-Rollen praezisiert werden.
- Der naechste sinnvolle Folge-Slice ist M16-DH Uferwald Measurement
  Precision Pass, nicht direkt JSON/YAML oder Runtime-Daten.

M16-DH erledigt:

- M16T-ASSET-088

M16-DH operationalisiert fuer kuenftige Slices:

- `docs/world_design/391-uferwald-measurement-precision-pass.md`
  definiert relative Pfadbreiten, `planning_path_corridor` vs.
  `runtime_path_centerline`, Station-Abstand und Kamera-Follow-Abstand.
- Wassergrenzen, Uferpuffer, River Entry/Exit sowie Bruecken-/Furt-Blockade
  sind fachlich geklaert.
- Baum-/Hainrollen trennen `decorative_tree`, `soft_forest_edge`,
  `hard_tree_blocker` und `tree_occlusion_edge`.
- Fels-/Klippenrollen trennen `decorative_rock`, `hard_rock_blocker`,
  `cliff_edge` und `height_occlusion_edge`.
- No-Walk- und No-Build-Unionen sind als getrennte Review-Formeln definiert.
- Pfad-gegen-Blocker-QA, Sort-/Occlusion-Regeln und Anchor-Rollen sind
  ausreichend fuer einen naechsten Visual-Precision-Pass.
- JSON/YAML, Runtime-Mapdaten, Flutter-Code, Assets und finale Koordinaten
  bleiben weiterhin blockiert.
- Der naechste sinnvolle Folge-Slice ist M16-DI Uferwald Measurement Visual
  Precision Pass.

M16-DI erledigt:

- M16T-ASSET-089

M16-DI operationalisiert fuer kuenftige Slices:

- `docs/world_design/392-uferwald-measurement-visual-precision-pass.md`
  dokumentiert, dass die M16-DH-Regeln als SVG/PNG-Dokumentationsvisual
  sichtbar geprueft wurden.
- Der M16-DI-Preview-Ordner enthaelt `documentation_only`- und
  `planning_visual`-Visuals fuer `planning_path_corridor`, Pfadbreiten,
  Engpass-Marker, Wasser-/Uferpuffer, Baum-/Hainrollen, Fels-/Klippenrollen,
  No-Walk-/No-Build-Unionen, Pfad-gegen-Blocker-QA, Sort-/Occlusion-Kanten
  und Anchor-Rollen.
- M16-DI erzeugt keine finalen Koordinaten, keine Runtime-Path-Centerline,
  keine JSON/YAML-Daten, keine Assets, keine Runtime-Mapdaten und keinen Code.
- Der naechste sinnvolle Folge-Slice ist M16-DJ Uferwald Visual Precision
  Review.

M16-DJ erledigt:

- M16T-ASSET-090

M16-DJ operationalisiert fuer kuenftige Slices:

- `docs/world_design/393-uferwald-visual-precision-review.md` bewertet die
  vier M16-DI-Detailansichten, das Contact Sheet, das Overview-SVG/PNG und die
  Preview-README.
- M16-DJ entscheidet, dass Walkable/Water, Build/No-Build,
  Obstacles/Occlusion und Anchors/Sort-Bands ausreichend verstaendlich und
  ausreichend praezise fuer ein Docs-only Schema-/Planungs-Gate sind.
- Ein M16-DI-FIX-2 ist nicht noetig.
- M16-DJ gibt keine JSON/YAML-Dateien, keine Runtime-Mapdaten, keine finalen
  Koordinaten, keine neuen Visuals, keine Assets und keinen Code frei.
- Der naechste sinnvolle Folge-Slice ist M16-DK Uferwald Technical Planning
  Schema Gate.

M16-DK erledigt:

- M16T-ASSET-091

M16-DK operationalisiert fuer kuenftige Slices:

- `docs/world_design/394-uferwald-technical-planning-schema-gate.md`
  definiert ein reines Markdown-Schema fuer spaetere Uferwald-
  Planungsstrukturen.
- Das Schema umfasst Layer-IDs, Layer-Rollen, gemeinsame Pflichtfelder,
  Geometry-Placeholder, Rollen-/Status-Enums fuer Walkability, Buildability,
  Obstacles, Occlusion, Anchors, Sort-Bands, Path Corridor und Water/Buffer,
  QA-Felder, offene Messfragen und Blockerstatus.
- M16-DK verbietet weiterhin Pixelableitung fuer Walkability, Buildability,
  Collision, Wassergrenzen, Blocker, No-Walk/No-Build, Path-Centerlines,
  Footprints, Anchors, Sort-Bands und Kapazitaeten.
- M16-DK erzeugt keine JSON/YAML-Datei, keine Runtime-Mapdaten, keine finalen
  Koordinaten, keine Polygone, keine Visuals, keine Assets und keinen Code.
- Der naechste sinnvolle Folge-Slice ist M16-DL Uferwald Planning Schema
  Review, bevor ein enges JSON/YAML-Planning-Format-Gate vorbereitet wird.

M16-DL erledigt:

- M16T-ASSET-092

M16-DL operationalisiert fuer kuenftige Slices:

- `docs/world_design/395-uferwald-planning-schema-review.md` reviewt das
  M16-DK-Feldschema gegen Layer-IDs, Rollen, gemeinsame Pflichtfelder,
  Geometry-Placeholder, Enums, QA-Felder, offene Messfragen,
  Pixelableitungsverbote, manuelle Messpflichten, Runtime-Review-Pflichten
  und Blockerstatus.
- M16-DL entscheidet: M16-DK ist ausreichend und ein M16-DK-FIX ist nicht
  noetig.
- Ein M16-DM JSON/YAML Planning Format Gate darf vorbereitet werden, bleibt
  aber ein Format-Gate und darf nicht automatisch Runtime-Daten, finale
  Koordinaten, Polygone, Path-Centerlines, Assets, Figma-Writes, App-
  Integration oder Code erzeugen.
- Wenn M16-DM echte JSON/YAML-Dateien oeffnen soll, muss der Folgeprompt Pfad,
  Status, Felder und Verbote ausdruecklich freigeben; ohne diese Oeffnung
  bleibt M16-DM Markdown-only.

M16-DM erledigt:

- M16T-ASSET-093

M16-DM operationalisiert fuer kuenftige Slices:

- `docs/world_design/396-uferwald-json-yaml-planning-format-gate.md`
  bevorzugt YAML als erstes spaeteres Planning-Format, weil es fuer Review
  und offene Messfragen lesbarer ist als JSON.
- M16-DM definiert nur Formatregeln, erlaubte Feldgruppen, Pflichtstatus,
  verbotene Felder, erlaubte Platzhalter, QA-Regeln und einen moeglichen
  spaeteren Planning-Pfad.
- M16-DM erzeugt keine `.json`, `.yaml` oder `.yml` Datei und keine Beispiel-
  Datei.
- Echte Koordinaten, Polygonpunkte, Path-Centerlines, Path-Nodes, Build-
  Zonen-Polygone, No-Walk-/No-Build-Unionen als echte Werte,
  Pixelableitung, Runtime-Status, Assets, App-Integration und Code bleiben
  blockiert.
- Der naechste sinnvolle Folge-Slice ist M16-DN Uferwald JSON/YAML Planning
  Format Review, bevor ein echter Skeleton-Slice vorbereitet wird.

Damit bleiben keine normalen offenen `[ ]` M16-T-Items und keine ausgelagerten
`[>]` Detail-Gates. Blockierte und teilweise erledigte Gates bleiben bewusst
bestehen und duerfen nicht nebenbei als Implementierungsfreigabe gelesen
werden.

M16-U Detail-Gates inzwischen geschlossen:

- M16T-RESEARCH-002
- M16T-RESEARCH-003

Alle verbleibenden Punkte bleiben teilweise vorbereitet oder blockiert und
brauchen eigene Folge-Gates, bevor daraus Implementierung entstehen darf.

## 28. Scrum-lite Operating Model

| Rolle / Artefakt | Definition |
| --- | --- |
| Product Owner | Andreas / Projektentscheidung |
| Product Coach / Review | ChatGPT |
| Implementierung | Codex + manuelle Pruefung |
| Product Backlog | M16-T |
| Sprint Backlog | ausgewaehlte M16-T-IDs |
| Sprint Goal | ein kurzer Satz pro Arbeitsblock |
| Commit-Regel | Commit erst nach separater Freigabe |

Definition of Ready:

- relevante M16-T-IDs sind genannt,
- fuehrende Dokumente sind genannt,
- Scope und Non-Goals sind klar,
- Stop-Regeln sind explizit,
- erwartete Dateien/Pfade sind benannt,
- Checks sind benannt,
- offene Produktfragen sind entweder beantwortet oder bewusst blockiert.

Definition of Done:

- erwartete Dateien wurden erstellt/geaendert,
- keine unklaren Dateien wurden geaendert,
- Stop-Regeln sind geprueft,
- relevante M16-T-IDs sind erledigt/teilweise/offen/neu berichtet,
- `git diff --check` wurde ausgefuehrt,
- `git status --short` wurde berichtet,
- Commit wurde nicht automatisch ausgefuehrt.

Sprint Review:

- Ergebnis gegen Sprint Goal pruefen,
- offene Blocker markieren,
- neue M16-T-IDs oder Detail-Gates anlegen,
- naechste empfohlene IDs bestimmen.

Sprint Retrospective:

- Was war zu breit?
- Was war zu eng?
- Welche Stop-Regel hat geholfen?
- Welche Dokumentations- oder Visual-QA-Regel muss geschaerft werden?

## 29. MVP-Roadmap

Ziel:

Erste lauffaehige Version von Talvori als kleiner, spielbarer Lernloop.

Leitsatz:

Nicht alle M16-T-Items muessen vor der ersten lauffaehigen Version vollstaendig
erledigt sein. Aber Learning Logic, Core Loop, Reward Bridge, Word Outcome
Taxonomy, Sensitive-Regeln, Review Queue und eine minimale World Feedback Loop
muessen fachlich harmonieren.

| Klassifizierung | Bereiche / IDs | Warum |
| --- | --- | --- |
| MVP-kritisch | M16T-PROD-001..003, M16T-CORE-001..003, M16T-L2W-001..003, M16T-LEARN-001..002, M16T-WOT-001..008, M16T-SEM-001..004, M16T-SCALE-001..004, M16T-REWARD-001..005, M16T-WORLD-001, M16T-WORLD-004, M16T-SENS-001..003, M16T-QUEUE-001..004, M16T-GAME-001..004, M16T-PLAY-001..005, M16T-PLAY-007..009, M16T-INFRA-001..012, M16T-SPINE-001..015, M16T-FUN-001..019, M16T-LANGUAGE-001..006, M16T-DESIGN-001..004, M16T-DESIGN-007..010, M16T-MVP-004 | Diese Punkte definieren den kleinen spielbaren Lernloop, das Play-First-/Island-First-Gefuehl, die Starter-Insel-Grundlage, den Construction-Learning-Spine, den Fun-/Adventure-/Curiosity-Layer, object-first Bauplatzregeln, character-assisted World Actions, Flow-Rejoin-Grenzen, Language-Layer-/Game-Bible-Regeln, professionelle Design-before-Code- und Cozy-Island-Diorama-Game-Direction-Grenzen und verhindern falsche Weltreaktionen. |
| Vor MVP zu klaeren | M16T-MOBILE-001..004, M16T-COMP-001..004, M16T-ARCH-001, M16T-ARCH-002, M16T-ARCH-003, M16T-DATA-001, M16T-DATA-002, M16T-UNDO-001 | Produktive Nutzbarkeit braucht Mobile, Companion-Grenzen, technische Boundaries und Datenentscheidungen. |
| Nach MVP | M16T-WHEEL-002..004, M16T-WORLD-002..003, M16T-DEPTH-001..002, M16T-SOCIAL-001..003, M16T-METRICS-001..003 | Wichtig, aber nicht zwingend fuer ersten spielbaren Lernloop. |
| Produktions-/release-kritisch | M16T-DATA-003..005, M16T-ARCH-004, M16T-ASSET-001..088, M16T-ART-001..017, M16T-DOC-001..007, M16T-GIT-001..004, M16T-MGMT-001..004 | Noetig fuer echte Produktqualitaet, Release, Daten-, Asset-, Art-Pipeline-, Style-System-, Master-Reference-, Prompt-Template-, Commit- und Projektmanagement-Sicherheit. |
| Blockiert bis eigenes Gate | M16T-WHEEL-001, M16T-ASSET-001, M16T-DATA-001..003, M16T-DATA-005, M16T-ARCH-002..004, M16T-DOC-004, M16T-GIT-003 | Diese Themen duerfen nicht nebenbei umgesetzt werden. |

## 30. Change-/Idea-Intake

Neue Erkenntnisse, bessere Ideen oder entdeckte Luecken werden nicht direkt
implementiert. Sie gehen zuerst durch Intake.

Template:

| Feld | Inhalt |
| --- | --- |
| ID | `M16T-CHANGE-YYYYMMDD-###` oder neue stabile M16-T-ID |
| Quelle / Grund | Nutzerhinweis, Review, Benchmark, technischer Fund, UX-Beobachtung |
| Hypothese | Was koennte besser werden? |
| Betroffene M16-T-IDs | Bestehende IDs nennen |
| Entscheidung | aufnehmen / parken / ablehnen / research noetig |
| MVP-Relevanz | kritisch / vor MVP / nach MVP / release-kritisch / blockiert |
| Risiko | Scope Drift, App-Integration, Persistenz, Asset, Safety, Retention-Druck |
| Naechster Schritt | Dokumentation, Research, Detail-Gate, Prompt-Draft oder keine Aktion |

Regeln:

- Neue Ideen nie direkt implementieren.
- Betroffene M16-T-IDs immer verlinken.
- Wenn keine passende ID existiert, neue ID in M16-T anlegen.
- Jede Idee muss MVP-Relevanz und Risiko nennen.

## 31. Research-/Benchmark-Gate

Fuer Lernlogik, Reward, Level, Progression, Social/Competition, Retention, UX
und Spielmechanik muessen erfolgreiche Apps/Spiele recherchiert werden, bevor
produktive Mechaniken festgelegt werden.

Research-Ziele:

| Benchmark | Zu untersuchen | Talvori-Frage |
| --- | --- | --- |
| Duolingo | Habit, Streaks, XP, Leagues, Lernmotivation | Was motiviert, ohne Talvori in Schuld-/Streak-Druck zu kippen? |
| Clash of Clans / Supercell | Progression, Entscheidungen, Trade-offs, Social Play, Competition, Clans, Balance | Welche Aufbau- und Sozialprinzipien passen, ohne Pay-to-Win oder Druck zu uebernehmen? |
| Weitere Lern-/Gamification-Apps | spaeter ergaenzbar | Welche Prinzipien verbessern Lernen, nicht nur Retention? |

Regel:

Nicht blind kopieren. Nur Prinzipien ableiten:

- Was funktioniert?
- Warum funktioniert es?
- Was passt zu Talvori?
- Was ist fuer Talvori gefaehrlich?
- Wie bleibt Lernen wichtiger als Retention-Druck?

## 32. Neue Dashboard-/Operating-Model-ID-Gruppen

### M16T-DASH

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-DASH-001 | [x] | Progress Dashboard ergaenzen | Fortschritt muss sichtbar steuerbar sein. | Gesamtzahlen, Prozent und Balken in 328 stehen. | Dashboard fehlt. | nein |
| M16T-DASH-002 | [x] | Prozentformel definieren | Fortschritt braucht reproduzierbare Berechnung. | Gewichte fuer `[x]`, `[~]`, `[ ]`, `[!]`, `[>]` dokumentiert sind. | Unklare Fortschrittsberechnung. | nein |
| M16T-DASH-003 | [x] | Bereichsfortschritt je Bereich anzeigen | Schwache Bereiche muessen sichtbar bleiben. | Bereichs-Dashboard fuer die bestehenden Bereiche inklusive Play, Interaction, Infra, Spine, Fun, Language, Management und Design steht. | Nur Gesamtzahl ohne Bereichssicht. | nein |
| M16T-DASH-004 | [x] | Dashboard nach jedem Slice aktualisieren | Fortschritt darf nicht veralten. | Jeder spaetere Slice Zahlen, Balken und Empfehlungen aktualisiert. | Veraltetes Dashboard. | nein |

### M16T-SCRUM

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-SCRUM-001 | [x] | Scrum-lite Rollenmodell definieren | Verantwortungen sollen klar bleiben. | PO, Coach/Review, Implementierung, Backlogs dokumentiert sind. | Unklare Entscheidungsrollen. | nein |
| M16T-SCRUM-002 | [x] | Sprint Goal Template definieren | Jeder Block braucht ein klares Ziel. | Sprint Goal als ein Satz pro Block verlangt wird. | Scope Drift. | nein |
| M16T-SCRUM-003 | [x] | Definition of Ready definieren | Prompts sollen erst mit genug Kontext starten. | DoR in 328 steht. | Unklare Prompts. | nein |
| M16T-SCRUM-004 | [x] | Definition of Done definieren | Abschluesse brauchen klare Pruefung. | DoD in 328 steht. | Halb fertige Slices. | nein |
| M16T-SCRUM-005 | [x] | Sprint Review/Retrospective Regel definieren | Lernen aus jedem Block schuetzt das Produkt. | Review/Retro-Fragen in 328 stehen. | Wiederholte Fehler. | nein |

### M16T-MVP

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-MVP-001 | [x] | Erste lauffaehige Version als Produktziel definieren | M16-T braucht eine steuerbare Zielrichtung. | "kleiner, spielbarer Lernloop" als MVP-Ziel dokumentiert ist. | Endlose Gate-Kette ohne MVP-Ziel. | nein |
| M16T-MVP-002 | [x] | MVP-kritische M16-T-IDs markieren | Nicht alle Items sind vor MVP gleich wichtig. | MVP-kritische IDs in 328 markiert sind. | Alles wird MVP-blockierend. | nein |
| M16T-MVP-003 | [x] | Nicht-MVP-kritische Themen parken | Scope muss klein bleiben. | Nach-MVP und blockierte Themen klassifiziert sind. | Zu grosses MVP. | nein |
| M16T-MVP-004 | [x] | Minimal spielbaren Lernloop definieren | Der erste lauffaehige Loop braucht konkrete Grenzen. | Lernaktion, Semantikvorschlag, freiwillige Entscheidung und Weltfeedback als Minimal-Loop detailliert sind. | MVP-Code ohne Loop-Contract. | nein |

### M16T-CHANGE

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-CHANGE-001 | [x] | Neue Erkenntnisse/Ideen als Intake-Prozess definieren | Gute Ideen sollen nicht verloren gehen. | Intake-Template in 328 steht. | Ideen ohne Bewertung. | nein |
| M16T-CHANGE-002 | [x] | Neue Ideen nie direkt implementieren, erst bewerten | Spontane Ideen koennen Architektur brechen. | Intake-Regel "nicht direkt implementieren" dokumentiert ist. | Direktumsetzung. | nein |
| M16T-CHANGE-003 | [x] | Betroffene M16-T-IDs bei neuen Ideen verlinken | Ideen muessen ins bestehende Gate-System passen. | Intake verlangt betroffene IDs. | Isolierte neue Ideen ohne Traceability. | nein |

### M16T-RESEARCH

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-RESEARCH-001 | [x] | Benchmark-Gate fuer erfolgreiche Lern-/Spiel-Apps definieren | Talvori soll von bewaehrten Prinzipien lernen. | Research-Gate in 328 steht. | Produktive Mechanik ohne Benchmark. | nein |
| M16T-RESEARCH-002 | [x] | Duolingo-Research fuer Habit/XP/Streaks/Leagues planen | Habit-Mechaniken sind stark, aber druckgefaehrlich. | Eigenes Research-Dokument Prinzipien und Risiken ableitet. | Blindes Kopieren von Streak/League-Druck. | nein |
| M16T-RESEARCH-003 | [x] | Clash/Supercell-Research fuer Progression/Social/Competition planen | Aufbau- und Sozialspiel braucht Balance-Wissen. | Eigenes Research-Dokument Progression, Trade-offs, Social und Risiken ableitet. | Pay-to-win, FOMO, Competition-Druck. | nein |
| M16T-RESEARCH-004 | [x] | Research-Ergebnisse in Talvori-Prinzipien uebersetzen | Research ist nur nuetzlich, wenn es Talvori-Regeln erzeugt. | Abgeleitete Prinzipien in M16-T/MVP-Gates eingearbeitet sind. | Research bleibt Sammlung. | nein |

### M16T-GAME

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-GAME-001 | [x] | Gameplay Pillars definieren | Talvori braucht klare Spielsaeulen. | 3-5 Gameplay Pillars mit Lernbezug dokumentiert sind. | Mechaniken ohne Richtung. | nein |
| M16T-GAME-002 | [x] | Level-/Quest-/Challenge-Loop planen | Lernen braucht wiederkehrende, aber faire Spielmomente. | Loop fuer Level, Quest und Challenge ohne Druck dokumentiert ist. | Quest-/Level-Code. | nein |
| M16T-GAME-003 | [x] | Lernlogik und Spielaufbau harmonisieren | Spiel darf Lernlogik nicht korrumpieren. | Reward, Challenge und Weltfeedback getrennt, aber verbunden sind. | Reward Bridge ohne Contract. | nein |
| M16T-GAME-004 | [x] | Spass/Spannung ohne Lernschaden definieren | Engagement darf Retention-Druck nicht ueber Lernen stellen. | Spannung, Risiko, Belohnung und Pause als faire Prinzipien dokumentiert sind. | Druckmechaniken. | nein |

### M16T-PLAY

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-PLAY-001 | [x] | Play-First Learning Doctrine | Talvori darf nicht wie ein Vokabeltrainer mit Spieldeko wirken. | Verbindliche Doctrine dokumentiert ist: Talvori ist ein Spiel, dessen Spielhandlungen Lernnutzen erzeugen. | Implementierung ohne Spielmoment. | nein |
| M16T-PLAY-002 | [x] | Lernen als Nebenprodukt des Spielens | Nutzer sollen Neugier, Entscheidung und Weltfortschritt spuerbar erleben. | Lernen als Wirkung von Spielhandlung, Challenge, Entdeckung und Feedback dokumentiert ist. | Pflichtlernen als Hauptgefuehl. | nein |
| M16T-PLAY-003 | [x] | Spielmechanik-zu-Lernnutzen-Matrix | Jede Mechanik muss Lernnutzen haben, ohne Lernpflicht zu wirken. | Matrix von Puzzle, Weg, Container, Aktion, Weltbereich, Codex und Review zu Lernnutzen existiert. | Mechanik ohne Lernanker. | nein |
| M16T-PLAY-004 | [x] | Neugier-/Challenge-/Flow-Regeln | Spielgefuehl entsteht aus klaren Zielen, kleiner Herausforderung und sicherem Feedback. | Curiosity-, Challenge- und Flow-Regeln mit Safe Defaults dokumentiert sind. | Druck, Sackgassen, Ueberladung. | nein |
| M16T-PLAY-005 | [x] | Uebung darf sich nicht wie Uebung anfuehlen | Klassische Uebungs- und Fragebogenmuster wuerden das Produktgefuehl brechen. | Verbotene Uebungsgefuehle und Play-Alternativen dokumentiert sind. | Multiple-Choice als Hauptgefuehl, Textwand, XP-Grind. | nein |
| M16T-PLAY-006 | [x] | Benchmark-Games ohne Lernfokus analysieren | Talvori muss auch von reinen Spielen lernen, nicht nur von Lernapps. | Minecraft, Roblox, Puzzle-, Runner-, Match-, Card- und MOBA-Patterns als Research-Quellen tief ausgewertet und in Talvori-Regeln uebersetzt sind. | Blindes Kopieren, Social-/FOMO-/Gacha-/Timer-Druck. | nein |
| M16T-PLAY-007 | [x] | MVP-Playtest-Kriterien fuer Spielgefuehl | Spaetere MVP-Tests muessen fragen, ob sich Talvori wirklich wie Spiel anfuehlt. | Playtest-Fragen zu Spielgefuehl, Neugier, Freiwilligkeit, Stress, Fehlern und Weltreaktion existieren. | MVP ohne Spielgefuehl-Pruefung. | nein |
| M16T-PLAY-008 | [x] | Play-First-Check fuer jede Implementierung | Die Doctrine muss in spaeterem Code-Scope aktiv geprueft werden. | Play-First-Check als Pflichtregel dokumentiert und in spaeteren Implementierungs-Prompts angewendet wird. | App-Code fuer Lernuebungen ohne Spielmoment-Beschreibung. | nein |
| M16T-PLAY-009 | [x] | Island-First Play Rule | Talvori-Aufgaben duerfen nicht als separate Lernfenster dominieren. | Regel dokumentiert ist und die Bank Meaning Puzzle Preview als Insel-/Plot-/Flussufer-Szene statt Lernfenster angewendet ist. | Karten/Fenster als Hauptspielraum, Welt nur als Deko. | nein |

### M16T-INTERACT

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-INTERACT-001 | [x] | Interaction Pattern Decision Matrix | Talvori darf Wheel, Drag, Popup oder neue Seite nicht pauschal einsetzen. | `350-interaction-pattern-decision-matrix.md` definiert Muster, Kriterien und Regeln. | UI-Muster nach Gewohnheit statt Aktionstyp. | nein |
| M16T-INTERACT-002 | [x] | UI-Muster pro Aktion waehlen | Jede Aktion braucht die passende Groesse und Dichte. | Kuenftige Prompts muessen UI-Art, Passung, Groesse und verworfene Alternative nennen. | Wheel/Popup/Seite ohne Begruendung. | nein |
| M16T-INTERACT-003 | [x] | Wheel nur fuer kurze In-place-Auswahl | Ein zu grosses Wheel fuehlt sich wie Fenster statt Spielobjekt an. | Wheel ist auf wenige Optionen mit Icon + Kurzname begrenzt; Details wandern in HUD/Bottom-Sheet/Showcase. | Wheel fuer lange Texte oder komplexe Vergleiche. | nein |
| M16T-INTERACT-004 | [x] | Showcase-Seite fuer grosse visuelle Auswahl | Manche Entscheidungen brauchen Vergleich und Vorschau statt Mini-Menue. | Showcase-Regel fuer BuildChoice, Companion, Style, Biome und groessere visuelle Auswahl dokumentiert ist. | Grosse Auswahl in kleinen Chips erzwingen. | nein |
| M16T-INTERACT-005 | [x] | Drag/Drop nicht als Standard-Nutzerflow | Freies Dragging kann mobil unpraezise und zu technisch wirken. | Drag/Drop als Dev-/Layout-Modus oder spaetere Editierfunktion eingeordnet ist. | Drag als Hauptflow fuer normale Spielentscheidungen. | nein |
| M16T-INTERACT-006 | [x] | Research-/Benchmark-Check vor unklaren UI-Entscheidungen | Unklare UI- und Spielaufbau-Entscheidungen sollen von erfolgreichen Spielmustern lernen, statt aus Gewohnheit gebaut zu werden. | `350-interaction-pattern-decision-matrix.md` verlangt vor Umsetzung einen kurzen Benchmark-/Research-Check mit gewaehltem Muster, Passung, Vorbildlogik und verworfenen Alternativen. | UI-Entscheidung ohne Pattern- oder Benchmark-Abgleich. | nein |

### M16T-INFRA

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-INFRA-001 | [x] | Starter Island Infrastructure Strategy | Weitere Insel-, Wheel-, BuildChoice- und Spielmoment-Slices brauchen eine gemeinsame Inselgrundlage. | `351-starter-island-infrastructure-strategy-gate.md` definiert Terrain, Slots, Templates, Varianten, Unlocks und Stop-Regeln. | Code ohne Infrastruktur-Gate. | nein |
| M16T-INFRA-002 | [x] | Fixed vs Player-Editable Infrastructure | Talvori braucht Orientierung, ohne Nutzerkreativitaet zu bevormunden. | Kueste, Wasser, Hauptwege, Slots, Kategorie, Variante, BuildChoice und Terrain-Modifikation getrennt sind. | Fixe Kategorieplaetze, Terrain-Editor im MVP. | nein |
| M16T-INFRA-003 | [x] | Starter Slot Count and Unlock Strategy | Mobile-Dichte und Neugier brauchen begrenzte, aber sichtbare freie Flaechen. | 8-12 sichtbare Slots, 4-6 Startslots, 4-6 spaetere Erweiterungsslots als Planungswert definiert sind. | ueberladene Insel, zu viele Pflichtentscheidungen. | nein |
| M16T-INFRA-004 | [x] | Category Template and Terrain Variant Rules | Kategorien sollen kreativ mehrfach nutzbar sein, statt einmalig oder hart platziert zu wirken. | Kategorien als Templates und Slot + Kategorie + Terrain als Variante ohne BuildState dokumentiert sind. | Kategorie erzeugt Gebaeude, Asset oder Placement. | nein |
| M16T-INFRA-005 | [x] | Path/River/Bridge Strategy | Wege und Wasser muessen Orientierung geben, duerfen aber keinen produktiven Pfadbau ausloesen. | Fluss/Wasser, Hauptwege, Nebenwege und Bruecken als Grund-Infrastruktur bzw. spaetere Gates eingeordnet sind. | freie Fluss-/Pfadbearbeitung oder Bridge-Code im MVP. | nein |
| M16T-INFRA-006 | [x] | Coin/Unlock Strategy without Economy Implementation | Unlocks koennen Neugier erzeugen, duerfen aber keinen Druck oder Economy-Scope starten. | Muenzen/Unlocks fachlich, druckfrei und ohne Economy-, Timer-, Pay-to-Win- oder Persistenzfreigabe dokumentiert sind. | Economy, Timer, Kaufdruck, Pay-to-Win. | nein |
| M16T-INFRA-007 | [x] | Starter Island Identity / Biome | Die erste Insel braucht ein klares Spielraum-Gefuehl statt generischer Greybox. | `353-starter-island-identity-biome-and-category-scope-gate.md` entscheidet Uferhain/Kuestenhain/Flussufer als MVP-Starter-Identitaet. | weitere Board-/BuildChoice-Slices ohne Inselidentitaet. | nein |
| M16T-INFRA-008 | [x] | Starter Island Category Scope | Der MVP braucht klare Kategorien und klare Nicht-Kategorien. | Starter-Templates und nicht im Starter-Scope liegende Kategorien dokumentiert sind. | Arena, Hafen, Stadt, Labor oder Social/PvP im Starter-Scope. | nein |
| M16T-INFRA-009 | [x] | Terrain-to-Variant Mapping | Terrain soll Kreativitaet unterstuetzen, aber Kategorien nicht hart blockieren. | Ufer-, Wald-, Huegel-, Zentrum- und Rand-Varianten als lokale Namen/Previews ohne BuildState dokumentiert sind. | Terrain erzwingt Kategorie oder Placement. | nein |
| M16T-INFRA-010 | [x] | Future Island Family Roadmap | Spaetere Biome sollen sichtbar geplant, aber vom MVP getrennt bleiben. | Wuesten-, Berg-/Schnee-, Hafen-/Meer-, Wald-/Natur-, Stadt-/Dorf-, Wissens-/Archiv- und Werkstatt-/Technik-Inseln als Roadmap abgegrenzt sind. | Future-Island-Scope im Starter-MVP. | nein |
| M16T-INFRA-011 | [x] | Player-editable Terrain Boundary | Nutzerfreiheit braucht Grenzen zwischen freier Kategorie und fixer Infrastruktur. | MVP fixiert Kueste, Fluss, Hauptwege, Hub und Landmarken; Nutzer waehlen Kategorie/Variante, Terrainmodifikation bleibt Gate. | Terrain-Editor, freie Fluss-/Pfadbearbeitung oder Persistenz ohne Gate. | nein |
| M16T-INFRA-012 | [x] | User-facing category naming and BuildChoice hierarchy | Nutzer sollen keine internen Systembegriffe oder ueberladenen Unterauswahlen im ersten Wheel sehen. | `353-starter-island-identity-biome-and-category-scope-gate.md` trennt interne Begriffe von sichtbaren Nutzerkategorien und ordnet Garage, Terrasse, Pool, Teich usw. als spaetere BuildChoice-/Showcase-Kandidaten ein. | Codex/Safe als Spielerbegriffe, alle Unterideen im ersten Wheel, BuildChoice-Code ohne Gate. | nein |

### M16T-SPINE

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-SPINE-001 | [x] | Core Construction Learning Spine | Talvori darf nicht zu einem Insel-Menue mit einzelnen Lernraetseln werden. | `355-talvori-core-construction-learning-spine.md` definiert Insel -> Slot -> Kategorie -> BuildChoice -> Bauphase -> Lernhandlung -> Ausbau -> Raum -> Container als fuehrenden Loop. | isolierte Mini-Lernmomente ohne Bau-/Weltzweck. | nein |
| M16T-SPINE-002 | [x] | BuildChoice hierarchy from category to object/detail | Hauptkategorie, konkrete Bauidee, Raum und Container duerfen nicht in einem Wheel verschwimmen. | Hierarchie von Kategorie zu BuildChoice, Bauabschnitt, Interior und Container/Depth dokumentiert ist. | Garage, Terrasse, Pool, Teich usw. als erste Kategorie; BuildChoice-Code ohne Gate. | nein |
| M16T-SPINE-003 | [x] | Learning task must serve build/world action | Lernen soll Motor des Aufbaus sein, nicht separates Quiz neben der Welt. | Jede Lernaufgabe muss eine Bau-, Ausbau-, Welt-, Raum- oder Containeraktion unterstuetzen. | Lernfenster, Quizkarte oder Meaning Puzzle ohne Weltauftrag. | nein |
| M16T-SPINE-004 | [x] | First vertical construction-learning slice | Der naechste MVP-Schritt braucht einen End-to-End-Beweis fuer Spiel = Bauen = Lernen. | Erstes empfohlenes Vertical Slice ist Uferhain -> Startslot -> Zuhause -> Haus -> Grundstueckszoom -> Fundament-Candidate -> spielerische Lernaufgabe -> lokales Feedback. | direkt produktiver Build, Persistenz, Asset oder App-Integration. | nein |
| M16T-SPINE-005 | [x] | No isolated learning moments without world/build purpose | Einzelne Lernmomente koennen das Play-First-Versprechen verfehlen. | Kuenftige Prompts muessen Spine-Stufe, Bau-/Weltaktion, sichtbaren Fortschritt und Lernhandlung nennen. | "Wort X"-Slice ohne Bau-/Ausbau-/Weltbezug. | nein |
| M16T-SPINE-006 | [x] | First Local Construction-Learning Vertical Slice Gate | Der erste Code-Schritt braucht ein praezises Prompt-Gate statt vager Build-Idee. | `356-first-local-construction-learning-vertical-slice-gate.md` definiert Uferhain -> Startslot -> Zuhause -> Haus -> Grundstueckszoom -> Fundament-Candidate -> Lernhandlung -> lokales Feedback. | Code ohne Gate, isolierte Lernmomente, Bank-/Quiz-Fokus. | nein |
| M16T-SPINE-007 | [x] | Grundstueckszoom Preview Boundary | Der Zoom darf nicht heimlich Route, neue Seite oder Persistenz werden. | Grundstueckszoom als lokale Preview-Ebene ohne Navigation, Route, App-Seite oder Persistenzwechsel dokumentiert ist. | Router, Home-/App-Umbau, gespeicherter Zoom-/Plotzustand. | nein |
| M16T-SPINE-008 | [x] | Foundation Candidate Construction Step | Der erste Bauabschnitt braucht sichtbares Baugefuehl ohne BuildState. | Fundament-Ghost/Skizze/Markierung als Candidate ohne `foundation_started`, Bauzustand, Asset oder Persistenz definiert ist. | produktiver BuildState, Asset, gespeichertes Fundament. | nein |
| M16T-SPINE-009 | [x] | Learning Action as Build Action | Lernen muss den Bau antreiben, nicht als Quizfenster daneben stehen. | Bauteile-sortieren am Grundstueck als erste Lernhandlung mit Fundament/Fenster/Dach und ruhigem Feedback definiert ist. | Score, Timer, XP, Review-Zwang, isolierter Quizscreen. | nein |
| M16T-SPINE-010 | [x] | M16-BK Implementation Prompt Readiness | Der erste Foundation-Codebeweis brauchte klare Dateien, Scope und Akzeptanzkriterien. | M16-BK First Local Foundation Construction Preview mit isolierter Datei-Strategie und Checks vorbereitet wurde; M16-BL korrigiert danach die visuelle Richtung. | Code-Slice ohne Stop-Regeln, BuildChoice-Implementierung, Persistenz oder App-Integration. | nein |
| M16T-SPINE-011 | [x] | Game-like island selection and camera flow | Der erste Bau-/Lernbeweis muss wie Spielwelt wirken, nicht wie UI-Flow-Karten. | `357-game-like-island-selection-and-construction-camera-flow-gate.md` definiert Insel-Showcase -> Insel betreten -> Kamera-Zoom -> Bauplatz -> Feedback als fuehrenden Game-Flow. | Textpanel-Flow, Formular, Flow-Chart oder Lernfenster als Hauptgefuehl. | nein |
| M16T-SPINE-012 | [x] | Showcase pattern for island/buildchoice selection | Insel- und BuildChoice-Auswahl brauchen visuelle Ownership statt kleiner Textwahl. | Inselwahl als Showcase/Carousel und BuildChoice als visuelle Preview/Showcase/Werkbank-Muster dokumentiert sind. | BuildChoice im kleinen Wheel, lange Textliste, produktive Showcase-Route. | nein |
| M16T-SPINE-013 | [x] | Construction task must happen on build site | Lernen soll Bauhandlung am Ort sein, nicht Fragekarte neben der Welt. | Fundament-/Bauteile-Aufgabe muss direkt am Bauplatz passieren; Text darf nur helfen. | Quizkarte mit drei Textbuttons als Hauptflaeche. | nein |
| M16T-SPINE-014 | [x] | Minimal HUD for construction-learning flow | Spielraum muss dominieren, nicht HUD/Debug/Guardrails. | HUD-Regeln mit einem Hauptziel, kurzen Bubbles, kompakten Safe Actions und ohne permanente Debug-/Guardrail-Chips dokumentiert sind. | Footer, Phasenleiste, Textwand, technisches HUD im normalen Spielbild. | nein |
| M16T-SPINE-015 | [x] | M16-BM prompt readiness | Der naechste Code-Slice braucht den korrigierten Game-like Flow und neue Datei-Grenzen. | M16-BM Game-like Island Showcase to Foundation Camera Preview mit empfohlenen Dateien und Akzeptanzkriterien vorbereitet ist. | alte M16-BK-Dateien weiterfuehren, Starter-Island-Board ueberladen, Code ohne 357. | nein |

### M16T-FUN

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-FUN-001 | [x] | Fun/Adventure/Curiosity Spine | Talvori darf nicht nur technisch korrekt und lehrreich sein, sondern muss freiwilliges Weiterspielen ausloesen. | `358-fun-adventure-curiosity-reward-gameplay-spine-gate.md` definiert den Fun-/Adventure-/Curiosity-Layer ueber dem Construction-Spine. | Bau-/Lernflow ohne Spielspass- oder Neugieranker. | nein |
| M16T-FUN-002 | [x] | Every slice must define player hook | Jeder Slice braucht eine klare Antwort, warum der Spieler weitermachen will. | Kuenftige Prompts muessen Player Hook, kleine Huerde, naechsten Schritt und uebertragenes Spielmuster nennen. | Implementierung ohne Hook/Neugier/Weiter-Spiel-Impuls. | nein |
| M16T-FUN-003 | [x] | Construction task must include playful tension | Bauaufgaben brauchen spielerische Spannung statt technischer Abfolge. | Erlaubte Spannungen wie oeffnen, finden, reparieren, bauen, retten, sammeln, kombinieren und Geheimnis entdecken dokumentiert sind. | Bauhandlung als Formular, Checkliste oder reine Textphase. | nein |
| M16T-FUN-004 | [x] | Reward means new possibility, not pressure | Belohnung soll Moeglichkeit und Ownership erzeugen, nicht Retention-Druck. | Reward-Regel definiert neue Bauabschnitte, Blueprint-Ideen, Fundstuecke, Container, Tali/Vori-Hilfe oder Archiv-Eintrag ohne Economy/Persistenz. | XP-/Timer-/Streak-/FOMO-/Pay-to-Win-Reward. | nein |
| M16T-FUN-005 | [x] | Safe danger/repair/discovery patterns | Spannung wie Gefahr oder Vernichtung muss in sichere Talvori-Formen uebersetzt werden. | Nebel vertreiben, Weg reparieren, Ort aufraeumen, Objekt finden, Flaeche beleuchten und Bauplatz stabilisieren als druckfreie Muster dokumentiert sind. | Weltverlust, Zeitdruck, Bestrafung, Angst oder sensible Inhalte als Drama. | nein |
| M16T-FUN-006 | [x] | M16-BO Hook Polish readiness | M16-BM braucht vor Commit/naechstem Gate mehr Hook, Weltreaktion und Belohnung als neue Moeglichkeit. | M16-BO Game-like Construction Hook Polish mit erlaubten M16-BM-Dateien, Scope und Ziel vorbereitet ist. | M16-BM als rein technischer Greybox-Stand ohne Fun-/Hook-Polish weitertragen. | nein |
| M16T-FUN-007 | [x] | Successful Game Pattern Translation | Talvori soll erfolgreiche Spielmuster als Prinzipien uebersetzen, nicht technisch korrekte UI-Greyboxes bauen. | `359-successful-game-pattern-translation-for-talvori-construction-play.md` uebersetzt Puzzle-, Ordnung-, Aufbau-, Sammel-, Perspektiv-, Sprach-, Mission- und Showcase-Muster in Talvori-Regeln. | Blindes Kopieren oder Code ohne Pattern-Uebersetzung. | nein |
| M16T-FUN-008 | [x] | Object-first before text | Spielhandlungen muessen vor Text sichtbar sein. | Regel dokumentiert ist: erst sichtbares Problem, Objekt und Ort, dann kurze Erklaerung. | Text erklaert die Aufgabe, bevor der Ort sie zeigt. | nein |
| M16T-FUN-009 | [x] | Buildsite puzzle must change the world | Eine Foundation-Aufgabe darf nicht nur richtige Antwort markieren. | Object-Based Buildsite Puzzle definiert Bodenproblem, Bauteile, Einrasten/Wackeln und sichtbare Veraenderung. | Bauteile als Buttons, Quizkarte, keine Weltreaktion. | nein |
| M16T-FUN-010 | [x] | Reward as next visible possibility | Belohnung soll als naechste Moeglichkeit im Raum erscheinen. | Aussenwand-Schatten, neuer Bauabschnitt oder Blueprint-Hook als Belohnung ohne Punkte/XP/Muenzen dokumentiert ist. | Reward als Text, Punkte, XP, Muenzen oder echtes System ohne Gate. | nein |
| M16T-FUN-011 | [x] | M16-BQ implementation readiness | Der naechste Code-Slice braucht klare object-first Akzeptanzkriterien. | M16-BQ Object-Based Foundation Buildsite Puzzle Preview mit empfohlenen Dateien, Scope und Kriterien vorbereitet ist. | M16-BO Button-Flow weiter polishen, statt Bauplatzproblem objektbasiert zu testen. | nein |
| M16T-FUN-012 | [x] | Character-assisted world action rule | Passende Weltaktionen sollen sich wie lebendige Arbeit im Raum anfuehlen, nicht nur wie UI-Bestaetigung. | `360-character-assisted-world-action-rule.md` dokumentiert die Pflichtpruefung fuer Figur/Worker/Tali/Vori oder sichtbares Weltobjekt bei Bau-, Reparatur-, Sammel-, Container- und Objektaktionen. | Code-Slice mit Button-Feedback, obwohl sichtbare Figur/Worker-Handlung den Moment klarer machen wuerde. | nein |
| M16T-FUN-013 | [x] | Indirect worker control as MVP default | MVP muss spielerisch, aber scope-klein bleiben. | Regel dokumentiert ist: Spieler gibt Ziel/Werkzeug/Material/Reihenfolge/Objekt vor; Figur/Worker fuehrt sichtbar aus. | Joystick-/Avatarsteuerung als impliziter Standard. | nein |
| M16T-FUN-014 | [x] | Direct avatar control requires own gate | Direkte Steuerung oeffnet Mobile-, Kamera-, Pathfinding-, Kollision- und Accessibility-Scope. | Eigenes UX-/Control-Gate als Voraussetzung fuer direkte Figurensteuerung dokumentiert ist. | Direkte Steuerung nebenbei in Preview- oder Gameplay-Code. | nein |
| M16T-FUN-015 | [x] | Worker task loop and visible construction progress | Worker darf nicht nur dekorativ stehen oder teleportieren. | Worker-Loop Auftrag -> Figur laeuft -> sichtbare Arbeit -> Weltveraenderung -> neue Moeglichkeit -> Hook dokumentiert ist. | Figur zeigt nur Positionswechsel ohne Arbeitsbewegung oder sichtbaren Fortschritt. | nein |
| M16T-FUN-016 | [x] | M16-BQ-FIX-2 readiness | M16-BQ-FIX braucht vor Commit Pruefung auf echten Arbeitsloop und sichtbaren Construction Progress. | Folge-Code-Fix M16-BQ-FIX-2 Worker Task Loop and Visible Construction Progress mit Scope und Ziel vorbereitet ist. | M16-BQ-FIX als final ansehen, obwohl Worker-Arbeitsbewegung noch zu schwach ist. | nein |
| M16T-FUN-017 | [x] | Local construction preview flow rejoin boundary | Der gruene Bauplatz-Proof muss in den Talvori-Spine zurueck, ohne App-/Route-/BuildState-Scope zu oeffnen. | `361-local-construction-preview-boundary-and-flow-rejoin-gate.md` definiert Rejoin als lokale Preview-Verbindung von Uferhain, Slot, BuildChoice, Kamera/Fokus und BQ-Muster. | BQ weiter polishen oder Aussenwaende bauen, bevor Flow-/Boundary-Fragen geklaert sind. | nein |
| M16T-FUN-018 | [x] | BQ as object-based buildsite pattern | M16-BQ soll Muster bleiben, nicht automatisch Produktmodul werden. | BQ als lokale Referenz fuer object-first Worker-Bauplatz, Arbeitsloop und neue Moeglichkeit abgegrenzt ist. | BQ direkt als produktives Widget, Provider, Datenmodell oder BuildState-Quelle lesen. | nein |
| M16T-FUN-019 | [x] | M16-BT rejoin preview readiness | Der naechste Code-Slice braucht klare Dateien, Akzeptanzkriterien und Stop-Regeln. | M16-BT Local Uferhain-to-Buildsite Rejoin Preview mit Option-A-Dateien und Akzeptanzkriterien vorbereitet ist. | Rejoin-Code ohne klare Datei-/Import-Grenze oder App-Integration-Verbot. | nein |

### M16T-LANGUAGE

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-LANGUAGE-001 | [x] | Talvori Game Bible as primary product reference | AGENTS.md soll kurz bleiben; Produkt-, Game-, Lern- und Sprachlogik brauchen eine dauerhafte Referenz. | `docs/world_design/talvori_game_bible.md` als saubere Game Bible angelegt und in AGENTS/336 verlinkt ist. | Codex entscheidet nur aus AGENTS.md oder verstreuten Chatnotizen. | nein |
| M16T-LANGUAGE-002 | [x] | Corrected core formula and layer separation | Talvori darf nicht auf "Wort wird Objekt" reduziert werden. | Game Bible definiert Building creates context, Learning uses context, Language grows into sentences/pronunciation/conversations sowie World-Building, Language Anchor und Language Use Layer. | Wortimport als einzige Weltbauquelle oder jedes UI-Wort als Lerninhalt. | nein |
| M16T-LANGUAGE-003 | [x] | Active target language and Language Passport model | Mehrsprachigkeit braucht klare Sessions statt Mischsprache im normalen Flow. | Game Bible trennt aktive Zielsprache, UI language, Companion language und Language Passport pro Zielsprache. | Freies Mischen mehrerer Zielsprachen oder Sprachwechsel mit Datenmutation ohne Gate. | nein |
| M16T-LANGUAGE-004 | [x] | Skill profile and adaptive scaffolding | Ein linearer Levelwert reicht fuer echte Sprachfaehigkeit nicht. | Skill-Dimensionen und Beginner/Advanced/Very Advanced Experience sind dokumentiert. | Fortgeschrittene Nutzer durch offensichtliche Basics zwingen. | nein |
| M16T-LANGUAGE-005 | [x] | Internal corpus primary and optional capture | Talvori muss ohne Nutzerimport spielbar sein, ohne persoenliche Funde zu verlieren. | Internal Corpus Primary Rule und Optional Capture Rule sind in AGENTS und Game Bible dokumentiert. | User-imported/shared words als Pflichtquelle oder automatische Wortplatzierung. | nein |
| M16T-LANGUAGE-006 | [x] | AI/DeepL/Tali/Vori language boundaries | KI und DeepL duerfen helfen, aber nicht didaktische oder produktive Wahrheit allein entscheiden. | Game Bible grenzt DeepL, KI und Companion an Szene, Level, aktive Sprache, bekannte Inhalte und deterministische Regeln. | KI/DeepL als alleinige Wahrheit fuer Level, Kontext, Persistenz oder Produktfortschritt. | nein |

### M16T-MGMT

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-MGMT-001 | [x] | Repo as source of truth for project management | Notion, Linear und GitHub duerfen keine zweite Wahrheit neben Repo-Dokumenten erzeugen. | `362-notion-linear-project-management-mapping.md` definiert das Repo als Quelle fuer AGENTS.md, Game Bible, M16-Dokumente, Code, technische Entscheidungen, Stop-Regeln und Commits. | Entscheidungen gelten nur, weil sie in Notion oder Linear stehen. | nein |
| M16T-MGMT-002 | [x] | Notion as product overview mirror | Notion ist stark fuer lesbare Uebersichten, aber gefaehrlich als unversionierte Produktwahrheit. | Notion-Rolle als Kurzfassung, Roadmap, Decisions, Research, offene Fragen und visuelle Uebersicht ohne Freigabecharakter dokumentiert ist. | Notion ersetzt 328/336/Game Bible oder schreibt produktive Entscheidungen. | nein |
| M16T-MGMT-003 | [x] | Linear as work tracking mirror | Linear soll Arbeit steuerbar machen, ohne Fachentscheidungen aus dem Repo zu ziehen. | Linear-Rolle fuer Arbeitspakete, Sprints, Bugs, Review, Visual-QA, Blocker und M16-Slice-Tracking dokumentiert ist. | Linear-Issue gilt als Featurefreigabe ohne Repo-Gate. | nein |
| M16T-MGMT-004 | [x] | External write approval rule | Plugin-Writes koennen externe Wahrheit, Daten oder Tickets veraendern. | Notion-/Linear-/GitHub-/Supabase-/API-Key- und andere externe Writes als explizit freigabepflichtig dokumentiert sind. | Externe Writes, Issues, PRs, Daten- oder API-Key-Aenderungen ohne Freigabe. | nein |

### M16T-DESIGN

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-DESIGN-001 | [x] | Professional design-before-code rule | Komplexe World-/UI-Flows duerfen nicht direkt im Preview-Code gesucht werden. | `363-professional-island-build-flow-design-gate.md` definiert Research/Benchmark, schriftlichen Flow, Wireflow, visuelle Preview, Interaktionsregeln und Visual-QA vor Code. | Neuer komplexer Island-/BuildChoice-Code ohne Designphase. | nein |
| M16T-DESIGN-002 | [x] | Island build flow wireflow required before code | Der Inselbau-Flow braucht eine visuelle Reihenfolge, bevor Flutter-Layout entsteht. | M16-BW verlangt Low-Fidelity-Wireflow fuer Inselauswahl, Insel betreten, Karte bewegen/zoomen, Slot, BuildChoice, Grundstueck und Bauphase. | Flutter-Preview als Ersatz fuer fehlenden Wireflow. | nein |
| M16T-DESIGN-003 | [x] | BuildChoice interaction pattern must be visually approved | BuildChoice kippt schnell in Bottom-Sheet, Label-Wolke oder technisches Menue. | M16-BW legt fest, dass In-World-Wheel, Werkbank, Showcase oder Companion/Worker-Vorschlag vor Code visuell entschieden werden muessen. | BuildChoice-Wheel oder BuildChoice-Panel ohne visuelle Freigabe. | nein |
| M16T-DESIGN-004 | [x] | Pan/zoom/slot focus design gate | Mobile-Kamera, Slot-Fokus und Erreichbarkeit bestimmen das Spielgefuehl. | M16-BW dokumentiert native Pan/Pinch-Zoom-Erwartung, Slot-Tap-Fokus, Toolbelt-Grenzen und spaetere Kamera-/Map-Engine als eigenes Gate. | Dev-Pfeile, Zoom-Buttons, ungeregeltes Clamping oder verdeckte BuildChoice-Ghosts. | nein |
| M16T-DESIGN-007 | [x] | Modern mobile game direction board | Low-Fidelity-Wireflow reicht nicht, wenn er wie ein Arbeitsblatt wirkt. | `365-modern-mobile-game-direction-board.md` definiert moderne Mobile-Game-DNA, Benchmark-Prinzipien, Hauptflow, Screen-Richtung und Visual Direction Board. | Neuer Wireflow oder Flutter-Code ohne moderne Game-Direction. | nein |
| M16T-DESIGN-008 | [x] | Game-DNA before high-fidelity island flow | High-Fidelity-Flow braucht eine klare Talvori-Game-DNA. | M16-BY legt cozy adventure construction world, island-first, object-first, character-assisted und context-based language learning als Richtung fest. | High-Fidelity-Screens, die wieder nach Schule, Formular oder Menue-first wirken. | nein |
| M16T-DESIGN-009 | [x] | BuildChoice pattern selected by game feel | BuildChoice darf nicht nur nach technischer Einfachheit entschieden werden. | M16-BY waehlt Build Station am Slot mit fokussierter Auswahl als fuehrendes Pattern und verwirft Bottom-Sheet, Vollbild-Menue und reine Listenwahl fuer den Hauptmoment. | BuildChoice-Wheel, Bottom-Sheet oder Kartenliste ohne Spielgefuehl-Pruefung. | nein |
| M16T-DESIGN-010 | [x] | Cozy island diorama direction separated from rejected v2 board | Die moderne Richtung muss sich wie Mobile Game und nicht wie Corporate-Folie anfuehlen, darf aber nicht aus einem schwachen Zwischenboard abgeleitet werden. | M16-BY haelt Cozy Island Diorama Builder, Build Station am Slot, Worker/Tali/Vori und klare Avoid-Liste als konzeptionelle Richtung fest; `modern_mobile_game_direction_board_v2.*` ist als nicht akzeptierte Zwischenvorschau eingeordnet. | High-Fidelity-Flow oder Flutter-Code, der wieder nach Schulblatt, Menue, Dashboard, isoliertem Wheel oder dem abgelehnten v2-Board als Zielbild wirkt. | nein |

### M16T-ART

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-ART-001 | [x] | AI art production ownership | Ohne echten Artist braucht Talvori klare Rollen statt zufaelliger Einzelprompts. | `366-ai-art-production-pipeline-and-style-consistency-gate.md` trennt ChatGPT, Codex, KI-Bildtool, Nachbearbeitungstools und spaeteren Artist. | Unklare Verantwortung fuer Bildgenerierung, Art Direction oder Asset-Freigabe. | nein |
| M16T-ART-002 | [x] | Reference image is direction, not asset | Das starke Referenzbild darf nicht versehentlich als App-Screen oder Spielasset behandelt werden. | Referenzbild-Regel dokumentiert ist: Art-Direction-Reference, Dokumentationsmaterial, nicht nach `assets/`, nicht von Codex nachzeichnen. | Referenzbild kopieren, vereinfachen, nachzeichnen oder als finales Asset nutzen. | nein |
| M16T-ART-003 | [x] | Style consistency pipeline required | Talvori braucht wiedererkennbare Weltgrafik statt Stilbruch zwischen einzelnen KI-Bildern. | Kontrollierte Pipeline mit Style/Structure References, ggf. LoRA/ControlNet, manueller Nachbearbeitung und QA dokumentiert ist. | Freie Einzelprompts, zufaellige Stilwechsel oder finale Bilder ohne Pruefung. | nein |
| M16T-ART-004 | [x] | Engine-ready asset export rules | Schoene Bilder reichen nicht, wenn sie nicht layerbar, skalierbar oder lizenzklar sind. | Engine-ready Exportregeln fuer PNG/WebP mit Transparenz, getrennte Layer, Metadaten, Quellen/Prompts/Referenzen und eigenes Asset-Gate stehen. | Riesige Gesamtbilder, unklare Lizenz, fehlende Metadaten oder `assets/`-Writes ohne Gate. | nein |
| M16T-ART-005 | [x] | Talvori Art Bible v1 | Pipeline-Regeln brauchen ein konkretes Style-System, bevor Master References oder Asset-Familien entstehen. | `367-talvori-art-bible-v1.md` definiert Visual North Star, Kamera, Perspektive, Diorama-Stil, Licht, Farbe, Formen, Figuren, Build Station, HUD, Metadaten, QA und Stop-Regeln. | Master References, High-Fidelity-Flows oder Flutter-Code ohne Art Bible. | nein |
| M16T-ART-006 | [x] | Camera, perspective and diorama style system | Insel, Slots, Gebaeude und Figuren muessen in derselben 2.5D-Welt stehen. | Art Bible legt 2.5D-Diorama-Perspektive, Kamera-Gefuehl, Insel-/Slot-Proportionen und Tiefe Insel -> Grundstueck -> Gebaeude -> Raum -> Moebel -> Container fest. | Assets mit uneinheitlicher Perspektive oder technischer Editor-Draufsicht. | nein |
| M16T-ART-007 | [x] | Character and worker visual style rules | Tali, Vori und Worker muessen emotional wirken, ohne wie fremde Sticker auszusehen. | Art Bible definiert gemeinsame Figurenperspektive, Licht, Proportionen, Silhouetten, Gesten und Worker-Auftrag-vs-direkte-Steuerung-Grenze. | Figuren aus anderem Stil, Joystick-/Pathfinding-Scope oder Worker als reines UI-Icon. | nein |
| M16T-ART-008 | [x] | UI/HUD and bubble visual style rules | Spiel-HUD darf nicht wieder Web-App, Dashboard, Worksheet oder Tutorial-Panel werden. | Art Bible definiert kleine, ruhige, kontextuelle HUD-/Bubble-Regeln, Copy-Beispiele und verbotene sichtbare technische Begriffe. | Bottom-Sheet, Menue-first, Quizkarte oder dominante Admin-Kaesten als Hauptspielmoment. | nein |
| M16T-ART-009 | [x] | Art QA checklist against style drift | KI- und Nachbearbeitungsprozesse brauchen harte Pruefpunkte gegen Collage-Stil. | Art Bible listet QA gegen Kamera-, Licht-, Farb-, Form-, Detail-, Figuren-, Gebaeude-, UI-, Layer-, Export- und Metadatenbruch. | Stilbruch zwischen Insel, Gebaeude, Figuren, UI oder Asset-Familien. | nein |
| M16T-ART-010 | [x] | Prompt/reference metadata standard | Spaetere Bild- und Asset-Kandidaten brauchen nachvollziehbare Quellen, Prompts und Referenzen. | Art Bible definiert Mindestfelder fuer asset_family, working_name, purpose, source_tool, prompt, references, seed/generation_id, postprocess_tool, license_notes, export_format, layer_notes, qa_status und approved/blocked scope. | Bilder ohne Source-/Prompt-/Reference-/License-/QA-Metadaten. | nein |
| M16T-ART-011 | [x] | Starter Island Master Reference Set | M16-CC braucht klare Reference-Briefs, bevor Asset-Familien oder Bilder entstehen. | `368-starter-island-master-reference-set.md` definiert Master-Reference-Briefs fuer Starter-Insel, Build Station, Haus-Bauphasen, Worker/Tali/Vori, UI/HUD, Slot/Marker/Layer, optionale Future-/Terrain-Refs sowie Metadaten und QA. | Master References als finale Assets, App-Screens oder Code lesen. | nein |
| M16T-ART-012 | [x] | Uferhain island master reference | Die Starter-Insel darf nicht generisch werden und braucht belastbare Slot-Kapazitaet. | Uferhain ist als Kuestenhain-/Flussufer-Starterinsel mit Kueste, Flussarm, Hain, zentraler Lichtung/Hub, leichten Hoehen, ruhigen Randbereichen, 12 sichtbaren Slots, 6 freien Slots, 6 spaeteren Slots, Reserve 16-20 und neutralen Slots beschrieben. | Generische Insel, feste Kategorieplaetze oder Terrain als harte Kategorie-Sperre. | nein |
| M16T-ART-013 | [x] | Build Station master reference | BuildChoice muss Spielobjekt bleiben und darf nicht wieder Menue, Shop oder Bottom-Sheet werden. | Build Station am Slot ist als Weltobjekt beschrieben: Haus als Hauptidee, Garten/Werkstatt/Garage als ruhigere Alternativen, Wheel nur untergeordnet, Worker/Tali/Vori koennen den Moment beleben. | Menue-first, Shop, Bottom Sheet, Label-Wolke oder isoliertes Wheel als Hauptentscheidung. | nein |
| M16T-ART-014 | [x] | House build phases master reference | Hausbau braucht sichtbare, layerbare Zwischenzustaende ohne produktiven BuildState. | Lockeren Boden, vorbereiteten Boden, Fundament, Wand-Ghost, Tuer-/Fenster-Ghost und spaetere Raum-/Interior-/Container-Tiefe sind als Brief beschrieben. | Finale Haus-Assets, produktiver BuildState oder echte Bauphasen-Implementierung. | nein |
| M16T-ART-015 | [x] | Worker/Tali/Vori master reference | Figuren muessen die Welt beleben, ohne wie fremde Sticker oder direkte Steuerung zu wirken. | Gleiche Perspektive, gleiche Lichtlogik, freundliche Lesbarkeit, Worker als sichtbarer Arbeitsmoment ohne Joystick-/Pathfinding-Scope und Tali/Vori als Companion-Hilfe statt Tutorial-Panel sind definiert. | Sticker-Figuren, anderes Licht, Joystick-/Pathfinding-Scope oder Companion als UI-Lehrerbox. | nein |
| M16T-ART-016 | [x] | UI/HUD/Bubble master reference | HUD und Bubbles muessen Spielraum schuetzen und duerfen nicht nach Web-App oder Worksheet wirken. | Kleines Spiel-HUD, kurze kontextuelle Bubbles, ruhige Safe Actions und Verbote gegen Dashboard-, Worksheet-, Admin-Kasten-, Textwand- und App-Screen-Optik sind beschrieben. | Admin-HUD, Formular, Textwand, Worksheet oder App-Screen-Freigabe. | nein |
| M16T-ART-017 | [x] | Slot/marker/layer master reference | Slots muessen kreativ frei, neutral und spaeter layerbar bleiben. | Neutrale Slots, Lage statt Kategorie, gedimmte spaetere Slots, fokussierter gewaehlter Slot bei sichtbarer Welt und Layer-Reihenfolge aus der Art Bible sind als Brief definiert. | Kategorieplaetze, Asset-Dateien, Map-Daten, harte Slot-Bindung oder unklare Layerbarkeit. | nein |

### M16T-SOCIAL

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-SOCIAL-001 | [x] | Social/Competition als spaeteres Gate aufnehmen | Social kann motivieren, aber auch Druck erzeugen. | Social/Competition als eigenes Gate in Roadmap/Backlog steht. | Produktive Social-Mechanik. | nein |
| M16T-SOCIAL-002 | [x] | Gegen-andere-antreten nur nach Fairness-/Safety-Gate | Wettbewerb kann Lernen verzerren. | Fairness, Safety, Alters-/Privacy- und Anti-Druck-Regeln dokumentiert sind. | Competition ohne Gate. | nein |
| M16T-SOCIAL-003 | [x] | Clan-/Team-/Freunde-Ideen als Research-Thema aufnehmen | Teams und Freunde koennen spaeter Talvori staerken. | Clan/Freunde/Team-Research mit Talvori-Prinzipien existiert. | Social Scope Drift. | nein |

### M16T-METRICS

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-METRICS-001 | [x] | Erfolgsmessung fuer Lernerfolg definieren | Produktfortschritt muss Lernen messen, nicht nur Nutzung. | Lernmetriken ohne SRS-Mutation definiert sind. | Analytics ohne Lernziel. | nein |
| M16T-METRICS-002 | [x] | Erfolgsmessung fuer Motivation/Retention definieren | Motivation soll beobachtbar, aber nicht manipulativ werden. | Motivations-/Retention-Metriken mit Fairness-Grenzen dokumentiert sind. | Druckmetriken. | nein |
| M16T-METRICS-003 | [x] | Privacy-Gate fuer spaetere Analytics definieren | Messung darf private Wort-/Kontextdaten nicht gefaehrden. | Analytics-Privacy-Gate dokumentiert ist. | Analytics ohne Privacy. | nein |

## 33. M16-U Dokumentationsvisualisierungen

Optionaler M16-U-Visualsatz:

`docs/world_design/previews/m16_u_product_delivery_dashboard/`

Geplante Visuals:

- `progress_dashboard.png`
- `mvp_roadmap.png`
- `scrum_lite_flow.png`
- `research_to_product_loop.png`
- `change_intake_flow.png`
- optional `00_contact_sheet.png`

Diese Visuals sind Dokumentationsmaterial, keine App-Screens, keine
Screenshots, keine Spielassets und keine Dateien unter `assets/`.

Visual-QA:

- Text bleibt in Karten/Rahmen/Panels.
- Ausreichender Innenabstand.
- Kartenabstaende.
- Keine Ueberlappung von Karten, Labels, Pfeilen, Titeln, Footern oder
  Legenden.
- Contact Sheet vollstaendig lesbar, falls erzeugt.
- Keine abgeschnittenen Inhalte.

## 34. Stop-Regeln fuer M16-T / M16-U

M16-T gibt nicht frei:

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
