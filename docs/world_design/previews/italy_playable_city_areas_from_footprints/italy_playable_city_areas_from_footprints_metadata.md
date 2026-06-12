# Italy Playable City Areas From Footprints Metadata

Stand: 2026-06-12

Status: `documentation_only` / `playable_city_area_candidates` /
`not_asset` / `not_runtime_data` / `not_engine_ready`

## Source Basis

- source_gate: `docs/world_design/410-italy-city-footprints-istat-comuni-gate.md`
- source_visual:
  `docs/world_design/previews/italy_city_footprints_istat_comuni/`
- source_owner: Istat - Istituto nazionale di statistica
- source_dataset: Confini delle unita amministrative a fini statistici
- source_level_used: `comuni` / municipality boundaries
- source_variant_used: version generalizzata / less detailed
- source_year: 2026
- source_download_url:
  `https://www.istat.it/storage/cartografia/confini_amministrativi/generalizzati/2026/Limiti01012026_g.zip`
- extracted_layer: `Com01012026_g/Com01012026_g_WGS84`
- projection_file: `WGS_1984_UTM_Zone_32N`
- local_processing: temporary read from `/private/tmp`, no source shapefile
  copied into the repo

## License And Attribution

- license_page: `https://www.istat.it/note-legali/`
- license_model: CC BY 4.0 unless otherwise indicated on the Istat site
- attribution_required: yes
- attribution_note_for_docs:
  `Fonte: Istat, Confini delle unita amministrative a fini statistici, 2026, CC BY 4.0; modified for Talvori documentation visual.`
- license_link_required: `https://creativecommons.org/licenses/by/4.0/deed.it`
- scope_note: this metadata records source and review use only; it does not
  approve runtime, asset, production, app, or engine use.

## Reuse-Before-Build Check

| Grundlage | Ergebnis | Entscheidung |
| --- | --- | --- |
| ISTAT-Comuni-Quelle aus 410 | geeignet | Wiederverwendet als Source-Footprint-Basis. |
| 407-Makro-Blockout | geeignet als Richtung, aber zu grob fuer Stadtbereiche | Stadtlogik bleibt relevant; spielbare Stadtbereiche werden aus 410 abgeleitet. |
| 408-Stadtanker-Liste | geeignet | 6 Kernstaedte und 7 Reserve-Staedte bleiben fuehrend. |
| 409-Europa-Zoom-Architektur | geeignet | `playable_city_area` bleibt generische Stadt-Zoom-Stufe, keine Italien-Sonderarchitektur. |
| OSM / MapTiler / OpenMapTiles / free-map.org | nicht noetig fuer diesen Slice | Nicht genutzt; kein Tile-, Screenshot- oder Fremdasset-Import. |

Keine Kartenbilder, Screenshots, Tiles, Google Maps, Apple Maps, Pinterest,
Luftbilder oder Atlasbilder wurden kopiert oder nachgezeichnet.

## Generated Files

All generated files are documentation files only and remain under:

```text
docs/world_design/previews/italy_playable_city_areas_from_footprints/
```

Files:

- `italy_playable_city_areas_from_footprints.svg`
- `italy_playable_city_areas_from_footprints.png`
- `italy_playable_city_areas_from_footprints_metadata.md`

## Derivation Rule

The ISTAT footprint is used only as a faint source outline and planning cue.
It is not copied 1:1 into gameplay.

Each city receives an abstracted Talvori candidate made of:

- city core,
- reserve area,
- edge / no-build ring,
- possible start build spot.

These shapes are local documentation visuals. They are not final polygons,
not collision, not build-zone geometry, not pathfinding, not YAML/JSON, not
app data, and not assets.

## Derived City Areas

| City | Role | Playable-city-area idea | Start-build note |
| --- | --- | --- | --- |
| Milano | core | Nord-Hub, trade/workshop feel, broad compact core | flacher Startplatz |
| Venezia | core | Wasserstadt, bridge/discovery feel, careful edge buffers | kanalnaher Start |
| Bologna | core | Wegekreuz and learning/network hub | kompakter Start |
| Firenze | core | Kulturkern, craft/archive, softer reserve | ruhiger Start |
| Roma | core | Main hub, history, central growth space | grosser Startplatz |
| Napoli | core | Coastal core, energy, southern gateway | Kuestenstart |
| Genova | reserve | Western harbor reserve, narrow coastal growth | kleiner Start |
| Pisa | reserve | Landmarke and small object-focus city | kleiner Start |
| Verona | reserve | Northeast reserve, culture/visit role | kleiner Start |
| Bari | reserve | Adriatic southeast harbor reserve | kleiner Start |
| Palermo | reserve | Sicily west / island hub candidate | kleiner Start |
| Catania | reserve | Sicily east / height-volcano influence | kleiner Start |
| Cagliari | reserve | Sardinia / island hub candidate | kleiner Start |

## Visual Simplification

- The Italy overview stays reduced and soft so the city candidates remain the
  focus.
- The true ISTAT footprint outline is intentionally thin and muted.
- The playable candidate is drawn as a simplified organic area inside/around
  the source footprint.
- Core cities use stronger visual weight.
- Reserve cities use quieter visual weight.
- No exact geometry scale is implied.
- No city polygon is exported as runtime data.

## Visual-QA

| Check | Result |
| --- | --- |
| All 13 cities included | JA |
| Core cities stronger than reserve cities | JA |
| Each city shows core, reserve, edge/no-build and start marker | JA |
| Italy context visible | JA |
| Labels readable | JA |
| Labels clipped | NEIN |
| GIS-/Atlas-/Dashboard-look dominant | NEIN |
| Status protection visible | JA |
| Runtime geometry created | NEIN |
| Assets created | NEIN |

## Non-Runtime Boundary

This visual and metadata are not:

- runtime data,
- final coordinates,
- production polygons,
- collision geometry,
- build-zone geometry,
- no-walk/no-build geometry,
- pathfinding data,
- YAML/JSON/YML,
- app data,
- assets,
- engine-ready exports.

Before any runtime or app work, a separate review must decide which
city-area abstractions are suitable for Greybox, buildable-ground planning,
path planning, and later game-look work.
