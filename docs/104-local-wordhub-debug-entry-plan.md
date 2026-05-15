# 104 Local WordHub Debug Entry Plan

Stand: 2026-05-15

## 1. Ziel

Ziel ist ein kleiner lokaler WordHub-Debug-Entry, der lokale Kategorien aus `talvori_local_v1.db` im WordHub-Umfeld sichtbar machen kann.

Der Einstieg soll:

- nur fuer Debug/Dev gedacht sein
- lokale Kategorien aus `localCategoriesProvider` anzeigen
- `basics` sichtbar machen, wenn diese lokale Kategorie vorhanden ist
- den bestehenden Supabase-WordHub unveraendert lassen
- keine automatische Datenbefuellung ausloesen
- keine Session automatisch starten

Der lokale Debug-Entry ist kein Ersatz fuer den bestehenden WordHub. Er ist ein kontrollierter Brueckenschritt, um lokale Kategorien manuell pruefbar zu machen.

## 2. Moegliche Varianten

### A) Bestehenden WordHubScreen Direkt Erweitern

Beschreibung:

- `WordHubScreen` wuerde direkt einen lokalen Bereich oder lokale Kacheln anzeigen.
- Der Bereich wuerde `localCategoriesProvider` lesen.

Vorteile:

- lokale Kategorien sind sofort im echten WordHub-Kontext sichtbar
- spaeteres Produktverhalten ist leichter vorstellbar

Nachteile:

- `WordHubScreen` ist bereits komplex
- Risiko, bestehenden Supabase-Flow oder Layout zu beeinflussen
- Debug- und Produktdaten koennen optisch vermischt werden
- Widget-Tests fuer den kompletten Screen sind vermutlich aufwendig

Bewertung:

- nicht als erster Schritt ideal

### B) Separaten LocalWordHubDebugScreen Bauen

Beschreibung:

- eigener kleiner Debug-Screen zeigt nur lokale Kategorien.
- Er liest `localCategoriesProvider`.
- Tap oeffnet lokalen Debug-Lernscreen.

Vorteile:

- klare Trennung vom bestehenden WordHub
- geringer Regressionseinfluss
- gut testbar
- kein Umbau der bestehenden WordHub-Sektionen

Nachteile:

- noch nicht direkt im bestehenden WordHub eingebettet
- zusaetzlicher Debug-Screen statt echter Produktintegration

Bewertung:

- sicherste UI-nahe Variante, wenn ein Screen-Schritt gewuenscht ist

### C) Kleinen Lokalen Debug-Entry Im Bestehenden WordHub Vorbereiten

Beschreibung:

- zunaechst eine isolierte Entry-/Presenter-Logik planen oder bauen
- spaeter kann sie unter `kDebugMode` im `WordHubScreen` sichtbar werden
- der bestehende WordHub bleibt in diesem Schritt unveraendert

Vorteile:

- sehr kleiner Scope
- gute Testbarkeit
- trennt Datenentscheidung von UI-Einbau
- bereitet spaetere Integration vor

Nachteile:

- noch keine sichtbare UI
- braucht einen weiteren Schritt fuer echte Anzeige

Bewertung:

- bester naechster TDD-Schritt

### D) Nur Provider Behalten, Noch Keine UI

Beschreibung:

- `localCategoriesProvider` bleibt der einzige Baustein.
- keine weitere UI-nahe Vorbereitung.

Vorteile:

- kein Risiko fuer UI-Regression
- aktueller Stand bleibt stabil

Nachteile:

- lokale Kategorien bleiben weiterhin unsichtbar
- Ziel WordHub-Sichtbarkeit kommt nicht naeher

Bewertung:

- sicher, aber zu passiv als naechster Schritt

## 3. Empfehlung

Empfohlen ist Variante C als naechster Schritt:

- kleinen UI-neutralen oder widget-nahen Debug-Entry-Presenter vorbereiten
- Eingabe: lokale Kategorien aus `localCategoriesProvider`
- Ausgabe: ob ein Debug-Entry sichtbar sein darf und welche Kategorien angezeigt werden
- noch kein Umbau von `WordHubScreen`
- noch keine Produktnavigation

Danach kann Variante B oder eine sehr kleine Variante von A folgen:

- separater `LocalWordHubDebugScreen`
- oder ein `kDebugMode`-geschuetzter kleiner Bereich im bestehenden `WordHubScreen`

Nicht empfohlen:

- bestehende WordHub-Sektionen direkt auf lokale Kategorien umstellen
- Supabase-WordHub entfernen oder ersetzen
- lokale und Supabase-Kategorien in derselben Liste ohne klare Kennzeichnung mischen

## 4. Zu Nutzende Daten

Der Debug-Entry sollte auf diesen Daten basieren:

- `localCategoriesProvider`
- `LocalCategory.id`
- `LocalCategory.name`
- `LocalCategory.sortOrder`
- `LocalCategory.isArchived`

Aktuelle Regeln:

- nur aktive Kategorien anzeigen
- Sortierung kommt aktuell aus `CategoryRepository.loadCategories(...)`
- `LocalCategory.id` kann als lokale `categoryId` und als Debug-Key dienen
- `LocalCategory.name` ist das sichtbare Label

Spaeter sinnvoll:

- `wordCount`
- Beschreibung
- Import-/Diagnose-Status

Noch nicht nutzen:

- Supabase-ID
- `word_hub_taxonomy.supabaseId`
- alte `local_word_database.dart`
- technische Fallbacks auf `basics`

## 5. Verhalten Beim Tap

Moegliche Ziele:

### LocalLearningTestScreen Oeffnen

Beschreibung:

- Tap oeffnet `LocalLearningTestScreen` mit `categoryId: LocalCategory.id`.
- Umsetzung spaeter ueber `buildLocalLearningDebugScreen(categoryId: category.id)`.

Vorteile:

- passt zum aktuellen Debug-/Offline-first-Meilenstein
- keine bestehende Produkt-UI wird veraendert
- keine automatische Session
- kein LearnModeController
- kein Supabase

Nachteile:

- noch nicht die finale Produkt-Lernoberflaeche

Bewertung:

- Empfehlung fuer den ersten Tap-Schritt

### CategoryDetailScreen Mit categorySlug Oeffnen

Beschreibung:

- Tap oeffnet `CategoryDetailScreen` mit `categorySlug: category.id`.

Vorteile:

- naeher am bestehenden UI-Konzept
- nutzt vorhandenen CategoryDetail-Kontext

Nachteile:

- `CategoryDetailScreen` ist weiterhin an alte Controller-/Supabase-nahe Flows gekoppelt
- koennte falsche Erwartungen an lokalen Produktflow erzeugen
- lokale Kategorien und alte Progress-UI koennten vermischt wirken

Bewertung:

- spaeter separat planen

Empfehlung:

- zuerst `LocalLearningTestScreen` oeffnen
- `CategoryDetailScreen`-Oeffnung erst planen, wenn der lokale CategoryDetail-Startpfad und UI-Zustand robuster abgesichert sind

## 6. Was Nicht Passieren Darf

Nicht erlaubt:

- kein automatischer Import
- keine automatische Session
- kein Progress erzeugen
- keine Review-History schreiben
- kein Supabase entfernen
- keine bestehende WordHub-Navigation ersetzen
- keine bestehenden WordHub-Kacheln veraendern
- kein LearnModeController-Umbau
- kein `learn_mode_screen.dart`-Umbau
- keine Nutzung von `local_word_database.dart`
- kein Fallback auf `basics`
- kein produktiv sichtbarer Debug-Entry

Wenn keine lokalen Kategorien vorhanden sind, darf der Debug-Entry nicht so tun, als gaebe es `basics`.

## 7. Spaetere Tests

Sinnvolle Tests:

- `local_wordhub_debug_entry_shows_basics_when_local_category_exists`
  - lokale Kategorie `basics` vorhanden
  - Debug-Entry-State enthaelt `basics`
  - sichtbares Label stimmt

- `local_wordhub_debug_entry_hidden_when_no_local_categories`
  - Provider liefert leere Liste
  - kein Debug-Entry sichtbar

- `local_wordhub_debug_entry_opens_local_learning_screen_with_category_id`
  - Tap auf `basics` oeffnet `LocalLearningTestScreen`
  - `categoryId == basics`
  - kein Import und keine Session werden automatisch gestartet

- `old_wordhub_flow_remains_unchanged`
  - bestehende `hubSections` und alte WordHub-Taps bleiben unveraendert
  - Supabase-Flow wird nicht ersetzt

Zusaetzlich sinnvoll:

- archivierte lokale Kategorien werden nicht angezeigt
- kein Fallback auf `basics`
- Debug-Entry nur unter Debug-Gate sichtbar

## 8. Risiken

Risiken:

- alter WordHub wird versehentlich veraendert
- Debug-Entry wird produktiv sichtbar
- lokale und Supabase-Kategorien werden vermischt
- `basics` wird faelschlich als Fallback benutzt
- lokale Kategorien werden mit alten CategoryDetail-Progressdaten verwechselt
- Import und Sichtbarkeit werden zu frueh gekoppelt

Risikoreduktion:

- zuerst UI-neutralen Presenter/State bauen
- bestehende `hubSections` nicht anfassen
- `localCategoriesProvider` nur lesen
- sichtbaren UI-Schritt erst danach unter `kDebugMode`
- Tap zunaechst zum isolierten `LocalLearningTestScreen`

## 9. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt sollte noch nicht `WordHubScreen` veraendern.

Empfohlen:

1. Einen kleinen UI-neutralen Presenter fuer lokale WordHub-Debug-Kategorien erstellen.
2. Eingabe:
   - `List<LocalCategory>`
3. Ausgabe:
   - `isVisible`
   - Liste kleiner Debug-Items mit `categoryId` und `label`
4. Erster Test:
   - `local_wordhub_debug_entry_shows_basics_when_local_category_exists`

Danach:

- `local_wordhub_debug_entry_hidden_when_no_local_categories`
- dann erst ein kleiner Debug-Screen oder ein `kDebugMode`-geschuetzter WordHub-Entry

Nicht als naechster Schritt empfohlen:

- direkter Umbau von `WordHubScreen`
- direkte Navigation zu `CategoryDetailScreen`
- automatischer Import im WordHub
- Vermischung mit `word_hub_taxonomy.supabaseId`
