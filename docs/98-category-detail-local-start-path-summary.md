# 98 Category Detail Local Start Path Summary

Stand: 2026-05-15

## 1. Aufgabe

`CategoryDetailLocalStartPath` ist ein UI-neutraler Startpfad-Baustein fuer eine spaetere kontrollierte Verbindung zwischen `CategoryDetail` und der lokalen Offline-first-Lernkette.

Er entscheidet, ob fuer gegebene CategoryDetail-nahe Daten ein lokaler Debug-Lernpfad angeboten werden darf.

Er nutzt intern den `CategoryDetailLocalCategoryAdapter`.

Der Baustein startet keine Session, navigiert nicht und veraendert keine bestehende UI.

## 2. Aktuell Unterstuetzte Eingaben

Aktuell unterstuetzt:

- `categorySlug`

Beispiel:

- `categorySlug: basics`

Noch nicht unterstuetzt:

- `categoryKey` direkt im StartPath
- `categoryName`
- Supabase-ID
- `CategoryInfo`
- UI-Labels

Diese Felder koennen spaeter kontrolliert ergaenzt werden, wenn ein konkreter UI-Startpfad geplant wird.

## 3. Ausgabe

`resolve(...)` gibt ein `CategoryDetailLocalStartPathResult` zurueck.

Das Ergebnis enthaelt:

- `localCategoryId`
- `canOpenLocalDebugLearning`

Bedeutung:

- `localCategoryId` ist die lokale Kategorie-ID fuer `talvori_local_v1.db`, falls ein Mapping existiert.
- `canOpenLocalDebugLearning` ist `true`, wenn eine lokale Kategorie-ID vorhanden ist.
- `canOpenLocalDebugLearning` ist `false`, wenn kein lokales Mapping existiert.

## 4. Aktuelle Regeln

Aktuell gilt:

- `categorySlug: basics` -> `localCategoryId: basics`
- `categorySlug: basics` -> lokaler Debug-Lernpfad erlaubt
- `categorySlug: unknown` -> kein lokaler Debug-Lernpfad
- `categorySlug: travel` -> kein lokaler Debug-Lernpfad
- `categorySlug: null` -> kein lokaler Debug-Lernpfad
- kein Fallback auf `basics`

`travel` bleibt bewusst deaktiviert, solange `travel` nicht als lokale Asset-Kategorie freigegeben ist.

## 5. Tests

Die Tests liegen in:

- `test/core/local_database/category_detail_local_start_path_test.dart`

Aktuell existieren:

- `local_start_path_resolves_basics_from_category_slug`
  - sichert ab, dass `categorySlug: basics` zu `localCategoryId: basics` fuehrt
  - sichert ab, dass `canOpenLocalDebugLearning == true` ist
- `local_start_path_hidden_when_no_local_mapping`
  - sichert ab, dass `unknown`, `travel` und `null` keine lokale Kategorie-ID liefern
  - sichert ab, dass `canOpenLocalDebugLearning == false` bleibt
  - verhindert implizite Fallbacks auf `basics`

## 6. Grenzen

Der StartPath macht weiterhin nicht:

- keine UI-Anbindung
- keine Datenbank oeffnen
- kein Supabase verwenden
- keinen Import starten
- keine Session starten
- keinen Progress erzeugen
- keine Review-History schreiben
- keine Navigation ausloesen
- keinen bestehenden Startbutton veraendern
- `LearnModeController` nicht verwenden oder veraendern
- `learn_mode_screen.dart` nicht verwenden oder veraendern
- `category_detail_screen.dart` nicht verwenden oder veraendern

## 7. Aktuelle Stabilitaetschecks

Zuletzt gruen:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter test test/features/local_learning_debug/`
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`

Ergebnis:

- 200 lokale Tests bestanden
- gezielter Analyzer: `No issues found`

## 8. Naechste Schritte

Sinnvoll:

- `CategoryDetailLocalStartPath` als abgeschlossenen UI-neutralen Baustein markieren
- danach einen Debug-only Button in `CategoryDetailScreen` separat planen
- alten Supabase-Startflow weiterhin unangetastet lassen
- bei UI-Planung klar trennen zwischen altem Startbutton und lokalem Debug-Einstieg
- lokale Produktintegration erst nach weiteren Adapter-/Regressionstests planen

Nicht empfohlen:

- kein direkter Umbau des bestehenden Startbuttons
- keine direkte Anbindung an `LearnModeScreen`
- kein automatischer Sessionstart beim Oeffnen von `CategoryDetailScreen`
- kein automatischer Import
