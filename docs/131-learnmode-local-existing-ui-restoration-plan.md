# LearnMode Local Existing UI Restoration Plan

## 1. Ausgangslage

Der lokale Offline-Flow funktioniert technisch:

`WordHub local -> CategoryDetail local -> Start -> LearnModeScreen local`

Der Start aus dem lokalen `CategoryDetailScreen` oeffnet bereits `LearnModeScreen(useLocalOfflineFlow: true, localCategoryId: ...)`.

Der aktuelle lokale LearnMode-Branch ist aber nur eine einfache Empty-/Start-UI mit Text und Button. Ziel ist nicht ein Ersatzscreen, sondern die alte LearnMode-Optik mit lokaler Daten- und Controllerlogik darunter.

## 2. Problem

`LearnModeScreen.build()` zweigt bei `useLocalOfflineFlow` direkt zu `_buildLocalOfflineFlow(context)` ab.

Dadurch wird der alte vollstaendige LearnMode-Aufbau komplett umgangen. Im lokalen Branch fehlen aktuell:

- Wheel/Header
- grosse Kartenflaeche
- Swipe-Karte
- Stage-Switches
- Plasma-Link
- BottomControls

## 3. Alte LearnMode-Bausteine

Der alte visuelle LearnMode-Aufbau besteht im Kern aus:

- `HeaderBar`
- `CategoryWheel`
- `CardArea`
- `SwipeableWordCard`
- `StageSwitchRow` / `StageSwitchRowView`
- `BottomControls`
- `PlasmaBandPainter`
- `SwitchPulsePainter`
- Keys und Rects fuer Plasma-Link und Pulse-FX

## 4. Provider-/Controller-Kopplungen

Einige alte Bausteine sind visuell relevant, aber nicht direkt lokal wiederverwendbar, weil sie alte Provider oder Controller lesen:

- `CardArea` liest alte Provider wie `currentWordProvider`, `learnModeControllerProvider`, `isPausedProvider`, `primaryLanguageProvider`
- `BottomControls` liest alte Controller-, Timer- und Tooltip-Provider
- `StageSwitchRow` als Wrapper liest alte Provider
- alte Swipe-Commit-Methoden haengen am alten `LearnModeController`
- alte Queue-, FinalRound-, Hybrid- und Timer-Logik ist nicht direkt fuer den lokalen Flow geeignet

Diese Kopplungen duerfen nicht blind in den lokalen Branch uebernommen werden.

## 5. Bereits lokale Bausteine

Fuer die lokale LearnMode-Kette existieren bereits:

- `localLearningViewModelProvider`
- `localLearningControllerProvider`
- `LocalLearnModeUiAdapter`
- `LearnModeCardPresenter`
- `LearnModeCardView` aus dem Debug-Bereich
- lokale Actions `startOrResume`, `submitCorrect`, `submitWrong`

Diese Bausteine liefern den lokalen Daten- und Aktionspfad ohne Supabase und ohne alten `LearnModeController`.

## 6. Sicher wiederverwendbare UI-Teile

Voraussichtlich sicher wiederverwendbar:

- `HeaderBar` mit `customWheelLabels`
- `CategoryWheel`, sofern provider-frei genutzt
- `SwipeableWordCard`, wenn rein ueber Props und Callbacks versorgt
- `StageSwitchRowView`
- `PlasmaBandPainter`, wenn lokale Card-/Switch-Rects geliefert werden

Nicht direkt verwenden:

- `CardArea`, solange es alte Provider liest
- `BottomControls`, solange es alte Controller-/Timer-Provider liest
- `StageSwitchRow` Wrapper, solange er alte Provider liest

## 7. Zielstruktur

Der geplante lokale `LearnModeScreen` soll den alten visuellen Rahmen nutzen:

- alter Header/Wheel oben
- lokale Kartenflaeche
- `SwipeableWordCard` fuer die Wortkarte
- Tap auf Karte dreht Vorder-/Rueckseite
- Swipe rechts -> `localLearningControllerProvider.submitCorrect`
- Swipe links -> `localLearningControllerProvider.submitWrong`
- `StageSwitchRowView` unten
- Plasma-Link spaeter mit lokalen Keys/Rects
- Bottom-Bereich zunaechst provider-frei leer oder als Platzhalter
- Empty-State nicht mehr als separater Screen, sondern als Startzustand innerhalb des alten Frames

## 8. Nicht-Ziele

Nicht Teil dieses Umbaus:

- keine Supabase-Logik aendern
- kein WordHub-Umbau
- kein CategoryDetail-Umbau
- keine Alt-Code-Bereinigung
- `CardArea` / `BottomControls` nicht direkt uebernehmen, solange sie alte Provider lesen
- keine alte `LearnModeController`-Logik in den lokalen Branch ziehen

## 9. Tests

Geplante Tests:

- `test/features/learn_mode_screen_local_branch_test.dart` anpassen
- lokale Ansicht zeigt Header/Wheel statt reiner Empty-Seite
- `Starten/Fortsetzen` bleibt innerhalb des alten Frames moeglich
- spaeter Swipe/Flip testen
- `test/features/local_learning_debug/` bleibt gruen
- Analyzer fuer `LearnModeScreen`

## 10. Naechster Code-Schritt

Kleinster naechster Implementierungsschritt:

- provider-freien lokalen LearnMode-Frame im echten `LearnModeScreen` vorbereiten
- `HeaderBar(customWheelLabels: [title])` verwenden
- alte Column-/Stack-Struktur lokal nachbilden
- lokale Card-Flaeche zunaechst mit Empty-State im Frame rendern
- `StageSwitchRowView` unten anzeigen
- noch ohne Plasma/Swipe als erster Schritt
