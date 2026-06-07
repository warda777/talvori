# M15-A2: Foundation Choice Minimal Slice Implementation Prompt Draft

Stand: 2026-06-06

Status: `Prompt-Draft gestartet / keine Implementierung`

## 1. Ziel

Dieses Dokument bereitet einen spaeteren tatsaechlichen Implementierungs-Prompt
fuer einen minimalen Foundation-Choice-Slice vor. Es fuehrt diesen Prompt nicht
aus.

M15-A2 ist nur Prompt-Draft. Es ist keine Implementierung, keine Codefreigabe,
keine Testfreigabe, keine App-Integration, keine Runtime-Konfiguration, keine
Persistenz und keine Assetfreigabe.

Es entstehen keine Flutter-/Dart-Dateien, keine Tests, keine Widget-Tests,
keine Screenshots, keine neuen PNGs, keine PNG-Aenderungen, keine Spielassets,
keine Asset-Dateien unter `assets/`, keine Runtime-Konfiguration, keine
Persistenz, keine Supabase Writes, keine SRS-/`word_progress`-Aenderung, keine
Reward Bridge, keine automatische Wortplatzierung, kein `frame_started` und
kein Bauzustand.

## 2. Grundlage

Fuehrend fuer diesen Prompt-Draft sind:

- `docs/world_design/309-foundation-choice-implementation-gate.md`,
- `docs/world_design/298-foundation-choice-product-preview-visual-review.md`,
- `docs/world_design/297-foundation-choice-product-preview-plan.md`,
- `docs/world_design/294-foundation-choice-device-preview-plan.md`,
- `docs/world_design/291-early-onboarding-product-wireframe-plan.md`,
- `docs/world_design/282-early-island-onboarding-choice-visual-review.md`,
- `docs/world_design/281-early-island-onboarding-choice-review.md`,
- `docs/world_design/308-visual-backfill-quality-review.md`,
- `docs/world_design/previews/m14_visual_backfill_283_306/09_foundation_choice_product_flow.png`,
- `docs/world_design/previews/m14_visual_backfill_283_306/13_small_implementation_candidate_gate.png`,
- `docs/world_design/previews/m14_visual_backfill_283_306/14_global_stop_rules_map.png`.

Diese Quellen erlauben nur die Vorbereitung eines spaeteren Prompts. Sie
erlauben keine Implementierung.

## 3. Spaeterer Implementierungs-Scope Als Entwurf

Ein spaeterer Implementierungs-Prompt duerfte hoechstens diesen Scope pruefen:

- lokale Preview-/Demo-Darstellung,
- kein echtes Onboarding,
- kein Persistieren,
- keine Runtime-Konfiguration,
- keine App-weite Navigation,
- drei Foundation-Karten:
  - Zuhause / Alltag,
  - Schule / Lernen,
  - Garten / Natur nah,
- kurzer Tali/Vori-Intro-Platzhalter,
- lokale In-Memory-Auswahl,
- sichtbarer Hinweis `spaeter aenderbar`,
- sichtbarer Safe Exit / `spaeter entscheiden`,
- keine finale Startinsel,
- keine automatische Wortplatzierung,
- keine Assets,
- kein Build-State,
- kein `frame_started`.

Der Scope ist nur als spaeterer Entwurf brauchbar, wenn er lokal, reversibel,
nicht persistent und ohne App-weite Nebenwirkungen bleibt.

## 4. Hypothetisch Betroffene Bereiche

Diese Bereiche duerfen in M15-A2 nur hypothetisch genannt werden. Sie werden in
diesem Block nicht geaendert.

Moegliche UI-nahe Flutter-Bereiche:

- Home-/Talvori-Welt-Zentrale-nahe UI-Schichten,
- Onboarding- oder First-Run-nahe UI-Schichten, falls vorhanden,
- isolierte Preview-/Demo-UI fuer den Foundation-Choice-Flow,
- Companion-Bubble-/Text-nahe UI-Schichten fuer einen Tali/Vori-Platzhalter.

Moegliche Preview-/Demo-Bereiche:

- lokaler Demo-Einstieg,
- isolierter Product-Preview-Bereich,
- kein produktiver Onboarding-Pfad,
- keine App-weite Route ohne eigenes Gate.

Moegliche Home-/World-Entry-nahe Bereiche:

- spaeterer Einstiegspunkt nur, wenn der Implementierungs-Prompt ihn explizit
  freigibt,
- keine Home-Zentrale-Aenderung aus M15-A2,
- keine World-State- oder Startinsel-Ableitung.

Moegliche Testbereiche, falls spaeter freigegeben:

- spaetere gezielte Widget-/UI-Tests nur bei ausdruecklicher Testfreigabe,
- keine Tests aus M15-A2,
- keine Test-Harness-Implementierung aus M15-A2.

## 5. Draft: Later Implementation Prompt

Der folgende Prompt ist ein Entwurf fuer einen spaeteren Block. Er ist nicht
freigegeben und darf aus M15-A2 nicht ausgefuehrt werden.

```text
Wir arbeiten im Repository `talvori`.

Bitte starte einen minimalen Foundation-Choice-Implementierungs-Slice.

Wichtig:
- Dieser Prompt ist nur gueltig, wenn Andreas ihn ausdruecklich als
  Implementierungsblock freigibt.
- Vor dem Start `git status --short` ausgeben.
- Vor Dateiaenderungen die konkret betroffenen Dateien/Module auflisten und
  kurz begruenden.
- Keine unklaren Dateien aendern.
- Nur den minimalen Scope umsetzen.
- Noch nicht committen.

Minimal erlaubter Scope:
- lokale Preview-/Demo-Darstellung,
- kein echtes Onboarding,
- kein Persistieren,
- keine Runtime-Konfiguration,
- keine App-weite Navigation,
- drei Foundation-Karten:
  - Zuhause / Alltag,
  - Schule / Lernen,
  - Garten / Natur nah,
- kurzer Tali/Vori-Intro-Platzhalter,
- lokale In-Memory-Auswahl,
- sichtbarer Hinweis "spaeter aenderbar",
- sichtbarer Safe Exit / "spaeter entscheiden",
- keine finale Startinsel,
- keine automatische Wortplatzierung,
- keine Assets,
- kein Build-State,
- kein `frame_started`.

Explizit blockiert:
- keine Asset-Aenderungen,
- keine Asset-Dateien unter `assets/`,
- keine Persistenz,
- keine Supabase Writes,
- keine lokalen Datenbankwrites,
- keine SRS-/`word_progress`-Aenderung,
- keine Reward Bridge,
- keine automatische Wortplatzierung,
- keine Runtime-Konfiguration,
- keine finale UI,
- keine App-weite Navigation,
- kein echtes Onboarding,
- keine ThemeIsland-Erzeugung,
- kein Bauzustand,
- kein `frame_started`,
- keine Tests, ausser sie werden in diesem spaeteren Prompt ausdruecklich
  freigegeben.

Arbeitsweise:
1. Fuehrende Dokumente lesen:
   - `docs/world_design/309-foundation-choice-implementation-gate.md`
   - `docs/world_design/298-foundation-choice-product-preview-visual-review.md`
   - `docs/world_design/297-foundation-choice-product-preview-plan.md`
   - `docs/world_design/294-foundation-choice-device-preview-plan.md`
2. Bestehende Code-Struktur lesen, bevor Dateien geaendert werden.
3. Die minimal moeglichen Dateien/Module nennen.
4. Nur nach Scope-Bestaetigung innerhalb dieses Prompts implementieren.
5. Keine Produktionsdaten, keine Persistenz und keine Runtime-Konfiguration
   anfassen.
6. Nach Aenderungen ausgeben:
   - `git status --short`
   - `git diff --check`
   - ggf. gezielte Analyseausgabe, falls ein bestehender Analyzer sinnvoll ist
     und keine neuen Tests erzeugt.
7. Nicht committen.

Abschlussausgabe:
- geaenderte Dateien,
- kurzer Scope-Nachweis,
- bestaetigen, dass keine Persistenz, keine Runtime-Konfiguration, keine
  Assets, keine automatische Wortplatzierung und kein `frame_started`
  entstanden sind,
- Ergebnis von `git diff --check`,
- Ergebnis von `git status --short`.
```

## 6. Review-Checkliste Fuer Den Spaeteren Prompt

Vor jedem spaeteren Implementierungsstart muss geprueft werden:

- [ ] Scope minimal?
- [ ] Nur lokal/in-memory?
- [ ] Keine Persistenz?
- [ ] Keine Runtime-Konfiguration?
- [ ] Keine Assets?
- [ ] Keine automatische Wortplatzierung?
- [ ] Keine finale UI?
- [ ] Keine App-weite Navigation?
- [ ] Safe Exit sichtbar?
- [ ] `spaeter aenderbar` sichtbar?
- [ ] Tali/Vori blockiert keine Interaktion?
- [ ] Small Phone beruecksichtigt?
- [ ] Ruecknahme einfach?
- [ ] Tests nur nach spaeterer Freigabe?

Wenn eine Antwort unsicher ist, darf kein Implementierungs-Prompt gestartet
werden.

## 7. Prompt-Draft-Risiken

| Risiko | Warum relevant | Schutzregel |
| --- | --- | --- |
| Draft wird als Freigabe gelesen | Der Abschnitt ist kopierbar formuliert | Immer als nicht freigegeben markieren |
| Minimal-Slice waechst in Onboarding | Foundation Choice liegt nahe an First Run | Kein echtes Onboarding, keine Persistenz |
| In-Memory-State wird gespeichert | Auswahl wirkt produktrelevant | Keine Datenbank, kein Supabase, keine Runtime Config |
| UI wirkt final | Karten koennen wie App-Screen wirken | Preview/Demo-Sprache, keine finale UI |
| Tests werden automatisch erzeugt | Implementierungsprompts fragen oft nach Tests | Tests nur bei spaeterer ausdruecklicher Freigabe |
| Assets werden gesucht oder erstellt | Foundation-Karten koennen Icons nahelegen | Keine Assets, keine Asset-Dateien unter `assets/` |
| `frame_started` wird abgeleitet | Foundation kann faelschlich Bauzustand triggern | Kein Build-State, kein `frame_started` |

## 8. Stop-Regeln

Aus M15-A2 folgt ausdruecklich:

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
