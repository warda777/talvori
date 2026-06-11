# M16-CL: Anchor, Registration and Placement Logic Gate

Stand: 2026-06-11

Status: `Markdown-Docs-/Registration-Gate / keine Bild- oder Asset-Freigabe`

Template: `docs/world_design/prompt_templates/art_master_reference_slice.md`

## 1. Zweck und Non-Goals

M16-CL definiert einen festen Pruefstandard fuer Anchor-, Registration- und
Placement-Logik in spaeterer Talvori-Layer- und Bildarbeit.

Warum das zwingend ist:

- Layer muessen spaeter exakt uebereinander liegen.
- Bildvarianten duerfen nicht frei im Crop driften.
- Slots, Build Stations, Bauphasen, Figuren und HUD brauchen stabile
  Bezugspunkte.
- Candidate A ist als Struktur stark, aber ohne Anchor-/Registration-Logik
  nicht produktionsreif.
- Spaetere externe Bildarbeit braucht reproduzierbare Canvas-, Framing-,
  Origin-, Pivot-, Anchor-, Zone- und Sortierregeln.

Non-Goals:

- keine neuen Bilder,
- keine PNG/SVG,
- kein Preview-Ordner,
- keine Assets,
- keine Dateien unter `assets/`,
- keine Engine-ready Candidates,
- keine approved Assets,
- kein Code,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- keine Tests,
- keine externen Writes,
- kein Commit.

M16-CL ist ein Gate-Standard. Es ist keine Bild-, Asset-, Code-, App- oder
Engine-ready-Freigabe.

## 2. Eingangsquellen und Abgrenzung

Fuehrende Quellen:

- `docs/world_design/367-talvori-art-bible-v1.md`
- `docs/world_design/368-starter-island-master-reference-set.md`
- `docs/world_design/370-asset-family-and-export-spec.md`
- `docs/world_design/372-starter-island-base-candidate-generation-gate.md`
- `docs/world_design/373-candidate-a-structure-lock-and-postprocess-brief.md`
- `docs/world_design/374-candidate-a-layer-and-postprocess-plan.md`
- `docs/world_design/375-candidate-a-external-postprocess-and-layer-production-brief.md`
- `docs/world_design/previews/m16_cg_starter_island_base_candidate_generation/talvori_island_base_uferhain_candidate_metadata.md`
- `docs/world_design/previews/m16_cg_starter_island_base_candidate_generation/talvori_island_base_uferhain_candidate_a_1x.png`

Abgrenzung:

- M16-CG erzeugte Candidate A als Dokumentationscandidate.
- M16-CI sperrte Candidate A nur als Strukturreferenz.
- M16-CJ plante Layer- und Postprocess-Familien.
- M16-CK schrieb den externen Postprocess-/Layer-Production-Brief.
- M16-CL macht Anchor-/Registration-/Placement-Logik zum Pflichtstandard.

## 3. Professionelle Grundregel

Talvori-Layerproduktion folgt kuenftig dieser Grundlogik:

```text
stable canvas
-> stable framing
-> defined origin
-> layer-family pivot rules
-> named anchors
-> placement zones
-> no-build / no-overlap zones
-> layer order
-> depth / sorting metadata
-> QA before image/layer/asset progress
```

Kein spaeterer Bild-, Layer-, Candidate-, Asset- oder Engine-ready-Slice darf
sich nur auf "sieht passend aus" stuetzen. Ueberlagerbarkeit muss ueber
Canvas, Registrierung, Anchors, Zonen und Sortierung dokumentiert sein.

## 4. Feste Canvas- und Framing-Regel

Jede verwandte Layerfamilie braucht eine feste Dokumentations-Canvas.

Pflicht:

- gleiche Canvas-Groesse fuer verwandte Layer,
- gleiche Seitenratio,
- gleiche Kamera/Perspektive,
- gleiche Inselposition im Canvas,
- gleiche Padding-/Randlogik,
- keine frei driftenden Ausschnitte,
- keine nachtraeglichen Crops pro Layer,
- keine Layer, die nur durch visuelles Verschieben "ungefaehr passen".

Empfohlene Dokumentationsregel fuer Uferhain:

```text
canvas_family: uferhain_island_base
ratio: 1:1 square
scale_variant: 1x documentation candidate
origin_mode: top_left_normalized_plus_world_origin
coordinate_space: normalized_0_1 and optional pixel coordinates
framing_lock: island silhouette remains inside the same safe canvas bounds
```

Die aktuelle Candidate-A-Datei ist ein Dokumentationsbild, keine finale
Canvas-Freigabe. Spaetere Layer-Candidates muessen ihre eigene Canvas-Groesse
und Framing-Regel dokumentieren.

## 5. Origin- und Pivot-Logik

Talvori braucht zwei Ebenen von Origins:

| Begriff | Regel |
| --- | --- |
| `canvas_origin` | Top-left des festen Canvas: `(0,0)` normalisiert, `(width,height)` optional in Pixeln. |
| `world_origin` | Spielweltlicher Hauptbezugspunkt, fuer Uferhain vorlaeufig `hub_center_anchor`. |
| `layer_pivot` | Layer-spezifischer Ankerpunkt fuer Registration, nicht automatisch Bildmitte. |
| `placement_pivot` | Objekt-/Station-/Figurenbezugspunkt fuer spaetere Platzierung. |

Pivot-Regeln je Layer-Familie:

| Layer-Familie | Pivot-Regel |
| --- | --- |
| `island_base` | Pivot am `world_origin`, aber Canvas bleibt top-left registriert. |
| `water_paths` | Pivot am `world_origin`; Wasser muss mit Inselkante registrieren. |
| `terrain_layers` | Pivot am `world_origin`; Hoehen/Hain/Felsen muessen Inselbasis decken. |
| `slot_markers` | Jeder Marker hat eigenen Anchor, Layer registriert zusaetzlich am `world_origin`. |
| `build_stations` | Placement-Pivot am gewaehlten Slot-Anchor. |
| `building_phases` | Placement-Pivot am jeweiligen Build-Footprint-Anchor. |
| `workers_companions` | Pivot am Fuss-/Standpunkt der Figur, nicht an der Bildmitte. |
| `ui_hud_bubbles` | Pivot an UI-Safe-Area oder Weltanchor plus Offset, niemals in Weltlayer eingebrannt. |

Spaetere Platzierungen beziehen sich nie auf frei geratenes Auge-Mass. Sie
beziehen sich auf Anchor IDs und dokumentierte Offsets.

## 6. Anchor-Point-System

Anchor Points sind benannte, dokumentierte Bezugspunkte im Canvas und in der
Weltstruktur.

Pflicht-Anchors fuer Uferhain:

| Anchor ID | Bedeutung | Candidate-A-Bezug | Darf Kategorie erzwingen? |
| --- | --- | --- | --- |
| `main_build_area_anchor` | Primaere breite Bau-/Reserveflaeche. | Grosse zentrale Lichtung / mittlere Inselterrasse. | Nein |
| `house_primary_anchor` | Erster Haus-Proof-Anker fuer spaetere Tests. | Innerhalb der zentralen Reserve, aber nur als Proof-Anker. | Nein |
| `hub_center_anchor` | Weltlicher Mittelpunkt und Orientierungsanker. | Zentrum der grossen Lichtung. | Nein |
| `river_entry_anchor` | Oberer/seitlicher Eintritt des Fluss-/Uferarms. | Linker/oberer Wasserarm. | Nein |
| `river_exit_anchor` | Unterer/seitlicher Austritt oder Weiterlauf des Wasserbezugs. | Linker/unterer Ufer-/Wasseruebergang. | Nein |
| `grove_anchor` | Hain-/Waldidentitaet. | Oberer/rechter dichter Hain. | Nein |
| `reserve_zone_anchor_north` | Noerdliche neutrale Reserve. | Obere Lichtung / Hainrandflaeche. | Nein |
| `reserve_zone_anchor_south` | Suedliche neutrale Reserve. | Untere Wiesen-/Strandreserve. | Nein |

Empfohlene weitere Anchors:

- `reserve_zone_anchor_west`
- `reserve_zone_anchor_east`
- `shoreline_anchor_south`
- `cliff_edge_anchor_east`
- `small_islet_anchor_west`
- `safe_ui_anchor_top_right`

Benennungsstandard:

```text
<subject>_<purpose>_anchor
```

Beispiele:

- `hub_center_anchor`
- `river_entry_anchor`
- `reserve_zone_anchor_north`
- `build_station_anchor_selected_slot`

## 7. Anchor-Dokumentation

Jeder Anchor muss spaeter mindestens diese Felder haben:

```text
anchor_id:
anchor_type:
canvas_family:
coordinate_space:
normalized_x:
normalized_y:
pixel_x:
pixel_y:
source_reference:
layer_family:
purpose:
placement_zone:
sort_band:
allowed_offsets:
no_overlap_radius:
confidence:
qa_status:
notes:
```

Regeln:

- `normalized_x` und `normalized_y` sind Pflicht fuer Dokumentationsarbeit.
- Pixelkoordinaten sind optional, aber empfohlen, sobald Canvasgroesse fix ist.
- `source_reference` muss Candidate A, Postprocess-Candidate oder Master
  Reference nennen.
- `confidence` unterscheidet `rough_from_structure`, `measured_from_canvas`,
  `locked_after_review`.
- Anchors mit `rough_from_structure` duerfen keine Engine-ready- oder
  Runtime-Platzierung freigeben.

## 8. Footprint- und Placement-Zonen

Talvori trennt Anchor Points von Zonen. Ein Anchor ist ein Punkt; eine Zone ist
eine Flaeche oder Regelregion.

| Zone | Bedeutung | Darf jetzt produktiv platzieren? |
| --- | --- | --- |
| `buildable_footprint` | Flaeche, auf der spaeter ein Objekt/Station/Gebaeude liegen koennte. | Nein |
| `soft_placement_zone` | Weiche, natuerliche Reserve fuer spaetere Platzierung. | Nein |
| `reserve_zone` | Langfristige Flaechenreserve ohne aktuelle Platzierung. | Nein |
| `no_build_zone` | Wasser, dichter Hain, Klippen, wichtige Wege oder geschuetzte Rander. | Nein |
| `no_overlap_zone` | Schutzradius um Hain, Wasserarm, Build Station, Figuren, HUD oder Bauphase. | Nein |
| `water_only_zone` | Wasserflaechen und Uferarm. | Nein |
| `terrain_sensitive_zone` | Hang, Fels, Hainrand, Strand oder andere variantensensible Flaechen. | Nein |

Klare Trennung:

- Neutrale Reserve ist noch keine echte Platzierung.
- Ein Buildable Footprint ist noch kein Slot-State.
- Ein Anchor ist kein BuildState.
- Eine Zone schreibt keine Persistenz.
- Terrain darf Varianten nahelegen, aber keine Kategorie hart blockieren.

## 9. Layer-Reihenfolge

Feste Reihenfolge fuer spaetere Ueberlagerung:

```text
background_water_or_void
-> island_base
-> water_paths
-> terrain_layers
-> fixed_landmarks
-> slot_markers
-> selected_slot_focus
-> build_stations
-> building_phases
-> workers_companions
-> work_reactions
-> ui_hud_bubbles
```

Diese Reihenfolge ist eine Dokumentations- und QA-Regel. Sie ist noch keine
Flutter-Implementierung.

Regeln:

- `ui_hud_bubbles` werden nie in Weltlayer eingebrannt.
- `workers_companions` liegen ueber Terrain/Bauobjekten, aber unter Bubbles.
- `slot_markers` liegen ueber Terrain, aber unter Build Station und
  Bauphasen.
- `water_paths` muessen mit Inselkante und Terrain registriert sein.
- `building_phases` muessen am Placement-Footprint haften.

## 10. Depth- und Sorting-Logik

Depth darf nicht aus Pixeln geraten werden. Jeder spaetere Layer- oder
Object-Candidate braucht Sorting-Metadaten.

Pflichtfelder:

```text
sort_band:
sort_anchor:
sort_offset:
occlusion_rule:
foreground_rule:
background_rule:
```

Empfohlene Sort-Bands:

| Sort-Band | Bedeutung |
| --- | --- |
| `background` | Wasser/Leere ausserhalb der Insel. |
| `base` | Inselbasis und grosse Landmasse. |
| `terrain_low` | Boden, Gras, Wege, flache Terrainflaechen. |
| `terrain_high` | Felsen, Hain, Baumkronen, Hoehenkanten. |
| `interactive_ground` | Slotmarker, gewaehlter Slot, Build-Station-Bodenanker. |
| `build_object` | Build Station, Bauphase, Ghost. |
| `character` | Worker, Tali, Vori. |
| `reaction` | Staub, Materialreaktion, kleine Effekte. |
| `hud` | Bubbles, Safe Actions, UI-Hinweise. |

Grundregel:

- In 2.5D kann spaeter `screen_y` beim Sortieren helfen, aber niemals ohne
  `sort_band` und Anchor-Metadaten.
- Baumkronen und Hain duerfen Figuren nicht unklar verschlucken.
- Build Station darf Slotmarker ueberdecken, aber nicht den gewaehlten Ort
  unlesbar machen.
- HUD darf keine Build Station, Figur oder Bauphase verdecken.

## 11. Candidate-A-Bezug

Aus Candidate A sollen spaeter abgeleitet werden:

- `hub_center_anchor` aus der zentralen Lichtung,
- `main_build_area_anchor` aus der grossen mittleren Reserveflaeche,
- `house_primary_anchor` als Proof-Anker innerhalb der zentralen Reserve,
- `river_entry_anchor` aus dem oberen/seitlichen Wasserarm,
- `river_exit_anchor` aus dem unteren/seitlichen Wasserbezug,
- `grove_anchor` aus der oberen/rechten Hainzone,
- `reserve_zone_anchor_north` aus der oberen Hainrand-/Lichtungsreserve,
- `reserve_zone_anchor_south` aus der unteren Wiesen-/Strandreserve,
- `no_build_zone` fuer Wasser, dichten Hain, harte Klippen und Aussenwasser,
- `terrain_sensitive_zone` fuer Hainrand, Felsen, Hoehen und Strand.

Nicht direkt uebernommen werden:

- Pixel,
- finale Licht-/Farbqualitaet,
- eingebackene Wege,
- pad-artige Lichtungsformen,
- fertige Bauplaetze,
- Kategorieplaetze,
- UI, Texte, Pins oder Icons,
- monolithisches Bild als Runtime-Basis.

Warum Candidate A ohne diese Logik nicht produktionsreif ist:

- Es ist ein flaches Dokumentationsbild.
- Es hat keine Canvas-Registration-Metadaten.
- Es hat keine gemessenen Anchor Points.
- Es hat keine Placement-Zonen.
- Es hat keine No-Build-/No-Overlap-Regeln.
- Es hat keine Sort-Bands.
- Es trennt Wasser, Terrain, Slots, Stationen, Figuren und HUD noch nicht.

## 12. QA-Regeln

Jeder kuenftige Bild-, Layer- oder Candidate-Slice muss diese Fragen mit JA
beantworten:

- Canvas-Regel vorhanden?
- Framing stabil?
- Origin/Pivot dokumentiert?
- Anchor Points benannt?
- Placement-Zonen dokumentiert?
- No-Build-Zonen dokumentiert?
- No-Overlap-Zonen dokumentiert?
- Layer-Reihenfolge dokumentiert?
- Depth-/Sorting-Logik dokumentiert?
- Spaetere Ueberlagerbarkeit plausibel?
- Candidate A nur Strukturreferenz, nicht Pixelziel?
- Kein `assets/`-Pfad?
- Kein Engine-ready- oder approved-Asset-Status?

Wenn eine der ersten zehn Fragen NEIN ist, ist der Slice nicht commitfaehig.
Wenn Pfad- oder Statusschutz NEIN ist, ist der Slice blockiert.

## 13. Metadatenstandard fuer spaetere Layer-Candidates

Spaetere Layer-Candidates muessen mindestens diese Registration-Felder
ergaenzen:

```text
canvas_family:
canvas_width:
canvas_height:
canvas_ratio:
framing_lock:
canvas_origin:
world_origin_anchor:
layer_pivot_anchor:
anchor_manifest:
placement_zone_manifest:
no_build_zone_manifest:
no_overlap_zone_manifest:
layer_order_index:
sort_band:
sort_anchor:
sort_offset:
registration_qa_status:
```

Ohne diese Felder darf ein Candidate nicht zu `engine_ready_candidate`
aufsteigen.

## 14. Stop-Regeln

- Keine Bildfreigabe ohne Anchor-/Registration-Pruefung.
- Keine Layer-Candidates ohne Placement-/Anchor-Logik.
- Keine neuen Bilder in M16-CL.
- Keine PNG/SVG.
- Kein Preview-Ordner.
- Keine Assets.
- Keine Dateien unter `assets/`.
- Keine Engine-ready Candidates.
- Keine approved Assets.
- Kein Code.
- Keine Flutter-/Dart-Dateien.
- Keine App-Integration.
- Keine Route.
- Keine Navigation.
- Keine Persistenz.
- Kein BuildState.
- Keine Tests.
- Keine externen Writes.
- Kein Commit.

## 15. Folgepfad

Erst nach M16-CL darf spaetere ChatGPT/image_gen- oder externe Bildarbeit fuer
Layer-Candidates sinnvoll weitergehen.

Naechster moeglicher Slice:

```text
M16-CM Candidate A Anchor Manifest and Layer Candidate Generation Brief
```

Dieser Folge-Slice duerfte nur mit ausdruecklicher Freigabe Bilder oder
externe Toolarbeit oeffnen. Ohne diese Freigabe bleibt der naechste Schritt ein
weiterer Docs-/QA-Gate-Slice.
