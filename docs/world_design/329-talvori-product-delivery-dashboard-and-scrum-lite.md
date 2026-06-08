# M16-U: Talvori Product Delivery Dashboard and Scrum-Lite Operating Model

Stand: 2026-06-08

Status: `Dokumentations-/Steuerungsmodell gestartet / keine Implementierung`

## 1. Ziel

M16-U ergaenzt M16-T um ein steuerbares Fortschrittsdashboard,
Prozent-Progressbars, Scrum-lite-Arbeitsmodell, MVP-Roadmap,
Change-/Idea-Intake und Research-/Benchmark-Gate.

M16-U baut die bestehende Checkliste nicht um. Die fuehrende Liste bleibt:

`docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`

M16-U ist keine Codefreigabe, keine App-Integration, keine Route, keine
Persistenzfreigabe, keine Assetfreigabe und keine Implementierungsfreigabe.

## 2. Delivery Dashboard

Aktueller Stand nach M16-U:

| Kennzahl | Wert |
| --- | --- |
| Gesamtanzahl M16-T-Items | 119 |
| Offen | 79 |
| Teilweise erledigt | 10 |
| Erledigt | 16 |
| Blockiert | 12 |
| Ausgelagert | 2 |
| Gewichteter Fortschritt | 17.6 % |

Fortschritt:

```text
████░░░░░░░░░░░░░░░░ 17.6 %
```

Naechste empfohlene Arbeitsrichtung:

1. Minimal spielbaren Lernloop definieren.
2. Core Loop und Learning-to-World Contract ausarbeiten.
3. Minimal Word Outcome Taxonomy finalisieren.
4. Reward ohne Druck als Fachgate definieren.
5. Review Queue als MVP-kritisches Gate planen.
6. Duolingo- und Supercell-/Clash-Research als Benchmark-Gates starten.

## 3. Scrum-lite Operating Model

| Element | Regel |
| --- | --- |
| Product Owner | Andreas trifft Produktentscheidungen. |
| Product Coach / Review | ChatGPT hilft beim Strukturieren, Bewerten und Gegenpruefen. |
| Implementierung | Codex setzt nur freigegebene, enge Slices um; manuelle Pruefung bleibt Pflicht. |
| Product Backlog | M16-T ist das fuehrende Backlog. |
| Sprint Backlog | Pro Block werden relevante M16-T-IDs ausgewaehlt. |
| Sprint Goal | Ein kurzer Satz beschreibt den Nutzen des Blocks. |
| Definition of Ready | IDs, Scope, Non-Goals, Dateien, Stop-Regeln und Checks sind klar. |
| Definition of Done | Dateien, Checks, Stop-Regeln, ID-Status und `git status` sind berichtet. |
| Commit-Regel | Commit erst nach separater Freigabe. |

## 4. MVP-Roadmap

Ziel der ersten lauffaehigen Version:

> Ein kleiner, spielbarer Lernloop, in dem Lernen sichtbar einen sicheren,
> reversiblen Weltvorschlag erzeugt, ohne automatische Platzierung,
> Build-State, Persistenz-Drift oder Retention-Druck.

MVP-kritisch:

- Produktanker und Unterschied Lernziel/Spielziel.
- Core Loop.
- Learning-to-World Contract.
- Lernloop-Schutz ohne SRS-/`word_progress`-Mutation.
- Minimal Word Outcome Taxonomy.
- Semantik-System und 20.000+-Skalierungsprinzip.
- Reward ohne Druck.
- Minimaler World Feedback Loop.
- Sensitive-Regeln.
- Review Queue.
- Gameplay Pillars und kleiner Quest-/Challenge-Loop.

Vor MVP zu klaeren:

- Mobile-/Accessibility-Dichtebudgets.
- Companion-Regeln.
- Architecture/Boundary Gate.
- Datenmodell- und Persistenzrichtung, falls echte Speicherung noetig wird.

Nach MVP:

- Build-Wheel.
- tiefe Container-/Depth-Systeme.
- Social/Competition.
- fortgeschrittene Metriken.
- komplexe ThemeIsland-Resizing-Systeme.

## 5. Change-/Idea-Intake

Neue Ideen werden aufgenommen, aber nicht sofort umgesetzt.

Jede Idee braucht:

- ID,
- Quelle/Grund,
- Hypothese,
- betroffene M16-T-IDs,
- Entscheidung,
- MVP-Relevanz,
- Risiko,
- naechsten Schritt.

Entscheidungen:

- aufnehmen,
- parken,
- ablehnen,
- research noetig.

## 6. Research-/Benchmark-Gate

Produktive Mechaniken fuer Lernlogik, Reward, Progression, Social,
Competition, Retention, UX und Spielmechanik brauchen Research vor Umsetzung.

Erste Benchmarks:

- Duolingo fuer Habit, XP, Streaks, Leagues und Lernmotivation.
- Clash of Clans / Supercell fuer Progression, Entscheidungen, Trade-offs,
  Social Play, Competition, Clans und Balance.

Regel:

Talvori kopiert nicht blind. Es werden nur Prinzipien abgeleitet:

- Was funktioniert?
- Warum funktioniert es?
- Was passt zu Talvori?
- Was ist gefaehrlich?
- Wie bleibt Lernen wichtiger als Retention-Druck?

## 7. Dokumentationsvisualisierungen

M16-U erzeugt optionale Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_u_product_delivery_dashboard/`

Visuals:

- `progress_dashboard.png`
- `mvp_roadmap.png`
- `scrum_lite_flow.png`
- `research_to_product_loop.png`
- `change_intake_flow.png`
- optional `00_contact_sheet.png`

Diese PNGs sind Dokumentationsmaterial, keine App-Screens, keine Screenshots,
keine finalen UI-PNGs, keine Spielassets und keine Dateien unter `assets/`.

## 8. Stop-Regeln

Aus M16-U folgt ausdruecklich:

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
