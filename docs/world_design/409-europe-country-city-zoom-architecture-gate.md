# 409: Europe Country City Zoom Architecture Gate

Stand: 2026-06-12

Status: `docs_only` / `architecture_gate` / `documentation_only` /
`not_asset` / `not_runtime_data` / `not_engine_ready` / `no_yaml_json`

## 1. Zweck

Dieses Gate verallgemeinert die aktuelle Italien-Richtung zu einer
uebertragbaren Europa-Land-/Stadt-Zoom-Architektur. Italien bleibt der erste
konkrete Prototyp, aber die technische und produktionelle Grundlogik darf nicht
nur fuer Italien funktionieren.

Zielarchitektur:

```text
Europa-Overview
-> Land auswaehlen
-> Landkarte
-> Stadtanker
-> Stadtgrundform / Stadtbereich
-> Bauflaechen / Wege / Gebaeude / Lernorte
```

409 erzeugt keine neue Kontur, keine Stadtpunkte, keine Stadtgrenzen, keine
Runtime-Daten, keine YAML-/JSON-Datei, keine Assets und keinen Code. Es legt
fest, welche generische Architektur fuer weitere europaeische Laender
anzuwenden ist und welche Source-/Lizenz-/Stop-Regeln vor jeder konkreten
Ableitung gelten.

## 2. Reuse-before-build Check

| Grundlage / Tool | Geeignet fuer | Lizenz-/Risiko-Notiz | Entscheidung |
| --- | --- | --- | --- |
| Natural Earth Admin 0 - Countries | `country_shape_source` fuer Laenderkonturen und Europa-Overview | Natural Earth ist laut 405 bevorzugt, weil offene Vektorquelle/Public Domain; konkrete Version und Downloadpfad muessen je Visual dokumentiert werden. | Geeignet als Standardkandidat fuer Laenderkonturen. |
| Natural Earth Populated Places | `city_anchor_source` fuer erste Stadtanker | Natural Earth Populated Places wurde fuer den korrigierten Italien-Blockout bereits als offene Stadtpunktquelle genutzt; fuer Review gut, aber nicht automatisch Runtime-Daten. | Geeignet als erster Stadtanker-Kandidat. |
| ISTAT Comuni | `city_footprint_source` fuer Italien-Stadtgrundformen | Amtliche/open-data Quelle fuer italienische Gemeindegrenzen; genaue Datensatzversion, Lizenz, Attribution, Felder und Vereinfachungsgrenzen muessen im naechsten Slice geprueft werden. | Kandidat fuer Italien, noch nicht uebernommen. |
| Laenderspezifische amtliche/open-data Quellen | Stadt-/Gemeindegrenzen fuer weitere Laender | Deutschland, Frankreich, Spanien, Oesterreich usw. brauchen je eigenes Quellen-, Lizenz-, Attribution- und Nutzbarkeitsgate. | Erforderlich pro neuem Land. |
| OpenStreetMap | alternative Grenzen, Orte, POIs | ODbL-/Attributions-/Share-Alike-Risiko; darf nicht still als Datenquelle uebernommen werden. | Nur Kandidat mit eigenem Lizenzgate. |
| OpenMapTiles / MapTiler / free-map.org | Toolchains, Styles, Vektor-/Tile-Kandidaten | Nicht als Quelle ungeprueft uebernehmen; Tiles, Screenshots und Kartenbilder duerfen nicht abgezeichnet werden. Kommerzielle/technische Nutzungsbedingungen muessen vorab geklaert werden. | Nur Tool-/Kandidat, keine Uebernahme in 409. |

Verboten bleiben Google Maps, Apple Maps, Pinterest, Screenshots,
Kartenkacheln, Atlasbilder, Luftbilder und fremde Kartenbilder als
Nachzeichnungs- oder Konturgrundlage.

Quellenstatus fuer dieses Gate:

- Natural Earth Terms of Use: Natural-Earth-Raster- und Vektordaten auf der
  offiziellen Website sind Public Domain; Attribution ist nicht erforderlich,
  aber ein kurzer Quellenhinweis bleibt fuer Talvori-Dokumentation sinnvoll.
  Referenz: `https://www.naturalearthdata.com/about/terms-of-use/`
- Natural Earth Admin 0 - Countries: geeigneter Laenderkontur-Kandidat;
  offizieller Download ist aktuell als Version 5.1.1 dokumentiert.
  Referenz:
  `https://www.naturalearthdata.com/downloads/10m-cultural-vectors/10m-admin-0-countries/`
- Natural Earth Populated Places: geeigneter Stadtanker-Kandidat; offizieller
  Download ist aktuell als Version 5.1.2 dokumentiert. Referenz:
  `https://www.naturalearthdata.com/downloads/10m-cultural-vectors/10m-populated-places/`
- OpenStreetMap: offene Daten unter ODbL mit Attributionspflicht und
  Share-Alike-Regeln bei abgeleiteten/adaptierten Daten; deshalb nur Kandidat
  mit eigenem Lizenzgate. Referenz:
  `https://www.openstreetmap.org/copyright`
- OpenMapTiles: offene Map-/Tile-Schema-Toolchain auf Basis von OSM, Natural
  Earth und weiteren OpenData-Quellen; Attribution und Tool-/Datenmodell-
  Grenzen muessen vor Uebernahme separat geprueft werden. Referenz:
  `https://openmaptiles.org/`
- MapTiler: Anbieter fuer Map-APIs, SDKs, Hosting, Geodatenverarbeitung und
  Styles; wegen Nutzungsbedingungen, kommerziellem Kontext und API-/Hosting-
  Rolle nur Tool-/Dienst-Kandidat, keine Source-of-Truth in 409. Referenz:
  `https://www.maptiler.com/`

## 3. Zielarchitektur

### Europa-Overview

Die Europa-Overview zeigt spaeter die spielbare Weltregion als Auswahlraum.
Sie ist kein politischer Atlas und kein GIS-Tool. Sie dient dazu, Laender als
spielbare Profile anzusteuern.

Erwartung:

- Europa ist `world_region`.
- Laender sind auswaehlbare `country_profile`-Einheiten.
- Die Darstellung bleibt spielartig und fullscreen/near-fullscreen, nicht
  Dashboard oder Kartenliste.

### Land Auswaehlen

Die Land-Auswahl fuehrt von der Europa-Overview in ein konkretes Landprofil.
Italien ist das erste Profil, aber die Logik muss fuer weitere Laender
funktionieren.

Erwartung:

- Jedes Land braucht eine eigene Quellenentscheidung.
- Jedes Land braucht eine eigene Abstraktionsentscheidung.
- Kein Land darf durch den Italien-Prototyp technisch hart verdrahtet werden.

### Landkarte

Die Landkarte nutzt eine echte Laenderkontur als Source-of-Truth-Kandidat,
vereinfacht sie aber fuer mobile Lesbarkeit, 2.5D-Diorama-Gefuehl und
Spielbarkeit.

Erwartung:

- Aussenform aus gepruefter Quelle.
- Innenstruktur bleibt Talvori-gerecht.
- Keine 1:1-Geografie als Spielziel.

### Stadtanker

Stadtanker sind Orientierungspunkte fuer Wege, Makro-Blockout,
Lernorte, Bauzonen und spaetere Stadtbereiche. Sie sind keine finalen
Runtime-Koordinaten.

Erwartung:

- Natural Earth Populated Places ist ein guter erster Kandidat.
- Stadtanker bleiben `documentation_only`, bis ein Runtime-Gate sie explizit
  oeffnet.
- Stadtanker duerfen Spielrollen bekommen, aber keine harte Kategoriebindung.

### Stadtgrundform / Stadtbereich

Stadtgrundformen sind spaetere Kandidaten fuer `playable_city_area`. Sie
koennen aus amtlichen/open-data Gemeinde- oder Stadtgrenzen inspiriert werden,
muessen aber spielgerecht abstrahiert werden.

Erwartung:

- Italien prueft als erstes ISTAT Comuni.
- Andere Laender brauchen eigene amtliche/open-data Kandidaten.
- Stadtformen sind keine automatisch begehbaren Runtime-Polygone.

### Bauflaechen / Wege / Gebaeude / Lernorte

Bauflaechen, Wege, Gebaeude und Lernorte werden aus der spielbaren Struktur
entwickelt, nicht blind aus echter Geografie kopiert.

Erwartung:

- 11-14 organische Bauflaechen bleiben Zielgroesse fuer spielnahe
  Land-/Stadt-Previews, sofern der konkrete Land-/Stadt-Slice sie oeffnet.
- Ca. 6 Flaechen duerfen als sofort plausible Startkapazitaet wirken.
- Wege fuehren logisch zu allen relevanten Bauflaechen.
- Lernorte entstehen aus Spiel- und Sprachkontext, nicht aus Atlasdaten.

## 4. Italien als erster konkreter Prototyp

| Feld | Italien-Prototyp |
| --- | --- |
| `country` | `Italy` |
| `country_shape_source` | Natural Earth Admin 0 - Countries, dokumentiert in 405/406 |
| `city_anchor_source` | Natural Earth Populated Places, dokumentiert in 408 und im korrigierten 407-Blockout |
| `city_footprint_source` | ISTAT Comuni als Kandidat fuer den naechsten Slice |
| `prototype_paths` | Italien darf `italy_*`-Dokumente und Previewpfade behalten. |
| `scope_boundary` | Italien ist Prototyp, keine Sonderarchitektur. |

Italien darf weiterhin mit italienischen Dateinamen, Previewpfaden und
Prototyp-Slices arbeiten. Die darunterliegende Architektur muss aber
country-agnostic bleiben: dieselben Begriffe, Statuswerte, Stop-Regeln und
Quelle-vor-Rendering-Regeln muessen fuer Deutschland, Frankreich, Spanien,
Oesterreich und weitere Laender tragfaehig sein.

## 5. Generische Begriffe

| Begriff | Definition | Nicht daraus ableiten |
| --- | --- | --- |
| `world_region` | Grober Weltbereich, z. B. Europa. | Keine Runtime-Karte, keine politische Simulation. |
| `country_profile` | Spielbares Landprofil mit Name, Status, Quellenstand und Folge-Gates. | Keine App-Route, kein Save-State. |
| `country_shape_source` | Gepruefte Quelle fuer die Aussenkontur eines Landes. | Keine finalen Runtime-Polygone. |
| `city_anchor_source` | Gepruefte Quelle fuer Stadtanker. | Keine finalen Stadtkoordinaten fuer Runtime. |
| `city_footprint_source` | Kandidat fuer Stadt-/Gemeindegrenzen oder Stadtbereiche. | Keine automatische Collision-, Bau- oder Laufgeometrie. |
| `playable_city_area` | Gameplaygerecht abstrahierter Stadt-/Gebietsraum. | Kein 1:1-GIS-Polygon. |
| `buildable_ground` | Organische, spielbare Bau-Eignungsflaeche. | Keine fest verdrahtete Kategorie oder finaler Slot. |
| `reserved_ground` | Sichtbare oder geplante Reserve fuer spaeteren Ausbau. | Keine sofortige Baupflicht. |
| `no_walk` | Bereich, der fuer Bewegung gesperrt oder nur dekorativ ist. | Keine Pixelableitung ohne Layer-/Mask-Gate. |
| `no_build` | Bereich, der fuer Bauen gesperrt oder geschuetzt ist. | Keine Vermischung mit `no_walk`. |
| `landmark_anchor` | Orientierungspunkt fuer Land, Stadt, Lernort oder Objektfokus. | Kein Runtime-Anker ohne eigenes Review-Gate. |

## 6. Architekturentscheidungen

- Keine reine Italien-Sonderarchitektur: Italien ist der erste Prototyp, nicht
  die einzige Zielstruktur.
- Italien darf Prototypnamen und Previewpfade behalten, solange die
  generischen Begriffe und Stop-Regeln sichtbar bleiben.
- Natural Earth Admin 0 ist der Standardkandidat fuer Laenderkonturen.
- Natural Earth Populated Places ist der erste Kandidat fuer Stadtanker.
- Stadt-/Gemeindegrenzen muessen laenderspezifisch geprueft werden.
- Reale Grenzen und Stadtformen sind Source-of-Truth-Kandidaten, aber
  Spielbereiche bleiben Talvori-gerecht abstrahiert.
- Kein realer Datensatz wird automatisch Runtime-Daten.
- Keine Kartenbilder, Screenshots, Tiles oder Atlasbilder werden kopiert oder
  nachgezeichnet.

## 7. Erweiterbarkeit: Neues Land hinzufuegen

Ein neues europaeisches Land darf erst nach dieser Reihenfolge in die
Produktion:

1. `country_profile` anlegen oder dokumentieren: Name, Region, Status,
   Quelle offen.
2. `country_shape_source` pruefen: offene Vektorquelle, Lizenz,
   Attribution, Version, Downloadpfad, Vereinfachungsgrenzen.
3. `city_anchor_source` pruefen: offene Stadtpunktquelle, Lizenz,
   Vollstaendigkeit, Nutzbarkeit fuer Review.
4. `city_footprint_source` pruefen: amtliche/open-data Stadt- oder
   Gemeindegrenzen, Lizenz, Aktualitaet, Felder, Vereinfachbarkeit.
5. Landkontur als Dokumentationsvisual ableiten, noch nicht Runtime.
6. Stadtanker als Dokumentationsvisual pruefen, noch nicht Runtime.
7. Stadtgrundformen oder `playable_city_area` als Planungsvisual pruefen,
   noch nicht Runtime.
8. Blockout/Greybox mit Wegen, Wasser, Bauflaechen und Lernorten erzeugen.
9. Technische Layer/Masks planen.
10. Erst danach duerfen enge Runtime-, App- oder Interaktions-Gates
    vorbereitet werden.

## 8. Stop-Regeln

Ein kommender Europa-/Land-/Stadt-/World-/Map-/Build-Slice ist nicht
commitfaehig, wenn:

- er eine Italien-Sonderarchitektur baut, die nicht auf weitere Laender
  uebertragbar ist,
- Quelle, Lizenz, Attribution oder Version der verwendeten Kontur- oder
  Stadtquelle unklar sind,
- OSM, OpenMapTiles, MapTiler, free-map.org oder andere Tool-/Datenkandidaten
  ohne eigenes Lizenz-/Nutzungs-Gate uebernommen werden,
- Kartenbilder, Screenshots, Tiles, Google Maps, Apple Maps, Pinterest,
  Atlasbilder oder Luftbilder kopiert oder nachgezeichnet werden,
- Laender- oder Stadtformen direkt als Runtime-Koordinaten, Polygone,
  YAML/JSON oder App-Daten entstehen,
- Stadtanker als finale Runtime-Koordinaten gelesen werden,
- `no_walk` und `no_build` vermischt werden,
- die Darstellung wie GIS, Unterrichtsatlas, Debug-Tool, Dashboard oder
  Tabellenansicht wirkt,
- Dateien unter `assets/` entstehen,
- App-Code, Flutter-Routes, Persistenz, Supabase-/DB-Writes oder BuildState
  beruehrt werden,
- finale Kunstproduktion vor Source-of-Truth, Blockout/Greybox und
  Playability-Pruefung gestartet wird.

## 9. Naechster empfohlener Slice

Naechster Slice:

```text
Italien-Stadtgrundformen aus ISTAT-Comuni pruefen/ableiten
```

Dieser Folge-Slice soll die ISTAT-Comuni-Quelle fuer Italien fachlich und
rechtlich pruefen, aber erst dann konkrete Stadtgrundformen ableiten, wenn
Datensatz, Lizenz, Attribution, Vereinfachungsgrenzen und Dokumentationspfad
klar freigegeben sind.
