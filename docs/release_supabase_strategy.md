# Release Supabase Strategy

## 1. Kurzbewertung

Supabase soll für Talvori langfristig erhalten bleiben. Für den ersten Release sollte Supabase aber nicht als unkontrollierte Hintergrundmagie wirken. Die App sollte offline-first starten, lokale Daten schützen und Online-Daten nur kontrolliert, versioniert und nachvollziehbar übernehmen.

Die sinnvollste Release-Option ist daher **Option C: Supabase kontrolliert aktiv lassen, aber nur unter klaren Bedingungen**.

Das bedeutet:

- Supabase-Initialisierung darf bleiben.
- Debug-/Admin-Import bleibt debug- bzw. developer-gated.
- Content-Download darf nicht ungefragt Nutzerfortschritt überschreiben.
- Der aktuelle `SupabaseWordsLocalAutoSyncService` ist inzwischen über eine Release-Policy gegated: Debug darf den Legacy-Auto-Sync weiter nutzen, Release überspringt ihn standardmäßig, bis versionierte und freigegebene Content-Pakete existieren.

## 2. Aktuelle Supabase-Nutzung

### App-Start

Datei: `lib/main.dart`

Beim Start passiert aktuell:

1. `.env` wird geladen.
2. Supabase wird initialisiert.
3. Debug-Auto-Login läuft nur bei `kDebugMode`.
4. Eine Test-Datenbankabfrage auf `categories` wird ausgeführt.
5. `_SupabaseWordsLocalAutoSyncBootstrap` startet nach dem ersten Frame `supabaseWordsLocalAutoSyncServiceProvider.runIfNeeded(...)`.

Der kritische Release-Punkt war Schritt 5: Der Auto-Sync wurde produktiv gestartet, nicht nur im Debug-Build. Aktuell prüft der Bootstrap vorher `ReleaseSyncPolicy.allowLegacySupabaseWordsAutoSync`. Dadurch läuft der wortanzahlbasierte Legacy-Auto-Sync im Debug weiter, wird im Release aber standardmäßig übersprungen.

### Automatischer Wörter-Sync

Dateien:

- `lib/core/local_database/services/supabase_words_local_auto_sync_service.dart`
- `lib/core/local_database/providers/supabase_words_local_import_controller_provider.dart`
- `lib/core/local_database/services/supabase_words_remote_reader.dart`
- `lib/core/local_database/services/supabase_words_local_import_service.dart`

Aktueller Ablauf:

1. Lokale Wortanzahl wird geladen.
2. Wenn `countAllWords()` mindestens `minimumCompleteLocalWordCount` erreicht, wird übersprungen.
3. Wenn der lokale Bestand kleiner ist, werden Supabase-Tabellen gelesen:
   - `words`
   - `categories`
   - `word_categories`
4. Danach wird lokal in SQLite importiert.

Der Auto-Sync ist damit **nicht read-only insgesamt**:

- Supabase: read-only
- lokale SQLite-Datenbank: write

### Manueller Supabase-Import

Datei: `lib/features/home/ui/screens/supabase_words_local_import_screen.dart`

Der manuelle Import-Screen:

- kann eine Preview ausführen,
- kann nach Preview einen lokalen Import starten,
- ist aktuell über Settings nur im `kDebugMode` sichtbar.

Damit ist der manuelle Admin-Import im Release nicht normal erreichbar.

## 3. Auto-Sync-Befund

### Read/Write

Der Auto-Sync liest remote und schreibt lokal:

- Remote-Lesezugriff über `SupabaseRestWordsRemoteReader`.
- Lokale Schreibvorgänge über `SupabaseWordsLocalImportService.apply(...)`.

Er verändert keine Supabase-Daten.

### Idempotenz

Der Import ist weitgehend idempotent:

- Wiederholtes Anwenden legt gleiche Wörter nicht erneut an.
- Kategorien werden anhand normalisierter Namen wiederverwendet.
- Memberships werden über `word_id|category_id` dedupliziert.
- `word_progress` wird nicht absichtlich verändert; der Report prüft Vorher-/Nachher-Count.
- Lokale vorhandene Übersetzungen werden bei Konflikten nicht überschrieben.

Grenzen der Idempotenz:

- Es gibt noch keine Content-Paket-Versionierung.
- Es gibt keine klare `approved`-Markierung für remote Content.
- Die Importentscheidung basiert nur auf lokaler Wortanzahl, nicht auf Sprachpaar, Paketstatus oder Nutzerentscheidung.
- Der Import kann lokale `words` ergänzen oder leere Felder wie Level, source_language, target_language und leere Übersetzungen auffüllen.

### Mehrfachlauf

Innerhalb einer Service-Instanz schützt `_inFlight` vor parallelen Doppelstarts. Nach Abschluss kann der Auto-Sync erneut laufen. Ob dann erneut importiert wird, hängt wieder von der lokalen Wortanzahl ab.

### Offline- und Fehlerverhalten

Fehler werden gefangen und als `SupabaseWordsLocalAutoSyncResult.failed` zurückgegeben. Die App soll weiterlaufen. Das ist gut für Offline-first, aber der Nutzer sieht aktuell keinen klaren Content-Sync-Status.

### Neuinstallation

Nach App-Neuinstallation ist die lokale SQLite-Datenbank leer oder nur lokal geseedet. Dann kann der Auto-Sync remote Content nachladen, sobald Supabase erreichbar ist. Das ist nützlich, aber ohne Paketversion und Sprachpaarfilter riskant für Release-Qualität.

## 4. Risikoanalyse

### Release-Risiken

- Ungeprüfte oder nicht freigegebene Supabase-Wörter könnten lokal sichtbar werden.
- Der Import ist nicht an `appLanguage`, `nativeLanguage` oder `learningLanguage` gekoppelt.
- Der Auto-Sync nutzt eine reine Wortanzahl-Schwelle. Diese sagt nicht aus, ob das richtige Sprachpaket vorhanden ist.
- Content-Qualität, Level und Wortwelten hängen von der aktuellen Supabase-Datenqualität ab.
- Startlogik hängt von Netzwerk/Supabase ab, auch wenn Fehler gefangen werden.
- Es gibt noch keine sichtbare Nutzerentscheidung für Online-Content-Download.

### Datenrisiken

Aktuell relativ gut geschützt:

- `word_progress` wird nicht importiert oder überschrieben.
- Lokale nicht-leere Übersetzungen werden bei Konflikt nicht überschrieben.
- Memberships werden nicht gelöscht.

Noch offen:

- Keine klare Trennung zwischen Content-Paket-Daten und User-Daten im Sync-Konzept.
- Keine Paketversionen.
- Keine Remote-Freigabestati.
- Keine Backup-/Restore-Strategie für User-Daten.

## 5. Release-Optionen

### Option A: Auto-Sync im Release aktiv lassen

Vorteile:

- Neue Installationen können automatisch mit größerem Content versorgt werden.
- Supabase bleibt direkt produktiv eingebunden.
- Content kann zentral aktualisiert werden.

Risiken:

- Zu abhängig von aktueller Supabase-Datenqualität.
- Keine Paketversionierung.
- Keine `approved`-Filter.
- Kein Sprachpaarfilter.
- Nutzer sehen eventuell Inhalte, die noch nicht Release-geprüft sind.

Bedingungen, falls Option A gewählt würde:

- Remote Content muss vollständig geprüft sein.
- Import muss auf freigegebene Pakete begrenzt werden.
- Sprachpaar muss eindeutig sein.
- Timeout und stiller Fallback müssen erhalten bleiben.
- Tests für Neuinstallation, Offline, Wiederholung und Konflikte müssen grün sein.

Bewertung: Für den ersten Release zu riskant.

### Option B: Auto-Sync nur in Debug/Migration aktiv lassen

Vorteile:

- Minimiert Release-Risiko.
- Keine unkontrollierten Content-Änderungen beim Nutzer.
- Lokale MVP-Erfahrung bleibt stabil.

Risiken:

- Neue Content-Pakete können nicht automatisch ausgeliefert werden.
- Supabase-Rolle im Release bleibt zu passiv.
- Spätere Aktivierung braucht erneute Release-Arbeit.

Bewertung: Sicher, aber für Talvoris langfristige Online-Strategie zu defensiv.

### Option C: Auto-Sync kontrolliert aktiv lassen

Empfohlene Bedingungen:

- Nur für freigegebene Content-Pakete.
- Nur mit Paket-ID und Version.
- Nur für passendes Sprachpaar.
- Nur wenn lokaler Paketmarker fehlt oder eine neuere freigegebene Version verfügbar ist.
- Keine Änderungen an `word_progress`, Review-History, Known-/Reviewed-Status oder Favoriten ohne explizite Migrationsregel.
- Keine Überschreibung lokaler Nutzeränderungen.
- Read-only gegen Supabase.
- Lokaler Import idempotent.
- Netzwerkfehler blockieren den App-Start nicht.
- Optional: Download erst nach Nutzerzustimmung oder eindeutigem Onboarding-Schritt.

Bewertung: Beste Release-Richtung für Talvori.

## 6. Empfohlene Release-Entscheidung

Für den ersten Release sollte `SupabaseWordsLocalAutoSyncService` **nicht in seiner aktuellen Form unverändert aktiv bleiben**.

Empfehlung:

1. Supabase bleibt initialisiert.
2. Debug-/Admin-Import bleibt debug-gated.
3. Der aktuelle wortanzahlbasierte Legacy-Auto-Sync ist im Release standardmäßig deaktiviert.
4. Auto-Sync wird als nächster Ausbau zu einem kontrollierten Content-Paket-Sync weiterentwickelt.
5. Bis diese Guards existieren, gilt der aktuelle wortanzahlbasierte Auto-Sync nicht als finaler Release-Mechanismus.

Minimaler Release-Guard:

- Zentrale Policy `ReleaseSyncPolicy.allowLegacySupabaseWordsAutoSync`.
- Debug-Builds erlauben den Legacy-Auto-Sync.
- Release-Builds überspringen ihn standardmäßig.
- Eine spätere Aktivierung braucht Paketversion/Marker, nicht nur Wortanzahl.
- Zusätzlich Paketversion/Marker prüfen, nicht nur Wortanzahl.
- Remote-Pakete nur mit `approved`/freigegebenem Status laden.
- Die vorbereitende Content-Paket-Entscheidungsschicht existiert inzwischen als reines In-Memory-Modell (`ContentPackageMetadata`, `ContentPackageImportMarker`, `ContentPackageSyncPolicy`, `VersionCompare`), ist aber noch nicht an Supabase, SQLite-Migration oder Importlogik angeschlossen.
- `ContentPackageMetadata` unterstützt vorbereitend optionale Paketfelder wie `packageFamily`, `packageStage`, `packageType`, `levelRange`, `displayName` und `description`.
- `ContentPackageTaxonomy` normalisiert Paketfamilien und Spezialpakete, z. B. `Top 500 Words` zu `top_words`, `TOEFL` zu `toefl` und `Business English` zu `business_english`.
- Top-Wortschatz wird intern bevorzugt als Bereichspaket vorbereitet, während die UI später kumulative Ziele wie `Top 100`, `Top 200` oder `Top 500` zeigen kann.
- Spezialpakete wie TOEFL, IELTS, Cambridge, Business, Grammar oder Phrases bleiben trotzdem normale Content-Pakete im Sinne der Policy: ohne `approved`, passendes Sprachpaar und kompatible Version werden sie nicht importierbar.
- Stabile Sprachcodes sind zentral über `TalvoriLanguages` vorbereitet. Bestehende UI-Labels bleiben kompatibel, Content-Paket-Entscheidungen sollen aber Codes und normalisierte Sprachpaare nutzen.
- Die Settings-UI erklärt App-Sprache, Muttersprache und Lernsprache nun getrennt. Sichtbar bleiben im MVP nur Deutsch, Englisch, Spanisch und Französisch; weitere Sprachen sind intern vorbereitet, aber nicht freigeschaltet.

## 7. Langfristige Supabase-Rolle

Supabase sollte langfristig vier Rollen haben:

1. **Content-Quelle**
   - geprüfte Wortpakete,
   - Sprachpakete,
   - Lernlevel,
   - Wortwelten,
   - Premium-Pakete.

2. **User-Backup**
   - Fortschritt,
   - bekannte Wörter,
   - reviewed-for-learning,
   - Favoriten,
   - eigene Wörter,
   - Einstellungen,
   - Streaks,
   - Sammlungen.

3. **Account-/Sync-Schicht**
   - Login,
   - Gerätewechsel,
   - Restore,
   - Konfliktauflösung.

4. **Companion-/Chat-Sync**
   - getrennte Chatverläufe für Tali/Vori,
   - Datenschutz,
   - Löschbarkeit,
   - Nutzerkontrolle.

## 8. Trennung Content-Daten vs. User-Daten

### Content-Daten

Beispiele:

- Wörter
- Übersetzungen
- Kategorien/Wortwelten
- Lernlevel
- Sprachpakete
- Beispielsätze
- geprüfte Notizen

Content-Daten dürfen online nachgeladen werden, wenn sie freigegeben, versioniert und zum Sprachpaar passend sind.

### User-Daten

Beispiele:

- `word_progress`
- `word_world_memberships.is_known`
- `word_world_memberships.is_reviewed_for_learning`
- `word_world_memberships.is_disabled`
- Favoriten
- eigene Wörter
- `word_sources`
- ProfilePreferences
- Streaks
- Sammlungen
- Chatverläufe

User-Daten dürfen niemals ungefragt durch Content-Sync überschrieben werden.

## 9. Backup-/Restore-Konzept

Für später:

1. Nutzerkonto optional anbieten.
2. Lokale User-Daten bleiben führend, solange kein Account aktiv ist.
3. Nach Login kann ein Backup erstellt werden.
4. Restore muss Konflikte sichtbar oder deterministisch lösen:
   - neuerer Zeitstempel,
   - lokale Änderungen behalten,
   - remote nur ergänzen,
   - nie still löschen.
5. Löschbarkeit muss pro Konto und Datenschutzanforderung garantiert sein.

MVP:

- Kein verstecktes User-Backup.
- Lokale Daten bleiben lokal.
- Content-Sync darf keine User-Daten anfassen.

## 10. Content-Paket-Konzept

Empfohlenes Paketmodell:

- `content_package_id`
- `language_pair`
- `base_language`
- `learning_language`
- `native_language` oder `translation_language`
- `version`
- `status`: `draft`, `ai_suggested`, `human_reviewed`, `approved`, `deprecated`
- `package_family`, z. B. `top_words`, `toefl`, `business_english`
- `package_stage`, z. B. `1-100`, `101-200`, `academic`
- `package_type`, z. B. `frequency`, `exam`, `topic_pack`, `grammar`, `phrase_pack`, `business`, `travel`, `custom`
- `level_range`, z. B. `A1-B2`
- `min_app_version`
- `released_at`
- `checksum`

Lokale Marker:

- Paket-ID
- Version
- Importdatum
- Sprachpaar
- Prüfsumme

Dadurch ersetzt eine Paketprüfung die aktuelle reine Wortanzahl-Schwelle.

Wichtig: Diese Felder sind nur vorbereitende Metadaten. Sie aktivieren keinen Supabase-Reader, keine SQLite-Migration und keinen produktiven Paketimport.

## 11. Mehrsprachigkeits- und Sprachpaket-Konzept

Aktuell existieren:

- `words.source_language`
- `words.target_language`
- `ProfilePreferences.appLanguage`
- `ProfilePreferences.nativeLanguage`
- `ProfilePreferences.learningLanguage`
- `TalvoriLanguages` als zentrale Übergangsschicht von UI-Labels zu Codes

Noch problematisch:

- Viele UI- und Spielpfade gehen faktisch von Deutsch/Englisch aus.
- Settings bietet aktuell nur Deutsch, Englisch, Spanisch, Französisch.
- Einige KI-/Tagesimpuls-Pfade senden feste Sprachcodes wie `DE` oder `EN`.

Release-Leitlinie:

- App-Sprache, Muttersprache, Lernsprache und Content-Sprache müssen getrennt bleiben.
- Content-Pakete müssen nach Sprachpaar geladen werden.
- Ein deutsches UI darf nicht bedeuten, dass der Nutzer Deutsch als Muttersprache oder Lernsprache nutzt.
- Neue Sprachen sollten über Paketdaten ergänzt werden, nicht über hartcodierte Sonderfälle.
- Eine vollständige ARB/l10n-Umstellung und eine Migration gespeicherter Sprachlabels auf Codes bleiben separate spätere Schritte.

## 12. Chat-/Companion-Sync

Chat- und Companion-Daten sollten nicht im ersten Release automatisch online synchronisiert werden.

Später sinnvoll:

- eigene Identitäten für Tali und Vori,
- getrennte Chatverläufe,
- Account-gebundene Backups,
- klare Löschfunktion,
- Datenschutz- und Einwilligungslogik,
- keine Vermischung von lokalen und remote Nachrichten ohne Konfliktmodell.

## 13. Konkrete nächste ToDos

### Muss vor Release

1. Release-Entscheidung für `SupabaseWordsLocalAutoSyncService` treffen.
2. Current Auto-Sync nicht unverändert als finalen Release-Pfad verwenden.
3. Feature-Flag oder Paket-Guard ergänzen.
4. Content-Paket-Marker lokal speichern.
5. Remote Content nur mit geprüftem Status importieren.
6. Sprachpaarfilter einführen.
7. Tests für Offline, Fehler, Wiederholung, Neuinstallation und Konflikte ergänzen.

### Sollte vor Release

1. Settings/Onboarding klar machen, welche Sprache gelernt wird.
2. Englisch-Deutsch-Basiscontent vollständig prüfen.
3. Supabase-Content-Tabellen um Paket-/Versionsinformationen erweitern.
4. Import-Report im Adminscreen um Paketversion und Sprachpaar erweitern.
5. Manuelle Admin-Preview als Release-Checkliste nutzen.

### Kann nach Release

1. Cloud-Backup für User-Daten.
2. Account-gebundener Restore.
3. Mehrsprachige Content-Pakete für Spanisch, Französisch und weitere Sprachen.
4. Remote Feature-Rollouts.
5. Companion-/Chat-Sync.

## 14. Offene Fragen

- Soll der erste Release mit komplett lokal gebündeltem Content starten oder bereits remote Content-Pakete laden?
- Welche Supabase-Tabelle markiert künftig `approved` Content?
- Wird ein Content-Paket pro Sprachpaar oder pro Lernsprache plus Übersetzungssprache modelliert?
- Wie werden Bedeutungsvarianten eines Wortes versioniert?
- Soll Content-Sync automatisch, nach Onboarding oder erst per Nutzeraktion starten?
- Welche User-Daten werden im ersten Backup-Release synchronisiert?

## 15. Prüfergebnis

- Supabase-Daten wurden nicht geändert.
- Kein Import wurde ausgeführt.
- Keine SRS-/word_progress-Daten wurden geändert.
- Keine Vokabeldaten wurden geändert.
- Diese Datei ist eine Analyse- und Entscheidungsdokumentation.
