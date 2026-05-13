# 55 Local Learning Screen Contract Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant einen lokalen Screen-Vertrag fuer eine spaetere lokale Lernoberflaeche.

Der Vertrag beschreibt, welche Daten ein lokaler Screen lesen duerfte, welche Aktionen er ausloesen duerfte und welche Zustaende dargestellt werden muessen. Er ist noch keine UI-Implementierung und veraendert keine bestehenden App-Flows.

Es ist nur Planung:

- kein Code
- keine UI-Aenderung
- keine Supabase-Aenderung
- keine App-Flow-Aenderung
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`

## 1. Daten Aus LocalLearningViewModelState

Ein lokaler Lernscreen sollte seine darstellbaren Daten aus `LocalLearningViewModelState` beziehen.

Primaere Quelle:

- `localLearningViewModelProvider`

Relevante Felder:

- `isLoading`
- `errorMessage`
- `hasSession`
- `sessionId`
- `categoryId`
- `mode`
- `trainingArea`
- `status`
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

Der Screen sollte diese Daten nur lesen. Er sollte keine Sessiondaten selbst berechnen und keine direkte Datenbank- oder Repository-Schicht kennen.

## 2. Erlaubte Aktionen

Ein lokaler Lernscreen duerfte spaeter nur Aktionen auf dem `LocalLearningController` ausloesen.

Erlaubte Aktionen:

- `startOrResume(...)`
- `submitCorrect(...)`
- `submitWrong(...)`
- `completeIfFinished(...)`

### startOrResume

Zweck:

- lokale Session fuer `categoryId + mode + trainingArea` starten oder fortsetzen

Noetige Parameter:

- `categoryId`
- `LearningMode`
- `TrainingArea`
- `DateTime now`
- optional `sessionSize`

Wichtig:

- Der Screen sollte diese Aktion nur explizit ausloesen, z. B. beim Oeffnen eines isolierten lokalen Testscreens oder nach bewusster Nutzeraktion.
- Das reine Lesen des ViewModel-Providers darf keine Session starten.

### submitCorrect

Zweck:

- aktuelle Karte als richtig beantworten

Voraussetzung:

- `canSubmitAnswer == true`
- `sessionId != null`
- `currentWordId != null`

### submitWrong

Zweck:

- aktuelle Karte als falsch beantworten

Voraussetzung:

- `canSubmitAnswer == true`
- `sessionId != null`
- `currentWordId != null`

### completeIfFinished

Zweck:

- Session abschliessen, wenn keine offenen Items mehr vorhanden sind

Voraussetzung:

- `canCompleteSession == true`
- `sessionId != null`

Wichtig:

- Completion erzeugt keine neue Session.
- Neue Session entsteht nur durch spaeteren expliziten `startOrResume(...)`-Aufruf.

## 3. Darzustellende Zustaende

Ein lokaler Lernscreen muss mindestens diese Zustaende sauber darstellen koennen.

### Initial

Kriterien:

- `isLoading == false`
- `hasSession == false`
- `errorMessage == null`

Bedeutung:

- Es wurde noch keine lokale Session gestartet oder fortgesetzt.

Moegliche UI-Reaktion spaeter:

- Start-/Fortsetzen-Aktion anbieten

Noch nicht hart verdrahten:

- Buttontext
- Moduslabel
- Trainingsbereichslabel

### Loading

Kriterien:

- `isLoading == true`

Bedeutung:

- Controller fuehrt gerade eine Aktion aus, z. B. Start, Submit oder Completion.

Moegliche UI-Reaktion spaeter:

- Eingaben deaktivieren
- Ladezustand anzeigen

Noch nicht hart verdrahten:

- Loading-Text
- Spinner-/Animationstyp

### Error

Kriterien:

- `errorMessage != null`

Bedeutung:

- Lokale Aktion ist fehlgeschlagen oder kein aktiver Session-Kontext ist vorhanden.

Moegliche UI-Reaktion spaeter:

- Fehlerzustand anzeigen
- Wiederholen anbieten

Noch nicht hart verdrahten:

- finale Fehlertexte
- Lokalisierung
- Retry-Buttontext

### Active Session

Kriterien:

- `hasSession == true`
- `status == active`
- `currentWordId != null`

Bedeutung:

- Es gibt eine laufende lokale Session mit aktueller Karte.

Moegliche UI-Reaktion spaeter:

- Begriff anzeigen
- optional Uebersetzung anzeigen
- Fortschritt anzeigen
- Richtig/Falsch-Aktionen anbieten, wenn `canSubmitAnswer == true`

### No Current Card

Kriterien:

- `hasSession == true`
- `currentWordId == null`
- `status` ist nicht zwingend `completed`

Bedeutung:

- Es gibt eine Session, aber aktuell keine darstellbare Karte.
- Das kann ein Zwischenzustand oder ein nahezu abgeschlossener Zustand sein.

Moegliche UI-Reaktion spaeter:

- Completion pruefen lassen
- keine Antwortbuttons aktivieren

Wichtig:

- Dieser Zustand darf nicht automatisch eine neue Session starten.

### Completed

Kriterien:

- `status == completed`
- `currentWordId == null`
- `canSubmitAnswer == false`

Bedeutung:

- Die lokale Session ist abgeschlossen.

Moegliche UI-Reaktion spaeter:

- Abschlusszustand anzeigen
- spaeter neue Session explizit starten lassen

Noch nicht hart verdrahten:

- Completion-Meldung
- Buttontexte
- Navigation nach Abschluss

## 4. Sichtbare Felder

Diese Felder koennen spaeter sichtbar werden:

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

### term

Primaerer Begriff der aktuellen Karte.

### translation

Uebersetzung der aktuellen Karte.

Ob sie sofort sichtbar ist oder erst nach Nutzeraktion, bleibt eine UI-Entscheidung.

[PRÜFEN] Ob der lokale Testscreen zuerst immer beide Seiten zeigt oder eine einfache Aufdecklogik braucht.

### exampleSentence

Optionaler Beispielsatz.

### notes

Optionale Notizen.

### currentStage

Aktuelle lokale SRS-Stufe.

Wichtig:

- Stage darf angezeigt werden, aber UI-Texte fuer Stufen sollten noch nicht final fest verdrahtet werden.

### Progress Counters

Moegliche Anzeige:

- `answeredCount`
- `totalItems`
- `remainingCount`
- `currentPosition`

Wichtig:

- Der Screen sollte diese Werte nicht neu berechnen.
- Er sollte sie aus dem ViewModel-State uebernehmen.

### canSubmitAnswer

Steuert, ob Richtig/Falsch-Aktionen angeboten werden.

### canCompleteSession

Steuert, ob Completion angeboten oder automatisch nach Nutzeraktion geprueft werden darf.

## 5. UI-Texte Nicht Hart Verdrahten

Noch nicht hart verdrahten:

- Modusnamen
- Trainingsbereichsnamen
- Buttontexte
- Completion-Meldungen
- Fehlertexte
- Empty-State-Texte
- Stage-Erklaerungen

Grund:

- Die endgueltigen Begriffe fuer Modi und Trainingsbereiche sind fachlich geplant, aber noch nicht an bestehende UI angebunden.
- Alte Begriffe wie `T-SRS`, `A-SRS` und `Hybrid` sollen nicht ungeprueft in Nutzeroberflaechen fortgefuehrt werden.
- Ein isolierter lokaler Testscreen kann spaeter Platzhalter oder sehr neutrale Texte nutzen, sollte diese aber nicht zur finalen Produktkopie machen.

## 6. Bestehende UI-Dateien Weiterhin Nicht Aendern

Weiterhin nicht aendern:

- `lib/features/words/ui/screens/learn_mode_screen.dart`
- `lib/features/words/application/learn_mode_controller.dart`
- `lib/features/words/application/word_providers.dart`
- `lib/main.dart`
- `lib/features/words/ui/widgets/srs_mode_toggle.dart`
- `lib/features/words/ui/widgets/srs_mode_toggle_with_hint.dart`
- `lib/features/words/ui/widgets/stage_switch_row.dart`
- `lib/features/words/ui/widgets/level_selector_buttons.dart`
- `lib/features/words/ui/widgets/levels_card.dart`
- `lib/features/words/ui/screens/category_detail_screen.dart`

Begruendung:

- Diese Dateien sind an alte Supabase-, SRS-, Stage-, Mode- und UI-Flows gekoppelt.
- Eine Aenderung dort waere eine echte App-Integration und braucht eigene Planung.

## 7. Spaeter Sinnvolle Tests

Spaeter sinnvolle Tests fuer einen Screen-Vertrag oder eine Screen-State-Hilfsschicht:

- `screen_contract_handles_empty_state`
- `screen_contract_handles_active_card`
- `screen_contract_handles_completed_state`
- `screen_contract_exposes_submit_actions_only_when_allowed`

### screen_contract_handles_empty_state

Sichert ab:

- fehlende Session wird sauber erkannt
- keine Antwortaktionen sind erlaubt
- keine Karte wird erwartet

### screen_contract_handles_active_card

Sichert ab:

- aktive Session mit aktueller Karte liefert Begriffsdaten
- Stage und Progress werden verfuegbar
- Submit-Aktionen sind nur bei `canSubmitAnswer == true` erlaubt

### screen_contract_handles_completed_state

Sichert ab:

- completed Session zeigt keine aktuelle Karte
- Submit-Aktionen sind deaktiviert
- Abschlusszustand ist eindeutig erkennbar

### screen_contract_exposes_submit_actions_only_when_allowed

Sichert ab:

- `submitCorrect` und `submitWrong` werden nur angeboten, wenn `canSubmitAnswer == true`
- bei fehlender Session oder fehlender Karte bleiben Submit-Aktionen gesperrt

## 8. Ist Danach Ein Isolierter Lokaler Testscreen Sinnvoll?

Ja, ein isolierter lokaler Testscreen kann nach diesem Vertrag sinnvoll sein.

Vorteile:

- visuelle Smoke-Tests der lokalen Offline-first-Kette
- keine Aenderung am bestehenden `learn_mode_screen.dart`
- schnelleres manuelles Pruefen von Start, Antwort, Requeue und Completion
- Rueckbau bleibt einfach, solange keine Navigation in bestehende Flows eingebaut wird

Risiken:

- trotzdem UI-Code
- kann zu frueh Produktentscheidungen ueber Texte und Layout erzwingen
- braucht klare Grenze, damit er nicht versehentlich den bestehenden Lernflow ersetzt

Empfehlung:

- erst einen kleinen Vertrag/Presenter fuer Screen-Zustaende testen
- dann einen isolierten lokalen Testscreen planen
- den Testscreen noch nicht in bestehende Navigation einhaengen

## 9. Kleinster Naechster Schritt

Der kleinste naechste Schritt ist weiterhin UI-neutral:

1. Einen kleinen lokalen Screen-Contract-/Presenter-State planen oder implementieren.
2. Nur aus `LocalLearningViewModelState` ableiten:
   - `isInitial`
   - `isLoading`
   - `hasError`
   - `hasActiveCard`
   - `isCompleted`
   - `canShowSubmitActions`
3. Einen ersten Test schreiben:
   - `screen_contract_handles_empty_state`
4. Keine UI-Datei anfassen.
5. Keine Navigation anfassen.
6. Keine Supabase-Datei anfassen.

Alternative:

- Wenn eine echte UI als naechster Schritt gewuenscht ist, zuerst einen isolierten lokalen Testscreen planen, aber noch nicht bauen.

## Abschlussbewertung

Der lokale ViewModel-Provider liefert inzwischen genug Daten fuer einen einfachen lokalen Lernscreen-Vertrag.

Trotzdem sollte die naechste Bewegung klein bleiben. Der sicherste Schritt ist ein weiterer UI-neutraler Screen-Contract oder Presenter, bevor ein echter Screen oder bestehende UI-Dateien beruehrt werden.
