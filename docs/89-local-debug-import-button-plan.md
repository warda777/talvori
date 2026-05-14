# 89 Local Debug Import Button Plan

Stand: 2026-05-14

## 1. Zweck Des Debug-Import-Buttons

Der Debug-Import-Button soll den registrierten lokalen JSON-Asset-Import bewusst ausloesen.

Ziele:

- Asset `assets/local_import/default_words_v1.json` explizit importieren
- lokale `basics`-Kategorie und Woerter fuer Debug/QA bereitstellen
- vor `Starten/Fortsetzen` im lokalen Testscreen lokale Daten verfuegbar machen
- Importstatus sichtbar machen
- Fehlerzustand fuer Debug/QA sichtbar machen

Der Button ist kein Produktfeature. Er dient nur dazu, die lokale Offline-first-Kette im Debug-Kontext manuell vorzubereiten.

## 2. Moegliche Orte

### Im LocalLearningTestScreen

Vorteile:

- kleinster Weg zum Ziel
- bereits isolierter Debug-/QA-Kontext
- bereits manuell ueber `/debug/local-learning` erreichbar
- keine bestehende Produktnavigation betroffen
- direkte Naehe zu `Starten/Fortsetzen`
- kann ueber Callback-Injection gut getestet werden

Nachteile:

- Testscreen bekommt eine zweite Debug-Aufgabe: Daten vorbereiten und Lernkette pruefen
- klare visuelle Trennung noetig, damit Import und Session-Start nicht verwechselt werden

Risiko: niedrig, wenn der Button nur im Debug-Testscreen liegt und keinen automatischen Import ausloest.

### Eigener Debug-Import-Screen

Vorteile:

- sauber getrennte Verantwortung
- Importdiagnose kann spaeter ausgebaut werden
- weniger Vermischung mit Lernscreen

Nachteile:

- neuer Screen
- neue Route oder neue Navigation im Debug-Kontext noetig
- groesserer erster Schritt
- mehr Widget-Tests und mehr UI-Oberflaeche

Risiko: mittel. Fachlich sauber, aber fuer den naechsten Schritt groesser als noetig.

### HomeScreen Debug-FAB Erweitern

Vorteile:

- schneller erreichbar
- kein weiterer Screen noetig

Nachteile:

- HomeScreen ist produktnahe UI
- der bestehende Debug-FAB oeffnet bereits die Debug-Route
- ein zweiter Modus oder Menue wuerde den HomeScreen staerker veraendern
- Importlogik rueckt naeher an Produktnavigation

Risiko: mittel bis hoch. Der HomeScreen sollte nicht zum Import-Debug-Menue werden.

### Debug-Menue Spaeter

Vorteile:

- langfristig skalierbar
- mehrere Debug-Aktionen koennen sauber gebuendelt werden
- gute Stelle fuer Import, Diagnose und lokale Testscreen-Links

Nachteile:

- braucht zusaetzliche Planung
- braucht eigene Debug-Navigation oder Debug-Composition
- nicht der kleinste naechste Schritt

Risiko: niedrig bis mittel, aber erst sinnvoll, wenn mehrere Debug-Werkzeuge wirklich zusammengefuehrt werden sollen.

## 3. Empfehlung

Empfohlen ist fuer den naechsten Schritt:

- Debug-Import-Button im `LocalLearningTestScreen`
- nur als explizite Aktion
- klar getrennt von `Starten/Fortsetzen`
- kein automatischer Import beim Screen-Build
- kein Ausbau des HomeScreen-FAB
- kein eigener Debug-Import-Screen im ersten Schritt

Das ist die kleinste und sicherste Variante, weil der Testscreen bereits isoliert ist und keine bestehende Lernoberflaeche ersetzt.

## 4. Lokale Kette

Die Importaktion soll die bestehende lokale Kette nutzen:

`LocalDebugImportController` -> `LocalControlledAssetImportService` -> `LocalJsonAssetImportService` -> `LocalJsonImportService`

Rollen:

- `LocalDebugImportController`: haelt Debug-State und ruft `importDefaultWords(...)`
- `LocalControlledAssetImportService`: loest den registrierten Asset-Import explizit aus
- `LocalJsonAssetImportService`: laedt JSON aus dem AssetBundle und delegiert
- `LocalJsonImportService`: validiert und schreibt Kategorien/Woerter ueber lokale Repositorys

Der Screen darf keine Importdetails selbst kennen. Er soll nur eine Aktion ausloesen und Debug-State anzeigen.

## 5. Was Der Button Tun Darf

Der Button darf:

- `importDefaultWords(now: now)` ausloesen
- einen Ladezustand anzeigen
- erfolgreichen Import anzeigen
- `lastImportedAt` anzeigen
- technische Fehler fuer Debug/QA anzeigen
- optional `resetDebugState()` anbieten, falls ein Reset-Button spaeter noetig wird

Er darf lokal sichtbar machen:

- Import laeuft
- Import erfolgreich
- Import fehlgeschlagen
- letzter erfolgreicher Importzeitpunkt

## 6. Was Nicht Passieren Darf

Nicht erlaubt:

- kein Import automatisch beim Oeffnen des Screens
- kein Import beim App-Start
- kein Import beim Lesen eines Providers
- kein Supabase
- kein Zugriff auf `local_word_database.dart`
- kein Progress durch Import
- keine Session durch Import
- keine Review-History durch Import
- keine automatische Navigation nach Import
- keine bestehende Produktnavigation
- keine Aenderung am bestehenden Lernflow
- keine Aenderung an `LearnModeController`
- keine Aenderung an `learn_mode_screen.dart`
- keine Aenderung an `word_providers.dart`

Import und Session-Start bleiben getrennte bewusste Aktionen.

## 7. Provider-/Controller-Bereitstellung

### Neuer Isolierter localDebugImportControllerProvider

Vorteile:

- passt zur bestehenden Riverpod-Struktur
- Screen kann State reaktiv lesen
- Default-Pfad nutzt echte lokale Importkette
- Widget-Tests koennen Provider oder Callbacks kontrollieren

Nachteile:

- Provider muss lokale Bootstrap-/Repository-Abhaengigkeiten sauber beziehen
- Gefahr, versehentlich beim Provider-Lesen Importlogik auszufuehren

Bewertung:

- sinnvoll, aber erst nach einem kleinen Button-Test mit Callback-Injection oder einem isolierten Provider-Plan
- Provider darf beim Lesen nur Controller/State bereitstellen, keinen Import starten

### Callback-Injection Im Testscreen

Vorteile:

- kleinster testbarer UI-Schritt
- keine echte DB im Widget-Test noetig
- entspricht dem bestehenden Muster fuer `Starten/Fortsetzen`, `Richtig`, `Falsch`, `Session abschließen`
- Import-Button kann zuerst nur beweisen, dass ein expliziter Tap die Aktion ausloest

Nachteile:

- fuer echte Nutzung braucht der Default-Pfad danach noch Provider/Controller-Anbindung
- Debug-State-Anzeige ist ohne Provider zunaechst nur begrenzt testbar

Bewertung:

- beste Variante fuer den kleinsten naechsten TDD-Schritt
- danach kann ein isolierter Provider fuer `LocalDebugImportControllerState` geplant werden

## 8. Sinnvolle Tests

Spaeter sinnvolle Tests:

- `debug_import_button_calls_import_default_words`
- `debug_import_button_shows_success_state`
- `debug_import_button_shows_error_state`
- `debug_import_button_does_not_import_on_screen_build`
- `debug_import_button_does_not_start_session`

Erste Testprioritaet:

- Button wird gerendert
- Button-Tap ruft exakt eine Importaktion auf
- kein Import beim Rendern
- keine Session-Aktion wird aufgerufen
- keine Supabase-Initialisierung noetig
- keine Datenbank im Widget-Test noetig

## 9. Risiken

Risiken:

- Demo-Daten werden unkontrolliert importiert
- Button wird versehentlich produktiv sichtbar
- Import und Session-Start werden vermischt
- Debug-State wird als Produkt-UI missverstanden
- HomeScreen wird schleichend zu einem Debug-Menue
- Provider loest Import versehentlich beim Lesen aus

Gegenmassnahmen:

- Button nur im isolierten Debug-Testscreen
- expliziter Tap erforderlich
- klare Trennung von Import-Button und `Starten/Fortsetzen`
- keine automatische Ausfuehrung in Provider, Bootstrap oder App-Start
- Widget-Test fuer "kein Import beim Screen-Build"

## 10. Kleinster Naechster TDD-Schritt

Empfohlener kleinster naechster TDD-Schritt:

1. `LocalLearningTestScreen` um optionale Callback-Injection erweitern:
   - `onImportDefaultWords`
   - optional weiter vorhandenes `nowProvider` wiederverwenden
2. Im Screen einen kleinen Debug-Import-Button anzeigen:
   - Text zum Beispiel `Debug-Daten importieren`
   - nur im Debug-Testscreen, nicht im HomeScreen
3. Widget-Test schreiben:
   - `debug_import_button_calls_import_default_words`
   - Screen rendern
   - Button antippen
   - pruefen, dass Callback genau einmal mit `now` aufgerufen wurde
   - pruefen, dass beim Rendern kein Import passiert
   - pruefen, dass keine Session-Aktion ausgeloest wird

Noch nicht im ersten Schritt:

- keinen neuen Provider bauen
- keine echte Datenbank im Widget-Test
- keine automatische Importausloesung
- keine HomeScreen-Erweiterung
- keine Produktnavigation
