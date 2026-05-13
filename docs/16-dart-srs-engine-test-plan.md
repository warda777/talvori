# 16 Dart SRS Engine Test Plan

Stand: 2026-05-13

## Ziel

Dieser Plan beschreibt die konkrete Teststruktur für die reine Dart-SRS-Engine Version 1. Es wird kein produktiver Dart-Code definiert oder geschrieben. Die Tests sollen zuerst die fachlichen Engine-Regeln aus `docs/14-final-engine-rules-v1.md` absichern und ohne Flutter, SQLite, Supabase, Repository oder UI laufen.

## Testdateien

Später sinnvolle Testdateien:

- `test/core/srs/stage_transition_service_test.dart`
- `test/core/srs/due_date_calculator_test.dart`
- `test/core/srs/requeue_service_test.dart`
- `test/core/srs/new_card_policy_service_test.dart`
- `test/core/srs/queue_builder_test.dart`
- `test/core/srs/srs_engine_test.dart`

Optionale spätere Hilfsdateien:

- `test/core/srs/srs_test_fixtures.dart`
- `test/core/srs/srs_test_clock.dart`

## Testdaten

Minimal benötigte Testdaten:

- `WordProgress` in S0, S1, S2, S3, S4, S5
- fixe aktuelle Zeit, z. B. `2026-05-13 10:00:00`
- `recentAnswers` mit weniger als 3 Fehlern in 10 Antworten
- `recentAnswers` mit genau 3 Fehlern in 10 Antworten
- `sameSessionWrongCount` 0, 1, 2, 3
- `dueReviewProgresses`
- `newProgresses`
- `notDueProgresses`
- `SessionConfig` mit `sessionSize = 20`
- `QueueBuildInput` für T-SRS, A-SRS und Hybrid
- `TrainingArea.all`, `TrainingArea.reviewOnly`, `TrainingArea.focused`

## Priorisierte Tests

### 1. Stage-Aufstieg

Testdatei:

- `test/core/srs/stage_transition_service_test.dart`

Testname:

- `s0_correct_moves_to_s1_and_resets_pass_count`

Ausgangszustand:

- `WordProgress` in S0
- `passCount = 0`
- `ReviewAnswer.correct`
- `LearningMode.adaptive`
- `TrainingArea.all`

Aktion:

- `applyStageTransition(...)`

Erwartetes Ergebnis:

- Stage wird S1
- `passCount = 0`
- `stageChanged = true`

Betroffene Regel aus `docs/14`:

- Aufstieg: S0 -> S1 nach 1 richtiger Antwort.

### 2. Stage-Aufstieg Mit Mehreren Richtigen Antworten

Testdatei:

- `test/core/srs/stage_transition_service_test.dart`

Testname:

- `s1_requires_two_correct_answers_before_moving_to_s2`

Ausgangszustand:

- `WordProgress` in S1 mit `passCount = 0`
- danach S1 mit `passCount = 1`
- `ReviewAnswer.correct`

Aktion:

- `applyStageTransition(...)` zweimal gedanklich getrennt testen

Erwartetes Ergebnis:

- erste richtige Antwort: bleibt S1, `passCount = 1`
- zweite richtige Antwort: S1 -> S2, `passCount = 0`

Betroffene Regel aus `docs/14`:

- S1 -> S2 nach 2 richtigen Antworten.

### 3. Rückfall

Testdatei:

- `test/core/srs/stage_transition_service_test.dart`

Testname:

- `s5_wrong_falls_back_to_s3`

Ausgangszustand:

- `WordProgress` in S5
- `passCount` beliebig
- `ReviewAnswer.wrong`

Aktion:

- `applyStageTransition(...)`

Erwartetes Ergebnis:

- Stage wird S3
- `passCount = 0`
- `wrongCount` steigt

Betroffene Regel aus `docs/14`:

- S5 falsch -> S3.
- S5 fällt nicht auf S0 zurück.

### 4. T-SRS-Intervalle

Testdatei:

- `test/core/srs/due_date_calculator_test.dart`

Testname:

- `time_mode_uses_fixed_v1_intervals`

Ausgangszustand:

- fixe aktuelle Zeit
- `LearningMode.time`
- Stages S1-S5

Aktion:

- `calculateNextDueAt(...)`

Erwartetes Ergebnis:

- S1 -> +1 Tag
- S2 -> +3 Tage
- S3 -> +7 Tage
- S4 -> +14 Tage
- S5 -> +30 Tage

Betroffene Regel aus `docs/14`:

- T-SRS Version-1-Intervalle.

### 5. A-SRS Ohne Zeitblockade

Testdatei:

- `test/core/srs/stage_transition_service_test.dart`

Testname:

- `adaptive_mode_can_advance_to_s5_on_same_day_when_thresholds_are_met`

Ausgangszustand:

- Folge von `WordProgress`-Zuständen derselben Karte
- `LearningMode.adaptive`
- `ReviewAnswer.correct`
- alle benötigten `passCount`-Schwellen werden erfüllt
- gleiche aktuelle Zeit für alle Reviews

Aktion:

- `applyStageTransition(...)` über die Stufen S0 -> S5

Erwartetes Ergebnis:

- keine zeitliche Sperre verhindert den Aufstieg
- Karte kann am selben Tag S5 erreichen
- S5 bleibt wiederholbar

Betroffene Regel aus `docs/14`:

- A-SRS hat kein Tageslimit und keine zeitliche Sperre.
- Karten dürfen bei ausreichender Leistung am selben Tag bis S5 aufsteigen.

### 6. Hybrid-Intervalle

Testdatei:

- `test/core/srs/due_date_calculator_test.dart`

Testname:

- `hybrid_mode_uses_short_v1_intervals_for_s3_to_s5`

Ausgangszustand:

- fixe aktuelle Zeit
- `LearningMode.hybrid`
- Stages S3, S4, S5

Aktion:

- `calculateNextDueAt(...)`

Erwartetes Ergebnis:

- S3 -> +1 Tag
- S4 -> +3 Tage
- S5 -> +5 Tage

Betroffene Regel aus `docs/14`:

- Hybrid Version-1-Regel: S3 1 Tag, S4 3 Tage, S5 5 Tage.

### 7. Fehlerquote-Regel

Testdatei:

- `test/core/srs/new_card_policy_service_test.dart`

Testname:

- `three_wrong_answers_in_last_ten_blocks_automatic_new_cards`

Ausgangszustand:

- `recentAnswers` mit genau 3 falschen Antworten innerhalb der letzten 10 Antworten
- verfügbare S0-Karten
- je ein Fall für `LearningMode.time`, `LearningMode.hybrid`, `LearningMode.adaptive`

Aktion:

- `shouldIntroduceNewCards(...)`

Erwartetes Ergebnis:

- T-SRS: neue S0-Karten werden für diese Session blockiert
- Hybrid: neue S0-Karten werden für diese Session blockiert
- A-SRS: automatischer Nachschub wird gestoppt, aber kein harter Lernblock

Betroffene Regel aus `docs/14`:

- Fehlerquote: 3 Fehler in 10 Antworten stoppen neue S0-Karten automatisch.
- Für A-SRS ist es keine harte Lernblockade.

### 8. Mehrfach-Requeue

Testdatei:

- `test/core/srs/requeue_service_test.dart`

Testname:

- `same_card_wrong_answers_use_10_then_5_then_difficult_end_queue`

Ausgangszustand:

- dieselbe Karte in derselben Session
- `sameSessionWrongCount` 0, 1, 2
- aktuelle Queue mit ausreichend anderen Karten

Aktion:

- `applyRequeue(...)`

Erwartetes Ergebnis:

- 1. Fehler: Requeue nach ca. 10 anderen Karten
- 2. Fehler: Requeue nach ca. 5 anderen Karten
- 3. Fehler: Status `difficult`, ans Ende der aktuellen Session-Queue
- Karte verschwindet nicht dauerhaft

Betroffene Regel aus `docs/14`:

- Mehrfach-Requeue 1/2/3.

### 9. A-SRS 2:1-Mischregel

Testdatei:

- `test/core/srs/queue_builder_test.dart`

Testname:

- `adaptive_queue_mixes_two_reviews_then_one_new_card`

Ausgangszustand:

- `LearningMode.adaptive`
- `TrainingArea.all`
- `sessionSize = 20`
- genügend aktive Wiederholungskarten
- genügend neue S0-Karten

Aktion:

- `buildSessionQueue(...)`

Erwartetes Ergebnis:

- Muster: zwei aktive Wiederholungskarten, dann eine neue S0-Karte
- Queue bleibt maximal 20 Karten
- keine automatische Erweiterung

Betroffene Regel aus `docs/14`:

- A-SRS 2:1-Mischregel.
- Sessiongröße 20.

### 10. Sessiongröße 20

Testdatei:

- `test/core/srs/queue_builder_test.dart`

Testname:

- `all_modes_build_queue_with_v1_session_size_twenty`

Ausgangszustand:

- viele verfügbare Karten
- je ein Fall für T-SRS, A-SRS, Hybrid
- `SessionConfig.sessionSize = 20`

Aktion:

- `buildSessionQueue(...)`

Erwartetes Ergebnis:

- Queue enthält maximal 20 Karten
- T-SRS enthält maximal 5 neue S0-Karten
- Hybrid enthält maximal 8 neue S0-Karten
- A-SRS enthält maximal 20 S0-Karten, wenn keine aktiven Wiederholungen vorhanden sind

Betroffene Regel aus `docs/14`:

- Standard-Sessiongröße 20.
- Neue Karten pro Session.

### 11. Gezielt Üben Ohne Progression

Testdatei:

- `test/core/srs/stage_transition_service_test.dart`

Testname:

- `focused_training_does_not_change_srs_progress`

Ausgangszustand:

- `TrainingArea.focused`
- Karte in S2 oder S5
- Antwort richtig oder falsch

Aktion:

- `reviewCard(...)` oder `applyStageTransition(...)`

Erwartetes Ergebnis:

- `stage` unverändert
- `passCount` unverändert
- `nextDueAt` unverändert
- S5-Status unverändert

Betroffene Regel aus `docs/14`:

- Gezielt üben verändert in Version 1 nicht die normale SRS-Progression.

## Reine Unit-Tests

Diese Tests sollen reine Unit-Tests ohne Flutter, SQLite, Repository und Dateisystem sein:

- Stage-Aufstieg
- Rückfall
- T-SRS-Intervalle
- A-SRS ohne Zeitblockade
- Hybrid-Intervalle
- Fehlerquote-Regel
- Mehrfach-Requeue
- A-SRS 2:1-Mischregel
- Sessiongröße 20
- Gezielt üben ohne Progression
- `isMasteredDisplayOnly` beeinflusst Queue und Due nicht
- `reviewOnly` führt keine neuen S0-Karten ein

## Spätere Repository-/SQLite-Tests

Diese Tests gehören nicht in die reine Engine-Testschicht:

- `word_progress` wird nach `ReviewResult` korrekt gespeichert
- `review_history` wird atomar mit Progress-Update gespeichert
- `learning_sessions` verhindert doppelte aktive Sessions
- `session_items` speichert Queue-Positionen stabil
- App-Neustart lädt aktive Session statt neuer Queue
- Requeue-Positionen bleiben nach Neustart erhalten
- SQLite speichert `mode`-Werte `time`, `adaptive`, `hybrid` korrekt
- Migration oder Seed-Daten laden Wörter/Kategorien korrekt

## Bewusst Noch Nicht Schreiben

Diese Tests werden für Version 1 bewusst zurückgestellt:

- Supabase-Migration
- DeepL/Wortimport
- Online-Sync
- UI-Widget-Tests für Modusbuttons
- Navigationstests
- Tests für Nutzerwahl 10/20/40
- Tests für feinere A-SRS-Mischgewichte
- Tests für nicht-binäre Antwortqualitäten
- Tests für komplexe Ease-Factor-Algorithmen
- Tests für KI-gestützte Wiederholungsoptimierung

## Testreihenfolge

Empfohlene Reihenfolge:

1. `stage_transition_service_test.dart`
2. `due_date_calculator_test.dart`
3. `requeue_service_test.dart`
4. `new_card_policy_service_test.dart`
5. `queue_builder_test.dart`
6. `srs_engine_test.dart`

Erst wenn diese reinen Engine-Tests grün geplant und später implementiert sind, sollten Repository-/SQLite-Tests folgen.

