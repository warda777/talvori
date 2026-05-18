# Lokale SRS-Engine: verifizierter Stand

## 1. Ausgangslage

Die SRS-Engine ist der fachliche Kern der App. Ziel der letzten Engine-Blöcke war, die drei Lernmodi Zeitplan, Limitlos und Kombination nicht nur punktuell, sondern end-to-end über Engine, Session, Persistenz, Controller/ViewModel und LearnMode-UI abzusichern.

Grundlage waren insbesondere:

- `docs/10-session-and-queue-rules.md`
- `docs/11-mode-specific-progress.md`
- `docs/14-final-engine-rules-v1.md`

## 2. Modi

- Zeitplan = T-SRS / `time`
- Limitlos = A-SRS / `adaptive`
- Kombination = Hybrid / `hybrid`

## 3. Progress-Key

Lokaler Fortschritt ist pro Modus getrennt:

```text
category_id + word_id + mode_id
```

Der Trainingsbereich gehoert nicht in den Progress-Key. Er ist Session-Kontext und gehoert in den Session-Key:

```text
category_id + mode_id + training_area_id
```

Damit koennen Zeitplan, Limitlos und Kombination unterschiedliche Fortschrittsstaende fuer dasselbe Wort haben. Updates in einem Modus ueberschreiben keinen anderen Modus.

## 4. Stage-Regeln

Stufen:

- S0: neu
- S1: begonnen
- S2: im Aufbau
- S3: gefestigt
- S4: sicher
- S5: Langzeit

Aufstieg bei richtigen Antworten:

- S0 -> S1 nach 1 richtiger Antwort
- S1 -> S2 nach 2 richtigen Antworten
- S2 -> S3 nach 2 richtigen Antworten
- S3 -> S4 nach 3 richtigen Antworten
- S4 -> S5 nach 3 richtigen Antworten

Bei Aufstieg wird `pass_count` fuer die neue Stufe zurueckgesetzt.

Rueckfall bei falscher Antwort:

- S0 falsch -> S0
- S1 falsch -> S1
- S2 falsch -> S1
- S3 falsch -> S2
- S4 falsch -> S3
- S5 falsch -> S3

S5 bleibt wiederholbar. `is_mastered` ist kein Engine-Ausschluss und darf Karten nicht aus Queue, Faelligkeit oder Engine entfernen.

## 5. Zeitplan

Zeitplan ist zeitbasiert.

Intervalle:

- S1: 1 Tag
- S2: 3 Tage
- S3: 7 Tage
- S4: 14 Tage
- S5: 30 Tage

Same-Day-Regel: S1 darf am selben Tag erneut gezeigt werden, steigt bei einer weiteren richtigen Antwort am selben Tag aber nicht nach S2 auf. Erst ab dem Folgetag kann S1 nach S2 steigen.

Neue Karten:

- Erste neue Kategorie ohne Fortschritt: bis zu 20 neue S0-Karten.
- Danach: maximal 5 neue S0-Karten pro Session.
- Fällige Wiederholungen haben Vorrang vor neuen Karten.

## 6. Limitlos

Limitlos hat keine Zeitblockade fuer Stufenaufstieg. Karten koennen bei ausreichenden richtigen Antworten am selben Tag bis S5 steigen.

Regeln:

- Sessiongroesse bleibt 20 Startkarten.
- Kein unkontrollierter Endlos-Refill.
- Bei aktiven Wiederholungen gilt die 2:1-Mischregel: zwei Wiederholungen, dann eine neue S0-Karte.
- Wenn Wiederholungen fehlen, duerfen freie Plaetze mit neuen S0-Karten gefuellt werden.
- Weiterlernen oder eine neue Session ist eine bewusste Nutzerentscheidung.

## 7. Kombination

Kombination verbindet freie fruehe Stufen mit zeitbasierten hoeheren Stufen.

- S0-S2 verhalten sich wie Limitlos.
- Ab S3 greift Zeitlogik.

Intervalle:

- S3: 1 Tag
- S4: 3 Tage
- S5: 5 Tage

Kombination fuehrt maximal 8 neue S0-Karten pro Session ein. S5 bleibt wiederholbar.

## 8. Requeue und Fehler

Bei falscher Antwort:

- `wrong_count` steigt.
- `pass_count` wird auf 0 gesetzt.
- Die Karte wird erneut in die Session eingereiht.

Requeue:

- erster Fehler: Retry nach ca. 10 anderen Karten
- zweiter Fehler: Retry nach ca. 5 anderen Karten
- dritter Fehler: `difficult` / ans Ende

`difficult` bleibt offen und zaehlt als remaining. Eine falsch beantwortete Karte verschwindet nicht dauerhaft. Es gibt keine aktiven Duplikate desselben Wortes in derselben Session.

Fehlerquote:

- 3 Fehler innerhalb der letzten 10 Antworten stoppen neue S0-Karten.
- Aktive Wiederholungen laufen weiter.
- Bei Limitlos bedeutet das keinen harten Lernstopp, sondern keinen automatischen Nachschub.

## 9. Session-Manipulationsschutz

Es gibt maximal eine aktive Session pro:

```text
category_id + mode_id + training_area_id
```

Wenn eine aktive Session existiert, wird sie fortgesetzt. Sie wird nicht durch App-Neustart, Repository-Neuladen oder erneutes Oeffnen ersetzt.

Abgesichert ist:

- Queue wird nicht neu gewuerfelt.
- `current_position` bleibt erhalten.
- Retry-/Requeue-Items bleiben erhalten.
- Fehlerzustand geht nicht verloren.
- File-DB-Reopen bleibt stabil.
- Normales Resume resetet keinen Progress.

## 10. Completed / Reset

Ein abgeschlossener Zustand bleibt sichtbar. Es gibt keinen automatischen Neustart.

`Neue Session starten` nutzt den expliziten `resetAndStart`-Pfad:

- Progress der Kategorie im Modus wird auf S0 gesetzt.
- `pass_count`, `wrong_count`, `next_due_at` und `last_reviewed_at` werden passend zurueckgesetzt.
- Danach entsteht eine neue aktive Session.
- Die lokale LearnMode-UI zeigt wieder eine Karte.

## 11. Tests

Wichtige Testdateien:

- `test/core/srs/srs_mode_scenario_test.dart`
- `test/core/local_database/local_srs_mode_scenario_test.dart`
- `test/core/local_database/local_srs_persistence_file_test.dart`
- `test/core/local_database/local_learning_controller_persistence_test.dart`
- `test/features/learn_mode_screen_local_branch_test.dart`
- `test/core/local_database/local_srs_session_service_test.dart`
- `test/core/local_database/srs_review_persistence_service_test.dart`
- `test/core/local_database/word_progress_repository_test.dart`
- `test/core/local_database/learning_session_repository_test.dart`
- `test/core/local_database/local_learning_session_facade_test.dart`

## 12. Bekannte offene Punkte

- `profile_id` ist lokal noch nicht vollstaendig eingefuehrt.
- Weitere Kategorien und Importe muessen spaeter folgen.
- Gezielt ueben ist Progress-neutral, muss UI-/Flow-seitig spaeter weiter ausgestaltet werden.
- Analyzer-Alt-Warnungen in alten UI-Dateien bleiben ein separates Cleanup-Thema.

## 13. Naechster sinnvoller Schritt

Moegliche naechste Schritte:

- SRS-Engine vorerst nicht weiter anfassen und Feature-Arbeit fortsetzen.
- `profile_id` / Multi-Profile gezielt vorbereiten.
- Weitere Kategorieimporte und Mappings ausbauen.
