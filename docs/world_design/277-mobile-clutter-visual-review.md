# Phase 2G-M12-E2: Mobile Clutter Visual Review

Stand: 2026-06-06

Status: `visuelle Pruefung gestartet / erste Mobile-Clutter-Richtung brauchbar`

## 1. Zweck

Dieses Dokument prueft die M12-E-Previews visuell und inhaltlich. Ziel ist zu
entscheiden, ob die Mobile And Clutter Rules For Small Objects als erste
Planungsrichtung brauchbar sind oder nachgebessert werden muessen.

M12-E2 ist:

- reiner Dokumentationsblock,
- visuelle und inhaltliche Pruefung von Planungs-Previews,
- keine finale Mobile-UI,
- keine finale Datenstruktur,
- keine Runtime-Konfiguration,
- keine Container-Implementierung,
- keine ThemeIsland-Umsetzung,
- keine App-Integration,
- keine Assetfreigabe,
- keine Freigabe fuer `frame_started`.

## 2. Gepruefte Dateien

- `docs/world_design/previews/phase2g_m12e_mobile_clutter_rules/01_mobile_clutter_depth_ladder.png`
- `docs/world_design/previews/phase2g_m12e_mobile_clutter_rules/02_small_object_routing_matrix.png`
- `docs/world_design/previews/phase2g_m12e_mobile_clutter_rules/03_container_clutter_examples.png`
- `docs/world_design/previews/phase2g_m12e_mobile_clutter_rules/04_mobile_stop_gates.png`
- `docs/world_design/previews/phase2g_m12e_mobile_clutter_rules/README.md`

## 3. Visuelle Bewertung

| Prueffrage | Bewertung | Notiz |
| --- | --- | --- |
| Ist die Mobile Clutter Depth Ladder verstaendlich? | Ja | Die Ebenen IslandView, PlotView, InteriorView, ContainerOpenView und DetailInteractionView sind klar in zunehmender Tiefe angeordnet. |
| Wird klar, dass kleine Objekte mit zunehmender Detailtiefe sichtbar werden? | Ja | Die Ladder sagt explizit, dass kleine Objekte tiefer wandern, wenn Screen-Groesse und Detailanspruch steigen. |
| Wird klar, dass TinyObjects nicht dauerhaft in IslandView gehoeren? | Ja | IslandView nennt "No tiny objects always visible"; Good/Risky Island Screen verstaerkt die Regel. |
| Wird klar, dass Container wenige Challenge-Objekte zeigen sollen? | Ja | ContainerOpenView nennt 3-5 Challenge-Objekte und nur eine aktive Challenge; die Container-Beispiele zeigen gute und riskante Varianten. |
| Wird klar, dass Container keine Objektlisten sind? | Ja | `03_container_clutter_examples.png` formuliert "Containers are focus spaces, not object lists" und zeigt die Ueberladung als Risky-Fall. |
| Ist die Small Object Routing Matrix lesbar? | Ja, fuer interne Planung | Die Matrix ist dicht, aber Spalten, Status-Pills und Legende bleiben erkennbar. |
| Ist die Matrix zu technisch? | Technisch, aber brauchbar | Sie eignet sich fuer interne Planung, nicht fuer Nutzer-UX. |
| Sind die Clutter-Kategorien verstaendlich? | Ja | `tinyObject`, `smallTool`, `containerItem`, `ambientDecoration`, `interactiveFocusObject`, `buildingPart`, `sequenceObject` und `sensitiveSmallObject` sind in der Matrix unterscheidbar. |
| Sind Good/Risky-Beispiele fuer Schublade und Federmappe verstaendlich? | Ja | Beide Good-Beispiele zeigen 3 Fokusobjekte; Risky-Beispiele zeigen zu viele Kleinteile und fehlenden Zoom. |
| Wird klar, dass zu viele Kleinteile zu Zoom, Pagination, Codex oder Backlog fuehren muessen? | Ja | Guardrail, Stop-Gates und Fallback-Pfad nennen Zoom, Pagination, Codex, Blueprint und Backlog. |
| Sind die Mobile Stop Gates verstaendlich? | Ja | Too small, Too many labels, Tap target unclear, Decoration covers learning, Sensitive without M12-D und Container becomes list sind klar getrennt. |
| Werden kleine Objekte, Labelwolken, unklare Tap-Ziele, verdeckende Deko und sensitiveSmallObjects als Stop-Gates sichtbar? | Ja | Die Stop-Gate-Karten decken diese Risiken explizit ab. |
| Bleiben Texte innerhalb von Karten/Rahmen/Panels? | Ja | Keine wichtigen Labels laufen aus Panels heraus; die Texte haben genug Padding. |
| Suggerieren die Previews finale UI, Spielassets, Runtime-Werte oder Implementierung? | Nein | Titel, README und Footer markieren die Previews als Planung und schliessen finale UI, Runtime Limits, Implementierung, Assets und automatische Wortplatzierung aus. |

## 4. Bewertung Nach Datei

### `01_mobile_clutter_depth_ladder.png`

Die Ladder ist die staerkste Uebersicht. Sie zeigt, dass kleine Objekte nicht
auf der Inseloberflaeche geloest werden, sondern ueber Plot, Interior,
Container und DetailInteraction schrittweise fokussiert werden. Die Good/Risky
Island-Beispiele machen sichtbar, warum TinyObject-Wolken auf Mobile nicht
funktionieren.

Bewertung: brauchbar.

Risiko: Die Zahlenwerte sind Planungswerte. Sie duerfen nicht als finale
Runtime-Grenzen gelesen werden.

### `02_small_object_routing_matrix.png`

Die Matrix ist intern gut nutzbar. Sie zeigt, welche Clutter-Kategorien auf
welchen Ebenen sinnvoll sind, wo Kontext noetig ist und wo die Ebene vermieden
werden soll. Besonders wichtig ist, dass `sensitiveSmallObject` fast immer in
Codex/Backlog oder M12-D-Kontext faellt.

Bewertung: brauchbar fuer interne Planung.

Risiko: Die Matrix ist keine finale Datenstruktur und keine Nutzeransicht.

### `03_container_clutter_examples.png`

Die Good/Risky-Gegenueberstellung ist klar. Schublade und Federmappe mit drei
Fokusobjekten wirken als mobile Challenge-Ansicht plausibel. Die riskanten
Varianten zeigen, dass zu viele Kleinteile ohne Zoom oder Pagination wie
Inventory-Clutter wirken.

Bewertung: brauchbar.

Risiko: Spaeter braucht es echte Device-Previews, um Tap-Ziele, Fingerabstand,
Schriftgroesse und Accessibility zu pruefen.

### `04_mobile_stop_gates.png`

Die Stop-Gates sind deutlich. Sie zeigen, wann sichtbare Platzierung endet und
stattdessen sichere Tiefe, Container, Detailansicht, Codex, Blueprint oder
Backlog gewaehlt werden muss.

Bewertung: brauchbar.

Risiko: Die Gate-Liste ist eine Planungsregel. Sie ersetzt keine spaetere
Mobile-UX-, Accessibility- oder Runtime-Pruefung.

## 5. Entscheidungsempfehlung

Empfehlung:

M12-E als erste Mobile-/Clutter-Planungsrichtung grundsaetzlich bestaetigen.

Begruendung:

- Die Previews zeigen die Tiefenlogik fuer kleine Objekte verstaendlich.
- TinyObjects werden klar aus IslandView und ueberfuellter PlotView
  herausgehalten.
- Container werden als Fokusraeume statt Objektlisten verstanden.
- Stop-Gates fuer Tap-Ziele, Labelwolken, Deko, sensitiveSmallObjects und
  Ueberladung sind sichtbar.
- Codex, Blueprint und Backlog sind als sichere Fallbacks dokumentiert.
- Die Grenzen der Previews sind klar markiert.

Nicht ableiten:

- keine finale Mobile-UI,
- keine finale Datenstruktur,
- keine Runtime-Konfiguration,
- keine finalen Clutter-Grenzwerte,
- keine Container-Implementierung,
- keine ThemeIsland-Umsetzung,
- keine automatische Wortplatzierung,
- keine App-Integration,
- keine Assetfreigabe,
- kein `frame_started`.

## 6. Bestaetigte Mobile-/Clutter-Regeln

M12-E2 bestaetigt als erste Planungsrichtung:

- `tinyObject` gehoert nicht dauerhaft in `IslandView`.
- Kleine Objekte werden auf die kleinste sinnvolle Depth-Ebene geroutet.
- `ContainerOpenView` zeigt wenige Challenge-Objekte, keine vollstaendige
  Objektliste.
- Pro Container soll nur eine aktive Challenge sichtbar sein.
- Detailobjekte duerfen gelernt, gesammelt oder im Codex gespeichert werden,
  ohne dauerhaft sichtbar zu bleiben.
- Labels erscheinen nur bei Fokus, Challenge, Feedback oder
  Accessibility-Modus.
- Deko bleibt Hintergrund und darf Lernobjekte nicht verdecken.
- Tap-Ziele muessen auf Mobile klar und gross genug gedacht werden.
- Bei Clutter-Gefahr gewinnt Zoom, Container, DetailInteractionView, Codex,
  Blueprint oder Backlog gegen sichtbare Platzierung.
- `sensitiveSmallObject` folgt zusaetzlich M12-D.

## 7. Sichtbare Risiken

- Die Previews sind keine echten Device-Previews.
- Tap-Ziel-Groessen, Fingerabstand und Schriftgroessen bleiben ungeprueft.
- Accessibility-Modus, Label-Umschaltung und Screenreader-Logik bleiben offen.
- Pagination fuer Container ist nur als Fallback genannt, aber nicht
  visualisiert.
- Die Matrix ist dicht und nur fuer interne Planung geeignet.
- Gute Containerbeispiele koennen spaeter immer noch zu leer oder zu
  schematisch wirken, wenn emotionale Produktgestaltung fehlt.
- SensitiveSmallObjects brauchen weiterhin M12-D und spaetere Safety-/UX-
  Pruefung.
- Keine der Planungszahlen ist ein finaler Runtime-Wert.

## 8. Weiterhin Offene Folgeblocks

Spaeter sinnvoll:

- echte Device-/Mobile-Preview fuer kleine Objekte,
- Accessibility-/Label-Modus fuer kleine Objekte,
- Pagination-Flow fuer Container mit mehr als 3 bis 5 passenden Objekten,
- Tap-Target- und Fingerabstandsregeln fuer Flutter-UI,
- Clutter-Pruefung fuer echte ThemeIsland-Layouts,
- emotionale Produktpreview fuer Container mit wenigen Objekten,
- M12-E-Nachbesserung, falls Device-Preview die Planungswerte widerlegt.

M12-E2 ersetzt diese Folgeblocks nicht.

## 9. Stop-Regeln

Stoppen, wenn:

- aus M12-E2 eine finale Mobile-UI abgeleitet wird,
- aus M12-E2 eine finale Datenstruktur abgeleitet wird,
- aus M12-E2 Runtime-Konfiguration abgeleitet wird,
- aus M12-E2 Container-Implementierung abgeleitet wird,
- aus M12-E2 automatische Wortplatzierung abgeleitet wird,
- TinyObjects dauerhaft in IslandView platziert werden,
- ueberfuellte Container als Nutzeransicht freigegeben werden,
- dauerhafte Labelwolken geplant werden,
- Deko Lernobjekte verdeckt,
- sensitiveSmallObjects ohne M12-D-Regeln geplant werden,
- aus M12-E oder M12-E2 App-, Code- oder Assetfreigabe abgeleitet wird,
- Device- oder Accessibility-Entscheidungen ohne spaetere echte Mobile-
  Pruefung getroffen werden.

## 10. Naechster Erlaubter Schritt

Erlaubt:

- M12-E2 reviewen,
- M12-E/M12-E2 bei Bedarf nachbessern,
- spaeter echte Mobile-/Accessibility-/Pagination-Previews planen,
- naechste reine Planungsbloecke fuer ThemeIsland-, Routing-, Capability- oder
  UX-Folgefragen starten.

Weiterhin nicht erlaubt:

- Code,
- App-Integration,
- Tests aendern,
- Spielassets,
- PNG-Aenderungen,
- finale Mobile-UI,
- finale Datenstruktur,
- Runtime-Konfiguration,
- Container-Implementierung,
- ThemeIsland-Umsetzung,
- automatische Wortplatzierung,
- Assetfreigabe,
- `frame_started`.
