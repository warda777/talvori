# M16-CE: Starter Island Asset Candidate Gate

Stand: 2026-06-11

Status: `Analyse-/Gate-Slice / keine Asset-Candidate-Erzeugung`

Template: `docs/world_design/prompt_templates/art_master_reference_slice.md`

## 1. Zweck und Non-Goals

M16-CE bereitet das erste echte Starter-Island-Asset-Candidate-Gate vor,
ohne bereits Bilder, Assets oder Engine-ready Candidates zu erzeugen.

Ziel:

- entscheiden, welche einzelne Starter-Island-Asset-Familie zuerst als
  Candidate-Gate sinnvoll ist,
- klaeren, warum andere Familien noch warten sollen,
- Quellen, Metadaten, QA, Exportregeln und Pfadgrenzen fuer das Folge-Gate
  definieren,
- klaeren, welche Rolle ChatGPT, KI-Bildtool, Figma/Design-Tool, optionaler
  Artist und Codex spaeter haben,
- entscheiden, ob M16-CF echte Candidate-Erzeugung erlauben darf oder weiter
  blockiert bleibt.

Non-Goals:

- keine Assets,
- keine Dateien unter `assets/`,
- keine Bilder,
- keine PNG/SVG,
- keine Preview-Ordner,
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

M16-CE ist ein Entscheidungs- und Grenzdokument. Es erzeugt noch keinen
`asset_candidate` und keinen `engine_ready_candidate`.

## 2. Eingangsquellen und Abgrenzung

Fuehrende Quellen:

- `docs/world_design/365-modern-mobile-game-direction-board.md`
- `docs/world_design/366-ai-art-production-pipeline-and-style-consistency-gate.md`
- `docs/world_design/367-talvori-art-bible-v1.md`
- `docs/world_design/368-starter-island-master-reference-set.md`
- `docs/world_design/370-asset-family-and-export-spec.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`

Abgrenzung:

- M16-BY gibt die Game-DNA: Cozy Island Diorama Builder, island-first,
  object-first, character-assisted, Build Station am Slot und kein
  Worksheet-/Menue-first-Gefuehl.
- M16-BZ gibt die kontrollierte KI-Art-Pipeline und verbietet freie
  Einzelprompts, Codex-Bildnachbau und ungepruefte finale Assets.
- M16-CA gibt Style-System, Kamera, Perspektive, Licht, Farbe, Figuren,
  HUD und QA gegen Stilbruch.
- M16-CB gibt Master-Reference-Briefs fuer Uferhain, Build Station,
  Haus-Bauphasen, Worker/Tali/Vori, UI/HUD und Slot/Marker/Layer.
- M16-CC gibt Asset-Familien, Layer, Export, Groessen, Benennung,
  Metadaten und QA-Status.

Das starke Talvori-Referenzbild bleibt Art-Direction-Reference. Es ist kein
App-Screen, kein finales Asset, nicht nach `assets/` zu kopieren und nicht
von Codex nachzuzeichnen.

`modern_mobile_game_direction_board_v2.*` bleibt rejected/transitional und
darf keine Zielqualitaet setzen.

## 3. Ergebnisentscheidung

Die erste Starter-Island-Asset-Familie fuer ein spaeteres Candidate-Gate soll
sein:

```text
island_base
```

Begruendung:

- `island_base` setzt die Grundsilhouette, Perspektive, Massstaeblichkeit und
  Uferhain-Identitaet.
- Alle anderen Starter-Island-Familien haengen daran: Terrain, Wasser/Wege,
  Slots, Build Station und Bauphasen muessen auf derselben Basis sitzen.
- Ohne Inselbasis kippen spaetere Slots zu abstrakten Markern und Build
  Stations zu freischwebenden UI-Objekten.
- Ein erstes `island_base`-Candidate-Gate kann noch ohne Produktintegration
  pruefen, ob Uferhain als Kuestenhain-/Flussufer-Starterinsel lesbar wird.

M16-CE erlaubt noch keine Erzeugung. Es entscheidet nur, dass ein spaeteres
M16-CF diese Familie als ersten Candidate-Scope oeffnen darf, wenn der Prompt
Bilder, Zielpfad, Metadaten und QA ausdruecklich freigibt.

## 4. Familienvergleich

| Familie | Wert als erstes Gate | Abhaengigkeiten | Risiko wenn zuerst | Entscheidung |
| --- | --- | --- | --- | --- |
| `island_base` | Definiert Silhouette, Perspektive, Uferhain-Identitaet und Flaechenreserve. | Art Bible, Uferhain Master Reference, Asset-Spec. | Kann zu monolithisch werden, wenn Terrain, Slots oder UI hineingebacken werden. | Zuerst. |
| `terrain_layers` | Macht Hain, Wege, Hoehen und Ufer lebendig. | Braucht stabile Inselbasis und Layergrenzen. | Terrain wird zur finalen Gesamtkarte statt getrenntem Layer. | Nach `island_base`. |
| `slot_markers` | Macht 6 freie und 6 spaetere Orte pruefbar. | Braucht Inselmassstab und Slotflaechen. | Slots werden wieder Kategorieplaetze oder UI-Pins. | Nach `island_base` und grober Terrainlogik. |
| `build_stations` | Fuehrt BuildChoice als Weltobjekt ein. | Braucht Slotmassstab, Kamera und Bodenbezug. | Station wirkt wie Menue, Shop oder Overlay. | Nach Inselbasis und Slot-Layer. |
| `building_phases` | Zeigt Fundament, Wand-Ghost und Baufortschritt. | Braucht Slot, Build Station und Plot-Fokus. | Bauphase wirkt isoliert oder oeffnet BuildState-Scope. | Spaeter, nach Basis/Slot/Station. |

## 5. Scope fuer das erste Folge-Gate

M16-CF sollte, falls freigegeben, heissen:

```text
M16-CF Starter Island Base Candidate Generation Gate
```

Moeglicher Scope:

- nur Asset-Familie `island_base`,
- nur Uferhain-Starterinsel,
- nur Dokumentations-/Candidate-Erzeugung ausserhalb von `assets/`,
- keine Runtime-Integration,
- keine Engine-ready Candidate-Freigabe,
- keine finalen Assets,
- keine Slots als finale Marker,
- keine Build Station,
- keine Gebaeude,
- keine Figuren,
- keine HUD/Bubbles.

M16-CF darf nur dann Bilder oder Dateien erzeugen, wenn der M16-CF-Prompt
ausdruecklich erlaubt:

- Bildgenerierung,
- erlaubten Dokumentations-/Preview-Pfad,
- Dateinamen,
- Metadatenformat,
- QA-Kriterien,
- Tool-Rolle,
- Lizenz-/Source-Regeln,
- Status als `asset_candidate` oder niedriger,
- klare Nicht-Freigabe fuer `assets/`, Produktintegration und Engine-ready
  Nutzung.

Wenn diese Freigaben fehlen, bleibt M16-CF ebenfalls Analyse/Gate und darf
keine Candidate-Erzeugung starten.

## 6. Island-Base-Anforderungen fuer M16-CF

Ein spaeteres `island_base`-Candidate darf nur die Basis der Starter-Insel
pruefbar machen.

Pflichtbestandteile:

- Kuestenhain-/Flussufer-Starterinsel,
- Inselkontur mit Wassernaehe,
- Flussarm oder Uferarm als Identitaetstraeger,
- zentrale Lichtung / Hub,
- lesbarer Hain-/Waldnahbereich,
- leichte Hoehen oder ruhige Randbereiche,
- Flaechenreserve fuer ca. 12 sichtbare Slots,
- langfristige Reserve fuer ca. 16-20 Slots,
- 2.5D-Diorama-Perspektive aus der Art Bible.

Noch nicht enthalten:

- keine finalen Slot Marker,
- keine Kategorieplaetze,
- keine Build Station,
- keine Gebaeude,
- keine Figuren,
- keine HUD/Bubbles,
- keine finalen Terrain-Layer,
- keine produktive Map-Datei.

Erlaubte Strukturhinweise:

- grobe Flaechenzonen,
- lesbare Land-/Wasser-/Hain-Silhouette,
- ungefaehre Bauplatz-Reserve ohne feste Kategorie,
- dezente Orientierung fuer spaetere Layer.

Nicht erlaubt:

- monolithische finale Inselkarte,
- Slots als "Hausplatz", "Marktplatz" oder "Werkstattplatz",
- UI-Pins als Weltgrafik,
- zu realistische oder zu generisch-cozy Insel,
- Uferhain ohne Wasser-/Hain-Identitaet,
- Referenzbild-Kopie,
- v2-Board-Nachbau.

## 7. Quellen und Tool-Rollen

Spaetere Candidate-Erzeugung braucht klare Rollen.

| Rolle | Erlaubt fuer M16-CF, falls freigegeben | Nicht erlaubt |
| --- | --- | --- |
| ChatGPT | Art Direction schaerfen, Promptvarianten, Negative Prompts, QA-Regeln und Referenzbeschreibung liefern. | Finales Asset ohne Pipeline- und QA-Gate als produktiv erklaeren. |
| KI-Bildtool | Kontrollierte Kandidaten mit Style-/Structure-References erzeugen, falls Prompt und Tool explizit freigegeben sind. | Freie Einzelprompts ohne Referenzen und Metadaten. |
| Figma/Photoshop/Photopea/Aseprite | Zuschnitt, Layerplanung, Paintover, Strukturklarheit und Exportvorbereitung. | App-Screen oder produktives Asset ohne Asset-Gate. |
| Optionaler Artist | Kandidaten finalisieren, Stilbruch pruefen, Layerbarkeit verbessern. | Repo-Regeln oder Source-/Lizenz-Metadaten umgehen. |
| Codex | Dokumentation, Gate-Regeln, Metadatenstandard, Checks und Review. | Hochwertige Spielbilder erzeugen, Referenzen nachzeichnen oder Dateien nach `assets/` schreiben. |

Codex bleibt in M16-CE rein dokumentierend.

## 8. Metadaten fuer einen spaeteren Candidate

Ein M16-CF-Candidate braucht mindestens die M16-CC-Pflichtfelder:

```text
asset_id:
asset_family: island_base
working_name:
intended_use:
slice_id: M16-CF
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

Starter-Island-spezifisch ergaenzen:

```text
uferhain_identity_check:
slot_capacity_check:
reserve_capacity_check:
perspective_check:
layer_separation_check:
mobile_readability_check:
not_asset_path_check:
```

Pflichtwerte fuer M16-CF, falls Candidate-Erzeugung erlaubt wird:

- `asset_family: island_base`
- `master_reference: docs/world_design/368-starter-island-master-reference-set.md`
- `style_reference: docs/world_design/367-talvori-art-bible-v1.md`
- `status: asset_candidate` oder niedriger
- `qa_status: not_checked` bis maximal `candidate_ready_for_asset_gate`
- `allowed_scope: documentation_candidate_only`

`engine_ready_candidate`, `approved_asset` und Dateien unter `assets/`
bleiben fuer M16-CF blockiert, ausser ein spaeteres separates Gate erlaubt
sie ausdruecklich. M16-CE erlaubt sie nicht.

## 9. Export- und Pfadgrenzen fuer spaeter

M16-CE erzeugt keine Dateien. Ein spaeteres M16-CF darf, falls der Prompt es
ausdruecklich erlaubt, einen Dokumentations-/Candidate-Ordner verwenden, z. B.:

```text
docs/world_design/previews/m16_cf_starter_island_base_candidate_gate/
```

Dieser Pfad waere Dokumentationsmaterial, nicht `assets/`.

Potentiell erlaubte Dateitypen fuer M16-CF, nur nach ausdruecklicher Freigabe:

- PNG als Dokumentationscandidate,
- ggf. Source-/Metadata-Datei ausserhalb produktiver Asset-Pfade,
- ggf. Contact Sheet zur QA, wenn Visuals erlaubt sind.

Nicht erlaubt fuer M16-CF ohne weiteres Gate:

- Dateien unter `assets/`,
- Engine-ready Exports,
- Flutter-Asset-Registrierung,
- App-Integration,
- Route/Navigation,
- Persistenz,
- BuildState,
- finale Spielassets.

## 10. QA-Kriterien fuer M16-CF

M16-CF muss jeden Candidate gegen diese Kriterien pruefen:

| QA-Bereich | Kriterium |
| --- | --- |
| Uferhain-Identitaet | Kueste/Flussarm und Hain sind klar lesbar. |
| Game-DNA | Wirkt wie Cozy Island Diorama Builder, nicht Worksheet, Dashboard oder Editor-Map. |
| Perspektive | 2.5D-Diorama-Perspektive passt zu Art Bible und spaeteren Figuren/Gebaeuden. |
| Slot-Kapazitaet | Ca. 12 sichtbare Slots sind moeglich, ohne dass Kategorien erzwungen werden. |
| Reserve | Langfristig 16-20 Slots bleiben denkbar. |
| Layerbarkeit | Inselbasis ist nicht als untrennbares finales Gesamtbild gedacht. |
| Mobile-Lesbarkeit | Silhouette, Hauptzonen und spaetere Slotflaechen bleiben auf Smartphone-Groesse erkennbar. |
| Stilbruch | Nicht zu realistisch, nicht zu generisch cozy, nicht zu kindlich, nicht malerisch-unlayerbar. |
| Referenzschutz | Starkes Referenzbild und v2-Board werden nicht kopiert oder nachgezeichnet. |
| Pfadschutz | Keine Datei liegt unter `assets/`. |
| Metadaten | Source, Prompt, References, Lizenznotiz und QA-Status sind vorhanden. |

Ein Candidate darf nicht weiterverwendet werden, wenn:

- Quelle oder Lizenz unklar sind,
- Prompt/References fehlen,
- Uferhain generisch wird,
- Slots als Kategorien erscheinen,
- Layerbarkeit nicht plausibel ist,
- die Datei als App-Screen oder finales Asset missverstanden werden kann.

## 11. Entscheidung zu M16-CF

M16-CF darf echte Candidate-Erzeugung grundsaetzlich vorbereiten und oeffnen,
aber nur mit einem expliziten neuen Prompt, der Bilder und Pfade freigibt.

Empfohlene Entscheidung:

```text
M16-CF darf asset_candidate-Erzeugung fuer island_base erlauben.
M16-CF darf keine engine_ready_candidates, approved_assets oder assets/-Writes
erlauben.
```

Begruendung:

- M16-BZ, M16-CA, M16-CB und M16-CC liefern genug Governance fuer einen ersten
  eng begrenzten Candidate.
- `island_base` ist die stabilste erste Familie, weil alle spaeteren Familien
  daran anschliessen.
- Ein Candidate ausserhalb von `assets/` kann Art-/Structure-/QA-Fragen
  pruefbar machen, ohne Produktintegration zu oeffnen.
- Engine-ready und App-Integration brauchen danach weiterhin eigene Gates.

Wenn M16-CF keinen expliziten Bild-/Tool-/Pfad-/Metadaten-/QA-Scope nennt,
bleibt auch M16-CF blockiert und darf nur Planung liefern.

## 12. Risiken und Gegenregeln

| Risiko | Gegenregel |
| --- | --- |
| Candidate wird als finales Asset gelesen. | Status und Metadaten muessen `documentation_candidate_only` oder niedriger tragen. |
| Codex erzeugt doch Spielbilder. | Codex bleibt Dokumentations-/Check-Rolle; Bildgenerierung nur durch explizit freigegebenes Tool im Folgeprompt. |
| Uferhain wird generisch. | Kueste/Flussarm/Hain/Zentrale Lichtung sind Pflicht-QA. |
| Inselbasis wird monolithische Map. | Terrain, Slots, Station, Gebaeude, Figuren und HUD bleiben eigene Familien. |
| Slots werden Kategorieplaetze. | M16-CF darf hoechstens Bauplatzreserve zeigen, keine Haus-/Markt-/Werkstattplaetze. |
| Bild kopiert Referenz. | Referenzbild bleibt Art-Direction-Reference; kein Nachzeichnen. |
| v2-Board wird Zielbild. | `modern_mobile_game_direction_board_v2.*` bleibt rejected/transitional. |
| Export wird zu frueh engine-ready. | M16-CF darf maximal `asset_candidate`, nicht `engine_ready_candidate`. |
| Pfade rutschen nach `assets/`. | Erlaubt ist nur ein expliziter Dokumentations-/Preview-Pfad ausserhalb `assets/`. |
| App-Code startet nebenbei. | Keine Flutter-/Dart-Dateien, keine App-Integration, keine Route, keine Persistenz. |

## 13. M16-T-IDs

M16-CE erfuellt:

- M16T-ASSET-013 Starter Island Asset Candidate Gate
- M16T-ASSET-014 First candidate family decision: island_base
- M16T-ASSET-015 Starter island candidate source and metadata requirements
- M16T-ASSET-016 Starter island candidate QA and path boundaries
- M16T-ASSET-017 M16-CF candidate generation permission boundary

M16T-ASSET-001 bleibt blockiert, weil M16-CE noch keine echten Assets, keine
Dateien unter `assets/`, keine Engine-ready Candidates und keine
Produktintegration freigibt.

## 14. Stop-Regeln

M16-CE gibt nicht frei:

- keine Assets,
- keine Dateien unter `assets/`,
- keine Bilder,
- keine PNG/SVG,
- keine Preview-Ordner,
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

## 15. Folgepfad

Empfohlener Folgepfad:

```text
M16-CE Starter Island Asset Candidate Gate
-> Review/Commit von M16-CE
-> M16-CF Starter Island Base Candidate Generation Gate
```

M16-CF sollte nur dann echte Candidate-Erzeugung erlauben, wenn der Prompt
explizit Bildgenerierung, Dokumentationspfad, Tool, Metadaten, QA und
Nicht-Integration freigibt. Danach waeren weitere Gate-Schritte noetig:

```text
M16-CF island_base asset_candidate
-> Review/QA
-> terrain_layers / water_paths Gate
-> slot_markers Gate
-> build_stations Gate
-> building_phases Gate
-> erst spaeter Engine-ready / assets / Flutter-Integration
```

