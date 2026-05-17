# Local LearnMode End-to-End State

## 1. Ausgangslage

Der lokale Offline-Flow wurde schrittweise von technischen Debug-Screens in die echte Talvori-UI integriert.

Ziel war, bestehende UI-Strukturen weiterzuverwenden und im lokalen Flow Supabase-/Online-Logik gezielt zu umgehen, statt separate Ersatz-Screens als Hauptweg weiter auszubauen.

## 2. Aktueller funktionierender Flow

Der aktuell bestätigte Simulator-Flow:

```text
Home
-> WordHub local
-> Health & Fitness
-> CategoryDetail local
-> Start
-> LearnMode local
```

## 3. Was funktioniert jetzt

- WordHub local zeigt wieder die alte WordHub-Taxonomie.
- `Health & Fitness` mappt aktuell auf `seed-category-basics`.
- CategoryDetail local öffnet korrekt.
- Der Startbutton öffnet LearnMode local.
- Eine lokale Karte erscheint.
- Tap dreht die Karte zur Rückseite/Übersetzung.
- Swipe links/rechts funktioniert.
- Stage-Counts aktualisieren sich aus lokalem Progress.
- Plasma-Link ist sichtbar.
- Der Ziel-Switch pulst nach Swipe.
- Die lokale Session läuft bis S5.
- `Neue Session starten` setzt den Progress zurück auf S0.
- Danach kann erneut gelernt werden.

## 4. Wichtige technische Bausteine

- `localLearningViewModelProvider`
- `localLearningControllerProvider`
- `LocalLearnModeUiAdapter`
- `LearnModeCardPresenter`
- `local_srs_session_service`
- `srs_review_persistence_service`
- `word_progress_repository`
- `StageSwitchRowView`
- `SwipeableWordCard`
- `PlasmaBandPainter`
- `SwitchPulsePainter`

## 5. Wichtige Commits

- `84c8452 feat: pulse local stage switch on swipe`
- `425dc1d fix: reset completed local sessions to stage zero`
- `653e72b feat: add local plasma link in learn mode`
- `dae77a7 fix: map local word hub to seeded category`
- `f35cbfa feat: show local swipeable card in learn mode`
- `9639a27 feat: add local learn mode frame`
- `f57f493 feat: redesign local category detail neon UI`
- `20a7e1c feat: use provider-free levels body in local detail`
- `53c33eb refactor: extract provider-free levels card view`

## 6. Tests

Zuletzt grün geprüfte Bereiche:

- `flutter test test/features/learn_mode_screen_local_branch_test.dart`
- `flutter test test/features/local_learning_debug/`
- `flutter test test/core/local_database/local_srs_session_service_test.dart`
- `flutter test test/core/local_database/word_progress_repository_test.dart`
- `flutter test test/core/local_database/local_session_read_service_test.dart`

Der Analyzer für `learn_mode_screen.dart` enthält weiterhin bekannte Alt-Warnungen/Infos, die nicht Teil dieses lokalen Flow-Abschlusses bereinigt wurden.

## 7. Bekannte offene Punkte

- Das Mapping ist aktuell exemplarisch: `health_fitness -> seed-category-basics`.
- Weitere WordHub-Kategorien müssen später sauber gemappt oder importiert werden.
- Die lokale Datenbasis ist aktuell ein Seed-/Testdatenstand.
- Header/Wheel im LearnMode kann später finalisiert werden.
- Der Bottom-Bereich im LearnMode ist noch frei.
- `learn_mode_screen.dart` enthält bekannte Analyzer-Alt-Warnungen.
- Eine finale Architekturübersicht oder ein Architekturdiagramm kann später ergänzt werden.

## 8. Nächster sinnvoller Schritt

Sinnvolle nächste Schritte sind:

- weitere Kategorien lokal mappen oder importieren,
- den LearnMode-Bottom-Bereich fachlich planen,
- oder Analyzer-/Alt-Code-Cleanup separat planen.
