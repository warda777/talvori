# Plan: Lokaler Content-Paket-Marker

## 1. Ziel

Talvori soll später geprüfte, versionierte Content-Pakete aus Supabase laden können, ohne lokale Nutzerstände zu überschreiben. Der aktuelle Legacy-Auto-Sync ist bereits über `ReleaseSyncPolicy.allowLegacySupabaseWordsAutoSync` im Release geschützt. Der nächste Schritt ist ein lokaler Marker, der eindeutig speichert, welche freigegebenen Sprach-/Content-Pakete bereits importiert wurden.

Dieser Plan ist bewusst vorbereitend: Es wird noch keine produktive Migration eingeführt, keine Supabase-Tabelle erstellt und kein Import ausgeführt.

## 2. Geprüfte lokale Struktur

Relevante Dateien und Bereiche:

- `lib/core/local_database/local_database_schema.dart`
- `lib/core/local_database/local_database_factory.dart`
- `lib/core/local_database/repositories/local_import_settings_repository.dart`
- `lib/core/local_database/repositories/word_repository.dart`
- `lib/core/local_database/services/supabase_words_local_import_service.dart`
- `lib/core/local_database/services/supabase_words_local_auto_sync_service.dart`
- `lib/core/local_database/services/supabase_words_remote_reader.dart`
- `lib/core/local_database/providers/supabase_words_local_import_controller_provider.dart`
- `lib/core/sync/release_sync_policy.dart`
- `lib/features/home/application/profile_preferences_controller.dart`
- `test/core/local_database/local_database_schema_test.dart`
- `test/core/local_database/supabase_words_local_import_service_test.dart`
- `test/core/local_database/supabase_words_local_auto_sync_service_test.dart`

Vorhandene Tabellen:

- `words`
- `categories`
- `word_world_memberships`
- `word_progress`
- `review_history`
- `learning_sessions`
- `session_items`
- `word_sources`
- `settings`

Die vorhandene `settings`-Tabelle wird aktuell unter anderem über `LocalImportSettingsRepository` für den lokalen Default-Import-Marker genutzt. Das reicht für einen einfachen Asset-Import, ist aber nicht stark genug für mehrere versionierte Content-Pakete, Sprachpaare, Prüfsummen und Update-Entscheidungen.

## 3. Gibt es bereits einen geeigneten Marker?

Nein, nicht für versionierte Content-Pakete.

Vorhanden ist:

- `LocalImportSettingsRepository`
- Keys wie `default_words_v1_imported_at`, `default_words_v1_asset_key`, `default_words_v1_import_version`

Das ist geeignet für:

- einen einzelnen lokalen Default-Import
- einfache Import-Metadaten
- letzte Fehlermeldung oder letzter Versuch

Nicht geeignet ist es für:

- mehrere Pakete parallel
- mehrere Sprachpaare
- Paketversionen mit Update-Vergleich
- Checksums
- Paketstatus wie `approved`
- `min_app_version`
- Wort-/Kategorie-Zählungen pro Paket
- spätere Paket-Historie oder Rollback-Entscheidungen

Empfehlung: Die `settings`-Marker bleiben für lokale App-/Asset-Importe bestehen. Für Supabase-Content-Pakete sollte später eine eigene SQLite-Tabelle eingeführt werden.

## 4. Empfohlenes lokales Marker-Modell

Tabellenname:

```sql
content_package_imports
```

Empfohlene Felder:

```sql
CREATE TABLE content_package_imports (
  content_package_id TEXT NOT NULL,
  language_pair TEXT NOT NULL,
  base_language TEXT NOT NULL,
  learning_language TEXT NOT NULL,
  translation_language TEXT NOT NULL,
  version TEXT NOT NULL,
  status TEXT NOT NULL,
  checksum TEXT,
  source TEXT NOT NULL,
  min_app_version TEXT,
  word_count INTEGER NOT NULL DEFAULT 0,
  category_count INTEGER NOT NULL DEFAULT 0,
  imported_at TEXT NOT NULL,
  last_checked_at TEXT,
  metadata_json TEXT,
  PRIMARY KEY (content_package_id, language_pair)
)
```

Empfohlene Indizes:

```sql
CREATE INDEX idx_content_package_imports_language_pair
ON content_package_imports (language_pair);

CREATE INDEX idx_content_package_imports_status
ON content_package_imports (status);

CREATE INDEX idx_content_package_imports_learning_translation
ON content_package_imports (learning_language, translation_language);
```

## 5. Feldbedeutung

- `content_package_id`
  - stabile Paket-ID aus Supabase, z. B. `core-en-de-a1-v1`
  - darf nicht nur aus dem Namen abgeleitet werden

- `language_pair`
  - normalisierter Schlüssel, z. B. `en-de`, `en-es`, `en-fr`
  - dient als schneller Guard für Nutzerprofil und Paketentscheidung

- `base_language`
  - Sprache der Basis-/Lemma-Struktur, z. B. `en`
  - wichtig, wenn Kategorien und Wort-Keys an einer Basissprache hängen

- `learning_language`
  - Sprache, die gelernt wird, z. B. `en`
  - entspricht fachlich nicht automatisch der UI-Sprache

- `translation_language`
  - Muttersprache oder Übersetzungssprache, z. B. `de`, `es`, `fr`
  - muss von `appLanguage` getrennt bleiben

- `version`
  - Paketversion, z. B. `1.0.0`
  - sollte später semantisch oder über einen monotonen `version_code` vergleichbar sein

- `status`
  - lokaler Importstatus, z. B. `imported`, `superseded`, `failed`
  - Remote-Status `approved` sollte vor Import geprüft werden; lokal wird gespeichert, was importiert wurde

- `checksum`
  - Prüfsumme des freigegebenen Remote-Pakets
  - verhindert stillen Inhaltstausch unter gleicher Version

- `source`
  - z. B. `supabase`, `bundled_asset`, `manual_debug`

- `min_app_version`
  - kleinste App-Version, für die das Paket gedacht ist
  - verhindert Import neuer Paketstrukturen durch alte Apps

- `word_count`, `category_count`
  - Plausibilitätswerte für Readback, Tests und Diagnose

- `imported_at`, `last_checked_at`
  - Import- und Prüfzeitpunkte

- `metadata_json`
  - bewusst optionaler Erweiterungsplatz für spätere Felder wie `premium_tier`, `package_type`, `taxonomy_version`

## 6. Sollte der Marker in SQLite liegen?

Ja.

Begründung:

- Die importierten Wörter, Kategorien und Memberships liegen ebenfalls in SQLite.
- Offline-first bleibt erhalten.
- Paketentscheidungen können ohne Netzwerk getroffen werden.
- Der Marker kann in derselben Transaktion wie der spätere Paketimport geschrieben werden.
- Reinstall/Backup kann später die lokale Content-Historie konsistent wiederherstellen.

Nicht empfohlen:

- Nur `SharedPreferences`: zu schwach für Paketlisten und Transaktionen.
- Nur Supabase: offline nicht verfügbar und nicht atomar mit lokalem Import.
- Nur `settings`: möglich, aber bei mehreren Paketen unübersichtlich und fehleranfällig.

## 7. Spätere Migration

Für die echte Umsetzung wäre eine neue lokale DB-Version nötig, z. B. `version = 7`.

Geplanter Migrationsschritt:

```dart
static Future<void> migrateV6ToV7(Database db) async {
  await createContentPackageImportsTable(db);
}
```

Wichtig:

- Migration idempotent mit `CREATE TABLE IF NOT EXISTS`.
- Keine bestehenden `words`, `word_world_memberships` oder `word_progress` verändern.
- Keine vorhandenen User-Daten zurücksetzen.
- Schema-Test für neue Tabelle, Spalten und Indizes ergänzen.

Die Migration wird jetzt bewusst verschoben, weil noch keine Remote-Paketstruktur mit `approved`, `version`, `checksum` und Sprachpaarfilter existiert.

## 8. Trennung von Content-Daten und User-Daten

Content-Daten:

- Wörter
- Übersetzungen
- Kategorien
- Wortwelten
- Lernlevel
- Top-Wörter
- Beispielsätze
- Paket-Metadaten

User-Daten:

- `word_progress`
- `word_world_memberships.is_known`
- `word_world_memberships.is_reviewed_for_learning`
- `word_world_memberships.is_disabled`
- Favoriten
- eigene Wörter
- Einstellungen
- Streaks
- Chat-/Companion-Verläufe

Release-Regel:

Content-Paket-Importe dürfen User-Daten nicht ungefragt überschreiben. Besonders geschützt sind `word_progress` und alle nutzerbezogenen Membership-Flags.

## 9. Schutz vor Überschreiben von User-Daten

Der spätere Content-Paket-Import sollte:

- neue Wörter und Kategorien hinzufügen
- vorhandene Wörter über stabile IDs oder Sprach-/Term-Keys wiederverwenden
- geprüfte Übersetzungen nur nach klarer Konfliktstrategie aktualisieren
- `word_progress` nie anfassen
- `is_known`, `is_reviewed_for_learning`, `is_disabled` nie zurücksetzen
- Memberships hinzufügen, aber bestehende Membership-Flags nicht ersetzen
- Paket-Marker erst nach erfolgreichem Import schreiben
- Import und Marker in einer SQLite-Transaktion ausführen

Bei Konflikten:

- lokale Nutzerstände haben Vorrang
- lokale Übersetzung wird nicht blind überschrieben
- Konflikte werden im Importreport sichtbar gemacht
- Paketimport kann teilweise abgelehnt werden, wenn Checksum/Version nicht passt

## 10. Zusammenhang mit Sprachpaaren

Aktuelle Profileinstellungen:

- `ProfilePreferences.appLanguage`
- `ProfilePreferences.nativeLanguage`
- `ProfilePreferences.learningLanguage`

Diese sind weiterhin kompatibel zu sichtbaren Sprachlabels, z. B. `Deutsch`, `Englisch`. Zusätzlich gibt es jetzt eine zentrale Sprachcode-Grundlage in `lib/core/language/language_code.dart`. Sie leitet aus bestehenden Labels stabile Codes ab und hält die UI damit rückwärtskompatibel:

- `app_language_code`, z. B. `de`
- `native_language_code`, z. B. `de`
- `learning_language_code`, z. B. `en`
- `translation_language_code`, z. B. `de`

Der Paketmarker sollte keine UI-Labels speichern, sondern normalisierte Codes:

- `learning_language = en`
- `translation_language = de`
- `language_pair = en-de`

So kann Talvori später auch Pakete wie `en-es`, `en-fr`, `es-en`, `fr-en`, `en-ja`, `en-zh`, `en-hi`, `en-ru` sauber unterscheiden.

Aktueller Stand:

- `TalvoriLanguages` kennt stabile Codes für `de`, `en`, `es`, `fr`.
- Weitere große Zielsprachen sind intern vorbereitet: `zh`, `hi`, `ja`, `ru`, `ar`.
- Produktiv sichtbar bleiben im MVP weiterhin die bestehenden Sprachen Deutsch, Englisch, Spanisch und Französisch.
- `ProfilePreferences` speichert noch keine migrierten Codes, bietet aber kompatible Getter wie `appLanguageCode`, `nativeLanguageCode`, `learningLanguageCode` und `contentLanguagePair`.
- `ContentPackageMetadata`, `ContentPackageImportMarker` und `ContentPackageSyncPolicy` normalisieren Sprachcodes und Sprachpaare über diese zentrale Grundlage.
- Eine echte Migration bestehender gespeicherter Labels auf Codes ist später möglich, aber in diesem Schritt bewusst nicht umgesetzt.

## 11. Offline-first-Verhalten

Der Marker unterstützt Offline-first:

- Wenn kein Netzwerk vorhanden ist, nutzt die App den lokalen Content und Marker.
- Wenn ein Paket bereits importiert wurde, muss beim Start nichts nachgeladen werden.
- Wenn später ein Online-Check fehlschlägt, bleibt der lokale Content nutzbar.
- Neue Pakete werden nur nach kontrollierter Prüfung geladen.

Empfohlenes späteres Verhalten:

1. Lokalen Marker lesen.
2. Nutzer-Sprachpaar bestimmen.
3. Optional Remote-Paketliste abrufen.
4. Nur `approved` Pakete mit passendem Sprachpaar und kompatibler App-Version berücksichtigen.
5. Version/Checksum gegen lokalen Marker vergleichen.
6. Nur fehlende oder neuere Pakete importieren.
7. Bei Fehlern still auf lokalen Bestand zurückfallen.

## 12. Remote-Approval-Prüfung

Supabase sollte später nicht direkt aus `words`, `categories`, `word_categories` global importiert werden. Stattdessen sollte es eine Paket-Metadatenebene geben.

Remote-Paketmetadaten sollten mindestens enthalten:

- `content_package_id`
- `status`, z. B. `draft`, `review`, `approved`, `deprecated`
- `language_pair`
- `base_language`
- `learning_language`
- `translation_language`
- `version`
- `checksum`
- `min_app_version`
- `word_count`
- `category_count`
- `published_at`

Importregel:

- Nur `status = approved`.
- Nur passendes Sprachpaar.
- Nur kompatible `min_app_version`.
- Nur wenn lokale Version fehlt oder älter ist.
- Nur wenn Checksum plausibel ist.

## 13. Einordnung zum aktuellen Legacy-Sync

Aktuell:

- `SupabaseRestWordsRemoteReader` liest globale Tabellen `words`, `categories`, `word_categories`.
- `SupabaseWordsLocalImportService` schreibt lokal in `words`, `categories`, `word_world_memberships`.
- `SupabaseWordsLocalAutoSyncService` entscheidet noch über lokale Wortanzahl.
- `ReleaseSyncPolicy` verhindert diesen Legacy-Auto-Sync im Release standardmäßig.

Nächster technischer Ausbau:

- Remote-Paketmetadaten lesen statt globale Tabellen blind zu importieren.
- Paketentscheidung über Marker/Policy treffen.
- Erst danach den Import ausführen.
- Marker nach erfolgreichem Import lokal schreiben.

## 14. Tests für die spätere Umsetzung

Schema-Tests:

- Tabelle `content_package_imports` existiert nach Migration.
- Spalten und Indizes existieren.
- Migration ist idempotent.
- Defaultwerte sind korrekt.

Repository-Tests:

- Marker speichern und laden.
- Marker nach `content_package_id` und `language_pair` finden.
- Neuere Version wird erkannt.
- Gleiche Version mit gleicher Checksum wird übersprungen.
- Gleiche Version mit anderer Checksum wird als Risiko markiert.

Policy-Tests:

- Paket ohne `approved` wird abgelehnt.
- Falsches Sprachpaar wird abgelehnt.
- Zu hohe `min_app_version` wird abgelehnt.
- Bereits importierte gleiche Version wird übersprungen.
- Neuere freigegebene Version wird als importierbar markiert.

Import-Tests:

- Marker wird erst nach erfolgreichem Import geschrieben.
- Fehlerhafter Import schreibt keinen Marker.
- `word_progress` bleibt unverändert.
- `is_known`, `is_reviewed_for_learning`, `is_disabled` bleiben unverändert.
- Memberships werden ergänzt, ohne User-Flags zu überschreiben.

Offline-/Fehler-Tests:

- Remote-Fehler blockiert App-Start nicht.
- Lokaler Content bleibt nutzbar.
- Kein Import, wenn Paketentscheidung unklar ist.

## 15. Empfohlene Reihenfolge

1. Remote-Paketmetadaten fachlich definieren, ohne Supabase produktiv zu ändern.
2. Stabile Sprachcodes für App-/Native-/Learning-Language vorbereiten.
3. Lokales Value-Object für Paketmetadaten und Importentscheidung ergänzen.
4. Policy-Tests für `approved`, `language_pair`, `version`, `checksum`, `min_app_version`.
5. SQLite-Migration für `content_package_imports`.
6. Repository für Marker lesen/schreiben.
7. Supabase-Reader auf Paketmetadaten erweitern.
8. Importservice paketbewusst ausführen.
9. Legacy-Auto-Sync vollständig durch Content-Paket-Sync ersetzen.

## 16. Offene Fragen

- Wird `language_pair` als `learning-translation` gespeichert, z. B. `en-de`, oder braucht Talvori zusätzlich eine separate `base_language`-Ebene?
- Sollen Content-Pakete pro Sprachpaar, pro Lernsprache oder pro Pakettyp versioniert werden?
- Wie werden Premium-Pakete später lokal markiert, ohne Kauf-/Account-Logik mit Content-Import zu vermischen?
- Darf ein Paket bestehende Content-Übersetzungen aktualisieren, wenn Nutzer bereits Fortschritt auf dem Wort hat?
- Soll es einen Rollback-Status geben, wenn ein Paket nachträglich deprecated wird?
- Wie wird die App-Version zuverlässig für `min_app_version` verglichen?

## 17. Aktuelle Entscheidung

Der erste vorbereitende Code-Schritt ist jetzt umgesetzt, ohne den Import produktiv anzuschließen.

Umgesetzt wurden:

- `lib/core/sync/content_package_metadata.dart`
  - reines Value-Object für Remote-Paketmetadaten
  - normalisiert Sprachcodes und Statuswerte über die zentrale Sprachcode-Grundlage
  - enthält Pflichtfelder wie `contentPackageId`, `languagePair`, `baseLanguage`, `learningLanguage`, `translationLanguage`, `version`, `status`, `checksum`, `source`, `minAppVersion`, `wordCount`, `categoryCount`, `publishedAt`
- `lib/core/sync/content_package_import_marker.dart`
  - reines Value-Object für lokal bereits importierte Pakete
  - entspricht dem späteren SQLite-Marker, aber ohne Repository und ohne Migration
- `lib/core/language/language_code.dart`
  - zentrale Mapping-/Normalisierungsschicht für UI-Labels und stabile Sprachcodes
  - unterstützt vorhandene Labels wie `Deutsch`, `Englisch`, `Spanisch`, `Französisch` und Codes wie `DE`, `EN`, `ES`, `FR`
- `lib/core/sync/version_compare.dart`
  - kleiner semantischer Versionsvergleich für Werte wie `1.0.0`, `1.2.0`, `2.0.0`
  - ungültige Versionen führen zu `invalid` statt zu Crashes
- `lib/core/sync/content_package_sync_policy.dart`
  - entscheidet rein in Memory, ob ein Remote-Paket importierbar, zu überspringen oder blockiert ist
  - prüft `approved`, Sprachpaar, `minAppVersion`, Version und Checksum
  - berührt keine User-Daten und startet keinen Import

Die Policy kennt folgende Reason-Codes:

- `approvedPackageMissingLocally`
- `newerApprovedVersionAvailable`
- `alreadyImported`
- `notApproved`
- `languagePairMismatch`
- `minAppVersionTooHigh`
- `checksumChangedForSameVersion`
- `olderVersion`
- `invalidPackageMetadata`

Wichtig: Es gibt weiterhin keine SQLite-Migration für `content_package_imports`, keinen Supabase-Paketreader und keine aktive Content-Paket-Synchronisation. Der bestehende Legacy-Auto-Sync bleibt separat über `ReleaseSyncPolicy` geschützt.

## 18. Aktualisierte nächste Schritte

1. Remote-Paketformat finalisieren.
2. Supabase-Metadaten nur konzeptionell abstimmen, noch nicht produktiv migrieren.
3. SQLite-Migration `content_package_imports` ergänzen, sobald das Paketformat stabil ist.
4. Repository für lokale Content-Paket-Marker bauen.
5. Supabase-Reader für Paketmetadaten ergänzen.
6. Paketentscheidung mit `ContentPackageSyncPolicy` vor den Import schalten.
7. `SupabaseWordsLocalImportService` paketbewusst erweitern.
8. Legacy-Auto-Sync durch kontrollierten Content-Paket-Sync ablösen.
