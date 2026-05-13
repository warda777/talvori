# 39 Local App Database Path Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den lokalen App-Datenbankpfad-Baustein zusammen.

Der Baustein ist weiterhin UI-neutral und oeffnet keine Datenbank. Er bildet nur den spaeteren Pfad zur neuen lokalen Offline-first-Datenbank.

## LocalAppDatabasePath

`LocalAppDatabasePath` uebernimmt nur eine Aufgabe:

- aus einem uebergebenen Basis-Datenbankpfad den vollstaendigen Pfad zur neuen lokalen Talvori-Datenbank bilden

Umgesetzt ist:

- `databaseName`
- `buildPath(String databasesPath)`

Die Methode:

- verwendet den uebergebenen Basisdatenbankpfad
- haengt den neuen Datenbanknamen an
- oeffnet keine Datenbank
- ruft `getDatabasesPath()` nicht selbst auf
- erzeugt keine Repositorys
- kennt keine UI
- kennt kein Supabase
- greift nicht auf die alte `local_word_database.dart` zu

## Datenbankname

Verwendeter Name:

- `talvori_local_v1.db`

Dieser Name ist die geplante neue lokale Offline-first-Datenbank fuer die V1-Schicht unter `lib/core/local_database/`.

## Trennung Von word_progress.db

Die alte lokale Datenbank aus `lib/features/words/data/local_word_database.dart` verwendet:

- `word_progress.db`

`talvori_local_v1.db` ist bewusst getrennt davon.

Gruende:

- `word_progress.db` gehoert zur alten lokalen A-SRS-/Refill-/Mirror-Logik.
- Die alte Datenbank verwendet andere Tabellen und andere Progress-Regeln.
- Die alte `word_progress`-Tabelle ist nicht kompatibel mit dem neuen V1-Schema.
- Die alte Logik nutzt unter anderem `is_mastered`, `ever_enrolled`, `streak_in_stage`, `device_id` und `device_seq`.
- Die neue Engine verwendet `S0` bis `S5`, `pass_count`, `wrong_count`, `next_due_at`, Sessions und Review-History.
- Eine Vermischung koennte bestehende lokale Daten beschaedigen oder neue Repositorys gegen falsche Tabellen laufen lassen.

Fuer Version 1 gilt:

- `word_progress.db` nicht aendern
- `word_progress.db` nicht migrieren
- `word_progress.db` nicht fuer neue lokale SRS-Engine verwenden
- `talvori_local_v1.db` separat halten

## Tests

Datei:

- `test/core/local_database/local_app_database_path_test.dart`

Tests:

- `app_database_path_uses_expected_name`
- `app_database_path_does_not_use_old_word_progress_database_name`

Abgesichert wird:

- Der neue Datenbankname ist `talvori_local_v1.db`.
- Der gebaute Pfad endet auf `talvori_local_v1.db`.
- Der Pfad verwendet nicht `word_progress.db`.
- Der neue Datenbankname ist nicht identisch mit dem alten Namen `word_progress.db`.
- Es wird keine Datenbank geoeffnet.

## Weiterhin Geltende Grenzen

Weiterhin nicht umgesetzt:

- keine Datenbankoeffnung ueber echten App-Pfad
- keine Repository-Erzeugung
- keine Seed-Daten
- kein Import echter Woerter
- keine UI-Anbindung
- keine Provider-Anbindung
- keine Navigation
- keine Supabase-Anbindung
- keine Supabase-Entfernung
- keine App-Flow-Aenderung
- keine Migration alter lokaler Daten
- keine Migration von Supabase-Daten
- keine Aenderung an `local_word_database.dart`

Der Baustein ist nur Pfadlogik.

## Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte:

1. Einen kleinen Test ergaenzen, der sicherstellt, dass die neue Pfadlogik nicht die alte `LocalWordDatabase` initialisiert.
2. Danach einen UI-neutralen Baustein planen, der `getDatabasesPath()` holt und `LocalAppDatabasePath.buildPath(...)` verwendet.
3. Kleine lokale Seed-Daten fuer Kategorien und Woerter planen.
4. Seed-Daten erst separat implementieren und testen.
5. Danach pruefen, ob aus Seed-Daten Progress initialisiert und eine lokale Session gestartet werden kann.

Empfehlung:

Der naechste Schritt sollte weiterhin lokal und UI-neutral bleiben. Keine UI- oder Provider-Anbindung, bis Datenpfad, Seed-Daten und lokale Startkette sauber getestet sind.
