# 411: Italy Playable City Areas From Footprints

Stand: 2026-06-12

Status: `documentation_visual` / `playable_city_area_candidates` /
`not_asset` / `not_runtime_data` / `not_engine_ready` / `no_yaml_json` /
`no_app_integration`

## 1. Zweck

Dieses Gate leitet aus den echten ISTAT-Comuni-Stadtgrundformen erste
Talvori-gerechte `playable_city_area`-Kandidaten ab.

Wichtig: Die echten Stadt-/Gemeindegrenzen werden nicht 1:1 als Spielbereich
uebernommen. Sie dienen als Source-Footprints fuer Formgefuehl, Lage und
Massstab. Der eigentliche spielbare Stadtbereich bleibt abstrahiert und muss
spaeter fuer Wege, Build-Flows, Kamera und Lernorte separat geplant werden.

## 2. Reuse-Before-Build Check

| Grundlage / Tool | Ergebnis | Entscheidung |
| --- | --- | --- |
| `410` ISTAT-Comuni-Gate | geeignet | Wiederverwendet als saubere Footprint-Quelle. |
| `previews/italy_city_footprints_istat_comuni/` | geeignet | Dient als Source-Visual und Matching-Referenz. |
| `408` Stadtanker-Plan | geeignet | Fuehrt die 6 Kernstaedte und 7 Reserve-Staedte. |
| `409` Europa-Zoom-Architektur | geeignet | `playable_city_area` bleibt generische Stufe fuer weitere Laender. |
| `407` Makro-Blockout | teilweise geeignet | Richtung bleibt, aber Stadtbereiche werden nun footprint-basiert abstrahiert. |
| OSM / MapTiler / OpenMapTiles / free-map.org | nicht noetig | Nicht uebernommen; kein Tile-, Screenshot- oder Fremdasset-Import. |

Keine fremden Kartenbilder, Screenshots, Tiles, Google Maps, Apple Maps,
Pinterest, Luftbilder oder Atlasbilder wurden kopiert oder nachgezeichnet.

## 3. Erzeugte Dateien

Erlaubter Preview-Pfad:

```text
docs/world_design/previews/italy_playable_city_areas_from_footprints/
```

Erzeugt:

- `italy_playable_city_areas_from_footprints.svg`
- `italy_playable_city_areas_from_footprints.png`
- `italy_playable_city_areas_from_footprints_metadata.md`

Das Visual zeigt Italien als ruhigen Kontext, die echten ISTAT-Footprints als
dezente Quellenumrisse und darueber abstrahierte spielbare Stadtbereiche.

## 4. Ableitungsregel

Jede Stadt erhaelt vier Review-Bestandteile:

| Bestandteil | Bedeutung | Grenze |
| --- | --- | --- |
| Stadtkern | moeglicher dichter Start-/Lern-/Landmark-Bereich | kein finaler Bauplatz |
| Reserveflaeche | spaetere Erweiterung, Besucher- oder Objektfokus | keine Runtime-Zone |
| Rand / No-Build | Schutzraum gegen Rand, Wasser, Enge oder Ueberfrachtung | keine produktive No-Build-Maske |
| Start-Bauplatz | moeglicher erster Spieler-Ort | keine gespeicherte Position |

Die Formen sind bewusst organisch und vereinfacht. Sie sollen die spaetere
Greybox vorbereiten, aber keine echten Polygone, Koordinaten, Collision,
Pathfinding, Build-Zones oder App-Daten liefern.

## 5. Abgeleitete Stadtbereiche

| Stadt | Rolle | Playable-City-Area-Kandidat | Start-/Reserve-Idee |
| --- | --- | --- | --- |
| Milano | Kernstadt | kompakter Nord-Hub fuer Handel, Werkstatt und spaetere Stadtvernetzung | flacher Startplatz, starke Reserve fuer Ausbau |
| Venezia | Kernstadt | Wasserstadt-Kandidat mit Bruecken-/Uebergangslogik und vorsichtigem Randpuffer | kanalnaher Start, Reserve fuer Entdeckung |
| Bologna | Kernstadt | Wegekreuz, Lernnetzwerk und zentraler Verbindungspunkt | kompakter Start, klare Stadtkern-Reserve-Trennung |
| Firenze | Kernstadt | Kulturkern fuer Handwerk, Archiv und ruhige Lernorte | ruhiger Start, weicher Reservebereich |
| Roma | Kernstadt | Haupt-Hub mit grossem Stadtkern und hoher Landmark-Dichte | grosser Startplatz, zentrale Reserve |
| Napoli | Kernstadt | Kuestenkern und suedliches Energietor | Kuestenstart, Reserve Richtung Rand/Hoehe |
| Genova | Reserve | westlicher Hafenraum und schmalere Kuestenreserve | kleiner Start, vorsichtiger Randpuffer |
| Pisa | Reserve | Landmark- und Object-Focus-Stadt | kleiner Start, reduzierte Reserve |
| Verona | Reserve | nordoestlicher Kultur- und Besuchsraum | kleiner Start, dezente Reserve |
| Bari | Reserve | Adriatischer Suedost-Hafenraum | kleiner Start, klare Kuestenabgrenzung |
| Palermo | Reserve | Sizilien-West und moeglicher Insel-Hub | kleiner Start, Reserve fuer Insel-Erweiterung |
| Catania | Reserve | Sizilien-Ost mit Hoehen-/Vulkan-Inspiration | kleiner Start, Rand-/Hoehenschutz |
| Cagliari | Reserve | Sardinien-Hub und separater Inselbereich | kleiner Start, kompakte Reserve |

## 6. Kernstadt- und Reserve-Gewichtung

Staerker ausgearbeitet:

- Milano,
- Venezia,
- Bologna,
- Firenze,
- Roma,
- Napoli.

Diese sechs Kernstaedte erhalten im Visual groessere und kontrastreichere
Kandidaten, weil sie im ersten Italien-Greybox-Pfad wahrscheinlich die
wichtigsten Zoom- und Bauentscheidungen tragen.

Dezenter gehalten:

- Genova,
- Pisa,
- Verona,
- Bari,
- Palermo,
- Catania,
- Cagliari.

Diese sieben Reserve-Staedte bleiben sichtbar, aber ruhiger. Sie sollen den
Europa->Land->Stadt-Zoom vorbereiten, ohne den ersten spielbaren Fokus zu
ueberladen.

## 7. Visual-QA

| Pruefung | Ergebnis |
| --- | --- |
| Alle 13 Staedte enthalten | JA |
| Kernstaedte visuell priorisiert | JA |
| Reserve-Staedte sichtbar, aber dezenter | JA |
| Jede Stadt zeigt Stadtkern, Reserve, Rand/No-Build und Startmarker | JA |
| Echte ISTAT-Footprints nur als dezente Quellenumrisse | JA |
| Italien-Kontext sichtbar | JA |
| Labels lesbar | JA |
| Labels abgeschnitten | NEIN |
| GIS-/Atlas-/Dashboard-Look vermieden | JA |
| Statusschutz `documentation_only`, `not_asset`, `not_runtime_data`, `not_engine_ready` sichtbar | JA |

## 8. Nicht-Freigaben

Nicht freigegeben:

- keine Runtime-Daten,
- keine finalen Koordinaten,
- keine produktiven Polygone,
- keine Path-Centerlines,
- keine Path-Nodes,
- keine Collision,
- keine Build-Zones,
- keine echten No-Walk-/No-Build-Masken,
- keine YAML-/JSON-/YML-Dateien,
- keine Assets,
- keine Dateien unter `assets/`,
- keine App-Code-Dateien,
- keine App-Integration,
- keine Route,
- keine Persistenz,
- kein BuildState.

Die echten Stadtgrenzen aus ISTAT bleiben Source-Footprints. Die gezeichneten
spielbaren Stadtbereiche bleiben Review-Kandidaten und duerfen nicht als
Runtime-Geometrie oder finaler Stadtplan gelesen werden.

## 9. Entscheidung

| Frage | Entscheidung |
| --- | --- |
| Wurden fuer alle 13 Staedte spielbare Stadtbereichs-Kandidaten abgeleitet? | JA |
| Bleiben echte ISTAT-Comuni-Grenzen von Gameplay-Geometrie getrennt? | JA |
| Sind Kernstaedte staerker ausgearbeitet? | JA |
| Sind Reserve-Staedte dezenter dokumentiert? | JA |
| Entstanden Runtime-Daten, YAML/JSON, Assets oder App-Code? | NEIN |

## 10. Naechster Slice

Naechster empfohlener Slice:

```text
Italien spielbare Stadtbereiche Review und Stadt-Blockout-Entscheidung
```

Dieser Folge-Slice soll pruefen, ob die 13 Kandidaten fuer einen ersten
Stadt-Greybox-Plan ausreichen oder ob einzelne Staedte vor Wegen, Baupunkten,
Bruecken, Wasser- und No-Build-Logik noch anders abstrahiert werden muessen.
