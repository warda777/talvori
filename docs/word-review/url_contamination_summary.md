# URL Contamination Summary

Stand: 2026-05-24T14:50:02.789453

Dieser Schritt ist read-only. Es wurden keine Supabase-Daten,
Woerter, Kategorien oder SRS-Fortschritte veraendert.

## Ergebnis

- Betroffene Woerter: 8

## Issue-Typen

- `translation_longer_than_80`: 8

## Beispiele

- `d032e036-261a-400a-8e69-ae677987c97c`: cleave (split) – cleft/clove/cleaved – cleft/cloven/cleaved / spalten (spalten) - gespalten/gespalten/gespalten - gespalten/gespalten/gespalten
  - Issues: translation_longer_than_80
- `4fd74a05-a38a-40f4-9707-03c70904f654`: Do you mind if I approve the request, when you have a moment? / Haben Sie etwas dagegen, wenn ich die Anfrage genehmige, wenn Sie einen Moment Zeit haben?
  - Issues: translation_longer_than_80
- `c33ae598-da01-480a-80f5-04e1394009e2`: Do you mind if I confirm the booking, when you have a moment? / Haben Sie etwas dagegen, wenn ich die Buchung bestätige, wenn Sie einen Moment Zeit haben?
  - Issues: translation_longer_than_80
- `1c9bd500-ac22-48bf-841e-b8c49e5c045f`: Do you mind if I move the meeting, asap? / Macht es Ihnen etwas aus, wenn ich das Treffen so schnell wie möglich verschiebe?
  - Issues: translation_longer_than_80
- `f0fc7093-e649-433b-8743-fa964fec1fa5`: Do you mind if I move the meeting, when you have a moment? / Haben Sie etwas dagegen, wenn ich die Sitzung verschiebe, wenn Sie einen Moment Zeit ha...
  - Issues: translation_longer_than_80
- `0e3d7060-6c97-4c42-bacc-3245f01621bd`: Do you mind if I slow things down, when you have a moment? / Haben Sie etwas dagegen, wenn ich das Tempo drossle, wenn Sie einen Moment Zeit haben?
  - Issues: translation_longer_than_80
- `bd57695a-5198-4711-9d96-12b2473a53c6`: Do you mind if I speed things up, when you have a moment? / Haben Sie etwas dagegen, wenn ich die Dinge beschleunige, wenn Sie einen Moment Zeit ha...
  - Issues: translation_longer_than_80
- `d73b7180-c201-49af-94b4-cd98fa3e7a2c`: misspell – misspelled/misspelt – misspelled/misspelt / falsch geschrieben - falsch geschrieben/falsch geschrieben - falsch geschrieben/falsch ...
  - Issues: translation_longer_than_80

## Empfehlung

1. Die Review-Datei `url_contaminated_words_review.csv` manuell
   pruefen.
2. Bei sicheren Faellen `decision` und `notes` ausfuellen.
3. Erst danach ein separates, dry-run-first Update-Skript
   vorbereiten.
4. Sprachcode-Normalisierung erst nach dieser Pruefung produktiv
   ausfuehren, damit verunreinigte Begriffe nicht still
   normalisiert werden.
