# M16-CM: Candidate A Anchor Manifest and Layer Generation Brief

Stand: 2026-06-11

Status: `Markdown-Docs-/Anchor-Manifest-Brief / keine Bild-, Asset-, Code- oder Engine-ready-Freigabe`

Template: `art_master_reference_slice`

## 1. Zweck und Non-Goals

M16-CM uebersetzt Candidate A aus M16-CG in ein konkretes
Anchor-/Placement-/Registration-Manifest und einen Brief fuer spaetere
Layer-Candidate-Bildarbeit.

Der Slice beantwortet:

- welche Anchors aus Candidate A strukturell abgeleitet werden,
- welche Placement-, No-Build- und No-Overlap-Zonen fuer Uferhain gelten,
- welche Layerfamilien diese Anchors spaeter sichtbar oder ableitbar halten
  muessen,
- welche QA vor jeder weiteren Bild-/Layerproduktion zwingend ist.

Non-Goals:

- keine neuen Bilder,
- keine PNG/SVG,
- kein Preview-Ordner,
- keine Assets und keine Dateien unter `assets/`,
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

Codex darf Candidate A lesen, einordnen und strukturieren. Codex darf
Candidate A nicht nachzeichnen, keine KI-Bildtools anstossen und keine
Bildvarianten erzeugen.

## 2. Eingangsquellen und Abgrenzung

Fuehrende Quellen:

- `367-talvori-art-bible-v1.md`
- `368-starter-island-master-reference-set.md`
- `370-asset-family-and-export-spec.md`
- `373-candidate-a-structure-lock-and-postprocess-brief.md`
- `374-candidate-a-layer-and-postprocess-plan.md`
- `375-candidate-a-external-postprocess-and-layer-production-brief.md`
- `376-anchor-registration-and-placement-logic-gate.md`
- `previews/m16_cg_starter_island_base_candidate_generation/talvori_island_base_uferhain_candidate_metadata.md`
- `previews/m16_cg_starter_island_base_candidate_generation/talvori_island_base_uferhain_candidate_a_1x.png`

Abgrenzung:

- Candidate A bleibt Primaer-Structure-Reference.
- Candidate A ist kein Pixelziel.
- Candidate A ist kein Asset.
- Candidate A ist kein finales Zielbild.
- Candidate A ist kein Engine-ready Candidate.
- Candidate A ist keine App- oder Flutter-Grundlage.
- Alle Koordinaten in diesem Dokument sind `rough_from_structure`, nicht
  gemessen, nicht final und nicht produktionsfaehig.

## 3. Candidate-A-Anchor-Manifest

Manifest-Grundfelder:

| Feld | Wert |
| --- | --- |
| `manifest_id` | `m16_cm_candidate_a_anchor_manifest_v1` |
| `slice_id` | `M16-CM` |
| `source_candidate` | `talvori_island_base_uferhain_candidate_a_1x.png` |
| `canvas_family` | `uferhain_island_base` |
| `canvas_origin` | `top_left_normalized_0_0` |
| `world_origin` | `hub_center_anchor` |
| `layer_pivot` | `world_origin_unless_family_override` |
| `coordinate_space` | `normalized_0_1_rough_from_structure` |
| `framing_lock` | `square_documentation_canvas_same_island_silhouette_safe_bounds` |
| `anchor_precision` | `rough_from_structure` |
| `qa_status` | `structure_manifest_only_needs_measured_canvas_review` |
| `max_status` | `structure_reference_manifest` |

Registration-Regel:

Spaetere Layer-Candidates duerfen Candidate A nicht als Pixelbild uebernehmen.
Sie muessen aber die Strukturbeziehungen reproduzierbar halten: Inselkontur,
Wasserbezug, zentraler Hub, Hain, Hoehen/Randbereiche, Reserveflaechen,
No-Build-Zonen und spaetere Safe Areas muessen anhand dieses Manifests
ueberpruefbar bleiben.

## 4. Anchor-Status und Koordinatenwarnung

Die folgenden normalized-Werte sind absichtlich grob. Sie beschreiben, wo
Candidate A visuell Struktur anbietet. Sie ersetzen keine spaetere
Mess-/Figma-/Postprocess-Registration und duerfen nicht direkt in Runtime,
Flutter, Asset-Metadaten oder Produktlogik uebernommen werden.

Jeder Anchor braucht in einem spaeteren Bild-/Layer-Slice:

- gemessene Canvas- oder Source-Datei-Groesse,
- klaren Crop/Framing-Nachweis,
- bestaetigten `world_origin`,
- dokumentierten `layer_pivot`,
- zugeordnete Placement-Zone,
- No-Overlap-Regel,
- Sort-Band,
- QA-Status.

## 5. Pflicht-Anchors aus Candidate A

| Anchor ID | Zweck | Candidate-A-Bezug | Rough normalized x/y | Placement-Zone | Sort-Band | No-Overlap-Hinweis | QA-Status | Risiko |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `main_build_area_anchor` | Primaere zentrale Bau- und Reserveorientierung fuer Uferhain. | Groessere helle Lichtungs-/Wiesenreserve im mittleren Inselbereich. | `0.50 / 0.49` | `soft_placement_zone` | `interactive_ground` | Muss Abstand zu Wasserarm, Hainkante und spaeterer Build Station halten. | `rough_from_structure` | Koennte faelschlich als fester Hausplatz gelesen werden. |
| `house_primary_anchor` | Proof-Anchor, dass ein Haus dort moeglich sein kann, ohne den Slot fest zu koppeln. | Innerhalb der zentralen Reserve, leicht vom Hub trennbar. | `0.48 / 0.50` | `buildable_footprint` | `build_object` | Darf keine Kategoriepflicht erzeugen; gleiche Logik muss spaeter fuer andere freie Slots gelten. | `rough_from_structure` | Name koennte als Haus-Zwang missverstanden werden. |
| `hub_center_anchor` | Vorlaeufiger World-Origin und Insel-Hub. | Zentrum der Hauptlichtung / erster Orientierungspunkt. | `0.50 / 0.47` | `soft_placement_zone` | `interactive_ground` | Muss frei von UI, Pins und festen Kategorieobjekten bleiben. | `rough_from_structure` | Hub darf kein Menuepunkt oder Dashboard werden. |
| `river_entry_anchor` | Registriert den oberen/seitlichen Einstieg des Fluss- oder Uferarms. | Wasserarm im oberen linken Inselbereich. | `0.30 / 0.15` | `water_only_zone` | `base` | Kein Slot, keine Build Station, keine Figur darauf platzieren. | `rough_from_structure` | Wasserform koennte in spaeteren Varianten driften. |
| `river_exit_anchor` | Registriert den Auslauf/Anschluss des Wasserarms zum Aussenwasser. | Linker bis unterer Wasserbezug an der Inselkante. | `0.17 / 0.45` | `water_only_zone` | `base` | Muss mit `water_paths` und `island_base` deckungsgleich bleiben. | `rough_from_structure` | Ohne Registration kann Wasser wie anderer Inseltyp wirken. |
| `grove_anchor` | Hauptanker fuer den Hain-/Waldnahbereich. | Dichtere Baumgruppe im oberen/rechten Inselbereich. | `0.60 / 0.20` | `terrain_sensitive_zone` | `terrain_high` | Hain ist No-Build-nahe; keine Kategorieplaetze oder Gebaeude einbacken. | `rough_from_structure` | Hain kann zu dicht oder stickerhaft werden. |
| `reserve_zone_anchor_north` | Nord-/Oberreserve fuer spaetere neutrale Slots. | Wiese/Terrasse nahe Hainkante, noch nicht als Pad. | `0.62 / 0.33` | `reserve_zone` | `interactive_ground` | Darf nicht mit Hain, Klippe oder UI-Safe-Area kollidieren. | `rough_from_structure` | Koennte als fertige Bauplatte erscheinen. |
| `reserve_zone_anchor_south` | Suedreserve fuer spaetere neutrale Slots. | Ruhigere untere Wiesen-/Randzone. | `0.45 / 0.72` | `reserve_zone` | `interactive_ground` | Abstand zu Strand/Wasser und unteren Klippen pruefen. | `rough_from_structure` | Mobile-Lesbarkeit kann bei spaeteren Markern leiden. |

## 6. Optionale Zusatz-Anchors

Diese Anchors sind nicht Pflicht fuer den ersten Manifeststand, aber sinnvoll
fuer spaetere Layer-Candidates, wenn mehr Uferhain-Struktur gesichert werden
soll.

| Anchor ID | Zweck | Candidate-A-Bezug | Rough normalized x/y | Placement-Zone | Sort-Band | No-Overlap-Hinweis | QA-Status | Risiko |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `reserve_zone_anchor_west` | Westliche Reserve fuer freie Gestaltung. | Linke untere/seitliche Landreserve. | `0.23 / 0.62` | `reserve_zone` | `interactive_ground` | Nicht mit Flussauslauf oder Aussenwasser vermischen. | `rough_from_structure` | Koennte zu klein fuer mobile Tap-Targets werden. |
| `reserve_zone_anchor_east` | Oestliche Reserve fuer spaetere Slotkapazitaet. | Rechte mittlere Wiese/Randreserve. | `0.78 / 0.45` | `reserve_zone` | `interactive_ground` | Abstand zur Klippe und zum Hain einhalten. | `rough_from_structure` | Risiko von Edge-Crop oder Toolbelt-Konflikt in App-Screens. |
| `shoreline_anchor_south` | Registriert Strand-/Uferkante im unteren Bereich. | Untere helle Uferlinie / ruhiger Rand. | `0.43 / 0.88` | `terrain_sensitive_zone` | `terrain_low` | Kein Build-Footprint im Wasser oder auf harter Uferkante. | `rough_from_structure` | Ufer darf nicht generisch tropisch werden. |
| `cliff_edge_anchor_east` | Registriert harte rechte Hoehen-/Felskante. | Rechter Fels-/Hoehenrand. | `0.83 / 0.55` | `no_build_zone` | `terrain_high` | Keine Build Station, keine Slotmarker auf harter Kante. | `rough_from_structure` | Koennte spaeter mit nutzbarer Wiese verwechselt werden. |
| `small_islet_anchor_west` | Prueft kleine Nebeninsel-/Wasserstruktur. | Kleine westliche Wasser-/Landform. | `0.19 / 0.36` | `water_only_zone` | `base` | Nur Struktur-/Wasserregistrierung, kein Bauraum. | `rough_from_structure` | Darf keine neue produktive Insel freigeben. |
| `safe_ui_anchor_top_right` | Fruehe Safe-Area-Andeutung fuer spaetere HUD-Verdeckung. | Oberer rechter Rand ausserhalb Hauptinteraktion. | `0.86 / 0.12` | `no_overlap_zone` | `hud` | HUD darf keine Hauptslots, Build Station oder Worker verdecken. | `rough_from_structure` | Noch keine App-HUD-Freigabe. |

## 7. Placement-Zonen

### `buildable_footprint`

Zweck:

- spaetere konkrete Objekt-/Gebaeudeflaeche innerhalb eines neutralen Slots.

Regel:

- darf erst nach Slot-/BuildChoice-/Build-Station-Gate produktiv werden,
- darf nicht aus Candidate A als fertiges Pad ausgeschnitten werden,
- bleibt in M16-CM nur eine Manifest-Kategorie.

### `soft_placement_zone`

Zweck:

- weiche Zone fuer Fokus, Hub, Build Station oder spaetere Auswahl,
- zeigt Moeglichkeit, nicht Pflicht.

Regel:

- keine Kategoriebindung,
- keine fertigen Kanten,
- keine UI- oder Menueoptik.

### `reserve_zone`

Zweck:

- neutrale Flaechenreserve fuer ca. 12 sichtbare Slots und langfristig 16-20
  Slotmoeglichkeiten.

Regel:

- beschreibt Kapazitaet,
- erzeugt keine Slotmarker,
- bleibt frei von Hausplatz-/Marktplatz-/Werkstattplatz-Logik.

### `no_build_zone`

Zweck:

- schuetzt Wasser, harte Klippen, dichten Hain und Aussenwasser.

Regel:

- keine Gebaeude,
- keine Build Stations,
- keine Figuren als feste Arbeitsorte,
- keine produktiven Platzierungen.

### `no_overlap_zone`

Zweck:

- verhindert spaetere Kollisionen zwischen Slot, Build Station, Worker,
  Figuren, HUD/Bubbles und wichtigen Landmarken.

Regel:

- muss in spaeteren Visual-/Layer-Slices aktiv geprueft werden,
- besonders fuer zentrale Build Station, Hainkante und UI-Safe-Areas.

### `water_only_zone`

Zweck:

- trennt Wasserarm, Aussenwasser und Uferbezug von bebaubaren Flaechen.

Regel:

- nur Wasser-/Ufer-/Brueckenlogik spaeter,
- keine Kategorieplots,
- keine Bubbles oder Pins im Wasser.

### `terrain_sensitive_zone`

Zweck:

- markiert Hainkante, Ufer, Felsen, Hoehen und Strandbereiche, die Varianten
  beeinflussen duerfen.

Regel:

- Terrain darf spaeter Gestaltung vorschlagen,
- Terrain blockiert keine Kategorie hart, solange die Zone nicht No-Build ist.

## 8. No-Build- und No-Overlap-Zonen

Pflichtzonen fuer spaetere Bild-/Layerarbeit:

| Zone | Kandidat-A-Bezug | Regel |
| --- | --- | --- |
| Wasser | Aussenwasser rund um die Insel und Wasserarm. | Keine Gebaeude, keine Slots, keine Build Stations, keine UI-Pins. |
| Dichter Hain | Oberer/rechter Baumcluster. | No-Build-nahe; hoechstens weiche Hainkante fuer Stimmung/Variante. |
| Harte Klippen | Rechte und untere Fels-/Hoehenkanten. | Keine neutralen Slots auf schmalen harten Kanten. |
| Aussenwasser | Vollstaendig ausserhalb Inselkontur. | Nur Hintergrund/Water Layer, keine Interaktion. |
| Hauptflussarm | Linker/oberer Wasserarm. | `water_paths` muss passen; Build-Footprints bleiben getrennt. |
| Spaetere UI-Safe-Areas | Vor allem obere/rechte Randbereiche. | HUD/Bubbles duerfen Hub, Build Station, Worker und Slotmarker nicht verdecken. |
| Spaetere Build-Station-Schutzbereiche | Rund um gewaehlte Slots. | Station und kleine Optionen brauchen Lesbarkeit ohne Slot- oder Hainkollision. |

## 9. Layer-Generation-Brief

### `island_base`

Muss sichtbar oder ableitbar halten:

- Insel-Silhouette,
- Kuesten-/Flussufer-Identitaet,
- zentrale Lichtung / Hub,
- Hain-/Waldzone,
- grobe Hoehen-/Randlogik,
- Reservelogik fuer 12 sichtbare Slots und 16-20 Langfristreserve.

Darf nicht enthalten:

- finale Slotmarker,
- Build Stations,
- Gebaeude,
- Figuren,
- HUD/Bubbles,
- Texte, Pins, Icons,
- harte Kategorieplaetze.

Anchor-Pflicht:

- `hub_center_anchor`
- `main_build_area_anchor`
- `river_entry_anchor`
- `river_exit_anchor`
- `grove_anchor`
- Nord-/Suedreserve mindestens als Flaechenlogik.

### `water_paths`

Muss passen zu:

- `river_entry_anchor`,
- `river_exit_anchor`,
- `shoreline_anchor_south`,
- `water_only_zone`,
- Inselbasis-Crop und Framing.

Darf nicht:

- Wasserarm als zufaellige Dekolinie verschieben,
- Bauplaetze oder Icons im Wasser enthalten,
- Uferhain in eine generische Tropeninsel verwandeln.

### `terrain_layers`

Muss respektieren:

- `grove_anchor`,
- Hainkante,
- Hoehen-/Terrassenlogik,
- `terrain_sensitive_zone`,
- `no_build_zone` an Klippen und dichten Baumgruppen.

Darf nicht:

- Lichtungen zu fertigen Pads machen,
- feste Kategoriezonen zeichnen,
- Hain, Felsen und Wiese untrennbar in ein monolithisches Bild backen.

### `slot_markers`

Braucht:

- neutrale Reserve-Zonen,
- 12 sichtbare Slotmoeglichkeiten als Designziel,
- 6 sofort nutzbare und 6 spaetere sichtbare Reserven als spaetere
  Markierungslogik,
- No-Overlap-Regeln zu Wasser, Hain, Klippen und spaeterem HUD.

Darf nicht:

- Kategorieplaetze zeigen,
- `house_primary_anchor` als einzigen Hausplatz behandeln,
- fertige Icons, Pins oder UI-Labels ohne eigenes Visual-/Asset-Gate setzen.

### `build_stations`

Noch nicht erzeugen.

Grund:

- Build Station braucht ausgewaehlten Slot, Footprint-Regel,
  Figuren-/Worker-Bezug, Lesbarkeit, No-Overlap-Zone und eigenes
  Build-Station-Asset-/Visual-Gate.
- In Candidate A und M16-CM wird nur die spaetere Schutzlogik vorbereitet.

## 10. QA-Regeln fuer Commitfaehigkeit spaeterer Bild-/Layer-Slices

Kein spaeterer Bild-/Layer-Slice ist commitfaehig, wenn:

- Anchor-Manifest fehlt,
- Placement-Zonen fehlen,
- No-Build-/No-Overlap-Zonen fehlen,
- Depth-/Sorting fehlt,
- Canvas- und Framing-Regel fehlen,
- Origin/Pivot nicht dokumentiert sind,
- Candidate A als Pixelziel statt Strukturreferenz genutzt wird,
- Slotreserven als Kategorieplaetze dargestellt werden,
- Build Stations vor Slot-/Footprint-/No-Overlap-Regel erzeugt werden,
- Dateien unter `assets/` entstehen,
- `engine_ready_candidate` oder `approved_asset` ohne eigenes Gate behauptet
  wird.

Mindest-QA fuer jeden spaeteren Layer-Candidate:

| Frage | Erwartung |
| --- | --- |
| Ist `canvas_family` angegeben? | Ja. |
| Ist `framing_lock` stabil? | Ja. |
| Sind `canvas_origin`, `world_origin` und `layer_pivot` dokumentiert? | Ja. |
| Sind alle Pflicht-Anchors benannt? | Ja. |
| Sind Placement-Zonen zugeordnet? | Ja. |
| Sind No-Build-Zonen dokumentiert? | Ja. |
| Sind No-Overlap-Zonen dokumentiert? | Ja. |
| Ist die Layer-Reihenfolge angegeben? | Ja. |
| Ist ein Sort-Band je interaktivem Element vorhanden? | Ja. |
| Bleibt Candidate A Strukturreferenz, kein Pixelziel? | Ja. |

## 11. Metadaten-Erweiterung fuer spaetere Layer-Candidates

Spaetere Metadata-Dateien muessen neben den Feldern aus 370/372/375 zusaetzlich
enthalten:

- `anchor_manifest`
- `anchor_manifest_version`
- `canvas_family`
- `canvas_origin`
- `world_origin`
- `layer_pivot`
- `coordinate_space`
- `framing_lock`
- `anchor_precision`
- `required_anchors_present`
- `placement_zones_documented`
- `no_build_zones_documented`
- `no_overlap_zones_documented`
- `sort_bands_documented`
- `candidate_a_used_as`
- `candidate_a_not_used_as_pixel_target`
- `registration_qa_status`

Erlaubter `candidate_a_used_as`-Wert fuer Folgearbeit:

```text
structure_reference_only
```

Nicht erlaubt:

```text
pixel_source
runtime_base
engine_ready_base
approved_asset_source
traced_image
```

## 12. Folgepfad

Nach M16-CM kann ein spaeterer Slice hier im Chat oder mit einem benannten
Bildtool einen ersten `layer_postprocess_candidate` vorbereiten, aber nur mit
ausdruecklicher Bildfreigabe, erlaubtem Dokumentationspfad, erlaubten
Dateinamen, Metadata-Pflicht und QA.

Codex-Rolle danach:

- Intake,
- Metadatenpruefung,
- Dateieinordnung,
- QA,
- Scope-Check,
- Dokumentation.

Codex-Rolle nicht:

- Bildgenerierung,
- KI-Bildtool starten,
- Candidate A nachzeichnen,
- Asset-Freigabe,
- Engine-ready Export,
- Flutter-/App-Integration.

Empfohlener naechster Slice:

```text
M16-CN First Uferhain Layer Postprocess Candidate Permission Gate
```

Dieser Folge-Slice muss explizit klaeren, ob Bildarbeit erlaubt wird und ob
ChatGPT/image_gen, ein externes KI-Bildtool, Figma/Photopea/Photoshop/Aseprite
oder Artist-Arbeit genutzt werden soll.

## 13. Entscheidung

| Entscheidung | Wert |
| --- | --- |
| Candidate A als Anchor-Manifest-Grundlage | JA |
| Candidate A als Pixelziel | NEIN |
| Candidate A als Asset | NEIN |
| Candidate A als Engine-ready Grundlage | NEIN |
| Grobe Anchors dokumentiert | JA |
| Placement-Zonen dokumentiert | JA |
| No-Build-/No-Overlap-Zonen dokumentiert | JA |
| Layer-Generation-Brief erstellt | JA |
| Neue Bildgenerierung jetzt noetig | NEIN |
| `assets/` weiterhin blockiert | JA |
| Flutter/App-Integration weiterhin blockiert | JA |

## 14. Stop-Regeln

- keine Bildfreigabe ohne Anchor-/Registration-Pruefung,
- keine Layer-Candidates ohne Placement-/Anchor-Logik,
- keine neuen Bilder in M16-CM,
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
