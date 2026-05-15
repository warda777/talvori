# 115 LearnMode Card Presenter Plan

Stand: 2026-05-15

## 1. Ziel

Ziel ist ein controller-neutraler LearnMode-Karten-Presenter als erster kleiner Baustein zur Wiederverwendung der echten LearnMode-UI.

Der Presenter soll:

- den Kartenbereich der bestehenden LearnMode-UI vorbereiten
- lokale Kartendaten in visuell nutzbare Kartenfelder uebersetzen
- keine direkte Aenderung an `LearnModeScreen` erzwingen
- keine direkte Aenderung an `LearnModeController` erzwingen
- keine Supabase-Abhaengigkeit haben
- kein `WordUserView` erzeugen oder erwarten

Er ist bewusst kein Widget. Er bereitet nur Daten fuer einen spaeteren controller-neutralen Karten-View vor.

## 2. Eingabe

Fuer Version 1 sollte der Presenter als Eingabe nutzen:

- `LocalLearnModeUiState`

Diese Eingabe ist bereits UI-nah und kommt aus:

1. `localLearningViewModelProvider`
2. `LocalLearningViewModelAdapter`
3. `LocalLearnModeUiAdapter`

Spaeter kann ein zweiter Adapter ergaenzt werden, der alte `LearnModeState`-Daten auf denselben Karten-Presenter-State abbildet.

Wichtig:

- Version 1 liest keinen Provider.
- Version 1 kennt keinen `LearnModeController`.
- Version 1 kennt keinen `WordUserView`.
- Version 1 nutzt keine Datenbank.

## 3. Ausgabe

Der Presenter sollte einen kleinen Karten-State erzeugen, z. B.:

- `frontText`
- `backText`
- `exampleSentence`
- `notes`
- `stageLabel`
- `progressLabel`
- `canSubmitAnswer`
- `hasCard`
- `isCompleted`

Sinnvolle erste Mapping-Regeln:

- `hasCard` wird aus `LocalLearnModeUiState.hasCard` uebernommen.
- `frontText` kann zunaechst aus `term` entstehen.
- `backText` kann zunaechst aus `translation` entstehen.
- `exampleSentence` wird uebernommen.
- `notes` wird uebernommen.
- `stageLabel` wird aus `currentStage?.name` gebildet.
- `progressLabel` wird uebernommen.
- `canSubmitAnswer` wird uebernommen.
- `isCompleted` wird uebernommen.

Der Presenter sollte keine Spracheinstellungen, Flip-Logik, Timer-Logik oder alte Stage-/PassCount-Semantik hineinziehen.

## 4. Warum Dieser Presenter Sinnvoll Ist

Der bestehende `LearnModeScreen` ist visuell wertvoll, aber aktuell stark an alte Controller- und Provider-Strukturen gekoppelt.

Besonders `CardArea` liest direkt:

- `currentWordProvider`
- `learnModeControllerProvider`
- `isPausedProvider`
- `primaryLanguageProvider`

Der Presenter schafft eine schmale Grenze:

- lokale Lernkette -> `LocalLearnModeUiState`
- Karten-Presenter -> controller-neutraler Karten-State
- spaeterer Karten-View -> echte UI-nahe Darstellung

Vorteile:

- trennt visuelle Karte von alter Controller-Logik
- macht die Kartenanzeige ohne Supabase testbar
- verhindert ein kuenstliches `WordUserView`
- kann spaeter sowohl vom lokalen Pfad als auch vom alten Pfad gespeist werden
- reduziert das Risiko, `LearnModeScreen` direkt mit lokalen Branches zu ueberladen

Der Presenter ist damit der kleinste sichere Schritt in Richtung echter UI-Wiederverwendung.

## 5. Was Nicht Passieren Darf

Der Presenter darf nicht:

- `WordUserView` erzeugen
- `WordUserView` importieren
- `LearnModeController` lesen
- `learnModeControllerProvider` lesen
- `localLearningViewModelProvider` lesen
- irgendeinen Provider lesen
- UI bauen
- Navigation ausloesen
- Aktionen ausfuehren
- eine Session starten
- einen Import starten
- Supabase kennen
- Datenbankzugriff haben
- alte `passCount`-/`streak`-/Queue-Semantik rekonstruieren

Er bleibt ein reiner Mapping-Baustein.

## 6. Spaeter Sinnvolle Tests

Sinnvolle Tests:

- `learnmode_card_presenter_maps_local_active_card`
  - prueft aktive Karte
  - prueft `frontText`
  - prueft `backText`
  - prueft `exampleSentence`
  - prueft `notes`
  - prueft `stageLabel`
  - prueft `progressLabel`
  - prueft `canSubmitAnswer`

- `learnmode_card_presenter_handles_empty_state`
  - prueft `hasCard == false`
  - prueft leere oder null Kartenfelder
  - prueft, dass kein Fallback-Text erfunden wird

- `learnmode_card_presenter_handles_completed_state`
  - prueft `isCompleted == true`
  - prueft Fortschrittslabel
  - prueft, dass keine aktive Karte entsteht

- `learnmode_card_presenter_does_not_require_worduserview_or_supabase`
  - indirekt ueber reine Unit-Tests ohne Provider, DB und Supabase

Spaeter, nach einem zweiten alten Adapter:

- `learnmode_card_presenter_can_be_fed_from_legacy_learnmode_state_adapter`

Dieser Test sollte erst kommen, wenn der alte Pfad separat und bewusst geplant wurde.

## 7. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt:

- Einen reinen Presenter fuer lokale aktive Karten implementieren.

Moegliche Datei:

- `lib/core/local_database/adapters/learnmode_card_presenter.dart`

Moegliche Testdatei:

- `test/core/local_database/learnmode_card_presenter_test.dart`

Erster Test:

- `learnmode_card_presenter_maps_local_active_card`

Testidee:

1. Erzeuge einen `LocalLearnModeUiState` mit aktiver Karte:
   - `term: hello`
   - `translation: hallo`
   - `exampleSentence: Hello, how are you?`
   - `notes: Common greeting.`
   - `currentStage: SrsStage.s0`
   - `progressLabel: 1 / 3`
   - `canSubmitAnswer: true`
   - `hasCard: true`
   - `isCompleted: false`
2. Mappe mit dem Presenter.
3. Pruefe:
   - `frontText == hello`
   - `backText == hallo`
   - `exampleSentence` stimmt
   - `notes` stimmt
   - `stageLabel == s0`
   - `progressLabel == 1 / 3`
   - `canSubmitAnswer == true`
   - `hasCard == true`
   - `isCompleted == false`

Nicht Teil dieses Schritts:

- keine Widget-Extraktion
- keine `LearnModeScreen`-Aenderung
- keine `CardArea`-Aenderung
- keine Provider-Anbindung
- keine Aktionen
- keine Supabase- oder `WordUserView`-Abhaengigkeit
