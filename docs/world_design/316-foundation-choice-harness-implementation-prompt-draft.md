# M15-D2: Foundation Choice Harness Implementation Prompt Draft

Stand: 2026-06-07

Status: `Prompt-Draft gestartet / keine Harness-Implementierung`

## 1. Ziel

Dieses Dokument bereitet den spaeteren tatsaechlichen Implementierungs-Prompt
fuer einen minimalen isolierten Foundation-Choice-Preview-Harness vor. Der
Prompt wird nur dokumentiert und nicht ausgefuehrt.

M15-D2 ist ein reiner Prompt-Draft. Es ist keine Implementierung, keine
Codefreigabe, keine Testfreigabe, keine Screenshot-Freigabe, keine
App-Integration, keine Home-/Onboarding-/World-Routing-Integration, keine
Runtime-Konfiguration, keine Persistenz, keine Assetfreigabe und keine
Implementierungsfreigabe.

## 2. Gepruefte Grundlage

Fuehrend fuer M15-D2 sind:

- `lib/features/world/local_world/ui/widgets/foundation_choice_preview.dart`,
- `docs/world_design/315-foundation-choice-local-preview-harness-implementation-gate.md`,
- `docs/world_design/314-foundation-choice-local-preview-harness-gate.md`,
- `docs/world_design/313-foundation-choice-preview-code-review.md`,
- `docs/world_design/312-foundation-choice-final-pre-implementation-checklist.md`,
- `docs/world_design/previews/m15_d_foundation_choice_harness_implementation_gate/00_contact_sheet.png`,
- `docs/world_design/previews/m15_d_foundation_choice_harness_implementation_gate/01_harness_implementation_gate_map.png`,
- `docs/world_design/previews/m15_d_foundation_choice_harness_implementation_gate/02_allowed_vs_blocked_harness_scope.png`.

M15-D bestaetigt: Ein spaeterer isolierter Local Preview Harness ist
theoretisch freigabefaehig, aber nur mit separatem Implementierungs-Prompt und
ausdruecklicher Nutzerfreigabe.

## 3. Spaeterer Harness-Scope Als Entwurf

Ein spaeterer Harness-Slice duerfte hoechstens enthalten:

- eine isolierte lokale Preview-/Demo-Flaeche,
- `FoundationChoicePreview` isoliert anzeigen,
- keine App-Route,
- keine Home-Integration,
- keine Onboarding-Integration,
- keine World-Routing-Integration,
- keine produktive Navigation,
- keine Persistenz,
- keine Runtime-Konfiguration,
- keine Assets,
- keine Screenshots,
- keine Tests,
- keine Widget-Tests,
- keine automatische Wortplatzierung,
- kein Build-State,
- kein `frame_started`.

Dieser Scope ist nur ein Entwurf fuer einen spaeteren Prompt. Er gibt aktuell
keinen Code frei.

## 4. Draft: Later Harness Implementation Prompt

> Status: Nicht freigegeben. Nur spaeter verwenden, wenn Andreas diesen
> Prompt oder eine aktualisierte Fassung ausdruecklich freigibt.

```text
Wir arbeiten im Repository `talvori`.

Ich gebe jetzt den minimalen isolierten Foundation-Choice-Preview-Harness
ausdruecklich frei.

Fuehrend sind:
- `docs/world_design/316-foundation-choice-harness-implementation-prompt-draft.md`
- `docs/world_design/315-foundation-choice-local-preview-harness-implementation-gate.md`
- `docs/world_design/314-foundation-choice-local-preview-harness-gate.md`
- `docs/world_design/313-foundation-choice-preview-code-review.md`
- `lib/features/world/local_world/ui/widgets/foundation_choice_preview.dart`

Wichtig:
- Vor dem Start `git status --short` ausgeben.
- Bestehende Struktur lesen, bevor Dateien geaendert werden.
- Betroffene Dateien vor jeder Aenderung konkret nennen und kurz begruenden.
- Keine unklaren Dateien aendern.
- Nur einen minimalen isolierten Preview-Harness umsetzen.
- Keine App-Route erzeugen.
- Keine Home-/Onboarding-/World-Integration erzeugen.
- Keine produktive Navigation erzeugen.
- Keine Persistenz erzeugen.
- Keine Supabase Writes.
- Keine lokalen DB-Writes.
- Keine Runtime-Konfiguration.
- Keine Assets und keine Asset-Dateien unter `assets/`.
- Keine Screenshots erzeugen.
- Keine Tests erzeugen, ausser sie werden in diesem Prompt spaeter
  ausdruecklich ergaenzt und freigegeben.
- Keine Widget-Tests erzeugen.
- Keine automatische Wortplatzierung.
- Kein Build-State.
- Kein `frame_started`.
- Keine Bauzustaende.

Minimal erlaubter Scope:
- Eine lokale, isolierte Preview-/Demo-Flaeche fuer `FoundationChoicePreview`.
- `FoundationChoicePreview` ohne Navigation anzeigen.
- Small Phone Portrait als sichtbaren Leitfall beruecksichtigen.
- Keine App-weite Einbindung.
- Keine Persistenz, keine Config, keine Assets, keine Tests, keine Screenshots.

Nach der Aenderung:
- `dart format` fuer alle geaenderten Dart-Dateien ausfuehren.
- `dart analyze` fuer die geaenderten Dart-Dateien ausfuehren.
- `git diff --check` ausfuehren.
- `git status --short` ausfuehren.
- Bestaetigen, dass keine App-Integration, keine Persistenz, keine Runtime-
  Konfiguration, keine Assets, keine Screenshots, keine Tests, keine
  automatische Wortplatzierung und kein `frame_started` entstanden sind.
- Noch nicht committen.
```

## 5. Hypothetisch Betroffene Datei-/Modulbereiche

Diese Bereiche werden nur hypothetisch genannt und in M15-D2 nicht geaendert:

- moegliche lokale Preview-/Demo-Datei,
- moegliche Debug-/Dev-only-Flaeche,
- moegliche Widget-Datei, falls `FoundationChoicePreview` nur importiert und
  gerendert wird,
- moegliche spaetere Testbereiche, falls Tests spaeter ausdruecklich
  freigegeben werden,
- moegliche Dokumentations-Harness-Bereiche.

Keine konkrete Datei wird aus M15-D2 fuer eine Harness-Implementierung
geaendert.

## 6. Copy-Entscheidung

Die bestehende Copy `Lernfokus lokal merken` darf im isolierten Preview-Code
bleiben.

Entscheidung fuer M15-D2:

- Fuer einen spaeteren Harness-Slice ist eine Copy-Aenderung nicht zwingend.
- Der Harness-Prompt soll keine Copy-Aenderung erzwingen, ausser Andreas
  fordert sie ausdruecklich.
- Vor jeder Integration soll erneut geprueft werden, ob `Lernfokus lokal
  anzeigen` besser ist, weil diese Formulierung weniger nach Persistenz klingt.
- M15-D2 aendert keine Copy und keinen Flutter-/Dart-Code.

## 7. Review-Checkliste Fuer Den Spaeteren Harness-Prompt

| Check | Erwartung | Status in M15-D2 |
| --- | --- | --- |
| Scope isoliert? | nur lokale Preview-/Demo-Flaeche | als Draft beschrieben |
| Nur lokale Preview/Demo? | kein Nutzerfeature | als Stop-Regel enthalten |
| Keine App-Route? | keine neue Route | hart blockiert |
| Keine Home-/Onboarding-/World-Integration? | keine produktive Einbindung | hart blockiert |
| Keine Persistenz? | keine DB, kein Supabase, kein lokaler Write | hart blockiert |
| Keine Runtime-Konfiguration? | keine Flags, keine Config | hart blockiert |
| Keine Assets? | nichts unter `assets/` | hart blockiert |
| Keine Screenshots? | nur spaeter mit eigener Freigabe | hart blockiert |
| Keine Tests? | nur spaeter mit eigener Freigabe | hart blockiert |
| Keine automatische Wortplatzierung? | keine Word-to-Island-Aktion | hart blockiert |
| Kein `frame_started`? | kein Build-State | hart blockiert |
| Small Phone Portrait sichtbar? | erster Leitfall fuer Harness | spaeter erlaubt |
| Safe Exit sichtbar? | `Spaeter entscheiden` pruefbar | spaeter erlaubt |
| `spaeter aenderbar` sichtbar? | Reversibilitaet pruefbar | spaeter erlaubt |
| Tali/Vori verdeckt nichts? | Collision-Check im Harness | spaeter erlaubt |
| `dart analyze` sauber? | nur bei spaeterer Umsetzung | im Draft gefordert |
| Nicht committen? | kein automatischer Commit | im Draft gefordert |

## 8. Dokumentationsvisualisierungen

M15-D2 ergaenzt echte PNG-Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m15_d2_foundation_choice_harness_prompt_draft/`

Geplante Visuals:

- `01_harness_prompt_scope_boundary.png`,
- `02_harness_prompt_execution_flow.png`,
- optional `00_contact_sheet.png`.

Diese PNGs sind Dokumentationspreviews. Sie sind keine App-Screens, keine
Screenshots, keine finalen UI-PNGs, keine Spielassets und keine Asset-Dateien
unter `assets/`.

## 9. Stop-Regeln

Aus M15-D2 folgt ausdruecklich:

- Keine Harness-Implementierung.
- Keine Flutter-/Dart-Dateien.
- Keine App-Integration.
- Keine Home-/Onboarding-/World-Routing-Integration.
- Keine Tests.
- Keine Widget-Tests.
- Keine Screenshots.
- Keine Persistenz.
- Keine Runtime-Konfiguration.
- Keine Supabase Writes.
- Keine lokalen DB-Writes.
- Keine SRS-/`word_progress`-Aenderung.
- Keine Reward Bridge.
- Keine automatische Wortplatzierung.
- Keine Assetfreigabe.
- Keine Assets und keine Asset-Dateien unter `assets/`.
- Kein Build-State.
- Kein `frame_started`.
- Kein Bauzustand.

## 10. Ergebnis

M15-D2 enthaelt einen spaeter nutzbaren, aber aktuell nicht freigegebenen
Harness-Implementierungs-Prompt als Draft. Der Draft ist eng genug, um einen
spaeteren isolierten Preview-Harness zu beschreiben, solange Andreas ihn in
einem separaten Prompt ausdruecklich freigibt.

Bis dahin bleibt alles blockiert: keine Harness-Implementierung, keine Tests,
keine Screenshots, keine App-Integration, keine Runtime-Konfiguration, keine
Persistenz, keine Assets, keine automatische Wortplatzierung und kein
`frame_started`.
