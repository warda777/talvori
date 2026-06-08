# M16-AD: World Loop and Plot Family Gate

Stand: 2026-06-08

Status: `Planungs-/Gate-Slice / keine Implementierung`

## 1. Zweck

M16-AD definiert fachlich, wie Talvori Weltfortschritt, generische
Plot-Familien, BuildChoice, Undo/Reversibility und spaetere
Weltentscheidungen steuert. Der Slice verbindet die MVP-Lernloop-Regeln aus
M16-V bis M16-AC mit den ThemeIsland-/Plot-Capacity-Regeln aus M16-I/K und
den Plot-Capability-Regeln aus M12-C.

Kernregel:

```text
Learning/Semantics koennen Weltmoeglichkeiten erzeugen.
Sie erzeugen aber keine Platzierung, keinen BuildState,
keine Persistenz, keine Assets und kein frame_started.
```

## 2. Non-Goals und Stop-Regeln

M16-AD erzeugt nicht:

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
- keine automatische Wortplatzierung,
- kein Build-Wheel-Code,
- keine Assets,
- keine Asset-Dateien unter `assets/`,
- kein Build-State,
- kein `frame_started`,
- keine Bauzustaende.

Dieses Dokument ist keine Codefreigabe und keine Build-Wheel-Freigabe.

## 3. Gelesene Grundlagen

| Dokument | Relevanz fuer M16-AD |
| --- | --- |
| `328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrende ToDo-/Gate-Liste, betroffene World/Wheel/Undo-IDs. |
| `336-documentation-map-and-slice-reading-rules.md` | Pflichtlektuere-Regeln fuer World-/Island-/Plot-/Build-Slices. |
| `330-minimal-playable-learning-loop-contract.md` | Lernen erzeugt Moeglichkeit, keine Platzierung. |
| `331-minimal-word-outcome-detail-gate.md` | `WorldCandidate`, Queue-Ausgaenge und Reward/Placement/BuildState-Grenzen. |
| `332-reward-budget-and-review-queue-control-gate.md` | Vorschlaege werden dosiert; keine Pflichtentscheidung und kein Reward-Spam. |
| `333-minimal-semantic-profile-and-routing-priority-gate.md` | Safety > Sense > Word Type > Clutter > Confidence > User Choice > Capability > Reward. |
| `334-companion-and-sensitive-return-safety-gate.md` | Companion/Sensitive duerfen keine Welt-, Reward- oder Placement-Ausloeser sein. |
| `335-learning-states-and-srs-boundary-gate.md` | `worldFeedbackEligible` ist nur Vorschlagserlaubnis, keine Platzierung. |
| `337-mobile-density-accessibility-and-depth-planning-gate.md` | Mobile-Dichte, Landmarken-vor-Kleinteilen und Depth-/Container-Grenzen. |
| `318-theme-island-plot-capacity-and-build-wheel-plan.md` | Theme -> Plotbedarf -> Groessenmix -> Slot-Auswahl -> spaeteres In-place Wheel. |
| `320-global-theme-island-plot-capacity-matrix.md` | Globale Kategorien und unterschiedliche Plot-Capacity-Profile. |
| `272-plot-capability-derivation.md` | Plot-Capabilities sind Erlaubnisse, keine Pflichtbelegung. |
| `321-global-world-semantics-consistency-audit.md` | Pflichtpipeline fuer Word/Sense/Representation/User Choice/Later Gate. |

## 4. Betroffene M16-T-IDs

| ID | M16-AD-Entscheidung |
| --- | --- |
| `M16T-WORLD-001` | World/Island Loop fachlich definiert. |
| `M16T-WORLD-003` | Generische Plot-Familien dokumentiert. |
| `M16T-WHEEL-002` | BuildChoice-Begriff als Candidate/Preview/Confirm/Later/Cancel/Change definiert. |
| `M16T-WHEEL-004` | Undo-/Reversibility-Anforderung fuer BuildChoice festgelegt. |
| `M16T-UNDO-001` | Undo/Reversibility fuer Sense, Outcome, Plot-Familie, ThemeIsland und Review dokumentiert. |
| `M16T-UNDO-002` | Reclassification-Regeln fuer geaenderte Semantik dokumentiert. |

## 5. World/Island Loop

Der World/Island Loop ist eine fachliche Reihenfolge. Er ist kein
Produktionsdatenmodell, kein Renderer-Kontrakt und keine Persistenzfreigabe.

| Schritt | Bedeutung | Erlaubt | Blockiert |
| --- | --- | --- | --- |
| Learning Event | Nutzer lernt, wiederholt oder sieht ein Wort. | Semantikpruefung vorbereiten. | SRS-/`word_progress`-Mutation ohne Gate, BuildState. |
| Semantic Outcome | Word Type, Sense, Safety, Clutter und Confidence ergeben einen MVP-Outcome. | `CodexOnly`, `WorldCandidate`, `ContainerItem`, `ActionChallenge`, `ContextCard`, `SensitiveGated`, `NeedsUserChoice`. | direkte ThemeIsland-/Plot-Belegung. |
| Review/Choice | Nutzer sieht nur budgetierte, relevante Entscheidungen. | Later, Codex, Backlog, Confirm, Change, Hide. | Pflichtentscheidung, Massenreview. |
| Safe World Feedback | Sichtbares Signal, dass Lernen etwas ermoeglicht. | kleine Preview, Highlight, Fallback, ContextCard. | Placement, Asset, Persistenz, `frame_started`. |
| World Candidate | Wort koennte spaeter Weltbezug tragen. | Candidate/Fallback mit Gate-Hinweis. | automatisches Objekt. |
| Plot Family Candidate | Moegliche Plot-Familie wird als Erlaubnis gezeigt. | Wechseln, Verschieben, Abwaehlen. | feste Belegung oder BuildState. |
| BuildChoice Candidate | Spaetere freiwillige Wahlmoeglichkeit entsteht. | Preview/Later/Cancel/Change. | Bauausfuehrung, Wheel-Code. |
| Later Gate | Eigene Gate-Pruefung fuer echte Umsetzung. | Datenmodell-, Undo-, Persistenz-, Asset-, App-Gate planen. | nebenbei produktiv schreiben. |
| Undo/Reversibility | Entscheidung kann spaeter geaendert oder erklaert werden. | Sense, Outcome, Theme, Plot-Familie, BuildChoice aendern. | irreversible MVP-Weltentscheidung. |

Loop-Regeln:

- Weltfortschritt entsteht aus kuratierten, gated Entscheidungen.
- Kein Lernereignis baut direkt.
- Kein Reward erzeugt Platzierung.
- Kein UI-Tap schreibt Weltzustand.
- Kein Plot erzeugt Persistenz.
- Weltfeedback bleibt zunaechst Preview, Fallback oder ContextCard.

## 6. Generische Plot-Familien

Plot-Familien sind wiederverwendbare fachliche Families. Sie ersetzen keine
ThemeIsland-Capacity-Matrix und keine spaetere Datenstruktur. Eine Familie sagt
nur: Diese Art von Weltbereich koennte spaeter bestimmte Outcomes aufnehmen,
wenn Sense, Safety, Mobile, User Choice und Gate passen.

| Plot-Familie | Zweck | Typische Word Outcomes | Erlaubte Weltreaktion | Blockierte Weltreaktion | Mobile/Clutter Risiko | Sensitive Risiko | Offene Gates |
| --- | --- | --- | --- | --- | --- | --- | --- |
| dwelling / home | Wohn-, Alltags- und Zuhause-Kontext. | `WorldCandidate`, `NeedsUserChoice`, `ContainerItem`, `ContextCard`. | Home-nahe Preview oder Plot-Family Candidate. | Pflicht-Hausstart, Auto-Zuhause. | Interior/Labels koennen ueberladen. | Familie/Privatsphaere. | Sense, Privacy, Undo, Persistence. |
| garden / nature | Pflanzen, Baeume, Naturflaechen, ruhige Orientierung. | `WorldCandidate`, `ContainerItem`, `Backlog`, `ContextCard`. | Landmarke, Naturbereich, Clutter-gepruefter Candidate. | Deko-Masse, Baumwolke als Reward. | hoch bei vielen Kleinteilen. | gering bis mittel. | Clutter, Asset, Growth/Fairness. |
| learning / school | Lernen, Schule, Bibliothek, Material, Lernort. | `ActionChallenge`, `ContextCard`, `WorldCandidate`, `ContainerItem`. | Lernraum-Candidate oder ContextCard. | Verb `lernen` automatisch als Schulgebaeude. | Text-/Overlay-Risiko. | Pflichtschule/Testmodus. | Learning, Privacy, Accessibility. |
| food / kitchen / restaurant | Kochen, Essen, Kueche, Cafe, Restaurant. | `ContainerItem`, `ActionChallenge`, `WorldCandidate`, `ContextCard`. | Kitchen/food Plot-Family Candidate oder Container. | Produktions-/Timerlogik, Assetliste. | viele kleine Items. | Ernaehrung/gesundheitliche Sensitivitaet. | Food, Safety, Container, Asset. |
| travel / movement / transport | Bewegung, Fahrzeuge, Wege, Parken, Orientierung. | `ActionChallenge`, `WorldCandidate`, `NeedsUserChoice`. | Path/transport Candidate, ContextCard. | Verkehrssystem, Fahrzeuglogik, Route. | Label-/Path-Clutter. | Unfall/Notfall moeglich. | Travel, Vehicle, Safety, Mobile. |
| work / craft / production | Arbeit, Werkstatt, Handwerk, Produktion. | `ActionChallenge`, `ContainerItem`, `WorldCandidate`, `ContextCard`. | Workshop Candidate oder Tool-Container. | Produktionsloop, Timer, Economy. | Tool-Clutter. | Arbeit/Industrie/Safety. | Work, Economy, Safety, Persistence. |
| water / coast / harbor | Wasser, Strand, Pier, Hafen, Schwimmen, Boote. | `ActionChallenge`, `WorldCandidate`, `ContextCard`, `SensitiveGated` bei Safety. | Wasser-/Kuesten-Candidate, Safety-Hinweis. | Wasserlogik, Bootslogik, automatische Platzierung. | hoch durch kleine Objekte/Labels. | Water Safety. | Water, Safety, Path, Asset. |
| public / civic | Oeffentliche Gebaeude, Verwaltung, Polizei, Institutionen. | `SensitiveGated`, `ContextCard`, `CodexOnly`, `Backlog`. | neutrale ContextCard oder gated Candidate. | automatische Polizeiwache/Gericht/Rathaus. | Symbolik kann dominieren. | hoch. | Policy, Sensitive, Opt-in. |
| health / emergency / sensitive | Gesundheit, Notfall, medizinische/psychologische Begriffe. | `SensitiveGated`, `ContextCard`, `CodexOnly`, `Backlog`, `Hide`. | neutrale Erklaerung, Later/Hide. | Reward, Deko, Beratung, sichtbare Klinik ohne Gate. | gering visuell, hoch in Copy. | sehr hoch. | Policy, Privacy, Safety, Companion. |
| culture / social | Kultur, Gesellschaft, Treffen, Freizeit, soziale Raeume. | `WorldCandidate`, `ContextCard`, `NeedsUserChoice`, `Backlog`. | sozialer/cultural Candidate nach Gate. | Social-System, globaler Chat, Pflichtinteraktion. | Personen-/Label-Clutter. | mittel. | Social, Privacy, Moderation. |
| technology / digital | Technik, Digitales, Geraete, Apps, KI. | `ContainerItem`, `ContextCard`, `CodexOnly`, `ActionChallenge`. | Tech-ContextCard oder Container. | AI-Provider, Runtime-Konfiguration, Device-Asset. | kleine Objekte/Icons. | Datenschutz. | AI, Privacy, Provider, Asset. |
| container / storage | Schublade, Tasche, Regal, Kiste, Werkzeugbox. | `ContainerItem`, `CodexOnly`, `Backlog`, `NeedsUserChoice`. | Container-Pfad oder Findability-Hinweis. | unsichtbares Pflichtobjekt, Inventar-Dump. | mittel bis hoch bei Massenitems. | abhaengig vom Inhalt. | Depth, Search, Persistence, A11y. |
| action / challenge | Verben, Handlungen, Sequenzen, Aufgaben. | `ActionChallenge`, `ContextCard`, `Backlog`, `CodexOnly`. | Challenge-Idee oder ContextCard. | statisches Gebaeude, automatische Quest. | Overlay-/Queue-Druck. | abhaengig vom Verb. | Gameplay, Reward, Queue, Safety. |
| abstract / context | Gefuehle, Eigenschaften, abstrakte Begriffe. | `ContextCard`, `CodexOnly`, `SensitiveGated`, `NeedsUserChoice`. | Erklaerkarte, Companion-Hinweis, Codex. | Symbolpflicht, falsches Objekt, dramatische Darstellung. | Textlast. | oft mittel bis hoch. | Copy, Companion, Sensitive, A11y. |

## 7. Plot-Capability-Regel

Capability ist Erlaubnis, keine Pflichtbelegung.

Verbindliche Regeln:

- Eine ThemeIsland darf passende Plot-Familien anbieten.
- Ein Plot darf nur Candidate, Fallback oder Erklaeranker sein.
- Ein Plot erzeugt keinen BuildState.
- Ein Plot erzeugt kein Asset.
- Ein Plot erzeugt keine Persistenz.
- Ein Plot wird nicht automatisch aus einem Wort belegt.
- `core_plot` ist flexibel, aber nicht automatisch `home`.
- `hub_capable_plot` kann `market` oder `learningHub` tragen, wird aber nicht
  automatisch Markt oder Lernhub.
- Water, travel, vehicle, farm, digital und sensitive Capabilities bleiben bis
  zu eigenen Folge-Gates blockiert.

Capability-Pipeline:

```text
Word Outcome
-> Candidate ThemeIsland
-> Candidate Plot Family
-> Capability Check
-> User Choice / Later
-> Preview Only
-> Later Gate
```

Nicht erlaubt:

```text
Word -> Capability -> Plot belegt -> BuildState -> frame_started
```

## 8. BuildChoice-Begriff

BuildChoice ist eine spaetere freiwillige Auswahlmoeglichkeit. BuildChoice ist
nicht BuildState, nicht Placement, nicht Persistenz, nicht Asset, nicht
`frame_started`, nicht App-Route und nicht Wheel-Code.

| Begriff | Bedeutung | Erlaubt | Blockiert |
| --- | --- | --- | --- |
| BuildChoice Candidate | Moegliche Auswahl wird aus Outcome, Plot-Familie und Capability abgeleitet. | als Option oder Fallback planen. | automatische Bauausfuehrung. |
| BuildChoice Preview | Nutzer sieht eine nicht-persistente Vorschau. | ansehen, vergleichen, abbrechen. | Placement, Asset, BuildState. |
| BuildChoice Confirm | Nutzer bestaetigt spaeter eine Entscheidung. | nur nach eigenem Gate relevant. | DB Write, SRS-Write, `frame_started` in M16-AD. |
| BuildChoice Later | Nutzer verschiebt Entscheidung. | Backlog/Queue/Fallback. | Druck, Verlust, Weltstrafe. |
| BuildChoice Cancel | Nutzer bricht ab oder waehlt ab. | Auswahl schliessen, Safe Default. | negative Lernwirkung. |
| BuildChoice Change | Nutzer aendert Sense, Outcome, Plot-Familie oder Candidate. | Reclassification/Undo-Pfad planen. | alte Entscheidung kaputtmachen. |

BuildChoice-Regel:

Eine spaetere BuildChoice darf erst dann produktiv werden, wenn Undo,
Persistenz, Asset Scope, Accessibility, Performance, App-Integration und
Tests in eigenen Gates freigegeben sind.

## 9. Undo/Reversibility

Talvori darf im MVP keine irreversible Weltentscheidung erzwingen. Undo und
Aenderbarkeit sind fachliche Voraussetzungen fuer jede spaetere echte
Weltentscheidung.

| Aenderung | Warum noetig | Sichere MVP-Reaktion | Blockiert |
| --- | --- | --- | --- |
| Sense aendern | `Bank` kann Sitzbank, Geldinstitut oder Flussufer sein. | ContextCard, NeedsUserChoice, Change. | persistente Default-Bedeutung ohne Gate. |
| Outcome aendern | Ein Wort kann von `WorldCandidate` zu `CodexOnly` wechseln. | Queue/Backlog aktualisieren als Planung. | BuildState aus altem Outcome. |
| Plot-Familie aendern | `Garage` kann Zuhause, Verkehr oder Stadt sein. | Plot-Family Candidate wechseln. | feste Zuhause-Belegung. |
| ThemeIsland aendern | `Haus` kann Zuhause, Stadt, Land oder Strand betreffen. | Multi-Home-Choice neu oeffnen. | kaputte alte Entscheidung. |
| BuildChoice zuruecknehmen | Nutzer will Candidate nicht mehr. | Later, Cancel, Change. | irreversible Bauentscheidung. |
| Review spaeter aendern | Nutzer lernt Kontext nach. | Change/Backlog/ContextCard. | einmalige finale Entscheidung. |
| Sensitive/Context neu bewerten | Safety gewinnt sofort. | SensitiveGated, Hide, Later. | Weltwunsch ueberstimmt Safety. |

Undo-Regeln:

- Review ignorieren hat keine negative Welt- oder Lernwirkung.
- `Confirm` bleibt ohne Persistenz, bis ein eigenes Gate existiert.
- Spaetere Persistenz braucht Undo-/Migration-/Privacy-Regeln.
- Sensitive-Reclassification gewinnt sofort gegen Weltwunsch.

## 10. Geaenderte Semantik

Ein Wort kann spaeter anders klassifiziert werden, weil Kontext, Sprache,
Nutzerziel, Safety oder Confidence sich aendern.

Regeln:

- Ein Wort kann spaeter anders klassifiziert werden.
- Nutzerentscheidungen duerfen dadurch nicht kaputtgehen.
- Alte Entscheidungen muessen erklaerbar bleiben.
- Reclassification darf keine Persistenzmigration ohne Gate erzeugen.
- Sensitive-Reclassification gewinnt sofort gegen Weltwunsch.
- Low confidence darf nicht zu BuildChoice Confirm oder Placement fuehren.
- Multi-Home-Woerter bleiben aenderbar.
- Aenderung bedeutet zunaechst ContextCard, Backlog, NeedsUserChoice oder
  Later, nicht Weltmutation.

## 11. Beispiele

| Wort | Risiko / Semantik | Sichere World-/Plot-Regel | BuildChoice-Lesart | Undo/Reclassification |
| --- | --- | --- | --- | --- |
| Haus | Multi-Home: Zuhause, Stadt, Land, Strand. | dwelling/home oder civic/stadt/farm/coast nur nach Sense/User Choice. | Candidate, kein Pflicht-Hausstart. | Sense/ThemeIsland muss wechselbar bleiben. |
| Garage | Zuhause, Verkehr, Stadt, Utility. | dwelling, travel/transport oder work/utility als Candidate. | BuildChoice spaeter, keine Vehicle-Logik. | Auto-Zuhause korrigierbar halten. |
| Baum | Garten/Natur, Stadt/Park, Farm/Obstbaum. | garden/nature mit Clutter-Gate. | Landmarke oder Backlog, kein Deko-Spam. | Deko zu Codex/Backlog verschiebbar. |
| Schuessel/Schluessel | Schuessel: kitchen/container; Schluessel: TinyObject/Sequence. | food/container oder container/storage. | ContainerItem, nicht IslandView-Objekt. | Schreib-/Sense-Klaerung vor Weltwirkung. |
| Messer | Tool/Kueche, aber Safety relevant. | container/storage, food oder SensitiveGated. | kein sichtbares Objekt ohne Safety-Gate. | Sensitive-Neubewertung gewinnt. |
| schwimmen | Verb/Aktion, Wasser/Freizeit. | action/challenge oder water ContextCard. | keine Wasserplatzierung. | Safety/Water-Gate kann blockieren. |
| lernen | Verb/LearningMode, Schule moeglich. | action/challenge oder learning ContextCard. | kein automatisches Schulgebaeude. | Schule als Theme bleibt optional. |
| Polizei | Public Institution/Sensitive. | public/civic nur gated, meist ContextCard/SensitiveGated. | keine Polizeiwache als Reward. | Policy-Update gewinnt. |
| Angst | Emotion/sensitiv moeglich. | abstract/context, ContextCard, CodexOnly, SensitiveGated. | kein Weltobjekt. | Companion-Copy bleibt neutral. |
| Bank | Sitzbank, Geldinstitut, Flussufer. | NeedsUserChoice vor Plot-Familie. | Candidate erst nach Sense. | Default-Sense nie final. |
| Hafen | Wasser/Transport/Arbeit. | water/coast/harbor Candidate mit Water/Path/Safety-Gate. | kein Bootssystem. | Reclass zu Stadt/Handel moeglich. |
| Schule | Ort, Lernen, Institution. | learning/school Candidate nach Kontext. | kein Pflicht-Lerngebaeude. | Lernen als Verb bleibt getrennt. |
| Kueche | Interior/Food/Container. | food/kitchen oder dwelling-depth. | eher Depth/Interior, kein eigenes Island-Massenobjekt. | Privacy/Interior spaeter pruefen. |
| Garten | Natur, Zuhause, Food, Freizeit. | garden/nature oder food/farm Candidate. | keine Growth-/Timerlogik. | Farm/Garden-Kontext wechselbar. |

## 12. Gate-Entscheidung

M16-AD macht einen spaeteren lokalen Planungs-/Preview-Slice theoretisch
sinnvoller, weil World Loop, Plot-Familien, BuildChoice und Undo jetzt
begrifflich getrennt sind.

Freigegeben ist dadurch weiterhin nicht:

- keine World-Code-Implementierung,
- keine Build-Wheel-Implementierung,
- keine App-Integration,
- keine Route,
- keine Persistenz,
- keine Assets,
- keine automatische Wortplatzierung,
- kein Build-State,
- kein `frame_started`.

## 13. Visualisierungen

Dokumentationsvisualisierungen liegen unter:

`docs/world_design/previews/m16_ad_world_loop_plot_family/`

Erwartete PNGs:

- `00_contact_sheet.png`
- `world_loop_gate_flow.png`
- `plot_family_matrix.png`
- `capability_not_placement.png`
- `buildchoice_boundary_model.png`
- `undo_reversibility_flow.png`
- `semantic_reclassification_safety_flow.png`

Visual-QA-Regel:

- Text bleibt in Karten/Rahmen/Panels.
- Ausreichender Innenabstand.
- Kartenabstaende.
- Keine Ueberlappung von Karten, Labels, Pfeilen, Titeln, Footern oder Legenden.
- Contact Sheet vollstaendig lesbar.
- Keine abgeschnittenen Inhalte.

## 14. Update fuer M16-T

M16-AD setzt passend auf erledigt:

- `M16T-WORLD-001`
- `M16T-WORLD-003`
- `M16T-WHEEL-002`
- `M16T-WHEEL-004`
- `M16T-UNDO-001`
- `M16T-UNDO-002`

Bewusst offen oder teilweise:

- `M16T-WORLD-002` bleibt teilweise, weil ThemeIsland-/Plot-Capacity in
  spaeteren konkreten Slices angewendet werden muss.
- `M16T-WORLD-004` bleibt teilweise, weil die Capability-Regel in jedem
  spaeteren Plot-Slice aktiv als Stop-Regel gefuehrt werden muss.
- `M16T-WHEEL-001` bleibt blockiert; M16-AD erzeugt keinen Wheel-Code.
- `M16T-WHEEL-003` bleibt teilweise; In-Place-Regeln sind geplant, aber kein
  Wheel-Slice ist freigegeben.
- `M16T-UNDO-003` bleibt offen; ThemeIsland-Resizing braucht eigenes Gate.

## 15. Checks

Nach Erstellung auszufuehren:

- `git diff --check`
- `git status --short`
- Scope-Check gegen `lib/`, `assets/`, `test/`, `integration_test/`

Erwarteter Scope:

- `docs/world_design/338-world-loop-plot-family-and-buildchoice-gate.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/previews/m16_ad_world_loop_plot_family/`

Nicht erwartet:

- Aenderungen unter `lib/`,
- Aenderungen unter `assets/`,
- Tests,
- Routen,
- App-Integration,
- Persistenz.
