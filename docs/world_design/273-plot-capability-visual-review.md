# Phase 2G-M12-C2: Plot-Capability Visual Review

Stand: 2026-06-06

Status: `visuelle Pruefung gestartet / erste Plot-Capability-Richtung brauchbar`

## 1. Zweck

Dieses Dokument prueft die M12-C-Previews visuell. Ziel ist zu entscheiden, ob
die Plot-Capability-Ableitung als erste Planungsrichtung brauchbar ist oder
nachgebessert werden muss.

M12-C2 ist:

- reiner Dokumentationsblock,
- visuelle Pruefung von Planungs-Previews,
- keine finale Plot-Datenstruktur,
- keine Runtime-Konfiguration,
- keine Plot-Implementierung,
- keine ThemeIsland-Umsetzung,
- keine App-Integration,
- keine Assetfreigabe,
- keine Freigabe fuer `frame_started`.

## 2. Gepruefte Dateien

- `docs/world_design/previews/phase2g_m12c_plot_capability_derivation/01_plot_capability_pipeline.png`
- `docs/world_design/previews/phase2g_m12c_plot_capability_derivation/02_plot_type_capability_matrix.png`
- `docs/world_design/previews/phase2g_m12c_plot_capability_derivation/03_early_theme_capability_cards.png`
- `docs/world_design/previews/phase2g_m12c_plot_capability_derivation/04_mid_late_special_plot_limits.png`
- `docs/world_design/previews/phase2g_m12c_plot_capability_derivation/README.md`

## 3. Visuelle Bewertung

| Prueffrage | Bewertung | Notiz |
| --- | --- | --- |
| Ist die Plot-Capability-Pipeline verstaendlich? | Ja | Taxonomy, ThemeIsland Priority, Word Routing, Plot Capability, User Choice und Safe Result sind als Prozess erkennbar. |
| Wird klar, dass Taxonomy, ThemeIsland-Prioritaet und Routing nur zu Plot-Erlaubnissen fuehren? | Ja | Untertitel und Stop-Gates benennen Erlaubnisse statt Platzierung. |
| Wird klar, dass Plot-Capabilities keine automatische Platzierung ausloesen? | Ja | Pipeline und Stop-Gates sagen explizit: keine automatische Wortplatzierung. |
| Ist die Plot-Type-Capability-Matrix lesbar? | Ja, fuer interne Planung | Die Matrix ist dicht, aber Spalten, Zeilen, Labels und Risiko-Hinweise bleiben lesbar. |
| Ist die Matrix zu technisch? | Technisch, aber brauchbar | Sie eignet sich fuer interne Planung, nicht fuer Nutzer-UX. |
| Wird klar, dass `allowedFunctions` Erlaubnisse sind? | Ja | Die Fussnote stellt klar: Erlaubnisse, keine Pflichtbelegung. |
| Wird klar, dass `core_plot` nicht automatisch `home` bedeutet? | Ja | Matrix und Early-Regeln sagen, dass `core_plot` flexibel bleibt und kein Pflicht-Hausstart ist. |
| Wird klar, dass `hub_capable_plot` nicht automatisch Markt bedeutet? | Ja | `hub_capable_plot` erlaubt LearningHub, Market, Food, Social, Path und Decoration; Market/Social brauchen Scope-Regeln. |
| Wird klar, dass Edge-Plots Randfunktionen tragen? | Ja | Edge Nature, Edge Water, Edge Farm und Expansion Socket sind als Rand-/Spezialplots sichtbar. |
| Bleiben Water/Farm/Travel/Vehicle/Digital/Sensitive gated? | Ja | Die Limits-Preview und Stop-Regel halten diese Funktionen in Folgepruefungen. |
| Sind die Early Theme Capability Cards verstaendlich? | Ja | Zuhause/Alltag, Schule/Lernen und Garten/Natur nah sind gut getrennt und mit Risiken versehen. |
| Werden die Early-Kandidaten sinnvoll abgeleitet? | Ja | Die Ableitung passt zu Routing, Taxonomy und M12-A2-Priorisierung. |
| Sind Risiken sichtbar genug? | Ja | Clutter, Mobile, Fairness/Timer, Scope, Water/Travel und Sensitive sind sichtbar. |
| Bleiben Texte in Karten/Rahmen/Panels? | Ja | Keine wichtigen Texte laufen aus Panels oder Tabellen heraus. |
| Suggeriert die Preview Datenstruktur, Runtime, Implementierung, UI oder Assetfreigabe? | Nein | Die Previews sind als Planungsansicht und Dokumentationsmaterial markiert. |

## 4. Bewertung Nach Datei

### `01_plot_capability_pipeline.png`

Die Pipeline ist klar. Sie zeigt, dass Taxonomy, ThemeIsland-Prioritaet und
Word Routing nicht direkt bauen, sondern erst Plot-Erlaubnisse erzeugen. Der
Nutzerentscheidungsschritt und das sichere Resultat verhindern automatische
Platzierung.

Bewertung: brauchbar.

Risiko: Fuer eine spaetere Nutzeransicht ist die Pipeline zu technisch. Fuer
interne Planung ist sie passend.

### `02_plot_type_capability_matrix.png`

Die Matrix ist dicht, aber lesbar. Sie zeigt fuer abstrakte Plottypen
`plotSize`, `allowedFunctions`, Wave, Depth und Risiko. Besonders wichtig:
`core_plot` bleibt flexibel, `hub_capable_plot` wird nicht automatisch Markt,
und Edge-Plots bilden Randfunktionen ab.

Bewertung: brauchbar fuer interne Planung.

Risiko: Die Matrix darf nicht als finale Plot-Datenstruktur oder Runtime-
Konfiguration gelesen werden.

### `03_early_theme_capability_cards.png`

Die Early Theme Cards sind die produktnaeheste Preview. Zuhause/Alltag,
Schule/Lernen und Garten/Natur nah werden sinnvoll getrennt. Die Risiken fuer
Pflicht-Hausstart, Kleinteile/Clutter und Wachstum/Fairness sind sichtbar.

Bewertung: brauchbar.

Risiko: Schule/Federmappe und Garten/Natur brauchen vor Umsetzung zwingend
M12-E bzw. Fairness-/Timer-Regeln.

### `04_mid_late_special_plot_limits.png`

Die Grenzen fuer Mid, Late und Special sind gut sichtbar. Kueste/Meer/Hafen,
Essen/Restaurant/Cafe, Einkauf/Versorgung und Land/Farm brauchen extra Regeln.
Stadt/Verkehr, Arbeit/Berufe, Technik/Digital und Freizeit/Outdoor brauchen
eigene Systeme. Gesundheit, Kultur/Gesellschaft, Verwaltung/Politik sowie
Religion/Gericht/Polizei bleiben sensitive Themen mit M12-D-Bedarf.

Bewertung: brauchbar.

Risiko: Die Preview bestaetigt noch keine dieser Funktionen als umsetzbar.

## 5. Entscheidungsempfehlung

Empfehlung:

M12-C als erste Plot-Capability-Planungsrichtung grundsaetzlich bestaetigen.

Begruendung:

- Die Pipeline ist verstaendlich.
- Die Matrix ist fuer interne Planung ausreichend lesbar.
- Early Theme Capability Cards leiten Zuhause, Schule und Garten sinnvoll ab.
- Mid/Late/Special-Grenzen sind sichtbar.
- Die Previews suggerieren keine finale Datenstruktur, keine Runtime-
  Konfiguration, keine Implementierung und keine Assetfreigabe.

Nicht ableiten:

- keine finale Plot-Datenstruktur,
- keine Runtime-Konfiguration,
- keine Plot-Implementierung,
- keine ThemeIsland-Umsetzung,
- keine automatische Wortplatzierung,
- keine Assetfreigabe,
- keine App-Integration,
- kein `frame_started`.

## 6. Bestaetigte Plot-Capability-Regeln

M12-C2 bestaetigt als erste Planungsrichtung:

- Plot-Capabilities sind Erlaubnisse, keine Pflichtbelegung.
- `allowedFunctions` duerfen nie automatisch sichtbare Objekte oder
  BuildInstances erzeugen.
- `core_plot` ist flexibel, aber nicht automatisch `home`.
- `hub_capable_plot` kann LearningHub, Market, Food oder Social tragen, wird
  aber nicht automatisch Markt.
- Edge-Plots tragen Randfunktionen wie Nature, Water, Farm oder Expansion.
- Water, Farm, Travel, Vehicle, Digital und Sensitive bleiben gated.
- Early-Plottypen sollen wenige klare Funktionen tragen.
- Sichtbare Platzierung braucht weiterhin Routing, Requirements und
  Nutzerbestaetigung.
- M12-D und M12-E bleiben harte Folge-Gates.

## 7. Sichtbare Risiken

- Matrix und Pipeline sind keine Nutzeransichten.
- Schule/Federmappe kann Kleinteile- und Mobile-Clutter erzeugen.
- Garten/Natur kann Timer-, Wachstum- und Fairness-Fragen erzeugen.
- Water/Travel/Vehicle brauchen eigene System- und Mobile-Pruefung.
- Digitalbegriffe brauchen eigene Digital-Object-/UI-Abgrenzung.
- Sensitive Funktionen brauchen M12-D.
- Capabilities koennen spaeter missverstanden werden, wenn sie als feste
  Rollen statt als Erlaubnisse gelesen werden.

## 8. Weiterhin Offene Folgeblocks

Weiterhin offen:

- `Phase 2G-M12-D Sensitive Content Representation Rules`
- `Phase 2G-M12-E Mobile And Clutter Rules For Small Objects`

Zusaetzlich spaeter sinnvoll:

- Mobile-Pruefung fuer Capability-Labels,
- UX-Pruefung fuer Nutzerwahl bei Plot-Funktionen,
- Fairness-/Timer-Regeln fuer Wachstum und Farm,
- eigene Folgepruefung fuer Water/Travel/Vehicle/Digital.

M12-C2 ersetzt diese Folgeblocks nicht.

## 9. Stop-Regeln

Stoppen, wenn:

- aus M12-C2 eine finale Plot-Datenstruktur abgeleitet wird,
- aus M12-C2 Runtime-Konfiguration abgeleitet wird,
- aus M12-C2 Plot-Implementierung abgeleitet wird,
- aus M12-C2 ThemeIsland-Umsetzung abgeleitet wird,
- aus Plot-Capabilities automatische Wortplatzierung abgeleitet wird,
- sensitive Plot-Funktionen ohne M12-D geplant werden,
- Kleinteile-, Container- oder Schulobjekt-Umsetzung ohne M12-E geplant wird,
- Gartenwachstums- oder Farm-Mechanik ohne Fairness-/Timer-Regeln geplant
  wird,
- Water-, Travel-, Vehicle- oder Digital-Plots ohne eigene Folgepruefung
  geplant werden,
- aus M12-C oder M12-C2 App-, Code- oder Assetfreigabe abgeleitet wird.

## 10. Naechster Erlaubter Schritt

Erlaubt:

- M12-C2 reviewen,
- M12-C/M12-C2 bei Bedarf nachbessern,
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
