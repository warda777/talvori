# M16-O: Word Semantics Preview Implementation Gate

Stand: 2026-06-07

Status: `Implementation Gate gestartet / keine Implementierung`

## 1. Ziel

M16-O prueft, ob ein spaeterer minimaler, isolierter
`WordSemanticsDecisionPreview`-Code-Slice sinnvoll und sicher genug waere.
Dieser Block gibt noch keine Implementierung frei. Er ist nur Gate,
Dokumentation und Visualisierung.

Aus M16-O folgen keine Flutter-/Dart-Dateien, keine App-Integration, keine
Route, keine neue Seite, keine Tests, keine Screenshots, keine Runtime-
Konfiguration, keine Persistenz, keine Assets, keine automatische
Wortplatzierung, kein Build-State, kein `frame_started` und keine
Bauzustaende.

## 2. Gepruefte Grundlage

| Dokument | Bedeutung fuer M16-O |
| --- | --- |
| `docs/world_design/323-word-semantics-decision-preview-scope.md` | Konkretisiert die spaetere Preview-Pipeline und Beispielwort-Karten. |
| `docs/world_design/322-next-safe-preview-slice-decision-gate.md` | Empfiehlt `WordSemanticsDecisionPreview` als sichersten naechsten Kandidaten. |
| `docs/world_design/321-global-world-semantics-consistency-audit.md` | Definiert die Pflichtfilter vor jedem World-/Plot-/Build-/Word-Slice. |
| `docs/world_design/270-word-to-island-routing-matrix.md` | Routing macht Vorschlaege, keine automatische Platzierung. |
| `docs/world_design/272-plot-capability-derivation.md` | Plot-Capabilities sind Erlaubnisse, keine Pflichtbelegung. |
| `docs/world_design/274-sensitive-content-representation-rules.md` | Sensitive/abstract Begriffe brauchen neutrale Fallbacks und Policy Gates. |
| `docs/world_design/276-mobile-clutter-rules-small-objects.md` | Kleine Objekte gehoeren in Depth/Container/Codex/Backlog, nicht automatisch in IslandView. |
| `docs/world_design/284-word-to-island-ux-flow.md` | User Choice, Sense und sichere Ausgaenge stehen vor Placement. |

## 3. Gate-Entscheidung

Gate-Entscheidung:

`spaeterer minimaler isolierter Code-Slice theoretisch moeglich, aber nicht
aus M16-O freigegeben`

Begruendung:

- Der spaetere Slice kann als lokales, isoliertes Preview-Widget ohne
  App-Anschluss gedacht werden.
- Er muss Beispielwoerter erklaeren, nicht echte Routinglogik ausfuehren.
- Er kann M16-L/M16-N sichtbar absichern, bevor neue World-, Plot- oder
  Build-Wheel-Slices entstehen.
- Er darf keinen produktiven Pfad, keine Datenstruktur, keine Persistenz und
  keine automatische Wortplatzierung einfuehren.

Vor Code braucht es weiterhin eine ausdrueckliche Nutzerfreigabe und einen
separaten Implementierungs-Prompt.

## 4. Erlaubter spaeterer Minimal-Scope

Falls spaeter separat freigegeben, waere hoechstens erlaubt:

- eine neue isolierte Preview-Datei unter
  `lib/features/world/local_world/ui/widgets/`,
- Beispielwoerter als lokale Karten,
- lokale Auswahl eines Beispielwortes,
- Anzeige von:
  - Context/Sense,
  - Word Type,
  - Safety/Sensitive,
  - Candidate ThemeIsland(s),
  - Representation Decision,
  - Preview Only / Later Gate,
- lokale States nur in-memory,
- keine Speicherung,
- keine Platzierung,
- kein Bauzustand.

## 5. Blockierter Scope

Aus einem spaeteren Minimal-Slice bleiben blockiert:

- keine echte Routing-Implementierung,
- keine finale Datenstruktur,
- keine App-Integration,
- keine Route,
- keine produktive Navigation,
- keine Persistenz,
- keine Supabase Writes,
- keine lokalen DB-Writes,
- keine automatische Wortplatzierung,
- keine Build-Wheel-Implementierung,
- keine Assets,
- kein Build-State,
- kein `frame_started`.

## 6. Spaetere Datei-Kandidatenstruktur

Nur als Planung, nicht in M16-O erstellen:

| Spaeterer Kandidat | Zweck | Gate-Status |
| --- | --- | --- |
| `lib/features/world/local_world/ui/widgets/word_semantics_decision_preview.dart` | Isoliertes lokales Preview-Widget fuer Beispielwort-Entscheidungen. | Nur nach separater Nutzerfreigabe. |
| `lib/features/world/local_world/ui/widgets/word_semantics_decision_preview_main.dart` | Optionaler lokaler Launch-Target fuer manuelles `flutter run -t`, falls spaeter separat freigegeben. | Nicht Teil von M16-O; eigener Prompt noetig. |

Keine der genannten Dateien wird in M16-O erstellt.

## 7. Beispielwort-Gate-Matrix

| Word | Warum wichtig | Verhindert Fehlableitung | Sicherer Preview-Output | Weiteres Gate |
| --- | --- | --- | --- | --- |
| `Haus` | Multi-Home-Beispiel fuer Zuhause, Stadt, Land/Farm und Kueste/Strand. | Pflicht-Hausstart, automatische Gebaeudeplatzierung, `frame_started`. | Context/Sense + `Blueprint` oder `PlacementCandidate` nur als Preview. | Nutzerkontext, Plot-/Build-Gate. |
| `Garage` | Zeigt Utility-/Parking-/Stadt-Kontext statt nur Zuhause. | Automatische Zuhause-Zuordnung oder Fahrzeuglogik. | ContextCard oder Blueprint-Preview. | Theme-/Vehicle-/Plot-Gate. |
| `Baum` | Naturwort kann Garten, Stadt/Park oder Farm/Obstbaum bedeuten. | Deko-Clutter oder Massendeko in IslandView. | Natur-/Clutter-Hinweis, ggf. Backlog. | Mobile-/Clutter-Gate. |
| `schwimmen` | Verb/Aktion mit Wasser-/Freizeit-Kontext. | Verb als statisches Objekt oder Wasserlogik. | `ActionChallenge` oder `ContextCard`. | Water-/Safety-/Action-Gate. |
| `Angst` | Emotion/sensibles Gefuehl. | Objekt, Deko, Druck oder dramatische Companion-Reaktion. | Companion/ContextCard/Codex. | Sensitive-/UX-Gate. |
| `lernen` | Aktion/Verb mit Schule als Kandidat, aber nicht Pflicht. | Automatisches Schulgebaeude oder Pflichtschule. | Challenge/LearningMode oder Codex. | Learning-/School-Misread-Gate. |
| `Messer` | Kleines Tool/ContainerItem mit Safety-Kontext. | Sichtbares Objekt ohne Safety oder Container. | ContainerItem-Preview oder ContextCard. | Safety-/Container-/Clutter-Gate. |
| `Polizei` | Public Institution und policy-sensibel. | Automatische Polizeiwache, Autoritaetsfantasie oder Bias. | ContextCard, Codex oder BlockedUntilRules. | Policy-/Sensitive-Gate. |

## 8. Dokumentationsvisualisierungen

M16-O ergaenzt echte PNG-Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_o_word_semantics_preview_implementation_gate/`

Erzeugte Visuals:

- `01_implementation_gate_scope_map.png`
- `02_allowed_later_vs_blocked_now.png`
- `03_preview_file_boundary_map.png`
- `04_example_word_guardrail_map.png`
- optional `00_contact_sheet.png`

Diese PNGs sind Dokumentationspreviews. Sie sind keine Screenshots, keine
App-Screens, keine finalen UI-PNGs, keine Spielassets und keine Dateien unter
`assets/`.

Visual-Quality-Regel:

Alle M16-O-Visuals muessen Text-Containment, Innenabstand, Kartenabstand,
ueberlappungsfreie Karten, Labels, Titel, Footer und Legenden, lesbares
Contact Sheet sowie nicht abgeschnittene Inhalte pruefen.

## 9. Stop-Regeln

Aus M16-O folgt ausdruecklich:

- Keine Implementierung.
- Keine Flutter-/Dart-Dateien.
- Keine App-Integration.
- Keine Route.
- Keine neue Seite.
- Keine Tests und keine Widget-Tests.
- Keine Screenshots.
- Keine Runtime-Konfiguration.
- Keine Persistenz.
- Keine Supabase Writes.
- Keine lokalen DB-Writes.
- Keine SRS-/`word_progress`-Aenderung.
- Keine Reward Bridge.
- Keine automatische Wortplatzierung.
- Keine Assets.
- Keine Asset-Dateien unter `assets/`.
- Kein Build-State.
- Kein `frame_started`.
- Keine Bauzustaende.
