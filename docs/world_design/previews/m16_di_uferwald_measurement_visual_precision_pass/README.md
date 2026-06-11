# M16-DI Uferwald Measurement Visual Precision Pass Preview

Status: `documentation_only`, `planning_visual`, `not_runtime_data`,
`not_asset`, `not_engine_ready`

Dieser Ordner enthaelt die M16-DI-Dokumentationsvisuals fuer den Uferwald
Measurement Visual Precision Pass.

Dateien:

- `uferwald_measurement_visual_precision_pass.svg`
- `uferwald_measurement_visual_precision_pass.png`
- `uferwald_measurement_visual_precision_contact_sheet.png`
- `01_walkable_and_water_review.png`
- `02_build_and_no_build_review.png`
- `03_obstacles_and_occlusion_review.png`
- `04_anchors_and_sort_bands_review.png`

Die M16-DI-FIX-Ueberarbeitung trennt die urspruenglich ueberladene
Gesamtansicht in vier pruefbare Detailansichten:

1. Walkable/Water-Review: Laufkorridor, Wasser, Wassergrenze,
   `water_no_walk_buffer`, Engpass-/Konfliktmarker.
2. Build/No-Build-Review: organische Build-Zonen, `no_build_mask`,
   Wegschutz, Wasser-/Rand-/Hub-/Anchor-Schutz.
3. Obstacles/Occlusion-Review: Deko vs harte Blocker, Baum-/Hainrollen,
   Fels-/Klippenrollen, Occlusion-Kanten.
4. Anchors/Sort-Bands-Review: Anchor-Rollen und Sort-Bands.

Die Visuals machen Regeln aus
`docs/world_design/391-uferwald-measurement-precision-pass.md` sichtbar:
Pfadbreiten, Wasser-/Uferpuffer, Baum-/Hainrollen, Fels-/Klippenrollen,
No-Walk-/No-Build-Unionen, Pfad-gegen-Blocker-QA, Sort-/Occlusion-Kanten und
Anchor-Rollen.

Grenzen:

- keine Runtime-Mapdaten,
- keine finalen Koordinaten,
- keine JSON/YAML-Daten,
- keine Assets,
- keine Dateien unter `assets/`,
- keine Engine-ready Candidates,
- keine App- oder Code-Freigabe.
