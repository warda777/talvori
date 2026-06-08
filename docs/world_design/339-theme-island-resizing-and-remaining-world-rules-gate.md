# M16-AE: ThemeIsland Resizing and Remaining World Rules Gate

Stand: 2026-06-08

Status: `Planungs-/Gate-Slice / keine Implementierung`

## 1. Zweck

M16-AE schliesst die noch offenen oder teilweise erledigten world-nahen Regeln
aus M16-T:

- Plot-Capability wird als verbindliche Stop-Regel fuer spaetere Plot-,
  World- und BuildChoice-Slices fixiert.
- ThemeIsland-Resizing wird fachlich als Aenderbarkeitsmodell geplant.
- TinyObject-/Container-Regeln werden final gegen IslandView-Clutter
  abgesichert.
- Sensitive-safe Asset-Regeln werden vorbereitet, ohne Assets freizugeben.

Dieser Slice gibt keinen World-Code, keinen Build-State, keine Persistenz und
keine Assets frei.

## 2. Non-Goals und harte Stop-Regeln

M16-AE erzeugt nicht:

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
- keine Reward Bridge,
- keine automatische Wortplatzierung,
- kein Build-Wheel-Code,
- keine Assets,
- keine Asset-Dateien unter `assets/`,
- kein Build-State,
- kein `frame_started`,
- keine Bauzustaende.

M16-AE ist keine Assetfreigabe, keine ThemeIsland-Implementierung, keine
Resizing-Implementierung und keine Runtime-Logik.

## 3. Gelesene Grundlagen

| Dokument | Relevanz fuer M16-AE |
| --- | --- |
| `328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrende M16-T-ID-Liste und Dashboard. |
| `336-documentation-map-and-slice-reading-rules.md` | Pflichtlektuere- und Output-Regeln fuer World-/Asset-/Docs-Slices. |
| `338-world-loop-plot-family-and-buildchoice-gate.md` | World Loop, Plot-Familien, BuildChoice und Undo-Grenzen. |
| `337-mobile-density-accessibility-and-depth-planning-gate.md` | TinyObject-, Container-, Mobile- und Accessibility-Grenzen. |
| `333-minimal-semantic-profile-and-routing-priority-gate.md` | Safety/Sense/Clutter/Confidence vor Capability und Reward. |
| `334-companion-and-sensitive-return-safety-gate.md` | Sensitive und Companion duerfen keine Reward-/Placement-Ausloeser sein. |
| `331-minimal-word-outcome-detail-gate.md` | Outcomes, Queue-Ausgaenge, Reward/Placement/BuildState-Trennung. |
| `318-theme-island-plot-capacity-and-build-wheel-plan.md` | Theme -> Plotbedarf -> Groessenmix -> Slot-Auswahl -> spaeteres Gate. |
| `320-global-theme-island-plot-capacity-matrix.md` | Globale Kategorien und unterschiedliche Capacity-Profile. |
| `272-plot-capability-derivation.md` | Plot-Capability ist Erlaubnis, keine Pflichtbelegung. |
| `276-mobile-clutter-rules-small-objects.md` | TinyObjects und ContainerItems duerfen IslandView nicht ueberladen. |
| `274-sensitive-content-representation-rules.md` | Sensitive Inhalte nicht automatisch als Gebaeude, Symbol, Objekt oder Reward. |
| `289-asset-prioritization-scope-gate.md` | Assets folgen aus Produktentscheidungen, nicht aus Taxonomy oder Semantik. |
| `assets/images/world/buildable_islands/forest_clearing/template.md` | Waldlichtung bleibt Starter-/Testform; keine App-/Assetfreigabe. |

## 4. Betroffene M16-T-IDs

| ID | M16-AE-Entscheidung |
| --- | --- |
| `M16T-WORLD-004` | Plot-Capability ist als verbindliche Stop-Regel fuer spaetere Slices fixiert. |
| `M16T-UNDO-003` | ThemeIsland-Resizing ist fachlich geplant, ohne Runtime- oder Migration-Freigabe. |
| `M16T-DEPTH-003` | TinyObject-/Container-Regel ist final gegen eigene Grundstuecke und Objektwolken abgesichert. |
| `M16T-ASSET-003` | Sensitive-safe Asset-Regeln sind als Policy-Vorbereitung dokumentiert, ohne Assetfreigabe. |

## 5. Plot-Capability als verbindliche Stop-Regel

Capability ist Erlaubnis, keine Pflichtbelegung.

Verbindliche Stop-Regel fuer jeden spaeteren Plot-/World-/BuildChoice-Slice:

- Capability darf nie automatisch Placement erzeugen.
- Capability darf nie BuildState erzeugen.
- Capability darf nie Asset erzeugen.
- Capability darf nie Persistenz erzeugen.
- Capability darf nie `frame_started` erzeugen.
- Capability darf nie SRS-/`word_progress` veraendern.
- Capability darf nie eine App-Route oder produktive Navigation erzeugen.
- Jeder spaetere Plot-/World-/BuildChoice-Slice muss diese Regel wiederholen.
- Bei Unsicherheit gewinnt Safe Default, Backlog, `CodexOnly`, `ContextCard`
  oder `Later`.

Erlaubte Lesart:

```text
WorldCandidate
-> Candidate ThemeIsland
-> Candidate Plot Family
-> Capability Check
-> User Choice / Later
-> Preview Only
-> Later Gate
```

Blockierte Lesart:

```text
Word
-> Capability
-> Slot belegt
-> Asset erzeugt
-> BuildState
-> frame_started
```

Capability bleibt also ein Filter fuer spaetere Moeglichkeiten, nicht der
Startpunkt fuer eine Weltmutation.

## 6. ThemeIsland-Resizing

ThemeIsland-Resizing ist in M16-AE ein fachliches Anpassungsmodell. Es ist
keine Runtime-Logik, keine Migration, keine Layout-Engine und keine
Implementierungsfreigabe.

Eine ThemeIsland darf spaeter:

- wachsen,
- Reserveflaechen nutzen,
- Slots umsortieren,
- neue Plot-Familien aufnehmen,
- alte Entscheidungen erklaerbar halten,
- Entscheidungen reversibel machen,
- sensitive oder clutter-relevante Bereiche in sichere Fallbacks verschieben.

Verbindliche Resizing-Regeln:

- Alte Entscheidungen duerfen nicht kaputtgehen.
- Nutzerentscheidungen muessen erklaerbar und reversibel bleiben.
- Resizing darf keine Migration ohne Gate erzeugen.
- Resizing darf keine automatische Neubelegung erzeugen.
- Resizing darf keine Assets erzeugen.
- Resizing darf keine BuildStates erzeugen.
- Resizing darf kein `frame_started` erzeugen.
- Resizing darf keine Persistenz schreiben.
- Resizing bleibt Planungsmodell, keine Runtime-Konfiguration.

### 6.1 Resizing-Faelle

| Fall | Sichere Reaktion | Blockiert |
| --- | --- | --- |
| Neues Thema kommt hinzu | neue Candidate-Familie oder Reservebedarf dokumentieren | automatische Inselmutation |
| Viele Woerter landen in einer Kategorie | Review Queue, Backlog, Codex, Reserveplanung | Objekt-/Plot-Masse sichtbar machen |
| Bisherige Insel ist zu klein | Groessenmix neu planen, Reserveflaeche vormerken | Migration oder Layout-Write ohne Gate |
| Sensitive/Policy aendert einen Bereich | `SensitiveGated`, Hide, Later, ContextCard | altes sichtbares Symbol behalten |
| TinyObjects muessen in Container verschoben werden | Container/Depth-Pfad und Findability planen | Minipixel in IslandView |
| Nutzer will andere Insel-/Plot-Zuordnung | Change, Later, Backlog, neue Candidate-Familie | irreversible Zuordnung |

### 6.2 Resizing-Operationen als Planung

| Operation | Zweck | Erlaubt in M16-AE | Blockiert |
| --- | --- | --- | --- |
| Grow | mehr thematischer Bedarf | Bedarf dokumentieren | Runtime-Layout |
| Reserve | Platz fuer spaetere Gates | Reserve als Planungsannahme | Unlock-Druck |
| Reorder | Lesbarkeit oder Sense verbessert sich | neue Reihenfolge beschreiben | Migration |
| Split | Kategorie wird zu gross oder sensibel | Teilbereich/Fallback planen | neue ThemeIsland bauen |
| Merge | kleine Bereiche werden ruhiger zusammengefasst | Clutter reduzieren | Datenmodell schreiben |
| Move to Depth | TinyObjects/Interior verlagern | Container-Pfad planen | Persistenz |

## 7. TinyObject-/Container-Regel

Kleine Objekte bekommen nicht automatisch eigene Grundstuecke.

Verbindliche Regeln:

- TinyObjects gehen bevorzugt in `ContainerItem`, `CodexOnly`, `Backlog`,
  `ContextCard` oder `Later`.
- IslandView darf nicht zur Objektwolke werden.
- Container/Depth ist kein BuildState.
- Container/Depth ist keine Persistenz.
- Container/Depth ist keine Assetfreigabe.
- Container/Depth braucht spaeter Auffindbarkeit.
- Container sind Fokusraeume, keine 20-Objekte-Listen.
- Kleine Objekte duerfen nicht als Minipixel auf der Insel verpflichtend
  sichtbar werden.

Beispiele:

| Wort | Sichere Regel | Blockiert |
| --- | --- | --- |
| Schluessel | `ContainerItem`, Codex, Backlog, spaeter Container-Pfad | eigener Plot, Minipixel |
| Messer | `ContainerItem` plus Safety/Context oder `SensitiveGated` | sichtbares Tool ohne Gate |
| Loeffel | Kueche -> Schublade -> 3-5 Fokusobjekte | Besteckwolke |
| Bleistift | Schule -> Federmappe -> Detail/Context | IslandView-Dauerobjekt |
| Samen | Beet/Container/Backlog, keine Growth-Logik | Timer-/Produktionsloop |
| Werkzeug | Werkbank/Kiste/Container, nicht jedes Tool sichtbar | Tool-Asset-Masse |
| Tasse | Kueche/Codex/Container, optional ContextCard | eigener Plot |

## 8. Sensitive-safe Asset-Regeln

Sensitive-safe Asset-Regeln werden in M16-AE nur fachlich vorbereitet. Es
entstehen keine Assets und keine Asset-Dateien unter `assets/`.

Verbindliche Regeln:

- Sensitive Inhalte erzeugen keine Assets.
- Sensitive Inhalte sind keine Deko.
- Sensitive Inhalte sind kein Reward.
- Sensitive Inhalte sind keine Retention-Trigger.
- Sensitive Inhalte bekommen keine Symbolpflicht.
- Sensitive Inhalte duerfen nicht dramatisiert werden.
- Falls spaeter ein Symbol noetig wird, muss es neutral, optional,
  policy-geprueft und nicht dramatisierend sein.
- Kein Asset-Scope ohne eigenes Asset-Gate.
- Keine automatische Asset-Ableitung aus Wort, Semantik, Taxonomy, Routing,
  Plot-Capability, BuildChoice oder Review Queue.

Beispiele:

| Begriff | Sicherer Ausgang | Blockiert |
| --- | --- | --- |
| Polizei | `SensitiveGated`, `ContextCard`, Codex, Later/Hide | Polizeiwache als Reward |
| Angst | `ContextCard`, Companion optional, Codex, Later | Symbol, Druck, Drama |
| Krankheit | Codex, ContextCard, SensitiveGated | medizinische Beratung, Klinik-Asset |
| Gericht | ContextCard, Codex, Backlog, Policy Gate | Richter-/Gerichtsasset ohne Gate |
| Religion | Codex, ContextCard, Opt-in Gate | pauschales Symbol |
| Krieg | Hide, Later, ContextCard, SensitiveGated | Deko, Quest, Reward |
| Notfall | ContextCard, Codex, SensitiveGated | Alarm-/Druckmechanik |

Sensitive-safe Asset-Regeln gelten auch dann, wenn ein Begriff scheinbar gut zu
einer ThemeIsland, Plot-Familie oder Capability passt.

## 9. Verbindliche World-Regelkarte

| Konzept | Verbindliche Lesart | Nicht erlaubt |
| --- | --- | --- |
| Word Outcome | Candidate oder Fallback. | Placement. |
| Plot Family | Erlaubnisrahmen. | Pflichtbelegung. |
| Capability | Moeglichkeit. | Build. |
| BuildChoice | Auswahlmoeglichkeit. | BuildState. |
| Resizing | Anpassbarkeit. | Migration. |
| TinyObject | Container/Depth oder Fallback. | eigenes Grundstueck. |
| Sensitive | Gate/Fallback. | Symbol, Deko oder Reward. |
| Asset | eigenes Gate. | Semantik-Ergebnis. |

Diese Karte muss vor spaeteren World-/Plot-/BuildChoice-/Asset-Slices als
Pflichtfilter gelesen werden.

## 10. Beispiele

| Beispiel | Sichere M16-AE-Regel | Blockiert |
| --- | --- | --- |
| Haus | Multi-Home; Plot-Familie erst nach Sense/User Choice. | Pflicht-Hausstart, automatische Belegung. |
| Garage | Zuhause, Verkehr oder Stadt; Capability nur Candidate. | Fahrzeuglogik oder Auto-Zuhause. |
| Baum | Landmarke oder Backlog mit Clutter-Gate. | Baumwolke, Deko-Spam, Auto-Asset. |
| Garten | grosse/flexible Plot-Familie, Growth/Fairness spaeter. | Timer-/Produktionslogik. |
| Hafen | Water/Harbor braucht eigenes Water-/Path-/Safety-Gate. | Wasser-/Bootssystem. |
| Schule | learning/school nur nach Kontext; Verb `lernen` bleibt getrennt. | Pflicht-Schulgebaeude. |
| Kueche | eher Interior/Container/Depth. | jedes Kuechenobjekt als Inselobjekt. |
| Schluessel | TinyObject -> Container/Codex/Backlog. | eigener Plot, Minipixel. |
| Messer | Container plus Safety/Context. | sichtbares Tool ohne Gate. |
| Loeffel | Container-Fokusobjekt. | Besteckliste als UI. |
| Polizei | Sensitive/Public Institution. | Polizeiwache, Symbolpflicht, Reward. |
| Angst | Emotion/abstrakt, neutraler Context. | dramatisches Objekt. |
| Bank | Sense klaeren: Sitzbank, Geldinstitut, Flussufer. | Default-Sense als Platzierung. |
| 100 Woerter in einer ThemeIsland | Queue, Backlog, Codex, Reserveplanung. | 100 sichtbare Objekte/Plots. |
| ThemeIsland muss erweitert werden | Resizing-Plan, Reserve, Split/Move to Depth. | Migration oder automatische Neubelegung. |

## 11. Gate-Entscheidung

M16-AE schliesst die offenen world-nahen Planungsregeln fuer:

- Capability als Stop-Regel,
- ThemeIsland-Resizing,
- TinyObject-/Container-Regel,
- sensitive-safe Asset-Regeln.

Weiterhin blockiert bleiben:

- echte World-/Plot-/ThemeIsland-Implementierung,
- Build-Wheel-Code,
- BuildState,
- `frame_started`,
- Persistenz,
- Supabase/local DB Writes,
- SRS-/`word_progress`-Aenderungen,
- Assets und Asset-Dateien unter `assets/`,
- automatische Wortplatzierung,
- App-Integration und Route.

## 12. Visualisierungen

Dokumentationsvisualisierungen liegen unter:

`docs/world_design/previews/m16_ae_theme_island_resizing_world_rules/`

Erwartete PNGs:

- `00_contact_sheet.png`
- `capability_stop_rule.png`
- `theme_island_resizing_flow.png`
- `tinyobject_container_rule.png`
- `sensitive_safe_asset_ladder.png`
- `remaining_world_rules_summary.png`

Visual-QA-Regel:

- Text bleibt in Karten/Rahmen/Panels.
- Ausreichender Innenabstand.
- Kartenabstaende.
- Keine Ueberlappung von Karten, Labels, Pfeilen, Titeln, Footern oder Legenden.
- Contact Sheet vollstaendig lesbar.
- Keine abgeschnittenen Inhalte.

## 13. Update fuer M16-T

M16-AE setzt passend auf erledigt:

- `M16T-WORLD-004`
- `M16T-UNDO-003`
- `M16T-DEPTH-003`
- `M16T-ASSET-003`

Bewusst weiter offen, teilweise oder blockiert:

- `M16T-WORLD-002` bleibt teilweise, weil ThemeIsland-/Plot-Capacity in
  konkreten spaeteren Slices angewendet werden muss.
- `M16T-ASSET-001` bleibt blockiert; M16-AE gibt keine Assets frei.
- `M16T-ASSET-002` bleibt teilweise; jeder Word-/World-Slice muss weiterhin
  keine Auto-Assets aus Semantik ableiten.
- `M16T-ASSET-004` bleibt offen; Lizenz-/Quelle-/Benennung-Regeln brauchen
  eigenes Asset-Gate.
- `M16T-WHEEL-001` bleibt blockiert; Build-Wheel-Code bleibt gesperrt.
- `M16T-WHEEL-003` bleibt teilweise; kein Wheel-Slice ist freigegeben.

## 14. Checks

Nach Erstellung auszufuehren:

- `git diff --check`
- `git status --short`
- Scope-Check gegen `lib/`, `assets/`, `test/`, `integration_test/`

Erwarteter Scope:

- `docs/world_design/339-theme-island-resizing-and-remaining-world-rules-gate.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/previews/m16_ae_theme_island_resizing_world_rules/`

Nicht erwartet:

- Aenderungen unter `lib/`,
- Aenderungen unter `assets/`,
- Tests,
- Routen,
- App-Integration,
- Persistenz.
