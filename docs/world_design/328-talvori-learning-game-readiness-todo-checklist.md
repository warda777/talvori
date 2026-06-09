# M16-T: Talvori Learning Game Readiness ToDo Checklist

Stand: 2026-06-09

Status: `fortlaufende ToDo-/Gate-Liste gestartet / keine Implementierung`

## 0. Product Delivery Dashboard

Letzte Aktualisierung: 2026-06-09

Aktive Sprint-ID: `M16-BD`

Sprint Goal:

> Starter-Insel-Identitaet, Biome, Kategorie-Scope und Terrain-Varianten fachlich festlegen.

### 0.1 Gesamtfortschritt

| Kennzahl | Wert |
| --- | --- |
| Gesamtanzahl M16-T-Items | 145 |
| Offen `[ ]` | 0 |
| Teilweise erledigt `[~]` | 12 |
| Erledigt `[x]` | 121 |
| Blockiert `[!]` | 12 |
| Ausgelagert `[>]` | 0 |
| Gewichteter Fortschritt | 87.6 % |
| Fortschrittsbalken | `██████████████████░░` |

Naechste empfohlene IDs:

- M16T-WORLD-002
- M16T-WHEEL-003
- M16T-PROD-003
- M16T-CORE-003
- M16T-L2W-003
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

### 0.3 Bereichs-Dashboard fuer 26 Bereiche

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
| World / Island / Plot | M16T-WORLD | 4 | 3 | 1 | 0 | 0 | 87.5 % | `█████████░` | ThemeIsland-/Plot-Capacity in konkreten spaeteren Slices anwenden. |
| Container / Depth | M16T-DEPTH | 3 | 3 | 0 | 0 | 0 | 100.0 % | `██████████` | TinyObject-/Container-Regeln in kuenftigen World-/UI-Slices als Stop-Regel anwenden. |
| Build-Wheel | M16T-WHEEL | 4 | 2 | 1 | 0 | 1 | 62.5 % | `██████░░░░` | Wheel-Code weiter blockiert halten; In-place-Regeln erst mit eigenem Gate anwenden. |
| Undo / Reversibility | M16T-UNDO | 3 | 3 | 0 | 0 | 0 | 100.0 % | `██████████` | Undo-/Resizing-Regeln in spaeteren Persistenz- und World-Slices anwenden. |
| Tali/Vori Companion | M16T-COMP | 4 | 4 | 0 | 0 | 0 | 100.0 % | `██████████` | Companion-Regeln in kuenftigen Copy-/Review-Slices anwenden. |
| Mobile / Clutter / Accessibility | M16T-MOBILE | 4 | 4 | 0 | 0 | 0 | 100.0 % | `██████████` | Dichte-, Overlay- und A11y-Regeln in kuenftigen MVP-Screens anwenden. |
| Sensitive / Policy | M16T-SENS | 3 | 2 | 1 | 0 | 0 | 83.3 % | `████████░░` | Sensitive-no-deco/no-reward-Regel spaeter mit Asset-/World-Gates abschliessen. |
| Asset Scope | M16T-ASSET | 4 | 2 | 1 | 0 | 1 | 62.5 % | `██████░░░░` | Asset-Scope bleibt blockiert; Lizenz-/Quelle-/Benennung-Regeln in spaeteren Asset-Slices anwenden. |
| Datenmodell / Persistenz / Backend | M16T-DATA | 5 | 1 | 0 | 0 | 4 | 20.0 % | `██░░░░░░░░` | Offline-/Sync-Konfliktregeln anwenden; echte Datenmodell-/Persistenz-Gates bleiben blockiert. |
| Confidence Scoring / AI Governance | M16T-AI | 4 | 2 | 2 | 0 | 0 | 75.0 % | `████████░░` | AI-/Privacy-Regeln in eigenem Provider-Governance-Gate vertiefen. |
| Review Queue | M16T-QUEUE | 4 | 4 | 0 | 0 | 0 | 100.0 % | `██████████` | Queue-Regeln in kuenftigen Semantik-/MVP-Slices anwenden. |
| Play-First Learning | M16T-PLAY | 9 | 9 | 0 | 0 | 0 | 100.0 % | `██████████` | Play-First- und Island-First-Regeln in MVP-/Gameplay-/UI-/Implementierungs-Slices weiter als harte Stop-Regeln anwenden. |
| Interaction Patterns | M16T-INTERACT | 6 | 6 | 0 | 0 | 0 | 100.0 % | `██████████` | Interaction Pattern Decision Matrix und Research-/Benchmark-Check in kuenftigen UI-/World-/Gameplay-/Implementierungs-Slices anwenden. |
| Starter Island Infrastructure | M16T-INFRA | 11 | 11 | 0 | 0 | 0 | 100.0 % | `██████████` | Starter-Insel-Infrastruktur aus 351 und Uferhain-Identitaet aus 353 in kommenden World-/Island-/Plot-/BuildChoice-Slices anwenden. |
| Technische Architektur / App-Integration | M16T-ARCH | 4 | 0 | 0 | 0 | 4 | 0.0 % | `░░░░░░░░░░` | Boundaries klaeren, App-Integration blockiert halten. |
| Dokumentations- und Visual-QA | M16T-DOC | 4 | 2 | 1 | 0 | 1 | 62.5 % | `██████░░░░` | Visual-QA-Regel anwenden; Screenshots bleiben blockiert. |
| Commit-/Review-Hygiene | M16T-GIT | 3 | 2 | 0 | 0 | 1 | 66.7 % | `███████░░░` | Status-, Diff- und Scope-Checks vor Commit weiter anwenden. |

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

## 26. Commit-/Review-Hygiene

| ID | Status | Thema | Warum wichtig | Done wenn | Blockiert | Darf Code erzeugen |
| --- | --- | --- | --- | --- | --- | --- |
| M16T-GIT-001 | [x] | `git status` vor Commit | Unbeabsichtigte Dateien sollen sichtbar bleiben. | Jeder Abschluss `git status --short` berichtet. | Commit ohne Status. | nein |
| M16T-GIT-002 | [x] | Scope gegen Stop-Regeln pruefen | Stop-Regeln verhindern Drift. | Jede Abschlussausgabe Stop-Regeln bestaetigt. | Drift in App/Assets/Persistenz. | nein |
| M16T-GIT-003 | [!] | Commit erst nach separater Freigabe | Review kann vor Commit noch korrigieren. | Nutzer gibt Commit explizit frei. | Automatischer Commit. | nein |

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
  Lager/Container, Wissen, Codex, Safe/Later/Backlog und Ufer/Wasser.
- Terrain erzeugt lokale Varianten wie `Markt am Ufer` oder `Zuhause im
  Hain`, blockiert Kategorien aber nicht hart.
- Future Island Families wie Wueste, Berg/Schnee, Hafen/Meer, Wald/Natur,
  Stadt/Dorf, Wissen/Codex und Werkstatt/Technik bleiben nach MVP oder eigene
  Gates.

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
| MVP-kritisch | M16T-PROD-001..003, M16T-CORE-001..003, M16T-L2W-001..003, M16T-LEARN-001..002, M16T-WOT-001..008, M16T-SEM-001..004, M16T-SCALE-001..004, M16T-REWARD-001..005, M16T-WORLD-001, M16T-WORLD-004, M16T-SENS-001..003, M16T-QUEUE-001..004, M16T-GAME-001..004, M16T-PLAY-001..005, M16T-PLAY-007..009, M16T-INFRA-001..011, M16T-MVP-004 | Diese Punkte definieren den kleinen spielbaren Lernloop, das Play-First-/Island-First-Gefuehl, die Starter-Insel-Grundlage und verhindern falsche Weltreaktionen. |
| Vor MVP zu klaeren | M16T-MOBILE-001..004, M16T-COMP-001..004, M16T-ARCH-001, M16T-ARCH-002, M16T-ARCH-003, M16T-DATA-001, M16T-DATA-002, M16T-UNDO-001 | Produktive Nutzbarkeit braucht Mobile, Companion-Grenzen, technische Boundaries und Datenentscheidungen. |
| Nach MVP | M16T-WHEEL-002..004, M16T-WORLD-002..003, M16T-DEPTH-001..002, M16T-SOCIAL-001..003, M16T-METRICS-001..003 | Wichtig, aber nicht zwingend fuer ersten spielbaren Lernloop. |
| Produktions-/release-kritisch | M16T-DATA-003..005, M16T-ARCH-004, M16T-ASSET-001..004, M16T-DOC-001..004, M16T-GIT-001..003 | Noetig fuer echte Produktqualitaet, Release, Daten- und Asset-Sicherheit. |
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
| M16T-DASH-003 | [x] | Bereichsfortschritt je 26 Bereiche anzeigen | Schwache Bereiche muessen sichtbar bleiben. | Bereichs-Dashboard fuer die bestehenden Bereiche plus M16T-PLAY, M16T-INTERACT und M16T-INFRA steht. | Nur Gesamtzahl ohne Bereichssicht. | nein |
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
| M16T-INFRA-010 | [x] | Future Island Family Roadmap | Spaetere Biome sollen sichtbar geplant, aber vom MVP getrennt bleiben. | Wuesten-, Berg-/Schnee-, Hafen-/Meer-, Wald-/Natur-, Stadt-/Dorf-, Wissens-/Codex- und Werkstatt-/Technik-Inseln als Roadmap abgegrenzt sind. | Future-Island-Scope im Starter-MVP. | nein |
| M16T-INFRA-011 | [x] | Player-editable Terrain Boundary | Nutzerfreiheit braucht Grenzen zwischen freier Kategorie und fixer Infrastruktur. | MVP fixiert Kueste, Fluss, Hauptwege, Hub und Landmarken; Nutzer waehlen Kategorie/Variante, Terrainmodifikation bleibt Gate. | Terrain-Editor, freie Fluss-/Pfadbearbeitung oder Persistenz ohne Gate. | nein |

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
