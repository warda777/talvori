# M16-K: Global ThemeIsland Plot Capacity Matrix

Stand: 2026-06-07

Status: `globale Kategorie-/Plot-Capacity-Matrix gestartet / keine Implementierung`

## 1. Ziel

M16-K sammelt die bereits dokumentierten ThemeIsland-, Taxonomy- und
World-Kategorien und ueberfuehrt sie in eine globale
Grundstuecksflaechen-Matrix.

M16-J bleibt ein enges Dorf-/Zuhause-/Alltag-Beispiel. Es ist nicht die globale
Grundlage fuer ThemeIsland-Kapazitaet. Vor einem weiteren dorf-spezifischen
Code-Slice muessen alle Kategorieprofile sichtbar sein.

M16-K ist nur Dokumentation und Visualisierung. Daraus folgen keine
Flutter-/Dart-Dateien, keine App-Integration, keine Route, keine neue Seite,
keine Build-Wheel-Implementierung, keine Tests, keine Screenshots, keine
Runtime-Konfiguration, keine Persistenz, keine Assets, keine automatische
Wortplatzierung, kein Build-State, kein `frame_started` und keine
Bauzustaende.

## 2. Gepruefte Grundlage

Gelesene und ausgewertete Kategorie-/Capacity-Dokumente:

| Dokument | Beitrag fuer M16-K |
| --- | --- |
| `docs/world_design/266-world-content-taxonomy-and-location-catalog.md` | 14 Hauptkategorien, Ebenenlogik von ThemeIsland bis DetailObject, Wasser/Farm/Verkehr/Sensitive als eigene Bereiche |
| `docs/world_design/267-world-content-taxonomy-review.md` | Bestaetigt Taxonomy als Grundlage, warnt vor Waldlichtungs-Ueberladung |
| `docs/world_design/268-theme-island-prioritization.md` | Early/Mid/Late/Sensitive-Kandidaten und Risiken |
| `docs/world_design/269-theme-island-prioritization-visual-review.md` | Bestaetigt die Wellenlogik und markiert Sensitive/Blocked sauber |
| `docs/world_design/270-word-to-island-routing-matrix.md` | Routing macht Vorschlaege, keine automatische Platzierung; Depth- und Container-Ebenen |
| `docs/world_design/272-plot-capability-derivation.md` | Plotgroessen, allowedFunctions, Adjacency, Depth, Risk Flags |
| `docs/world_design/273-plot-capability-visual-review.md` | Bestaetigt, dass Capabilities Erlaubnisse und keine Pflichtbelegung sind |
| `docs/world_design/279-theme-island-roadmap-draft.md` | Roadmap-Wellen: Foundation, Expansion 1/2, System-Heavy, Sensitive/Special |
| `docs/world_design/283-theme-island-capability-sheets.md` | Konkrete Capability-Sheets pro ThemeIsland-Kandidat |
| `docs/world_design/318-theme-island-plot-capacity-and-build-wheel-plan.md` | Pipeline: Theme -> Plots -> Groessen -> Kapazitaet -> Slots -> Build-Wheel spaeter |
| `docs/world_design/319-village-plot-capacity-local-preview-scope.md` | Enges Dorf-Beispiel, nur Teilkandidat, nicht fuehrend |

Zusaetzlich wurde per `rg` nach den geforderten Kategoriebegriffen gesucht. Die
Treffer bestaetigen die globale Breite: Zuhause, Schule, Garten/Natur,
Kueste/Meer/Hafen, Essen, Einkauf, Farm/Landwirtschaft, Stadt/Dorfzentrum,
Verkehr, Arbeit/Industrie, Freizeit/Outdoor, Technik, Gesundheit, Kultur,
Verwaltung sowie sensitive Bereiche.

## 3. Globale Leitregel

ThemeIsland-Kapazitaet entsteht nicht aus einer fixen Inselgroesse.

```text
Kategorie sammeln
-> typische Zonen bestimmen
-> benoetigte Plot-Familien ableiten
-> Groessenmix und Connectoren bestimmen
-> Depth / Container / Water / Interior pruefen
-> Austauschbarkeit und Mobile-Risiko bewerten
-> spaeteren Preview-Kandidaten waehlen
```

Wichtige Konsequenzen:

- Nicht jede Insel braucht Haus, Garage oder Garten.
- Nicht jede Insel hat die gleiche Slot-Anzahl.
- Wasser, Hafen und Strand brauchen andere Flaechen als Dorf.
- Stadt, Verkehr und Industrie brauchen andere Flaechen als Garten/Natur.
- Landwirtschaft/Farm braucht andere Flaechen als Schule/Lernen.
- Sensitive/Special bleibt policy-gated und darf nicht automatisch
  visualisiert werden.

## 4. Globale Kategoriegruppen

M16-K uebernimmt diese Kategoriegruppen als globale Planungsbasis:

1. Zuhause / Alltag
2. Schule / Lernen
3. Garten / Natur nah
4. Kueste / Meer / Hafen / Strand
5. Essen / Restaurant / Cafe
6. Einkauf / Versorgung
7. Land / Farm / Landwirtschaft
8. Stadt / Dorfzentrum
9. Verkehr / Fahrzeuge / Parken / Reisen
10. Arbeit / Gewerbe / Industrie / Werkstatt
11. Freizeit / Outdoor / Sport
12. Technik / Digital
13. Oeffentliche Gebaeude / Verwaltung
14. Gesundheit / Notfall
15. Kultur / Gesellschaft
16. Sensible Bereiche: Religion / Politik / Gericht / Polizei

## 5. Kategorieprofile

| Kategorie | Typische Zonen | Benoetigte Plottypen | Groessenmix | Kandidaten | Depth/Container | Hauptrisiken | Gate |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Zuhause / Alltag | Kueche, Zimmer, Eingang, Hof, Regal/Ablage | residential, home, path, kleiner Garten, Interior | mittel/gross, innenraum, container, verbindend | Haus, Lernraum, Kueche, Ablage, kleiner Hof | Interior und Container stark | Pflicht-Hausstart, Kleinteile, private Begriffe | Home/Interior/Device/Clutter Gate |
| Schule / Lernen | Klassenzimmer, Lernnische, Regal, Schulhof, Federmappe | learningHub, school, social klein, path, container | mittel, innenraum, container, klein | Lernhaus, Regal, Federmappe, Tisch, Bibliothek | Container und Interior zentral | Pflichtschule, Testmodus, Kleinteile | School/Clutter/Emotion Gate |
| Garten / Natur nah | Beet, Pflanzkiste, Wiese, Geraeteecke, kleiner Weg | garden, nature, edge, path, food klein | klein/mittel/gross, reserve, container | Beet, Pflanzbereich, Baum, Geraeteecke | Container/Sequenz spaeter | Growth-/Timer-Druck, Deko-Clutter | Fairness/Timer/Clutter Gate |
| Kueste / Meer / Hafen / Strand | Wasser, Strand, Pier, Hafen, Bootskiste, Kueste | water, dock, edge, travel, market klein | wasser, gross, verbindend, container, reserve | Pier, Bootsliegeplatz, Fischstand, Leuchtturm spaeter | Navigationskiste, Kajute spaeter | Wasserlogik, Bootssystem, Mobile-Clutter | Water/Dock/Travel Gate |
| Essen / Restaurant / Cafe | Kueche, Tisch, Theke, Vorrat, Terrasse | food, market, social, interior, container | mittel, innenraum, container, verbindend | Restaurant, Cafe, Theke, Vorratsregal | Tisch/Regal/Kueche | Objektlisten, Dialog-/Service-Scope | Food/Service/Clutter Gate |
| Einkauf / Versorgung | Marktstand, Regal, Kasse, Shop, Versorgungspunkt | market, service, hub, path, container | mittel/gross, container, verbindend | Markt, Supermarkt, Baeckerei, Apotheke neutral | Regal, Korb, Schrank | Warenlisten, Kaufdruck, Apotheke sensibel | Market/Commerce/Safety Gate |
| Land / Farm / Landwirtschaft | Feld, Beet, Scheune, Stall, Hofplatz, Wasserstelle | farm, garden, nature, workshop, path | gross/sehr gross, mittel, verbindend, reserve | Feld, Stall, Scheune, Hofladen, Wasserstelle | Kisten, Tools, Stall/Interior spaeter | Timer, Produktion, Tiere, Retention-Druck | Farm/Fairness/Animal Gate |
| Stadt / Dorfzentrum | Platz, Strasse, Markt, Kiosk, Civic-Flaeche | hub, market, civic, path, service, social | gross/sehr gross, verbindend, klein/mittel | Platz, Kiosk, Rathausplatz, Marktstand | Container in Shops, Details spaeter | Clutter, Navigation, viele Systeme | City/Path/Hub Gate |
| Verkehr / Fahrzeuge / Parken / Reisen | Strasse, Haltestelle, Bahnhof, Parkplatz, Route | path, vehicle, travel, connector, edge | verbindend, gross, mittel, container | Bushalt, Ticketautomat, Garage, Bahnhof | Automaten/Koffer Container | Vehicle-System, Verben als Objekte | Path/Vehicle/Action Gate |
| Arbeit / Gewerbe / Industrie / Werkstatt | Werkstatt, Buero, Lager, Fabrik, Labor | workshop, production, industry, tech, path | mittel/gross/sehr gross, container, innenraum | Werkbank, Lager, Buero, Labor, Fabrikhalle | Werkzeugkasten, Schreibtisch, Regal | Prozessketten, Maschinen, Safety | Process/Tool/Safety Gate |
| Freizeit / Outdoor / Sport | Sportfeld, Spielplatz, Camping, Pfad, Aussicht | activity, social, nature, path, container | gross, mittel, verbindend, container | Sportplatz, Spielplatz, Campingplatz, Rucksack | Sporttasche/Rucksack | Aktionen, Sequenzen, Leistungsdruck | Action/Safety/Mobile Gate |
| Technik / Digital | Computerplatz, Serverraum, Labor, Geraeteregal | tech, digital, workshop, interior, container | innenraum, mittel/gross, container | Computerplatz, Serverrack, Kabelregal, Labor | Schreibtisch, Geraeteschrank | UI-in-UI, abstrakte Begriffe | Digital-Object/UI Gate |
| Oeffentliche Gebaeude / Verwaltung | Rathaus, Bibliothek, Bahnhof, Feuerwehr, Polizei spaeter | civic, publicService, education, safety, path | gross, hub, innenraum, container | Bibliothek, Rathaus, Feuerwehrhaus, Bahnhof | Regal, Schalter, Automat | Institutionen, Politik/Polizei sensibel | Civic/Sensitive Gate |
| Gesundheit / Notfall | Praxis, Apotheke neutral, Hilfe-Kontext, Codex | health, publicService, contextCard | innenraum, container, blocked/special | Praxis, Medizinschrank, Hilfe-Karte | nur neutral und gated | medizinische Beratung, Druck, Datenschutz | Health/Safety/Privacy Gate |
| Kultur / Gesellschaft | Museum, Forum, Denkmal, Veranstaltungsort | culture, social, civic, codex, path | hub, gross, innenraum, container | Museum, Vitrine, Forum, Kulturkarte | Vitrine/ContextCard | Bias, Stereotype, Identitaet | Culture/Bias/Safety Gate |
| Sensible Bereiche | Religion, Politik, Gericht, Polizei, Krieg/Tod | contextCard, codex, backlog, blocked | policy-gated, keine normale Slotpflicht | nur neutrale Karten/Dialoge spaeter | kein Auto-Interior | Symbolik, Beratung, Angst, Stereotype | Policy/Sensitive Gate |

## 6. Globale Matrix

Minimum Plot Count ist eine Planungsannahme, keine finale Zahl.

| Category | Required Plot Families | Minimum Plot Count | Size Mix | Required Connectors | Needs Water? | Needs Interior/Depth? | Needs Container? | Exchangeability Level | Build Wheel Candidate Families | Major Risks | Gate Before Code |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Zuhause / Alltag | residential, interior, path, small garden, learningHub | medium: 5-8 | medium/gross + innenraum/container | path, entrance | nein | ja | ja | mittel | Zuhause, Kueche, Lernraum, Hof, Ablage | Pflicht-Hausstart, Kleinteile | Home/Interior/Device |
| Schule / Lernen | school, learningHub, room, shelf, container, yard | medium: 5-8 | mittel + innenraum/container | path, schoolyard | nein | ja | ja | mittel | Lernraum, Regal, Tisch, Federmappe, Bibliothek | Testmodus, Clutter | School/Clutter |
| Garten / Natur nah | garden, nature, tool, path, reserve | small/medium: 3-8 | klein/mittel/gross + reserve | path | optional spaeter | optional | ja | hoch | Beet, Pflanzkiste, Baum, Geraeteecke | Timer, Growth-Druck | Fairness/Timer |
| Kueste / Meer / Hafen / Strand | water, beach, pier, dock, harbor, storage, edge | large: 8-12 | wasser/gross/verbindend/container | path + dock | ja | ja spaeter | ja | mittel | Strand, Pier, Boot, Lager, Fischstand, Leuchtturm | Wasser, Boote, Mobile | Water/Dock/Travel |
| Essen / Restaurant / Cafe | food, service, kitchen, table, storage, terrace | medium: 5-8 | mittel/innenraum/container | path/service | nein | ja | ja | mittel | Cafe, Tisch, Kueche, Theke, Vorrat | Warenlisten, Dialog-Scope | Food/Service |
| Einkauf / Versorgung | market, shop, shelf, checkout, service, path | medium: 5-8 | mittel/gross/container | path/hub | nein | ja | ja | mittel | Markt, Regal, Kasse, Shop, Korb | Kaufdruck, Clutter | Market/Safety |
| Land / Farm / Landwirtschaft | field, barn, stable, yard, water, path, reserve | large: 8-12 | gross/sehr gross/mittel/reserve | path + water point | optional | ja spaeter | ja | hoch | Feld, Scheune, Stall, Hof, Wasserstelle | Produktion, Tiere, Timer | Farm/Fairness |
| Stadt / Dorfzentrum | hub, plaza, street, shop, public, service | very large/modular: 12+ | hub/gross/verbindend/klein | street/path grid | nein | ja | ja | mittel | Platz, Kiosk, Markt, Rathaus, Strasse | Clutter, Navigation | City/Path |
| Verkehr / Fahrzeuge / Parken / Reisen | road, station, parking, vehicle, ticket, route | large: 8-12 | verbindend/gross/mittel/container | route/path | optional | ja spaeter | ja | niedrig/mittel | Haltestelle, Bahnhof, Ticket, Parkplatz | Vehicle-System | Vehicle/Path |
| Arbeit / Gewerbe / Industrie | workshop, office, storage, production, lab | large: 8-12 | mittel/gross/sehr gross/container | path/service | nein | ja | ja | mittel | Werkbank, Lager, Buero, Labor | Prozesse, Maschinen | Process/Safety |
| Freizeit / Outdoor / Sport | activity, field, equipment, path, social | medium/large: 5-12 | gross/mittel/verbindend/container | path | optional | optional | ja | hoch | Sportfeld, Spielplatz, Camping, Tasche | Aktionen, Safety | Action/Mobile |
| Technik / Digital | tech room, device, server, desk, lab | medium: 5-8 | innenraum/mittel/container | path/interior | nein | ja | ja | mittel | Computerplatz, Serverraum, Geraeteregal | UI-in-UI | Digital/UI |
| Oeffentliche Gebaeude / Verwaltung | civic, public service, education, transport, path | large: 8-12 | hub/gross/innenraum | path/hub | nein | ja | ja | niedrig/mittel | Bibliothek, Rathaus, Schalter, Bahnhof | Institutionen sensibel | Civic/Sensitive |
| Gesundheit / Notfall | health, help, pharmacy neutral, context | small/blocked: 3-5 only after policy | innenraum/container/context | path optional | nein | ja, gated | ja, gated | niedrig | Praxis, Hilfe-Karte, neutraler Schrank | Beratung, Privacy | Health/Safety |
| Kultur / Gesellschaft | culture, museum, forum, civic, codex | medium/blocked: 5-8 after policy | hub/innenraum/container | path/hub | nein | ja, gated | ja, gated | niedrig | Museum, Vitrine, Forum, ContextCard | Bias, Stereotype | Culture/Safety |
| Sensible Bereiche | policy-only, contextCard, codex, backlog | blocked | keine normale Slotzahl | none | nein | nur gated | nur gated | niedrig | keine automatische Wheel-Familie | Symbolik, Beratung, Angst | Policy Gate |

## 7. Kategorie-spezifische Beispiele

### Kueste / Meer / Hafen / Strand

| Plot-Familie | Groesse | Rolle | Build-Wheel spaeter | Risiko | Gate |
| --- | --- | --- | --- | --- | --- |
| Wasserflaeche | wasser/gross | Hauptflaeche, kein normaler Bauplatz | Wasser, Bootsliegeplatz spaeter | Wasserlogik, Mobile | Water Gate |
| Strandflaeche | gross | Land-Wasser-Uebergang | Strand, Rettungspunkt, Natur | Clutter/Deko | Coast Mobile Gate |
| Steg / Pier | verbindend/mittel | Zugriff auf Wasser | Pier, Anleger | Path/Dock-System | Dock Gate |
| Bootsliegeplatz | mittel/gross | Travel-/Bootskandidat | Boot, Kajute spaeter | Vehicle/Travel | Travel Gate |
| Hafenlager / Kiste | container/mittel | Container-Depth | Lager, Kiste, Seil, Kompass | kleine Objekte | Container Gate |
| Leuchtturm optional | gross/edge | Landmarke spaeter | Leuchtturm | Asset-/Symbol-Druck | Asset/Scope Gate |
| Felsen / Kueste | edge/klein | Rand und Lesbarkeit | Kueste, Felsen | Deko-Clutter | Clutter Gate |
| Markt-/Fischstand optional | mittel | Food/Market Uebergang | Stand, Kiste | Food/Commerce | Market Gate |
| Reserveflaeche | reserve | Erweiterung | Backlog | Unlock-Druck | Expansion Gate |

### Land / Farm

Farm braucht grosszuegige Flaechen: Feld, Beet, Stall/Scheune, Hofplatz, Weg,
Wasserstelle, Baum-/Naturflaeche und Reserve. Der Hauptblocker ist nicht die
Geometrie, sondern Fairness: keine Timerpflicht, keine Pflegeangst, keine
Paywall- oder Retention-Mechanik.

### Stadt / Dorfzentrum

Stadt und Dorfzentrum brauchen viele verbindende Flaechen: Platz,
Strasse/Weg, Geschaeft, Cafe/Restaurant, Wohn-/Arbeitsgebaeude, oeffentliche
Flaeche, Schilder/Deko und Reserve. Hauptblocker sind Dichte, Navigation,
Clutter und institutionelle/sensitive Uebergaenge.

### Schule / Lernen

Schule braucht weniger grosse Aussenflaechen als Stadt/Farm, aber mehr
Container/Interior: Lernhaus oder Schulgebaeude, Klassenzimmer, Bibliothek,
Schulhof, Tasche/Federmappe, Materialbereich. Hauptblocker sind Pflichtschule,
Testmodus und Kleinteile-Clutter.

## 8. Verhaeltnis M16-I / M16-J / M16-K

- M16-I definiert die Pipeline: Theme -> benoetigte Grundstuecke -> Groessen
  -> Inselkapazitaet -> austauschbare Slots -> spaeteres In-Place Build-Wheel.
- M16-J ist ein enges Dorf-/Zuhause-/Alltag-Beispiel. Es bleibt nuetzlich,
  aber ist nicht die globale Grundlage.
- M16-K sammelt global alle dokumentierten Kategorien und verhindert, dass der
  naechste Schritt zu frueh nur Dorf/Zuhause baut.
- Nach M16-K darf erst entschieden werden, welcher Kategorie-Preview-Slice als
  naechstes sinnvoll ist.
- Dorf/Zuhause bleibt ein Kandidat. Kueste/Meer/Hafen, Garten/Natur,
  Farm/Land, Stadt, Schule, Essen/Einkauf, Technik und sensitive Bereiche
  brauchen eigene Plot-Capacity-Profile.

## 9. Dokumentationsvisualisierungen

M16-K ergaenzt echte PNG-Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_k_global_theme_island_plot_capacity_matrix/`

Erzeugte Visuals:

- `01_global_category_to_plot_family_map.png`
- `02_theme_island_size_mix_comparison.png`
- `03_coast_harbor_plot_capacity_example.png`
- `04_global_allowed_vs_blocked_scope.png`
- optional `00_contact_sheet.png`

Diese PNGs sind Dokumentationspreviews. Sie sind keine App-Screens, keine
Screenshots, keine finalen UI-PNGs, keine Spielassets und keine Dateien unter
`assets/`.

## 10. Entscheidung

M16-K empfiehlt:

- keinen weiteren dorf-spezifischen Commit-Kandidaten aus M16-J ableiten,
  bevor globale Kategorieprofile sichtbar sind,
- als naechste Entscheidung zuerst Kategorie-Preview-Kandidaten vergleichen,
- insbesondere Kueste/Meer/Hafen und Farm/Land nicht auf Dorf-Slot-Logik
  reduzieren,
- Sensitive/Special weiterhin policy-gated halten,
- `VillagePlotCapacityPreview` nur als moeglichen Dorf-Kandidaten behandeln,
  nicht als generisches ThemeIsland-Modell.

## 11. Stop-Regeln

Aus M16-K folgt ausdruecklich:

- Keine Implementierung.
- Keine Flutter-/Dart-Dateien.
- Keine App-Integration.
- Keine Route.
- Keine neue Seite.
- Keine Build-Wheel-Implementierung.
- Keine Tests und keine Widget-Tests.
- Keine Screenshots.
- Keine Runtime-Konfiguration.
- Keine Persistenz.
- Keine Supabase Writes.
- Keine lokalen DB-Writes.
- Keine SRS-/`word_progress`-Aenderung.
- Keine Reward Bridge.
- Keine automatische Wortplatzierung.
- Keine Assets.
- Keine Asset-Dateien unter `assets/`.
- Kein Build-State.
- Kein `frame_started`.
- Keine Bauzustaende.
