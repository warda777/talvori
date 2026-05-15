# 96 Category Detail Local Category Adapter Summary

Stand: 2026-05-15

## 1. Aufgabe

Der `CategoryDetailLocalCategoryAdapter` ist eine kleine, UI-neutrale Bruecke zwischen bestehenden CategoryDetail-nahen Daten und der lokalen Offline-first-Kette.

Er nimmt CategoryDetail-nahe Eingaben entgegen und bestimmt daraus eine lokale `categoryId` fuer `talvori_local_v1.db`.

Intern nutzt er den `LocalCategoryIdResolver`.

Der Adapter startet keine Session, oeffnet keine Datenbank und veraendert keine bestehende UI.

## 2. Unterstuetzte Eingaben

Aktuell unterstuetzt:

- `categoryKey`
- `categorySlug`

Beide Eingaben sind optional.

Noch nicht unterstuetzt:

- `categoryName`
- Supabase-ID
- `CategoryInfo`
- `HubSubcat`
- UI-Labels wie `Health & Fitness`

## 3. Prioritaet

Die Prioritaet ist:

1. `categoryKey`
2. `categorySlug`

Ablauf:

- Wenn `categoryKey` gesetzt und bekannt ist, wird diese lokale Kategorie verwendet.
- Wenn `categoryKey` fehlt, leer oder unbekannt ist, wird `categorySlug` geprueft.
- Wenn auch `categorySlug` unbekannt ist oder fehlt, wird `null` zurueckgegeben.

## 4. Mapping-Regeln

Die Mapping-Regeln kommen aus `LocalCategoryIdResolver`.

Aktuell gilt:

- `basics` -> `basics`
- normalisierte `basics`-Werte -> `basics`
  - z. B. ` basics `
  - z. B. `BASICS`
  - z. B. `Basics`
- unbekannte Werte -> `null`
- kein Fallback auf `basics`

Wichtig:

`travel` bleibt aktuell `null`, solange `travel` nicht als lokale Asset-Kategorie freigegeben ist.

## 5. Keine Supabase-ID

Der Adapter nutzt keine Supabase-ID.

Gruende:

- die lokale Offline-first-Kette soll ohne Supabase funktionieren
- Supabase-IDs sind Remote-/Legacy-IDs
- lokale Asset-Kategorien verwenden sprechende lokale IDs wie `basics`
- ein spaeteres Supabase-ID-Mapping soll optional, explizit und separat getestet werden

Der Adapter behandelt alte Kategorie-IDs daher nicht automatisch als lokale Kategorie-IDs.

## 6. Tests

Die Tests liegen in:

- `test/core/local_database/category_detail_local_category_adapter_test.dart`

Aktuell existieren:

- `adapter_maps_basics_to_local_category_id`
  - sichert `categoryKey: basics -> basics` ab
- `adapter_returns_null_for_unknown_category`
  - sichert ab, dass unbekannte Keys, `travel`, `null` und leere Eingaben keinen Fallback auf `basics` bekommen
- `adapter_uses_category_slug_when_key_missing`
  - sichert ab, dass `categorySlug` genutzt wird, wenn `categoryKey` fehlt, leer oder unbekannt ist
  - sichert auch normalisierte Slug-Werte wie `BASICS`

## 7. Grenzen

Der Adapter macht weiterhin nicht:

- keine UI-Anbindung
- keine Datenbank oeffnen
- kein Supabase verwenden
- keinen Import starten
- keine Session starten
- keinen Progress erzeugen
- keine Review-History schreiben
- keine Navigation ausloesen
- `LearnModeController` nicht verwenden oder veraendern
- `learn_mode_screen.dart` nicht verwenden oder veraendern
- `category_detail_screen.dart` nicht verwenden oder veraendern

## 8. Aktuelle Stabilitaetschecks

Zuletzt gruen:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter test test/features/local_learning_debug/`
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`

Ergebnis:

- 198 lokale Tests bestanden
- gezielter Analyzer: `No issues found`

## 9. Naechste Schritte

Sinnvoll:

- `CategoryDetailLocalCategoryAdapter` als abgeschlossenen lokalen Adapter-Baustein markieren
- lokalen Startpfad aus CategoryDetail separat planen
- bestehende UI weiterhin nicht direkt umbauen
- spaeter weitere lokale Asset-Kategorien explizit freigeben
- spaeter einen Adapter fuer bestehende UI-Daten oder einen lokalen Startpfad testen

Nicht empfohlen:

- kein direkter Umbau von `CategoryDetailScreen`
- kein direkter Umbau von `LearnModeController`
- keine automatische Supabase-ID-Uebernahme
- kein Fallback unbekannter Kategorien auf `basics`
