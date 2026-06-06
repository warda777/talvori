# Phase 2G-M13-C: ThemeIsland Capability Sheets

Stand: 2026-06-06

Status: `Planung gestartet / Capability Sheets erstellt`

## 1. Zweck

Dieses Dokument konkretisiert die ThemeIsland-Roadmap aus M13/M13-A2 und die
reversible Foundation-Wahl aus M13-B/M13-B2. Es sammelt pro ThemeIsland-
Kandidat Lernbereiche, Worttypen, moegliche Plot-Faehigkeiten, Gebaeude- und
Container-Ideen, Risiken, Gates und Stop-Regeln.

Die Capability Sheets sind nur Planungs- und Strukturmaterial. Sie sind keine
finale ThemeIsland-Roadmap, keine finale Startinsel, keine Assetliste, keine
finale Datenstruktur, keine Runtime-Konfiguration, keine App-Integration und
keine ThemeIsland-Umsetzung.

## 2. Bezug Zu M12 Und M13

M12 bis M12-F klaeren die Grundlage:

- ThemeIsland-Priorisierung,
- Word-to-Island Routing,
- Plot-Capability-Ableitung,
- Sensitive-Content-Regeln,
- Mobile-/Clutter-Regeln,
- konsolidierte Readiness fuer weitere reine Planung.

M13 und M13-A2 ordnen ThemeIsland-Kandidaten in Wellen:

- Foundation / Starter Learning World,
- Expansion Wave 1,
- Expansion Wave 2,
- System-Heavy Wave,
- Sensitive / Special Wave.

M13-B und M13-B2 bestaetigen Hybrid als erste Onboarding-Choice-
Planungsrichtung. Die erste Wahl ist ein reversibler Lernfokus, keine finale
Startinsel.

M13-C fuehrt diese Planungsstraenge zusammen, ohne Umsetzung freizugeben.

## 3. Einheitliche Capability-Sheet-Struktur

Jedes ThemeIsland Sheet nutzt folgende Struktur:

| Feld | Bedeutung |
| --- | --- |
| ThemeIsland-Name | Arbeitstitel des Themeninsel-Kandidaten. |
| Roadmap-Welle | Foundation, Expansion Wave 1, Expansion Wave 2, System-Heavy oder Sensitive/Special. |
| Kurzrolle im Lernsystem | Warum dieses Thema fuer Lernen und Weltbau relevant ist. |
| Geeignete Lernbereiche / Wortfelder | Typische Vocabulary-Sets und Alltagsbereiche. |
| Geeignete Worttypen | Objekte, Orte, Aktionen, Rollen, Prozesse, abstrakte Begriffe usw. |
| Moegliche Zonen | Grobe Bereiche innerhalb der Insel. |
| Moegliche Plot-/Gebaeude-Faehigkeiten | `allowedFunctions`, Zonen- oder Plotfaehigkeiten, aber keine Pflichtbelegung. |
| Moegliche Container-/Depth-Beispiele | Beispiele fuer Interior, Container, Focus Object oder DetailInteractionView. |
| Direkt sichtbar | Was frueh als Fokus, Zone oder ruhiges Objekt sichtbar sein koennte. |
| Codex / Blueprint / Backlog | Was nicht direkt sichtbar sein darf oder erst spaeter passt. |
| Gates vor Umsetzung | Pruefungen, die vor jeder Umsetzung noetig bleiben. |
| Mobile-/Clutter-Risiken | Kleinteile, Labels, Tap-Ziele, Ueberladung. |
| Sensitive-/Safety-Risiken | Sensible Begriffe, Institutionen, Koerper, Politik, Religion usw. |
| Fairness-/Timer-/Retention-Risiken | Druck, harte Timer, Streak-Zwang, Paywall oder manipulative Wartezeiten. |
| Nicht-Freigaben / Stop-Regeln | Was aus dem Sheet nicht abgeleitet werden darf. |

## 4. Foundation Capability Sheets

### 4.1 Zuhause / Alltag

| Feld | Inhalt |
| --- | --- |
| ThemeIsland-Name | Zuhause / Alltag |
| Roadmap-Welle | Foundation / Starter Learning World |
| Kurzrolle im Lernsystem | Vertrauter Alltagsfokus fuer erste Woerter, Raeume, Container und kleine Objekte. |
| Geeignete Lernbereiche / Wortfelder | Haushalt, Kueche, Zimmer, Eingang, Moebel, einfache Gegenstaende, einfache Routinen. |
| Geeignete Worttypen | Konkrete Objekte, Raeume, Moebel, Container, einfache Aktionen, Gebaeudeteile mit Blueprint-Zustand. |
| Moegliche Zonen | Kuechenbereich, Zimmerbereich, Eingang, kleiner Aussenbereich, Regal-/Ablagebereich. |
| Moegliche Plot-/Gebaeude-Faehigkeiten | `home`, `decoration`, `learningHub`, `path`, klein `workshop` spaeter; `core_plot` oder `residential_capable_plot`, aber nicht automatisch Haus. |
| Moegliche Container-/Depth-Beispiele | Kueche -> Schublade -> Besteck; Zimmer -> Kiste -> Spielzeug/Gegenstaende; Eingang -> Ablage -> Schluessel. |
| Direkt sichtbar | Ruhiger Wohn-/Alltagsbereich, wenige Fokusobjekte, grobe Raum- oder Container-Einstiege. |
| Codex / Blueprint / Backlog | Gebaeudeteile wie `window`, `door`, `wall`, wenn kein passender Bauzustand existiert; abstrakte Alltagsbegriffe; ueberzaehlige Kleinteile. |
| Gates vor Umsetzung | Kein Pflicht-Hausstart; Onboarding-Wahl muss reversibel sein; Device-/Accessibility-/Tap-Target-Pruefung; Clutter-Regeln fuer Kleinteile. |
| Mobile-/Clutter-Risiken | Schluessel, Besteck, kleine Haushaltsobjekte, Labels und Detailobjekte koennen Mobile-Ansichten ueberladen. |
| Sensitive-/Safety-Risiken | Koerpernahe, private, familiaere oder gesundheitliche Woerter muessen bei Bedarf neutral in Codex/Dialog bleiben. |
| Fairness-/Timer-/Retention-Risiken | Zuhause darf keine Pflichtpflege, Verfallslogik oder Schuldmechanik bekommen. |
| Nicht-Freigaben / Stop-Regeln | Kein Pflicht-Hausstart, keine automatische Hausbaupflicht, keine Gebaeudeteile ohne Blueprint/Bauzustand, keine finale Startinsel, keine Assetliste. |

Warum geeignet:

Zuhause / Alltag ist als Foundation-Kandidat stark, weil viele Lernwoerter
sofort verstaendlich sind und kleine Gegenstaende gut ueber Depth und Container
organisiert werden koennen. Das Thema unterstuetzt fruehe Nutzerwahl, weil es
vertraut ist, darf aber Talvori nicht auf ein Hausbau-Spiel reduzieren.

Gefaehrlich falsch platzierbare Woerter:

- `window`, `door`, `roof`, `wall`: nur mit passendem Bauzustand oder
  Blueprint, nicht als frei schwebendes Objekt.
- `key`: nicht dauerhaft als Minipixel in IslandView, eher Container oder
  DetailInteractionView.
- `family`, `privacy`, `illness`, `medicine`: ggf. Codex, ContextCard oder
  M12-D-Regeln.

### 4.2 Schule / Lernen

| Feld | Inhalt |
| --- | --- |
| ThemeIsland-Name | Schule / Lernen |
| Roadmap-Welle | Foundation / Starter Learning World |
| Kurzrolle im Lernsystem | Lernnaher, objektklarer Fokus fuer Schreibzeug, Buecher, einfache Aufgaben und organisierte Container. |
| Geeignete Lernbereiche / Wortfelder | Schreibzeug, Buecher, Klassenzimmer, einfache Schulaktionen, Lernmaterialien, Ordnung, Aufgaben. |
| Geeignete Worttypen | Kleine Objekte, ContainerItems, Moebel, Lernorte, einfache Aktionen, Rollen vorsichtig. |
| Moegliche Zonen | Klassenzimmer, Tisch, Regal, ruhige Lernnische, Federmappen-Fokus. |
| Moegliche Plot-/Gebaeude-Faehigkeiten | `school`, `learningHub`, `decoration`, `path`, klein `social` spaeter; kein automatischer Schulgebaeudezwang. |
| Moegliche Container-/Depth-Beispiele | Klassenzimmer -> Federmappe -> Bleistift/Radiergummi/Lineal; Regal -> Buch/Heft; Tisch -> Aufgabe/Zuordnung. |
| Direkt sichtbar | Wenige grosse Fokusobjekte wie Tisch, Regal, Federmappe oder Buchstapel. |
| Codex / Blueprint / Backlog | Zu viele Stifte, Hefte, kleine Gegenstaende, Rollen, Schulstress, Pruefungsangst oder sensible Bildungskontexte. |
| Gates vor Umsetzung | Emotionale Produktdarstellung, echte Mobile-/Clutter-Regeln, Tap-Target-Pruefung, keine Pflichtschule-Anmutung. |
| Mobile-/Clutter-Risiken | Federmappe, Stifte, Radiergummi, Lineal und kleine Labels koennen schnell ueberladen. |
| Sensitive-/Safety-Risiken | Stress, Pruefungsangst, Mobbing, Leistung, soziale Konflikte muessen neutral und optional bleiben. |
| Fairness-/Timer-/Retention-Risiken | Kein Druck durch Hausaufgaben-, Strafen-, Streak- oder Pflichtschul-Mechanik. |
| Nicht-Freigaben / Stop-Regeln | Keine Schule-/Kleinteile-Umsetzung ohne M12-E-Regeln, keine finale Schulinsel, keine finale UI, keine Assetproduktion. |

Warum geeignet:

Schule / Lernen passt stark zum Produktkern, weil Lerngegenstaende und erste
Challenges natuerlich wirken. Damit diese Option motivierend bleibt, muss sie
freundlich und spielnah wirken, nicht wie ein digitales Arbeitsblatt.

Gefaehrlich falsch platzierbare Woerter:

- `pencil`, `eraser`, `ruler`: nicht dauerhaft in IslandView, sondern in
  Federmappe, DetailInteraction oder Codex.
- `exam`, `grade`, `failure`: nicht als Druck- oder Retention-Mechanik.
- `teacher`, `student`: Rollen brauchen Kontext und soziale Sensibilitaet.

### 4.3 Garten / Natur Nah

| Feld | Inhalt |
| --- | --- |
| ThemeIsland-Name | Garten / Natur nah |
| Roadmap-Welle | Foundation / Starter Learning World |
| Kurzrolle im Lernsystem | Freundlicher Natur- und Wachstumsfokus mit starker Symbolik fuer Lernfortschritt. |
| Geeignete Lernbereiche / Wortfelder | Pflanzen, Gartenwerkzeuge, Beet, Wetter niedrigschwellig, Farben, Pflege, einfache Naturprozesse. |
| Geeignete Worttypen | Pflanzen, SmallTools, einfache Prozesse, Sequenzen spaeter, Natur-Details, Dekoration begrenzt. |
| Moegliche Zonen | Beet, Pflanzkiste, Geraeteecke, kleiner Weg, ruhige Wiese, Kompost/Erde spaeter. |
| Moegliche Plot-/Gebaeude-Faehigkeiten | `garden`, `nature`, `decoration`, `path`, klein `food` spaeter; `edge_nature_capable_plot` oder `edge_farm_capable_plot` erst mit Gates. |
| Moegliche Container-/Depth-Beispiele | Garten -> Beet -> Samen/Giesskanne/Pflanze; Geraeteecke -> Werkzeug; Pflanzkiste -> Samen/Erde. |
| Direkt sichtbar | Beet, wenige Pflanzen, Geraeteecke, groessere Tools wie Giesskanne. |
| Codex / Blueprint / Backlog | Viele Pflanzenvarianten, Tiere, komplexes Wachstum, Wetter, Farmproduktion und Timerlogik bis zu eigenen Regeln. |
| Gates vor Umsetzung | Fairness-/Timer-Regeln, Mobile-/Clutter-Pruefung, keine manipulative Growth-/Streak-Mechanik. |
| Mobile-/Clutter-Risiken | Zu viele Pflanzen, Steine, Deko, Samen und Labels koennen den Screen ueberladen. |
| Sensitive-/Safety-Risiken | Tiere, Krankheit von Pflanzen/Tieren, Umweltkatastrophen oder Angstbegriffe brauchen spaetere Regeln. |
| Fairness-/Timer-/Retention-Risiken | Wachstum darf nicht als harter Timer, Verlustdruck, Paywall oder Streak-Strafe funktionieren. |
| Nicht-Freigaben / Stop-Regeln | Keine Garten-/Growth-Mechanik ohne Fairness-/Timer-Regeln, keine Farmableitung ohne eigenes System, keine finale Startinsel. |

Warum geeignet:

Garten / Natur nah wirkt emotional freundlich und unterstuetzt Fortschritts-
Metaphern. Es ist als Foundation-Kandidat geeignet, solange Wachstum nicht als
Manipulation, Wartezwang oder Druckmechanik verstanden wird.

Gefaehrlich falsch platzierbare Woerter:

- `seed`: nicht als Massendeko, sondern Container/Detail oder Quest.
- `water`, `grow`, `harvest`: eher Prozess oder Sequenz, nicht automatisch
  statisches Objekt.
- `animal`, `disease`, `storm`: nur mit spaeteren Regeln.

## 5. Expansion Wave 1 Capability Sheets

### 5.1 Essen / Restaurant / Cafe

| Feld | Inhalt |
| --- | --- |
| Roadmap-Welle | Expansion Wave 1 |
| Kurzrolle | Starkes Alltags- und Dialogthema fuer Essen, Bestellung, Zutaten und Service. |
| Lernbereiche / Wortfelder | Essen, Zutaten, Besteck, Kochen, einfache Dialoge, Bestellung, Tisch. |
| Worttypen | DetailObjects, ContainerItems, Aktionen, Rollen, einfache Sequenzen. |
| Zonen | Kueche, Tischbereich, Theke, Vorratsregal. |
| Plot-/Gebaeude-Faehigkeiten | `food`, `market`, `social`, `interiorAllowed`, `containerAllowed`. |
| Container-/Depth-Beispiele | Regal -> Zutaten; Tisch -> Besteck; Kueche -> Topf/Zutaten; Bestellung -> Dialog. |
| Hauptgates | Food-/Service-Flow, Mobile-Clutter, keine reine Objektliste, keine finale Restaurantinsel. |
| Hauptrisiko | Viele kleine Objekte und Dialog-/Service-Komplexitaet. |

### 5.2 Einkauf / Versorgung

| Feld | Inhalt |
| --- | --- |
| Roadmap-Welle | Expansion Wave 1 |
| Kurzrolle | Wortschatz fuer Kaufen, Shops, Produkte, Versorgung und einfache Alltagsdialoge. |
| Lernbereiche / Wortfelder | Supermarkt, Marktstand, Apotheke neutral, Baeckerei, Produkte, Preise, Kaufen. |
| Worttypen | Objekte, Orte, Aktionen, Dialoge, Rollen, Zahlen/Preise spaeter. |
| Zonen | Marktstand, Regal, Kasse, kleiner Shop, Versorgungspunkt. |
| Plot-/Gebaeude-Faehigkeiten | `market`, `food`, `social`, `hub`, `path`, `containerAllowed`. |
| Container-/Depth-Beispiele | Regal -> Produkte; Korb -> Objekte; Kasse -> Dialog; Marktstand -> Auswahl. |
| Hauptgates | Clutter-Regeln, Shop-/Dialog-Konzept, keine Paywall- oder Kaufdruck-Metapher. |
| Hauptrisiko | Zu viele Produkte, Monetarisierungsassoziationen, sensible Versorgung wie Medikamente. |

### 5.3 Land / Farm

| Feld | Inhalt |
| --- | --- |
| Roadmap-Welle | Expansion Wave 1 |
| Kurzrolle | Erweiterung von Garten in Richtung Tiere, Werkzeuge, Produktion und Laendlichkeitswortschatz. |
| Lernbereiche / Wortfelder | Bauernhof, Stall, Acker, Werkzeuge, Tiere, Pflanzen, einfache Produktionsketten. |
| Worttypen | Natur, Tiere, Tools, Sequenzen, Prozesse, Orte. |
| Zonen | Acker, Stall, Scheune, Geraeteecke, Hofladen spaeter. |
| Plot-/Gebaeude-Faehigkeiten | `farm`, `garden`, `nature`, `workshop`, `path`, `sequenceAllowed` spaeter. |
| Container-/Depth-Beispiele | Scheune -> Werkzeug; Hofladen -> Produkte; Acker -> Samen/Ernte als spaetere Sequenz. |
| Hauptgates | Fairness-/Timer-Regeln, Tierdarstellung, Produktionsloop-Regeln. |
| Hauptrisiko | Manipulative Timer, Produktionsdruck, Tier-/Pflege-Sensibilitaet. |

## 6. Expansion Wave 2 Capability Sheets

### 6.1 Kueste / Meer / Hafen

| Feld | Inhalt |
| --- | --- |
| Roadmap-Welle | Expansion Wave 2 |
| Kurzrolle | Starkes Reise-, Wasser-, Navigations- und Naturthema. |
| Lernbereiche / Wortfelder | Hafen, Boot, Meer, Navigation, Wetter, Reisen, Ausruestung. |
| Worttypen | Orte, Tools, Travel-Woerter, Aktionen, Sequenzen, Naturbegriffe. |
| Zonen | Hafenbereich, Bootssteg, Navigationskiste, Bootskajuete, Leuchtturm spaeter. |
| Plot-/Gebaeude-Faehigkeiten | `water`, `travel`, `path`, `edge`, `dock adjacency`, `containerAllowed`. |
| Container-/Depth-Beispiele | Bootskajuete -> Kompass/Karte/Seil; Navigationskiste -> Reiseobjekte. |
| Hauptgates | Water-/Dock-/Mobile-Komplexitaetspruefung, Travel-/Vehicle-Regeln. |
| Hauptrisiko | Nicht auf Waldlichtung pressen; Wasser, Boote und Edge-Plots brauchen eigene Regeln. |

### 6.2 Natur / Berge / Outdoor

| Feld | Inhalt |
| --- | --- |
| Roadmap-Welle | Expansion Wave 2 |
| Kurzrolle | Biome-, Landschafts-, Outdoor- und Entdeckungswortschatz. |
| Lernbereiche / Wortfelder | Berg, Wald, Weg, Camping, Wetter, Ausruestung, Pflanzen/Tiere. |
| Worttypen | Orte, Natur, Tools, Sequenzen, Wetter, Tiere, abstraktere Naturbegriffe. |
| Zonen | Pfad, Aussichtspunkt, Campingplatz, Waldkante, Berghang. |
| Plot-/Gebaeude-Faehigkeiten | `nature`, `path`, `travel`, `decoration`, `edge_nature`. |
| Container-/Depth-Beispiele | Rucksack -> Ausruestung; Campingkiste -> Tools; Aussichtspunkt -> Karte. |
| Hauptgates | Outdoor-System, Wetter-/Tageszeitregeln, Tier- und Sicherheitsdarstellung. |
| Hauptrisiko | Visuelle Ueberladung durch Deko/Naturdetails und Wetter-/Gefahrenbegriffe. |

### 6.3 Freizeit / Sport

| Feld | Inhalt |
| --- | --- |
| Roadmap-Welle | Expansion Wave 2 |
| Kurzrolle | Bewegungs-, Spiel-, Hobby- und soziale Aktivitaetswoerter. |
| Lernbereiche / Wortfelder | Sportarten, Spielplatz, Ausruestung, Regeln, einfache Aktionen. |
| Worttypen | Aktionen, Objekte, Rollen, Orte, Sequenzen. |
| Zonen | Spielplatz, Sportfeld, Skatebereich, Picknick-/Freizeitbereich. |
| Plot-/Gebaeude-Faehigkeiten | `social`, `decoration`, `path`, `learningHub`, `sequenceAllowed` spaeter. |
| Container-/Depth-Beispiele | Sporttasche -> Ball/Schuhe; Spielkiste -> Gegenstaende; Mini-Sequenz fuer Aktionen. |
| Hauptgates | Aktions-/Sequenzregeln, Safety, mobile Bedienbarkeit. |
| Hauptrisiko | Viele Aktionen brauchen Animation/Sequenzkonzept; Sport darf nicht Leistungsdruck erzeugen. |

## 7. System-Heavy Wave Capability Sheets

### 7.1 Stadt / Dorfzentrum

| Feld | Inhalt |
| --- | --- |
| Roadmap-Welle | System-Heavy Wave |
| Kurzrolle | Groesserer Hub fuer Wege, Markt, Oeffentlichkeit und viele Gebaeudearten. |
| Lernbereiche / Wortfelder | Stadt, Dorf, Marktplatz, Rathausplatz, Wege, Shops, Orientierung. |
| Benoetigte Systeme | Connector-/Path-Konzept, Hub-Regeln, Clutter-Regeln, Social/Showcase spaeter. |
| Hauptgates | Keine Umsetzung ohne Systemkonzept und Scope-Gate. |
| Hauptrisiko | Zu viele Gebaeude, Funktionen und Details gleichzeitig. |

### 7.2 Reisen / Verkehr

| Feld | Inhalt |
| --- | --- |
| Roadmap-Welle | System-Heavy Wave |
| Kurzrolle | Fahrzeuge, Wege, Haltestellen, Richtung, Bewegung und Verben. |
| Lernbereiche / Wortfelder | Fahren, gehen, Bahnhof, Flughafen, Bus, Auto, Route, Ticket. |
| Benoetigte Systeme | Vehicle-Regeln, Path/Connector, Action/Sequence, mobile Tap-Ziele. |
| Hauptgates | Kein Verb als statisches Objekt; keine Verkehrsinsel ohne Systemkonzept. |
| Hauptrisiko | Fahrzeuge, Bahnhoefe und Flughaefen skalieren schnell zu komplex. |

### 7.3 Arbeit / Werkstatt

| Feld | Inhalt |
| --- | --- |
| Roadmap-Welle | System-Heavy Wave |
| Kurzrolle | Berufe, Werkzeuge, Prozesse, Reparieren, Produzieren und Arbeitsorte. |
| Lernbereiche / Wortfelder | Werkzeuge, Berufe, Werkstatt, Buero, Fabrik, Forschung, einfache Prozesse. |
| Benoetigte Systeme | Prozess-/Sequenzregeln, Tool-/Machine-Regeln, Rollen-/Berufs-Kontext. |
| Hauptgates | Keine Werkstatt-/Arbeitsinsel ohne Prozess- und Safety-Regeln. |
| Hauptrisiko | Maschinen, Arbeitssicherheit, Berufe und Produktionsketten brauchen eigene Grenzen. |

### 7.4 Technik / Digital

| Feld | Inhalt |
| --- | --- |
| Roadmap-Welle | System-Heavy Wave |
| Kurzrolle | Digitale Begriffe, Computer, App, Server, Technikobjekte und abstrakte UI-Woerter. |
| Lernbereiche / Wortfelder | Computer, Smartphone, Server, App, Kabel, Bildschirm, digitale Aktionen. |
| Benoetigte Systeme | Digital-Object-/UI-Abgrenzung, keine Verwechslung mit echter App-UI, Accessibility. |
| Hauptgates | Keine Digitalinsel ohne eigenes Digital-Object-Konzept. |
| Hauptrisiko | Digitalbegriffe koennen App-UI, Weltobjekt und abstrakten Begriff vermischen. |

## 8. Sensitive / Special Wave Capability Sheets

### 8.1 Gesundheit

| Feld | Inhalt |
| --- | --- |
| Roadmap-Welle | Sensitive / Special Wave |
| Kurzrolle | Gesundheitswortschatz neutral erklaeren, ohne medizinische Beratung oder automatische Visualisierung. |
| Typische Inhalte | Gesundheit, Krankheit, Pflege, Koerper, Hilfe, Wohlbefinden. |
| Erlaubte fruehe Wege | CodexEntry, ContextCard, CompanionDialog, BacklogOnly. |
| Hauptgates | Vertiefte M12-D-Regeln, Safety-/UX-Pruefung, keine Beratung. |
| Stop-Regel | Keine Gesundheitsinsel, Klinik oder medizinisches Objekt automatisch erzeugen. |

### 8.2 Kultur / Gesellschaft / Verwaltung

| Feld | Inhalt |
| --- | --- |
| Roadmap-Welle | Sensitive / Special Wave |
| Kurzrolle | Gesellschaftliche und institutionelle Begriffe neutral, kontextbezogen und optional behandeln. |
| Typische Inhalte | Gesellschaft, Verwaltung, Rathaus, Regeln, Rechte, Gemeinschaft, Identitaet. |
| Erlaubte fruehe Wege | Codex, ContextCard, Dialog, Backlog. |
| Hauptgates | Sensitive-/Policy-Regeln, neutrale Darstellung, keine Meinung als Spielziel. |
| Stop-Regel | Keine automatische Verwaltungs- oder Gesellschaftsinseln aus Begriffen. |

### 8.3 Religion

| Feld | Inhalt |
| --- | --- |
| Roadmap-Welle | Sensitive / Special Wave |
| Kurzrolle | Kultur- und Weltanschauungsbegriffe respektvoll und neutral behandeln. |
| Typische Inhalte | Kirche, Tempel, Gebet, Feiertag, Glaube, Symbolik. |
| Erlaubte fruehe Wege | Codex, ContextCard, Nutzerkontext, BacklogOnly. |
| Hauptgates | Keine pauschale Symbolik; vertiefte Safety-/UX-/Privacy-Regeln. |
| Stop-Regel | Keine automatische Religionsinsel, kein Symbol oder Gebaeude ohne eigenes Konzept. |

### 8.4 Politik

| Feld | Inhalt |
| --- | --- |
| Roadmap-Welle | Sensitive / Special Wave |
| Kurzrolle | Politische Begriffe neutral erklaeren, ohne Meinung, Parteiung oder Spielziel. |
| Typische Inhalte | Politik, Wahl, Regierung, Meinung, Demokratie, Partei. |
| Erlaubte fruehe Wege | Codex, ContextCard, CompanionDialog neutral, BacklogOnly. |
| Hauptgates | Policy-/Safety-/Age-Regeln, keine politische Beratung oder Meinung. |
| Stop-Regel | Keine automatische Politikinsel oder politische Symbolproduktion. |

### 8.5 Gericht

| Feld | Inhalt |
| --- | --- |
| Roadmap-Welle | Sensitive / Special Wave |
| Kurzrolle | Recht, Gerechtigkeit und Gericht neutral erklaeren, ohne juristische Beratung. |
| Typische Inhalte | Gericht, Gesetz, Urteil, Gerechtigkeit, Rechte, Pflicht. |
| Erlaubte fruehe Wege | Codex, ContextCard, abstrakte Dialogkarte. |
| Hauptgates | Keine Rechtsberatung, keine automatische Gebaeude-/Symbolerzeugung. |
| Stop-Regel | Keine Gerichtsumsetzung ohne vertiefte Safety- und Darstellungskonzeption. |

### 8.6 Polizei

| Feld | Inhalt |
| --- | --- |
| Roadmap-Welle | Sensitive / Special Wave |
| Kurzrolle | Oeffentliche Sicherheit und Institutionen neutral und kontextsensibel behandeln. |
| Typische Inhalte | Polizei, Hilfe, Sicherheit, Notfall, Regeln. |
| Erlaubte fruehe Wege | Codex, ContextCard, RequiresUserChoice, Backlog. |
| Hauptgates | Safety-/Bias-/Kontextregeln, keine automatische Station, keine Angstmechanik. |
| Stop-Regel | Keine Polizeistation, Uniformsymbolik oder Notfallquest ohne eigenes Konzept. |

### 8.7 Krankenhaus

| Feld | Inhalt |
| --- | --- |
| Roadmap-Welle | Sensitive / Special Wave |
| Kurzrolle | Medizinische Orte und Pflege neutral behandeln, ohne Beratung oder Dramatisierung. |
| Typische Inhalte | Krankenhaus, Arzt, Pflege, Medikament, Notfall, Gesundheit. |
| Erlaubte fruehe Wege | Codex, ContextCard, BacklogOnly, spaeter neutrales Special-Konzept. |
| Hauptgates | M12-D, medizinische Safety-Regeln, keine automatischen Assets. |
| Stop-Regel | Keine Krankenhausinsel, kein Krankenhausasset und keine medizinische Empfehlung aus Wortimport. |

## 9. Capability-Matrix

| ThemeIsland | Wave | Early Suitability | Required Systems | Main Word Types | Main Risk | Before Implementation |
| --- | --- | --- | --- | --- | --- | --- |
| Zuhause / Alltag | Foundation | Hoch als Option | Depth, Container, Clutter, Blueprint fuer Gebaeudeteile | Alltagsobjekte, Raeume, Container, einfache Aktionen | Pflicht-Hausstart, Kleinteile, Gebaeudeteile ohne Zustand | Onboarding-Reversibilitaet, Device-/Tap-Target-Pruefung, kein Pflichtstart |
| Schule / Lernen | Foundation | Hoch, wenn freundlich | Container, Mobile-Clutter, emotionale Produktwirkung | Schreibzeug, Buecher, Lernobjekte, einfache Aufgaben | Wirkt trocken oder schulisch, Kleinteile | Mobile-/Clutter-Regeln, emotionale Darstellung, keine Pflichtschule |
| Garten / Natur nah | Foundation | Hoch als Wachstumsmetapher | Growth-Fairness, Container, Natur-Clutter | Pflanzen, Tools, einfache Prozesse | Timer-/Retention-Druck, Deko-Ueberladung | Fairness-/Timer-Regeln, keine Growth-Manipulation |
| Essen / Restaurant / Cafe | Expansion 1 | Mittel | Food-/Service-Flow, Dialog, Clutter | Zutaten, Essen, Besteck, Bestellung | Viele Objekte, Dialogkomplexitaet | Food-Service-Konzept, Mobile-Pruefung |
| Einkauf / Versorgung | Expansion 1 | Mittel | Market/Hub, Dialog, Produkt-Clutter | Produkte, Kaufen, Preise, Shops | Objektflut, Kauf-/Paywall-Assoziation | Shop-/Dialogkonzept, sensible Versorgung pruefen |
| Land / Farm | Expansion 1 | Mittel | Farm, Growth, Tiere, Produktion | Tiere, Pflanzen, Tools, Prozesse | Timer, Tiere, Produktionsdruck | Fairness-/Timer-/Tierregeln |
| Kueste / Meer / Hafen | Expansion 2 | Mittel spaeter | Water, Dock, Travel, Edge, Mobile | Navigation, Boote, Meer, Reise | Water-/Dock-Komplexitaet | Water-/Dock-/Mobile-Pruefung |
| Natur / Berge / Outdoor | Expansion 2 | Mittel spaeter | Biome, Outdoor, Wetter, Path | Landschaft, Wetter, Tools, Tiere | Deko, Wetter, Sicherheit | Outdoor-/Wetter-/Safety-Konzept |
| Freizeit / Sport | Expansion 2 | Mittel spaeter | Action, Sequence, Safety | Sportobjekte, Bewegungen, Regeln | Leistungsdruck, Animation/Sequenz | Action-/Safety-/Mobile-Pruefung |
| Stadt / Dorfzentrum | System-Heavy | Niedrig frueh | Hub, Connector, Path, Social spaeter | Orte, Shops, Orientierung, oeffentliche Begriffe | Scope, Gebaeudeflut | Systemkonzept und Scope-Gate |
| Reisen / Verkehr | System-Heavy | Niedrig frueh | Vehicle, Path, Connector, Sequence | Fahrzeuge, Verben, Orte, Tickets | Fahrzeuge, Flughafen/Bahnhof-Komplexitaet | Vehicle-/Path-Konzept |
| Arbeit / Werkstatt | System-Heavy | Niedrig frueh | Process, Tools, Machines, Roles | Berufe, Werkzeuge, Prozesse | Maschinen, Rollen, Safety | Prozess-/Werkzeug-/Safety-Konzept |
| Technik / Digital | System-Heavy | Niedrig frueh | Digital-Object/UI-Abgrenzung | Computer, Server, Apps, Kabel | Verwechslung mit App-UI | Digital-Object-Konzept |
| Gesundheit | Sensitive/Special | Blockiert | Sensitive Content, Safety, neutral UX | Gesundheit, Pflege, Koerper, Krankheit | Beratung, Angst, medizinische Inhalte | M12-D vertiefen, keine Beratung |
| Kultur / Gesellschaft / Verwaltung | Sensitive/Special | Blockiert | Sensitive/Policy, ContextCard | Gesellschaft, Verwaltung, Identitaet | Meinung, Bias, Institutionen | Safety-/UX-/Policy-Regeln |
| Religion | Sensitive/Special | Blockiert | Sensitive/Privacy, neutral UX | Glaube, Feiertage, Symbole | Pauschale Symbolik, Weltanschauung | Eigenes neutrales Konzept |
| Politik | Sensitive/Special | Blockiert | Policy, Safety, Neutralitaet | Politik, Wahl, Meinung | Meinung als Spielziel | Keine politische Beratung, Policy-Regeln |
| Gericht | Sensitive/Special | Blockiert | Legal Safety, neutral context | Recht, Gericht, Gerechtigkeit | Juristische Beratung | Keine Rechtsberatung, Safety-Regeln |
| Polizei | Sensitive/Special | Blockiert | Bias/Safety, neutral context | Sicherheit, Hilfe, Notfall | Angst, Bias, Institution | Keine automatische Station, Safety-Regeln |
| Krankenhaus | Sensitive/Special | Blockiert | Medical Safety, neutral context | Medizin, Pflege, Notfall | Beratung, Dramatisierung | Keine medizinische Beratung, M12-D vertiefen |

## 10. Uebergreifende Erkenntnisse

- Foundation-Kandidaten sind planbare Startoptionen, keine finale Startinsel.
- `allowedFunctions` sind Erlaubnisse, keine Pflichtbelegung.
- Kleine Woerter gehoeren oft in Interior, Container, DetailInteraction, Codex
  oder Backlog.
- Word-to-Island Routing macht Vorschlaege, keine automatische Platzierung.
- Spaetere Wellen bleiben nicht wegen geringem Lernwert blockiert, sondern
  wegen System-, Mobile-, Safety-, Fairness- oder Scope-Gates.
- Sensitive/Special-Themen duerfen zuerst neutral ueber Codex, ContextCard,
  CompanionDialog oder Backlog laufen.

## 11. Stop-Regeln

Aus M13-C darf nicht abgeleitet werden:

- keine ThemeIsland-Umsetzung aus M13-C,
- keine finale ThemeIsland-Roadmap aus M13-C,
- keine finale Startinsel aus M13-C,
- keine finale Onboarding-UI aus M13-C,
- keine finale Datenstruktur aus M13-C,
- keine Runtime-Konfiguration aus M13-C,
- keine automatische Wortplatzierung aus M13-C,
- keine Assetproduktion aus M13-C,
- keine App-/Assetfreigabe aus M13-C,
- kein Code aus M13-C,
- kein `frame_started` oder Bauzustand aus M13-C,
- keine Foundation-Insel ohne spaetere Device-/Accessibility-/Tap-Target-
  Pruefung,
- keine Garten-/Growth-Mechanik ohne Fairness-/Timer-Regeln,
- keine Schule-/Kleinteile-Umsetzung ohne Mobile-/Clutter-Regeln,
- kein Zuhause-/Alltag-Start als Pflicht-Hausstart,
- keine Sensitive-/Special-Insel ohne vertiefte Sensitive-Content-/Safety-/
  UX-Regeln,
- keine Stadt-/Verkehr-/Technikinsel ohne eigenes Systemkonzept,
- keine Kuesten-/Hafeninsel ohne Water-/Dock-/Mobile-
  Komplexitaetspruefung,
- keine automatische Darstellung sensibler oder abstrakter Begriffe.

## 12. Naechster Erlaubter Schritt

Erlaubt ist nur:

- M13-C reviewen,
- M13-C dokumentarisch nachbessern,
- M13-D Word-to-Island UX Flow als reinen Planungsblock starten,
- M13-E Device And Accessibility Preview Plan als reinen Planungsblock
  starten,
- einzelne Capability Sheets textlich vertiefen.

Weiterhin nicht erlaubt:

- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Spielassets,
- PNG-Erzeugung oder PNG-Aenderung,
- finale ThemeIsland-Roadmap,
- finale Startinsel,
- ThemeIsland-Umsetzung,
- finale Datenstruktur,
- Runtime-Konfiguration,
- `frame_started`,
- Bauzustaende.
