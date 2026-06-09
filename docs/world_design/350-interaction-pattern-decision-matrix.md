# M16-AX: Interaction Pattern Decision Matrix

Stand: 2026-06-09

Status: `Dokumentations-/Regel-Slice, keine Implementierung`

## 1. Zweck

Talvori waehlt Interaktionsmuster kuenftig bewusst. Nicht jede Aktion nutzt ein
Wheel. Nicht jede Aktion nutzt Drag. Nicht jede Aktion braucht ein Popup oder
eine neue Seite.

Die UI-Art wird nach Aktionstyp, Risiko, Informationsmenge, Wiederholung,
Entscheidungsgewicht und Spielkontext entschieden. Erfolgreiche Mobile-,
Live-Service- und Game-UIs kombinieren direkte Weltaktionen, HUD, kleine
Kontextmenues, Bottom-Sheets, In-place-Wheels, Showcase-Seiten,
Crafting-/Inventar-Seiten, Reward-Popups und Questtracker je nach Aufgabe.
Talvori uebernimmt daraus Prinzipien, aber keine produktive Mechanik.

## 2. Non-Goals / Stop-Regeln

Dieser Slice erzeugt keine Implementierung.

Nicht freigegeben:

- keine Flutter-/Dart-Codeaenderung,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- keine Assets,
- keine Tests,
- kein BuildState,
- kein `frame_started`,
- keine Produktivmechanik-Freigabe.

## 3. Gelesene Grundlagen

- `328-talvori-learning-game-readiness-todo-checklist.md`
- `336-documentation-map-and-slice-reading-rules.md`
- `345-play-first-learning-experience-doctrine.md`
- `346-non-learning-game-patterns-for-play-first-talvori.md`
- `338-world-loop-plot-family-and-buildchoice-gate.md`
- `339-theme-island-resizing-and-remaining-world-rules-gate.md`
- `318-theme-island-plot-capacity-and-build-wheel-plan.md`
- `272-plot-capability-derivation.md`

## 4. Grundsatz

Island-First bleibt fuehrend, bedeutet aber nicht, dass nie eine eigene Seite
erlaubt ist.

Verbindlich:

- Der Spielmoment muss aus der Welt entstehen: Insel, Plot, Weg, Objekt,
  Figur, Szene, Container, Codex-Ort oder Board.
- Kleine, haeufige Aktionen bleiben moeglichst direkt im Spielbild.
- Mittlere Entscheidungen duerfen kleine Overlays, Bottom-HUDs oder kompakte
  In-place-Menues nutzen.
- Grosse Entscheidungen mit Vergleich, Vorschau oder Planung duerfen eine
  eigene Showcase-, Werkbank-, Inventar- oder Management-Ansicht nutzen.
- Eine eigene Ansicht muss wie ein Spielmodus wirken, nicht wie ein
  Lernformular.
- UI erklaert und strukturiert; sie darf den Weltmoment nicht durch ein
  separates Lernfenster ersetzen.

## 5. Interaktionsmuster

| Muster | Geeignet fuer | Nicht geeignet fuer | Talvori-Regel |
| --- | --- | --- | --- |
| Direkte Weltaktion | Tappen, Sammeln, Oeffnen, kurzer Start eines Spielmoments | komplexe Vergleiche, riskante irreversible Schritte | Erste Wahl fuer haeufige kleine Inselaktionen. |
| Kleines Kontextmenue am Objekt | 2-4 schnelle Objektaktionen | lange Texte, viele Optionen | Nur nahe am Objekt, kurz, kein Vollfenster. |
| Kompaktes In-place-Wheel | kurze Kategorieauswahl mit wenigen Optionen | viele Kategorien, Details, Vergleiche | Icon + Kurzname; Details gehoeren woanders hin. |
| Bottom-Sheet / Bottom-HUD | mittlere Entscheidung, kurze Details, Safe Exits | dauerhafte Hauptnavigation, lange Planung | Muss Spielbild sichtbar lassen und klein starten. |
| Permanente HUD-/Hotbar-Elemente | Safe Exits, Inventarzugriff, Questbadge, Modus | erklaerender Textblock | Ruhig, klein, dauerhaft lesbar. |
| Angepinnter Quest-/Aufgaben-Tracker | freiwillige Ziele, naechster Schritt, Fortschritt | Pflichtliste, Druck, Streak-Schuld | Nur leichte Orientierung, kein Pop-up-Spam. |
| Eigene Showcase-Seite | grosse visuelle Auswahl, BuildChoice, Companion, Biome | schnelle Weltaktion | Muss als Spielmodus mit grossem Preview wirken. |
| Carousel-/Card-Auswahl | wenige visuelle Alternativen, Varianten, Style | sehr kleine Aktionen, lange Erklaerungen | Karten duerfen Auswahlstuetze sein, nicht Lernfenster. |
| Crafting-/Werkbank-Ansicht | Herstellung, Kombinieren, Planen | einzelner Plot-Tap, kurzer Meaning-Puzzle-Moment | Eigene Spielstation, keine BuildState-Freigabe. |
| Inventory-/Deck-/Sammlungsseite | Codex, Sammlung, Deck, Rueckblick | spontane Aktion im Spielbild | Eigener Ort fuer Ordnung und Vergleich. |
| Kurzes Reward-Popup / Toast | besonderer Fund, kleines Feedback | Standardaktion, Pflichtreview | Kurz, reversibel, kein Druck, kein Build. |
| Bestaetigungsdialog | riskante oder potentiell verwirrende Aktion | normale Taps, Spieltempo | Nur bei echtem Risiko; sicherer Abbruch immer sichtbar. |
| Map-/Board-Ansicht | Inselplanung, Regionen, Plot-Kandidaten, Reise | Detailtexte und Lernformular | Board bleibt Spielraum, HUD erklaert. |
| Companion-Bubble / Sprechblase | kurze Erklaerung, Hinweis, Calm Retry | Beratung, Druck, lange Tutorials | Optional, ruhig, keine Pflichtentscheidung. |

## 6. Entscheidungsmatrix fuer Talvori-Situationen

| Situation | Primaeres Muster | Sekundaeres Muster | Bewusst nicht |
| --- | --- | --- | --- |
| Plot/Grundstueck antippen | Direkte Weltaktion auf dem Board | Bottom-HUD mit Kurzinfo | neue Seite fuer einfachen Tap |
| Plot-Kategorie waehlen | kompaktes In-place-Wheel | kleines Bottom-Sheet, wenn 5+ Optionen noetig sind | grosses Wheel-Fenster, Drag als Standard |
| Gebaeude/BuildChoice auswaehlen | eigene Showcase-Seite | Carousel/Card-Auswahl | kleines Wheel mit langen Beschreibungen |
| Grundstuecksgroesse/Shape previewen | Board-/Map-Ansicht mit Shape-Overlay | Bottom-HUD fuer Details | sofortiges Placement oder BuildState |
| Spielmoment starten | direkte Weltaktion am Plot/Objekt | Companion-Bubble mit kurzem Hook | separate Lernseite als Start |
| Bank Meaning Puzzle loesen | Weltaktion am Flussufer-Plot | Plot-Bubble / ContextCard-HUD | Quizfenster als Hauptflaeche |
| Container Hunt loesen | direkte Weltaktion am Container/Ort | kleines Kontextmenue | globale Liste kleiner Objekte |
| Action Moment loesen | direkte Szene-/Figuraktion | Companion-Bubble | Formular oder Multiple-Choice als Hauptgefuehl |
| Codex ansehen | Inventory-/Sammlungsseite oder Codex-Ort | Bottom-Sheet fuer Kurzfund | Popup fuer lange Inhalte |
| Crafting/Herstellung | Crafting-/Werkbank-Ansicht | Inventory/Deck als Quelle | In-place-Wheel fuer komplexe Rezepte |
| Quest/Aufgabe verfolgen | angepinnter Questtracker/Badge | Bottom-HUD bei Auswahl | stoerende Popups nach jeder Aktion |
| Belohnung/Fund anzeigen | kurzer Toast / Reward-Popup | Companion-Bubble fuer seltene Erklaerung | Druck, Streak, sensitive Retention |
| Riskante Entscheidung bestaetigen | Bestaetigungsdialog | spaeter Review/Later | stilles Ueberschreiben |
| App-Integration / Navigation | eigenes App-/Route-Gate | Showcase- oder Mode-Konzept im Plan | nebenbei in Preview-Code |
| Debug/Layout-Modus | Map-/Board-Ansicht mit Dev-HUD | Drag/Snap-Handles | Standard-Nutzerflow |

## 7. Konkrete Talvori-Regeln

- Haeufige kleine Aktionen bleiben direkt auf der Insel.
- Grundstueckskategorien nutzen In-place-Wheel oder kompaktes Bottom-Sheet.
- Gebaeude-/BuildChoice-Auswahl darf eine Showcase-Seite nutzen, wenn
  visuelle Vorschau, Vergleich oder Varianten wichtig sind.
- Crafting/Herstellung bekommt eher eine Werkbank-Seite als ein Wheel.
- Codex/Sammlung bekommt eine eigene Sammlung/Detailseite oder einen
  klaren Codex-Ort.
- Aufgaben werden als kleiner Tracker, Badge oder HUD-Hinweis gefuehrt,
  nicht als stoerendes Popup.
- Belohnungen und Funde erscheinen als kurzer Toast, kleines Popup oder
  weltnahe Bubble.
- Drag & Drop bleibt primaer Dev-/Layout-Modus oder spaetere Editierfunktion,
  nicht Haupt-Nutzerflow.
- Popups sind besondere Momente, nicht Standardaktionen.
- Bestaetigungen sind fuer Risiko, nicht fuer jeden Tap.
- Jede UI muss Safe Defaults wie Later, Codex, Backlog, Cancel oder Close
  leicht erreichbar halten.

## 8. Wheel neu einordnen

Ein In-place-Wheel ist geeignet, wenn alle Bedingungen erfuellt sind:

- wenige Optionen,
- kurze Kategorienamen,
- Icon + Kurzname reichen,
- Entscheidung ist lokal und reversibel,
- Details sind nicht entscheidend fuer die erste Auswahl,
- das Wheel bleibt nahe am Weltobjekt oder Anchor.

Ein Wheel ist nicht geeignet fuer:

- viele Kategorien,
- lange Texte,
- komplexe Vergleiche,
- BuildChoice mit visueller Vorschau,
- Crafting-Rezepte,
- sensible Entscheidungen,
- riskante oder irreversible Schritte.

Regel:

```text
Wheel = kurze In-place-Auswahl.
Details = HUD, Bottom-Sheet oder Showcase.
Confirm = lokale Preview, keine Speicherung.
```

## 9. Showcase-Seite definieren

Eine Showcase-Seite ist erlaubt, wenn die Entscheidung visuelle Vorschau,
Vergleich oder Planung braucht.

Geeignet fuer:

- Gebaeude auswaehlen,
- Charakter/Companion auswaehlen,
- Outfit/Skin/Style auswaehlen,
- groessere BuildChoice-Vorschau,
- Insel-/Biome-Auswahl,
- spaetere World- oder Region-Entscheidungen.

Muss spielartig wirken:

- grosses zentrales Preview-Objekt,
- Carousel, Side Cards oder klare Vergleichsbereiche,
- wenige klare Aktionen,
- Safe Exit sichtbar,
- kein Lernformular,
- kein Tabellen-/Admin-Gefuehl als Hauptflaeche.

Auch eine Showcase-Seite bleibt ein Gate-Konzept: Sie erzeugt keine Route,
keinen BuildState, kein Asset, keine Persistenz und keine produktive
Mechanikfreigabe.

## 10. Research-/Benchmark-Check bei unklaren UI-Entscheidungen

Bei unklarer UI-, Spielaufbau- oder Interaktionsentscheidung muss vor der
Umsetzung ein kurzer Benchmark-/Research-Check erfolgen. Das gilt besonders,
wenn unklar ist, ob Talvori eine direkte Weltaktion, ein kleines Kontextmenue,
ein In-place-Wheel, ein Bottom-HUD, eine Showcase-Seite, eine Werkbank-/
Crafting-Seite, eine Inventar-/Codex-Seite, einen Questtracker oder einen
Reward-Toast nutzen soll.

Pflichtfragen:

| Frage | Erwartetes Ergebnis |
| --- | --- |
| Welche erfolgreichen Spiel-/UI-Muster wurden geprueft? | z. B. direkte Weltaktion, Kontextmenue, HUD, Wheel, Bottom-Sheet, Showcase, Werkbank, Inventar/Codex, Questtracker, Toast. |
| Welche Spiel-/UI-Logik dient als Vorbild? | Prinzip benennen, keine blinde Kopie eines Produkts. |
| Welches Muster wird gewaehlt? | Konkrete UI-Art nennen. |
| Warum passt dieses Muster? | Aktionstyp, Risiko, Informationsmenge, Wiederholung und Spielkontext begruenden. |
| Welche Alternativen wurden bewusst verworfen? | z. B. kein grosses Fenster, kein Drag als Standard, keine Showcase-Seite fuer kleine Auswahl. |
| Welche Talvori-Regeln schuetzen die Umsetzung? | Play-First, Island-First, Safe Defaults, kein BuildState, keine Persistenz, kein Druck. |

Regel:

```text
Unsichere UI-Entscheidung
-> kurzer Benchmark-/Research-Check
-> Pattern bewusst waehlen
-> Alternativen begruendet verwerfen
-> erst dann Implementierung.
```

Dieser Check ist keine Mechanikfreigabe. Er verhindert nur, dass Talvori
UI-Muster aus Gewohnheit baut, statt von erfolgreichen Spielmustern zu lernen
und sie passend zu Talvori zu uebersetzen.

## 11. Prompt-Regel fuer kuenftige Slices

Jeder kuenftige UI-, MVP-, Gameplay-, Quest-, Challenge-, World-, BuildChoice-,
App-Integrations- oder Implementierungs-Slice muss beantworten:

| Frage | Pflichtantwort |
| --- | --- |
| Welche UI-Art wird genutzt? | z. B. Weltaktion, Wheel, Bottom-HUD, Showcase, Werkbank, Codex-Seite. |
| Warum passt sie zur Aktion? | Aktionstyp, Risiko, Informationsmenge und Spielkontext benennen. |
| Warum ist sie nicht zu gross oder zu klein? | Wheel nicht fuer Vergleich; Showcase nicht fuer einfachen Tap. |
| Welche Alternative wurde bewusst nicht gewaehlt? | z. B. kein Drag, kein Popup, keine neue Seite, kein Wheel. |
| Wo bleibt Island-First sichtbar? | Weltort oder Spielmodus muss die Handlung tragen. |
| War ein Research-/Benchmark-Check noetig? | Wenn ja: Muster, Vorbildlogik, Entscheidung und verworfene Alternativen nennen. |

## 12. M16-T-ID-Entscheidung

| ID | Status | Entscheidung |
| --- | --- | --- |
| M16T-INTERACT-001 | [x] | Interaction Pattern Decision Matrix ist mit diesem Dokument definiert. |
| M16T-INTERACT-002 | [x] | UI-Muster muessen pro Aktion bewusst gewaehlt und begruendet werden. |
| M16T-INTERACT-003 | [x] | Wheel ist auf kurze In-place-Auswahl mit Icon + Kurzname begrenzt. |
| M16T-INTERACT-004 | [x] | Showcase-Seiten sind fuer grosse visuelle Auswahl fachlich erlaubt, aber keine Implementierungsfreigabe. |
| M16T-INTERACT-005 | [x] | Drag/Drop wird als Dev-/Layout- oder spaetere Editierfunktion eingeordnet, nicht als Standard-Nutzerflow. |
| M16T-INTERACT-006 | [x] | Unsichere UI-/Spielaufbau-Entscheidungen brauchen vor Umsetzung einen kurzen Benchmark-/Research-Check. |

## 13. Visualisierungen

In diesem Slice wurden keine Preview-Visuals erzeugt. Die Matrix ist textuell
verbindlich dokumentiert. Ein spaeterer Visual-Slice kann optional Diagramme
unter `docs/world_design/previews/m16_ax_interaction_pattern_matrix/`
erzeugen, bleibt aber ebenfalls ohne App-, Route-, Persistenz-, Asset- oder
Codefreigabe.
