# M16-AC: Mobile Density and Accessibility Planning Gate

Stand: 2026-06-08

Status: `Dokumentations-/Visual-Slice gestartet / keine Implementierung`

## 1. Zweck und Non-Goals

M16-AC definiert, wie Talvori spaetere MVP-Screens, World-Previews,
Review-Karten, Companion-Hinweise und Container-/Depth-Inhalte auf mobilen
Geraeten lesbar, bedienbar und nicht ueberladen haelt. Der Slice verbindet die
M16-V bis M16-AB-Gates mit den frueheren Mobile-Clutter- und Container-Flow-
Regeln.

M16-AC gibt keine Implementierung frei.

Non-Goals:

- keine Implementierung,
- keine Flutter-/Dart-Codeaenderung,
- keine App-Integration,
- keine Route,
- keine neue Seite,
- keine Tests oder Widget-Tests,
- keine Screenshots als Repo-Artefakte,
- keine Persistenz,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- kein Build-State,
- kein Build-Wheel-Code,
- keine Assets und keine Asset-Dateien unter `assets/`,
- kein `frame_started`,
- keine Bauzustaende.

## 2. Gepruefte Grundlage

| Dokument | Bedeutung fuer M16-AC |
| --- | --- |
| `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrendes M16-T-Backlog und Dashboard. |
| `docs/world_design/336-documentation-map-and-slice-reading-rules.md` | Pflichtlektuere- und Slice-Regeln fuer Mobile/Container/Visual-Dokumentation. |
| `docs/world_design/330-minimal-playable-learning-loop-contract.md` | Lernen erzeugt Moeglichkeit, keine Platzierung; UI-Events schreiben keinen Fortschritt. |
| `docs/world_design/331-minimal-word-outcome-detail-gate.md` | `ContainerItem`, `ContextCard`, `SensitiveGated` und `NeedsUserChoice` brauchen lesbare UI-Grenzen. |
| `docs/world_design/332-reward-budget-and-review-queue-control-gate.md` | Review-Queue und Weltvorschlaege bleiben budgetiert, Later bleibt erreichbar. |
| `docs/world_design/333-minimal-semantic-profile-and-routing-priority-gate.md` | Clutter/Mobile gewinnt vor sichtbarer Weltreaktion. |
| `docs/world_design/334-companion-and-sensitive-return-safety-gate.md` | Companion-Hinweise bleiben kurz, optional und nicht ueberdeckend. |
| `docs/world_design/335-learning-states-and-srs-boundary-gate.md` | Review und Weltfeedback duerfen Lernzustand/SRS nicht aus UI-Interaktion mutieren. |
| `docs/world_design/276-mobile-clutter-rules-small-objects.md` | TinyObjects gehoeren in Depth/Container/Codex/Backlog, nicht dauerhaft in IslandView. |
| `docs/world_design/277-mobile-clutter-visual-review.md` | M12-E-Regeln sind brauchbar, aber echte Device-/Accessibility-Pruefung bleibt offen. |
| `docs/world_design/256-depth-container-user-flow-preview-plan.md` | Depth/Container-Flow: Bereich -> Container -> kleine Challenge -> Feedback. |
| `docs/world_design/264-multi-example-container-flow-previews.md` | Schule, Hafen und Garten zeigen, dass Container/Focus-Zonen je Thema unterschiedlich funktionieren. |

## 3. Betroffene M16-T-IDs

| ID | M16-AC Entscheidung | Grund |
| --- | --- | --- |
| `M16T-MOBILE-001` | `[x]` | Mobile-Dichtebudgets sind als Planungswerte fuer Reviews, Companion, World-Vorschlaege, Labels und TinyObjects definiert. |
| `M16T-MOBILE-002` | `[x]` | Landmarken-vor-Kleinteilen-Regel ist verbindlich dokumentiert. |
| `M16T-MOBILE-003` | `[x]` | Text-/Overlay-Regeln fuer Review-Karten, Companion-Bubbles, ContextCards, Sensitive-Hinweise, Labels und Footer sind dokumentiert. |
| `M16T-MOBILE-004` | `[x]` | Accessibility-Gate fuer Schrift, Kontrast, Tap-Ziele, Semantics, Motion, Farbe, Fehler und Einhandbedienung ist definiert. |
| `M16T-DEPTH-001` | `[x]` | Container-/Depth-Modell mit Level 0 bis 4 ist fachlich definiert. |
| `M16T-DEPTH-002` | `[x]` | Suchbarkeit verschachtelter Objekte ueber Codex, Backlog, Container-Pfad, Tali/Vori und Review Queue ist dokumentiert. |

## 4. Mobile-Dichtebudgets

Die folgenden Werte sind Planungsannahmen fuer spaetere MVP-Screens. Sie sind
keine finale UI-Spezifikation, keine Runtime-Konfiguration und keine
Implementierungsfreigabe.

| Bereich | Planungsbudget fuer kleine Mobile-Ansicht | Muss erreichbar bleiben | Blockiert |
| --- | --- | --- | --- |
| Review-Karten | 0 bis 3 aktive Entscheidungen pro Session, maximal 1 dominante Karte pro Screen | `Later`, `Codex`, `Backlog`, `Change` | Review-Stapel, Pflichtentscheidung, 20.000-Wort-Inbox |
| Companion-Hinweise | 0 bis 1 aktiver Hinweis, kurz und wegklickbar | Close/Later, Lerninhalt, Hauptaktion | Dauerbubble, Textblock ueber Inhalt, Drucksprache |
| World-Vorschlaege | 0 bis 2 aktive Vorschlaege pro Session, visuell klar getrennt | Abwaehlen, Later, keine Platzierung | Vorschlag nach jedem Wort, Auto-Placement |
| World-/Island-Labels | 0 bis 3 permanente/fokussierte Labels, weitere nur bei Fokus oder A11y-Modus | Orientierung, Tap-Ziele | Labelwolke, Debuglabels als Nutzeransicht |
| TinyObject-/Container-Hinweise | 0 bis 2 Hinweise auf Overview-Ebene, 3 bis 5 Fokusobjekte im Container | Container-Pfad, Codex/Backlog | Minipixel, Objektwolke, Container als Inventarliste |
| Mindestabstand Karten | mindestens 12 bis 16 px als Planungswert | Lesbarkeit und Fingerabstand | Karten kleben aneinander |
| Touch-Ziele | mindestens 44 x 44 pt als Planungswert, groesser fuer wichtige Ziele | Close, Later, Primary, Deselect | winzige Chips, nicht erreichbare Exit-Aktion |
| Textlesbarkeit | keine Textwuesete; kurze Zeilen, klare Hierarchie, skalierbare Schrift | Dynamic Type/A11y spaeter | abgeschnittene Labels, kleiner grauer Pflichttext |

Regel:

Wenn ein Screen mehr Inhalte braucht, muss er in Tiefe, Pagination, Filter,
Codex, Backlog oder eine spaetere Review-Queue ausweichen. Mehr Inhalt auf
gleicher Ebene ist nicht die sichere Loesung.

## 5. Landmarken-vor-Kleinteilen-Regel

Talvori muss auf Mobile zuerst Orientierung geben.

Reihenfolge:

1. grosse Orientierungspunkte,
2. ThemeIsland/Region/Plot-Familie,
3. Plot, Area oder fokussierte Zone,
4. Container/Depth,
5. Detail/Codex/ContextCard.

Pflichtregeln:

- Erst Landmarken, dann Details.
- Plot-/Bereichsebene vor Einzelobjekten.
- Container/Depth vor TinyObject-Sichtbarkeit.
- TinyObjects nie direkt in IslandView als Massenobjekte.
- Weltuebersicht darf nicht zur Objektwolke werden.
- Deko bleibt ruhiger Hintergrund und verdeckt keine Lernobjekte.
- Bei Clutter gewinnt Codex, Backlog, Container oder ContextCard gegen
  sichtbare Platzierung.

## 6. Text-/Overlay-Regeln

| Overlay-Typ | Erlaubt | Blockiert |
| --- | --- | --- |
| Review-Karte | eine klare Frage, wenige Ausgaenge, `Later` sichtbar | Stapel, Pflichtreview, verdeckte Hauptinteraktion |
| Companion-Bubble | kurz, optional, wegklickbar, nicht nach jedem Wort | Dauer-Overlay, Schuld, Beratung, sensitive Trigger |
| ContextCard | knappe Erklaerung, Sense-Hilfe, optionaler Codex/Backlog-Ausgang | Symbolzwang, Textwueste, Modal ohne Exit |
| SensitiveGated-Hinweis | neutral, ruhig, `Later`/`Hide`/`Codex` moeglich | Drama, Reward, Push, Pflichtentscheidung |
| Later/Codex/Backlog-Ausgaenge | jederzeit erreichbar und nicht versteckt | Sackgassen-UI, Verlustwarnung |
| Footer/Legende/Labels | klein, lesbar, nicht ueber Inhalt | Footer ueber Karten, Labelwolken |

Zusaetzliche Regeln:

- Keine ueberdeckenden Dauer-Overlays.
- Keine Textwueseten.
- Close, Later oder Deselect muss erreichbar bleiben.
- Overlays duerfen Tap-Ziele nicht verdecken.
- Companion-Hinweis und Review-Karte duerfen nicht gleichzeitig um Aufmerksamkeit
  kaempfen, ausser ein spaeteres A11y-/Interaction-Gate das prueft.

## 7. Accessibility Gate

Vor produktiver UI braucht jeder relevante MVP-Screen ein eigenes
Accessibility-/Device-Gate. M16-AC definiert nur die spaeteren Pruefpflichten.

| Prueffeld | Spaetere Pflicht |
| --- | --- |
| Schriftgroesse | Texte bleiben bei kleineren und groesseren Schriftgroessen lesbar, ohne Karten zu sprengen. |
| Kontrast | Text, Buttons, Badges, Labels und deaktivierte Zustaende brauchen ausreichenden Kontrast. |
| Tap-Ziele | Hauptaktionen, Close, Later, Deselect und Container-Ziele bleiben fingerfreundlich. |
| Screenreader / Semantics | Review, Companion, ContextCard, Container und Exit-Aktionen brauchen sinnvolle Semantics. |
| Motion / Animation reduzieren | Puls, Glow, Wheel, World-Feedback und Companion-Bewegung muessen reduzierbar sein. |
| Farbunabhaengigkeit | Status darf nicht nur durch Farbe kommuniziert werden. |
| Fehlertoleranz | Fehler, falscher Tap, Review ignorieren oder Later duerfen keine Strafe erzeugen. |
| Einhandbedienung | Wichtigste Aktionen sollten auf kleinen Phones mit einer Hand erreichbar geplant werden. |

## 8. Container-/Depth-Modell

Das folgende Modell ist fachlich, nicht technisch. Es ist keine Datenstruktur,
kein Routing, keine Persistenz und kein Build-State.

| Level | Ebene | Zweck | Beispiele | Grenzen |
| --- | --- | --- | --- | --- |
| Level 0 | World/Island overview | grobe Orientierung und wenige aktive Hinweise | Insel, grosse Landmarken, 0-2 Vorschlaege | keine TinyObject-Masse, keine Labelwolke |
| Level 1 | ThemeIsland/Region/Plot family | thematische Zone und grobe Funktion | Schule, Garten, Hafen, Zuhause | keine feste Gebaeudeliste als Pflicht |
| Level 2 | Plot/Building/Area | fokussierter Lern- oder Weltbereich | Haus, Garage, Baumzone, Beet, Schreibtischbereich | kein Build-State, kein `frame_started` |
| Level 3 | Room/Zone/Container | kleine Objekte gezielt sichtbar machen | Schublade, Federmappe, Kiste, Beet, Navigationskiste | kein Inventar-Dump |
| Level 4 | Detail/Codex/ContextCard | Bedeutung, Sense, Objektgruppe oder Detail erklaeren | Codex, ContextCard, DetailInteraction | keine versteckte Pflichtentscheidung |

Pflichtregeln:

- Container/Depth ist kein Build-State.
- Container/Depth erzeugt keine Persistenz.
- Container/Depth ist zunaechst nur Fachmodell.
- Kleine Objekte muessen auffindbar bleiben.
- Ein Container ist ein Fokusraum, keine Objektliste.
- Ein Detail ist ein Lern-/Erklaerraum, keine automatische Platzierung.

## 9. Suchbarkeit verschachtelter Objekte

Kleine oder verschachtelte Lernobjekte duerfen nicht unsichtbar verloren gehen.

Erlaubte Auffindbarkeit:

- Codex-Verweis,
- Backlog-Verweis,
- spaeterer Container-Pfad, z. B. `Schule -> Tisch -> Federmappe -> Stifte`,
- Tali/Vori-Erklaerung, kurz und optional,
- Review-Queue-Verweis, wenn Budget und Risiko passen,
- ContextCard mit Sense-/Container-Hinweis.

Nicht erlaubt:

- unsichtbare Lernobjekte ohne Auffindbarkeit,
- versteckte Platzierung ohne Nutzerentscheidung,
- Container als 20-Objekte-Liste,
- TinyObjects als dauerhafte IslandView-Masse,
- Persistenz oder Datenpfad ohne eigenes Gate,
- Suchfunktion oder Filter-Implementierung aus M16-AC ableiten.

## 10. Beispiele

| Beispiel | Sicherer Mobile-/Depth-Ausgang | Warum | Blockiert |
| --- | --- | --- | --- |
| `Schluessel` | `ContainerItem`, Codex, Backlog, spaeter Container-Pfad | TinyObject; sonst Minipixel/Clutter | IslandView-Dauerobjekt, eigener Plot |
| `Messer` | `ContainerItem` plus Safety/Context, Codex oder SensitiveGated | kleines Tool mit Safety-Risiko | sichtbares Tool ohne Gate |
| `Loeffel` | Kueche -> Schublade -> Besteck, 3-5 Fokusobjekte | passt in Container-Challenge | 20 Besteckteile gleichzeitig |
| `Baum` | Landmarke oder WorldCandidate mit Clutter-Gate | gross genug, aber Deko-Masse riskant | Baumwolke als Reward |
| `Haus` | Landmarke/PlotCandidate nach Sense/User Choice | Orientierungspunkt, multi-home | Pflicht-Hausstart |
| `Garage` | Plot/Area nach User Choice, nicht automatisch Zuhause | Utility/Verkehr/Stadt moeglich | Auto-Zuhause, Fahrzeuglogik ohne Gate |
| `Angst` | `SensitiveGated`, ContextCard, Codex, Hide/Later | Emotion; kein Objektzwang | Symbol/Reward/Druck |
| `Polizei` | `SensitiveGated`, ContextCard, Codex, Later/Hide | Institution; Policy-Gate | Polizeiwache als Default |
| `schwimmen` | `ActionChallenge` oder ContextCard | Aktion/Wasser-Safety | Gebaeude, Wasserlogik ohne Gate |
| `lernen` | `ActionChallenge`, CodexOnly oder ContextCard | Verb/LearningMode | automatisches Schulgebaeude |
| 10 Review-Kandidaten | 0-3 zeigen, Rest Later/Backlog/Codex | Queue-Budget schuetzt Fokus | Massenreview |
| 100 importierte Woerter | Profiling/Safe Defaults, wenige Top-Fragen | kein Import-zu-UI-Sturm | 100 Karten oder Inselobjekte |
| kleine iPhone-Ansicht | ein Fokus, wenige Labels, Close/Later erreichbar | begrenzte Flaeche | ueberdeckte Exit-Aktion |

## 11. Gates vor Umsetzung

M16-AC klaert Mobile-/Depth-Planung, aber nicht die Umsetzung. Spaeter braucht
Talvori eigene Gates fuer:

- echte Device-Previews,
- Accessibility-Pruefung,
- Semantics/Screenreader-Plan,
- Tap-Target- und Layout-Tests,
- Motion-Reduce-Regeln,
- Container-/Depth-Architektur,
- Such-/Codex-/Backlog-Datenmodell,
- Undo/Reversibility,
- Persistenz,
- App-Integration,
- Tests,
- Performance,
- keine automatische Platzierung.

## 12. Dokumentationsvisualisierungen

M16-AC erzeugt Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_ac_mobile_density_accessibility/`

Visuals:

- `mobile_density_budget.png`
- `landmark_to_detail_hierarchy.png`
- `overlay_rules_mobile.png`
- `accessibility_gate_checklist.png`
- `depth_container_levels.png`
- `nested_object_findability_flow.png`
- optional `00_contact_sheet.png`

Diese PNGs sind Dokumentationsmaterial, keine App-Screens, keine Screenshots,
keine Spielassets und keine Dateien unter `assets/`.

Visual-QA:

- Text bleibt in Karten/Rahmen/Panels.
- Ausreichender Innenabstand.
- Kartenabstaende.
- Keine Ueberlappung von Karten, Labels, Pfeilen, Titeln, Footern oder
  Legenden.
- Contact Sheet vollstaendig lesbar, falls erzeugt.
- Keine abgeschnittenen Inhalte.

## 13. Stop-Regeln

Aus M16-AC folgt ausdruecklich:

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
