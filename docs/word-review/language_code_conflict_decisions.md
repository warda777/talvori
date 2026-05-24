# Language-Code Conflict Decisions

Stand: 2026-05-24

Diese Datei bereitet Entscheidungen fuer die 9 verbleibenden
Sprachcode-Konflikte vor. Sie ist read-only: Es wurden keine
Supabase-Daten, Woerter, Kategorien, `user_words`, `word_progress` oder
`user_word_srs` veraendert.

Quelle:
- `docs/word-review/language_code_conflict_context.csv`
- `docs/word-review/language_code_conflict_context_summary.md`

## Uebersicht

| Gruppe | Einordnung | Empfehlung | Risiko |
| --- | --- | --- | --- |
| behind | exakte Dublette | review_merge_exact_duplicate | niedrig bis mittel |
| dash | Gross-/Kleinschreibungsvariante | review_merge_case_variant | niedrig bis mittel |
| entire | exakte Dublette | review_merge_exact_duplicate | niedrig bis mittel |
| incident | Bedeutungsvariante | keep_separate_or_merge_meanings | mittel |
| interview | exakte Dublette | review_merge_exact_duplicate | niedrig bis mittel |
| move | Bedeutungsvariante | keep_separate_or_merge_meanings | mittel |
| report | Gross-/Kleinschreibungsvariante | review_merge_case_variant | niedrig bis mittel |
| satellite | Gross-/Kleinschreibungsvariante | review_merge_case_variant | niedrig bis mittel |
| throughout | Bedeutungsvariante | keep_separate_or_merge_meanings | mittel |

## Entscheidungskriterien

- Exakte Dubletten koennen spaeter fuer Merge/Archivierung geprueft werden,
  wenn Kategorien, Tags, `word_categories`, `user_words` und SRS-Verweise
  sauber zusammengefuehrt oder ausgeschlossen wurden.
- Gross-/Kleinschreibungsvarianten wirken fachlich zusammenfuehrbar, aber
  die Seite mit besseren Kategorien, Tags und Leveldaten sollte als Basis
  dienen. Deutsche Nomen sollten grossgeschrieben bleiben.
- Bedeutungsvarianten duerfen nicht automatisch geloescht werden. Bei einer
  Sprachlern-App koennen mehrere Bedeutungen fachlich relevant sein.
- Wenn spaeter SRS-/User-Bezuege auftauchen, keine automatische Loeschung
  durchfuehren.

## behind

- candidate_id: `3d018bfe-bd5d-4ba2-a448-6a92f54eb7bb`
- conflicting_id: `857507cd-ca70-4a7d-bc5f-66dc09e7f648`

| Rolle | Text | Uebersetzung | Sprachen | Level | Kategorien | Kategorie-Typen | Gruppen | Tags | User/SRS/Progress |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| candidate | behind | hinter | EN -> DE | - | Productivity | topic | Life & Daily Flow | - | 0 / 0 / 0 |
| conflict | behind | hinter | en -> de | A1 | A1 | topic | Levels & Progress | - | 0 / 0 / 0 |

Fachliche Einordnung: Exakte Dublette nach Normalisierung. Gleicher
englischer Begriff und gleiche deutsche Uebersetzung.

Empfohlene Entscheidung: `review_merge_exact_duplicate`.

Risiko: niedrig bis mittel. Vor Merge pruefen, ob die thematische Kategorie
`Productivity` und das Level `A1` zusammengefuehrt werden sollen.

Naechster technischer Schritt: Merge-/Archivierungsplan vorbereiten, der
`word_categories` beider Seiten erhalten kann. `keep_word_id` erst nach
manueller Pruefung setzen.

## dash

- candidate_id: `0a29d3d0-ad57-4c78-94b7-ad6d603915c0`
- conflicting_id: `e09286d3-351c-4f04-a14a-b7d851c25713`

| Rolle | Text | Uebersetzung | Sprachen | Level | Kategorien | Kategorie-Typen | Gruppen | Tags | User/SRS/Progress |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| candidate | dash | Bindestrich | EN -> DE | - | Productivity | topic | Life & Daily Flow | - | 0 / 0 / 0 |
| conflict | dash | bindestrich | en -> de | C2 | C2 | topic | Levels & Progress | - | 0 / 0 / 0 |

Fachliche Einordnung: Gross-/Kleinschreibungsvariante. Die deutsche
Uebersetzung ist fachlich ein Nomen und sollte `Bindestrich` bleiben.

Empfohlene Entscheidung: `review_merge_case_variant`.

Risiko: niedrig bis mittel. Kategorien und Leveldaten unterscheiden sich.

Naechster technischer Schritt: Pruefen, ob `Bindestrich` als kanonische
Uebersetzung genutzt wird und ob `Productivity` plus `C2` erhalten werden
sollen.

## entire

- candidate_id: `37a99d9c-9192-44ce-83b9-08eee8bca169`
- conflicting_id: `2a5d060a-cddf-4a67-8ce7-a21367c00fe1`

| Rolle | Text | Uebersetzung | Sprachen | Level | Kategorien | Kategorie-Typen | Gruppen | Tags | User/SRS/Progress |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| candidate | entire | gesamte | EN -> DE | - | Productivity | topic | Life & Daily Flow | - | 0 / 0 / 0 |
| conflict | entire | gesamte | en -> de | B2 | B2 | topic | Levels & Progress | - | 0 / 0 / 0 |

Fachliche Einordnung: Exakte Dublette nach Normalisierung. Gleicher
englischer Begriff und gleiche deutsche Uebersetzung.

Empfohlene Entscheidung: `review_merge_exact_duplicate`.

Risiko: niedrig bis mittel. Die Levelinformation `B2` und die thematische
Kategorie `Productivity` liegen auf unterschiedlichen Eintraegen.

Naechster technischer Schritt: Vor Merge pruefen, welcher Eintrag als Basis
dienen soll und wie Level/Kategorie zusammengefuehrt werden.

## incident

- candidate_id: `8b48b271-2a4e-472e-a0d1-99c142cdc1ab`
- conflicting_id: `f054cac4-7825-4d46-975e-ca008040a3ee`

| Rolle | Text | Uebersetzung | Sprachen | Level | Kategorien | Kategorie-Typen | Gruppen | Tags | User/SRS/Progress |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| candidate | incident | Vorfall | EN -> DE | - | - | - | - | - | 0 / 0 / 0 |
| conflict | incident | Störung/Vorfall | en -> de | B1 | B2; Work & Careers | topic | Levels & Progress; Society & Systems | - | 0 / 0 / 0 |

Fachliche Einordnung: Bedeutungsvariante. `Vorfall` und
`Störung/Vorfall` koennen je nach Kontext zusammengehoeren, sind aber nicht
identisch modelliert.

Empfohlene Entscheidung: `keep_separate_or_merge_meanings`.

Risiko: mittel. Nicht automatisch loeschen, weil Bedeutungsvarianten in der
Lernlogik relevant sein koennen.

Naechster technischer Schritt: Datenmodell fuer mehrere Bedeutungen pruefen.
Moegliche kanonische Uebersetzung waere `Vorfall; Störung`, falls ein
Mehrbedeutungsfeld oder ein sauberer Trenner vorgesehen ist.

## interview

- candidate_id: `1aff8ead-820c-447c-9dc9-fe5981d91412`
- conflicting_id: `b07abd1a-d672-4f35-a12c-86c0ff47062d`

| Rolle | Text | Uebersetzung | Sprachen | Level | Kategorien | Kategorie-Typen | Gruppen | Tags | User/SRS/Progress |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| candidate | interview | Interview | EN -> DE | - | Productivity | topic | Life & Daily Flow | - | 0 / 0 / 0 |
| conflict | interview | Interview | en -> de | A1 | A1; Media & News | topic | Levels & Progress; Society & Systems | - | 0 / 0 / 0 |

Fachliche Einordnung: Exakte Dublette nach Normalisierung. Gleicher
englischer Begriff und gleiche deutsche Uebersetzung.

Empfohlene Entscheidung: `review_merge_exact_duplicate`.

Risiko: niedrig bis mittel. Die thematischen Zuordnungen unterscheiden sich.

Naechster technischer Schritt: Pruefen, ob `Media & News`, `Productivity`
und `A1` am zu behaltenden Eintrag zusammengefuehrt werden sollen.

## move

- candidate_id: `0c165b4c-2afb-4861-ac60-75bf59a8611b`
- conflicting_id: `ba6b854f-c6af-4751-b9e8-61d8374272a2`

| Rolle | Text | Uebersetzung | Sprachen | Level | Kategorien | Kategorie-Typen | Gruppen | Tags | User/SRS/Progress |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| candidate | move | umziehen | EN -> DE | - | - | - | - | - | 0 / 0 / 0 |
| conflict | move | bewegen | en -> de | B1 | A1; B1; Top 500 Words | topic | Language Tools; Levels & Progress | - | 0 / 0 / 0 |

Fachliche Einordnung: Bedeutungsvariante. `move` kann `bewegen` und
`umziehen` bedeuten; beide Bedeutungen sind fuer Lernende relevant.

Empfohlene Entscheidung: `keep_separate_or_merge_meanings`.

Risiko: mittel. Nicht automatisch loeschen. Der bestehende Konflikt traegt
Top-500-/Level-Kontext, der spaeter separat behandelt werden muss.

Naechster technischer Schritt: Pruefen, ob `move` als ein Eintrag mit
`bewegen; umziehen` modelliert werden soll oder ob getrennte Bedeutungen im
Datenmodell vorgesehen sind.

## report

- candidate_id: `31b9fd7e-fbbf-44fa-af67-40c66144f843`
- conflicting_id: `70fbac34-dad7-4af5-986a-19942af4baf5`

| Rolle | Text | Uebersetzung | Sprachen | Level | Kategorien | Kategorie-Typen | Gruppen | Tags | User/SRS/Progress |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| candidate | report | Bericht | EN -> DE | - | Productivity | topic | Life & Daily Flow | - | 0 / 0 / 0 |
| conflict | report | bericht | en -> de | A2 | A1; A2 | topic | Levels & Progress | - | 0 / 0 / 0 |

Fachliche Einordnung: Gross-/Kleinschreibungsvariante. Als Nomen sollte die
deutsche Uebersetzung `Bericht` bleiben. Achtung: Der conflict-Eintrag hat
`pos = verb`, was fachlich gegen die Uebersetzung `bericht` spricht und
zusaetzlich geprueft werden sollte.

Empfohlene Entscheidung: `review_merge_case_variant`.

Risiko: niedrig bis mittel. POS, Level und Kategorien sollten vor Merge
validiert werden.

Naechster technischer Schritt: Kanonische Uebersetzung `Bericht` pruefen und
entscheiden, ob POS korrigiert oder separat modelliert werden muss.

## satellite

- candidate_id: `32464b29-fec5-4fd3-ba25-a873e3b0f8eb`
- conflicting_id: `e0d7acc3-7b01-48b4-a6e8-2f0cb06ad422`

| Rolle | Text | Uebersetzung | Sprachen | Level | Kategorien | Kategorie-Typen | Gruppen | Tags | User/SRS/Progress |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| candidate | satellite | Satellit | EN -> DE | - | - | - | - | - | 0 / 0 / 0 |
| conflict | satellite | satellit | en -> de | B2 | B2; Space | topic | Levels & Progress; Nature & Beyond | - | 0 / 0 / 0 |

Fachliche Einordnung: Gross-/Kleinschreibungsvariante. Die deutsche
Uebersetzung ist ein Nomen und sollte `Satellit` bleiben.

Empfohlene Entscheidung: `review_merge_case_variant`.

Risiko: niedrig bis mittel. Der conflict-Eintrag hat bessere Level- und
Wortwelt-Daten.

Naechster technischer Schritt: `Satellit` als kanonische Uebersetzung
pruefen und `B2`/`Space` erhalten.

## throughout

- candidate_id: `6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f`
- conflicting_id: `8aae50ac-dadb-49ad-8ce6-89f6c501ecac`

| Rolle | Text | Uebersetzung | Sprachen | Level | Kategorien | Kategorie-Typen | Gruppen | Tags | User/SRS/Progress |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| candidate | throughout | durchgehend | EN -> DE | - | - | - | - | - | 0 / 0 / 0 |
| conflict | throughout | in ganz | en -> de | B1 | B1 | topic | Levels & Progress | - | 0 / 0 / 0 |

Fachliche Einordnung: Bedeutungsvariante. `durchgehend` und `in ganz`
decken unterschiedliche Nutzungen ab; `in ganz` wirkt alleine sprachlich
unvollstaendig und sollte fachlich geprueft werden.

Empfohlene Entscheidung: `keep_separate_or_merge_meanings`.

Risiko: mittel. Nicht automatisch loeschen oder zusammenfuehren, bevor die
gewuenschte Uebersetzungsform feststeht.

Naechster technischer Schritt: Fachlich pruefen, ob `durchgehend; während
des gesamten` oder eine getrennte Bedeutungsmodellierung besser passt.

## Naechste technische Schritte

1. Fuer jede Gruppe `keep_word_id` manuell festlegen, falls ein Merge oder
   Archivierungsschritt gewuenscht ist.
2. Vor produktiven Aenderungen nochmals live pruefen, ob inzwischen
   `user_words`, `word_progress`, `user_word_srs` oder neue Kategorien an
   einer der IDs haengen.
3. Danach erst ein separates SQL-/Tool-Konzept fuer Merge, Archivierung oder
   Bedeutungszusammenfuehrung erstellen.

