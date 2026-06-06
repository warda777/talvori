# Phase 2G-M11-C: World Content Taxonomy And Location Catalog

Stand: 2026-06-06

Status: `Dokumentationsnachtrag / Taxonomy-Backlog gestartet`

Dieses Dokument nimmt die umfangreiche Nutzerliste moeglicher Orte, Gebaeude,
Aussenbereiche, Infrastruktur, Naturflaechen, Wasserbereiche, Landwirtschaft
und Details als langfristigen Content-/Location-Katalog auf.

Der Katalog ist:

- ein Planungs- und Taxonomy-Backlog,
- keine Assetliste,
- keine Bau-Freigabe,
- keine finale ThemeIsland-Roadmap,
- keine Code-, App- oder Assetfreigabe.

Ziel ist, spaetere Weltthemen, Gebaeudearten, Aussenbereiche, Detailobjekte,
Container-/Depth-Flows und Word-to-Island-Routing nicht zu verlieren.

## 1. Zweck

Talvori braucht eine langfristig erweiterbare Weltlogik. Einzelne
Container-Flows wie Kueche/Schublade, Schule/Federmappe oder Garten/Beet
reichen nicht, um den gesamten Content-Raum zu steuern.

Dieser Katalog soll:

- grosse Weltbereiche als spaetere Themeninseln und Zonen einordnen,
- Gebaeude-, Plot-, Aussen-, Innen-, Container- und Detailbegriffe trennen,
- verhindern, dass grosse Kategorien auf die Starter-Waldlichtung gepresst
  werden,
- spaeter ThemeIsland-Routing, Plot-Capabilities, Depth-/Container-Planung,
  Word-to-World-Backlog und Asset-Priorisierung stuetzen.

## 2. Strukturierungsprinzip

Talvori-Content wird nach Groesse, Funktion, Kontext und Lernrolle geroutet.

| Ebene | Zweck | Beispiele |
| --- | --- | --- |
| `ThemeIsland` | Grober Lern-/Weltkontext | Stadtleben, Land/Farm, Kueste/Meer, Schule, Gesundheit, Arbeit, Freizeit, Natur, Reisen/Verkehr |
| `DistrictOrZone` | Bereich innerhalb einer Insel | Wohngebiet, Marktplatz, Hafenbereich, Gartenbereich, Industriegebiet |
| `PlotOrBuildingType` | baubare Flaeche oder Gebaeudeart | Einfamilienhaus, Supermarkt, Schule, Bootshaus, Werkstatt |
| `ExteriorArea` | Aussenbereich am Plot/Gebaeude | Vorgarten, Terrasse, Einfahrt, Hof, Beet, Parkplatz |
| `InteriorOrRoom` | Innenraum oder betretbarer Bereich | Kueche, Klassenzimmer, Bootskajute, Werkstatt, Praxisraum |
| `ContainerOrFocusObject` | fokussierbares Objekt oder Mini-Raum | Schublade, Federmappe, Werkzeugkasten, Medizinschrank, Navigationskiste |
| `DetailObjectOrDecoration` | kleines Objekt, Deko oder Lernobjekt | Loeffel, Bleistift, Kompass, Giesskanne, Bank, Laterne, Schild |

Regeln:

- Grosse Dinge gehoeren eher zu Insel, Zone, Plot oder Gebaeude.
- Kleine Woerter gehoeren eher zu Innenraum, Container, Detailansicht oder
  Codex.
- Deko darf Atmosphaere schaffen, aber Gameplay und Lernobjekte nicht
  ueberladen.
- Nicht jedes Wort braucht ein eigenes sichtbares Asset.
- Manche Begriffe sind Kulisse, andere lernrelevant, andere Build- oder
  Progressionsobjekte.
- Content wird erst produktiv, wenn Plot-Capabilities, Word-to-Island-Routing
  und Depth-Level passen.

## 3. Prioritaetswerte

| Prioritaet | Bedeutung |
| --- | --- |
| `early_candidate` | Fuer fruehe Prototypen oder erste Themeninsel gut geeignet. |
| `later_candidate` | Wertvoll, aber nicht fuer den ersten Scope. |
| `decoration_pool` | Primaer fuer Atmosphaere und kleine Detailanker. |
| `special_theme` | Braucht eigene Themeninsel oder eigenes System. |
| `requires_own_system` | Nicht als einfache Deko behandeln; braucht eigene Regeln. |

## 4. Hauptkategorien

### 4.1 Wohnbereiche

| Feld | Inhalt |
| --- | --- |
| Zweck fuer Talvori | Wohnformen als Gebaeude-Archetypen, Identitaet und Alltagsvokabular sammeln. |
| ThemeIsland-Zuordnung | Zuhause/Alltag, Stadtleben, Land/Farm, Kueste/Meer, Berge/Outdoor. |
| Plot-/Zone-Rolle | `PlotOrBuildingType`, Wohnplot, Interior-Ausgangspunkt. |
| Container-/Depth-Potenzial | Haus -> Raum -> Moebel -> Container; Apartment -> Zimmer; Hausboot -> Kajute. |
| Beispiele | Einfamilienhaus, Apartmenthaus, Tiny House, Bauernhaus, Stadthaus, Hausboot, Berghuette, Strandhaus. |
| Risiko / Scope-Hinweis | Nicht alle Wohnformen im MVP; als spaetere Building-Archetypes behandeln. |
| Prioritaet | `early_candidate` fuer einfaches Zuhause; sonst `later_candidate` oder `special_theme`. |

### 4.2 Grundstueck Und Aussenbereich Am Haus

| Feld | Inhalt |
| --- | --- |
| Zweck fuer Talvori | Aussenbereiche fuer Haus-, Garten- und Alltagsvokabular strukturieren. |
| ThemeIsland-Zuordnung | Zuhause/Alltag, Garten/Natur, Land/Farm, Freizeit. |
| Plot-/Zone-Rolle | `ExteriorArea`, Plot-Erweiterung, ObjectAnchor-/DecorationAnchor-Flaeche. |
| Container-/Depth-Potenzial | Garten -> Beet -> Samen/Giesskanne; Terrasse -> Tisch/Topf; Gewaechshaus -> Pflanzenregal. |
| Beispiele | Vorgarten, Hauptgarten, Hintergarten, Terrasse, Balkon, Gewaechshaus, Teich, Pool, Gartenhaus, Zaun, Hecke, Tor. |
| Risiko / Scope-Hinweis | Viele Elemente eignen sich fuer Depth-Flows, duerfen aber die Starterinsel nicht ueberladen. |
| Prioritaet | `early_candidate` fuer Garten/Beet; sonst `later_candidate` oder `decoration_pool`. |

### 4.3 Fahrzeuge, Parken Und Nebenbauten

| Feld | Inhalt |
| --- | --- |
| Zweck fuer Talvori | Verkehr, Werkstatt, Mobilitaet und Nebenbau-Vokabular vorbereiten. |
| ThemeIsland-Zuordnung | Reisen/Verkehr, Stadtleben, Arbeit/Gewerbe, Zuhause/Alltag, Land/Farm. |
| Plot-/Zone-Rolle | Garage, Carport, Stellplatz, Werkstatt, Lieferzone, VehicleArea. |
| Container-/Depth-Potenzial | Auto -> Kofferraum; Werkstatt -> Werkzeugkasten; Garage -> Regal/Reifen. |
| Beispiele | Garage, Carport, Stellplatz, E-Ladestation, Werkstatt, Scheune, Lieferzone. |
| Risiko / Scope-Hinweis | Fahrzeuge brauchen eigene Groessen-, Bewegungs- und Interaktionslogik. |
| Prioritaet | `requires_own_system` fuer Fahrzeuge; `later_candidate` fuer Garage/Werkstatt. |

### 4.4 Strassen Und Wege

| Feld | Inhalt |
| --- | --- |
| Zweck fuer Talvori | Navigation, Connectoren, Wege und Verkehrswoerter systematisch vorbereiten. |
| ThemeIsland-Zuordnung | Stadtleben, Reisen/Verkehr, Dorf, Arbeit, Kueste. |
| Plot-/Zone-Rolle | Connector-/Path-System, `path_socket`, District-Verbindung. |
| Container-/Depth-Potenzial | Haltestelle -> Fahrplan; Bruecke -> Gelander/Schild; Kreuzung -> Ampel/Zebrastreifen. |
| Beispiele | Hauptstrasse, Nebenstrasse, Fussweg, Radweg, Bruecke, Unterfuehrung, Kreisverkehr, Zebrastreifen, Bushaltestelle. |
| Risiko / Scope-Hinweis | Nicht als Deko allein behandeln; Wege beeinflussen Navigation und Anschluesse. |
| Prioritaet | `requires_own_system`. |

### 4.5 Stadt- Und Dorfzentrum

| Feld | Inhalt |
| --- | --- |
| Zweck fuer Talvori | Civic-, Social- und Hub-Orte fuer Stadt-/Dorfvokabular sammeln. |
| ThemeIsland-Zuordnung | Stadtleben, Dorf, Verwaltung/Gesellschaft, Markt. |
| Plot-/Zone-Rolle | Hub-Zone, Marktplatz, Civic-Zone, Social-Zone. |
| Container-/Depth-Potenzial | Kiosk -> Regal; Wochenmarkt -> Stand/Korb; Rathausplatz -> Schild/Denkmal. |
| Beispiele | Marktplatz, Rathausplatz, Fussgaengerzone, Wochenmarkt, Kiosk, Denkmal, Uhrturm. |
| Risiko / Scope-Hinweis | Gut fuer Stadt- oder Dorfinsel, nicht fuer die Waldlichtung erzwingen. |
| Prioritaet | `special_theme` oder `later_candidate`. |

### 4.6 Einkauf Und Versorgung

| Feld | Inhalt |
| --- | --- |
| Zweck fuer Talvori | Shop-, Service- und Alltagsversorgung als Lernkontexte abbilden. |
| ThemeIsland-Zuordnung | Stadtleben, Essen/Restaurant/Markt, Gesundheit, Arbeit, Zuhause/Alltag. |
| Plot-/Zone-Rolle | Shop-/Service-Buildings, Marktstaende, Hub-nahe Plots. |
| Container-/Depth-Potenzial | Supermarkt -> Regal/Korb; Baeckerei -> Theke; Apotheke -> Schrank. |
| Beispiele | Supermarkt, Baeckerei, Apotheke, Buchhandlung, Baumarkt, Blumenladen, Wochenmarkt. |
| Risiko / Scope-Hinweis | Viele Vocabulary-Sets, aber hohe Scope-Gefahr durch Innenraeume und Warenlisten. |
| Prioritaet | `later_candidate`; Apotheke teils `special_theme` wegen Gesundheit. |

### 4.7 Gastronomie Und Freizeit

| Feld | Inhalt |
| --- | --- |
| Zweck fuer Talvori | Essen, Freizeit, Tourismus und Aktivitaeten als spaetere Lernraeume sammeln. |
| ThemeIsland-Zuordnung | Essen/Restaurant/Markt, Freizeit, Stadtleben, Reisen/Verkehr. |
| Plot-/Zone-Rolle | Freizeit-/Service-/Tourismusbereiche. |
| Container-/Depth-Potenzial | Restaurant -> Kueche/Tisch; Cafe -> Theke; Hotel -> Zimmer/Koffer. |
| Beispiele | Restaurant, Cafe, Hotel, Kino, Theater, Schwimmbad, Fitnessstudio. |
| Risiko / Scope-Hinweis | Braucht spaeter eigene Innenraum-, Aktivitaets- und Interaktionsflows. |
| Prioritaet | `later_candidate` oder `special_theme`. |

### 4.8 Oeffentliche Gebaeude

| Feld | Inhalt |
| --- | --- |
| Zweck fuer Talvori | Bildung, Gesundheit, Verwaltung, Sicherheit und Transport als grosse Themen sammeln. |
| ThemeIsland-Zuordnung | Schule/Lernen, Gesundheit, Verwaltung/Gesellschaft, Reisen/Verkehr, Stadtleben. |
| Plot-/Zone-Rolle | PublicService-, Education-, Health- und Transport-Buildings. |
| Container-/Depth-Potenzial | Schule -> Klassenzimmer -> Federmappe; Krankenhaus -> Praxisraum -> Medizinschrank; Bahnhof -> Ticketautomat. |
| Beispiele | Rathaus, Polizeistation, Feuerwehrhaus, Schule, Kindergarten, Universitaet, Bibliothek, Krankenhaus, Bahnhof. |
| Risiko / Scope-Hinweis | Sensible Bereiche wie Krankenhaus, Polizei, Politik oder Religion brauchen neutrale Darstellung und Safety-Pruefung. |
| Prioritaet | `special_theme`; Schule kann `early_candidate` fuer Lernkontext sein. |

### 4.9 Arbeit, Gewerbe Und Industrie

| Feld | Inhalt |
| --- | --- |
| Zweck fuer Talvori | Berufs-, Werkzeug-, Prozess- und Produktionsvokabular vorbereiten. |
| ThemeIsland-Zuordnung | Arbeit/Firmen/Berufe, Technik/Labor, Land/Farm, Stadt/Industrie. |
| Plot-/Zone-Rolle | Work-, Production-, Profession- und Industry-Zones. |
| Container-/Depth-Potenzial | Werkstatt -> Werkzeugkasten; Labor -> Geraet/Schrank; Buero -> Schreibtisch/Ordner. |
| Beispiele | Buerogebaeude, Fabrikhalle, Werkstatt, Autowerkstatt, Forschungslabor, Rechenzentrum, Bauernhof, Baustelle. |
| Risiko / Scope-Hinweis | Stark fuer Prozessvokabeln, aber Produktionsketten duerfen nicht zu frueh explodieren. |
| Prioritaet | `later_candidate`, teils `requires_own_system`. |

### 4.10 Natur- Und Gruenflaechen

| Feld | Inhalt |
| --- | --- |
| Zweck fuer Talvori | Biome, Kulisse, Naturwoerter und ruhige Lernorte sammeln. |
| ThemeIsland-Zuordnung | Natur, Land/Farm, Berge/Outdoor, Kueste/Meer, Freizeit. |
| Plot-/Zone-Rolle | Biome, Landschaftsplots, Nature-Zones, Edge-Zones. |
| Container-/Depth-Potenzial | Wald -> Baum/Blatt; See -> Ufer/Stein; Feld -> Pflanze/Samen. |
| Beispiele | Park, Wald, Wiese, Berg, See, Fluss, Strand, Klippe, Feld, Weinberg, Aussichtspunkt. |
| Risiko / Scope-Hinweis | Gut fuer Themeninseln und Kulisse; nicht jedes Naturwort braucht ein eigenes Asset. |
| Prioritaet | `early_candidate` fuer einfache Natur; sonst `special_theme` oder `decoration_pool`. |

### 4.11 Freizeitflaechen Draussen

| Feld | Inhalt |
| --- | --- |
| Zweck fuer Talvori | Aktionswoerter, Sport, Bewegung und Aktivitaetszonen vorbereiten. |
| ThemeIsland-Zuordnung | Sport/Freizeit, Natur/Outdoor, Reisen/Verkehr, Kueste/Meer. |
| Plot-/Zone-Rolle | Activity-Zones, Event-Zones, Sport-/Outdoor-Plots. |
| Container-/Depth-Potenzial | Spielplatz -> Schaukel/Rutsche; Campingplatz -> Zelt/Rucksack; Bootssteg -> Kiste/Seil. |
| Beispiele | Spielplatz, Sportplatz, Skatepark, Campingplatz, Bootssteg, Reitplatz, Aussichtsturm. |
| Risiko / Scope-Hinweis | Viele Aktionswoerter; Mini-Sequenzen erst nach separater Aktionslogik pruefen. |
| Prioritaet | `later_candidate` oder `special_theme`. |

### 4.12 Wasser, Hafen Und Kuestenbereiche

| Feld | Inhalt |
| --- | --- |
| Zweck fuer Talvori | Meer, Reisen, Navigation, Boote, Wetter und Wasserwoerter trennen. |
| ThemeIsland-Zuordnung | Kueste/Meer, Reisen/Verkehr, Freizeit, Arbeit/Fischerei. |
| Plot-/Zone-Rolle | Coast/Sea/Travel-ThemeIsland, Harbor-Zone, WaterEdge-Plot. |
| Container-/Depth-Potenzial | Boot -> Kajute; Hafen -> Fischkiste; Leuchtturm -> Laterne; Bootshaus -> Werkzeug. |
| Beispiele | Hafen, Marina, Anleger, Leuchtturm, Bootshaus, Werft, Fischmarkt, Schleuse, Rettungsturm. |
| Risiko / Scope-Hinweis | Nicht auf Waldlichtung pressen; eigene Kuesteninsel ist sinnvoll. |
| Prioritaet | `special_theme`. |

### 4.13 Landwirtschaft Und Laendliche Bereiche

| Feld | Inhalt |
| --- | --- |
| Zweck fuer Talvori | Wachstum, Tiere, Werkzeuge, Ernte und Produktionsloops vorbereiten. |
| ThemeIsland-Zuordnung | Land/Farm, Natur, Essen/Markt, Arbeit/Gewerbe. |
| Plot-/Zone-Rolle | Farm-Plots, Barn-Zones, Field-Zones, Production-Zones. |
| Container-/Depth-Potenzial | Scheune -> Werkzeug; Stall -> Futter; Acker -> Samen/Pflanze; Hofladen -> Kiste/Regal. |
| Beispiele | Bauernhof, Scheune, Stall, Weide, Acker, Traktorhalle, Silo, Hofladen, Muehle. |
| Risiko / Scope-Hinweis | Stark fuer Wachstum und Produktionsloops, aber Timer/Fortschritt muessen fair bleiben. |
| Prioritaet | `special_theme`, teils `early_candidate` fuer Garten/Feld. |

### 4.14 Dekoration Und Details Fuer Lebendigkeit

| Feld | Inhalt |
| --- | --- |
| Zweck fuer Talvori | Atmosphaere, Lesbarkeit und kleine Lern-/Dekoobjekte sammeln. |
| ThemeIsland-Zuordnung | Alle Inseln, je nach Kategorie und Stil. |
| Plot-/Zone-Rolle | `DecorationPool`, `AmbientObject`, `DetailAnchor`, `ObjectAnchor`. |
| Container-/Depth-Potenzial | Briefkasten -> Brief; Laterne -> Licht; Bank -> Sitz-/Ortswort; Schild -> Text-/Richtungswort. |
| Beispiele | Strassenlaternen, Baenke, Muelltonnen, Schilder, Ampeln, Briefkaesten, Blumenkuebel, Fahnen, Zaeune, Baeume, Steine, Paletten, Container. |
| Risiko / Scope-Hinweis | Deko darf Atmosphaere schaffen, aber UI und Lernobjekte nicht ueberladen. Keine Deko-Massenproduktion ohne Clutter-Regeln. |
| Prioritaet | `decoration_pool`, teils `later_candidate`. |

## 5. Routing-Regeln Fuer Begriffe

Jeder neue Begriff aus Lernen, Import, Nutzerwunsch oder Content-Planung wird
zuerst geroutet:

1. Welche Bedeutung / Sense?
2. Welche Kategorie?
3. Welche ThemeIsland passt?
4. Welche Ebene passt?
   - Insel/Zone,
   - Plot/Gebaeude,
   - Aussenbereich,
   - Innenraum,
   - Container,
   - Detailobjekt,
   - Dekoration,
   - Codex/Blueprint/Backlog.
5. Gibt es passende Plot-Capabilities?
6. Gibt es passende Depth-/Container-Level?
7. Ist die Darstellung lernrelevant, atmosphaerisch oder nur Backlog?
8. Gibt es Safety-/Sensitivity-Risiken?
9. Ist Nutzerbestaetigung noetig?

## 6. Scope-Regeln

- Nicht alles wird gebaut.
- Nicht alles kommt auf die Starterinsel.
- Nicht alles braucht ein eigenes Asset.
- Grosse Kategorien werden ueber ThemeIslands getrennt.
- Die Waldlichtung bleibt Starter-/Testform und darf nicht Stadt, Hafen,
  Industrie, Krankenhaus, Flughafen, Landwirtschaft und alle Details tragen.
- Content darf erst produktiv werden, wenn Plot-Capabilities,
  Word-to-Island-Routing und Depth-Level passen.
- Der Katalog dient spaeter als Grundlage fuer ThemeIsland-Roadmap,
  Asset-Priorisierung und Lernwort-Routing.
- Katalogbegriffe duerfen in Codex, Blueprint, Backlog oder Future Island
  Suggestion landen, wenn der passende Ort noch fehlt.

## 7. Stop-Regeln

Stoppen, wenn:

- ein Katalogbegriff ohne Routing-Entscheidung umgesetzt werden soll,
- eine grosse Kategorie auf die Starterinsel gepresst werden soll,
- aus dem Taxonomy-Katalog Assetproduktion abgeleitet wird,
- eine ThemeIsland-Umsetzung ohne Priorisierung und Scope-Gate gestartet wird,
- Deko-Massenproduktion ohne Clutter-Regeln geplant wird,
- oeffentliche, medizinische, religioese oder politische Gebaeude ohne
  sensible Darstellungspruefung geplant werden,
- Verkehrs-/Strassenlogik ohne eigenes Connector-/Path-Konzept umgesetzt
  werden soll,
- Fahrzeug-/Parklogik ohne Groessen- und Interaktionsregeln geplant wird.

## 8. Naechster Erlaubter Schritt

Erlaubt:

- diesen Taxonomy-Katalog reviewen,
- spaeter einzelne ThemeIsland-Kandidaten priorisieren,
- spaeter Plot-Capabilities je Kategorie ableiten,
- spaeter Word-to-Island-Routing anhand dieses Katalogs verfeinern.

Nicht erlaubt:

- Code,
- Assets,
- App-Integration,
- finale Themeninsel-Roadmap,
- finale Container-Systemarchitektur,
- `frame_started`,
- Bauzustaende.

