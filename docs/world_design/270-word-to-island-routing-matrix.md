# Phase 2G-M12-B: Word-to-Island Routing Matrix

Stand: 2026-06-06

Status: `Planungs- und Visualisierungsblock gestartet`

Dieses Dokument definiert eine erste Routing-Matrix fuer Lernwoerter,
importierte Woerter und Nutzerziele. Es klaert, wie Woerter auf ThemeIslands,
Zonen, Plots, Raeume, Container, Detailobjekte, Aktionen, Codex, Blueprints
oder Backlog geroutet werden koennen.

M12-B ist:

- Planungsgrundlage,
- Previewgrundlage,
- keine finale Routing-Implementierung,
- keine finale Datenstruktur,
- keine App-Integration,
- keine ThemeIsland-Umsetzung,
- keine Assetfreigabe,
- keine Freigabe fuer `frame_started`.

## 1. Zweck

M12-A2 bestaetigt die erste ThemeIsland-Priorisierung. Bevor eine Early-Insel
produktiver geplant werden darf, muss klar sein, wie Woerter dorthin geroutet
werden.

M12-B beantwortet:

- Welche Bedeutung hat ein Wort?
- Welche ThemeIsland passt?
- Welche Depth-Ebene passt?
- Ist sichtbare Platzierung erlaubt?
- Braucht das Wort einen Container, eine Aktion, eine Sequenz, Codex,
  Blueprint oder Backlog?
- Muss Tali/Vori den Nutzer nach Kontext, Bedeutung oder Ziel fragen?

Routing macht Vorschlaege. Es platziert nichts automatisch.

## 2. Routing-Ebenen

| Ebene | Zweck | Beispiele |
| --- | --- | --- |
| `ThemeIsland` | Grober Lern-/Weltkontext | Zuhause, Schule, Garten, Kueste, Essen, Einkauf, Farm |
| `ZoneOrPlot` | Bereich oder Plot auf einer Insel | Kueche, Klassenzimmer, Beet, Hafen, Marktstand |
| `BuildingOrInterior` | Gebaeude oder Innenraum | Haus, Schule, Bootskajute, Restaurantkueche |
| `ContainerOrFocus` | Fokussierbares Objekt oder Mini-Raum | Schublade, Federmappe, Pflanzkiste, Navigationskiste, Regal |
| `DetailObject` | Kleines sichtbares Objekt | Loeffel, Bleistift, Giesskanne, Kompass |
| `ActionOrSequence` | Handlung, Interaktion oder Reihenfolge | oeffnen, giessen, fahren, kochen, kaufen |
| `AbstractOrSensitive` | Begriff ohne direkte Objektplatzierung oder mit Safety-Bedarf | Politik, Gesundheit, Angst, Gerechtigkeit |
| `CodexBlueprintBacklog` | Fallback, wenn Ort, Kontext oder Freigabe fehlt | Codex, Blueprint, Backlog, Future Island Suggestion |

Regel:

Ein Wort soll auf der kleinsten sinnvollen Ebene erscheinen. Ein kleines
Objekt gehoert nicht auf die Hauptinsel, wenn es besser in einen Raum,
Container oder eine Detailansicht passt.

## 3. Worttypen

Start-Worttypen fuer Routing:

| Worttyp | Beschreibung | Typische Ziel-Ebene |
| --- | --- | --- |
| Konkrete Objekte | physische Dinge | `DetailObject`, `ContainerOrFocus`, `ZoneOrPlot` |
| Gebaeudeteile | Teile eines Gebaeudes | `BuildingOrInterior`, `CodexBlueprintBacklog` |
| Raeume | betretbare oder fokussierte Innenbereiche | `BuildingOrInterior` |
| Orte | groessere Orte oder Zielbereiche | `ThemeIsland`, `ZoneOrPlot` |
| Container | Schubladen, Taschen, Kisten, Regale | `ContainerOrFocus` |
| Aktionen / Verben | Handlungen | `ActionOrSequence`, `DetailInteractionView` |
| Prozesse / Sequenzen | mehrschrittige Ablaeufe | `ActionOrSequence`, `Quest`, `CodexBlueprintBacklog` |
| Personen / Rollen / Berufe | soziale oder berufliche Rollen | `ThemeIsland`, `ZoneOrPlot`, `Codex` |
| Essen / Zutaten | Lebensmittel und Kuechenobjekte | `ContainerOrFocus`, `DetailObject`, `ThemeIsland` |
| Natur / Pflanzen / Tiere | Naturbegriffe | `ThemeIsland`, `ZoneOrPlot`, `DetailObject` |
| Fahrzeuge / Verkehr | Mobilitaet, Wege, Fahrzeuge | `ThemeIsland`, `ActionOrSequence`, `CodexBlueprintBacklog` |
| Werkzeuge / Maschinen | benutzbare oder technische Objekte | `ContainerOrFocus`, `DetailObject`, `ActionOrSequence` |
| Digitale Begriffe | App, Server, Datei, Daten | `AbstractOrSensitive`, `Codex`, spaeter Technikinsel |
| Emotionen / soziale Situationen | Zustand oder Kontext | `Codex`, `Dialog`, `Scene` |
| Abstrakte Begriffe | nicht direkt sichtbare Konzepte | `AbstractOrSensitive`, `Codex`, `Dialog` |
| Sensible Begriffe | Gesundheit, Politik, Religion, Gewalt, Identitaet | `AbstractOrSensitive`, `Codex`, `Dialog` |
| Mehrdeutige Woerter | mehrere Bedeutungen oder Inseln | `CodexBlueprintBacklog`, `SenseSelection` |

## 4. Beispiel-Routing-Matrix

| Wort | Worttyp | ThemeIsland-Kandidaten | Ziel-Ebene / Depth | Darstellung | Challenge / Interaktion | Fallback / Regel |
| --- | --- | --- | --- | --- | --- | --- |
| `spoon / Loeffel` | konkretes Objekt | Zuhause, Essen | Kueche -> Schublade -> Besteck | `DetailObject` im Container | Tap-Auswahl: Finde den Loeffel | Backlog, wenn keine Kueche/Schublade existiert |
| `pencil / Bleistift` | konkretes Objekt | Schule | Federmappe -> Schreibzeug | `DetailObject` im Container | Tap-Auswahl oder Matching | Backlog, wenn kein Schul-/Container-Kontext existiert |
| `watering can / Giesskanne` | konkretes Objekt | Garten | Beet, Geraeteecke, Pflanzkiste | `DetailObject` oder `ToolObject` | Tap-Auswahl; spaeter giessen als Sequenz | Blueprint, wenn kein Garten/Hof/Beet existiert |
| `compass / Kompass` | konkretes Objekt | Kueste, Reisen | Navigationskiste, Bootskajute | `DetailObject` im Container | Audio + Tap; spaeter Navigation | Backlog, wenn Kueste/Reisen nicht offen ist |
| `window / Fenster` | Gebaeudeteil | Zuhause, Schule, Stadt | Gebaeudeteil an passendem Zustand | `BuildPart` | Erkennen/Benennen am Gebaeude | Blueprint/Backlog, wenn kein Gebaeudezustand passt |
| `drive / fahren` | Aktion / mehrdeutig | Reisen, Verkehr, Stadt, Technik | `ActionOrSequence` | Animation, Quest, Dialog, Codex | Mini-Sequenz spaeter | Sense-Auswahl: fahren, antreiben, Laufwerk, Motivation |
| `buy / kaufen` | Aktion | Einkauf, Stadt, Essen | Aktion/Dialog/Sequenz | Markt-/Shop-Interaktion | Dialog- oder Auswahlaufgabe | Codex/Quest, wenn kein Shop-Kontext existiert |
| `health / Gesundheit` | abstrakt / sensibel | Gesundheit | `AbstractOrSensitive` | Codex/Dialog/Kontextkarte | keine automatische Objektplatzierung | M12-D Safety-Regeln erforderlich |
| `justice / Gerechtigkeit` | abstrakt / sensibel | Kultur/Gesellschaft/Verwaltung, Codex | `AbstractOrSensitive` | Codex/Dialog/Beispielsituation | Kontextfrage oder Reflexionskarte | keine automatische Symbol- oder Gebaeudeplatzierung |
| `bank` | mehrdeutig | Stadt, Natur, Business, Codex | Sense-abhaengig | Sitzbank, Bankinstitut, Flussufer oder Codex | Nutzer-/Kontextentscheidung | nie blind platzieren |
| `apple / Apfel` | Multi-home-Objekt | Garten, Essen, Einkauf | Obstbaum, Marktware, Zutat, DetailObject | je nach Kontext sichtbar oder Blueprint | Tap, Matching, Sortieren | Multi-home-Auswahl oder Nutzerziel pruefen |
| `server` | digital / Technik | Technik, Arbeit | Technikinsel, Serverraum, Codex | DigitalObject, abstrakter Technikbegriff | spaeter Technik-Flow | Digital-Object-/UI-Abgrenzung erforderlich |

## 5. Entscheidungsregeln

Grundregeln:

- Kein automatisches sichtbares Objekt ohne passende ThemeIsland und
  Depth-Ebene.
- Kein Gebaeudeteil ohne passenden Gebaeudezustand oder Blueprint.
- Kein Verb als statisches Objekt erzwingen.
- Mehrdeutige Woerter brauchen Kontext oder Nutzerentscheidung.
- Multi-home-Woerter duerfen mehrere moegliche Inseln haben.
- Nutzerziel priorisiert Vorschlaege, ueberschreibt aber keine Safety-Regeln.
- Sensitive Begriffe werden neutral, optional und ohne automatische
  Visualisierung behandelt.
- Routing macht Vorschlaege, keine Zwangsplatzierung.

Wenn kein passender Ort existiert:

- `CodexEntry` speichern,
- `BlueprintEntry` vorbereiten,
- `WordObjectBacklogEntry` anlegen,
- `CompanionSuggestion` erzeugen,
- `futureIslandSuggestion` vormerken,
- bei Insel-/Plot-Freischaltung erneut pruefen.

## 6. Routing-Pipeline

Erste Pipeline:

1. Word intake
   - gelerntes Wort, Import, Satz, Nutzerwunsch oder Companion-Input.
2. Semantic profile
   - Sprache, Wortart, Sense-Kandidaten, Kategorie, Tags.
3. Safety/context check
   - sensible Themen, Mehrdeutigkeit, fehlender Satzkontext.
4. Theme candidates
   - eine oder mehrere passende ThemeIslands.
5. Depth candidates
   - beste Ebene: Plot, Interior, Container, Detail, Aktion, Codex.
6. Placement requirements
   - Plot-Faehigkeit, Gebaeudezustand, Container, Anchor, Unlock.
7. User suggestion
   - Tali/Vori oder UI schlaegt Optionen vor.
8. User decision
   - Nutzer bestaetigt, waehlt Sense, lehnt ab oder speichert spaeter.
9. Result
   - `PlacedWorldObject`, `BuildInstance`, `BlueprintEntry`, `CodexEntry`,
     `WordObjectBacklogEntry`, `Quest` oder `futureIslandSuggestion`.

Automatische Analyse darf Vorschlaege vorbereiten. Sichtbare Platzierung
braucht passende Regeln und Nutzerbestaetigung.

## 7. Multi-Home Routing

Ein Wort kann mehrere passende Inseln haben.

Beispiele:

- `apple / Apfel`
  - Garten: Obstbaum, Beet, Pflanze.
  - Essen: Zutat, Rezept, Kueche.
  - Einkauf: Marktware, Regal, Einkaufsliste.
- `bank`
  - Stadt: Sitzbank.
  - Business: Bankinstitut.
  - Natur: Flussufer, falls Kontext passt.
- `drive`
  - Verkehr: fahren.
  - Technik: Laufwerk.
  - Motivation: abstrakter Begriff.
- `light`
  - Technik: Lampe.
  - Eigenschaft: leicht.
  - Natur: Licht.

Regeln:

- Nutzer-Sense-Auswahl gewinnt.
- Satzkontext gewinnt vor Einzelwortinterpretation.
- Aktives Nutzerziel beeinflusst Vorschlaege.
- Bereits vorhandene passende Inseln duerfen bevorzugt werden, aber falsche
  Zuordnung bleibt verboten.
- Bei Unsicherheit: Codex, Blueprint oder Backlog statt sichtbarer Platzierung.

## 8. Early-Island Anwendung

### Zuhause / Alltag

Geeignet fuer:

- Besteck,
- Moebel,
- einfache Raeume,
- Kleidung,
- Schluessel,
- Haushaltsgegenstaende.

Grenze:

- Kein Pflicht-Hausstart.
- Gebaeudeteile nur mit Gebaeudezustand oder Blueprint.

### Schule / Lernen

Geeignet fuer:

- Federmappe,
- Stifte,
- Hefte,
- Buch,
- Regal,
- einfache Lernobjekte.

Grenze:

- Kleinteile brauchen M12-E Mobile-/Clutter-Regeln.

### Garten / Natur nah

Geeignet fuer:

- Beet,
- Samen,
- Pflanze,
- Giesskanne,
- Blume,
- Baum,
- einfache Naturaktionen.

Grenze:

- Wachstum, Timer, Daily-Routinen und Ernte brauchen Fairness-Regeln.

## 9. Weiterhin Offene Folgeblocks

Weiterhin offen:

- `Phase 2G-M12-C Plot-Capability Derivation`
- `Phase 2G-M12-D Sensitive Content Representation Rules`
- `Phase 2G-M12-E Mobile And Clutter Rules For Small Objects`

M12-B ersetzt diese Folgeblocks nicht.

## 10. Stop-Regeln

Stoppen, wenn:

- aus M12-B Word-to-Island-Routing-Code abgeleitet wird,
- aus M12-B automatische Wortplatzierung abgeleitet wird,
- ein sichtbares Objekt ohne passende Depth-Ebene geplant wird,
- ein Multi-home-Wort ohne Nutzer- oder Kontextentscheidung final platziert
  wird,
- ein sensibler Begriff ohne M12-D-Regeln sichtbar gemacht wird,
- ein Gebaeudeteil ohne passenden Gebaeudezustand oder Blueprint geplant wird,
- ein Verb als statisches Objekt erzwungen wird,
- ein Digitalbegriff ohne Digital-Object-/UI-Abgrenzung geplant wird,
- aus Routing-Karten Assetproduktion abgeleitet wird.

## 11. Naechster Erlaubter Schritt

Erlaubt:

- M12-B visuell pruefen,
- M12-B nachbessern,
- M12-C Plot-Capability Derivation planen,
- M12-D Sensitive Content Representation Rules planen,
- M12-E Mobile And Clutter Rules planen.

Weiterhin nicht erlaubt:

- Code,
- App-Integration,
- Spielassets,
- finale Routing-Implementierung,
- finale Datenstruktur,
- ThemeIsland-Umsetzung,
- `frame_started`.
