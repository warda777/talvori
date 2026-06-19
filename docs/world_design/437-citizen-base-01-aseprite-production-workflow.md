# 437 Citizen Base 01 Aseprite Production Workflow

Status: documentation_only / toolchain_check
Character: `citizen_base_01`
Target sheet: `citizen_base_01_idle_8dir`
Runtime asset import: NO
Flame integration: NO
Motion Lab: NO

## 1. Ziel

Dieser Slice legt den praktischen Workflow fuer die naechste manuelle
Asset-Produktion von `citizen_base_01_idle_8dir` fest.

Er erzeugt keine neuen Character-Assets unter `assets/`, keine Runtime-Daten,
keine Flame-Integration und kein Motion Lab.

## 2. Toolchain-Check

Startzustand:

- `git status --short`: clean.
- `aseprite --version`: PASS im Nutzer-Terminal.
- Aseprite-Version: `Aseprite 1.3.17.2-arm64`.
- Aseprite ist ueber Steam installiert.
- Ausfuehrbarer Pfad:
  `/Users/andreaswarda/Library/Application Support/Steam/steamapps/common/Aseprite/Aseprite.app/Contents/MacOS/aseprite`.
- Wrapper: `$HOME/bin/aseprite`.
- `.zshrc` enthaelt:
  `export PATH="$HOME/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"`.

Konsequenz:

- Die Aseprite-CLI ist fuer die naechste manuelle Sprite-Produktion erreichbar.
- Der Zielcheck bleibt: `aseprite --version` muss vor einem Aseprite-basierten
  Export erfolgreich eine Version ausgeben.
- Codex darf Aseprite-CLI-Schritte nur dann als reproduzierbar dokumentieren,
  wenn dieser Check im ausfuehrenden Terminal erfolgreich ist.

## 3. Warum Aseprite

Aseprite ist fuer diesen Schritt das richtige Werkzeug, weil die Figur als
echtes Sprite-Sheet mit kontrollierbarer Transparenz, festen Frames und
pruefbarem Fussanker produziert werden muss.

Wichtig sind:

- echte Alpha-Transparenz statt nachtraeglicher Freistellung,
- pixelgenaue Kontrolle ueber Bein-, Arm- und Schattenbereiche,
- feste Frame-Grenzen,
- stabile Fussanker,
- manuelle Sichtpruefung pro Richtung und Idle-Frame.

## 4. Warum RGB-Contact-Sheet-Extraktion stoppt

Die bisherigen Kandidaten v1 bis v4 zeigen, dass automatische Freistellung aus
RGB-Contact-Sheets fuer `citizen_base_01` nicht zuverlaessig genug ist.

Beobachtete Risiken:

- eingebrannte Checkerboard- oder helle Hintergrundreste,
- weisse Restflaechen zwischen Beinen,
- helle Restbereiche an Arm oder Ellbogen,
- Halos um Schuhe und Schatten,
- unklare Trennung zwischen heller Kleidung und Hintergrund,
- fehlende Source-/License-/Tool-/Author-Metadaten fuer einen echten
  Asset-Import.

Ab jetzt gilt fuer den naechsten PASS-faehigen Kandidaten:

- keine automatische RGB-Freistellung als Hauptweg,
- kein Retuschieren durch Codex als Ersatz fuer sauberen Export,
- keine neue Figur und keine neue Posefamilie durch Codex.

## 5. Ziel fuer saubere Produktion

Verbindliches Idle-Ziel:

- echtes transparentes PNG,
- Gesamtgroesse `256 x 1536` px,
- Layout `2 x 8`,
- Framegroesse `128 x 192` px,
- Direction Order: `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW`,
- Spalte 1: Idle Frame 0,
- Spalte 2: Idle Frame 1,
- Fussanker: `(64, 180)` in jedem `128 x 192` Frame,
- 16 gefuellte Frames,
- keine Walk-Frames,
- keine Varianten,
- keine Bodenplatten,
- kein eingebranntes Checkerboard.

Hinweis nach
`438-talvori-modern-2d-25d-character-sprite-style-decision.md`: Der fruehere
`96 x 128` / `192 x 1024` Pixel-Art-Teststand und die lokalen leeren
`96 x 128` Templates unter `_incoming_character_assets/` sind verworfen und
werden nicht importiert.

## 6. Manuelle Arbeit in Aseprite

Vor jedem Export pruefen:

- Hintergrund ist wirklich transparent.
- Zwischen Beinen und Armen gibt es keine weissen oder hellen Restflaechen.
- Kopf, Haare, Haende, Stiefel, Tasche und Schatten sind nicht abgeschnitten.
- Jede Figur bleibt vollstaendig innerhalb des `128 x 192` Frames.
- Der Fussanker bleibt frameuebergreifend stabil bei `(64, 180)`.
- Schatten liegt nur unter den Fuessen und springt nicht zwischen Frame 0 und
  Frame 1.
- Es gibt keine Bodenflaechen, Panels, Labels, Rasterlinien oder Text im
  Sprite-Sheet.
- Das Sheet enthaelt keine sichtbare technische Arbeitsumgebung.
- Die Detaildichte bleibt fuer iPhone-Landscape-Lesbarkeit reduziert.

Empfohlene Aseprite-Arbeitsweise:

1. In einer `.aseprite`-Arbeitsdatei mit festen `128 x 192` Frames arbeiten.
2. Pro Richtung zwei Idle-Frames als minimale Atem-/Standvariation anlegen.
3. Fussanker und Schatten in der Arbeitsdatei sichtbar kontrollieren.
4. Vor Export auf transparentem, dunklem und hellem Hintergrund pruefen.
5. Exakt als transparentes PNG-Sheet exportieren.
6. Kandidat zuerst nach `_incoming_character_assets/` legen, nicht nach
   `assets/`.

## 7. Codex-Rolle

Codex darf:

- CLI-Verfuegbarkeit pruefen,
- exportierte PNGs technisch pruefen,
- Dimensionen, Alpha, Raster, Frames und Fussanker dokumentieren,
- Dark-/Light-/Anchor-Review-Previews erzeugen,
- Intake-Reviews schreiben,
- klare Fixlisten formulieren.

Codex darf nicht:

- automatisch neue Figuren erzeugen,
- prozedurale Ersatzfiguren zeichnen,
- RGB-Contact-Sheets als Hauptweg freistellen,
- Koerper, Kleidung, Pose oder Stil retuschieren,
- Character-Dateien nach `assets/images/world/characters/` importieren,
- Motion Lab oder Flame-Integration starten,
- JSON-/YAML-/YML-Metadaten erzeugen.

## 8. Naechster Workflow

```text
Design Preview
-> Manual Aseprite Cleanup
-> Exact Sprite Sheet Export
-> Codex Intake
-> Import Gate
-> Motion Lab
```

Der naechste produktive Schritt ist ein manueller Aseprite-Export eines
transparenten `citizen_base_01_idle_8dir`-Kandidaten nach
`_incoming_character_assets/`.

Motion Lab 2B bleibt gesperrt, bis:

- ein formaler Idle-Intake PASS ist,
- Source-/License-/Tool-/Author-Metadaten vorliegen,
- ein eigenes Import-Gate den Import nach `assets/images/world/characters/`
  freigibt.

## 9. Ergebnis

Toolchain-Status: PASS / CLI erreichbar.

Aseprite-Version: `1.3.17.2-arm64`.

Workflow-Status: PASS als Produktionsanweisung.

RGB-Contact-Sheet-Extraktion: gestoppt als Hauptweg.

Aktuelle Zielwerte nach 438: `128 x 192` Frame, `256 x 1536` Idle Sheet,
`512 x 1536` Walk Sheet, Fussanker `(64, 180)`.

v1-v4 und lokale leere `96 x 128` Templates bleiben Dokumentations- bzw.
Testkandidaten und sind keine Produktionsquelle.

Naechster Schritt: manueller Aseprite-Export eines echten transparenten
`256 x 1536` PNG-Kandidaten nach `_incoming_character_assets/`.
