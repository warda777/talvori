# M16-AG: Broad Learning and Game Benchmark Research Gate

Stand: 2026-06-08

Status: `Research-Prep-/Dokumentations-Slice / keine Implementierung`

## 1. Zweck

M16-AG erweitert die bisherige Research-Ausrichtung. Talvori betrachtet nicht
mehr nur Duolingo und Supercell/Clash, sondern bereitet eine breitere
Benchmark-Landkarte fuer Lern-, Habit-, Flashcard-, Interactive-Learning-,
AI-Tutor-, Aufbau-, Social-, Challenge- und Progression-Systeme vor.

M16-AG ist eine Research-Landkarte. Es ist keine echte Research-Auswertung,
keine Mechanikfreigabe, keine Produktentscheidung und keine Implementierung.

Ziel:

```text
Benchmarks sammeln
-> Vergleichskriterien definieren
-> Risiken sichtbar machen
-> Talvori-Ableitungsfragen vorbereiten
-> spaetere Deep-Research-Gates ermoeglichen
```

## 2. Non-Goals und harte Stop-Regeln

M16-AG erzeugt nicht:

- keine Implementierung,
- keine Flutter-/Dart-Codeaenderung,
- keine App-Integration,
- keine Route,
- keine neue Seite,
- keine Tests,
- keine Widget-Tests,
- keine Screenshots,
- keine Runtime-Konfiguration,
- keine Persistenz,
- keine Supabase Writes,
- keine lokalen DB-Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine Reward Bridge,
- keine automatische Wortplatzierung,
- kein Build-Wheel-Code,
- keine Assets,
- keine Asset-Dateien unter `assets/`,
- kein Build-State,
- kein `frame_started`,
- keine Bauzustaende,
- keine Social-/Competition-Freigabe,
- keine Analytics-/Metrics-Implementierung,
- keine echte Monetarisierungsentscheidung,
- keine produktive Research-Auswertung als Mechanikfreigabe.

Benchmark-Namen in diesem Dokument sind Research-Kandidaten. Sie sind keine
Empfehlung, keine Kopiervorlage und keine Aussage, dass eine konkrete Mechanik
fuer Talvori geeignet ist.

## 3. Gelesene Grundlagen

| Dokument | Relevanz fuer M16-AG |
| --- | --- |
| `328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrende M16-T-ID-Liste, Dashboard und Research-/Social-/Metrics-Status. |
| `336-documentation-map-and-slice-reading-rules.md` | Pflichtlektuere-, Visual-QA-, Scope- und Output-Regeln. |
| `329-talvori-product-delivery-dashboard-and-scrum-lite.md` | Research-Gate, MVP-Roadmap, Scrum-lite und Change-/Idea-Intake. |
| `340-gameplay-pillars-and-mvp-quest-loop-research-prep.md` | Bisherige enge Research-Vorbereitung fuer Duolingo und Supercell/Clash. |
| `330-minimal-playable-learning-loop-contract.md` | Lernen erzeugt Moeglichkeit, keine automatische Platzierung. |
| `331-minimal-word-outcome-detail-gate.md` | Outcomes, Queue-Ausgaenge und Reward/Placement/BuildState-Grenzen. |
| `332-reward-budget-and-review-queue-control-gate.md` | Reward-Budget, Queue-Budget, Safe Defaults und Anti-Druck-Regeln. |
| `333-minimal-semantic-profile-and-routing-priority-gate.md` | Safety, Sense, Word Type, Clutter und Confidence vor Reward/World Feedback. |
| `334-companion-and-sensitive-return-safety-gate.md` | Companion, Pause, Fehler und sensitive Inhalte bleiben druckfrei. |
| `335-learning-states-and-srs-boundary-gate.md` | Lernzustaende bleiben von SRS, `word_progress`, Reward und Weltfeedback getrennt. |
| `337-mobile-density-accessibility-and-depth-planning-gate.md` | Mobile-Dichte, Micro Sessions, Overlays, Accessibility und Container/Depth. |
| `338-world-loop-plot-family-and-buildchoice-gate.md` | WorldCandidate, Plot Family und BuildChoice bleiben Candidates, kein Build. |
| `339-theme-island-resizing-and-remaining-world-rules-gate.md` | Capability, TinyObject, Resizing und sensitive-safe Asset-Regeln. |

## 4. Betroffene M16-T-IDs

| ID | M16-AG Entscheidung |
| --- | --- |
| `M16T-RESEARCH-002` | Bleibt `[>]`: Duolingo braucht weiter ein eigenes Deep-Research-Gate. |
| `M16T-RESEARCH-003` | Bleibt `[>]`: Supercell/Clash braucht weiter ein eigenes Deep-Research-Gate. |
| `M16T-RESEARCH-004` | Bleibt `[~]`: Research-to-Talvori-Prinzipien sind operationalisiert, echte Ergebnisse fehlen. |
| `M16T-SOCIAL-001` | Wird `[x]`: Social/Competition ist als spaeteres Gate und Research-Feld aufgenommen. |
| `M16T-SOCIAL-002` | Wird `[~]`: Fairness-/Safety-/Privacy-/Anti-Druck-Regeln sind vorbereitet, aber kein eigenes Social-Gate. |
| `M16T-SOCIAL-003` | Wird `[~]`: Clan-/Team-/Freunde-Ideen sind als Research-Thema aufgenommen, aber nicht tief ausgewertet. |
| `M16T-METRICS-001` | Wird `[~]`: Lernerfolgsmetriken sind als Research-/Gate-Richtung definiert, aber nicht produktiv. |
| `M16T-METRICS-002` | Wird `[~]`: Motivation/Retention-Metriken sind mit Anti-Druck-Grenzen vorbereitet. |
| `M16T-METRICS-003` | Wird `[~]`: Analytics-/Privacy-Gate ist als Pflicht vorbereitet, aber nicht umgesetzt. |

## 5. Warum breiter als Duolingo und Supercell/Clash?

Duolingo ist ein wichtiger Benchmark fuer Habit, Daily Practice, Streaks, XP,
Leagues und Lernmotivation. Gerade deshalb muss Talvori dort genau zwischen
hilfreichem Rhythmus und druckvoller Retention unterscheiden.

Supercell/Clash ist ein wichtiger Benchmark fuer Aufbaufortschritt,
Entscheidungen, Trade-offs, Progression, Social/Competition, Gruppen und
Balance. Gerade deshalb muss Talvori dort genau zwischen motivierendem Aufbau
und FOMO, War Pressure, Pay-to-Win oder Social Pressure unterscheiden.

Talvori braucht zusaetzlich Benchmarks fuer:

- interaktives Lernen,
- Flashcards und Recall,
- Spaced Repetition,
- AI Tutor / Companion Learning,
- Kontextlernen,
- freiwillige Quests und Challenges,
- Worldbuilding und Progression,
- Mobile Micro Sessions,
- Accessibility und ruhiges Lernen,
- spaetere Social-/Fairness-Regeln,
- spaetere Metrics fuer Lernerfolg und Motivation.

M16-AG macht deshalb zuerst eine Landkarte. Nicht jede App wird tief
analysiert. Nicht jede beobachtete Mechanik darf uebernommen werden.

## 6. Benchmark-Kategorien

| Kategorie | Was untersuchen? | Warum fuer Talvori wichtig? | Harte Grenze |
| --- | --- | --- | --- |
| Habit / Daily Practice | Rueckkehr, Tagesziel, Rhythmus, Einstieg nach Pause. | Talvori braucht regelmaessiges Lernen ohne Schuld. | keine Streak-Schuld, kein Verlust, kein FOMO. |
| Flashcard / Recall / SRS | Wiederholung, Abruf, Spaced Repetition, Fehlerfeedback. | Bestehende Lernbasis darf nicht korrumpiert werden. | keine SRS-/`word_progress`-Mutation ohne Gate. |
| Interactive Learning / Learn by Doing | kleine Aufgaben, direkte Rueckmeldung, Erklaerung. | Talvori soll Kontext und Bedeutung staerken. | keine Pflichtquest, keine UI-Events als Fortschritt. |
| AI Tutor / Companion Learning | Erklaeren, Fragen, Dialog, Personalisierung. | Tali/Vori soll helfen, aber nicht entscheiden. | keine Beratung, kein Provider-Call ohne Gate. |
| Quest / Challenge / Goals | freiwillige Ziele, kurze Aufgaben, Wahlmomente. | Spielgefuehl darf aus Lernen entstehen. | keine Questpflicht, Timer oder Build-State. |
| Worldbuilding / Progression | Aufbau, sichtbarer Fortschritt, Langzeitmotivation. | "Meine Woerter bauen eine Welt" braucht sichere Progression. | keine automatische Wortplatzierung. |
| Social / Team / Community | Freunde, Gruppen, Hilfe, Showcase. | Social kann motivieren, aber ist nach MVP. | kein Leaderboard/PvP ohne Fairness-Gate. |
| Competition / League / Ranking | Rang, Vergleich, Wettbewerb, Balance. | Spaeter relevant, aber druckgefaehrlich. | keine Blossstellung, kein War Pressure. |
| Motivation / Retention without Pressure | sanfte Bindung, Pausen, Comeback, Friktion. | Motivation darf Lernen nicht manipulieren. | keine sensitive Trigger, keine Schuld. |
| Mobile UX / Micro Sessions | kurze Sessions, Lesbarkeit, Tap-Ziele, Overlays. | MVP muss auf kleinen Screens ruhig bleiben. | keine Textwuesten, keine Objektwolke. |
| Accessibility / Calm Learning | Kontrast, Motion, Screenreader, Fehlerfreundlichkeit. | Lernen soll einladend und erreichbar bleiben. | keine produktive UI ohne A11y-Gate. |
| Metrics / Learning Success | Lernerfolg, Motivation, Retention, Privacy. | Erfolg darf nicht nur Nutzung messen. | keine Analytics ohne Privacy-Gate. |

## 7. Benchmark-Kandidaten-Matrix

Diese Matrix ist eine Startlandkarte. Sie ersetzt keine echte Recherche und
enthaelt keine aktuellen Marktclaims.

| Kandidat | Warum relevant | Zu untersuchen | Was Talvori lernen koennte | Gefahr | MVP-Relevanz | Nach-MVP-Relevanz | Tiefer Slice noetig? |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Duolingo | Habit, Daily Practice, Lernmotivation. | Streaks, XP, Leagues, Daily Goals, Motivationssprache. | Rhythmus, kleine Lektionen, klare Rueckmeldung. | Schuld, FOMO, XP-Jagd, League-Druck. | hoch als Anti-Druck-Vergleich | mittel | ja, eigenes Gate bleibt `[>]`. |
| Supercell / Clash of Clans | Aufbau, Progression, Entscheidungen, Social. | Base Progression, Ressourcen, Timer, Clans, Competition. | Weltfortschritt, Trade-offs, Langzeitziele. | Pay-to-Win, Timer/FOMO, War Pressure, Social Pressure. | mittel als Warn-/Progressionsvergleich | hoch | ja, eigenes Gate bleibt `[>]`. |
| Brilliant | Interaktives Verstehen und Learn by Doing. | gefuehrte Aufgaben, Erklaerschritte, visuelle Probleme. | Bedeutung vor Auswendiglernen, kleine Denk-Challenges. | zu viel Problem-UI statt Weltgefuehl. | hoch | mittel | ja, spaeterer Interactive-Learning-Slice. |
| Quizlet | Flashcards, Sets, Recall, Lernmodi. | Karten, Tests, Sets, schnelle Wiederholung. | klare Recall-Schleifen und Nutzerkontrolle. | oberflaechliches Pauken, Set-/UI-Ueberladung. | hoch | mittel | ja, nach SRS-/Learning-Gate. |
| Anki | SRS, Eigenkontrolle, Langzeitwiederholung. | Spaced Repetition, Decks, Ease/Review-Last. | Wiederholung ernst nehmen, aber Daten schuetzen. | Komplexitaet, Review-Schuld, Migration-Risiko. | hoch als SRS-Grenze | hoch | ja, SRS-/Migration-Gate separat. |
| Khan Academy / Khanmigo | Erklaerlernen und Tutor-Unterstuetzung. | Schrittweise Erklaerung, Hilfestellung, Tutor-Grenzen. | Tali/Vori kann erklaeren, nicht entscheiden. | falsche Beratung, Privacy, Provider-Abhaengigkeit. | mittel | hoch | ja, AI-/Privacy-Gate. |
| Memrise | Sprache, Kontext, Wiederholung, alltagsnahe Beispiele. | Vokabeln, Kontext, Aussprache, Wiederholung. | Woerter im realen Kontext staerken. | reine Listenlogik oder Content-Abhaengigkeit. | mittel | mittel | optional. |
| Drops | Micro Sessions, visuelle Wortassoziation. | kurze Einheiten, visuelle Klarheit, Tempo. | kleine Sessions und klare Mobile-Flaechen. | Bildzwang, oberflaechliche Zuordnung. | mittel | niedrig bis mittel | optional. |
| Habitica | Habit als Spiel, Aufgaben als RPG-Rahmen. | Habits, To-dos, Party/Social, Belohnungen. | externe Motivation und Selbststeuerung verstehen. | Schuld, Straflogik, Gamification ueber Lernen. | niedrig bis mittel | mittel | ja, nur Anti-Druck/Quest-Vergleich. |
| Pokemon GO | Sammeln, reale Welt, Events, Social/Teams. | Sammelmotivation, Exploration, Events, Teamgefuehl. | Sammeln kann Freude machen, ohne jedes Wort zu platzieren. | FOMO, Standort-/Privacy-Risiko, Event-Druck. | niedrig | mittel bis hoch | nur spaeter, kein GPS-Ziel. |
| Minecraft Education | Kreativwelt, Lernen, Sandbox, Aufgaben. | offene Welt, Lernaktivitaeten, Creator/Teacher-Struktur. | Welt als Lernraum, aber kuratiert. | zu breite Sandbox, Bauzwang, Asset-/3D-Scope. | niedrig bis mittel | hoch | spaeter, Worldbuilding-Gate. |
| Lingvist / Babbel | strukturierter Sprachlernfortschritt. | adaptive Uebungen, Kurse, Progression, UX. | Lernprogression und klare Sprachziele. | Kurszwang, zu wenig Weltgefuehl. | mittel | mittel | optional. |

## 8. Research-Fragen pro Kategorie

| Kategorie | Leitfragen | Betroffene M16-T-Regeln | Blockiert bleibt |
| --- | --- | --- | --- |
| Habit / Daily Practice | Was erzeugt Rueckkehr? Warum? Welche Emotion entsteht? Wie bleibt Pause neutral? | `M16T-REWARD-004`, `M16T-REWARD-005`, `M16T-GAME-004` | Streak-Schuld, Verlust, FOMO. |
| Flashcard / Recall / SRS | Was verbessert Abruf? Wie bleibt Review freiwillig? Wo entsteht Schuld? | `M16T-LEARN-002`, `M16T-QUEUE-002`, `M16T-METRICS-001` | SRS-/`word_progress`-Mutation ohne Gate. |
| Interactive Learning | Wann hilft eine Aufgabe wirklich? Was ist zu viel? | `M16T-WOT-005`, `M16T-GAME-002`, `M16T-MOBILE-003` | Pflichtquest, UI-Fortschritt. |
| AI Tutor / Companion | Wann erklaert ein Tutor gut? Wann wirkt er autoritaer? | `M16T-COMP-001..004`, `M16T-AI-002`, `M16T-AI-004` | Beratung, Provider-Call, Privacy-Drift. |
| Quest / Challenge / Goals | Welche Ziele motivieren ohne Druck? Welche Budgetgrenzen braucht es? | `M16T-GAME-002`, `M16T-REWARD-002`, `M16T-QUEUE-002` | Timer, Questpflicht, FOMO. |
| Worldbuilding / Progression | Was macht sichtbaren Fortschritt befriedigend? Welche Trade-offs sind fair? | `M16T-WORLD-001`, `M16T-WHEEL-002`, `M16T-UNDO-001` | BuildState, Placement, Economy. |
| Social / Team / Community | Wann hilft Social? Wann entsteht Vergleichsdruck? | `M16T-SOCIAL-001..003`, `M16T-COMP-003` | Leaderboard/PvP/Clans im MVP. |
| Competition / League / Ranking | Was ist fairer Wettbewerb? Wer wird ausgeschlossen? | `M16T-SOCIAL-002`, `M16T-METRICS-002` | Blossstellung, Ranking-Druck. |
| Motivation / Retention | Welche Signale laden ein? Welche manipulieren? | `M16T-REWARD-001..005`, `M16T-SENS-003` | sensitive Retention-Trigger. |
| Mobile UX / Micro Sessions | Wie kurz kann eine Session sein? Wie viele Elemente sind lesbar? | `M16T-MOBILE-001..004`, `M16T-QUEUE-002` | Textwueste, Review-Masse. |
| Accessibility / Calm Learning | Wie werden Fehler, Motion, Kontrast und Screenreader bedacht? | `M16T-MOBILE-004`, `M16T-DOC-003` | Produktive UI ohne A11y-Gate. |
| Metrics / Learning Success | Was misst Lernen statt Nutzung? Welche Daten sind privat? | `M16T-METRICS-001..003`, `M16T-AI-004` | Analytics ohne Privacy-Gate. |

Jede Kategorie muss fragen:

- Was funktioniert?
- Warum funktioniert es?
- Welche Nutzeremotion wird erzeugt?
- Was passt zu Talvori?
- Was muss Talvori vermeiden?
- Welche M16-T-Regeln sind betroffen?
- Welche Mechaniken bleiben blockiert?

## 9. Research-to-Talvori-Prinzipien

Spaetere Research-Ergebnisse duerfen nicht als Mechanik kopiert werden. Sie
muessen in Talvori-Prinzipien uebersetzt werden.

Verbindliches Template:

| Feld | Frage |
| --- | --- |
| Quelle / Benchmark | Welche App, welches Spiel oder welches Pattern wurde betrachtet? |
| Beobachtung | Was wurde beobachtet, ohne daraus schon eine Freigabe abzuleiten? |
| Mechanik | Welche konkrete Mechanik oder Produktlogik steckt dahinter? |
| Zugrunde liegendes Prinzip | Welches allgemeinere Prinzip erklaert die Wirkung? |
| Talvori-Anwendung | Wie koennte Talvori das Prinzip sicher und lernzentriert nutzen? |
| Lernnutzen | Welcher Lernprozess wird besser? |
| Motivationsnutzen | Welche positive Emotion entsteht ohne Druck? |
| Risiko | Welche Gefahr entsteht fuer Druck, Safety, Privacy, FOMO, Pay-to-Win oder Scope? |
| Anti-Druck-Pruefung | Entsteht Schuld, Zwang, Verlustangst, Massenreview oder sensitive Retention? |
| Safety-/Privacy-Pruefung | Sind sensible Inhalte, private Woerter, Kontextdaten oder Minderjaehrige betroffen? |
| Entscheidung | uebernehmen / angepasst uebernehmen / ablehnen / spaeter pruefen. |
| Betroffene M16-T-IDs | Welche IDs muessen aktualisiert, geprueft oder neu angelegt werden? |
| Notwendiges Folge-Gate | Welches Gate muss vor Umsetzung kommen? |

Regel:

```text
Benchmark-Mechanik
-> Beobachtung
-> Prinzip
-> Talvori-Anwendung
-> Anti-Druck/Safety/Privacy
-> M16-T-ID-Abgleich
-> Folge-Gate
-> erst spaeter Implementierungsfreigabe
```

## 10. Social/Competition Vorpruefung

M16-AG bereitet Social/Competition fachlich vor, gibt aber nichts frei.

Pflichtregeln:

- Social/Competition bleibt nach MVP.
- Kein Leaderboard ohne Fairness-/Safety-Gate.
- Kein PvP ohne Alters-, Privacy-, Anti-Druck- und Moderationsregeln.
- Clan-/Team-/Freunde-Ideen bleiben Research-Thema.
- Freunde und Showcase koennen spaeter motivieren, duerfen Lernen aber nicht
  verzerren.
- Competition darf keine Schwaecheren blossstellen.
- Kein War-/Raid-/Pressure-System fuer den MVP.
- Keine Social-Metrik darf private Wort-, Fehler- oder Pausendaten oeffentlich
  machen.
- Kein Social-System darf Tali/Vori Companion oder menschliche Freunde
  vermischen.

Vor spaeterer Social-Freigabe braucht Talvori mindestens:

| Gate | Klaerung |
| --- | --- |
| Fairness | Wie bleiben Level, Zeit, Alter, Lernstand und Sprache vergleichbar? |
| Safety | Wie werden Druck, Blossstellung, Belaestigung und toxische Muster verhindert? |
| Privacy | Welche Lern-, Wort-, Fehler- und Kontextdaten bleiben privat? |
| Moderation | Welche Interaktionen brauchen Schutz, Meldung oder Begrenzung? |
| Motivation | Welche Social-Signale helfen, ohne Lernen zu verzerren? |
| MVP-Grenze | Warum bleibt Social fuer die erste spielbare Version blockiert? |

## 11. Metrics Vorpruefung

M16-AG bereitet Metrics vor, implementiert aber keine Analytics.

Pflichtregeln:

- Lernerfolg messen, nicht nur Nutzungszeit.
- Motivation beobachten, nicht manipulieren.
- Retention-Metriken duerfen keinen Druck erzeugen.
- Keine Analytics ohne Privacy-Gate.
- Keine privaten Wort-, Satz-, Kontext-, Fehler- oder Pausendaten ohne klares
  Datenkonzept.
- Keine Metrik darf SRS-/`word_progress` aus UI-Ereignissen veraendern.
- Keine Metrik darf Review-Zwang, FOMO, Leaderboard-Druck oder sensitive
  Retention ausloesen.

Moegliche spaetere Messrichtungen als Planung:

| Bereich | Sicherer Fokus | Blockiert |
| --- | --- | --- |
| Lernerfolg | Verstehen, Recall-Qualitaet, Kontextnutzung, freiwillige Wiederkehr zum Wort. | reine Nutzungszeit als Erfolg. |
| Motivation | freiwillige Rueckkehr, Later-Nutzung, Druckfreiheit, ruhiger Wiedereinstieg. | Manipulation, Schuld, Push-Druck. |
| Review Queue | wenige hilfreiche Entscheidungen, viele Safe Defaults, kein Massenreview. | Optimierung auf maximale Entscheidungen. |
| World Feedback | Versteht Nutzer Candidate/Fallback und Stop-Regeln? | BuildState- oder Asset-Metrik im MVP. |
| Privacy | Datenminimierung, lokale Defaults, Opt-in spaeter. | Analytics ohne Datenkonzept. |

## 12. Deep-Research-Priorisierung

M16-AG empfiehlt, spaetere Deep-Research-Gates nicht nach Bekanntheit der App,
sondern nach Talvori-Risiko und MVP-Nutzen zu priorisieren.

| Prioritaet | Research-Feld | Warum |
| --- | --- | --- |
| 1 | Habit ohne Druck | Talvori braucht Rueckkehr, darf aber keine Schuld erzeugen. |
| 2 | Recall/SRS ohne Datenmutation | Lernqualitaet ist Kern, bestehende SRS-/`word_progress`-Logik bleibt geschuetzt. |
| 3 | Interactive Learning / Challenge | MVP-Spielgefuehl braucht kleine freiwillige Lernmomente. |
| 4 | Metrics/Privacy | Messen darf Lernen schuetzen, nicht Nutzer manipulieren. |
| 5 | Worldbuilding/Progression | Weltfortschritt ist zentral, aber Build/Persistenz bleiben blockiert. |
| 6 | Social/Competition | Wertvoll, aber nach MVP und sicherheitskritisch. |

## 13. Beispiele fuer Talvori-Ableitungsfragen

| Beobachtungsfeld | Talvori-Frage | Safe Default |
| --- | --- | --- |
| Eine App nutzt Tagesziele. | Wie kann Talvori einen ruhigen Einstieg anbieten, ohne Pflicht? | Later, Pause-neutral, kein Streak-Verlust. |
| Eine App nutzt XP. | Welche Lernqualitaet wird wirklich sichtbar, statt nur Aktivitaet? | Lernsignal ohne BuildState. |
| Eine App nutzt Ranglisten. | Wer wird dadurch motiviert, wer beschaemt oder ausgeschlossen? | Social bleibt nach MVP blockiert. |
| Ein Spiel nutzt Timer. | Entsteht Vorfreude oder FOMO? | Keine Timer im MVP. |
| Ein Spiel nutzt Aufbauressourcen. | Staerkt das Entscheidungen oder erzeugt Grind? | BuildChoice bleibt Candidate. |
| Eine Tutor-App erklaert mit AI. | Welche Daten werden verarbeitet und wie wird Fehlerberatung begrenzt? | Kein Provider-Call ohne Gate. |
| Eine App nutzt Micro Sessions. | Wie klein kann ein Talvori-Lernmoment sein, ohne oberflaechlich zu werden? | kleine Review-Queue, ContextCard, Codex. |

## 14. Gate-Entscheidung

M16-AG entscheidet:

- Die Research-Landkarte wird breiter als Duolingo und Supercell/Clash.
- Duolingo und Supercell/Clash bleiben wichtige eigene Detail-Gates.
- Weitere Benchmarks werden als Kandidaten und Kategorien aufgenommen.
- Social/Competition ist als spaeteres Gate und Research-Feld verankert.
- Metrics/Analytics sind als Privacy- und Learning-Success-Vorpruefung
  vorbereitet.
- Research-to-Talvori-Prinzipien sind als verbindliches Template
  operationalisiert.

Nicht freigegeben:

- keine produktive Quest-/Level-/Progression-Mechanik,
- keine Social-/Competition-Mechanik,
- keine Analytics,
- keine AI-/Tutor-Provider-Integration,
- keine App-Integration,
- keine Route,
- keine Persistenz,
- keine automatische Wortplatzierung,
- kein BuildState,
- kein `frame_started`.

## 15. Dokumentationsvisualisierungen

Dokumentationsvisualisierungen liegen unter:

`docs/world_design/previews/m16_ag_broad_benchmark_research/`

Erwartete PNGs und SVGs:

- `00_contact_sheet.png`
- `00_contact_sheet.svg`
- `benchmark_category_map.png`
- `benchmark_category_map.svg`
- `benchmark_candidate_matrix.png`
- `benchmark_candidate_matrix.svg`
- `research_to_talvori_principles_flow.png`
- `research_to_talvori_principles_flow.svg`
- `social_competition_gate_map.png`
- `social_competition_gate_map.svg`
- `metrics_privacy_gate_map.png`
- `metrics_privacy_gate_map.svg`

Diese Visuals sind Dokumentationsmaterial, keine App-Screens, keine
Screenshots, keine Spielassets und keine Dateien unter `assets/`.

Visual-QA-Regel:

- PNG und SVG bevorzugt erzeugen.
- Text bleibt vollstaendig in Karten/Rahmen/Panels.
- Keine Woerter laufen aus Rahmen.
- Ausreichender Innenabstand.
- Kartenabstaende.
- Keine Ueberlappung von Karten, Labels, Pfeilen, Titeln, Footern oder
  Legenden.
- Contact Sheet vollstaendig lesbar.
- Keine abgeschnittenen Inhalte.
- SVG-Dateien muessen XML-parsebar sein.

## 16. Update fuer M16-T

M16-AG setzt passend auf erledigt:

- `M16T-SOCIAL-001`

M16-AG setzt passend auf teilweise vorbereitet:

- `M16T-SOCIAL-002`
- `M16T-SOCIAL-003`
- `M16T-METRICS-001`
- `M16T-METRICS-002`
- `M16T-METRICS-003`

M16-AG vertieft, aber laesst unveraendert teilweise vorbereitet:

- `M16T-RESEARCH-004`

Bewusst weiter ausgelagert:

- `M16T-RESEARCH-002`
- `M16T-RESEARCH-003`

## 17. Checks

Nach Erstellung auszufuehren:

- `git diff --check`
- `git status --short`
- Scope-Check gegen `lib/`, `assets/`, `test/`, `integration_test/`

Erwarteter Scope:

- `docs/world_design/341-broad-learning-game-benchmark-research-gate.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/previews/m16_ag_broad_benchmark_research/`

Nicht erwartet:

- Aenderungen unter `lib/`,
- Aenderungen unter `assets/`,
- Tests,
- Routen,
- App-Integration,
- Persistenz.
