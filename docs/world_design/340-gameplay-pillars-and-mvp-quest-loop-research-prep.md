# M16-AF: Gameplay Pillars and MVP Quest Loop Research Prep

Stand: 2026-06-08

Status: `Planungs-/Research-Prep-Slice / keine Implementierung`

## 1. Zweck

M16-AF bereitet die spielerische Seite von Talvori fachlich vor. Der Slice
definiert Gameplay Pillars, einen MVP-nahen Quest-/Challenge-Loop,
Regeln fuer Spass und Spannung ohne Lernschaden sowie Research-Fragen fuer
erfolgreiche Lern- und Aufbauspiele.

M16-AF gibt keine Spielmechanik als Runtime frei. Quest, Challenge, Level,
Progression, Social und Competition bleiben Planungsbegriffe.

## 2. Non-Goals und harte Stop-Regeln

M16-AF erzeugt nicht:

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
- keine Social-/Competition-Freigabe.

Dieses Dokument ist keine Quest-Engine-Freigabe, keine Level-System-
Freigabe, keine Economy-Freigabe und keine produktive Research-Auswertung.

## 3. Gelesene Grundlagen

| Dokument | Relevanz fuer M16-AF |
| --- | --- |
| `328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrende M16-T-ID-Liste, Dashboard und Backlog. |
| `336-documentation-map-and-slice-reading-rules.md` | Pflichtlektuere-, Prompt-, Output- und Commit-Regeln. |
| `330-minimal-playable-learning-loop-contract.md` | Lernen erzeugt Moeglichkeit, keine Platzierung. |
| `331-minimal-word-outcome-detail-gate.md` | Outcomes und Queue-Ausgaenge begrenzen Quest-/Challenge-Ausloeser. |
| `332-reward-budget-and-review-queue-control-gate.md` | Reward- und Review-Budgets verhindern Druck und Massenentscheidungen. |
| `333-minimal-semantic-profile-and-routing-priority-gate.md` | Safety, Sense, Word Type, Clutter und Confidence stehen vor Reward/Weltfeedback. |
| `334-companion-and-sensitive-return-safety-gate.md` | Tali/Vori begleitet optional und ohne Druck, Beratung oder sensitive Trigger. |
| `335-learning-states-and-srs-boundary-gate.md` | Lernzustaende schreiben kein SRS/`word_progress` und erzeugen kein Placement. |
| `337-mobile-density-accessibility-and-depth-planning-gate.md` | Mobile-Dichte, Overlay- und Container-Grenzen fuer Challenges. |
| `338-world-loop-plot-family-and-buildchoice-gate.md` | WorldCandidate, PlotFamily und BuildChoice bleiben Kandidaten, kein BuildState. |
| `339-theme-island-resizing-and-remaining-world-rules-gate.md` | Capability, TinyObject, Resizing und sensitive-safe Asset-Regeln als Stop-Regeln. |
| `329-talvori-product-delivery-dashboard-and-scrum-lite.md` | MVP-Roadmap, Research-Gate und Scrum-lite-Arbeitsmodell. |

## 4. Betroffene M16-T-IDs

| ID | M16-AF-Entscheidung |
| --- | --- |
| `M16T-GAME-001` | Gameplay Pillars sind mit Lernbezug, erlaubten und blockierten Mechaniken dokumentiert. |
| `M16T-GAME-002` | MVP Quest-/Challenge-Loop ist fachlich geplant, ohne Quest-/Level-Code. |
| `M16T-GAME-003` | Lernlogik, Semantik, Reward, Challenge und Weltfeedback sind harmonisiert und getrennt. |
| `M16T-GAME-004` | Spass/Spannung ohne Lernschaden ist als Regelset dokumentiert. |
| `M16T-RESEARCH-002` | Bleibt ausgelagert: echte Duolingo-Recherche braucht eigenes Research-Gate. |
| `M16T-RESEARCH-003` | Bleibt ausgelagert: echte Clash-/Supercell-Recherche braucht eigenes Research-Gate. |
| `M16T-RESEARCH-004` | Teilweise vorbereitet: Research-zu-Talvori-Prinzipien-Template ist definiert, echte Ergebnisse fehlen. |

## 5. Gameplay Pillars

Die Pillars sind Produktregeln, keine Runtime-Mechaniken.

| Pillar | Zweck | Lernbezug | Erlaubte Mechaniken | Blockierte Mechaniken | Risiko | MVP-Relevanz |
| --- | --- | --- | --- | --- | --- | --- |
| Lernen oeffnet Moeglichkeiten | Lernen soll spuerbar etwas freischalten, aber nicht automatisch ausfuehren. | Lernereignis kann Semantikpruefung und Vorschlag vorbereiten. | sanftes Feedback, freiwilliger Vorschlag, Later, Codex, Backlog | Auto-Placement, BuildState, SRS-Mutation, Reward Bridge | Lernen wird nur Mittel zum Weltgrind | hoch |
| Bedeutung vor Weltreaktion | Sense, Word Type, Safety und Clutter entscheiden vor jeder sichtbaren Reaktion. | Nutzer lernt Kontext statt nur Objektzuordnung. | ContextCard, NeedsUserChoice, ActionChallenge, Safe Defaults | Default-Sense, falsche Kategorie, sichtbare Reaktion bei Low Confidence | falsche Semantik wirkt spielerisch "richtig" | hoch |
| Kleine Entscheidungen statt Pflichtlisten | Talvori soll fokussierte Wahlmomente bieten, keine Review-Arbeitsschlange. | Nur relevante, riskante oder mehrdeutige Woerter werden aktiv gefragt. | 0-3 Review-Fragen, Later immer erlaubt, Queue-Budget | Pflichtentscheidung, 20.000-Wort-Inbox, Entscheidung nach jedem Wort | Nutzer fuehlt Arbeit statt Spiel | hoch |
| Sichtbarer Fortschritt ohne Druck | Weltfeedback darf motivieren, aber nicht bestrafen. | Fortschritt bleibt sanft, reversibel und vom Lernloop getrennt. | Preview/Fallback, kleines Signal, ruhige Rueckkehr, kein Verfall | Streak-Schuld, FOMO, Timer, Weltverfall, sensitive Trigger | Retention frisst Lernen | hoch |
| Tali/Vori begleitet, entscheidet aber nicht | Companion macht Regeln verstaendlich, ohne Autoritaet oder Druck zu sein. | Tali/Vori erklaert Unsicherheit, CodexOnly, Later oder SensitiveGated. | kurze optionale Erklaerung, ruhige Pause-/Fehlercopy | Entscheidung erzwingen, Beratung, Reward/Placement ausloesen | Companion wird Drucksystem | mittel bis hoch |

Merksatz:

```text
Spielgefuehl entsteht aus klaren, freiwilligen Lernentscheidungen.
Nicht aus Zwang, Timer, Auto-Build oder Social-Druck.
```

## 6. MVP Quest-/Challenge-Loop

Der MVP-nahe Quest-/Challenge-Loop ist ein fachlicher Ablauf. Er ist keine
Quest Engine, kein Levelsystem und keine Runtime-Konfiguration.

```text
Lernblock
-> semantischer Impuls
-> optionaler Quest-/Challenge-Vorschlag
-> freiwillige Entscheidung
-> kleines Weltfeedback oder Safe Default
-> Later / Codex / Backlog jederzeit moeglich
```

### 6.1 Erlaubte Loop-Lesart

| Schritt | Bedeutung | Erlaubt | Blockiert |
| --- | --- | --- | --- |
| Lernblock | Nutzer uebt, wiederholt oder versteht ein Wort im Kontext. | Lernereignis als fachliches Signal. | SRS-/`word_progress`-Mutation ohne Gate. |
| Semantischer Impuls | Outcome, Sense, Safety und Word Type erzeugen eine moegliche Richtung. | CodexOnly, WorldCandidate, ContainerItem, ActionChallenge, ContextCard, SensitiveGated, NeedsUserChoice. | Auto-Routing in Weltobjekt. |
| Quest-/Challenge-Vorschlag | Optionaler, kleiner Vorschlag, wenn Budget und Safety passen. | freiwillig ansehen, Later, Codex, Backlog. | Pflichtquest, Timer, FOMO, sensitive Trigger. |
| Freiwillige Entscheidung | Nutzer entscheidet, verschiebt oder parkt. | Confirm als Preview-Idee, Change, Later, Hide. | Pflichtentscheidung, negative Wirkung bei Ignorieren. |
| Kleines Weltfeedback | Sichtbares Signal, dass Lernen etwas ermoeglicht. | Preview Only, ContextCard, Highlight, Erklaerung. | Placement, BuildState, Asset, Persistenz, `frame_started`. |

### 6.2 Verbindliche Quest-Grenzen

- Keine Questpflicht.
- Keine Streak-Schuld.
- Keine sensitive Trigger.
- Keine automatische Weltplatzierung.
- Keine SRS-/`word_progress`-Mutation.
- Keine BuildStates.
- Keine Timer-/FOMO-Mechanik.
- Keine Social- oder Competition-Freigabe.
- Keine Quest-Engine aus diesem Gate ableiten.

## 7. Quest-/Challenge-Arten

| Challenge-Art | Wann sinnvoll | Was sie lernen laesst | Was motiviert | Blockiert bleibt | Muss beachten |
| --- | --- | --- | --- | --- | --- |
| Word Sense Challenge | Multi-Home, mehrdeutige oder contextMissing Woerter. | Bedeutung im Kontext unterscheiden. | "Welche Bedeutung passt hier?" als kleine Wahl. | Default-Sense, finale Platzierung. | M16-Y, M16-W, M16-X |
| ContextCard Challenge | abstrakte, emotionale oder erklaerbeduerftige Woerter. | kurze Bedeutung, Beispiel, Satzkontext. | Klarheit statt Objektzwang. | Symbolpflicht, Textwueste, Beratung. | M16-W, M16-Z, M16-AC |
| ActionChallenge | Verben, Prozesse oder Bewegungen. | Aktion verstehen und anwenden, nicht als Objekt denken. | kleine freiwillige Aufgabe oder Beispiel. | automatische Quest, Gebaeude, Timer. | M16-W, M16-Y, M16-X |
| Container Findability Challenge | TinyObjects und verschachtelte Dinge. | Objekt im passenden Kontext finden/erklaeren. | "Wo wuerde das spaeter hingehören?" | IslandView-Objektwolke, Container-Dump. | M16-AC, M16-AE |
| Review Choice Challenge | wenige relevante NeedsUserChoice-Faelle. | Entscheidung, Fallback und Later verstehen. | kurze, reversible Wahl. | Pflichtreview, Massenliste. | M16-X, M16-W |
| WorldCandidate Explanation Challenge | groessere, sichere WorldCandidates. | Warum ein Wort nur Candidate ist. | sichtbarer Fortschritt als Moeglichkeit. | Placement, BuildChoice Confirm, BuildState. | M16-AD, M16-AE |
| Return After Pause Challenge | Rueckkehr ohne Druck. | ruhige Wiederaufnahme und naechster kleiner Schritt. | "Wir machen ruhig weiter." | Verlust, Streak-Schuld, Weltverfall. | M16-Z, M16-X |

## 8. Spass und Spannung ohne Lernschaden

Talvori darf neugierig, lebendig und spielerisch werden. Die Spannung darf
aber nie gegen Lernen, Safety oder Nutzerkontrolle arbeiten.

| Prinzip | Erlaubt | Blockiert |
| --- | --- | --- |
| Neugier | kleine offene Frage, "das koennte spaeter passen" | Mystery als Druck oder Pflicht |
| Kleine Ziele | ein Lernblock, ein Vorschlag, ein freiwilliger Review | endlose Tagesliste |
| Sichtbare Verbesserung | Preview/Fallback, sanftes Highlight, klares Feedback | Weltverfall, Ruinen, Verlust |
| Freiwillige Wahl | Later, Codex, Backlog, Change jederzeit | Sackgassen-UI |
| Ueberraschung ohne Druck | seltene positive Variation, keine Pflichtfolge | Lootbox, Pay-to-Win, FOMO |
| Langfristiger Fortschritt | Weltmoeglichkeiten wachsen durch Lernen und Gates | Timer, Verfall, Retention-Schuld |
| Pause bleibt neutral | ruhige Rueckkehr, keine Strafe | "du verlierst Fortschritt" |
| Sensitive Schutz | Codex, ContextCard, Hide, Later, SensitiveGated | sensitive Inhalte als Motivation |
| Keine Pay-to-Win-/FOMO-Logik | Lernen und Kontext bleiben Kern | Druck durch Ressourcen, Timer, Ranglisten |

Spannung darf aus Bedeutung, Wahl und sanftem Weltfeedback entstehen, nicht aus
Angst vor Verlust.

## 9. Research Prep: Duolingo

M16-AF fuehrt keine echte Duolingo-Recherche durch. Die folgenden Fragen
bereiten ein spaeteres Research-Gate vor.

### 9.1 Zu untersuchen

- Habit/Streaks.
- XP.
- Leagues.
- Daily Goals.
- Lessons/Skill Progression.
- Motivationssprache.
- Risiken: Schuld, Druck, FOMO, oberflaechliche XP-Jagd.

### 9.2 Ableitungsfragen

| Frage | Talvori-Relevanz |
| --- | --- |
| Was erzeugt regelmaessige Rueckkehr, ohne Schuld zu erzeugen? | Rueckkehr-nach-Pause-Regel und Reward-Budget. |
| Welche XP-/Punkteprinzipien staerken Lernen wirklich? | Reward darf kein BuildState und keine SRS-Mutation sein. |
| Welche Streak-/League-Mechaniken erzeugen Druck? | Talvori muss FOMO, Schuld und Competition-Druck vermeiden. |
| Wie kann eine Daily Goal-Idee freiwillig bleiben? | Later, Pause und Safe Defaults muessen immer moeglich sein. |
| Welche Motivationssprache ist ruhig, konkret und nicht beschamend? | Companion-Copy und Fehlerkommunikation. |
| Wie bleibt Lernen wichtiger als Streak/XP? | M16-V Contract und M16-X Reward-Budget. |

## 10. Research Prep: Clash of Clans / Supercell

M16-AF fuehrt keine echte Clash-/Supercell-Recherche durch. Die folgenden
Fragen bereiten ein spaeteres Research-Gate vor.

### 10.1 Zu untersuchen

- Aufbaufortschritt.
- Entscheidungen und Trade-offs.
- Base/World Progression.
- Ressourcen/Timers.
- Clans/Social.
- Competition.
- Balance.
- Risiken: Pay-to-Win, FOMO, War Pressure, Timer, Social Pressure.

### 10.2 Ableitungsfragen

| Frage | Talvori-Relevanz |
| --- | --- |
| Welche Aufbauentscheidungen fuehlen sich sinnvoll an, ohne zu ueberfordern? | BuildChoice bleibt spaeter freiwillig, reversibel und gated. |
| Welche Progression motiviert, ohne Timer-Druck zu erzeugen? | Keine Timer-/FOMO-Mechanik im MVP. |
| Wie funktionieren Trade-offs, ohne Lernen zu bestrafen? | Wahl darf keine Lernstrafe, SRS-Mutation oder Weltverlust erzeugen. |
| Welche Social-Mechaniken staerken Zugehoerigkeit, ohne Druck? | Social/Competition bleibt nach MVP und braucht Gate. |
| Welche Balance-Prinzipien verhindern Pay-to-Win? | Monetization darf den ersten Wow-Moment nicht blockieren. |
| Was ist fuer Talvori gefaehrlich? | Timers, War Pressure, Social Pressure, Ressourcen-Druck. |

## 11. Talvori-Prinzipien aus Research vorbereiten

Spaetere Research-Ergebnisse muessen in Talvori-Regeln uebersetzt werden,
bevor Mechaniken entstehen. Dieses Template bereitet `M16T-RESEARCH-004`
teilweise vor.

| Feld | Frage |
| --- | --- |
| Beobachtung | Was wurde in einer Lern-/Spiel-App beobachtet? |
| Prinzip | Welches allgemeine Produktprinzip steckt dahinter? |
| Talvori-Anwendung | Wie koennte es Talvori helfen, ohne Lernen zu schwaechen? |
| Risiko | Welche Druck-, Safety-, Privacy-, FOMO- oder Pay-to-Win-Gefahr entsteht? |
| Entscheidung | uebernehmen / anpassen / ablehnen / spaeter pruefen |
| Betroffene M16-T-IDs | Welche Checklist-IDs muessen geaendert oder bestaetigt werden? |
| Gate vor Umsetzung | Welches Detail-Gate waere noetig? |

Regel:

Research darf nur Prinzipien vorbereiten. Keine beobachtete Mechanik wird
direkt kopiert, implementiert oder als MVP-Mechanik freigegeben.

## 12. MVP-Grenzen

Nichtziele fuer den MVP aus M16-AF:

- keine echte Economy,
- keine Timer,
- keine Clans,
- keine Leaderboards,
- keine PvP-/Wettbewerbslogik,
- keine Push-Retention,
- keine produktive Quest Engine,
- keine App-Route,
- keine Persistenz,
- keine Assets,
- keine BuildStates,
- keine Social-/Competition-Implementierung,
- keine SRS-/`word_progress`-Mutation,
- keine automatische Wortplatzierung.

## 13. Beispiele

| Beispiel | Sicherer M16-AF-Ausgang | Blockiert |
| --- | --- | --- |
| 5 Woerter gelernt | sanftes Feedback, hoechstens ein freiwilliger Vorschlag oder Safe Default | 5 Quests, 5 Weltobjekte, XP-Druck |
| Falsch beantwortetes Wort | ContextCard, Codex, ruhige Wiederholung | Beschämung, Weltstrafe, SRS-Abwertung aus UI |
| Nutzer kehrt nach Pause zurueck | Return After Pause Challenge als optionaler Einstieg | Schuld, Verlust, Pflichtreview |
| NeedsUserChoice-Wort | kleine Word Sense Challenge, Later immer sichtbar | Default-Sense als finale Weltwirkung |
| ActionChallenge mit `schwimmen` | Aktion/ContextCard mit Water-/Safety-Gate | Gebaeude, Wasserlogik, Timerquest |
| ContainerItem mit `Schluessel` | Container Findability Challenge als Planung | eigener Plot, Minipixel, Asset |
| SensitiveGated mit `Angst` | Codex/ContextCard/Later/Hide, Tali/Vori neutral | Drama, Reward, Retention-Trigger |
| WorldCandidate mit `Baum` | Explanation Challenge: Candidate, kein Placement | Baumwolke, Auto-Asset, Deko-Spam |
| Spaeterer Level-Fortschritt | nur als Research-/Planungsfrage | Levelsystem, Timer, Economy |
| Vergleich mit Freunden | bleibt nach MVP und braucht Social-/Fairness-Gate | Leaderboard, PvP, Social Pressure |

## 14. Gate-Entscheidung

M16-AF schliesst die fachliche Vorbereitung fuer Gameplay Pillars und den
MVP-nahen Quest-/Challenge-Loop. Der naechste sichere Schritt ist nicht
sofortige Spielmechanik, sondern entweder:

- echte Research-Gates fuer Duolingo und Supercell/Clash,
- ein weiteres Detail-Gate fuer Social/Fairness, falls Social frueher
  diskutiert wird,
- ein spaeterer eng freigegebener Preview-Slice, der nur eine lokale
  Challenge-Darstellung zeigt und alle M16-V bis M16-AF-Grenzen wiederholt.

Weiterhin blockiert bleiben:

- produktive Quest Engine,
- Levelsystem,
- Timer/FOMO,
- Economy,
- Social/Competition,
- App-Integration,
- Route,
- Persistenz,
- Reward Bridge,
- BuildState,
- `frame_started`,
- automatische Wortplatzierung,
- Assets.

## 15. Dokumentationsvisualisierungen

Dokumentationsvisualisierungen liegen unter:

`docs/world_design/previews/m16_af_gameplay_pillars_quest_research/`

Erwartete PNGs:

- `00_contact_sheet.png`
- `gameplay_pillars_overview.png`
- `mvp_quest_loop.png`
- `challenge_type_matrix.png`
- `fun_without_learning_harm.png`
- `research_to_talvori_principles.png`

Dokumentationsvisuals sollen kuenftig bevorzugt als PNG und SVG erzeugt
werden. PNG dient der schnellen Vorschau. SVG dient der verlustfreien Zoom-
und Dokumentationsqualitaet.

Erwartete SVGs:

- `00_contact_sheet.svg`, falls sauber erzeugbar
- `gameplay_pillars_overview.svg`
- `mvp_quest_loop.svg`
- `challenge_type_matrix.svg`
- `fun_without_learning_harm.svg`
- `research_to_talvori_principles.svg`

Visual-QA-Regel:

- Text bleibt in Karten/Rahmen/Panels.
- Text darf nie aus Rahmen laufen.
- Ausreichender Innenabstand.
- Kartenabstaende.
- Keine Ueberlappung von Karten, Labels, Pfeilen, Titeln, Footern oder Legenden.
- Contact Sheet vollstaendig lesbar.
- Keine abgeschnittenen Inhalte.

## 16. Update fuer M16-T

M16-AF setzt passend auf erledigt:

- `M16T-GAME-001`
- `M16T-GAME-002`
- `M16T-GAME-003`
- `M16T-GAME-004`

M16-AF setzt passend auf teilweise vorbereitet:

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

- `docs/world_design/340-gameplay-pillars-and-mvp-quest-loop-research-prep.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/previews/m16_af_gameplay_pillars_quest_research/`

Nicht erwartet:

- Aenderungen unter `lib/`,
- Aenderungen unter `assets/`,
- Tests,
- Routen,
- App-Integration,
- Persistenz.
