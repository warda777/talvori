# 407: Italy Macro Blockout Paths, Water and Build Areas

Stand: 2026-06-12

Status: `documentation_visual / planning_blockout / not_asset / not_runtime_data / not_engine_ready`

## 1. Zweck

Dieses Gate uebersetzt die Italien-Arbeitskontur aus `406` in einen ersten
sichtbaren Makro-Blockout. Ziel ist ein pruefbares Spielfeld-Gefuehl fuer
Wege, Wasser/Kueste, Uebergaenge, organische Bauflaechen und grobe
No-Walk-/No-Build-Bereiche.

Der erste abstrakte 407-Stand wurde nach `408` zuerst manuell an Stadtankern
ausgerichtet, war aber fachlich noch zu ungenau. Dieser korrigierte Stand
nutzt echte Stadtpunkte aus Natural Earth Populated Places `5.1.2` als
Dokumentationsgrundlage fuer die sichtbaren Anker. Der Blockout bleibt trotzdem
ein Dokumentationsvisual, keine Stadtpunkt-Datei und keine Runtime-Geometrie.

Das Gate erzeugt keine technische Spielkarte, keine Runtime-Geometrie, keine
Assets und keinen Code.

## 2. Reuse-before-build Check

| Grundlage | Ergebnis | Entscheidung |
| --- | --- | --- |
| Natural-Earth-basierte 406-Arbeitskontur | geeignet | Wiederverwendet als visuelle Basis. |
| 408-Stadtanker-Plan | geeignet | Wiederverwendet als fachliche Stadtanker-Liste fuer diesen ueberarbeiteten Blockout. |
| Natural Earth Populated Places | geeignet und fuer die Korrektur genutzt | Version `5.1.2` wurde temporaer aus `https://naciscdn.org/naturalearth/10m/cultural/ne_10m_populated_places.zip` gelesen. Die Lon/Lat-Werte dienen nur der Dokumentationsplatzierung, nicht Runtime. |
| Flutter packages | nicht noetig | Kein Code-Scope in diesem Slice. |
| OpenGameArt / externe Assets | nicht geeignet fuer diesen Slice | Keine Assets, kein Lizenz-/Attributions-Import. |
| GitHub-/Figma-/Design-Resources | nicht noetig | Lokaler SVG/PIL-Blockout reicht fuer Review. |

Lizenzrisiko:

- Natural Earth bleibt per 405/406 die risikoarme Source-of-Truth.
- Natural Earth Populated Places wurde temporaer als offene Stadtpunktquelle
  genutzt, weil der manuelle Stadtanker-Blockout sichtbar falsche Positionen
  erzeugt hatte.
- Die Stadtkoordinaten wurden nicht als Datei ins Repo gelegt und nicht als
  Runtime-Werte freigegeben.
- OSM/ISTAT bleiben wegen Lizenz-/Attributionspruefung blockiert.
- Keine weiteren externen Assets, Code-Dateien oder Design-Dateien wurden
  uebernommen.
- Alle neuen Overlays sind lokale Dokumentationszeichnungen im Repo.

## 3. Erzeugte Dateien

Alle neuen Visuals liegen unter:

```text
docs/world_design/previews/italy_macro_blockout_paths_water_buildareas/
```

Erzeugt wurden:

- `italy_macro_blockout_paths_water_buildareas.svg`
- `italy_macro_blockout_paths_water_buildareas.png`
- `italy_macro_blockout_paths_water_buildareas_metadata.md`

## 4. Blockout-Inhalt

- Festland Italien: enthalten.
- Sizilien: enthalten.
- Sardinien: enthalten.
- Stadtanker: 13 sichtbar benannte italienische Anker auf Basis von Natural
  Earth Populated Places `5.1.2`.
- Sofort wichtige Stadtanker: 6 klar priorisierte Kernstaedte.
- Reserve-Stadtanker: 7 dezenter dargestellte Anker.
- Organische Bauflaechen: 13 sichtbare Bereiche, an Stadtankern ausgerichtet.
- Sofort plausibel: 6 Bereiche an Mailand, Venedig, Bologna, Florenz, Rom und
  Neapel.
- Reserve: 7 Bereiche an Genua, Pisa, Verona, Bari, Palermo, Catania und
  Cagliari.
- Wege: Haupt- und Nebenwege fuehren zu allen Stadt-/Bauflaechen.
- Wasser/Kueste: Meer, Kuestenpuffer, Lagunen-/Kuestenbezug und Meerenge sind
  sichtbar.
- Uebergaenge: Sardinien-Faehrweg und Sizilien-Uebergang sind als
  Planungsquerungen markiert, nicht als Runtime-Kanten.
- No-Walk/No-Build: Wald-/Hoehen-/Kuesten-/Hub-Schutzraeume sind grob und
  subtil sichtbar.

Nicht aufgenommen:

- Madrid, weil Madrid nicht in Italien liegt und nach `408` fuer diesen
  Prototyp blockiert ist.

Stadtlagen-Korrektur:

- Bari liegt jetzt klar am suedostlichen Adriaraum.
- Genua liegt an der nordwestlichen Kueste.
- Venedig liegt am nordoestlichen Adriaraum.
- Palermo und Catania liegen auf Sizilien.
- Cagliari liegt auf Sardinien.

## 5. Visual-QA

| Pruefung | Ergebnis |
| --- | --- |
| Landform dominiert das Bild | JA |
| Italien bleibt erkennbar | JA |
| Festland/Sizilien/Sardinien beruecksichtigt | JA |
| 11-14 Bauflaechen sichtbar | JA, 13 |
| 13 Stadtanker sichtbar benannt | JA |
| Stadtanker aus Natural Earth Populated Places gesetzt | JA, Version 5.1.2 |
| 6 sofort wichtige Staedte visuell priorisiert | JA |
| 7 Reserve-Staedte dezenter dargestellt | JA |
| ca. 6 sofort plausible Bauflaechen | JA, 6 an Kernstaedten |
| Wege zu allen Bauflaechen sichtbar | JA |
| Wege/Bauflaechen an Stadtlogik ausgerichtet | JA |
| Wasser/Kueste/Uebergaenge raeumlich sinnvoll | JA |
| No-Walk/No-Build grob sichtbar | JA |
| Madrid ausgeschlossen | JA |
| Bari/Genua/Venedig/Sizilien/Sardinien-Stadtlagen plausibel | JA |
| Debug-/Dashboard-/GIS-Look vermieden | JA |
| Labels abgeschnitten | NEIN |
| Asset-/Engine-ready-Freigabe | NEIN |
| Runtime-Geometrie entstanden | NEIN |

## 6. Grenzen

Nicht freigegeben:

- keine App-Code-Dateien,
- keine Flutter-/Dart-Dateien,
- keine Assets,
- keine Dateien unter `assets/`,
- keine Runtime-Daten,
- keine finalen Koordinaten,
- keine produktiven Polygone,
- keine YAML-/JSON-/YML-Strukturen,
- keine App-Integration,
- keine Route,
- keine Persistenz,
- kein BuildState,
- keine finale Kunst.

Die SVG-/PNG-Overlays sind reine Dokumentationszeichnungen. Sie duerfen nicht
als Runtime-Map, Collision, Pathfinding, Build-Zonen-Polygone oder finale
Gameplay-Geometrie gelesen werden.

Die Stadtanker nutzen echte Natural-Earth-Lon/Lat-Werte nur als Input fuer die
Dokumentationsplatzierung. Es entstehen keine finalen Koordinaten, keine
Stadtpunkt-Datei, keine Path-Nodes und keine produktiven Polygone.

## 7. Naechster Slice

Naechster empfohlener Slice:

```text
Italien technische Layer/Masks fuer stadtankerbasierten Makro-Blockout planen
```

Dieser Folge-Slice soll die sichtbaren Blockout-Entscheidungen in getrennte
Planungsfamilien ueberfuehren: `island_shape`, `water_river_layer`,
`path_network_layer`, `buildable_ground_layer`, `no_walk_layer`,
`no_build_layer`, `anchor_landmark_layer` und optionale Sort-/Depth-Bands.
