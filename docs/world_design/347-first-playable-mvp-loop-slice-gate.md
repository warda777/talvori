# M16-AM: First Playable MVP Loop Slice Gate

Stand: 2026-06-08

Status: `Dokumentations-/Visual-Slice / keine Implementierung`

## 1. Zweck

M16-AM definiert den ersten sehr kleinen, play-first gedachten
Talvori-MVP-Loop fachlich. Ziel ist eine konkrete erste Spielminute, die sich
nicht wie Vokabeltraining mit Spieldeko anfuehlt, sondern wie ein kleiner
Spielmoment, dessen Handlung Lernnutzen erzeugt.

Fuehrender Filter:

```text
Talvori ist kein Vokabeltrainer mit Spieldeko.
Talvori ist ein Spiel, dessen Spielhandlungen Lernnutzen erzeugen.
```

M16-AM ist ein Slice-Gate. Es gibt keine Implementierung, keine App-Integration
und keine produktive Spielmechanik frei.

## 2. Non-Goals und Stop-Regeln

M16-AM erzeugt nicht:

- keine Implementierung,
- keine Flutter-/Dart-Codeaenderung,
- keine App-Integration,
- keine Route,
- keine neue Seite,
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

Alle Loop-, UI- und Weltbegriffe in M16-AM sind fachliche Planung. Sie duerfen
nicht als Freigabe fuer Widget-Code, Route, Screen, Datenmodell, Persistenz,
Asset, BuildChoice oder BuildState gelesen werden.

## 3. Gelesene interne Grundlagen

| Dokument | Rolle fuer M16-AM |
| --- | --- |
| `328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrendes M16-T-Dashboard und Fokus-IDs. |
| `336-documentation-map-and-slice-reading-rules.md` | Pflichtlektuere-, Output-, Scope- und Visual-QA-Regeln. |
| `345-play-first-learning-experience-doctrine.md` | Play-First Rule und Spielmoment-Pflichtfilter. |
| `346-non-learning-game-patterns-for-play-first-talvori.md` | Non-Learning-Game-Muster, sichere Uebersetzung und Druckmuster. |
| `343-habit-motivation-pressure-free-retention-research.md` | Micro Sessions, Recall, Motivation ohne Druck. |
| `344-supercell-clash-progression-social-pressure-research.md` | Aufbaufortschritt ohne Timer, Social Pressure oder Economy. |
| `340-gameplay-pillars-and-mvp-quest-loop-research-prep.md` | Gameplay Pillars und Quest-/Challenge-Grenzen. |
| `330-minimal-playable-learning-loop-contract.md` | Learning-to-World Contract und Event-Trennung. |
| `331-minimal-word-outcome-detail-gate.md` | Outcome-Regeln, Queue-Ausgaenge, Reward/BuildState-Trennung. |
| `332-reward-budget-and-review-queue-control-gate.md` | Reward-Budget, Review-Budget, Safe Defaults. |
| `333-minimal-semantic-profile-and-routing-priority-gate.md` | Safety, Sense, Word Type, Clutter, Confidence vor World Feedback. |
| `334-companion-and-sensitive-return-safety-gate.md` | Tali/Vori, Pause, Fehler, Sensitive ohne Druck. |
| `335-learning-states-and-srs-boundary-gate.md` | Lernzustaende bleiben von SRS, Reward, Queue und Weltfeedback getrennt. |
| `337-mobile-density-accessibility-and-depth-planning-gate.md` | Mobile-Dichte, Overlays, Touch-Ziele und Depth-Grenzen. |
| `338-world-loop-plot-family-and-buildchoice-gate.md` | WorldCandidate, Plot Family und BuildChoice bleiben Candidates. |
| `339-theme-island-resizing-and-remaining-world-rules-gate.md` | Capability, TinyObject, Resizing und Asset-Scope als Stop-Regeln. |

## 4. M16-T-ID-Entscheidung

| ID | Entscheidung nach M16-AM | Begruendung |
| --- | --- | --- |
| `M16T-PLAY-008` | bleibt `[~]` | Der Play-First-Check ist fuer den ersten Loop konkretisiert, aber noch nicht in einem echten Implementierungs-Slice angewendet. |
| `M16T-MVP-004` | bleibt `[x]` | Minimal spielbarer Lernloop war bereits definiert; M16-AM konkretisiert nur die erste Spielminute. |
| `M16T-PROD-003` | bleibt `[~]` | Welt-dient-Lernen-Regel wird angewendet, muss aber in spaeteren World-/Code-Slices weiter nachgewiesen werden. |
| `M16T-CORE-003` | bleibt `[~]` | UI-Event-Regel wird wiederholt, aber noch nicht in Code angewendet. |
| `M16T-L2W-003` | bleibt `[~]` | Weltreif wird fuer `Bank` operationalisiert, produktive Kriterien bleiben spaeteres Gate. |
| `M16T-SCALE-001` | bleibt `[~]` | Der Loop zeigt ein Einzelwort-Beispiel; Massensemantik bleibt eigenes System. |
| `M16T-WORLD-002` | bleibt `[~]` | ThemeIsland-/Plot-Capacity wird nicht umgesetzt und bleibt fuer spaetere Slices offen. |
| `M16T-WHEEL-003` | bleibt `[~]` | In-place-Wheel ist nicht Teil des ersten Loop-Gates. |
| `M16T-SENS-003` | bleibt `[~]` | Sensitive Inhalte bleiben blockiert; keine neue Sensitive-Asset-/World-Freigabe. |
| `M16T-ASSET-002` | bleibt `[~]` | Kein Wort erzeugt Assets; die Regel wird wiederholt, nicht produktiv geprueft. |

## 5. Executive Definition: erste Talvori-Spielminute

Die erste Talvori-Spielminute ist:

```text
Ein kleines Meaning Puzzle mit Context Door fuer das Wort `Bank`.
```

Ablauf in einem Satz:

> Tali/Vori zeigt eine kleine Situation mit drei moeglichen Bedeutungs-Tueren;
> der Nutzer entscheidet, welche Bedeutung von `Bank` in den Kontext passt,
> und erhaelt eine kurze ContextCard/Codex-Discovery statt Build, Placement
> oder SRS-Schreibzugriff.

Kernregeln:

- Nutzer startet einen kleinen Spielmoment.
- Tali/Vori setzt eine neugierige Situation.
- Das Wort wird nicht abgefragt, sondern als Problem/Situation eingebettet.
- Nutzer loest ein Meaning Puzzle oder eine Context Door.
- Ergebnis erzeugt kein Build, sondern `ContextCard`, `Codex Discovery` oder
  kleinen `World Hint`.
- `Later`, `Codex`, `Backlog` und `Change` bleiben sichtbar.
- Lernen passiert als Nebenprodukt: der Nutzer versteht Sense und Kontext.

## 6. Play-First Check fuer den ersten Loop

| Frage | Antwort fuer M16-AM |
| --- | --- |
| Was ist der Spielmoment? | Eine kleine Situationswahl: Welche Tuer passt zu `Bank`? |
| Was macht neugierig? | `Bank` sieht einfach aus, kann aber Sitzbank, Geldinstitut oder Flussufer sein. |
| Was ist die kleine Herausforderung? | Den Satz-/Bildkontext lesen und die passende Bedeutung waehlen. |
| Was fuehlt sich belohnend an? | Die richtige Tuer leuchtet als Bedeutung auf; Codex/ContextCard wird klarer. |
| Was lernt der Nutzer nebenbei? | Multi-Sense, Context vor Oberflaeche, kein Default-Sense. |
| Warum fuehlt es sich nicht wie klassische Uebung an? | Der Nutzer loest eine Szene, keine Uebersetzungsabfrage und kein Multiple-Choice-Drill. |
| Welche Druckmechaniken sind ausgeschlossen? | Timer, Streak, XP-Grind, Review-Zwang, FOMO, Gacha, Rank, Social Pressure. |
| Wo sind sichere Ausgaenge? | `Later`, `Codex`, `Backlog`, `ContextCard`, `Change`. |

M16-AM-Anwendung der Play-First Rule:

```text
Game pattern: Puzzle / Context Door.
Talvori moment: Bedeutungstuer in kleiner Situation waehlen.
Learning value: Sense und Kontext werden verstanden.
Blocked traps: Quiz-Skin, Timer, BuildState, Auto-Placement, Pflichtreview.
```

## 7. Primaere MVP-Loop-Variante

| Feld | Entscheidung |
| --- | --- |
| Typ | Meaning Puzzle + Context Door |
| Beispielwort | `Bank` |
| Warum `Bank`? | Hoher Lernwert durch Mehrdeutigkeit, klarer Spielmoment, geringes Sensitive-/Asset-/World-Scope. |
| Companion | optionaler kurzer Tali/Vori-Hinweis, keine Entscheidung durch Companion. |
| Spielmoment | Nutzer waehlt zwischen drei Bedeutungs-Tueren einer kleinen Szene. |
| Ergebnis | `ContextCard`, `Codex Discovery` oder kleiner `World Hint` als Preview/Fallback. |
| Safe Defaults | `Later`, `Codex`, `Backlog`, `Change`. |
| Blockiert | BuildState, Placement, SRS-Write, Asset, Route, App-Integration. |

### 7.1 Beispielszene fuer `Bank`

Keine finale Copy, nur fachliches Muster:

```text
Tali/Vori: "Drei Tueren reagieren auf dasselbe Wort. Welche Tuer passt zur
Szene?"

Szene: "Am Fluss macht Tali kurz Pause."

Tueren:
- Sitzbank
- Geldinstitut
- Flussufer

Sicherer Ausgang:
- passende Tuer erklaert den Sense,
- `Bank` wird im Codex als mehrdeutig markiert,
- optionaler World Hint: "Kontext kann spaeter Orte oeffnen",
- kein Build, kein Placement, kein Asset.
```

Warum nicht `Schluessel` als primaerer Loop?

`Schluessel` ist stark fuer Container Hunt, bringt aber TinyObject/Depth-Scope
frueher hinein. `Bank` prueft Play-First, Semantik und User Choice sauberer,
ohne Container- oder Asset-Erwartung.

## 8. Alternative Mini-Loops

Diese Alternativen bleiben dokumentiert, aber nicht freigegeben.

| Alternative | Spielgefuehl | Lernnutzen | Erlaubtes Feedback | Blockierte Mechaniken | MVP-Eignung |
| --- | --- | --- | --- | --- | --- |
| Container Hunt mit `Schluessel` | kleines Objekt im passenden Kontext finden | TinyObject, ContainerItem, Depth verstehen | Container-Hinweis, Codex, Backlog | IslandView-Minipixel, Asset, Persistenz | gut, aber nach Mobile/Depth-Preview |
| Action Moment mit `schwimmen` | kurze Handlung statt Objekt | Verb, ActionChallenge, Water/Safety-Kontext | ContextCard oder ActionChallenge-Idee | Wasserlogik, Timer, Questpflicht, Gebaeude | spaeter, weil Safety/Water-Gate noetig |
| Codex Discovery mit `Freiheit` oder `Angst` | Bedeutung als ruhiger Fund | abstrakt/sensibel ohne Symbolzwang | Codex, ContextCard, Later/Hide | sensitive Retention, Drama, Deko, Reward | gut als Safety-Beispiel, nicht als erste Spielminute |

## 9. Erste Spielminute als Ablauf

Planungsablauf, keine UI-Implementierung:

| Zeit | Moment | Handlung | Lernnutzen | Sicherer Ausgang |
| --- | --- | --- | --- | --- |
| 0-5s | Einstieg | Nutzer startet freiwillig den Mini-Moment. | Erwartung: Spielhandlung statt Uebung. | Abbrechen/Later ohne Verlust. |
| 5-12s | Situation | Tali/Vori zeigt eine kurze Szene zu `Bank`. | Kontext wird wichtiger als Wortoberflaeche. | Companion bleibt optional. |
| 12-25s | Wort-/Kontextimpuls | Drei Bedeutungs-Tueren erscheinen als fachliches Konzept. | Multi-Sense wird sichtbar. | Codex/Backlog sichtbar. |
| 25-40s | Nutzerentscheidung | Nutzer waehlt Sitzbank, Geldinstitut oder Flussufer. | Sense-Entscheidung. | Change/Later jederzeit moeglich. |
| 40-50s | Feedback | Passende Bedeutung wird kurz erklaert. | Kontext bestaetigt Lernen. | Kein SRS-Write, kein Score-Zwang. |
| 50-58s | Welt-/Codex-Signal | ContextCard/Codex Discovery oder kleiner World Hint erscheint. | Welt dient Bedeutung, ersetzt Lernen nicht. | Kein BuildState, kein Placement. |
| 58-60s | Ende ohne Pflicht | Nutzer kann noch eine Runde, Codex, Later oder Ende waehlen. | Freiwilligkeit und Flow. | Keine Pflichtserie, kein Timer. |

## 10. UI-/Screen-Nichtfreigabe

M16-AM beschreibt nur fachlich:

- keine Route,
- kein Screen-Code,
- keine Widgets,
- kein Launch Target,
- kein Asset,
- keine Persistenz,
- keine Tests,
- keine echte App-Integration,
- keine produktive Navigation,
- keine Runtime-Konfiguration.

Ein spaeterer Preview-Code-Slice waere nur nach separatem Implementierungs-
Prompt moeglich. Dieser Prompt muesste `347`, `345`, `346`, `330`, `331`,
`332`, `333`, `334`, `335`, `337`, `338`, `339` und `328` lesen und die
Play-First-Check-Fragen vor Code wiederholen.

## 11. MVP-Loop-Grenzen

Der erste Loop blockiert:

- kein Timer,
- kein Streak,
- kein XP-Grind,
- kein Leaderboard,
- kein Social,
- kein BuildState,
- kein `frame_started`,
- keine automatische Weltplatzierung,
- kein Review-Zwang,
- kein Pflichtlernen,
- keine sensitive Retention,
- kein Gacha,
- kein Pay-to-Win,
- keine Economy,
- keine Upgradezeit,
- keine Clans oder PvP,
- kein Asset,
- keine SRS-/`word_progress`-Aenderung.

## 12. Spielmoment-zu-Lernnutzen-Mapping

| Spielhandlung | Lernnutzen | Word Outcome | Feedback-Typ | Safe Default | Blockiert |
| --- | --- | --- | --- | --- | --- |
| Context Door waehlen | Sense im Satz verstehen | `NeedsUserChoice` -> `ContextCard` | kurze Bedeutungsklaerung | `Later`, `Change` | Default-Sense als Weltobjekt |
| Bedeutung bestaetigen | Multi-Sense bewusst machen | `ContextCard` / `CodexOnly` | Codex Discovery | `Codex`, `Backlog` | SRS-Write, Score-Zwang |
| Falsche Tuer korrigieren | Fehler als Spielinformation | `NeedsUserChoice` bleibt offen | Calm Retry | `Change`, `Later` | Beschamung, Weltstrafe |
| World Hint ansehen | Weltbezug als Moeglichkeit sehen | spaeter `WorldCandidate` nur nach Gate | Preview/Fallback | `Backlog` | Placement, BuildState |
| Runde beenden | Freiwilligkeit erhalten | kein neuer Outcome-Zwang | ruhiges Ende | Ende/Later | Pflichtserie, Timer |

## 13. Playtest-Kriterien fuer diesen ersten Loop

Spaetere Tests fuer genau diesen Loop muessen fragen:

| Frage | Erwartetes Signal |
| --- | --- |
| Hat sich das wie Spielen angefuehlt? | Ja, kleine Situation/Entscheidung statt Fragebogen. |
| Wolltest du wissen, was als Naechstes passiert? | Neugier ohne FOMO. |
| Hat sich das wie Schule/Vokabeltest angefuehlt? | Nein oder nur minimal. |
| War die Entscheidung klein genug? | Drei klare Optionen, keine Ueberforderung. |
| War `Later` sichtbar? | Nutzer fuehlt keinen Zwang. |
| War Feedback motivierend? | Klarheit und kleiner Fund, keine Strafe. |
| Hast du verstanden, warum die Welt reagiert hat? | Welt-/Codex-Signal folgt aus Bedeutung, nicht aus Score. |
| Hast du unbewusst etwas gelernt? | Sense und Kontext wurden klarer. |
| Wuerdest du freiwillig noch eine Runde spielen? | Play-First-Loop hat Potenzial. |

## 14. Entscheidung

Beste erste MVP-Loop-Entscheidung:

```text
Meaning Puzzle + Context Door mit `Bank`.
```

Warum zuerst:

- Es zeigt sofort, dass Talvori nicht Vokabeln abfragt, sondern Bedeutung
  spielerisch klaert.
- Es nutzt ein starkes Non-Learning-Game-Muster: kleine Puzzle-Entscheidung,
  sofortiges Feedback, freiwilliger Retry.
- Es beweist die M16-L/Y-Regel: Context/Sense vor World/Theme/Reward.
- Es vermeidet fruehen Build-, Asset-, Container-, Water-, Sensitive-,
  Social- oder Economy-Scope.
- Es ist klein genug fuer eine spaetere isolierte Preview, aber fachlich stark
  genug, um Play-First zu pruefen.

Was bleibt fuer spaeter:

- Container Hunt mit `Schluessel`,
- Action Moment mit `schwimmen`,
- Codex Discovery mit abstrakten/sensiblen Woertern,
- echte Review-Queue-UI,
- echte World Preview,
- BuildChoice/Wheel,
- App-Integration,
- Persistenz,
- SRS-/`word_progress`-Gate,
- Tests/Accessibility/Performance.

Folge-Slices vor Code:

1. `M16-AN` oder vergleichbar: isolierter Preview-Implementation-Prompt-Draft
   fuer `Bank` Meaning Puzzle, ohne Route/App-Integration.
2. Separater Implementierungs-Gate-Slice mit erlaubter Datei, Format-/Analyze-
   Checks und expliziter Stop-Regel gegen SRS, Persistenz, BuildState.
3. Erst danach ein minimaler lokaler Preview-Code-Slice, falls explizit
   freigegeben.

## 15. Visualisierungen

M16-AM erzeugt Dokumentationsvisuals unter:

`docs/world_design/previews/m16_am_first_playable_mvp_loop/`

Visuals:

- `first_playable_loop_flow.png` + `.svg`
- `play_first_check_for_mvp_loop.png` + `.svg`
- `first_minute_sequence.png` + `.svg`
- `game_moment_to_learning_mapping.png` + `.svg`
- `allowed_vs_blocked_mvp_loop.png` + `.svg`
- `00_contact_sheet.png` + `.svg`

Visual-QA:

- Text bleibt vollstaendig in Karten/Rahmen/Panels.
- Keine Woerter laufen aus Rahmen.
- Ausreichender Innenabstand und Kartenabstand.
- Keine Ueberlappung von Karten, Labels, Pfeilen, Titeln, Footern oder
  Legenden.
- Contact Sheet ist vollstaendig lesbar.
- Keine abgeschnittenen Inhalte.
- SVGs muessen XML-parsebar sein.

## 16. Stop-Regeln

M16-AM gibt nicht frei:

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
