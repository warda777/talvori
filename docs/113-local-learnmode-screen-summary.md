# 113 Local LearnMode Screen Summary

Stand: 2026-05-15

## 1. Aufgabe

`LocalLearnModeScreen` ist eine isolierte lokale LearnMode-nahe Screen-Variante im Debug-Bereich.

Er dient dazu, die lokale Offline-first-Lernkette UI-nah darzustellen, ohne den bestehenden produktiven `LearnModeScreen` oder den alten `LearnModeController` umzubauen.

Der Screen ist ein Zwischenschritt zwischen dem technischen `LocalLearningTestScreen` und einer spaeteren kontrollierten Produktintegration.

## 2. Lokale Datenquelle

Der Screen nutzt:

- `localLearningViewModelProvider`
- `LocalLearnModeUiAdapter`

Ablauf:

1. `localLearningViewModelProvider` liefert `LocalLearningViewModelState`.
2. `LocalLearnModeUiAdapter` mappt diesen State auf `LocalLearnModeUiState`.
3. `LocalLearnModeScreen` rendert ausschliesslich aus dem lokalen UI-State.

Der Screen oeffnet keine Datenbank direkt, kennt kein Supabase und erzeugt kein `WordUserView`.

## 3. Darstellbare Zustaende

Aktuell kann `LocalLearnModeScreen` diese Zustaende darstellen:

- Active Card
- Loading
- Error
- Empty / No Session
- Completed

Bei Loading zeigt der Screen:

- `Laedt...`

Bei Error zeigt der Screen:

- `Fehler`
- die vorhandene `errorMessage`

Bei Empty / No Session zeigt der Screen:

- `Keine aktive lokale Session`

Bei Completed zeigt der Screen:

- `Session abgeschlossen`
- das Fortschrittslabel, z. B. `3 / 3`

## 4. Aktive Karte

Bei einer aktiven Karte zeigt der Screen:

- `term`
- `translation`
- `exampleSentence`, falls vorhanden
- `notes`, falls vorhanden
- `currentStage`
- `progressLabel`

Der Fortschritt wird aktuell als einfacher Text dargestellt, z. B.:

- `Fortschritt 1 / 3`

## 5. Tests

Die Tests liegen in:

- `test/features/local_learning_debug/local_learn_mode_screen_test.dart`

Aktuell existieren:

- `local_learnmode_screen_shows_active_card`
  - prueft die aktive lokale Karte
  - prueft Begriff, Uebersetzung, Beispielsatz und Notizen
  - prueft Stage-Anzeige
  - prueft Fortschritt `1 / 3`

- `local_learnmode_screen_handles_loading_error_empty`
  - prueft Loading-Zustand
  - prueft Error-Zustand inklusive vorhandener Fehlermeldung
  - prueft Empty-/No-Session-Zustand

- `local_learnmode_screen_handles_completed_state`
  - prueft Completed-Zustand
  - prueft Fortschritt `3 / 3`
  - prueft, dass keine aktive Karte angezeigt wird
  - prueft, dass keine Submit-Aktionen angezeigt werden

Die Tests nutzen Provider-Overrides und brauchen kein Supabase, kein `WordUserView`, keine echte Datenbank und keinen Import.

## 6. Grenzen

Weiterhin gilt:

- kein Supabase
- kein `WordUserView`
- keine Produktnavigation
- kein `LearnModeScreen`-Umbau
- kein `LearnModeController`-Umbau
- keine automatische Session
- kein automatischer Import
- keine direkte Datenbankoeffnung im Screen
- keine bestehende App-Flow-Aenderung

Der Screen ist weiterhin lokal und isoliert im Debug-Bereich.

## 7. Aktuelle Stabilitaetschecks

Zuletzt gruen:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter test test/features/local_learning_debug/`
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`

Ergebnis:

- 219 lokale Tests bestanden
- gezielter Analyzer: `No issues found`

Hinweis:

- Flutter meldete weiterhin Paket-Updates als Hinweis: `76 packages have newer versions incompatible with dependency constraints`
- Es gab keine Testfehler und keine Analyzer-Probleme

## 8. Naechste Schritte

Sinnvoll:

- `LocalLearnModeScreen` als abgeschlossen markieren
- danach Aktionen `Correct`, `Wrong` und `Start` separat planen
- spaeter die UI optisch naeher an die bestehende `LearnModeScreen`-UI bringen
- bestehenden `LearnModeScreen` weiterhin nicht direkt umbauen
- bestehenden `LearnModeController` weiterhin nicht direkt umbauen

Nicht empfohlen:

- keine direkte Produktnavigation
- kein automatischer Sessionstart beim Screen-Build
- kein `WordUserView`-Fake
- keine Vermischung mit der alten Supabase-nahen Lernkette
