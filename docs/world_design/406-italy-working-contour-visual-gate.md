# 406: Italy Working Contour Visual Gate

Stand: 2026-06-12

Status: `documentation_visual / no runtime data / no asset`

## 1. Zweck

Dieses Gate erzeugt die erste sichtbare Arbeitsgrundflaeche fuer den Italien-
Prototyp. Es setzt die Source-of-Truth-Regel aus `405` praktisch um:
Natural Earth liefert die echte Italien-Aussenkontur, daraus entsteht aber
noch keine Runtime-Geometrie, kein Asset, keine finale Kunst und keine App-
Integration.

Das Ergebnis ist ein Dokumentationsvisual fuer die naechste Planung von Wegen,
Wasser, Bauflaechen, Blockout und technischen Layern.

## 2. Quelle und Lizenznotiz

- source_dataset: Natural Earth Admin 0 - Countries
- source_version: 5.1.1
- source_download_url: `https://naciscdn.org/naturalearth/10m/cultural/ne_10m_admin_0_countries.zip`
- source_feature: Italy (`ISO_A3=ITA` / `ADMIN=Italy`)
- license_notes: Natural Earth vector data is public domain.
- attribution_note: Made with Natural Earth.

Nicht verwendet wurden Google Maps, Apple Maps, Pinterest, Screenshots,
Atlasbilder, Kartenkacheln, Luftbilder oder Pixeltracing.

## 3. Erzeugte Dateien

Alle Dateien liegen ausschliesslich unter:

```text
docs/world_design/previews/italy_shape_working_contour/
```

Erzeugt wurden:

- `italy_shape_working_contour.svg`
- `italy_shape_working_contour.png`
- `italy_shape_working_contour_metadata.md`

Maximalstatus:

- `documentation_only`
- `not_asset`
- `not_runtime_data`
- `not_engine_ready`

## 4. Enthaltene Bestandteile

- Festland Italien: enthalten als fuehrende, erkennbare Stiefel-Form.
- Sizilien: enthalten, weil stark wiedererkennbar und fuer spaetere
  Gameplay-Abstraktion wertvoll.
- Sardinien: enthalten, weil es die Italien-Lesbarkeit staerkt und als
  spaeterer Insel-/Reserve-/Reisebezug nuetzlich werden kann.
- Kleine Nebeninseln: fuer diese erste mobile Arbeitskontur weggelassen oder
  durch Vereinfachung absorbiert, damit die Form nicht kleinteilig wirkt.

## 5. Vereinfachung

Die Natural-Earth-Geometrie wurde auf die drei groessten Italien-Polygonteile
reduziert und per Ramer-Douglas-Peucker fuer ein Dokumentationsvisual
vereinfacht.

Ziel der Vereinfachung:

- Stiefel-Form bleibt auf einen Blick lesbar.
- Sizilien und Sardinien bleiben klar getrennt und erkennbar.
- Kuestenrauschen wird reduziert, damit die Form spaeter als mobile
  Spielfeldgrundform vorstellbar bleibt.
- Das Visual wirkt nicht wie GIS-Tool, Unterrichtsatlas oder Debug-Board.

Diese Vereinfachung ist keine finale Gameplay-Geometrie und kein produktiver
Polygonstand.

## 6. Eignung fuer Mobile, 2.5D und Spielbarkeit

Die Arbeitskontur ist fuer den naechsten Schritt geeignet, weil:

- die Landform das Bild dominiert,
- die Aussenform klar als Italien lesbar ist,
- die grossen Bestandteile genug Flaeche fuer spaetere Makro-Zonen,
  Wege, Wasser-/Kuestenbezug, Bauflaechen und Blockout lassen,
- die Detailmenge niedrig genug bleibt, um spaeter fullscreen oder
  near-fullscreen spielnah zu funktionieren,
- die Form noch offen genug ist, um Innenstruktur gameplaygerecht statt
  atlasgetreu zu planen.

## 7. Keine Runtime-Geometrie

Dieses Gate erzeugt keine technische Spielkarte.

Nicht freigegeben:

- keine Runtime-Daten,
- keine finalen Koordinaten,
- keine produktiven Polygone,
- keine YAML-/JSON-/YML-Struktur,
- keine Assets,
- keine Dateien unter `assets/`,
- keine App-Integration,
- keine Route,
- keine Persistenz,
- kein BuildState,
- keine finale Kunst.

Die SVG-ViewBox-Koordinaten sind nur Zeichenkoordinaten des
Dokumentationsvisuals. Sie duerfen nicht als Runtime-Koordinaten, technische
Mapdaten oder finale Konturwerte gelesen werden.

## 8. QA-Entscheidung

| Pruefung | Ergebnis |
| --- | --- |
| Italien auf einen Blick erkennbar | JA |
| Stiefel-Form erhalten | JA |
| Sizilien lesbar | JA |
| Sardinien lesbar | JA |
| Visual ueberfuellt | NEIN |
| Labels abgeschnitten | NEIN |
| GIS-/Atlas-/Debug-Look | NEIN |
| Asset-/Engine-ready-Freigabe | NEIN |
| Runtime-Geometrie entstanden | NEIN |

## 9. Naechster Slice

Naechster empfohlener Slice:

```text
Italien-Makro-Blockout mit Wegen, Wasser und Bauflaechen
```

Dieser Folge-Slice darf die Arbeitskontur als visuelle Grundlage verwenden,
muss aber technische Layer/Masks, Build-Zonen, Wege, No-Walk/No-Build und
Anchor-/Landmark-Regeln weiterhin separat planen.
