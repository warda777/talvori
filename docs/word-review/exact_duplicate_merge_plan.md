# Exact Duplicate Merge Plan

Stand: 2026-05-24

Diese Datei ist eine reine Entscheidungsvorbereitung fuer drei exakte
Sprachcode-Dubletten. Es wurden keine Supabase-Daten geaendert, keine
Woerter geloescht, keine Kategorien veraendert und keine SRS-/User-Daten
beruehrt.

Grundlage:
- `docs/word-review/language_code_conflict_decisions.md`
- `docs/word-review/language_code_conflict_context.csv`
- `docs/word-review/language_code_conflicts_remaining_summary.md`

## Leitentscheidung

Bei allen drei Gruppen wirkt die `en`/`de`-ID fachlich als bessere
Behalte-Kandidatin, weil dort bereits Level, POS und/oder sauberere
Remote-Metadaten vorhanden sind. Die `EN`/`DE`-ID enthaelt dagegen jeweils
die thematische Kategorie `Productivity`.

Vorlaeufige Empfehlung:
- `en`/`de`-ID behalten.
- `Productivity`-Membership des `EN`/`DE`-Kandidaten auf die `en`/`de`-ID
  uebertragen.
- `EN`/`DE`-Dubletten erst archivieren, wenn eine sichere
  Archivierungsstrategie fuer `public.words` bestaetigt wurde.
- Keine automatische Loeschung.

## behind

### IDs

- candidate_id: `3d018bfe-bd5d-4ba2-a448-6a92f54eb7bb`
- conflicting_id: `857507cd-ca70-4a7d-bc5f-66dc09e7f648`

### Voraussichtliche Behalte-/Archivierungsentscheidung

- Voraussichtlich behalten: `857507cd-ca70-4a7d-bc5f-66dc09e7f648`
- Koennte spaeter archiviert werden:
  `3d018bfe-bd5d-4ba2-a448-6a92f54eb7bb`

Begruendung:
- keep-Kandidat ist bereits `behind / hinter / en -> de`.
- keep-Kandidat hat Level `A1` und POS `preposition`.
- candidate hat die thematische Kategorie `Productivity`.

### Zu erhaltende Kategorien und Leveldaten

- Keep-ID behalten:
  - Level: `A1`
  - Kategorie: `A1`
  - Gruppe: `Levels & Progress`
- Vom candidate uebernehmen:
  - Kategorie: `Productivity`
  - Gruppe: `Life & Daily Flow`

### User-/SRS-/Progress-Bezuege

Im Kontext-Export sichtbar:
- candidate: `user_words_count = 0`, `word_progress_count = 0`,
  `user_word_srs_count = 0`
- conflict: `user_words_count = 0`, `word_progress_count = 0`,
  `user_word_srs_count = 0`

Vor produktivem Merge trotzdem live erneut pruefen.

### Risiko

Niedrig bis mittel. Das Risiko liegt vor allem im Verlust der
`Productivity`-Zuordnung oder in spaeter auftauchenden User-/SRS-Bezuegen.

### Spaetere SQL-Schritte

1. Vorher live beide `words`-Zeilen lesen.
2. Live `user_words`, `word_progress`, `user_word_srs` fuer beide IDs
   zaehlen.
3. `word_categories` beider IDs lesen.
4. Fehlende Kategorie-Memberships des candidate auf die keep-ID kopieren.
5. Archivierungsstrategie fuer candidate pruefen.
6. Erst danach candidate archivieren oder separat als Konflikt belassen.

## entire

### IDs

- candidate_id: `37a99d9c-9192-44ce-83b9-08eee8bca169`
- conflicting_id: `2a5d060a-cddf-4a67-8ce7-a21367c00fe1`

### Voraussichtliche Behalte-/Archivierungsentscheidung

- Voraussichtlich behalten: `2a5d060a-cddf-4a67-8ce7-a21367c00fe1`
- Koennte spaeter archiviert werden:
  `37a99d9c-9192-44ce-83b9-08eee8bca169`

Begruendung:
- keep-Kandidat ist bereits `entire / gesamte / en -> de`.
- keep-Kandidat hat Level `B2` und POS `adjective`.
- candidate hat die thematische Kategorie `Productivity`.

### Zu erhaltende Kategorien und Leveldaten

- Keep-ID behalten:
  - Level: `B2`
  - Kategorie: `B2`
  - Gruppe: `Levels & Progress`
- Vom candidate uebernehmen:
  - Kategorie: `Productivity`
  - Gruppe: `Life & Daily Flow`

### User-/SRS-/Progress-Bezuege

Im Kontext-Export sichtbar:
- candidate: `user_words_count = 0`, `word_progress_count = 0`,
  `user_word_srs_count = 0`
- conflict: `user_words_count = 0`, `word_progress_count = 0`,
  `user_word_srs_count = 0`

Vor produktivem Merge trotzdem live erneut pruefen.

### Risiko

Niedrig bis mittel. Das Risiko liegt vor allem im Verlust der
`Productivity`-Zuordnung oder in spaeter auftauchenden User-/SRS-Bezuegen.

### Spaetere SQL-Schritte

1. Vorher live beide `words`-Zeilen lesen.
2. Live `user_words`, `word_progress`, `user_word_srs` fuer beide IDs
   zaehlen.
3. `word_categories` beider IDs lesen.
4. Fehlende Kategorie-Memberships des candidate auf die keep-ID kopieren.
5. Archivierungsstrategie fuer candidate pruefen.
6. Erst danach candidate archivieren oder separat als Konflikt belassen.

## interview

### IDs

- candidate_id: `1aff8ead-820c-447c-9dc9-fe5981d91412`
- conflicting_id: `b07abd1a-d672-4f35-a12c-86c0ff47062d`

### Voraussichtliche Behalte-/Archivierungsentscheidung

- Voraussichtlich behalten: `b07abd1a-d672-4f35-a12c-86c0ff47062d`
- Koennte spaeter archiviert werden:
  `1aff8ead-820c-447c-9dc9-fe5981d91412`

Begruendung:
- keep-Kandidat ist bereits `interview / Interview / en -> de`.
- keep-Kandidat hat Level `A1`, POS `noun` und die thematische Kategorie
  `Media & News`.
- candidate hat zusaetzlich die thematische Kategorie `Productivity`.

### Zu erhaltende Kategorien und Leveldaten

- Keep-ID behalten:
  - Level: `A1`
  - Kategorien: `A1`, `Media & News`
  - Gruppen: `Levels & Progress`, `Society & Systems`
- Vom candidate uebernehmen:
  - Kategorie: `Productivity`
  - Gruppe: `Life & Daily Flow`

### User-/SRS-/Progress-Bezuege

Im Kontext-Export sichtbar:
- candidate: `user_words_count = 0`, `word_progress_count = 0`,
  `user_word_srs_count = 0`
- conflict: `user_words_count = 0`, `word_progress_count = 0`,
  `user_word_srs_count = 0`

Vor produktivem Merge trotzdem live erneut pruefen.

### Risiko

Niedrig bis mittel. Das Risiko liegt vor allem im Verlust der
`Productivity`-Zuordnung oder in spaeter auftauchenden User-/SRS-Bezuegen.

### Spaetere SQL-Schritte

1. Vorher live beide `words`-Zeilen lesen.
2. Live `user_words`, `word_progress`, `user_word_srs` fuer beide IDs
   zaehlen.
3. `word_categories` beider IDs lesen.
4. Fehlende Kategorie-Memberships des candidate auf die keep-ID kopieren.
5. Archivierungsstrategie fuer candidate pruefen.
6. Erst danach candidate archivieren oder separat als Konflikt belassen.

## Gemeinsame technische Reihenfolge fuer einen spaeteren Merge

1. Live-Pruefung aller sechs IDs.
2. Live-Pruefung aller User-/SRS-/Progress-Tabellen.
3. Live-Pruefung von `word_categories`.
4. Falls keine blockierenden User-/SRS-Bezuege bestehen:
   - fehlende `word_categories` vom archive-Kandidaten auf keep-ID kopieren.
   - pruefen, ob `public.words` ein Archivierungsfeld besitzt.
   - nur bei bestaetigter Strategie archivieren.
5. Keine `DELETE`-Strategie verwenden, solange User-/SRS-Referenzen und
   historische Imports nicht vollstaendig geklaert sind.

