# 47 Local Learning Session Facade Provider Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant einen isolierten Provider fuer `LocalLearningSessionFacade`.

Der Provider soll die bereits durch `localBootstrapProvider` erzeugte Facade bereitstellen, ohne selbst eine Datenbank zu oeffnen, Seed-Daten auszufuehren oder eine Session zu starten.

Ziele:

- `localBootstrapProvider` lesen
- `LocalLearningSessionFacade` aus `LocalAppBootstrapResult` bereitstellen
- keine Datenbank selbst oeffnen
- keine Session automatisch starten
- keine Seed-Daten ausfuehren
- keine Supabase-, UI- oder App-Flow-Abhaengigkeit einfuehren

## 1. Aufgabe Des Providers

Der Provider soll ein kleiner abgeleiteter Zugriff sein.

Er soll:

- auf `localBootstrapProvider` warten
- aus dem `LocalAppBootstrapResult` die `learningSessionFacade` entnehmen
- diese Facade fuer spaetere lokale Controller bereitstellen

Er soll nicht:

- `LocalAppBootstrap.bootstrap(...)` erneut aufrufen
- `LocalDatabaseFactory` verwenden
- eine zweite Datenbank oeffnen
- Seed-Daten ausfuehren
- Progress initialisieren
- eine Lernsession starten
- Antworten verarbeiten
- Completion pruefen
- UI-State verwalten
- Navigation ausloesen

## 2. Riverpod-Form

### Variante A: FutureProvider<LocalLearningSessionFacade>

Beschreibung:

- Provider liest `localBootstrapProvider.future`.
- Danach gibt er `result.learningSessionFacade` zurueck.

Vorteile:

- einfach
- passt zur async Natur des Bootstrap-Providers
- Aufrufer bekommen eine klare async Facade
- testbar mit `ProviderContainer`
- keine eigene Datenbanklogik

Nachteile:

- Lesende Controller muessen async/`AsyncValue` beachten

Bewertung:

- beste Variante fuer Version 1.

### Variante B: Abgeleiteter Provider Auf AsyncValue-Basis

Beschreibung:

- Provider liest `ref.watch(localBootstrapProvider)`.
- Gibt daraus ein `AsyncValue<LocalLearningSessionFacade>` oder einen synchronen Provider ueber `when`/Mapping zurueck.

Vorteile:

- kann Loading/Error des Bootstrap-Providers direkt durchreichen
- passend, wenn UI spaeter `AsyncValue` direkt beobachten soll

Nachteile:

- fuer rein lokale Tests etwas umstaendlicher
- koennte zu frueh UI-nahe Form erzwingen

Bewertung:

- spaeter moeglich, aber erster Schritt kann einfacher bleiben.

### Variante C: Synchroner Provider

Beschreibung:

- synchroner Provider erwartet, dass Bootstrap bereits abgeschlossen ist.

Vorteile:

- einfache Nutzung nach Initialisierung

Nachteile:

- fehleranfaellig, wenn Bootstrap noch laedt
- unklarer Initialisierungsvertrag

Bewertung:

- nicht empfohlen fuer Version 1.

## Empfehlung Fuer Version 1

Empfohlen wird:

- `FutureProvider<LocalLearningSessionFacade>`

Geplanter Ablauf:

1. `localBootstrapProvider.future` lesen.
2. `LocalAppBootstrapResult` erhalten.
3. `result.learningSessionFacade` zurueckgeben.

Wichtig:

- Die Datenbank bleibt weiterhin Besitz des `localBootstrapProvider`.
- Der Facade-Provider registriert kein eigenes `database.close()`.
- Der Facade-Provider oeffnet keine neue Datenbank.

## 3. Erlaubte Und Nicht Erlaubte Abhaengigkeiten

### Erlaubt

Erlaubte Abhaengigkeiten:

- `localBootstrapProvider`
- `LocalLearningSessionFacade`

Optional fuer Tests:

- `localBootstrapDatabasesPathProvider`
- `ProviderContainer`
- temporaerer Datenbankpfad

### Nicht Erlaubt

Nicht erlaubte Abhaengigkeiten:

- Supabase
- `SupabaseWordRepository`
- `supabaseWordRepositoryProvider`
- UI-Widgets
- Navigation
- `BuildContext`
- `LearnModeController`
- `WordUserView`
- alte `local_word_database.dart`
- `word_progress.db`
- `LocalDatabaseFactory`
- `LocalAppBootstrap` direkt im Facade-Provider

## 4. Erste Tests

Zuerst sinnvolle Tests:

- `local_learning_session_facade_provider_exposes_facade`
- `local_learning_session_facade_provider_uses_existing_bootstrap_result`
- `local_learning_session_facade_provider_does_not_open_second_database`
- `local_learning_session_facade_provider_does_not_touch_supabase_or_old_db`

### local_learning_session_facade_provider_exposes_facade

Soll pruefen:

- ProviderContainer ueberschreibt `localBootstrapDatabasesPathProvider`.
- Facade-Provider kann gelesen werden.
- Rueckgabe ist eine `LocalLearningSessionFacade`.
- Keine Seed-Daten werden angelegt.

### local_learning_session_facade_provider_uses_existing_bootstrap_result

Soll pruefen:

- `localBootstrapProvider` liefert ein Result.
- Facade-Provider liefert exakt die Facade aus diesem Result.
- Der Provider erzeugt keine separate Facade-Kette.

### local_learning_session_facade_provider_does_not_open_second_database

Soll pruefen:

- Vor und nach Lesen des Facade-Providers existiert nur die eine neue lokale Datenbankdatei.
- `localBootstrapProvider` bleibt der einzige Bootstrap-Besitzer.
- Es wird keine zweite aktive lokale Datenbank im Testpfad angelegt.

Hinweis:

- Eine direkte Zaehlung geoeffneter SQLite-Verbindungen ist schwierig.
- Fuer Version 1 reicht wahrscheinlich die strukturelle Absicherung:
  - Provider liest nur `localBootstrapProvider`
  - Test prueft keine weitere Datenbankdatei und gleiche Facade-Instanz.

### local_learning_session_facade_provider_does_not_touch_supabase_or_old_db

Soll pruefen:

- Test laeuft ohne Supabase-Initialisierung.
- Im temporaeren Pfad entsteht keine `word_progress.db`.
- Provider importiert keine Supabase-Abhaengigkeiten.

## 5. Risiken

### Provider Startet Versehentlich Session

Risiko:

- Beim bloßen Lesen der Facade wuerde Progress oder Session-Zustand entstehen.

Gegenmassnahme:

- Provider darf nur `result.learningSessionFacade` zurueckgeben.
- Tests sollten pruefen, dass `learning_sessions`, `word_progress` und `review_history` leer bleiben.

### Provider Oeffnet Versehentlich Zweite Datenbank

Risiko:

- Mehrere DB-Instanzen oder unterschiedliche Pfade koennen Lifecycle-Fehler erzeugen.

Gegenmassnahme:

- Provider darf `LocalAppBootstrap` nicht direkt verwenden.
- Provider darf `LocalDatabaseFactory` nicht importieren.
- Test gegen gleiche Facade aus Bootstrap-Result.

### Provider Wird Zu Frueh In Bestehende UI Eingebaut

Risiko:

- bestehende Supabase-UI und lokale Facade koennten gemischt werden.

Gegenmassnahme:

- Provider zunaechst nur lokal testen.
- Noch keine Aenderung an `main.dart`, `word_providers.dart`, `learn_mode_controller.dart` oder UI-Dateien.

### Lifecycle Wird Missverstanden

Risiko:

- Facade-Provider koennte als Besitzer der Datenbank verstanden werden.

Gegenmassnahme:

- Dokumentieren: Besitz bleibt beim `localBootstrapProvider`.
- `database.close()` bleibt dort per `ref.onDispose(...)`.

## 6. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt sollte sein:

1. Bestehende Datei `lib/core/local_database/providers/local_bootstrap_provider.dart` minimal erweitern.
2. Einen neuen `FutureProvider<LocalLearningSessionFacade>` ergaenzen.
3. Nur einen Test schreiben:
   - `local_learning_session_facade_provider_exposes_facade`
4. Test nutzt temporaeren Datenbankpfad ueber `localBootstrapDatabasesPathProvider.overrideWithValue(...)`.
5. Test liest den Facade-Provider.
6. Test prueft:
   - Rueckgabe ist `LocalLearningSessionFacade`
   - keine Seed-Kategorien wurden angelegt
   - keine `learning_sessions` wurden angelegt
   - keine Supabase-Initialisierung ist noetig

Nicht Teil des ersten TDD-Schritts:

- keine Session starten
- keine Antwort submitten
- keine UI anbinden
- keinen lokalen Lerncontroller erstellen
- keine bestehenden Provider ersetzen

## Empfehlung

Der Facade-Provider ist sinnvoll als naechste kleine Schicht.

Er sollte nur die bereits vorhandene `LocalLearningSessionFacade` aus dem Bootstrap-Result herausreichen. Damit wird die spaetere lokale Controller-Anbindung einfacher, ohne App-Flows, UI oder Supabase anzufassen.
