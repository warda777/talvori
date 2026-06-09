# M16-AK: Play-First Learning Experience Doctrine

Stand: 2026-06-08

Status: `Research-Prep-/Dokumentations-Slice / keine Implementierung`

## 1. Zweck

M16-AK dokumentiert den wichtigsten Produktgrundsatz fuer Talvori:

```text
Talvori muss sich zuerst wie ein spannendes Spiel anfuehlen.
Lernen ist der Hauptnutzen, soll aber als Wirkung von Spiel, Neugier,
Herausforderung, Entdeckung, Entscheidung und Weltfortschritt erlebt werden.
```

Diese Doctrine ist ab sofort Pflichtfilter fuer MVP-, Gameplay-, Quest-,
Challenge-, World-, Companion-, UI- und Implementierungs-Slices.

M16-AK ist Research Prep und Produktdoktrin. Es ist keine Mechanikfreigabe,
keine Implementierung, kein Playtest-Ergebnis und keine App-Integration.

## 2. Non-Goals und harte Stop-Regeln

M16-AK erzeugt nicht:

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
- keine Social-/Competition-/Economy-/Timer-Freigabe.

Alle Game-Benchmarks in diesem Dokument sind Pattern-Kandidaten. Sie sind
keine Kopiervorlage und keine Aussage, dass eine konkrete Mechanik fuer
Talvori geeignet ist.

## 3. Gelesene Grundlagen

| Dokument | Relevanz fuer M16-AK |
| --- | --- |
| `328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrende M16-T-Liste, Dashboard und neue `M16T-PLAY`-Gruppe. |
| `336-documentation-map-and-slice-reading-rules.md` | Pflichtlektuere-, Prompt-, Output- und Scope-Regeln. |
| `340-gameplay-pillars-and-mvp-quest-loop-research-prep.md` | Gameplay Pillars und Quest-/Challenge-Grenzen. |
| `341-broad-learning-game-benchmark-research-gate.md` | Breite Benchmark-Landkarte und Research-to-Talvori-Template. |
| `343-habit-motivation-pressure-free-retention-research.md` | Habit, Motivation, Micro Sessions und Anti-Druck-Prinzipien. |
| `344-supercell-clash-progression-social-pressure-research.md` | Aufbaufortschritt, Trade-offs, Social Pressure und MVP-Verbote. |
| `330-minimal-playable-learning-loop-contract.md` | Minimaler Lernloop: Lernen erzeugt Moeglichkeit, keine Platzierung. |
| `331-minimal-word-outcome-detail-gate.md` | Outcomes, Queue-Ausgaenge und Reward/Placement/BuildState-Grenzen. |
| `332-reward-budget-and-review-queue-control-gate.md` | Reward- und Queue-Budgets, Safe Defaults und Anti-Druck-Regeln. |
| `333-minimal-semantic-profile-and-routing-priority-gate.md` | Safety, Sense, Word Type, Clutter und Confidence vor Reward/Weltfeedback. |
| `334-companion-and-sensitive-return-safety-gate.md` | Companion, Pause, Fehler und sensitive Inhalte bleiben ruhig und optional. |
| `337-mobile-density-accessibility-and-depth-planning-gate.md` | Mobile-Dichte, Overlays, Micro Sessions und Accessibility. |
| `338-world-loop-plot-family-and-buildchoice-gate.md` | WorldCandidate, Plot Family und BuildChoice bleiben Candidates, kein Build. |
| `339-theme-island-resizing-and-remaining-world-rules-gate.md` | Capability, Resizing, TinyObject, Container und Asset-Gates. |

## 4. Betroffene und neue M16-T-IDs

| ID | M16-AK / M16-AS Entscheidung |
| --- | --- |
| `M16T-PLAY-001` | `[x]` Play-First Learning Doctrine ist als verbindlicher Produktgrundsatz dokumentiert. |
| `M16T-PLAY-002` | `[x]` Lernen als Nebenprodukt des Spielens ist definiert. |
| `M16T-PLAY-003` | `[x]` Spielmechanik-zu-Lernnutzen-Matrix ist dokumentiert. |
| `M16T-PLAY-004` | `[x]` Neugier-/Challenge-/Flow-Regeln sind festgelegt. |
| `M16T-PLAY-005` | `[x]` Verbotene Uebungsgefuehle und "Uebung darf sich nicht wie Uebung anfuehlen" sind dokumentiert. |
| `M16T-PLAY-006` | `[x]` Games ohne Lernfokus sind mit M16-AL tief researched und in Talvori-Regeln uebersetzt. |
| `M16T-PLAY-007` | `[x]` MVP-Playtest-Kriterien fuer Spielgefuehl sind definiert. |
| `M16T-PLAY-008` | `[x]` Play-First-Check ist als Pflichtregel definiert und in M16-AO/M16-AP praktisch angewendet. |
| `M16T-PLAY-009` | `[x]` Island-First Play Rule ist mit M16-AS als harte Ergaenzung dokumentiert und in der Bank Preview angewendet. |

Referenzierte bestehende IDs:

`M16T-GAME-001..004`, `M16T-RESEARCH-004`, `M16T-MVP-004`,
`M16T-REWARD-001`, `M16T-QUEUE-002`, `M16T-COMP-001`,
`M16T-MOBILE-001`.

## 5. Executive Doctrine

Verbindliche Formulierung:

```text
Talvori ist kein Vokabeltrainer mit Spieldeko.
Talvori ist ein Spiel, dessen Spielhandlungen Lernnutzen erzeugen.
```

Konsequenzen:

- Nutzer sollen zuerst Spiel, Neugier, Herausforderung, Entdeckung,
  Entscheidung und Weltfortschritt spuern.
- Lernen darf sichtbar und ehrlich erkennbar sein, aber es darf sich nicht wie
  Pflichtlernen anfuehlen.
- Jede Uebung braucht einen Spielmoment.
- Jede Lernhandlung braucht einen Bedeutungsanker.
- Jeder Reward braucht Spielnutzen, nicht nur Punkte.
- Jede Review-Frage braucht Kontext, Wahl oder Neugier, nicht nur Abarbeitung.
- Weltfeedback darf Lernen staerken, aber nie BuildState, Persistenz oder
  automatische Platzierung erzeugen.

Produktlesart:

```text
Spielhandlung
-> Bedeutung entdecken
-> freiwillige Entscheidung
-> kleines sicheres Feedback
-> Lernen passiert dabei
```

## 6. Play-First Rule

Jede spaetere Mechanik muss vor Implementierung diese Fragen beantworten:

| Frage | Muss sichtbar beantwortet werden |
| --- | --- |
| Was ist der Spielmoment? | Welche Handlung fuehlt sich wie Spiel an, nicht wie Formular oder Arbeitsliste? |
| Was macht neugierig? | Warum will der Nutzer freiwillig wissen, was als Naechstes passiert? |
| Was ist die kleine Herausforderung? | Welcher Denk-, Such-, Wahl-, Timing- oder Bedeutungsimpuls ist enthalten? |
| Was fuehlt sich belohnend an? | Welches Feedback macht Fortschritt spuerbar, ohne Druck zu erzeugen? |
| Was lernt der Nutzer dabei? | Welcher Sense, Kontext, Recall, Outcome oder Worttyp wird besser verstanden? |
| Warum fuehlt es sich nicht wie klassische Uebung an? | Welche Spielsituation ersetzt Fragebogen-, Karteikarten- oder Schultest-Gefuehl? |
| Welche Druckmechaniken sind blockiert? | Streak-Schuld, Timer, Pflichtreview, XP-Grind, FOMO, Ranking, Social Pressure. |
| Wo sind sichere Ausgaenge? | `Later`, `Codex`, `Backlog`, `ContextCard`, `Hide`, `SensitiveGated`. |

Stop-Regel:

Kein App-Code fuer Lernuebungen ohne Spielmoment-Beschreibung.

## 7. Island-First Play Rule

M16-AS ergaenzt die Play-First Doctrine um eine harte Island-First-Regel:

```text
Talvori-Spielaufgaben passieren primaer in der Welt.
UI-Karten erklaeren nur, sie sind nicht der Hauptspielraum.
```

Verbindliche Regeln:

- Jede Talvori-Spielaufgabe findet primaer in der Welt statt: Insel, Plot,
  Weg, Tuer, Objekt, Figur, Szene, Container oder Codex-Ort.
- UI-Karten sind nur unterstuetzend: Sprechblase, HUD, Schild, Codex-Overlay
  oder Safe-Exit-Leiste.
- Keine Lernaufgabe darf primaer wie ein separates Lernfenster wirken.
- Karten/Fenster duerfen nicht das Hauptgefuehl der Uebung sein.
- Die Spielwelt oder Szene traegt die Aufgabe; UI erklaert nur.

Jede kuenftige MVP-/Gameplay-/Quest-/Challenge-/World-/UI-/
Implementierungsarbeit muss beantworten:

| Frage | Pflichtantwort |
| --- | --- |
| Wo auf der Insel oder auf dem Plot passiert der Spielmoment? | Konkreter Weltort, z. B. Flussufer, Weg, Container, Haus, Schild, Figur oder Codex-Ort. |
| Welche Figur, welches Objekt, welcher Weg oder welche Tuer traegt die Aufgabe? | Das interaktive Element muss in der Szene verankert sein. |
| Welche UI-Elemente sind nur HUD/Sprechblase/Schild? | Karten duerfen nur erklaeren, nicht den Spielraum ersetzen. |
| Warum fuehlt sich das nicht wie ein Lernfenster an? | Die Handlung muss als Weltmoment lesbar sein, nicht als Formular oder Quizkarte. |

Stop-Regel:

Kein App-Code fuer Lernuebungen, wenn der Hauptspielraum ein separates
Lernfenster ist.

### 7.1 Interaction Pattern Rule

M16-AX ergaenzt Play-First und Island-First um eine UI-Muster-Regel:

- Das UI-Muster muss zum Spielmoment passen.
- Weltaktion, Kontextmenue, kompaktes In-place-Wheel, HUD, Bottom-Sheet,
  Showcase-Seite, Werkbank, Inventar/Codex oder Reward-Toast werden je nach
  Aktionstyp, Risiko, Informationsmenge und Spielkontext gewaehlt.
- Island-First bedeutet nicht, dass nie eine eigene Seite erlaubt ist; grosse
  visuelle Auswahl darf eine spielartige Showcase- oder Werkbank-Ansicht
  bekommen.
- Wheel ist nur fuer kurze In-place-Auswahl mit Icon + Kurzname geeignet.
- Drag/Drop ist nicht der Standard-Nutzerflow, sondern Dev-/Layout-Modus oder
  spaetere Editierfunktion, wenn ein eigenes Gate sie erlaubt.
- Jede kuenftige UI-/World-/Gameplay-/Implementierungsarbeit muss nennen,
  welche UI-Art gewaehlt wurde und welche Alternative bewusst nicht gewaehlt
  wurde.

## 8. Game Pattern Benchmarks

Diese Matrix ist Research Prep. Sie benennt Hypothesen und
Ableitungsfragen, aber keine finalen Research-Ergebnisse.

| Spiel / Benchmark | Kern-Spielgefuehl | Warum Nutzer weitermachen | Aufgabe / Challenge | Belohnungsschleife | Talvori-Idee | Talvori muss vermeiden | MVP | Nach MVP |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Minecraft | frei bauen, erkunden, entdecken | eigene Welt, Neugier, Kreativitaet | Ressourcen verstehen, Raum formen | sichtbare eigene Veraenderung | Welt als Ausdruck von Bedeutung | endlose Sandbox, 3D-Scope, Bauzwang | niedrig | hoch |
| Roblox | viele kurze Experiences, Social Play | Vielfalt, Freunde, schnelle Neues | Modus verstehen, Rolle ausprobieren | neue Orte, soziale Anerkennung | modulare Mini-Momente | ungepruefter UGC, Social Pressure | niedrig | mittel |
| Block Blast! | klares Puzzle, kurze Runde | schnelle Wiederholung, Pattern-Fluss | Formen passend setzen | geloeste Flaeche, neue Runde | Meaning Puzzle mit wenig UI-Last | stumpfer Grind, kein Lernanker | mittel | mittel |
| Subway Surfers | sofortige Aktion und Flow | einfache Steuerung, kurze Spannung | Ausweichen, Rhythmus, Sammeln | Distanz, kleine Ziele | Action Moment fuer Verben | Timer-/Endlosdruck, Reflex statt Bedeutung | niedrig | mittel |
| Candy Crush Saga | Level-Puzzle und Zielkombination | klare Level, kleine Siege | Muster erkennen, Zuege planen | Levelabschluss, neue Schwierigkeit | Sense/Context Puzzle als Levelziel | Pay/FOMO/Frust durch Knappheit | mittel | mittel |
| Clash of Clans | Aufbau, Planung, Zugehoerigkeit | langfristige Basis, Trade-offs, Clans | Entscheidungen und Strategie | Basisfortschritt, Gruppenziele | Weltfortschritt als Moeglichkeit | Timer, War Pressure, Pay-to-Win | niedrig | hoch |
| Clash Royale | kurze Duelle und Deck-Entscheidungen | schnelle Matches, Skill, Wettbewerb | Echtzeitentscheidung | Rang, Karten, Sieg | kleine taktische Wahl | PvP-/Rangdruck, Balance-Stress | nein | spaeter Gate |
| Honor of Kings | Teamrollen, Skill, Wettbewerb | Mastery, Teamplay, Rang | Rolle ausfuehren, Teamfight | Sieg, Rang, Fortschritt | spaeter Social/Fairness-Fragen | Competition, Toxicity, Druck | nein | Research |
| Pokemon TCG Pocket | Sammeln, Deck, kurze Duelle | Sammlung, Entdeckung, kleine Matches | Karte waehlen, Synergie verstehen | neue Karten, Deckverbesserung | Codex Discovery und Sammlung | Gacha/FOMO/Collection Pressure | niedrig | Research |
| Minecraft Education | Lernwelt und Aufgabe im Raum | Weltkontext, Kreativitaet, Unterrichtsziel | Aufgabe im Raum loesen | Verstehen durch Handlung | World-as-learning-space | Schule-Gefuehl, Lehrzwang | mittel | hoch |
| Habitica | Alltag als RPG | Avatar, Gruppe, Aufgabenfeedback | Habit erledigen | Fortschritt, Gruppe, Items | Motivation durch Rolle | Strafe, Schuld, Aufgabenliste | niedrig | Research |
| Brilliant | interaktives Verstehen | Aha-Momente, direkte Rueckmeldung | Problem loesen | Konzept klarer verstehen | ContextCard / Meaning Puzzle | reine Problem-UI statt Welt | hoch | mittel |
| Duolingo | kurze Lektionen und Habit | kleine Einheiten, Feedback | Sprache ueben | XP, Streak, Path | Micro Session und klare Rueckmeldung | Streak-Schuld, League-Druck | hoch als Warnung | mittel |

## 9. Spielmechanik-zu-Lernnutzen-Matrix

| Spielmechanik | Lernnutzen | Talvori-Form | Blockiert |
| --- | --- | --- | --- |
| Puzzle loesen | Bedeutung/Sense verstehen | Meaning Puzzle fuer `Bank`, `Haus`, `Freiheit` | Multiple Choice als Hauptgefuehl |
| Weg finden | Kontext anwenden | Context Door: welcher Satz oeffnet welche Bedeutung? | Route/App-Navigation ohne Gate |
| Gegenstand waehlen | Word Outcome verstehen | ContainerItem vs WorldCandidate vs CodexOnly | automatische Wortplatzierung |
| Container finden | Objektkontext lernen | Container Hunt fuer `Schluessel`, `Loeffel`, `Messer` | TinyObject in IslandView |
| Aktion ausfuehren | Verb/ActionChallenge lernen | Action Moment fuer `schwimmen`, `kochen`, `lernen` | Verb als Gebaeude |
| Weltbereich entdecken | Kategorie/Theme verstehen | World Hint fuer Garten, Hafen, Zuhause, Schule | ThemeIsland-Placement |
| Sammlung erweitern | Codex/Recall staerken | Codex Discovery mit kleiner Erklaerung | 20.000 Karten |
| Kleine Runde meistern | Micro Session | 1 kurzer Spielmoment, 0-2 Vorschlaege | Pflichtliste |
| Fehler korrigieren | Feedback ohne Strafe | ruhiger Retry, ContextCard, Tali/Vori optional | Beschaemung, Weltverlust |
| Challenge waehlen | freiwillige Review | Choice Fork mit Later/Codex/Backlog | Review-Zwang |

## 10. Uebung darf sich nicht wie Uebung anfuehlen

Verbotene Hauptgefuehle:

- blosse Multiple-Choice-Vokabelabfrage als Kernmoment,
- Fragebogen-Feeling,
- Lernpflicht nach jeder Runde,
- Textwand,
- stumpfe Wiederholung,
- "richtig/falsch" ohne Spielsituation,
- XP-Grind,
- Streak-Schuld,
- Pflichtreview,
- Timerdruck,
- kuenstliche Ressourcenknappheit,
- rote Fehlerdramaturgie,
- Review-Stapel statt Spielziel.

Erlaubte Alternative:

```text
klassische Uebung
-> in eine kleine Spielsituation uebersetzen
-> Bedeutung/Context/Choice einbauen
-> sichere Ausgaenge sichtbar halten
-> ruhiges Feedback geben
```

Beispiel:

Nicht: "Waehle die richtige Uebersetzung."

Stattdessen: "Welche Tuer passt zu diesem Satz? Eine fuehrt in die Kueche,
eine in den Hafen, eine bleibt im Codex."

## 11. Talvori-Spielmoment-Typen

| Typ | Spielgefuehl | Lernnutzen | Beispiel | Erlaubtes Feedback | Blockiert |
| --- | --- | --- | --- | --- | --- |
| Meaning Puzzle | kleine Bedeutungsraetsel loesen | Sense und Multi-Home verstehen | `Bank`: Sitz, Geld, Flussufer | ContextCard, Codex, Later | Default-Gebaeude |
| Context Door | Kontext oeffnet passende Richtung | Satzkontext anwenden | `Haus` in Stadt vs Strand | kurze Auswahl, Safe Default | finale Platzierung |
| Tali/Vori Micro Quest | Companion stellt optionale Mini-Frage | Unsicherheit klaeren | "Willst du das spaeter im Codex parken?" | ruhig, optional | Druck/Autocoach |
| Container Hunt | kleines Ding im richtigen Kontext finden | TinyObject/Depth verstehen | `Schluessel` gehoert in Container | Container-Hinweis, Codex | Minipixel-Insel |
| Action Moment | Handlung statt Objekt denken | Verb/Prozess verstehen | `schwimmen` als Aktion | ActionChallenge-Idee | Wasserlogik/Questpflicht |
| World Hint | Welt reagiert klein und sicher | Thema/Plot-Familie erkennen | Baum als Natur-Hinweis | Preview Only | BuildState |
| Codex Discovery | Sammlung macht Wissen sichtbar | Recall und Erklaerung | abstraktes Wort im Codex | ruhiger Fund | Weltzwang |
| Calm Comeback | Rueckkehr ohne Schuld | Wiederaufnahme und Sicherheit | nach Pause weitermachen | "ruhig weiter" | Streak-Schuld |
| Choice Fork | kleine freiwillige Entscheidung | Outcome/Fallback verstehen | Confirm/Change/Later | sichere Optionen | Pflichtreview |
| Tiny Mystery | kleine Neugier ohne Druck | Kontext suchen | "Wo wuerde dieses Ding spaeter liegen?" | Later/Backlog | Hidden Pflichtobjekt |

## 12. Curiosity / Challenge / Flow Regeln

Pflichtregeln:

- kurze klare Ziele,
- sofort verstehbare Aufgabe,
- kleine Ueberraschung,
- sichtbares Ergebnis,
- freiwilliger naechster Schritt,
- keine Sackgassen,
- keine Pflicht,
- keine Ueberladung,
- `Later` bleibt erlaubt,
- Welt reagiert klein und sicher,
- Fehler bleiben spielerische Information, keine Strafe,
- Tali/Vori darf erklaeren, aber nicht entscheiden,
- Safety/Sensitive gewinnt gegen Neugier und Reward.

Flow entsteht, wenn der Nutzer eine kleine Handlung versteht, sie ausfuehrt,
eine Bedeutung klarer sieht und freiwillig weitergehen moechte.

Flow bricht, wenn der Nutzer Formulare, Pflichtlisten, Verlustdrohung,
Review-Schulden, Rangdruck oder Textwuesen erlebt.

## 13. Playtest-Kriterien

Spaetere MVP-/Gameplay-/UI-Tests muessen mindestens diese Fragen enthalten:

| Frage | Warum wichtig |
| --- | --- |
| Hat sich das wie Spielen angefuehlt? | Play-First-Hauptsignal. |
| Wann hast du gemerkt, dass du gelernt hast? | Lernen soll wirken, aber nicht als Pflicht dominieren. |
| Warst du neugierig auf die naechste Aufgabe? | Curiosity statt Abarbeitung. |
| Haettest du freiwillig weitergemacht? | Motivation ohne Druck. |
| War etwas langweilig oder wie Schule? | Uebungsgefuehl erkennen. |
| War etwas stressig? | Druck, Timer, Pflicht und FOMO erkennen. |
| Wurde dir etwas aufgezwungen? | User Choice und Later pruefen. |
| Hast du verstanden, warum die Welt reagiert hat? | Learning-to-World Contract pruefen. |
| Hast du dich bei Fehlern sicher gefuehlt? | Fehlerkommunikation und Companion-Safety pruefen. |
| Waren Exit, Later, Codex oder Backlog auffindbar? | Safe Defaults muessen sichtbar bleiben. |

MVP-Playtest darf keine Analytics-Implementierung, keine produktive Metrik und
keine Persistenz ableiten. Es ist eine spaetere Research-/QA-Aktivitaet.

## 14. Dauerhafte Pflichtregel

Ab M16-AK gilt:

- Jeder kuenftige MVP-/Gameplay-/Quest-/Challenge-/World-/UI-/
  Implementierungs-Slice muss die Play-First Rule und Island-First Play Rule
  nennen.
- Kein App-Code fuer Lernuebungen ohne Spielmoment-Beschreibung.
- Kein App-Code fuer Lernuebungen ohne Antwort, wo auf Insel, Plot oder
  Welt-Szene der Spielmoment passiert.
- Kein MVP-Screen ohne Playtest-Fragen.
- Kein Reward ohne Spielnutzen.
- Kein Review ohne Spielkontext.
- Kein Lernen ohne Neugier- oder Bedeutungsanker.
- Kein World-Slice ohne Antwort, warum die Weltreaktion Spielgefuehl erzeugt
  und trotzdem keine automatische Platzierung ist.
- Kein Companion-Slice ohne Antwort, wie Tali/Vori Neugier foerdert, ohne
  Pflicht, Schuld oder Beratung zu erzeugen.
- Kein UI-Slice ohne Mobile-Dichte- und Safe-Exit-Pruefung.
- Kein UI-/World-/Gameplay-/Implementierungs-Slice ohne begruendete
  Interaction-Pattern-Entscheidung aus `350`.
- Kein Implementierungs-Prompt darf diese Doctrine als Codefreigabe lesen.

Kurzform fuer kuenftige Prompts:

```text
Play-First Check:
Spielmoment? Neugier? Challenge? Belohnendes Feedback?
Lernnutzen? Kein Uebungsgefuehl? Kein Druck? Safe Defaults sichtbar?
Island-First Check:
Welcher Insel-/Plot-Ort? Welche Figur, welches Objekt, welcher Weg?
Welche UI ist nur HUD/Sprechblase/Schild? Warum kein Lernfenster?
```

## 15. Visualisierungen

M16-AK erzeugt Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_ak_play_first_learning/`

Geplante Visuals:

- `play_first_doctrine.png` + `.svg`
- `game_pattern_to_learning_bridge.png` + `.svg`
- `game_benchmark_pattern_matrix.png` + `.svg`
- `talvori_play_moment_types.png` + `.svg`
- `playtest_questions.png` + `.svg`
- optional `00_contact_sheet.png` + `.svg`

Visual-QA:

- PNG und SVG werden erzeugt.
- Text bleibt vollstaendig in Karten/Rahmen/Panels.
- Keine Woerter laufen aus Rahmen.
- Ausreichender Innenabstand.
- Kartenabstaende.
- Keine Ueberlappung von Karten, Labels, Pfeilen, Titeln, Footern oder
  Legenden.
- Contact Sheet vollstaendig lesbar.
- Keine abgeschnittenen Inhalte.
- SVG-Dateien muessen XML-parsebar sein.

## 16. Stop-Regeln

M16-AK gibt nicht frei:

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
- Tests oder Widget-Tests,
- Social-/Competition-/Economy-/Timer-Implementierung,
- Commit ohne separate Freigabe.
