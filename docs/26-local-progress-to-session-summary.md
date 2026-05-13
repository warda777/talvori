# 26 Local Progress To Session Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den lokalen Progress-to-Session-Integrationsnachweis zusammen.

Der Nachweis bleibt vollstaendig innerhalb der isolierten lokalen SQLite-/Repository-/SRS-Schicht. Es gibt weiterhin keine UI-Anbindung, keine Supabase-Entfernung und keine Aenderung bestehender App-Flows.

## Was Der Integrationstest Nachweist

Der Test `initialized_progress_can_start_session_with_new_s0_cards` zeigt:

- lokale Kategorie kann erzeugt werden
- lokale aktive Woerter koennen erzeugt werden
- `LocalProgressInitializationService` kann fuer diese Woerter `S0`-Progress im gewuenschten Modus erzeugen
- `LocalSrsSessionService.startOrResumeSession(...)` kann danach eine aktive Session starten
- neue `S0`-Progress-Daten werden als neue Karten in die Session-Queue aufgenommen
- Session-Items stammen aus den initialisierten Progress-Daten
- die Session bleibt auf die technische Sessiongroesse begrenzt
- `currentWordId` ist gesetzt
- `remainingCount` ist groesser als 0
- erneuter Start fuer denselben Kontext erzeugt keine zweite aktive Session

Damit ist lokal bewiesen: vorbereiteter `word_progress` kann direkt in eine lernbare Session-Queue uebergehen.

## Funktionierende Lokale Kette

Aktuell funktioniert diese lokale Kette:

1. `CategoryRepository`
   - speichert lokale Kategorie.

2. `WordRepository`
   - speichert lokale Woerter.
   - liefert aktive Wort-IDs der Kategorie.

3. `LocalProgressInitializationService`
   - laedt aktive Wort-IDs.
   - ruft fuer jedes Wort `WordProgressRepository.ensureProgressForWord(...)` auf.

4. `WordProgressRepository`
   - erzeugt fehlenden Fortschritt als `S0`.
   - speichert Fortschritt getrennt pro `word_id`, `category_id` und `mode_id`.

5. `LocalSrsSessionService.startOrResumeSession(...)`
   - laedt neue `S0`-Progress-Daten.
   - baut `QueueBuildInput`.
   - ruft `SrsEngine.buildSessionQueue(...)` auf.
   - speichert die Queue als aktive Session ueber `LearningSessionRepository`.

6. `LearningSessionRepository`
   - legt genau eine aktive Session fuer `category_id + mode_id + training_area_id` an.
   - speichert `session_items` in stabiler Reihenfolge.
   - verwendet eine bestehende aktive Session wieder.

## Beteiligte Komponenten

Am Integrationsnachweis beteiligt sind:

- `LocalDatabaseSchema`
- `CategoryRepository`
- `WordRepository`
- `WordProgressRepository`
- `ReviewHistoryRepository`
- `LearningSessionRepository`
- `LocalProgressInitializationService`
- `LocalSrsSessionService`
- `SrsReviewPersistenceService`
- reine Dart-`SrsEngine`
- `LearningMode`
- `TrainingArea`
- `SrsStage`
- `QueueItemStatus`

Der Test nutzt eine In-Memory-SQLite-Datenbank und echte lokale Repository-/Service-Instanzen.

## Weiterhin Geltende Grenzen

Nicht umgesetzt:

- keine UI-Anbindung
- keine ViewModel-Anbindung
- keine Navigation
- keine Supabase-Entfernung
- kein Supabase-Datenimport
- keine App-Flow-Aenderung
- keine echte Produktionsdatenbank-Oeffnung
- keine Seed- oder Importstrategie fuer echte App-Woerter
- kein Mapping von `word_hub_taxonomy.dart`
- keine Anzeige von Worttext/Uebersetzung im UI
- keine Backup-/Export-Strategie

Der Nachweis zeigt nur, dass die lokale technische Kette funktioniert. Die bestehende App nutzt diese Kette noch nicht.

## Warum Dieser Schritt Wichtig Ist

Vor einer App-Anbindung muss klar sein, dass die lokale Datenbasis nicht nur isoliert speichern kann, sondern auch eine echte Lernsession vorbereitet.

Dieser Schritt prueft genau den kritischen Uebergang:

- aus lokalen Woertern werden Progress-Daten
- aus Progress-Daten werden Queue-Items
- aus Queue-Items wird eine aktive Session

Ohne diesen Nachweis waere eine UI-Anbindung riskant, weil der Start einer Session zwar oberflaechlich ausgeloest werden koennte, aber keine belastbare lokale Queue entstehen muesste.

Der Test reduziert dieses Risiko, bevor bestehende ViewModels oder App-Flows beruehrt werden.

## Sinnvolle Naechste Schritte

Sinnvolle naechste kleine Schritte:

1. Planen, wie lokale Kategorien und Woerter fuer echte App-Nutzung bereitgestellt werden.
2. Pruefen, ob `word_hub_taxonomy.dart`, bestehende lokale Daten oder ein spaeterer Supabase-Export als erste Datenquelle dienen sollen.
3. Einen App-nahen Read-State planen, der zu einer Session nicht nur IDs, sondern auch Worttext und Uebersetzung liefern kann.
4. Einen vorsichtigen ViewModel-Adapter planen, der noch nicht die bestehende UI umbaut.
5. Vor jeder App-Anbindung die lokalen Tests fuer SRS, SQLite, Repositories und lokale Session-Services ausfuehren.

Empfehlung:

Der naechste kleinste Planungsschritt ist ein UI-neutraler Session-Read-Plan: Wie kommt die App spaeter von `LocalSrsSessionState.currentWordId` zu den angezeigten Wortdaten, ohne UI, Engine und Repository-Schicht zu vermischen?
