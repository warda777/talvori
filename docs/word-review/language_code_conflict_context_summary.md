# Language-Code Conflict Context Summary

Stand: 2026-05-24T18:51:34.586923

Dieser Schritt ist read-only. Es wurden keine Supabase-Daten,
Woerter, Kategorien, `user_words`, `word_progress` oder
`user_word_srs` veraendert.

## Ergebnis

- Konfliktgruppen: 9
- Beteiligte Wort-IDs: 18
- Kontext-Zeilen: 18

## Konfliktgruppen

- `behind`: `3d018bfe-bd5d-4ba2-a448-6a92f54eb7bb` vs `857507cd-ca70-4a7d-bc5f-66dc09e7f648` (same_text_translation_lang)
- `dash`: `0a29d3d0-ad57-4c78-94b7-ad6d603915c0` vs `e09286d3-351c-4f04-a14a-b7d851c25713` (same_text_lang)
- `entire`: `37a99d9c-9192-44ce-83b9-08eee8bca169` vs `2a5d060a-cddf-4a67-8ce7-a21367c00fe1` (same_text_translation_lang)
- `incident`: `8b48b271-2a4e-472e-a0d1-99c142cdc1ab` vs `f054cac4-7825-4d46-975e-ca008040a3ee` (same_text_lang)
- `interview`: `1aff8ead-820c-447c-9dc9-fe5981d91412` vs `b07abd1a-d672-4f35-a12c-86c0ff47062d` (same_text_translation_lang)
- `move`: `0c165b4c-2afb-4861-ac60-75bf59a8611b` vs `ba6b854f-c6af-4751-b9e8-61d8374272a2` (same_text_lang)
- `report`: `31b9fd7e-fbbf-44fa-af67-40c66144f843` vs `70fbac34-dad7-4af5-986a-19942af4baf5` (same_text_lang)
- `satellite`: `32464b29-fec5-4fd3-ba25-a873e3b0f8eb` vs `e0d7acc3-7b01-48b4-a6e8-2f0cb06ad422` (same_text_lang)
- `throughout`: `6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f` vs `8aae50ac-dadb-49ad-8ce6-89f6c501ecac` (same_text_lang)

## Progress-/SRS-/User-Bezuege

- Keine sichtbaren Progress-/SRS-/User-Bezuege gefunden.

## Kategorien/Tags auf beiden Seiten

- `behind`
- `dash`
- `entire`
- `interview`
- `report`

## Einordnung

- Wirken wie exakte Dubletten: behind; entire; interview
- Wirken wie Bedeutungsvarianten: incident; move; throughout

## Tabellenzugriff

- user_words: read ok (0 rows visible).
- word_progress: read ok (0 rows visible).
- user_word_srs: read ok (0 rows visible).

## Entscheidungskriterien

- Wenn candidate und conflict exakt gleiche Uebersetzung und keine
  separaten Progress-Verweise haben: merge/archive pruefen.
- Wenn unterschiedliche Uebersetzung, aber gleiche Bedeutung:
  Uebersetzung zusammenfuehren pruefen.
- Wenn unterschiedliche Bedeutung: getrennt behalten pruefen.
- Wenn SRS/user_words an beiden haengen: keine automatische Loeschung.

Keine produktive Entscheidung wurde getroffen.
