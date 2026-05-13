# 02 Supabase Removal Analysis

Stand: 2026-05-13

## Kurzfazit

Supabase ist aktuell nicht nur Datenquelle, sondern auch Teil der Geschäftslogik. Besonders SRS-Reviews, Queue-Auswahl, Kategorieprogress, Single-Session und Wortimport hängen an RPCs, Views und Edge Functions. Eine Entfernung darf deshalb nicht mit dem Löschen des Packages beginnen, sondern muss zuerst alle Serverfunktionen lokal ersetzen.

## Direkte Supabase-Abhängigkeiten

### Package

- `pubspec.yaml`
  - `supabase_flutter: ^2.6.0`

### App-Start

- `lib/main.dart`
  - importiert `supabase_flutter`
  - initialisiert Supabase mit `.env`
  - Debug-Auto-Login per E-Mail/Passwort
  - Testabfrage auf `categories`

### Zentrale Repository-Schicht

- `lib/features/words/data/supabase_word_repository.dart`
  - größter Abhängigkeitsblock
  - nutzt `Supabase.instance.client`
  - liest Auth-User
  - ruft viele RPCs auf
  - liest/schreibt Tabellen und Views
  - ruft Edge Functions auf

### Weitere direkte Imports

- `lib/features/words/application/category_detail_controller.dart`
- `lib/features/home/data/share_ingest_service.dart`
- diverse UI-/Application-Dateien importieren `SupabaseWordRepository`

### Supabase Edge Functions

- `supabase/functions/ingest_word/index.ts`
  - Wortimport
  - DeepL-Integration
  - Auth-Auflösung
  - Schreibzugriff auf `words` und `user_words`

- `supabase/functions/translate-missing/index.ts`
  - Nachübersetzung fehlender Übersetzungen
  - DeepL-Integration
  - liest Views und aktualisiert `words`

### Supabase SQL

Viele Migrationen enthalten SRS- und Queue-Logik. Auffällige Tabellen/RPC-Bereiche:

- `user_word_srs`
- `user_words`
- `words`
- `categories`
- `word_categories`
- `word_progress`
- `word_progress_deck_state`
- `single_session_items`
- `user_requeue`
- `user_s0_lock_state`
- `user_category_daily_budget`
- `user_hybrid_daily_state`
- `a_refill_state`
- `a_deck_state`

## Aktuell von Supabase abhängige Funktionen

### Auth / User-Kontext

Supabase liefert aktuell den `currentUser`. Offline-first braucht stattdessen ein lokales Nutzer-/Profilkonzept:

- lokale `user_id`
- lokale `device_id`
- optionale spätere Sync-Fähigkeit, aber nicht für Launch nötig

### Kategorien und Wörter

Aktuell über Supabase:

- Kategorien laden
- Wortlisten laden
- Wörter nach Kategorie laden
- Wortsuche
- User-Status wie `picked`, `favorite`, `in_my_words`
- Kategorie- und Stage-Counts

### SRS

Aktuell über Supabase:

- Review-RPCs für T-SRS, A-SRS, Hybrid
- Queue-RPCs
- A-SRS Refill/Intake
- Hybrid-Budget/Freeze-Verhalten
- Stage-Counts
- `next_due_at`
- `pass_count`
- `is_mastered`
- Requeue nach Fehlern

### Single Training

Aktuell über Supabase:

- `fn_single_session_seed`
- `fn_single_session_counts`
- `fn_single_session_move`
- `fn_single_session_reset`
- `fn_single_session_next`
- Tabelle `single_session_items`

### Wortimport / Teilen

Aktuell über Supabase:

- `share_ingest_service.dart`
- Edge Function `ingest_word`
- Auth-Session für Function-Aufruf
- DeepL auf Server-Seite

[ENTSCHEIDUNG NOTWENDIG] Für Launch muss entschieden werden, ob Wortimport/DeepL offline-first vorerst deaktiviert, lokal vereinfacht oder als spätere Online-Zusatzfunktion geplant wird.

## Schrittweise Entfernung

1. Abhängigkeitskarte einfrieren
   - alle Supabase-Imports erfassen
   - alle RPCs und Tabellenzugriffe katalogisieren
   - keine Löschung

2. Lokale Datenmodell-Zielstruktur festlegen
   - Tabellen und Indizes definieren
   - Migrationsstrategie bestimmen
   - Seed-/Importquelle für Wörter festlegen

3. Repository-Interface einziehen
   - UI und Controller dürfen nicht direkt Supabase kennen
   - zunächst Supabase-Implementierung hinter Interface lassen

4. SQLite-Implementierung parallel aufbauen
   - Wörter/Kategorien lesen
   - Progress lesen/schreiben
   - Sessions speichern
   - Review-Events persistieren

5. SRS-Engine lokal neu implementieren
   - erst nach finaler Theorie und Testfällen
   - Supabase-RPCs nicht 1:1 blind kopieren

6. Feature für Feature umschalten
   - Kategorieprogress
   - Learn Queue
   - Review
   - Single Training
   - Settings
   - Wortlisten

7. Supabase aus App-Start entfernen
   - erst wenn keine Runtime-Abhängigkeit mehr besteht

8. Package entfernen
   - `supabase_flutter` erst am Ende löschen
   - danach `flutter analyze`

9. Supabase-Verzeichnis archivieren oder entfernen
   - erst nach Datenmigration und Validierung

## Risiken

- Server-RPCs enthalten versteckte Geschäftslogik, die in Dart fehlen könnte.
- Direkte Supabase-Imports in UI/Application machen Austausch riskant.
- Auth-abhängige Daten müssen lokal eindeutig einem Nutzer/Profil zugeordnet werden.
- Vorhandene Supabase-Daten könnten verloren gehen, wenn kein Export-/Importpfad existiert.
- Edge Functions für Wortimport/Übersetzung sind nicht automatisch offline ersetzbar.
- Tests fehlen für die Gleichwertigkeit der neuen lokalen Engine.
- `is_mastered`, `pass_count`, `next_due_at` und Stage-Counts sind historisch inkonsistent gewachsen.

## Empfehlung

Supabase nicht löschen, bevor folgende Punkte fertig sind:

- finales SQLite-Zielmodell
- vollständige SRS-Theorie
- natürliche Testfälle
- lokale Session-Regeln
- klare Entscheidung zu Wortimport/Übersetzung
- Repository-Grenzen

