# M16-AL: Non-Learning Game Patterns For Play-First Talvori

Stand: 2026-06-08

Status: `Deep-Research-/Dokumentations-/Visual-Slice / keine Implementierung`

## 1. Zweck

M16-AL untersucht erfolgreiche Non-Learning Games darauf, warum sie spannend,
neugierig machend, flow-stark und "ich will weitermachen"-artig wirken. Ziel
ist nicht, Mechaniken zu kopieren, sondern Muster fuer Talvoris
Play-First-Learning abzuleiten.

Fuehrender Filter:

```text
Talvori darf sich nicht wie Lernen mit Spieldeko anfuehlen.
Talvori muss sich wie ein Spiel anfuehlen, dessen Spielhandlungen Lernnutzen
erzeugen.
```

M16-AL schliesst `M16T-PLAY-006` fachlich und vertieft `M16T-PLAY-008`, ohne
Implementierung, App-Integration oder produktive Mechanik freizugeben.

## 2. Non-Goals und Stop-Regeln

M16-AL erzeugt nicht:

- keine Implementierung,
- keine Flutter-/Dart-Codeaenderung,
- keine App-Integration,
- keine Route,
- keine Tests oder Widget-Tests,
- keine Screenshots,
- keine Persistenz,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine Reward Bridge,
- keine automatische Wortplatzierung,
- kein Build-Wheel-Code,
- keine Assets oder Asset-Dateien unter `assets/`,
- kein Build-State,
- kein `frame_started`,
- keine Bauzustaende,
- keine Social-/Competition-/Economy-/Timer-Implementierung,
- keine Produktivmechanik-Freigabe.

Alle Benchmarks sind Research-Material. Nichts in M16-AL darf als Freigabe fuer
Gacha, FOMO, Pay-to-Win, Clans, PvP, Leaderboards, Timers, Economy oder
Social-Pressure gelesen werden.

## 3. Gelesene interne Grundlagen

| Dokument | Rolle fuer M16-AL |
| --- | --- |
| `328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrende M16-T-Liste, Dashboard und Fokus-IDs. |
| `336-documentation-map-and-slice-reading-rules.md` | Pflichtlektuere, Output, Scope und Visual-QA. |
| `340-gameplay-pillars-and-mvp-quest-loop-research-prep.md` | Gameplay Pillars, Quest-/Challenge-Grenzen und Spass ohne Lernschaden. |
| `341-broad-learning-game-benchmark-research-gate.md` | Benchmark-Landkarte und Research-to-Talvori-Template. |
| `343-habit-motivation-pressure-free-retention-research.md` | Micro Sessions, Recall, Habit und Druckfreiheit. |
| `344-supercell-clash-progression-social-pressure-research.md` | Aufbau-, Social- und Competition-Risiken. |
| `345-play-first-learning-experience-doctrine.md` | Fuehrende Play-First-Doktrin. |

## 4. Source Register

Quellen wurden am 2026-06-08 geprueft. Konkrete Benchmark-Aussagen beziehen
sich auf diese Quellen. Talvori-Ableitungen sind Inferenz aus Quellen und
internen Gates.

| Benchmark | Quelle | Art | Relevanz |
| --- | --- | --- | --- |
| Minecraft | [Minecraft: What is Minecraft?](https://www.minecraft.net/en-us/about-minecraft) | Offizielle Produktseite | Sandbox, Bauen, Ueberleben, Creative/Survival, Multiplayer und Updates. |
| Roblox | [Roblox: What is Roblox?](https://about.roblox.com/vi/what-is-roblox) | Offizielle Plattformseite | User-created Experiences, Play/Create/Connect, Avatar, Social, Free-to-play/Robux. |
| Block Blast! | [Block Blast: About Us](https://www.blockblast.com/about-us) | Offizielle Studio-/Produktseite | Drag-match-clear Puzzle, einfache Mechanik, Relaxed Play, Accessibility und strategische Tiefe. |
| Subway Surfers | [Subway Surfers Help: What is Subway Surfers?](https://sybo.helpshift.com/hc/en/5-subway-surfers/faq/202-what-is-subway-surfers/?p=android) | Offizielles Help Center | Free-to-play mobile runner, Coins, Keys, Event Coins und optionale Kaeufe. |
| Candy Crush Saga | [Candy Crush Help: Controls](https://candycrush.zendesk.com/hc/en-us/articles/360000750278-Controls-how-to-switch-and-match-candies) | Offizielles Help Center | Switch/match candies, Ziele, Moves, Boosters und Board-Feedback. |
| Candy Crush Saga | [Candy Crush Help: Game modes](https://candycrush.zendesk.com/hc/en-us/articles/360000754897-Which-game-modes-will-I-find) | Offizielles Help Center | Level-Typen, Zielarten und Schwierigkeitshinweise. |
| Clash Royale | [Supercell: Clash Royale](https://supercell.com/en/games/clashroyale/) | Offizielle Produktseite | Real-time multiplayer card battles, cards, upgrades, trophies, crowns and arena. |
| Honor of Kings | [Honor of Kings official site](https://www.honorofkings.com/) | Offizielle Produktseite | 5v5 mobile MOBA, roles, lanes, team play, battlefield goals and esports. |
| Pokemon TCG Pocket | [Pokemon TCG Pocket official site](https://tcgpocket.pokemon.com/en-us/) | Offizielle Produktseite | Collecting, daily booster packs, deck building, battling and community. |
| Pokemon TCG Pocket | [Pokemon Support: Gameplay FAQ](https://support.pokemon.com/hc/en-us/articles/30330309361172-Pok%C3%A9mon-TCG-Pocket-Gameplay-FAQ) | Offizielles Help Center | Pack stamina, pack points, Pokegold, rank, win streak points, trading/sharing and rewards. |

## 5. Benchmark-Auswertung pro Spiel

| Spiel | Warum spannend? | Neugier / Flow / Noch-eine-Runde | Challenge und Ziele | Feedback / Progression | Talvori-geeignet | Talvori-gefaehrlich |
| --- | --- | --- | --- | --- | --- | --- |
| Minecraft | Offene Welt, Bauen, Ueberleben, Ressourcen und eigene Ziele. | "Was finde oder baue ich als Naechstes?", jede Idee fuehrt zur naechsten kleinen Aufgabe. | Kurz: Schutz, Material, Weg. Lang: eigene Welt, seltene Dinge, grosse Builds. | Block gesetzt, Werkzeug gebaut, Ort entdeckt, Welt sichtbar veraendert. | Welt als Ausdruck von Bedeutung; selbst gesetzte kleine Ziele. | Endlose Sandbox, Bauzwang, 3D-Scope, Assetflut, Welt ersetzt Lernloop. |
| Roblox | Vielfalt, Social Presence und schnelle Experience-Wechsel. | "Was gibt es noch?", Freunde, Avatar, neue Modi. | Je Experience: Obstacle, Roleplay, Racing, Tycoon, Simulation. | Avatar, soziale Reaktion, Fortschritt im Modus. | Modulare Mini-Spielmomente und Auswahl zwischen ruhigen Experiences. | UGC-Scope, Moderation, Robux, Social Pressure, Ablenkung vom Lernen. |
| Block Blast! | Einfache Drag-match-clear-Regel mit wachsender Board-Spannung. | Welche Form passt noch? Niedrige Einstiegskosten, sofortiger Retry. | Raumplanung, Vorausdenken, Mustererkennung. | Linie verschwindet, Board wird frei, Score steigt. | Meaning Puzzle mit wenig UI-Last und sofort lesbarem Feedback. | Stumpfe Wiederholung ohne Lernanker; Puzzle als Selbstzweck. |
| Subway Surfers | Permanente Vorwaertsbewegung, klare Reaktion, knappe Hindernisse. | Naechster Abschnitt, Sammelobjekte, Figuren, schnelle Fehlerkorrektur. | Timing, Ausweichen, Sammeln, Risiko/Belohnung auf dem Weg. | Bewegung, Pickups, Score, Crash/Retry. | Action Moment fuer Verben: kurze Handlung mit Bedeutung. | Endlosdruck, Reflex statt Bedeutung, Store-/Currency-/Event-Druck. |
| Candy Crush Saga | Einfache Match-Regel, Levelziele, begrenzte Moves und Spezialeffekte. | Neues Board, neue Zielart, Kettenreaktion, "ein Zug noch". | Muster erkennen, Zuege planen, Levelziel erfuellen. | Candies verschwinden, neue fallen nach, Spezialeffekte loesen aus. | Sense-/Context-Puzzle mit klarer Zielbedingung. | Moves-Druck, Booster-FOMO, Frust-Design, Pay-to-progress. |
| Clash Royale | Kurze Echtzeitduelle, Kartenwahl, Timing und direkte Gegnerreaktion. | Neue Karten, Deck-Ideen, Arena-Fortschritt, "haette ich anders gespielt?" | Taktik, Elixir-/Timing-Entscheidung, Gegner lesen. | Treffer, Turmverlust, Kartenzyklus, Trophies/Crowns. | Kleine taktische Wahl: welcher Outcome/Fallback passt jetzt? | PvP, Ranking, Upgrade-Grind, Card-Power, Pay-to-win-Wahrnehmung. |
| Honor of Kings | 5v5-Teamziel, Rollen, Lanes, Map-Control und Skill-Decke. | Helden, Rollen, Teamkombinationen, Mastery. | Teamkoordination, Rollenverstaendnis, Strategie, Reaktion. | Kampf, Objectives, Teamfight, Sieg/Niederlage, Rank. | Rollenprinzip: welche Wortrolle ist heute relevant? | PvP, Rangdruck, Team-Schuld, Toxicity, eSports-/Competition-Scope. |
| Pokemon TCG Pocket | Sammeln, Booster-Oeffnen, Kartenkunst, Deck-Ideen und kurze Battles. | Welche Karte kommt? Welche Sammlung oder Deckidee entsteht? | Sammlung verstehen, Deck bauen, Battle-Regeln nutzen. | Neue Karte, Pack Points, Flair, Deck, Battle-Ergebnis. | Codex Discovery: Bedeutung gefunden, sicher abgelegt, auffindbar. | Gacha, Pack-Stamina, Pokegold, Rank/FOMO, Collection Pressure. |

## 6. Gemeinsame Muster ueber alle Spiele hinweg

| Muster | Warum es wirkt | Talvori-Uebersetzung | Gate |
| --- | --- | --- | --- |
| Sofort verstaendliche Handlung | Nutzer muss nicht lange lesen, bevor Spiel beginnt. | Eine kleine Meaning-/Context-/Action-Handlung pro Moment. | Mobile/Accessibility. |
| Sichtbares Ergebnis | Der Zustand veraendert sich sofort sichtbar. | Kleine Preview, ContextCard, Codex Discovery, Highlight. | Kein BuildState/Persistenz. |
| Korrigierbare Fehler | Fehler fuehlen sich wie naechster Versuch an. | Retry, Change, Later, Tali/Vori optional. | Kein SRS-/`word_progress`-Write. |
| Kurzfristiges Ziel | Eine Runde oder ein Level hat klares Ziel. | Ein Wort-Sense, ein Container, eine Context Door. | Kein Pflichtreview. |
| Langfristige Bedeutung | Fortschritt baut Identitaet oder Sammlung. | Eigene Welt/Codex wird reicher. | Kein Auto-Placement. |
| Neugier auf Naechstes | Naechster Ort, Pack, Level, Match oder Muster lockt. | "Was bedeutet das hier?" statt "lerne noch eins". | Kein FOMO. |
| Wahl und Ownership | Spieler entscheidet Weg, Build, Deck, Rolle oder Zug. | Outcome/Fallback/Context-Wahl. | Reversibility. |
| Rhythmus und Flow | Wiederholbare klare Aktion mit steigender Kompetenz. | Micro Session mit einem Spielmoment. | Kein Grind. |

## 7. Talvori-geeignete Muster

| Muster | Talvori-Regel | Beispiel |
| --- | --- | --- |
| Sandbox-Ownership | Welt reagiert als Moeglichkeit, nicht als Pflichtbau. | Ein Baum-Wort macht Naturbereich als Candidate verstaendlicher. |
| Mini-Puzzle | Bedeutung wird durch Spielentscheidung klar. | `Bank` als Sitz, Geldinstitut oder Flussufer. |
| Context Door | Satzkontext oeffnet eine passende Richtung. | `Haus` im Urlaubssatz fuehrt nicht automatisch Zuhause. |
| Container Hunt | Kleine Objekte bekommen Such-/Depth-Kontext. | `Schluessel` wird ContainerItem, nicht Inselobjekt. |
| Action Moment | Verben werden kurze Handlungsideen. | `schwimmen` als Water/Safety-gated ActionChallenge. |
| Codex Discovery | Sammeln macht Bedeutung sichtbar und auffindbar. | `Freiheit` wird ContextCard/Codex, kein Symbolzwang. |
| Choice Fork | Nutzer darf bestaetigen, aendern oder spaeter entscheiden. | Confirm/Change/Later/Backlog/Codex. |
| Calm Retry | Fehler fuehlen sich wie Spielinformation an. | Falscher Sense wird ruhig erklaert. |

## 8. Talvori-gefaehrliche Muster

| Muster | Gefahr fuer Talvori | Blockierte Lesart |
| --- | --- | --- |
| FOMO | Nutzer kehrt aus Verlustangst zurueck. | Tagespflicht, Event-Verfall, "du verlierst Fortschritt". |
| Gacha | Zufall/Sammlung uebernimmt Lernmotivation. | Booster, Pack-Stamina, Pulls, Rarity-Hype. |
| Pay-to-Win / Pay-to-progress | Geld ersetzt Lernen oder beschleunigt Weltstatus. | Wort-/Weltfortschritt kaufen. |
| PvP / Leaderboard | Lernen wird Vergleich, Rang oder Blossstellung. | Liga, Trophy, Klassenranking, Freunde beschamen. |
| Clan-/Teamdruck | Fehler oder Pause schadet Gruppe. | War, Raid, Pflichtbeitrag, Team-Schuld. |
| Timer / Upgradezeit | Warten wird Retention-Mechanik. | Bauzeit, Weltverfall, Countdown. |
| Booster-Frust | Schwierigkeit erzeugt Kaufdruck. | "Nur mit Hilfe schaffbar" als Lernmoment. |
| Mechanik ohne Lernnutzen | Spiel laeuft, aber Bedeutung wird nicht klarer. | Reflex/Puzzle als reiner Skin ueber Vokabeln. |

## 9. Verbindliche Talvori Play-First-Prinzipien

1. Jede Lernhandlung braucht zuerst einen Spielmoment.
2. Jeder Spielmoment braucht einen Lernanker: Sense, Context, Outcome,
   Recall, Action, Container oder Codex.
3. Feedback muss sofort lesbar sein, aber nicht bauen.
4. Neugier darf einladen, aber nie als FOMO, Timer oder Verlustdrohung wirken.
5. Fehler sind Spielinformation, keine Strafe.
6. Sammlung ist Codex Discovery, kein Gacha.
7. Wettbewerb bleibt nach MVP und braucht Fairness-/Privacy-/Safety-Gates.
8. Weltfortschritt ist Moeglichkeit und Bedeutung, nicht Auto-Placement.
9. Jede Wahl muss `Later`, `Codex`, `Backlog`, `ContextCard` oder `Change`
   als sicheren Ausgang behalten.
10. Wenn eine Mechanik keinen Lernnutzen benennen kann, gehoert sie nicht in
    den MVP.

## 10. MVP-Regeln

MVP-erlaubt als Planung:

- Meaning Puzzle,
- Context Door,
- Container Hunt,
- Action Moment,
- Codex Discovery,
- Calm Comeback,
- Choice Fork,
- World Hint als Preview/Fallback.

MVP-blockiert:

- Gacha,
- Pack-Stamina,
- FOMO-Events,
- Timers,
- Upgradezeiten,
- Economy,
- PvP,
- Clans,
- Leaderboards,
- Rank,
- Pay-to-Win,
- Social Pressure,
- sensitive Retention,
- automatische Wortplatzierung,
- BuildState,
- `frame_started`.

## 11. Konsequenzen fuer kuenftige Slices

Jeder kuenftige MVP-/Gameplay-/Quest-/Challenge-/UI-/World-/
Implementierungs-Slice muss ab M16-AL beantworten:

| Pflichtfrage | Konsequenz |
| --- | --- |
| Welches Non-Learning-Game-Muster wird genutzt? | Pattern nennen: Puzzle, Discovery, Action, Choice, Collection. |
| Was ist der Talvori-Spielmoment? | Konkrete Spielhandlung beschreiben, nicht nur Lernaufgabe. |
| Was lernt der Nutzer nebenbei? | Sense, Context, Outcome, Recall, Action oder Container benennen. |
| Was verhindert Uebungsgefuehl? | Keine Textwand, kein Fragebogen, kein Pflichtreview. |
| Welche Druckmuster sind ausgeschlossen? | FOMO, Gacha, Pay-to-Win, Timer, Rank, Clan, PvP, sensitive Retention. |
| Wo sind sichere Ausgaenge? | Later, Codex, Backlog, ContextCard, Change, Hide. |
| Was bleibt blockiert? | BuildState, Persistenz, App-Integration, Route, Assets, Tests, Auto-Placement. |

## 12. M16-T-ID-Entscheidung

| ID | Status nach M16-AL | Begruendung |
| --- | --- | --- |
| `M16T-PLAY-006` | `[x]` | Non-Learning Games wurden als Pattern-Quellen tief ausgewertet und in Talvori-Regeln uebersetzt. |
| `M16T-PLAY-008` | `[~]` | Play-First-Check ist vertieft und operationalisiert, aber echte Anwendung steht erst in spaeteren Implementierungs-Slices aus. |

Unveraendert bleiben:

- `M16T-GAME-001..004`,
- `M16T-RESEARCH-004`,
- `M16T-MVP-004`,
- `M16T-REWARD-001`,
- `M16T-QUEUE-002`,
- `M16T-COMP-001`,
- `M16T-MOBILE-001`.

## 13. Visualisierungen

M16-AL erzeugt Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_al_non_learning_game_patterns/`

Visuals:

- `non_learning_game_pattern_matrix.png` + `.svg`
- `curiosity_challenge_flow_map.png` + `.svg`
- `session_hook_pattern_map.png` + `.svg`
- `safe_vs_dangerous_game_patterns_for_talvori.png` + `.svg`
- `talvori_play_first_translation_matrix.png` + `.svg`
- `00_contact_sheet.png` + `.svg`

Visual-QA:

- Text bleibt vollstaendig in Karten/Rahmen/Panels.
- Keine Woerter laufen aus Rahmen.
- Keine abgeschnittenen Inhalte.
- Keine unerwuenschten Ueberlappungen.
- Contact Sheet ist vollstaendig lesbar.
- PNG und SVG werden erzeugt.
- SVGs muessen XML-parsebar sein.

## 14. Stop-Regeln

M16-AL gibt nicht frei:

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
- Produktivmechanik,
- Commit ohne separate Freigabe.
