# M15-A3: Foundation Choice Prompt Visual Review

Stand: 2026-06-06

Status: `Visual Review gestartet / keine Implementierung`

## 1. Ziel

Dieses Dokument prueft den Prompt-Draft aus M15-A2 visuell und inhaltlich. Es
bewertet, ob der spaetere Implementierungs-Prompt eng genug, verstaendlich
genug und sicher genug formuliert ist.

M15-A3 ist nur Dokumentations- und Visualisierungsreview. Es ist keine
Implementierung, keine Codefreigabe, keine Testfreigabe, keine
App-Integration, keine Runtime-Konfiguration, keine Persistenz und keine
Assetfreigabe.

## 2. Gepruefte Grundlage

Geprueft wurden:

- `docs/world_design/310-foundation-choice-minimal-slice-prompt-draft.md`,
- `docs/world_design/309-foundation-choice-implementation-gate.md`,
- `docs/world_design/308-visual-backfill-quality-review.md`,
- `docs/world_design/307-visual-backfill-283-306.md`,
- `docs/world_design/previews/m14_visual_backfill_283_306/09_foundation_choice_product_flow.png`,
- `docs/world_design/previews/m14_visual_backfill_283_306/13_small_implementation_candidate_gate.png`,
- `docs/world_design/previews/m14_visual_backfill_283_306/14_global_stop_rules_map.png`.

M15-A2 markiert den spaeteren Copy-&-Paste-Prompt als nicht freigegeben. Der
Draft begrenzt einen moeglichen spaeteren Slice auf lokale Preview-/Demo-
Darstellung, drei Foundation-Karten, Tali/Vori-Platzhalter, lokale
In-Memory-Auswahl, Safe Exit und `spaeter aenderbar`.

## 3. Neue Dokumentationsvisualisierungen

Die M15-A3-PNGs liegen unter:

`docs/world_design/previews/m15_a3_foundation_choice_prompt_visual_review/`

| PNG | Zweck | Review-Ergebnis |
| --- | --- | --- |
| `00_contact_sheet.png` | Schneller Ueberblick ueber alle vier Review-Visuals | brauchbar als Uebersicht |
| `01_prompt_scope_boundary.png` | Trennt erlaubten spaeteren Minimal-Scope von hart blockiertem Scope | macht `no code now` klar sichtbar |
| `02_later_implementation_prompt_gate_flow.png` | Zeigt den notwendigen Weg von Draft zu spaeterer separater Freigabe | zeigt klar, dass M15-A2/M15-A3 nichts ausfuehren |
| `03_foundation_choice_minimal_slice_risk_map.png` | Ordnet Scope-Creep-Risiken je Guardrail | brauchbar, nicht ueberladen |
| `04_stop_rules_summary.png` | Fasst zentrale Stop-Regeln gross und lesbar zusammen | stark genug fuer Review-Kontext |

Diese PNGs sind Dokumentationspreviews. Sie sind keine App-Screens, keine
finalen UI-PNGs, keine Spielassets und keine Implementierungsfreigabe.

## 4. Visuelle Qualitaetsbewertung

Die Visuals verwenden grosse Karten, helle Hintergrundflaechen, klare Titel,
kurze Untertitel und einen Footer mit dem Hinweis `documentation preview only /
no code / no assets / no implementation`.

Sichtpruefung:

- Titel, Untertitel und Footer sind sichtbar.
- Texte bleiben innerhalb von Karten, Rahmen und Panels.
- Die Flow-Grafik laesst Titel in Karten umbrechen und vermeidet
  Textueberlauf.
- Die Risiko- und Stop-Regel-Karten sind nicht ueberladen.
- Das Contact Sheet ist fuer schnellen Ueberblick brauchbar, auch wenn die
  Einzeltexte dort naturgemaess nur grob lesbar sind.
- Keine Grafik suggeriert finale UI, App-Integration, Assetfreigabe,
  Implementierungsfreigabe oder `frame_started`.

## 5. Inhaltliche Prompt-Draft-Pruefung

Review-Fragen:

| Frage | Ergebnis |
| --- | --- |
| Ist der spaetere Implementierungs-Prompt klar als nicht freigegeben markiert? | ja |
| Ist klar, dass M15-A2 keine Umsetzung ausfuehrt? | ja |
| Ist klar, dass M15-A3 keine Umsetzung ausfuehrt? | ja, durch Review-Text und PNGs |
| Ist der spaetere Scope klein genug? | ja, wenn er lokal und demoartig bleibt |
| Ist `local preview/demo only` klar? | ja |
| Sind Persistenz, Runtime-Konfiguration und App-weite Navigation hart genug blockiert? | ja |
| Sind Assets und `frame_started` hart genug blockiert? | ja |
| Sind Tests nur bei spaeterer ausdruecklicher Freigabe erlaubt? | ja |
| Ist der spaetere Prompt fuer Codex eng genug, um nicht aus dem Scope zu laufen? | grundsaetzlich ja |
| Fehlen Stop-Regeln? | keine harten Luecken sichtbar |
| Muss der spaetere Prompt vor echter Umsetzung geschaerft werden? | nur kleine Praezisierung empfohlen |

Kleine Praezisierung fuer einen spaeteren echten Implementierungsblock:

- Vor Code sollte der spaetere Prompt den konkreten Preview-/Demo-Einstieg
  benennen oder explizit festlegen, dass Codex ihn vor Aenderungen vorschlaegt
  und erst im selben Prompt bestaetigt.
- Tests sollten weiterhin nur nach ausdruecklicher Testfreigabe entstehen.
- Der spaetere Prompt muss die betroffenen Dateien vor Aenderungen nennen und
  darf unklare Dateien nicht aendern.

Diese Hinweise sind keine Blocker fuer den Prompt-Draft.

## 6. Review-Matrix

| Area | Review Result | Risk | Needed Adjustment | Decision |
| --- | --- | --- | --- | --- |
| Draft status | pass | Draft wird als Freigabe gelesen | Keine; Markierung ist klar | accepted |
| Minimal scope | minor note | Scope waechst in echtes Onboarding | Spaeteren Einstiegspunkt vor Code klaeren | accepted-with-minor-note |
| File-change discipline | pass | Unklare Dateien werden geaendert | Betroffene Dateien vor Aenderung listen | accepted |
| Local in-memory only | pass | Auswahl wird gespeichert | Keine Persistenz wiederholen | accepted |
| No persistence | pass | Supabase/SQLite/word_progress Drift | Hart blockiert lassen | accepted |
| No runtime config | pass | Config/Flag wird eingefuehrt | Hart blockiert lassen | accepted |
| No app-wide navigation | minor note | Route wird zu produktivem Onboarding | Spaeteren Einstiegspunkt gesondert gaten | accepted-with-minor-note |
| No tests unless approved | pass | Tests entstehen automatisch | Testfreigabe spaeter explizit verlangen | accepted |
| No assets | pass | Karten erzeugen Icons/Assets | Keine Asset-Dateien unter `assets/` | accepted |
| No automatic word placement | pass | Lernfokus wird Wortplatzierung | Stop-Regel wiederholen | accepted |
| No `frame_started` | pass | Foundation wird Bauzustand | Stop-Regel wiederholen | accepted |
| No commit until checked | pass | Implementierung wird sofort committed | Spaeter weiter `noch nicht committen` setzen | accepted |

## 7. Entscheidung

Optionen:

1. Prompt-Draft akzeptiert.
2. Prompt-Draft mit kleinen Nachbesserungen akzeptiert.
3. Prompt-Draft braucht Nachbesserung.
4. Prompt-Draft blockieren, weil zu implementierungsnah.

Empfehlung: Option 2.

M15-A2 ist als Prompt-Draft brauchbar. Die kleinen Nachbesserungen betreffen
keine Aenderung an App oder Code, sondern nur spaetere Ausfuehrungsdisziplin:
vor einem echten Implementierungsblock muessen Einstiegspunkt, betroffene
Dateien und Testfreigabe erneut explizit eingegrenzt werden.

Daraus folgt keine Implementierungsfreigabe. Wenn spaeter Code gewuenscht wird,
muss Andreas den separaten Implementierungs-Prompt ausdruecklich freigeben.

## 8. Stop-Regeln

Aus M15-A3 folgt ausdruecklich:

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
- Keine Screenshots.
- Keine Spielassets.
- Keine Asset-Dateien unter `assets/`.
- Keine automatische Wortplatzierung.
- Kein `frame_started`.
- Kein Bauzustand.

## 9. Ergebnis

M15-A3 bestaetigt den M15-A2-Prompt-Draft als brauchbare, aber weiterhin nicht
freigegebene Grundlage fuer einen moeglichen spaeteren Implementierungs-Prompt.
Die neuen PNGs machen die Scope-Grenzen, den Freigabeweg, die Risiken und die
Stop-Regeln besser sichtbar.

Der naechste Schritt darf nicht automatisch Code sein. Ein spaeterer
Implementierungsblock braucht weiterhin ausdrueckliche Nutzerfreigabe,
minimalen Scope und erneute Pruefung vor jeder Dateianderung.
