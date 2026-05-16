# 123 LearnModeScreen First Local Branch Plan

Stand: 2026-05-16

## 1. Dateien Im Ersten Schritt

Der erste Code-Schritt sollte bewusst klein bleiben.

Voraussichtlich zu aendern:

- `lib/features/words/ui/screens/learn_mode_screen.dart`
- ein neuer oder bestehender Widget-Test fuer den echten LearnModeScreen, z. B.:
  - `test/features/words/learn_mode_screen_local_branch_test.dart`
  - oder ein passender vorhandener Testpfad, falls es bereits eine Struktur fuer Words-UI-Screen-Tests gibt

Nicht im ersten Schritt aendern:

- `lib/features/words/application/learn_mode_controller.dart`
- `lib/features/words/application/word_providers.dart`
- `lib/features/words/data/supabase_word_repository.dart`
- lokale Controller-/Repository-/SQLite-Schichten
- bestehende Debug-Screens

Der erste Schritt ist kein visueller Umbau und keine Produktnavigation.

## 2. Lokale Modus-Parameter

`LearnModeScreen` sollte einen optionalen lokalen Modus bekommen.

Sinnvolle Parameter:

- `bool useLocalOfflineFlow = false`
- `String? localCategoryId`

Regeln:

- Default bleibt `useLocalOfflineFlow == false`.
- Bestehende Aufrufe von `LearnModeScreen` bleiben dadurch unveraendert.
- `localCategoryId` wird nur verwendet, wenn `useLocalOfflineFlow == true`.
- Wenn `useLocalOfflineFlow == true` und `localCategoryId == null`, soll der lokale Branch keinen impliziten Fallback auf `basics` erzeugen.
- `categoryId` und `title` bleiben fuer den alten Flow erhalten.

Optional spaeter, nicht im ersten Schritt:

- `DateTime Function()? nowProvider`
- lokale Mode-/TrainingArea-Parameter
- lokale Kategorieanzeige bzw. lokaler Titel

## 3. Schutz Des Alten Supabase-Flows

Der alte Flow wird geschuetzt, indem der lokale Modus strikt opt-in bleibt.

Schutzregeln:

- Ohne `useLocalOfflineFlow` laeuft exakt der bestehende Codepfad.
- Keine Aenderung an `LearnModeController`.
- Keine Aenderung an `word_providers.dart`.
- Keine Aenderung an `SupabaseWordRepository`.
- Keine Aenderung an `WordUserView`.
- Keine Aenderung an bestehenden Navigationsaufrufen.
- Keine lokale Logik wird in alte Provider gepresst.

Der lokale Branch muss frueh genug greifen:

- vor alter Controller-Initialisierung
- vor alten `ref.listen`-Subscriptions
- vor altem `currentWordProvider`
- vor altem `HeaderBar`, `CardArea`, `StageSwitchRow` und `BottomControls`, solange diese alte Provider lesen

## 4. `initState`-Aufrufe, Die Lokal Nicht Laufen Duerfen

Im lokalen Modus duerfen diese bestehenden Initialisierungen nicht laufen:

- `_stagesSub = ref.listenManual<LearnModeState>(learnModeControllerProvider, ...)`
- `_controller = ref.read(learnModeControllerProvider.notifier)`
- `_controller.setInLearnScreen(true)`
- `_controller.init(...)`
- `_showLinkForCurrentCard()` als Folge alter Queue-/Stage-Logik

AnimationController wie `fx` und `pulse` sind technisch UI-nah, aber im ersten lokalen Schritt sollten sie entweder weiter initialisiert werden, ohne alte Provider zu lesen, oder der lokale Branch rendert eine eigene minimale Struktur ohne FX-Overlay. Risikoaermer ist: lokaler Branch rendert vorerst ohne Plasma-/Pulse-Overlay.

Auch in `dispose` muss gegated werden:

- `_controller.setInLearnScreen(false)` darf im lokalen Modus nicht aufgerufen werden, wenn `_controller` nicht fuer den lokalen Modus initialisiert wurde.
- `_stagesSub?.close()` ist unkritisch, wenn die Subscription im lokalen Modus null bleibt.

## 5. Erlaubte Lokale Provider Im Lokalen Modus

Im ersten lokalen Branch duerfen nur lokale Offline-first-Provider gelesen werden:

- `localLearningViewModelProvider`
- `localLearningControllerProvider`

Erlaubte lokale Adapter:

- `LocalLearnModeUiAdapter`
- `LearnModeCardPresenter`

Erlaubte lokale Aktionen:

- `localLearningControllerProvider.notifier.startOrResume(...)`
- `localLearningControllerProvider.notifier.submitCorrect(...)`
- `localLearningControllerProvider.notifier.submitWrong(...)`

Nicht im ersten Schritt noetig:

- `completeIfFinished(...)`, ausser der lokale Branch zeigt bereits einen Completed-State mit explizitem Abschlussbutton.

Nicht erlaubt im lokalen Branch:

- `learnModeControllerProvider`
- `currentWordProvider`
- `WordUserView`
- `categoriesProvider`
- `isLoadingProvider`
- `isPlayingProvider`
- `isPausedProvider`
- `srsModeControllerProvider`, falls dadurch alte globale SRS-Logik gekoppelt wird
- Supabase-nahe Provider

## 6. Bestehende UI-Abschnitte Fuer Den Ersten Lokalen Modus

Der erste lokale Modus soll beweisen, dass der echte `LearnModeScreen` lokal geoeffnet werden kann, ohne den alten Flow zu starten.

Deshalb im ersten Schritt nur die grobe bestehende Struktur wiederverwenden:

- `Scaffold`
- `SafeArea`
- `Stack` oder `Column`-Grundstruktur
- dunkler LearnMode-Hintergrund
- Header-Position oben
- zentraler Kartenbereich
- unterer Action-Bereich

Noch nicht direkt wiederverwenden:

- `HeaderBar`, weil es alte Provider liest
- `CardArea`, weil es `currentWordProvider` und alten Controller liest
- `BottomControls`, weil es alte Timer-/FinalRound-/Reset-Logik ausfuehrt
- `StageSwitchRow`, solange es intern alte Provider lesen kann

Moeglicher erster sichtbarer lokaler Inhalt:

- Titel/Name aus `title` oder `localCategoryId`
- Empty-State: `Starten/Fortsetzen`
- Active-Card-Daten ueber `LocalLearnModeUiAdapter` und `LearnModeCardPresenter`
- einfache lokale Buttons `Richtig` / `Falsch`

Das ist noch kein finaler visueller Wiederaufbau. Es ist der Sicherheitsbeweis im echten Screen.

## 7. Lokale Aktionen Im Ersten Schritt

Im lokalen Modus werden Aktionen explizit ausgelöst, nie automatisch.

### `startOrResume`

Nur bei Tap auf `Starten/Fortsetzen`.

Parameter:

- `categoryId: localCategoryId`
- `mode: LearningMode.adaptive`
- `trainingArea: TrainingArea.all`
- `now: DateTime.now()` oder spaeter `nowProvider`

Wichtig:

- Kein Start im `build`.
- Kein Start in `initState`.

### `submitCorrect`

Nur bei Tap auf `Richtig`.

Aktion:

- `localLearningControllerProvider.notifier.submitCorrect(now: now)`

### `submitWrong`

Nur bei Tap auf `Falsch`.

Aktion:

- `localLearningControllerProvider.notifier.submitWrong(now: now)`

Noch nicht im ersten Schritt:

- Swipe-Commit ueber alte `SwipeableWordCard`
- Plasma-Link
- Stage-Pulse
- alte Timer-Controls
- FinalRound-Logik

## 8. Ausdruecklich Nicht Geaendert

Im ersten Code-Schritt unveraendert:

- `LearnModeController`
- `SupabaseWordRepository`
- `WordUserView`
- `word_providers.dart`
- alte SRS-/Queue-/Timer-/Hybrid-/FinalRound-Logik
- lokale SQLite-/Repository-/Import-Schichten
- bestehende Produktnavigation
- `CategoryDetailScreen`
- `WordHubScreen`

Keine Supabase-Entfernung.

Kein `WordUserView`-Fake fuer lokale Daten.

Keine automatische Migration.

## 9. Tests Fuer Den Ersten Code-Schritt

Der erste Test sollte nicht beweisen, dass die gesamte lokale UI fertig ist. Er soll beweisen, dass der echte `LearnModeScreen` lokal geoeffnet werden kann, ohne den alten Flow zu starten.

Empfohlener Test:

- `learn_mode_screen_local_mode_opens_without_starting_old_flow`

Pruefen:

- `LearnModeScreen(useLocalOfflineFlow: true, localCategoryId: 'basics', categoryId: 'legacy-id', title: 'Basics')` rendert.
- Lokaler Empty-State oder lokaler Startbereich ist sichtbar.
- `Starten/Fortsetzen` ist sichtbar.
- Kein alter `HeaderBar`-Providerzugriff ist noetig.
- Kein `currentWordProvider` ist noetig.
- Kein `WordUserView` ist noetig.
- Kein Supabase ist noetig.
- Kein Import startet.
- Keine lokale Session startet beim Rendern.

Wenn technisch sauber moeglich, zusaetzlich absichern:

- `learnModeControllerProvider` wird im lokalen Modus nicht initialisiert bzw. sein State bleibt initial.
- `localLearningViewModelProvider` kann im Test ueberschrieben werden.
- Tap auf `Starten/Fortsetzen` ruft den lokalen Controllerpfad nur explizit auf.

Minimaler zweiter Test, falls der erste zu breit wird:

- `learn_mode_screen_default_mode_keeps_existing_constructor_behavior`

Dieser Test sollte nur absichern, dass die neuen Parameter optional sind und bestehende Konstruktion weiterhin moeglich bleibt. Er muss nicht den ganzen alten Supabase-Flow ausfuehren.

## 10. Exakter Kleinster Implementierungsschritt

Der kleinste sinnvolle Code-Schritt:

1. `LearnModeScreen` um zwei optionale Parameter erweitern:
   - `useLocalOfflineFlow = false`
   - `localCategoryId`
2. In `_LearnModeScreenState` eine lokale Hilfsentscheidung einfuehren:
   - lokaler Modus ist aktiv, wenn `widget.useLocalOfflineFlow == true`
3. `initState` so gaten, dass im lokalen Modus diese alte Initialisierung nicht laeuft:
   - keine `learnModeControllerProvider`-Subscription
   - kein `_controller = ref.read(...)`
   - kein `setInLearnScreen(true)`
   - kein `_controller.init(...)`
4. `dispose` so gaten, dass im lokalen Modus kein alter Controller-State geschrieben wird.
5. Am Anfang von `build` einen lokalen Branch einfuehren:
   - liest `localLearningViewModelProvider`
   - mappt ueber `LocalLearnModeUiAdapter`
   - rendert eine kleine lokale LearnMode-Struktur im echten `LearnModeScreen`
   - zeigt ohne Session `Starten/Fortsetzen`
   - zeigt bei aktiver Karte lokale Kartentexte und `Richtig`/`Falsch`
6. Bestehenden alten `build`-Pfad unveraendert lassen, wenn `useLocalOfflineFlow == false`.

Nicht Teil dieses ersten Schritts:

- bestehende `HeaderBar`, `CardArea`, `BottomControls` oder `StageSwitchRow` neutralisieren
- `SwipeableWordCard` lokal anbinden
- Produktnavigation umstellen
- CategoryDetail-Startpfad auf lokalen Modus umlegen
- Supabase entfernen

Erfolgskriterium:

Der echte `LearnModeScreen` kann mit `useLocalOfflineFlow: true` im lokalen Modus gerendert werden, ohne den alten Supabase-/LearnModeController-Flow zu starten.
