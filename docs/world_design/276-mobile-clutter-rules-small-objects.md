# Phase 2G-M12-E: Mobile And Clutter Rules For Small Objects

Stand: 2026-06-06

Status: `Planungs- und Visualisierungsblock gestartet`

Dieses Dokument definiert erste Mobile- und Clutter-Regeln fuer kleine
Objekte, Deko, Container-Inhalte und Detailobjekte in Talvori. Ziel ist, viele
Lernwoerter aufnehmen zu koennen, ohne IslandView, PlotView, Raeume oder
Container auf Mobile-Geraeten zu ueberladen.

M12-E ist:

- Planungsgrundlage,
- Previewgrundlage,
- keine finale UI,
- keine finale Datenstruktur,
- keine App-Integration,
- keine ThemeIsland-Umsetzung,
- keine Container-Implementierung,
- keine Assetfreigabe,
- keine Freigabe fuer `frame_started`.

## 1. Kernproblem

Talvori soll viele Lernwoerter aufnehmen koennen. Trotzdem darf nicht jedes Wort
dauerhaft sichtbar auf Insel, Plot oder Raumoberflaeche liegen.

Kleine Woerter wie Loeffel, Bleistift, Radiergummi, Kompass, Samen, Schluessel,
Schraube, Tablette, Muenze oder Kabel duerfen Mobile-Ansichten nicht
ueberladen.

Kleine Woerter gehoeren oft in:

- `InteriorView`,
- `ContainerOpenView`,
- `ObjectView`,
- `DetailInteractionView`,
- `Codex`,
- `Blueprint`,
- `Backlog`.

Kleine Woerter gehoeren normalerweise nicht dauerhaft in:

- `IslandView`,
- ueberfuellte `PlotView`,
- sichtbare Aussenflaeche,
- technische Debug-Overlays als Nutzeransicht.

Grundsatz:

Ein Wort kann gelernt, gesammelt oder als Blueprint gespeichert werden, ohne
dass es dauerhaft als sichtbares Objekt auf der aktuellen Ebene erscheinen
muss.

## 2. Clutter-Kategorien

| Kategorie | Beispiele | Typische Ziel-Ebene | Clutter-Risiko |
| --- | --- | --- | --- |
| `tinyObject` | Loeffel, Bleistift, Schluessel, Schraube | `ContainerOpenView`, `DetailInteractionView`, `Codex` | sehr hoch, wenn dauerhaft sichtbar |
| `smallTool` | Giesskanne, Hammer, Kompass, Lineal | `PlotView`, `InteriorView`, `ObjectView`, `ContainerOpenView` | mittel, wenn zu viele Werkzeuge sichtbar sind |
| `containerItem` | Besteck, Stifte, Samen, Karten, Kabel | `ContainerOpenView`, `DetailInteractionView` | hoch, wenn Container als Liste wirkt |
| `ambientDecoration` | Steine, Blumen, Bank, Laterne, Schild | `IslandView`, `PlotView`, `InteriorView` | mittel, wenn Deko Lernobjekte verdeckt |
| `interactiveFocusObject` | Schublade, Federmappe, Kiste, Regal, Beet | `InteriorView`, `PlotView`, `ObjectView` | niedrig bis mittel, wenn wenige klare Ziele |
| `buildingPart` | Fenster, Tuer, Dach, Wand | `BuildingView`, `Blueprint`, `Backlog` | hoch, wenn ohne Gebaeudezustand platziert |
| `sequenceObject` | Objekte fuer giessen, oeffnen, sortieren | `DetailInteractionView`, `Quest`, `ContainerOpenView` | mittel, wenn Aktion unklar ist |
| `sensitiveSmallObject` | Medikament, Spritze, Notfallobjekt | `Codex`, `ContextCard`, `BacklogOnly` | sehr hoch; M12-D gilt zusaetzlich |

## 3. Depth- und Sichtbarkeitsregeln

Pflichtregeln:

- `tinyObject` nicht dauerhaft in `IslandView` zeigen.
- `tinyObject` nur in passender Depth-Ebene sichtbar machen.
- Pro Screen nur wenige Fokusobjekte zeigen.
- Container zeigen wenige passende Objekte, nicht ganze Objektlisten.
- Detailobjekte duerfen gelernt, gesammelt oder im Codex gespeichert werden,
  ohne dauerhaft sichtbar zu sein.
- Deko darf Atmosphaere erzeugen, aber Lernobjekte nicht verdecken.
- Interaktive Objekte brauchen klare Tap-Flaechen.
- Mobile-Tap-Ziele muessen gross genug gedacht werden.
- Labels erscheinen nur bei Fokus, Challenge, Feedback oder Accessibility-
  Modus, nicht dauerhaft ueberall.
- Mehrere Kleinteile brauchen Gruppierung, Zoom, Container, Pagination,
  Filter oder Detailansicht.
- `sensitiveSmallObject` folgt zusaetzlich M12-D.
- Bei hoher Clutter-Gefahr gewinnt Codex, Blueprint oder Backlog gegen
  sichtbare Platzierung.

## 4. Mobile-Grenzwerte Als Planungswerte

Diese Werte sind Planungswerte. Sie sind keine finale UI-Spezifikation, keine
Runtime-Konfiguration und keine Datenstruktur.

| Ebene | Sichtbare Objektplanung | Regel |
| --- | --- | --- |
| `IslandView` | 0 bis 3 aktive Fokusobjekte | keine TinyObject-Daueranzeige |
| `PlotView` | 1 bis 5 sichtbare relevante Objekte | Deko nur als ruhiger Hintergrund |
| `InteriorView` | 3 bis 7 relevante Fokusobjekte | kleine Objekte meist erst nach Zoom oder Container |
| `ContainerOpenView` | 3 bis 5 Challenge-Objekte gleichzeitig | maximal 1 aktive Challenge |
| `DetailInteractionView` | 1 Hauptobjekt plus 2 bis 4 Auswahl-/Vergleichsobjekte | klare Feedback- und Reward-Flaeche |
| Labels | nur bei Fokus, Challenge, Feedback oder Accessibility-Modus | keine dauerhaften Labelwolken |
| Companion-Hinweise | kurz, optional, nicht ueberdeckend | kein Textblock ueber Lernobjekten |

Planungsinterpretation:

- Wenn eine Ansicht mehr Objekte braucht, muss sie zoomen, gruppieren,
  paginieren oder in Codex/Backlog ausweichen.
- Wenn Tap-Ziele unklar werden, ist die Ebene falsch gewaehlt.
- Wenn Labels noetig sind, sollte die Ansicht fokussierter werden.

## 5. Beispielregeln

| Wort | Kategorie | Ziel-Ebene | Regel |
| --- | --- | --- | --- |
| `spoon / Loeffel` | `tinyObject` / `containerItem` | Kueche -> Schublade -> Besteck | nicht auf Insel; max. wenige Besteckobjekte sichtbar |
| `pencil / Bleistift` | `tinyObject` / `containerItem` | Schule -> Federmappe -> Stifte | keine 20 Stifte gleichzeitig |
| `watering can / Giesskanne` | `smallTool` | Garten -> Beet/Geraeteecke | groesser als TinyObject; als Fokuswerkzeug geeignet |
| `compass / Kompass` | `smallTool` / `containerItem` | Hafen/Reisen -> Navigationskiste | nicht dauerhaft auf Hafenflaeche |
| `window / Fenster` | `buildingPart` | Gebaeudezustand, Blueprint, Backlog | nur an passendem Gebaeude, sonst Blueprint/Backlog |
| `medicine / Medikament` | `sensitiveSmallObject` | Codex, ContextCard, BacklogOnly | M12-D; keine automatische Platzierung |
| `stone / Stein` | `ambientDecoration` | PlotView, IslandView, Deko-Pool | Deko moeglich, aber nicht jede Vokabel als einzelner Stein |
| `key / Schluessel` | `tinyObject` / `sequenceObject` | Container, DetailInteraction | nicht dauerhaft als Minipixel |

## 6. Container-Regeln

Container sind Fokusraeume, keine Objektlisten.

Erlaubt:

- 3 bis 5 relevante Challenge-Objekte gleichzeitig,
- 1 aktive Aufgabe,
- klare Tap-Ziele,
- optionales Label nur fuer Fokus oder Accessibility,
- kurzer Feedback-/Reward-Moment,
- weitere Objekte im Backlog, Codex oder spaeterer Seite.

Nicht erlaubt:

- 20 Kleinteile gleichzeitig,
- kleine Objekte ohne Zoom,
- dauerhafte Labelwolken,
- Deko vor Lernobjekten,
- mehrere aktive Challenges gleichzeitig,
- sensitiveSmallObjects ohne M12-D-Regeln.

## 7. Decoration-Regeln

Deko darf Weltgefuehl erzeugen, aber nicht die Lernhandlung blockieren.

Regeln:

- Deko bleibt visuell ruhiger als aktive Lernobjekte.
- Deko darf Tap-Ziele nicht verdecken.
- Deko darf nicht wie eine Aufgabe aussehen, wenn sie nicht interaktiv ist.
- Ambient-Deko braucht keine eigene Lernlogik.
- Nicht jedes Deko-Wort braucht ein eigenes sichtbares Asset.
- Deko-Massenproduktion bleibt blockiert, bis Clutter und Asset-Scope geprueft
  sind.

## 8. Accessibility- und Label-Regeln

Labels sind hilfreich, koennen aber Clutter erzeugen.

Erlaubt:

- Labels bei Fokus,
- Labels in Challenge,
- Labels nach Tap oder Hover/Long-Press,
- Accessibility-Modus mit groesseren Labels,
- kurzes Feedbacklabel nach Erfolg oder Fehler.

Nicht erlaubt:

- alle Objekte dauerhaft beschriften,
- Labels, die Objekte verdecken,
- Labels, die Companion-Hinweise ueberlagern,
- Labels, die auf Mobile nicht lesbar sind,
- technische Debuglabels als Nutzeransicht.

## 9. Stop-Gates Fuer Sichtbare Platzierung

Sichtbare Platzierung stoppt, wenn:

- Objekt zu klein fuer die aktuelle Ebene ist,
- Tap-Ziel unklar ist,
- mehr als die Planungswerte sichtbar werden,
- mehrere Labels kollidieren,
- Deko Lernobjekte verdeckt,
- Container wie Objektliste wirkt,
- SensitiveSmallObject ohne M12-D-Kontext auftaucht,
- Gebaeudeteil ohne Gebaeudezustand platziert wuerde,
- Verb/Sequenz als statisches Objekt erscheinen wuerde,
- Nutzerkontext oder Sense fehlt.

Fallbacks:

- Zoom,
- Container,
- DetailInteractionView,
- Codex,
- Blueprint,
- Backlog,
- Accessibility Label,
- spaetere ThemeIsland- oder UX-Pruefung.

## 10. Offene Fragen

Offene Folgefragen:

- Welche echten Tap-Ziel-Mindestgroessen gelten spaeter fuer Flutter-UI?
- Wie wird Accessibility-Modus fuer Labels und kleine Objekte gestaltet?
- Wie viele Dekoobjekte sind je ThemeIsland vertretbar?
- Wie werden mehrere Container-Seiten oder Pagination gefuehrt?
- Wann wird ein kleines Objekt als Sammlung, Codex-Eintrag oder sichtbares
  Objekt angezeigt?
- Wie werden kleine Objekte in Device-Previews pruefbar, ohne Spielassets zu
  erzeugen?
- Wie werden sensitiveSmallObjects mit M12-D und spaeterer Safety-UX verbunden?

## 11. Weiterhin Blockiert

M12-E gibt nicht frei:

- finale Mobile-UI,
- finale Clutter-Grenzwerte als Runtime-Werte,
- finale Datenstruktur,
- Container-Implementierung,
- Kleinteile-Implementierung,
- ThemeIsland-Umsetzung,
- App-Integration,
- Assetfreigabe,
- `frame_started`.

## 12. Stop-Regeln

Stoppen, wenn:

- aus M12-E eine Kleinteile-/Container-Implementierung abgeleitet wird,
- aus M12-E eine finale Mobile-UI abgeleitet wird,
- M12-E-Planungswerte als finale Runtime-Werte uebernommen werden,
- `tinyObject` dauerhaft in `IslandView` platziert werden soll,
- ueberfuellte Container-Ansichten als Nutzeransicht freigegeben werden,
- Labels dauerhaft ueberall angezeigt werden sollen,
- Deko Lernobjekte verdeckt,
- `sensitiveSmallObject` ohne M12-D-Regeln platziert wird,
- aus M12-E App-, Code- oder Assetfreigabe abgeleitet wird,
- aus Clutter-Regeln automatische Wortplatzierung abgeleitet wird.

## 13. Naechster Erlaubter Schritt

Erlaubt:

- M12-E visuell pruefen,
- M12-E nachbessern,
- spaeter eine Mobile-/Clutter-Review-Preview planen.

Weiterhin nicht erlaubt:

- Code,
- App-Integration,
- Tests aendern,
- Spielassets,
- finale Mobile-UI,
- finale Datenstruktur,
- Container-Implementierung,
- Kleinteile-Implementierung,
- ThemeIsland-Umsetzung,
- Assetfreigabe,
- `frame_started`.
