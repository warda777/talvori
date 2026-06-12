# Italy City Footprints ISTAT Comuni Metadata

Stand: 2026-06-12

Status: `documentation_only` / `source_review_visual` / `not_asset` /
`not_runtime_data` / `not_engine_ready`

## Source

- source_owner: Istat - Istituto nazionale di statistica
- source_page: `https://www.istat.it/it/archivio/222527`
- source_page_current_url:
  `https://www.istat.it/notizia/confini-delle-unita-amministrative-a-fini-statistici-al-1-gennaio-2018-2/`
- source_dataset: Confini delle unita amministrative a fini statistici
- source_level_used: `comuni` / municipality boundaries
- source_variant_used: version generalizzata / less detailed
- source_year: 2026
- source_update_context: confini amministrativi aggiornati al 1 gennaio 2026
- source_download_url:
  `https://www.istat.it/storage/cartografia/confini_amministrativi/generalizzati/2026/Limiti01012026_g.zip`
- extracted_layer: `Com01012026_g/Com01012026_g_WGS84`
- projection_file: `WGS_1984_UTM_Zone_32N`
- local_processing: temporary read from `/private/tmp`, no source shapefile
  copied into the repo

## License And Attribution

- license_page: `https://www.istat.it/note-legali/`
- license_model: CC BY 4.0 unless otherwise indicated on the Istat site
- commercial_use: allowed under CC BY 4.0 terms
- adaptation: allowed under CC BY 4.0 terms
- attribution_required: yes
- attribution_note_for_docs:
  `Fonte: Istat, Confini delle unita amministrative a fini statistici, 2026, CC BY 4.0; modified for Talvori documentation visual.`
- license_link_required: `https://creativecommons.org/licenses/by/4.0/deed.it`
- scope_note: this metadata records source and review use only; it does not
  approve runtime, asset, or production use.

## Generated Files

All generated files are documentation files only and remain under:

```text
docs/world_design/previews/italy_city_footprints_istat_comuni/
```

Files:

- `italy_city_footprints_istat_comuni.svg`
- `italy_city_footprints_istat_comuni.png`
- `italy_city_footprints_istat_comuni_metadata.md`

## Found City Footprints

| City label | ISTAT `COMUNE` | `PRO_COM_T` | Role |
| --- | --- | --- | --- |
| Milano | Milano | 015146 | core |
| Venezia | Venezia | 027042 | core |
| Bologna | Bologna | 037006 | core |
| Firenze | Firenze | 048017 | core |
| Roma | Roma | 058091 | core |
| Napoli | Napoli | 063049 | core |
| Genova | Genova | 010025 | reserve |
| Pisa | Pisa | 050026 | reserve |
| Verona | Verona | 023091 | reserve |
| Bari | Bari | 072006 | reserve |
| Palermo | Palermo | 082053 | reserve |
| Catania | Catania | 087015 | reserve |
| Cagliari | Cagliari | 118006 | reserve |

## Matching Notes

The source layer stores Italian municipality names in `COMUNE`. For the
Talvori German-facing city labels, the following matching rule was used:

- Rom -> `Roma`
- Florenz -> `Firenze`
- Venedig -> `Venezia`
- Mailand -> `Milano`
- Neapel -> `Napoli`
- Genua -> `Genova`
- Bologna, Pisa, Verona, Bari, Palermo, Catania and Cagliari match directly.

Broad substring matching is not safe because names such as `Romano`,
`Bariano`, `Baricella`, `Villafranca di Verona`, or `Orciano Pisano` can create
false positives. Exact `COMUNE` matching is required for future source work.

## Visual Simplification

- Italy overview is drawn from the ISTAT 2026 generalized region layer for
  context.
- The 13 city footprints are drawn from the ISTAT generalized Comuni layer.
- The right-side silhouettes are scaled per city for review readability and
  are not a common runtime scale.
- The route line is a review zoom cue only, not a path centerline or gameplay
  route.
- Core cities use a stronger color; reserve cities are quieter.

## Non-Runtime Boundary

This visual and its source read are not:

- runtime data,
- final coordinates,
- production polygons,
- collision geometry,
- build-zone geometry,
- no-walk/no-build geometry,
- pathfinding data,
- app data,
- assets,
- engine-ready exports.

Playable city areas must be abstracted in a future slice before any runtime,
Flutter, YAML/JSON, asset, or interaction work.
