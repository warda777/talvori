# 438 Talvori Modern 2D/2.5D Character Sprite Style Decision

Status: character_style_decision / documentation_only
Scope: Talvori character sprite direction
Runtime asset import: NO
Flame integration: NO
Motion Lab: NO

## 1. Ziel

Dieser Slice entscheidet die Character-Asset-Richtung fuer Talvori neu:
Talvori nutzt fuer finale Hauptfiguren keinen klassischen 96 x 128
Pixel-Art-Stil mehr.

Stattdessen wird `citizen_base_01` als erster moderner stilisierter
2D-/2.5D-Mobile-Game-Sprite geplant: klare Silhouette, handgemalter
mobile-game-artiger Look, echte transparente PNGs und modulare
Asset-Produktion.

## 2. Grund

Die bisherigen 96 x 128 Tests und die RGB-Contact-Sheet-Extraktion haben als
Produktionsweg nicht getragen:

- 96 x 128 ist fuer den gewuenschten detailreichen Talvori-Stil zu klein.
- Figuren wirken in dieser Groesse schnell matschig oder zerlegt.
- Freistellung aus RGB-Contact-Sheets ist unzuverlaessig.
- Helle Restflaechen zwischen Beinen, Armen und Schatten sind schwer sauber zu
  entfernen.
- Gelaende, Gebaeude, Props und Charaktere muessen langfristig denselben
  hochwertigen stilisierten Look tragen.

## 3. Entscheidung

- Talvori nutzt keinen klassischen 96 x 128 Pixel-Art-Stil als finalen
  Character-Hauptstil.
- Talvori nutzt moderne stilisierte 2D-/2.5D-Sprites mit sauberer Silhouette,
  echten transparenten PNGs und mobiler Lesbarkeit.
- Aseprite bleibt Produktions-, Export- und QA-Tool, aber nicht als Zwang zu
  harter Pixel-Art.
- Codex erzeugt keine Figuren und fuehrt keine automatische Contact-Sheet-
  Freistellung mehr als Produktionsweg durch.
- Codex prueft, dokumentiert, erzeugt Review-Grafiken und formuliert
  Intake-Fixlisten.

## 4. Neue Zielwerte fuer citizen_base_01

| Feld | Neuer Zielwert |
| --- | --- |
| Framegroesse | `128 x 192` px |
| Idle Sheet | `2 x 8`, also `256 x 1536` px |
| Walk Sheet | `4 x 8`, also `512 x 1536` px |
| Direction Order | `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW` |
| Idle Frames | 2 pro Richtung |
| Walk Frames | 4 pro Richtung |
| Foot Anchor | `(64, 180)` |
| Hintergrund | echte PNG-Transparenz |
| Export | keine Bodenplatten, kein Checkerboard, keine technische Arbeitsumgebung |

## 5. Verworfene Zwischenstaende

- v1 bis v4 bleiben Dokumentationskandidaten.
- v1 bis v4 sind keine Produktionsquelle.
- Die automatische RGB-Contact-Sheet-Freistellung bleibt als Hauptweg
  verworfen.
- Lokale leere 96 x 128 Template-Dateien unter `_incoming_character_assets/`
  sind verworfen und werden nicht importiert.
- 96 x 128 bleibt nur historischer Teststand, nicht aktuelles Ziel.

## 6. Produktionsregel ab jetzt

Der naechste PASS-faehige Kandidat muss aus manueller, sauberer
Sprite-Produktion kommen:

1. Design-Preview als Stilreferenz nutzen.
2. In Aseprite oder einem kompatiblen Art-Tool im neuen `128 x 192` Frame-
   Vertrag arbeiten.
3. Echte transparente PNGs exportieren.
4. Keine Bodenplatte, kein Checkerboard, keine Labels und keine technische
   Arbeitsumgebung im Export.
5. Kandidaten zuerst nach `_incoming_character_assets/` legen.
6. Codex fuehrt nur technischen Intake, Visual-QA, Anchor-Review und
   Dokumentation durch.
7. Import nach `assets/images/world/characters/` erst nach eigenem Import
   Gate.

## 7. Auswirkungen auf Folge-Slices

`Firenze Character Motion Lab 2B` bleibt gesperrt, bis:

- ein neuer `128 x 192` Idle-Kandidat formal PASS ist,
- Source-/License-/Tool-/Author-Metadaten vorliegen,
- ein eigenes Import-Gate den Import nach `assets/images/world/characters/`
  freigibt.

Walk-Produktion startet erst nach sauberem Idle-Intake oder mit expliziter
neuer Freigabe.

## 8. Grenzen

- Keine App-Integration.
- Keine Flame-Character-Implementierung.
- Keine neuen Character-PNGs als Produktionsasset.
- Keine Dateien unter `assets/images/world/characters/`.
- Keine Retusche.
- Keine neue Figur.
- Keine automatische Contact-Sheet-Freistellung.
- Keine JSON-/YAML-/YML-Dateien.
- Keine Persistenz.
- Kein Commit.

## 9. Ergebnis

Character Sprite Style Decision: PASS.

Aktueller Zielstil: moderner stilisierter 2D-/2.5D-Mobile-Game-Sprite.

Aktuelle Zielwerte: `128 x 192` Frame, `256 x 1536` Idle Sheet,
`512 x 1536` Walk Sheet, Foot Anchor `(64, 180)`.

96 x 128 Pixel-Art-Teststand: verworfen fuer finale Character-Produktion.
