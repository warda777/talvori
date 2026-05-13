# 51 Local UI Adapter Strategy

Stand: 2026-05-13

## Zweck

Dieses Dokument plant die naechste sichere app-nahe Integrationsschnittstelle fuer die lokale Offline-first-Schicht.

Es ist nur Planung:

- kein Code
- keine UI-Aenderung
- keine Supabase-Aenderung
- keine App-Flow-Aenderung
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`

## Ausgangslage

Der lokale Offline-first-Block ist isoliert vorhanden:

- lokale SQLite-Schema-/Repository-Schicht
- lokale SRS-Engine
- `LocalLearningSessionFacade`
- `localLearningSessionFacadeProvider`
- `LocalLearningController`
- lokale Controller-Tests

Der bestehende Lernflow nutzt weiterhin:

- `learn_mode_screen.dart`
- `learn_mode_controller.dart`
- `WordUserView`
- Supabase-Repository
- alte SRS-/Queue-/Stage-/Timer-Logik
- alte Modus- und Trainingsbereichslogik

Der bestehende Screen ist UI- und animationsreich. Der bestehende Controller ist gross, Supabase-gekoppelt und enthaelt alte SRS-Fachlogik. Deshalb sollte die naechste Schnittstelle weiterhin neben dem bestehenden Flow entstehen.

## 1. Integrationsoptionen

### Option A: Neuer Isolierter Lokaler Testscreen

Beschreibung:

- Neuer Screen nur fuer die lokale Offline-first-Schicht.
- Nutzt spaeter `LocalLearningController` oder einen UI-nahen Adapter.
- Bestehender `learn_mode_screen.dart` bleibt unveraendert.

Vorteile:

- bestehender Lernflow bleibt unangetastet
- manuelle lokale Smoke-Tests werden moeglich
- Rueckbau waere einfach, solange der Screen nicht in Navigation eingebunden ist

Risiken:

- ist bereits UI-Code
- kann Design-/Navigationsfragen zu frueh aufmachen
- braucht spaeter klare Entscheidung, wie er erreichbar wird
- kann parallele UI-Strukturen erzeugen, wenn zu frueh gebaut

Bewertung:

- Risiko fuer bestehende App-Flows: niedrig, solange nicht eingebunden
- Supabase-Vermischung: niedrig
- Testbarkeit: mittel
- Rueckbaubarkeit: hoch
- Geschwindigkeit: mittel

Fazit:

- sinnvoll fuer spaeteren manuellen Smoke-Test
- nicht der kleinste naechste Schritt

### Option B: Neuer UI-Neutraler Adapter/ViewModel

Beschreibung:

- Neuer Adapter zwischen `LocalLearningControllerState` und spaeterer UI.
- Gibt UI-nahe, aber widget-unabhaengige Daten aus.
- Kennt keine Navigation, keine Widgets und kein Supabase.
- Bestehender Lernscreen und alter Controller bleiben unveraendert.

Vorteile:

- niedrigstes Risiko
- sehr gut testbar
- keine bestehende UI wird beruehrt
- keine Supabase-Vermischung
- bereitet spaetere Screen-Anbindung vor
- Rueckbau einfach

Risiken:

- ein zusaetzlicher Zwischenschritt
- Mapping muss spaeter mit echter UI abgeglichen werden
- darf nicht zu frueh UI-Texte oder Layoutentscheidungen enthalten

Bewertung:

- Risiko fuer bestehende App-Flows: sehr niedrig
- Supabase-Vermischung: sehr niedrig
- Testbarkeit: hoch
- Rueckbaubarkeit: hoch
- Geschwindigkeit: hoch

Fazit:

- beste Option fuer den naechsten Schritt

### Option C: Bestehenden learn_mode_screen Vorsichtig Anbinden

Beschreibung:

- `learn_mode_screen.dart` wuerde spaeter lokal erzeugte Lernkarten anzeigen.
- Bestehende Animationen, Swipe-Logik und Stage-Anzeigen muessten an lokale Daten angepasst werden.

Beobachtete Kopplungen:

- importiert `WordUserView`
- liest `learnModeControllerProvider`
- liest `srsModeControllerProvider`
- liest `levelSelectionProvider`
- nutzt Stage-Switches, Single-Mode-Switches und Plasma-/Pulse-/Swipe-Animationen
- enthaelt alte passCount- und Stage-Vorschau-Logik
- nutzt alte Labels und Stage-Prefixe wie T/A/H

Vorteile:

- direkter Weg zur sichtbaren App-Nutzung
- bestehendes Look-and-Feel koennte erhalten bleiben

Risiken:

- hohes Risiko fuer bestehende Lernflows
- alte und neue SRS-Logik koennen sich vermischen
- `WordUserView` passt nicht direkt zu `LocalSessionReadState`
- alte UI-Annahmen zu T-SRS/A-SRS/Hybrid widersprechen V1-Namen und V1-Regeln
- Animationen und Controller-State sind eng gekoppelt

Bewertung:

- Risiko fuer bestehende App-Flows: hoch
- Supabase-Vermischung: hoch
- Testbarkeit: mittel bis niedrig
- Rueckbaubarkeit: mittel
- Geschwindigkeit: scheinbar hoch, praktisch riskant

Fazit:

- nicht als naechster Schritt empfohlen
- erst nach Adapter, Mapping und Tests anfassen

### Option D: Bestehenden LearnModeController Umbauen

Beschreibung:

- `learn_mode_controller.dart` wuerde direkt auf lokale Facade/Controller umgestellt.

Beobachtete Kopplungen:

- importiert `SupabaseWordRepository`
- importiert `supabase_flutter`
- nutzt alte `srs_logic.dart` und `srs_config.dart`
- haelt `WordUserView`-Queues
- verwaltet Timer, Hybrid-Budgets, Stage-Queues, Server-Progress und alte Review-Pfade
- enthaelt sehr viel UI-nahen State

Vorteile:

- eine zentrale bestehende Stelle fuer den alten Lernflow

Risiken:

- sehr hohe Regression-Gefahr
- Supabase- und lokale Persistenz koennten gleichzeitig wirken
- alte und neue Queue-Regeln koennten kollidieren
- schwer testbar
- schwer rueckbaubar
- grosse Datei mit vielen Nebenwirkungen

Bewertung:

- Risiko fuer bestehende App-Flows: sehr hoch
- Supabase-Vermischung: sehr hoch
- Testbarkeit: niedrig
- Rueckbaubarkeit: niedrig
- Geschwindigkeit: niedrig, wenn sicher gemacht

Fazit:

- aktuell nicht empfohlen
- erst spaeter, wenn der lokale Flow in einer separaten Schnittstelle stabil nutzbar ist

## 2. Klare Empfehlung

Der naechste Schritt sollte ein neuer UI-neutraler `LocalLearningViewModelAdapter` sein.

Warum:

- er beruehrt keine bestehende UI
- er beruehrt keinen alten Controller
- er beruehrt kein Supabase
- er macht den lokalen Controller fuer eine spaetere UI nutzbar
- er ist klein und gut testbar
- er kann spaeter sowohl fuer einen lokalen Testscreen als auch fuer eine vorsichtige bestehende UI-Anbindung genutzt werden

Noch nicht empfohlen:

- kein neuer Screen als naechster Schritt
- keine Aenderung an `learn_mode_screen.dart`
- kein Umbau von `learn_mode_controller.dart`
- keine Aenderung an Navigation

## 3. Moeglicher LocalLearningViewModelAdapter

### Zweck

Der Adapter soll `LocalLearningControllerState` in einen UI-nahen, aber nicht widget-spezifischen State uebersetzen.

Er soll:

- `LocalLearningControllerState` lesen oder als Input erhalten
- `LocalSessionReadState` auswerten
- einfache Felder fuer spaetere UI bereitstellen
- keine UI-Widgets kennen
- keine Navigation kennen
- keine Supabase-Abhaengigkeit haben
- keine `WordUserView`-Abhaengigkeit haben
- keine eigene SRS-Fachlogik enthalten

### Moeglicher Ort

Empfohlen:

- `lib/core/local_database/adapters/`

Alternative:

- `lib/core/local_database/controllers/`

Bewertung:

- Ein eigener `adapters`-Ordner macht klar, dass diese Schicht nur Mapping und UI-nahe Aufbereitung uebernimmt.
- Der Controller bleibt fuer Aktionen und State verantwortlich.
- Der Adapter bleibt fuer reine Darstellungsvorbereitung verantwortlich.

### Moegliche Klassen

Moegliche Dateien fuer spaeter:

- `local_learning_view_model_adapter.dart`
- `local_learning_view_model_state.dart`

Moeglicher State:

- `isLoading`
- `errorMessage`
- `hasSession`
- `sessionId`
- `status`
- `categoryId`
- `mode`
- `trainingArea`
- `currentWordId`
- `term`
- `translation`
- `exampleSentence`
- `notes`
- `currentStage`
- `currentPosition`
- `totalItems`
- `answeredCount`
- `remainingCount`
- `canSubmitAnswer`
- `canCompleteSession`
- `lastAction`

Wichtig:

- keine lokalisierten Button-Texte
- keine technischen Moduslabels wie `T-SRS`, `A-SRS`, `Hybrid`
- keine Widget-spezifischen Layoutfelder
- keine Navigationsergebnisse
- keine Animationstrigger als Fachlogik

## 4. Spaeter Benoetigte UI-Daten

Fuer eine spaetere lokale Lernansicht werden voraussichtlich gebraucht:

- `term`
- `translation`
- `exampleSentence`
- `notes`
- `currentStage`
- `currentPosition`
- `totalItems`
- `answeredCount`
- `remainingCount`
- `canSubmitAnswer`
- `canCompleteSession`
- `isLoading`
- `errorMessage`
- `status`

Optional spaeter:

- displayfaehige Stage-Namen
- displayfaehige Modusnamen
- displayfaehige Trainingsbereichsnamen
- Completion-Hinweise
- leere Session-/keine Karten-Zustaende

Diese optionalen Felder sollten erst nach der UI-Textstrategie aus `docs/06-mode-and-training-names.md` und den V1-Regeln entschieden werden.

## 5. Was Noch Nicht Passieren Darf

Weiterhin nicht tun:

- kein Umbau des bestehenden `learn_mode_screen.dart`
- kein Ersatz des bestehenden `LearnModeController`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `main.dart`
- keine Supabase-Entfernung
- keine Supabase-Repository-Ersetzung
- keine Modusbutton-UI-Aenderung
- keine Longpress-/Switch-UI-Aenderung
- keine Navigation
- kein Import von `WordUserView` in den lokalen Adapter
- keine direkte SQLite-Abfrage im Adapter
- keine Session automatisch starten nur durch Adapter-Lesen

## 6. Erste Sinnvolle Tests

Fuer den Adapter sollten zuerst reine Unit-Tests geschrieben werden.

Empfohlene Tests:

- `local_learning_view_model_adapter_maps_read_state_to_view_model_state`
- `local_learning_view_model_adapter_exposes_loading_and_error`
- `local_learning_view_model_adapter_handles_missing_read_state`
- `local_learning_view_model_adapter_exposes_progress_counters`
- `local_learning_view_model_adapter_exposes_submit_and_completion_flags`
- `local_learning_view_model_adapter_preserves_last_action`
- `local_learning_view_model_adapter_does_not_require_supabase_or_word_user_view`

### Test 1: maps_read_state_to_view_model_state

Sichert ab:

- `term`, `translation`, `exampleSentence`, `notes` werden aus `LocalSessionReadState` uebernommen
- `currentStage` wird uebernommen
- Session-Felder werden uebernommen
- keine Daten veraendert

### Test 2: exposes_loading_and_error

Sichert ab:

- `isLoading` wird vom Controller-State uebernommen
- `errorMessage` wird uebernommen
- Adapter erzeugt keine eigenen Fehlertexte

### Test 3: handles_missing_read_state

Sichert ab:

- kein aktiver State fuehrt zu `hasSession = false`
- `canSubmitAnswer = false`
- `canCompleteSession = false`
- Wortfelder bleiben null

### Test 4: exposes_progress_counters

Sichert ab:

- `currentPosition`
- `totalItems`
- `answeredCount`
- `remainingCount`

### Test 5: exposes_submit_and_completion_flags

Sichert ab:

- `canSubmitAnswer` wird nicht neu berechnet, sondern aus dem Read-State uebernommen
- `canCompleteSession` wird uebernommen

### Test 6: preserves_last_action

Sichert ab:

- `lastAction` bleibt fuer spaetere UI-Reaktionen nachvollziehbar
- Adapter fuehrt keine Aktion selbst aus

### Test 7: does_not_require_supabase_or_word_user_view

Sichert ab:

- Test kann ohne Supabase-Initialisierung laufen
- Adapter nutzt lokale Modelle
- keine `WordUserView`-Instanz ist notwendig

## 7. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt:

1. Neue Planungsgrenze beibehalten: keine UI-Datei anfassen.
2. Einen reinen Adapter-State planen und dann testgetrieben umsetzen.
3. Nur einen ersten Test schreiben:
   - `local_learning_view_model_adapter_maps_read_state_to_view_model_state`
4. Nur lokale Modelle verwenden:
   - `LocalLearningControllerState`
   - `LocalSessionReadState`
   - `LearningMode`
   - `TrainingArea`
   - `SrsStage`
5. Danach gezielt testen:
   - `flutter test test/core/local_database/local_learning_view_model_adapter_test.dart`

Noch nicht im ersten TDD-Schritt:

- kein Provider fuer den Adapter
- kein Widget
- kein Screen
- kein `learn_mode_screen.dart`
- kein `LearnModeController`
- keine Navigation
- keine UI-Texte

## 8. Empfohlene Reihenfolge Danach

Empfohlene Reihenfolge:

1. `LocalLearningViewModelAdapter` planen und testen.
2. Adapter um Loading-/Error-/Empty-State-Tests ergaenzen.
3. Adapter um Submit-/Completion-Flags ergaenzen.
4. Stabilitaetscheck fuer lokalen Block ausfuehren.
5. Danach erst entscheiden:
   - neuer isolierter lokaler Testscreen
   - oder weiterer UI-neutraler Provider fuer Adapter-State
6. Bestehenden `learn_mode_screen.dart` erst spaeter und nur mit eigener Integrationsplanung anfassen.

## Abschlussbewertung

Die lokale Offline-first-Schicht ist inzwischen stabil genug, um eine app-nahe Schnittstelle zu planen.

Sie ist noch nicht bereit fuer einen direkten Umbau des bestehenden Lernflows.

Die sicherste naechste Bewegung ist ein neuer UI-neutraler Adapter, der lokale Controller-Daten so vorbereitet, dass spaeter eine UI angebunden werden kann, ohne Supabase, `WordUserView`, Navigation oder alte SRS-Logik mitzuziehen.
