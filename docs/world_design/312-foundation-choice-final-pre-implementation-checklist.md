# M15-A4: Foundation Choice Final Pre-Implementation Checklist

Stand: 2026-06-06

Status: `Final Pre-Implementation Checklist gestartet / keine Implementierung`

## 1. Ziel

Dieses Dokument haelt als letzte Pre-Implementation-Checkliste fest, ob der
spaetere Foundation-Choice-Minimal-Slice wirklich eng genug ist, bevor Andreas
einen separaten Implementierungs-Prompt ausdruecklich freigibt.

M15-A4 ist keine Implementierung, keine Codefreigabe, keine Testfreigabe,
keine App-Integration, keine Runtime-Konfiguration, keine Persistenz und keine
Assetfreigabe.

## 2. Gepruefte Grundlage

Fuehrend fuer diese Checkliste sind:

- `docs/world_design/311-foundation-choice-prompt-visual-review.md`,
- `docs/world_design/310-foundation-choice-minimal-slice-prompt-draft.md`,
- `docs/world_design/309-foundation-choice-implementation-gate.md`,
- `docs/world_design/previews/m15_a3_foundation_choice_prompt_visual_review/01_prompt_scope_boundary.png`,
- `docs/world_design/previews/m15_a3_foundation_choice_prompt_visual_review/02_later_implementation_prompt_gate_flow.png`,
- `docs/world_design/previews/m15_a3_foundation_choice_prompt_visual_review/03_foundation_choice_minimal_slice_risk_map.png`,
- `docs/world_design/previews/m15_a3_foundation_choice_prompt_visual_review/04_stop_rules_summary.png`.

Diese Quellen bestaetigen nur, dass ein spaeterer Minimal-Slice theoretisch
denkbar waere. Sie geben weiterhin keine Implementierung frei.

## 3. Finaler Go/No-Go-Status

Pruefung:

| Frage | Ergebnis |
| --- | --- |
| Ist der spaetere Scope minimal genug? | ja, wenn er lokale Preview/Demo bleibt |
| Ist klar, dass es nur lokale Preview/Demo ist? | ja |
| Ist klar, dass es kein echtes Onboarding ist? | ja |
| Ist klar, dass keine Persistenz entsteht? | ja |
| Ist klar, dass keine Runtime-Konfiguration entsteht? | ja |
| Ist klar, dass keine App-weite Navigation entsteht? | ja |
| Ist klar, dass keine Assets entstehen? | ja |
| Ist klar, dass keine automatische Wortplatzierung entsteht? | ja |
| Ist klar, dass kein `frame_started` entsteht? | ja |
| Ist klar, dass Tests nur nach ausdruecklicher Testfreigabe entstehen? | ja |
| Ist klar, dass Codex vor Code die betroffenen Dateien nennen muss? | ja |
| Ist klar, dass nach Umsetzung nicht automatisch committed wird? | ja |

Go/No-Go-Ergebnis:

`ready-for-explicit-user-approval`

Das bedeutet: Der spaetere Slice ist nur bereit, falls Andreas ihn in einem
separaten Implementierungs-Prompt ausdruecklich freigibt. M15-A4 selbst gibt
keinen Code frei.

## 4. Go/No-Go-Tabelle

Statuswerte:

- `ready-for-explicit-user-approval`: bereit fuer spaetere ausdrueckliche
  Nutzerfreigabe, aber nicht aus diesem Dokument heraus.
- `needs-clarification`: vor spaeterer Freigabe muss eine Frage geklaert
  werden.
- `blocked`: darf auch spaeter nicht Teil dieses Minimal-Slices werden.

| Check | Status | Evidence | Risk if missed | Decision |
| --- | --- | --- | --- | --- |
| Scope | `ready-for-explicit-user-approval` | M15-A2/M15-A3 begrenzen auf lokale Preview/Demo | Scope waechst in echtes Onboarding | Nur minimaler lokaler Preview-Slice spaeter denkbar |
| Entry point | `needs-clarification` | M15-A3 empfiehlt spaetere Einstiegspunkt-Klaerung | App-weite Navigation entsteht unbemerkt | Vor Code konkreten Preview-/Demo-Einstieg nennen |
| UI finality | `ready-for-explicit-user-approval` | M15-A2/M15-A3 blockieren finale UI | Preview wirkt wie finales Onboarding | Nur nicht-finaler Demo-/Preview-Look |
| Local in-memory state | `ready-for-explicit-user-approval` | M15-A2 fordert lokale In-Memory-Auswahl | Auswahl wird gespeichert | Keine Persistenz, kein Save |
| Persistence | `blocked` | M15-A2/M15-A3 blockieren Supabase, SQLite und `word_progress` | Daten- oder Lernlogik wird veraendert | Nicht Teil des Minimal-Slices |
| Runtime config | `blocked` | M15-A2/M15-A3 blockieren Runtime-Konfiguration | Feature-Flag oder Konfiguration wird produktiv | Nicht Teil des Minimal-Slices |
| App navigation | `needs-clarification` | Keine App-weite Navigation erlaubt | Flow wird echter App-Pfad | Separates Gate oder klar isolierter Demo-Einstieg |
| Assets | `blocked` | M15-A2/M15-A3 blockieren Assets und `assets/`-Dateien | Karten erzeugen Icons oder Spielassets | Nicht Teil des Minimal-Slices |
| Tests | `needs-clarification` | Tests nur bei spaeterer ausdruecklicher Freigabe | Tests entstehen ungefragt | Testentscheidung im spaeteren Prompt explizit machen |
| Word placement | `blocked` | Keine automatische Wortplatzierung erlaubt | Lernfokus erzeugt Weltplatzierung | Nicht Teil des Minimal-Slices |
| `frame_started` | `blocked` | Kein Build-State und kein `frame_started` erlaubt | Foundation Choice wird Bauzustand | Nicht Teil des Minimal-Slices |
| Commit discipline | `ready-for-explicit-user-approval` | M15-A2 fordert `noch nicht committen` und Checks | Code wird ohne Review committed | Spaeter weiter kein Commit ohne Nutzerauftrag |

## 5. Spaetere Freigabeformulierung

Diese Formulierung ist nur Dokumentation. Sie darf aus M15-A4 nicht ausgefuehrt
werden.

```text
Ich gebe den minimalen Foundation-Choice-Implementierungs-Slice jetzt
ausdruecklich frei. Nutze den Prompt aus 310, beachte die Reviews 311 und 312,
aendere nur den minimal noetigen lokalen Preview-Scope, nenne vor Code die
konkret betroffenen Dateien, erzeuge keine Assets, keine Persistenz, keine
Runtime-Konfiguration, keine automatische Wortplatzierung und kein
`frame_started`, und committe noch nicht.
```

Ohne eine vergleichbar ausdrueckliche spaetere Nutzerfreigabe darf kein Code
entstehen.

## 6. Finale Pre-Implementation-Checkliste

Vor einem spaeteren Implementierungs-Prompt muessen alle Punkte erneut mit Ja
beantwortet werden:

- [ ] Der Prompt ist ausdruecklich als Implementierungsblock freigegeben.
- [ ] Der Scope ist lokal, klein und demoartig.
- [ ] Der Einstiegspunkt ist isoliert oder vor Code geklaert.
- [ ] Es entsteht kein echtes Onboarding.
- [ ] Es entsteht keine finale UI.
- [ ] Es entsteht keine Persistenz.
- [ ] Es entstehen keine Supabase Writes.
- [ ] Es entsteht keine SRS-/`word_progress`-Aenderung.
- [ ] Es entsteht keine Reward Bridge.
- [ ] Es entsteht keine Runtime-Konfiguration.
- [ ] Es entsteht keine App-weite Navigation.
- [ ] Es entstehen keine Assets und keine Asset-Dateien unter `assets/`.
- [ ] Es entsteht keine automatische Wortplatzierung.
- [ ] Es entsteht kein `frame_started` und kein Bauzustand.
- [ ] Tests sind nur erlaubt, wenn der spaetere Prompt sie ausdruecklich
  freigibt.
- [ ] Codex nennt vor Code die betroffenen Dateien.
- [ ] Nach Umsetzung wird nicht automatisch committed.

Wenn ein Punkt unsicher ist, darf kein Implementierungsblock starten.

## 7. Stop-Regeln

Aus M15-A4 folgt ausdruecklich:

- Keine Implementierung.
- Keine Flutter-/Dart-Dateien.
- Keine Tests.
- Keine Widget-Tests.
- Keine App-Integration.
- Keine finale UI.
- Keine Runtime-Konfiguration.
- Keine Persistenz.
- Keine Supabase Writes.
- Keine SRS-/`word_progress`-Aenderung.
- Keine Reward Bridge.
- Keine Codefreigabe.
- Keine Implementierungsfreigabe.
- Keine Assetfreigabe.
- Keine PNG-Erzeugung.
- Keine PNG-Aenderung.
- Keine Screenshots.
- Keine Spielassets.
- Keine Asset-Dateien unter `assets/`.
- Keine automatische Wortplatzierung.
- Kein `frame_started`.
- Kein Bauzustand.

## 8. Ergebnis

M15-A4 kommt zu folgendem Ergebnis:

- Der spaetere Foundation-Choice-Minimal-Slice ist eng genug beschrieben, um
  bei ausdruecklicher Nutzerfreigabe als separater Implementierungs-Prompt
  gestartet werden zu koennen.
- Vor Code bleiben der konkrete isolierte Einstiegspunkt und die Testfrage
  ausdruecklich zu bestaetigen.
- M15-A4 gibt keine Implementierung frei.
- Ein spaeterer Implementierungsblock muss den Prompt aus `310`, die Reviews
  `311` und diese Checkliste `312` beachten.
