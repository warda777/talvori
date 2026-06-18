# Citizen Base 01 Idle 8dir Candidate v1 Intake Review

Status: documentation_intake_only
Candidate: `citizen_base_01_idle_8dir_candidate_v1.png`
Runtime asset import: NO
Sprite sheet approval: NO
Flame integration: NO
Motion Lab approval: NO

## 1. Gepruefte Grundlagen

- `docs/world_design/433-talvori-base-character-asset-spec-v1.md`
- `docs/world_design/434-citizen-base-01-asset-production-plan.md`
- `docs/world_design/435-citizen-base-01-style-mini-brief.md`
- `docs/world_design/previews/citizen_base_01_design_preview_intake/citizen_base_01_design_preview_intake_review.md`
- `docs/world_design/436-citizen-base-01-idle-frame-production-prep.md`

## 2. Aufgenommene Dokumentationsdatei

| Datei | Rolle | SHA-256 |
| --- | --- | --- |
| `citizen_base_01_idle_8dir_candidate_v1.png` | Idle-Kandidat v1, nur Dokumentations-/Intake-Pruefung | `faae8591b2d5eebe4d470e403d0684d01540c6a7b768274ae8205ec74d29344f` |

Die Datei wurde nur nach
`docs/world_design/previews/citizen_base_01_idle_asset_intake/` kopiert. Es
wurde keine Datei nach `assets/images/world/characters/` kopiert.

## 3. Technische PNG-Werte

| Pruefung | Ergebnis |
| --- | --- |
| Bilddimension | `1086 x 1448` |
| PNG-Modus / Color Type | RGB, Color Type `2` |
| Alpha-/Transparenz-Kanal | Nein |
| Echte Transparenz | Nein |
| Checkerboard als Pixel | Ja, sichtbar und technisch durch RGB-Hintergrund belegt |
| Zielmass `192 x 1024` | Nein |
| Rechnerisch in 2 x 8 teilbar | Ja, aber nur als `543 x 181` Raster |
| Ziel-Framegroesse `96 x 128` erreichbar | Nein |
| 8 Zeilen x 2 Spalten erkennbar | Visuell ja, technisch nicht im Zielraster |
| 16 Frames sichtbar gefuellt | Ja, alle 16 Zellen enthalten Figurinhalt |
| Richtung-Reihenfolge | Plausibel: `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW` |
| Zwei Idle-Frames je Richtung | Visuell ja |
| Fuesse sichtbar | Ja |
| Fussanker `(48,118)` pruefbar | Nein, wegen falschem Raster und fehlender transparenter Framegrenzen |
| Schatten stabil | Grob plausibel, aber nicht belastbar pruefbar |
| Detaildichte fuer `96 x 128` | Wahrscheinlich zu hoch; viele Guertel-/Taschen-/Ornamentdetails |

Technischer Hintergrundbefund:

- Das PNG hat keinen Alpha-Kanal.
- Die haeufigsten RGB-Werte sind helle Checkerboard-/Hintergrundfarben, u. a.
  `(254,254,254)`, `(246,246,246)`, `(245,245,245)`.
- Das sichtbare Checkerboard ist daher Teil des Bildes und nicht nur eine
  Transparenz-Vorschau.

## 4. Intake-Entscheidung

```text
NEEDS_FIX
```

Begruendung: Der Kandidat ist als visuelles Contact-/Preview-Sheet nuetzlich,
aber nicht als echter Idle-Sprite-Kandidat fuer Intake PASS geeignet. Die Datei
hat falsche Masse, keinen Alpha-Kanal, ein eingebranntes Checkerboard und kein
exaktes `96 x 128`-Frame-Raster.

## 5. Was bereits passt

- 8 Richtungen sind visuell vorhanden.
- Zwei Idle-Frames je Richtung sind visuell vorhanden.
- Richtung-Reihenfolge wirkt plausibel.
- Die Figur bleibt stilistisch nah am freigegebenen maennlichen Design.
- Fuesse sind sichtbar.
- Silhouette und Richtungserkennung sind grundsaetzlich lesbar.

## 6. Fixliste fuer die naechste Bildproduktion

Fuer einen neuen Intake-Kandidaten muss die naechste Produktion liefern:

1. Export als echtes transparentes PNG mit Alpha-Kanal.
2. Kein eingebranntes Checkerboard, kein weisser oder grauer Pixelhintergrund.
3. Exaktes Sheet-Mass `192 x 1024`.
4. Exaktes Raster: 2 Spalten x 8 Zeilen.
5. Exakte Framegroesse `96 x 128`.
6. Richtung-Reihenfolge: `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW`.
7. Zwei Idle-Frames je Richtung.
8. Fussanker pro Frame bei `(48,118)` pruefbar halten.
9. Contact Sheet zusaetzlich separat liefern, mit sichtbaren Framegrenzen und
   Fussanker-Markierung.
10. Schatten stabil unter den Fuessen halten und nicht zwischen Frames
    springen lassen.
11. Detaildichte weiter reduzieren: weniger Mini-Schnallen, Taschen,
    Guertel- und Ornamentdetails fuer bessere `96 x 128`-Lesbarkeit.
12. Source-/License-/Tool-/Author-Metadata fuer den naechsten Intake beilegen.

Wichtig: Diese Datei darf in diesem Slice nicht automatisch skaliert, gecroppt,
retuschiert oder als Ersatz-Sprite repariert werden. Der naechste Kandidat muss
sauber aus der Bildproduktion exportiert werden.

## 7. Motion-Lab-Entscheidung

```text
Motion Lab 2B erlaubt: NO
```

Grund: `Firenze Character Asset Intake 2A.2-idle` ist nicht PASS. Ohne echtes
transparentes `192 x 1024`-Idle-Sheet mit pruefbarem Fussanker darf kein Motion
Lab starten.

## 8. Grenzen

- Kein `assets/`-Import.
- Keine Sprite-Sheet-Korrektur.
- Keine automatische Skalierung.
- Kein Cropping.
- Keine Retusche.
- Keine Flame-Character-Implementierung.
- Keine App-Integration.
- Keine JSON-/YAML-/YML-Dateien.
- Keine Persistenz.
- Kein Commit.
