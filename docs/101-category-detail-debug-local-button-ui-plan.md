# 101 Category Detail Debug Local Button UI Plan

Stand: 2026-05-15

## 1. Ziel

Ziel ist der erste minimale UI-Schritt fuer einen Debug-only lokalen Lernbutton in `CategoryDetailScreen`.

Der Button soll:

- nur unter `kDebugMode` sichtbar sein
- nur sichtbar sein, wenn `CategoryDetailLocalStartPath` ein lokales Mapping liefert
- den bestehenden Startbutton in `LevelsCard` unveraendert lassen
- den bestehenden Supabase-/LearnMode-Startflow nicht ersetzen
- einen manuellen Debug-Einstieg in den lokalen `LocalLearningTestScreen` ermoeglichen

Der Button ist kein Produkt-Feature, sondern ein kontrollierter Dev-/QA-Zugang fuer die lokale Offline-first-Kette.

## 2. Empfohlene Position

Der Button sollte moeglichst nahe am bestehenden Startbereich erscheinen, aber nicht in dessen Logik eingreifen.

Empfohlen:

- unterhalb der bestehenden `LevelsCard`
- vor dem finalen unteren Padding
- klein und klar als Debug markiert
- ohne Umbau der `LevelsCard`
- ohne Aenderung von `onStartPressed`

Warum dort:

- der bestehende Startbutton bleibt unangetastet
- der Debug-Zugang ist logisch nahe am Lernstart
- die bestehende `LevelsCard` muss nicht erweitert werden
- das Risiko fuer Regressionen im alten Lernflow bleibt niedrig

Nicht empfohlen:

- bestehenden Startbutton ersetzen
- `LevelsCard` fuer den ersten Schritt umbauen
- Button in produktive Navigation oder Header-Aktionen legen

## 3. Verwendete Daten

Fuer den ersten UI-Schritt sollten nur bereits vorbereitete lokale Bausteine genutzt werden:

- `widget.categorySlug`
- `CategoryDetailLocalStartPath`
- `CategoryDetailDebugLocalButtonPresenter`
- `localCategoryId`

Geplanter Ablauf im Build-Kontext:

1. `CategoryDetailLocalStartPath.resolve(categorySlug: widget.categorySlug)` auswerten.
2. Ergebnis an `CategoryDetailDebugLocalButtonPresenter.present(...)` geben.
3. Wenn `kDebugMode == true` und `state.isVisible == true`, Debug-Button anzeigen.
4. Beim Tap `state.localCategoryId` verwenden.

Wichtig:

- `widget.categorySlug` ist die erste kontrollierte Eingabe.
- Supabase-IDs werden nicht als lokale IDs verwendet.
- unbekannte Kategorien erzeugen keinen Button.
- es gibt keinen Fallback auf `basics`.

## 4. Verhalten Beim Tap

Beim Tap soll der Button den lokalen Debug-Lernscreen fuer die gemappte Kategorie oeffnen.

Sinnvolle Varianten:

- `buildLocalLearningDebugScreen(categoryId: localCategoryId)` in einer lokalen `MaterialPageRoute` verwenden
- alternativ spaeter eine parametrisierte Debug-Route nutzen, falls diese sauber geplant ist

Empfehlung fuer den kleinsten UI-Schritt:

- direkt `buildLocalLearningDebugScreen(categoryId: localCategoryId)` verwenden
- keinen bestehenden Router umbauen
- keine neue Produktnavigation einfuehren
- keinen Import starten
- keine Session automatisch starten

Der lokale Screen darf danach weiterhin selbst durch explizite Buttons arbeiten:

- Debug-Daten importieren
- Starten/Fortsetzen
- Richtig/Falsch
- Session abschliessen

## 5. Was Nicht Passieren Darf

Nicht erlaubt:

- bestehenden Startbutton veraendern
- `LearnModeController` anfassen
- `LearnModeScreen` anfassen
- Supabase-Dateien oder Supabase-Flows anfassen
- `word_providers.dart` anfassen
- `local_word_database.dart` verwenden
- automatischen Import beim Oeffnen von `CategoryDetailScreen` starten
- automatische lokale Session starten
- Datenbank direkt aus dem UI-Button oeffnen
- unbekannte Kategorie auf `basics` fallbacken
- Button in Release/Profile sichtbar machen

Der bestehende `LevelsCard.onStartPressed` muss unveraendert beim alten Flow bleiben.

## 6. Spaetere Tests

Sinnvolle Tests fuer den UI-Schritt:

- `debug_local_button_visible_for_basics_slug`
  - `categorySlug: basics`
  - lokales Mapping vorhanden
  - Debug-Button ist im Debug-Gate sichtbar

- `debug_local_button_hidden_without_local_mapping`
  - `categorySlug: unknown`, `travel` oder `null`
  - kein lokales Mapping
  - Debug-Button ist nicht sichtbar

- `debug_local_button_opens_local_learning_screen_with_category_id`
  - Tap oeffnet `LocalLearningTestScreen` mit `categoryId: basics`
  - kein Import wird automatisch gestartet
  - keine Session wird automatisch gestartet

- `existing_start_button_still_uses_old_flow`
  - vorhandener Startbutton bleibt am bisherigen `LearnModeScreen`-/Controller-Pfad
  - lokaler Debug-Button veraendert den alten Startpfad nicht

Wenn `kDebugMode` im Widget-Test schwer direkt steuerbar ist, sollte zuerst ein kleiner testbarer UI-Helfer oder eine Builder-Funktion geplant werden, die das Debug-Gate explizit als Parameter bekommt.

## 7. Risiken

Risiken:

- bestehender Startflow wird versehentlich veraendert
- Button wird produktiv sichtbar
- falsche Kategorie wird geoeffnet
- Layout wird durch den Zusatzbutton beschaedigt
- Debug-Button wird mit Produktfunktion verwechselt
- lokaler Import und lokaler Lernstart werden zu frueh gekoppelt

Risikoreduktion:

- `kDebugMode` als harte UI-Bedingung
- bestehendes `onStartPressed` nicht anfassen
- Button nur anzeigen, wenn Presenter-State sichtbar ist
- `localCategoryId` explizit aus `CategoryDetailLocalStartPath` verwenden
- keine automatische Aktion im Build
- erster UI-Schritt so klein wie moeglich halten

## 8. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt sollte noch nicht den bestehenden Startbutton veraendern.

Empfohlen:

1. Einen kleinen widget-nahen Builder fuer den Debug-Button einfuehren oder direkt minimal in `CategoryDetailScreen` testen.
2. Ersten Test schreiben:
   - `debug_local_button_visible_for_basics_slug`
3. Der Test sollte absichern:
   - bei Debug-Gate aktiv und `categorySlug: basics` wird der Debug-Button sichtbar
   - bestehender Startbutton bleibt vorhanden
   - kein Import und keine Session starten beim Rendern

Danach:

- `debug_local_button_hidden_without_local_mapping`
- erst anschliessend Tap-/Navigationstest mit `buildLocalLearningDebugScreen(categoryId: basics)`

Nicht als erster Schritt empfohlen:

- `LearnModeController` umbauen
- bestehenden Startbutton umverdrahten
- lokale Session direkt aus `CategoryDetailScreen` starten
- Importbutton und Lernbutton in einem Schritt koppeln
