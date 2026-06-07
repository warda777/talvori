# M16-N: Word Semantics Decision Preview Scope

Stand: 2026-06-07

Status: `Scope/Visualisierung gestartet / keine Implementierung`

## 1. Ziel

M16-N konkretisiert die M16-M-Empfehlung fuer einen spaeteren lokalen
`WordSemanticsDecisionPreview`-Slice. Ziel ist eine kleine, sichtbare
Entscheidungs-Preview, die verhindert, dass Woerter automatisch gebaut, fest
einer ThemeIsland zugeordnet oder als Bauzustand gelesen werden.

M16-N ist nur Dokumentation und Visualisierung. Daraus folgen keine Flutter-/
Dart-Dateien, keine App-Integration, keine Route, keine neue Seite, keine
Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine
Assets, keine automatische Wortplatzierung, kein Build-State, kein
`frame_started` und keine Bauzustaende.

## 2. Gepruefte Grundlage

| Dokument | Relevanz fuer M16-N |
| --- | --- |
| `docs/world_design/322-next-safe-preview-slice-decision-gate.md` | Empfiehlt `WordSemanticsDecisionPreview` als sichersten naechsten Preview-Kandidaten. |
| `docs/world_design/321-global-world-semantics-consistency-audit.md` | Definiert Pflichtpipeline: Context/Sense, Word-Type, Safety, Theme, Representation Decision, User Choice, Preview Only, Later Gate. |
| `docs/world_design/270-word-to-island-routing-matrix.md` | Routing macht Vorschlaege, platziert nichts automatisch; Codex, Blueprint und Backlog bleiben sichere Ausgaenge. |
| `docs/world_design/272-plot-capability-derivation.md` | Plot-Capabilities sind Erlaubnisse, keine Pflichtbelegung oder automatische Bauentscheidung. |
| `docs/world_design/274-sensitive-content-representation-rules.md` | Sensitive/abstract Begriffe brauchen neutrale Wege wie Codex, ContextCard, CompanionDialog, Backlog oder RequiresUserChoice. |
| `docs/world_design/276-mobile-clutter-rules-small-objects.md` | Kleine Objekte und ContainerItems duerfen nicht automatisch in der IslandView erscheinen. |
| `docs/world_design/283-theme-island-capability-sheets.md` | Kategorien haben unterschiedliche Worttypen, Depth-Wege, Gates und Stop-Regeln. |
| `docs/world_design/284-word-to-island-ux-flow.md` | User Choice, Sense-Klaerung und sichere Fallbacks stehen vor sichtbarer Platzierung. |

## 3. Preview-Pipeline

Pflichtpipeline fuer die spaetere Preview:

```text
Word / User Intent
-> Context / Sense Check
-> Word Type
-> Safety / Sensitive Check
-> Candidate ThemeIsland(s)
-> Candidate Plot / Depth
-> Representation Decision
-> User Choice
-> Preview Only
-> Later Gate
```

Kernregeln:

- Nicht jedes Wort wird gebaut.
- Nicht jedes Wort bekommt ein Grundstueck.
- Nicht jedes Wort gehoert nur zu einer Kategorie.
- Kein Wort wird automatisch platziert.
- Eine ThemeIsland-Kategorie ist ein Kandidat, keine Verpflichtung.
- Ein Plot ist eine Moeglichkeit, keine automatische Belegung.
- `Blueprint`, `Codex`, `Backlog`, `ContextCard`, `ActionChallenge` und
  `ContainerItem` sind legitime Ausgaenge, nicht Fehlerfaelle.
- `Preview Only` ist kein Build-State und kein `frame_started`.

## 4. Beispielwort-Karten

| Word | Sense / Category Candidates | Word Type / Risk | Preview Decision |
| --- | --- | --- | --- |
| `Haus` | Zuhause/Alltag, Stadt, Land/Farm, Kueste/Strand | Multi-Home, BuildingCandidate | Kontext oder Nutzerwahl noetig; kein Pflicht-Hausstart, kein `frame_started`. |
| `Garage` | Zuhause/Dorf, Verkehr/Fahrzeuge, Stadt | Utility, Vehicle/Parking-Kontext | Nicht automatisch Zuhause; Plot-/Kategoriefrage offen lassen. |
| `Baum` | Garten/Natur, Stadt/Park, Farm/Obstbaum | Natural object, Deko-/Clutter-Risiko | Natur-/Deko-/Clutter-Gate; nicht als Massendeko in IslandView. |
| `schwimmen` | Wasser/Freizeit, Kueste/Meer, Sport | Aktion/Verb, Water-Safety | `ActionChallenge` oder `ContextCard`; kein Gebaeude. |
| `Angst` | Emotion/Gefuehl, Companion, Codex | Sensitive/Emotion | `CompanionDialog`, `ContextCard` oder `Codex`; kein Objekt, kein Druck. |
| `lernen` | Aktion/Verb, Schule moeglich, LearningMode | Aktion, nicht automatisch Schulgebaeude | Challenge/LearningMode oder Codex; Schule nur nach Kontext. |
| `Messer` | Kueche, Tool, ContainerItem | Safety/Context, kleines Objekt | Safety-/Context-Gate; moeglich als ContainerItem, nicht frei sichtbar. |
| `Polizei` | Public Institution, Verwaltung, Sicherheit | Sensitive/Policy | Policy Gate; keine automatische Polizeiwache oder Autoritaetsfantasie. |

## 5. Erlaubter spaeterer Minimal-Code-Scope

Ein spaeterer `WordSemanticsDecisionPreview`-Slice duerfte hoechstens:

- lokal und isoliert sein,
- Beispielwoerter als Karten zeigen,
- lokale Auswahl eines Beispielwortes erlauben,
- Context/Sense, Word-Type, Safety und Representation Decision anzeigen,
- moegliche Ausgaenge zeigen:
  - `PlacementCandidate`,
  - `Blueprint`,
  - `Codex`,
  - `Backlog`,
  - `ContextCard`,
  - `ActionChallenge`,
  - `ContainerItem`,
- klar sagen:
  - keine Speicherung,
  - keine Platzierung,
  - kein Bauzustand.

Nicht erlaubt:

- keine echte Routing-Implementierung,
- keine finale Datenstruktur,
- keine App-Integration,
- keine Route,
- keine Persistenz,
- keine automatische Wortplatzierung,
- keine Build-Wheel-Implementierung,
- keine Assets,
- kein Build-State,
- kein `frame_started`.

## 6. Dokumentationsvisualisierungen

M16-N ergaenzt echte PNG-Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_n_word_semantics_decision_preview_scope/`

Erzeugte Visuals:

- `01_word_semantics_preview_pipeline.png`
- `02_example_word_decision_cards.png`
- `03_representation_outputs_map.png`
- `04_allowed_vs_blocked_word_semantics_scope.png`
- optional `00_contact_sheet.png`

Diese PNGs sind Dokumentationspreviews. Sie sind keine App-Screens, keine
Screenshots, keine finalen UI-PNGs, keine Spielassets und keine Dateien unter
`assets/`.

Visual-Quality-Regel:

Alle M16-N-Visuals muessen Text-Containment, ausreichenden Innenabstand,
Abstand zwischen Karten, ueberlappungsfreie Karten, Labels, Pfeile, Titel,
Footer und Legenden, ein lesbares Contact Sheet sowie nicht abgeschnittene
Inhalte pruefen.

## 7. Entscheidung fuer den naechsten Schritt

M16-N gibt noch keine Implementierung frei. Es macht nur den spaeteren lokalen
Preview-Scope greifbarer. Wenn ein Code-Slice danach gewuenscht ist, braucht
es eine ausdrueckliche Nutzerfreigabe fuer einen minimalen, isolierten
Preview-Slice. Dieser spaetere Slice darf weiterhin keine produktive Route,
keine App-Integration, keine Persistenz, keine automatische Wortplatzierung,
keine Assets, keinen Build-State und kein `frame_started` erzeugen.

## 8. Stop-Regeln

Aus M16-N folgt ausdruecklich:

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
