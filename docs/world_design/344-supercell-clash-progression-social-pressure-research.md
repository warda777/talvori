# M16-AJ: Supercell / Clash Progression and Social Pressure Deep Research

Stand: 2026-06-08

Status: `Deep-Research-/Dokumentations-Slice / keine Implementierung`

## 1. Zweck

M16-AJ fuehrt die zweite grosse Deep-Research-Auswertung durch. Der Slice
untersucht Supercell / Clash of Clans und vergleichbare Aufbau-, Progression-,
Social- und Competition-Muster. Ziel ist nicht, Mechaniken zu kopieren,
sondern Prinzipien fuer langfristige Motivation, Aufbaufortschritt,
Entscheidungen, Trade-offs, Social Play und Competition-Risiken abzuleiten.

Fokus:

```text
Clash/Supercell beobachten
-> Progressions- und Social-Prinzip verstehen
-> Druck-/FOMO-/Pay-to-Win-/Social-Risiko bewerten
-> Talvori-Prinzip ableiten
-> MVP-Verbote bestaetigen
-> Implementierung weiter blockiert halten
```

## 2. Non-Goals und harte Stop-Regeln

M16-AJ erzeugt nicht:

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
- keine Analytics-Implementierung,
- keine Economy,
- keine Timer,
- keine Clans,
- keine Leaderboards,
- keine PvP-/Competition-Freigabe,
- keine Reward Bridge,
- keine automatische Wortplatzierung,
- kein Build-Wheel-Code,
- keine Assets,
- keine Asset-Dateien unter `assets/`,
- kein Build-State,
- kein `frame_started`,
- keine Bauzustaende,
- keine Social-/Competition-Implementierung,
- keine Monetarisierungsfreigabe,
- keine produktive Spielmechanik-Freigabe.

Alle Beobachtungen sind Research-Material. Sie sind keine Freigabe fuer
Runtime-Systeme, keine Economy-Entscheidung, keine Timer-Entscheidung und
keine Social-/Competition-Freigabe.

## 3. Gelesene interne Grundlagen

| Dokument | Rolle fuer M16-AJ |
| --- | --- |
| `328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrende M16-T-Liste, Dashboard und betroffene IDs. |
| `336-documentation-map-and-slice-reading-rules.md` | Pflichtlektuere, Output-Regeln, Scope-Checks und Visual-QA. |
| `341-broad-learning-game-benchmark-research-gate.md` | Benchmark-Landkarte; M16T-RESEARCH-003 war als eigenes Deep-Gate ausgelagert. |
| `343-habit-motivation-pressure-free-retention-research.md` | Anti-Druck-Prinzipien aus Habit/Motivation/Recall. |
| `340-gameplay-pillars-and-mvp-quest-loop-research-prep.md` | Gameplay Pillars, Quest-/Challenge-Grenzen und Research Prep. |
| `330-minimal-playable-learning-loop-contract.md` | Lernen erzeugt Moeglichkeit, keine Platzierung, keinen BuildState und keine Persistenz. |
| `332-reward-budget-and-review-queue-control-gate.md` | Reward-/Queue-Budgets verhindern Pflichtentscheidungen und Druck. |
| `334-companion-and-sensitive-return-safety-gate.md` | Companion, Pause, Fehler und sensitive Inhalte bleiben druckfrei. |
| `338-world-loop-plot-family-and-buildchoice-gate.md` | BuildChoice bleibt Candidate/Preview/Later, nicht BuildState. |
| `339-theme-island-resizing-and-remaining-world-rules-gate.md` | Capability, Resizing, TinyObject und sensitive-safe Asset-Regeln. |
| `342-asset-naming-licensing-and-offline-sync-planning-gate.md` | Asset-, Sync- und Konflikt-Gates bleiben ohne Implementierung. |

## 4. Research Source Register

Alle externen Quellen wurden am 2026-06-08 geprueft. Konkrete
Benchmark-Aussagen in diesem Dokument beziehen sich auf diese Quellen.

| Quelle | Art | Relevanz |
| --- | --- | --- |
| [Supercell: About Us](https://supercell.com/en/about-us/) | Offizielle Studio-Seite | Langzeit-Spielziel und Supercell-Produktphilosophie als Kontext fuer "Games for years". |
| [Supercell: Clash of Clans game page](https://supercell.com/en/games/clashofclans/) | Offizielle Produktseite | Village customization, army building, Clan-Bezug und Community-Kontext. |
| [Clash Support: About Clan Wars](https://support.supercell.com/clash-of-clans/en/articles/about-clan-wars-2.html) | Offizielles Help Center | Clans treten in Wars gegeneinander an; War-Struktur als Social-/Competition-Muster. |
| [Clash Support: Participating in a Clan War](https://support.supercell.com/clash-of-clans/en/articles/participating-in-a-clan-war.html) | Offizielles Help Center | Auswahl von War-Teilnehmern, Opt-in/Opt-out-Status, Leader-Auswahl und War-Teilnahmedruck. |
| [Clash Support: Clan War Matchmaking](https://support.supercell.com/clash-of-clans/en/articles/clan-war-matchmaking.html) | Offizielles Help Center | Matchmaking nach War Strength, Teamzusammenstellung und Fairness-Hinweise. |
| [Clash Support: Clan War Leagues](https://support.supercell.com/clash-of-clans/en/articles/about-cwl-3.html) | Offizielles Help Center | Season-Struktur, Leagues, Groups, Clan-Ergebnisse und Competition. |
| [Clash Support: Clan War League Leaderboard](https://support.supercell.com/clash-of-clans/en/articles/clan-war-league-leaderboard.html) | Offizielles Help Center | Ranking-/Leaderboard-Struktur fuer CWL. |
| [Clash Support: Clan Games](https://support.supercell.com/clash-of-clans/en/articles/clan-games.html) | Offizielles Help Center | Zeitlich begrenzte Clan-Challenges, Challenge-Auswahl und Clan-Zusammenarbeit. |
| [Clash Support: Clan Games Rewards](https://support.supercell.com/clash-of-clans/en/articles/clan-games-rewards.html) | Offizielles Help Center | Reward-Tiers, Punkte, Reward-Abholung und Ablaufzeiten. |
| [Clash Support: Loot and Star Bonus](https://ingame.support.supercell.com/clash-of-clans/en/articles/about-multiplayer-and-trophies-2.html) | Offizielles Help Center | Gold, Elixir, Dark Elixir, Star Bonus und 24-Stunden-Timer als Ressourcen-/Rhythmusmuster. |
| [Clash Support: Magic Items and the Trader](https://support.supercell.com/clash-of-clans/en/articles/magic-items-and-the-trader.html) | Offizielles Help Center | Items beschleunigen/unterstuetzen Upgrades, Training, Building, Ressourcen, Trader und Kaufwege; Pressure-/Monetization-Risiko. |
| [Clash Support: In-App Purchase information](https://support.supercell.com/clash-of-clans/en/articles/info-cc.html) | Offizielles Help Center | Monetarisierung und Kaufkontext als Pay-to-progress-/Fairness-Risikofeld. |
| [Clash Support: Builders and Builder's Huts](https://support.supercell.com/clash-of-clans/en/articles/builders-4.html) | Offizielles Help Center | Builders, Builder Huts, Gem-Kosten und Upgrade-/Progressionsmuster. |
| [Clash Royale Support: Clan Wars](https://support.supercell.com/clash-royale/en/articles/clan-wars.html) | Offizielles Help Center | Vergleichbares Supercell-Social-/War-Pattern fuer Teamdruck und Race-Struktur. |
| [Deconstructor of Fun: Why Clash of Clans is so successful](https://www.deconstructoroffun.com/blog/2012/12/why-clash-of-clans-is-so-successful) | Game-Design-Analyse | Sekundaere Design-Perspektive zu Builder, Resources, Raids, Progression und Social Dynamics. |
| [GameRefinery: Clash of Clans feature analysis](https://www.gamerefinery.com/feature-analysis-clash-of-clans-supercell/) | Game-Design-/Market-Analyse | Sekundaere Analyse zu LiveOps, Progression, Clans, Events und Motivation. |

## 5. Research-Framing fuer Talvori

Talvori sucht Prinzipien, keine Kopien.

Clash of Clans ist fuer Talvori interessant, weil es langfristigen
Aufbaufortschritt, Entscheidungen, Trade-offs, Social Play und Competition sehr
sichtbar macht. Genau dieselben Staerken sind fuer Talvori gefaehrlich, wenn
sie unkritisch uebernommen werden:

- Aufbaufortschritt darf motivieren, aber keine Timer-/FOMO-Logik erzeugen.
- Entscheidungen duerfen Bedeutung geben, aber nicht bestrafen.
- Social darf Zugehoerigkeit foerdern, aber keine Blossstellung oder War
  Pressure erzeugen.
- Competition bleibt nach MVP und braucht Fairness-, Safety-, Privacy-,
  Alters- und Moderations-Gates.
- Lernen bleibt wichtiger als Grind, Ressourcen, Rang, Clan-Pflicht oder
  sichtbarer Weltstatus.

MVP-Grenze:

```text
Talvori kann aus Aufbau- und Social-Spielen Prinzipien lernen.
Talvori uebernimmt im MVP keine Economy, Timer, Clans, Wars, Leagues,
Leaderboards, PvP, Upgradezeiten, Pay-to-Win oder Social Pressure.
```

## 6. Supercell / Clash Deep Research

### 6.1 Beobachtete Muster

| Muster | Beobachtung aus Quellen | Warum es motivieren kann | Talvori-Risiko |
| --- | --- | --- | --- |
| Base Progression | Dorf/Base, Town Hall, Upgrades, Builders und neue Systeme erzeugen langfristige Aufbaupfade. | Sichtbarer Fortschritt, klare Langzeitziele, "Ich baue etwas Eigenes". | BuildState, Timer, Grind oder Druck durch fehlende Ressourcen. |
| Resources / Upgrades / Timers | Gold, Elixir, Dark Elixir, Gems, Magic Items und Builder-Beschleuniger strukturieren Wachstum. | Ressourcen machen Entscheidungen greifbar und Ziele planbar. | Pay-to-Win, FOMO, Upgradezeit-Druck, Lernbremse durch Knappheit. |
| Decisions / Trade-offs | Clash betont strategische Tiefe und meaningful choices, besonders bei Town Hall/Progression. | Entscheidungen fuehlen sich wirksam an und erzeugen Ownership. | Zu grosse irreversible Entscheidungen koennen ueberfordern oder bestrafen. |
| Clans | Clans organisieren Gruppe, Hilfe, War-Teilnahme, Clan Games und Clan Capital. | Zugehoerigkeit, gemeinsame Ziele, Hilfe und Showcase. | Gruppendruck, Sichtbarkeit privater Lernleistung, Clan-Pflicht. |
| Clan Wars | Clans treten in War-Formaten gegeneinander an; Teilnahme kann ueber Leaders gesteuert werden. | Koordination, Teamziel, hohe Spannung. | War Pressure, Schuld bei Fehlern, soziale Sanktionen. |
| Clan War Leagues | Seasons, Groups, Leagues, Rewards und Rankings erzeugen Wettbewerb. | Langfristiges Ziel, Rangspannung, Teamidentitaet. | Rangdruck, Leaderboard-Scham, Competition verzerrt Lernen. |
| Clan Games | Zeitlich begrenzte Challenges mit Punkten und Reward-Tiers. | Gemeinsame Aktivitaet und short-term goals. | FOMO, Ablaufzeiten, Pflichtgefuehl gegenueber Clan. |
| Balance / Fairness | Matchmaking, War Strength und Balance-Regeln versuchen unfaire Paarungen zu reduzieren. | Vertrauen, sportlicher Wettbewerb. | Talvori braucht deutlich mehr Safety/Privacy, weil Lernleistung privat ist. |
| Monetization | Gems, In-App Purchases, Trader/Magic Items und Booster koennen Progress beschleunigen. | Finanzierung und Wahlmoeglichkeit. | Pay-to-Win- oder Pay-to-progress-Wahrnehmung, Lernmotivation wird gekauft. |

### 6.2 Aufbaufortschritt / Base Progression

Clash zeigt, dass langfristiger Aufbau motivieren kann, wenn Nutzer eine
eigene Basis wiedererkennen, Entscheidungen sehen und Fortschritt ueber Zeit
spuerbar ist. Fuer Talvori ist das Kernprinzip relevant:

```text
Eigener Lernfortschritt kann eine sichtbare Weltmoeglichkeit erzeugen.
```

Aber Talvori darf im MVP nicht die Clash-Ausfuehrungsform kopieren:

- keine Upgradezeiten,
- keine Builder,
- keine Ressourcenknappheit,
- keine Economy,
- keine permanente Base-Mutation,
- keine automatische Weltplatzierung,
- kein BuildState,
- kein `frame_started`.

Talvori-Lesart:

Aufbaufortschritt entsteht zunaechst als Bedeutung, Orientierung und
freiwilliger Candidate. Er wird nicht als Timer, Bauauftrag oder
Pflichtentscheidung sichtbar.

### 6.3 Ressourcen, Upgrades und Timer

Clash nutzt Ressourcen, Builder, Bonusrhythmen und Beschleuniger, um Upgrades
zu planen, zu begrenzen oder zu beschleunigen. Magic Items und Trader-Angebote
zeigen, wie Items und Gems Progression strukturieren koennen.

Fuer Talvori ist das ein Warnsignal:

- Eine Ressource kann Lernen schnell in Grind verwandeln.
- Ein Timer kann FOMO und Rueckkehrdruck erzeugen.
- Ein gekaufter Fortschritt kann Lernwert und Fairness beschaedigen.
- Eine knappe Ressource kann Nutzer vom eigentlichen Lernziel ablenken.

Talvori-Prinzip:

```text
MVP-Fortschritt ist semantisch und freiwillig, nicht zeitlich verknappt.
```

### 6.4 Entscheidungen und Trade-offs

Trade-offs koennen motivierend sein, wenn sie:

- klein genug sind,
- Sinn im aktuellen Kontext haben,
- spaeter aenderbar sind,
- Nutzerkompetenz staerken,
- nicht irreversible Nachteile erzeugen,
- nicht durch Geld, Rang oder Social Pressure verzerrt werden.

Trade-offs werden unfair oder ueberfordernd, wenn sie:

- zu viele Optionen gleichzeitig zeigen,
- Nutzer fuer Spaetentscheidung bestrafen,
- irreversible Weltfolgen haben,
- sensible/private Inhalte offenlegen,
- Lernfortschritt mit Ressourcenmangel koppeln,
- "richtige" Wahl als Druck inszenieren.

Talvori-Regel:

`Later`, `Codex`, `Backlog`, `Change` und `ContextCard` bleiben sichere
Ausgaenge. `BuildChoice` ist nur Candidate/Preview/Later, kein BuildState.

### 6.5 Clans, Clan Wars und Social Pressure

Clans und Wars zeigen, wie stark Zugehoerigkeit motivieren kann. Gleichzeitig
entsteht genau dort Talvoris groesstes Social-Risiko:

- andere koennen Leistung sehen oder erwarten,
- Gruppe kann Teilnahme einfordern,
- Fehler koennen sozial bewertet werden,
- Rang/War-Ergebnis kann Druck erzeugen,
- private Lerninhalte duerfen nicht geteilt werden,
- Pausen duerfen nicht als "Team schaden" erscheinen.

Talvori darf Social spaeter nur als freiwilligen, privacy-sicheren,
anti-druck-geprueften Raum betrachten. Fuer MVP bleibt Social/Competition
blockiert.

## 7. Vergleich mit Talvori

| Clash-Frage | Talvori-Uebersetzung | MVP-Entscheidung |
| --- | --- | --- |
| Wie motiviert sichtbarer Aufbau? | Weltfeedback zeigt Moeglichkeit und Bedeutung. | kleines, reversibles Feedback, kein BuildState. |
| Wie fuehlen sich Entscheidungen wirksam an? | Nutzer waehlt Sense, Outcome, Later oder Safe Default. | kleine semantische Entscheidungen, nicht Bauzwang. |
| Wie bleiben Trade-offs fair? | Jede Wahl bleibt aenderbar, erklaerbar und privacy-sicher. | Undo/Reversibility bleibt Voraussetzung. |
| Wie kann BuildChoice spaeter funktionieren? | Candidate -> Preview -> Later/Cancel/Change -> spaeteres Gate. | kein BuildChoice-Confirm im MVP. |
| Wie kann Social Zugehoerigkeit geben? | Freunde/Showcase spaeter, nur mit Privacy und Opt-in. | keine Clans, Wars, Ranglisten oder PvP. |
| Welche Progression passt zu Sprache? | Fortschritt als Kontext, Verstehen und Weltmoeglichkeit. | kein Grind, keine Ressource als Lernbremse. |

## 8. Aufbaufortschritt ohne Druck

Talvori-Prinzipien:

- Progression bedeutet mehr Bedeutung und mehr sichere Moeglichkeiten, nicht
  mehr Grind.
- Lernen oeffnet Optionen, fuehrt sie aber nicht automatisch aus.
- Kleine sichtbare Moeglichkeiten sind besser als Baupflicht.
- Weltfeedback bleibt reversibel und gated.
- Kein Timer im MVP.
- Keine War-/Raid-Mechanik.
- Keine Ressourcenknappheit als Druck.
- Kein Pay-to-Win.
- Keine Verlustangst.
- Kein Weltverfall.
- Kein Fortschritt durch Geld im ersten MVP.

Erlaubtes Bild:

```text
Lernen -> Bedeutung -> freiwilliger Candidate -> Later/Preview -> spaeteres Gate
```

Blockiertes Bild:

```text
Lernen -> Ressource -> Timer -> Upgrade -> BuildState -> Social Ranking
```

## 9. Social / Clan / Team / Freunde

### 9.1 Spaeter hilfreiche Social-Mechaniken

Nur nach eigenen Gates koennten spaeter nuetzlich sein:

- freiwilliges Showcase einer Welt,
- Freunde-Reaktionen ohne Rangliste,
- gemeinsames Lernen ohne sichtbaren Fehlerdruck,
- private Hilfeanfragen,
- Teamziele ohne Sanktion,
- Co-op-Ziele ohne sensible/private Inhalte,
- Companion-erklaerte Privacy-Auswahl.

### 9.2 Gefaehrliche Social-Mechaniken

Blockiert oder stark gated:

- Clanpflicht,
- War/Raid,
- Leaderboards,
- Leagues,
- PvP,
- sichtbare Fehlerhistorie,
- Teamdruck nach Pause,
- Wettbewerb um sensible/private Woerter,
- Rangpunkte aus Lernmenge,
- Social-Pushes,
- Gruppenchats ohne Moderation,
- Alters-/Privacy-unklare Freundesmechanik.

### 9.3 Daten, die nicht geteilt werden duerfen

Ohne eigenes Privacy-/Social-Gate duerfen nicht geteilt werden:

- private Woerter,
- Importquellen,
- Satz-/Kontext-Hints,
- sensitive Flags,
- Companion-Gespraeche,
- Fehlerhistorie,
- SRS-/`word_progress`-Werte,
- Review-Entscheidungen,
- Pausen- oder Rueckkehrmuster,
- Low-confidence Klassifikationen,
- private ThemeIsland- oder BuildChoice-Entscheidungen.

### 9.4 Anti-Blossstellung

Talvori muss verhindern, dass schwaechere, pausierende oder privatere Lernende
sichtbar schlechter wirken:

- kein Ranking nach Lernmenge,
- kein Ranking nach Fehlerfreiheit,
- keine War-Pflicht,
- keine Teamstrafe bei Pause,
- keine sichtbaren "schwache Mitglieder"-Signale,
- keine sensitive Inhalte im Social Feed,
- Opt-in vor jeder spaeteren Social-Sichtbarkeit.

## 10. Competition / League / Ranking

Wettbewerb kann motivieren, weil er:

- Ziele vergleicht,
- Spannung erzeugt,
- Gruppe und Identitaet staerkt,
- Fortschritt sichtbar macht,
- langfristige Meisterschaft andeutet.

Wettbewerb kann Lernen verzerren, weil er:

- Tempo ueber Verstehen stellt,
- einfache Aufgaben belohnt,
- Fehler beschaemt,
- Pausen sanktioniert,
- private Lerninhalte sichtbar macht,
- Nutzer nach Alter, Zeit, Vorwissen oder Sprache unfair vergleicht,
- sensitive Themen als Wettbewerbsmaterial missbrauchen koennte.

Fuer spaetere Competition-Gates muessen mindestens geklaert werden:

- Alters- und Minderjaehrigenschutz,
- Privacy und Sichtbarkeit,
- Moderation und Missbrauch,
- Fairness zwischen unterschiedlichen Lernzielen,
- Umgang mit Pausen,
- Umgang mit Fehlern,
- Opt-in/Opt-out,
- keine sensitive Inhalte,
- keine Pay-to-Win-Progression,
- keine Rang-/League-Pflicht.

MVP-Regel:

`Leaderboard`, `League`, `PvP`, `Clan`, `War`, `Raid`, `Team Pressure` und
`Social Ranking` bleiben blockiert.

## 11. Talvori-Prinzipien aus Research

| Prinzip | Bedeutung fuer Talvori | MVP-Regel |
| --- | --- | --- |
| Aufbaufortschritt als Moeglichkeit | Fortschritt oeffnet sichere Optionen, keine Pflicht. | Candidate/Preview/Later, kein BuildState. |
| Entscheidungen klein halten | Entscheidungen sollen Bedeutung klaeren, nicht bestrafen. | Later, Change, Codex und Backlog bleiben sichtbar. |
| Trade-offs semantisch begruenden | Wahl basiert auf Sense, Kontext, Safety und Nutzerziel. | Keine Ressourcen- oder Timer-Trade-offs. |
| Keine Timer/FOMO | Rueckkehr darf nicht von Ablaufzeiten getrieben sein. | keine Upgradezeiten, keine Event-Pflicht. |
| Keine Pay-to-Win-Progression | Lernen und Bedeutung bleiben Kern. | kein Fortschritt durch Geld im ersten MVP. |
| Social spaeter nur mit Gates | Zugehoerigkeit braucht Privacy, Fairness, Safety und Opt-in. | keine Clans, Wars oder Teams im MVP. |
| Keine Blossstellung durch Rankings | Lernleistung ist privat und individuell. | kein Leaderboard, kein League-System. |
| Keine War-/Raid-Pflicht | Teamdruck passt nicht zum Druckfrei-Lernen. | keine War-Mechanik, keine Gruppenschuld. |
| Weltfortschritt ersetzt Lernen nicht | Welt ist Feedback, nicht Hauptzweck. | kein Grind, keine Economy als Lernbremse. |
| BuildChoice bleibt Candidate | BuildChoice ist Option, nicht Zustand. | kein BuildChoice Confirm, kein `frame_started`. |

## 12. Anti-Patterns

Talvori muss vermeiden:

- Timerdruck,
- War Pressure,
- Clanpflicht,
- Leaderboard-Scham,
- Pay-to-Win,
- Grind,
- Ressourcenmangel als Lernbremse,
- FOMO-Events,
- Verlustangst,
- sozialer Druck,
- Fortschritt durch Geld statt Lernen,
- Wettbewerb um sensible/private Lerninhalte,
- sichtbare Fehlerhistorie,
- Pausen als Teamproblem,
- Upgradezeiten,
- BuildState als Reward,
- `frame_started` aus Progression.

## 13. MVP-Implikationen

Fuer den ersten MVP gilt:

- Social/Competition bleibt aus MVP raus.
- Keine Timer.
- Keine Economy.
- Keine Clans.
- Keine Leaderboards.
- Kein PvP.
- Kein Ranking.
- Kein BuildState.
- Keine Ressourcenlogik als Druck.
- Keine Upgradezeiten.
- Keine War-/Raid-Mechanik.
- Keine Teampflicht.
- Kein Fortschritt durch Geld.
- Weltfeedback bleibt klein, freiwillig, reversibel und gated.
- BuildChoice bleibt Candidate/Preview/Later, nicht BuildState.

MVP-kompatible Progressionsform:

```text
Lernen
-> semantische Bedeutung
-> sichere freiwillige Option
-> Later / ContextCard / Backlog / Preview Only
```

## 14. M16-T-ID-Entscheidung

| ID | Entscheidung in M16-AJ | Begruendung |
| --- | --- | --- |
| `M16T-RESEARCH-003` | Wird `[x]` | Supercell/Clash Deep Research fuer Progression, Trade-offs, Social, Competition und Risiken ist dokumentiert. |
| `M16T-SOCIAL-002` | Wird `[x]` | Fairness-/Safety-/Privacy-/Anti-Druck-Fragen fuer Competition sind dokumentiert; Implementierung bleibt blockiert. |
| `M16T-SOCIAL-003` | Wird `[x]` | Clan-/Team-/Freunde-Ideen sind als spaetere Gates mit Risiken und sicheren Grenzen dokumentiert. |
| `M16T-GAME-003` | Bleibt `[x]` | M16-AJ bestaetigt die bestehende Harmonisierung, erzeugt aber keine neue Runtime-Mechanik. |
| `M16T-GAME-004` | Bleibt `[x]` | Spass/Spannung ohne Lernschaden wird verschaerft, war aber bereits erledigt. |
| `M16T-WORLD-002` | Bleibt `[~]` | ThemeIsland-/Plot-Capacity-Regeln muessen weiter in konkrete spaetere World-Slices uebernommen werden. |
| `M16T-WHEEL-003` | Bleibt `[~]` | In-place-Wheel-Regeln bleiben eigenes Detail-/Implementierungs-Gate; M16-AJ gibt kein Wheel frei. |

## 15. Visualisierungen

Dokumentationsvisualisierungen:

`docs/world_design/previews/m16_aj_supercell_progression_research/`

Geplante und erzeugte Dateien:

- `supercell_progression_pattern_matrix.png`
- `supercell_progression_pattern_matrix.svg`
- `clash_risk_translation_to_talvori.png`
- `clash_risk_translation_to_talvori.svg`
- `progression_without_pressure_rules.png`
- `progression_without_pressure_rules.svg`
- `social_competition_safety_gate.png`
- `social_competition_safety_gate.svg`
- `talvori_post_mvp_social_boundary.png`
- `talvori_post_mvp_social_boundary.svg`
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

## 16. Weiter blockiert

Weiter blockiert bleiben:

- produktive Social-/Competition-Mechanik,
- Clans,
- Clan Wars,
- Leagues,
- Leaderboards,
- PvP,
- Economy,
- Timer,
- Upgradezeiten,
- Pay-to-Win-/Pay-to-progress-Systeme,
- Push-Retention,
- Analytics-Implementierung,
- produktive Progression,
- BuildChoice Confirm,
- BuildState,
- `frame_started`,
- App-Integration,
- Route,
- Persistenz,
- Supabase/local DB Writes,
- automatische Wortplatzierung,
- Assets,
- SRS-/`word_progress`-Aenderung.
