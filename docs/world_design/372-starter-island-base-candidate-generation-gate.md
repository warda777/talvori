# M16-CF: Starter Island Base Candidate Generation Gate

Stand: 2026-06-11

Status: `Planungs-/Freigabe-Gate / noch keine Candidate-Erzeugung`

Template: `docs/world_design/prompt_templates/art_master_reference_slice.md`

## 1. Zweck und Non-Goals

M16-CF bereitet die konkrete spaetere Erzeugung erster
`island_base`-Candidates fuer Uferhain vor, ohne bereits Bilder, Dateien oder
Engine-ready Candidates zu erzeugen.

Ziel:

- den spaeter erlaubten Dokumentationspfad fuer Candidate-Dateien definieren,
- erlaubte Dateinamen und Statuswerte fuer M16-CG festlegen,
- Tool- und Rollenverteilung fuer ChatGPT, KI-Bildtool,
  Figma/Photopea/Aseprite/Artist und Codex klaeren,
- Prompt- und Negative-Prompt-Anforderungen fuer spaetere Bildgenerierung
  definieren,
- Pflichtmetadaten fuer `island_base` festlegen,
- QA-Checkliste fuer Uferhain / `island_base` definieren,
- entscheiden, ob M16-CG echte Candidate-Bildgenerierung erlauben darf.

Non-Goals:

- noch keine Bilder,
- noch keine PNG/SVG,
- noch kein Preview-Ordner,
- keine Dateien unter `assets/`,
- keine Engine-ready Candidates,
- keine approved Assets,
- keine finalen Spielbilder,
- keine App-Screens,
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

M16-CF ist eine Freigabeplanung fuer M16-CG. Es erzeugt selbst keinen
`asset_candidate`.

## 2. Eingangsquellen und Abgrenzung

Fuehrende Quellen:

- `docs/world_design/365-modern-mobile-game-direction-board.md`
- `docs/world_design/366-ai-art-production-pipeline-and-style-consistency-gate.md`
- `docs/world_design/367-talvori-art-bible-v1.md`
- `docs/world_design/368-starter-island-master-reference-set.md`
- `docs/world_design/370-asset-family-and-export-spec.md`
- `docs/world_design/371-starter-island-asset-candidate-gate.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`

Abgrenzung:

- M16-CE hat `island_base` als erste Starter-Island-Candidate-Familie
  entschieden.
- M16-CF definiert, wie M16-CG diese Entscheidung sicher operationalisieren
  darf.
- M16-CF erzeugt keinen Ordner, kein Bild, keine Metadatendatei und keinen
  Candidate.
- M16-CF erlaubt keine Engine-ready Candidates, keine approved Assets und
  keine Dateien unter `assets/`.

Das starke Talvori-Referenzbild bleibt Art-Direction-Reference. Es ist kein
App-Screen, kein finales Asset, nicht nach `assets/` zu kopieren und nicht von
Codex nachzuzeichnen.

`modern_mobile_game_direction_board_v2.*` bleibt rejected/transitional und
darf keine Zielqualitaet setzen.

## 3. Entscheidung fuer M16-CG

M16-CG darf echte Candidate-Bildgenerierung fuer `island_base` erlauben, wenn
der M16-CG-Prompt alle Grenzen aus diesem Dokument ausdruecklich uebernimmt.

Erlaubter Maximalstatus fuer M16-CG:

```text
asset_candidate
```

Ausdruecklich weiter blockiert:

- `engine_ready_candidate`,
- `approved_asset`,
- Dateien unter `assets/`,
- Flutter-/Dart-Code,
- App-Integration,
- Route,
- Navigation,
- Persistenz,
- BuildState,
- Produktivmechanik.

Wenn M16-CG keinen ausdruecklichen Bild-/Tool-/Pfad-/Metadaten-/QA-Scope
enthaelt, bleibt M16-CG ebenfalls ein Planungs-/Review-Slice und darf keine
Bildgenerierung starten.

## 4. Erlaubter Dokumentationspfad fuer M16-CG

M16-CF erzeugt keinen Ordner. Falls M16-CG spaeter Candidate-Dateien erzeugen
darf, ist der einzige erlaubte Dokumentationspfad:

```text
docs/world_design/previews/m16_cg_starter_island_base_candidate_generation/
```

Regeln:

- Dieser Pfad ist Dokumentationsmaterial.
- Dieser Pfad ist kein `assets/`-Pfad.
- Dateien darin sind keine App-Screens und keine finalen Spielassets.
- Der Ordner darf erst im M16-CG-Slice entstehen, wenn der Prompt
  Bildgenerierung und diesen Pfad ausdruecklich erlaubt.
- Keine Datei aus diesem Pfad darf automatisch nach `assets/` kopiert werden.
- Keine Datei aus diesem Pfad darf ohne weiteres Gate in Flutter registriert
  oder produktiv verwendet werden.

## 5. Erlaubte Dateinamen fuer M16-CG

M16-CF erzeugt keine Dateien. Fuer M16-CG sind, falls Bilder ausdruecklich
erlaubt werden, nur diese Dateinamenmuster erlaubt:

```text
talvori_island_base_uferhain_candidate_a_1x.png
talvori_island_base_uferhain_candidate_b_1x.png
talvori_island_base_uferhain_candidate_c_1x.png
talvori_island_base_uferhain_contact_sheet_1x.png
talvori_island_base_uferhain_candidate_metadata.md
```

Optional, falls das Tool zwingend eine Source- oder Arbeitsdatei liefert:

```text
talvori_island_base_uferhain_source_notes.md
```

Nicht erlaubt:

- zufaellige Generatornamen,
- Dateinamen mit Leerzeichen oder Umlauten,
- `final`, `approved`, `engine_ready`, `production`, `app`, `runtime` oder
  `asset` als Dateinamenbestandteil,
- Dateien ausserhalb des erlaubten Dokumentationspfads,
- Dateien unter `assets/`.

## 6. Tool- und Rollenverteilung

| Rolle | Darf in M16-CG, falls freigegeben | Darf nicht |
| --- | --- | --- |
| ChatGPT | Bildbrief, Prompt, Negative Prompt, Variantenbeschreibung und QA-Raster aus 365/367/368/370/371 ableiten. | Ein Bild als finales Asset, App-Screen oder direktes Nachzeichnen der Referenz deklarieren. |
| KI-Bildtool | 2-3 kontrollierte `island_base`-Candidates mit Style-/Structure-References erzeugen. | Freie Einzelprompts ohne Referenzen, Metadaten oder QA erzeugen. |
| Figma/Photopea/Aseprite | Zuschnitt, einfache Strukturklarheit, Contact-Sheet-Anordnung und Metadaten-Sichtung vorbereiten. | Produktives Layering, App-Screen-Layout oder Engine-ready Export behaupten. |
| Optionaler Artist | Candidate-Auswahl kommentieren, Stilbruch markieren, Paintover-Hinweise geben. | Repo-Gates, Lizenzpruefung oder Asset-Freigabe ersetzen. |
| Codex | Repo-Dokumentation, erlaubte Dateinamen, Metadatencheck, QA-Checkliste und Abschlussbericht fuehren. | Hochwertige Spielbilder erzeugen, Referenzbilder nachzeichnen, externe Writes ausfuehren oder Dateien nach `assets/` schreiben. |

Codex darf in M16-CG nur dann Bildwerkzeuge anstossen, wenn der Nutzer den
M16-CG-Slice ausdruecklich mit Bildgenerierung, erlaubtem Pfad und
Nicht-Integration freigibt.

## 7. Prompt-Anforderungen fuer M16-CG

Ein M16-CG-Bildprompt muss mindestens enthalten:

- Asset-Familie: `island_base`,
- Ort: Uferhain Starter-Insel,
- Stil: warmes 2.5D-Cozy-Island-Diorama,
- Perspektive: leicht erhoeht, einheitlich mit Art Bible,
- Identitaet: Kuestenhain-/Flussufer-Starterinsel,
- Pflichtmerkmale:
  - Inselkontur mit Wassernaehe,
  - Flussarm oder Uferarm,
  - zentrale Lichtung / Hub,
  - Hain-/Waldnahbereich,
  - leichte Hoehen oder ruhige Randbereiche,
  - Flaechenreserve fuer ca. 12 sichtbare Slots,
  - langfristige Reserve fuer 16-20 Slots,
- nur grobe Bauplatzreserve, keine finalen Slot Marker,
- keine Gebaeude, keine Figuren, keine HUD/Bubbles,
- keine Texte im Bild,
- keine App-UI,
- kein finaler Asset-Status.

Der Prompt muss klar sagen:

```text
This is a documentation candidate for art/structure review only, not a final
game asset, not an app screen, not engine-ready, and not for production use.
```

## 8. Negative-Prompt-Anforderungen

Ein M16-CG-Negative-Prompt muss mindestens blockieren:

- photorealistic,
- realistic 3D render,
- flat editor map,
- city builder UI,
- app screen,
- dashboard,
- worksheet,
- school exercise,
- menu UI,
- bottom sheet,
- labels,
- text,
- logo,
- characters,
- buildings,
- market,
- house,
- workshop,
- roads as rigid grid,
- category plots,
- pins,
- icons,
- final game asset,
- production asset,
- pixel-art mismatch,
- dark grim mood,
- generic tropical island,
- copied reference image,
- screenshot look,
- watermark,
- low-resolution blur,
- cluttered tiny details.

Wenn das verwendete Bildtool andere Negative-Prompt-Konventionen nutzt, muss
M16-CG die gleiche Absicht toolgerecht uebersetzen und im Metadata-File
dokumentieren.

## 9. Pflichtmetadaten fuer `island_base`

M16-CG muss fuer jeden Candidate eine Metadatenzeile oder einen Abschnitt im
Metadata-File erfassen.

Pflichtfelder:

```text
asset_id:
asset_family: island_base
working_name:
intended_use: documentation_candidate_only
slice_id: M16-CG
status: asset_candidate
source_tool:
source_file:
prompt:
negative_prompt:
style_reference: docs/world_design/367-talvori-art-bible-v1.md
structure_reference: docs/world_design/368-starter-island-master-reference-set.md
master_reference: docs/world_design/368-starter-island-master-reference-set.md
asset_spec: docs/world_design/370-asset-family-and-export-spec.md
candidate_gate: docs/world_design/371-starter-island-asset-candidate-gate.md
generation_gate: docs/world_design/372-starter-island-base-candidate-generation-gate.md
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
allowed_scope: documentation_candidate_only
```

Starter-Island-spezifische Pflichtfelder:

```text
uferhain_identity_check:
coast_or_riverarm_check:
grove_check:
central_clearing_check:
slot_capacity_12_check:
reserve_capacity_16_20_check:
neutral_slot_reserve_check:
perspective_check:
mobile_readability_check:
layer_separation_check:
no_text_or_ui_check:
not_asset_path_check:
not_engine_ready_check:
```

Erlaubte `qa_status`-Werte fuer M16-CG:

- `not_checked`,
- `style_check_failed`,
- `structure_check_failed`,
- `license_blocked`,
- `metadata_incomplete`,
- `mobile_readability_failed`,
- `needs_postprocess`,
- `candidate_ready_for_asset_gate`.

Nicht erlaubt:

- `approved_after_asset_gate`,
- `approved_asset`,
- `engine_ready_candidate`.

## 10. QA-Checkliste fuer Uferhain / `island_base`

M16-CG muss jeden Candidate einzeln pruefen.

| Check | Bestehensregel |
| --- | --- |
| Uferhain-Identitaet | Candidate ist klar als Kuestenhain-/Flussufer-Starterinsel lesbar. |
| Inselbasis | Bild zeigt Basis/Silhouette, nicht fertige Spielkarte. |
| Perspektive | 2.5D-Diorama-Perspektive passt zu Art Bible. |
| Flaechenreserve | Ca. 12 spaetere Slots sind plausibel, ohne feste Marker. |
| Langfristige Reserve | 16-20 Slots bleiben als Erweiterung denkbar. |
| Neutralitaet | Keine Kategorieplaetze wie Hausplatz, Marktplatz oder Werkstattplatz. |
| Layerbarkeit | Terrain, Slots, Station, Gebaeude, Figuren und HUD sind nicht final hineingebacken. |
| Mobile-Lesbarkeit | Hauptform, Wasser/Hain/Zentrum und Flaechenreserve bleiben klein lesbar. |
| Game-DNA | Wirkt cozy, hochwertig, island-first und nicht wie Worksheet, Dashboard oder Editor. |
| Referenzschutz | Kein Nachzeichnen des starken Referenzbilds und kein v2-Board-Zielbild. |
| Metadaten | Prompt, Negative Prompt, Source, References, Lizenz und QA-Status vorhanden. |
| Pfadschutz | Datei liegt nur im erlaubten Dokumentationspfad und nie unter `assets/`. |
| Statusschutz | Maximal `asset_candidate`, nie `engine_ready_candidate` oder `approved_asset`. |

Ein Candidate ist automatisch blockiert, wenn:

- Quelle, Lizenz oder Nutzungsrechte unklar sind,
- Metadaten fehlen,
- Uferhain generisch wird,
- Bild wie App-Screen, Level-Editor, Schulblatt oder Dashboard wirkt,
- Bild Texte, Labels, UI oder finale Kategorien enthaelt,
- Bild als finale Runtime-Karte missverstanden werden kann.

## 11. M16-CG-Freigabeentscheidung

M16-CF empfiehlt:

```text
M16-CG darf echte Bildgenerierung fuer 2-3 island_base-Dokumentations-
Candidates erlauben.
```

Diese Freigabe gilt nur unter diesen Grenzen:

- nur `island_base`,
- nur Uferhain,
- nur Dokumentationspfad aus Abschnitt 4,
- nur Dateinamen aus Abschnitt 5,
- nur Status `asset_candidate` oder niedriger,
- Metadatenpflicht aus Abschnitt 9,
- QA-Pflicht aus Abschnitt 10,
- kein `assets/`,
- kein `engine_ready_candidate`,
- kein `approved_asset`,
- keine Flutter-/Dart-Dateien,
- keine App-Integration.

M16-CG darf keine Produktintegration und keine Runtime-Nutzung vorbereiten.
Nach M16-CG muss ein Review entscheiden, ob ein Candidate:

- verworfen wird,
- ueberarbeitet werden muss,
- als `candidate_ready_for_asset_gate` dokumentiert werden darf,
- oder in ein weiteres, separates Asset-/Layer-/Engine-ready-Gate uebergeht.

## 12. Risiken und Gegenregeln

| Risiko | Gegenregel |
| --- | --- |
| Bildgenerierung wird als Asset-Freigabe gelesen. | M16-CG-Dateien bleiben Dokumentationscandidates mit Status `asset_candidate`. |
| Codex wird zum Bildgenerator. | Codex darf nur bei ausdruecklichem M16-CG-Scope ein Bildtool nutzen und bleibt Dokumentations-/QA-Agent. |
| Candidate landet unter `assets/`. | Nur der Dokumentationspfad aus Abschnitt 4 ist erlaubt. |
| Candidate wird engine-ready genannt. | `engine_ready_candidate` bleibt blockiert. |
| Candidate wird approved Asset. | `approved_asset` bleibt blockiert. |
| Insel wird generisch. | Uferhain-QA verlangt Kueste/Flussarm/Hain/Zentrum. |
| Slots werden Kategorieplaetze. | M16-CG darf nur Flaechenreserve zeigen, keine finalen Marker oder Kategorien. |
| Bild kopiert Referenz. | Referenzbild bleibt Art-Direction-Reference; kein Nachzeichnen. |
| Bild folgt abgelehntem v2-Board. | v2 bleibt rejected/transitional und darf keine Zielqualitaet setzen. |
| App-Code startet nebenbei. | Keine Flutter-/Dart-Dateien, keine App-Integration, keine Route, keine Persistenz. |

## 13. M16-T-IDs

M16-CF erfuellt:

- M16T-ASSET-018 Starter Island Base Candidate Generation Gate
- M16T-ASSET-019 Candidate documentation path and filenames
- M16T-ASSET-020 Candidate tool roles and prompt requirements
- M16T-ASSET-021 Island base metadata schema
- M16T-ASSET-022 Uferhain island_base QA checklist
- M16T-ASSET-023 M16-CG image generation permission boundary

M16T-ASSET-001 bleibt blockiert, weil M16-CF noch keine echten Assets, keine
Dateien unter `assets/`, keine Engine-ready Candidates und keine
Produktintegration freigibt.

## 14. Stop-Regeln

M16-CF gibt nicht frei:

- keine Bilder in diesem Slice,
- keine PNG/SVG in diesem Slice,
- kein Preview-Ordner in diesem Slice,
- keine Dateien unter `assets/`,
- keine Engine-ready Candidates,
- keine approved Assets,
- keine finalen Spielbilder,
- keine App-Screens,
- kein Code,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- keine Tests,
- keine externen Writes,
- kein Commit ohne separate ausdrueckliche Freigabe.

## 15. Folgepfad

Empfohlener Folgepfad:

```text
M16-CF Starter Island Base Candidate Generation Gate
-> Review/Commit von M16-CF
-> M16-CG Starter Island Base Candidate Generation
-> M16-CG Review
-> spaeteres Asset-/Layer-/Engine-ready-Gate nur bei akzeptiertem Candidate
```

M16-CG ist der erste Slice, der echte Candidate-Bildgenerierung erlauben darf,
aber nur mit den harten Grenzen aus diesem Dokument.

