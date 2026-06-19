# Citizen Base 01 Idle 8dir Candidate v4 Technical Report

Status: local_technical_fix_candidate
Runtime asset import: NO
Flame integration: NO
Motion Lab approval: NO
Commit: NO

## Quelle

`docs/world_design/previews/citizen_base_01_idle_asset_intake/citizen_base_01_idle_8dir_candidate_v3.png`

Source PNG: `724 x 2172`, Color Type `2` / RGB, kein Alpha.

## Methode

- v3 wurde als `2` Spalten x `8` Zeilen Contact-Sheet gelesen.
- Pro Zelle wurde ein randverbundener heller Checkerboard-/Hintergrundbereich per Pixelanalyse erkannt und transparent gesetzt.
- Pro Zelle wurde danach die sichtbare Figuren-Bounding-Box gesucht; das finale Crop nutzt diese BBox, nicht die volle nominale Zelle.
- Der Body-Bottom wurde getrennt vom hellen Schattenbereich geschaetzt, damit der Fuss-/Schattenbereich plausibel zum Zielanker `(48, 118)` liegt.
- Es wurde keine neue Kunst erzeugt, keine Pose geaendert, kein Walk-Frame ergaenzt und nichts retuschiert.

## Ergebnis

| Pruefung | Ergebnis |
| --- | --- |
| Zieldatei | `_incoming_character_assets/citizen_base_01_idle_8dir_candidate_v4.png` |
| Finale Groesse | `192 x 1024` |
| PNG-Modus | RGBA / Color Type `6` |
| Alpha vorhanden | Ja, Alpha `0..255` |
| Transparente Pixel | `141283` |
| Opaque Pixel | `47869` |
| Raster | `2 x 8` |
| Framegroesse | `96 x 128` |
| 16 Frames gefuellt | Ja |
| Empfehlung fuer folgenden Intake | `NEEDS_FIX` |

## Frame-Pruefung

| Richtung | Frame | Source cell | BBox vorher | Body-BBox vorher | Scale | Platzierung nachher | BBox nachher | Anchor nachher | Vollstaendig |
| --- | ---: | --- | --- | --- | ---: | --- | --- | --- | --- |
| `N` | `0` | `(0, 0, 362, 272)` | `(158, 14, 294, 271)` | `(159, 15, 294, 271)` | `0.4280` | `(19, 8, 59, 110)` | `(19, 8, 77, 117)` | `(48.32, 118.0)` | `YES` |
| `N` | `1` | `(362, 0, 362, 272)` | `(64, 14, 201, 271)` | `(65, 15, 200, 271)` | `0.4280` | `(19, 8, 59, 110)` | `(19, 8, 77, 117)` | `(48.32, 118.0)` | `YES` |
| `NE` | `0` | `(0, 272, 362, 271)` | `(144, 0, 306, 270)` | `(166, 0, 290, 270)` | `0.4074` | `(14, 8, 66, 110)` | `(14, 8, 79, 117)` | `(48.22, 118.0)` | `YES` |
| `NE` | `1` | `(362, 272, 362, 271)` | `(54, 0, 207, 270)` | `(72, 0, 196, 270)` | `0.4074` | `(15, 8, 63, 110)` | `(15, 8, 77, 117)` | `(47.59, 118.0)` | `YES` |
| `E` | `0` | `(0, 543, 362, 271)` | `(146, 0, 300, 270)` | `(167, 0, 276, 270)` | `0.4074` | `(17, 8, 63, 110)` | `(17, 8, 79, 117)` | `(47.76, 118.0)` | `YES` |
| `E` | `1` | `(362, 543, 362, 271)` | `(53, 0, 206, 270)` | `(73, 0, 183, 270)` | `0.4074` | `(17, 8, 63, 110)` | `(17, 8, 79, 117)` | `(47.56, 118.0)` | `YES` |
| `SE` | `0` | `(0, 814, 362, 272)` | `(167, 0, 287, 271)` | `(178, 0, 268, 271)` | `0.4059` | `(25, 8, 49, 110)` | `(25, 8, 73, 117)` | `(47.73, 118.0)` | `YES` |
| `SE` | `1` | `(362, 814, 362, 272)` | `(77, 0, 190, 271)` | `(84, 0, 175, 271)` | `0.4059` | `(27, 8, 46, 110)` | `(27, 8, 72, 117)` | `(48.31, 118.0)` | `YES` |
| `S` | `0` | `(0, 1086, 362, 272)` | `(158, 0, 292, 271)` | `(168, 0, 280, 271)` | `0.4059` | `(21, 8, 55, 110)` | `(21, 8, 75, 117)` | `(47.79, 118.0)` | `YES` |
| `S` | `1` | `(362, 1086, 362, 272)` | `(65, 0, 197, 271)` | `(75, 0, 187, 271)` | `0.4059` | `(21, 8, 54, 110)` | `(21, 8, 74, 117)` | `(47.79, 118.0)` | `YES` |
| `SW` | `0` | `(0, 1358, 362, 271)` | `(159, 0, 296, 270)` | `(165, 0, 288, 270)` | `0.4074` | `(20, 8, 56, 110)` | `(20, 8, 75, 117)` | `(47.5, 118.0)` | `YES` |
| `SW` | `1` | `(362, 1358, 362, 271)` | `(64, 0, 198, 270)` | `(72, 0, 192, 270)` | `0.4074` | `(20, 8, 55, 110)` | `(20, 8, 74, 117)` | `(47.7, 118.0)` | `YES` |
| `W` | `0` | `(0, 1629, 362, 271)` | `(173, 0, 273, 270)` | `(196, 0, 258, 270)` | `0.4074` | `(26, 8, 41, 110)` | `(26, 8, 66, 117)` | `(48.0, 118.0)` | `YES` |
| `W` | `1` | `(362, 1629, 362, 271)` | `(79, 0, 177, 270)` | `(102, 0, 164, 270)` | `0.4074` | `(26, 8, 40, 110)` | `(26, 8, 65, 117)` | `(48.0, 118.0)` | `YES` |
| `NW` | `0` | `(0, 1900, 362, 272)` | `(166, 0, 292, 264)` | `(171, 0, 279, 262)` | `0.4198` | `(23, 8, 53, 111)` | `(23, 8, 75, 118)` | `(47.77, 118.0)` | `YES` |
| `NW` | `1` | `(362, 1900, 362, 272)` | `(69, 0, 196, 264)` | `(77, 0, 185, 262)` | `0.4198` | `(22, 8, 54, 111)` | `(22, 8, 75, 118)` | `(48.03, 118.0)` | `YES` |

Frame-Fuellung nach Alpha-Pixeln:

| Richtung | Frame 0 | Frame 1 |
| --- | ---: | ---: |
| `N` | `4415` | `4382` |
| `NE` | `3841` | `3899` |
| `E` | `3156` | `2921` |
| `SE` | `2602` | `2592` |
| `S` | `3654` | `3650` |
| `SW` | `4023` | `3953` |
| `W` | `2199` | `2161` |
| `NW` | `3914` | `3963` |

## Fussanker und Vollstaendigkeit

- Alle 16 Frames wurden in das `96 x 128`-Raster gesetzt.
- Kein Frame wurde beim Einpassen abgeschnitten; die sichtbare BBox bleibt innerhalb des Ziel-Frames.
- Der geschaetzte Body-Fussbereich liegt nach der Platzierung rechnerisch bei bzw. nahe `(48, 118)`.
- Der Schattenbereich bleibt unter der Figur erhalten, wurde aber technisch aus dem v3-RGB-Contact-Sheet abgeleitet.

## Bekannte Risiken

- v4 ist weiterhin ein technischer Kandidat aus einem RGB-Contact-Sheet, kein sauberer Originalexport aus der Bildproduktion.
- Die Alpha-Freistellung ist automatisiert; helle Randpixel oder kleine Shadow-Halos koennen manuelle QA brauchen.
- Zwischen den Beinen sind bei mehreren Figuren noch weisse bzw. helle Restflaechen sichtbar.
- Beim oberen rechten Frame ist am Ellbogen/Arm noch ein weisser Restbereich sichtbar.
- Diese Artefakte zeigen, dass die automatische Freistellung aus dem RGB-Contact-Sheet nicht zuverlaessig genug fuer eine Asset-Freigabe ist.
- Der Fussanker ist plausibel angenaehert, aber nicht durch Original-Metadaten bewiesen.
- Source-/License-/Tool-/Author-Metadaten fehlen weiterhin fuer echte Asset-Freigabe.
- Wegen der automatischen Ableitung bleibt die Empfehlung fuer den folgenden Intake `NEEDS_FIX`, auch wenn die harten technischen Zielwerte nun stimmen.

## Empfehlung

`NEEDS_FIX`: Der Kandidat ist technisch erzeugt und kann formal erneut geprueft werden, ersetzt aber keinen echten transparenten Sprite-Sheet-Export mit Metadaten. Ein PASS-faehiger Kandidat muss entweder aus einem echten transparenten Sprite-/Grafikexport kommen oder manuell sauber freigestellt werden.
