# 60 Local Testscreen Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant einen isolierten lokalen Testscreen fuer die neue Offline-first-Lernkette.

Der Testscreen soll spaeter eine kleine visuelle Smoke-Test-Flaeche sein, um die lokale Kette bewusst zu pruefen:

- lokale Session starten oder fortsetzen
- richtige Antwort ausloesen
- falsche Antwort ausloesen
- Requeue-Verhalten sichtbar pruefen
- Completion pruefen
- lokalen ViewModel-State und Screen-Contract im Zusammenspiel sehen

Der Testscreen ersetzt keine bestehende Lernoberflaeche. Er ist kein Umbau von `learn_mode_screen.dart` und kein Ersatz fuer den bestehenden `LearnModeController`.

## 1. Ziel Des Lokalen Testscreens

Der lokale Testscreen soll nur fuer Entwicklung und QA dienen.

Er darf zeigen:

- ob `localLearningControllerProvider` Aktionen korrekt an die lokale Facade weitergibt
- ob `localLearningViewModelProvider` den aktuellen Lernzustand korrekt bereitstellt
- ob `localLearningScreenContractProvider` die Screen-Zustaende korrekt ableitet
- ob eine lokale Session nach Start/Fortsetzen eine aktuelle Karte liefert
- ob `Richtig` die Session fortschreibt
- ob `Falsch` ein Requeue-Item erzeugt
- ob `Session abschliessen` nur bei erledigten Items wirkt
- ob nach Completion bewusst eine weitere Session gestartet werden kann

Er darf nicht als produktive Nutzeroberflaeche verstanden werden.

## 2. Moeglicher Ablageort

### Option A: `lib/core/local_database/debug/`

Vorteile:

- sehr nah an der lokalen Offline-first-Schicht
- klar als lokaler Debug-Baustein erkennbar
- geringe Gefahr, direkt mit bestehenden Word-Feature-Flows verwechselt zu werden

Nachteile:

- `core` wuerde erstmals einen Widget-nahen Debug-Screen enthalten
- UI-Dateien in `core` koennen langfristig unsauber wirken

### Option B: `lib/features/local_learning_debug/`

Vorteile:

- eigener isolierter Feature-Bereich
- keine Vermischung mit `features/words`
- gute Rueckbaubarkeit
- spaeter leicht als Debug-Route oder interner Dev-Schalter anschliessbar
- signalisiert klar: lokale Lernkette, aber noch nicht produktiver Lernscreen

Nachteile:

- neuer Feature-Ordner nur fuer Debug/QA
- braucht spaeter eine bewusste Entscheidung, ob er dauerhaft bleibt oder entfernt wird

### Option C: `lib/features/words/ui/screens/local_learning_test_screen.dart`

Vorteile:

- liegt nahe beim bestehenden Lernscreen
- spaeter leicht mit Word-Feature-Kontext vergleichbar

Nachteile:

- hoechstes Risiko, alte und neue Lernlogik zu vermischen
- zu nah an `learn_mode_screen.dart`
- koennte versehentlich als produktiver Screen verstanden werden
- groessere Gefahr, `WordUserView`, alte Provider oder Supabase-nahe Strukturen zu importieren

### Empfehlung

Fuer Version 1 ist `lib/features/local_learning_debug/` am sichersten.

Empfohlene spaetere Struktur:

- `lib/features/local_learning_debug/ui/local_learning_test_screen.dart`

Der Screen bleibt dadurch deutlich von der bestehenden Word-UI getrennt. Er kann spaeter gezielt geloescht, versteckt oder ueber eine Debug-Route angebunden werden, ohne bestehende App-Flows zu beruehren.

## 3. Erlaubte Provider

Ein spaeterer Testscreen duerfte nur diese lokalen Provider lesen:

- `localLearningViewModelProvider`
- `localLearningScreenContractProvider`
- `localLearningControllerProvider.notifier`

Geplante Nutzung:

- `localLearningViewModelProvider` liefert darstellbare Daten wie Wort, Stage und Fortschritt.
- `localLearningScreenContractProvider` liefert boolesche Screen-Zustaende.
- `localLearningControllerProvider.notifier` wird nur fuer explizite Button-Aktionen genutzt.

Der Testscreen sollte nicht direkt lesen:

- `localBootstrapProvider`
- `localLearningSessionFacadeProvider`
- Repositories
- SQLite-Datenbank
- alte Word-Provider
- Supabase-Provider

## 4. Erlaubte Aktionen

Der Testscreen duerfte nur diese Controller-Aktionen ausloesen:

- `startOrResume(...)`
- `submitCorrect(...)`
- `submitWrong(...)`
- `completeIfFinished(...)`

Die Aktionen sollen direkt auf den lokalen Controller gehen. Der Screen darf keine eigene SRS-Logik, Requeue-Logik oder Completion-Pruefung enthalten.

Fuer einen ersten Testscreen waere eine feste, einfache Konfiguration sinnvoll:

- Lernmodus: `LearningMode.adaptive`
- sichtbares Label: **Intensiv lernen**
- Trainingsbereich: `TrainingArea.all`
- sichtbares Label: **Alles lernen**

Die `categoryId` wird dem lokalen Testscreen als Konstruktor-Parameter uebergeben.

Damit gilt:

- Der Screen laedt keine Kategorien selbst.
- Der Screen nutzt keine feste Seed-ID.
- Der Screen fuehrt keine Datenbankabfrage aus.
- Der Screen startet keine Seed-Daten automatisch.
- Eine spaetere Debug-Route oder ein spaeteres Debug-Menue kann die `categoryId` uebergeben.
- Widget-Tests koennen eine Test-`categoryId` uebergeben.

## 5. Zu Verwendende Texte Aus Docs/59

Der Testscreen darf einfache, neutrale Texte verwenden.

Empfohlene sichtbare Labels:

- **Intensiv lernen**
- **Alles lernen**
- **Starten/Fortsetzen**
- **Richtig**
- **Falsch**
- **Session abschließen**
- **Weitere Session starten**

Erlaubte einfache Zustandstexte:

- **Noch keine Session**
- **Lädt...**
- **Keine aktuelle Karte**
- **Session abgeschlossen**

Diese Texte sind fuer einen Testscreen ausreichend. Sie sind noch keine finale Produktkopie.

## 6. Darstellbare Daten

Der Testscreen duerfte diese Daten aus `LocalLearningViewModelState` anzeigen:

- `term`
- `translation`
- `exampleSentence`
- `notes`
- `currentStage`
- `currentPosition`
- `totalItems`
- `answeredCount`
- `remainingCount`

Fuer `currentStage` sollte spaeter die Labelstrategie aus docs/59 gelten:

- S0: **Neu**
- S1: **Begonnen**
- S2: **Im Aufbau**
- S3: **Gefestigt**
- S4: **Sicher**
- S5: **Langzeit**

Im Testscreen darf das technische Kuerzel klein oder zusaetzlich sichtbar sein, wenn es QA hilft. Es darf aber nicht die einzige Nutzerfuehrung sein.

## 7. Bewusst Verboten

Der Testscreen darf nicht:

- bestehende Navigation aendern
- automatisch beim App-Start erscheinen
- `main.dart` aendern
- `word_providers.dart` aendern
- `learn_mode_controller.dart` aendern
- `learn_mode_screen.dart` aendern
- Supabase importieren oder initialisieren
- `WordUserView` verwenden
- den alten `LearnModeController` verwenden
- die alte `local_word_database.dart` verwenden
- direkt Repositorys oder SQLite lesen
- Seed-Daten automatisch ungefragt ausfuehren
- finale Produkttexte erzwingen
- T-SRS, A-SRS oder Hybrid als sichtbare Hauptbegriffe verwenden
- Longpress-Hinweise fuer Moduswechsel anzeigen
- einen Switch zwischen A-SRS und T-SRS einfuehren

## 8. Erreichbarkeit Ohne App-Flow-Risiko

Moegliche Stufen:

1. Noch gar nicht einhaengen
   - Screen-Datei existiert isoliert.
   - Widget-Tests koennen ihn mit Provider-Overrides rendern.
   - Keine App-Navigation wird veraendert.

2. Spaeter ueber Debug-Route
   - Nur in einer bewusst geplanten Debug-Anbindung.
   - Keine produktive Navigation.
   - Keine automatische Sichtbarkeit fuer Nutzer.

3. Spaeter ueber internen Dev-Schalter
   - Nur wenn klar ist, wie Debug-Features in der App verwaltet werden.
   - Seed/Import muss getrennt kontrolliert bleiben.

Empfehlung fuer den naechsten Schritt:

- Den Testscreen zunaechst gar nicht in die App einhaengen.
- Nur Datei und Widget-Tests erstellen.
- Provider in Tests gezielt ueberschreiben.

## 9. Sinnvolle Tests

Spaetere Tests sollten zuerst reine Widget-/Provider-Tests sein, ohne echte App-Navigation.

Priorisierte Tests:

1. `local_learning_test_screen_renders_initial_state`
   - initialer Contract wird angezeigt
   - Start/Fortsetzen ist sichtbar
   - Richtig/Falsch sind nicht aktiv
   - keine Datenbank muss fuer diesen Test geoeffnet werden, wenn Provider ueberschrieben werden

2. `local_learning_test_screen_shows_active_card`
   - aktiver ViewModel-State zeigt Begriff, Uebersetzung, Beispiel und Stage
   - Fortschrittszaehler werden angezeigt
   - Richtig/Falsch sind sichtbar oder aktiv, wenn `canShowSubmitActions == true`

3. `local_learning_test_screen_buttons_follow_contract_flags`
   - Submit-Aktionen folgen `canShowSubmitActions`
   - Completion-Aktion folgt `canCompleteSession`
   - Loading deaktiviert Aktionen

4. `local_learning_test_screen_handles_completed_state`
   - completed Contract zeigt abgeschlossenen Zustand
   - keine Submit-Aktionen
   - Weitere Session starten kann spaeter sichtbar sein

5. `local_learning_test_screen_does_not_require_supabase_or_word_user_view`
   - Test laeuft ohne Supabase-Initialisierung
   - keine `WordUserView`-Instanz noetig
   - lokale Provider-Overrides reichen aus

6. `local_learning_test_screen_does_not_start_session_on_build`
   - reines Rendern loest keine Controller-Aktion aus
   - Start passiert nur durch expliziten Button

## 10. Kleinster Naechster Schritt

Der kleinste sichere naechste TDD-Schritt waere:

1. Eine isolierte Screen-Datei planen oder erstellen unter:
   - `lib/features/local_learning_debug/ui/local_learning_test_screen.dart`
2. Der Screen bekommt `categoryId` als Konstruktor-Parameter.
3. Zuerst nur den Initialzustand testen:
   - `local_learning_test_screen_renders_initial_state`
4. Im Widget-Test eine Test-`categoryId` uebergeben.
5. Provider im Widget-Test ueberschreiben:
   - `localLearningViewModelProvider`
   - `localLearningScreenContractProvider`
6. Noch keine echte lokale Datenbank oeffnen.
7. Noch keine Navigation einhaengen.
8. Noch keine bestehende App-Datei aendern.

Damit ist der kleinste naechste Schritt ein initialer Widget-Test mit Konstruktor-`categoryId` und Provider-Overrides. Der Testscreen bleibt isoliert und muss weder Kategorien laden noch Seed-Daten kennen.
