# Phase 2G-M12-C: Plot-Capability Derivation

Stand: 2026-06-06

Status: `Planungs- und Visualisierungsblock gestartet`

## 1. Zweck

Dieses Dokument leitet aus Taxonomy, ThemeIsland-Priorisierung und
Word-to-Island Routing ab, welche Plot-Slots welche Funktionen erlauben
duerfen.

M12-C ist:

- Planungsgrundlage,
- Previewgrundlage,
- keine finale Datenstruktur,
- keine Runtime-Konfiguration,
- keine ThemeIsland-Umsetzung,
- keine Plot-Implementierung,
- keine Assetfreigabe,
- keine App-Integration,
- keine Freigabe fuer `frame_started`.

M12-C beantwortet:

- Welche Plotgroessen tragen welche Funktionen?
- Welche Depth-Ebenen sind pro Plottyp plausibel?
- Welche Funktionen passen zu Early ThemeIslands?
- Welche Mid/Late/Special-Themen brauchen zusaetzliche Regeln?
- Welche Risiken stoppen eine spaetere Umsetzung?

M12-C platziert nichts automatisch. Plot-Capabilities beschreiben nur, welche
Funktionen ein Plot theoretisch tragen darf.

## 2. Capability-Grundbegriffe

### `plotSize`

| Wert | Bedeutung | Typische Nutzung |
| --- | --- | --- |
| `small` | kleiner Einzelbereich | Deko, Beet, kleiner Fokuspunkt, Objektgruppe |
| `small_medium` | kleiner bis mittlerer Plot | kleiner Garten, kleiner Lernbereich, einfache Werkbank |
| `medium` | Standard-Plot | Zuhause, kleines Schul-/Lerngebaeude, Workshop, Interior |
| `large_edge` | groesserer Randplot | Naturbereich, Farmrand, groesserer Garten, Uebergangszone |
| `hub` | zentraler oder sozialer Plot | LearningHub, Markt, Service, Treffpunkt |
| `edge` | Rand-, Wasser-, Natur- oder Expansionsplot | Wasser, Dock, Farmkante, Naturkante, Expansion |

### `allowedFunctions`

| Funktion | Bedeutung | Erste Lesart |
| --- | --- | --- |
| `home` | Wohn-/Alltagsbereich | Early, aber nie Pflicht-Hausstart |
| `garden` | Garten, Beet, Pflanzen, Hof | Early |
| `learningHub` | Lernzentrum, Tali/Vori-Impuls, Aufgabenpunkt | Early |
| `market` | Markt, Shop, kleiner Handel | Mid oder Hub |
| `food` | Essen, Zutaten, Kueche, Restaurant | Early/Mid je nach Kontext |
| `workshop` | Werkbank, kleine Werkstatt, Tools | Early klein, spaeter komplexer |
| `school` | Schule, Lernmaterial, Klassenzimmer | Early |
| `nature` | Natur, Park, Wald, Pflanzen, Tiere | Early/Mid |
| `water` | Wasser, Hafen, Kueste, Dock | Mid, eigene Regeln |
| `travel` | Reisen, Weg, Boot, Verkehr | Mid/Late, eigene Systeme |
| `social` | Treffpunkt, kleine soziale Interaktion | Early klein, spaeter komplexer |
| `decoration` | Atmosphaere, Deko, kleine Details | immer begrenzt durch Clutter-Regeln |
| `path` | Weg, Connector, Zugang | technische Voraussetzung |
| `expansion` | Erweiterungsrand, Unlock, Inselwachstum | spaeter |

### `requiredAdjacency`

| Wert | Bedeutung |
| --- | --- |
| `path` | braucht Anschluss an Weg oder Connector |
| `water` | braucht Wasser-/Uferkante |
| `market` | braucht Hub-, Markt- oder Service-Nahe |
| `nature` | braucht Natur-, Garten- oder Randnahe |
| `residential` | braucht Wohn-/Alltagsnahe |
| `farm` | braucht Farm-, Garten- oder Naturkontext |
| `none` | keine harte Nachbarschaft im Planungsstand |

### `depthSupport`

| Wert | Bedeutung |
| --- | --- |
| `exteriorOnly` | nur Aussenbereich oder Fokuszone |
| `buildingExterior` | Gebaeude von aussen moeglich |
| `interiorAllowed` | Innenraum/Room View erlaubt |
| `containerAllowed` | Container/Fokusobjekt mit inneren Objekten erlaubt |
| `sequenceAllowed` | Aktionen, Mini-Sequenzen oder Prozessschritte erlaubt |

### `riskFlags`

| Wert | Bedeutung |
| --- | --- |
| `clutterRisk` | Kleinteile/Deko koennen ueberladen |
| `mobileRisk` | mobile Lesbarkeit oder Bedienung riskant |
| `sensitiveRisk` | Inhalt braucht Safety-/Darstellungsregeln |
| `systemComplexity` | braucht eigenes System, z. B. Fahrzeuge, Produktion, Timers |
| `needsOwnRules` | vor Umsetzung eigener Planungsblock noetig |

## 3. Early ThemeIsland Plot-Capabilities

### Zuhause / Alltag

Moegliche Plot-Funktionen:

- `home`
- `garden`
- `decoration`
- `path`
- `learningHub`
- `workshop` klein/spaeter

Typische Depth:

- Gebaeude aussen,
- Innenraum,
- Container,
- DetailObject.

Passende Plottypen:

- `core_plot`
- `core_edge_plot`
- `residential_capable_plot`
- `connector_plot`
- kleiner `hub_capable_plot` fuer LearningHub.

Risiken:

- kein Pflicht-Hausstart erzwingen,
- Gebaeudeteile brauchen Gebaeudezustand oder Blueprint,
- zu viele Haushaltsobjekte brauchen M12-E Clutter-Regeln,
- Interior und Container duerfen nicht zu frueh als Runtime-System gelesen
  werden.

### Schule / Lernen

Moegliche Plot-Funktionen:

- `school`
- `learningHub`
- `decoration`
- `path`
- `social` klein/spaeter

Typische Depth:

- Klassenzimmer,
- Regal,
- Federmappe,
- Schreibtisch,
- DetailObject.

Passende Plottypen:

- `core_plot`
- `hub_capable_plot`
- `connector_plot`
- `core_edge_plot` fuer kleinere Lern-/Aussenbereiche.

Risiken:

- viele Kleinteile,
- Mobile-Clutter,
- Schule darf nicht zu voll oder trocken wirken,
- Social-Funktionen brauchen spaeter eigene Grenzen.

### Garten / Natur nah

Moegliche Plot-Funktionen:

- `garden`
- `nature`
- `decoration`
- `path`
- `food` klein/spaeter
- `workshop` klein/spaeter

Typische Depth:

- Beet,
- Pflanzkiste,
- Geraeteecke,
- Pflanzenwachstum,
- Mini-Sequenz spaeter.

Passende Plottypen:

- `core_edge_plot`
- `edge_nature_capable_plot`
- `edge_farm_capable_plot` nur klein/spaeter,
- `connector_plot`
- kleiner `core_plot` fuer Hof/Garten.

Risiken:

- Timer/Fairness,
- Wachstum darf nicht manipulativ wirken,
- viele Pflanzen/Deko koennen ueberladen,
- Farm-/Produktionslogik darf nicht heimlich gestartet werden.

## 4. Mid/Late/Sensitive Plot-Grenzen

| Thema | Plot-Grenze | Warum nicht Early |
| --- | --- | --- |
| Kueste / Meer / Hafen | braucht `water`-capable Plots, path/dock/edge adjacency | mobile und systemische Komplexitaet, Dock/Boot/Navigation |
| Essen / Restaurant / Cafe | braucht `food`, Service, Interior, Container | darf nicht zur Objektliste werden; Bestellungen/Dialog brauchen Regeln |
| Einkauf / Versorgung | braucht `market`, Service, Hub | viele Waren und Regale erzeugen starke Clutter-Gefahr |
| Land / Farm | braucht `farm`, `nature`, `garden` | Wachstum, Produktion und Tiere brauchen eigene Regeln |
| Stadt / Dorfzentrum | braucht Hub, Social, Path, Markt, Services | zu viele Systeme und dichte Zonen fuer Early |
| Reisen / Verkehr | braucht Connector, Path, Vehicle, Travel | Fahrzeuge und Wege brauchen eigenes Konzept |
| Arbeit / Berufe / Werkstatt | braucht Prozesse, Tools, Rollen | starke Prozess- und Berufslogik |
| Technik / Digital | braucht Digital-Object-/UI-Abgrenzung | digitale Begriffe duerfen nicht beliebig visualisiert werden |
| Gesundheit | `blocked_until_rules` | M12-D Sensitive Content Representation Rules noetig |
| Kultur / Gesellschaft / Verwaltung | `blocked_until_rules` | abstrakte/sensible Begriffe brauchen neutrale Darstellung |

## 5. Plot-Capability Matrix

| Plottyp | `plotSize` | `allowedFunctions` | Wellen | Depth | Typische Worttypen | Stop-/Risiko-Hinweis |
| --- | --- | --- | --- | --- | --- | --- |
| `core_plot` | `medium` | `home`, `school`, `learningHub`, `garden`, `decoration`, `path` | early | exterior, building, interior, container | Alltagsobjekte, Raeume, Lernmaterial, kleine Tools | kein Pflicht-Hausstart; Clutter pruefen |
| `core_edge_plot` | `small_medium`, `medium` | `garden`, `nature`, `decoration`, `path`, `food` klein | early/mid | exterior, container, sequence spaeter | Pflanzen, Hofobjekte, kleine Naturwoerter | Wachstum/Timer nicht ohne Fairness |
| `connector_plot` | `small`, `small_medium` | `path`, `decoration`, `learningHub` klein, `social` klein | early/mid | exterior, sequence spaeter | Wegwoerter, einfache Aktionen, Hinweisobjekte | kein Verkehrssystem daraus ableiten |
| `hub_capable_plot` | `hub` | `learningHub`, `market`, `food`, `social`, `path`, `decoration` | early/mid | exterior, building, interior, container, sequence | Kaufen, Treffen, Marktware, Aufgaben | Market/Social nicht ohne Scope-Regeln |
| `edge_nature_capable_plot` | `large_edge`, `edge` | `nature`, `garden`, `decoration`, `path`, `expansion` | early/mid | exterior, container, sequence spaeter | Natur, Pflanzen, Tiere spaeter | Tiere/Wachstum brauchen eigene Regeln |
| `edge_water_capable_plot` | `edge` | `water`, `travel`, `nature`, `path`, `decoration`, `expansion` | mid | exterior, container, sequence spaeter | Boot, Kompass, Hafen, Wetter | water/travel nicht ohne eigene Folgepruefung |
| `edge_farm_capable_plot` | `large_edge`, `edge` | `farm`, `garden`, `nature`, `food`, `workshop`, `path` | mid | exterior, container, sequence | Samen, Geraete, Tiere spaeter, Ernte | Produktion/Timer/Tiere blockiert |
| `residential_capable_plot` | `medium` | `home`, `garden`, `decoration`, `path`, `social` klein | early/mid | exterior, building, interior, container | Hausobjekte, Kleidung, Moebel, Familie | nicht als fixer Hausplatz lesen |
| `expansion_socket_plot` | `edge` | `expansion`, `path`, `nature`, `decoration` | mid/late | exteriorOnly | Unlock, Randlogik, Future Island Link | keine Expansion ohne Randlogik |

Matrix-Lesart:

- `allowedFunctions` sind Erlaubnisse, keine Pflichtbelegung.
- `Depth` beschreibt moegliche Ebenen, keine Implementierungsfreigabe.
- `Wellen` priorisieren Planung, keine Roadmap.
- Jede sichtbare Platzierung braucht weiterhin Routing, Requirements und
  Nutzerbestaetigung.

## 6. Ableitungsregeln

M12-C leitet folgende Grundregeln ab:

- Kein Plot kann alles.
- Early-Plottypen sollen wenige klare Funktionen tragen.
- `core_plot` ist flexibel, aber nicht automatisch `home`.
- `hub_capable_plot` darf `market` oder `learningHub` koennen, aber nicht
  automatisch Markt werden.
- Edge-Plots tragen Randfunktionen: Natur, Wasser, Farm, Expansion.
- Water, travel, vehicle, farm, digital und sensitive Funktionen bleiben
  blockiert, bis eigene Folgepruefungen abgeschlossen sind.
- Plot-Capabilities duerfen keine automatische Wortplatzierung ausloesen.
- Nutzerentscheidung bleibt zentral.
- M12-D und M12-E bleiben harte Folge-Gates.

## 7. Preview-Dateien

Geplanter und erzeugter Ordner:

`docs/world_design/previews/phase2g_m12c_plot_capability_derivation/`

Dateien:

- `01_plot_capability_pipeline.png`
- `02_plot_type_capability_matrix.png`
- `03_early_theme_capability_cards.png`
- `04_mid_late_special_plot_limits.png`
- `README.md`

Die Dateien sind Dokumentations-/Previewmaterial, keine Spielassets und keine
finale UI.

## 8. Weiterhin Offene Folgeblocks

Weiterhin offen:

- `Phase 2G-M12-D Sensitive Content Representation Rules`
- `Phase 2G-M12-E Mobile And Clutter Rules For Small Objects`

Ausserdem bleiben fuer spaeter offen:

- UX-Pruefung fuer Nutzerwahl bei Plot-Funktionen,
- Mobile-Pruefung fuer Capability-Labels,
- Fairness-/Timer-Regeln fuer Wachstum und Produktion,
- eigene Regeln fuer Water/Travel/Vehicle/Digital.

## 9. Stop-Regeln

Stoppen, wenn:

- aus M12-C Plot-Capability-Implementierung abgeleitet wird,
- aus M12-C eine finale Plot-Datenstruktur abgeleitet wird,
- aus M12-C Runtime-Konfiguration abgeleitet wird,
- eine Early-Insel nur wegen M12-C umgesetzt werden soll,
- Schule/Federmappe ohne M12-E Mobile-/Clutter-Regeln umgesetzt wird,
- Gartenwachstum ohne Fairness-/Timer-Regeln umgesetzt wird,
- `water`, `farm`, `travel`, `vehicle`, `digital` oder `sensitive` Plots ohne
  eigene Folgepruefung umgesetzt werden,
- aus Plot-Capability-Karten Assetproduktion abgeleitet wird,
- aus Plot-Capabilities automatische Wortplatzierung abgeleitet wird.

## 10. Naechster Erlaubter Schritt

Erlaubt:

- M12-C visuell pruefen,
- M12-C nachbessern,
- M12-D Sensitive Content Representation Rules planen,
- M12-E Mobile And Clutter Rules planen.

Weiterhin nicht erlaubt:

- Code,
- App-Integration,
- Tests aendern,
- Spielassets,
- finale Plot-Datenstruktur,
- Runtime-Konfiguration,
- Plot-Implementierung,
- ThemeIsland-Umsetzung,
- `frame_started`.
