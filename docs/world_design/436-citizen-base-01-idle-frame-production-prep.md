# 436 Citizen Base 01 Idle Frame Production Prep

Status: idle_production_prep_only / documentation_only
Character: `citizen_base_01`
Target sheet: `citizen_base_01_idle_8dir`
Runtime release: NO
Sprite asset generation: NO
Flame integration: NO

## 1. Ziel

Dieser Slice bereitet die konkrete Produktion von
`citizen_base_01_idle_8dir` vor.

Der Scope ist ausschliesslich Idle: noch kein Walk, keine echten
Sprite-Dateien, keine Dateien unter `assets/images/world/characters/`, keine
Flame-Integration und kein Motion Lab.

## 2. Ausgangsentscheidung

- `citizen_base_01_male` Design-Preview ist `PASS`.
- Die maennliche Figur darf als Grundlage fuer die Idle-Produktion dienen.
- `citizen_base_02_female_reference` bleibt nur Style-Family-Reference.
- Keine Variantenproduktion vor Freigabe der Basisfigur.
- Die PASS-Entscheidung ist keine Sprite-Sheet-, Runtime-, Flame- oder
  Asset-Import-Freigabe.
- Nach
  `438-talvori-modern-2d-25d-character-sprite-style-decision.md` ist der alte
  `96 x 128` Pixel-Art-Teststand verworfen. Diese Prep bleibt historischer
  Dokumentationskontext; aktuelles Ziel ist `128 x 192`.

## 3. Idle-Ziel

Verbindlicher Idle-Zielvertrag:

- 8 Richtungen: `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW`.
- 2 Idle-Frames je Richtung.
- Sheet-Layout: 8 Zeilen x 2 Spalten.
- Framegroesse: `128 x 192` px.
- Sheetgroesse: `256 x 1536` px.
- Hintergrund: transparent.
- Fussanker: fixer `bottomCenter`, Zielwert `(64, 180)`.
- Schatten: separat oder stabil gebacken.
- Keine Runtime-Ganzkoerperrotation.
- Richtungsauswahl spaeter ueber Direction Buckets, nicht ueber freie
  Sprite-Rotation.

## 4. Vereinfachung vor Sprite-Produktion

Aus dem Design-Preview fuer die Idle-Produktion ableiten:

- Weniger Taschen, Gurte, Schnallen und Mini-Ornamente als im Konzeptbild.
- Silhouette erhalten, Detaildichte reduzieren.
- Figur soll neutraler Talvori-Buerger/Entdecker sein, nicht zu heroisch.
- Klare Kleidungsschichten behalten:
  Hemd, Weste oder kurzer Mantel, Guertel, Stiefel, Tasche.
- Kleine Akzentfarbe ist erlaubt, aber nicht ueberladen.
- Profil, Kopf-/Koerperverhaeltnis und Fusslesbarkeit muessen erhalten
  bleiben.
- Keine Waffen, keine Kampfpose, keine Fremd-IP-Anmutung.

## 5. Framegrenzen

Frame-Vertrag:

- Jedes Frame ist exakt `128 x 192` px.
- Safe Padding bleibt eine transparente Sicherheitszone um die Figur.
- Kopf darf oben nicht anschneiden.
- Stiefel und Schatten duerfen unten nicht anschneiden.
- Alle Richtungen muessen gleiche visuelle Hoehe behalten.
- Frame-Mittelachse liegt bei `x=64`.
- Fussanker liegt bei `y=180`.
- Der freie Bereich unter dem Fussanker bleibt fuer Schatten und Padding
  kontrolliert.

## 6. Fussanker- und Schattenregel

- Fussanker ist `bottomCenter` der Standposition.
- Beide Idle-Frames derselben Richtung muessen identischen Fussanker haben.
- Alle Richtungen nutzen denselben Fussanker-Koordinatenvertrag.
- Schatten liegt unter den Fuessen.
- Schatten rotiert nicht frei.
- Schatten darf zwischen Idle-Frames nicht springen.
- Fussanker muss spaeter im Contact Sheet pruefbar markiert werden.
- Wenn ein Frame den Fussanker nicht eindeutig einhaelt, ist der Idle-Kandidat
  nicht intake-ready.

## 7. Idle-Animation

Frame 0/1 duerfen nur sehr kleine Idle-Unterschiede enthalten:

- sehr dezenter Atem- oder Standwechsel,
- minimaler Schulterversatz,
- minimaler Kopfversatz,
- minimaler Stoff- oder Mantelversatz,
- keine Fussverschiebung,
- keine Richtungsveraenderung,
- keine Arm-Puppet-Bewegung,
- keine starke Poseaenderung,
- keine Veraenderung der Koerpergroesse.

Ziel: Die Figur wirkt lebendig, bleibt aber als stillstehender Citizen stabil.

## 8. Produktionsauftrag fuer Idle

Auftrag fuer externe Bild-/Sprite-Produktion:

> Erzeuge `citizen_base_01_idle_8dir` als transparentes PNG-Sprite-Sheet.
> Das Sheet hat 8 Zeilen und 2 Spalten. Die Richtung-Reihenfolge ist
> `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW`. Jedes Frame ist 128 x 192 px.
> Das Idle-Sheet ist 256 x 1536 px. Der Fussanker ist `bottomCenter`, Zielwert
> `(64, 180)`, und muss
> fuer jedes Frame identisch bleiben. Reduziere die Detaildichte des
> Design-Previews, erhalte aber Silhouette, Kopf-/Koerperlesbarkeit,
> Kleidungsschichten, Stiefel und einfache Tasche. Keine Walk-Frames, keine
> Varianten, keine Waffen, keine fremde IP.

Lieferumfang fuer die spaetere Intake-Pruefung:

- `citizen_base_01_idle_8dir.png`
- Contact Sheet mit sichtbaren Framegrenzen und Fussanker-Markierung
- Metadata-Entwurf fuer `citizen_base_01_metadata.md`
- Source-/License-Information

## 9. Metadata-Vorbereitung

Die spaetere Metadata muss mindestens enthalten:

| Feld | Erwartung |
| --- | --- |
| `source` / `license` | Ursprung, Rechte, Talvori-Nutzbarkeit |
| `tool` / `author` | Produktionswerkzeug und Urheber |
| `frame_size` | `128 x 192` |
| `direction_order` | `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW` |
| `frame_count` | `idle=2` je Richtung |
| `foot_anchor` | `bottomCenter`, Zielwert `(64, 180)` |
| `shadow_anchor` | separat oder stabil an Fussanker gebunden |
| `status` | `idle_candidate` |
| `blocked_uses` | keine App-Integration, keine NPC-Population, keine Walk-Animation-Freigabe |

Metadata bleibt Markdown, keine JSON-/YAML-Datei.

## 10. QA vor 2A.2

Die spaetere Idle-Kandidatenpruefung muss pruefen:

- Masse stimmen.
- Transparenz vorhanden.
- Sheet ist 8 Zeilen x 2 Spalten.
- Richtung-Reihenfolge stimmt.
- Fussanker ist in allen Frames identisch.
- Schatten ist stabil.
- Keine abgeschnittenen Koerperteile.
- Keine Frame-Zitterer.
- Keine fremde IP.
- iPhone-Lesbarkeit ist plausibel.
- Detaildichte ist gegenueber dem Konzeptbild reduziert.
- Keine Walk-Frames oder Varianten sind enthalten.

## 11. Naechster Schritt

Nach diesem Prep-Slice:

1. Echte `citizen_base_01_idle_8dir` PNG-Produktion ausserhalb von Codex.
2. Danach `Firenze Character Asset Intake 2A.2-idle`.
3. Kein Motion Lab vor Intake PASS.
4. Keine Walk-Produktion vor sauberem Idle-Intake.

## 12. Diagramm

Erzeugte Dokumentationsgrafik:

```text
docs/world_design/previews/citizen_base_01_idle_frame_prep/citizen_base_01_idle_frame_prep.svg
docs/world_design/previews/citizen_base_01_idle_frame_prep/citizen_base_01_idle_frame_prep.png
```

Das Diagramm zeigt nur den technischen Idle-Frame-Vertrag:

- 8 Zeilen x 2 Spalten,
- historischer Framegroesse-Teststand 96 x 128,
- aktueller Zielwert nach 438: 128 x 192,
- aktueller Fussanker `(64, 180)`,
- Safe Padding,
- Frame 0 / Frame 1 je Richtung,
- QA-Gate vor Asset Intake.

Es erzeugt keine Spielgrafik und keine Figur.

## 13. Grenzen

- Keine App-Integration.
- Keine Flame-Character-Implementierung.
- Keine echten Sprite-Assets.
- Keine Dateien unter `assets/images/world/characters/`.
- Keine KI-Bildgenerierung durch Codex.
- Keine prozeduralen Figuren.
- Keine Aenderung an `pubspec.yaml`.
- Keine Aenderung am Firenze Flame Proof.
- Keine JSON-/YAML-/YML-Dateien.
- Keine Persistenz.
- Kein Commit.

## 14. Ergebnis

Idle-Frame-Vertrag: PASS fuer Produktionsvorbereitung.
Detailreduktionsentscheidung: Konzept-Silhouette behalten, Mini-Ornamente und
Hero-/Abenteurer-Dichte reduzieren.
Aktuelle Zielwerte nach 438: `128 x 192` Frame, `256 x 1536` Idle Sheet,
Fussanker `(64, 180)`.
v1-v4 und lokale leere `96 x 128` Templates bleiben Dokumentations- bzw.
Testkandidaten und sind keine Produktionsquelle.
Naechster Schritt: echte `citizen_base_01_idle_8dir`-Produktion ausserhalb von
Codex, danach `Firenze Character Asset Intake 2A.2-idle`.
