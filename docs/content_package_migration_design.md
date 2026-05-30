# Design: Content-Package-Migration

Stand: 2026-05-30

Dieses Dokument beschreibt die spätere lokale SQLite- und Supabase-Zielstruktur
für Talvori-Content-Pakete. Es ist ein Architekturdesign. Es wurde keine
Migration ausgeführt, keine Supabase-Tabelle geändert, kein Import gestartet
und keine produktiven Vokabel-, SRS- oder `word_progress`-Daten verändert.

## 1. Ziel

Talvori braucht eine klare Content-Paket-Struktur, weil die aktuelle
Kategorie-/Wortwelt-Struktur mehrere fachliche Dinge vermischt:

- echte Wortwelten wie `Travel`, `Food & Cooking` oder `Work & Careers`
- Lernlevel wie `A1` bis `C2`
- Paket- und Sammlungslogik wie `Top 500 Words`
- spätere Spezialpakete wie TOEFL, IELTS, Cambridge English, Business English,
  Grammar & Syntax oder Phrases & Idioms

Die Migration wird noch nicht ausgeführt, weil der Content-Review, das
Remote-Paketformat, die Paketfreigabe und die Konfliktregeln zuerst stabil
sein müssen. Eine verfrühte Migration würde riskieren, fehlerhafte
Paketmitgliedschaften oder ungeprüfte Kategorieinterpretationen dauerhaft in
lokale Daten zu schreiben.

Die spätere Zielstruktur soll lösen:

- Pakete werden versionierbar und freigabefähig.
- Top-Wortschatz kann in kleine Etappen zerlegt werden.
- Prüfungspakete werden nicht mit Themen-Wortwelten verwechselt.
- Ein Wort kann mehreren Paketen angehören.
- User-Daten, SRS und `word_progress` bleiben unabhängig vom Content-Sync.
- Supabase kann langfristig geprüfte Sprachpakete liefern, ohne lokale
  Nutzerstände ungefragt zu überschreiben.

## 2. Aktuelle Struktur

Lokal existieren unter anderem:

- `words`
- `categories`
- `word_world_memberships`
- `word_progress`
- `review_history`
- `learning_sessions`
- `session_items`
- `word_sources`
- `settings`

Aktuelle Rollen:

- `words` enthält den lokalen Wortbestand.
- `categories` enthält aktuell sowohl Themen als auch Level- oder Paketnamen.
- `word_world_memberships` verbindet Wörter mit Kategorien/Wortwelten und
  enthält nutzerbezogene Flags wie `is_known`, `is_reviewed_for_learning` und
  `is_disabled`.
- `word_progress` enthält SRS-/Lernfortschritt und darf durch Content-Pakete
  nicht überschrieben werden.
- `settings` enthält einfache lokale Marker, ist aber nicht stark genug für
  versionierte Paketlisten.

Hauptproblem:

`categories` und `word_world_memberships` tragen heute zu viel Bedeutung. Eine
Kategorie kann Thema, Level, Paket oder Importartefakt sein. Für Release-Content
und spätere Supabase-Pakete muss diese Bedeutung getrennt werden.

## 3. Zielstruktur lokal

Die lokale Zielstruktur trennt drei Ebenen:

- `content_packages`: Paketdefinition
- `content_package_memberships`: welche Wörter in welchem Paket sind
- `content_package_imports`: welche Pakete lokal bereits importiert wurden

Diese Tabellen werden hier nur geplant. Es wird keine DB-Version erhöht und
keine Migration ausgeführt.

### 3.1 `content_packages`

`content_packages` beschreibt ein Paket als Content-Objekt.

```sql
CREATE TABLE content_packages (
  content_package_id TEXT PRIMARY KEY,
  language_pair TEXT NOT NULL,
  base_language TEXT NOT NULL,
  learning_language TEXT NOT NULL,
  translation_language TEXT NOT NULL,
  package_family TEXT,
  package_stage TEXT,
  package_type TEXT,
  level_range TEXT,
  display_name TEXT,
  description TEXT,
  version TEXT NOT NULL,
  status TEXT NOT NULL,
  checksum TEXT,
  source TEXT NOT NULL,
  min_app_version TEXT,
  released_at TEXT,
  created_at TEXT,
  updated_at TEXT,
  metadata_json TEXT
);
```

Empfohlene Indizes:

```sql
CREATE INDEX idx_content_packages_language_pair
ON content_packages (language_pair);

CREATE INDEX idx_content_packages_family_stage
ON content_packages (package_family, package_stage);

CREATE INDEX idx_content_packages_status
ON content_packages (status);
```

Rolle:

- beschreibt Pakete wie `top-1-100-en-de-v1`, `toefl-academic-en-de-v1`
  oder `business-english-b1-b2-en-de-v1`
- speichert Paketstatus, Version, Checksum und Metadaten
- ersetzt nicht `words`, `categories` oder `word_progress`

### 3.2 `content_package_memberships`

`content_package_memberships` verbindet Wörter mit Paketen.

```sql
CREATE TABLE content_package_memberships (
  content_package_id TEXT NOT NULL,
  word_id TEXT NOT NULL,
  membership_type TEXT,
  rank INTEGER,
  review_status TEXT,
  created_at TEXT,
  metadata_json TEXT,
  PRIMARY KEY (content_package_id, word_id),
  FOREIGN KEY (content_package_id)
    REFERENCES content_packages (content_package_id)
);
```

Empfohlene Indizes:

```sql
CREATE INDEX idx_content_package_memberships_word
ON content_package_memberships (word_id);

CREATE INDEX idx_content_package_memberships_rank
ON content_package_memberships (content_package_id, rank);
```

Rolle:

- speichert Paketmitgliedschaften als Many-to-many-Struktur
- erlaubt, dass ein Wort gleichzeitig in `Top 1-100`, TOEFL und Business
  English vorkommt
- `rank` ist besonders wichtig für Top-Wortschatz
- `review_status` beschreibt die Paketmitgliedschaft, nicht den User-Fortschritt
- überschreibt keine `word_world_memberships`-User-Flags

### 3.3 `content_package_imports`

`content_package_imports` ist der lokale Importmarker.

```sql
CREATE TABLE content_package_imports (
  content_package_id TEXT NOT NULL,
  language_pair TEXT NOT NULL,
  version TEXT NOT NULL,
  checksum TEXT,
  source TEXT NOT NULL,
  imported_at TEXT NOT NULL,
  last_checked_at TEXT,
  word_count INTEGER NOT NULL DEFAULT 0,
  category_count INTEGER NOT NULL DEFAULT 0,
  metadata_json TEXT,
  PRIMARY KEY (content_package_id, language_pair)
);
```

Rolle:

- speichert, was lokal bereits erfolgreich importiert wurde
- ist die Grundlage für Skip-/Update-Entscheidungen
- wird erst nach erfolgreicher Transaktion geschrieben
- ist bewusst getrennt von der Paketdefinition, weil ein Paket bekannt sein
  kann, ohne bereits importiert zu sein

### 3.4 Verhältnis der Tabellen

- `content_packages` = Was ist das Paket?
- `content_package_memberships` = Welche Wörter gehören dazu?
- `content_package_imports` = Wurde dieses Paket lokal schon importiert?

Diese Trennung ist wichtig, weil Talvori später Paketlisten anzeigen, Preview
ausführen, Importstatus prüfen und Paketupdates bewerten können soll, ohne
direkt produktive Wortdaten zu verändern.

## 4. Zielstruktur Supabase

Supabase sollte langfristig dieselbe fachliche Trennung abbilden.

Empfohlene Remote-Tabellen oder Views:

- `content_packages`
- `content_package_memberships`
- optional `content_package_releases`
- optional `content_package_review_events`
- später `word_meanings`
- später `translations`

### 4.1 Remote `content_packages`

Remote-Paketmetadaten sollten mindestens enthalten:

- `content_package_id`
- `language_pair`
- `base_language`
- `learning_language`
- `translation_language`
- `package_family`
- `package_stage`
- `package_type`
- `level_range`
- `display_name`
- `description`
- `version`
- `status`
- `checksum`
- `min_app_version`
- `released_at`
- `created_at`
- `updated_at`
- `metadata_json`

Nur Pakete mit `status = approved` dürfen für Release-Sync berücksichtigt
werden. `draft`, `ai_suggested`, `human_reviewed`, `review` oder
`deprecated` dürfen nicht automatisch importiert werden.

### 4.2 Remote `content_package_memberships`

Remote-Memberships sollten enthalten:

- `content_package_id`
- `word_id`
- `membership_type`
- `rank`
- `review_status`
- `metadata_json`

Für Top-Wortschatz ist `rank` fachlich relevant. Für Prüfungspakete kann
`membership_type` später z. B. `core`, `optional`, `exam_relevant` oder
`phrase` sein.

### 4.3 Optionale Releases und Review Events

`content_package_releases` kann später Releases von Paketdefinitionen trennen:

- Paketversion
- Checksum
- Freigabezeitpunkt
- Reviewer
- Release Notes
- Rollback-/Deprecated-Status

`content_package_review_events` kann später nachvollziehen:

- wer ein Paket geprüft hat
- welche Review-Stufe erreicht wurde
- wann Status von `human_reviewed` zu `approved` gewechselt ist

### 4.4 RLS und Policies

Spätere Supabase-Regeln:

- normale Clients dürfen `approved` Pakete lesen
- Draft-/Review-Pakete nur Admin/Editor
- Writes nur über Admin-/Service-Rollen
- User-Daten und Content-Daten getrennte Policies
- keine Client-Route darf ungeprüften Content produktiv veröffentlichen

Dieses Dokument ändert kein Supabase-Schema.

## 5. Top-Wortschatz-Modell

Top-Wortschatz wird intern bevorzugt als Bereichspaket modelliert:

- `top-1-100-en-de-v1`
- `top-101-200-en-de-v1`
- `top-201-300-en-de-v1`
- `top-301-400-en-de-v1`
- `top-401-500-en-de-v1`

Empfohlene Metadaten:

- `package_family = top_words`
- `package_stage = 1-100`, `101-200`, `201-300`, `301-400`, `401-500`
- `package_type = frequency`
- `language_pair = en-de`
- `level_range`, z. B. `A1-B2`, nur wenn fachlich geprüft

Vorteile:

- einzelne 100er-Blöcke sind reviewbar
- Paketupdates können gezielt nur einen Bereich betreffen
- `rank` bleibt eindeutig pro Paketmitgliedschaft
- UI kann kumulative Ziele bauen:
  - `Top 100` = `Top 1-100`
  - `Top 200` = `Top 1-100` + `Top 101-200`
  - `Top 500` = alle fünf Bereiche

Alternative kumulative Pakete sind UX-seitig leicht verständlich, erzeugen
aber technisch mehr doppelte Memberships. Deshalb ist die interne
Bereichsstruktur robuster.

## 6. Prüfungs- und Spezialpakete

Spezialpakete sind Content-Pakete, keine Wortwelten.

Empfohlene Einordnung:

- TOEFL: `package_type = exam`, `package_family = toefl`
- IELTS: `package_type = exam`, `package_family = ielts`
- Cambridge English: `package_type = exam`, `package_family = cambridge_english`
- Business English: `package_type = business` oder `topic_pack`,
  `package_family = business_english`
- Grammar & Syntax: `package_type = grammar`, `package_family = grammar_syntax`
- Phrases & Idioms: `package_type = phrase_pack`,
  `package_family = phrases_idioms`
- Travel Basics: `package_type = travel` oder `topic_pack`,
  `package_family = travel_basics`

Alle Spezialpakete müssen pro Sprachpaar versioniert werden. Beispiele:

- `toefl-academic-en-de-v1`
- `ielts-core-en-de-v1`
- `cambridge-b2-en-de-v1`
- `business-english-b1-b2-en-de-v1`
- `grammar-syntax-a1-b1-en-de-v1`

Expert Review kann später als zusätzliche Qualitätsschicht ergänzt werden,
ändert aber die Grundregel nicht: Ohne `approved` kein Release-Sync.

## 7. Migrationsstrategie

### Phase 1: Review und Overlays

- bestehende Review-Tools weiter nutzen
- Struktur-Overlays für Level, Wortwelt und Paketmitgliedschaft prüfen
- keine produktiven Daten ändern

### Phase 2: Lokale Migration vorbereiten

- endgültiges SQLite-Schema festlegen
- DB-Version erhöhen
- idempotente Migrationen schreiben
- Schema-Tests ergänzen
- noch keinen Import aktivieren

### Phase 3: Repositories für Marker und Pakete

- Repository für `content_packages`
- Repository für `content_package_memberships`
- Repository für `content_package_imports`
- Transaktionsregeln definieren

### Phase 4: Supabase-Metadaten read-only Reader

- nur Paketmetadaten lesen
- nur `approved` Pakete für Release-Preview berücksichtigen
- keine Supabase-Writes
- keine automatische App-Start-Synchronisation

### Phase 5: Paket-Preview

- anzeigen, welche Pakete fehlen oder neuer sind
- Sprachpaar, Version, Checksum und `min_app_version` prüfen
- Konflikte in einem Report sichtbar machen
- keine User-Daten verändern

### Phase 6: Paketbewusster Import

- Import nur nach positiver Policy-Entscheidung
- Import und Marker in einer SQLite-Transaktion
- Marker erst nach erfolgreichem Abschluss schreiben
- Konflikte reporten, nicht still korrigieren

### Phase 7: Legacy-Auto-Sync ersetzen

- wortanzahlbasierten Legacy-Auto-Sync entfernen oder dauerhaft debug-only
  lassen
- Paket-Sync übernimmt die kontrollierte Content-Versorgung
- `ReleaseSyncPolicy` bleibt Schutzschicht für alte Pfade

## 8. Schutzregeln

- Content-Sync darf `word_progress` nie anfassen.
- Content-Sync darf `review_history` nie still verändern.
- Content-Sync darf `is_known`, `is_reviewed_for_learning`, `is_disabled`
  und Favoriten nie überschreiben.
- Paketmitgliedschaft ergänzt nur eine Content-Sicht.
- Themen-Wortwelt, Lernlevel und Paketmitgliedschaft bleiben getrennt.
- Lokale User-Daten haben Vorrang vor Content-Updates.
- Importmarker wird erst nach erfolgreicher Transaktion geschrieben.
- Checksum-Konflikte blockieren statt still zu überschreiben.
- Gleiche Paketversion mit anderer Checksum ist ein Blocker.
- Remote-Fehler dürfen den App-Start nicht blockieren.
- Ungeprüfte Pakete bleiben unsichtbar für Release-Sync.

## 9. Testplanung

Schema-Tests:

- Tabellen existieren nach Migration.
- Spalten, Primärschlüssel und Indizes stimmen.
- Migration ist idempotent.
- Keine bestehenden Tabellen werden beschädigt.

Repository-Tests:

- Paket speichern/laden.
- Membership speichern/laden.
- Importmarker speichern/laden.
- Paket nach Sprachpaar und Familie finden.
- Top-Ranges nach `rank` sortieren.

Policy-Tests:

- nur `approved` ist importierbar.
- falsches Sprachpaar wird blockiert.
- zu hohe `min_app_version` wird blockiert.
- gleiche Version/Checksum wird übersprungen.
- gleiche Version/andere Checksum wird blockiert.
- neuere Version wird importierbar.

Import-Tests:

- Import schreibt Marker erst nach Erfolg.
- Fehlerhafter Import schreibt keinen Marker.
- Paketmitgliedschaften werden ergänzt.
- bestehende Wörter werden nicht unkontrolliert überschrieben.
- `word_progress` bleibt unverändert.
- User-Flags bleiben unverändert.

Offline-/Fehler-Tests:

- Supabase offline blockiert App-Start nicht.
- lokale Pakete bleiben nutzbar.
- Paket-Preview zeigt Fehler ohne Import.
- Retry erzeugt keine doppelten Memberships.

Rollback-/Partial-Failure-Tests:

- Transaktionsfehler rollt Paketdaten und Marker zurück.
- teilweise geschriebene Pakete werden nicht als importiert markiert.
- Checksum-Konflikte erzeugen Reports.

## 10. Offene Fragen

- Braucht Talvori lokal direkt `content_packages` oder reicht zuerst
  `content_package_imports` plus Remote-Metadaten-Preview?
- Soll Top-Wortschatz intern nur Bereichspakete nutzen und UI-Bundles separat
  berechnen?
- Ist `rank` global pro Lernsprache oder immer paketbezogen?
- Wie werden Paketupdates versioniert, wenn nur Memberships, aber nicht Wörter
  geändert werden?
- Wie werden Memberships für mehrere Sprachpaare modelliert, wenn dieselbe
  Basis-Wort-ID mehrere Übersetzungssprachen hat?
- Wann werden `word_meanings` und `translations` vom Review-Schema ins echte
  Datenmodell überführt?
- Wie werden Premium-/Freemium-Pakete getrennt, ohne Kaufstatus mit
  Content-Definition zu vermischen?
- Brauchen Prüfungspakete zusätzliche Qualitätsstufen wie `expert_reviewed`?
- Soll es lokale Paket-Bundles geben, die mehrere Bereichspakete zu einem
  UI-Ziel bündeln?

## 11. Nicht umgesetzt

In diesem Block bewusst nicht umgesetzt:

- keine Änderung an `local_database_schema.dart`
- keine DB-Versionserhöhung
- keine SQLite-Migration
- kein Supabase-Reader
- kein Importservice-Umbau
- keine App-Startlogik
- keine UI
- keine echten Paketdaten
- keine produktive Vokabel- oder Membership-Zuordnung
- keine Änderung an SRS, `word_progress` oder User-Flags
