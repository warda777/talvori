# M16-CD: Codex Prompt Compression and Slice Template Gate

Stand: 2026-06-11

Status: `Docs-/Template-Gate-Slice / keine Implementierung`

## 1. Zweck und Non-Goals

M16-CD legt fest, wie Talvori kuenftig kurze Codex-Prompts nutzen kann, ohne
die Sicherheits- und Qualitaetsregeln aus AGENTS.md, 328, 336 und den
relevanten Fachdocs zu verlieren.

Ziel:

- wiederkehrende Pflichtlektuere, Stop-Regeln, Checks und Output-Regeln in
  Repo-Dokumenten und Templates verankern,
- Chat-Prompts auf Slice-ID, Template, Ziel, erwartete Dateien und besondere
  Grenzen reduzieren,
- M16-T-ID-Abgleich, Scope-Checks, Commit-Grenzen und External-Write-Grenzen
  weiter verbindlich halten,
- M16-CC und folgende Slices mit kuerzeren Prompts startbar machen.

Non-Goals:

- keine App-/Flutter-/Dart-Codeaenderung,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- keine Tests,
- keine Assets,
- keine Bilder,
- keine Preview-Ordner,
- keine PNG/SVG,
- keine externen Writes,
- keine Stashes anfassen,
- kein Commit.

M16-CD gibt keine Implementierung frei. Templates sind Arbeitsvertraege, keine
Produktivfreigabe.

## 2. Problem: Prompts wurden zu lang

Talvori-Prompts sind gewachsen, weil jeder Slice dieselben Regeln erneut
ausformuliert:

- Pflichtlektuere,
- M16-T-ID-Abgleich,
- Stop-Regeln,
- erlaubte Dateien,
- Checks,
- Scope-Checks,
- Output-Regeln,
- Commit-Grenzen,
- External-Write-Grenzen,
- Art-/Asset-/Visual-QA-Grenzen.

Das war sicher, aber langsam und fehleranfaellig. Lange Prompts koennen selbst
zum Risiko werden: wichtige Abweichungen gehen unter, Codex liest viel Text
statt der eigentlichen Aufgabe, und wiederholte Regeln driften leicht
auseinander.

## 3. Zielmodell

M16-CD trennt die Steuerung in vier Ebenen:

| Ebene | Rolle |
| --- | --- |
| AGENTS.md | Kurze Codex-Verfassung: Produkt-North-Star, Kernregeln, Plugin-/Skill-Routing und harte Write-Grenzen. |
| 328 | M16-T-/Dashboard-/ID-Backlog: Status, Fortschritt, IDs, Blocker und Folgepfad. |
| 336 | Routing- und Pflichtlektuere-Regel: welche Docs pro Slice-Typ zu lesen sind, welche Standardantworten und Checks gelten. |
| `prompt_templates/` | Wiederverwendbare Arbeitsvertraege fuer haeufige Slice-Arten. |

Kurzregel:

```text
Kurzprompt nennt die Aufgabe.
Template nennt den Arbeitsvertrag.
336 routet die Pflichtdocs.
328 haelt IDs und Fortschritt.
AGENTS.md bleibt die Verfassung.
```

AGENTS.md soll dadurch kurz bleiben. Detailregeln wandern nicht zurueck in
AGENTS.md, sondern in 336 und die Templates.

## 4. Was kuenftig im Kurzprompt bleiben muss

Ein kurzer Codex-Prompt muss mindestens nennen:

- Slice-ID,
- Template-Name,
- Ziel,
- erwartete Dateien oder erlaubte Dateibereiche,
- besondere Grenzen oder Abweichungen,
- ob Commit ausdruecklich erlaubt ist oder nicht.

Wenn ein Slice produktive Daten, externe Tools, App-Integration, Code, Assets,
SRS, `word_progress`, Supabase, Route, Navigation, Persistenz oder BuildState
beruehren koennte, muss der Kurzprompt diese Grenze explizit nennen.

Wenn der Kurzprompt diese Angaben nicht nennt, muss Codex die Luecken aus
AGENTS.md, 328, 336 und Template ableiten. Bei echter Mehrdeutigkeit bleibt
der Slice Analyse/Review und darf keine Implementierung starten.

## 5. Was aus 336/Templates geerbt wird

Kuenftige Kurzprompts muessen nicht jedes Mal voll ausschreiben:

- Pflichtlektuere je Slice-Typ,
- M16-T-ID-Abgleich,
- Standard-Stop-Regeln,
- Standard-Output-Regeln,
- Scope-Check,
- `git status --short`,
- `git diff --check`,
- kein Commit ohne ausdrueckliche Freigabe,
- keine externen Writes ohne ausdrueckliche Freigabe,
- Visual-QA bei erlaubten PNG/SVG,
- Art-/Asset-Grenzen aus 366, 367 und 368,
- 328-Update-Regel, wenn IDs geaendert werden.

Vererbung bedeutet nicht, dass Codex die Regeln ignorieren darf. Codex muss im
Abschluss berichten, welches Template genutzt wurde und welche Regeln aus
336/Template geerbt wurden.

## 6. Minimaler Kurzprompt mit Beispiel

Beispiel fuer M16-CC:

```text
Slice: M16-CC
Template: art_master_reference_slice
Ziel: Asset Family and Export Spec erstellen.
Erwartete Dateien:
- docs/world_design/370-asset-family-and-export-spec.md

Besondere Grenzen:
- keine Assets
- keine Bilder
- kein Code
- kein Commit

Nutze AGENTS.md, 328, 336 und die passende Template-Regel.
Leite Pflichtlektuere, Stop-Regeln, Checks und Abschlussbericht aus
336/Template ab.
```

Dieses Prompt ist kurz, aber nicht blind. Es benennt Slice, Template, Ziel,
Dateien und harte Abweichungen. Der Rest wird aus Repo-Regeln geerbt.

## 7. Template-Uebersicht

| Template | Datei | Zweck |
| --- | --- | --- |
| Docs-only Slice | `docs/world_design/prompt_templates/docs_only_slice.md` | Dokumentations-, Gate-, Planungs- und Boundary-Slices ohne Code/Assets. |
| Review Slice | `docs/world_design/prompt_templates/review_slice.md` | Commitfaehigkeit, Scope, Risiken, erwartete Dateien und Stop-Regeln pruefen. |
| Art / Master Reference Slice | `docs/world_design/prompt_templates/art_master_reference_slice.md` | Art Bible, Master References, Asset-Specs, KI-Art-/Asset-Pipeline-Gates. |
| Visual Documentation Slice | `docs/world_design/prompt_templates/visual_documentation_slice.md` | Repo-native Dokumentationsvisuals, wenn Visuals ausdruecklich erlaubt sind. |
| Implementation Slice | `docs/world_design/prompt_templates/implementation_slice.md` | Isolierte Code-Slices mit ausdruecklicher Implementierungsfreigabe und exaktem Dateiscope. |

Bewusst nicht als eigene Templates angelegt:

- Project-Management-Sync,
- Supabase/Data-Slice,
- App-Integration-Slice,
- Commit-Slice.

Diese bleiben Spezialfaelle ueber 336 und muessen im Kurzprompt besonders
benannt werden, weil ihr Risiko hoeher ist.

## 8. Risiken und Gegenregeln

| Risiko | Gegenregel |
| --- | --- |
| Kurzprompts werden zu vage. | Kurzprompt muss Slice-ID, Template, Ziel, erwartete Dateien, besondere Grenzen und Commit-Status nennen. |
| Codex liest falsche Spezialdocs. | 336 bleibt fuehrendes Routing-Dokument; Template ersetzt 336 nicht. |
| Templates werden selbst zu lang. | Templates bleiben Arbeitsvertraege und verweisen auf 336 statt alle Fachregeln zu kopieren. |
| Stop-Regeln wirken implizit und werden uebersehen. | Abschlussbericht muss geerbte Regeln und Scope-Check nennen. |
| AGENTS.md wird wieder zur Detailablage. | AGENTS.md bleibt kurz; Detailregeln gehen in 336/Templates. |
| Implementierungs-Slices starten ohne Detail-Gate. | Implementation-Template verlangt ausdrueckliche Implementierungsfreigabe, exakte Dateien und relevante Gate-Dokumente. |
| Externe Writes werden versehentlich erlaubt. | Templates erben 362/AGENTS: externe Writes nur mit ausdruecklicher Freigabe. |
| Commit passiert aus Gewohnheit. | Alle Templates sagen: kein Commit ohne separate ausdrueckliche Freigabe. |
| Art-/Asset-Slices erzeugen zu frueh Bilder oder Assets. | Art-/Visual-Templates trennen Reference, Style, Structure, Master, Asset Candidate und erlauben Bilder nur bei expliziter Freigabe. |

## 9. Stop-Regeln

M16-CD gibt nicht frei:

- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- keine Assets,
- keine Dateien unter `assets/`,
- keine Bilder,
- keine Preview-Ordner,
- keine PNG/SVG,
- keine Tests,
- keine Figma-/Notion-/Linear-/GitHub-Writes,
- keine externen Writes,
- keine Stashes anfassen,
- kein Commit ohne separate ausdrueckliche Freigabe.

Templates sind keine Implementierungsfreigabe. Wenn ein Template und ein
Prompt kollidieren, gilt die strengere Stop-Regel. Wenn ein Prompt eine
Freigabe behauptet, aber relevante Gate-Dokumente widersprechen, muss Codex
stoppen und berichten.

## 10. Folgepfad

Empfohlener Folgepfad:

```text
M16-CD Codex Prompt Compression and Slice Template Gate
-> M16-CC Asset Family and Export Spec mit Kurzprompt
-> Review/Commit-Freigabe nach separater Pruefung
```

M16-CC kann danach mit einem Kurzprompt gestartet werden, solange der Prompt
Template, Ziel, erwartete Dateien, besondere Grenzen und Commit-Status nennt.

