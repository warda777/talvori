# Template: Art / Master Reference Slice

Status: `Arbeitsvertrag / keine Bild-, Asset- oder Implementierungsfreigabe`

## Einsatz

Nutze dieses Template fuer Art Bible, Master References, Asset-Specs,
KI-Art-/Asset-Pipeline-Gates, Style-System-Gates und visuelle
Produktionsgrenzen.

## Kurzprompt muss nennen

- Slice-ID,
- Ziel,
- erwartete Markdown-Dateien,
- ob Visuals erlaubt sind,
- ob Assets erlaubt sind,
- besondere Grenzen,
- Commit-Status.

## Pflichtabgleich

Beruecksichtige, wenn betroffen:

- M16-BY / `365-modern-mobile-game-direction-board.md`,
- M16-BZ / `366-ai-art-production-pipeline-and-style-consistency-gate.md`,
- M16-CA / `367-talvori-art-bible-v1.md`,
- M16-CB / `368-starter-island-master-reference-set.md`,
- 328 und 336.

## Harte Art-/Asset-Grenzen

- Codex erzeugt keine hochwertigen Spielbilder.
- Codex zeichnet Referenzbilder nicht nach.
- Keine Assets unter `assets/` ohne eigenes Asset-Gate und Freigabe.
- Keine High-Fidelity-Bilder, ausser der Kurzprompt erlaubt sie
  ausdruecklich.
- Keine App-Screens, ausser der Kurzprompt erlaubt einen Screen-Konzept-Slice
  ausdruecklich und grenzt ihn als Dokumentationsmaterial ab.
- Reference, Style Reference, Structure Reference, Master Reference,
  Asset Candidate und finales Asset muessen getrennt bleiben.
- `modern_mobile_game_direction_board_v2.*` bleibt rejected/transitional und
  darf keine Zielqualitaet setzen.

## Standard-Stop-Regeln

- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine externen Writes,
- kein Commit ohne Freigabe.

## Standardchecks

```bash
git status --short
git diff --check
git status --short -- lib assets test integration_test ios android macos web windows linux
```

Falls Visuals ausdruecklich erlaubt sind, zusaetzlich Visual-QA nach
`visual_documentation_slice.md`.

## Abschlussbericht

Berichte:

- genutztes Template,
- geaenderte/erstellte Dateien,
- neue/geaenderte M16-T-IDs,
- ob 328/336 aktualisiert wurden,
- welche Art-/Asset-Grenzen angewandt wurden,
- ob Codex keine Spielbilder/Assets erzeugt hat,
- Check-Ergebnisse,
- Risiken/offene Punkte,
- empfohlener Folge-Slice,
- kein Commit durchgefuehrt: JA/NEIN.

