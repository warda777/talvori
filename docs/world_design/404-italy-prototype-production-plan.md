# Italien-Prototyp Produktionsplan

Stand: 2026-06-12

Status: `docs_only_slice`, `production_plan`, `no_code`, `no_assets`,
`not_runtime_data`

## 1. Ausgangspunkt und Richtungswechsel

Talvori soll sich wie ein echtes Spiel anfuehlen. Die sichtbare Progression
entsteht ueber Welt, Land, Bauflaechen, Entdeckung und Ausbau, nicht ueber
Tabellen, Listen, Debug-Boards oder eine technische Kartenansicht.

Der naechste Welt-Prototyp startet deshalb nicht mehr mit einer frei
erfundenen Inselgrundform. Der erste neue Prototyp nutzt Italien als echte,
wiedererkennbare Landform.

Richtungswechsel:

- Die echte Italien-Kontur dient als erkennbare Aussenform.
- Die Innenstruktur wird gameplaygerecht abstrahiert.
- Talvori baut keine 1:1-Geografie nach.
- Der Prototyp bleibt ein 2.5D-Cozy-World-/Island-Builder-Spielfeld.
- Die Uferwald-Regeln bleiben als technische und produktionelle Regeln
  relevant, werden aber auf den Italien-Prototyp uebertragen.

Dieser Slice erzeugt nur Dokumentation und Produktionsplanung:

- kein Code,
- keine Flutter-/Dart-Dateien,
- keine Bilder,
- keine SVG/PNG,
- keine Assets,
- keine Dateien unter `assets/`,
- keine YAML-/JSON-/YML-Aenderung,
- keine Runtime-Daten,
- keine finalen Koordinaten,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- kein Commit.

## 2. Produktregel fuer Italien

Der Italien-Prototyp nutzt eine echte Landform als Spielgrundlage:

- Die Aussenform basiert auf der echten Italien-Kontur.
- Die Form muss auch nach 2.5D- und Cozy-Abstraktion als Italien erkennbar
  bleiben.
- Festland, Sizilien und Sardinien sind als Bestandteile zu pruefen.
- Kleine Nebeninseln werden nur beruecksichtigt, wenn sie gameplayrelevant
  sind.
- Kueste, Wasserraeume, Engstellen, Gebirge, Ebenen und Inselnaehe duerfen als
  Strukturhinweise genutzt werden.
- Die Innenstruktur wird fuer Spielbarkeit, Lesbarkeit und Bauprogression
  abstrahiert.

Nicht erlaubt:

- keine fremden Bilder kopieren,
- keine Karten- oder Luftbildvorlage nachzeichnen, solange Quelle und Lizenz
  nicht geklaert sind,
- keine 1:1-geografische Pflichtkarte,
- keine politischen, administrativen oder realweltlichen Detailkarten als
  Spielziel,
- keine festen Kategorien wie `home`, `market` oder `library` auf sichtbaren
  Bauflaechen.

Eine zulaessige Vektorquelle und Lizenz muessen spaeter in einem eigenen
Source-of-Truth-Slice festgelegt werden, bevor daraus ein Blockout, ein
Dokumentationsvisual, eine Greybox oder ein Spielrender entstehen darf.

## 3. Professionelle Produktionsreihenfolge

Die naechsten Slices sollen mit sprechenden Namen gefuehrt werden. Technische
IDs duerfen intern ergaenzt werden, sind aber nicht der user-facing Name.

### 1. Italien-Kontur als Source of Truth festlegen

Ziel:

- Eine rechtlich und fachlich saubere Konturquelle fuer Italien bestimmen.
- Festlegen, ob Festland, Sizilien und Sardinien im ersten Prototyp enthalten
  sind.
- Klaeren, welche Vereinfachung der Aussenform erlaubt ist.

Erwartetes Ergebnis:

- Markdown-Source-of-Truth-Gate mit erlaubter Quelle, Lizenznotiz,
  Vereinfachungsregeln und klarer Grenze gegen Kopieren fremder Bilder.

Pflichtregeln:

- 403 zuerst anwenden: Land/Karte muss spaeter fullscreen/near-fullscreen
  Spielfeld werden, nicht Tool-Ansicht.
- 367 anwenden: 2.5D-Cozy-Diorama, keine realistische Editor-Karte.
- 384/385 anwenden: Sichtbares Bild ist nicht technische Spielkarte.

Stop-Regeln:

- Keine ungeklaerte Bild-, Karten- oder Vektorquelle.
- Keine Kopie fremder Bilder.
- Keine finale Kunst.
- Keine Runtime-Daten.

Erlaubt:

- Dokumentation.

Nicht erlaubt:

- Code, Assets, Bilder, SVG/PNG, Runtime-Daten.

### 2. Italien-Erkennungsmerkmale und Gameplay-Abstraktion

Ziel:

- Festlegen, welche Merkmale Italien erkennbar machen muessen.
- Definieren, welche geografischen Details fuer Spielbarkeit abstrahiert
  werden duerfen.

Erwartetes Ergebnis:

- Regelset fuer erkennbare Stiefelkontur, Inselbezug, Kueste, Nord-/Mittel-/
  Suedraum, Gebirge/Ebenen und spielbare Reduktion.

Pflichtregeln:

- Wiedererkennbarkeit schuetzen.
- Keine 1:1-Geografie erzwingen.
- Keine politischen Detailkarten als Spielziel.
- Spielgefuehl vor Atlasgenauigkeit.

Stop-Regeln:

- Wenn die Form nicht mehr als Italien lesbar ist, blockiert.
- Wenn die Karte wie Unterrichtsatlas, Worksheet oder Admin-Tool wirkt,
  blockiert.

Erlaubt:

- Dokumentation und abstrakte Strukturentscheidung.

Nicht erlaubt:

- Code, Assets, Bilder, SVG/PNG, Runtime-Daten.

### 3. Italien-Makro-Landschaftsarchitektur

Ziel:

- Die grossen Spielraeume innerhalb der Italien-Kontur definieren.
- Landschaftslogik fuer Bau, Wege, Entdeckung und spaetere Visit/Wander-
  Lesbarkeit vorbereiten.

Erwartetes Ergebnis:

- Makro-Plan fuer Wasser/Kueste, Nordraum, zentralen Hub-/Startbereich,
  Suedraum, Inselraeume, Vegetation, Hoehen, Felsen/Gebirge und Reserve.

Pflichtregeln:

- Land/Karte dominiert den Screen.
- Vegetation, Felsen, Hoehenbereiche und natuerliche Blocker logisch planen.
- Landmark-/Anchor-Punkte vorbereiten.
- Keine technische Debug-Optik als Zielbild.

Stop-Regeln:

- Zufallige Vegetation.
- Hoehen/Felsen ohne raeumliche Funktion.
- Wasser/Kueste nur als Dekoration.
- Grosse UI-Erklaerung statt Weltlesbarkeit.

Erlaubt:

- Dokumentation.

Nicht erlaubt:

- Code, Assets, Bilder, SVG/PNG, Runtime-Daten.

### 4. Italien-Bauflaechen- und Wegenetz-Plan

Ziel:

- 11-14 bebaubare Grundflaechen als organische Spielraeume planen.
- Ca. 6 sofort plausible Bauflaechen und weitere Reservebereiche vorbereiten.
- Wege zu allen Bauflaechen logisch denken.

Erwartetes Ergebnis:

- Planungsdokument fuer freie, neutrale Bauflaechen, Hauptwege, Nebenwege,
  Kuesten-/Inseluebergaenge, Bruecken/Faehren/Passagen nur wenn raeumlich
  sinnvoll, und Build-Station-am-Slot als spaeteres Pattern.

Pflichtregeln:

- Slots bleiben neutral.
- Kategorien bleiben frei waehlbar.
- Wege duerfen nicht nur Dekoration sein.
- Bauflaechen duerfen nicht isoliert schweben.

Stop-Regeln:

- Weniger als 11 bebaubare Grundflaechen.
- Aufgeklebte Kreise als Bauflaechen.
- Sichtbare harte Kategorien wie `home`, `market` oder `library`.
- Wege fuehren nicht zu allen Bauflaechen.

Erlaubt:

- Dokumentation.

Nicht erlaubt:

- Code, Assets, Bilder, SVG/PNG, Runtime-Daten.

### 5. Italien-Technische Layer/Masks-Plan

Ziel:

- Die Uferwald-Layer-Regeln auf den Italien-Prototyp uebertragen.
- Vor jedem Rendering technische Layer, Masks, Zonen und Anchor-Rollen
  planen.

Erwartetes Ergebnis:

- Markdown-Spec fuer mindestens:
  `italy_shape`, `water_coast_layer`, `grass_land_layer`,
  `forest_grove_layer`, `rock_mountain_layer`, `path_network_layer`,
  `bridge_or_crossing_layer`, `buildable_ground_layer`,
  `reserved_ground_layer`, `no_walk_layer`, `no_build_layer`,
  `anchor_landmark_layer` und optionale `sort_depth_bands`.

Pflichtregeln:

- Sichtbares Art-Bild ist nicht technische Spielkarte.
- Technische Layer zuerst, sichtbares Rendering danach.
- No-Walk und No-Build getrennt planen.
- Pixelableitung bleibt verboten.

Stop-Regeln:

- Runtime-Mapdaten vor Layer-/Masken-Gate.
- Pfade, Kollision oder Bauzonen aus einem Bild erraten.
- YAML/JSON ohne eigenes Format- und Datei-Gate.

Erlaubt:

- Dokumentation.

Nicht erlaubt:

- Code, Assets, Bilder, SVG/PNG, YAML/JSON/YML-Dateien, Runtime-Daten.

### 6. Italien-Fullscreen-Greybox-Preview

Ziel:

- Eine fullscreen oder near-fullscreen Greybox zeigen, die die Italien-Form
  als spielbares Feld pruefbar macht.

Erwartetes Ergebnis:

- Isolierte Preview oder Dokumentationsvisual erst nach eigener Freigabe:
  Aussenform, Wasser, Bauflaechen, Wege, Landmarken, No-Walk/No-Build und HUD
  muessen spielnah lesbar sein.

Pflichtregeln:

- Land/Karte ist Hauptflaeche des Screens.
- Keine grosse Header-/Dashboard-/Listenansicht.
- Keine technischen Layernamen im spielnahen Bild.
- 11-14 Bauflaechen und Wege zu allen Bauflaechen sichtbar.

Stop-Regeln:

- Debug-Tool-Optik.
- UI nimmt mehr Raum als Land/Karte ein.
- Bauflaechen wirken wie aufgeklebte Kreise.
- Keine Wege oder keine plausible Wasser-/Kuestenfunktion.

Erlaubt:

- Nur mit eigenem Folge-Slice: isolierte Preview oder Dokumentationsvisual.

Nicht erlaubt in diesem aktuellen Slice:

- Code, Bilder, Assets, Runtime-Daten.

### 7. Italien-Game-Look-Preview

Ziel:

- Aus freigegebener Kontur, Blockout und technischen Layern eine erste
  spielnahe 2.5D-Cozy-Look-Preview vorbereiten.

Erwartetes Ergebnis:

- Spaetere Review-Preview mit warmem Talvori-Stil, klarer Form,
  spielbaren Bauflaechen, kleinen HUD-Overlays und Weltobjekt-Fokus.

Pflichtregeln:

- 367 Art Bible.
- 365 Modern Game Direction.
- 403 Fullscreen-Spielgefuehl.
- Keine finale Kunst ohne Source-of-Truth, Blockout und Playability-Pruefung.

Stop-Regeln:

- High-Fidelity-Bild ohne technische Grundlage.
- App-Screen als Zielbild.
- Asset-Status oder Engine-ready-Status ohne eigenes Gate.

Erlaubt:

- Nur nach eigenem Visual- oder Art-Gate.

Nicht erlaubt in diesem aktuellen Slice:

- Bilder, Assets, Code, Runtime-Daten.

### 8. Italien-Slot-Interaktion-Prototyp

Ziel:

- Nach Greybox- und Layout-Freigabe eine erste lokale Interaktion an
  Bauflaechen pruefen.

Erwartetes Ergebnis:

- Spaeterer isolierter Prototyp: Tap am Slot, kleine Build-Station-Andeutung,
  freie Kategorieentscheidung, keine Speicherung.

Pflichtregeln:

- Aktionen gehoeren ins Spielfeld.
- BuildChoice wird am Slot / an der Build Station gedacht.
- Keine Route, keine App-Integration, keine Persistenz, kein BuildState ohne
  eigenes Gate.

Stop-Regeln:

- Runtime-Implementierung vor Greybox- und Layout-Freigabe.
- Listen- oder Tabelleninteraktion als Hauptflow.
- Persistenz, SRS, Supabase oder Produkt-Routes ohne eigenes Gate.

Erlaubt:

- Nur mit eigenem Implementierungs-Slice und enger Dateigrenze.

Nicht erlaubt in diesem aktuellen Slice:

- Code, App-Integration, Persistenz, Runtime-Daten.

## 4. Namensregel

Technische Slice-IDs duerfen intern genutzt werden. Fuer Andreas muessen
kommende Slices aber immer mit sprechendem Namen gefuehrt werden.

Richtig:

```text
Italien-Kontur als Spielgrundform festlegen (M16-DW)
```

Nicht ausreichend:

```text
M16-DW
```

Jeder Folge-Slice soll zuerst sagen, was fachlich entschieden oder gebaut
wird. Die technische ID ist nur eine kurze Referenz.

## 5. Uebertragung der Uferwald-Regeln

Die bisherigen Uferwald-Regeln bleiben relevant, aber sie werden nicht als
Name, Bildziel oder freie Inselkontur uebernommen.

Uebertragen werden:

- echte oder feste Aussenform als fuehrende Struktur,
- fullscreen/near-fullscreen Spielfeldgefuehl,
- Land/Karte dominiert den Screen,
- keine Debug-, Tool-, Tabellen-, Kartenlisten- oder Dashboard-Optik,
- 11-14 bebaubare Grundflaechen,
- ca. 6 sofort plausible Bauflaechen,
- Wege zu allen Bauflaechen,
- Wasser/Kueste/Bruecken/Uebergaenge, wenn raeumlich sinnvoll,
- Vegetation, Felsen, Hoehenbereiche und natuerliche Blocker,
- No-Walk/No-Build logisch planen,
- Landmark-/Anchor-Punkte,
- technische Layer erst planen, dann rendern,
- Spielgefuehl vor Debug-Ansicht.

Nicht uebertragen wird:

- der Name Uferwald fuer den neuen Prototyp,
- die frei erfundene Uferwald-Inselgrundform,
- vorhandene Uferwald-Bilder als Kontur- oder Zielbild,
- Uferwald-YAML-Strukturen als Italien-Runtime-Daten.

## 6. Stop-Regeln

Ein kommender Italien-/World-/Map-/Build-Slice ist nicht commitfaehig, wenn:

- die Ansicht eine Debug-Tool-Optik als Zielbild hat,
- eine grosse Header-, Dashboard-, Listen- oder Tabellenansicht der
  Hauptscreen ist,
- die Landform nicht fullscreen oder near-fullscreen als Spielfeld gedacht
  wird,
- Bauflaechen als aufgeklebte Kreise wirken,
- sichtbare harte Kategorien wie `home`, `market` oder `library` vorgegeben
  werden,
- weniger als 11 bebaubare Grundflaechen geplant sind,
- Wege nicht zu allen Bauflaechen fuehren,
- Wasser/Kueste/Bruecken/Uebergaenge raeumlich ignoriert werden,
- Runtime-Implementierung vor Greybox- und Layout-Freigabe entsteht,
- finale Kunst vor Source-of-Truth, Blockout und Playability-Pruefung
  entsteht,
- aus Bildern Pfade, Kollision, Walkability, Buildability oder No-Walk/
  No-Build geraten werden,
- ein Commit ohne ausdrueckliche Freigabe vorbereitet wird.

## 7. Naechster empfohlener Slice

Naechster Slice nach diesem Dokument:

```text
Italien-Kontur als Source of Truth festlegen
```

Dieser Slice soll zuerst Quelle, Lizenz, erlaubte Vereinfachung, enthaltene
Landbestandteile und Stop-Regeln klaeren. Er soll noch keine finale Kunst,
keine App-Integration, keine Runtime-Daten und keine Produkt-Route erzeugen.
