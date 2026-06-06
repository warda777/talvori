# Flexible Plot Placement And Learning Semantics

Stand: 2026-06-06

Status: `Planung vertieft / M6-F ergaenzt / Variante-B nicht als finales Layout bestaetigen`

## 1. Zweck

Dieses Dokument stoppt jede Bestaetigung der aktuellen Variante-B-Greybox als
finale feste Gebaeudeanordnung.

Es definiert zwei Grundentscheidungen:

- Talvori-Plots sind flexible Grundstuecksflaechen mit Faehigkeiten, Groessen,
  Anchors, Sockets und Regeln.
- Lernwoerter werden nicht blind in feste Objekte uebersetzt, sondern ueber
  Semantik, Kontext, Anforderungen und Fallbacks in Weltaufbau, sichtbare
  Objekte, Bauteile, Szenen, Aufgaben, Blueprints oder Codex-Eintraege
  ueberfuehrt.

Nicht-Ziele:

- kein Flutter-/Dart-Code,
- keine App-Integration,
- keine Tests,
- keine Spielassets,
- keine PNG-Aenderungen,
- kein finales Inselbild,
- kein `frame_started`,
- keine Bauzustands-Fortsetzung,
- kein Commit.

## 2. Ausgangsproblem

Die Variante-B-Greybox loest einige M4-Probleme: Sie wirkt weniger linear, der
Markt haengt weniger stark als langer Schwanz, und Wasser/Natur/Randlogik sind
besser lesbar.

Die manuelle Sichtpruefung hat aber einen grundlegenden Designfehler sichtbar
gemacht:

```text
Die Greybox wirkt so, als seien Haus, Garten, Markt, Farm, Wasser und
Nachbarschaft bereits fest an Positionen gebunden.
```

Das ist fuer Talvori zu starr. Talvori soll keine Insel bauen, die bei jedem
Nutzer gleich aussieht.

## 3. Variante-B-Greybox Neu Interpretieren

Die Variante-B-Greybox darf nicht als finale feste Anordnung von Haus, Garten,
Markt, Garage, Farm oder Wasserbereich verstanden werden.

Bisherige Namen wie:

- `starter_home`,
- `garden_west`,
- `market_square`,
- `function_seed_east`,
- `water_edge_east`,
- `farm_southwest`,
- `neighbor_west`,

waren nur Beispielrollen fuer Debug-Zwecke.

Kuenftig muessen diese Plaetze allgemeiner als flexible Plot-Slots verstanden
werden. Bessere Arbeitsnamen sind zum Beispiel:

| Alter Debug-Name | Neue flexible Lesart |
| --- | --- |
| `starter_home` | `core_plot_a` |
| `garden_west` | `core_plot_b` |
| `path_south` | `connector_plot_a` |
| `nature_north` | `core_edge_plot_a` |
| `function_seed_east` | `core_plot_c` |
| `hub_seed_south` | `hub_capable_plot_a` |
| `market_square` | `hub_capable_plot_b` oder `unlock_plot_a` |
| `water_edge_east` | `edge_water_capable_plot_a` |
| `farm_southwest` | `edge_farm_capable_plot_a` |
| `neighbor_west` | `residential_capable_unlock_plot_a` |
| `nature_edge_nw` | `edge_nature_capable_plot_a` |
| `expansion_edge_se` | `expansion_socket_plot_a` |

Diese Namen beschreiben nicht, was dort zwingend gebaut wird. Sie beschreiben,
welche Funktionen ein Plot tragen kann.

Beispiel-Capabilities:

- `supportsHome`
- `supportsGarden`
- `supportsMarket`
- `supportsWorkshop`
- `supportsNature`
- `supportsWaterEdge`
- `supportsGarage`
- `supportsDecoration`
- `supportsExpansion`

## 4. Grundsatzentscheidung: Freie Nutzerplatzierung

Talvori soll keine starre Insel bauen, die bei jedem Nutzer gleich aussieht.

Stattdessen gilt:

- Nutzer waehlen aus vorhandenen oder freigeschalteten Grundstuecksflaechen.
- Nutzer entscheiden, welches kompatible Gebaeude, welcher Bereich oder
  welches Objekt dort gebaut wird.
- Das System schlaegt passende Optionen vor, erzwingt sie aber nicht
  automatisch.
- Manche Plots haben besondere Eigenschaften, zum Beispiel Wassernahe,
  Randlage, Hub-Eignung, kleine Deko-Flaeche oder Fahrzeug-/Utility-Eignung.
- Nicht jeder Plot kann alles tragen.
- Automatische Platzierung ist nur optional und bestaetigungspflichtig.

Beispiele:

- Ein Haus braucht mindestens einen `medium`- oder `home`-faehigen Plot.
- Ein Markt braucht einen groesseren oder `hub`-faehigen Plot.
- Ein Garten kann auf `small`, `medium` oder `large` entstehen.
- Eine Garage braucht mindestens `medium` oder einen
  `vehicle/utility`-faehigen Plot.
- Ein einzelnes Objekt wie `Giesskanne` braucht nur einen passenden
  Objekt- oder Dekoanker auf einem geeigneten Hof-, Garten- oder Utility-Plot.

## 5. Plot Capability Model

Jeder Plot bekommt Faehigkeiten statt feste Gebaeude.

Pflichtfelder:

```text
plotId
plotSize
allowedFunctions[]
buildingAnchors[]
objectAnchors[]
decorationAnchors[]
pathSockets[]
expansionSockets[]
requiredAdjacency[]
forbiddenAdjacency[]
maxBuildingFootprint
supportsInterior
supportsObjectDetail
isUserSelectable
```

### `plotSize`

Erlaubte Startgroessen:

- `micro`
- `small`
- `medium`
- `large`
- `hub`
- `edge`

### `allowedFunctions`

Erlaubte Funktionsgruppen:

- `home`
- `garden`
- `market`
- `workshop`
- `garage`
- `nature`
- `farm`
- `water`
- `decoration`
- `path`
- `social`
- `learningHub`

### Beispiele

| Beispiel | Mindest-Plot | Benoetigte Faehigkeiten | Hinweise |
| --- | --- | --- | --- |
| Haus | `medium` | `home`, `path` | Spaeter `supportsInterior: true`; braucht Front-/Backyard-Anker. |
| Garten | `small` bis `large` | `garden`, `decoration`, `nature` | Kann Objektanker fuer `Giesskanne`, Blume, Baum tragen. |
| Markt | `hub` oder `large` | `market`, `social`, `path` | Braucht mehrere PathSockets und ausreichend Freiraum. |
| Garage | `medium` | `garage`, `path`, optional `vehicle` | Braucht Zufahrt und spaeter ObjectDetail fuer Fahrzeug. |
| Einzelnes Objekt | `micro` bis `large` | `decoration` oder passende Funktion | Darf nur auf kompatiblen Objektankern stehen. |
| Wasser-/Hafenbereich | `edge` | `water`, `path`, optional `social` | Muss Rand-/Uferlogik besitzen. |
| Farm | `large` oder `edge` | `farm`, `nature`, `path` | Eher Rand- oder Uebergangszone. |

## 6. Regeln Fuer Freie Platzierung

Nutzerfreiheit ist regelbasiert, nicht chaotisch.

Regeln:

- Ein Plot zeigt kompatible Bauoptionen anhand von `allowedFunctions`,
  `plotSize`, Anchors, Sockets und Adjacency-Regeln.
- Gebaeude duerfen nur auf `buildingAnchors` oder innerhalb definierter
  `building_footprint_polygon`-Flaechen stehen.
- Einzelobjekte duerfen nur auf `objectAnchors` oder
  `decorationAnchors` liegen.
- Wege duerfen nur ueber kompatible `pathSockets` verbunden werden.
- Wasser-, Hafen- oder Randobjekte brauchen passende `edge`- oder
  `water`-Faehigkeit.
- Ein Plot darf Optionen vorschlagen, aber nicht jeden Vorschlag automatisch
  ausfuehren.
- Der Nutzer entscheidet, sofern keine explizite Tutorial-, Onboarding- oder
  Sicherheitsregel eine Ausnahme begruendet.

## 7. Lernwort-Zu-Welt-System

Gelernte Woerter werden nach semantischem Typ verarbeitet.

### 7.1 Konkrete Objektwoerter

Beispiele:

- `Giesskanne`
- `Baum`
- `Blume`
- `Stuhl`
- `Auto`

Moegliche Darstellung:

- sichtbares Objekt auf passendem Plot,
- Deko-Objekt,
- `ObjectDetail`,
- Blueprint, wenn noch kein passender Ort existiert.

Regel:

Ein konkretes Objekt braucht einen kompatiblen Plot und einen kompatiblen
Objektanker. Es wird nicht frei auf beliebige Flaechen gesetzt.

### 7.2 Gebaeudeteile / Bauteilwoerter

Beispiele:

- `Fenster`
- `Tuer`
- `Dach`
- `Wand`
- `Boden`

Moegliche Darstellung:

- an passendem Gebaeudezustand,
- als Blueprint fuer spaeteren Ausbau,
- als Teil eines BuildState, wenn das Gebaeude weit genug ist.

Regel:

Bauteile duerfen niemals frei in der Luft oder ohne passenden
Gebaeudezustand platziert werden.

### 7.3 Raum- Und Ort-Woerter

Beispiele:

- `Kueche`
- `Garten`
- `Markt`
- `Garage`
- `Schule`

Moegliche Darstellung:

- Plot-Typ oder Bereich,
- spaeter Interior,
- spaeter Zone,
- Themenbereich oder Kategoriepfad.

Regel:

Ort-Woerter koennen Bauvorschlaege erzeugen, aber keine feste Position auf der
Insel erzwingen.

### 7.4 Aktionswoerter

Beispiele:

- `gehen`
- `fahren`
- `oeffnen`
- `kaufen`

Moegliche Darstellung:

- kurze Animation,
- Quest,
- Companion-Satz,
- Mini-Szene,
- Interaktion an passendem Objekt.

Regel:

Aktionswoerter werden nicht als statische Gegenstaende gemappt. Sie brauchen
Kontext, Objekt, Szene oder Aufgabe.

### 7.5 Eigenschaften / Adjektive

Beispiele:

- `gross`
- `klein`
- `alt`
- `neu`
- `politisch`

Moegliche Darstellung:

- Vergleichsaufgabe,
- Dialog,
- Markierung,
- Story-/Kontextkarte,
- Companion-Erklaerung.

Regel:

Eigenschaften muessen nicht zwingend als Weltobjekt erscheinen.

### 7.6 Abstrakte Begriffe

Beispiele:

- `Freiheit`
- `Meinung`
- `Entscheidung`
- `Politik`

Moegliche Darstellung:

- Codex,
- Gespraech mit Tali/Vori,
- Debattenplatz / Rathaus / Forum / Marktgespraech,
- Beispielszene,
- Aufgabe statt Objekt.

Regel:

Abstrakte Begriffe duerfen nicht als beliebige physische Objekte erzwungen
werden.

### 7.7 Mehrdeutige Woerter

Beispiele:

- `drive`
- `bank`
- `light`

Moegliche Darstellung:

- Kontextanalyse,
- Sense-Auswahl durch Nutzer,
- mehrere moegliche Weltzuordnungen,
- Companion-Rueckfrage.

Regel:

Mehrdeutige Woerter werden niemals blind auf ein Objekt gemappt.

## 8. Blueprint- Und Backlog-System

Wenn ein gelerntes Wort noch keinen passenden Ort hat, wird es nicht ignoriert
und nicht falsch platziert.

Stattdessen landet es in einem oder mehreren Fallbacks:

- `visualBlueprint`
- `wordObjectBacklog`
- `codexEntry`
- `futurePlacementCandidate`
- `companionSuggestion`

Beispiele:

| Gelerntes Wort | Fehlender Kontext | Fallback |
| --- | --- | --- |
| `Fenster` | kein Haus / keine Wand | Blueprint fuer spaeteres Haus oder Wand-State |
| `Giesskanne` | kein Garten/Hof | Garten-Objekt im Backlog; Companion kann Garten vorschlagen |
| `fahren` | kein Fahrzeug/Wege-System | Aktionskarte, Quest oder Beispielsatz |
| `politisch` | kein geeigneter Kontext | Dialog-, Codex- oder Kontextkarte |
| `Auto` | kein Garage-/Vehicle-Plot | Blueprint oder ObjectDetail-Vorschlag spaeter |

## 9. Lerngetriebene Vorschlaege Ohne Zwangsplatzierung

Talvori darf aus Lernmustern Vorschlaege ableiten:

- `Du lernst gerade viele Gartenwoerter. Moechtest du einen Gartenbereich bauen?`
- `Du hast mehrere Hauswoerter gesammelt. Moechtest du ein Haus oder einen Raum vorbereiten?`
- `Dieses Wort braucht einen passenden Ort. Es wurde als Blueprint gespeichert.`

Aber:

- Der Nutzer entscheidet, wo gebaut wird.
- Woerter duerfen fuehren, aber nicht das Layout fest verdrahten.
- Die Insel bleibt individuell.
- Automatische Platzierung ist optional und bestaetigungspflichtig.
- Vorschlaege muessen klar und kurz bleiben.

## 10. Kategorien Und Themen Nicht Hart Codieren

Neue Kategorien wie Reisen, Gesundheit, Politik, Technik, Essen, Schule,
Business oder Kultur muessen spaeter ergaenzbar sein.

Dazu braucht jedes Wort / Objekt / Plot mindestens:

```text
semanticTags[]
categoryTags[]
placementRequirements[]
compatiblePlotFunctions[]
visualRepresentationType
unlockRules[]
fallbackRepresentation
```

Beispiele:

- `Giesskanne`
  - `semanticTags`: `object`, `garden_tool`
  - `compatiblePlotFunctions`: `garden`, `farm`, `yard`
  - `fallbackRepresentation`: `visualBlueprint`

- `Fenster`
  - `semanticTags`: `building_part`
  - `placementRequirements`: `building_state >= frame_or_wall_started`
  - `fallbackRepresentation`: `futurePlacementCandidate`

- `Politik`
  - `semanticTags`: `abstract`, `social_topic`
  - `visualRepresentationType`: `codex`, `dialogue`, `forum_scene`
  - `fallbackRepresentation`: `codexEntry`

## 11. Konsequenzen Fuer Die Bestehende Greybox

Die aktuelle Variante-B-Greybox sollte nicht als feste Benennung uebernommen
werden.

Stattdessen gilt:

- Variante B kann als raeumliche Testform genutzt werden.
- Die Plotnamen muessen spaeter abstrahiert werden.
- Die Plot-Funktion legt der Nutzer innerhalb der Regeln fest.
- Debug-Labels duerfen nicht zu Produktlogik werden.

Vorgeschlagene Umbenennung:

| Variante-B-Label | Abstrakter Plot-Slot |
| --- | --- |
| `starter_home` | `core_plot_a` |
| `garden_west` | `core_plot_b` |
| `nature_north` | `core_edge_plot_a` |
| `path_south` | `connector_plot_a` |
| `function_seed_east` | `core_plot_c` |
| `hub_seed_south` | `hub_capable_plot_a` |
| `market_square` | `hub_capable_plot_b` |
| `water_edge_east` | `edge_water_capable_plot_a` |
| `farm_southwest` | `edge_farm_capable_plot_a` |
| `neighbor_west` | `residential_capable_unlock_plot_a` |
| `nature_edge_nw` | `edge_nature_capable_plot_a` |
| `expansion_edge_se` | `expansion_socket_plot_a` |

## 12. Stop-Regeln

Stoppen, wenn:

- eine Plot-Greybox als feste Gebaeudeanordnung behandelt wird,
- ein Nutzer mit Hausbau beginnen muss,
- ein Wort ohne passenden Kontext platziert werden soll,
- ein `Fenster` ohne Wand/Hauszustand platziert werden soll,
- eine `Giesskanne` ohne Garten, Hof oder geeigneten Objektanker platziert
  werden soll,
- ein abstraktes Wort als beliebiges physisches Objekt erzwungen wird,
- automatische Platzierung ohne Nutzerbestaetigung geplant wird,
- ein Wort-zu-Welt-System ohne Placement Decision Pipeline geplant wird,
- ein Word-to-World-System ohne abstrakte Datenmodell-Skizze geplant wird,
- ein Import-Feature ohne Kontext-/Sense-/Safety-Pruefung geplant wird,
- ein mehrdeutiges Wort sichtbar dargestellt werden soll, ohne dass Sense
  entschieden oder bestaetigt ist,
- ein sensibler oder abstrakter Begriff automatisch als Weltobjekt erscheinen
  soll,
- Lernfortschritt automatisch starre Baupositionen erzwingen soll,
- ein Lernmodus ohne Nutzerbestaetigung sichtbare Weltobjekte massenhaft
  erzeugen soll,
- freie Plot-Platzierung ohne Onboarding-Erklaerung geplant wird,
- Progression den Nutzer faktisch wieder zum Hausstart zwingt,
- Import ohne Governance-/Privacy-/Safety-Regeln geplant wird,
- eine sensible Kategorie ohne Bestaetigung und neutrale Darstellung sichtbar
  werden soll,
- die naechste Greybox feste Gebaeude-Rollenlabels nutzt,
- eine Capability-Greybox ohne `allowedFunctions` und `isUserSelectable`
  geplant wird,
- Kategorie-Priorisierung ohne Nutzerziel und Satzkontext geplant wird,
- eine einzelne Insel alle Lernwelten tragen soll,
- Meer-, Tauchen- oder Boot-Themen auf die Waldlichtung gepresst werden,
  obwohl eine Kuesteninsel sinnvoller ist,
- Stadt-, Krankenhaus- oder Flughafen-Komplexitaet auf die Starterinsel
  gepresst wird,
- eine Themeninsel ohne eigene Plot-Capabilities geplant wird,
- eine Themeninsel ohne Word-to-Island-Routing geplant wird,
- Monetarisierung ohne eigenes spaeteres Dokument geplant wird,
- eine Paywall Core Learning blockiert,
- Multi-Island-Produktion ohne Scope-Gate gestartet wird,
- ein Multi-Island-System ohne Archipel-Navigation geplant wird,
- ein Themeninsel-System ohne gemeinsamen Codex-/Blueprint-/Backlog-Plan
  geplant wird,
- ein Multi-Home-Wort ohne Cross-Island-Routing geplant wird,
- ein Insel-Slot-System ohne Status/Lifecycle geplant wird,
- mehrere private Inseln ohne Besitzer-/Identitaetslogik geplant werden,
- eine Archipel-Roadmap den Nutzer mit zu vielen Optionen ueberfordert,
- Social- oder Showcase-Funktionen ohne eigenes Privacy-/Social-Konzept
  geplant werden,
- ein Plot ohne Capability Matrix freigegeben wird,
- ein Objekt sichtbar platziert wird, ohne Placement Requirements zu erfuellen,
- ein abstraktes Wort ohne passenden Repraesentationstyp visualisiert wird,
- eine Weltvisualisierung Mobile-Lesbarkeit ueberlaedt,
- Umbauen oder Verschieben ohne definierte Folgen fuer Wortobjekte,
  Blueprints und Backlogs geplant wird,
- Kategorien hart codiert werden,
- Spielassets erzeugt werden, bevor Plot-Flexibilitaet und Wort-Semantik
  geklaert sind,
- `frame_started` wieder aufgenommen wird, bevor Plot-Funktion,
  Gebaeude-Footprint und Nutzerplatzierung geklaert sind.

## 13. Naechster Erlaubter Schritt

Der naechste erlaubte Schritt ist:

```text
Flexible Plot-/Learning-Semantics-Planung pruefen; danach Greybox-Namen,
Plot-Rollen und Capability-Labels nachbessern.
```

Nicht erlaubt:

- Code,
- Spielassets,
- finale Inselkunst,
- `frame_started`,
- Bauzustands-Fortsetzung,
- App-Integration,
- Persistenz,
- Supabase,
- SRS-/`word_progress`,
- Reward Bridge,
- Ressourcenlogik.

## 14. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- Variante B nicht mehr als feste Gebaeudeanordnung verstanden wird,
- Plots als flexible Grundstuecksflaechen mit Faehigkeiten definiert sind,
- Nutzerplatzierung innerhalb klarer Regeln moeglich bleibt,
- Lernwoerter nicht blind auf Objekte gemappt werden,
- Blueprint-/Backlog-Fallbacks fuer fehlende Kontexte existieren,
- Kategorien spaeter erweiterbar bleiben,
- naechste Greybox-Nachbesserung aus abstrakten Plot-Slots ableitbar ist,
- `frame_started`, neue Assets und Code weiterhin blockiert bleiben.

## 15. Placement Decision Pipeline

Jeder Bauwunsch und jedes gelernte Wort laeuft spaeter durch eine
Entscheidungspipeline. Diese Pipeline trennt automatische Analyse klar von
Nutzerentscheidung.

```text
1. Wort / Lerninhalt kommt rein
2. Sprache und Kontext pruefen
3. Wortart / semantischen Typ bestimmen
4. Bedeutung / Sense bestimmen
5. passende Welt-Darstellung suchen
6. Voraussetzungen pruefen
7. passende Plots suchen
8. Nutzerentscheidung einholen
9. platzieren / Blueprint speichern / Codex speichern / Quest erzeugen
10. spaetere Freischaltung oder Nachplatzierung ermoeglichen
```

### Automatische Analyse

Das System darf automatisch:

- Sprache erkennen,
- Satz- und Importkontext auswerten,
- Wortart und semantischen Typ vorschlagen,
- Sense-Kandidaten bestimmen,
- moegliche Repraesentationstypen vorschlagen,
- notwendige Voraussetzungen pruefen,
- kompatible Plot-Kandidaten suchen,
- unplatzierbare Woerter als Blueprint, Backlog oder Codex-Kandidat
  vorbereiten.

### Nutzerentscheidung

Der Nutzer entscheidet:

- ob ein Vorschlag gebaut wird,
- welcher kompatible Plot genutzt wird,
- ob ein Wort sichtbar wird, Blueprint bleibt oder nur im Codex landet,
- ob mehrere Bedeutungen getrennt gespeichert werden,
- ob automatische Vorschlaege ignoriert, spaeter erledigt oder priorisiert
  werden.

### Pipeline-Regeln

- Analyse darf Optionen vorbereiten, aber nicht ungefragt bauen.
- Ein Wort darf nicht sichtbar platziert werden, wenn Kontext, Plot,
  Anchor oder Repraesentationstyp fehlen.
- Wenn Voraussetzungen fehlen, entsteht ein Fallback: Blueprint, Backlog,
  Codex, Quest oder Companion-Vorschlag.
- Spaetere Freischaltung muss rueckwirkend pruefen koennen, ob Backlog-Woerter
  nun platzierbar sind.

## 16. Plot Capability Matrix

Diese Matrix ist ein Greybox-Planungswerkzeug. Sie ist noch kein Datenmodell
und keine Codefreigabe.

Legende:

- `erlaubt`: passt grundsaetzlich zur Plotgroesse.
- `bedingt`: nur mit passenden Anchors, Sockets, Adjacency oder Unlocks.
- `nicht erlaubt`: soll nicht angeboten werden.

| Plotgroesse | Erlaubt | Bedingt Erlaubt | Nicht Erlaubt | Voraussetzungen |
| --- | --- | --- | --- | --- |
| `micro` | `decoration`, kleines `object`, kleiner `path`-Marker | `nature` als Mini-Gruppe, `learningHub` nur als Symbol/Marker im Codex-Kontext | `home`, `market`, `garage`, `workshop`, `farm`, `water` als Zone | objectAnchor oder decorationAnchor; darf Hauptansicht nicht ueberladen |
| `small` | `garden`, `decoration`, kleiner `nature`-Bereich, `path` | kleines `workshop`-Objekt, kleiner `social`-Spot, kleines `home`-Nebenelement | `market`, vollwertiges `home`, `garage`, grosse `farm`, `learningHub` als Gebaeude | PathSocket, Sicherheitsabstand, max. kleines Footprint |
| `medium` | `home`, `garage`, `workshop`, `garden`, `path`, `decoration` | kleines `market`-Element, kleiner `learningHub`, `social`, `nature` | grosse `market`-Plaza, grosse `farm`, vollwertige `water`-Zone | buildingAnchor, Front-/Backyard-Anker, pathSocket |
| `large` | grosser `garden`, `farm`, `nature`, groesseres `home`, `workshop`, `path` | `market`, `garage`, `social`, kleiner `learningHub`, Rand-`water` mit EdgeSocket | kein ueberdimensionierter Hub ohne HubSockets | mehrere Anchors, Deko-Sicherheitszonen, Path-Verbindung |
| `hub` | `market`, `social`, `learningHub`, Bibliothek/Forum-Logik, `path` | `home` als Sonderfall, `workshop`, `decoration`, kleiner `garden` | `farm` als Hauptfunktion, `garage` ohne Zufahrt, `water` ohne Edge | mehrere PathSockets, ausreichend Freiraum, hohe Mobile-Lesbarkeit |
| `edge` | `water`, `nature`, `expansion`, Rand-Deko, `path` | `farm`, Hafen/Steg, kleine `social`-Kante, `garden` am Rand | grosses `home`, grosser `market`, `garage` ohne Zufahrt | EdgeSocket, Terrain-/WaterSocket, klare Randlogik |

Funktionsregeln:

- `home` braucht mindestens `medium` oder einen besonderen Starter-Plot.
- `market` braucht `hub` oder `large` mit mehreren PathSockets.
- `garage` braucht `medium`, Zufahrt und spaeter Vehicle-/ObjectDetail-Regeln.
- `garden` skaliert von `small` bis `large`.
- `farm` ist eher `large` oder `edge`.
- `water` ist nur auf `edge` oder speziellen Wasserplots sinnvoll.
- `learningHub` darf als kleines Thema auftauchen, aber als Gebaeude braucht
  es `hub` oder ausreichend grossen Plot.

## 17. Word Placement Requirements

Wortplatzierung braucht konkrete Voraussetzungen pro Worttyp.

| Worttyp | Anforderungen | Nicht erlaubt |
| --- | --- | --- |
| Objektwort | kompatibler Plot, `objectAnchor` oder `decorationAnchor`, passende Umgebung/Kategorie, freier Detail-Slot | Objekt frei auf Gras setzen, wenn Anchor oder Kontext fehlt |
| Bauteilwort | passender Gebaeudezustand, Bauteil-Slot, Gebaeude- oder BuildState-Kontext | `Fenster`, `Tuer`, `Dach` oder `Wand` frei in der Luft platzieren |
| Raum-/Ort-Wort | Plot-, Zone- oder Interior-Kontext; passende Plot-Funktion; ggf. Unlock | Ort als zufaelliges Dekoobjekt platzieren |
| Aktionswort | Szene, Objekt, Weg, Interaktion, Quest oder Companion-Satz | Aktion als statisches Objekt behandeln |
| Eigenschaft/Adjektiv | Vergleich, Kontextkarte, Markierung, Dialog oder Aufgabe | Adjektiv zwingend als Gegenstand darstellen |
| Abstrakter Begriff | Codex, Dialog, Szene, Debatten-/Forum-Kontext oder Aufgabe | abstrakten Begriff als beliebiges physisches Objekt erzwingen |
| Mehrdeutiges Wort | Kontextanalyse oder Nutzer-Sense-Auswahl | blindes Mapping auf erste gefundene Bedeutung |

Zusatzregeln:

- Objektwoerter koennen sichtbar werden, wenn Plot und Anchor passen.
- Bauteilwoerter koennen erst sichtbar werden, wenn das Gebaeude den passenden
  Zustand hat.
- Aktionswoerter brauchen Bewegung, Interaktion oder Quest-Kontext.
- Abstrakta duerfen prominent gelernt werden, muessen aber nicht als Objekt
  existieren.
- Mehrdeutige Woerter duerfen mehrere Kandidaten im Backlog haben.

## 18. Visual Representation Tiers

Nicht jedes Wort soll direkt als Objekt erscheinen. Talvori nutzt
Repraesentationsstufen.

| Tier | Bedeutung | Beispiel |
| --- | --- | --- |
| `none` | keine direkte Weltvisualisierung | Funktionswort, selten sichtbarer Grammatikfall |
| `codex_only` | nur Codex-Eintrag | abstrakter Begriff ohne Szenenkontext |
| `dialogue` | Tali/Vori erklaert es | `politisch`, `Meinung` |
| `blueprint` | spaeter platzierbar | `Fenster` ohne Haus, `Giesskanne` ohne Garten |
| `small_object` | kleines sichtbares Objekt | Blume, Stuhl, Giesskanne |
| `build_part` | Teil eines Gebaeudes | Fenster, Tuer, Dach |
| `plot_theme` | beeinflusst Bereich/Plot | Garten, Markt, Schule |
| `scene` | Mini-Szene | Kaufen auf dem Markt |
| `animation` | kurze Aktion | gehen, fahren, oeffnen |
| `quest` | Aufgabe / Lernauftrag | Sammle drei Gartenwoerter |
| `interior_detail` | Detail in Innenraum | Tasse auf Tisch, Stuhl in Kueche |
| `object_detail` | Detailansicht eines Objekts | Lenkrad, Sitz, Frontscheibe |

Regel:

Der Repraesentationstyp ist eine Produktentscheidung. Er darf spaeter durch
KI vorgeschlagen werden, aber die App-Logik muss pruefen, ob Plot, Zustand und
Lesbarkeit passen.

## 19. User Choice And Suggestions

Talvori darf Vorschlaege machen, aber die Insel bleibt individuell.

Erlaubt:

- passende Plots hervorheben,
- Blueprints sammeln,
- Companion-Vorschlaege anzeigen,
- sagen: `Dafuer brauchst du einen Garten.`,
- sagen: `Dieses Wort ist als Blueprint gespeichert.`,
- mehrere passende Platzierungen anbieten.

Nicht erlaubt:

- automatisch bauen, ohne dass der Nutzer bestaetigt,
- Lernrichtung und Bauprioritaet gleichsetzen,
- Nutzer zu Hausbau als erstem Schritt zwingen,
- eine Plot-Greybox als feste Reihenfolge verwenden,
- unpassende Woerter sichtbar machen, nur weil sie gelernt wurden.

Nutzer darf zuerst bauen, wenn kompatibel:

- Garten,
- Markt,
- Haus,
- Werkstatt,
- Naturbereich,
- Garage,
- Wasser-/Randbereich.

Das System darf dabei sinnvolle Reihenfolgen empfehlen, aber die Empfehlung
ist kein Zwang.

## 20. Ambiguity And Context Handling

Mehrdeutigkeit ist normal und darf nicht durch blindes Mapping geloest werden.

Beispiele:

- `bank`: Sitzbank oder Geldinstitut.
- `drive`: fahren, antreiben, Laufwerk, Motivation.
- `light`: Licht, leicht, hell.
- `politisch`: Eigenschaft, Thema, Diskussionskontext.
- `oeffnen`: Aktion an Tuer, Fenster, Datei, Gespraech.
- `fahren`: Bewegung mit Fahrzeug, reisen, transportieren.

Regeln:

- Wenn Kontext eindeutig ist, darf KI eine Bedeutung vorschlagen.
- Wenn Kontext unsicher ist, muss Tali/Vori fragen.
- Mehrere Bedeutungen duerfen als Sense-Kandidaten gespeichert werden.
- Kein blindes Mapping auf Objekt.
- Browser-Import muss Satzkontext beruecksichtigen.
- Sense-Auswahl kann spaeter selbst eine Lerninteraktion sein.

Beispiel:

```text
Wort: bank
Kontext: I sat on the bank in the park.
Vorschlag: Sitzbank / Objekt oder Naturplot-Deko

Wort: bank
Kontext: I opened a bank account.
Vorschlag: Finanz-/Business-Kontext, Codex oder Markt-/Forum-Szene
```

## 21. Visual Clutter Rules

Talvori darf aus vielen Woertern keine ueberladene Insel machen.

Regeln:

- Nicht jedes gelernte Wort wird sofort sichtbar.
- Pro Plot gibt es eine maximale Zahl sichtbarer Detailobjekte.
- Weitere Woerter landen in Codex, Blueprint, Interior oder Detailansicht.
- Mobile-Lesbarkeit hat Vorrang vor Vollstaendigkeit.
- Die grosse Inselansicht zeigt nur Hauptobjekte.
- Detailansichten zeigen Wortdetails.
- Nutzer kann sichtbare Lieblingsobjekte auswaehlen.
- Mikro-Objekte sollen in Island View gebuendelt, abstrahiert oder verborgen
  werden.
- Kategoriehaeufungen duerfen als Plot-Thema sichtbar werden, ohne jedes Wort
  einzeln darzustellen.

Vorlaeufige Clutter-Fragen:

- Wie viele sichtbare Details vertraegt ein `micro`-, `small`- oder
  `medium`-Plot?
- Welche Objekte gehoeren in Island View, welche in Interior oder
  ObjectDetail?
- Braucht der Nutzer spaeter einen Favoriten-/Showcase-Modus?

## 22. Rebuild, Move And Personalization

Flexible Platzierung braucht spaeter Regeln fuer Umbau und Verschieben.

Noch offene Entscheidungen:

- Darf der Nutzer Gebaeude spaeter verschieben?
- Darf der Nutzer eine Plot-Funktion aendern?
- Was passiert mit bereits platzierten Wortobjekten?
- Was passiert mit Blueprints, die an den alten Plot gebunden waren?
- Gibt es Umbaukosten oder Cooldown?
- Gibt es Undo?
- Welche Aenderungen sind nur visuell und welche betreffen Save State?

Erste Planungsregeln:

- Umbau darf keine gelernten Woerter verlieren.
- Wortobjekte muessen migriert, eingelagert oder in Blueprints
  zurueckgefuehrt werden koennen.
- Wenn ein Plot seine Funktion verliert, muessen inkompatible Objekte in
  `wordObjectBacklog` oder `futurePlacementCandidate` zurueckfallen.
- Undo ist fuer lokale Mock-/Planungsphasen wuenschenswert, aber noch nicht
  freigegeben.
- Umbaukosten, Cooldowns und Ressourcenlogik bleiben blockiert, bis ein
  eigenes System geplant ist.
- Individualitaet entsteht durch Nutzerwahl, nicht durch starre
  Produktionslayouts.

## 23. Abstract Data Model Sketch

Diese Modelle sind reine Planungsmodelle. Sie sind keine Dart-Klassen, keine
Datenbanktabellen und keine Persistenzfreigabe.

### `PlotSlot`

Zweck:

Beschreibt eine flexible Grundstuecksflaeche im Insel-Masterlayout.

Wichtige Felder:

```text
plotId
layoutId
plotSize
positionHint
capabilityIds[]
buildingAnchors[]
objectAnchors[]
decorationAnchors[]
pathSockets[]
expansionSockets[]
footprintPolygon
isUserSelectable
unlockState
```

Nicht:

- kein festes Gebaeude,
- keine feste Kategorie,
- keine Runtime-Asset-Datei.

Warum noetig:

Damit eine Greybox Flaechen beschreibt, nicht vorgeschriebene Bauplaetze.

### `PlotCapability`

Zweck:

Beschreibt, welche Funktionen ein Plot unter welchen Bedingungen tragen kann.

Wichtige Felder:

```text
capabilityId
allowedFunctions[]
requiredPlotSizes[]
requiredSockets[]
requiredAdjacency[]
forbiddenAdjacency[]
maxBuildingFootprint
supportsInterior
supportsObjectDetail
```

Nicht:

- keine Nutzerentscheidung,
- kein konkretes gebautes Objekt.

Warum noetig:

Damit ein Plot `home`, `garden`, `market`, `garage` oder `nature` tragen kann,
ohne darauf festgelegt zu sein.

### `BuildableDefinition`

Zweck:

Beschreibt, was grundsaetzlich gebaut werden kann.

Wichtige Felder:

```text
buildableId
displayName
allowedFunctions[]
requiredPlotCapabilities[]
requiredAnchors[]
buildStateSequence[]
visualRepresentationIds[]
supportsInterior
supportsObjectDetail
categoryTags[]
semanticTags[]
```

Nicht:

- kein konkreter Bauzustand eines Nutzers,
- keine Speicherinstanz.

Warum noetig:

Damit Haus, Garten, Markt oder Garage als moegliche Bauoptionen definiert
werden koennen, ohne einen Plot fest zu belegen.

### `BuildInstance`

Zweck:

Beschreibt eine konkrete vom Nutzer gewaehlte Bauentscheidung auf einem Plot.

Wichtige Felder:

```text
buildInstanceId
buildableId
plotId
currentBuildState
placedAnchorId
visualState
linkedWordIds[]
createdFromSuggestionId optional
```

Nicht:

- keine globale Definition,
- kein Lernfortschritt selbst.

Warum noetig:

Damit mehrere Nutzer denselben Plot-Slot unterschiedlich nutzen koennen.

### `WordSemanticProfile`

Zweck:

Beschreibt, was ein gelerntes Wort inhaltlich sein kann.

Wichtige Felder:

```text
wordId
language
lemma
surfaceForm
partOfSpeech
semanticType
senseCandidates[]
selectedSense optional
categoryTags[]
semanticTags[]
riskTags[]
sourceContexts[]
```

Nicht:

- kein Platzierungsentscheid,
- kein sichtbares Objekt.

Warum noetig:

Damit `bank`, `drive`, `light`, `Fenster` oder `politisch` nicht blind
gleich behandelt werden.

### `PlacementRequirement`

Zweck:

Beschreibt, was fuer eine Platzierung oder Visualisierung erfuellt sein muss.

Wichtige Felder:

```text
requirementId
semanticType
requiredPlotFunctions[]
requiredAnchors[]
requiredBuildState optional
requiredSceneContext optional
requiredInteriorState optional
forbiddenContexts[]
fallbackRepresentation
```

Nicht:

- kein Vorschlag,
- keine konkrete Platzierung.

Warum noetig:

Damit zum Beispiel `Fenster` einen Wand-/Hauszustand braucht und `Giesskanne`
einen Garten-, Hof- oder Objektanker.

### `PlacementCandidate`

Zweck:

Beschreibt eine moegliche, noch nicht bestaetigte Platzierung.

Wichtige Felder:

```text
candidateId
wordId optional
buildableId optional
plotId
anchorId optional
representationTier
confidence
reason
requiresUserConfirmation
riskLevel
```

Nicht:

- keine gebaute Instanz,
- keine automatische Ausfuehrung.

Warum noetig:

Damit Talvori mehrere Optionen anbieten kann, bevor der Nutzer entscheidet.

### `BlueprintEntry`

Zweck:

Speichert etwas, das spaeter platziert oder gebaut werden kann.

Wichtige Felder:

```text
blueprintId
sourceWordId
targetBuildableId optional
targetRepresentationTier
missingRequirements[]
suggestedPlotFunctions[]
createdFromContextId
```

Nicht:

- kein sichtbares Objekt,
- keine Baugarantie.

Warum noetig:

Damit gelernte Woerter nicht verloren gehen, wenn der passende Ort noch fehlt.

### `WordObjectBacklogEntry`

Zweck:

Sammelt Wortobjekte, die prinzipiell sichtbar werden koennten, aber noch
nicht platziert werden sollen.

Wichtige Felder:

```text
backlogId
wordId
semanticType
preferredRepresentationTier
compatiblePlotFunctions[]
blockedBy[]
priority
```

Nicht:

- kein Codex-Ersatz,
- keine automatische Bauwarteschlange.

Warum noetig:

Damit aus vielen Woertern keine ueberladene Insel wird.

### `VisualRepresentation`

Zweck:

Beschreibt die Art der Darstellung eines Wortes, Objekts oder Buildables.

Wichtige Felder:

```text
representationId
representationTier
assetPath optional
sceneId optional
dialogueTemplateId optional
codexTemplateId optional
requiresInterior
requiresObjectDetail
mobileVisibilityLevel
```

Nicht:

- kein Save State,
- keine Lerndatenquelle.

Warum noetig:

Damit `codex_only`, `blueprint`, `small_object`, `scene` und `quest` sauber
unterschieden werden.

### `PlacedWorldObject`

Zweck:

Beschreibt ein sichtbar platziertes Wort- oder Dekoobjekt.

Wichtige Felder:

```text
placedObjectId
sourceWordId optional
definitionId
plotId
anchorId
visualState
visibilityPriority
canMove
```

Nicht:

- kein Gebaeude selbst,
- kein Wortfortschritt.

Warum noetig:

Damit sichtbare Objekte spaeter verschoben, verborgen oder in Detailansichten
verschoben werden koennen.

### `LearningContext`

Zweck:

Beschreibt, woher und in welchem Lernzusammenhang ein Wort kommt.

Wichtige Felder:

```text
learningContextId
sourceMode
taskId optional
sentenceContext optional
topicTags[]
confidence
createdAt
```

Nicht:

- kein BuildState,
- keine Weltplatzierung.

Warum noetig:

Damit Vokabeltraining, T-SRS, A-SRS, Chat, Import und Wortspiele spaeter
unterschiedliche Vorschlagsqualitaet liefern koennen.

### `ImportContext`

Zweck:

Beschreibt Kontext aus Browser, Text, Screenshot oder Teilen-Funktion.

Wichtige Felder:

```text
importContextId
sourceType
sourceLanguage
detectedLanguages[]
rawTextSnippet
sentenceContext
paragraphContext optional
sourceUrl optional
sensitivityTags[]
phraseCandidates[]
```

Nicht:

- keine automatische Weltplatzierung,
- kein Freifahrtschein fuer KI-Mapping.

Warum noetig:

Damit importierte Woerter mit Satzkontext, Sprache, Sensibilitaet und
Mehrdeutigkeit bewertet werden koennen.

## 24. Learning Progress And Build Progress Separation

Lernen und Bauen sind verbunden, aber nicht identisch.

Grundregeln:

- Lernen darf Bauvorschlaege erzeugen, aber nicht automatisch Layout
  erzwingen.
- Bauen darf Lernkontexte eroeffnen, aber nicht verhindern, dass der Nutzer
  andere Woerter lernt.
- Der Nutzer kann Gartenwoerter lernen, ohne sofort Garten zu bauen.
- Der Nutzer kann Garten bauen, ohne vorher viele Gartenwoerter gelernt zu
  haben.
- Wortfortschritt kann Details, Blueprints, Vorschlaege, kleine Objekte oder
  kosmetische Upgrades freischalten.
- Baufortschritt kann neue Lernkontexte, Szenen, Innenraeume oder Objektanker
  oeffnen.
- Beide Systeme duerfen einander inspirieren, aber nicht gegenseitig
  blockieren.

Moegliche Verbindungsarten:

| Verbindung | Bedeutung | Beispiel |
| --- | --- | --- |
| `suggestionOnly` | Lernen erzeugt nur einen Vorschlag | viele Gartenwoerter -> Garten vorschlagen |
| `cosmeticUnlock` | Wortfortschritt schaltet Kosmetik frei | Blumenvarianten fuer Garten |
| `blueprintUnlock` | Wort erzeugt spaeter baubaren Blueprint | `Fenster` fuer Hauszustand |
| `detailUnlock` | Wort schaltet Detailanker frei | Lenkrad im Auto-Detail |
| `questUnlock` | Wortgruppe eroeffnet Aufgabe | Marktgespraech mit Kaufen/V erkaufen |
| `buildRequirement` | Bau braucht definierte Voraussetzung | spaeter optional fuer Spezialbau, nicht fuer Basisfreiheit |
| `optionalBoost` | Lernen beschleunigt oder verfeinert Bau | mehr passende Woerter -> bessere Varianten |

Stop-Regel:

Kein Lernfortschritt darf automatisch starre Baupositionen erzwingen.

## 25. Browser Import And Real-World Word Intake

Woerter aus Browser, Text, Screenshot oder Teilen-Funktion brauchen mehr
Kontextpruefung als manuell angelegte Einzelwoerter.

Importarten:

- Einzelwort,
- mehrere Woerter,
- Satz,
- Absatz,
- unbekannter Kontext,
- mehrdeutiger Kontext,
- sensible oder abstrakte Themen,
- Fremdsprache / Mischsprache,
- Eigennamen,
- Redewendungen,
- Phrasal Verbs,
- zusammengesetzte Woerter.

Pipeline:

```text
1. Importquelle erkennen
2. Sprache erkennen
3. Satzkontext sichern
4. Wort/Sense-Kandidaten erzeugen
5. Themenbereich vorschlagen
6. Risiko/Sensibilitaet pruefen
7. Representation Tier bestimmen
8. Nutzer bestaetigt oder korrigiert
9. Codex/Blueprint/Backlog/Quest speichern
```

Regeln:

- Satzkontext hat Vorrang vor Einzelwort-Mapping.
- Mischsprache darf mehrere Sprachprofile erzeugen.
- Eigennamen werden nicht automatisch als Weltobjekte platziert.
- Redewendungen und Phrasal Verbs duerfen nicht wortwoertlich als einzelne
  Objekte gemappt werden.
- Sensible Themen gehen zuerst in Codex, Dialog oder neutrale Kontextkarte.
- Browser-Import darf keine Weltplatzierung ohne Nutzerbestaetigung ausloesen.

## 26. Representation Priority And Conflict Resolution

Ein Wort kann mehrere passende Darstellungen haben.

Beispiele:

- `apple`: Obstbaum im Garten, Marktware, Essen-Vokabel, kleines Objekt.
- `bank`: Sitzbank oder Geldinstitut.
- `light`: Licht oder leicht.
- `drive`: fahren, Antrieb, Laufwerk, Motivation.

Prioritaetsregel:

```text
1. Nutzer-Sense-Auswahl gewinnt.
2. Eindeutiger Satzkontext gewinnt.
3. Bereits vorhandene passende Plots/Objekte werden bevorzugt.
4. Lernziel/Kategorie des Nutzers wird beruecksichtigt.
5. Bei Unsicherheit: Blueprint/Codex statt sichtbare Platzierung.
6. Bei hohem Risiko: keine automatische Visualisierung.
7. Tali/Vori fragt nach.
```

Konfliktregeln:

- Wenn zwei Darstellungen gleich plausibel sind, wird nicht automatisch
  platziert.
- Wenn ein sichtbares Objekt Mobile-Clutter erzeugen wuerde, wird Blueprint
  oder Codex bevorzugt.
- Wenn ein vorhandener Plot sehr gut passt, darf Talvori ihn hervorheben, aber
  nicht ungefragt nutzen.
- Wenn eine Bedeutung sensibel ist, gewinnt Safety vor Sichtbarkeit.

## 27. Sensitive And Abstract Concept Handling

Nicht jeder Begriff gehoert als Objekt in die Welt.

Vorsichtig zu behandeln sind unter anderem:

- Politik,
- Religion,
- Krankheit,
- Gewalt,
- Identitaet,
- Krieg,
- Tod,
- Sexualitaet,
- persoenliche Eigenschaften,
- sensible soziale Gruppen,
- traumatische oder kontroverse Themen.

Bevorzugte Darstellung:

- Codex,
- Dialog,
- neutrale Kontextkarte,
- Lernsatz,
- Debatten-/Forum-Szene nur wenn spaeter bewusst geplant.

Regeln:

- Keine problematischen Symbole automatisch platzieren.
- Keine politische oder religioese Gebaeude- oder Symbolplatzierung ohne
  bewusste Nutzerentscheidung und spaeteres eigenes Safety-Konzept.
- Keine sensiblen Begriffe als Deko-Objekte erzwingen.
- Sensible Begriffe duerfen gelernt werden, muessen aber neutral, kontextuell
  und respektvoll behandelt werden.
- Tali/Vori darf bei Unsicherheit nach Kontext fragen.

## 28. Learning Mode Integration

Kein Lernmodus darf ohne Nutzerentscheidung chaotisch die Insel bebauen.

| Lernmodus | Weltobjekte automatisch? | Vorschlaege? | Blueprints? | Codex-Fortschritt? | Nutzerbestaetigung? |
| --- | --- | --- | --- | --- | --- |
| klassisches Vokabeltraining | nein | ja, wenn thematisch klar | ja | ja | ja fuer Platzierung |
| T-SRS | nein | ja, auf Basis stabiler Wiederholung | ja | ja | ja |
| A-SRS | nein | ja, wenn KI-Kontext sicher ist | ja | ja | ja |
| Hybrid-Modus | nein | ja | ja | ja | ja |
| Wortspiele | nein | optional nach Abschluss | optional | ja | ja |
| Kontext-Challenge | nein | ja, stark kontextbezogen | ja | ja | ja |
| Chat mit Tali/Vori | nein | ja, dialogisch | ja | ja | ja |
| importierte Woerter | nein | ja, nach Kontext-/Safety-Pruefung | ja | ja | ja |
| manuell angelegte Woerter | nein | ja, wenn Nutzer Kontext gibt | ja | ja | ja |

Grundregeln:

- Lernmodus erzeugt zuerst Fortschritt, Kontext und Vorschlaege.
- Sichtbare Weltobjekte entstehen erst nach Placement Decision Pipeline und
  Nutzerbestaetigung.
- Codex-Fortschritt darf automatisch entstehen, solange keine sensible
  Fehlzuordnung passiert.
- Blueprints duerfen als sichere Zwischenform entstehen.
- Lernmodus, Weltvorschlag und Bauentscheidung bleiben getrennte Schritte.

## 29. Progression Without Forced Build Order

Talvori braucht Progression ohne verdeckte Pflichtreihenfolge.

Grundregeln:

- Nutzer darf mit Haus, Garten, Markt, Werkstatt, Naturbereich oder anderem
  kompatiblen Bereich starten.
- Talvori darf keine feste Reihenfolge erzwingen.
- Progression soll ueber Optionen, Blueprints, kosmetische Freischaltungen,
  Lernkontexte und neue Anchors funktionieren.
- Basisbau soll frei bleiben.
- Spezialbau darf Voraussetzungen haben, wenn sie klar, optional oder
  sinnvoll begruendet sind.
- Lernen darf Vorschlaege und Details freischalten, aber nicht automatisch
  starre Baupositionen erzeugen.
- Bauen darf neue Lernkontexte oeffnen, aber keine Lernrichtung erzwingen.

Erste Progression-Typen:

| Typ | Bedeutung | Beispiel |
| --- | --- | --- |
| `freeBuildOption` | sofort kompatibel und frei waehlen | Garten oder Haus auf passendem Core-Plot |
| `suggestedBuildOption` | empfohlen, aber nicht erzwungen | viele Gartenwoerter -> Garten vorschlagen |
| `blueprintAvailable` | als Plan vorhanden, Ort fehlt noch | `Fenster` als Haus-Blueprint |
| `cosmeticDetailUnlocked` | sichtbares Detail oder Variante | Blumenfarbe, Schild, kleines Objekt |
| `contextSceneUnlocked` | neuer Lern-/Szenenkontext | Marktgespraech, Gartenpflege |
| `specialBuildRequirement` | besondere Voraussetzung fuer Spezialbau | groesserer Hub, Wasseranschluss, Kategoriepfad |
| `optionalLearningBoost` | Lernen erleichtert oder veredelt Bau | mehr passende Woerter -> bessere Varianten |

Stop-Regel:

Eine Progression ist nicht akzeptabel, wenn sie formal frei wirkt, den Nutzer
praktisch aber wieder in dieselbe Haus-zuerst-Reihenfolge zwingt.

## 30. First Session And Free Start Choice

Die erste Session muss freie Erstwahl erklaeren, ohne den Nutzer mit
Systemsprache zu ueberfordern.

Der Nutzer soll nicht automatisch mit Hausbau starten muessen.

Moegliche Startoptionen:

- `Haus vorbereiten`
- `Garten anlegen`
- `Marktstand vorbereiten`
- `Naturbereich gestalten`

Onboarding-Regeln:

- Erste Session zeigt 2-4 kompatible Startoptionen.
- Tali/Vori erklaert kurz: `Du kannst frei waehlen.`
- Tali/Vori erklaert: Woerter koennen spaeter passende Objekte, Blueprints
  oder Vorschlaege erzeugen.
- Tali/Vori erklaert: Nichts wird ohne Bestaetigung automatisch platziert.
- Wenn der Nutzer keine Entscheidung treffen will, darf Talvori eine
  empfohlene Standardroute vorschlagen, aber nicht erzwingen.
- Startoptionen muessen zu vorhandenen Plot-Capabilities passen.
- Das Onboarding darf keine feste spaetere Stadtstruktur behaupten.

Beispieltext:

```text
Du entscheidest, wie deine Insel beginnt. Waehle einen Bereich, der zu dir
passt. Deine Woerter koennen spaeter passende Objekte, Blueprints und kleine
Aufgaben vorschlagen.
```

## 31. Import Governance, Privacy And Safety

Importierte Woerter und Saetze koennen private, sensible oder problematische
Inhalte enthalten.

Regeln:

- Browser-/Share-Import darf nicht blind als Weltobjekt verarbeitet werden.
- Sensible Inhalte werden bevorzugt als Codex, Dialog oder neutrale
  Kontextkarte behandelt.
- Keine automatische politische, religioese, medizinische, sexuelle,
  gewaltbezogene oder personenbezogene Symbol-/Gebaeudeplatzierung.
- Nutzer muss bei sensiblen oder unsicheren Bedeutungen bestaetigen.
- Wenn spaeter KI- oder Cloud-Verarbeitung genutzt wird, braucht es eigene
  Datenschutz-/Safety-Planung.
- Lokal/Cloud-Frage bleibt fuer spaetere Architektur blockiert.
- Importierte Inhalte duerfen keine Supabase Writes oder Persistenz ausloesen,
  solange diese nicht explizit freigegeben sind.

Governance-Tags:

- `sensitiveTopic`
- `personalDataRisk`
- `medicalTopic`
- `politicalTopic`
- `religiousTopic`
- `violenceTopic`
- `adultTopic`
- `identityTopic`
- `unknownRisk`

Interpretation:

Ein Governance-Tag blockiert nicht zwingend Lernen. Es blockiert aber
automatische sichtbare Weltplatzierung, bis Kontext, Safety und
Nutzerentscheidung geklaert sind.

## 32. User Goal And Category Priority

Wenn ein Wort mehrere Darstellungen haben kann, beeinflussen Nutzerziel,
aktive Kategorie und Satzkontext die Vorschlaege.

Beispiele:

| Wort | Kategorie / Ziel | Bevorzugter Vorschlag |
| --- | --- | --- |
| `apple` | Essen | Marktware / Lebensmittel / Codex |
| `apple` | Garten | Baum / Obstgarten / Garten-Blueprint |
| `apple` | Alltag | kleines Objekt oder Codex |
| `drive` | Reisen | fahren / Route / Szene |
| `drive` | Technik | Laufwerk / Geraet / Codex |
| `drive` | Motivation | abstrakter Begriff / Dialog |
| `bank` | Stadt/Alltag | Sitzbank / kleines Objekt |
| `bank` | Business | Bankinstitut / Codex / Forum-Szene |

Prioritaetsregel:

```text
1. Nutzer gewaehlte Bedeutung gewinnt.
2. Aktive Lernkategorie beeinflusst Vorschlag.
3. Satzkontext schlaegt Einzelwortinterpretation.
4. Vorhandene passende Plots reduzieren Aufwand.
5. Bei Unsicherheit: Tali/Vori fragt oder Codex/Blueprint statt Platzierung.
```

Regeln:

- Kategorie-Priorisierung darf keine harte Kategoriebindung im Plot erzwingen.
- Nutzerziel darf Vorschlaege sortieren, aber nicht automatisch bauen.
- Satzkontext kann Kategorieannahmen korrigieren.
- Bei Widerspruch zwischen Kategorie und Satzkontext gewinnt Kontext oder
  Tali/Vori fragt nach.

## 33. Next Greybox Renaming Requirements

Die naechste Greybox darf nicht mehr `starter_home`, `garden_west`,
`market_square` oder aehnliche Namen als feste Rollen zeigen.

Stattdessen soll sie abstrakte Capability-Labels verwenden:

- `core_plot_a`
- `core_plot_b`
- `core_plot_c`
- `connector_plot_a`
- `hub_capable_plot_a`
- `hub_capable_plot_b`
- `edge_water_capable_plot_a`
- `edge_farm_capable_plot_a`
- `edge_nature_capable_plot_a`
- `residential_capable_unlock_plot_a`
- `expansion_socket_plot_a`

Die naechste Greybox muss sichtbar machen:

- Plotgroesse,
- `allowedFunctions`,
- `isUserSelectable`,
- `requiredAdjacency`,
- `pathSockets`,
- `objectAnchors`,
- `buildingFootprint`,
- ob ein Plot mehrere Funktionen tragen kann.

Debug-Regeln:

- Diese Greybox bleibt Dokumentationsmaterial, keine finale Kunst.
- Plot-Labels duerfen keine feste Gebaeudefunktion suggerieren.
- Mehrfachfaehige Plots sollen als solche sichtbar werden.
- `allowedFunctions` muessen lesbar genug sein, damit die Nutzerfreiheit
  geprueft werden kann.
- `isUserSelectable` muss sichtbar sein, damit freie Erstwahl pruefbar wird.

Naechster Greybox-Zweck:

```text
Pruefen, ob flexible Plot-Capabilities visuell planbar sind, ohne wieder wie
feste Haus-/Garten-/Marktpositionen zu wirken.
```

## 34. Thematic Island And Archipelago Strategy

Talvori soll langfristig nicht aus einer einzigen Insel bestehen.

Die aktuelle Wald-/Starterinsel ist nur eine erste private Lerninsel. Sie darf
nicht alle Lernbereiche, Biome, Stadtfunktionen und Spezialthemen aufnehmen
muessen.

Grundregeln:

- Themen, die raeumlich oder semantisch nicht passen, erhalten eigene Inseln,
  Biome oder Lernwelten.
- Ein Wort wird nicht zwanghaft auf eine unpassende Insel gepresst.
- Themeninseln helfen, visuelle Logik, Lernkontext und Plot-Capabilities
  sauber zu trennen.
- Jede Themeninsel bleibt intern flexibel und nutzt Plot-Capabilities statt
  fester Gebaeudeplaetze.
- Themeninseln duerfen spaeter erweitert werden, ohne hart codiert zu sein.

Grundsatzentscheidung:

```text
Talvori wird als Personal Learning Archipelago geplant.
```

Eine Nutzerwelt kann mehrere private Inseln enthalten. Jede Insel hat:

- Thema,
- Biome,
- Plot-Capabilities,
- typische Buildables,
- passende Wort-/Kategoriezuordnungen,
- eigene Unlock-Regeln,
- eigene Greybox- und Asset-Pipeline.

Interpretation:

Die Waldlichtung bleibt `StarterCorePlot` / Starterinsel-Testform. Sie muss
nicht Meer, Flughafen, Krankenhaus, Grossstadt, Weltraum und Bauernhof
gleichzeitig tragen.

## 35. Candidate Theme Islands

Diese Liste ist eine Planungslandkarte, keine Produktionsfreigabe. Nicht alle
Inseln werden gleichzeitig produziert.

| Theme Island | Zweck | Typische Lernwoerter | Typische Plot-Typen | Typische Buildables | Passt dort nicht gut | Moegliche Unlock-Logik |
| --- | --- | --- | --- | --- | --- | --- |
| Starter / Zuhause / Alltag | sanfter Start fuer Basiswoerter und private Inselidentitaet | Haus, Garten, Familie, Zimmer, Dinge, einfache Verben | `core`, `home_capable`, `garden_capable`, `connector`, `decoration` | Haus, Hof, Garten, einfache Wege, kleine Deko | Flughafen, Krankenhauskomplex, Hafen, grosse Stadt | erste Insel oder Startwahl |
| Kueste / Meer / Tauchen / Boote | Wasser-, Wetter-, Reise- und Meereswortschatz | Strand, Boot, Fisch, tauchen, segeln, Wetter, Navigation | `water_edge`, `dock`, `beach`, `marina`, `boat`, `weather` | Strand, Hafen, Bootssteg, Tauchbasis, Marina | Waldhaus als Hauptthema, grosses Krankenhaus, Buero | nach Starter oder bei Reise-/Meer-Interesse |
| Stadtleben | urbane Alltagssituationen | Strasse, Laden, Rathaus, Bank, Post, Cafe, Wohnung | `street`, `market`, `residential`, `administration`, `shop`, `social` | Platz, Cafe, Shop, Rathaus, Wohnhaus | Farmflaechen, offenes Meer, Raumstation | nach Alltag/Markt/Transport-Interesse |
| Land / Bauernhof / Natur | Natur-, Tier-, Werkzeug- und Lebensmittelwoerter | Feld, Tier, Scheune, Obst, Baum, Werkzeug | `farm`, `field`, `barn`, `orchard`, `nature`, `tool` | Feld, Scheune, Obstgarten, Tierbereich | Flughafen, grosses Buero, Krankenhauskomplex | nach Garten-/Naturwoertern oder Food-Pfad |
| Berge / Abenteuer / Outdoor | Bewegung, Ausruestung, Wetter, Abenteuer | Berg, Schnee, wandern, klettern, Ausruestung | `mountain`, `trail`, `snow`, `lookout`, `cabin`, `camp` | Berghuette, Wanderweg, Aussichtspunkt, Kletterstelle | Marktstadt als Hauptfokus, Hafen | nach Natur/Reise/Sport-Interesse |
| Reisen / Verkehr | Mobilitaet, Wegbeschreibung und Reiseablauf | Bahnhof, Flughafen, Taxi, Ticket, Gepaeck, Hotel | `station`, `airport`, `road`, `hotel`, `vehicle`, `ticket` | Bahnhof, Flughafenbereich, Busstation, Hotel | Waldgarten als Hauptfunktion, Farm als Fokus | nach Reise-/Transportwoertern |
| Gesundheit / Krankenhaus / Arzt | medizinische Alltagssprache und Pflegekontext | Arzt, Apotheke, Koerper, Symptom, Pflege, Notfall | `clinic`, `pharmacy`, `hospital`, `care`, `emergency` | Arztpraxis, Apotheke, Klinik, Pflegebereich | automatische Deko fuer sensible Begriffe | spaeter, nach Safety-Konzept |
| Arbeit / Firmen / Berufe | Berufswortschatz, Prozesse und Werkzeuge | Buero, Meeting, Lager, Werkzeug, Beruf, Produktion | `office`, `workshop`, `warehouse`, `meeting`, `production` | Buero, Meetingraum, Werkstatt, Lager | Strand/Tauchen als Fokus | nach Business-/Berufsinteresse |
| Essen / Restaurant / Markt | Essen, Kochen, Einkaufen und Service | Restaurant, Kueche, Speise, Getraenk, kaufen | `restaurant`, `kitchen`, `market`, `shop`, `food` | Restaurant, Supermarkt, Marktstand, Kueche | Krankenhaus als Hauptthema, Flughafenkomplex | nach Food-/Alltag-/Marktwoertern |
| Schule / Lernen / Universitaet | Bildungssprache und Lernorte | Schule, Fach, Pruefung, Buch, Bibliothek | `classroom`, `library`, `campus`, `study`, `exam` | Klassenraum, Bibliothek, Campus, Lernhof | Hafen/Tauchen als Fokus | nach Lern-/Schulthemen |
| Technik / Digital / Labor | Geraete, Daten, Apps, Labor und Programmierung | Computer, Server, App, Daten, Labor, Programm | `lab`, `server`, `device`, `coding`, `research` | Labor, Serverraum, Werkbank, Tech-Hub | Bauernhof als Hauptthema | nach Technik-/Digitalwoertern |
| Weltraum / Zukunft / Science-Fiction | Zukunfts-, Astronomie- und abstraktere Technikwoerter | Planet, Rakete, Raumstation, Astronomie | `space_station`, `planet`, `rocket`, `science`, `future` | Raumstation, Raketenplattform, Sternwarte | normales Zuhause als einziger Kontext | spaeterer Spezialpfad, hoher Produktionsaufwand |
| Kultur / Geschichte / Museum | Geschichte, Kunst, Tradition und Orte | Museum, Denkmal, Kirche, Kunst, Tradition | `museum`, `monument`, `gallery`, `heritage`, `culture` | Museum, Galerie, Denkmalplatz | automatische sensible Symbole | nach Kultur-/Geschichtsthemen, mit Safety |
| Sport / Freizeit | Aktivitaeten, Regeln, Bewegung, Freizeit | Fussball, Fitness, schwimmen, Spiel, Sport | `field`, `court`, `gym`, `pool`, `playground` | Sportplatz, Fitnessbereich, Schwimmbad, Spielplatz | Krankenhaus als Fokus | nach Sport-/Freizeitwoertern |
| Verwaltung / Politik / Gesellschaft | abstrakte und sensible Gesellschaftsbegriffe neutral behandeln | Politik, Meinung, Entscheidung, Recht, Gesellschaft | `forum`, `townhall`, `codex`, `debate`, `administration` | Rathaus, Forum, neutraler Codex-/Dialograum | automatische politische/religioese Symbolik | spaeter, nur mit Safety- und Neutralitaetskonzept |

## 36. First Island Choice And Island Slots

Der Nutzer soll am Anfang nicht mit zu vielen Inseln ueberfordert werden.

Empfehlung:

- Start mit 1 aktiver Insel.
- 3 bis 5 Start-Themen zur Auswahl.
- Weitere Themen als sichtbare, aber gesperrte Roadmap.
- Spaeter mehrere private Inseln als Personal Learning Archipelago.

Moegliche erste Startoptionen:

- Zuhause/Alltag,
- Garten/Natur,
- Stadt/Markt,
- Reisen/Verkehr,
- Meer/Kueste optional, wenn visuell stark genug.

Regeln:

- Der Nutzer darf spaeter weitere private Inseln freischalten.
- Jede Insel gehoert sichtbar zum Nutzer, zum Beispiel ueber Avatar, Fahne
  oder Besitzer-Symbol.
- Mehrere Inseln sollen nicht wie getrennte Apps wirken, sondern wie ein
  zusammenhaengender persoenlicher Lernarchipel.
- Startauswahl darf nicht zur dauerhaften Sackgasse werden.

Free/Paid-Vorbereitung:

- Free braucht mindestens eine starke Startinsel und eine klare Roadmap.
- Free sollte spaeter mindestens einen Blick auf weitere Themen bekommen.
- Zahlende Nutzer koennten mehr parallele Insel-Slots oder fruehere
  Themenfreischaltung erhalten.
- Pay-to-Win beim Lernen ist nicht erlaubt.
- Core Learning darf nicht hart hinter Paywall blockiert werden.

Produktionsbremse:

- Zum Start nicht alle Inseln anbieten.
- Krankenhaus, Flughafen, Weltraum, Verwaltung/Politik und grosse Stadt sind
  spaeter sinnvoller, weil sie mehr Safety-, Asset- und Scope-Aufwand haben.

## 37. Island Roadmap And Learning Path

Talvori kann eine visuelle Roadmap nutzen, aehnlich einer Lernpfad-Idee.

Struktur:

- Themeninseln als Stationen,
- Unterbereiche als Units,
- einzelne Plots oder Buildables als Lernabschnitte,
- optionale Abzweigungen fuer Nutzerinteressen.

Die Roadmap darf Orientierung geben, aber nicht alle Nutzer gleich machen.
Jede Themeninsel kann eine eigene Mini-Roadmap haben.

Beispiele:

```text
Kuesteninsel:
Strand -> Bootssteg -> Marina -> Tauchen -> Segelboot -> Wetter/Navigation

Stadtinsel:
Strasse -> Cafe -> Markt -> Bahnhof -> Rathaus -> Krankenhaus

Arbeitsinsel:
Buero -> Meetingraum -> Werkstatt -> Lager -> Berufsspezialisierung
```

Planungsbegriffe:

- `ThemeIsland`: thematische Insel mit Biome, Plot-Capabilities und
  Lernkontext.
- `IslandUnit`: groesserer Abschnitt einer Themeninsel.
- `PlotCluster`: Gruppe kompatibler Plots innerhalb einer Unit.
- `LearningPathNode`: Lern- oder Bauknoten im Pfad.
- `UnlockGate`: Voraussetzung fuer neue Unit, Insel oder Spezialbuildable.
- `OptionalBranch`: freiwilliger Pfad ohne harte Pflichtreihenfolge.

Regel:

Roadmap ist Orientierung, nicht starre Bauanweisung.

## 38. Theme Islands With Flexible Plot Slots

Auch Themeninseln duerfen nicht starr sein.

Regeln:

- Jede Themeninsel definiert erlaubte Plot-Capabilities, nicht feste Gebaeude.
- Nutzer entscheidet innerhalb der Insel, welche kompatible Nutzung zuerst
  entsteht.
- Themeninsel-Capabilities sortieren Vorschlaege, erzwingen aber keine
  Einzelplatzierung.

Beispiele:

```text
coast_island
supports: water, marina, beach, boat, fishing, travel, weather
first choices: beach_plot, dock_plot, market_stall_plot

city_island
supports: market, residential, transport, office, social, administration
first choices: cafe_plot, shop_plot, apartment_plot, station_plot

farm_island
supports: farm, garden, animals, tools, food, nature
first choices: field_plot, barn_plot, garden_plot
```

Interpretation:

- Eine Kuesteninsel soll Wasser-/Hafen-Plots haben, aber Nutzer entscheidet,
  ob zuerst Bootssteg, Strandbar, Tauchbasis oder kleiner Markt entsteht.
- Eine Stadtinsel soll Stadt-Plots haben, aber Nutzer entscheidet, ob zuerst
  Cafe, Wohnung, Shop, Bank oder Markt entsteht.
- Eine Gesundheitsinsel kann Krankenhaus, Apotheke oder Arztpraxis ermoeglichen,
  aber sensible Woerter bleiben safety-geprueft.

## 39. Word To Island Routing

Wenn ein Wort gelernt oder importiert wird, muss Talvori zuerst den besten
Inselkontext pruefen.

Routing-Pipeline:

```text
1. Welche Bedeutung / Sense?
2. Welche Kategorie?
3. Welche Themeninsel passt am besten?
4. Gibt es dort einen passenden Plot?
5. Gibt es auf einer anderen Insel einen besseren Kontext?
6. Ist die passende Insel freigeschaltet?
7. Wenn nicht: Blueprint / Codex / Future Island Suggestion
```

Beispiele:

| Wort | Moegliche Inselroute |
| --- | --- |
| `boat` | Kueste/Meer/Transport |
| `dive` | Kueste/Tauchen/Sport |
| `airport` | Reisen/Verkehr/Stadt |
| `hospital` | Gesundheit/Stadt |
| `meeting` | Arbeit/Firma |
| `apple` | Essen/Markt oder Garten/Farm je nach Kontext |
| `politics` | Verwaltung/Gesellschaft/Codex/Dialog |
| `drive` | Verkehr/Reisen oder Technik je nach Kontext |

Regeln:

- Wenn passende Insel fehlt, entsteht keine falsche Waldlichtungsplatzierung.
- Wenn passende Insel gesperrt ist, entsteht ein Blueprint, Codex-Eintrag oder
  `futureIslandSuggestion`.
- Tali/Vori kann erklaeren: `Dieses Wort passt spaeter gut zu deiner
  Kuesteninsel.`
- Word-to-Island Routing kommt vor Plot-Platzierung.

## 40. Free And Paid Island Access Principles

Dieses Dokument trifft keine Monetarisierungsentscheidung. Es legt nur
Prinzipien fest.

Core-Prinzipien:

- Core Learning darf nicht hart hinter Paywall blockiert werden.
- Free-Nutzer brauchen mindestens eine starke Startinsel und klare
  Fortschrittsroadmap.
- Wichtige Grundvokabeln duerfen nicht nur gegen Zahlung erreichbar sein.
- Monetarisierung darf nicht Pay-to-Win beim Lernen erzeugen.

Moegliche Paid-Vorteile spaeter:

- mehr parallele Insel-Slots,
- fruehere Themeninsel-Freischaltung,
- mehr kosmetische Varianten,
- schnellere Wechsel zwischen Themeninseln,
- zusaetzliche Deko-/Showcase-Optionen,
- mehr KI-/Import-Komfort, falls Kosten entstehen.

Nicht erlaubt:

- Pay-to-Win beim Lernen,
- notwendige Grundvokabeln nur gegen Zahlung,
- unfaire Blockade wichtiger Lernbereiche,
- zahlungspflichtige Pflichtinsel fuer Basisfortschritt.

Regel:

Monetarisierung braucht spaeter ein eigenes Dokument.

## 41. Production Scope Control For Theme Islands

Nicht alle Inseln werden gleichzeitig produziert.

Scope-Regeln:

- Erst 1-2 Themen tief planen.
- Weitere Inseln nur als Roadmap oder Backlog.
- Fuer MVP/Vertical Slice:
  - eine Starterinsel,
  - eine zweite Themeninsel als Konzept oder Preview,
  - keine vollstaendige Multi-Island-Produktion.

Jede neue Insel braucht:

- `ThemeIsland`-Dokument,
- Plot-Capability-Liste,
- Wortkategorien,
- Unlock-Regeln,
- Greybox,
- Asset-Prompt,
- Device-/Preview-Check,
- Freigabe.

Stop-Regel:

Keine Multi-Island-Produktion ohne Scope-Gate. Eine Themeninsel darf erst
produziert werden, wenn klar ist, warum sie gebraucht wird, welche Woerter sie
traegt, welche Plot-Capabilities sie hat und wie sie in den Personal Learning
Archipelago passt.

## 42. Archipelago Navigation And World Map

Mehrere Inseln brauchen eine uebergeordnete Navigation.

Prinzipien:

- Der Nutzer soll nicht das Gefuehl haben, in getrennten Apps zu sein.
- Es braucht eine Archipel-/Weltkarten-Ansicht oder spaetere Globus-/
  Kartenlogik.
- Jede private Insel gehoert sichtbar zum Nutzer.
- Tali/Vori kann erklaeren, warum eine Insel empfohlen wird.
- Navigation soll Orientierung geben, aber keine Aufgabenflut erzeugen.

Moegliche Inselstatus in der Archipelansicht:

- `active`
- `locked`
- `recommended`
- `inProgress`
- `completed`
- `favorite`
- `archived`

Moegliche Darstellungen:

- persoenliche Archipelkarte,
- Inselpfad,
- Themenkarten,
- Globus mit Inselgruppen,
- Roadmap mit freischaltbaren Inseln.

Noch nicht festgelegt:

- konkrete UI,
- Kamera- oder Zoomlogik,
- Animation,
- technische Navigation.

## 43. Shared Codex Blueprint And Backlog Across Islands

Codex, Blueprints und Backlogs duerfen nicht nur an einer einzelnen Insel
haengen.

Regeln:

- Der Codex gehoert zur gesamten Nutzerwelt, nicht nur zu einer Insel.
- Blueprints koennen inselbezogen oder global sein.
- `wordObjectBacklog` kann Woerter sammeln, die spaeter auf mehreren Inseln
  relevant werden.
- Ein Wort darf nicht verloren gehen, wenn die passende Insel noch nicht
  freigeschaltet ist.
- Wenn eine neue Insel freigeschaltet wird, sollen passende Backlog- und
  Blueprint-Eintraege erneut geprueft werden.

Beispiele:

- `boat` gelernt, Kuesteninsel noch gesperrt ->
  `globalBlueprint` / `futureIslandSuggestion`.
- `apple` gelernt -> kann Esseninsel, Markt oder Garten/Farm betreffen.
- `hospital` gelernt, Gesundheitsinsel fehlt -> `globalCodexEntry` +
  `futureIslandSuggestion`.
- `window` gelernt -> Haus-/Gebaeude-Blueprint, egal auf welcher passenden
  Insel spaeter ein Gebaeude entsteht.

Begriffe:

- `globalCodexEntry`: weltweiter Codex-Eintrag des Nutzers.
- `islandBlueprint`: Blueprint, der an eine konkrete Insel oder Inselart
  gebunden ist.
- `globalBlueprint`: Blueprint ohne aktuelle Inselbindung.
- `wordObjectBacklog`: Sammelliste fuer spaeter platzierbare Wortobjekte.
- `futureIslandSuggestion`: Hinweis, dass ein Wort gut zu einer spaeteren
  Themeninsel passt.
- `recheckOnIslandUnlock`: erneute Pruefung, wenn eine passende Insel
  freigeschaltet wird.

## 44. Cross-Island Word Routing And Multi-Home Words

Ein Wort kann zu mehreren Inseln passen.

Beispiele:

- `apple`
  - Essen/Restaurant,
  - Garten/Farm,
  - Markt/Stadt.
- `drive`
  - Reisen/Verkehr,
  - Technik,
  - Motivation/Dialog.
- `bank`
  - Stadt/Sitzbank,
  - Business/Bankinstitut,
  - Natur/Flussufer, falls Kontext passt.
- `light`
  - Technik/Lampe,
  - Eigenschaft/leicht,
  - Natur/Licht.

Regeln:

- Ein Wort darf mehrere `IslandCandidates` haben.
- Nutzer-Sense-Auswahl gewinnt.
- Satzkontext entscheidet vor Kategorie.
- Bereits freigeschaltete Inseln duerfen bevorzugt vorgeschlagen werden, aber
  nicht falsche Zuordnungen erzwingen.
- Wenn mehrere Inseln passen, zeigt Tali/Vori eine einfache Auswahl.
- Ein Wort kann in einer Insel sichtbar sein und in einer anderen nur Codex
  oder Blueprint bleiben.
- Keine doppelte chaotische Platzierung ohne Nutzerwunsch.

Begriffe:

- `primaryIslandCandidate`: wahrscheinlich beste Insel fuer aktuelle
  Bedeutung.
- `secondaryIslandCandidates`: weitere passende Inseln.
- `multiHomeWord`: Wort mit mehreren legitimen Inselkontexten.
- `islandSpecificRepresentation`: Darstellung, die nur fuer eine Insel
  gilt.
- `globalRepresentation`: Codex/Dialog/Blueprint-Darstellung fuer die
  gesamte Nutzerwelt.

## 45. Island Slot Lifecycle

Jede Insel braucht einen Status.

Moegliche Status:

- `locked`
- `preview`
- `available`
- `active`
- `paused`
- `completed`
- `archived`
- `favorite`

Regeln:

- Free-Nutzer sollen nicht zu viele aktive Inseln gleichzeitig verwalten
  muessen.
- Paid-Nutzer koennten spaeter mehr parallele aktive Insel-Slots bekommen.
- Archivieren darf keine Woerter loeschen.
- Pausieren darf Fortschritt nicht verlieren.
- Abgeschlossene Inseln bleiben als Showcase oder Wiederholungsbereich
  nutzbar.
- Eine Insel kann empfohlen werden, wenn viele passende Woerter im Backlog
  liegen.
- Slot-Limits duerfen Core Learning nicht blockieren.

Offen:

- Wie viele aktive Inseln Free haben soll.
- Ob `paused` und `archived` fuer V1 ueberhaupt sichtbar sind.
- Welche Status spaeter lokal oder cloud-authoritative sind.

## 46. Island Ownership And Identity

Mehrere private Inseln muessen klar als Inseln desselben Nutzers erkennbar
sein.

Moegliche Marker:

- Avatar-Symbol,
- Fahne,
- Besitzer-Icon,
- persoenliches Farbschema,
- Inselname.

Regeln:

- Marker sind rein visuell und organisatorisch.
- Marker duerfen keine sozialen oder oeffentlichen Funktionen erzwingen.
- Jede Insel bleibt Teil der privaten Nutzerwelt, solange kein Social-/
  Showcase-Konzept freigegeben ist.
- Spaetere Showcase- und Freundesfunktionen brauchen eigenes Social-/
  Privacy-Konzept.

## 47. Archipelago UX Complexity Control

Zu viele Inseln am Anfang ueberfordern den Nutzer.

Regeln:

- Zu Beginn nur wenige klare Optionen zeigen.
- Weitere Inseln duerfen als Roadmap sichtbar sein, aber nicht als
  Aufgabenflut.
- Nutzer kann Empfehlungen ignorieren.
- Empfehlungen brauchen eine klare, einfache Begruendung.
- Die Archipelansicht braucht eine einfache Prioritaetshierarchie.

Beispielhinweise:

- `Du lernst viele Reisewoerter. Eine Reiseinsel passt gut.`
- `Du hast mehrere Meerwoerter gesammelt. Spaeter kannst du eine
  Kuesteninsel oeffnen.`

Einfache Ansicht:

- Meine aktive Insel,
- empfohlene naechste Insel,
- spaeter freischaltbare Inseln.

Stop-Regel:

Keine Archipel-Roadmap, die mehr Optionen zeigt, als der Nutzer sinnvoll
verstehen oder priorisieren kann.
