# M16-L: Global World Semantics Consistency Audit

Stand: 2026-06-07

Status: `Audit und Visualisierung gestartet / keine Implementierung`

## 1. Ziel

M16-L konsolidiert die bisherigen World-Design-Regeln, damit weitere
ThemeIsland-, Plot-, Build-Wheel-, Word-to-Island-, Container-, Sensitive-,
Asset- oder Preview-Slices nicht nur Kategorie- oder Slot-Logik beachten,
sondern auch die bereits festgelegten Semantik-, Routing-, Fallback-, Depth-,
Mobile- und Policy-Regeln.

Kernfrage:

Welche bestehenden Regeln muessen bei jedem weiteren World-/Island-/Plot-/
Build-Wheel-/Word-/Container-/Sensitive-/Asset-Prompt als Pflichtfilter
beruecksichtigt werden?

M16-L ist nur Dokumentation, Audit und Visualisierung. Daraus folgen keine
Flutter-/Dart-Dateien, keine App-Integration, keine Route, keine neue Seite,
keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz,
keine Assets, keine automatische Wortplatzierung, kein Build-State, kein
`frame_started` und keine Bauzustaende.

## 2. Gepruefte Grundlage

| Dokument | Beitrag fuer M16-L |
| --- | --- |
| `docs/world_design/252-flexible-plot-placement-and-learning-semantics.md` | Flexible Plot-Funktionen, Nutzerentscheidung, Wortsemantik und keine automatische Platzierung. |
| `docs/world_design/253-capability-greybox-plan.md` | `plotSize`, `allowedFunctions`, optionale Anchors und Capabilities als Erlaubnisse. |
| `docs/world_design/254-capability-greybox-visual-review.md` | Greybox nur intern; kleine Objekte gehoeren in Depth/Container; kein `frame_started`. |
| `docs/world_design/255-world-depth-gameplay-retention-research.md` | Depth-Ebenen von IslandView bis DetailInteractionView; Aktionen als Challenges; Container statt Objektlisten. |
| `docs/world_design/256-depth-container-user-flow-preview-plan.md` | Container als fokussierter Lernraum, nicht als Inventarliste. |
| `docs/world_design/257-depth-container-user-flow-visual-review.md` | Ein Beispiel reicht nicht fuer ein generelles Container-System. |
| `docs/world_design/264-multi-example-container-flow-previews.md` | Schule/Federmappe, Hafen/Bootskajute und Garten/Beet zeigen verschiedene Container-Risiken. |
| `docs/world_design/265-multi-example-container-flow-visual-review.md` | Multi-Flow-Richtung ist brauchbar, aber Container-Architektur bleibt gated. |
| `docs/world_design/266-world-content-taxonomy-and-location-catalog.md` | Taxonomy von ThemeIsland bis Detail/Deko; Kategorien wie Zuhause, Wasser/Hafen, Farm, Stadt, Arbeit, Natur. |
| `docs/world_design/267-world-content-taxonomy-review.md` | Taxonomy brauchbar, aber Cross-Cutting-Themen wie Emotion, Technik, Gesundheit, Kultur und Verwaltung fehlen als Gate. |
| `docs/world_design/268-theme-island-prioritization.md` | Early/Mid/Late/Sensitive-Wellen und Kategorie-Risiken. |
| `docs/world_design/270-word-to-island-routing-matrix.md` | Word-to-Island macht Vorschlaege; Word-Type-Routing, Multi-Home, Fallbacks und User Choice sind Pflicht. |
| `docs/world_design/271-word-to-island-routing-visual-review.md` | Bestaetigt Routing-Pipeline, Beispielkarten, Codex/Blueprint/Backlog und keine automatische Platzierung. |
| `docs/world_design/272-plot-capability-derivation.md` | Plot-Capabilities sind permissions; `allowedFunctions`, `depthSupport`, Risk Flags und Gates. |
| `docs/world_design/273-plot-capability-visual-review.md` | `core_plot` ist nicht automatisch `home`; Water/Farm/Travel/Vehicle/Digital/Sensitive bleiben gated. |
| `docs/world_design/274-sensitive-content-representation-rules.md` | Sensitive/abstract Begriffe gehen neutral in Codex, ContextCard, Blueprint, Backlog oder RequiresUserChoice. |
| `docs/world_design/275-sensitive-content-visual-review.md` | Unsicherheit fuehrt zu keiner sichtbaren Platzierung; keine automatische Klinik/Polizei/Kirche. |
| `docs/world_design/276-mobile-clutter-rules-small-objects.md` | TinyObjects nicht dauerhaft in IslandView; Clutter fuehrt zu Zoom, Container, Detail, Codex, Blueprint oder Backlog. |
| `docs/world_design/277-mobile-clutter-visual-review.md` | Bestaetigt M12-E: Container brauchen wenige Challenge-Objekte und Lesbarkeit. |
| `docs/world_design/278-m12-consolidated-readiness-review.md` | Konsolidiert Routing, Multi-Home, Capabilities, Sensitive, Clutter und Fallbacks als Planungsgrundlage. |
| `docs/world_design/279-theme-island-roadmap-draft.md` | Roadmap-Wellen und Gates fuer Foundation, Expansion, System-Heavy und Sensitive/Special. |
| `docs/world_design/283-theme-island-capability-sheets.md` | Capability Sheets pro ThemeIsland mit Worttypen, Depth, Fallbacks, Mobile, Safety und Fairness. |
| `docs/world_design/284-word-to-island-ux-flow.md` | UX-Pfade fuer direkt passend, mehrdeutig, Gebaeudeteil, Kleinteil, Verb, abstrakt und sensibel. |
| `docs/world_design/287-sensitive-content-policy-deepening.md` | Sensitive Policy vertieft: CodexOnly, ContextCard, NeutralCompanionDialog, BacklogOnly, RequiresUserChoice, NeutralBlueprint. |
| `docs/world_design/288-growth-timer-fairness-rules.md` | Growth/Timer darf motivieren, aber nicht bestrafen; kein Verfall, keine Schuld, kein FOMO, kein Pay-to-Win. |
| `docs/world_design/289-asset-prioritization-scope-gate.md` | Keine automatische Assetproduktion aus Taxonomy, Routing, Capability Sheets oder Preview. |
| `docs/world_design/290-m13-consolidated-readiness-review.md` | M13-Kette ist Planungsgrundlage, aber keine Code-, Asset-, Runtime- oder `frame_started`-Freigabe. |
| `docs/world_design/318-theme-island-plot-capacity-and-build-wheel-plan.md` | M16-I definiert Theme -> Plots -> Groessen -> Kapazitaet -> Slots -> Build-Wheel-Overlay. |
| `docs/world_design/319-village-plot-capacity-local-preview-scope.md` | M16-J ist ein enges Dorf-Beispiel, kein globaler Standard. |
| `docs/world_design/320-global-theme-island-plot-capacity-matrix.md` | M16-K sammelt globale Kategorien, braucht aber zusaetzlich Semantik-/Routing-/Fallback-Pflichtfilter. |

Zusaetzlich wurde per `rg` nach Multi-Home-, Backlog-, Blueprint-, Codex-,
ContextCard-, PlacementCandidate-, WordSemanticProfile-, Capability-, PlotSize-,
Depth-, Container-, Sensitive-, Abstract-, Action-, Emotion-, State-, Verb-,
Adjektiv-, Haus-, Strand-, Stadt-, Land-, Farm-, Garten-, Schule-, Hafen- und
Routing-Begriffen gesucht. Der Scan bestaetigt, dass diese Regeln quer ueber
die Dokumente verteilt sind und fuer Zukunftsprompts explizit gebuendelt
werden muessen.

## 3. Audit-Matrix

| Existing Rule / Concept | Source Docs | Meaning | Was M16-I considered? | Was M16-J considered? | Was M16-K considered? | Gap | Required Future Rule |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Multi-Home-Woerter | 270, 271, 278, 284 | Ein Wort kann mehrere ThemeIsland-Kontexte haben, z. B. Haus, Garage, Baum, bank, apple. | Teilweise ueber austauschbare Slots, aber nicht wortsemantisch. | Kaum; Dorf liest Haus/Garage als Zuhause. | Teilweise ueber Kategorien, aber nicht als Wortregel. | Multi-Home braucht Sense/User Choice vor Kategorieentscheidung. | Jeder Prompt muss Multi-Home-Woerter explizit pruefen. |
| Kontext/Sense vor Platzierung | 270, 271, 284 | Satz, Nutzerziel und Bedeutung entscheiden vor jeder sichtbaren Route. | Nicht zentral. | Nicht zentral. | Nur implizit. | Kategorieprofile koennen ohne Sense zu frueh wirken. | Kein Plot-/Wheel-/Preview-Slice ohne Context/Sense-Check-Regel. |
| Word-Type Routing | 270, 284 | Nomen, Verb, Adjektiv, Emotion, Abstract, Sensitive, TinyObject, Place, BuildingPart und ContainerItem brauchen verschiedene Wege. | Nicht vollstaendig. | Nein. | Kategorien ja, Worttypen nur begrenzt. | Word-Type fehlt als Pflichtfilter vor Slot/Build. | Word-Type-Klassifikation vor ThemeIsland-/Plot-Entscheidung. |
| PlacementCandidate vs Blueprint vs Codex vs Backlog | 270, 271, 278, 284, 287 | Sichtbare Option ist nur ein Ergebnis neben sicheren Fallbacks. | Preview Only vorhanden, Fallbacks nicht tief. | Wenig. | Kategorien enthalten Gates, aber keine Representation Decision. | M16-K kann wie direktes Plot-Mapping wirken. | Jede Wortentscheidung muss Representation Decision enthalten. |
| Plot-Capabilities als Erlaubnisse | 252, 253, 254, 272, 273 | `allowedFunctions` erlauben Nutzung, sie belegen keinen Plot automatisch. | Ja. | Ja, aber Dorfslots wirken konkreter. | Ja. | Bei spaeterem Code droht feste Belegung. | Capabilities niemals als Pflichtbelegung formulieren. |
| User Choice vor Platzierung | 252, 270, 271, 284 | Talvori schlaegt vor, Nutzer bestaetigt, aendert oder verschiebt. | Ja fuer Slot/Wheel. | Ja als Highlight/Deselect. | Teilweise. | Word-Level-Choice fehlt. | User Choice ist vor sichtbarer Weltwirkung Pflicht. |
| Keine automatische Wortplatzierung | 252, 270, 271, 278, 284, 289 | Kein Wort erzeugt automatisch Objekt, Gebaeude, Slot, Asset oder Build-State. | Ja. | Ja. | Ja. | Muss auch fuer Kategorieprofile gelten. | In jedem Prompt explizit wiederholen. |
| Container-/Depth-Regeln | 255, 256, 257, 264, 265, 276, 277 | Kleine Objekte und Interiors brauchen Depth, Container, Detail oder Fallback. | Zoom/Depth erwaehnt, aber nicht voll. | Kaum. | Enthalten, aber grob. | ContainerItem/TinyObject koennten in Plotlisten rutschen. | Vor Plot-Preview immer Depth/Container-Pruefung. |
| Mobile-/Clutter-Regeln | 276, 277, 283, 290 | Kleine Objekte, Labels, Deko und Container duerfen Mobile nicht ueberladen. | Ja als Risiko. | Ja fuer Dorf. | Ja als Kategorie-Risiko. | Braucht konkrete Pflichtcheckliste fuer naechste Prompts. | Small-phone, Tap-Target und Clutter vor sichtbarer Umsetzung. |
| Sensitive-/Policy-Gates | 274, 275, 287, 283, 290 | Sensitive Begriffe bleiben neutral, privat, optional und nicht automatisch visualisiert. | Stop-Regel, aber keine Representation-Tiers. | Nicht zentral. | Kategorien enthalten Sensitive, aber nicht alle Tiers. | Sensitive kann als Kategorieprofil zu konkret wirken. | Sensitive immer ueber Policy, Codex/ContextCard/Backlog pruefen. |
| Growth-/Timer-Fairness | 288, 283, 290 | Garten/Farm/Growth darf keinen Druck, Verfall, FOMO, Pay-to-Win oder Schuld erzeugen. | Erwaehnt bei Dorf/Garten. | Erwaehnt. | Erwaehnt fuer Farm/Garten. | Muss fuer Farm/Garten/Outdoor als globaler Gate gelten. | Kein Growth-/Timer-Slice ohne Fairness-Gate. |
| Asset-Scope-Gates | 289, 290 | Documentation Preview ist kein Spielasset; Assets folgen nur aus eigenem Gate. | Ja. | Ja. | Ja. | Bei Build-Wheel-Kandidaten droht Assetableitung. | Build-Wheel-Kandidaten duerfen keine Assetliste sein. |
| ThemeIsland-Kategorien | 266, 267, 268, 279, 283, 320 | Viele globale Kategorien; Dorf ist nur ein Beispiel. | Dorf als Beispiel. | Zu eng Dorf. | Ja, breit gesammelt. | Kategorie allein loest Semantik nicht. | Kategorieprofile plus Word-Type-Routing zusammen pruefen. |
| Build-Wheel als Overlay, nicht neue Seite | 318, 319, 320 | Slot antippen, Overlay/Wheel in-place, abbrechbar, keine Route. | Ja. | Ja als spaeter. | Ja. | Wheel muss noch Representation/Fallback respektieren. | Build-Wheel zeigt Kandidaten, keine Bauausfuehrung. |
| Abwaehlen / Deselect | 318, 319 | Nutzer kann Slot/Overlay abbrechen oder abwaehlen. | Ja. | Ja. | Teilweise. | Muss fuer jedes Wheel/Preview gelten. | Jeder Preview-/Wheel-Slice braucht Cancel/Deselect. |
| Austauschbarkeit von Slots | 318, 319, 320 | Slots bleiben konfigurierbar, nicht fest mit Gebaeude belegt. | Ja. | Ja. | Ja. | Austauschbarkeit muss auch Multi-Home-Woerter tragen. | Slots nach Capability/Context, nicht nach fixem Objekt belegen. |
| Zoom/Depth pro Grundstueck | 255, 272, 276, 318, 320 | Manche Plots brauchen Interior, Container oder Detail-Depth. | Ja grob. | Ja fuer Dorfslot. | Ja grob. | Noch nicht als globale Pflichtpipeline. | Plot-Profil muss DepthSupport und Containerbedarf nennen. |
| Inselgroesse aus Theme-Bedarf | 318, 320 | Inselkapazitaet entsteht aus Theme und Slotbedarf, nicht aus fixer Mini-Insel. | Ja. | Dorf-Beispiel. | Ja global. | Muss mit Word-Semantics gekoppelt werden. | Theme capacity plus semantic routing immer zusammen betrachten. |
| Backlog/Codex/Blueprint als sichere Fallbacks | 270, 271, 274, 278, 284, 287 | Fehlender Kontext, Safety, Depth oder Island fuehrt zu neutralen Fallbacks. | Nur indirekt. | Kaum. | Erwaehnt, aber nicht zentral. | Fallbacks fehlen in Plot-Capacity-Visualisierung als Pflichtausgang. | Jede Pipeline braucht Codex/Blueprint/Backlog als explizite Ausgaenge. |
| Kein `frame_started` | 254, 278, 289, 290, 318, 319, 320 | Kein Rohbau, Build-State oder Bauzustand aus Planung ableiten. | Ja. | Ja. | Ja. | Muss unveraendert bleiben. | `frame_started` bleibt eigener blockierter Build-State-Gate. |
| Aktionen/Verben sind keine statischen Objekte | 270, 271, 284, 283 | Verben werden ActionChallenge, Sequence, Dialog, Codex oder Backlog. | Nicht voll. | Nicht. | In Kategorien nur grob. | Build-Wheel koennte Aktionen als Objekte zeigen. | Verben nur als Aktion/Challenge/Quest ohne automatische Platzierung. |
| Emotionen/abstrakte Begriffe | 267, 270, 274, 284, 287 | Gefuehle und Abstrakta brauchen ContextCard, EmotionCue, CompanionDialog, Codex oder Backlog. | Nicht. | Nicht. | Sensitive/Special grob, aber nicht als Word-Type. | Kategorie-Matrix laesst Emotion/Abstract unterbelichtet. | Emotion/Abstract duerfen nicht als Gebaeude/Objekt erzwungen werden. |
| Kleine Objekte und ContainerItems | 255, 256, 264, 276, 277, 284 | TinyObjects gehoeren in Container/Detail/Challenge oder Fallback. | Kaum. | Kaum. | Containerbedarf erwaehnt. | Multi-Slot-Preview koennte zu viele Kleinteile vorbereiten. | TinyObjects nie dauerhaft in IslandView oder Plot-Uebersicht. |
| Water/Farm/Vehicle/Digital Spezialgates | 272, 273, 279, 283, 320 | Wasser, Farm, Fahrzeuge und Digitales brauchen eigene Systemkonzepte. | Teilweise. | Nur Vehicle/Farm im Dorf. | Ja als Kategorien. | Worttypen wie schwimmen/fahren/click brauchen Aktion/Sequence. | Spezialgates muessen Semantik und Systembedarf koppeln. |

## 4. Globale Pflicht-Pipeline

Jeder weitere World-/Island-/Plot-/Build-/Wheel-/Word-/Container-/Sensitive-/
Asset-Prompt muss diese Pipeline explizit pruefen:

```text
Word / User Intent
-> Context / Sense Check
-> Word Type Classification
-> Safety / Sensitive Check
-> Candidate ThemeIsland(s)
-> Candidate Plot Family / Depth Level
-> Representation Decision
   - WorldObject
   - PlotCandidate
   - BuildingCandidate
   - InteriorObject
   - ContainerItem
   - ActionChallenge
   - EmotionCue
   - ContextCard
   - Codex
   - Blueprint
   - Backlog
-> User Choice
-> Preview Only
-> Later Gate
```

Pflichtlesart:

- Nicht jedes Wort wird gebaut.
- Nicht jedes Wort hat ein Grundstueck.
- Nicht jedes Wort gehoert nur zu einer Kategorie.
- Nicht jedes Wort darf automatisch visualisiert werden.
- Eine ThemeIsland-Kategorie ist kein Placement-Befehl.
- Ein Build-Wheel-Kandidat ist keine Bauausfuehrung.
- Ein Preview-Zustand ist keine Persistenz, kein Asset und kein Build-State.

## 5. Beispielentscheidungen

| Wort | Moegliche Kontexte | Word Type / Risk | Sichere Entscheidung | Blockiert |
| --- | --- | --- | --- | --- |
| Haus | Zuhause/Alltag: Wohnhaus; Stadt: Gebaeude/Block/Adresse; Land/Farm: Bauernhaus; Kueste/Strand: Ferienhaus/Strandhaus gated | Multi-Home, BuildingCandidate | Nutzer-/Kontextentscheidung, dann Blueprint oder PreviewCandidate | Pflicht-Hausstart, automatische Platzierung, `frame_started` |
| Garage | Zuhause/Dorf: Utility; Verkehr/Fahrzeuge: Parking; Stadt: Parkhaus/Service | Multi-Home, Utility/Vehicle | Context/Sense vor Kategorie; ggf. Utility-/Vehicle-Gate | automatisch Zuhause oder Fahrzeuglogik |
| Baum | Garten/Natur: Baum; Stadt: Strassenbaum/Park; Farm/Land: Obstbaum | Nature/Decoration, Clutter | Natur-/Deko-/Clutter-Gate, ggf. PlotCandidate | Deko-Masse, TinyObject-Clutter |
| schwimmen | Kueste/Meer/Hafen oder Freizeit/Sport | Verb/Action, Water/Safety | ActionChallenge, QuestWithoutSymbol, ContextCard oder Backlog | Gebaeude, statisches Objekt, Water-System ohne Gate |
| Angst | Gefuehl/Emotion | Sensitive/Emotion | EmotionCue, CompanionDialog, ContextCard, Codex | Gebaeude, Reward, Drama, Retention-Druck |
| lernen | Aktion/Verb; Schule moeglich | Action/LearningMode | Challenge, Quest, LearningMode, ContextCard | automatisch Schulgebaeude |
| Messer | Kueche/Tool/Objekt; Safety-sensitive je Kontext | Tool, small object, possible sensitive | Container/Detail mit Safety/Sense, ggf. Codex | sichtbares Objekt ohne Gate |
| Polizei | Institution/Sicherheit/Notfall; Sensitive/Public Institution | Sensitive/Institution | ContextCard, Codex, RequiresUserChoice, Backlog | automatische Polizeiwache, Angst-/Notfallquest |

## 6. Bewertung M16-I / M16-J / M16-K

### M16-I

M16-I ist als Pipeline fuer ThemeIsland-Plot-Capacity brauchbar:

- Thema analysieren,
- benoetigte Grundstuecke ableiten,
- Groessen bestimmen,
- Inselkapazitaet ableiten,
- Slots austauschbar halten,
- Build-Wheel spaeter in-place planen.

Gap:

- Word-Type-Routing, Multi-Home-Woerter, Sensitive-/Abstract-Routen und
  Codex/Blueprint/Backlog-Fallbacks sind nicht tief genug als Pflichtfilter
  eingebettet.

### M16-J

M16-J ist brauchbar als Dorf-/Zuhause-/Alltag-Beispiel:

- mehrere Slotgroessen,
- Weg/Platz als Connector,
- austauschbare Slots,
- kein Build-Wheel-Code,
- kein Build-State.

Entscheidung:

- M16-J nicht als alleinigen naechsten Commit-/Code-Kandidaten behandeln.
- M16-J muss durch M16-K/M16-L global eingeordnet werden.
- Dorf/Zuhause bleibt Kandidat, aber nicht globale Grundlage.

### M16-K

M16-K ist brauchbar als globale Kategorie-/Plot-Capacity-Matrix:

- alle relevanten Kategorien werden gesammelt,
- M16-J wird als Dorf-Beispiel eingeordnet,
- Kueste/Hafen, Farm/Land, Stadt, Schule, Garten, Technik und Sensitive werden
  sichtbar.

Gap:

- Word-Type-Routing,
- Multi-Home-Regeln,
- Representation Decision,
- Codex/Blueprint/Backlog-Fallbacks,
- Sensitive/Abstract/Emotion/Action-Regeln,
- Container-/Depth-Pflichtausgaenge
  muessen noch explizit vor jeden spaeteren Slice geschaltet werden.

## 7. Zukuenftige Prompt-Regel

Vor jedem weiteren Codex-Prompt fuer World, Island, Plot, Build, Wheel, Word,
Container, Sensitive oder Asset muss geprueft werden:

| Pflichtfrage | Muss beantwortet sein? |
| --- | --- |
| Relevante bestehende Docs gelesen? | ja |
| Taxonomy beruecksichtigt? | ja |
| Word-to-Island Routing beruecksichtigt? | ja |
| Plot-Capabilities als Erlaubnisse beruecksichtigt? | ja |
| Sensitive Rules beruecksichtigt? | ja |
| Mobile/Clutter beruecksichtigt? | ja |
| Depth/Container beruecksichtigt? | ja |
| Multi-Home-Woerter beruecksichtigt? | ja |
| Codex/Blueprint/Backlog-Fallbacks beruecksichtigt? | ja |
| Stop-Regeln eingehalten? | ja |
| Visualisierung noetig? | falls sinnvoll, als Dokumentationspreview |

Wenn eine Frage nicht beantwortet ist, darf kein weiterer Implementierungs-,
Asset-, Build-Wheel-, Routing- oder `frame_started`-Schritt daraus abgeleitet
werden.

## 8. Dokumentationsvisualisierungen

M16-L ergaenzt echte PNG-Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_l_global_world_semantics_consistency_audit/`

Erzeugte Visuals:

- `01_global_semantics_decision_pipeline.png`
- `02_word_type_representation_map.png`
- `03_multi_home_word_examples.png`
- `04_m16_i_j_k_gap_map.png`
- `05_required_future_prompt_checklist.png`
- optional `00_contact_sheet.png`

Diese PNGs sind Dokumentationspreviews. Sie sind keine App-Screens, keine
Screenshots, keine finalen UI-PNGs, keine Spielassets und keine Dateien unter
`assets/`.

## 9. Entscheidung

M16-L empfiehlt:

- M16-I als Plot-Capacity-Pipeline behalten.
- M16-J als enges Dorf-Beispiel behalten, aber nicht als alleinige globale
  Grundlage committen oder in Code ueberfuehren.
- M16-K als globale Kategorie-/Plot-Capacity-Matrix behalten.
- Vor jedem weiteren Schritt zusaetzlich M16-L als Pflichtfilter lesen.
- Naechste Slices erst waehlen, wenn Kategoriebedarf und
  Word-Semantics-/Routing-/Representation-Regeln gemeinsam geprueft sind.

## 10. Stop-Regeln

Aus M16-L folgt ausdruecklich:

- Keine Implementierung.
- Keine Flutter-/Dart-Dateien.
- Keine App-Integration.
- Keine Route.
- Keine neue Seite.
- Keine Build-Wheel-Implementierung.
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
