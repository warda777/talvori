# 25 Local Progress Initialization Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den `LocalProgressInitializationService` zusammen.

Der Service ist ein kleiner lokaler Koordinationsbaustein innerhalb der SQLite-/Repository-Schicht. Er ist weiterhin isoliert und wird noch nicht in UI, Supabase oder bestehende App-Flows eingebunden.

## Aufgabe Des Service

`LocalProgressInitializationService` bereitet SRS-Fortschritt fuer lokale Woerter einer Kategorie vor.

Er sorgt dafuer, dass fuer alle aktiven Woerter einer Kategorie ein fehlender `word_progress`-Eintrag im gewuenschten Lernmodus existiert.

Fachlich bedeutet das:

- aktive Wort-IDs einer Kategorie laden
- fuer jedes aktive Wort fehlenden Fortschritt erzeugen
- Fortschritt startet als `S0`
- Fortschritt wird fuer genau einen angeforderten `LearningMode` initialisiert
- wiederholte Ausfuehrung erzeugt keine doppelten Fortschrittsdaten
- archivierte Woerter werden standardmaessig nicht initialisiert

Der Service berechnet keine SRS-Regeln und entscheidet nicht ueber Queue, Stage-Wechsel, Due Dates oder Reviews.

## Koordinierte Repositories

Der Service koordiniert genau diese Repositories:

- `WordRepository`
- `WordProgressRepository`

Verwendete Aufgaben:

- `WordRepository.loadWordIdsForCategory(...)`
  - liefert aktive Wort-IDs einer Kategorie
  - blendet archivierte Woerter standardmaessig aus

- `WordProgressRepository.ensureProgressForWord(...)`
  - erzeugt fehlenden Fortschritt als `S0`
  - nutzt `word_id`, `category_id` und `mode_id`
  - gibt bestehenden Fortschritt zurueck, wenn er bereits existiert

Damit bleibt die Trennung klar:

- `WordRepository` kennt Wortbasisdaten
- `WordProgressRepository` kennt Fortschrittsdaten
- `LocalProgressInitializationService` koordiniert beide

## Umgesetzte Methode

Umgesetzt wurde:

- `initializeProgressForCategoryAndMode({required categoryId, required mode, required now})`

Ablauf:

1. Lade aktive Wort-IDs fuer `categoryId`.
2. Iteriere ueber diese Wort-IDs.
3. Rufe fuer jede Wort-ID `ensureProgressForWord(...)` mit dem angeforderten `LearningMode` auf.
4. Speichere selbst keine Zusatzdaten.
5. Fuehre keine SRS-Engine-Entscheidungen aus.

## Tests

Datei:

- `test/core/local_database/local_progress_initialization_service_test.dart`

Abgesichert wird:

- `initializes_s0_progress_for_all_active_words_in_category`
  - aktive Woerter einer Kategorie erhalten Fortschritt
  - Fortschritt startet in `S0`
  - `passCount`, `wrongCount`, `nextDueAt` und `lastReviewedAt` starten neutral

- `does_not_initialize_archived_words`
  - archivierte Woerter werden nicht geladen
  - archivierte Woerter erhalten keinen Fortschritt

- `does_not_create_duplicate_progress_on_second_run`
  - erneuter Service-Aufruf erzeugt keine doppelten Eintraege
  - bestehende `word_progress`-Eintraege werden wiederverwendet

- `initializes_progress_only_for_requested_learning_mode`
  - Fortschritt wird nur fuer den angeforderten Modus angelegt
  - andere Lernmodi bleiben unberuehrt

Die Tests nutzen eine In-Memory-SQLite-Datenbank und bleiben vollstaendig lokal.

## Weiterhin Geltende Grenzen

Nicht umgesetzt:

- keine UI-Anbindung
- kein Supabase-Zugriff
- keine Supabase-Entfernung
- keine App-Flow-Aenderung
- keine SRS-Engine-Logik
- keine Queue-Erstellung
- keine Review-Verarbeitung
- kein Import echter App-Daten
- kein Mapping von `word_hub_taxonomy.dart`

Der Service ist ein Vorbereitungsbaustein, nicht der eigentliche Session-Service.

## Bedeutung Fuer Spaetere Session-Starts

`LocalSrsSessionService` baut Sessions spaeter aus vorhandenen `word_progress`-Daten.

Dafuer muss vor dem ersten Session-Start sichergestellt sein, dass lokale Woerter einer Kategorie ueberhaupt Fortschrittseintraege haben. Ohne diesen Schritt koennte die Queue keine neuen `S0`-Karten aus `word_progress` laden.

Der `LocalProgressInitializationService` schliesst genau diese Luecke:

- Kategorie und Woerter koennen lokal existieren.
- Fortschritt kann pro Modus vorbereitet werden.
- Danach kann `WordProgressRepository.loadNewProgresses(...)` neue `S0`-Karten fuer die Queue liefern.

Damit wird spaeter ein sicherer Ablauf moeglich:

1. Kategorie auswaehlen.
2. Progress fuer Kategorie und Modus vorbereiten.
3. Session starten oder fortsetzen.
4. Queue aus Due- und New-Progresses bauen.

## Sinnvolle Naechste Schritte

Sinnvolle naechste kleine Schritte:

1. Planen, an welcher Stelle der lokale Session-Start spaeter `LocalProgressInitializationService` aufrufen soll.
2. Einen isolierten Test vorbereiten, der Progress-Initialisierung und `LocalSrsSessionService.startOrResumeSession(...)` kombiniert.
3. Lokale Seed- oder Import-Strategie fuer erste Kategorien und Woerter planen.
4. Pruefen, ob bestehende lokale App-Daten oder `word_hub_taxonomy.dart` als Quelle fuer erste lokale Kategorien und Woerter dienen koennen.
5. Erst danach eine vorsichtige App-Anbindung planen.

Empfehlung:

Der naechste kleine technische Schritt ist ein integrationsnaher Test, der zeigt, dass nach `initializeProgressForCategoryAndMode(...)` eine lokale Session fuer denselben `categoryId` und `LearningMode` neue `S0`-Karten in die Queue aufnehmen kann.
