# 17 Dart SRS Engine Implementation Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den aktuellen Stand der fertiggestellten reinen Dart-SRS-Engine-Schicht zusammen. Es beschreibt nur die isolierte Engine unter `lib/core/srs/` und die zugehörigen Tests unter `test/core/srs/`.

Die bestehende App, UI, Supabase-Anbindung, SQLite-/Repository-Schicht und App-Flows wurden dabei nicht angebunden oder verändert.

## Erstellte Engine-Bausteine

### Einstiegspunkt

Der zentrale Einstiegspunkt ist:

- `lib/core/srs/services/srs_engine.dart`

`SrsEngine` ist eine minimale Fassade. Sie speichert nichts selbst und delegiert an die spezialisierten Services.

### Services

Erstellt wurden:

- `StageTransitionService`
  - entscheidet Aufstieg, Rückfall und `passCount`
- `DueDateCalculator`
  - berechnet `nextDueAt` je Modus und Stage
- `RequeueService`
  - entscheidet Requeue nach falschen Antworten
- `NewCardPolicyService`
  - entscheidet, ob neue S0-Karten automatisch eingeführt werden dürfen
- `QueueBuilder`
  - baut eine endliche Session-Queue
- `SrsEngine`
  - koordiniert Review-Entscheidung und Queue-Aufbau

### Modelle und Enums

Erstellt wurden unter anderem:

- `SrsStage`
- `LearningMode`
- `TrainingArea`
- `ReviewAnswer`
- `WordProgress`
- `StageTransitionResult`
- `RequeueDecision`
- `RequeueReason`
- `NewCardPolicy`
- `NewCardPolicyResult`
- `SessionConfig`
- `QueueBuildInput`
- `QueueBuildResult`
- `SessionItem`
- `QueueItemStatus`
- `SessionContext`
- `ReviewInput`
- `ReviewResult`

## Bereits Implementierte Regeln Aus docs/14

Implementiert sind:

- S0 bis S5 als aktive SRS-Stufen
- `isMastered` wird nicht für Engine-Entscheidungen verwendet
- Aufstieg:
  - S0 -> S1 nach 1 richtiger Antwort
  - S1 -> S2 nach 2 richtigen Antworten
  - S2 -> S3 nach 2 richtigen Antworten
  - S3 -> S4 nach 3 richtigen Antworten
  - S4 -> S5 nach 3 richtigen Antworten
- `passCount` wird bei Aufstieg zurückgesetzt
- falsche Antworten setzen `passCount` zurück
- Rückfall:
  - S0 falsch -> S0
  - S1 falsch -> S1
  - S2 falsch -> S1
  - S3 falsch -> S2
  - S4 falsch -> S3
  - S5 falsch -> S3
- T-SRS-Intervalle:
  - S1 1 Tag, S2 3 Tage, S3 7 Tage, S4 14 Tage, S5 30 Tage
- Hybrid-Intervalle:
  - S0-S2 ohne harte Zeitblockade
  - S3 1 Tag, S4 3 Tage, S5 5 Tage
- A-SRS ohne harte Zeitblockade
- S5 bleibt wiederholbar und bekommt weiterhin ein `nextDueAt`
- Mehrfach-Requeue:
  - 1. Fehler: nach ca. 10 Karten
  - 2. Fehler: nach ca. 5 Karten
  - 3. Fehler: schwierig markieren und ans Queue-Ende
- kurze Queue führt zum Queue-Ende, aber die Karte verschwindet nicht
- neue Karten:
  - `reviewOnly` blockiert neue S0-Karten
  - `focused` blockiert neue S0-Karten für normale Progression
  - T-SRS maximal 5 neue S0-Karten
  - Hybrid maximal 8 neue S0-Karten
  - A-SRS maximal technische Sessiongröße 20
- Fehlerquote:
  - 3 Fehler in den letzten 10 Antworten blockieren neue S0-Karten in T-SRS und Hybrid
  - A-SRS stoppt dabei automatischen Nachschub, aber keinen Lernblock
- Session-Queue:
  - V1-Standardgröße 20
  - Queue wird nicht automatisch über 20 erweitert
  - Wiederholungen haben in T-SRS und Hybrid Vorrang
  - A-SRS kann ohne Wiederholungen bis zu 20 neue S0-Karten enthalten
  - A-SRS nutzt bei Wiederholungen die 2:1-Mischregel
  - A-SRS füllt freie Plätze mit neuen Karten, wenn Wiederholungen nicht ausreichen
- `focused` verändert keine normale SRS-Progression

## Vorhandene Tests

### `stage_transition_service_test.dart`

Sichert ab:

- Stage-Aufstieg von S0 bis S5
- notwendige richtige Antworten je Stufe
- Rückfall bei falschen Antworten
- `passCount`-Reset
- `focused` ohne Progression
- `isMastered` ohne Engine-Wirkung

### `due_date_calculator_test.dart`

Sichert ab:

- feste T-SRS-Intervalle
- kurze Hybrid-Intervalle für S3-S5
- A-SRS ohne Zeitblockade
- S5 mit weiterem `nextDueAt`

### `requeue_service_test.dart`

Sichert ab:

- 1. Fehler nach 10 Karten
- 2. Fehler nach 5 Karten
- 3. Fehler als schwierig ans Queue-Ende
- kurze Queue ohne dauerhaftes Entfernen

### `new_card_policy_service_test.dart`

Sichert ab:

- `reviewOnly` blockiert neue Karten
- `focused` blockiert neue Karten für normale Progression
- T-SRS max. 5 neue Karten
- Hybrid max. 8 neue Karten
- A-SRS max. 20 neue Karten innerhalb der Session
- Fehlerquote-Regel
- freie Sessionplätze als harte Obergrenze

### `queue_builder_test.dart`

Sichert ab:

- Queue maximal 20 Karten
- `reviewOnly` ohne neue S0-Karten
- T-SRS und Hybrid mit Moduslimits
- A-SRS ohne Reviews mit bis zu 20 neuen Karten
- A-SRS 2:1-Mischregel
- A-SRS-Auffüllen bei zu wenigen Reviews
- Fehlerquote blockiert neue Karten, lässt Reviews aber bestehen

### `srs_engine_test.dart`

Sichert ab:

- `reviewCard(...)` koordiniert Stage-Transition und Due-Date
- falsche Antwort koordiniert Stage-Transition und Requeue
- `focused` bleibt ohne Progression
- `buildSessionQueue(...)` delegiert an `QueueBuilder`
- Engine braucht keine SQLite- oder Repository-Abhängigkeit

## Weiterhin Geltende Grenzen

Die reine Dart-SRS-Engine hat weiterhin keine:

- SQLite-Abhängigkeit
- UI-Abhängigkeit
- Supabase-Abhängigkeit
- Repository-Logik
- Flutter-Widget-Abhängigkeit
- Navigation
- Persistenzlogik
- App-Flow-Logik

Die Engine nimmt fertige Datenmodelle entgegen und gibt Entscheidungen zurück. Speichern, Laden, Session-Fortsetzung und Datenmigration bleiben außerhalb dieser Schicht.

## Noch Nicht Umgesetzt

Noch nicht umgesetzt sind:

- SQLite-Repository
- SQLite-Tabellen und Migrationen
- Session-Persistenz
- Wiederaufnahme aktiver Sessions nach App-Neustart
- atomare Speicherung von Progress, Review-History und Session-Items
- App-Anbindung an die neue Engine
- Supabase-Entfernung
- Datenmigration von Supabase zu lokalem Speicher
- UI-Buttons für die neuen Modi
- UI-Umbenennung der Modi und Trainingsbereiche
- Integration in bestehende ViewModels
- vollständiger `flutter analyze`-Durchlauf für die gesamte App nach App-Anbindung

## Sinnvolle Nächste Schritte

1. Engine-API kurz prüfen
   - Stimmen Namen, Modellgrenzen und Rückgabewerte für die spätere Repository-Anbindung?

2. SQLite-Repository separat planen und testgetrieben vorbereiten
   - `word_progress`
   - `review_history`
   - `learning_sessions`
   - `session_items`

3. Session-Persistenz entwerfen
   - aktive Session pro Kategorie, Modus und Trainingsbereich
   - gespeicherte Queue-Positionen
   - Requeue-Zustand nach App-Neustart

4. Repository-Tests schreiben
   - Speichern von `ReviewResult`
   - Speichern von `QueueBuildResult`
   - Wiederladen aktiver Sessions

5. Bestehende App-Anbindung erst danach beginnen
   - ViewModels gezielt verbinden
   - UI-Begriffe anpassen
   - Supabase erst entfernen, wenn lokale Engine und Repository stabil sind

## Kurzfazit

Die reine Dart-SRS-Engine-Schicht ist als isolierte, getestete Logikschicht vorhanden. Sie ist bereit als Grundlage fuer den naechsten Schritt: eine lokale SQLite-/Repository-Schicht, die Engine-Entscheidungen speichert und aktive Sessions stabil fortsetzt.
