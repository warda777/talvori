# 107 Local WordHub Debug Screen Summary

Stand: 2026-05-15

## 1. Aufgabe

`LocalWordHubDebugScreen` ist ein isolierter Debug-Screen fuer lokale Kategorien.

Er macht Kategorien aus der lokalen Offline-first-Datenbank sichtbar, ohne den bestehenden `WordHubScreen` umzubauen oder den Supabase-WordHub zu ersetzen.

Der Screen dient als lokaler Debug-/QA-Einstieg fuer den Weg:

- lokale Kategorien laden
- sichtbare lokale Kategorien anzeigen
- bei Auswahl in den isolierten `LocalLearningTestScreen` wechseln

## 2. Genutzte Provider Und Presenter

Der Screen nutzt:

- `localCategoriesProvider`
- `LocalWordHubDebugEntryPresenter`

`localCategoriesProvider` liefert lokale Kategorien ueber die bestehende lokale Bootstrap-/Repository-Kette.

Der Provider:

- nutzt `localBootstrapProvider`
- liest ueber `CategoryRepository`
- oeffnet keine eigene Datenbank im Screen
- startet keinen Import

`LocalWordHubDebugEntryPresenter` leitet daraus UI-neutrale Debug-Items ab.

Der Presenter:

- filtert archivierte Kategorien heraus
- erzeugt Items mit `categoryId` und `label`
- entscheidet ueber `isVisible`
- kennt keine Navigation, keine Datenbank und kein Supabase

## 3. Darstellbare Zustaende

Der Screen kann aktuell darstellen:

- lokale Kategorien sichtbar
- Empty-State
- Ladezustand
- Fehlerzustand

Wenn lokale aktive Kategorien vorhanden sind, zeigt der Screen eine Liste mit Kategorie-Items.

Beispiel:

- `Basics`
- lokale `categoryId`: `basics`

Wenn keine sichtbaren lokalen Kategorien vorhanden sind, zeigt der Screen:

- `Keine lokalen Kategorien gefunden`

Dabei wird kein Fallback auf `basics` erzeugt.

## 4. Tap Auf Kategorie

Beim Tap auf eine lokale Kategorie wird der isolierte lokale Lern-Testscreen geoeffnet:

- `buildLocalLearningDebugScreen(categoryId: item.categoryId)`

Damit wird z. B. fuer `basics` der `LocalLearningTestScreen` mit `categoryId: basics` gebaut.

Dabei passiert nicht automatisch:

- kein Import
- kein Sessionstart
- keine Progress-Erzeugung
- keine Review-History
- kein Supabase-Zugriff

## 5. Tests

Die Tests liegen in:

- `test/features/local_learning_debug/local_wordhub_debug_screen_test.dart`

Aktuell existieren:

- `local_wordhub_debug_screen_shows_basics_when_local_category_exists`
  - prueft, dass eine vom Provider gelieferte aktive lokale Kategorie `Basics` angezeigt wird
  - prueft, dass der Screen-Titel `Lokale Kategorien` sichtbar ist

- `local_wordhub_debug_screen_shows_empty_state_when_no_local_categories`
  - prueft, dass bei leerer Kategorienliste der Empty-State angezeigt wird
  - prueft, dass `Basics` nicht sichtbar ist
  - verhindert implizite Fallbacks

- `local_wordhub_debug_screen_opens_local_learning_screen_with_category_id`
  - prueft, dass Tap auf `Basics` den lokalen `LocalLearningTestScreen` oeffnet
  - prueft den initialen Testscreen-Zustand
  - prueft, dass der lokale Lernscreen ohne automatische Session startet

## 6. Grenzen

Weiterhin gilt:

- kein bestehender `WordHubScreen`-Umbau
- kein Supabase
- kein automatischer Import
- keine automatische Session
- keine Produktnavigation
- keine Aenderung bestehender Lernflows
- keine Aenderung an `LearnModeController`
- keine Aenderung an `learn_mode_screen.dart`
- keine Nutzung von `word_providers.dart`
- keine alte `local_word_database.dart`

Der Screen ist weiterhin ein isolierter Debug-Screen im Bereich `local_learning_debug`.

## 7. Aktuelle Stabilitaetschecks

Zuletzt gruen:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter test test/features/local_learning_debug/`
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`

Ergebnis:

- 209 lokale Tests bestanden
- gezielter Analyzer: `No issues found`

Hinweis:

- Flutter meldete weiterhin Paket-Updates als Hinweis: `76 packages have newer versions incompatible with dependency constraints`
- Es gab keine Testfehler und keine Analyzer-Probleme

## 8. Naechste Schritte

Sinnvoll:

- `LocalWordHubDebugScreen` als abgeschlossen markieren
- spaeter einen Debug-Zugang zu diesem Screen separat planen
- bestehenden `WordHubScreen` weiterhin unangetastet lassen
- produktive Navigation weiterhin separat entscheiden
- lokalen WordHub-Debug-Weg erst nach bewusstem Debug-Gate anbinden

Nicht empfohlen:

- kein direkter Umbau des bestehenden WordHub
- keine Vermischung lokaler Kategorien mit Supabase-Kategorien ohne klares Konzept
- kein automatischer Import beim Oeffnen des Screens
- keine direkte Produktintegration ohne separaten Plan
