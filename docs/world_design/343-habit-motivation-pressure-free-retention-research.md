# M16-AI: Habit, Motivation and Pressure-Free Retention Deep Research

Stand: 2026-06-08

Status: `Deep-Research-/Dokumentations-Slice / keine Implementierung`

## 1. Zweck

M16-AI fuehrt die erste echte Research-Auswertung fuer Habit, Motivation,
freiwillige Rueckkehr, Micro Sessions, Recall, interaktives Lernen und
Retention ohne Druck durch. Der Slice sucht Prinzipien, die Talvori spaeter
nutzen kann, ohne einzelne Mechaniken blind zu kopieren.

Fokus:

```text
Benchmark beobachten
-> Wirkprinzip verstehen
-> Lernnutzen und Motivationsnutzen trennen
-> Druck-/FOMO-/Privacy-Risiko bewerten
-> Talvori-Prinzip ableiten
-> Implementierung weiter blockiert halten
```

## 2. Non-Goals und harte Stop-Regeln

M16-AI erzeugt nicht:

- keine Implementierung,
- keine Flutter-/Dart-Codeaenderung,
- keine App-Integration,
- keine Route,
- keine neue Seite,
- keine Tests,
- keine Widget-Tests,
- keine Screenshots,
- keine Persistenz,
- keine Supabase Writes,
- keine lokalen DB-Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine Push-Retention,
- keine Analytics-/Metrics-Implementierung,
- keine Reward Bridge,
- keine automatische Wortplatzierung,
- kein Build-Wheel-Code,
- keine Assets,
- keine Asset-Dateien unter `assets/`,
- kein Build-State,
- kein `frame_started`,
- keine Bauzustaende,
- keine Social-/Competition-Freigabe,
- keine produktive Spielmechanik-Freigabe.

Alle Benchmark-Beobachtungen sind Research-Material. Sie sind keine
Kopiervorlage, keine Produktentscheidung und keine Runtime-Freigabe.

## 3. Gelesene interne Grundlagen

| Dokument | Rolle fuer M16-AI |
| --- | --- |
| `328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrende M16-T-Liste, Dashboard und betroffene IDs. |
| `336-documentation-map-and-slice-reading-rules.md` | Pflichtlektuereregeln, Output-Regeln, Visual-QA und Stop-Regeln. |
| `341-broad-learning-game-benchmark-research-gate.md` | Benchmark-Landkarte und Research-to-Talvori-Template. |
| `340-gameplay-pillars-and-mvp-quest-loop-research-prep.md` | Gameplay Pillars und Research Prep fuer Lern-/Quest-Mechaniken. |
| `330-minimal-playable-learning-loop-contract.md` | Lernfortschritt erzeugt Moeglichkeit, keine automatische Platzierung. |
| `332-reward-budget-and-review-queue-control-gate.md` | Reward-/Queue-Budgets, Safe Defaults und Anti-Druck-Regeln. |
| `334-companion-and-sensitive-return-safety-gate.md` | Rueckkehr, Fehler, Tali/Vori und sensitive Kommunikation bleiben druckfrei. |
| `335-learning-states-and-srs-boundary-gate.md` | Lernzustaende bleiben von SRS, `word_progress`, Reward und Weltfeedback getrennt. |
| `337-mobile-density-accessibility-and-depth-planning-gate.md` | Micro Sessions, mobile Dichte, Overlays und Accessibility. |
| `342-asset-naming-licensing-and-offline-sync-planning-gate.md` | Asset-/Sync-Gates bleiben fuer diese Research-Auswertung blockiert. |

## 4. Research Source Register

Alle externen Quellen wurden am 2026-06-08 geprueft. Konkrete
Benchmark-Aussagen in diesem Dokument beziehen sich auf diese Quellen.

| Quelle | Art | Relevanz |
| --- | --- | --- |
| [Duolingo: How Streaks keep learners committed](https://blog.duolingo.com/how-streaks-keep-duolingo-learners-committed-to-their-language-goals/) | Offizieller Produkt-/Research-Blog | Streaks, Daily Goal, Erinnerungen, Weekend Amulet als Pausenschutz, Retention-Effekte und Streak-Risiko. |
| [Duolingo: How Leaderboards work](https://blog.duolingo.com/duolingo-leagues-leaderboards/) | Offizieller Produkt-Blog | Leaderboards, Leagues, XP-Wettbewerb, Matching, Opt-out und Competition-Risiko. |
| [Duolingo: Time Spent Learning Well](https://blog.duolingo.com/time-spent-learning-well/) | Offizieller Produkt-/Metrics-Blog | Lernzentrierte Proxy-Metrik, XP-Gaming-Risiko, Daily Quests, Leaderboard-Rebalancing, Burnout-Grenze. |
| [Duolingo: How to use Duolingo](https://blog.duolingo.com/duolingo-101-how-to-learn-a-language-on-duolingo/) | Offizieller Produkt-Blog | Lesson Flow, XP, Streak, Streak Freeze, Score, Friends Quest, Hearts und Practice Hub. |
| [Duolingo: How we learn how you learn](https://blog.duolingo.com/how-we-learn-how-you-learn/) | Offizieller Research-Blog | Student model, strength meters, forgetting curves, spacing, practice timing. |
| [Brilliant homepage](https://brilliant.org/) | Offizielle Produktseite | Visual/interaktive Sessions, Schritt-fuer-Schritt-Probleme, Tutor/Feedback, Motivation. |
| [Brilliant Learn by doing landing](https://brilliant.org/landing/learn-computer-science-basics/) | Offizielle Produktseite | 15-Minuten-Sessions, interaktive Problemloesung, Custom Feedback, bite-sized lessons. |
| [Brilliant FAQ](https://brilliant.org/faq/) | Offizielle Produkt-FAQ | Interaktive Kurse, hands-on problem solving, Verstehen statt Memorieren. |
| [Brilliant math by doing](https://brilliant.org/math/doing) | Offizielle Produktseite | Step-by-step interactive lessons, custom feedback, concept mastery, practice by progress. |
| [Quizlet: Studying with Learn](https://help.quizlet.com/hc/en-us/articles/360030986971-Studying-with-Learn) | Offizielles Help Center | Learn Mode, Ziele, personalisierte Study Path, Fragearten, Optionen. |
| [Quizlet: Studying with Flashcards](https://help.quizlet.com/hc/en-ca/articles/360030988091-Studying-with-Flashcards) | Offizielles Help Center | Flashcards, Flip, Shuffle, Know/Still learning, Audio, Nutzerkontrolle. |
| [Quizlet: Studying with Test](https://help.quizlet.com/hc/en-us/articles/360030642972-Studying-with-Test-mode) | Offizielles Help Center | Test Mode, Frageauswahl, Score/Review, keine automatische Persistenz in Test-Progress. |
| [Quizlet: Progress for targeted studying](https://help.quizlet.com/hc/en-au/articles/360048803491-Using-Progress-for-targeted-studying) | Offizielles Help Center | Progress-Gruppen, targeted study, sync, Lernstandssicht. |
| [Anki Manual: deck options and FSRS](https://docs.ankiweb.net/deck-options.html) | Offizielle Dokumentation | Spaced Repetition, FSRS, Review-Last, Easy Days als Workload-Entlastung. |
| [Carnegie Mellon: Retrieval Practice](https://www.cmu.edu/teaching/resources/instructionalstrategies/activelearningstrategies/retrievalpractice/index.html) | Universitaere Teaching-Ressource | Retrieval Practice als aktives Abrufen, Feedback und langfristiges Lernen. |
| [RetrievalPractice.org](https://www.retrievalpractice.org/retrievalpractice) | Learning-Science-Ressource | Retrieval Practice als no-stakes, flexible, schnelle Lernstrategie. |
| [The Learning Scientists FAQ](https://www.learningscientists.org/faq) | Learning-Science-Ressource | Retrieval und spaced practice als stark gestuetzte Lernstrategien, Transfer- und Anwendungseffekte. |

## 5. Research-Framing fuer Talvori

Talvori sucht keine Kopien von Streaks, Leagues, XP-Systemen, Flashcard-Modi
oder Tutor-Interfaces. Talvori sucht Prinzipien:

- Was hilft Nutzerinnen und Nutzern freiwillig zurueckzukehren?
- Was hilft wirklich beim Lernen, nicht nur bei Nutzungszeit?
- Welche sichtbaren Signale motivieren, ohne Schuld oder Verlustangst?
- Wo kippt Engagement in Druck, FOMO oder oberflaechliches Sammeln?
- Welche Daten waeren spaeter fuer Lernqualitaet hilfreich, aber privat oder
  manipulationsgefaehrlich?

Arbeitsregel:

```text
Lernen bleibt wichtiger als Retention.
Habit darf Rueckkehr erleichtern, aber keine Schuld erzeugen.
Motivation darf sichtbar sein, aber keinen Verlustdruck erzeugen.
Sensitive Inhalte duerfen nie Retention-Trigger sein.
```

## 6. Benchmark-Auswertung

| Benchmark | Beobachtete Mechaniken | Warum sie funktionieren koennten | Nutzeremotion | Lernnutzen | Motivationsnutzen | Risiken | Talvori koennte ableiten | Talvori muss vermeiden | M16-T-IDs |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Duolingo | XP, Streaks, Daily Goals, Leagues, Leaderboards, Quests, Lesson Path, Practice Hub, Hearts, Streak Freeze. | Kleine Einheiten, sofortiges Feedback, klare Tageshandlung, sichtbarer Fortschritt und soziale Vergleichbarkeit. | Stolz, Drang weiterzumachen, Wettbewerb, gelegentlich Verlustangst. | Path Lessons und personalisierte Practice koennen Lernen strukturieren. | Habit-Schleife und sichtbare Ziele senken Einstiegshuerde. | Streak-Schuld, FOMO, XP-Jagd, League-Druck, Vergleich, Herzen als Fehlerdruck. | Ruhige Micro Sessions, freiwillige Review-Impulse, pausenfreundliche Rueckkehr, lernzentrierte Metrik statt reiner Aktivitaet. | Keine Streak-Verlustmechanik, keine League/Leaderboard im MVP, keine Push-Schuld, keine Pflichtserie. | `M16T-RESEARCH-002`, `M16T-RESEARCH-004`, `M16T-METRICS-001..003` |
| Brilliant | Learn by doing, interaktive Probleme, visuelle Erklaerungen, Schritt-fuer-Schritt-Feedback, kurze Sessions, progressbasierte Practice. | Aktives Problemlosen erzeugt Bedeutung, Feedback kommt direkt am Denkpunkt, Visuals reduzieren Abstraktion. | Neugier, Aha-Moment, Kompetenzgefuehl, Flow. | Kontextuelles Verstehen und Transfer statt nur Wiedererkennen. | Kleine Denkaufgaben koennen spannender sein als reine Wiederholung. | Zu viel Interaktion kann kognitive Last erhoehen; Competitive Features duerfen Druck erzeugen. | ContextCards, ActionChallenges, kleine Bedeutungskarten und optionale Companion-Erklaerung. | Keine lange Textwand, keine Pflicht-Challenge, keine Competition als Default. | `M16T-GAME-002`, `M16T-RESEARCH-004`, `M16T-METRICS-001` |
| Quizlet | Flashcards, Learn, Test, Spell, Progress, Study Modes, Ziele/Optionen, Know/Still learning. | Nutzer kontrolliert Format, Recall wird wiederholt, Sets koennen zielgerichtet geuebt werden. | Kontrolle, Pruefungsnaehe, Sicherheit, manchmal Review-Last. | Recall, Selbsttest und gezielte Wiederholung. | Kurze Review-Momente passen zu Micro Sessions. | Oberflaechliches Pauken, Massenreview, Fortschrittsdruck, Abarbeitungslisten. | Budgetierte Review Queue, Later, Codex, Backlog und kurze freiwillige Recall-Momente. | Keine 20.000-Wort-Inbox, kein automatischer SRS-Write, kein Review nach jedem Wort. | `M16T-QUEUE-002`, `M16T-LEARN-002`, `M16T-METRICS-001` |
| Anki / SRS | Spaced repetition, FSRS, Review-Intervalle, Easy Days, grosse Decks. | Timing kann Vergessen abfangen und Wiederholung effizienter machen. | Kontrolle, Pflichtgefuehl, bei grossen Decks auch Last. | Langfristiges Erinnern durch Wiederholung und Abruf. | Fortschritt entsteht aus sichtbarer Reduktion faelliger Karten. | Review-Schulden, Queue-Druck, algorithmische Mutation ohne Transparenz. | SRS bleibt separates Gate; Talvori kann Recall-Prinzip nutzen, ohne `word_progress` zu schreiben. | Keine SRS-/`word_progress`-Aenderung aus Research, UI oder Reward. | `M16T-LEARN-002`, `M16T-AI-002`, `M16T-AI-004` |
| Retrieval Practice / Learning Science | Aktives Abrufen, Feedback, no-stakes Uebung, Spacing, Transfer. | Abrufen staerkt Erinnerung und zeigt Luecken; Feedback korrigiert ohne Straflogik. | Konzentration, kleine Herausforderung, Klarheit ueber Wissen. | Starker Lernnutzen fuer Recall und Anwendung. | Kurze no-stakes Aufgaben koennen angenehm wiederholbar sein. | Zu schwerer Abruf kann frustrieren; ohne Feedback bleibt Unsicherheit. | Fehler als Lernsignal, kurze Recall-Momente, Feedback ohne Weltstrafe. | Keine Beschaemung, keine negative Weltreaktion, keine Pflicht-Tests. | `M16T-REWARD-004`, `M16T-METRICS-001`, `M16T-LEARN-002` |

## 7. Duolingo Deep Research

### 7.1 Beobachtete Mechaniken

Duolingo nutzt sichtbare Gamification, um Gewohnheiten zu formen:

- XP fuer abgeschlossene Lernaktivitaeten, Stories, Practice und Challenges,
- Streak als sichtbarer Tagesrhythmus,
- Daily Goals und Daily/Monthly Quests,
- Leagues und Leaderboards als woechentlicher Wettbewerb,
- Lesson Path mit persoenlicher Practice,
- Streak Freeze und verwandte Schutzmechaniken,
- Herzen und Practice Hub als Fehler-/Review-Schleife,
- Freunde, Friends Quests und Feed als soziale Motivation.

Die offiziellen Duolingo-Quellen zeigen zugleich, dass Duolingo selbst zwischen
reiner Aktivitaet und Lernqualitaet unterscheidet. Die Metrik
`Time Spent Learning Well` priorisiert lernwirksamere Aktivitaeten gegenueber
reinem Session- oder XP-Volumen. Duolingo beschreibt auch, dass XP-Gaming und
Leaderboard-Unfairness ein Designproblem sein koennen.

### 7.2 Warum sie funktionieren koennten

| Mechanik | Moegliches Wirkprinzip | Talvori-Lesart |
| --- | --- | --- |
| XP | Sofortige Rueckmeldung und sichtbarer Abschluss. | Nur als sanftes Feedback denkbar, nie als Lernersatz. |
| Streak | Einfache Erinnerung an Kontinuitaet. | Rueckkehr kann sichtbar werden, aber ohne Verlust. |
| Daily Goal | Niedrige Einstiegshuerde. | Micro Session ja, Tagespflicht nein. |
| Leagues | Vergleich und Zielspannung. | Nach MVP blockiert, weil Wettbewerb Druck erzeugt. |
| Streak Freeze | Pause wird teilweise reparierbar. | Talvori sollte Pause von Anfang an neutral behandeln, nicht als Rettung nach Verlust. |
| Lesson Path | Reduziert Entscheidungsaufwand. | Talvori braucht klare naechste Lernmoeglichkeit, aber ohne Zwang. |
| TSLW | Lernqualitaet statt Aktivitaetsvolumen. | Metriken muessen lernenzentriert und privacy-gated sein. |

### 7.3 Risiken

Duolingo ist fuer Talvori gerade deshalb wertvoll, weil es die
Motivationsstaerke und die Risiken sichtbar macht:

- Streaks koennen Stolz erzeugen, aber auch Verlustangst.
- Streak Freeze reduziert Bruch, kann aber den Streak als etwas
  Gefaehrdetes bestaetigen.
- XP kann Abschluss sichtbar machen, aber XP-Jagd belohnen.
- Leaderboards koennen motivieren, aber Lernende blossstellen oder
  oberflaechliches Grinding foerdern.
- Herzen koennen Fehler relevant machen, aber Fehlerdruck erzeugen.
- Daily Goals koennen Einstieg erleichtern, aber Pflichtgefuehl erzeugen.

### 7.4 Talvori-Ableitung

Talvori sollte Duolingo nicht kopieren. Talvori sollte die folgenden
Principles uebernehmen:

- Micro Sessions sind gut, wenn sie freiwillig und klein bleiben.
- Fortschrittssignale sollen sichtbar sein, aber nicht verfallen.
- Rueckkehr nach Pause ist neutral und freundlich.
- Review darf vorgeschlagen werden, aber Later bleibt immer sichtbar.
- Lernmetriken muessen Lernqualitaet, nicht nur Aktivitaet, beobachten.
- Competition, League, Rangliste und Streak-Verlust bleiben fuer MVP blockiert.

Konkrete MVP-Regel:

```text
Kein Streak-System im MVP.
Kein Leaderboard im MVP.
Kein Push-Druck.
Kein Verlust bei Pause.
Kein XP-Grinding als Ziel.
Kein SRS-/word_progress-Write aus Motivation.
```

## 8. Brilliant Deep Research

### 8.1 Beobachtete Mechaniken

Brilliant beschreibt seinen Ansatz als interaktives Lernen durch Tun:

- visuelle und interaktive Sessions,
- Schritt-fuer-Schritt-Probleme,
- direkte und teils personalisierte Rueckmeldung,
- kleine Konzepte statt langer Textbloecke,
- Practice, die sich an Fortschritt oder Luecken orientiert,
- taegliche Motivation und Level/Streak-Elemente.

### 8.2 Warum sie funktionieren koennten

Brilliant ist fuer Talvori interessant, weil Bedeutung nicht nur erklaert,
sondern handelnd erfahrbar wird. Das passt zu Talvori besser als reine
XP-Mechanik:

- Ein Begriff kann als kleine Denkaufgabe erscheinen.
- Ein Kontext kann durch eine ContextCard sichtbar werden.
- Ein Verb kann als ActionChallenge statt als Objekt erscheinen.
- Ein Fehler kann sofort erklaert werden, ohne Weltstrafe.
- Eine visuelle Erklaerung kann kognitive Last reduzieren, wenn sie kurz ist.

### 8.3 Risiken

- Zu viele interaktive Schritte koennen selbst zur Pflichtliste werden.
- Visualisierung kann falsche Sicherheit erzeugen, wenn der Kontext fehlt.
- Competitive Features und taegliche Ziele duerfen nicht in Druck kippen.
- Lange Erklaerungen duerfen mobile Screens nicht ueberladen.

### 8.4 Talvori-Ableitung

Talvori sollte Brilliant-Prinzipien in einer ruhigen, sprachsemantischen Form
nutzen:

- `ContextCard` fuer Bedeutung und Beispiel,
- `ActionChallenge` fuer Verben und Handlungen,
- kurze Denkimpulse statt Textwaende,
- direkte, freundliche Rueckmeldung,
- optionale Companion-Erklaerung,
- keine Pflicht-Challenge nach jedem Wort.

## 9. Quizlet / Recall Deep Research

### 9.1 Beobachtete Mechaniken

Quizlet dokumentiert mehrere Study Modes:

- Flashcards mit Flip, Navigation, Shuffle, Audio und optionaler Sortierung in
  `Know` / `Still learning`,
- Learn Mode mit Zielwahl, personalisiertem Study Path und Fragearten,
- Test Mode mit Frageanzahl, Fragetypen, Score und Review,
- Progress fuer gezieltes Ueben nach Lernstand.

### 9.2 Warum sie funktionieren koennten

Quizlet ist fuer Talvori wichtig, weil es Recall und Nutzerkontrolle zeigt:

- Lernende koennen Format und Ziel selbst waehlen.
- Flashcards erzeugen kurze Abrufmomente.
- Learn/Test machen Luecken sichtbar.
- Progress kann gezielt helfen, ohne alles gleichzeitig zu zeigen.

### 9.3 Risiken

- Flashcards koennen oberflaechliches Paarlernen foerdern.
- Grosse Sets koennen Review-Last erzeugen.
- Test Scores koennen Druck erzeugen, wenn sie als Urteil wirken.
- Progress-Sync und Lernstandsdaten sind spaeter privacy- und
  persistence-relevant.

### 9.4 Talvori-Ableitung

Talvori sollte Recall nutzen, aber nicht ungeplant SRS schreiben:

- kurze freiwillige Review-Momente,
- maximal wenige Review-Fragen pro Session,
- Later immer erlaubt,
- Codex/Backlog/ContextCard als sichere Ausgaenge,
- keine Massenentscheidung,
- kein SRS-/`word_progress`-Write aus Review UI,
- keine 20.000-Wort-Inbox.

## 10. Optionaler Recall- und Spacing-Unterbau

Anki und Learning-Science-Quellen zeigen, dass Spaced Practice und Retrieval
Practice fachlich stark sind. Fuer Talvori bedeutet das jedoch nicht, dass
M16-AI eine SRS-Implementierung freigibt.

Planungsregel:

- Retrieval darf als Lernprinzip genutzt werden.
- Spacing darf als spaeteres SRS-Gate untersucht werden.
- `word_progress` bleibt unangetastet.
- UI-Events, Rewards, Queue-Entscheidungen und Weltfeedback schreiben keine
  SRS-Werte.
- AI-/Provider-Klassifikation bleibt ohne eigenes Privacy-/Provider-Gate
  blockiert.

## 11. Talvori-Prinzipien aus Research

| Prinzip | Bedeutung fuer Talvori | MVP-Regel |
| --- | --- | --- |
| Rueckkehr ohne Schuld | Pause ist neutral, nicht reparaturbeduerftig. | Keine Verlustmeldung, kein Weltverfall, kein Streak-Verlust. |
| Micro Session statt Pflichtliste | Kleine freiwillige Lernmomente senken Einstiegshuerde. | Kurze Session anbieten, aber keine Daily-Pflicht. |
| Sichtbares Feedback ohne BuildState | Feedback darf motivieren, aber nichts bauen. | Kein Reward erzeugt Placement, Persistenz oder `frame_started`. |
| Recall ohne SRS-Mutation | Abruf kann helfen, aber bestehende Lernlogik bleibt geschuetzt. | Kein SRS-/`word_progress`-Write ohne eigenes Gate. |
| Bedeutung vor Bild | Interaktive Semantik ist wertvoller als sofortiges Symbol. | ContextCard/ActionChallenge vor Weltobjekt. |
| Companion erklaert optional | Tali/Vori kann Unsicherheit reduzieren. | Kein Companion-Druck, keine Beratung, keine Pflichtentscheidung. |
| Review bleibt budgetiert | Nur relevante, wenige Entscheidungen werden sichtbar. | Kein Review nach jedem Wort, Later immer sichtbar. |
| Keine sensitive Retention | Sensitive Woerter sind keine Motivationstrigger. | SensitiveGated, Hide, Later, CodexOnly oder ContextCard. |
| Keine League im MVP | Wettbewerb kann spaeter sinnvoll sein, aber nicht im ersten Loop. | Kein Leaderboard, keine Blossstellung, keine Social Pressure. |

## 12. Anti-Patterns fuer Talvori

Talvori muss vermeiden:

- Streak-Schuld,
- FOMO,
- Push-Druck,
- League-/Leaderboard-Druck,
- XP-Jagd ohne Lernen,
- Pflichtreview,
- oberflaechliche Wort-zu-Bild-Zuordnung,
- Timer als Druckmechanik,
- Verlustangst,
- negative Weltreaktion bei Fehlern,
- sensitive Trigger fuer Rueckkehr,
- Companion-Schuldformulierungen,
- Analytics ohne Privacy-Gate,
- SRS-/`word_progress`-Mutation aus UI-Events,
- Review-Schulden als Produktprinzip.

## 13. MVP-Implikationen

Fuer den ersten kleinen spielbaren Talvori-Lernloop ist sinnvoll:

- sehr kurze freiwillige Lernmomente,
- optionales sanftes Feedback nach Lernaktion,
- wenige Review-Fragen pro Session,
- Later immer sichtbar,
- keine Pflichtentscheidung nach Lernblock,
- kein Streak-System,
- kein Leaderboard,
- kein Push-Druck,
- keine Daily-Pflicht,
- keine sensitive Retention,
- kein SRS-/`word_progress`-Write,
- keine Analytics-Implementierung,
- keine Weltplatzierung ohne Gate.

MVP-Formel:

```text
Lernen
-> optionaler sanfter Impuls
-> semantisch sicherer Outcome oder Fallback
-> budgetierte freiwillige Review-Entscheidung
-> kleines reversibles Weltfeedback nur nach Gate
```

## 14. Metrics-Vorbereitung

M16-AI definiert keine Analytics und keine Datenerhebung. Es bereitet nur
Prinzipien fuer spaetere Metrics-Gates vor.

### 14.1 Lernzentrierte Metriken, die spaeter sinnvoll sein koennten

- freiwillig abgeschlossene Micro Sessions,
- Recall-Versuche mit Feedback, ohne SRS-Mutation,
- Kontextverstaendnis statt nur Wortpaar-Treffer,
- Anteil `Later` ohne negative Folge,
- erfolgreiche Rueckkehr nach Pause ohne Druck,
- freiwillig geoeffnete ContextCards,
- reduzierte Review-Ueberlastung,
- Lernzielnahe Aktivitaeten statt reiner Nutzungszeit,
- Nutzer kann schwierige Woerter spaeter wiederfinden.

### 14.2 Gefaehrliche Metriken

- reine Daily Active Users als Produktziel,
- Streak-Laenge als Werturteil,
- XP pro Minute,
- Leaderboard-Rang,
- Push-Clickrate,
- sensitive Topic Engagement,
- Anzahl erzwungener Reviews,
- Zeit in App ohne Lernqualitaet,
- Weltobjekt-Anzahl als Lernproxy,
- Conversion aus Verlustangst.

### 14.3 Daten, die nicht ohne Privacy-Gate erhoben werden duerfen

- private Woerter und Importquellen,
- Satz- und Kontext-Hints,
- sensitive Flags,
- Companion-Gespraeche,
- genaue Fehlerhistorie pro Wort,
- Rohdaten zu Lernzeiten und Rueckkehrmustern,
- Geraete-/Account-Identifikatoren fuer Analytics,
- soziale Vergleichsdaten,
- AI-/Provider-Klassifikationsergebnisse.

### 14.4 Motivation messen ohne Manipulation

Spaetere Metriken muessen zeigen, ob Talvori Lernen leichter macht, nicht ob
Talvori Druck maximiert:

- Nutzer kehrt freiwillig zurueck,
- Pausen fuehren nicht zu Verlust,
- Later wird genutzt und respektiert,
- Review-Budget bleibt klein,
- Lernende fuehlen sich nicht beschaemt,
- Fehler fuehren zu Erklaerung, nicht Strafe,
- sensible Inhalte erhoehen keine Retention-Ziele.

## 15. M16-T-ID-Entscheidung

| ID | Entscheidung in M16-AI | Begruendung |
| --- | --- | --- |
| `M16T-RESEARCH-002` | Wird `[x]` | Duolingo Deep Research fuer Habit, XP, Streaks, Leagues, Daily Goals, Lesson Flow und Risiken ist dokumentiert. |
| `M16T-RESEARCH-004` | Wird `[x]` | Research-Ergebnisse sind in konkrete Talvori-Prinzipien und Anti-Patterns uebersetzt. |
| `M16T-METRICS-001` | Wird `[x]` | Lernzentrierte Metriken ohne SRS-Mutation sind vorbereitet. |
| `M16T-METRICS-002` | Wird `[x]` | Motivation/Retention-Metriken mit Anti-Druck-Grenzen sind vorbereitet. |
| `M16T-METRICS-003` | Wird `[x]` | Analytics-Privacy-Grenzen und nicht zu erhebende Daten sind dokumentiert. |
| `M16T-LEARN-002` | Bleibt `[~]` | Es existiert weiter kein eigenes SRS-/`word_progress`-Migration-/Test-Gate. |
| `M16T-AI-002` | Bleibt `[~]` | Provider-Governance wird beruehrt, aber nicht vollstaendig geschlossen. |
| `M16T-AI-004` | Bleibt `[~]` | Privacy-Regeln werden fuer Metrics beruehrt, aber AI-Klassifikation braucht weiter eigenes Gate. |

## 16. Visualisierungen

Dokumentationsvisualisierungen:

`docs/world_design/previews/m16_ai_habit_motivation_research/`

Geplante und erzeugte Dateien:

- `habit_motivation_benchmark_matrix.png`
- `habit_motivation_benchmark_matrix.svg`
- `pressure_free_retention_principles.png`
- `pressure_free_retention_principles.svg`
- `duolingo_risk_translation.png`
- `duolingo_risk_translation.svg`
- `brilliant_quizlet_learning_patterns.png`
- `brilliant_quizlet_learning_patterns.svg`
- `talvori_mvp_motivation_rules.png`
- `talvori_mvp_motivation_rules.svg`
- `00_contact_sheet.png`
- `00_contact_sheet.svg`

Visual-QA-Regel:

- Text bleibt vollstaendig in Karten/Rahmen/Panels.
- Keine Woerter laufen aus Rahmen.
- Innenabstand und Kartenabstand sind ausreichend.
- Karten, Labels, Pfeile, Titel, Footer und Legenden ueberlappen nicht.
- Contact Sheet ist lesbar.
- SVG-Dateien sind XML-parsebar.
- Keine Inhalte sind abgeschnitten.

## 17. Weiter blockiert

Weiter blockiert bleiben:

- produktive Motivation-/Habit-/Quest-Mechanik,
- Push-Retention,
- Analytics-/Metrics-Implementierung,
- SRS-/`word_progress`-Aenderung,
- Provider-/AI-Klassifikation,
- App-Integration,
- Route,
- Persistenz,
- Supabase/local DB Writes,
- automatische Wortplatzierung,
- Build-State,
- Build-Wheel-Code,
- `frame_started`,
- Assets,
- Social/Competition.
