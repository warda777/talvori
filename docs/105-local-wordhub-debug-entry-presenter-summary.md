# 105 Local WordHub Debug Entry Presenter Summary

Stand: 2026-05-15

## 1. Aufgabe

`LocalWordHubDebugEntryPresenter` ist ein UI-neutraler Presenter fuer einen spaeteren lokalen WordHub-Debug-Einstieg.

Er nimmt vorhandene lokale Kategorien entgegen und leitet daraus ab, ob ein Debug-Entry sichtbar sein darf und welche lokalen Kategorien angezeigt werden koennen.

Der Presenter baut keine UI, liest keine Datenbank und startet keine lokalen Aktionen.

## 2. Eingabe

Der Presenter nutzt:

- `List<LocalCategory>`

Die Liste kann z. B. spaeter aus `localCategoriesProvider` kommen.

Verwendete Felder:

- `LocalCategory.id`
- `LocalCategory.name`
- `LocalCategory.isArchived`

## 3. Ausgabe

`present(...)` erzeugt einen `LocalWordHubDebugEntryState` mit:

- `isVisible`
- `items`

Jedes `LocalWordHubDebugItem` enthaelt:

- `categoryId`
- `label`

Bedeutung:

- `isVisible` ist `true`, wenn mindestens ein sichtbares lokales Debug-Item vorhanden ist.
- `items` enthaelt die sichtbaren lokalen Kategorien fuer einen spaeteren Debug-Einstieg.
- `categoryId` entspricht der lokalen Kategorie-ID, z. B. `basics`.
- `label` entspricht dem lokalen Kategorienamen, z. B. `Basics`.

## 4. Regeln

Aktuell gelten:

- aktive lokale Kategorien werden sichtbar
- archivierte Kategorien werden nicht sichtbar
- leere Liste -> `isVisible == false`
- nur archivierte Kategorien -> `isVisible == false`
- kein Fallback auf `basics`
- keine Supabase-ID wird verwendet

Der Presenter erzeugt nur Items aus der uebergebenen Liste. Wenn `basics` nicht enthalten ist, wird `basics` auch nicht erfunden.

## 5. Tests

Die Tests liegen in:

- `test/core/local_database/local_wordhub_debug_entry_presenter_test.dart`

Aktuell existieren:

- `local_wordhub_debug_entry_shows_basics_when_local_category_exists`
  - prueft, dass eine aktive lokale Kategorie `basics` den Entry sichtbar macht
  - prueft, dass genau ein Item entsteht
  - prueft `categoryId == basics`
  - prueft `label == Basics`

- `local_wordhub_debug_entry_hidden_when_no_local_categories`
  - prueft, dass eine leere Liste keinen sichtbaren Entry erzeugt
  - prueft, dass eine nur archivierte Kategorie keinen sichtbaren Entry erzeugt
  - prueft, dass keine Items entstehen
  - verhindert implizite Fallbacks auf `basics`

## 6. Grenzen

Weiterhin gilt:

- keine UI-Anbindung
- keine Datenbank
- kein Supabase
- kein Import
- keine Session
- keine Navigation
- kein WordHub-Umbau
- kein bestehender App-Flow wird veraendert

Der Presenter ist nur eine lokale Zustandsableitung aus bereits vorhandenen Kategorien.

## 7. Aktuelle Stabilitaetschecks

Zuletzt gruen:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter test test/features/local_learning_debug/`
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`

Ergebnis:

- 206 lokale Tests bestanden
- gezielter Analyzer: `No issues found`

Hinweis:

- Ein erster parallel gestarteter SRS-Lauf hatte einmalig ein macOS/native-assets Codesign-Race; der direkt wiederholte SRS-Lauf war gruen.

## 8. Naechste Schritte

Sinnvoll:

- `LocalWordHubDebugEntryPresenter` als abgeschlossen markieren
- danach einen kleinen lokalen WordHub-Debug-Screen oder Debug-Entry planen
- bestehenden WordHub weiterhin unangetastet lassen
- spaeter `localCategoriesProvider` und Presenter kontrolliert verbinden
- Tap-Ziel zunaechst weiter zum isolierten `LocalLearningTestScreen` planen

Nicht empfohlen:

- kein direkter Umbau von `WordHubScreen`
- keine Vermischung lokaler Kategorien mit Supabase-Kategorien ohne klare Trennung
- kein automatischer Import beim Oeffnen des WordHub
- keine direkte Anbindung an `LearnModeScreen`
