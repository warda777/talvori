# M16-CK: Candidate A External Postprocess and Layer Production Brief

Stand: 2026-06-11

Status: `Markdown-Docs-/External-Production-Brief / keine Bild- oder Asset-Freigabe`

Template: `docs/world_design/prompt_templates/art_master_reference_slice.md`

## 1. Zweck und Non-Goals

M16-CK beschreibt, wie eine spaetere externe Postprocess- und Layer-Produktion
fuer M16-CG Candidate A vorbereitet werden soll.

Das Ziel ist ein klarer Arbeitsbrief fuer spaetere Bild-/Figma-/Artist-Arbeit:
Candidate A wird nicht als Pixelbild uebernommen, sondern nur als
Strukturreferenz genutzt, um eine neu gedachte, layerbare Uferhain-Basis
vorzubereiten.

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

M16-CK ist ein Brief. Es ist keine Produktionsfreigabe.

## 2. Eingangsquellen und Abgrenzung

Fuehrende Quellen:

- `docs/world_design/365-modern-mobile-game-direction-board.md`
- `docs/world_design/366-ai-art-production-pipeline-and-style-consistency-gate.md`
- `docs/world_design/367-talvori-art-bible-v1.md`
- `docs/world_design/368-starter-island-master-reference-set.md`
- `docs/world_design/370-asset-family-and-export-spec.md`
- `docs/world_design/371-starter-island-asset-candidate-gate.md`
- `docs/world_design/372-starter-island-base-candidate-generation-gate.md`
- `docs/world_design/373-candidate-a-structure-lock-and-postprocess-brief.md`
- `docs/world_design/374-candidate-a-layer-and-postprocess-plan.md`
- `docs/world_design/previews/m16_cg_starter_island_base_candidate_generation/talvori_island_base_uferhain_candidate_metadata.md`
- `docs/world_design/previews/m16_cg_starter_island_base_candidate_generation/talvori_island_base_uferhain_candidate_a_1x.png`
- `docs/world_design/previews/m16_cg_starter_island_base_candidate_generation/talvori_island_base_uferhain_contact_sheet_1x.png`

Abgrenzung:

- Candidate A bleibt `asset_candidate`-Dokumentationsmaterial.
- Candidate A bleibt primaere Strukturreferenz, nicht Zielbild.
- M16-CJ definiert die interne Layer-Reihenfolge.
- M16-CK definiert den externen Arbeitsbrief fuer spaetere Produktion.

## 3. Bild-Rolle

Codex darf in M16-CK:

- Brief, Dateistruktur, Dateinamen, Metadatenanforderungen und QA
  dokumentieren,
- vorhandene Repo-Bilder auswerten,
- Stop-Regeln und Pfadgrenzen pruefen,
- spaetere Folge-Slices vorbereiten.

Codex darf in M16-CK nicht:

- neue Bilder generieren,
- KI-Bildtools anstossen,
- Candidate A nachzeichnen,
- Candidate A als Asset freigeben,
- Engine-ready Export behaupten,
- Dateien nach `assets/` schreiben,
- Flutter- oder App-Code erzeugen.

Bildgenerierung oder Paintover-Arbeit kann spaeter nur ausserhalb dieses
Slices erfolgen: durch ChatGPT/image_gen oder ein ausdruecklich benanntes
externes Bild-/Design-Tool, jeweils mit eigener Freigabe.

## 4. Rollen fuer spaetere Arbeit

| Rolle | Darf spaeter tun | Darf nicht tun |
| --- | --- | --- |
| ChatGPT / image_gen | Bildvarianten und Layer-Candidates aus Brief, Art Bible, Master References und Candidate-A-Struktur erzeugen, aber nur nach separater Freigabe. | Ohne Freigabe generieren, finale Assets deklarieren, Candidate A direkt nachzeichnen oder Engine-ready behaupten. |
| Figma / Photopea / Photoshop / Aseprite / Artist | Layering, Zuschnitt, Paintover, Strukturkorrektur, saubere Trennung, Contact Sheet und Exportvorbereitung unter Dokumentationspfad vorbereiten. | App-Screens bauen, produktive Assets freigeben, Dateien nach `assets/` exportieren oder Flutter-Integration oeffnen. |
| Codex | Metadaten, QA, Repo-Dokumentation, Dateinamen, Pfadgrenzen, Statusschutz und Checks pflegen. | Bildgenerierung, Nachzeichnen, Asset-Freigabe, Engine-ready Export, externe Writes oder Code-Integration. |

## 5. Ziel der externen Arbeit

Spaetere externe Arbeit soll:

- Candidate A nur als Strukturreferenz nutzen,
- eine neue, layerbarer gedachte Uferhain-Basis vorbereiten,
- `island_base`, `water_paths`, `terrain_layers` und `slot_markers`
  voneinander trennen,
- Wasser, Hain, Lichtung, Felsen, Hoehen und Randbereiche sauberer lesbar
  machen,
- Slot-Reserven weich und neutral halten,
- 2.5D-Cozy-Island-Diorama-Perspektive und Uferhain-Identitaet schuetzen,
- Metadaten und QA so dokumentieren, dass spaeter ein eigenes Asset- oder
  Engine-ready-Gate ueberhaupt pruefen kann.

Spaetere externe Arbeit soll nicht:

- Candidate A als Pixelbild uebernehmen,
- aus Candidate A direkt ein Spielasset machen,
- feste Kategorieplaetze zeichnen,
- Gebaeude, Figuren, HUD, Bubbles, Text, Pins oder Icons einbauen,
- Runtime- oder Flutter-Strukturen erzeugen.

## 6. Ziel-Layer

M16-CK beschreibt vier konkrete Ziel-Layer:

1. `island_base`
2. `water_paths`
3. `terrain_layers`
4. `slot_markers`

Optional spaeter:

- `build_stations`

Nur erwaehnt, nicht freigegeben:

- `building_phases`
- `workers_companions`
- `ui_hud_bubbles`

## 7. Layer-Brief: `island_base`

Zweck:

- Grundsilhouette, Landmasse, Basisrand und begehbare Inselstruktur fuer
  Uferhain klaeren.

Strukturell aus Candidate A uebernehmen:

- kompakte, grosszuegige Inselkontur,
- zentrale Lichtung als Hub,
- ruhige Randreserven,
- sanfte Hoehen-/Terrassenlogik,
- Strand-/Felsrand als natuerliche Kante,
- grobe Reserve fuer ca. 12 sichtbare Slots und 16-20 Langfristreserve.

Neu/sauberer zeichnen oder trennen:

- Landmasse ohne eingebrannte Wasser-, Baum-, Fels- und Slotdetails,
- weichere Lichtungen ohne Pad-Look,
- klarer Rand zwischen Basisform und spaeteren Terrain-/Wasserlayern,
- weniger final gemalte Details.

Darf nicht enthalten:

- Gebaeude,
- Figuren,
- UI/HUD/Bubbles,
- Texte, Labels, Pins oder Icons,
- Kategorieplaetze,
- fertige Wege als starres Grid,
- direkte Pixelkopie von Candidate A.

Exportidee fuer spaeter:

- Dokumentationscandidate unter `docs/world_design/previews/`,
- bevorzugt transparente PNG-Variante plus dokumentierte Source/Layer-Datei,
- noch kein Engine-ready Export,
- noch keine Datei unter `assets/`.

Metadatenpflicht:

- Layer-Familie `island_base`,
- Source-/Tool-Angabe,
- Candidate-A-Strukturreferenz,
- Art Bible / Master Reference / Asset Spec,
- Prompt oder Paintover-Anweisungen,
- QA-Status,
- Lizenz-/Source-Notizen,
- Status maximal `layer_postprocess_candidate`.

QA:

- Uferhain bleibt Kuestenhain-/Flussufer-Starterinsel.
- Inselbasis ist ohne UI, Figuren, Gebaeude und Texte.
- 12 Slot-Reserven bleiben plausibel.
- 16-20 Langfristreserve bleibt plausibel.
- Landmasse ist als eigener Layer denkbar.
- Perspektive passt zu spaeteren Slots, Build Station und Figuren.

## 8. Layer-Brief: `water_paths`

Zweck:

- Wasserumfeld, Uferarm, Kueste und spaetere Wasserorientierung trennen.

Strukturell aus Candidate A uebernehmen:

- Wasser um die Insel,
- Fluss-/Uferarm links/oben,
- weiche Uferlinie,
- kleine Felsen/Steine als Kuestenrhythmus,
- Strand-/Uferuebergang unten.

Neu/sauberer zeichnen oder trennen:

- Wasser als separater Layer,
- Uferschaum und Ufersteine getrennt planbar,
- Flussarm klar, aber nicht als harte Kategoriebarriere,
- weniger verwaschene oder untrennbare Wasserkante.

Darf nicht enthalten:

- Slotmarker,
- Pins,
- UI,
- Gebaeude,
- Figuren,
- harte Editor-Grenzen,
- Text oder Labels.

Exportidee fuer spaeter:

- Dokumentationscandidate unter `docs/world_design/previews/`,
- transparente Wasser-/Ufer-Layer-Idee oder klarer Layer-Stack,
- noch keine Animation, Shader oder Runtime-Wasserlogik,
- noch kein Engine-ready.

Metadatenpflicht:

- Layer-Familie `water_paths`,
- Bezug zu Candidate A,
- Strukturreferenz Uferarm/Kueste,
- Tool/Source/Prompt/Paintover-Notizen,
- QA-Status und Lizenznotiz,
- Status maximal `layer_postprocess_candidate`.

QA:

- Wasserarm ist lesbar.
- Uferhain verliert seine Flussufer-Identitaet nicht.
- Wasser frisst keine Slot-Kapazitaet.
- Wasser ist nicht fest mit `island_base` verschmolzen.

## 9. Layer-Brief: `terrain_layers`

Zweck:

- Hain, Waldkante, Wiesen, Felsen, Hoehen und kleine Naturdetails getrennt
  planbar machen.

Strukturell aus Candidate A uebernehmen:

- dichter Hain oben/rechts,
- Wiesenlichtungen,
- Fels- und Hoehenkanten,
- warme Blueten-/Baumakzente,
- ruhige Randbereiche.

Neu/sauberer zeichnen oder trennen:

- Baumgruppen getrennt von Basisflaeche,
- Felsen und Hoehenkanten getrennt,
- Wiesen-/Lichtungstextur weniger pad-artig,
- Detaildichte mobile-lesbar reduzieren,
- Randbereiche weniger final/monolithisch gestalten.

Darf nicht enthalten:

- harte Kategorieplaetze,
- fertige Build Station,
- Gebaeude,
- Figuren,
- HUD/Bubbles,
- Icons, Pins oder Texte,
- unlesbare Kleinteildichte.

Exportidee fuer spaeter:

- Dokumentationscandidate unter `docs/world_design/previews/`,
- moeglichst getrennte Vegetation-/Felsen-/Hoehenvarianten,
- noch keine Engine-ready Terrain-Atlas-Datei,
- noch keine Asset-Datei.

Metadatenpflicht:

- Layer-Familie `terrain_layers`,
- Structure Reference fuer Hain, Lichtung, Rand, Hoehen,
- Style Reference aus Art Bible,
- Source-/Tool-/Prompt-/Paintover-Notizen,
- QA-Status,
- Status maximal `layer_postprocess_candidate`.

QA:

- Hain ist stark, aber nicht zu voll.
- Lichtungen bleiben natuerlich.
- Terrain blockiert keine Kategorie hart.
- Mobile-Lesbarkeit bleibt erhalten.
- 2.5D-Diorama-Perspektive bleibt einheitlich.

## 10. Layer-Brief: `slot_markers`

Zweck:

- Spaetere freie und spaetere Slots neutral sichtbar machen, ohne
  Kategorien oder BuildState einzubacken.

Strukturell aus Candidate A uebernehmen:

- ca. 12 plausible Reserveflaechen,
- zentrale Lichtung plus Randwiesen,
- Hainrand-, Ufer- und Hoehenbereiche,
- Reserve fuer 16-20 Slots.

Neu/sauberer zeichnen oder trennen:

- neutrale Marker als eigene Dokumentationsidee,
- freier Slot und spaeterer Slot visuell unterscheidbar,
- gewaehlter Slot als ruhiger Fokuszustand,
- Marker so klein/ruhig, dass die Insel Ort bleibt.

Darf nicht enthalten:

- Hausplatz,
- Marktplatz,
- Werkstattplatz,
- feste Kategoriepads,
- Wort-/Sprachzuweisung,
- automatische Platzierung,
- Persistenz oder BuildState,
- Pins/Icons mit App-UI-Gefuehl.

Exportidee fuer spaeter:

- Dokumentationscandidate unter `docs/world_design/previews/`,
- einzelne Marker-/State-Ideen getrennt vom `island_base`,
- noch keine Runtime-Mapdaten,
- noch keine Flutter-Integration.

Metadatenpflicht:

- Layer-Familie `slot_markers`,
- Slot-Zustand: frei, spaeter, gewaehlt,
- Uferhain-Bezug,
- QA fuer Neutralitaet,
- Status maximal `layer_postprocess_candidate`.

QA:

- Slots bleiben Lage, nicht Kategorie.
- Alle freien Slots koennen grundsaetzlich verschiedene Bauideen tragen.
- Spaetere Slots wirken ruhig, nicht strafend.
- Marker verdecken Hain, Wasser, Wege und Bauplatz nicht.

## 11. Optionaler spaeterer Layer: `build_stations`

`build_stations` sind fuer CK nur Folgekontext, keine aktuelle Freigabe.

Spaeterer Brief muss sicherstellen:

- Build Station erscheint erst am gewaehlten Slot,
- Build Station ist Weltobjekt, nicht Menue,
- Haus ist Hauptidee, Garten/Werkstatt/Garage koennen kleinere Alternativen
  sein,
- Worker/Tali/Vori koennen die Station beleben,
- keine Shop-, Bottom-Sheet- oder Labelwolken-Optik.

M16-CK erzeugt keine Build-Station-Bilder und keine BuildChoice-Logik.

## 12. Vorgeschlagener spaeterer Dokumentationspfad

Ein spaeterer Freigabe-Slice kann diesen Dokumentationspfad nutzen:

```text
docs/world_design/previews/m16_cl_candidate_a_layer_postprocess_candidates/
```

Regeln:

- Nur unter `docs/world_design/previews/`.
- Kein `assets/`-Pfad.
- Keine Runtime-Integration.
- Keine Flutter-Referenz.
- Keine automatische Kopie in Produktdateien.
- Exakter Pfad muss im spaeteren Bild-/Postprocess-Slice erneut ausdruecklich
  erlaubt werden.

## 13. Vorgeschlagene spaetere Dateinamen

```text
talvori_island_base_uferhain_structure_postprocess_candidate_a_1x.png
talvori_water_paths_uferhain_structure_postprocess_candidate_a_1x.png
talvori_terrain_layers_uferhain_structure_postprocess_candidate_a_1x.png
talvori_slot_markers_uferhain_structure_postprocess_candidate_a_1x.png
talvori_uferhain_layer_postprocess_metadata.md
talvori_uferhain_layer_postprocess_contact_sheet_1x.png
```

Diese Namen sind Vorschlaege fuer einen spaeteren Slice. M16-CK erstellt diese
Dateien nicht.

## 14. Metadatenanforderungen

Eine spaetere Metadata-Datei muss mindestens enthalten:

- `candidate_id`
- `layer_family`
- `working_name`
- `intended_use`
- `slice_id`
- `status`
- `source_tool`
- `source_file`
- `source_candidate`
- `structure_reference`
- `style_reference`
- `master_reference`
- `asset_spec`
- `postprocess_brief`
- `prompt_or_paintover_notes`
- `negative_prompt_or_forbidden_changes`
- `postprocess_tool`
- `license_notes`
- `export_format`
- `pixel_size`
- `scale_variant`
- `transparency_notes`
- `layer_notes`
- `qa_status`
- `approved_by`
- `blocked_reason`
- `allowed_scope`
- `not_asset_path_check`
- `not_engine_ready_check`
- `not_approved_asset_check`
- `no_text_or_ui_check`
- `uferhain_identity_check`
- `candidate_a_structure_check`
- `neutral_slot_check`
- `layer_separation_check`
- `mobile_readability_check`

Pflichtstatus:

```text
status: layer_postprocess_candidate
approved_by: none
allowed_scope: documentation_review_only
```

`engine_ready_candidate`, `approved_asset`, `production_asset` und Dateien
unter `assets/` bleiben blockiert.

## 15. QA-Kriterien

Jeder spaetere Layer-Candidate muss pruefen:

- Uferhain-Identitaet: Kueste, Flussarm, Hain, zentrale Lichtung.
- Candidate-A-Struktur: Silhouette, Randreserven, Hoehenlogik bleiben
  erkennbar.
- Kein Pixel-Nachzeichnen: Candidate A ist Struktur, nicht Kopiervorlage.
- Layertrennung: Wasser, Land, Terrain, Slots, Station, Figuren und HUD sind
  getrennt.
- Slot-Neutralitaet: keine Kategorieplaetze, keine Pins, keine festen
  Bauzwang-Zonen.
- Mobile-Lesbarkeit: grosse Formen bleiben klar.
- Game-DNA: cozy 2.5D island-first, object-first, kein Worksheet.
- Pfadschutz: nur Dokumentationspfad, nie `assets/`.
- Statusschutz: maximal `layer_postprocess_candidate`.
- Keine App-Screens, keine HUD/Bubbles, keine Texte, keine Labels.

## 16. Postprocess-Verbote

- Kein finales Asset.
- Kein Engine-ready.
- Kein `approved_asset`.
- Keine Dateien unter `assets/`.
- Keine Flutter-/Dart-Dateien.
- Keine App-Integration.
- Keine Gebaeudeeinbindung.
- Keine Figuren.
- Keine UI/HUD/Bubbles.
- Keine Texte, Labels, Pins oder Icons.
- Keine festen Kategorieplaetze.
- Keine direkte Candidate-A-Pixelkopie.
- Kein Codex-Nachzeichnen.
- Keine externen Writes ohne Freigabe.

## 17. Entscheidung

```text
Externe Postprocess-/Layer-Arbeit spaeter sinnvoll: JA
Neue Bildgenerierung jetzt noetig: NEIN
Candidate A als Pixelbild uebernehmen: NEIN
Candidate A als Strukturreferenz nutzen: JA
Engine-ready oder assets/ weiterhin blockiert: JA
```

Naechster Slice:

```text
M16-CL Candidate A Layer Postprocess Candidate Production oder
M16-CL Candidate A Layer Candidate Intake and QA
```

Die Produktionsvariante darf nur starten, wenn der Nutzer ausdruecklich neue
Bilder, den Dokumentationspfad, erlaubte Dateinamen, Tool-Rolle und
Maximalstatus erlaubt. Die Intake-/QA-Variante ist sinnvoll, wenn externe
Dateien ausserhalb von Codex erzeugt und danach nur geprueft werden sollen.

## 18. Stop-Regeln

- Keine neuen Bilder.
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
