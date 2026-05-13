# 11 Mode Specific Progress

Stand: 2026-05-13

## Ziel

Eine Kategorie muss in verschiedenen Lernmodi unabhängig gespielt werden können. Dasselbe Wort in derselben Kategorie kann je Modus einen anderen Fortschritt haben.

Pflichtschlüssel:

`category_id + word_id + mode_id = eigener Fortschritt`

Mit lokalem Profil:

`profile_id + category_id + word_id + mode_id`

## Warum getrennt?

Beispiel:

- In **Nach Zeitplan** ist ein Wort S4.
- In **Intensiv lernen** wurde es erst aktiv geübt und ist S2.
- In **Ausgewogen lernen** ist es S3.

Diese Zustände dürfen sich nicht gegenseitig überschreiben.

## Benötigte Felder pro Fortschritt

Tabelle `word_progress`:

- `profile_id`
- `category_id`
- `word_id`
- `mode_id`
- `stage`
- `pass_count`
- `correct_in_stage`
- `wrong_in_stage`
- `total_correct`
- `total_wrong`
- `lapses`
- `ever_introduced`
- `introduced_at`
- `last_reviewed_at`
- `next_due_at`
- `s5_reached_at`
- `reactivated_at`
- `updated_at`

Optional:

- `is_mastered` nur als Anzeige-/Statistikfeld, niemals als Engine-Ausschluss
- `mastered_at` nur als optionale Statistik

## Gehören Trainingsbereiche in den Fortschrittsschlüssel?

Trainingsbereiche:

- Alles lernen
- Nur wiederholen
- Gezielt üben

Empfehlung:

- Trainingsbereich gehört **nicht** in den Fortschrittsschlüssel.
- Er ist ein Session-Filter bzw. Session-Typ.
- Der Fortschritt bleibt pro Modus eindeutig.

Begründung:

- `Alles lernen` und `Nur wiederholen` sollen denselben Modusfortschritt bearbeiten.
- Sonst würden Fortschritte fragmentieren.
- Nutzer erwarten, dass Wiederholen denselben Lernstand stärkt.

Entscheidung für Version 1:

- `Gezielt üben` verändert keinen normalen SRS-Fortschritt.
- Antworten in `Gezielt üben` ändern nicht `stage`, `pass_count`, `next_due_at` oder S5-Status.
- Optionale Übungsstatistiken dürfen später getrennt gespeichert werden.

## Session-Schlüssel

Für aktive Sessions gehört der Trainingsbereich in den Schlüssel:

`profile_id + category_id + mode_id + training_area_id`

Warum:

- Eine aktive "Alles lernen"-Session ist anders als "Gezielt üben".
- Pro Bereich darf nur eine aktive Session existieren.
- Fortschritt bleibt trotzdem beim Modus.

## Review-Events

Review-Events sollten `training_area_id` speichern, damit später nachvollziehbar bleibt, wo die Antwort passiert ist.

Der Fortschritt wird aber über `mode_id` aktualisiert.

## Offene Entscheidungen

- [ENTSCHEIDUNG NOTWENDIG] Manuelle Reaktivierung von S5: `next_due_at = now` oder Rückstufung?
- [ENTSCHEIDUNG NOTWENDIG] Soll ein Wort, das in einer Kategorie gelernt wurde, Fortschritt in anderer Kategorie teilen? Empfehlung: nein, Fortschritt bleibt kategoriebasiert.
