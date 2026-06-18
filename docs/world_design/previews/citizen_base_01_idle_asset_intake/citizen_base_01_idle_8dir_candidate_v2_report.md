# Citizen Base 01 Idle 8dir Candidate v2 Technical Report

Status: local_technical_fix_candidate
Runtime asset import: NO
Flame integration: NO
Motion Lab approval: NO
Commit: NO

## Quelleingabe

`docs/world_design/previews/citizen_base_01_idle_asset_intake/citizen_base_01_idle_8dir_candidate_v1.png`

Technischer Ausgangsbefund aus v1:

- Gesamtgroesse: `1086 x 1448 px`
- PNG-Modus: RGB / kein Alpha
- Sichtbares Checkerboard war als Pixel eingebrannt.
- Visuelles Raster: `2 x 8`, aber nur als `543 x 181 px` Zellen.

## Erzeugte Zieldatei

`_incoming_character_assets/citizen_base_01_idle_8dir_candidate_v2.png`

SHA-256:

`74d01840bd6ecee834e892c8b9872b0216bca71ffd7e52d8f6ca0a35c4053964`

## Methode

- v1 wurde lokal technisch in `2` Spalten und `8` Zeilen zerlegt.
- Pro Zelle wurden helle, niedrig chromatische Checkerboard-/Hintergrundpixel
  transparent gesetzt.
- Keine neue Kunst, keine neue Posefamilie und keine Walk-Frames wurden
  erzeugt.
- Jede vorhandene Figur wurde in ein `96 x 128 px`-Frame eingepasst.
- Die sichtbare Figur wurde horizontal auf die Frame-Mittelachse ausgerichtet.
- Der sichtbare Fuss-/Schattenbereich wurde naeher an den Zielanker
  `(48, 118)` gesetzt, bleibt aber wegen fehlender Original-Metadaten nur
  technisch angenaehert.

## Raster- und PNG-Pruefung

| Pruefung | Ergebnis |
| --- | --- |
| Finale Pixelgroesse | `192 x 1024 px` |
| Raster | `2 x 8` |
| Framegroesse | `96 x 128 px` |
| PNG-Modus | RGBA |
| Alpha vorhanden | Ja, Alpha `0..255` |
| Transparente Pixel | `128053` |
| Opaque Pixel | `62449` |
| Alle 16 Frames sichtbar gefuellt | Ja |
| Richtungreihenfolge | Beibehalten: `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW` |
| Zwei Idle-Frames je Richtung | Ja |
| Checkerboard-Hintergrund | Technisch entfernt; kein sichtbares Checkerboard-Raster im Export |

Frame-Fuellung nach Alpha-Pixeln:

| Richtung | Frame 0 | Frame 1 |
| --- | ---: | ---: |
| `N` | `5615` | `5667` |
| `NE` | `4462` | `4398` |
| `E` | `4450` | `4446` |
| `SE` | `3263` | `3278` |
| `S` | `4308` | `4267` |
| `SW` | `4515` | `4462` |
| `W` | `2708` | `2690` |
| `NW` | `4958` | `5068` |

## Einschaetzung zur Nutzbarkeit

`candidate_v2` ist als lokaler technischer Folgekandidat fuer den naechsten
Idle-Intake nutzbar. Die harten technischen Raster- und Alpha-Anforderungen
werden erfuellt:

- `192 x 1024 px`
- `2 x 8`
- `96 x 128 px`
- RGBA mit echter Transparenz
- kein eingebranntes Checkerboard-Muster als Hintergrund

Der Kandidat ersetzt aber keine saubere externe Sprite-Produktion und gibt noch
keine Runtime-, Flame-, Motion-Lab- oder Asset-Import-Freigabe.

## Offene Restprobleme / Qualitaetsrisiken

- Die Freistellung wurde automatisch aus einem RGB-Contact-Sheet mit
  eingebranntem Checkerboard abgeleitet. Feine helle Randpixel koennen deshalb
  noch manuelle QA brauchen.
- Der Fussanker `(48, 118)` ist angenaehert, aber nicht aus Original-Metadaten
  garantiert.
- Der helle Bodenschatten aus v1 bleibt stellenweise sichtbar. Er liegt unter
  den Fuessen, sollte aber im naechsten Intake auf Zielhintergrund und
  Lesbarkeit geprueft werden.
- Die Detaildichte bleibt gegenueber der Produktionsvorgabe hoch; die Figur ist
  technisch rasterfaehig, aber visuell noch nicht automatisch final.
- Source-/License-/Author-/Tool-Metadaten fehlen weiterhin fuer eine spaetere
  Asset-Freigabe.

## Empfehlung

Naechster Schritt: `Firenze Character Asset Intake 2A.2-idle` erneut gegen
`candidate_v2` pruefen. Motion Lab 2B bleibt bis zu einem formalen Intake-PASS
geschlossen.
