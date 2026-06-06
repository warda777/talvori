# Phase 2G-M12-B2: Word-to-Island Routing Visual Review

Stand: 2026-06-06

Status: `visuelle Pruefung gestartet / erste Routing-Planungsrichtung brauchbar`

## 1. Zweck

Dieses Dokument prueft die M12-B-Previews visuell. Ziel ist zu entscheiden, ob
die Word-to-Island Routing Matrix als erste Planungsrichtung brauchbar ist oder
nachgebessert werden muss.

M12-B2 ist:

- reiner Dokumentationsblock,
- visuelle Pruefung von Planungs-Previews,
- keine finale Routing-Implementierung,
- keine finale Datenstruktur,
- keine automatische Wortplatzierung,
- keine ThemeIsland-Umsetzung,
- keine App-Integration,
- keine Assetfreigabe,
- keine Freigabe fuer `frame_started`.

## 2. Gepruefte Dateien

- `docs/world_design/previews/phase2g_m12b_word_to_island_routing/01_word_routing_pipeline.png`
- `docs/world_design/previews/phase2g_m12b_word_to_island_routing/02_word_type_routing_matrix.png`
- `docs/world_design/previews/phase2g_m12b_word_to_island_routing/03_example_word_routing_cards.png`
- `docs/world_design/previews/phase2g_m12b_word_to_island_routing/04_multi_home_and_backlog_flow.png`
- `docs/world_design/previews/phase2g_m12b_word_to_island_routing/README.md`

## 3. Visuelle Bewertung

| Prueffrage | Bewertung | Notiz |
| --- | --- | --- |
| Ist die Routing-Pipeline verstaendlich? | Ja | Die Pipeline trennt Word Intake, Semantic Profile, Safety/Context, Theme Candidates, Depth Candidates, User Suggestion, User Decision und Result klar. |
| Wird klar, dass Analyse nur Vorschlaege macht? | Ja | Der Untertitel und die Stop-Regel nennen explizit, dass sichtbare Platzierung Regeln und Nutzerbestaetigung braucht. |
| Wird klar, dass Platzierung Nutzerbestaetigung braucht? | Ja | `User decision` ist als eigener Schritt sichtbar. |
| Ist die Worttyp-Routing-Matrix lesbar? | Ja, fuer interne Planung | Die Matrix ist dicht, aber Spalten, Zeilen und Marker bleiben lesbar. |
| Ist die Matrix zu technisch? | Technisch, aber akzeptabel | Sie eignet sich fuer Planung, nicht fuer Nutzer-UX. |
| Zeigen die Beispielkarten die wichtigsten Wortfaelle? | Ja | Detailobjekt, ToolObject, BuildPart, Action, Multi-home und Abstract/Sensitive sind abgedeckt. |
| Funktionieren `spoon`, `pencil`, `watering can`, `compass` als Detail-/Containerobjekte? | Ja | Alle vier werden nachvollziehbar auf Container, Fokusobjekte oder passende Depth-Ebenen geroutet. |
| Wird `window` als Gebaeudeteil richtig begrenzt? | Ja | Die Karte markiert `BuildPart` und `nur mit Gebaeudezustand`. |
| Wird `drive` nicht als statisches Objekt gelesen? | Ja | Die Karte benennt `ActionOrSequence` und `Aktion, kein Objekt`. |
| Wird `bank` als mehrdeutig verstanden? | Ja | `Sense-abhaengig`, `Multi-home` und `Kontext oder Nutzerwahl` sind sichtbar. |
| Wird `health` als sensibel behandelt? | Ja | `AbstractOrSensitive`, Codex/Dialog und keine Auto-Platzierung sind klar. |
| Wird Multi-home bei `apple` verstaendlich? | Ja | Garten, Essen und Einkauf sind als moegliche Routen sichtbar; Kontext oder Nutzerziel entscheidet. |
| Sind Codex, Blueprint, Backlog und Future Island Suggestion verstaendlich? | Ja | Pipeline und Multi-home/Backlog-Flow zeigen sichere Fallbacks. |
| Bleiben Texte in Karten/Rahmen/Panels? | Ja | Keine wichtigen Texte laufen aus Karten oder Panels heraus. |
| Suggeriert die Preview Implementierung, Datenstruktur, UI oder Assetfreigabe? | Nein | Die Previews sind als Debug-/Dokumentationsmaterial markiert. |

## 4. Bewertung Nach Datei

### `01_word_routing_pipeline.png`

Die Pipeline ist die staerkste Preview. Sie zeigt, dass ein Wort nicht direkt
in die Welt faellt, sondern erst durch Analyse, Safety-/Kontextpruefung,
Theme- und Depth-Kandidaten sowie Nutzerentscheidung geht.

Bewertung: brauchbar.

Risiko: Fuer eine spaetere Produktansicht waere die Pipeline zu technisch.
Fuer interne Planung ist sie passend.

### `02_word_type_routing_matrix.png`

Die Matrix ist lesbar und zeigt die wichtigste Unterscheidung zwischen
primaerer Ziel-Ebene und Fallback. Sie macht sichtbar, dass konkrete Objekte,
Gebaeudeteile, Verben, digitale Begriffe, Emotionen und sensible Begriffe
nicht gleich behandelt werden.

Bewertung: brauchbar fuer interne Planung.

Risiko: Die Matrix darf nicht als finale Datenstruktur gelesen werden.

### `03_example_word_routing_cards.png`

Die Beispielkarten sind die produktnaheste Pruefung. Sie zeigen, warum
`spoon`, `pencil`, `watering can` und `compass` als kleine Detail- oder
Containerobjekte funktionieren, warum `window` einen Gebaeudezustand braucht,
warum `drive` eine Aktion bleibt, warum `bank` Sense-Auswahl braucht und warum
`health` keine automatische sichtbare Platzierung bekommt.

Bewertung: brauchbar.

Risiko: Weitere Beispiele fuer Emotionen, soziale Situationen, Tiere,
Kleidung, Werkzeuge und digitale Begriffe bleiben spaeter sinnvoll.

### `04_multi_home_and_backlog_flow.png`

Die Multi-home- und Backlog-Logik ist verstaendlich. `apple` zeigt mehrere
Inselrouten, `window` wartet auf Gebaeudezustand oder Blueprint, `justice`
bleibt Codex/Dialog ohne Auto-Symbol und `server` wartet auf Digital-Object-/
UI-Regeln.

Bewertung: brauchbar.

Risiko: Multi-home-Entscheidungen brauchen spaeter klare UX, damit Nutzer
nicht mit zu vielen Optionen ueberfordert werden.

## 5. Entscheidungsempfehlung

Empfehlung:

M12-B als erste Routing-Planungsrichtung grundsaetzlich bestaetigen.

Begruendung:

- Die Routing-Pipeline ist verstaendlich.
- Die Matrix ist fuer interne Planung ausreichend lesbar.
- Die Beispielkarten decken wichtige Wortfaelle ab.
- Multi-home, Backlog, Codex, Blueprint und Future Island Suggestion sind als
  sichere Fallbacks erkennbar.
- Die Previews suggerieren keine finale UI, keine Implementierung und keine
  Assetfreigabe.

Nicht ableiten:

- keine finale Routing-Implementierung,
- keine finale Datenstruktur,
- keine automatische Wortplatzierung,
- keine ThemeIsland-Umsetzung,
- keine Assetfreigabe,
- keine App-Integration,
- kein `frame_started`.

## 6. Bestaetigte Routing-Regeln

M12-B2 bestaetigt als erste Planungsrichtung:

- Routing macht Vorschlaege, keine Zwangsplatzierung.
- Sichtbare Platzierung braucht passende ThemeIsland, Depth-Ebene,
  Requirements und Nutzerbestaetigung.
- Konkrete kleine Objekte gehoeren eher in Container, Interior oder
  Detailansichten als direkt auf die Insel.
- Gebaeudeteile brauchen Gebaeudezustand oder Blueprint.
- Verben werden als Aktion, Sequenz, Quest, Animation oder Dialog behandelt,
  nicht als statisches Objekt.
- Mehrdeutige Woerter brauchen Kontext, Nutzerziel oder Sense-Auswahl.
- Multi-home-Woerter duerfen mehrere Inselkandidaten haben.
- Sensitive Begriffe bekommen keine automatische sichtbare Platzierung.
- Wenn Ort, Kontext, Regeln oder Insel fehlen, wird das Wort in Codex,
  Blueprint, Backlog oder Future Island Suggestion gesichert.

## 7. Sichtbare Risiken

- Matrix und Pipeline sind fuer Nutzer zu technisch.
- Multi-home-Optionen koennen spaeter UX-Komplexitaet erzeugen.
- Sensitive Begriffe sind nur als Stop-Regel sichtbar, aber noch nicht
  detailliert geregelt.
- Plot-Capabilities sind noch nicht aus der Routing-Matrix abgeleitet.
- Kleinteile und Container brauchen weiterhin Mobile-/Clutter-Regeln.
- Digitale Begriffe brauchen spaeter eine eigene Digital-Object-/UI-
  Abgrenzung.

## 8. Weiterhin Offene Folgeblocks

Weiterhin offen:

- `Phase 2G-M12-C Plot-Capability Derivation`
- `Phase 2G-M12-D Sensitive Content Representation Rules`
- `Phase 2G-M12-E Mobile And Clutter Rules For Small Objects`

M12-B2 ersetzt diese Folgeblocks nicht.

## 9. Stop-Regeln

Stoppen, wenn:

- aus M12-B2 eine finale Routing-Implementierung abgeleitet wird,
- aus M12-B2 automatische Wortplatzierung abgeleitet wird,
- aus M12-B2 eine Datenstruktur-Freigabe abgeleitet wird,
- Plot-Capabilities ohne M12-C abgeleitet werden,
- sensible Begriffe ohne M12-D sichtbar platziert werden,
- Kleinteile- oder Container-Umsetzung ohne M12-E Mobile-/Clutter-Regeln
  geplant wird,
- Multi-home-Entscheidungen ohne Nutzerziel, Satzkontext oder Sense-Auswahl
  finalisiert werden,
- aus M12-B oder M12-B2 App-, Code- oder Assetfreigabe abgeleitet wird.

## 10. Naechster Erlaubter Schritt

Erlaubt:

- M12-B2 reviewen,
- M12-B/M12-B2 bei Bedarf nachbessern,
- M12-C Plot-Capability Derivation planen,
- M12-D Sensitive Content Representation Rules planen,
- M12-E Mobile And Clutter Rules planen.

Weiterhin nicht erlaubt:

- Code,
- App-Integration,
- Tests aendern,
- Spielassets,
- finale Routing-Implementierung,
- finale Datenstruktur,
- automatische Wortplatzierung,
- ThemeIsland-Umsetzung,
- `frame_started`.
