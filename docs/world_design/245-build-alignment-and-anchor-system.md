# Phase 2G: Build Alignment And Anchor System

Stand: 2026-06-05

Dieses Dokument stoppt die weitere Freigabe von `frame_started.png` und
definiert zuerst ein verbindliches Alignment-/Anchor-System fuer aufeinander
aufbauende `BuildAreaState`-Assets.

Fuehrende Dokumente:

- `docs/world_design/235-world-production-roadmap-and-checklists.md`
- `docs/world_design/243-frame-started-plan.md`
- `docs/world_design/244-frame-started-asset-prompt.md`
- `docs/world_design/240-private-island-state-system.md`
- `docs/world_design/241-build-feedback-animation-and-sound.md`
- `assets/images/world/buildable_islands/forest_clearing/template.md`

## 1. Zweck

Talvori-Bauzustaende muessen exakt aufeinander aufbauen.

Dieses Dokument legt fest:

- welche Anchor-/Footprint-Daten ein aufbauendes Bau-Asset braucht,
- wie `frame_started` und spaetere Bauzustaende auf
  `foundation_complete` ausgerichtet werden,
- welche Debug-/Preview-Gates vor Freigabe Pflicht sind,
- warum ein nur ungefaehr passendes Zentrum nicht mehr reicht.

Nicht-Ziel:

- kein Flutter-/Dart-Code,
- keine App-Integration,
- keine Tests,
- keine Asset-Erzeugung,
- keine PNG-Aenderung,
- keine Freigabe von `frame_started.png`,
- kein Commit.

## 2. Problemstellung

Die manuelle Sichtpruefung der aktuellen `frame_started.png`-Version hat
gezeigt:

- Zentrum und Canvas koennen rechnerisch passen,
- trotzdem koennen Pfosten/Fuesse visuell nicht exakt genug auf
  `foundation_complete` stehen,
- ein Rohbau kann dadurch wie ein separates Objekt auf Gras/Erde wirken,
- spaetere Bauzustaende wuerden diese Ungenauigkeit weitervererben.

Fuer Talvori reicht deshalb nicht:

```text
gleicher Canvas + gleicher Mittelpunkt = freigegeben
```

Zusaetzlich muessen Footprint, Support-Punkte und Debug-Overlay geprueft
werden.

## 3. Warum "Ungefaehr Passend" Nicht Reicht

Buildable-Island-Assets sind keine isolierten Illustrationen. Sie sind
aufeinander aufbauende Zustandsbilder.

Wenn `frame_started` nicht sichtbar auf `foundation_complete` steht:

- verliert der Baufortschritt physische Glaubwuerdigkeit,
- wirken spaetere Zustaende wie harte Bildwechsel,
- wird Asset-Layering schwer testbar,
- entstehen im Code Versuchungen, schlechte Assets durch Offsets zu kaschieren,
- wird jede weitere Stufe (`frame_complete`, `building_level_1`) unsicherer.

Regel:

> Ein BuildAreaState-Asset wird nicht durch Bildmitte freigegeben, sondern
> durch Anchor-, Footprint- und Kontaktpunkt-Pruefung.

## 4. Professioneller Ansatz

Kurzer Research-/Orientierungscheck:

| Quelle / Orientierung | Ableitung fuer Talvori | Entscheidung |
| --- | --- | --- |
| Unreal Engine dokumentiert Sockets als benannte Attachment Points fuer Meshes und Objekte: `https://dev.epicgames.com/documentation/en-us/unreal-engine/skeletal-mesh-sockets-in-unreal-engine` und `https://dev.epicgames.com/documentation/en-us/unreal-engine/using-sockets-with-static-meshes-in-unreal-engine` | Professionelle Pipelines verlassen sich fuer Aufbau/Attachment nicht nur auf visuelle Schaetzung, sondern auf explizite benannte Punkte. | Talvori definiert benannte Support-Anker wie `front_left_support` und `rear_right_support`. |
| Unity Tilemap dokumentiert `Tile Anchor` als definierte Ausrichtung innerhalb einer Zelle: `https://docs.unity3d.com/Manual/class-Tilemap.html` | Platzierung braucht ein stabiles lokales Bezugssystem, nicht nur Screen-Positionen. | Talvori nutzt Asset-lokale Koordinaten auf dem `1536 x 1024` Template-Canvas. |
| Unity Sprite-/Collider-Workflows nutzen explizite Shapes/Polygone fuer Interaktion und Kollision, z. B. `https://docs.unity3d.com/Manual/class-PolygonCollider2D.html` | Sichtbare Flaechen und erlaubte Platzierungsbereiche koennen als Polygone/Masken beschrieben und validiert werden. | Talvori definiert `safe_inner_build_polygon` und `max_frame_footprint_polygon`. |
| Bestehende Talvori-Gates aus `234`, `239`, `240` und `241` verlangen Production Gates, Scale-Regeln, State-Trennung und Preview-Pruefung. | Asset-Qualitaet muss vor Code und vor Freigabe pruefbar sein. | Jede neue Bauphase braucht Contact Sheet, Debug-Overlay und gezielte Alignment-Pruefung. |

## 5. Talvori-Entscheidung

Talvori verwendet fuer aufeinander aufbauende BuildAreaState-Assets ein
Anchor-/Footprint-System.

Jeder neue Bauzustand muss dokumentieren:

- auf welchem Referenzzustand er aufbaut,
- wo das zentrale Build-Zentrum liegt,
- welche Kontaktpunkte erlaubt sind,
- wie gross der maximale Footprint sein darf,
- welche inneren Bereiche sicher sind,
- welche Randbereiche nicht belastet werden duerfen,
- wie das Asset im Debug-Overlay validiert wurde.

Phase 2G wird deshalb nicht weiter freigegeben, bis diese Regeln angewendet
wurden.

## 6. Anchor-System Fuer BuildAreaState-Assets

### Pflichtdaten Pro Aufbau-Asset

Jedes aufbauende Asset wie `frame_started`, `frame_complete` oder
`building_level_1` braucht:

- `canvasSize`: fuer Waldlichtung aktuell `1536 x 1024`
- `referenceState`: z. B. `foundation_complete`
- `referenceAssetPath`
- `build_center`
- `referenceVisibleBounds`
- `safe_inner_build_polygon`
- `max_frame_footprint_polygon`
- `supportAnchors`
- `contactPointRadius`
- `maxVisibleBounds`
- `maxSilhouetteHeight`
- `blockedContactAreas`
- `debugPreviewFiles`
- `alignmentDecision`

### Pflicht-Anchor-Typen Fuer Waldlichtung

Fuer `buildable_forest_clearing` muessen mindestens diese Typen existieren:

- `build_center`
- `front_left_support`
- `front_right_support`
- `rear_left_support`
- `rear_right_support`
- optional `mid_support_center`
- optional `mid_support_front`
- optional `mid_support_rear`
- `safe_inner_build_polygon`
- `max_frame_footprint_polygon`

### Regeln

- Pfosten/Fuesse muessen auf definierten Support-Ankern oder innerhalb des
  `safe_inner_build_polygon` sitzen.
- Kein sichtbarer Fuss darf ausserhalb des zulaessigen Fundamentbereichs auf
  Gras, freier Erde oder Deko stehen.
- Ein Aufbau-Asset darf nicht nur nach Zentrum ausgerichtet werden.
- Footprint, Support-Positionen und Silhouette muessen separat geprueft werden.
- Kontaktsteine/Fussplatten duerfen den Support-Anker leicht umgeben, aber
  nicht aus dem `max_frame_footprint_polygon` herausragen.
- Das Asset darf keine eigene grosse Bodenplatte oder umlaufende Plattform
  zeichnen, wenn der Referenzzustand schon ein Fundament liefert.
- Freigabe erst nach Debug-Overlay-Pruefung mit Referenzzustand.

## 7. Pflicht-Gates Vor Asset-Freigabe

Vor Freigabe eines BuildAreaState-Assets sind Pflicht:

1. Asset existiert im richtigen Canvas und Format.
2. Referenzzustand ist dokumentiert.
3. `build_center` stimmt mit dem Referenzzustand ueberein.
4. Sichtbare Bounds sind gemessen.
5. Support-Fuesse liegen auf erlaubten Kontaktpunkten oder im
   `safe_inner_build_polygon`.
6. Kein Fuss steht sichtbar ausserhalb des Fundaments.
7. Debug-Kompositionen existieren:
   - Base + Referenzzustand,
   - Base + neues Asset,
   - Base + Referenzzustand + neues Asset,
   - Nahansicht,
   - getoente Kontaktpunkt-/Footprint-Pruefung.
8. Contact Sheet existiert.
9. Manuelles Prueffazit ist dokumentiert.
10. Roadmap und Template-Metadaten sind aktualisiert.

Wenn einer dieser Punkte fehlt, bleibt das Asset blockiert.

## 8. Anwendung Auf Waldlichtung / `foundation_complete`

Alle folgenden Werte sind Asset-lokale Pixelkoordinaten im
`1536 x 1024`-Canvas. Sie sind Produktionsanker fuer Asset-Prompts,
Debug-Previews und spaetere Template-Metadaten, nicht automatische
Screen-Pixel.

### Referenzdaten

- `referenceState`: `foundation_complete`
- `referenceAssetPath`:
  `assets/images/world/buildable_islands/forest_clearing/foundation_complete.png`
- `referenceCanvas`: `1536 x 1024`
- `referenceVisibleBounds`: `(525, 386)` bis `(1045, 653)`
- `referenceCenter`: `(785, 519.5)`
- `build_center`: `(785, 520)`

### Sichtbarer Aeusserer Fundamentbereich

Der sichtbare Fundament-/Sockelbereich darf als grobe aeussere Grenze
verstanden werden, nicht als sicherer Pfostenbereich.

Vorgeschlagenes `foundation_complete_outer_polygon`:

```text
[
  (785, 386),
  (950, 420),
  (1045, 505),
  (1015, 585),
  (900, 650),
  (785, 653),
  (650, 650),
  (545, 585),
  (525, 515),
  (610, 425)
]
```

Regel:

- Deko, Gras und unregelmaessige Randsteine koennen innerhalb dieses Polygons
  sichtbar sein.
- Pfostenfuesse sollen nicht auf den aeussersten Randsteinen sitzen.
- Dieses Polygon ist zu gross fuer neue Rohbau-Fuesse.

### Sicherer Innerer Baupolygon

`safe_inner_build_polygon` definiert den Bereich, in dem Pfostenfuesse und
tragende Kontaktpunkte sicher liegen sollen.

```text
[
  (785, 445),
  (895, 470),
  (930, 545),
  (875, 610),
  (785, 620),
  (695, 610),
  (640, 545),
  (675, 470)
]
```

Regeln:

- Neue Pfostenfuesse muessen mit ihrem Mittelpunkt innerhalb dieses Polygons
  liegen.
- Kleine Fussplatten duerfen maximal ca. `18 x 12 px` um den Kontaktpunkt
  ausgreifen.
- Keine Fussplatte darf sichtbar auf Gras/Erde ausserhalb des
  Fundament-Sockels landen.

### Maximaler Frame-Footprint

`max_frame_footprint_polygon` erlaubt sichtbare Holz-/Kontaktflaechen etwas
weiter als der sichere Pfostenbereich, aber nicht bis an die komplette
Foundation-Aussenkante.

```text
[
  (785, 420),
  (925, 455),
  (970, 545),
  (905, 630),
  (785, 640),
  (665, 630),
  (600, 545),
  (645, 455)
]
```

Regeln:

- Horizontale Balken duerfen optisch ueber Support-Punkte laufen.
- Sichtbare Standfuesse, Steinbasen und Kontaktpunkte bleiben innerhalb dieses
  Polygons.
- Ein neues Asset, dessen sichtbare Basis wie ein grosses Tile ausserhalb
  dieses Polygons wirkt, wird gestoppt.

### Support-Anker

Vorgeschlagenes Anchor-Set fuer spaetere `frame_started`-Neuerzeugung:

| Anchor | Asset-lokal | Zweck |
| --- | --- | --- |
| `build_center` | `(785, 520)` | Zentrales Alignment-Zentrum. |
| `rear_left_support` | `(690, 475)` | Hinterer linker Pfosten/Fuss innerhalb des Fundamentes. |
| `rear_right_support` | `(880, 475)` | Hinterer rechter Pfosten/Fuss innerhalb des Fundamentes. |
| `front_left_support` | `(690, 585)` | Vorderer linker Pfosten/Fuss mit Abstand zum Rand. |
| `front_right_support` | `(880, 585)` | Vorderer rechter Pfosten/Fuss mit Abstand zum Rand. |
| `mid_support_center` | `(785, 520)` | Optionaler Mittelpfosten oder Hilfsanker. |
| `mid_support_rear` | `(785, 465)` | Optionaler hinterer Mittelanker. |
| `mid_support_front` | `(785, 600)` | Optionaler vorderer Mittelanker. |

Zulaessige Toleranz fuer Support-Mittelpunkte:

- horizontal: maximal `+/- 16 px`,
- vertikal: maximal `+/- 12 px`,
- groessere Abweichungen nur nach manueller Debug-Freigabe.

### Bereiche, In Denen Keine Pfosten Stehen Duerfen

Pfosten/Fuesse duerfen nicht stehen:

- ausserhalb von `max_frame_footprint_polygon`,
- auf sichtbarem Gras ausserhalb des Fundaments,
- auf der freien Lichtung vor dem Fundament,
- auf Deko-Grasbuescheln oder Blumen an der Sockelkante,
- so nah am Rand, dass die Fussplatte wie neben dem Fundament wirkt.

### Zulassige Silhouette

Fuer `frame_started` als erster Rohbau:

- sichtbare Holz-/Rohbau-Bounds sollten grob innerhalb
  `(600, 315)` bis `(970, 705)` bleiben,
- einzelne obere Pfosten duerfen fuer Lesbarkeit bis ca. `y = 300` reichen,
- keine Dachform,
- keine geschlossenen Waende,
- keine fertige Tuer-/Fenster-Silhouette.

## 9. Aktueller `frame_started`-Status

Aktueller Stand:

- `assets/images/world/buildable_islands/forest_clearing/frame_started.png`
  ist lokal vorhanden und untracked.
- Die gezielte Alignment-Nachbesserung hat rechnerisch Zentrum und Bounds stark
  verbessert.
- Manuelle Sichtpruefung verlangt trotzdem exakteres Aufsetzen auf
  `foundation_complete`.
- Das Asset ist nicht freigegeben.

Grund:

- `frame_started` muss sichtbar auf dem fertigen Fundament/Sockel stehen.
- Pfosten/Fuesse duerfen nicht nur ungefaehr passen.
- Weitere Freigabe ohne Anchor-System wuerde denselben Fehler in spaetere
  Bauzustaende tragen.

Naechste Erlaubnis:

1. Anchor-System fertig dokumentieren.
2. `frame_started` gezielt anhand der Anchor-/Footprint-Regeln neu erzeugen
   oder anpassen.
3. Erneute Alignment-Preview erzeugen.
4. Erst danach erneute Freigabepruefung.

## 10. Naechster Erlaubter Schritt

Nach diesem Dokument ist erlaubt:

- Asset-Prompt fuer `frame_started` um die konkreten Anchor-/Footprint-Regeln
  erweitern,
- oder eine gezielte Asset-Nachbesserung auf Basis dieser Anker vorbereiten.

Weiterhin blockiert:

- Phase-2G-Code,
- App-Integration,
- Freigabe des aktuellen `frame_started.png`,
- produktive Bau-/Lernlogik,
- Persistenz,
- Supabase,
- SRS-/`word_progress`,
- Reward Bridge,
- Ressourcenlogik,
- Sound-/FX-Schicht,
- Expansion,
- PlacedItems,
- Interiors/ObjectDetail.

## 11. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- klar ist, warum `frame_started` nicht weiter freigegeben wird,
- konkrete Anchor-Typen definiert sind,
- konkrete Pixelkoordinaten fuer `foundation_complete` vorliegen,
- Support-Punkte und Footprint-Polygone beschrieben sind,
- zukuenftige Asset-Prompts auf diese Werte verweisen koennen,
- Debug-Overlay-Pruefung vor Freigabe Pflicht ist,
- Code weiterhin blockiert bleibt.
