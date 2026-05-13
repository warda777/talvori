# 21 Local SRS Session Service Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den aktuellen lokalen SRS-/SQLite-Integrationsblock zusammen. Es beschreibt den Stand der isolierten lokalen Schicht unter `lib/core/local_database/` und ihre Verbindung zur reinen Dart-SRS-Engine unter `lib/core/srs/`.

Es beschreibt keine UI-Anbindung, keine Supabase-Entfernung und keine Umstellung bestehender App-Flows.

## Erstellte Lokale Bausteine

### SQLite-Schema

Erstellt wurde:

- `lib/core/local_database/local_database_schema.dart`

Das Schema legt die Version-1-Tabellen an:

- `categories`
- `words`
- `word_progress`
- `review_history`
- `learning_sessions`
- `session_items`
- `settings`

Wichtige abgesicherte Regeln:

- `word_progress` ist eindeutig pro `word_id + category_id + mode_id`
- es darf nur eine aktive Session pro `category_id + mode_id + training_area_id` geben
- `session_items` sind eindeutig pro `session_id + position`
- `settings.key` ist Primary Key
- wichtige Foreign Keys verhindern verwaiste Datensaetze

### Repository-Schicht

Erstellt wurden:

- `WordProgressRepository`
- `ReviewHistoryRepository`
- `LearningSessionRepository`

`WordProgressRepository` kann:

- fehlenden Fortschritt als S0 initialisieren
- vorhandenen Fortschritt wiederverwenden
- Fortschritt pro Modus getrennt speichern
- aktualisierten Fortschritt speichern
- faellige Wiederholungen laden
- neue S0-Karten laden
- einzelnen Fortschritt fuer `wordId + categoryId + mode` laden

`ReviewHistoryRepository` kann:

- Review-Events speichern
- Historie fuer ein Wort laden
- Recent Answers fuer Fehlerquote laden
- Focused-/Gezielt-ueben-Events speichern

`LearningSessionRepository` kann:

- aktive Sessions suchen
- Sessions aus `QueueBuildResult` speichern
- bestehende aktive Sessions wiederverwenden
- Session-Items nach Position laden
- `current_position` aktualisieren
- Requeue-Items speichern
- Sessions abschliessen
- Sessions per ID laden

### Lokale Session-Modelle

Erstellt wurde:

- `LocalSrsSessionState`

Der State ist UI-neutral und enthaelt aktuell:

- `sessionId`
- `categoryId`
- `mode`
- `trainingArea`
- `status`
- `sessionSize`
- `currentPosition`
- `totalItems`
- `answeredCount`
- `remainingCount`
- `currentWordId`
- `canCompleteSession`

## LocalSrsSessionService

Erstellt wurde:

- `lib/core/local_database/services/local_srs_session_service.dart`

`LocalSrsSessionService` ist die lokale Koordinationsschicht zwischen SQLite-Repositories und reiner `SrsEngine`.

Er uebernimmt:

- aktive Session starten oder fortsetzen
- bei vorhandener aktiver Session keine neue Queue erzeugen
- `QueueBuildInput` aus SQLite-Daten bauen
- `SrsEngine.buildSessionQueue(...)` aufrufen
- `QueueBuildResult` ueber `LearningSessionRepository` speichern
- aktuelles Session-Item fuer Antworten bestimmen
- `WordProgress` fuer das aktuelle Wort laden
- `SessionContext` mit Recent Answers, Position, Rest-Queue und Session-Fehlerzaehlern bauen
- `SrsEngine.reviewCard(...)` aufrufen
- `ReviewResult` ueber `SrsReviewPersistenceService` speichern
- aktualisierten `LocalSrsSessionState` zurueckgeben
- Session abschliessen, wenn keine offenen Items mehr vorhanden sind

Aktuell implementierte Methoden:

- `startOrResumeSession(...)`
- `submitAnswer(...)`
- `completeSessionIfFinished(...)`

Offene Item-Status fuer den Abschluss sind:

- `queued`
- `shown`
- `retryPending`

Nicht offene Status sind:

- `answered`
- `done`
- `difficult`

## SrsReviewPersistenceService

Erstellt wurde:

- `lib/core/local_database/services/srs_review_persistence_service.dart`

`SrsReviewPersistenceService` speichert ein `ReviewResult` atomar in einer SQLite-Transaktion.

Er uebernimmt:

- `word_progress` aktualisieren
- `review_history` schreiben
- beantwortetes `session_item` als `answered` markieren
- Requeue-Item erzeugen, falls die Engine eine Requeue-Entscheidung liefert
- `learning_sessions.current_position` aktualisieren
- `last_activity_at` und `updated_at` aktualisieren

Wichtig:

- Bei `TrainingArea.focused` wird `word_progress` nicht aktualisiert.
- Focused-Antworten werden trotzdem in `review_history` gespeichert.
- Das Session-Item wird auch bei Focused beantwortet.
- Die Session-Position wird auch bei Focused aktualisiert.
- Requeue wird nur erzeugt, wenn `ReviewResult.requeueDecision` vorhanden ist.

## Vorhandene Tests

### Schema-Tests

Datei:

- `test/core/local_database/local_database_schema_test.dart`

Sichert ab:

- alle Version-1-Tabellen werden erstellt
- `word_progress` ist eindeutig pro Wort, Kategorie und Modus
- es gibt maximal eine aktive Session pro Kontext
- `session_items.position` ist eindeutig pro Session
- Foreign Keys lehnen verwaiste Datensaetze ab

### WordProgressRepository-Tests

Datei:

- `test/core/local_database/word_progress_repository_test.dart`

Sichert ab:

- fehlender Fortschritt wird als S0 erstellt
- vorhandener Fortschritt wird wiederverwendet
- Fortschritt ist pro Lernmodus getrennt
- gespeicherter Fortschritt aktualisiert Stage, Pass Count, Wrong Count und Due Dates
- faellige Nicht-S0-Reviews werden korrekt geladen
- neue S0-Karten werden pro Kategorie und Modus mit Limit geladen

### ReviewHistoryRepository-Tests

Datei:

- `test/core/local_database/review_history_repository_test.dart`

Sichert ab:

- Review-Events speichern alle Kernfelder
- Wort-Historie laedt nur Events fuer das gewuenschte Wort
- Recent Answers kommen korrekt fuer Kategorie und Modus zurueck
- Focused-Reviews koennen ohne Progress-Aenderung als History gespeichert werden

### LearningSessionRepository-Tests

Datei:

- `test/core/local_database/learning_session_repository_test.dart`

Sichert ab:

- aktive Session wird gefunden
- neue Session speichert Items in Reihenfolge
- zweite aktive Session fuer denselben Kontext wird verhindert
- completed Session erlaubt neue aktive Session fuer denselben Kontext
- Session-Items werden nach Position geladen
- `current_position` wird gespeichert
- Requeue-Item wird erzeugt und das Original bleibt beantwortet

### SrsReviewPersistenceService-Tests

Datei:

- `test/core/local_database/srs_review_persistence_service_test.dart`

Sichert ab:

- ReviewResult aktualisiert Progress und schreibt History
- Session-Item wird beantwortet
- Requeue-Item wird bei Requeue-Entscheidung erzeugt
- `current_position` wird aktualisiert
- Persistenz ist atomar, wenn ein Schritt fehlschlaegt

### LocalSrsSessionService-Tests

Datei:

- `test/core/local_database/local_srs_session_service_test.dart`

Sichert ab:

- `startOrResumeSession(...)` erzeugt neue Session, wenn keine aktive existiert
- `startOrResumeSession(...)` verwendet bestehende aktive Session wieder
- richtige Antwort aktualisiert Progress, History, Item und Position
- falsche Antwort aktualisiert Progress, History, Item, Position und erzeugt Requeue-Item
- Focused-Antwort schreibt History und Session-Zustand ohne Progress-Aenderung
- `completeSessionIfFinished(...)` laesst Session aktiv, wenn offene Items existieren
- `completeSessionIfFinished(...)` setzt Session auf completed, wenn keine offenen Items existieren
- completed Session erlaubt wieder eine neue aktive Session fuer denselben Kontext

## Weiterhin Geltende Grenzen

Der lokale Integrationsblock hat weiterhin keine:

- UI-Anbindung
- Supabase-Entfernung
- App-Flow-Aenderung
- Navigation
- ViewModel-Anbindung
- echte App-Daten-Importlogik
- Backup-/Export-Strategie
- Supabase-Datenmigration
- DeepL- oder Wortimport-Integration
- echte Produktionsdatenbank-Oeffnung im App-Start

Die bestehende App nutzt diese lokale Schicht noch nicht automatisch.

## Sinnvolle Naechste Schritte

1. Lokale Datenbank-Oeffnung planen
   - Pfad, Versionierung, Migrationen und Foreign-Key-Aktivierung fuer echte App-Nutzung festlegen.

2. Minimalen Word-/Category-Read-Pfad planen
   - Die UI braucht spaeter Worttext, Uebersetzung und Kategorieinformationen fuer den `LocalSrsSessionState`.

3. Seed-/Import-Strategie fuer lokale Woerter klaeren
   - Ohne lokale Woerter und Kategorien kann die Engine zwar getestet, aber noch nicht sinnvoll in der App genutzt werden.

4. App-nahe Integration vorbereiten
   - ViewModel-Schnitt planen, ohne sofort Supabase zu entfernen.
   - Erst einen isolierten Lernmodus oder eine interne Debug-Route anbinden.

5. Session-Neustart-Szenario appnah testen
   - App schliessen, neu starten, aktive Session fortsetzen.

6. `flutter analyze` und breitere Tests erst nach App-Anbindung ausfuehren
   - Die lokale Schicht ist isoliert getestet; App-Anbindung kann neue Import- oder Provider-Themen sichtbar machen.

## Risiken Vor App-Anbindung

Vor einer echten App-Anbindung sollten diese Punkte geprueft werden:

- vorhandene App-Modelle passen eventuell noch nicht direkt zu den lokalen SQLite-Modellen
- bestehende Supabase-Services koennen parallel aehnliche Daten liefern und Namenskonflikte erzeugen
- echte Kategorien und Woerter muessen lokal verfuegbar sein
- lokale IDs und vorhandene Supabase-IDs duerfen nicht vermischt werden
- App-Neustart muss wirklich dieselbe aktive Session wiederfinden
- Requeue-Items duerfen in der UI nicht wie neue Woerter wirken
- Focused/Gezielt-ueben darf in der UI nicht als normaler SRS-Fortschritt erscheinen
- Session-Abschluss darf nicht versehentlich offene `retryPending`-Items ignorieren
- parallele Startversuche muessen auch im App-Kontext nur eine aktive Session erzeugen
- Fehler beim Speichern einer Antwort muessen fuer Nutzer verstaendlich behandelt werden
- lokale Datenbank-Migrationen muessen vor Launch stabil sein
- Supabase darf erst entfernt werden, wenn lokale App-Flows vollstaendig getestet sind

## Aktueller Stand

Der lokale SRS-/SQLite-Integrationsblock ist als isolierte Grundlage bereit fuer den naechsten Planungsschritt: lokale Datenbank-Oeffnung, lokale Wort-/Kategorieversorgung und vorsichtige App-Anbindungsplanung.

Er ist noch kein fertiger App-Flow.
