# 62 Local Testscreen Start Action Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant den naechsten kleinen TDD-Schritt fuer den isolierten `LocalLearningTestScreen`.

Ziel:

- Der Button **Starten/Fortsetzen** soll funktional werden.
- Beim Antippen soll `localLearningControllerProvider.notifier.startOrResume(...)` aufgerufen werden.
- Der Screen bleibt weiterhin isoliert und nicht in Navigation oder bestehende App-Flows eingebunden.

## 1. Gewuenschtes Verhalten

Wenn der Testscreen im Initialzustand angezeigt wird und der Nutzer **Starten/Fortsetzen** antippt, soll spaeter diese Controller-Aktion ausgefuehrt werden:

- `localLearningControllerProvider.notifier.startOrResume(...)`

Der Screen selbst soll nur koordinieren:

1. Button-Tap empfangen
2. aktuelle Zeit bestimmen
3. Controller-Notifier lesen
4. `startOrResume(...)` aufrufen

Der Screen darf keine eigene Lernlogik enthalten.

## 2. Parameter

Der Aufruf soll diese Werte verwenden:

- `categoryId`: aus dem Konstruktor `LocalLearningTestScreen(categoryId: ...)`
- `mode`: `LearningMode.adaptive`
- `trainingArea`: `TrainingArea.all`
- `now`: aktueller Zeitpunkt

Geplanter Aufruf:

- `startOrResume(categoryId: categoryId, mode: LearningMode.adaptive, trainingArea: TrainingArea.all, now: now)`

Optional fuer Testbarkeit:

- `DateTime Function()? nowProvider`

Damit kann der Widget-Test eine feste Zeit injizieren, ohne Systemzeit pruefen zu muessen.

## 3. Was Nicht Passieren Darf

Der Screen darf weiterhin nicht:

- eine Datenbank direkt oeffnen
- Repositorys direkt lesen
- `localLearningSessionFacadeProvider` direkt lesen
- Supabase importieren oder initialisieren
- Navigation ausloesen
- Seed-Daten automatisch starten
- alte `local_word_database.dart` verwenden
- `WordUserView` verwenden
- `LearnModeController` verwenden
- `learn_mode_screen.dart` ersetzen oder veraendern
- bestehende UI-Dateien veraendern
- bestehende App-Flows veraendern

Der Button-Tap ist nur eine delegierende Debug-Screen-Aktion.

## 4. Gewuenschter Widget-Test

Neuer Test:

- `local_learning_test_screen_start_button_calls_start_or_resume`

Testidee:

1. `LocalLearningTestScreen(categoryId: 'test-category')` rendern.
2. Provider-Overrides fuer Initialzustand setzen:
   - `localLearningViewModelProvider`
   - `localLearningScreenContractProvider`
3. Feste Zeit injizieren, z. B. `fixedNow`.
4. **Starten/Fortsetzen** antippen.
5. Pruefen, dass `startOrResume(...)` mit diesen Werten aufgerufen wurde:
   - `categoryId == 'test-category'`
   - `mode == LearningMode.adaptive`
   - `trainingArea == TrainingArea.all`
   - `now == fixedNow`
6. Keine echte Datenbank oeffnen.
7. Keine echte Facade verwenden.
8. Keine Supabase-Initialisierung benoetigen.
9. Keine Navigation benoetigen.

## 5. Mocking-/Notifier-Huerde

`localLearningControllerProvider` ist ein `NotifierProvider<LocalLearningController, LocalLearningControllerState>`.

Das direkte Mocking des Notifiers in einem Widget-Test ist voraussichtlich schwerer als bei einfachen Value-Providern, weil:

- der Screen `ref.read(localLearningControllerProvider.notifier)` verwenden muesste
- der echte `LocalLearningController` intern `localLearningSessionFacadeProvider.future` liest
- ein echter Controller-Aufruf dadurch die lokale Facade-Kette und potentiell Datenbank-Bootstrap beruehren wuerde
- der Test aber ausdruecklich keine echte Datenbank oeffnen soll

Deshalb sollte der erste funktionale Button-Test nicht versuchen, die echte Controller-/Facade-Kette zu starten.

## 6. Empfohlene Minimal Loesung

Empfohlen wird eine kleine Action-Callback-Injection nur fuer den isolierten Testscreen.

Moegliche Erweiterung am Screen:

- Konstruktor bleibt weiter:
  - `required String categoryId`
- zusaetzlich optional:
  - `Future<void> Function({required String categoryId, required LearningMode mode, required TrainingArea trainingArea, required DateTime now})? onStartOrResume`
  - `DateTime Function()? nowProvider`

Screen-Verhalten:

1. Wenn `onStartOrResume` gesetzt ist:
   - Button ruft diesen Callback auf.
   - Widget-Test kann Parameter ohne echte DB pruefen.
2. Wenn `onStartOrResume` nicht gesetzt ist:
   - Button liest `localLearningControllerProvider.notifier`.
   - Button ruft `startOrResume(...)` auf.

Vorteile:

- keine echte Datenbank im Widget-Test
- kein Fake-Notifier noetig
- kein Umbau der Provider-Kette
- Screen bleibt isoliert
- produktionsnaher Default bleibt Provider-basiert
- spaeter wieder leicht entfernbar, falls der Debug-Screen reift

Risiken:

- Der Screen bekommt eine Test-/Debug-spezifische Injektionsstelle.
- Der Callback darf nicht zu einer allgemeinen zweiten Architektur werden.

Bewertung:

- Fuer einen isolierten Debug-Testscreen ist diese Loesung risikoarm.
- Sie vermeidet eine groessere Riverpod-Test-Infrastruktur nur fuer einen Button-Tap.

## 7. Alternative: Provider-Fake

Alternative waere ein Provider-Fake fuer `localLearningControllerProvider`.

Nachteile:

- `NotifierProvider`-Overrides sind aufwendiger als einfache Value-Overrides.
- Ein Fake-Notifier muesste Riverpod-Lifecycle korrekt bedienen.
- Der Test koennte mehr lokale Infrastruktur brauchen als die eigentliche Screen-Logik.
- Hoeheres Risiko, versehentlich echte Facade-/DB-Kette zu beruehren.

Diese Alternative ist fuer den kleinsten naechsten Schritt weniger geeignet.

## 8. Warum Zuerst Nur Starten/Fortsetzen

`Starten/Fortsetzen` ist die kleinste sinnvolle Aktion, weil:

- sie keine bestehende `sessionId` im ViewModel-State braucht
- sie direkt `categoryId`, `LearningMode` und `TrainingArea` prueft
- sie die Testscreen-Konfiguration validiert
- sie keine Requeue-Logik beruehrt
- sie keine Completion-Regel beruehrt
- sie keine Antwortlogik beruehrt

`Richtig` und `Falsch` sollten spaeter getrennt geplant werden, weil sie:

- eine aktive Session brauchen
- eine `sessionId` aus dem Read-State brauchen
- Antwort-Persistenz ausloesen
- bei `Falsch` Requeue beruehren

## 9. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt:

1. Test `local_learning_test_screen_start_button_calls_start_or_resume` schreiben.
2. `LocalLearningTestScreen` im Initialzustand rendern.
3. `categoryId: 'test-category'` ueber Konstruktor setzen.
4. `nowProvider` mit fixer Zeit injizieren.
5. `onStartOrResume` als Test-Callback injizieren.
6. **Starten/Fortsetzen** antippen.
7. Pruefen, dass der Callback exakt mit diesen Werten aufgerufen wurde:
   - `categoryId: 'test-category'`
   - `mode: LearningMode.adaptive`
   - `trainingArea: TrainingArea.all`
   - `now: fixedNow`
8. Danach im Screen den Default-Pfad ergaenzen:
   - Wenn kein Callback gesetzt ist, `localLearningControllerProvider.notifier.startOrResume(...)` aufrufen.
9. Nur diesen Test ausfuehren:
   - `flutter test test/features/local_learning_debug/local_learning_test_screen_test.dart`

Weiterhin nicht tun:

- keine DB oeffnen
- keine Seed-Daten starten
- keine echte lokale Session im Widget-Test erzeugen
- keine Navigation einhaengen
- keine bestehende UI-Datei aendern

