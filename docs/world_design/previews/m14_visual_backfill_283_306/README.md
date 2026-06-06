# M14-V1 Visual Backfill For Docs 283-306

Stand: 2026-06-06

## Zweck

Dieser Ordner enthaelt echte PNG-Dokumentationsvisualisierungen fuer die
Dokumente `283` bis `306`. Der Backfill ersetzt nicht die Dokumente selbst,
sondern macht die seit M13-C bis M14-E2 entstandenen textuellen Planungs-,
Review-, Gate- und Stop-Regeln wieder visuell pruefbar.

Die Bilder orientieren sich am ruhigen Dokumentationsstil der M13-B-Previews:
helle Hintergrundflaeche, klare Ueberschriften, grosse Karten/Panels,
dezente Farben, lesbare Flows und Footer-Hinweise.

## Erzeugte PNGs

- `00_contact_sheet.png`
- `01_theme_island_capability_overview.png`
- `02_word_to_island_decision_pipeline.png`
- `03_device_accessibility_gate_map.png`
- `04_container_qa_overlay_map.png`
- `05_sensitive_policy_flow.png`
- `06_growth_timer_fairness_flow.png`
- `07_asset_scope_gate_map.png`
- `08_m13_readiness_gate_summary.png`
- `09_foundation_choice_product_flow.png`
- `10_word_to_island_product_preview_cards.png`
- `11_container_product_preview_examples.png`
- `12_review_harness_coverage_map.png`
- `13_small_implementation_candidate_gate.png`
- `14_global_stop_rules_map.png`

## Dokumentabdeckung

| PNG | Abgedeckte Dokumente | Zweck |
| --- | --- | --- |
| `01_theme_island_capability_overview.png` | `283` | ThemeIsland-Wellen, Capabilities und Gates |
| `02_word_to_island_decision_pipeline.png` | `284`, `292`, `299`, `300` | Word-to-Island-Entscheidungsflow ohne automatische Platzierung |
| `03_device_accessibility_gate_map.png` | `285`, `294`, `303`, `304` | Device-/Accessibility-Gates und Harness-Prueffokus |
| `04_container_qa_overlay_map.png` | `286`, `293`, `301`, `302` | Container-QA-Zonen, Fokusobjekt, Tap-Zonen und Blocker |
| `05_sensitive_policy_flow.png` | `287` | Sensitive-/Abstract-Policy-Flow und Stop-Regeln |
| `06_growth_timer_fairness_flow.png` | `288` | Faire Growth-/Timer-Regeln ohne Druck |
| `07_asset_scope_gate_map.png` | `289` | Asset-Scope-Gate gegen automatische Assetproduktion |
| `08_m13_readiness_gate_summary.png` | `290`, `295`, `296` | Readiness, Scope Freeze und Candidate Gate ohne Freigabe |
| `09_foundation_choice_product_flow.png` | `291`, `294`, `297`, `298` | Foundation-Choice-Flow als reversibler Lernfokus |
| `10_word_to_island_product_preview_cards.png` | `299`, `300` | Produktnahe Word-to-Island-Beispielkarten |
| `11_container_product_preview_examples.png` | `301`, `302` | Container-Beispiele ohne Inventarliste |
| `12_review_harness_coverage_map.png` | `303`, `304` | Harness-Coverage als Review-Plan, nicht als Testfreigabe |
| `13_small_implementation_candidate_gate.png` | `305`, `306` | Candidate Review mit klarer No-Code-Entscheidung |
| `14_global_stop_rules_map.png` | `283`-`306` | Uebergreifende Stop-Regeln |
| `00_contact_sheet.png` | alle erzeugten PNGs | Schnelle Sichtpruefung aller Backfill-Visuals |

## Hinweise

- Diese PNGs sind Dokumentationspreviews.
- Sie sind keine finale UI.
- Sie sind keine App-Screens.
- Sie sind keine Spielassets.
- Sie sind keine Asset-Dateien unter `assets/`.
- Sie erzeugen keinen Code, keine Tests, keine Widget-Tests und keine
  App-Integration.
- Sie erzeugen keine Runtime-Konfiguration und keine Implementierungsfreigabe.
- `frame_started` bleibt blockiert.
- Texte muessen innerhalb von Karten, Rahmen und Panels bleiben.

## Generator

Die PNGs wurden mit folgendem lokalen Dokumentationsgenerator erzeugt:

`docs/world_design/previews/m14_visual_backfill_283_306/generate_visuals.py`

Der Generator nutzt die lokale `.venv` und Pillow. Er ist Dokumentations-/
Preview-Tooling und keine App-/Runtime-Logik.
