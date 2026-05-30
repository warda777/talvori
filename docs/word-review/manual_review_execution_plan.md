# Manueller Vokabelreview: Ausführungsplan

Stand: 2026-05-30

Dieser Plan wertet den lokal erzeugten Master-Review-Seed und die kleinen Kandidatenlisten aus. Es wurden keine Supabase-Daten, keine SQLite-/App-Vokabeldaten, keine Imports, keine SRS-Daten und kein `word_progress` verändert.

## 1. Ziel

Der manuelle Review soll den englisch-deutschen Basisbestand schrittweise releasefähig machen, ohne automatische Korrekturen oder Freigaben vorzunehmen.

Als Erstes werden kleine, risikoarme und fachlich blockierende Kandidatengruppen geprüft:

1. Sicherheits- und Formatstatus bestätigen.
2. Exakte Dubletten und Case-Varianten prüfen.
3. Bedeutungsvarianten markieren.
4. Fehlende Level, Kategorien und Wortwelten ergänzungsfähig vorbereiten.

Diese Reihenfolge ist bewusst gewählt: Dubletten und Bedeutungsvarianten beeinflussen spätere `meaning_id`, `meaning_note`, Kategoriezuordnung und Content-Paket-Exports. Wenn diese Basis falsch ist, müssten Spanisch/Französisch und spätere Sprachpakete denselben Fehler erneut auflösen.

Bewusst nicht automatisch korrigiert werden:

- Schreibweisen und Groß-/Kleinschreibung
- Dubletten-Merges
- Kategorie-/Level-Zuordnungen
- Bedeutungsvarianten
- `approved` oder `release_ready`
- Spanisch-/Französisch-Übersetzungen

## 2. Priorisierte Arbeitsreihenfolge

1. **Sicherheits-/Formatcheck bestätigen**
   - Release-Risiko: hoch, aber schnell erledigt.
   - Prüfen, ob alle Zeilen weiterhin `needs_review` und `release_ready = false` sind.

2. **Leere Übersetzungen prüfen**
   - Aktuell 0 Kandidaten.
   - Trotzdem als erster Gatekeeper im Prozess behalten.

3. **Gleiches `base_term`/`de_translation` prüfen**
   - 992 Fälle.
   - Nicht alle sind falsch; Eigennamen, Abkürzungen und Internationalismen können korrekt sein.
   - Erst nach den kleineren Konfliktlisten bearbeiten.

4. **Exakte Dubletten prüfen**
   - 32 Kandidaten.
   - Kleine, gut abgrenzbare Liste.

5. **Case-Varianten prüfen**
   - 30 Kandidaten.
   - Häufig mit Dubletten verbunden, daher direkt danach.

6. **Bedeutungsvarianten prüfen**
   - 16 Kandidaten.
   - Blockiert späteres Mehrbedeutungsmodell und Übersetzungen in weitere Sprachen.

7. **Fehlende Level/Kategorien/Wortwelten prüfen**
   - 25 fehlende Level und 16 fehlende Kategorien/Wortwelten.
   - Für erste Etappe als 25 Zeilen in `manual_review_first_batch.csv` enthalten.

8. **A1-C2 und Top 500 als Strukturproblem bewerten**
   - 5.539 A1-C2-Strukturverdachte.
   - 500 Top-500-Strukturverdachte.
   - Nicht in der ersten Etappe vollständig bearbeiten; zuerst eine Datenmodell-/Mapping-Regel festlegen.

9. **Normale Wort-für-Wort-Prüfung starten**
   - Erst nach den Konflikt- und Strukturgrundlagen.

10. **Spanisch/Französisch ergänzen**
   - Erst nach stabiler Bedeutungsbasis.
   - Keine ungeprüften KI- oder Rohübersetzungen produktiv übernehmen.

## 3. Konkrete Review-Blöcke

### Block 1: Sicherheits-/Formatcheck

- **Quelle:** `vocabulary_review_seed_quality_report.md`
- **Anzahl:** 13.629 Zeilen geprüft
- **Warum wichtig:** Verhindert, dass ungeprüfte Zeilen versehentlich als releasefähig gelten.
- **Entscheidungen:** bestätigen / blockieren / Seed neu erzeugen
- **Risiko:** hoch
- **Aufwand:** klein
- **Abhängigkeiten:** aktueller Seed, Report
- **Ergebnis:** Sicherheitsgate schriftlich bestätigt; keine Zeile `approved`, keine Zeile `release_ready = true`.

### Block 2: Leere Übersetzungen

- **Quelle:** `seed_empty_translation_candidates.csv`
- **Anzahl:** 0 Kandidaten
- **Warum wichtig:** Leere Übersetzungen wären harte Release-Blocker.
- **Entscheidungen:** ergänzen_later / reject / needs_context
- **Risiko:** hoch, aktuell kein Befund
- **Aufwand:** klein
- **Abhängigkeiten:** keine
- **Ergebnis:** Liste bleibt leer oder wird bei späteren Exporten zuerst abgearbeitet.

### Block 3: Gleiches `base_term` und `de_translation`

- **Quelle:** Qualitätsreport
- **Anzahl:** 992 Kandidaten
- **Warum wichtig:** Kann echte Internationalismen enthalten, aber auch nicht übersetzte oder falsch importierte Begriffe.
- **Entscheidungen:** keep_as_internationalism / translate / add_note / reject / needs_context
- **Risiko:** mittel
- **Aufwand:** groß
- **Abhängigkeiten:** erst nach kleinen Konfliktlisten sinnvoll
- **Ergebnis:** Kandidaten später in eigene Arbeitsliste überführen; nicht Teil der ersten Etappe.

### Block 4: Exakte Dubletten

- **Quelle:** `seed_duplicate_candidates.csv`
- **Anzahl:** 32 Kandidaten
- **Warum wichtig:** Dubletten können spätere Content-Pakete, Suchlisten, Filteransichten und Lernkarten doppelt belasten.
- **Entscheidungen:** keep / merge_later / split_meaning / reject / needs_context
- **Risiko:** mittel
- **Aufwand:** klein
- **Abhängigkeiten:** `exact_duplicate_merge_plan.md`, `case_variant_merge_plan.md`
- **Ergebnis:** Pro Dublettengruppe steht fest, welche ID fachlich kanonisch wirkt und welche Daten erhalten bleiben müssen. Keine Löschung.

### Block 5: Case-Varianten

- **Quelle:** aus Seed berechnete Case-Varianten, enthalten in `manual_review_first_batch.csv`
- **Anzahl:** 30 Kandidaten
- **Warum wichtig:** Groß-/Kleinschreibung betrifft deutsche Nomen, Wochentage, Abkürzungen und technische Begriffe.
- **Entscheidungen:** canonical_case / merge_later / split_meaning / needs_context
- **Risiko:** mittel
- **Aufwand:** klein bis mittel
- **Abhängigkeiten:** `case_variant_merge_plan.md`
- **Ergebnis:** Kanonische Schreibweise und Merge-/Archivierungsbedarf dokumentiert, aber nicht ausgeführt.

### Block 6: Bedeutungsvarianten

- **Quelle:** `seed_meaning_variant_candidates.csv`
- **Anzahl:** 16 Kandidaten
- **Warum wichtig:** Gleicher englischer Begriff mit unterschiedlichen Übersetzungen darf nicht blind zusammengeführt werden.
- **Entscheidungen:** split_meaning / meaning_note / keep_separate / combine_later / needs_context
- **Risiko:** hoch
- **Aufwand:** mittel
- **Abhängigkeiten:** `meaning_variant_model_plan.md`
- **Ergebnis:** Jede echte Bedeutungsvariante bekommt später `meaning_id` und `meaning_note`.

### Block 7: Fehlende Level/Kategorien/Wortwelten

- **Quelle:** `seed_structure_issue_candidates.csv`, `manual_review_first_batch.csv`
- **Anzahl:** 25 Zeilen in der ersten Etappe
- **Warum wichtig:** Fehlende Struktur verhindert saubere Wortwelten, Level und spätere Content-Pakete.
- **Entscheidungen:** set_level / set_word_world / reject / needs_context
- **Risiko:** mittel
- **Aufwand:** klein bis mittel
- **Abhängigkeiten:** Wortwelten-/Level-Konzept, ggf. `docs/192-word-worlds-and-levels-plan.md`
- **Ergebnis:** Für jede Zeile ist klar, welches Level und welche Wortwelt später gesetzt werden sollen.

### Block 8: A1-C2 und Top 500 als Strukturproblem

- **Quelle:** Qualitätsreport, `seed_structure_issue_candidates.csv`
- **Anzahl:** 5.539 A1-C2-Verdachte, 500 Top-500-Verdachte
- **Warum wichtig:** Level und Pakete sind keine normalen Wortwelten; diese Trennung ist zentral für spätere Content-Pakete.
- **Entscheidungen:** level_only / package_only / keep_topic / split_mapping / needs_model_rule
- **Risiko:** hoch
- **Aufwand:** groß
- **Abhängigkeiten:** Content-Paket-Modell, Level-/Paket-Mapping
- **Ergebnis:** Eine Regel, wie Level, Pakete und Themen getrennt exportiert werden. Nicht Wort für Wort in der ersten Etappe.

### Block 9: Normale Wort-für-Wort-Prüfung

- **Quelle:** `vocabulary_review_seed.csv` als lokale Arbeitskopie
- **Anzahl:** 13.629 Zeilen
- **Warum wichtig:** Jede sichtbare Vokabel muss fachlich korrekt, eindeutig und releasefähig sein.
- **Entscheidungen:** approved / rejected / needs_review / ai_suggested / human_reviewed
- **Risiko:** hoch
- **Aufwand:** groß
- **Abhängigkeiten:** Konfliktlisten, Bedeutungsmodell, Strukturregeln
- **Ergebnis:** Nur menschlich geprüfte Zeilen werden später `approved` und `release_ready = true`.

### Block 10: Spanisch/Französisch vorbereiten

- **Quelle:** Master-Schema-Spalten `es_translation`, `fr_translation`
- **Anzahl:** aktuell 0 produktive Einträge
- **Warum wichtig:** Mehrsprachigkeit soll auf stabiler Bedeutungsbasis entstehen.
- **Entscheidungen:** leave_empty / ai_suggested / human_reviewed / approved
- **Risiko:** hoch
- **Aufwand:** groß
- **Abhängigkeiten:** Deutsch-Review, `meaning_id`, `meaning_note`
- **Ergebnis:** ES/FR bleiben leer oder explizit `needs_review`, bis eine menschliche Prüfung erfolgt.

## 4. Review-Regeln

- Niemals automatisch löschen.
- Niemals automatisch mergen.
- Niemals automatisch `approved` setzen.
- Niemals automatisch `release_ready = true` setzen.
- KI-Vorschläge dürfen nur den Status `ai_suggested` erhalten.
- Spanisch und Französisch bleiben leer oder `needs_review`, bis sie geprüft sind.
- User-Daten, SRS und `word_progress` dürfen nie betroffen sein.
- Bei Bedeutungsvarianten immer `meaning_id` und `meaning_note` vorbereiten.
- Dublettenentscheidungen müssen Kategorien, Level, POS und spätere User-/SRS-Referenzen berücksichtigen.
- Vor produktivem Merge oder Archivieren müssen Live-Referenzen erneut geprüft werden.

## 5. Arbeitsdateien

Zuerst öffnen:

1. `manual_review_first_batch.csv`
2. `seed_duplicate_candidates.csv`
3. `seed_meaning_variant_candidates.csv`
4. `seed_structure_issue_candidates.csv`
5. `vocabulary_review_seed_quality_report.md`

Parallel betrachten:

- `exact_duplicate_merge_plan.md`
- `case_variant_merge_plan.md`
- `meaning_variant_model_plan.md`
- `docs/192-word-worlds-and-levels-plan.md`

Empfehlung:

- Eine separate Arbeitskopie von `manual_review_first_batch.csv` für Review-Entscheidungen verwenden, falls mehrere Personen prüfen.
- Empfohlener Name für lokale persönliche Bearbeitung: `manual_review_first_batch_working.csv`.
- Dateien nach Muster `docs/word-review/*_working.csv` sind in `.gitignore` ignoriert.
- Die Arbeitskopie mit `tool/validate_manual_review_batch.dart` prüfen, bevor Ergebnisse weitergegeben werden.
- `review_decision` und `review_note` zunächst nur in der Arbeitskopie füllen.
- Die große `vocabulary_review_seed.csv` nicht direkt bearbeiten und nicht committen.
- `supabase_words_review.csv` als Rohbasis nicht überschreiben.
- Kandidatenlisten nicht als Korrekturdateien missverstehen; sie markieren nur Problemfälle.

Validator:

```bash
dart tool/validate_manual_review_batch.dart \
  --input docs/word-review/manual_review_first_batch_working.csv \
  --report docs/word-review/manual_review_first_batch_report.md
```

Overlay-Export:

```bash
dart tool/export_manual_review_overlay.dart \
  --input docs/word-review/manual_review_first_batch_working.csv \
  --output docs/word-review/manual_review_first_batch_overlay.csv \
  --reviewer Andreas \
  --reviewed-at 2026-05-30
```

Erlaubte Werte für `review_decision`:

- leer
- `keep`
- `merge_later`
- `split_meaning`
- `canonical_case`
- `set_level`
- `set_word_world`
- `reject`
- `needs_context`
- `add_note`

Für `needs_context`, `reject` und `split_meaning` sollte `review_note` gefüllt sein.
Der Validator setzt keine Entscheidung automatisch, vergibt kein `approved` und schreibt keine Produktivdaten.

Das Overlay-Tool exportiert nur Zeilen mit gefüllter `review_decision`.
Leere Entscheidungen werden übersprungen. Ein Overlay enthält ausschließlich:

- `word_key`
- `review_block`
- `base_term`
- `de_translation`
- `conflict_type`
- `review_decision`
- `review_note`
- `reviewer`
- `reviewed_at`

Das Overlay ist kein Produktivimport. Es enthält keine Korrekturen, kein
`approved`, kein `release_ready` und verändert keine App-, SQLite- oder
Supabase-Daten. Es dient nur dazu, abgestimmte menschliche Entscheidungen
klein und prüfbar zu versionieren. Persönliche Working-Copies bleiben ignored;
validierte Overlays können später separat reviewed und committed werden.

## 6. Erste manuelle Review-Etappe

Die erste Etappe ist bewusst klein:

- 32 exakte Dubletten
- 30 Case-Varianten
- 16 Bedeutungsvarianten
- 25 fehlende Level/Kategorie-/Wortwelt-Fälle

Arbeitsdatei:

- `manual_review_first_batch.csv`
- lokale persönliche Kopie: `manual_review_first_batch_working.csv`
- Validierungsreport: `manual_review_first_batch_report.md`
- spätere Overlay-Datei: `manual_review_first_batch_overlay.csv`

Umfang:

- 103 Review-Zeilen
- `review_decision` leer
- `review_note` leer
- keine Korrekturen
- keine Freigaben

Ziel der Etappe:

- Entscheidungen pro Kandidatengruppe vorbereiten.
- Offensichtliche Merge-/Split-/Kontextfälle klassifizieren.
- Fehlende Strukturfelder fachlich vorschlagen.
- Danach erst entscheiden, ob ein Overlay-Tool oder eine Review-Arbeitskopie für den ganzen Bestand sinnvoll ist.

Nicht Teil der ersten Etappe:

- alle 6.096 Strukturissue-Kandidaten vollständig prüfen
- alle 992 identischen `base_term`/`de_translation`-Fälle prüfen
- Spanisch/Französisch ergänzen
- `approved` setzen
- Content-Pakete exportieren

## 7. Nächste Tool-Schritte

Sinnvolle spätere Tools:

1. **Vorhandener Validator**
   - `tool/validate_manual_review_batch.dart`
   - prüft Header, Pflichtfelder, erlaubte Entscheidungen und nötige Notizen
   - schreibt nur einen Markdown-Report
   - keine Supabase-/SQLite-Verbindung, keine Imports, keine Korrekturen

2. **Vorhandenes Overlay-Tool für Review-Entscheidungen**
   - `tool/export_manual_review_overlay.dart`
   - liest eine Review-Arbeitskopie
   - erzeugt ein Overlay aus gefüllten Review-Entscheidungen
   - schreibt keine leeren Entscheidungen
   - verlangt `--force`, wenn eine Output-Datei überschrieben würde
   - verändert keine Produktivdaten

3. **Kandidatenlisten-Merge-Tool**
   - verbindet Dubletten-, Case-, Bedeutungs- und Strukturkandidaten mit dem Master-Seed
   - erzeugt kleine, priorisierte Arbeitskopien

4. **Review-Batch-Exporter**
   - erzeugt handliche Batches, z. B. 200 bis 500 Zeilen
   - filtert nach Risiko, Kategorie, Level oder Konflikttyp

5. **Release-Validator**
   - prüft, dass nur `approved` + `release_ready = true` in Release-Exports gelangen
   - blockiert `ai_suggested`, `needs_review`, leere Bedeutungsnotizen bei Varianten und Strukturkonflikte

6. **Content-Paket-Preview**
   - zeigt vor einem späteren Import, welche Wörter in welches Paket kämen
   - rein read-only, ohne Supabase- oder SQLite-Write

Noch nicht bauen:

- produktive Merge-/Archivierungslogik
- automatische Übersetzungsvorschläge
- produktive Content-Paket-Exporte
- Supabase-Write-Tools

## 8. Offene Fragen

- Soll `Top 500 Words` als Paket, Tag oder Content-Package-Membership modelliert werden?
- Sollen A1-C2 ausschließlich Level sein oder zusätzlich in manchen UIs sichtbar bleiben?
- Wie werden `meaning_id` und `meaning_note` später in lokale Daten und Supabase-Pakete übernommen?
- Soll SRS langfristig pro Wort oder pro Bedeutung laufen?
- Welche Rolle bekommen vorhandene Kategorien, wenn sie nur technische Level/Paketmarker waren?

## 9. Abschluss erster Batch und nächster Strukturblock

Der erste manuelle Batch ist abgeschlossen:

- `manual_review_first_batch_overlay.csv`
- `manual_review_first_batch_report.md`
- `manual_review_first_batch_summary.md`

Alle 103 Zeilen enthalten eine Review-Entscheidung, aber keine produktive
Korrektur oder Freigabe.

Der nächste große Review-Block trennt A1-C2 und `Top 500 Words` fachlich von
Wortwelten. Dafür wurden vorbereitet:

- `level_and_package_structure_review_plan.md`
- `level_package_structure_first_batch.csv`
- `tool/export_level_package_structure_batch.dart`

Die Struktur-Batch-Datei ist nur eine kleine Arbeitsliste. Sie verändert keine
App-Daten und setzt keine `approved`- oder `release_ready`-Werte.
