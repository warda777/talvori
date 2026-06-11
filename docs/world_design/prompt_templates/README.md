# Talvori Prompt Templates

Stand: 2026-06-11

Status: `Prompt-Template-System / keine Implementierungsfreigabe`

## Zweck

Dieser Ordner enthaelt kurze wiederverwendbare Arbeitsvertraege fuer haeufige
Talvori Codex-Slices. Die Templates sollen Chat-Prompts kuerzer machen, ohne
Pflichtlektuere, Stop-Regeln, M16-T-ID-Abgleich, Checks, Output-Regeln,
Commit-Grenzen oder External-Write-Grenzen zu verlieren.

## Grundregeln

- Templates ersetzen `docs/world_design/336-documentation-map-and-slice-reading-rules.md` nicht.
- Templates konkretisieren die Slice-Arbeit und erben Pflichtlektuere,
  Standardchecks und Stop-Regeln aus 336.
- Ein Kurzprompt muss mindestens Slice-ID, Template, Ziel, erwartete Dateien
  oder erlaubte Bereiche, besondere Grenzen und Commit-Status nennen.
- Bei Konflikt zwischen Prompt, Template, 336, 328, AGENTS.md oder Fachdocs
  gilt die strengere Stop-Regel.
- Kein Commit ohne separate ausdrueckliche Freigabe.
- Keine externen Writes ohne separate ausdrueckliche Freigabe.
- Templates sind keine App-, Code-, Asset-, Persistenz-, Route-, Supabase-,
  SRS- oder `word_progress`-Freigabe.

## Verfuegbare Templates

| Template | Datei | Zweck |
| --- | --- | --- |
| Docs-only Slice | `docs_only_slice.md` | Docs-/Gate-/Planungs-Slices. |
| Review Slice | `review_slice.md` | Review, Commitfaehigkeit, Scope und Risiken. |
| Art / Master Reference Slice | `art_master_reference_slice.md` | Art Bible, Master References, Asset-Specs und KI-Art-Gates. |
| Visual Documentation Slice | `visual_documentation_slice.md` | Dokumentationsvisuals, wenn Visuals ausdruecklich erlaubt sind. |
| Implementation Slice | `implementation_slice.md` | Isolierte Code-Slices mit expliziter Implementierungsfreigabe. |

## Minimaler Kurzprompt

```text
Slice: M16-XX
Template: docs_only_slice
Ziel: ...
Erwartete Dateien:
- ...

Besondere Grenzen:
- ...

Commit: nein
Nutze AGENTS.md, 328, 336 und das Template.
```

Codex muss im Abschluss berichten, welches Template genutzt wurde und welche
Regeln aus 336/Template geerbt wurden.

