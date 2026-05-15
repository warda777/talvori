# 94 Local Category ID Resolver Summary

Stand: 2026-05-14

## 1. Aufgabe

Der `LocalCategoryIdResolver` ist eine kleine, UI-neutrale Bruecke zwischen bestehender Talvori-UI und lokaler Offline-first-Datenbank.

Er bildet bekannte Kategorie-Eingaben auf lokale `categoryId`-Werte ab, die in `talvori_local_v1.db` verwendet werden koennen.

Er ist bewusst kein Repository, kein Provider und kein Importservice.

## 2. Aktuell Unterstuetzte Eingaben

Aktuell unterstuetzt:

- `basics`
- normalisierte Varianten von `basics`, z. B.:
  - ` basics `
  - `BASICS`
  - `Basics`

Noch nicht als lokale Kategorie freigegeben:

- `travel`
- weitere `word_hub_taxonomy.key`-Werte
- Supabase-IDs
- UI-Labels wie `Health & Fitness`

## 3. Ausgabe

Die Methode `resolve(String input)` gibt zurueck:

- eine lokale `categoryId`, wenn die Eingabe bekannt ist
- `null`, wenn die Eingabe unbekannt oder nicht freigegeben ist

Beispiel:

- `resolve('basics')` -> `basics`

## 4. Aktuelle Mapping-Regeln

Aktuell gelten diese Regeln:

- `basics` -> `basics`
- Eingaben werden mit `trim()` bereinigt
- Eingaben werden mit `toLowerCase()` normalisiert
- unbekannte Eingaben -> `null`
- kein Fallback auf `basics`

Wichtig:

`travel` gibt aktuell bewusst `null` zurueck, solange `travel` nicht als lokale Asset-Kategorie freigegeben ist.

## 5. Keine Supabase-ID Als Primaermapping

Supabase-IDs werden nicht als primaeres Mapping verwendet.

Gruende:

- die lokale Offline-first-Kette soll ohne Supabase funktionieren
- echte lokale Asset-Dateien verwenden stabile, sprechende lokale IDs
- Supabase-IDs sind technische Remote-IDs
- lokale Kategorien koennen existieren, ohne dass es eine Supabase-Kategorie dazu gibt
- spaetere Legacy-Mappings sollen optional und explizit bleiben

## 6. Tests

Die Tests liegen in:

- `test/core/local_database/local_category_id_resolver_test.dart`

Aktuell existieren:

- `local_category_id_resolver_maps_basics_debug_category`
  - sichert `basics -> basics` ab
- `local_category_id_resolver_normalizes_known_key`
  - sichert Trim-/Lowercase-Normalisierung fuer bekannte Keys ab
- `local_category_id_resolver_returns_null_for_unknown_category`
  - sichert ab, dass unbekannte Kategorien, `travel` und leere Eingaben `null` ergeben
  - verhindert implizite Fallbacks auf `basics`

## 7. Grenzen

Der Resolver macht weiterhin nicht:

- keine Datenbank oeffnen
- kein Supabase verwenden
- keinen Import starten
- keine Session starten
- keinen Progress erzeugen
- keine Review-History schreiben
- keine UI anbinden
- keine Navigation ausloesen
- `LearnModeController` nicht verwenden oder veraendern
- `learn_mode_screen.dart` nicht verwenden oder veraendern

## 8. Aktuelle Stabilitaetschecks

Zuletzt gruen:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter test test/features/local_learning_debug/`
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`

Ergebnis:

- 195 lokale Tests bestanden
- gezielter Analyzer: `No issues found`

## 9. Naechste Schritte

Sinnvoll:

- `LocalCategoryIdResolver` als kleinen abgeschlossenen Baustein markieren
- spaeter weitere lokale Asset-Kategorien explizit ergaenzen
- erst nach vorhandenen Asset-Kategorien weitere Taxonomy-Keys freigeben
- danach einen Adapter fuer bestehende UI-Daten planen

Nicht empfohlen:

- keine automatische Freigabe aller `word_hub_taxonomy.key`-Werte
- kein Fallback unbekannter Kategorien auf `basics`
- keine direkte Aenderung an bestehendem `LearnModeController`
- keine direkte Aenderung an `learn_mode_screen.dart`
