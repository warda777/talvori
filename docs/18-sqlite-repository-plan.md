# 18 SQLite Repository Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant die lokale SQLite-/Repository-Schicht fuer die bestehende Talvori-App. Es beschreibt keine Implementierung und keinen Dart-Code.

Die bestehende Supabase-Anbindung bleibt vorerst bestehen. Ziel ist ein sicherer, schrittweiser Weg zu einer lokalen Offline-first-Datenbasis, die die reine Dart-SRS-Engine unter `lib/core/srs/` mit Daten versorgt und Engine-Ergebnisse dauerhaft speichert.

## Grundgrenzen

- Die SRS-Engine bleibt frei von SQLite, Supabase, UI und Repository-Logik.
- Die Repository-Schicht speichert und laedt Daten.
- Die Repository-Schicht baut aus SQLite-Daten fertige Engine-Inputs.
- Die Repository-Schicht speichert Engine-Outputs atomar.
- Supabase wird erst entfernt, wenn lokale Tabellen, Repositorys und Tests stabil sind.

## SQLite-Tabellen Fuer Version 1

Version 1 benoetigt mindestens:

- `categories`
- `words`
- `word_progress`
- `review_history`
- `learning_sessions`
- `session_items`
- `settings`

## Tabellen Und Felder

### categories

Speichert Vokabel-Kategorien oder Lektionen.

Felder:

- `id` TEXT PRIMARY KEY
- `name` TEXT NOT NULL
- `description` TEXT NULL
- `sort_order` INTEGER NOT NULL DEFAULT 0
- `is_archived` INTEGER NOT NULL DEFAULT 0
- `created_at` TEXT NOT NULL
- `updated_at` TEXT NOT NULL

Optional spaeter:

- `source_language` TEXT NULL
- `target_language` TEXT NULL
- `icon_name` TEXT NULL
- `color_value` TEXT NULL
- `legacy_supabase_id` TEXT NULL

Entscheidung fuer Version 1:

- Kategorien verwenden lokale UUIDs.
- Bestehende Supabase-IDs werden nicht als Hauptstrategie uebernommen.
- Falls spaeter Migration noetig ist, kann optional `legacy_supabase_id` ergaenzt werden.
- Supabase-ID-Migration blockiert die erste lokale Engine nicht.

### words

Speichert die eigentlichen Vokabeln.

Felder:

- `id` TEXT PRIMARY KEY
- `category_id` TEXT NOT NULL
- `term` TEXT NOT NULL
- `translation` TEXT NOT NULL
- `example_sentence` TEXT NULL
- `notes` TEXT NULL
- `sort_order` INTEGER NOT NULL DEFAULT 0
- `is_archived` INTEGER NOT NULL DEFAULT 0
- `created_at` TEXT NOT NULL
- `updated_at` TEXT NOT NULL

Indizes:

- Index auf `category_id`

Version-1-Entscheidung:

- Es gibt keinen eindeutigen Index auf `category_id, term, translation`.
- Duplikate werden bewusst erlaubt, weil gleiche Begriffe in unterschiedlichen Kontexten, Lektionen oder Bedeutungen vorkommen koennen.

Beziehungen:

- `category_id` verweist auf `categories.id`

Entscheidung fuer Version 1:

- Es werden nur die oben gelisteten notwendigen Wortfelder verwendet.
- Audio, Artikel, Wortart, DeepL-Metadaten und weitere Zusatzfelder werden zurueckgestellt.
- Falls spaeter Migration noetig ist, kann optional `legacy_supabase_id` ergaenzt werden.

### word_progress

Speichert SRS-Fortschritt pro Wort, Kategorie und Modus getrennt.

Felder:

- `id` TEXT PRIMARY KEY
- `word_id` TEXT NOT NULL
- `category_id` TEXT NOT NULL
- `mode_id` TEXT NOT NULL
- `stage` TEXT NOT NULL
- `pass_count` INTEGER NOT NULL DEFAULT 0
- `wrong_count` INTEGER NOT NULL DEFAULT 0
- `next_due_at` TEXT NULL
- `last_reviewed_at` TEXT NULL
- `created_at` TEXT NOT NULL
- `updated_at` TEXT NOT NULL

Eindeutigkeit:

- UNIQUE `word_id, category_id, mode_id`

Indizes:

- Index auf `category_id, mode_id, next_due_at`
- Index auf `word_id`
- Index auf `stage`

Beziehungen:

- `word_id` verweist auf `words.id`
- `category_id` verweist auf `categories.id`

Regeln:

- `mode_id` speichert stabile Werte: `time`, `adaptive`, `hybrid`.
- `stage` speichert stabile Werte: `s0`, `s1`, `s2`, `s3`, `s4`, `s5`.
- `is_mastered` wird fuer Version 1 nicht als Engine-Zustand benoetigt.
- `wrong_count` bleibt kumulativ pro Wort, Kategorie und Modus.
- Session-spezifische Fehlerzaehler werden in `session_items.same_session_wrong_count` gespeichert.

### review_history

Speichert jede beantwortete Karte als unveraenderliches Ereignis.

Felder:

- `id` TEXT PRIMARY KEY
- `word_id` TEXT NOT NULL
- `category_id` TEXT NOT NULL
- `mode_id` TEXT NOT NULL
- `training_area_id` TEXT NOT NULL
- `session_id` TEXT NULL
- `answer` TEXT NOT NULL
- `reviewed_at` TEXT NOT NULL
- `old_stage` TEXT NOT NULL
- `new_stage` TEXT NOT NULL
- `old_pass_count` INTEGER NOT NULL
- `new_pass_count` INTEGER NOT NULL
- `old_next_due_at` TEXT NULL
- `new_next_due_at` TEXT NULL
- `requeue_reason` TEXT NULL
- `created_at` TEXT NOT NULL

Indizes:

- Index auf `word_id`
- Index auf `category_id, mode_id, reviewed_at`
- Index auf `session_id`

Regeln:

- Review-History wird nicht nachtraeglich veraendert.
- Sie dient Statistik, Debugging und spaeterer Auswertung.
- `focused`/Gezielt-ueben-Antworten duerfen in `review_history` gespeichert werden.
- `focused` veraendert trotzdem keinen normalen SRS-Fortschritt:
  - kein Stage-Wechsel
  - keine `pass_count`-Aenderung
  - keine `next_due_at`-Aenderung
  - kein S5-Statuswechsel

### learning_sessions

Speichert aktive und abgeschlossene Sessions.

Felder:

- `id` TEXT PRIMARY KEY
- `category_id` TEXT NOT NULL
- `mode_id` TEXT NOT NULL
- `training_area_id` TEXT NOT NULL
- `status` TEXT NOT NULL
- `session_size` INTEGER NOT NULL
- `current_position` INTEGER NOT NULL DEFAULT 0
- `started_at` TEXT NOT NULL
- `last_activity_at` TEXT NOT NULL
- `completed_at` TEXT NULL
- `created_at` TEXT NOT NULL
- `updated_at` TEXT NOT NULL

Moegliche `status`-Werte:

- `active`
- `completed`

Version-1-Entscheidung:

- `abandoned` wird nicht verwendet.
- Es gibt nur `active` und `completed`, damit Sessions nicht durch Abbruch manipulierbar werden.

Indizes:

- Index auf `category_id, mode_id, training_area_id, status`
- Index auf `last_activity_at`

Eindeutigkeit:

- Es darf pro `category_id, mode_id, training_area_id` nur eine aktive Session geben.
- SQLite kann das ueber einen partiellen Unique-Index absichern:
  - UNIQUE `category_id, mode_id, training_area_id` WHERE `status = active`

### session_items

Speichert die konkrete Reihenfolge und den Zustand der Karten innerhalb einer Session.

Felder:

- `id` TEXT PRIMARY KEY
- `session_id` TEXT NOT NULL
- `word_id` TEXT NOT NULL
- `category_id` TEXT NOT NULL
- `mode_id` TEXT NOT NULL
- `stage_at_enqueue` TEXT NOT NULL
- `position` INTEGER NOT NULL
- `status` TEXT NOT NULL
- `is_new_card` INTEGER NOT NULL DEFAULT 0
- `due_at_enqueue` TEXT NULL
- `retry_after_position` INTEGER NULL
- `requeue_reason` TEXT NULL
- `same_session_wrong_count` INTEGER NOT NULL DEFAULT 0
- `shown_at` TEXT NULL
- `answered_at` TEXT NULL
- `created_at` TEXT NOT NULL
- `updated_at` TEXT NOT NULL

Moegliche `status`-Werte:

- `queued`
- `shown`
- `answered`
- `retryPending`
- `done`
- `difficult`

Indizes:

- Index auf `session_id, position`
- Index auf `session_id, status`
- Index auf `session_id, word_id`

Eindeutigkeit:

- UNIQUE `session_id, position`

Regeln:

- Die Queue-Reihenfolge wird beim Session-Start gespeichert.
- Requeue wird als neues `session_item` gespeichert.
- Das urspruengliche `session_item` bleibt `answered`.
- Dadurch bleibt der Verlauf nachvollziehbar.
- App-Neustart darf nicht zu einer neuen Queue fuehren, solange eine aktive Session existiert.
- Fehler und Queue-Reihenfolge duerfen durch App-Abbruch nicht zurueckgesetzt werden.

### settings

Speichert lokale App- und Lern-Einstellungen.

Felder:

- `key` TEXT PRIMARY KEY
- `value` TEXT NOT NULL
- `value_type` TEXT NOT NULL
- `updated_at` TEXT NOT NULL

Moegliche Settings fuer Version 1:

- `default_session_size` = `20`
- `schema_version`
- `last_local_backup_at` spaeter optional als Post-Launch-Thema

Version-1-Entscheidung:

- Eine einfache Key-Value-Tabelle reicht fuer Version 1.
- Eine typisierte Settings-Struktur wird zurueckgestellt.

## Repository-Klassen

### CategoryRepository

Aufgaben:

- Kategorien laden
- Kategorie nach ID laden
- Kategorien sortieren
- Kategorien archivieren oder wiederherstellen
- spaeter Kategorien lokal anlegen und bearbeiten

Liefert an App/ViewModel:

- Kategorie-Listen
- Kategorie-Metadaten

### WordRepository

Aufgaben:

- Woerter pro Kategorie laden
- Wort nach ID laden
- neue Woerter lokal speichern
- Woerter aktualisieren oder archivieren
- S0-Startdaten fuer neue `word_progress`-Eintraege bereitstellen

Liefert an Engine indirekt:

- `WordProgress`-Listen werden ueber `WordProgressRepository` erzeugt; `WordRepository` liefert dafuer Wortbasisdaten.

### WordProgressRepository

Aufgaben:

- Fortschritt pro `word_id, category_id, mode_id` laden
- fehlende Fortschrittseintraege fuer Woerter als S0 initialisieren
- faellige Wiederholungen fuer Modus und Kategorie laden
- neue S0-Karten fuer Modus und Kategorie laden
- `ReviewResult.updatedProgress` speichern

Liefert an Engine:

- `WordProgress` fuer `ReviewInput`
- `dueReviewProgresses` fuer `QueueBuildInput`
- `newProgresses` fuer `QueueBuildInput`

Speichert aus Engine:

- `stage`
- `pass_count`
- `wrong_count`
- `next_due_at`
- `last_reviewed_at`

### ReviewHistoryRepository

Aufgaben:

- Review-Ereignisse aus `ReviewResult` speichern
- Historie fuer Statistik laden
- Fehlerquote fuer Session-Kontext oder Statistik bereitstellen, falls nicht aus Session-Items gelesen

Speichert aus Engine:

- altes und neues Stage-/PassCount-Paar
- Antwort
- Zeitpunkt
- neues `next_due_at`
- Requeue-Grund

### LearningSessionRepository

Aufgaben:

- aktive Session fuer `category_id, mode_id, training_area_id` suchen
- neue Session aus `QueueBuildResult` erzeugen
- bestehende aktive Session fortsetzen
- `session_items` mit Position und Status speichern
- aktuelle Position aktualisieren
- Requeue-Items speichern
- Session abschliessen
- Session-Kontext fuer `ReviewInput` liefern

Liefert an Engine:

- `QueueBuildInput`
- `SessionContext`

Speichert aus Engine:

- `QueueBuildResult`
- `ReviewResult.requeueDecision`
- neue oder aktualisierte `session_items`
- `current_position`
- `last_activity_at`

### SettingsRepository

Aufgaben:

- lokale Einstellungen lesen und schreiben
- Default-Sessiongroesse liefern
- spaeter Nutzerwahl 10/20/40 speichern
- Schema-/Migrationsversion pruefen

Liefert an Engine indirekt:

- `SessionConfig.sessionSize`

## Datenfluss Zur SRS-Engine

### Fuer `SrsEngine.buildSessionQueue(...)`

Die Repository-Schicht liefert:

- `SessionConfig`
  - `mode`
  - `trainingArea`
  - `now`
  - `sessionSize`
- `dueReviewProgresses`
  - alle faelligen Wiederholungskarten fuer Kategorie und Modus
- `newProgresses`
  - kontrolliert verfuegbare S0-Karten fuer Kategorie und Modus
- `recentAnswers`
  - letzte Antworten fuer die Fehlerquote

Die Engine fragt keine Datenbank ab.

### Fuer `SrsEngine.reviewCard(...)`

Die Repository-Schicht liefert:

- aktueller `WordProgress`
- `ReviewAnswer`
- `TrainingArea`
- `reviewedAt`
- `SessionContext`
  - `sessionId`
  - `currentPosition`
  - `recentAnswers`
  - `sameSessionWrongCountsByWordId`
  - `remainingQueueSize`

Die Engine gibt nur Entscheidungen zurueck.

## Zu Speichernde Engine-Ergebnisse

### Aus `ReviewResult`

Zu speichern:

- aktualisierter `WordProgress`
- `next_due_at`
- `last_reviewed_at`
- `stage`
- `pass_count`
- `wrong_count`
- Review-History-Ereignis
- Requeue-Entscheidung, falls vorhanden

Wichtig:

- Progress-Update, Review-History und Session-Update sollten in einer SQLite-Transaktion gespeichert werden.
- Ein Absturz zwischen diesen Schritten darf keine widerspruechlichen Daten erzeugen.

### Aus `QueueBuildResult`

Zu speichern:

- `learning_sessions`-Eintrag
- alle `session_items`
- Anzahl neuer Karten und Wiederholungen optional fuer Statistik

Version-1-Entscheidung:

- `newCardPolicy` aus `QueueBuildResult` wird nicht dauerhaft persistiert.
- Es kann spaeter optional fuer Debugging, Logs oder Statistik ergaenzt werden.
- Fuer die erste SQLite-/Repository-Schicht ist `newCardPolicy` kein Pflichtfeld.

## Aktive Session Speichern Und Fortsetzen

### Session-Erzeugung

Beim Start eines Lernmodus:

1. `LearningSessionRepository` prueft, ob fuer `category_id, mode_id, training_area_id` eine aktive Session existiert.
2. Falls ja: bestehende Session laden und fortsetzen.
3. Falls nein: Repository baut `QueueBuildInput`.
4. `SrsEngine.buildSessionQueue(...)` erzeugt `QueueBuildResult`.
5. Repository speichert `learning_sessions` und alle `session_items` in einer Transaktion.

### Session-Fortsetzung Nach App-Neustart

Beim Neustart:

1. App/ViewModel fragt aktive Session fuer Kategorie, Modus und Trainingsbereich ab.
2. Repository laedt `learning_sessions`.
3. Repository laedt `session_items` nach Position sortiert.
4. UI zeigt das naechste offene Item anhand von `current_position` und Item-Status.
5. Es wird keine neue Session erzeugt, solange eine aktive Session existiert.

### Manipulationsschutz

Folgende Daten muessen dauerhaft gespeichert werden:

- Queue-Reihenfolge
- aktuelle Position
- beantwortete Items
- Fehlerzaehler pro Karte in der Session
- Requeue-Items
- schwierige Items
- Review-History
- Fortschrittsstand

App schliessen, Abbruch oder Neustart darf nicht:

- Fehler loeschen
- Queue neu mischen
- Progress zuruecksetzen
- Requeue-Items entfernen
- neue Session erzeugen, wenn noch eine aktive Session existiert

## Nur Eine Aktive Session Pro Kontext

Kontext:

- `category_id`
- `mode_id`
- `training_area_id`

Regel:

- Es darf nur eine aktive Session pro Kontext geben.

Absicherung:

- Repository prueft vor Session-Erzeugung auf aktive Session.
- SQLite erzwingt die Regel mit partiellem Unique-Index.
- Session-Erzeugung erfolgt in einer Transaktion.

Fehlerfall:

- Wenn zwei Startversuche gleichzeitig passieren, darf nur einer eine Session anlegen.
- Der zweite Versuch muss die bereits erzeugte aktive Session laden.

## Supabase Schrittweise Ersetzen

### Phase 1: Lokale Tabellen Einfuehren

- SQLite-Schema hinzufuegen.
- Repositorys parallel zur bestehenden Supabase-Schicht erstellen.
- Keine UI-Flows umstellen.
- Tests fuer SQLite und Repositorys schreiben.

### Phase 2: Lokale SRS-Daten Nutzen

- SRS-Engine mit SQLite-Repository verbinden.
- Lernfortschritt lokal speichern.
- Sessions lokal speichern und fortsetzen.
- Supabase fuer SRS-Fortschritt nicht mehr neu beschreiben.
- Fuer Version 1 wird lokaler SRS-Fortschritt neu gestartet.
- Bestehender Supabase-Fortschritt wird nicht migriert, weil die alte Engine nicht zuverlaessig war.
- Supabase-Migration bleibt ein spaeteres Thema.

### Phase 3: Woerter Und Kategorien Lokal Lesen

- Kategorien und Woerter aus SQLite laden.
- Bestehende Import-/Seed-Strategie festlegen.
- Supabase-Lesezugriffe fuer Lernbereiche schrittweise entfernen.
- Fuer die erste lokale Version sollen Woerter und Kategorien lokal verfuegbar gemacht werden.
- Fuer Repository-Tests reichen lokale Test-/Seed-Daten.
- Falls vorhandene App-Daten einfach uebernommen werden koennen, wird das spaeter geprueft.
- Supabase-Export ist kein Blocker fuer die erste lokale Engine.

### Phase 4: Supabase-Abhaengigkeiten Entfernen

- Erst entfernen, wenn lokale Repositories in App-Flows stabil laufen.
- Imports, Services, Provider und Konfigurationen pruefen.
- Supabase-Pakete erst aus `pubspec.yaml` entfernen, wenn keine Nutzung mehr existiert.

### Phase 5: Launch-Vorbereitung

- Offline-Start ohne Netzwerk testen.
- App-Neustart mitten in aktiver Session testen.
- Datenintegritaet bei Abbruch testen.
- Backup-/Export-Strategie wird fuer Version 1 zurueckgestellt und als Post-Launch-Thema dokumentiert.

## Spaetere SQLite-/Repository-Tests

### Schema-Tests

- alle Tabellen werden erstellt
- Indizes existieren
- Unique-Regeln greifen
- Fremdschluessel greifen, falls aktiviert

### WordProgressRepository-Tests

- fehlender Fortschritt wird als S0 initialisiert
- Fortschritt ist pro `word_id, category_id, mode_id` getrennt
- T-SRS, A-SRS und Hybrid beeinflussen sich nicht gegenseitig
- faellige Reviews werden korrekt geladen
- S0-Karten werden als neue Karten geladen
- `ReviewResult.updatedProgress` wird korrekt gespeichert

### ReviewHistoryRepository-Tests

- Review-Ereignis wird unveraenderlich gespeichert
- alte und neue Stage-Werte stimmen
- `training_area_id` wird gespeichert
- Requeue-Grund wird gespeichert
- `focused`-Reviews koennen gespeichert werden, veraendern aber keinen normalen Fortschritt

### LearningSessionRepository-Tests

- neue Session wird mit Items gespeichert
- bestehende aktive Session wird fortgesetzt
- keine zweite aktive Session fuer denselben Kontext
- `current_position` bleibt nach Neustart erhalten
- beantwortete Items bleiben beantwortet
- Requeue-Items bleiben erhalten
- schwierige Items bleiben markiert
- Session kann abgeschlossen werden

### Transaktions-Tests

- Review speichert Progress, History und Session-Item atomar
- Fehler waehrend Speicherung hinterlaesst keinen halben Zustand
- paralleler Session-Start erzeugt keine Doppel-Session

### Integrationstests Auf Repository-Ebene

- `QueueBuildInput` wird korrekt aus SQLite-Daten gebaut
- `ReviewInput` wird korrekt aus SQLite-Daten und Session-Kontext gebaut
- `QueueBuildResult` wird korrekt persistiert
- `ReviewResult` wird korrekt persistiert
- App-Neustart-Szenario wird ohne UI simuliert

## Offene Entscheidungen

Der Version-1-Plan enthaelt aktuell keine offenen Schema-Entscheidungen.

## Empfohlene Naechste Schritte

1. Die verbleibenden kleinen Schema-Details pruefen.
2. SQLite-Schema-Testplanung als naechsten TDD-Schritt erstellen.
3. Repository-Tests zuerst fuer `word_progress`, `learning_sessions` und `session_items` schreiben.
4. Erst danach eine minimale Repository-Implementierung beginnen.
5. Bestehende App-Flows erst anbinden, wenn Repository-Tests gruen sind.

## Geklaerte Entscheidungen

Geklaert sind jetzt:

- Version 1 verwendet lokale UUIDs.
- Supabase-IDs werden nicht als Hauptstrategie uebernommen.
- `legacy_supabase_id` bleibt optional fuer spaetere Migration.
- Version 1 nutzt nur die notwendigen Wortfelder.
- Audio, Artikel, Wortart, DeepL-Metadaten und weitere Zusatzfelder werden zurueckgestellt.
- Lokaler SRS-Fortschritt startet neu.
- Bestehender Supabase-Fortschritt wird nicht migriert.
- Repository-Tests koennen mit lokalen Test-/Seed-Daten beginnen.
- Supabase-Export ist kein Blocker fuer die erste lokale Engine.
- `focused`-Antworten duerfen in `review_history` gespeichert werden.
- `focused` veraendert keinen normalen SRS-Fortschritt.
- Sessions kennen in Version 1 nur `active` und `completed`.
- `abandoned` wird nicht verwendet.
- Requeue wird als neues `session_item` gespeichert.
- Das urspruengliche `session_item` bleibt `answered`.
- Backup/Export wird als Post-Launch-Thema zurueckgestellt.
- `words` bekommt keinen eindeutigen Index auf `category_id, term, translation`.
- `settings` bleibt fuer Version 1 eine einfache Key-Value-Tabelle.
- `newCardPolicy` wird in Version 1 nicht dauerhaft persistiert.

## Bereitschaft Fuer SQLite-Schema-Testplanung

Der Plan ist bereit fuer den naechsten Schritt: SQLite-Schema-Testplanung.

Es sind keine offenen Schema-Entscheidungen fuer Version 1 mehr markiert. Die ersten SQLite-Schema-Tests koennen Tabellen, Indizes, Fremdschluessel, Unique-Regeln und Session-Integritaet pruefen.
