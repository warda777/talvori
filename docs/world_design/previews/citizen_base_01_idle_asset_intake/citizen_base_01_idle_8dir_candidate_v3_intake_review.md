# Citizen Base 01 Idle 8dir Candidate v3 Intake Review

Status: documentation_intake_only
Candidate: `citizen_base_01_idle_8dir_candidate_v3.png`
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

## 2. Eingabe und kopierte Dateien

Korrigierte Downloads-Quelle:

```text
/Users/andreaswarda/Downloads/citizen_base_01_idle_8dir_candidate_v3.png
```

Die Datei wurde gefunden und unveraendert kopiert nach:

```text
_incoming_character_assets/citizen_base_01_idle_8dir_candidate_v3.png
docs/world_design/previews/citizen_base_01_idle_asset_intake/citizen_base_01_idle_8dir_candidate_v3.png
```

Dokumentations-Overlay:

```text
docs/world_design/previews/citizen_base_01_idle_asset_intake/citizen_base_01_idle_8dir_candidate_v3_anchor_review.png
```

SHA-256 des Kandidaten:

```text
a4fe10ff87a4db3782d173386c6475a6fc72efb0a25b0847c78e2ed587f092fb
```

Es wurde keine Datei nach `assets/images/world/characters/` kopiert.

## 3. Technische PNG-Werte

| Pruefung | Ergebnis |
| --- | --- |
| Bilddimension | `724 x 2172` |
| PNG-Modus / Color Type | RGB, Color Type `2` |
| Alpha-/Transparenz-Kanal | Nein |
| Echte Transparenz | Nein |
| Transparente Pixel | `0` |
| Opaque Pixel | `1572528` |
| Eingebranntes Checkerboard | Ja, helle Checkerboard-/Hintergrundfarben sind Pixel |
| Zielmass `192 x 1024` | Nein |
| Raster `2 x 8` | Visuell ja, technisch nicht im Zielraster |
| Rechnerische Zellen im Ist-Bild | `362 x 271.5` |
| Framegroesse `96 x 128` | Nein |
| 16 Frames sichtbar gefuellt | Ja, visuell alle 16 Zellen gefuellt |
| Richtung-Reihenfolge | Plausibel: `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW` |
| Zwei Idle-Frames je Richtung | Plausibel ja |

Haeufigste Hintergrund-/Checkerboard-Farben:

| Farbe | Pixel |
| --- | ---: |
| `(254, 254, 254)` | `347293` |
| `(245, 245, 245)` | `203323` |
| `(246, 246, 246)` | `156203` |
| `(255, 255, 255)` | `67407` |
| `(253, 253, 253)` | `52723` |

Frame-Fuellung, grob ueber nicht-neutrale Pixel im nominalen Ist-Raster:

| Richtung | Frame 0 | Frame 1 |
| --- | ---: | ---: |
| `N` | `23425` | `23335` |
| `NE` | `22851` | `22828` |
| `E` | `17038` | `17025` |
| `SE` | `15492` | `15484` |
| `S` | `20821` | `20741` |
| `SW` | `22095` | `21714` |
| `W` | `12956` | `12739` |
| `NW` | `21288` | `21232` |

## 4. Anchor-Review

Erzeugte Pruefgrafik:

```text
docs/world_design/previews/citizen_base_01_idle_asset_intake/citizen_base_01_idle_8dir_candidate_v3_anchor_review.png
```

Das Overlay zeigt:

- cyan: nominale `2 x 8`-Aufteilung im tatsaechlichen `724 x 2172`-Bildraum,
- gelb: proportionaler Mittelpunkt je Spalte,
- gelb: proportionaler Bereich, an dem der Ziel-Fussanker `(48, 118)` in
  einem echten `96 x 128`-Frame liegen muesste,
- rot: proportionaler Ankerpunkt je nominalem Frame.

Wichtig: Weil `candidate_v3` nicht `192 x 1024` gross ist und keine
`96 x 128`-Frames besitzt, kann der echte Ziel-Fussanker `(48, 118)` nicht
belastbar bestaetigt werden. Das Overlay ist nur eine Dokumentationsgrafik und
keine korrigierte Sprite-Datei.

Anchor-Befund:

- Die nominalen Frame-Grenzen schneiden sichtbar durch Figurenbereiche.
- Mehrere Zeilen reichen bis an die nominalen Zellgrenzen.
- Der Fussanker ist im Zielraster nicht pruefbar.
- Der Schatten-/Bodenbereich ist im RGB-Checkerboard eingebettet und nicht als
  transparente Sprite-Fläche isoliert.

## 5. Visuelle Pruefung

| Pruefung | Ergebnis |
| --- | --- |
| Fuesse sichtbar | Ja, visuell sichtbar |
| Figur vollstaendig im Frame | Nein fuer Zielraster; nominale Grenzen schneiden sichtbar durch Figurenbereiche |
| Keine abgeschnittenen Koerperteile | Nicht bestanden im Zielraster |
| Schatten stabil und nicht springend | Grob plausibel als Contact-Sheet, aber nicht als transparenter Sprite-Schatten pruefbar |
| Detaildichte bei `96 x 128` | Nicht pruefbar, da keine `96 x 128`-Frames vorliegen |
| E-/W-Profil mit sichtbarer Nase | Ja, plausibel sichtbar |
| Fremd-IP erkennbar | Keine harte Fremd-IP erkennbar; Source-/License-Metadaten fehlen weiterhin |
| Keine Walk-Frames | Plausibel Idle, keine deutlichen Walk-Schritte |

## 6. Intake-Entscheidung

```text
NEEDS_FIX
```

Begruendung: `candidate_v3` ist als visuelles 8-Richtungs-Contact-Sheet
brauchbar, aber nicht als Intake-PASS fuer `citizen_base_01_idle_8dir`.
Die harten technischen Anforderungen werden nicht erfuellt:

- falsche Gesamtgroesse `724 x 2172` statt `192 x 1024`,
- RGB statt RGBA,
- kein Alpha,
- keine echte Transparenz,
- Checkerboard als Pixel eingebrannt,
- kein exaktes `2 x 8`-Zielraster mit `96 x 128`-Frames,
- Fussanker `(48, 118)` nicht pruefbar.

## 7. Fixliste fuer den naechsten Kandidaten

Fuer einen PASS-faehigen Kandidaten muss die naechste Produktion liefern:

1. Export als echtes transparentes RGBA-PNG.
2. Kein Checkerboard, kein weisser/grauer Pixelhintergrund.
3. Exakte Gesamtgroesse `192 x 1024`.
4. Exaktes Raster `2` Spalten x `8` Zeilen.
5. Exakte Framegroesse `96 x 128`.
6. Jede Figur vollstaendig innerhalb ihres Frames.
7. Fussanker je Frame bei `(48, 118)` sichtbar kontrollierbar.
8. Schatten stabil direkt unter den Fuessen, ohne Positionssprung.
9. Richtung-Reihenfolge `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW`.
10. Zwei subtile Idle-Frames je Richtung, keine Walk-Frames.
11. Source-/License-/Tool-/Author-Metadaten beilegen.

## 8. Motion-Lab-Entscheidung

```text
Motion Lab 2B erlaubt: NO
```

Grund: `candidate_v3` ist `NEEDS_FIX` und bleibt ohne Runtime-/Asset-Freigabe.
Noch kein Import nach `assets/images/world/characters/`, keine Flame-
Integration und keine Motion-Lab-Freigabe.

## 9. Grenzen

- Kein `assets/`-Import.
- Keine Sprite-Sheet-Korrektur.
- Keine automatische Skalierung.
- Kein Cropping.
- Keine Retusche.
- Keine Flame-Character-Implementierung.
- Keine App-Integration.
- Keine Aenderung an `pubspec.yaml`.
- Keine JSON-/YAML-/YML-Dateien.
- Keine Persistenz.
- Kein Commit.
