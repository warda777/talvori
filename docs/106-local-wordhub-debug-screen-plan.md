# 106 Local WordHub Debug Screen Plan

Stand: 2026-05-15

## 1. Ziel Des Screens

Ziel ist ein separater `LocalWordHubDebugScreen`, der lokale Kategorien sichtbar macht, ohne den bestehenden `WordHubScreen` zu veraendern.

Der Screen soll:

- lokale Kategorien aus `talvori_local_v1.db` anzeigen
- nur fuer Debug/Dev gedacht sein
- `basics` anzeigen, wenn diese Kategorie lokal vorhanden ist
- den bestehenden Supabase-WordHub nicht ersetzen
- keine bestehende Navigation veraendern
- keinen Import automatisch starten
- keine lokale Session automatisch starten

Der Screen ist ein isolierter Pruef- und Debug-Einstieg fuer den lokalen Kategorienpfad.

## 2. Zu Nutzende Provider

Der Screen sollte nutzen:

- `localCategoriesProvider`

Der Provider:

- nutzt intern `localBootstrapProvider`
- liest Kategorien ueber `CategoryRepository`
- oeffnet keine eigene Datenbank
- startet keinen Import

Der Screen sollte zusaetzlich nutzen:

- `LocalWordHubDebugEntryPresenter`

Der Presenter:

- filtert archivierte Kategorien heraus
- erzeugt `LocalWordHubDebugItem`
- entscheidet ueber `isVisible`
- kennt keine UI, Datenbank oder Navigation

Nicht nutzen:

- Supabase-Provider
- `word_providers.dart`
- `LearnModeController`
- `local_word_database.dart`
- alte WordHub-Taxonomy als lokale Datenquelle

## 3. Angezeigte Daten

Angezeigt werden sollen zunaechst nur lokale Debug-Items aus dem Presenter:

- `categoryId`
- `label`

Beispiel:

- `categoryId: basics`
- `label: Basics`

Darstellung fuer den ersten Schritt:

- einfache Liste oder kleine Cards
- klar als lokaler Debug-Bereich markiert
- Ladezustand fuer `localCategoriesProvider`
- leerer Zustand, wenn keine lokalen Kategorien vorhanden sind
- Fehlerzustand, falls der lokale Provider fehlschlaegt

Noch nicht noetig:

- `wordCount`
- Fortschritt
- Stage-Anzeige
- Importstatus
- alte WordHub-Sektionierung

## 4. Verhalten Beim Tap Auf basics

Beim Tap auf eine lokale Kategorie, z. B. `basics`, soll zunaechst der isolierte lokale Testscreen geoeffnet werden.

Empfehlung:

- `buildLocalLearningDebugScreen(categoryId: item.categoryId)` verwenden
- via lokaler `MaterialPageRoute` pushen

Warum nicht direkt `CategoryDetailScreen`:

- `CategoryDetailScreen` ist weiterhin an alte Controller-/Supabase-nahe Flows gekoppelt
- lokale Kategorien und alte Progress-/Stage-UI koennten vermischt werden
- der isolierte `LocalLearningTestScreen` ist bereits auf die lokale Offline-first-Kette ausgelegt

Beim Tap darf nicht passieren:

- kein automatischer Import
- keine automatische Session
- kein Progress erzeugen
- keine Review-History schreiben

Der lokale Testscreen kann danach weiterhin seine expliziten Buttons nutzen:

- Debug-Daten importieren
- Starten/Fortsetzen
- Richtig/Falsch
- Session abschliessen

## 5. Was Nicht Passieren Darf

Nicht erlaubt:

- kein Umbau von `WordHubScreen`
- keine Aenderung an bestehenden WordHub-Kacheln
- keine Supabase-Entfernung
- kein Supabase-Zugriff fuer lokale Kategorien
- kein automatischer Import beim Screen-Build
- keine automatische lokale Session beim Screen-Build
- keine direkte DB-Oeffnung im Screen
- kein `LearnModeController`
- kein `learn_mode_screen.dart`
- kein `word_providers.dart`
- keine alte `local_word_database.dart`
- kein Fallback auf `basics`
- keine produktive App-Flow-Anbindung

Wenn keine lokalen Kategorien vorhanden sind, muss der Screen leer bleiben oder einen Debug-Leerzustand anzeigen. Er darf `basics` nicht erfinden.

## 6. Sinnvolle Tests

Sinnvolle Tests fuer spaeter:

- `local_wordhub_debug_screen_shows_basics_when_local_category_exists`
  - Provider liefert lokale Kategorie `basics`
  - Screen zeigt `Basics`

- `local_wordhub_debug_screen_shows_empty_state_when_no_local_categories`
  - Provider liefert leere Liste
  - Screen zeigt keinen Kategorieeintrag
  - kein Fallback auf `basics`

- `local_wordhub_debug_screen_opens_local_learning_screen_with_category_id`
  - Tap auf `Basics`
  - `LocalLearningTestScreen` wird mit `categoryId: basics` gebaut
  - kein Import und keine Session werden automatisch gestartet

- `local_wordhub_debug_screen_does_not_require_supabase`
  - Test laeuft ohne Supabase-Initialisierung

- `old_wordhub_flow_remains_unchanged`
  - bestehender `WordHubScreen` wird in diesem Schritt nicht veraendert

Falls ein Widget-Test mit echtem `localCategoriesProvider` zu schwer ist:

- ersten Screen-Schritt mit Provider-Override testen
- lokale Kategorie direkt als Provider-Ergebnis einspeisen
- DB-Integration bleibt durch `localCategoriesProvider`-Tests abgedeckt

## 7. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt:

1. Neuen isolierten Screen anlegen:
   - `lib/features/local_learning_debug/ui/local_wordhub_debug_screen.dart`
2. Einen Widget-Test anlegen:
   - `test/features/local_learning_debug/local_wordhub_debug_screen_test.dart`
3. Erster Test:
   - `local_wordhub_debug_screen_shows_basics_when_local_category_exists`
4. Test mit Provider-Override:
   - `localCategoriesProvider` liefert eine aktive lokale Kategorie `basics`
5. Erwartung:
   - `Basics` ist sichtbar
   - kein Import wird gestartet
   - keine Session wird gestartet
   - kein Supabase wird benoetigt

Noch nicht im ersten Schritt:

- keine Navigation testen
- keinen App-Router anbinden
- keinen bestehenden `WordHubScreen` veraendern
- keinen Importbutton in diesen Screen einbauen

Danach:

- leerer Zustand
- Tap zum `LocalLearningTestScreen`
- spaeter separate Debug-Route oder Debug-Menue-Anbindung planen
