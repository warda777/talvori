# M16-W: Minimal Word Outcome Detail Gate

Stand: 2026-06-08

Status: `Dokumentations-/Visual-Slice gestartet / keine Implementierung`

## 1. Zweck und Non-Goals

M16-W konkretisiert die Minimal Word Outcome Taxonomy aus M16-V. Fuer jedes
Outcome wird festgelegt, wann es verwendet wird, welche Beispiele passen,
welche UI-/Weltreaktionen im MVP erlaubt sind, welche Reaktionen blockiert
bleiben und welche Review-Queue-Ausgaenge moeglich sind.

M16-W ist ein Detail-Gate. Es gibt keine Implementierung frei.

Non-Goals:

- keine Implementierung,
- keine finale Datenstruktur,
- keine App-Integration,
- keine Route,
- keine neue Seite,
- keine automatische Wortplatzierung,
- keine Persistenz,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- kein Build-State,
- kein Build-Wheel,
- keine Assets und keine Asset-Dateien unter `assets/`,
- kein `frame_started`,
- keine Bauzustaende,
- keine Tests oder Widget-Tests,
- keine Screenshots als Repo-Artefakte.

## 2. Gepruefte Grundlage

| Dokument | Bedeutung fuer M16-W |
| --- | --- |
| `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrende M16-T-ID- und Dashboard-Liste. |
| `docs/world_design/330-minimal-playable-learning-loop-contract.md` | Minimaler Learning-to-World Contract und MVP-Taxonomy. |
| `docs/world_design/327-talvori-learning-game-logic-readiness-review.md` | Readiness Review: starke Basis, produktive Systeme bleiben gated. |
| `docs/world_design/326-scalable-word-semantics-architecture-plan.md` | Viele Woerter brauchen Profile/Queues/Fallbacks, nicht viele Weltobjekte. |
| `docs/world_design/323-word-semantics-decision-preview-scope.md` | Beispielwoerter und sichere Representation Decisions. |
| `docs/world_design/321-global-world-semantics-consistency-audit.md` | Pflichtpipeline von Sense/Word-Type/Safety bis User Choice/Later Gate. |
| `docs/world_design/284-word-to-island-ux-flow.md` | Word-to-Island endet in Placement, Blueprint, Codex oder Backlog, nie automatisch. |
| `docs/world_design/274-sensitive-content-representation-rules.md` | Sensitive/abstract Inhalte bevorzugen Codex, ContextCard, Backlog oder User Choice. |
| `docs/world_design/276-mobile-clutter-rules-small-objects.md` | TinyObjects und ContainerItems muessen Clutter/Depth-Regeln respektieren. |

## 3. Betroffene M16-T-IDs

| ID | M16-W Entscheidung | Grund |
| --- | --- | --- |
| `M16T-WOT-002` | `[x]` | `CodexOnly` ist mit Kriterien, Beispielen, UI-Regeln und Grenzen dokumentiert. |
| `M16T-WOT-003` | `[x]` | `WorldCandidate` ist als Vorschlag mit User Choice und Gate definiert. |
| `M16T-WOT-004` | `[x]` | `ContainerItem` ist gegen TinyObject-/IslandView-Clutter abgegrenzt. |
| `M16T-WOT-005` | `[x]` | `ActionChallenge` trennt Aktionen/Verben von statischen Objekten. |
| `M16T-WOT-006` | `[x]` | `ContextCard` ist als Erklaer- und Sense-Ausgang definiert. |
| `M16T-WOT-007` | `[x]` | `SensitiveGated` ist mit Policy-/Opt-in-/Neutralitaetsgrenzen dokumentiert. |
| `M16T-WOT-008` | `[x]` | `NeedsUserChoice` ist fuer Multi-Home, Unsicherheit und Queue-Ausgang definiert. |
| `M16T-QUEUE-003` | `[x]` | Queue-Ausgaenge `Later`, `Codex`, `Backlog`, `Confirm`, `Change`, `Hide` sind dokumentiert. |
| `M16T-REWARD-003` | `[x]` | Reward, Vorschlag, PlacementCandidate und BuildState sind begrifflich getrennt. |

## 4. Outcome-Definitionen

### 4.1 `CodexOnly`

| Feld | Regel |
| --- | --- |
| Kurzdefinition | Wort bleibt im Lern-/Erklaerraum, ohne sichtbares Weltobjekt oder Plot. |
| Wann verwenden | Abstrakte, sensible, digitale, kontextarme oder nicht sinnvoll visualisierbare Woerter. |
| Typische Beispiele | `Freiheit`, `Angst`, `Gerechtigkeit`, digitale Begriffe, unklare Fachwoerter. |
| Gegenbeispiele | Klarer, ungefaehrlicher, groesserer Weltgegenstand mit Kontext und User Choice. |
| Erlaubte UI-/Weltreaktion im MVP | Codex-Eintrag, kurze Erklaerung, Lernhinweis, optionaler Tali/Vori-Kommentar. |
| Blockierte Reaktionen | Objekt, Gebaeude, Plot, Asset, Build-State, `frame_started`, Reward-Druck. |
| Erlaubte Queue-Ausgaenge | `Codex`, `Later`, `Backlog`, `Hide`, bei spaeterem Kontext `Change`. |
| Beziehung zu Reward | Darf ein ruhiges Lernsignal haben, aber kein Weltobjekt als Belohnung. |
| Beziehung zu Tali/Vori | Darf neutral erklaeren und "nur Codex" bestaetigen. |
| Beziehung zu spaeterer Persistenz | Spaetere Speicherung braucht eigenes Daten-/Privacy-Gate. |
| Offene Gates | Codex-Datenmodell, Privacy, Tali/Vori-Copy, Accessibility. |

### 4.2 `WorldCandidate`

| Feld | Regel |
| --- | --- |
| Kurzdefinition | Wort koennte spaeter eine sichtbare Weltmoeglichkeit werden, bleibt aber Candidate. |
| Wann verwenden | Konkrete, groessere, nicht sensitive Begriffe mit plausibler ThemeIsland/Plot-Familie. |
| Typische Beispiele | `Haus`, `Baum`, `Garage`, `Garten` nach Kontext und Clutter-Pruefung. |
| Gegenbeispiele | Sensitive Begriffe, Verben, TinyObjects, abstrakte Begriffe, unsicherer Sense. |
| Erlaubte UI-/Weltreaktion im MVP | Vorschlagskarte, Preview-Label, Review-Queue-Karte, spaeter aenderbar. |
| Blockierte Reaktionen | automatische Platzierung, Bauausfuehrung, Build-Wheel-Code, `frame_started`, Asset. |
| Erlaubte Queue-Ausgaenge | `Confirm`, `Change`, `Later`, `Backlog`, `Codex`. |
| Beziehung zu Reward | Reward darf Candidate sichtbar vorschlagen, aber nicht platzieren. |
| Beziehung zu Tali/Vori | Darf "koennte passen" sagen, nie "wird gebaut". |
| Beziehung zu spaeterer Persistenz | Bestaetigung bleibt ohne Persistenz, bis Persistence-/Undo-Gate existiert. |
| Offene Gates | ThemeIsland/Plot-Capacity, PlacementCandidate, Undo, Persistenz, Asset Scope. |

### 4.3 `ContainerItem`

| Feld | Regel |
| --- | --- |
| Kurzdefinition | Kleines oder verschachteltes Objekt gehoert eher in Container/Depth als in IslandView. |
| Wann verwenden | TinyObjects, kleine Werkzeuge, Schluessel, Besteck, Stifte, Samen, kleine Safety-Objekte. |
| Typische Beispiele | `Schluessel`, `Messer`, `Bleistift`, `Loeffel`, `Samen`. |
| Gegenbeispiele | Grosser Plot-/Landmarkenbegriff wie `Haus`, `Garten`, `Hafen`. |
| Erlaubte UI-/Weltreaktion im MVP | Hinweis "passt spaeter in Container/Depth", Codex/Backlog, keine Aussenplatzierung. |
| Blockierte Reaktionen | dauerhaftes TinyObject in IslandView, Kleinteil-Wolke, Asset-Produktion, Build-State. |
| Erlaubte Queue-Ausgaenge | `Backlog`, `Codex`, `Later`, `Change`, bei sicherem Kontext spaeter `Confirm`. |
| Beziehung zu Reward | Kann Lernsignal geben, aber kein kleines sichtbares Objekt als Reward streuen. |
| Beziehung zu Tali/Vori | Darf Container/Depth ruhig erklaeren und Clutter vermeiden. |
| Beziehung zu spaeterer Persistenz | Container-Zuordnung braucht Depth-/Datenmodell-/Undo-Gate. |
| Offene Gates | Container/Depth-Modell, Mobile-Clutter, Accessibility, SensitiveSmallObject. |

### 4.4 `ActionChallenge`

| Feld | Regel |
| --- | --- |
| Kurzdefinition | Verb oder Aktion wird als Aufgabe, Sequenz, Kontext oder Challenge gedacht. |
| Wann verwenden | Verben, Taetigkeiten, Bewegungen oder Lernhandlungen. |
| Typische Beispiele | `schwimmen`, `lernen`, `kochen`, `reisen`, `reparieren`. |
| Gegenbeispiele | Konkreter Ort/Gegenstand mit klarer statischer Repräsentation und User Choice. |
| Erlaubte UI-/Weltreaktion im MVP | Vorschlag "spaetere Aufgabe", ContextCard, Codex, Backlog. |
| Blockierte Reaktionen | Verb als Objekt/Gebaeude, automatische Quest, Reward-Zwang, Build-State. |
| Erlaubte Queue-Ausgaenge | `Later`, `Codex`, `Backlog`, `Change`, optional `Confirm` als Preview-Idee. |
| Beziehung zu Reward | Reward darf Motivation signalisieren, aber keine Pflicht-Challenge starten. |
| Beziehung zu Tali/Vori | Darf erklaeren, dass es eher eine Aktion als ein Ding ist. |
| Beziehung zu spaeterer Persistenz | Challenge-/Quest-Persistenz braucht eigenes Gate. |
| Offene Gates | Gameplay Pillars, Quest-/Challenge-Loop, Water/Safety bei Aktionen wie schwimmen. |

### 4.5 `ContextCard`

| Feld | Regel |
| --- | --- |
| Kurzdefinition | Wort bekommt Kontext, Sense oder Erklaerraum, ohne Weltobjektzwang. |
| Wann verwenden | Mehrdeutige, abstrakte, sensitive, kontextarme oder erklaerbeduerftige Woerter. |
| Typische Beispiele | `Freiheit`, `Polizei`, `Bank`, `Angst`, Satzbeispiele. |
| Gegenbeispiele | Eindeutiger, sicherer Candidate, der ohne Zusatzkontext verstanden wird. |
| Erlaubte UI-/Weltreaktion im MVP | kurze Kontextkarte, Sense-Frage, Beispiel, neutrale Erklaerung. |
| Blockierte Reaktionen | Symbolpflicht, Gebaeude, Asset, dramatischer Companion-Text, Placement. |
| Erlaubte Queue-Ausgaenge | `Change`, `Codex`, `Later`, `Backlog`, `Hide`; spaeter `Confirm` nach Klarheit. |
| Beziehung zu Reward | Kann als Lernfeedback erscheinen, nicht als Belohnungsobjekt. |
| Beziehung zu Tali/Vori | Darf kurz und optional mitsprechen, ohne Entscheidung zu erzwingen. |
| Beziehung zu spaeterer Persistenz | Speichern von Kontext/Sense braucht Privacy-/Datenmodell-Gate. |
| Offene Gates | ContextCard-UI, Privacy, Companion-Copy, Review Queue. |

### 4.6 `SensitiveGated`

| Feld | Regel |
| --- | --- |
| Kurzdefinition | Sensitive, persoenliche oder gesellschaftlich heikle Inhalte bleiben policy-gated. |
| Wann verwenden | Gesundheit, Polizei, Gericht, Religion, Politik, Gewalt, Krise, Medikamente, Emotionen mit Risiko. |
| Typische Beispiele | `Polizei`, `Angst`, `Krieg`, `Medikament`, `Tod`, `Religion`. |
| Gegenbeispiele | Nicht-sensitive Alltagsbegriffe mit klarem Kontext und geringem Clutter-Risiko. |
| Erlaubte UI-/Weltreaktion im MVP | neutraler Codex, ContextCard, Backlog, Opt-in/Later, ruhiger Tali/Vori-Hinweis. |
| Blockierte Reaktionen | Gebaeude, Symbol, Reward, Druck, Drama, Retention-Trigger, Asset. |
| Erlaubte Queue-Ausgaenge | `Later`, `Codex`, `Backlog`, `Hide`, `Change`; `Confirm` nur fuer neutralen Fallback. |
| Beziehung zu Reward | Sensitive Inhalte duerfen nie Reward/Deko/Retention-Trigger sein. |
| Beziehung zu Tali/Vori | Neutral, optional, keine Beratung, keine Schuld, kein Drama. |
| Beziehung zu spaeterer Persistenz | Sensitive Speicherung braucht Privacy, Opt-in, Datenmodell und Policy-Gate. |
| Offene Gates | Sensitive Review, Privacy, Age/Family Mode, Companion Safety, Asset Safety. |

### 4.7 `NeedsUserChoice`

| Feld | Regel |
| --- | --- |
| Kurzdefinition | Bedeutung, Kategorie, Sense oder Representation ist unklar und braucht Nutzerentscheidung. |
| Wann verwenden | Multi-Home-Woerter, niedrige Confidence, fehlender Kontext, mehrere plausible Outcomes. |
| Typische Beispiele | `Haus`, `Garage`, `Baum`, `Bank`, `Schluessel` ohne Kontext. |
| Gegenbeispiele | Eindeutige CodexOnly-Faelle oder klar sensitive Inhalte, die direkt gated werden. |
| Erlaubte UI-/Weltreaktion im MVP | kleine Review-Queue-Karte mit wenigen Optionen und "spaeter". |
| Blockierte Reaktionen | Default-Kategorie als finale Platzierung, automatische Island/Plot-Auswahl, Build-State. |
| Erlaubte Queue-Ausgaenge | `Later`, `Change`, `Codex`, `Backlog`, `Confirm`, `Hide`. |
| Beziehung zu Reward | Reward darf Entscheidung nicht erzwingen oder als Pflichtarbeit verkaufen. |
| Beziehung zu Tali/Vori | Darf Frage stellen und Optionen erklaeren, entscheidet aber nicht. |
| Beziehung zu spaeterer Persistenz | Nutzerentscheidung braucht Undo-/Persistence-/Privacy-Gate vor Speicherung. |
| Offene Gates | Review Queue Budget, Confidence Scoring, Undo/Reclassification, Persistence. |

## 5. Entscheidungsmatrix

| Word Type / Risiko | Clutter | Sense-Klarheit | Nutzerentscheidung | Primaerer Outcome | Sicherer Fallback |
| --- | --- | --- | --- | --- | --- |
| Abstrakt oder digital | niedrig bis mittel | oft kontextarm | optional | `CodexOnly` | `ContextCard`, `Backlog` |
| Konkreter grosser Gegenstand / Ort | niedrig | klar | erforderlich vor Weltwirkung | `WorldCandidate` | `NeedsUserChoice`, `Backlog` |
| TinyObject / kleines Werkzeug | hoch | klar oder unklar | oft erforderlich | `ContainerItem` | `CodexOnly`, `Backlog` |
| Verb / Aktion | mittel | meist klar, aber systemabhaengig | optional | `ActionChallenge` | `ContextCard`, `CodexOnly` |
| Mehrdeutig / Multi-Home | variabel | unklar | erforderlich | `NeedsUserChoice` | `ContextCard`, `Backlog` |
| Sensitive / persoenlich / Institution | variabel | auch bei klarer Sense gated | optional und neutral | `SensitiveGated` | `CodexOnly`, `ContextCard`, `Backlog` |
| Kontext fehlt / Low Confidence | unbekannt | unklar | nicht erzwingen | `NeedsUserChoice` | `Backlog`, `CodexOnly` |
| Gebaeudeteil / zustandsabhaengig | hoch ohne Gebaeude | klar, aber abhaengig | erforderlich | `ContextCard` oder `Backlog` | `Blueprint` spaeter, kein BuildState |

## 6. Queue-Ausgaenge

| Ausgang | Wann erlaubt | Bewirkt | Darf nicht bewirken |
| --- | --- | --- | --- |
| `Later` | Nutzer will nicht entscheiden, Kontext fehlt, Thema ist sensibel oder Queue-Budget voll. | Entscheidung wird verschoben. | keine Strafe, kein Druck, keine Platzierung. |
| `Codex` | Erklaerung reicht, Wort ist abstrakt/sensibel/unklar oder Nutzer will keine Weltwirkung. | neutraler Lern-/Erklaerpfad. | kein Weltobjekt, kein Asset, kein Build-State. |
| `Backlog` | Gate, Kontext, Insel, Depth oder Safety fehlt. | spaeter vormerken. | keine Persistenz ohne Gate, kein verstecktes Placement. |
| `Confirm` | Nutzer bestaetigt einen sicheren Vorschlag als Preview/Fallback. | bestaetigte Moeglichkeit fuer spaeteren Gate-Schritt. | kein Build, kein `frame_started`, keine DB Writes. |
| `Change` | Sense, Kategorie, Outcome oder Ziel passt nicht. | andere Bedeutung oder Outcome waehlen. | keine automatische finale Reclassification mit Persistenz. |
| `Hide` | Nutzer will Wort nicht in Review/Welt sehen oder Thema ist belastend. | aus aktiver Entscheidungsliste ausblenden. | kein Loeschen oder Datenverlust ohne eigenes Gate. |

## 7. Reward / Vorschlag / PlacementCandidate / BuildState

| Begriff | Bedeutung | MVP-Erlaubnis | Blockiert |
| --- | --- | --- | --- |
| Reward | Sanftes Signal, dass Lernen etwas ermoeglicht hat. | kurzer positiver Hinweis oder freiwilliger Vorschlag. | Strafe, Druck, SRS-Mutation, BuildState. |
| Vorschlag | Eine Moeglichkeit, die der Nutzer ansehen, aendern oder verschieben kann. | Review-Queue-Karte, ContextCard, Candidate-Hinweis. | Platzierung, Persistenz, Route. |
| `PlacementCandidate` | Spaeterer technischer Kandidat nach User Choice und Gate. | In M16-W nur Begriff/Planung. | MVP-Default, direkte Weltplatzierung. |
| `BuildState` | Produktiver Bauzustand eines Weltobjekts. | Nicht erlaubt. | jeder Build-State, `foundation_started`, `frame_started`. |
| `frame_started` | Spezifischer Bauzustand/Rohbauzustand. | Nicht erlaubt. | weiterhin hart blockiert. |

Merksatz:

```text
Reward ist Signal.
Vorschlag ist Moeglichkeit.
PlacementCandidate ist spaeteres Gate.
BuildState bleibt blockiert.
```

## 8. Beispiele

| Wort | Kontext / Risiko | Primaerer Outcome | Queue-Ausgaenge | Blockiert |
| --- | --- | --- | --- | --- |
| Haus | Multi-Home: Zuhause, Stadt, Land/Farm, Kueste/Strand | `NeedsUserChoice` oder spaeter `WorldCandidate` | `Change`, `Later`, `Backlog`, `Confirm` | Pflicht-Hausstart, automatische Platzierung, `frame_started` |
| Garage | Zuhause/Dorf, Verkehr, Stadt; Utility/Vehicle-Risiko | `NeedsUserChoice` | `Change`, `Backlog`, `Codex`, `Later` | automatisch Zuhause, Fahrzeuglogik ohne Gate |
| Baum | Natur, Stadt/Park, Farm; Deko-/Clutter-Risiko | `WorldCandidate` mit Clutter-Gate | `Confirm`, `Change`, `Backlog`, `Later` | Deko-Masse, Auto-Asset |
| schwimmen | Verb/Aktion, Wasser/Safety | `ActionChallenge` oder `ContextCard` | `Codex`, `Backlog`, `Later`, `Change` | Gebaeude, Wasserlogik ohne Gate |
| Angst | Emotion/sensibel | `SensitiveGated` oder `ContextCard` | `Codex`, `Later`, `Hide`, `Backlog` | Reward, Drama, Objekt, Retention-Druck |
| lernen | Verb/LearningMode, Schule moeglich aber nicht automatisch | `ActionChallenge` oder `CodexOnly` | `Codex`, `Later`, `Change`, `Backlog` | automatisch Schulgebaeude |
| Messer | Tool, ContainerItem, Safety-Kontext | `ContainerItem` plus Safety/Context | `Codex`, `Backlog`, `Later`, `Hide` | sichtbares Objekt ohne Gate |
| Polizei | Institution/sensibel | `SensitiveGated` | `ContextCard`, `Codex`, `Later`, `Hide` | Polizeiwache, Autoritaetsfantasie, Reward |
| Freiheit | abstrakt | `CodexOnly` oder `ContextCard` | `Codex`, `Later`, `Backlog`, `Hide` | Symbolpflicht, Gebaeude |
| Schluessel | TinyObject, Container/Sequence | `ContainerItem` oder `NeedsUserChoice` | `Backlog`, `Codex`, `Change`, `Later` | Minipixel in IslandView |
| kochen | Aktion/Verb, Essen/Kueche | `ActionChallenge` | `Codex`, `Backlog`, `Later`, `Confirm` als Preview-Idee | statisches Objekt, Pflichtquest |
| Bank | mehrdeutig: Sitzbank, Geldinstitut, Flussufer | `NeedsUserChoice` | `Change`, `ContextCard`, `Later`, `Backlog` | Default-Sense, automatische Kategorie |

## 9. Gates vor Umsetzung

Vor produktiver Nutzung der Outcomes braucht Talvori spaeter eigene Gates fuer:

- minimale Datenstruktur oder `WordSemanticProfile`,
- Privacy und Persistenz,
- Review Queue Budget,
- Confidence Scoring,
- Undo/Reclassification,
- Companion-Copy und Sensitive-Copy,
- Container/Depth,
- ThemeIsland/Plot-Capacity,
- Asset Scope,
- App-Integration,
- Accessibility und Device-Pruefung,
- Tests,
- keine automatische Platzierung.

## 10. Dokumentationsvisualisierungen

M16-W ergaenzt Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_w_word_outcome_detail_gate/`

Erzeugte Visuals:

- `word_outcome_decision_matrix.png`
- `outcome_cards_overview.png`
- `queue_exit_rules.png`
- `reward_vs_placement_boundaries.png`
- `example_words_outcome_map.png`
- optional `00_contact_sheet.png`

Diese PNGs sind Dokumentationsmaterial. Sie sind keine App-Screens, keine
Screenshots, keine Spielassets und keine Dateien unter `assets/`.

Visual-QA-Regel:

- Text bleibt in Karten/Rahmen/Panels.
- Ausreichender Innenabstand.
- Kartenabstaende.
- Keine Ueberlappung von Karten, Labels, Pfeilen, Titeln, Footern oder
  Legenden.
- Contact Sheet vollstaendig lesbar, falls erzeugt.
- Keine abgeschnittenen Inhalte.

## 11. Stop-Regeln

Aus M16-W folgt ausdruecklich:

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
- Nicht committen.
