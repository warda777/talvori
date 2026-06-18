# 433 Talvori Base Character Asset Spec v1

Status: specification_only / planning_only  
Scope: one base character asset specification  
Runtime release: NO  
Flutter/Flame implementation: NO  
Sprite asset generation: NO

## 1. Ziel

Dieser Slice spezifiziert genau eine Talvori-Basisfigur:
`citizen_base_01`.

Zweck ist ein spaeterer isolierter Motion Proof in Flame. Die Figur soll als
erste saubere Character-Grundlage fuer Talvori Welt dienen, nachdem
prozedurale Kreis-/Linien-/Puppet-Figuren abgelehnt wurden.

`citizen_base_01` ist kein Clash-of-Clans-Klon. Der Stil muss Talvori-eigen
bleiben: warm, weltlich, lesbar, freundlich und fuer die Firenze-/City-World
geeignet. Fremde Artstyles, Figuren, UI-Sprache, Oekonomie, IP oder
Animationsmuster duerfen nicht kopiert werden.

## 2. Perspektive und Stil

- Perspektive: 3/4 top-down, isometric-friendly.
- Einsatz: Talvori World/City, zuerst fuer einen isolierten Motion Lab Proof.
- Zielgeraet: iPhone im Landscape-Modus.
- Lesbarkeit: Figur muss auch bei City-Kamera-Zoom als Mensch/Rolle
  erkennbar bleiben.
- Anatomie: stilisiert und spielhaft, nicht realistisch, aber glaubwuerdig.
- Verboten: Strichfigur, Kreis-Maennchen, prozedurale Puppet-Figur,
  Code-Figur, rotierender Ganzkoerper.
- Silhouette: klarer Kopf, Koerper, Beinstand und Arm-/Schulterlesbarkeit.
- Farbigkeit: Talvori-kompatibel, ruhig genug fuer City-Hintergruende, aber
  mit erkennbarem Charakter-Kontrast.

## 3. Technisches Sprite-Ziel

Bevorzugtes Ziel:

- 8 Richtungen: `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW`.
- `idle`: 2 Frames pro Richtung.
- `walk`: 4 Frames pro Richtung.
- Format: transparente PNG-Frames oder transparente Sprite-Sheets.
- Framegroesse: fest je Sheet und je Animation.
- Fussanker: fixer `bottomCenter`-Anker pro Frame.
- Shadow-Anker: separat oder klar an denselben Fussanker gebunden.
- Fussposition: darf zwischen Frames nicht springen.
- Laufzeitrotation: keine Rotation des ganzen Koerpers.
- Richtungsauswahl: Route-Bewegungsvektor wird in Direction Buckets
  uebersetzt.

Mindestfallback nur bei Asset-Produktionsblocker:

- 4 Richtungen: `N`, `E`, `S`, `W`.
- Der Fallback muss explizit als Asset-Blocker-Fallback dokumentiert werden.
- Auch im Fallback bleibt Ganzkoerperrotation verboten.

## 4. Benennung

Geplante Sprite-Sheet-Dateien, noch nicht erzeugen:

```text
assets/images/world/characters/citizen_base_01/citizen_base_01_idle_8dir.png
assets/images/world/characters/citizen_base_01/citizen_base_01_walk_8dir.png
assets/images/world/characters/citizen_base_01/citizen_base_01_metadata.md
```

Falls Einzelbilder spaeter noetig werden:

```text
citizen_base_01_idle_N_00.png
citizen_base_01_idle_N_01.png
citizen_base_01_walk_N_00.png
citizen_base_01_walk_N_01.png
citizen_base_01_walk_N_02.png
citizen_base_01_walk_N_03.png
```

Die Richtung im Dateinamen folgt derselben Reihenfolge wie das Sheet:

```text
N, NE, E, SE, S, SW, W, NW
```

## 5. Frame- und Sheet-Layout

Sheet-Regel:

- Zeilen = Richtungen.
- Spalten = Frames.
- Richtung-Reihenfolge: `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW`.
- `idle_8dir`: 8 Zeilen x 2 Spalten.
- `walk_8dir`: 8 Zeilen x 4 Spalten.
- Framegroesse Vorschlag: 96 x 128 px.
- Padding: mindestens 8 px transparente Sicherheitszone um die Figur.
- Fussanker: `bottomCenter`, vorgeschlagen bei `(48, 118)` innerhalb eines
  96 x 128 Frames.
- Schatten: eigene Ebene oder baked shadow mit Mittelpunkt unter dem
  Fussanker; Schatten darf nicht rotieren.
- Flame-Skalierung: Sprite wird aus World Units skaliert, ohne separate
  Character-Kamera und ohne frameabhaengige Groessenwechsel.

Layout:

| Sheet | Zeilen | Spalten | Frames je Richtung | Richtung-Reihenfolge |
| --- | ---: | ---: | ---: | --- |
| `idle_8dir` | 8 | 2 | 2 | N, NE, E, SE, S, SW, W, NW |
| `walk_8dir` | 8 | 4 | 4 | N, NE, E, SE, S, SW, W, NW |

## 6. Motion-Regeln

- Die Route liefert Weltposition und Bewegungsvektor.
- Der Bewegungsvektor wird in 8 Direction Buckets uebersetzt.
- Der Bucket waehlt Richtung und passende Animation.
- Die Animation laeuft mit eigener Frame-Clock.
- Die Figur bleibt aufrecht; der Visual Root wird nicht kontinuierlich an der
  Routentangente gedreht.
- Der Schatten bleibt unter dem Fussanker und rotiert nicht mit dem Koerper.
- Y-/Depth-Sorting nutzt die Fussposition.
- `idle` stoppt die Walk-Animation.
- Der Walk-Cycle laeuft ueber Edge-Wechsel hinweg kontinuierlich weiter.
- Bewegungsgeschwindigkeit kommt aus der Route, nicht aus der Framezahl.
- Framewechsel duerfen die Fussposition nicht verschieben.

Direction-Bucket-Kontrakt:

| Bewegungsvektor | Bucket |
| --- | --- |
| nach oben | `N` |
| oben rechts | `NE` |
| rechts | `E` |
| unten rechts | `SE` |
| unten | `S` |
| unten links | `SW` |
| links | `W` |
| oben links | `NW` |

## 7. Qualitaetscheck

Harte Visual-QA fuer `citizen_base_01`:

- Figur kippt nicht.
- Kopf springt nicht ueber die Fuesse.
- Fuesse schwimmen nicht.
- Koerpergroesse bleibt zwischen Frames stabil.
- Alle Richtungen wirken wie dieselbe Figur.
- Diagonales Laufen wirkt glaubwuerdig.
- Figur bleibt bei City-Zoom lesbar.
- Keine Frame-Zitterer.
- Kein Salto-Effekt.
- Kein Strichmaennchen.
- Kein Kreis-/Punkt-/Puppet-Ersatz.
- Schatten bleibt stabil unter dem Fussanker.
- Idle und Walk sind klar unterscheidbar.

## 8. Spaeterer Folge-Slice

Naechster Slice:

```text
Firenze Character Motion Lab 2B
```

2B darf erst starten, wenn echte `citizen_base_01`-Assets bereitstehen oder
ein expliziter Asset-Production-Slice vorgeschaltet wurde.

2B-Ziel:

- isolierte Flame-Testszene,
- genau eine Figur,
- echte Assets,
- `idle` und `walk`,
- bevorzugt 8 Richtungen,
- kein Firenze-Graph,
- kein NPC-System,
- keine App-Integration,
- keine Persistenz.

## 9. Blocker

Falls keine echte Asset-Produktion moeglich ist, bleibt:

```text
CHARACTER_ASSET_BLOCKER
```

In diesem Fall darf Codex keine prozedurale Ersatzfigur zeichnen, keine
Kreis-/Linienfigur bauen, keine Puppet-Figur im Code erzeugen und keine
Asset-Attrappe in `assets/` legen. Der naechste zulaessige Schritt waere ein
enger Asset-Production-Slice fuer `citizen_base_01`.

## 10. Visuelles Diagramm

Erzeugte Dokumentationsgrafik:

```text
docs/world_design/previews/firenze_character_foundation_2a/citizen_base_01_sprite_sheet_layout.svg
docs/world_design/previews/firenze_character_foundation_2a/citizen_base_01_sprite_sheet_layout.png
```

Die Grafik zeigt nur das technische Sheet-/Motion-Prinzip:

- Richtung-Reihenfolge,
- Idle-/Walk-Sheet-Prinzip,
- `bottomCenter`-Fussanker,
- Shadow-Anker,
- Direction-Bucket-Prinzip,
- Pipeline: route vector -> direction bucket -> animation state -> sprite
  frame.

Sie erzeugt keine Spielgrafik und keine Figur.

## 11. Grenzen

- Keine App-Integration.
- Keine Flame-Character-Implementierung.
- Keine neuen Dateien unter `assets/images/world/characters/`.
- Keine echten Sprite-Bilder.
- Keine KI-Bildgenerierung.
- Keine prozeduralen Figuren.
- Keine Aenderung an `pubspec.yaml`.
- Keine Aenderung am Firenze Flame Proof.
- Keine JSON-/YAML-/YML-Dateien.
- Keine Persistenz.
- Kein Commit.

## 12. Ergebnis

Base Character Asset Specification: PASS  
Runtime-Freigabe: NO  
Sprite-Asset-Freigabe: NO  
Flame-Character-Integration: NO  
Naechster enger Slice: `Firenze Character Motion Lab 2B`, nach echter
Asset-Bereitstellung fuer `citizen_base_01`.

