# Citizen Base 01 Idle 8dir Candidate v2 Intake Review

Status: documentation_intake_only
Candidate: `citizen_base_01_idle_8dir_candidate_v2.png`
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
- `_incoming_character_assets/citizen_base_01_idle_8dir_candidate_v2_report.md`

## 2. Aufgenommene Dokumentationsdateien

| Datei | Rolle | SHA-256 |
| --- | --- | --- |
| `citizen_base_01_idle_8dir_candidate_v2.png` | Technisch korrigierter Idle-Kandidat v2, nur Dokumentations-/Intake-Pruefung | `74d01840bd6ecee834e892c8b9872b0216bca71ffd7e52d8f6ca0a35c4053964` |
| `citizen_base_01_idle_8dir_candidate_v2_report.md` | Lokaler technischer Erzeugungsbericht | n/a |
| `citizen_base_01_idle_8dir_candidate_v2_anchor_review.png` | Dokumentations-Overlay fuer Frame-Grenzen und Ziel-Fussanker `(48, 118)` | n/a |

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
| Transparente Pixel | `128053` |
| Opaque Pixel | `62449` |
| Zielmass `192 x 1024` | Ja |
| Raster | `2` Spalten x `8` Zeilen |
| Ziel-Framegroesse | `96 x 128` |
| 16 Frames sichtbar gefuellt | Ja |
| Richtung-Reihenfolge | Plausibel beibehalten: `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW` |
| Zwei Idle-Frames je Richtung | Ja, formal vorhanden |
| Eingebranntes Checkerboard | Nein als Hintergrundraster; v2 nutzt echte Transparenz |

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

## 4. Anchor-Review

Erzeugte Pruefgrafik:

```text
docs/world_design/previews/citizen_base_01_idle_asset_intake/citizen_base_01_idle_8dir_candidate_v2_anchor_review.png
```

Das Overlay zeigt:

- cyan: Frame-Grenzen fuer `2 x 8`,
- gelb: horizontale Frame-Mittelachse `x=48`,
- gelb: Ziel-Ankerhoehe `y=118`,
- rot: Ziel-Fussanker `(48, 118)` pro Frame.

Technischer Befund:

- Die sichtbaren Alpha-Bounding-Boxes liegen rechnerisch innerhalb der Frames.
- Der untere sichtbare Bereich liegt in allen Frames nahe `y=117`; der
  Zielanker `y=118` ist deshalb technisch pruefbar.
- Die Freistellung ist echter Alpha-Hintergrund, nicht mehr eingebranntes
  Checkerboard.

Visueller Befund:

- Das Overlay zeigt, dass v2 aus dem v1-Contact-Sheet technisch erzwungen
  gerastert wurde.
- Einige Frames wirken nicht wie sauber einzeln produzierte Sprite-Frames,
  sondern wie aus einem zu engen Contact-Sheet extrahierte Ausschnitte.
- Die Figur ist in der Gesamtdatei sichtbar, aber die Frame-Reinheit ist nicht
  belastbar genug fuer eine Intake-Freigabe.
- Der helle Bodenschatten bleibt als aus v1 uebernommener Schatten erhalten,
  wirkt stellenweise noch breit und sollte in einem echten Export kontrolliert
  werden.

## 5. Visuelle Pruefung

| Pruefung | Ergebnis |
| --- | --- |
| Fuesse sichtbar | Teilweise ja, aber nicht pro Frame belastbar genug |
| Figur vollstaendig im Frame | Nicht zuverlaessig; die Rasterisierung aus v1 erzeugt sichtbare Frame-Reinheitsrisiken |
| Keine abgeschnittenen Koerperteile | Nicht bestanden; einzelne Frames wirken durch Contact-Sheet-Zuschnitt belastet |
| Schatten stabil und nicht springend | Grob stabil, aber heller und breiter als ideal |
| Detaildichte bei `96 x 128` | Lesbar, aber weiterhin hoch |
| E-/W-Profil mit sichtbarer Nase | Plausibel vorhanden |
| Fremd-IP erkennbar | Keine harte Fremd-IP erkennbar; Source-/License-Metadaten fehlen weiterhin |
| Keine Walk-Frames | Ja, es bleibt formal Idle |

## 6. Intake-Entscheidung

```text
NEEDS_FIX
```

Begruendung: `candidate_v2` behebt die technischen Blocker aus v1
teilweise: Groesse, Raster, Framegroesse, RGBA/Alpha und Checkerboard sind
formal korrekt. Der Kandidat ist aber nicht Intake-PASS, weil die
frameweise Sprite-Qualitaet aus der automatischen v1-Rasterisierung nicht
zuverlaessig genug ist. Der Anchor-Review macht sichtbar, dass ein sauberer
Originalexport noetig bleibt.

## 7. Fixliste fuer den naechsten Kandidaten

Fuer einen PASS-faehigen Kandidaten muss die naechste Produktion liefern:

1. Neu aus der Bild-/Sprite-Produktion exportieren, nicht aus dem v1-Contact-
   Sheet nachtraeglich erzwingen.
2. Exaktes Sheet `192 x 1024`.
3. Exaktes Raster `2 x 8` mit `96 x 128` pro Frame.
4. Pro Frame eine vollstaendige, nicht angeschnittene Figur.
5. Echte Transparenz ohne Checkerboard-Pixel.
6. Fussanker `(48, 118)` sichtbar kontrollierbar halten.
7. Schatten unter den Fuessen stabilisieren und weniger breit/hell halten.
8. Detaildichte weiter reduzieren, besonders Mini-Gurte, Schnallen und
   Ornamentdetails.
9. Contact Sheet mit Frame-Grenzen und Fussanker-Markierung mitliefern.
10. Source-/License-/Tool-/Author-Metadaten beilegen.

## 8. Motion-Lab-Entscheidung

```text
Motion Lab 2B erlaubt: NO
```

Grund: Dieser Slice ist nur ein formaler Intake fuer den technischen
v2-Kandidaten. `candidate_v2` ist `NEEDS_FIX` und bleibt ohne
Runtime-/Asset-Freigabe. Selbst bei spaeterem Intake-PASS muessen
Source-/License-/Tool-/Author-Metadaten und ein eigenes Import-Gate vor
Runtime- oder Motion-Lab-Nutzung geklaert bleiben.

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
