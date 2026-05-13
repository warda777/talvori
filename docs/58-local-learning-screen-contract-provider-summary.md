# 58 Local Learning Screen Contract Provider Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den `localLearningScreenContractProvider` zusammen.

Der Provider ist eine isolierte, abgeleitete Riverpod-Leseschicht fuer die lokale Offline-first-Lernkette. Er liest den lokalen ViewModel-State und stellt daraus einen `LocalLearningScreenContract` bereit.

Er ist noch kein Screen, keine UI-Anbindung und kein Ersatz fuer bestehende App-Flows.

## Aufgabe Des Providers

Datei:

- `lib/core/local_database/providers/local_learning_screen_contract_provider.dart`

Der Provider uebernimmt:

- `localLearningViewModelProvider` lesen
- `LocalLearningScreenContract.fromViewModelState(...)` aufrufen
- `LocalLearningScreenContract` bereitstellen

Der Provider macht nicht:

- keine Session starten
- keine Antwort submitten
- keine Completion ausloesen
- keine Controller-Methoden aufrufen
- keine Datenbank oeffnen
- keine Repositorys lesen
- kein Supabase kennen
- kein `WordUserView` kennen
- keine UI-Widgets kennen
- keine Navigation ausloesen
- keine UI-Texte erzeugen

## Datenquelle

Die einzige Datenquelle ist:

- `localLearningViewModelProvider`

Der Provider liest daraus:

- `LocalLearningViewModelState`

Wichtig:

- Der Provider liest nicht `localLearningControllerProvider.notifier`.
- Der Provider liest nicht `localLearningSessionFacadeProvider`.
- Der Provider oeffnet keine Datenbank.

## Ableitung Des LocalLearningScreenContract

Die Ableitung ist:

1. `ref.watch(localLearningViewModelProvider)`
2. `LocalLearningScreenContract.fromViewModelState(viewModelState)`
3. Rueckgabe des Contracts

Damit bleibt die lokale Lesekette klar:

- `LocalLearningController` verwaltet Aktionen und lokalen Controller-State.
- `localLearningViewModelProvider` stellt UI-nahe Daten bereit.
- `LocalLearningScreenContract` leitet boolesche Screen-Zustaende ab.
- `localLearningScreenContractProvider` stellt diesen Contract fuer spaetere Leser bereit.

## Ausgabe

Die Ausgabe ist:

- `LocalLearningScreenContract`

Dieser Contract enthaelt:

- `isInitial`
- `isLoading`
- `hasError`
- `hasActiveCard`
- `isCompleted`
- `canShowSubmitActions`

Der Provider gibt nur diese abgeleiteten Screen-Zustaende weiter. Er erzeugt keine Texte, keine Labels und keine Navigation.

## Tests

Datei:

- `test/core/local_database/local_learning_screen_contract_provider_test.dart`

Vorhandene Tests:

- `local_learning_screen_contract_provider_maps_view_model_state`
- `local_learning_screen_contract_provider_does_not_start_session_or_submit`

### local_learning_screen_contract_provider_maps_view_model_state

Sichert ab:

- `localLearningViewModelProvider` kann kontrolliert ueberschrieben werden.
- Provider liest den ViewModel-State.
- Rueckgabe ist ein `LocalLearningScreenContract`.
- Aktiver Karten-State ergibt `hasActiveCard == true`.
- `canSubmitAnswer == true` und aktive Karte ergeben `canShowSubmitActions == true`.
- `isInitial == false`.
- `isCompleted == false`.
- keine Datenbank ist erforderlich.
- keine Supabase-Initialisierung ist erforderlich.
- keine `WordUserView`-Instanz ist erforderlich.

### local_learning_screen_contract_provider_does_not_start_session_or_submit

Sichert ab:

- Reines Lesen des Providers startet keine Session.
- Reines Lesen loest keine Submit-Aktion aus.
- Reines Lesen loest keine Completion aus.
- Ein ViewModel-State ohne Session bleibt `isInitial == true`.
- `hasActiveCard == false`.
- `canShowSubmitActions == false`.
- keine Datenbank ist erforderlich.
- keine Supabase-Initialisierung ist erforderlich.
- keine UI ist erforderlich.

## Weiterhin Geltende Grenzen

Weiterhin nicht umgesetzt:

- keine UI-Anbindung
- kein lokaler Screen
- keine Widgets
- keine Navigation
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`
- keine Provider-Ersetzung in bestehenden App-Flows
- keine Supabase-Entfernung
- keine Supabase-Migration
- keine Modusbutton-UI-Aenderung
- keine Completion-Meldungen
- keine finalen UI-Texte
- keine Mapping-Schicht zu `WordUserView`
- keine automatische Session-Erzeugung durch Lesen des Providers

Der Contract-Provider ist bewusst nur ein lokaler Lesebaustein.

## Aktuelle Stabilitaetschecks

Der zuletzt ausgefuehrte lokale Stabilitaetscheck war gruen:

- `flutter test test/core/srs/`
  - 39 Tests bestanden
- `flutter test test/core/local_database/`
  - 105 Tests bestanden
- `flutter analyze lib/core/srs lib/core/local_database test/core/srs test/core/local_database`
  - `No issues found!`

Damit waren zuletzt 144 lokale Tests fuer SRS, SQLite, Repository, Read-State, Facade, Factory, Seed, Bootstrap, Provider, Controller, Adapter, ViewModelProvider, ScreenContract und ScreenContractProvider gruen.

## Warum Weiterhin Keine Bestehende UI-/App-Flow-Anbindung

Eine direkte Anbindung an bestehende UI- oder App-Flows sollte weiterhin nicht erfolgen.

Gruende:

- Der Provider stellt nur boolesche Screen-Zustaende bereit.
- Es gibt noch keinen lokalen Screen und keine getestete Widget-Schicht.
- `learn_mode_screen.dart` ist weiterhin an alte Swipe-, Stage-, Animation- und `WordUserView`-Strukturen gekoppelt.
- `learn_mode_controller.dart` enthaelt weiterhin alte Supabase-, Queue-, Timer- und SRS-Logik.
- Supabase und lokale SQLite-Schicht laufen noch parallel.
- UI-Texte, Buttontexte, Modusnamen und Completion-Meldungen sind noch nicht final an die lokale UI gebunden.
- Eine zu fruehe UI-Anbindung koennte alte und neue Fortschrittslogik vermischen.

Der Provider ist ein sicherer Vorbereitungsschritt, aber noch kein produktiver Umschaltpunkt.

## Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte:

1. ScreenContractProvider-Block dokumentiert als abgeschlossen betrachten.
2. Vollstaendigen lokalen Stabilitaetscheck vor jeder weiteren Integration erneut ausfuehren.
3. Entscheiden, ob als naechstes ein isolierter lokaler Testscreen geplant werden soll.
4. Falls ja, zuerst eine Testscreen-Planungsdatei erstellen:
   - keine bestehende Navigation
   - keine bestehende UI ersetzen
   - keine Supabase-Datenquelle
   - nur lokale Provider-Kette
   - klare Rueckbaugrenze
5. Alternativ zuerst UI-Text-/Labelstrategie fuer lokale Lernmodi und Trainingsbereiche konkretisieren.
6. Bestehenden `learn_mode_screen.dart` und `LearnModeController` erst anfassen, wenn die lokale UI-nahe Kette bewusst und separat integriert werden soll.
