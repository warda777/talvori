# Citizen Base 01 Idle 8dir Candidate v4 Intake Review

Status: documentation_intake_only
Candidate: `citizen_base_01_idle_8dir_candidate_v4.png`
Runtime asset import: NO
Sprite sheet approval: NO
Flame integration: NO
Motion Lab approval: NO

## 1. Gepruefte Grundlagen

- `docs/world_design/433-talvori-base-character-asset-spec-v1.md`
- `docs/world_design/434-citizen-base-01-asset-production-plan.md`
- `docs/world_design/435-citizen-base-01-style-mini-brief.md`
- `docs/world_design/436-citizen-base-01-idle-frame-production-prep.md`
- `docs/world_design/previews/citizen_base_01_idle_asset_intake/citizen_base_01_idle_8dir_candidate_v1_intake_review.md`
- `docs/world_design/previews/citizen_base_01_idle_asset_intake/citizen_base_01_idle_8dir_candidate_v2_intake_review.md`
- `docs/world_design/previews/citizen_base_01_idle_asset_intake/citizen_base_01_idle_8dir_candidate_v3_intake_review.md`
- `_incoming_character_assets/citizen_base_01_idle_8dir_candidate_v4_report.md`

## 2. Aufgenommene Dokumentationsdateien

| Datei | Rolle | SHA-256 |
| --- | --- | --- |
| `citizen_base_01_idle_8dir_candidate_v4.png` | Technisch extrahierter Idle-Kandidat v4, nur Dokumentations-/Intake-Pruefung | `745c00302381f9029f91b120bc87c3ed95e246eedf24f3034eafd2543b310129` |
| `citizen_base_01_idle_8dir_candidate_v4_report.md` | Lokaler technischer Extraktionsbericht | n/a |
| `citizen_base_01_idle_8dir_candidate_v4_anchor_review.png` | Dokumentations-Overlay fuer Frame-Grenzen und Ziel-Fussanker `(48, 118)` | n/a |

Die Dateien wurden nur nach
`docs/world_design/previews/citizen_base_01_idle_asset_intake/` kopiert bzw.
dort als Dokumentationsgrafik erzeugt. Es wurde keine Datei nach
`assets/images/world/characters/` kopiert.

## 3. Technische PNG-Werte

| Pruefung | Ergebnis |
| --- | --- |
| Bilddimension | `192 x 1024` |
| PNG-Modus / Color Type | RGBA, Color Type `6` |
| Alpha-/Transparenz-Kanal | Ja |
| Echte Transparenz | Ja, Alpha `0..255` |
| Transparente Pixel | `141283` |
| Opaque Pixel | `47869` |
| Zielmass `192 x 1024` | Ja |
| Raster | `2` Spalten x `8` Zeilen |
| Ziel-Framegroesse | `96 x 128` |
| 16 Frames sichtbar gefuellt | Ja |
| Richtung-Reihenfolge | Beibehalten: `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW` |
| Zwei Idle-Frames je Richtung | Ja |
| Eingebranntes Checkerboard als Hintergrund | Nein, v4 nutzt echte Transparenz |

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

Sichtbare BBox je Frame im `96 x 128`-Raster:

| Richtung | Frame 0 | Frame 1 |
| --- | --- | --- |
| `N` | `(19, 8, 77, 117)` | `(19, 8, 77, 117)` |
| `NE` | `(14, 8, 79, 117)` | `(15, 8, 77, 117)` |
| `E` | `(17, 8, 79, 117)` | `(17, 8, 79, 117)` |
| `SE` | `(25, 8, 73, 117)` | `(27, 8, 72, 117)` |
| `S` | `(21, 8, 75, 117)` | `(21, 8, 74, 117)` |
| `SW` | `(20, 8, 75, 117)` | `(20, 8, 74, 117)` |
| `W` | `(26, 8, 66, 117)` | `(26, 8, 65, 117)` |
| `NW` | `(23, 8, 75, 118)` | `(22, 8, 75, 118)` |

## 4. Anchor-Review

Erzeugte Pruefgrafik:

```text
docs/world_design/previews/citizen_base_01_idle_asset_intake/citizen_base_01_idle_8dir_candidate_v4_anchor_review.png
```

Das Overlay zeigt:

- cyan: Frame-Grenzen fuer `2 x 8`,
- gelb: horizontale Frame-Mittelachse `x=48`,
- gelb: Ziel-Ankerhoehe `y=118`,
- rot: Ziel-Fussanker `(48, 118)` pro Frame.

Anchor-Befund:

- Der sichtbare untere Bereich liegt je Frame bei `y=117` oder `y=118`.
- Der geschaetzte Body-Fussbereich liegt laut v4-Report rechnerisch nahe
  `(48, 118)`.
- Die Figur bleibt pro Frame sichtbar innerhalb des `96 x 128`-Rasters.
- Der Fussanker ist plausibel, aber nicht durch Original-Metadaten oder eine
  echte Authoring-Datei belegt.

## 5. Visuelle Pruefung

| Pruefung | Ergebnis |
| --- | --- |
| Figur vollstaendig im Frame | Ja, innerhalb des technischen v4-Rasters |
| Keine abgeschnittenen Koerperteile | Ja, keine harten Schnitte im v4-Zielraster sichtbar |
| Fuesse sichtbar | Ja |
| Fussanker `(48, 118)` plausibel | Ja, aber automatisch angenaehert |
| Schatten stabil | Plausibel, aber aus RGB-Contact-Sheet extrahiert |
| E-/W-Profil mit sichtbarer Nase | Ja, plausibel sichtbar |
| Detaildichte bei `96 x 128` | Lesbar, aber weich und detailreich |
| Fremd-IP erkennbar | Keine harte Fremd-IP erkennbar; Source-/License-Metadaten fehlen weiterhin |
| Helle Rest-/Halo-Kanten | Ja, aus automatischer Hintergrundentfernung sichtbar |

Konkrete Freistellungsartefakte:

- Zwischen den Beinen sind bei mehreren Figuren noch weisse bzw. helle
  Restflaechen sichtbar.
- Beim oberen rechten Frame ist am Ellbogen/Arm noch ein weisser Restbereich
  sichtbar.
- Diese Artefakte zeigen, dass die automatische Freistellung aus dem
  RGB-Contact-Sheet nicht zuverlaessig genug fuer eine Asset-Freigabe ist.

## 6. Intake-Entscheidung

```text
NEEDS_FIX
```

Begruendung: `candidate_v4` erfuellt die harten technischen Zielwerte deutlich
besser als v1-v3: Groesse, Raster, Framegroesse, RGBA/Alpha und sichtbare
Frame-Vollstaendigkeit passen. Fuer eine Asset-Freigabe reicht das aber noch
nicht, weil v4 weiterhin eine automatische Extraktion aus einem
RGB-Contact-Sheet ist. Source-/License-/Tool-/Author-Metadaten fehlen, der
Fussanker ist nur technisch angenaehert, und die Freistellung enthaelt
konkret sichtbare helle Restflaechen zwischen den Beinen sowie einen weissen
Restbereich am Arm/Ellbogen im oberen rechten Frame.

## 7. Fixliste fuer einen PASS-faehigen Asset-Import

Fuer einen spaeteren Import-Gate-PASS muss geliefert oder geklaert werden:

1. Source-/License-/Tool-/Author-Metadaten.
2. Bestaetigung, dass Talvori die Figur kommerziell nutzen und bearbeiten darf.
3. Idealerweise echter Export aus der Bild-/Sprite-Produktion statt
   nachtraeglicher RGB-Contact-Sheet-Extraktion.
4. Kontakt-/Anchor-Sheet mit klar markiertem Fussanker `(48, 118)`.
5. Visuelle QA gegen helle Halo-/Shadow-Reste auf dunklem und hellem
   Hintergrund, besonders zwischen den Beinen und am Arm-/Ellbogenbereich.
6. Bestaetigung, dass die zwei Frames pro Richtung reine Idle-Frames sind und
   keine verdeckten Walk-/Posewechsel enthalten.

Ein PASS-faehiger Kandidat muss entweder aus einem echten transparenten
Sprite-/Grafikexport kommen oder manuell sauber freigestellt werden. Eine rein
automatische Freistellung aus dem RGB-Contact-Sheet reicht nach den sichtbaren
Artefakten nicht aus.

## 8. Motion-Lab-Entscheidung

```text
Motion Lab 2B erlaubt: NO
```

Grund: Dieser Slice ist ein Dokumentations-/Intake-Slice, kein Asset-Import.
Auch bei technisch brauchbarem v4 bleiben Runtime-Asset, Flame-Integration und
Motion Lab geschlossen, bis Source-/License-/Tool-/Author-Metadaten und ein
eigenes Import-Gate freigegeben sind.

## 9. Grenzen

- Kein `assets/`-Import.
- Keine Sprite-Korrektur.
- Keine Skalierung.
- Kein Cropping.
- Keine Retusche.
- Keine Flame-Character-Implementierung.
- Keine App-Integration.
- Keine Aenderung an `pubspec.yaml`.
- Keine JSON-/YAML-/YML-Dateien.
- Keine Persistenz.
- Kein Commit.
