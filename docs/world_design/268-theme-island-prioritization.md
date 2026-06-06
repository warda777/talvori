# Phase 2G-M12: ThemeIsland Prioritization

Stand: 2026-06-06

Status: `Planungs- und Visualisierungsblock gestartet`

Dieses Dokument leitet aus dem World Content Taxonomy-/Location-Katalog eine
erste priorisierte ThemeIsland-Reihenfolge ab.

M12 ist:

- eine Planungsgrundlage,
- eine Visualisierungsgrundlage,
- keine finale ThemeIsland-Roadmap,
- keine ThemeIsland-Umsetzung,
- keine Assetliste,
- keine Bau-Freigabe,
- keine Flutter-/Dart- oder App-Freigabe,
- keine Freigabe fuer `frame_started`.

## 1. Zweck

M11-C2 bestaetigt den Taxonomy-Katalog als erste Content-/Location-Grundlage.
M12 prueft nun, welche Themeninseln frueh, mittig, spaet oder nur nach
besonderen Regeln sinnvoll sind.

Ziel ist nicht, alle Inseln festzulegen. Ziel ist, Produktionsdruck zu senken:
Talvori soll mit wenigen starken, verstaendlichen Themen starten und komplexe
oder sensible Bereiche bewusst spaeter planen.

## 2. Bewertungskriterien

ThemeIsland-Kandidaten werden nach diesen Kriterien bewertet:

| Kriterium | Bedeutung fuer Talvori |
| --- | --- |
| Lernwert / Wortschatzbreite | Deckt die Insel viele alltagsnahe, wiederholbare Woerter ab? |
| Visuelle Attraktivitaet | Entsteht schnell ein sichtbarer Welt- und Belohnungsmoment? |
| MVP-Tauglichkeit | Kann ein erster Slice ohne viele neue Systeme funktionieren? |
| Einfache Container-/Depth-Flows | Gibt es klare Flows wie Raum -> Container -> kleine Objekte? |
| Geringe Mobile-Komplexitaet | Bleiben Labels, Objekte und Interaktionen auf kleinen Screens lesbar? |
| Geringe Clutter-Gefahr | Laesst sich der Inhalt ohne Objektueberladung darstellen? |
| Gute Tali/Vori-Einbindung | Kann der Companion freundlich, kurz und sinnvoll helfen? |
| Gute Challenge-Eignung mit Tap-Auswahl | Funktioniert der erste MVP-Challenge-Typ klar? |
| Gute spaetere Erweiterbarkeit | Kann die Insel spaeter wachsen, ohne neu gedacht zu werden? |
| Geringe Sensitivitaets-/Safety-Risiken | Entstehen wenig politische, medizinische, religioese oder persoenliche Risiken? |
| Produktionsaufwand | Braucht die Insel wenig neue Speziallogik, Animation oder Systeme? |
| Monetarisierungs-/Retention-Potenzial ohne Dark Patterns | Gibt es faire Sammel-, Deko-, Routine- oder Progressionsmomente? |

Bewertungsskala fuer die Matrix:

- `good`: fuer fruehe Planung stark geeignet.
- `medium`: brauchbar, aber mit Aufwand oder offener Frage.
- `risk`: nicht frueh ableiten; braucht eigene Regeln oder Tests.

## 3. Kandidatenbewertung

| ThemeIsland | Kurzbeschreibung | Passende Taxonomy-Kategorien | Erste Plots/Zonen | Erste Container-/Depth-Flows | Risiko | Empfehlung |
| --- | --- | --- | --- | --- | --- | --- |
| Zuhause / Alltag | Private Startwelt fuer Haus, Alltag, kleine Objekte und persoenliche Routinen. | Wohnbereiche, Grundstueck/Aussenbereich, Dekoration/Details | Core-Plot, Kueche, Zimmer, Hof, kleiner Garten | Kueche -> Schublade -> Besteck; Zimmer -> Schrank -> Kleidung; Flur -> Schluesselbrett -> Schluessel | Gefahr, wieder Hausstart zu erzwingen; muss frei waehlbar bleiben. | `early` |
| Schule / Lernen | Starker Lernkontext mit klaren Objekten und kurzen Aufgaben. | Oeffentliche Gebaeude, Lern-/Schulmaterialien, Dekoration/Details | Klassenzimmer, Bibliotheksecke, Federmappe, Regal | Schule -> Federmappe -> Stifte; Klassenzimmer -> Regal -> Hefte | Viele Kleinteile; Mobile-/Clutter-Regeln noetig. | `early` |
| Garten / Natur nah | Ruhiger Natur- und Wachstumsraum fuer konkrete Objekt- und Aktionswoerter. | Grundstueck/Aussenbereich, Natur/Gruenflaechen, Landwirtschaft | Beet, kleiner Naturplot, Geraetecke, Pflanzkiste | Garten -> Beet -> Samen/Giesskanne/Pflanze; Schuppen -> Kiste -> Werkzeug | Wachstum darf keine unfairen Timer oder Druck erzeugen. | `early` |
| Kueste / Meer / Hafen | Visuell starkes eigenes Biome fuer Wasser, Reise, Boot und Navigation. | Wasser/Hafen/Kueste, Reisen/Verkehr, Freizeit draussen | Strand, Anleger, Bootskajute, Navigationskiste | Hafen -> Bootskajute -> Kompass/Karte/Seil | Mobile-Komplexitaet, Wasser-/Fahrzeug-/Pfadlogik. | `mid` |
| Stadt / Dorfzentrum | Hub fuer Civic-, Social-, Wege- und Dienstleistungswoerter. | Stadt-/Dorfzentrum, Strassen/Wege, Einkauf/Versorgung, oeffentliche Gebaeude | Platz, Fussweg, Kiosk, Rathausplatz, Wochenmarkt | Kiosk -> Regal -> Zeitung; Markt -> Korb -> Ware | Hohe System- und Clutter-Gefahr; viele sensible Uebergaenge. | `late` |
| Einkauf / Versorgung | Shop- und Service-Welt fuer Waren, Preise, Listen und kurze Dialoge. | Einkauf/Versorgung, Stadt/Dorfzentrum, Essen/Gastronomie | Shop, Marktstand, Regal, Theke | Supermarkt -> Regal -> Apfel/Brot/Milch; Apotheke -> Schrank -> nur nach Safety | Viele Warenlisten; Apotheke sensibel. | `mid` |
| Essen / Restaurant / Cafe | Essen, Kochen, Bestellen und soziale Dialoge. | Gastronomie/Freizeit, Einkauf/Versorgung, Zuhause/Alltag | Kueche, Tisch, Theke, Vorratsregal | Restaurant -> Tisch -> Besteck; Kueche -> Schrank -> Zutaten | Viele Innenraeume und Prozesswoerter; scope-kritisch. | `mid` |
| Arbeit / Berufe / Werkstatt | Berufs-, Werkzeug- und Prozessvokabeln. | Arbeit/Gewerbe/Industrie, Fahrzeuge/Parken, Technik/Digital | Werkstatt, Buero, Werkzeugbank, Lager | Werkstatt -> Werkzeugkasten -> Hammer/Schraubenzieher | Produktionsketten und Maschinen koennen frueh explodieren. | `late` |
| Land / Farm | Farm, Tiere, Felder, Ernte und einfache Produktionsloops. | Landwirtschaft, Natur/Gruenflaechen, Arbeit/Gewerbe, Essen | Feld, Scheune, Stall, Hofladen | Feld -> Beet -> Samen; Scheune -> Kiste -> Werkzeug | Timer/Fairness, Tiere, Produktionsketten. | `mid` |
| Reisen / Verkehr | Wege, Fahrzeuge, Tickets, Bahnhof, Flughafen und Richtungen. | Reisen/Verkehr, Strassen/Wege, Fahrzeuge/Parken, oeffentliche Gebaeude | Bahnhof, Bushaltestelle, Ticketautomat, Kofferzone | Bahnhof -> Automat -> Ticket; Koffer -> Fach -> Kleidung | Connector-/Path-/Vehicle-Konzept fehlt. | `late` |
| Gesundheit | Koerper, Symptome, Pflege und medizinische Orte. | Oeffentliche Gebaeude, Einkauf/Versorgung, Gesundheitsobjekte | Arztpraxis, Apotheke, Medizinschrank | Praxis -> Schrank -> Verband; Apotheke -> Regal -> nur neutral | Sensibel, Safety und Datenschutz zentral. | `blocked_until_rules` |
| Freizeit / Sport | Bewegung, Spiele, Outdoor-Aktivitaeten und Routine. | Freizeit draussen, Gastronomie/Freizeit, Natur/Gruenflaechen | Sportplatz, Spielplatz, Campingplatz | Rucksack -> Fach -> Ball/Flasche; Spielplatz -> Geraet -> Aktion | Viele Aktionswoerter und Sequenzen. | `late` |
| Natur / Berge / Outdoor | Biome, Landschaft, Wetter, Ausruestung und Abenteuer. | Natur/Gruenflaechen, Freizeit draussen, Berge/Outdoor | Waldpfad, Berghuette, Aussichtspunkt, Rucksack | Berghuette -> Rucksack -> Karte/Flasche; Wald -> Baum -> Blatt | Wetter/Jahreszeiten und grosse Landschaften brauchen eigene Regeln. | `late` |
| Technik / Digital | Computer, App, Serverraum, Daten und technische Begriffe. | Technik/Digital, Arbeit/Gewerbe/Industrie, Schule/Lernen | Computerplatz, Labor, Serverraum, Geraeteregal | Schreibtisch -> Schublade -> Kabel; Computer -> Datei -> nur als abstrakter Flow | UI-in-UI-Gefahr; braucht klare Digital-Object-Abgrenzung. | `late` |
| Kultur / Gesellschaft / Verwaltung | Politik, Verwaltung, Kultur, Museum, Forum, Geschichte und sensible Begriffe. | Kultur/Geschichte, Verwaltung/Politik/Gesellschaft, oeffentliche Gebaeude | Forum, Museum, Rathaus, Codex-Raum | Museum -> Vitrine -> Objekt; Forum -> Dialogkarte -> Begriff | Sensible Darstellungs- und Safety-Regeln zwingend. | `blocked_until_rules` |

## 4. Erste Priorisierung

Diese Priorisierung ist eine erste Planungswelle, keine finale Roadmap.

### Early Candidates

Fruehe Kandidaten:

- `Zuhause / Alltag`
- `Schule / Lernen`
- `Garten / Natur nah`

Begruendung:

- viele konkrete Alltagswoerter,
- klare Container-/Depth-Flows,
- gute Tap-Auswahl-Eignung,
- starke Tali/Vori-Momente,
- relativ geringe Safety-Risiken,
- wenig neue Speziallogik.

### Mid Candidates

Gute zweite Welle:

- `Kueste / Meer / Hafen`
- `Essen / Restaurant / Cafe`
- `Einkauf / Versorgung`
- `Land / Farm`

Begruendung:

- hohe visuelle Attraktivitaet,
- gute Retention- und Sammelmomente,
- starke Wortsets,
- aber mehr Mobile-, Clutter-, Timer-, Wasser- oder Scope-Risiken.

### Late Candidates

Spaeter oder komplexer:

- `Stadt / Dorfzentrum`
- `Reisen / Verkehr`
- `Arbeit / Berufe / Werkstatt`
- `Freizeit / Sport`
- `Natur / Berge / Outdoor`
- `Technik / Digital`

Begruendung:

- wertvoll, aber systemisch komplexer,
- haeufig Connector-, Vehicle-, Prozess-, Aktions-, Wetter- oder UI-in-UI-
  Fragen,
- nicht fuer die erste ThemeIsland-Produktionswelle geeignet.

### Sensitive / Blocked Until Rules

Sensible Spezialthemen:

- `Gesundheit`
- `Kultur / Gesellschaft / Verwaltung`
- Religion,
- Politik,
- Gericht,
- Polizei,
- Krankenhaus.

Diese Themen brauchen vor jeder Produkt- oder Assetplanung eigene
Sensitive-Content-Darstellungsregeln, Safety-Pruefung, neutrale
Repraesentationsprinzipien und gegebenenfalls Datenschutz-/Alterslogik.

## 5. Visualisierungsplan

M12 erzeugt Dokumentations-/Preview-Dateien unter:

`docs/world_design/previews/phase2g_m12_theme_island_prioritization/`

Geplante Dateien:

1. `01_theme_island_priority_map.png`
   - gruppiert ThemeIslands nach `early`, `mid`, `late`, `special` und
     `blocked`.
2. `02_theme_island_decision_matrix.png`
   - zeigt Kandidaten gegen Kriterien mit `good`, `medium`, `risk`.
3. `03_early_candidate_flow_examples.png`
   - zeigt je einen einfachen Flow fuer Zuhause, Schule und Garten.
4. `04_scope_risk_wave_plan.png`
   - erklaert die Wellenlogik: Early einfach, Mid vielfaeltig, Late komplex,
     Special sensibel.
5. `README.md`
   - dokumentiert Zweck, Grenzen und Prueffazit.

Die Dateien sind keine Spielassets, keine finale UI und keine finale
ThemeIsland-Roadmap.

## 6. Prueffazit Fuer M12

Die erste Priorisierung wirkt als Planungsgrundlage plausibel:

- `Zuhause / Alltag` eignet sich fuer den emotionalen Start und den
  Kuechen-/Schubladen-Flow, darf aber keinen Hausbauzwang erzeugen.
- `Schule / Lernen` ist besonders stark fuer klare Container und Lernobjekte,
  braucht aber Kleinteile-/Clutter-Regeln.
- `Garten / Natur nah` ist stark fuer Wachstum, konkrete Objekte und ruhige
  Motivation, braucht aber Fairness-Regeln fuer Wachstum/Timer.
- `Kueste / Meer / Hafen` ist visuell sehr stark, sollte wegen Mobile- und
  Wasser-/Vehicle-Komplexitaet eher Mid bleiben.
- Stadt, Verkehr, Arbeit, Technik und grosse Outdoor-Systeme sollten spaeter
  kommen, weil sie viele neue Systeme gleichzeitig erzwingen.
- Gesundheit, Politik, Religion, Gericht, Polizei und Krankenhaus bleiben bis
  zu eigenen Sensitive-Content-Regeln blockiert.

## 7. Weiterhin Offene Folgeblocks

Weiterhin offen:

- `Phase 2G-M12-B Word-to-Island Routing Matrix`
- `Phase 2G-M12-C Plot-Capability Derivation`
- `Phase 2G-M12-D Sensitive Content Representation Rules`
- `Phase 2G-M12-E Mobile And Clutter Rules For Small Objects`

## 8. Stop-Regeln

Stoppen, wenn:

- aus M12 eine ThemeIsland-Umsetzung abgeleitet wird,
- aus M12 eine finale ThemeIsland-Roadmap abgeleitet wird,
- aus M12 Assetproduktion abgeleitet wird,
- eine Kuesten-/Hafeninsel ohne Mobile-Komplexitaetspruefung geplant wird,
- eine Gesundheits-, Politik-, Religion-, Gerichts-, Polizei- oder
  Krankenhausinsel ohne Sensitive-Content-Regeln geplant wird,
- eine Reise-/Verkehrsinsel ohne Connector-/Path-/Vehicle-Konzept geplant
  wird,
- eine Technik-/Digitalinsel ohne eigene Digital-Object-/UI-Abgrenzung geplant
  wird,
- eine fruehe Insel zu viele neue Systeme gleichzeitig erzwingt.

## 9. Naechster Erlaubter Schritt

Erlaubt:

- M12 visuell pruefen,
- M12 nachbessern,
- M12-B Word-to-Island Routing Matrix planen,
- M12-C Plot-Capability Derivation planen,
- M12-D Sensitive Content Representation Rules planen,
- M12-E Mobile And Clutter Rules planen.

Weiterhin nicht erlaubt:

- Code,
- App-Integration,
- Spielassets,
- finale Inselbilder,
- finale ThemeIsland-Roadmap,
- ThemeIsland-Umsetzung,
- `frame_started`.
