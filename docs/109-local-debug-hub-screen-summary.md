# 109 Local Debug Hub Screen Summary

Stand: 2026-05-15

## 1. Aufgabe

`LocalDebugHubScreen` ist ein isolierter Debug-Hub fuer lokale Offline-first-Funktionen.

Er buendelt lokale Debug-Einstiege an einer Stelle, damit spaeter nicht mehrere einzelne Debug-Zugaenge im `HomeScreen` noetig sind.

Der Screen liegt im Bereich `local_learning_debug` und ist weiterhin kein produktiver Einstieg. Er veraendert keine bestehenden App-Flows und ersetzt keine bestehende Lern- oder WordHub-Oberflaeche.

## 2. Aktuelle Eintraege

Aktuell enthaelt der Hub zwei Eintraege:

- `Lokaler Lernscreen`
- `Lokale Kategorien`

Beide Eintraege sind einfache `ListTile`-Eintraege.

## 3. Tap Auf Lokaler Lernscreen

Beim Tap auf `Lokaler Lernscreen` wird der bestehende lokale Lern-Testscreen geoeffnet.

Der Hub nutzt dafuer:

- `buildLocalLearningDebugScreen(...)`
- `localLearningDebugDefaultCategoryId`

Aktuell bedeutet das:

- `categoryId: basics`

Der geoeffnete Screen ist der isolierte `LocalLearningTestScreen`.

Dabei passiert nicht automatisch:

- kein Import
- keine Session
- kein Supabase-Zugriff
- keine Datenbankoeffnung durch den Hub selbst

## 4. Tap Auf Lokale Kategorien

Beim Tap auf `Lokale Kategorien` wird der bestehende `LocalWordHubDebugScreen` geoeffnet.

Der Zielscreen kann lokale Kategorien ueber `localCategoriesProvider` anzeigen und nutzt intern den `LocalWordHubDebugEntryPresenter`.

Der Hub selbst:

- laedt keine Kategorien
- startet keinen Import
- startet keine Session
- kennt kein Supabase

## 5. Tests

Die Tests liegen in:

- `test/features/local_learning_debug/local_debug_hub_screen_test.dart`

Aktuell existieren:

- `debug_hub_shows_local_learning_entry`
  - prueft, dass `Lokaler Debug-Hub` sichtbar ist
  - prueft, dass `Lokaler Lernscreen` sichtbar ist

- `debug_hub_shows_local_wordhub_entry`
  - prueft, dass `Lokaler Debug-Hub` sichtbar ist
  - prueft, dass `Lokaler Lernscreen` sichtbar ist
  - prueft, dass `Lokale Kategorien` sichtbar ist

- `debug_hub_opens_local_learning_screen`
  - tippt auf `Lokaler Lernscreen`
  - prueft, dass der `LocalLearningTestScreen` geoeffnet wird
  - prueft den Initialzustand mit `Noch keine Session`
  - prueft `Intensiv lernen` und `Alles lernen`

- `debug_hub_opens_local_wordhub_debug_screen`
  - tippt auf `Lokale Kategorien`
  - nutzt `localCategoriesProvider` mit leerer Liste als Override
  - prueft, dass der `LocalWordHubDebugScreen` geoeffnet wird
  - prueft den Empty-State `Keine lokalen Kategorien gefunden`

Die Tests laufen ohne:

- Supabase
- echten Import
- automatische Session
- produktive Navigation

## 6. Grenzen

Weiterhin gilt:

- kein automatischer Import
- keine automatische Session
- kein Supabase
- keine bestehende App-Flow-Aenderung
- keine produktive Navigation
- keine Aenderung an `main.dart`
- keine Aenderung an `home_screen.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`
- keine Aenderung an `word_hub_screen.dart`

Der Hub ist nur ein isolierter Debug-Screen. Er ist noch nicht als neuer HomeScreen-FAB-Zielscreen verdrahtet.

## 7. Aktuelle Stabilitaetschecks

Zuletzt gruen:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter test test/features/local_learning_debug/`
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`

Ergebnis:

- 213 lokale Tests bestanden
- gezielter Analyzer: `No issues found`

Hinweis:

- Flutter meldete weiterhin Paket-Updates als Hinweis: `76 packages have newer versions incompatible with dependency constraints`
- Es gab keine Testfehler und keine Analyzer-Probleme

## 8. Naechste Schritte

Sinnvoll:

- `LocalDebugHubScreen` als abgeschlossen markieren
- spaeter den `HomeScreen`-Debug-FAB auf den Hub umleiten
- weiterhin nur Debug-/Dev-Zugang verwenden
- weiterhin keinen produktiven Einstieg schaffen
- bestehende Produktnavigation unangetastet lassen

Nicht empfohlen:

- keine direkte produktive Navigation zum Hub
- kein automatischer Import beim Oeffnen des Hubs
- keine automatische Session beim Oeffnen des Hubs
- keine Vermischung mit bestehendem Supabase-WordHub
