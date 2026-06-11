# M16-DA: Uferwald Playable Map Layer and Mask Architecture

Stand: 2026-06-11

Status: `Docs-/Architecture-Gate / keine Code-, Bild- oder Asset-Freigabe`

Template: `docs/world_design/prompt_templates/docs_only_slice.md`

## 1. Zweck

M16-DA legt eine harte Talvori-Regel fuer spielbare Uferwald- und World-Karten
fest:

> Sichtbares Art-Bild ist nicht die technische Spielkarte.

Ein gerendertes Gesamtbild darf Art-, Atmosphaere-, Kamera- oder Review-
Preview sein. Es darf aber nicht die Quelle sein, aus der Codex, Flutter oder
ein spaeterer Gameplay-Slice Wege, Wasser, Baeume, Hindernisse, Bauzonen,
Grundstuecke, Kollision, Sortierung oder begehbare Flaechen erraten.

Der Slice entsteht nach M16-CP/M16-CQ/M16-CR und den Visit/Wander-Preview-
Polishes. Diese Arbeit hat gezeigt: Ein schoenes Uferwald-Bild kann schnell
spielbar wirken, aber ohne technische Layer/Masks/Zonen bleibt jede Navigation
und jede Bauplatzlogik geraten.

## 2. Eingangsquellen

Fuehrende Quellen:

- `docs/world_design/370-asset-family-and-export-spec.md`
- `docs/world_design/379-uferwald-layer-candidate-intake-and-qa.md`
- `docs/world_design/381-uferwald-anchor-zone-layer-overlay-plan.md`
- `docs/world_design/382-uferwald-mobile-map-camera-research-and-decision.md`
- `docs/world_design/383-talvori-camera-modes-and-visit-wander-rule.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`

Diese Quellen erlauben noch keine Produktkarte. 379 bestaetigt, dass Uferwald
aktuell ein flaches Bitmap mit Review-Kopien ist. 381 visualisiert
Dokumentationszonen. 382/383 definieren Kamera- und Modusregeln. 370 definiert
Asset-Familien und Exportgrenzen. M16-DA fuegt die fehlende Architekturregel
dazwischen: technische Map-Daten muessen vor visueller Spielbarkeit stehen.

## 3. Harte Regel

Fuer jede spielbare Uferwald-/World-Karte gilt:

- Visit/Wander darf keine Wege aus einem Bild erraten.
- Build/Map darf keine Grundstuecke, Build-Zonen oder Hindernisse aus einem
  Bild erraten.
- Object Focus darf keine Objektposition oder Occlusion aus Pixeln erraten.
- Overview darf ein Bild zeigen, aber darf daraus keine Runtime-Map ableiten.
- Codex darf bei Bild-Previews keine Gameplay-Pfade, Collision, Walkability,
  Plot-Footprints, Sort-Bands oder Grundstueckslogik aus Pixeln ableiten.
- ChatGPT/image_gen darf keine final spielbare Karte erzeugen, wenn Codex
  danach Pfade, Masks oder Placement-Regeln nur aus dem Bild raten muesste.
- Ein Bild darf erst sichtbares Rendering werden, wenn die darunterliegende
  technische Layer-/Masken-/Zonenstruktur definiert ist.

Diese Regel gilt auch, wenn das Bild hochwertig, stimmungsvoll oder in einer
isolierten Preview ueberzeugend wirkt.

## 4. Warum M16-DA noetig ist

M16-CY-FIX-3 ist das konkrete Risiko-Beispiel:

- Der Uferwald-Look ist stark genug, um eine Wander-Preview zu tragen.
- Stationsnamen und ein ruhiger Marker machen den Modus spielerischer.
- Der Pfad musste aber am fertigen Bild entlang interpretiert werden.
- Dadurch bleibt der Pfadverlauf geraten und nicht produktionsfaehig.
- Es gibt keine echte Walkability-Maske, keine Hindernis-Layer, keine
  getrennten Wege, keine Runtime-Placement-Zonen und keine verbindliche
  Sortierlogik.

M16-CY-FIX-3 ist deshalb als UX-/Preview-Erkenntnis wertvoll, aber nicht als
Grundlage fuer produktive Navigation, Build-Logik oder Cloud-/Besucheransicht.

## 5. Pflicht-Layer, Masks und Zonen

Bevor aus Uferwald eine spielbare Karte wird, muessen mindestens diese
technischen Ebenen definiert werden:

| Layer / Mask / Zone | Zweck | Darf aus Pixelbild geraten werden? |
| --- | --- | --- |
| `base_rock_shape` | Insel-Silhouette, Klippenkoerper, harte Landmasse. | Nein |
| `grass_terrain_mask` | begehbare/baubare Wiesen- und Bodenflaechen als Terrain-Grundlage. | Nein |
| `water_river_mask` | Meer, Flussarme, Wasserlaeufe, Uferuebergaenge. | Nein |
| `walkable_path_layer` | echte begehbare Wege, Pfadbreiten und Wegknoten. | Nein |
| `tree_obstacle_layer` | Baeume, Hain, Waldkanten und nicht begehbare Vegetation. | Nein |
| `rock_cliff_obstacle_layer` | Felsen, Klippen, harte Hoehenkanten und Blocker. | Nein |
| `buildable_zone_layer` | organische Eignungsraeume fuer freie Bauentscheidungen. | Nein |
| `plot_footprint_layer` | spaetere Objekt-/Gebaeude-Footprints und Groessenklassen. | Nein |
| `no_walk_mask` | harte Sperrflaechen fuer Visit/Wander und Figurenbewegung. | Nein |
| `no_build_mask` | harte Sperrflaechen fuer Build/Map und Placement. | Nein |
| `depth_sort_bands` | Vorder-/Mittel-/Hintergrund- und Occlusion-Zonen. | Nein |
| `landmark_anchor_layer` | benannte Bezugspunkte fuer Hub, Fluss, Hain, Aussicht und spaetere Objekte. | Nein |

Diese Ebenen duerfen textlich, tabellarisch, als JSON/YAML-Spec, als
vektorbasierte Maskenplanung, als Figma-/Design-Overlay oder spaeter als
technische Mapdaten entstehen. Sie duerfen nicht still aus RGB-Pixeln
rekonstruiert werden.

## 6. Richtige Produktionsreihenfolge

Die verbindliche Reihenfolge fuer spielbare Karten lautet:

1. Technische Layout-/Maskenplanung.
2. Pfade, Grundstuecke, Wasser, Baeume, Felsen, Flaechen, Hindernisse,
   Sort-Bands und Anchors als getrennte Daten definieren.
3. Aus diesen Daten Art-Rendering, Layer-Art oder Review-Visuals erzeugen.
4. Danach erst Visit/Wander-, Build/Map-, Object-Focus- oder Overview-
   Interaktion simulieren.
5. Erst nach eigenem Asset-/Engine-/Integration-Gate duerfen Runtime-Assets,
   App-Integration, Persistenz oder BuildState entstehen.

Wenn ein sichtbares Bild zuerst existiert, darf es hoechstens Struktur- oder
Art-Reference sein. Dann muss ein Folge-Gate die technische Karte bewusst
neu definieren, statt sie aus dem Bild abzulesen.

## 7. Modusbezogene Anforderungen

### Build/Map

Build/Map braucht:

- `buildable_zone_layer`,
- `plot_footprint_layer`,
- `no_build_mask`,
- `depth_sort_bands`,
- `landmark_anchor_layer`.

Freie Baukapazitaet bleibt Ortsfreiheit. Es duerfen keine festen
Kategorieplaetze entstehen. Terrain darf Varianten nahelegen, aber nicht hart
blockieren, solange kein eigenes Gate das begruendet.

### Visit/Wander

Visit/Wander braucht:

- `walkable_path_layer`,
- `no_walk_mask`,
- `tree_obstacle_layer`,
- `rock_cliff_obstacle_layer`,
- `water_river_mask`,
- `depth_sort_bands`,
- `landmark_anchor_layer`.

Ein Besucher-Marker darf nur auf technisch begehbaren Pfaden/Zonen laufen.
Stationen brauchen echte Anchor- oder Path-Knoten, nicht nur visuell
plausible Punkte auf einem Bild.

### Object Focus

Object Focus braucht:

- Objekt-/Footprint-Bezug,
- passende Sort-Bands,
- No-Overlap-Regeln,
- Umgebungskontext,
- Rueckweg zu Build/Map oder Visit/Wander.

Object Focus darf nicht aus einem gezoomten Pixelbereich entstehen, wenn
Occlusion, Pivot, Footprint und Interaktionszone fehlen.

### Overview

Overview darf eine gerenderte Gesamtansicht zeigen. Sie bleibt aber Review-
oder Orientierungsmodus. Overview ist keine technische Karte und ersetzt keine
Layer-/Maskendaten.

## 8. KI-Bildtool- und Codex-Grenze

ChatGPT/image_gen oder ein anderes Bildtool darf spaeter:

- Art Direction,
- Atmosphaere,
- Render-Varianten,
- Style-/Structure-References,
- layerbare Bildkandidaten

erzeugen, aber nur, wenn der jeweilige Slice das ausdruecklich erlaubt und
die technischen Layer/Masks/Zonen nicht durch Pixelraten ersetzt werden.

Codex darf:

- Regeln dokumentieren,
- Dateistruktur und Metadaten definieren,
- vorhandene Bilder pruefen,
- QA und Intake durchfuehren,
- technische Specs fuer spaetere Layer/Masks/Zonen vorbereiten.

Codex darf nicht:

- aus einem fertigen Bild Gameplay-Pfade ableiten,
- Collision oder Walkability aus Pixeln raten,
- Grundstuecke oder Build-Zonen aus Pixeln raten,
- technische Runtime-Daten aus einem RGB-Preview-Bild erzeugen,
- ein Bild als spielbare Karte freigeben.

## 9. Commitfaehigkeit kuenftiger Slices

Ein spaeterer Uferwald-/World-/Map-/Build-/Visit-Slice ist nicht
commitfaehig, wenn er spielbare Logik behauptet und eine dieser Fragen mit
NEIN beantwortet:

- Sind `walkable_path_layer` und `no_walk_mask` definiert, wenn Bewegung
  betroffen ist?
- Sind `buildable_zone_layer`, `plot_footprint_layer` und `no_build_mask`
  definiert, wenn Bauen betroffen ist?
- Sind Wasser, Baeume, Felsen und harte Hindernisse als eigene Masks oder
  Layer definiert?
- Sind `depth_sort_bands` fuer Ueberdeckung und Vorder-/Hintergrund klar?
- Sind `landmark_anchor_layer` und relevante Anchors benannt?
- Ist klar, welche Daten technisch fuehrend sind und welches Bild nur
  Rendering/Atmosphaere/Review ist?
- Wird keine Gameplay-Logik aus einem Pixelbild geraten?

Wenn eine Frage offen ist, bleibt der Slice Docs-/Review-/Preview-only.

## 10. Folgepfad

Empfohlener naechster Architekturpfad:

```text
M16-DB Uferwald Technical Layer and Mask Spec
```

Dieser Folge-Slice sollte noch keine App-Integration, keine Assets und keinen
BuildState oeffnen. Er sollte die technischen Ebenen aus Abschnitt 5 als
konkrete Daten-/Dokumentationsstruktur definieren, etwa als Markdown-Spec mit
spaeter optionalem JSON/YAML-Plan.

Erst danach sind sinnvoll:

- ein vektorbasierter Masken-/Zonenplan,
- ein echtes `walkable_path_layer`-Overlay,
- ein `buildable_zone_layer`/`plot_footprint_layer`-Plan,
- ein neues Rendering aus technischen Layern,
- eine Visit/Wander-Preview, die echte technische Pfade nutzt.

## 11. Stop-Regeln

M16-DA gibt nicht frei:

- keinen Code,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- keine Assets,
- keine Dateien unter `assets/`,
- keine Bilder, PNGs, SVGs oder Preview-Ordner,
- keine Engine-ready Candidates,
- keine approved Assets,
- keine Runtime-Mapdaten,
- keine externen Writes,
- keinen Commit.

