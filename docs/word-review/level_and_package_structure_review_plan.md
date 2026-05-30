# Review-Plan: Level, Top 500 und Wortwelten trennen

Stand: 2026-05-30

Diese Datei plant den nächsten Struktur-Review-Block. Es wurden keine
Supabase-Daten, keine SQLite-/App-Vokabeldaten, keine Imports, keine
SRS-Daten und kein `word_progress` verändert.

## 1. Grundentscheidung

- `A1`, `A2`, `B1`, `B2`, `C1`, `C2` sind Lernlevel.
- `Top 500 Words` ist ein Content-Paket oder eine kuratierte Sammlung.
- `Top 500 Words` sollte langfristig als Paketfamilie gedacht werden, nicht
  nur als ein einzelner großer Block.
- Beides soll nicht als normale Wortwelt erscheinen.
- Echte Wortwelten bleiben thematische Nutzeransichten, zum Beispiel
  `Travel`, `Food & Cooking`, `Work & Careers`, `Health & Fitness`,
  `Money & Shopping` oder `Media & News`.
- Speziallisten wie `TOEFL`, `IELTS`, `Cambridge English`,
  `Business English`, `Exam Preparation`, `Irregular Verbs`,
  `Phrases & Idioms` oder `Grammar & Syntax` sind ebenfalls keine normalen
  Wortwelten. Sie sind kuratierte Content-Pakete, Prüfungspakete oder
  Lernsammlungen.

## 2. Datenmodell-Ziel

Die späteren Content-Daten sollten logisch getrennte Felder oder Strukturen
verwenden:

- `level`: ein Lernniveau wie `A1` bis `C2`
- `word_world`: eine thematische Wortwelt
- `content_package`: eine kuratierte Sammlung wie `Top 500 Words`
- `content_package_id`: stabile technische Paket-ID, z. B.
  `top-100-en-de-v1`
- `package_family`: Paketfamilie, z. B. `top_words`, `toefl`,
  `business_english`
- `package_stage`: Stufe innerhalb einer Paketfamilie, z. B. `100`, `200`
  oder `academic`
- `package_type`: z. B. `frequency`, `exam`, `topic_pack`, `grammar`,
  `phrase_pack`
- `tags`: optionale Zusatzmerkmale
- `package_membership`: spätere Many-to-many-Zuordnung zwischen Wörtern und
  Content-Paketen

Diese Trennung muss später sowohl lokal als auch in Supabase-/Content-Paketen
konsistent gelten.

## 3. Warum das wichtig ist

- Die UI wird klarer, weil Lernlevel nicht wie Themen wirken.
- Content-Pakete werden versionierbar und können später gezielt
  heruntergeladen oder freigeschaltet werden.
- Mehrsprachige Pakete können pro Sprachpaar erzeugt werden.
- SRS und `word_progress` bleiben unabhängig vom Content-Layout.
- `Top 500 Words` kann später als Paket gepflegt werden, ohne die
  Wortwelten-Navigation zu vermischen.
- Kleinere Top-Wortschatz-Pakete verhindern, dass Nutzer direkt von einem
  großen 500er-Block erschlagen werden.
- Prüfungspakete wie TOEFL oder IELTS können versioniert, kuratiert und
  pro Sprachpaar separat freigegeben werden.
- A1-C2 kann für Lernpfade, Progression und Filter genutzt werden.

## 4. Aktuelle Risiken

- A1-C2 taucht aktuell in Kategorien und Wortwelten auf.
- `Top 500 Words` taucht aktuell in Kategorien und Wortwelten auf.
- Mehrfachkategorien vermischen Themen, Level und Paketzugehörigkeit.
- Der Qualitätsreport nennt 5.539 A1-C2-Strukturverdachte und 500
  Top-500-Strukturverdachte.
- Insgesamt gibt es 6.096 Strukturissue-Kandidaten.
- Eine automatische Korrektur wäre riskant, weil echte Themenzuordnungen
  verloren gehen könnten.

## 5. Review-Regeln

- Wenn eine Kategorie `A1` bis `C2` ist, wird sie als `level` behandelt.
- Wenn eine Kategorie `Top 500 Words` ist, wird sie als `content_package`
  behandelt.
- Wenn eine Kategorie oder ein Feld Begriffe wie `Top 100`, `Top 200`,
  `Top 300`, `Top 400`, `Top 500`, `TOEFL`, `IELTS`, `Cambridge`,
  `Business English`, `Exam Preparation`, `Irregular Verbs`,
  `Phrases & Idioms` oder `Grammar & Syntax` enthält, wird sie nicht als
  normale Wortwelt behandelt.
- Solche Begriffe werden als Content-Paket, Spezialliste oder Lernsammlung
  geprüft.
- Wenn zusätzlich ein Thema vorhanden ist, bleibt das Thema die `word_world`.
- Wenn nur Level oder Paket vorhanden ist und keine thematische Wortwelt,
  bleibt `word_world` zunächst `needs_context`.
- Level und Paket sollen nicht gelöscht, sondern in die richtige logische
  Struktur verschoben werden.
- Keine automatische Paketzuordnung ohne Review.
- Nicht automatisch löschen.
- Nicht automatisch mergen.
- Nicht automatisch App-Daten ändern.
- Nur Mapping-Regeln und Review-Entscheidungen vorbereiten.

## 6. Beispiel-Mapping

| Aktuelle Struktur | Ziel-Mapping |
|---|---|
| `A1; Travel` | `level=A1`, `word_world=Travel` |
| `B2; Top 500 Words; Work & Careers` | `level=B2`, `content_package=Top 500 Words`, `word_world=Work & Careers` |
| `C1` allein | `level=C1`, `word_world=needs_context` |
| `Top 500 Words` allein | `content_package=Top 500 Words`, `word_world=needs_context` |
| `A2; B1; Health & Fitness` | mehrere Level prüfen, `word_world=Health & Fitness` |
| `A1; Food & Cooking; Home & Living; Top 500 Words` | `level=A1`, `content_package=Top 500 Words`, mehrere Themen prüfen |
| `TOEFL; Academic English; B2` | `level=B2`, `content_package=TOEFL`, `word_world=needs_context`, optional `tag=academic` prüfen |
| `Business English; Work & Careers; B1` | `level=B1`, `content_package=Business English`, `word_world=Work & Careers` |

## 7. Top-Wortschatz als Paketfamilie

`Top 500 Words` sollte langfristig nicht nur als ein großes Paket verstanden
werden. Für Nutzer ist eine feinere Etappierung besser:

- `Top 100`
- `Top 200`
- `Top 300`
- `Top 400`
- `Top 500`

Es gibt zwei mögliche Modellierungsarten.

### Option A: Kumulative Pakete

Bei kumulativen Paketen ist `Top 100` Teil von `Top 200`, `Top 200` Teil von
`Top 300` und so weiter. Ein Wort aus Rang 1-100 gehört damit zugleich zu
`Top 100`, `Top 200`, `Top 300`, `Top 400` und `Top 500`.

Vorteile:

- sehr leicht für Nutzer zu verstehen
- Fortschritt kann als wachsende Zielmenge dargestellt werden
- `Top 500` bleibt als Gesamtpaket nutzbar
- Download/Freischaltung kann stufenweise erfolgen

Nachteile:

- ein Wort kann viele Paket-Memberships bekommen
- Exporte müssen Dubletten zwischen Stufen sauber deduplizieren
- Metriken müssen unterscheiden, ob ein Wort mehrfach gezählt wird oder nur
  einmal im größten aktiven Paket

### Option B: Bereichspakete

Bei Bereichspaketen werden nicht-kumulative Blöcke modelliert:

- `Top 1-100`
- `Top 101-200`
- `Top 201-300`
- `Top 301-400`
- `Top 401-500`

Vorteile:

- jedes Wort gehört pro Rangbereich nur zu einem Block
- technische Auswertung und Paketgrößen sind klarer
- Review-Batches lassen sich sauber in 100er-Blöcke schneiden
- spätere Paketversionen können gezielt nur einen Bereich aktualisieren

Nachteile:

- Nutzer müssen verstehen, dass `Top 300` aus mehreren Bereichspaketen besteht
- eine zusätzliche Paketfamilien-/Bundle-Logik wird nötig
- UI muss Gesamtpakete aus Bereichen zusammensetzen können

### Empfehlung

Für die Content-Pipeline ist Option B robuster: intern sollten
Bereichspakete wie `Top 1-100` und `Top 101-200` gespeichert werden. Für die
Nutzeroberfläche kann Talvori daraus kumulative Ziele wie `Top 100`,
`Top 200` oder `Top 500` zusammensetzen.

Damit bleiben Datenpflege und Versionierung sauber, während die UX trotzdem
kleine, motivierende Etappen zeigen kann.

## 8. Spezial- und Prüfungspakete

Prüfungs- und Spezialpakete sollen als Content-Pakete modelliert werden,
nicht als Wortwelten. Beispiele:

- `TOEFL`
- `IELTS`
- `Cambridge English`
- `Business English`
- `Travel Basics`
- `School English`
- `Academic English`
- `Exam Preparation`
- `Irregular Verbs`
- `Phrases & Idioms`
- `Grammar & Syntax`

Solche Pakete dürfen eigene Metadaten erhalten:

- `content_package_id`
- `package_family`
- `package_stage`
- `package_type`
- `language_pair`
- `level_range`
- `version`
- `status`

Beispiele für stabile Paket-IDs:

- `toefl-academic-en-de-v1`
- `top-100-en-de-v1`
- `top-500-en-de-v1`
- `business-english-b1-b2-en-de-v1`

Ein Wort kann gleichzeitig mehreren Sichten angehören:

- `level=B2`
- `word_world=Work & Careers`
- `content_package=TOEFL`
- `tags=academic; exam`

Die Paketzugehörigkeit darf aber erst nach Review gesetzt werden. Es werden
keine echten TOEFL-, IELTS-, Cambridge- oder Business-English-Wörter aus
dieser Planung heraus erzeugt.

## 9. Nächster Review-Batch

Der nächste Batch soll nicht alle 6.096 Strukturissues enthalten. Stattdessen
gibt es eine kleine repräsentative Arbeitsliste:

`docs/word-review/level_package_structure_first_batch.csv`

Sie enthält maximal 200 Zeilen und wird aus
`seed_structure_issue_candidates.csv` erzeugt. Aktuell enthält sie 57
Review-Zeilen plus Header.

Abgedeckte Falltypen:

- `level_only`
- `level_top_500`
- `level_topic`
- `level_top_500_topic`
- `multi_topic`

Nicht im aktuellen Quell-Sample enthalten:

- `top_500_only`
- `top_500_topic`

Diese Fälle sollten später ergänzt werden, falls sie im vollständigen
Strukturissue-Bestand vorkommen.

## 10. Review-Ziel für den Batch

Für jede Zeile wird nur eine Entscheidung vorbereitet:

- `map_level`
- `map_package`
- `map_word_world`
- `needs_context`
- `keep`
- `reject`

Dabei gilt: keine produktiven Vokabeldaten ändern, kein Import, keine
Freigabe, keine automatische Korrektur.

Der erste Struktur-Batch wurde in einer lokalen Working-Copy bearbeitet:

- Working-Copy: `docs/word-review/level_package_structure_first_batch_working.csv`
- Report: `docs/word-review/level_package_structure_first_batch_report.md`
- Overlay: `docs/word-review/level_package_structure_first_batch_overlay.csv`

Die Working-Copy bleibt lokal/ignored. Das Overlay enthält nur
Review-Entscheidungen und ist kein Import, kein Merge und keine produktive
Korrektur.

Aktuelle Entscheidungssumme:

| Entscheidung | Anzahl |
|---|---:|
| `map_level` | 25 |
| `map_package` | 15 |
| `map_word_world` | 17 |

## 11. Struktur-Validator und Overlay-Exporter

Für den Struktur-Batch existieren zwei read-only Werkzeuge:

- `tool/validate_level_package_structure_batch.dart`
- `tool/export_level_package_structure_overlay.dart`

Der Validator prüft:

- erwartetes Schema
- Pflichtfelder
- erlaubte `review_decision` Werte
- Notizpflicht bei `needs_context` und `reject`
- Zielstruktur-Hinweis bei `map_level`, `map_package` und `map_word_world`
- Zeilen pro Strukturfall
- Entscheidungen nach Typ

Der Overlay-Exporter schreibt nur Zeilen mit gefüllter Entscheidung. Er
verbindet sich nicht mit Supabase, öffnet keine SQLite-Datenbank, führt keinen
Import aus und setzt keine Freigabe.

## 12. Offene Fragen zur Paketstruktur

- Soll `Top 500` in der UI kumulativ erscheinen, während intern
  Bereichspakete gepflegt werden?
- Soll ein Wort mehrere Pakete haben dürfen? Empfehlung: ja, über
  `package_membership`.
- Wie werden Prüfungspakete später fachlich kuratiert und von wem
  freigegeben?
- Werden Prüfungspakete immer pro Sprachpaar versioniert, z. B. `en-de`,
  `en-es`, `en-fr`?
- Soll ein TOEFL-Paket nur für englische Lernsprache existieren oder später
  auch andere Lernrichtungen unterstützen?
- Brauchen Spezialpakete eigene Qualitätsstatus jenseits von
  `approved`, z. B. `expert_reviewed`?
- Wie werden Phrasen, Idioms und Grammatikstrukturen modelliert, wenn sie
  keine klassischen Einzelwörter sind?

## 13. Nächste technische Schritte

1. Struktur-Overlay fachlich gegen die Planung gegenlesen.
2. Gezielt weitere `top_500_only` und `top_500_topic` Fälle suchen, falls sie
   im vollständigen Kandidatenbestand vorkommen.
3. Entscheiden, ob Top-Wortschatz intern als Bereichspakete oder kumulativ
   gespeichert wird.
4. Paket-Metadatenmodell mit `package_family`, `package_stage`,
   `package_type`, `language_pair`, `level_range`, `version` und `status`
   finalisieren.
5. Größere Struktur-Batches erst nach Auswertung dieses repräsentativen
   Batches erzeugen.
6. Später ein getrenntes Import-/Migrationskonzept bauen, das Level, Paket und
   Wortwelt produktiv trennt.
