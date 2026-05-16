# 121 Direct Existing UI Offline Integration Decision

Stand: 2026-05-16

## 1. Was Bisher Erreicht Wurde

Die lokale Offline-first-Kette wurde zunaechst bewusst isoliert ueber Debug-Screens aufgebaut und getestet.

Abgeschlossen bzw. stabil vorhanden sind:

- lokale SRS-Engine
- lokale SQLite-Datenbank
- lokale Repository-Schicht
- lokale Session-Logik
- lokale Review-Logik
- lokale Read-/ViewModel-/Facade-Schicht
- JSON-Import
- Asset-Import
- kontrollierter Asset-Import
- Debug-Import-Controller
- Import-Settings-/Diagnose-Marker
- lokale CategoryId-/CategoryDetail-Adapter
- lokale Kategorien-Provider
- Debug-Hub
- lokale Lernscreens und lokale Testscreen-Kette

Die lokale Lernkette funktioniert live:

- lokale Daten koennen kontrolliert importiert werden
- lokale Kategorien koennen gelesen werden
- lokale Sessions koennen gestartet oder fortgesetzt werden
- Antworten koennen lokal als richtig oder falsch verarbeitet werden
- Sessions koennen lokal abgeschlossen werden
- Progress, Sessions und Review-History bleiben in der lokalen SQLite-Welt

Die Debug-Screens waren hilfreich, um Engine, SQLite, Import, Sessions und lokale Controller stabil zu bekommen.

## 2. Neue Entscheidung

Ab jetzt ist der Hauptweg nicht mehr der weitere Ausbau einer separaten Debug- oder Ersatz-UI.

Neue Entscheidung:

- Die echte bestehende Talvori-UI wird die Zieloberflaeche.
- Debug-Screens bleiben Referenz- und Pruefwerkzeuge.
- Debug-Screens sind nicht mehr der primaere Integrationspfad.
- Neue Ersatz-UI soll nicht weiter als Hauptproduktweg nachgebaut werden.

Ziel-UI:

- `LearnModeScreen`
- `CategoryDetailScreen`
- `WordHubScreen`
- bestehende Header-/Stage-/Karten-/Bottom-Control-Widgets
- bestehendes visuelles Talvori-Design

Die bestehende UI soll erhalten bleiben und schrittweise offline-first angebunden werden.

## 3. Ziel

Das neue Ziel ist, die lokale Offline-first-Kette unter die bestehende UI zu legen.

Konkret:

- `LearnModeScreen` soll lokal betrieben werden koennen.
- Das bestehende LearnMode-Design soll erhalten bleiben.
- Bestehende visuelle Widgets sollen weiterverwendet oder kontrolliert entkoppelt werden.
- Supabase soll im Lernflow schrittweise abgeloest werden.
- Lokale SRS-, Session- und Review-Logik soll die fachliche Grundlage werden.
- `WordHubScreen` und `CategoryDetailScreen` sollen spaeter lokale Kategorien und lokale Lernpfade unterstuetzen.

Wichtig:

- Design darf uebernommen werden.
- Alte Daten-/Controller-/Supabase-Logik darf nicht blind uebernommen werden.
- Visuelle UI und fachliche Lernlogik muessen sauber getrennt werden.

## 4. Was Weiterhin Nicht Passieren Darf

Weiterhin verboten:

- kein unkontrollierter Komplettumbau
- keine Supabase-Entfernung nebenbei
- keine automatische Migration
- keine automatische Datenbefuellung beim App-Start
- keine Vermischung alter und neuer SRS-Regeln
- kein `WordUserView`-Fake als lokale Produktgrundlage
- keine lokale Logik in Supabase-nahe Repository-Schichten pressen
- keine neue Produkt-Ersatz-UI bauen, wenn die bestehende UI angepasst werden kann
- keine Aenderung am bestehenden Lernflow ohne Analyse, Rueckbaupfad und Tests

Supabase darf nicht blind entfernt werden.

Stattdessen gilt:

- Abhaengigkeiten analysieren
- lokale Integrationsschnittstellen definieren
- kleine TDD-Schritte
- alte und neue Pfade kontrolliert trennen
- bestehenden Flow erst ersetzen, wenn der lokale Pfad fachlich und technisch abgesichert ist

## 5. Naechster Technischer Schritt

Der naechste technische Schritt ist eine konkrete Analyse des bestehenden `LearnModeScreen`.

Ziel dieser Analyse:

- bestimmen, welche Teile reine UI sind
- bestimmen, welche Teile alte Datenlogik enthalten
- bestimmen, welche Teile direkt an `LearnModeController`, `currentWordProvider`, `WordUserView` oder Supabase gekoppelt sind
- einen lokalen Integrationsschnitt fuer den bestehenden `LearnModeScreen` definieren

Moeglicher Fokus:

- Welche UI-Bereiche koennen unveraendert bleiben?
- Welche Widgets brauchen lokale, controller-neutrale Props?
- Welche Provider muessen fuer einen lokalen Modus ersetzt oder abstrahiert werden?
- Wie kann `LocalLearningViewModelState` oder ein lokaler UI-Adapter in die bestehende LearnMode-Oberflaeche eingebunden werden?
- Wie bleiben alte Supabase-Flows waehrend der Umstellung kontrolliert erhalten?

Empfehlung:

Erst den bestehenden `LearnModeScreen` und seine sichtbaren Child-Widgets analysieren, dann den kleinsten lokalen Integrationsschnitt planen.

Keine direkte Implementierung ohne diesen Schnitt.
