# 64 Local Offline-First Learning Milestone Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den abgeschlossenen lokalen Offline-first-Lernblock als Meilenstein zusammen.

Der Block umfasst:

- reine Dart-SRS-Engine
- lokale SQLite-Schicht
- lokale Repositorys
- Session- und Persistenzservices
- lokale Learning-Fassade
- Bootstrap und Provider
- Controller
- UI-nahe Adapter und Contracts
- isolierten lokalen Testscreen

Die bestehende App-UI, Supabase-Anbindung und bestehenden App-Flows wurden dabei bewusst nicht umgebaut.

## 1. Was Insgesamt Erreicht Wurde

Es existiert jetzt eine durchgehend lokale Offline-first-Lernkette, die fachlich und technisch isoliert ist.

Die Kette kann:

1. lokale Datenbank oeffnen
2. V1-Schema bereitstellen
3. lokale Kategorien und Woerter verwalten
4. optional kleine Seed-Daten einfuegen
5. Fortschritt fuer Woerter initialisieren
6. lokale SRS-Session starten oder fortsetzen
7. Session-Queue aus lokaler Datenlage bauen
8. Antworten auswerten
9. Progress, Review-History und Session-Items atomar speichern
10. Requeue fuer falsche Antworten erzeugen
11. Session abschliessen, wenn keine offenen Items mehr vorhanden sind
12. UI-neutralen Read-State bauen
13. Controller-State in ViewModel-State mappen
14. Screen-Zustaende ableiten
15. isoliert einen lokalen Testscreen anzeigen und bedienen

Kurz:

- SRS-Engine -> SQLite -> Repositorys -> SessionService -> Facade -> Controller -> ViewModel -> ScreenContract -> Testscreen

## 2. Lokale Bausteine

### Reine SRS-Engine

Unter `lib/core/srs/` existieren:

- `SrsEngine`
- `StageTransitionService`
- `DueDateCalculator`
- `RequeueService`
- `NewCardPolicyService`
- `QueueBuilder`
- SRS-Modelle und Enums wie `SrsStage`, `LearningMode`, `TrainingArea`, `ReviewAnswer`, `WordProgress`, `ReviewInput`, `ReviewResult`

Die Engine bleibt frei von SQLite, Supabase, UI, Repositorys und Persistenz.

### SQLite Und Repositorys

Unter `lib/core/local_database/` existieren:

- `LocalDatabaseSchema`
- `LocalDatabaseFactory`
- `LocalAppDatabasePath`
- `LocalRepositoryFactory`
- `CategoryRepository`
- `WordRepository`
- `WordProgressRepository`
- `ReviewHistoryRepository`
- `LearningSessionRepository`

### Lokale Services

Erstellt wurden unter anderem:

- `LocalProgressInitializationService`
- `LocalSrsSessionService`
- `SrsReviewPersistenceService`
- `LocalSessionReadService`
- `LocalLearningSessionFacade`
- `LocalSeedDataService`
- `LocalAppBootstrap`

### Provider Und Controller

Erstellt wurden:

- `localBootstrapProvider`
- `localLearningSessionFacadeProvider`
- `LocalLearningController`
- `localLearningViewModelProvider`
- `localLearningScreenContractProvider`

### UI-nahe Lokale Schichten

Erstellt wurden:

- `LocalLearningViewModelAdapter`
- `LocalLearningViewModelState`
- `LocalLearningScreenContract`
- isolierter `LocalLearningTestScreen`

Diese Schichten bleiben von bestehender App-UI getrennt.

## 3. Umgesetzte SRS-Regeln

Die lokale Engine setzt die V1-Regeln aus `docs/14` um:

- S0 bis S5 als aktive Stufen
- `isMastered` wird nicht fuer Engine-Entscheidungen verwendet
- Aufstieg:
  - S0 -> S1 nach 1 richtiger Antwort
  - S1 -> S2 nach 2 richtigen Antworten
  - S2 -> S3 nach 2 richtigen Antworten
  - S3 -> S4 nach 3 richtigen Antworten
  - S4 -> S5 nach 3 richtigen Antworten
- `passCount` wird bei Aufstieg oder falscher Antwort zurueckgesetzt
- Rueckfall:
  - S0 falsch -> S0
  - S1 falsch -> S1
  - S2 falsch -> S1
  - S3 falsch -> S2
  - S4 falsch -> S3
  - S5 falsch -> S3
- T-SRS-Intervalle fuer S1 bis S5
- Hybrid-Intervalle fuer S3 bis S5
- A-SRS ohne harte Zeitblockade
- S5 bleibt wiederholbar
- Mehrfach-Requeue:
  - 1. Fehler nach ca. 10 Karten
  - 2. Fehler nach ca. 5 Karten
  - 3. Fehler als schwierig ans Queue-Ende
- neue Karten:
  - `reviewOnly` blockiert neue Karten
  - `focused` blockiert neue Karten fuer normale Progression
  - Time maximal 5 neue Karten
  - Hybrid maximal 8 neue Karten
  - Adaptive maximal Sessiongroesse 20
- Fehlerquote-Regel:
  - 3 Fehler in den letzten 10 Antworten blockieren neue Karten in Time und Hybrid
  - Adaptive stoppt automatischen Nachschub, aber keinen Lernblock
- Sessiongroesse V1: 20
- A-SRS 2:1-Mischregel
- `focused` veraendert keine normale SRS-Progression

## 4. SQLite-/Repository-Funktionen

Das V1-Schema enthaelt:

- `categories`
- `words`
- `word_progress`
- `review_history`
- `learning_sessions`
- `session_items`
- `settings`

Abgesichert sind:

- Foreign Keys fuer die wichtigsten Beziehungen
- `word_progress` eindeutig pro Wort, Kategorie und Modus
- maximal eine aktive Session pro Kategorie, Modus und Trainingsbereich
- `session_items` eindeutig pro Session und Position
- `settings.key` als Primary Key

Repository-Funktionen:

- Kategorien lokal speichern, laden, sortieren und archivieren
- Woerter lokal speichern, pro Kategorie laden und archivieren
- Wort-IDs fuer Progress-Initialisierung laden
- fehlenden Fortschritt als S0 initialisieren
- Fortschritt pro Modus getrennt halten
- faellige Reviews und neue S0-Karten laden
- Review-History schreiben und Recent Answers laden
- aktive Sessions suchen, erstellen, fortsetzen und abschliessen
- Session-Items laden und Requeue-Items erzeugen

## 5. Session-/Facade-/Controller-Funktionen

### LocalSrsSessionService

Kann:

- aktive Session starten oder fortsetzen
- QueueBuildInput aus SQLite-Daten erzeugen
- `SrsEngine.buildSessionQueue(...)` aufrufen
- QueueBuildResult speichern
- Antworten einreichen
- `SessionContext` bauen
- `SrsEngine.reviewCard(...)` aufrufen
- ReviewResult atomar persistieren lassen
- Session abschliessen, wenn keine offenen Items mehr vorhanden sind

### SrsReviewPersistenceService

Speichert atomar:

- aktualisierten Progress
- Review-History-Event
- beantwortetes Session-Item
- optionales Requeue-Item
- Session-Position und Aktivitaetszeit

### LocalLearningSessionFacade

Kann:

- `startOrResumeLearning(...)`
- `submitAnswerAndReadNext(...)`
- `completeIfFinished(...)`

Sie koordiniert Progress-Initialisierung, Session-Service und Read-Service, enthaelt aber keine eigene SRS-Fachlogik.

### LocalLearningController

Kann:

- `startOrResume(...)`
- `submitCorrect(...)`
- `submitWrong(...)`
- `completeIfFinished(...)`

Der Controller haelt:

- `isLoading`
- `errorMessage`
- `readState`
- `lastAction`

Er ersetzt den bestehenden `LearnModeController` nicht.

## 6. UI-nahe Schichten

### LocalLearningViewModelAdapter

Mappt:

- `LocalLearningControllerState`
- zu `LocalLearningViewModelState`

Der ViewModel-State enthaelt:

- Loading/Error
- Session-Metadaten
- aktuelle Wortdaten
- Stage
- Progress-Counter
- Submit-/Completion-Flags
- letzte Aktion

### localLearningViewModelProvider

Liest:

- `localLearningControllerProvider`

Gibt zurueck:

- `LocalLearningViewModelState`

Er loest keine Aktionen aus.

### LocalLearningScreenContract

Leitet ab:

- `isInitial`
- `isLoading`
- `hasError`
- `hasActiveCard`
- `isCompleted`
- `canShowSubmitActions`

### localLearningScreenContractProvider

Liest:

- `localLearningViewModelProvider`

Gibt zurueck:

- `LocalLearningScreenContract`

Er loest keine Aktionen aus, oeffnet keine Datenbank und kennt keine UI-Texte.

## 7. Isolierter Testscreen

Der `LocalLearningTestScreen` liegt unter:

- `lib/features/local_learning_debug/ui/local_learning_test_screen.dart`

Er kann darstellen:

- Initial
- Active Card
- Loading
- Error
- Completed

Er kann Aktionen ausloesen:

- **Starten/Fortsetzen**
- **Richtig**
- **Falsch**
- **Session abschließen**

Umsetzung:

- Callback-Injection fuer Widget-Tests
- Default-Pfad ueber `localLearningControllerProvider.notifier`
- `nowProvider` fuer deterministische Testzeit
- `categoryId` kommt als Konstruktor-Parameter

Der Screen:

- ist nicht in Navigation eingebunden
- startet keine Session beim Rendern
- oeffnet keine Datenbank selbst
- startet keine Seed-Daten
- nutzt kein Supabase
- nutzt kein `WordUserView`
- nutzt keine alte `local_word_database.dart`

## 8. Zuletzt Gruene Tests

Der zuletzt ausgefuehrte lokale Stabilitaetscheck war gruen:

- `flutter test test/core/srs/`
  - 39 Tests bestanden
- `flutter test test/core/local_database/`
  - 105 Tests bestanden
- `flutter test test/features/local_learning_debug/`
  - 10 Tests bestanden
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`
  - `No issues found!`

Gesamt:

- 154 lokale Tests bestanden
- gezielter Analyzer meldete keine Probleme

## 9. Bewusst Nicht Veraenderte App-Bereiche

Bewusst nicht veraendert wurden:

- `main.dart`
- `word_providers.dart`
- `learn_mode_controller.dart`
- `learn_mode_screen.dart`
- bestehende App-Navigation
- bestehende Lern-Flows
- bestehende Supabase-Dateien
- bestehende UI-Dateien ausser dem neuen isolierten Debug-Testscreen
- alte `local_word_database.dart`
- bestehende Supabase-Repositories
- bestehende `WordUserView`-Strukturen

Der lokale Block laeuft parallel und isoliert.

## 10. Weiterhin Geltende Grenzen

Weiterhin nicht umgesetzt:

- keine produktive UI-Anbindung
- keine bestehende Provider-Ersetzung
- keine Navigation
- kein App-Start-Bootstrap in `main.dart`
- keine Supabase-Entfernung
- keine Supabase-Migration
- keine Migration alter lokaler Daten
- keine Migration von Supabase-Fortschritt
- kein `WordUserView`-Adapter
- keine echte lokale Launch-Datenstrategie
- keine produktive Kategorieauswahl fuer den Testscreen
- keine Debug-Route
- keine finale Produkt-UI

## 11. Risiken Vor Echter App-Anbindung

Vor einer echten App-Anbindung bleiben diese Risiken:

- alte Supabase-Lernlogik und neue lokale Lernlogik koennen vermischt werden
- bestehender `LearnModeController` ist weiterhin gross und app-nah
- bestehender `learn_mode_screen.dart` ist an alte State-, Swipe- und Word-Strukturen gekoppelt
- echte lokale Datenquelle fuer Launch-Inhalte ist noch nicht final
- Debug-Route oder Dev-Menue ist noch nicht geplant und getestet
- Datenbank-Lifecycle in echter App muss sauber verantwortet werden
- `categoryId`-Uebergabe muss fuer echte App-Kontexte geloest werden
- UI-Texte sind fuer Testscreen geeignet, aber noch keine finale Produktkopie
- Supabase laeuft weiterhin parallel

## 12. Naechste Optionen

### Option A: Lokalen Block Einfrieren

Den lokalen Block als abgeschlossenen Meilenstein markieren.

Sinnvoll, wenn:

- zuerst andere Produktbereiche stabilisiert werden sollen
- vor UI-Anbindung eine Pause oder Review gewuenscht ist
- der lokale Block als Referenzpunkt dienen soll

### Option B: Debug-Route Planen

Eine isolierte Debug-Erreichbarkeit planen.

Wichtig:

- keine produktive Navigation
- `categoryId` bewusst uebergeben
- keine automatische Seed-Ausfuehrung
- keine bestehende UI ersetzen

### Option C: Lokale Datenimportstrategie Planen

Klaeren, wie echte lokale Kategorien und Woerter in die neue Datenbank kommen.

Moegliche Themen:

- Seed-Daten erweitern
- JSON-/Asset-Import
- spaeterer Supabase-Export
- manuelle lokale Eingabe
- DeepL-/Wortimport spaeter

### Option D: Bestehende UI-Integration Separat Planen

Eine echte App-Anbindung separat und vorsichtig planen.

Dabei zuerst klaeren:

- welcher Screen betroffen waere
- welcher Provider ersetzt oder ergaenzt wird
- wie Rueckbau moeglich bleibt
- welche Tests vor und nach der Anbindung laufen muessen

## 13. Empfehlung

Die klare Empfehlung lautet:

- nicht direkt bestehende UI umbauen
- nicht direkt `learn_mode_screen.dart` ersetzen
- nicht direkt `LearnModeController` umbauen
- Supabase nicht nebenbei entfernen

Der lokale Offline-first-Lernblock ist stabil genug als isolierter Meilenstein.

Der naechste sinnvolle Schritt sollte bewusst gewaehlt werden:

1. lokalen Block einfrieren und dokumentiert lassen
2. oder eine isolierte Debug-Route planen
3. oder zuerst lokale Datenimportstrategie planen
4. oder eine separate App-Integrationsstrategie mit Rueckbaupfad erstellen

Eine direkte bestehende UI-/App-Flow-Anbindung waere zum jetzigen Zeitpunkt unnoetig riskant.

