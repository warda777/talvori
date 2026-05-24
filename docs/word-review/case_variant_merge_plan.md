# Case Variant Merge Plan

Stand: 2026-05-24

Diese Datei ist eine reine Entscheidungsvorbereitung fuer drei
Gross-/Kleinschreibungsvarianten unter den verbleibenden
Sprachcode-Konflikten. Es wurden keine Supabase-Daten geaendert, keine
Woerter geloescht, keine Kategorien veraendert und keine SRS-/User-Daten
beruehrt.

Grundlage:
- `docs/word-review/language_code_conflict_decisions.md`
- `docs/word-review/language_code_conflict_context.csv`
- `docs/word-review/language_code_conflicts_remaining_summary.md`

## Leitentscheidung

Fuer alle drei Faelle wirkt ein spaeterer Merge oder eine Archivierung
fachlich plausibel, aber nicht automatisch:

- Eine kanonische `en`/`de`-ID sollte voraussichtlich erhalten bleiben.
- Die deutsche Uebersetzung sollte bei Nomen grossgeschrieben werden.
- Level-, POS- und Kategorie-Daten muessen erhalten bleiben.
- Thematische Kategorien des anderen Eintrags sollten auf die keep-ID
  uebertragen werden, falls sie dort fehlen.
- Der Dubletten-Eintrag sollte erst spaeter archiviert werden, wenn eine
  sichere Archivierungsstrategie bestaetigt ist.
- `keep_word_id` wird in diesem Schritt nicht endgueltig gesetzt.

## dash

### IDs

- candidate_id: `0a29d3d0-ad57-4c78-94b7-ad6d603915c0`
- conflicting_id: `e09286d3-351c-4f04-a14a-b7d851c25713`

### Kontext

| Rolle | Text | Uebersetzung | Sprachen | Level | POS | Kategorien | Gruppen | Tags | User/SRS/Progress |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| candidate | dash | Bindestrich | EN -> DE | - | - | Productivity | Life & Daily Flow | - | 0 / 0 / 0 |
| conflict | dash | bindestrich | en -> de | C2 | other | C2 | Levels & Progress | - | 0 / 0 / 0 |

### Empfohlene kanonische Uebersetzung

`Bindestrich`

Begruendung: Deutsches Nomen, sollte grossgeschrieben bleiben.

### Voraussichtliche keep-ID

Voraussichtlich behalten: `e09286d3-351c-4f04-a14a-b7d851c25713`

Begruendung:
- Bereits `en`/`de`.
- Enthält Level `C2`.
- Candidate liefert die bessere Schreibweise und die thematische Kategorie
  `Productivity`.

### Zu uebertragende Daten

- Von candidate auf keep-ID:
  - Uebersetzung: `Bindestrich`
  - Kategorie: `Productivity`
  - Gruppe: `Life & Daily Flow`
- Auf keep-ID erhalten:
  - Level: `C2`
  - Kategorie: `C2`
  - POS: `other`, spaeter fachlich pruefen

### Risiko

Niedrig bis mittel. Das fachliche Risiko liegt in POS `other` und in der
Kategorie-Zusammenfuehrung.

### Naechster technischer Schritt

Vor produktivem Merge live pruefen, ob neue User-/SRS-Verweise entstanden
sind. Danach SQL-Entwurf fuer Grossschreibung und Kategorie-Uebertragung
separat erstellen.

## report

### IDs

- candidate_id: `31b9fd7e-fbbf-44fa-af67-40c66144f843`
- conflicting_id: `70fbac34-dad7-4af5-986a-19942af4baf5`

### Kontext

| Rolle | Text | Uebersetzung | Sprachen | Level | POS | Kategorien | Gruppen | Tags | User/SRS/Progress |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| candidate | report | Bericht | EN -> DE | - | - | Productivity | Life & Daily Flow | - | 0 / 0 / 0 |
| conflict | report | bericht | en -> de | A2 | verb | A1; A2 | Levels & Progress | - | 0 / 0 / 0 |

### Empfohlene kanonische Uebersetzung

`Bericht`

Begruendung: Als deutsche Uebersetzung ist `Bericht` ein Nomen und sollte
grossgeschrieben bleiben.

### Voraussichtliche keep-ID

Voraussichtlich behalten: `70fbac34-dad7-4af5-986a-19942af4baf5`

Begruendung:
- Bereits `en`/`de`.
- Enthält Level `A2` und Kategorien `A1`, `A2`.
- Candidate liefert die bessere Schreibweise und die thematische Kategorie
  `Productivity`.

### Zu uebertragende Daten

- Von candidate auf keep-ID:
  - Uebersetzung: `Bericht`
  - Kategorie: `Productivity`
  - Gruppe: `Life & Daily Flow`
- Auf keep-ID erhalten:
  - Level: `A2`
  - Kategorien: `A1`, `A2`
- Fachlich pruefen:
  - POS ist aktuell `verb`, passt aber nicht zur Uebersetzung `Bericht`.
  - Moegliche Alternativen: POS korrigieren, Bedeutung splitten oder
    separate Verb-Bedeutung modellieren.

### Risiko

Mittel. Der POS-Konflikt macht diesen Fall etwas riskanter als reine
Schreibvarianten. Nicht automatisch mergen, bevor POS und Bedeutung geklaert
sind.

### Naechster technischer Schritt

Vor produktivem Merge klären, ob `report` in diesem Datensatz als Nomen
(`Bericht`) oder Verb (`berichten`) modelliert werden soll. Danach erst
Grossschreibung, Kategorien und moegliche Archivierung planen.

## satellite

### IDs

- candidate_id: `32464b29-fec5-4fd3-ba25-a873e3b0f8eb`
- conflicting_id: `e0d7acc3-7b01-48b4-a6e8-2f0cb06ad422`

### Kontext

| Rolle | Text | Uebersetzung | Sprachen | Level | POS | Kategorien | Gruppen | Tags | User/SRS/Progress |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| candidate | satellite | Satellit | EN -> DE | - | - | - | - | - | 0 / 0 / 0 |
| conflict | satellite | satellit | en -> de | B2 | noun | B2; Space | Levels & Progress; Nature & Beyond | - | 0 / 0 / 0 |

### Empfohlene kanonische Uebersetzung

`Satellit`

Begruendung: Deutsches Nomen, sollte grossgeschrieben bleiben.

### Voraussichtliche keep-ID

Voraussichtlich behalten: `e0d7acc3-7b01-48b4-a6e8-2f0cb06ad422`

Begruendung:
- Bereits `en`/`de`.
- Enthält Level `B2`, POS `noun` und thematische Kategorie `Space`.
- Candidate liefert vor allem die korrekte Grossschreibung.

### Zu uebertragende Daten

- Von candidate auf keep-ID:
  - Uebersetzung: `Satellit`
- Auf keep-ID erhalten:
  - Level: `B2`
  - POS: `noun`
  - Kategorien: `B2`, `Space`
  - Gruppen: `Levels & Progress`, `Nature & Beyond`

### Risiko

Niedrig bis mittel. Der keep-Eintrag besitzt bereits die wichtigeren
Metadaten; die Hauptkorrektur waere die Grossschreibung.

### Naechster technischer Schritt

Vor produktivem Merge live pruefen, ob neue User-/SRS-Verweise entstanden
sind. Danach SQL-Entwurf fuer Grossschreibung und eventuelle Archivierung
separat erstellen.

## Gemeinsame technische Reihenfolge fuer einen spaeteren Merge

1. Live-Pruefung aller sechs IDs.
2. Live-Pruefung von `user_words`, `word_progress`, `user_word_srs`.
3. Live-Pruefung von `word_categories`.
4. Fachliche POS-Pruefung, besonders fuer `report`.
5. Falls sicher:
   - keep-ID behalten.
   - korrekte Grossschreibung auf keep-ID setzen.
   - fehlende Kategorien vom anderen Eintrag uebertragen.
   - Dubletten-Eintrag nur mit bestaetigter Archivierungsstrategie
     archivieren.
6. Keine `DELETE`-Strategie verwenden.

