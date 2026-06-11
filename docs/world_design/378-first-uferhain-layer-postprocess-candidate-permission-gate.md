# M16-CN: First Uferhain Layer Postprocess Candidate Permission Gate

Stand: 2026-06-11

Status: `Markdown-Docs-/Permission-Gate / keine aktuelle Bild-, Asset-, Code- oder Engine-ready-Freigabe`

Template: `art_master_reference_slice`

## 1. Zweck und Non-Goals

M16-CN klaert, ob die erste Uferhain-Layer-Postprocess-Bildarbeit nach
Candidate A grundsaetzlich als Folge-Slice vorbereitet werden darf.

Der Slice legt fest:

- ob Bildarbeit jetzt fuer einen naechsten Slice geoeffnet werden darf,
- welche Layer zuerst erlaubt sind,
- welcher Dokumentationspfad und welche Dateinamen spaeter gelten,
- welche Anchor-/Registration-/Placement-Regeln aus 376/377 zwingend sind,
- welche Metadaten und QA eine spaetere Bilddatei braucht,
- welche Bild-, Asset-, Engine-ready-, App- und Code-Grenzen geschlossen
  bleiben.

Non-Goals in M16-CN:

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

Codex darf in M16-CN nur Permission Gate, erlaubte Folgepfade, Dateinamen,
Bildarbeitsgrenzen, Metadatenpflichten, QA-Regeln und Stop-Regeln
dokumentieren. Codex darf keine Bilder generieren, keine KI-Bildtools
anstossen und Candidate A nicht nachzeichnen.

## 2. Eingangsquellen und Abgrenzung

Fuehrende Quellen:

- `367-talvori-art-bible-v1.md`
- `368-starter-island-master-reference-set.md`
- `370-asset-family-and-export-spec.md`
- `373-candidate-a-structure-lock-and-postprocess-brief.md`
- `374-candidate-a-layer-and-postprocess-plan.md`
- `375-candidate-a-external-postprocess-and-layer-production-brief.md`
- `376-anchor-registration-and-placement-logic-gate.md`
- `377-candidate-a-anchor-manifest-and-layer-generation-brief.md`
- `previews/m16_cg_starter_island_base_candidate_generation/talvori_island_base_uferhain_candidate_metadata.md`
- `previews/m16_cg_starter_island_base_candidate_generation/talvori_island_base_uferhain_candidate_a_1x.png`
- `previews/m16_cg_starter_island_base_candidate_generation/talvori_island_base_uferhain_contact_sheet_1x.png`

Abgrenzung:

- Candidate A bleibt `structure_reference_only`.
- Candidate A ist kein Pixelziel, kein Asset und keine Engine-ready Grundlage.
- M16-CN oeffnet keine aktuelle Bilddatei.
- M16-CN erlaubt keine Dateien unter `assets/`.
- M16-CN erlaubt keine Runtime-, Flutter- oder App-Integration.

## 3. Entscheidung: Wird Bildarbeit jetzt freigegeben?

| Entscheidung | Wert |
| --- | --- |
| Bildarbeit in M16-CN selbst | NEIN |
| Bildarbeit fuer naechsten ausdruecklichen Folge-Slice vorbereiten | JA |
| Erlaubter Folge-Slice | `M16-CO First Uferhain Island Base Layer Postprocess Candidate` |
| Erlaubte Bildrolle im Folge-Slice | `layer_postprocess_candidate` |
| Erlaubtes Tool im Folge-Slice | ChatGPT/image_gen ausserhalb von Codex oder ausdruecklich benanntes externes Bild-/Design-Tool |
| Codex-Bildgenerierung | NEIN |
| Codex-KI-Bildtool-Start | NEIN |
| Codex-Nachzeichnen von Candidate A | NEIN |

Damit ist die Antwort:

```text
Bildarbeit grundsaetzlich fuer M16-CO freigeben: JA, aber nur als separater
Folge-Slice mit expliziter Bildfreigabe, erlaubtem Dokumentationspfad,
Metadaten, Anchor-Manifest und QA.
```

M16-CN selbst erzeugt keine Bilddateien.

## 4. Welche erste Bildarbeit ist erlaubt?

### Erlaubt fuer M16-CO

1. `island_base`

   - bevorzugter erster Layer,
   - darf nur als strukturkorrigierter Uferhain-Layer-Postprocess-Candidate
     entstehen,
   - muss Candidate A strukturell lesen, aber nicht kopieren,
   - muss Anchor-/Registration-Pflichten aus 376/377 erfuellen.

2. `water_paths`

   - optional nur dann, wenn Wasserarm-/Ufer-Registration fuer den ersten
     `island_base`-Candidate zwingend mitgeprueft werden muss,
   - darf nicht als eigener vollstaendiger Asset-Schritt ausufern,
   - braucht dieselben Anchor-/Canvas-/Framing-Regeln.

### Noch nicht erlaubt

- `terrain_layers`: noch nicht, ausser ein spaeterer Slice begruendet sie
  ausdruecklich als reine Registration-/Postprocess-Abhaengigkeit.
- `slot_markers`: noch nicht als Bild; hoechstens als Manifest- oder
  Overlay-Plan in Docs.
- `build_stations`: weiterhin blockiert.
- `building_phases`: weiterhin blockiert.
- `workers_companions`: weiterhin blockiert.
- `ui_hud_bubbles`: weiterhin blockiert.

## 5. Erlaubter Dokumentationspfad fuer M16-CO

Nur folgender zukuenftiger Dokumentationspfad darf in M16-CO geoeffnet werden:

```text
docs/world_design/previews/m16_co_first_uferhain_layer_postprocess_candidate/
```

Regeln:

- Der Ordner wird in M16-CN nicht erstellt.
- Der Ordner darf erst im ausdruecklich geoeffneten M16-CO entstehen.
- Keine Dateien unter `assets/`.
- Keine Runtime-Dateien.
- Keine App-Screens.
- Keine Screenshots als Produktartefakt.

## 6. Erlaubte spaetere Dateinamen

Pflichtdatei fuer M16-CO, falls Bildarbeit freigegeben und ausgefuehrt wird:

```text
talvori_island_base_uferhain_structure_postprocess_candidate_a_v1_1x.png
```

Optional nur bei ausdruecklicher Freigabe im Folge-Slice:

```text
talvori_water_paths_uferhain_structure_postprocess_candidate_a_v1_1x.png
```

Pflicht-Metadaten und QA-Dateien fuer M16-CO:

```text
talvori_uferhain_layer_postprocess_metadata.md
talvori_uferhain_layer_postprocess_anchor_manifest.md
talvori_uferhain_layer_postprocess_contact_sheet_1x.png
```

Contact Sheet ist nur erlaubt, wenn mindestens eine Bilddatei im erlaubten
M16-CO-Pfad entsteht. Es bleibt Dokumentationsmaterial, kein Asset und kein
App-Screen.

## 7. Maximalstatus

Erlaubter Maximalstatus:

```text
layer_postprocess_candidate
```

Blockierte Status:

```text
engine_ready_candidate
approved_asset
production_asset
runtime_asset
app_asset
```

Ein M16-CO-Candidate darf spaeter nur als QA-faehiger Dokumentationscandidate
in `docs/world_design/previews/` existieren. Jede Hochstufung braucht ein
eigenes Asset-/Engine-ready-Gate.

## 8. Anchor-/Registration-Pflicht

M16-CO ist nur gueltig, wenn jede erzeugte Bilddatei und die Metadata-Datei
folgende Felder dokumentieren:

- `canvas_family`
- `canvas_origin`
- `world_origin`
- `layer_pivot`
- `coordinate_space`
- `framing_lock`
- `anchor_manifest`
- `anchor_manifest_version`
- `anchor_precision`
- `required_anchors_present`
- `placement_zones_documented`
- `no_build_zones_documented`
- `no_overlap_zones_documented`
- `sort_bands_documented`
- `candidate_a_used_as`
- `candidate_a_not_used_as_pixel_target`
- `registration_qa_status`

Pflichtwerte:

| Feld | Erwartung |
| --- | --- |
| `canvas_family` | `uferhain_island_base` |
| `canvas_origin` | `top_left_normalized_0_0` |
| `world_origin` | `hub_center_anchor` |
| `layer_pivot` | `world_origin_unless_family_override` oder begruendeter Layer-Family-Override |
| `coordinate_space` | `normalized_0_1` plus spaeter optional Pixelwerte |
| `framing_lock` | stabile quadratische Dokumentations-Canvas mit gleicher Insel-Silhouette |
| `anchor_manifest` | `m16_cm_candidate_a_anchor_manifest_v1` |
| `candidate_a_used_as` | `structure_reference_only` |
| `candidate_a_not_used_as_pixel_target` | `true` |

Pflicht-Anchors aus 377:

- `main_build_area_anchor`
- `house_primary_anchor`
- `hub_center_anchor`
- `river_entry_anchor`
- `river_exit_anchor`
- `grove_anchor`
- `reserve_zone_anchor_north`
- `reserve_zone_anchor_south`

Erwartete Zusatz-Anchors, wenn im Bildbereich betroffen:

- `reserve_zone_anchor_west`
- `reserve_zone_anchor_east`
- `shoreline_anchor_south`
- `cliff_edge_anchor_east`
- `safe_ui_anchor_top_right`

## 9. Bildprompt- und Tool-Grenzen fuer M16-CO

Jeder spaetere Bildprompt muss enthalten:

```text
This is a layer postprocess documentation candidate for art/structure review
only, not a final game asset, not an app screen, not engine-ready, not an
approved asset, and not for production use.
```

Positive Richtung:

- Uferhain als Kuestenhain-/Flussufer-Starterinsel,
- warmer 2.5D-Cozy-Island-Diorama-Stil,
- leicht erhoehte, mit Art Bible konsistente Perspektive,
- stabile Canvas und stabiles Framing,
- klare Inselkontur mit Wassernaehe,
- Flussarm oder Uferarm,
- zentrale Lichtung / Hub,
- Hain-/Waldnahbereich,
- leichte Hoehen oder ruhige Randbereiche,
- natuerliche, neutrale Reserveflaechen fuer spaetere Slotlogik,
- Candidate A nur als Strukturreferenz.

Negative Grenzen:

- kein Pixel-Nachzeichnen von Candidate A,
- keine Kategorieplaetze,
- keine Gebaeude,
- keine Figuren,
- keine UI/HUD/Bubbles,
- keine Texte,
- keine Labels,
- keine Pins,
- keine Icons,
- keine Build Stations,
- keine finalen Slotmarker im ersten `island_base`,
- keine App-UI,
- kein Dashboard,
- kein Worksheet,
- kein flacher Editor-Map-Look,
- kein rigid grid,
- kein final game asset,
- kein production asset,
- kein engine-ready export,
- kein copied reference image,
- kein screenshot look,
- kein watermark.

## 10. QA fuer spaetere Bildarbeit

Ein spaeterer M16-CO-Slice ist nicht commitfaehig, wenn:

- Anchor-/Registration-Logik fehlt,
- No-Build-/No-Overlap-Zonen fehlen,
- Placement-Zonen fehlen,
- Sort-Bands fehlen,
- Datei unter `assets/` entsteht,
- Status hoeher als `layer_postprocess_candidate` gesetzt wird,
- Candidate A als Pixelziel verwendet wird,
- Bild ohne Metadaten entsteht,
- Bild ohne Anchor-Manifest entsteht,
- Bild Gebaeude, Figuren, HUD, Texte, Pins, Icons oder Build Stations
  enthaelt,
- `slot_markers` unfreigegeben als Bild erzeugt werden,
- `terrain_layers` ohne neue Begruendung erzeugt werden,
- `water_paths` ohne Registration-Begruendung erzeugt werden,
- der erlaubte Dokumentationspfad verlassen wird.

Mindest-QA:

| Check | Erwartung |
| --- | --- |
| Uferhain-Identitaet | Kuestenhain-/Flussufer-Starterinsel bleibt lesbar. |
| Art Bible | 2.5D-Cozy-Island-Diorama-Stil bleibt konsistent. |
| Structure Reference | Candidate A wird nur strukturell genutzt. |
| Anchor Manifest | Pflicht-Anchors aus 377 sind dokumentiert. |
| Canvas/Framing | Quadratisch, stabil, nicht driftend. |
| Placement | Reserve, Build-Footprint, No-Build und No-Overlap getrennt. |
| Layer Boundary | `island_base` enthaelt keine Slots, Stationen, Figuren oder HUD. |
| Pfadschutz | Nur M16-CO-Dokumentationspfad, niemals `assets/`. |
| Statusschutz | Maximal `layer_postprocess_candidate`. |
| Metadata | Metadata- und Anchor-Manifest-Dateien vorhanden. |

## 11. Rolle von Codex nach M16-CN

Codex darf im spaeteren M16-CO:

- erzeugte Dateien in den erlaubten Dokumentationspfad einordnen,
- Metadaten pruefen,
- Anchor-Manifest pruefen,
- QA durchfuehren,
- Scope-Checks ausfuehren,
- Dokumentation aktualisieren.

Codex darf auch in M16-CO nicht:

- Bilder selbst generieren,
- KI-Bildtools selbst anstossen,
- Candidate A nachzeichnen,
- Asset-Freigabe behaupten,
- Engine-ready Export behaupten,
- Dateien nach `assets/` schreiben,
- Flutter-/App-Code schreiben.

## 12. Folgepfad

Wenn Bildarbeit weitergehen soll, lautet der naechste Slice:

```text
M16-CO First Uferhain Island Base Layer Postprocess Candidate
```

M16-CO muss ausdruecklich erlauben:

- ob ChatGPT/image_gen ausserhalb von Codex oder ein externes Bild-/Design-Tool
  die Bilddatei erzeugt,
- ob genau eine `island_base`-PNG entsteht,
- ob optional `water_paths` fuer Registration mitentsteht,
- welche Dateien im M16-CO-Dokumentationspfad entstehen duerfen,
- welche Metadatenfelder ausgefuellt werden,
- welche QA entscheidet, ob der Candidate weiter reviewbar ist.

Wenn diese Freigabe im Folgeprompt fehlt, bleibt der naechste Schritt ein
Docs-/QA-Gate ohne Bildarbeit.

## 13. Entscheidung

| Entscheidung | Wert |
| --- | --- |
| Bildarbeit in M16-CN | NEIN |
| Bildarbeit in M16-CO grundsaetzlich erlaubt | JA, wenn explizit im Folgeprompt geoeffnet |
| Erste erlaubte Layer-Familie | `island_base` |
| `water_paths` | Optional nur bei Registration-Bedarf |
| `terrain_layers` | Noch blockiert, ausser spaeter begruendet |
| `slot_markers` | Noch blockiert als Bild; hoechstens Manifest/Overlay-Plan |
| `build_stations` | Blockiert |
| Maximalstatus | `layer_postprocess_candidate` |
| `assets/` | Blockiert |
| Engine-ready | Blockiert |
| Approved Asset | Blockiert |
| Flutter/App-Integration | Blockiert |
| Candidate A als Pixelziel | Blockiert |

## 14. Stop-Regeln

- keine neuen Bilder in M16-CN,
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
