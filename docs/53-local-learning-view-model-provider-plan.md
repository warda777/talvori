# 53 Local Learning View Model Provider Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant einen isolierten Provider fuer `LocalLearningViewModelState`.

Der Provider soll die bestehende lokale Controller-/Adapter-Schicht fuer spaetere UI-nahe Nutzung lesbar machen, ohne selbst Aktionen auszufuehren oder bestehende App-Flows zu beruehren.

Es ist nur Planung:

- kein Code
- keine UI-Aenderung
- keine Supabase-Aenderung
- keine App-Flow-Aenderung
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`

## 1. Zweck Des Providers

Der Provider soll:

- `LocalLearningControllerState` lesen
- `LocalLearningViewModelAdapter` nutzen
- `LocalLearningViewModelState` bereitstellen
- bei jeder Controller-State-Aenderung neu mappen
- keine Aktionen ausfuehren
- keine Session starten
- keine Antwort submitten
- keine Completion pruefen
- keine Datenbank lesen
- keine UI kennen

Der Provider ist damit eine reine abgeleitete Leseschicht:

`LocalLearningControllerState -> LocalLearningViewModelAdapter -> LocalLearningViewModelState`

## 2. Erlaubte Und Nicht Erlaubte Abhaengigkeiten

### Erlaubt

Erlaubte Abhaengigkeiten:

- `localLearningControllerProvider`
- `LocalLearningControllerState`
- `LocalLearningViewModelAdapter`
- `LocalLearningViewModelState`

Optional:

- Riverpod `Provider`

### Nicht Erlaubt

Nicht erlaubte Abhaengigkeiten:

- Supabase
- `SupabaseWordRepository`
- UI-Widgets
- `BuildContext`
- Navigation
- `WordUserView`
- `LearnModeController`
- `learn_mode_controller.dart`
- `learn_mode_screen.dart`
- `word_providers.dart`
- alte `local_word_database.dart`
- direkte SQLite-Abfragen
- Repositorys
- `LocalLearningSessionFacade`

Wichtig:

- Der Provider darf nur lesen und mappen.
- Der Provider darf nicht selbst die lokale Facade lesen.
- Der Provider darf nicht `startOrResume(...)`, `submitCorrect(...)`, `submitWrong(...)` oder `completeIfFinished(...)` ausloesen.

## 3. Sinnvolle Riverpod-Form

### Option A: Normaler Provider

Beispielhafte Form fuer spaeter:

- `Provider<LocalLearningViewModelState>`

Arbeitsweise:

- liest `localLearningControllerProvider`
- erstellt oder verwendet `LocalLearningViewModelAdapter`
- gibt `adapter.map(controllerState)` zurueck

Vorteile:

- sehr klein
- keine eigene Mutationslogik
- kein Lifecycle-Problem
- gut testbar
- folgt der aktuellen Rolle als reine Mapping-Schicht

Risiken:

- Adapter wird bei jedem Provider-Read neu erstellt, falls nicht separat konstant gehalten
- minimal und unkritisch

Bewertung:

- beste Wahl fuer Version 1

### Option B: Abgeleiteter Provider Mit Separatem Adapter-Provider

Moegliche Struktur:

- `localLearningViewModelAdapterProvider`
- `localLearningViewModelProvider`

Arbeitsweise:

- Adapter-Provider stellt `const LocalLearningViewModelAdapter()` bereit
- ViewModel-Provider liest Controller-State und Adapter

Vorteile:

- Adapter kann in Tests leichter ueberschrieben werden
- klare Trennung zwischen Mapper-Instanz und ViewModel-State

Risiken:

- ein Provider mehr
- fuer aktuellen Bedarf eventuell leicht ueberdimensioniert

Bewertung:

- ebenfalls sinnvoll, falls Testbarkeit/Override wichtiger wird

### Option C: Notifier Oder AsyncNotifier

Beschreibung:

- eigener Notifier fuer `LocalLearningViewModelState`

Vorteile:

- koennte spaeter Aktionen buendeln

Risiken:

- doppelt Controller-Verantwortung
- Gefahr, dass Aktionen versehentlich in den Provider wandern
- unnoetig fuer reines Mapping

Bewertung:

- nicht empfohlen

## Empfehlung Fuer Version 1

Empfohlen wird ein normaler abgeleiteter Riverpod-Provider:

- kein `Notifier`
- kein `AsyncNotifier`
- keine eigene State-Mutation
- keine Side Effects

Optional kann ein separater Adapter-Provider genutzt werden, wenn Tests den Adapter gezielt ueberschreiben sollen.

Die einfache Zielregel:

- Controller verwaltet Aktionen und State.
- Adapter mappt State.
- Provider stellt den gemappten State bereit.

## 4. Erste Sinnvolle Tests

Empfohlene Tests:

- `local_learning_view_model_provider_maps_controller_state`
- `provider_does_not_start_session`
- `provider_does_not_call_submit_or_complete`
- `provider_does_not_require_supabase_or_word_user_view`

### local_learning_view_model_provider_maps_controller_state

Sichert ab:

- Provider liest `localLearningControllerProvider`
- Provider nutzt den Adapter
- Rueckgabe ist `LocalLearningViewModelState`
- Felder aus dem Controller-State werden korrekt gemappt

Praktischer Testansatz:

- `ProviderContainer` erstellen
- Controller-State direkt oder ueber Provider-Override bereitstellen
- ViewModel-Provider lesen
- gemappte Felder pruefen

[PRÜFEN] Ob fuer den ersten Test ein Override des Controller-Providers sinnvoller ist als echte Controller-Aktionen.

### provider_does_not_start_session

Sichert ab:

- Lesen des ViewModel-Providers ruft keine Controller-Aktion auf
- kein `readState` wird erzeugt, wenn keiner vorhanden war
- `hasSession == false`

Praktischer Testansatz:

- ProviderContainer ohne lokale Seed-/Session-Aktion
- ViewModel-Provider lesen
- sicherstellen, dass kein Session-State entsteht

### provider_does_not_call_submit_or_complete

Sichert ab:

- Provider fuehrt keine Antwort- oder Completion-Aktion aus
- `lastAction` wird nur aus dem Controller-State uebernommen
- keine neue Review-History oder Session-Progress-Aenderung wird angestossen

Praktischer Testansatz:

- fuer V1 wahrscheinlich als reiner State-Test ausreichend
- keine Datenbank erforderlich

### provider_does_not_require_supabase_or_word_user_view

Sichert ab:

- Test laeuft ohne Supabase-Initialisierung
- keine `WordUserView`-Instanz wird benoetigt
- Provider nutzt nur lokale Controller-/Adapter-Modelle

## 5. Risiken

### Provider Loest Versehentlich Aktionen Aus

Risiko:

- Ein Provider, der eigentlich nur lesen soll, koennte versehentlich `startOrResume(...)` oder andere Controller-Methoden ausloesen.

Gegenregel:

- Provider darf nur `ref.watch(localLearningControllerProvider)` lesen.
- Provider darf nicht `ref.read(localLearningControllerProvider.notifier)` verwenden.

### Provider Wird Zu Frueh In UI Eingebunden

Risiko:

- Bestehende UI koennte lokalen ViewModel-State lesen, waehrend alte Supabase-Flows weiter aktiv sind.

Gegenregel:

- keine Aenderung an `learn_mode_screen.dart`
- keine Aenderung an `word_providers.dart`
- keine Navigation
- Provider bleibt isoliert und getestet

### Adapter Bekommt UI-Texte

Risiko:

- Der Provider oder Adapter koennte anfangen, Moduslabels, Buttontexte oder lokalisierte Strings zu erzeugen.

Gegenregel:

- ViewModel-State bleibt datenorientiert
- keine Labels wie `T-SRS`, `A-SRS`, `Hybrid`
- UI-Texte spaeter separat planen

### Doppelte State-Verantwortung

Risiko:

- Ein Notifier-Provider koennte eine zweite State-Quelle neben `LocalLearningController` werden.

Gegenregel:

- fuer Version 1 nur `Provider<LocalLearningViewModelState>`
- keine eigene Mutation

## 6. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt:

1. Einen isolierten Provider im lokalen Bereich erstellen, z. B.:
   - `lib/core/local_database/providers/local_learning_view_model_provider.dart`
2. Nur einen normalen Riverpod-Provider bereitstellen:
   - liest `localLearningControllerProvider`
   - nutzt `LocalLearningViewModelAdapter`
   - gibt `LocalLearningViewModelState` zurueck
3. Nur einen ersten Test schreiben:
   - `local_learning_view_model_provider_maps_controller_state`
4. Test ohne UI, Supabase, Datenbank und `WordUserView` halten.
5. Danach nur gezielt ausfuehren:
   - `flutter test test/core/local_database/local_learning_view_model_provider_test.dart`

Nicht im ersten Schritt:

- kein UI-Screen
- keine Navigation
- keine Session starten
- keine Antwort submitten
- keine Completion ausloesen
- keine Datenbank oeffnen
- keine Supabase-Initialisierung
- keine Aenderung an bestehenden App-Dateien

## 7. Abschlussbewertung

Ein `LocalLearningViewModelState`-Provider ist ein sinnvoller naechster Baustein, weil er die lokale Controller-/Adapter-Kette app-naeher macht, ohne bestehende App-Flows zu beruehren.

Die sichere Richtung bleibt:

1. Controller stabil halten.
2. Adapter stabil halten.
3. ViewModel-State ueber isolierten Provider lesbar machen.
4. Danach erst entscheiden, ob ein lokaler Testscreen geplant wird.
5. Bestehende UI erst spaeter und mit eigener Integrationsplanung anfassen.
