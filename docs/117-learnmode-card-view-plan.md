# 117 LearnMode Card View Plan

Stand: 2026-05-15

## 1. Ziel

Ziel ist ein controller-neutraler `LearnModeCardView` als naechster Schritt zur Wiederverwendung der echten LearnMode-Karten-UI.

Der View soll:

- einen kleinen Karten-State anzeigen
- langfristig die echte LearnMode-Kartenoptik wiederverwendbar machen
- keine direkte Aenderung an `LearnModeScreen` erfordern
- keine direkte Aenderung an `LearnModeController` erfordern
- keine Supabase-Abhaengigkeit haben
- nicht an `WordUserView` gekoppelt sein

Der View ist der visuelle Nachfolger des reinen `LearnModeCardPresenter`.

## 2. Eingabe

Der View sollte als Eingabe nur bekommen:

- `LearnModeCardPresenterState`

Er darf nicht selbst lesen:

- Provider
- `LearnModeController`
- `LocalLearningController`
- `currentWordProvider`
- `WordUserView`
- Supabase
- Datenbank

Damit bleibt der View sowohl fuer lokale Daten als auch spaeter fuer alte Datenadapter nutzbar.

## 3. Anzeige

Der View sollte anzeigen koennen:

- `frontText`
- `backText`
- `exampleSentence`
- `notes`
- `stageLabel`
- `progressLabel`

Fuer den ersten Schritt reicht eine einfache, testbare Darstellung.

Empfohlene Anzeige fuer Version 1:

- Bei aktiver Karte:
  - Vorderseite/Text: `frontText`
  - Rueckseite/Antwort: `backText`
  - optional `exampleSentence`
  - optional `notes`
  - Stage als einfacher Text aus `stageLabel`
  - Fortschritt aus `progressLabel`

- Bei `hasCard == false`:
  - keine aktive Karte anzeigen
  - keine Fallback-Texte erfinden

- Bei `isCompleted == true`:
  - Completed-Zustand spaeter separat darstellen
  - im ersten Karten-View-Schritt nur sicherstellen, dass keine aktive Karte angezeigt wird

## 4. Optionale Aktionen

Der View sollte optional Callbacks bekommen:

- `onCorrect`
- `onWrong`
- `onFlip` spaeter optional

Wichtig:

- Der View liest keinen Controller.
- Der View entscheidet nicht selbst, ob eine Session gestartet wird.
- Der View fuehrt keine fachliche Aktion aus.
- Der View ruft nur uebergebene Callbacks auf.

Fuer Version 1 kann sogar noch ohne Aktionen gestartet werden:

- erst Darstellung aktiver Karte
- danach `onCorrect`
- danach `onWrong`
- spaeter optional `onFlip`

## 5. Spaeter Wiederverwendbare Echte UI-Teile

Langfristig wiederverwendbar aus der bestehenden LearnMode-UI:

- Kartenlayout
- Farben
- Stage-Anzeige
- Progress-Anzeige
- Button-Stile
- Teile der Swipe-/Flip-Optik
- spaeter ggf. `SwipeableWordCard`, wenn sie mit neutralen Props sicher nutzbar bleibt

Nicht direkt uebernehmen:

- alte Provider-Zugriffe
- alte `currentWordProvider`-Logik
- alte Queue-/Index-Pruefungen
- alte `WordUserView`-Abhaengigkeit
- alte Timer-/FinalRound-/Hybrid-Logik
- automatische Controller-Aktionen

Der erste View sollte deshalb klein starten und nur die neutrale Kartenanzeige beweisen.

## 6. Was Nicht Passieren Darf

`LearnModeCardView` darf nicht:

- `LearnModeController` lesen
- `learnModeControllerProvider` lesen
- `currentWordProvider` lesen
- `WordUserView` kennen
- Supabase kennen
- eine Session starten
- einen Import starten
- Navigation ausloesen
- Datenbankzugriff haben
- bestehende App-Flows aendern
- `LearnModeScreen` automatisch ersetzen

Der View darf nur Props anzeigen und optionale Callbacks ausloesen.

## 7. Spaeter Sinnvolle Tests

Sinnvolle Tests:

- `learnmode_card_view_shows_active_card`
  - rendert `frontText`
  - rendert `backText`
  - rendert `exampleSentence`
  - rendert `notes`
  - rendert `stageLabel`
  - rendert `progressLabel`

- `learnmode_card_view_hides_card_when_no_card`
  - bei `hasCard == false` keine aktive Karte
  - keine Fallback-Texte

- `learnmode_card_view_calls_correct_callback`
  - Button/Tap fuer correct ruft nur Callback
  - keine Controller-Abhaengigkeit

- `learnmode_card_view_calls_wrong_callback`
  - Button/Tap fuer wrong ruft nur Callback
  - keine Controller-Abhaengigkeit

- `learnmode_card_view_does_not_require_supabase_or_worduserview`
  - indirekt durch Widget-Test mit reinem `LearnModeCardPresenterState`

## 8. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt:

- Einen isolierten `LearnModeCardView` erstellen, der nur eine aktive Karte aus `LearnModeCardPresenterState` rendert.

Moegliche Datei:

- `lib/features/local_learning_debug/ui/learnmode_card_view.dart`

oder spaeter, wenn wirklich shared gewollt:

- `lib/features/words/ui/widgets/learnmode_card_view.dart`

Empfehlung fuer den ersten Schritt:

- im lokalen Debug-Bereich starten, um keine bestehende Produkt-UI zu beruehren
- erst spaeter bewusst entscheiden, ob der View in den shared/words-UI-Bereich wandert

Moegliche Testdatei:

- `test/features/local_learning_debug/learnmode_card_view_test.dart`

Erster Test:

- `learnmode_card_view_shows_active_card`

Testidee:

1. Erzeuge `LearnModeCardPresenterState` mit:
   - `hasCard: true`
   - `frontText: hello`
   - `backText: hallo`
   - `exampleSentence: Hello, how are you?`
   - `notes: Common greeting.`
   - `stageLabel: s0`
   - `progressLabel: 1 / 3`
   - `canSubmitAnswer: true`
   - `isCompleted: false`
2. Rendere `LearnModeCardView`.
3. Pruefe sichtbare Texte.
4. Pruefe indirekt:
   - kein Supabase
   - kein `WordUserView`
   - keine Provider
   - keine Session
   - kein Import

Nicht Teil des ersten Schritts:

- keine `LearnModeScreen`-Aenderung
- keine `CardArea`-Aenderung
- keine Navigation
- keine lokalen Controller-Aktionen
- keine alte Swipe-/Queue-Logik
