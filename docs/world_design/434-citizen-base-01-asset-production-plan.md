# 434 Citizen Base 01 Asset Production Plan

Status: production_plan_only / documentation_only  
Character: `citizen_base_01`  
Runtime release: NO  
Sprite asset generation: NO  
Flame integration: NO

## 1. Ziel

Dieser Slice plant die konkrete Produktion genau einer Talvori-Basisfigur:
`citizen_base_01`.

Zweck ist der spaetere `Firenze Character Motion Lab 2B`. Dieser Plan erzeugt
keine Varianten, keinen Worker, keinen Haendler, kein NPC-System und keine
Figuren-Dateien. Er ist die Produktionsbruecke zwischen der Spezifikation in
`433-talvori-base-character-asset-spec-v1.md` und einem spaeteren
Asset-Intake.

## 2. Produktionsentscheidung

Vergleich der moeglichen Wege:

| Weg | Staerken | Risiken | Entscheidung |
| --- | --- | --- | --- |
| Sprite-Sheet mit Aseprite, Photoshop, Krita oder Pixel-Tool | Schnell pruefbar, Flame-kompatibel, transparente PNGs reichen fuer Motion Proof, geringer Runtime-Aufwand | Asset-Produktion muss sauber Richtung, Fussanker und Frame-Stabilitaet halten | Waehlen |
| Rive-Rig | Gute Vektor-/Rig-Animationen, spaeter stark fuer UI-nahe Figuren | Neue Authoring-Disziplin, Rigging-Aufwand, Motion-Proof waere weniger direkt spritebasiert | Nicht fuer MVP |
| Spine/Rig-System | Stark fuer komplexe Character-Animationen | Neue Runtime-/Toolchain-Komplexitaet, Lizenz-/Pipeline-Aufwand, overpowered fuer eine Basisfigur | Nicht fuer MVP |

Entscheidung fuer den produktionsarmen MVP-Weg:

- transparente PNG-Sprite-Sheets fuer `idle_8dir` und `walk_8dir`,
- keine neue Runtime ausser Flame noetig,
- beste Option fuer schnellen isolierten Motion Proof,
- leichter visuell zu pruefen, bevor App-, Graph- oder NPC-Komplexitaet
  hinzukommt.

## 3. Asset-Anforderungen

Aus 433 uebernommene verbindliche Anforderungen:

- 8 Richtungen: `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW`.
- `idle`: 2 Frames je Richtung.
- `walk`: 4 Frames je Richtung.
- Framegroesse: 96 x 128 px als Startvorschlag.
- Fussanker: fixer `bottomCenter`, vorgeschlagen `(48, 118)`.
- Hintergrund: transparent.
- Figurengroesse: zwischen Frames stabil.
- Schatten: separat oder stabil gebacken, ohne Positionssprung.
- Laufzeit: keine Ganzkoerperrotation.
- Richtung: durch Direction Bucket, nicht durch freie Rotation.
- Stil: Talvori-eigen, kein kopierter fremder Spielstil.

## 4. Dateistruktur

Geplante Struktur, noch nicht erzeugen:

```text
assets/images/world/characters/citizen_base_01/
assets/images/world/characters/citizen_base_01/citizen_base_01_idle_8dir.png
assets/images/world/characters/citizen_base_01/citizen_base_01_walk_8dir.png
assets/images/world/characters/citizen_base_01/citizen_base_01_metadata.md
```

In diesem Slice werden keine Dateien unter
`assets/images/world/characters/` angelegt.

## 5. Metadata-Vertrag

Die spaetere Datei `citizen_base_01_metadata.md` muss mindestens enthalten:

| Feld | Erwartung |
| --- | --- |
| `status` | Asset-Status, z. B. `intake_candidate`, `qa_pass`, `blocked` |
| `source` / `license` | Ursprung, Rechte, Nutzbarkeit fuer Talvori |
| `frame_width` / `frame_height` | Erwartet `96` / `128`, falls nicht bewusst geaendert |
| `directions` | `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW` |
| `frame_counts` | `idle=2`, `walk=4` pro Richtung |
| `direction_order` | Zeilenreihenfolge exakt wie in 433 |
| `foot_anchor` | `bottomCenter`, vorgeschlagen `(48, 118)` |
| `shadow_anchor` | separat oder an Fussanker gebunden |
| `scale_hint` | geplanter Flame-/World-Scale-Hinweis |
| `allowed_runtime_use` | isolierter Motion Proof, spaeter echte Character-Runtime |
| `blocked_uses` | keine App-Integration, keine NPC-Menge, keine freie Rotation |
| `qa_status` | Contact Sheet, Transparenz, Fussanker, Richtungen, iPhone-Lesbarkeit |

Metadata bleibt Markdown, keine JSON-/YAML-Datei.

## 6. Qualitaetspruefung vor Import

Vor dem Kopieren in `assets/images/world/characters/citizen_base_01/` muss
ein Asset-Intake pruefen:

- Contact Sheet vorhanden und lesbar.
- Alle Frames haben gleiche Groesse.
- Transparenz ist vorhanden.
- Fussanker ist in jedem Frame identisch.
- Kein Koerperteil ist abgeschnitten.
- Keine Frame-Zitterer zwischen Animationsframes.
- Richtungen sind konsistent und wirken wie dieselbe Figur.
- Diagonalen `NE`, `SE`, `SW`, `NW` wirken plausibel.
- Schatten bleibt stabil.
- Figur ist auf iPhone im typischen City-Zoom lesbar.
- Keine Fremd-IP.
- Kein kopierter fremder Spielstil.
- Keine prozedurale Code-Figur oder Fake-Sprite-Attrappe.

## 7. Produktionsablauf

Verbindliche Reihenfolge:

1. Style-Mini-Brief fuer `citizen_base_01` erstellen.
2. Erste neutrale Figur entwerfen.
3. `idle` fuer `N`, `S`, `E`, `W` pruefen.
4. `walk` fuer `N`, `S`, `E`, `W` pruefen.
5. Diagonalen `NE`, `SE`, `SW`, `NW` ergaenzen.
6. Sprite-Sheets `idle_8dir` und `walk_8dir` bauen.
7. Contact Sheet erzeugen.
8. `citizen_base_01_metadata.md` schreiben.
9. QA durchfuehren.
10. Erst danach `Firenze Character Asset Intake 2A.2`.
11. Erst nach 2A.2 PASS darf `Firenze Character Motion Lab 2B` starten.

## 8. Blocker

Wenn keine echten Assets bereitstehen, bleibt:

```text
CHARACTER_ASSET_BLOCKER
```

Codex darf keine Code-Figur, Kreisfigur, Strichfigur, Puppet-Figur oder
Fake-Sprite-Figur als Ersatz bauen. Es darf auch kein Platzhalter-Sprite in
`assets/images/world/characters/` erzeugt werden.

## 9. Naechster Slice

Naechster erlaubter Slice:

```text
Firenze Character Asset Intake 2A.2
```

2A.2 darf nur starten, wenn echte PNG-Sheets oder echte Einzelbilder
vorliegen. Der Slice prueft:

- Masse,
- Transparenz,
- Fussanker,
- Direction-Reihenfolge,
- Frame Counts,
- Metadata,
- Rechte-/Source-Status,
- Visual-QA.

Erst nach Freigabe in 2A.2 duerfen Dateien nach
`assets/images/world/characters/citizen_base_01/` kopiert werden. Kein Motion
Lab vor 2A.2 PASS.

## 10. Prozessdiagramm

Erzeugte Dokumentationsgrafik:

```text
docs/world_design/previews/citizen_base_01_asset_production_plan/citizen_base_01_asset_production_flow.svg
docs/world_design/previews/citizen_base_01_asset_production_plan/citizen_base_01_asset_production_flow.png
```

Das Diagramm zeigt nur den Prozess:

```text
Spec 433 -> Art production -> Sprite sheets -> Metadata -> QA
-> Asset Intake 2A.2 -> Motion Lab 2B
```

Es erzeugt keine Spielgrafik und keine Sprite-Assets.

## 11. Grenzen

- Keine App-Integration.
- Keine Flame-Character-Implementierung.
- Keine echten Sprite-Assets.
- Keine Dateien unter `assets/images/world/characters/`.
- Keine KI-Bildgenerierung.
- Keine prozeduralen Figuren.
- Keine Aenderung an `pubspec.yaml`.
- Keine Aenderung am Firenze Flame Proof.
- Keine JSON-/YAML-/YML-Dateien.
- Keine Persistenz.
- Kein Commit.

## 12. Ergebnis

Produktionsweg: transparente PNG-Sprite-Sheets fuer `idle_8dir` und
`walk_8dir`.  
Asset-Produktion in diesem Slice: NO.  
Runtime-/Flame-Integration in diesem Slice: NO.  
Naechster enger Slice: `Firenze Character Asset Intake 2A.2`, sobald echte
`citizen_base_01`-PNG-Sheets oder Einzelbilder bereitstehen.

