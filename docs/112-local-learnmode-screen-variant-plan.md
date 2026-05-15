# 112 Local LearnMode Screen Variant Plan

Stand: 2026-05-15

## 1. Ziel

Ziel ist eine lokale LearnMode-nahe Screen-Variante, die auf der lokalen Offline-first-Lernkette basiert.

Die Variante soll:

- eine lokale LearnMode-nahe UI vorbereiten
- spaeter die bestehende echte UI oder Teile davon wiederverwendbar machen
- nicht direkt `LearnModeScreen` umbauen
- nicht direkt `LearnModeController` umbauen
- keine neue produktive Navigation erzwingen
- lokal und isoliert testbar bleiben

Der Screen waere ein Zwischenschritt zwischen dem technischen `LocalLearningTestScreen` und einer spaeteren kontrollierten Produktintegration.

## 2. Unterschied Zu LocalLearningTestScreen

`LocalLearningTestScreen` ist aktuell eine technische Debug-/QA-Oberflaeche.

Er zeigt:

- rohe lokale Zustandsdaten
- technische Aktionen
- Debug-Import-Button
- einfache Text-/Button-Struktur

Eine lokale LearnMode-Screen-Variante sollte naeher an der Produkt-UI liegen:

- klarere Kartenansicht
- UI-nahe Wortdarstellung
- sauberere Loading-/Error-/Empty-/Completed-Zustaende
- Produkt-naehere Button-Anordnung
- spaeter wiederverwendbare Bausteine fuer die echte UI

Trotzdem bleibt sie:

- lokal
- isoliert
- ohne Supabase
- ohne `WordUserView`
- ohne direkte Anbindung an bestehende Produktnavigation

## 3. Zu Nutzende Daten

Die Variante sollte nutzen:

- `localLearningViewModelProvider`
- `LocalLearnModeUiAdapter`
- `LocalLearnModeUiState`
- `LocalLearningController` fuer Aktionen

Empfohlene Datenkette:

1. `localLearningViewModelProvider` liefert `LocalLearningViewModelState`.
2. `LocalLearnModeUiAdapter` mappt auf `LocalLearnModeUiState`.
3. Der Screen rendert ausschliesslich aus `LocalLearnModeUiState`.
4. Aktionen gehen explizit an `LocalLearningController`.

Der Screen sollte nicht direkt:

- Repositorys lesen
- Datenbank oeffnen
- Supabase nutzen
- `WordUserView` erzeugen
- alte `LearnModeState`-Felder lesen

## 4. Noetige UI-Zustaende

Die erste lokale Variante sollte diese Zustaende abdecken:

### Loading

Quelle:

- `LocalLearnModeUiState.isLoading`

Darstellung:

- einfacher Ladezustand
- keine Aktion automatisch ausloesen

### Error

Quelle:

- `LocalLearnModeUiState.errorMessage`

Darstellung:

- einfacher Fehlerzustand
- technischer Fehlertext nur im lokalen/debugnahen Kontext
- keine eigenen Fehlertexte im Adapter erzeugen

### Empty / No Session

Quelle:

- keine aktive Karte
- nicht completed
- nicht loading
- kein error

Darstellung:

- Start-/Fortsetzen-Aktion anbieten
- keine Session automatisch beim Build starten

### Active Card

Quelle:

- `LocalLearnModeUiState.hasCard`
- `term`
- `translation`
- `exampleSentence`
- `notes`
- `currentStage`
- `progressLabel`
- `canSubmitAnswer`

Darstellung:

- Begriff
- Uebersetzung
- optional Beispielsatz
- optional Notizen
- Stage-Anzeige
- Fortschritt
- Richtig/Falsch-Aktionen

### Completed

Quelle:

- `LocalLearnModeUiState.isCompleted`

Darstellung:

- abgeschlossener Zustand
- optional Completion-Aktion oder Rueckkehr
- keine neue Session automatisch starten

## 5. Noetige Aktionen

Spaeter noetige Aktionen:

- `startOrResume`
- `submitCorrect`
- `submitWrong`
- `completeIfFinished`

Diese sollten ueber `LocalLearningController` laufen.

Der Screen sollte fuer Tests optional Callback-Injection behalten oder bekommen, aehnlich wie `LocalLearningTestScreen`.

Das erlaubt Widget-Tests ohne:

- echte Datenbank
- echte Facade
- Supabase
- Import
- Navigation

## 6. Wiederverwendbare Teile Aus Bestehender UI

Langfristig wiederverwendbar aus der bestehenden UI:

- Kartenlayout
- Stage-Anzeige
- Fortschrittsanzeige
- Button-Stile
- Teile von Animationen
- spaeter ggf. Komponenten rund um Kartenbewegung oder Feedback

Noch nicht direkt kopieren:

- alte Swipe-Commit-Logik
- alte Timer-Logik
- alte StageSwitch-/PassCount-Semantik
- alte `WordUserView`-basierte Kartenstruktur
- alte Queue-/Refill-Logik

Die erste lokale Variante sollte visuell naeher werden, aber fachlich bei der lokalen V1-Kette bleiben.

## 7. Moegliche Strategien

### A) Neuen Isolierten LocalLearnModeScreen Bauen

Beschreibung:

- neuer Screen im lokalen Bereich
- liest lokale Provider
- mappt ueber `LocalLearnModeUiAdapter`
- nutzt lokale Aktionen

Vorteile:

- geringes Risiko
- keine bestehende UI-Aenderung
- gut testbar
- Rueckbau einfach
- klare lokale Grenze

Nachteile:

- zunaechst separate UI
- Produkt-UI wird noch nicht direkt wiederverwendet

Bewertung:

- sicherste Strategie fuer den naechsten Schritt

### B) Bestehenden LearnModeScreen Direkt Erweitern

Beschreibung:

- `LearnModeScreen` bekommt lokale Verzweigung oder lokalen Modus.

Vorteile:

- bestehende Produkt-UI wird direkt genutzt

Nachteile:

- hohes Risiko
- `LearnModeScreen` ist stark an alte Provider und `WordUserView` gekoppelt
- bestehender Flow koennte brechen
- schwerer Regressionstest

Bewertung:

- nicht als naechster Schritt geeignet

### C) LocalLearningTestScreen Optisch Ausbauen

Beschreibung:

- bestehender Debug-Testscreen wird schrittweise produktnaeher.

Vorteile:

- vorhandene lokale Aktionen sind schon da
- schnelle Iteration

Nachteile:

- Debug-Import und technische Testscreen-Funktionen koennten mit Produkt-nahem Screen vermischt werden
- Testscreen verliert seine klare Rolle als technisches Werkzeug

Bewertung:

- moeglich, aber nicht ideal

### D) UI-Komponenten Extrahieren Und Wiederverwenden

Beschreibung:

- aus bestehender UI werden Komponenten extrahiert, die lokale und alte UI nutzen koennen.

Vorteile:

- langfristig sauber
- bessere Wiederverwendung

Nachteile:

- Extraktion aus komplexem `LearnModeScreen` ist riskant
- zuerst muss klar sein, welche lokale UI-State-Struktur stabil ist

Bewertung:

- sinnvoll nach einem isolierten lokalen Screen, nicht davor

## 8. Empfehlung

Empfohlen ist Strategie A:

- neuen isolierten `LocalLearnModeScreen` bauen
- mit `LocalLearnModeUiState` rendern
- Aktionen ueber lokale Controller-/Callback-Schicht anbinden
- bestehende Produkt-UI nicht anfassen

Diese Variante gibt Raum, produktnaehere lokale UI zu testen, ohne den alten Supabase-Lernflow oder `LearnModeScreen` zu gefaehrden.

## 9. Was Nicht Passieren Darf

Nicht erlaubt:

- kein Supabase
- kein `WordUserView`
- kein `LearnModeController`-Umbau
- kein `learn_mode_screen.dart`-Umbau
- keine automatische Session beim Build
- keine Produktnavigation
- kein Import beim Build
- keine Datenbankoeffnung direkt im Screen
- keine alte Queue-/Timer-/Stage-Semantik nachbauen
- keine Aenderung an bestehenden App-Flows

## 10. Sinnvolle Tests

Sinnvolle spaetere Tests:

- `local_learnmode_screen_shows_active_card`
  - rendert aktive Karte aus `LocalLearnModeUiState`
  - zeigt Begriff, Uebersetzung, Stage und Fortschritt

- `local_learnmode_screen_handles_loading_error_completed`
  - prueft Loading
  - prueft Error
  - prueft Completed

- `local_learnmode_screen_calls_submit_correct`
  - Button ruft lokale Correct-Aktion genau einmal

- `local_learnmode_screen_calls_submit_wrong`
  - Button ruft lokale Wrong-Aktion genau einmal

- `local_learnmode_screen_does_not_require_supabase_or_worduserview`
  - laeuft ohne Supabase
  - nutzt kein `WordUserView`

Weitere sinnvolle Tests:

- `local_learnmode_screen_does_not_start_session_on_build`
- `local_learnmode_screen_calls_start_or_resume_when_pressed`
- `local_learnmode_screen_disables_submit_when_not_allowed`
- `local_learnmode_screen_shows_empty_state_without_session`

## 11. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt:

1. Einen neuen isolierten Screen anlegen, z. B.:
   - `lib/features/local_learning_debug/ui/local_learn_mode_screen.dart`
2. Einen Widget-Test anlegen:
   - `test/features/local_learning_debug/local_learn_mode_screen_test.dart`
3. Erster Test:
   - `local_learnmode_screen_shows_active_card`
4. Test mit Provider-Override:
   - `localLearningViewModelProvider` liefert aktiven lokalen ViewModel-State
   - Screen mappt ueber `LocalLearnModeUiAdapter`
5. Erwartung:
   - Begriff sichtbar
   - Uebersetzung sichtbar
   - Fortschritt sichtbar
   - Stage sichtbar
   - kein Supabase noetig
   - keine Session startet beim Rendern

Noch nicht im ersten Schritt:

- keine Navigation
- keine Produktanbindung
- kein Umbau von `LearnModeScreen`
- kein Umbau von `LearnModeController`
- keine Animationsextraktion
- kein Importbutton
