# M16-CC: Asset Family and Export Spec

Stand: 2026-06-11

Status: `Markdown-Docs-/Asset-Spec-Gate / keine Asset-Freigabe`

Template: `docs/world_design/prompt_templates/art_master_reference_slice.md`

## 1. Zweck und Non-Goals

M16-CC definiert, welche Asset-Familien Talvori spaeter braucht und welche
Export-, Layer-, Namens-, Groessen-, Metadaten- und QA-Regeln gelten muessen,
bevor echte Bilddateien oder Engine-ready Candidates entstehen duerfen.

M16-CC schliesst die Luecke zwischen:

- M16-BZ: KI-Art-Pipeline und Style Consistency,
- M16-CA: Art Bible v1,
- M16-CB: Starter Island Master Reference Set,
- einem spaeteren Asset-Gate mit echten Dateien.

Non-Goals:

- keine Assets,
- keine Dateien unter `assets/`,
- keine Bilder,
- keine Preview-Ordner,
- keine PNG/SVG,
- keine Engine-ready Candidates,
- keine finalen Spielbilder,
- keine App-Screens,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- keine Tests,
- keine externen Writes,
- kein Commit.

M16-CC ist eine Spezifikation. Es sagt, was spaeter erlaubt werden kann, aber
es erlaubt noch keine Datei, kein Bild und keine Produktintegration.

## 2. Eingangsquellen und Abgrenzung

Fuehrende Quellen:

- `docs/world_design/365-modern-mobile-game-direction-board.md`
- `docs/world_design/366-ai-art-production-pipeline-and-style-consistency-gate.md`
- `docs/world_design/367-talvori-art-bible-v1.md`
- `docs/world_design/368-starter-island-master-reference-set.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/prompt_templates/art_master_reference_slice.md`

Abgrenzung:

- M16-BZ definiert Pipeline und Rollen.
- M16-CA definiert Stil, Kamera, Perspektive, Figuren, HUD und QA gegen
  Stilbruch.
- M16-CB definiert Master-Reference-Briefs fuer Uferhain, Build Station,
  Haus-Bauphasen, Worker/Tali/Vori, UI/HUD und Slot/Marker/Layer.
- M16-CC definiert Asset-Familien und Exportregeln fuer spaetere Dateien.

M16-CC erzeugt keine Master References, keine Bilder, keine Dateien unter
`assets/` und keine Engine-ready Candidates. Das starke Referenzbild aus
M16-BY bleibt Art-Direction-Reference. `modern_mobile_game_direction_board_v2.*`
bleibt rejected/transitional und darf keine Zielqualitaet setzen.

## 3. Asset-Status-Leiter

Talvori unterscheidet kuenftig folgende Stufen:

| Status | Bedeutung | Darf in `assets/`? |
| --- | --- | --- |
| `reference_note` | Textliche Referenz oder Brief. | Nein |
| `style_reference` | Stilreferenz fuer Kamera, Licht, Farbe, Form. | Nein |
| `structure_reference` | Strukturreferenz fuer Layout, Silhouette, Layer oder Proportion. | Nein |
| `master_reference` | Fuehrende visuelle Referenz nach eigenem Visual-/Art-Gate. | Nein, ausser ein spaeteres Asset-Gate erlaubt es ausdruecklich als Dokumentationsmaterial ausserhalb produktiver Asset-Pfade. |
| `asset_candidate` | Technisch vorbereiteter Kandidat mit Metadaten und QA-Status. | Nur nach eigenem Asset-Gate. |
| `engine_ready_candidate` | Kandidat mit Exportgroesse, Transparenz, Layern, Namen und QA. | Nur nach eigenem Asset-Gate. |
| `approved_asset` | Produktiv nutzbares Asset nach Review, Lizenzpruefung und Integrationsgate. | Ja, erst nach Freigabe. |
| `blocked_asset` | Nicht nutzbar wegen Stil, Lizenz, Layer, Lesbarkeit oder Scope. | Nein |

M16-CC erzeugt nur Spezifikation. Alle aktuellen Inhalte bleiben auf
`reference_note`-Ebene.

## 4. Fuehrende Asset-Familien

Erste Talvori-Asset-Familien:

| Familie | Zweck | Master Reference aus M16-CB | Darf jetzt entstehen? |
| --- | --- | --- | --- |
| `island_base` | Grundform der Starter-Insel und spaeterer Inseln. | Starter-Insel / Uferhain | Nein |
| `terrain_layers` | Wiesen, Hain, Hoehen, Ufer, Bodenvarianten. | Uferhain, Water/Path/Terrain | Nein |
| `water_paths` | Kueste, Flussarm, Wasserlinien, Wege. | Uferhain, Water/Path/Terrain | Nein |
| `slot_markers` | Freie und spaetere Slots, Auswahl, Fokus. | Slot/Marker/Layer | Nein |
| `build_stations` | BuildChoice als Weltobjekt am Slot. | Build Station | Nein |
| `building_phases` | Boden, Fundament, Wand-Ghost, Tuer-/Fenster-Ghost. | Haus-Bauphasen | Nein |
| `buildings` | Spaetere fertige und unfertige Gebaeude. | Haus-Bauphasen | Nein |
| `workers_companions` | Worker, Tali, Vori und sichtbare Handlungen. | Worker/Tali/Vori | Nein |
| `work_reactions` | Staub, kleine Materialreaktionen, Werkzeugfeedback. | Worker/Tali/Vori, Haus-Bauphasen | Nein |
| `props` | Kleine weltliche Requisiten ohne Insel-Clutter. | Build Station, Container Future | Nein |
| `interiors` | Spaetere Haus-/Raumebenen. | Container/Interior Future | Nein |
| `furniture` | Spaetere Moebel und Raumobjekte. | Container/Interior Future | Nein |
| `containers` | Spaetere Kisten, Schubladen, Taschen, Archivorte. | Container/Interior Future | Nein |
| `ui_hud_bubbles` | Bubbles, Safe Actions, kleine HUD-Elemente. | UI/HUD/Bubble | Nein |

Diese Familien sind Planungsfamilien. Keine Familie ist durch M16-CC fuer
Dateierzeugung oder Produktintegration freigegeben.

## 5. Layer-Erwartungen

Fuehrende Layer-Reihenfolge fuer Insel-/Bauplatz-Kompositionen:

```text
background_water_or_void
-> island_base
-> terrain_layers
-> water_paths
-> fixed_landmarks
-> slot_markers
-> selected_slot_focus
-> build_station
-> building_phase
-> worker_or_companion
-> work_reactions
-> ui_hud_bubbles
```

Regeln:

- Layer muessen einzeln exportierbar gedacht werden.
- Keine riesigen Gesamtbilder als spielbare Welt.
- Insel, Slots, Build Station, Gebaeude und Figuren muessen dieselbe
  2.5D-Perspektive aus der Art Bible teilen.
- UI/HUD/Bubbles bleiben getrennt von Weltgrafik.
- Work reactions wie Staub oder kleine Bodenreaktionen bleiben eigene
  kurze Effektfamilien, nicht Teil des Grundassets.
- Spaetere Interiors, Furniture und Containers gehoeren in tiefere Ebenen und
  duerfen die Inselansicht nicht mit TinyObjects fuellen.

## 6. Exportformate

Spaetere Kandidaten duerfen nur nach eigenem Asset-Gate erzeugt werden. Wenn
ein Gate sie erlaubt, gelten diese Formatregeln:

| Format | Nutzung | Regel |
| --- | --- | --- |
| PNG mit Transparenz | Einzelobjekte, Figuren, UI/HUD, Ghosts, Phasen. | Standard fuer fruehe Flutter-/Layer-Komposition. |
| WebP mit Transparenz | Optimierte Runtime-Variante spaeter. | Erst nach Pipeline- und Qualitaetspruefung. |
| SVG | Nur fuer einfache UI-/Diagramm-/Vector-Hilfen. | Nicht fuer malerische Weltassets erzwingen. |
| Source-Datei | Figma/PSD/Photopea/Aseprite/ComfyUI-Workflow. | Muss Metadaten, Layer und Exportnotizen tragen. |

Nicht verwenden:

- JPEG fuer transparente Spielobjekte,
- monolithische Gesamtbilder fuer spielbare Welten,
- unscharfe Upscales ohne Source,
- Screenshots als Assetquelle,
- kopierte Referenzbilder als Asset.

## 7. Groessen- und Skalierungsregeln

M16-CC legt noch keine finalen Pixelgroessen fest, definiert aber
Skalierungsprinzipien:

- Familien brauchen eine gemeinsame Basisskala.
- Slots und Build Stations muessen auf Smartphone-Groesse lesbar bleiben.
- Figuren muessen emotional lesbar sein, ohne den Bauplatz zu verdecken.
- UI/HUD/Bubbles muessen kleinere Schrift und kurze Texte erzwingen.
- Exportgroessen muessen in 1x/2x/3x oder einer vergleichbaren
  Flutter-tauglichen Skalierungslogik planbar sein.
- Jede Asset-Familie braucht spaeter eine canonical size und erlaubte
  Varianten.
- Skalierung darf nicht per zufaelligem Stretching passieren; lieber separate
  Varianten fuer kleine/mittlere/grosse Objekte.

Vorlaeufige Planungsrelationen:

| Familie | Relative Groesse |
| --- | --- |
| Slot Marker | klein, aber tippbar und lesbar |
| Build Station | groesser als Marker, kleiner als Gebaeude |
| Worker/Tali/Vori | klein genug fuer Welt, gross genug fuer Emotion |
| Haus-Fundament | slotfuellend, aber nicht ins Nachbargrundstueck laufend |
| HUD/Bubble | klein, kontextuell, nie Hauptspielraum |

## 8. Benennung und Dateiorganisation

Spaetere Asset-Dateien brauchen stabile, maschinenlesbare Namen.

Empfohlenes Namensschema:

```text
talvori_<family>_<subject>_<state>_<variant>_<size>.<ext>
```

Beispiele als Namensschema, nicht als zu erzeugende Dateien:

```text
talvori_island_base_uferhain_default_day_1x.png
talvori_slot_marker_free_default_active_2x.png
talvori_build_station_house_primary_day_2x.png
talvori_building_phase_house_foundation_clean_2x.png
talvori_worker_builder_idle_day_2x.png
talvori_ui_bubble_hint_short_light_2x.png
```

Regeln:

- Namen sind Englisch/ASCII fuer Dateistabilitaet.
- Sichtbare Spielertexte bleiben davon getrennt.
- `family`, `subject`, `state`, `variant` und `size` muessen in Metadaten
  wieder auftauchen.
- Keine Leerzeichen, keine Umlaute, keine zufaelligen Generatornamen.
- Keine Dateien nach `assets/` ohne eigenes Asset-Gate.

## 9. Source-/Prompt-/Reference-Metadaten

Jeder spaetere Asset Candidate braucht eine begleitende Metadatenstruktur.

Pflichtfelder:

```text
asset_id:
asset_family:
working_name:
intended_use:
slice_id:
status:
source_tool:
source_file:
prompt:
negative_prompt:
style_reference:
structure_reference:
master_reference:
seed_or_generation_id:
postprocess_tool:
license_notes:
export_format:
pixel_size:
scale_variant:
layer_notes:
qa_status:
approved_by:
blocked_reason:
allowed_scope:
```

Regeln:

- Kein Candidate ohne Quelle.
- Kein Candidate ohne Lizenznotiz.
- Kein Candidate ohne Style-/Structure-/Master-Reference-Bezug.
- Kein Candidate ohne QA-Status.
- KI-generierte Bilder brauchen Prompt, Referenzen und Generation-ID oder
  vergleichbare Reproduzierbarkeitsnotiz.
- Manuelle Paintovers brauchen Source-/Postprocess-Hinweise.

## 10. QA-Status

QA-Statuswerte:

| Status | Bedeutung |
| --- | --- |
| `not_checked` | Noch nicht geprueft. |
| `style_check_failed` | Stil, Licht, Perspektive oder Formensprache passt nicht. |
| `structure_check_failed` | Silhouette, Layer, Proportion oder Lesbarkeit passt nicht. |
| `license_blocked` | Quelle, Rechte oder Nutzung unklar. |
| `metadata_incomplete` | Pflichtfelder fehlen. |
| `mobile_readability_failed` | Auf Smartphone zu klein, zu dicht oder unklar. |
| `needs_postprocess` | Grundidee brauchbar, aber Zuschnitt/Layer/Lesbarkeit nicht fertig. |
| `candidate_ready_for_asset_gate` | Bereit fuer spaeteres Asset-Gate, noch nicht freigegeben. |
| `approved_after_asset_gate` | Erst nach eigenem Gate und Review nutzbar. |

M16-CC setzt keinen Candidate auf `candidate_ready_for_asset_gate`. Es definiert
nur die moeglichen Statuswerte.

## 11. Was spaeter ueberhaupt nach `assets/` darf

Nur nach einem eigenen Asset-Gate duerfen spaeter Dateien unter `assets/`
wandern.

Potentiell erlaubt nach Gate:

- transparente PNG/WebP-Layer fuer Inselbasis, Terrain, Slots, Build Station,
  Gebaeudephasen, Figuren, Work Reactions und UI/HUD,
- klar benannte Varianten mit Metadaten,
- optimierte Runtime-Exports,
- ggf. Source-nahe Dokumentationsdateien ausserhalb produktiver Asset-Pfade,
  wenn das Gate sie erlaubt.

Nicht erlaubt:

- Referenzbilder direkt aus Docs,
- das starke M16-BY-Referenzbild,
- `modern_mobile_game_direction_board_v2.*`,
- Screenshots als Assetquelle,
- monolithische Gesamtbilder als spielbare Welt,
- Bilder ohne Lizenz-/Source-/Prompt-/Reference-Metadaten,
- Bilder ohne Mobile-/Style-/Layer-QA,
- sensitive oder fremdstilartige Bilder ohne eigenes Policy-/Style-Gate.

## 12. Eigenes Asset-Gate vor Produktintegration

Vor jeder echten Asset-Datei braucht Talvori ein eigenes Asset-Gate.

Dieses Gate muss mindestens klaeren:

- welche Asset-Familie betroffen ist,
- welche Master Reference gilt,
- welches Tool erzeugt oder bearbeitet,
- welche Source-/Prompt-/Reference-Metadaten vorliegen,
- welche Lizenz-/Nutzungsrechte gelten,
- welche Exportformate und Groessen entstehen,
- welche Layer erzeugt werden,
- welcher QA-Status erreicht wurde,
- wo die Datei liegen darf,
- ob die Datei nur Dokumentationsmaterial, Candidate oder approved Asset ist,
- welche App-/Flutter-/Integration-Dateien beruehrt werden duerfen,
- welche Tests/Visual-QA noetig sind,
- ob Produktintegration erlaubt ist oder weiter blockiert bleibt.

Ohne dieses Gate bleiben Asset-Dateien, Engine-ready Candidates,
Produktintegration und App-Code blockiert.

## 13. Flutter- und Engine-Relevanz

M16-CC bereitet nur vor, wie spaetere Assets in Flutter nutzbar waeren:

- getrennte Layer fuer `Stack`, `CustomPaint`, `Transform` oder
  sprite-/layerartige Komposition,
- transparente Einzelobjekte statt grosser Gesamtbilder,
- klare Skalierungsvarianten,
- kurze Animationen oder Effekt-Layer spaeter getrennt,
- UI/HUD als eigene Familie,
- Figuren und Work Reactions getrennt von Terrain.

M16-CC erstellt keinen Flutter-Code und oeffnet keine App-Integration.

## 14. Risiken

M16-CC verhindert:

- Asset-Familien ohne gemeinsame Perspektive,
- Bilddateien ohne Metadaten,
- monolithische Weltbilder,
- zufaellige Generatornamen,
- unklare Lizenzlage,
- Referenzbilder als Assets,
- UI/HUD als Dashboard statt Spiel-HUD,
- Figuren als fremde Sticker,
- nicht layerbare malerische Bilder,
- Produktintegration ohne Asset-Gate.

## 15. M16-T-IDs

M16-CC erfuellt:

- M16T-ASSET-005 Asset Family and Export Spec
- M16T-ASSET-006 Asset family taxonomy
- M16T-ASSET-007 Layer and composition boundaries
- M16T-ASSET-008 Export formats and transparency rules
- M16T-ASSET-009 Size, scale and mobile density rules
- M16T-ASSET-010 Naming and directory planning rules
- M16T-ASSET-011 Source/prompt/reference metadata and QA status
- M16T-ASSET-012 Asset gate before assets and product integration

M16T-ASSET-001 bleibt blockiert, weil M16-CC noch keine echten Assets
freigibt.

## 16. Stop-Regeln

M16-CC gibt nicht frei:

- keine Assets,
- keine Dateien unter `assets/`,
- keine Bilder,
- keine Preview-Ordner,
- keine PNG/SVG,
- keine Engine-ready Candidates,
- keine finalen Spielbilder,
- keine App-Screens,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- keine Tests,
- keine externen Writes,
- kein Commit ohne separate ausdrueckliche Freigabe.

## 17. Folgepfad

Empfohlener Folgepfad:

```text
M16-CC Asset Family and Export Spec
-> Review/Commit von M16-CD + M16-CC
-> erstes echtes Asset-Gate fuer eine einzelne Familie
```

Ein sinnvoller naechster Asset-Gate-Kandidat waere:

```text
M16-CE Starter Island Asset Candidate Gate
```

Dieses Folge-Gate duerfte erst dann Bilder oder Dateien erlauben, wenn es
explizit Asset-Scope, Quellen, Metadaten, QA, erlaubte Pfade und Integrations-
Grenzen definiert.

