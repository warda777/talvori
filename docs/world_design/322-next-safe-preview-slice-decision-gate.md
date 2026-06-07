# M16-M: Next Safe Preview Slice Decision Gate

Stand: 2026-06-07

Status: `Entscheidungs-Gate gestartet / keine Implementierung`

## 1. Ziel

M16-M entscheidet nach M16-I, M16-J, M16-K und M16-L, welcher naechste kleine
lokale Preview-Slice sinnvoll ist, ohne die Architektur wieder auf Dorf/
Zuhause, feste Slots, Build-Wheel oder sichtbares Bauen zu verengen.

M16-M ist nur Dokumentation, Entscheidung und Visualisierung. Daraus folgen
keine Flutter-/Dart-Dateien, keine App-Integration, keine Route, keine neue
Seite, keine Build-Wheel-Implementierung, keine Tests, keine Screenshots,
keine Runtime-Konfiguration, keine Persistenz, keine Assets, keine
automatische Wortplatzierung, kein Build-State, kein `frame_started` und keine
Bauzustaende.

## 2. Gepruefte Grundlage

| Dokument | Relevanz fuer M16-M |
| --- | --- |
| `docs/world_design/318-theme-island-plot-capacity-and-build-wheel-plan.md` | Theme -> Plotbedarf -> Groessen -> Kapazitaet -> austauschbare Slots -> spaeteres In-Place Build-Wheel. |
| `docs/world_design/319-village-plot-capacity-local-preview-scope.md` | Dorf/Zuhause/Alltag ist ein brauchbares, aber enges Beispiel. |
| `docs/world_design/320-global-theme-island-plot-capacity-matrix.md` | Globale Kategorien verhindern, dass der naechste Schritt nur Dorf/Zuhause wird. |
| `docs/world_design/321-global-world-semantics-consistency-audit.md` | Pflichtfilter: Context/Sense, Word-Type, Safety, Representation Decision, Fallbacks, User Choice. |
| `docs/world_design/270-word-to-island-routing-matrix.md` | Routing macht Vorschlaege, keine automatische Platzierung; Multi-Home und Fallbacks sind zentral. |
| `docs/world_design/272-plot-capability-derivation.md` | `allowedFunctions` sind Erlaubnisse, keine Pflichtbelegung. |
| `docs/world_design/274-sensitive-content-representation-rules.md` | Sensitive/abstract Begriffe gehen neutral in Codex, ContextCard, Backlog oder RequiresUserChoice. |
| `docs/world_design/276-mobile-clutter-rules-small-objects.md` | Kleine Objekte, Container und Labels duerfen Mobile-Ansichten nicht ueberladen. |
| `docs/world_design/283-theme-island-capability-sheets.md` | Kategorien haben unterschiedliche Worttypen, Depth-Beispiele, Risiken und Gates. |
| `docs/world_design/284-word-to-island-ux-flow.md` | Ein Wort darf erst sichtbar werden, wenn Theme, Depth, Safety, Placement-Anforderung und Nutzerentscheidung passen. |

## 3. Bewertungslogik

Bewertungsskala:

- `5`: sehr stark / sehr sicher
- `4`: gut
- `3`: brauchbar, aber mit klarer Vorsicht
- `2`: riskant oder zu frueh
- `1`: aktuell blockiert

| Candidate | Architecture Safety | Game Feel | Misread Risk Control | M16-L Pipeline Fit | Mobile Readability | No-Asset Visualizability | Auto-Placement Safety | Build-State Safety | Next Code Value | Decision |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `VillagePlotCapacityPreview` | 3 | 4 | 2 | 3 | 3 | 4 | 3 | 3 | 3 | Zurueckstellen; als Dorf-Beispiel brauchbar, aber zu eng als naechster Schritt. |
| `GlobalThemeIslandPreviewSelector` | 3 | 3 | 2 | 4 | 4 | 5 | 4 | 4 | 3 | Zurueckstellen; Breite gut, aber kann wie echtes Onboarding wirken. |
| `CoastHarborPlotCapacityPreview` | 3 | 4 | 2 | 3 | 2 | 4 | 3 | 3 | 4 | Spaeter starkes Gegenbeispiel, aber Water/Dock/Boat-Misread ist jetzt zu hoch. |
| `WordSemanticsDecisionPreview` | 5 | 2 | 5 | 5 | 5 | 5 | 5 | 5 | 4 | Empfohlen als naechster Preview-Slice. |
| `BuildWheelOverlayPreviewPlan` | 2 | 4 | 2 | 3 | 3 | 4 | 2 | 2 | 2 | Zu frueh; Wheel braucht vorher Semantik- und Plot-Profile im Preview. |

## 4. Kandidatenbewertung

### 4.1 `VillagePlotCapacityPreview`

Nutzen:

- macht M16-I praktisch sichtbarer,
- zeigt mehrere Slotgroessen,
- kann lokale Slotauswahl ohne Assets vorbereiten.

Risiken:

- verengt wieder auf Dorf/Zuhause/Alltag,
- kann Haus/Garage/Garten als feste Richtung lesen lassen,
- kann M16-L unterlaufen, wenn Word-Type und Fallbacks nicht sichtbar sind.

Entscheidung:

Aktuell nicht als naechster Slice empfehlen. Brauchbar spaeter, wenn M16-L als
Semantikfilter im Preview sichtbar ist.

### 4.2 `GlobalThemeIslandPreviewSelector`

Nutzen:

- zeigt globale Breite,
- verhindert Dorf-Monokultur,
- laesst Kategorien vergleichen.

Risiken:

- kann wie echtes Onboarding oder Foundation Choice 2.0 wirken,
- kann Nutzerwahl vor Word/Sense/Representation zu stark betonen,
- koennte als App-Flow oder Route missverstanden werden.

Entscheidung:

Nicht als naechster Slice. Erst nach Semantics Decision Preview sinnvoller.

### 4.3 `CoastHarborPlotCapacityPreview`

Nutzen:

- starkes Gegenbeispiel zu Dorf,
- beweist andere Plot-Familien: Wasser, Strand, Pier, Dock, Lager, Reserve,
- spielnaher als reine Semantik.

Risiken:

- Wasser-, Dock-, Boot- und Travel-Systeme koennen zu frueh impliziert werden,
- Mobile-Clutter und kleine Hafenobjekte sind riskanter,
- kann Asset- oder Weltbild-Erwartung erzeugen.

Entscheidung:

Guter spaeterer Kandidat nach `WordSemanticsDecisionPreview`. Jetzt noch zu
systemnah.

### 4.4 `WordSemanticsDecisionPreview`

Nutzen:

- setzt M16-L direkt in eine sichtbare lokale Preview-Idee um,
- zeigt, warum ein Wort nicht automatisch gebaut wird,
- macht Multi-Home, Word-Type, Sensitive, Container, Codex, Blueprint und
  Backlog als sichere Ausgaenge sichtbar,
- schuetzt spaetere Dorf-, Kueste-, Wheel- und Build-Slices vor falscher
  Implementierungsableitung.

Risiken:

- weniger spielnah als Insel- oder Plot-Preview,
- kann trocken wirken, wenn es als Admin-Matrix statt als kleine Tali/Vori-
  Entscheidungskarte gestaltet wird.

Gegenmassnahme:

Als lokale, kleine, produktnahe Preview mit Beispielkarten planen, nicht als
technisches Routing-Panel:

- `Haus` als Multi-Home,
- `Garage` als Kontextfall,
- `schwimmen` als Aktion/Water-Gate,
- `Angst` als Emotion/ContextCard,
- `Messer` als Container/Safety,
- `Polizei` als Sensitive/Policy-Gate.

Entscheidung:

Empfohlen als genau ein naechster Preview-Slice.

### 4.5 `BuildWheelOverlayPreviewPlan`

Nutzen:

- wichtig fuer spaetere UX,
- in-place statt neue Seite,
- visuell nah am Weltbau.

Risiken:

- zu frueh, wenn Build-Wheel-Kandidaten noch keine Word-Type-/Safety-/Plot-
  Entscheidungen respektieren,
- kann wie Bau- oder Assetfreigabe wirken,
- erhoeht `frame_started`- und Build-State-Misread.

Entscheidung:

Blockiert fuer jetzt. Erst nach Semantics Preview und mindestens einem
gated Plot-Capacity-Preview sinnvoll.

## 5. Entscheidungsempfehlung

Empfohlener naechster Preview-Slice:

`WordSemanticsDecisionPreview`

Begruendung:

- Er ist der sicherste Kandidat gegen automatische Wortplatzierung.
- Er staerkt die M16-L-Pflichtpipeline, bevor weitere Welt-/Plot-Visuals zu
  konkret werden.
- Er verhindert, dass Dorf/Zuhause oder Kueste/Hafen als direkter Baupfad
  gelesen werden.
- Er benoetigt keine Assets, keine Route, keine Persistenz, keine Runtime-
  Konfiguration und keinen Build-State.
- Er kann spaeter als lokales Preview-Widget oder Dokumentationspreview
  sichtbar machen, warum Talvori vorschlaegt, fragt, verschiebt oder neutral
  in Codex/Blueprint/Backlog bleibt.

Nicht empfohlen als naechster Schritt:

- `VillagePlotCapacityPreview`, weil es wieder zu eng in Dorf/Zuhause fuehrt.
- `GlobalThemeIslandPreviewSelector`, weil es wie echtes Onboarding wirken
  kann.
- `CoastHarborPlotCapacityPreview`, weil Water/Dock/Boat-Misreads noch zu
  riskant sind.
- `BuildWheelOverlayPreviewPlan`, weil Wheel-UX ohne Semantics Preview zu
  frueh nach Bauen aussieht.

## 6. Erlaubter spaeterer Minimal-Scope fuer den empfohlenen Kandidaten

Ein spaeterer `WordSemanticsDecisionPreview`-Slice duerfte hoechstens:

- lokal und isoliert Beispielwoerter anzeigen,
- Context/Sense, Word-Type, Safety und Representation Decision sichtbar
  machen,
- moegliche Ausgaenge wie `PlacementCandidate`, `Blueprint`, `Codex`,
  `Backlog`, `ContextCard`, `ActionChallenge` oder `ContainerItem` zeigen,
- Nutzerentscheidung als Preview-Zustand darstellen,
- klar zeigen: keine Speicherung, keine Platzierung, kein Bauzustand.

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

## 7. Dokumentationsvisualisierungen

M16-M ergaenzt echte PNG-Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_m_next_safe_preview_slice_decision_gate/`

Erzeugte Visuals:

- `01_candidate_comparison_matrix.png`
- `02_risk_vs_value_map.png`
- `03_recommended_next_slice_flow.png`
- `04_allowed_vs_blocked_next_slice_scope.png`
- optional `00_contact_sheet.png`

Diese PNGs sind Dokumentationspreviews. Sie sind keine App-Screens, keine
Screenshots, keine finalen UI-PNGs, keine Spielassets und keine Dateien unter
`assets/`.

Quality Note fuer M16-M2:

Kuenftige Dokumentationsvisualisierungen muessen nicht nur Text-Containment
pruefen, sondern auch ausreichend Innenabstand, Abstand zwischen Karten,
ueberlappungsfreie Karten, Labels, Pfeile, Titel, Footer und Legenden, ein
ueberlappungsfreies Contact Sheet sowie nicht abgeschnittene Inhalte.

## 8. Stop-Regeln

Aus M16-M folgt ausdruecklich:

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
