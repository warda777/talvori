# 57 Local Learning Screen Contract Provider Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant einen isolierten Provider fuer `LocalLearningScreenContract`.

Der Provider soll die lokale UI-nahe Lesekette um eine weitere reine Ableitung ergaenzen:

`localLearningViewModelProvider -> LocalLearningScreenContract`

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

- `localLearningViewModelProvider` lesen
- daraus einen `LocalLearningScreenContract` ableiten
- die booleschen Screen-Zustaende fuer spaetere Leser bereitstellen
- keine Aktionen ausfuehren
- keine UI kennen
- keine Session starten
- keine Antwort submitten
- keine Completion ausloesen
- keine Datenbank lesen
- keine Navigation ausloesen

Die Rolle ist rein lesend:

1. `localLearningViewModelProvider` liefert `LocalLearningViewModelState`
2. `LocalLearningScreenContract.fromViewModelState(...)` leitet den Contract ab
3. der Provider gibt `LocalLearningScreenContract` zurueck

## 2. Erlaubte Und Nicht Erlaubte Abhaengigkeiten

### Erlaubt

Erlaubte Abhaengigkeiten:

- `localLearningViewModelProvider`
- `LocalLearningViewModelState`
- `LocalLearningScreenContract`

Optional:

- Riverpod `Provider`

### Nicht Erlaubt

Nicht erlaubte Abhaengigkeiten:

- Supabase
- `SupabaseWordRepository`
- UI-Widgets
- `BuildContext`
- Navigation
- `LearnModeController`
- `learn_mode_controller.dart`
- `learn_mode_screen.dart`
- `WordUserView`
- alte `local_word_database.dart`
- direkte SQLite-Abfragen
- Repositorys
- `LocalLearningSessionFacade`
- `localLearningControllerProvider.notifier`

Wichtig:

- Der Provider darf nur `localLearningViewModelProvider` lesen.
- Der Provider darf keine Controller-Methode aufrufen.
- Der Provider darf keine UI-Texte erzeugen.

## 3. Sinnvolle Riverpod-Form

### Empfehlung: Normaler Provider

Empfohlen wird:

- `Provider<LocalLearningScreenContract>`

Arbeitsweise:

- `ref.watch(localLearningViewModelProvider)`
- `LocalLearningScreenContract.fromViewModelState(viewModelState)`
- Rueckgabe des Contracts

Vorteile:

- klein
- synchron
- keine eigene State-Mutation
- kein Lifecycle-Problem
- gut testbar
- keine Side Effects

### Nicht Empfohlen: Notifier

Ein `Notifier` ist nicht sinnvoll, weil:

- der Contract keinen eigenen Zustand besitzen soll
- keine Aktionen ausgefuehrt werden
- sonst eine zweite State-Verantwortung neben Controller/ViewModelProvider entstehen koennte

### Nicht Empfohlen: AsyncNotifier

Ein `AsyncNotifier` ist nicht sinnvoll, weil:

- keine asynchronen Daten geladen werden
- keine Datenbank geoeffnet wird
- keine Facade direkt gelesen wird

## 4. Erste Sinnvolle Tests

Empfohlene Tests:

- `local_learning_screen_contract_provider_maps_view_model_state`
- `provider_does_not_start_session_or_submit`
- `provider_does_not_require_supabase_or_ui`

### local_learning_screen_contract_provider_maps_view_model_state

Sichert ab:

- Provider liest den ViewModel-State
- Provider erzeugt einen `LocalLearningScreenContract`
- abgeleitete Felder stimmen
- z. B. aktive Karte ergibt `hasActiveCard == true`
- Submit-Sichtbarkeit wird korrekt abgeleitet

Praktischer Testansatz:

- `ProviderContainer` erstellen
- `localLearningViewModelProvider` kontrolliert ueberschreiben, falls moeglich
- Contract-Provider lesen
- Contract-Felder pruefen

[PRÜFEN] Falls `localLearningViewModelProvider` schwer direkt zu ueberschreiben ist, kann alternativ der darunterliegende `localLearningControllerProvider` wie im ViewModelProvider-Test ueberschrieben werden.

### provider_does_not_start_session_or_submit

Sichert ab:

- reines Lesen des Contract-Providers erzeugt keine Session
- reines Lesen ruft keine Submit-/Completion-Aktion aus
- fehlender ViewModel-Session-Zustand bleibt initial

Praktischer Testansatz:

- kontrollierten State ohne Session bereitstellen
- Contract-Provider lesen
- `isInitial == true`
- `hasActiveCard == false`
- `canShowSubmitActions == false`

### provider_does_not_require_supabase_or_ui

Sichert ab:

- Test laeuft ohne Supabase-Initialisierung
- keine `WordUserView`-Instanz noetig
- keine Widgets noetig
- keine Navigation noetig
- keine Datenbank noetig

## 5. Risiken

### Provider Loest Versehentlich Aktionen Aus

Risiko:

- Ein eigentlich lesender Provider koennte versehentlich Controller-Methoden aufrufen.

Gegenregel:

- Provider darf nur `ref.watch(localLearningViewModelProvider)` verwenden.
- Provider darf nicht `ref.read(localLearningControllerProvider.notifier)` verwenden.

### Provider Wird Zu Frueh In UI Eingebunden

Risiko:

- Bestehende UI koennte den lokalen Contract lesen, waehrend alte Supabase-Flows weiter aktiv sind.

Gegenregel:

- keine Aenderung an `learn_mode_screen.dart`
- keine Aenderung an `word_providers.dart`
- keine Navigation
- keine bestehende Provider-Ersetzung

### Contract Bekommt UI-Texte

Risiko:

- Contract oder Provider koennten anfangen, Buttontexte, Modusnamen oder Completion-Meldungen zu erzeugen.

Gegenregel:

- Contract bleibt bei booleschen Zustaenden.
- UI-Texte werden separat geplant.
- Keine technischen Labels wie `T-SRS`, `A-SRS`, `Hybrid` im Contract.

### Zu Viele Abgeleitete Schichten

Risiko:

- Controller, ViewModelProvider und ContractProvider koennten fuer spaetere Entwickler unklar wirken.

Gegenregel:

- klare Verantwortlichkeiten dokumentieren:
  - Controller: Aktionen und lokaler Controller-State
  - ViewModelProvider: UI-nahe Datenform
  - ScreenContractProvider: boolesche Screen-Zustaende

## 6. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt:

1. Einen isolierten Provider im lokalen Bereich erstellen, z. B.:
   - `lib/core/local_database/providers/local_learning_screen_contract_provider.dart`
2. Provider als normalen Riverpod-Provider umsetzen:
   - liest `localLearningViewModelProvider`
   - ruft `LocalLearningScreenContract.fromViewModelState(...)` auf
   - gibt `LocalLearningScreenContract` zurueck
3. Nur einen ersten Test schreiben:
   - `local_learning_screen_contract_provider_maps_view_model_state`
4. Test ohne UI, Supabase, Datenbank, Navigation und `WordUserView` halten.
5. Danach nur gezielt ausfuehren:
   - `flutter test test/core/local_database/local_learning_screen_contract_provider_test.dart`

Nicht im ersten Schritt:

- kein Screen
- keine Widgets
- keine Navigation
- keine Controller-Aktionen
- keine Session starten
- keine Antwort submitten
- keine Completion ausloesen
- keine bestehende App-Datei anfassen

## 7. Abschlussbewertung

Ein `LocalLearningScreenContract`-Provider ist ein sinnvoller naechster lokaler Lesebaustein.

Er macht die lokale Screen-Zustandsableitung testbar und spaeter leichter konsumierbar, ohne den bestehenden Lernscreen oder alte App-Flows zu beruehren.

Die sichere Reihenfolge bleibt:

1. ViewModelProvider stabil halten.
2. ScreenContract stabil halten.
3. ScreenContractProvider isoliert testen.
4. Danach erst entscheiden, ob ein isolierter lokaler Testscreen geplant wird.
