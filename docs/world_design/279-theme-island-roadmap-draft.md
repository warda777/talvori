# Phase 2G-M13: ThemeIsland Roadmap Draft

Stand: 2026-06-06

Status: `Planungs- und Visualisierungsblock gestartet`

## 1. Zweck

Dieses Dokument leitet aus der M12-Kette einen ersten nicht-finalen
ThemeIsland-Roadmap-Draft ab. Es ordnet moegliche Themeninseln in Wellen, damit
Talvori nicht alle Lernbereiche auf eine Starterinsel presst und spaetere
Planung gezielt priorisieren kann.

M13 ist:

- Planungsgrundlage,
- Roadmap-Draft,
- keine finale Roadmap,
- keine Implementierungsfreigabe,
- keine finale Datenstruktur,
- keine Runtime-Konfiguration,
- keine App-Integration,
- keine Assetfreigabe,
- keine ThemeIsland-Umsetzung,
- keine Freigabe fuer `frame_started`.

## 2. Ableitung Aus M12

M12-F bestaetigt M12 bis M12-E2 als konsolidierte Planungsgrundlage:

- ThemeIsland-Priorisierung gibt Early/Mid/Late/Special Orientierung.
- Word-to-Island Routing macht Vorschlaege, keine automatische Platzierung.
- Plot-Capabilities sind Erlaubnisse, keine Pflichtbelegung.
- Sensitive Content bleibt ein Safety-/UX-Gate.
- Mobile-/Clutter-Regeln verhindern TinyObjects in IslandView und
  ueberfuellte Container.

M13 baut darauf auf, ohne eine finale Roadmap oder Umsetzung freizugeben.

## 3. Roadmap-Wellen

| Welle | Ziel | Kandidaten | Roadmap-Logik |
| --- | --- | --- | --- |
| `Foundation / Starter Learning World` | sichere Einstiegserfahrung, wenige Systeme, klare Depth-/Container-Regeln | Zuhause/Alltag, Schule/Lernen, Garten/Natur nah | Early-Kandidaten haben starke Alltagswoerter, einfache Container-Flows und kontrollierbare Mobile-Komplexitaet. |
| `Expansion Wave 1` | mehr Motivation, aber noch kontrollierbare Systeme | Essen/Restaurant/Cafe, Einkauf/Versorgung, Land/Farm | Mehr Vielfalt, Sets und Routinen; braucht aber Food-, Market-, Farm- und Fairness-Regeln. |
| `Expansion Wave 2` | starke Themenwelten mit mehr Systemkomplexitaet | Kueste/Meer/Hafen, Natur/Berge/Outdoor, Freizeit/Sport | Emotional attraktiv und wortstark, aber Water, Outdoor, Navigation, Sportaktionen und Mobile-Komplexitaet steigen. |
| `System-Heavy Wave` | groessere Systeminseln erst nach Path/Vehicle/Digital/Process-Konzepten | Stadt/Dorfzentrum, Reisen/Verkehr, Arbeit/Werkstatt, Technik/Digital | Erfordert Connector, Path, Vehicle, Prozess- oder Digital-Object-Konzepte. |
| `Sensitive / Special Wave` | nur nach Safety-/UX-/Darstellungsregeln | Gesundheit, Kultur/Gesellschaft/Verwaltung, Religion, Politik, Gericht, Polizei, Krankenhaus | Bleibt blockiert, bis vertiefte Safety-, Policy-, Privacy- und Darstellungsregeln existieren. |

## 4. Foundation / Starter Learning World

Zweck:

- ersten Wow-Moment ohne Systemueberladung vorbereiten,
- freie Startwahl ermoeglichen,
- erste Depth-/Container-Flows ueben,
- kleine Objekte mobile-lesbar halten.

Enthaltene Kandidaten:

- Zuhause / Alltag,
- Schule / Lernen,
- Garten / Natur nah.

Warum sinnvoll:

- viele Grundwoerter,
- gute erste Tap-Challenges,
- bekannte Orte,
- einfache Container wie Schublade, Federmappe, Regal, Beet oder Kiste,
- Tali/Vori kann freundlich und alltagsnah begleiten.

Lernwert:

- Alltagsobjekte,
- Schulmaterial,
- einfache Natur- und Gartenwoerter,
- erste Aktionen wie oeffnen, finden, sortieren, giessen.

Depth-/Container-Flows:

- Kueche -> Schublade -> Besteck,
- Klassenzimmer -> Federmappe -> Stifte,
- Garten -> Beet -> Samen/Giesskanne/Pflanze.

Risiken:

- Zuhause darf nicht als Pflicht-Hausstart wirken.
- Schule darf nicht trocken oder kleinteilig ueberladen werden.
- Garten darf keine manipulativen Timer oder Wachstumspflichten erzeugen.

Notwendige Gates vor Umsetzung:

- Onboarding-Choice-Review,
- Device-/Accessibility-/Tap-Target-Pruefung,
- M12-E Clutter-Regeln in echten Mobile-Previews testen,
- Growth/Timer Fairness fuer Garten,
- keine automatische Wortplatzierung.

Nicht freigegeben:

- keine Starterinsel-Implementierung,
- keine finale Auswahl der ersten Insel,
- keine Assets,
- keine Runtime-Datenstruktur.

## 5. Expansion Wave 1

Zweck:

- Motivation durch Essen, Einkauf, Markt und Farm erweitern,
- Sammel- und Set-Logik staerken,
- erste Produktions- oder Routineideen vorbereiten, ohne sie zu bauen.

Enthaltene Kandidaten:

- Essen / Restaurant / Cafe,
- Einkauf / Versorgung,
- Land / Farm.

Warum sinnvoll:

- hohe Wortschatzbreite,
- starke Alltagsnaehe,
- gute Dialog-, Sortier- und Container-Flows,
- gute spaetere Retention ueber kleine Ziele.

Lernwert:

- Speisen, Getraenke, Zutaten,
- Kaufen, Bezahlen, Bestellen,
- Werkzeuge, Tiere, Pflanzen, Ernte.

Depth-/Container-Flows:

- Restaurant -> Tisch -> Bestellung,
- Laden -> Regal -> Produktset,
- Farm -> Stall oder Acker -> Werkzeug/Tier/Pflanze.

Risiken:

- Food- und Market-Flows duerfen nicht wie reine Listen wirken.
- Farm/Growth kann Timer- und Fairness-Fragen erzeugen.
- Viele Objekte fuehren schnell zu Clutter.

Notwendige Gates vor Umsetzung:

- Food-/Order-/Market-UX-Konzept,
- Growth/Timer Fairness,
- Mobile-Clutter-Review fuer Regale, Stalls und Farmtools,
- Asset-Scope-Gate.

Nicht freigegeben:

- keine Produktionsketten,
- keine Farmmechanik,
- keine Shop-/Market-Implementierung,
- keine Assets.

## 6. Expansion Wave 2

Zweck:

- stark motivierende Themenwelten vorbereiten,
- mehr Entdeckung, Bewegung und Abenteuer ermoeglichen,
- aber Systemkomplexitaet bewusst nach hinten schieben.

Enthaltene Kandidaten:

- Kueste / Meer / Hafen,
- Natur / Berge / Outdoor,
- Freizeit / Sport.

Warum sinnvoll:

- visuell attraktiv,
- gute Wortfelder fuer Reisen, Wetter, Ausruestung, Sport und Navigation,
- starke Companion- und Quest-Momente moeglich.

Lernwert:

- Wasser, Boot, Hafen, Wetter,
- Wandern, Klettern, Ausruestung,
- Sportarten, Koerperbewegungen, Orte.

Depth-/Container-Flows:

- Hafen -> Bootskajute -> Kompass/Karte/Seil,
- Berghuette -> Rucksack -> Ausruestung,
- Sportplatz -> Tasche -> Ball/Schuhe/Trikot.

Risiken:

- Water/Dock braucht eigene Layout- und Mobile-Pruefung.
- Outdoor/Sport kann viele Aktionen und Sequenzen brauchen.
- Hafen/Boot ist mobil riskanter als Schublade oder Federmappe.

Notwendige Gates vor Umsetzung:

- Water-/Dock-/Mobile-Komplexitaetspruefung,
- Action-/Sequence-Regeln,
- Path-/Navigation-Pruefung,
- Device-Preview.

Nicht freigegeben:

- keine Kueste-/Hafeninsel,
- keine Water-/Dock-Systeme,
- keine Sport- oder Outdoor-Implementierung,
- keine Assets.

## 7. System-Heavy Wave

Zweck:

- groessere Systemwelten vorbereiten,
- komplexe Infrastruktur nicht zu frueh bauen,
- Themen erst nach eigenen Systemkonzepten zulassen.

Enthaltene Kandidaten:

- Stadt / Dorfzentrum,
- Reisen / Verkehr,
- Arbeit / Werkstatt,
- Technik / Digital.

Warum sinnvoll:

- sehr breite Wortfelder,
- spaeter wichtig fuer Erwachsene, Beruf und reale Importwoerter,
- gute Langzeitmotivation, aber hoher Architekturbedarf.

Lernwert:

- Orte, Institutionen, Wege,
- Fahrzeuge, Tickets, Richtungen,
- Berufe, Werkzeuge, Prozesse,
- digitale Begriffe, Geraete, Server, Apps.

Depth-/Container-Flows:

- Bahnhof -> Ticketautomat -> Ticket/Route,
- Werkstatt -> Werkzeugkasten -> Werkzeug,
- Buero -> Schreibtisch -> Dokumente/Geraete,
- Technikraum -> Serverrack -> Digitalbegriffe.

Risiken:

- Connector-/Path-/Vehicle-Systeme fehlen.
- Prozesswoerter duerfen nicht als statische Objekte erzwungen werden.
- Digitalbegriffe brauchen UI-Abgrenzung.
- Stadt kann alle anderen Systeme gleichzeitig anziehen.

Notwendige Gates vor Umsetzung:

- Connector-/Path-Konzept,
- Vehicle- und Travel-Regeln,
- Process-/Profession-Konzept,
- Digital-Object-/UI-Abgrenzung,
- Mobile- und Clutter-Pruefung.

Nicht freigegeben:

- keine Stadt-/Verkehrs-/Technikinsel,
- keine Fahrzeuge,
- keine Digital-UI,
- keine Prozesssysteme,
- keine Assets.

## 8. Sensitive / Special Wave

Zweck:

- sensible oder gesellschaftlich heikle Themen nur mit eigenen Regeln planen,
- neutrale, sichere und optionale Darstellung sichern,
- keine problematischen Symbole oder Gebaeude automatisch erzeugen.

Enthaltene Kandidaten:

- Gesundheit,
- Kultur / Gesellschaft / Verwaltung,
- Religion,
- Politik,
- Gericht,
- Polizei,
- Krankenhaus.

Warum sinnvoll:

- wichtige Wortfelder,
- stark fuer reale Texte und Imports,
- aber besonders hohes Safety-, Privacy-, Symbolik- und Tonalitaetsrisiko.

Lernwert:

- Gesundheit und Pflege,
- Institutionen und Gesellschaft,
- abstrakte Begriffe,
- Kontextverstehen und neutrale Erklaerung.

Depth-/Container-Flows:

- bevorzugt Codex,
- ContextCard,
- neutraler CompanionDialog,
- BacklogOnly,
- RequiresUserChoice,
- BlockedUntilRules.

Risiken:

- automatische Visualisierung kann falsch, verletzend oder politisch wirken.
- Medizinische, juristische oder politische Beratung ist ausgeschlossen.
- Retention mit Angst, Krankheit, Tod, Schuld, Politik oder Religion ist
  verboten.

Notwendige Gates vor Umsetzung:

- vertiefte Sensitive-Content-Policy,
- Safety-/UX-/Privacy-Review,
- neutrale ContextCard-Previews,
- Companion-Tonalitaetsregeln,
- Import-Governance.

Nicht freigegeben:

- keine sensible ThemeIsland-Umsetzung,
- keine Gebaeude-/Symbol-/Assetproduktion,
- keine automatische Visualisierung,
- keine Beratung.

## 9. Early Roadmap Cards

### Zuhause / Alltag

Moegliche Startzonen:

- Kueche,
- Zimmer,
- Eingang,
- kleiner Aussenbereich.

Moegliche Container:

- Schublade,
- Regal,
- Kiste.

Moegliche Woerter:

- `spoon`,
- `key`,
- `window`,
- `chair`,
- `table`.

Risiken:

- darf nicht als Pflicht-Hausstart erzwungen werden,
- Clutter durch viele Haushaltsobjekte,
- Gebaeudeteile nur mit passendem Gebaeudezustand oder Blueprint.

Gates:

- Onboarding-Choice-Review,
- Device-/Tap-Target-Pruefung,
- BuildingPart-Regeln fuer Fenster/Tuer/Dach.

### Schule / Lernen

Moegliche Startzonen:

- Klassenzimmer,
- Tisch,
- Regal,
- Federmappe.

Moegliche Container:

- Federmappe,
- Buecherregal,
- Schulranzen.

Moegliche Woerter:

- `pencil`,
- `ruler`,
- `book`,
- `eraser`,
- `notebook`.

Risiken:

- Kleinteile,
- Mobile-Clutter,
- darf nicht trocken oder rein tabellarisch wirken.

Gates:

- Mobile-/Clutter-Pruefung fuer Kleinteile,
- emotionale Produktflow-Pruefung,
- klare Challenge-Art fuer Schulmaterial.

### Garten / Natur Nah

Moegliche Startzonen:

- Beet,
- Geraeteecke,
- kleiner Weg,
- Pflanzbereich.

Moegliche Container/Fokusobjekte:

- Pflanzkiste,
- Samenbeutel,
- Giesskanne.

Moegliche Woerter:

- `seed`,
- `watering can`,
- `flower`,
- `soil`,
- `leaf`.

Risiken:

- Wachstum/Timer/Fairness,
- Deko-Clutter,
- Pflanzenueberladung.

Gates:

- Growth-/Timer-Fairness-Regeln,
- Deko-/Clutter-Grenzen,
- keine manipulative Wartezeit- oder Pay-to-Win-Logik.

## 10. Gates Vor Umsetzung

M13 definiert folgende harte Gates:

- Kein M13-Code.
- Keine ThemeIsland-Umsetzung.
- Keine finale Roadmap.
- Keine finale Datenstruktur.
- Keine Runtime-Konfiguration.
- Keine Assets.
- Keine automatische Wortplatzierung.
- Keine Early-Insel ohne Onboarding-Choice-Review.
- Keine Early-Insel ohne Device-/Accessibility-/Tap-Target-Pruefung.
- Keine Garten-/Farm-Mechanik ohne Growth-/Timer-Fairness.
- Keine Kuesten-/Hafeninsel ohne Water-/Dock-/Mobile-
  Komplexitaetspruefung.
- Keine Stadt-/Reisen-/Technikinsel ohne Systemkonzept.
- Keine Sensitive-/Special-Insel ohne vertiefte Safety-/UX-/Policy-Regeln.
- Keine App- oder Assetfreigabe aus M13.
- Kein `frame_started` oder Bauzustand aus M13.

## 11. Prueffazit

Der Roadmap-Draft ist als Orientierung brauchbar:

- Foundation sollte auf Zuhause/Alltag, Schule/Lernen und Garten/Natur nah
  fokussieren, ohne eine Pflichtreihenfolge zu erzwingen.
- Expansion Wave 1 kann mehr Motivation und Alltagssituationen bringen, braucht
  aber Food-/Market-/Farm-/Fairness-Regeln.
- Expansion Wave 2 ist emotional attraktiv, aber systemisch und mobil
  riskanter.
- System-Heavy Themen brauchen eigene Konzepte.
- Sensitive/Special Themen bleiben blockiert, bis Safety-/UX-/Policy-Regeln
  vertieft sind.

Der Draft ist keine finale Roadmap und keine Umsetzungsfreigabe.

## 12. Naechster Erlaubter Schritt

Erlaubt:

- M13 visuell pruefen,
- M13 nachbessern,
- M13-B Early Island Onboarding Choice Review planen,
- M13-C ThemeIsland Capability Sheets planen,
- M13-D Word-to-Island UX Flow planen.

Weiterhin nicht erlaubt:

- Flutter-/Dart-Code,
- App-Integration,
- Tests aendern,
- Spielassets,
- finale ThemeIsland-Roadmap,
- ThemeIsland-Umsetzung,
- finale Datenstruktur,
- Runtime-Konfiguration,
- automatische Wortplatzierung,
- App-/Assetfreigabe,
- `frame_started`,
- Bauzustaende weiterbauen.
