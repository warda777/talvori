# Review-Plan: Level, Top 500 und Wortwelten trennen

Stand: 2026-05-30

Diese Datei plant den nächsten Struktur-Review-Block. Es wurden keine
Supabase-Daten, keine SQLite-/App-Vokabeldaten, keine Imports, keine
SRS-Daten und kein `word_progress` verändert.

## 1. Grundentscheidung

- `A1`, `A2`, `B1`, `B2`, `C1`, `C2` sind Lernlevel.
- `Top 500 Words` ist ein Content-Paket oder eine kuratierte Sammlung.
- Beides soll nicht als normale Wortwelt erscheinen.
- Echte Wortwelten bleiben thematische Nutzeransichten, zum Beispiel
  `Travel`, `Food & Cooking`, `Work & Careers`, `Health & Fitness`,
  `Money & Shopping` oder `Media & News`.

## 2. Datenmodell-Ziel

Die späteren Content-Daten sollten logisch getrennte Felder oder Strukturen
verwenden:

- `level`: ein Lernniveau wie `A1` bis `C2`
- `word_world`: eine thematische Wortwelt
- `content_package`: eine kuratierte Sammlung wie `Top 500 Words`
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
- Wenn zusätzlich ein Thema vorhanden ist, bleibt das Thema die `word_world`.
- Wenn nur Level oder Paket vorhanden ist und keine thematische Wortwelt,
  bleibt `word_world` zunächst `needs_context`.
- Level und Paket sollen nicht gelöscht, sondern in die richtige logische
  Struktur verschoben werden.
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

## 7. Nächster Review-Batch

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

## 8. Review-Ziel für den Batch

Für jede Zeile soll später nur eine Entscheidung vorbereitet werden:

- `map_level`
- `map_package`
- `map_word_world`
- `needs_context`
- `keep`
- `reject`

Dabei gilt: keine produktiven Vokabeldaten ändern, kein Import, keine
Freigabe, keine automatische Korrektur. Erst nach dem manuellen Review kann
ein separates Overlay-Format für Strukturentscheidungen geplant werden.

## 9. Nächste technische Schritte

1. Struktur-Batch manuell prüfen.
2. Mapping-Regeln für Level, Paket und Wortwelt bestätigen.
3. Ein separates Struktur-Overlay-Format definieren.
4. Validator für Struktur-Overlays ergänzen.
5. Erst danach größere Struktur-Batches erzeugen.
