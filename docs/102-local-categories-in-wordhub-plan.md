# 102 Local Categories In WordHub Plan

Stand: 2026-05-15

## 1. Aktuelles Problem

Der bestehende `WordHubScreen` haengt weiterhin an der alten WordHub-/Supabase-nahen Struktur.

Aktuell relevant:

- `word_hub_taxonomy.dart` definiert die sichtbaren Hub-Bereiche und Subkategorien.
- `WordHubScreen` oeffnet `CategoryDetailScreen` mit vorhandenen Kategorieinformationen.
- Kategorie- und Wortdaten kommen im bestehenden Flow weiterhin aus Supabase-nahen Providern und Repositorys.
- Bei Supabase-, Netzwerk- oder DNS-Fehlern koennen Kategorien fuer den alten Flow nicht verlaesslich genutzt werden.
- Lokale Kategorien wie `basics` existieren nach bewusstem Asset-Import in `talvori_local_v1.db`, sind aber im normalen WordHub noch nicht als eigene lokale Kategoriequelle sichtbar.

Damit gibt es aktuell zwei getrennte Welten:

- bestehende WordHub-/Supabase-Kategorien
- lokale Offline-first-Kategorien in `talvori_local_v1.db`

Diese Welten duerfen nicht unkontrolliert vermischt werden.

## 2. Ziel

Ziel ist, lokale Kategorien kontrolliert sichtbar zu machen, ohne den bestehenden WordHub-Flow sofort zu ersetzen.

Der erste Zielzustand:

- lokale Kategorien aus `talvori_local_v1.db` koennen gelesen werden
- lokale Kategorie `basics` kann sichtbar werden, wenn sie importiert wurde
- bestehendes WordHub-Design kann spaeter weiterverwendet werden
- Supabase-Flow bleibt erhalten
- bestehende Produktnavigation bleibt erhalten
- kein automatischer Import
- keine automatische Session

Wichtig:

Die lokale Sichtbarkeit ist zunaechst ein Debug-/Integrationspfad, kein kompletter Produktumbau.

## 3. Moegliche Strategien

### A) Bestehende WordHub-UI Direkt Auf Lokale Kategorien Umstellen

Beschreibung:

- `WordHubScreen` wuerde statt Supabase-/Taxonomy-Daten direkt lokale Kategorien aus `talvori_local_v1.db` anzeigen.

Vorteile:

- schnell sichtbarer Offline-first-Effekt
- bestehendes Design wird unmittelbar genutzt

Nachteile:

- hohes Risiko fuer Regressionen im bestehenden WordHub
- Supabase-Flow wuerde indirekt ersetzt
- Kategorie-Mapping und Wortzahlen sind noch nicht vollstaendig geklaert
- alte und neue Datenquellen koennten vermischt werden

Bewertung:

- nicht als naechster Schritt geeignet

### B) Lokalen Debug-WordHub / Category-Entry Bauen

Beschreibung:

- separater lokaler Debug-Einstieg, der nur lokale Kategorien zeigt
- kann `CategoryRepository` nutzen
- kann spaeter eine lokale Kategorie wie `basics` zum `LocalLearningTestScreen` fuehren

Vorteile:

- sehr gute Trennung vom alten Flow
- niedrige Regressiongefahr
- gut testbar
- kein Umbau des produktiven WordHub noetig

Nachteile:

- noch kein nahtloses Produkt-Erlebnis
- zusaetzlicher Debug-Einstieg statt direkter Integration

Bewertung:

- sicherste Variante fuer einen ersten UI-nahen Schritt

### C) Lokalen Kategorien-Provider Parallel Zum Supabase-Provider Bauen

Beschreibung:

- neuer Provider liest lokale Kategorien ueber `localBootstrapProvider` und `LocalRepositoryFactory`
- bestehender WordHub kann spaeter optional lokale Kategorien anzeigen
- erster Schritt bleibt UI-neutral oder UI-arm

Vorteile:

- gute technische Grundlage
- nutzt bestehende lokale Bootstrap-/Repository-Schicht
- keine neue Datenbankoeffnung
- gut testbar
- Rueckbau einfach

Nachteile:

- Kategorien sind noch nicht automatisch sichtbar
- UI-Integration braucht separaten Schritt

Bewertung:

- beste technische Vorstufe
- sollte vor einer WordHub-UI-Aenderung kommen

### D) Supabase-Fehler Nur Verstecken

Beschreibung:

- Supabase-/DNS-Fehler im WordHub abfangen oder optisch verbergen

Vorteile:

- schnelle kosmetische Verbesserung

Nachteile:

- macht lokale Kategorien nicht sichtbar
- loest Offline-first-Ziel nicht
- kann echte Fehler verschleiern
- keine lokale Lernkette wird nutzbar

Bewertung:

- nicht ausreichend fuer das Ziel

## 4. Empfehlung

Empfohlen ist Strategie C als naechster technischer Schritt:

- einen lokalen Kategorien-Provider parallel zum bestehenden Supabase-/WordHub-Flow planen und bauen
- Provider nutzt `localBootstrapProvider`
- Provider nutzt die bestehende `LocalRepositoryFactory`
- Provider liest `CategoryRepository.loadCategories(...)`
- Provider oeffnet keine neue Datenbank
- Provider startet keinen Import
- Provider startet keine Session

Danach kann Strategie B als UI-naechster Schritt folgen:

- kleiner Debug-Entry im WordHub oder separater Debug-Local-WordHub
- zeigt lokale Kategorien nur, wenn vorhanden
- oeffnet kontrolliert lokalen Debug-Lernscreen oder `CategoryDetailScreen` mit lokalem Slug

Nicht empfohlen:

- bestehende WordHub-UI direkt umstellen
- Supabase-Provider nebenbei entfernen
- WordHub-Fehler nur verstecken

## 5. Lokale Datenquelle

Die lokale Datenquelle sollte sein:

- `localBootstrapProvider`
- `LocalRepositoryFactory`
- `CategoryRepository`

Konkret:

- `localBootstrapProvider` stellt den lokalen Bootstrap bereit.
- Der Bootstrap liefert die bestehende `LocalRepositoryFactory`.
- Aus der Factory wird der lokale `CategoryRepository` verwendet.
- `CategoryRepository.loadCategories(includeArchived: false)` liefert aktive lokale Kategorien.

Nicht verwenden:

- keine neue Datenbank direkt im WordHub oeffnen
- kein direkter `sqflite`-Zugriff in UI
- kein Supabase fuer lokale Kategorien
- keine alte `local_word_database.dart`

## 6. UI-Datenbedarf

Fuer eine WordHub-nahe lokale Kategorieanzeige werden mindestens benoetigt:

- `categoryId`
- `name`
- `slug` oder `key`
- `wordCount`
- `sortOrder`
- `isArchived`

Vorhanden in `LocalCategory`:

- `id`
- `name`
- `description`
- `sortOrder`
- `isArchived`
- `createdAt`
- `updatedAt`

Noch zu klaeren:

- `slug/key`: fuer Version 1 kann `id` als lokaler Key dienen, z. B. `basics`
- `wordCount`: sollte ueber `WordRepository` oder eine kleine lokale Query ermittelt werden
- archivierte Kategorien sollten standardmaessig nicht sichtbar sein

Fuer den ersten Provider-Schritt reicht eventuell:

- `id`
- `name`
- `sortOrder`
- `isArchived`

`wordCount` kann als zweiter TDD-Schritt folgen.

## 7. Sichtbarkeit Von basics

`basics` kann sichtbar werden, wenn die lokale Asset-Datei bewusst importiert wurde.

Aktuelle Grundlage:

- registriertes Asset: `assets/local_import/default_words_v1.json`
- Import ist bewusst und nicht automatisch
- lokale Kategorie: `basics`
- lokale Woerter: z. B. `basics_hello`, `basics_water`

Moegliche Oeffnung:

- lokaler Debug-Entry zeigt `basics`
- Tap oeffnet `LocalLearningTestScreen` mit `categoryId: basics`
- oder spaeter `CategoryDetailScreen` mit `categorySlug: basics`

Wichtig:

- kein automatischer Import beim Anzeigen des WordHub
- keine automatische Session beim Oeffnen einer Kategorie
- kein Fallback auf `basics`, wenn eine andere Kategorie unbekannt ist
- wenn `basics` noch nicht importiert wurde, bleibt der lokale Kategorienbereich leer oder zeigt einen Debug-Hinweis

## 8. Was Nicht Passieren Darf

Nicht erlaubt:

- kein kompletter Umbau von `WordHubScreen`
- keine Supabase-Entfernung nebenbei
- kein Umbau von `LearnModeController`
- kein Umbau von `learn_mode_screen.dart`
- kein Umbau des bestehenden Startbuttons
- keine direkte Nutzung von Supabase-IDs als lokale Kategorie-IDs
- kein Fallback auf `basics` bei unbekannten Kategorien
- kein automatischer Asset-Import
- keine automatische Session
- keine direkte Datenbankoeffnung in UI-Code
- keine Nutzung der alten `local_word_database.dart`

Der bestehende Supabase-WordHub muss als alter Flow weiter verfuegbar bleiben.

## 9. Spaetere Tests

Sinnvolle Tests:

- `local_categories_provider_loads_imported_categories`
  - importierte lokale Kategorien werden ueber den Provider geladen
  - `basics` ist enthalten

- `local_categories_provider_does_not_require_supabase`
  - Provider funktioniert ohne Supabase-Initialisierung
  - nur lokale Bootstrap-/Repository-Schicht wird genutzt

- `local_wordhub_debug_entry_shows_basics`
  - Debug-Entry zeigt `basics`, wenn lokale Kategorie vorhanden ist
  - kein Eintrag, wenn lokale Kategorie nicht vorhanden ist

- `local_category_tile_opens_local_debug_learning`
  - Tap auf lokalen Debug-Kategorieeintrag oeffnet `LocalLearningTestScreen` mit `categoryId: basics`
  - kein Import und keine Session werden automatisch gestartet

- `old_supabase_wordhub_flow_remains_unchanged`
  - bestehender WordHub-Startpfad bleibt verfuegbar
  - vorhandene Supabase-/CategoryDetail-Navigation bleibt unangetastet

Weitere sinnvolle Tests:

- archivierte lokale Kategorien werden nicht angezeigt
- Sortierung folgt `sortOrder`
- kein Fallback auf `basics`

## 10. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt sollte UI-neutral bleiben.

Empfohlen:

1. Einen lokalen Kategorien-Provider planen oder direkt minimal implementieren:
   - nutzt `localBootstrapProvider`
   - nutzt `LocalRepositoryFactory`
   - liest `CategoryRepository.loadCategories(...)`
   - startet keinen Import
   - oeffnet keine neue DB
2. Erster Test:
   - `local_categories_provider_loads_imported_categories`
3. Testablauf:
   - temporaere lokale Testdatenbank ueber Bootstrap-Pfad
   - bewusst Asset importieren oder Kategorie per Repository anlegen
   - Provider lesen
   - pruefen, dass `basics` geladen wird
   - pruefen, dass kein Progress, keine Session und keine Review-History entstehen

Danach:

- `local_categories_provider_does_not_require_supabase`
- erst danach ein kleiner Debug-WordHub-Entry oder lokaler Category-Tile

Nicht als naechster Schritt empfohlen:

- `WordHubScreen` direkt umbauen
- bestehenden Supabase-Provider ersetzen
- lokale Kategorien automatisch importieren
- lokale Kategorie direkt an `LearnModeScreen` anschliessen
