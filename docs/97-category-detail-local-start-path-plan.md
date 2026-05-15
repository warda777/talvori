# 97 Category Detail Local Start Path Plan

Stand: 2026-05-15

## 1. Ziel

Ziel ist ein kontrollierter lokaler Startpfad aus der bestehenden `CategoryDetail`-UI zur neuen lokalen Offline-first-Lernkette.

Der Startpfad soll spaeter:

- bestehende `CategoryDetailScreen`-UI als Einstiegspunkt nutzen
- lokale `categoryId` ueber `CategoryDetailLocalCategoryAdapter` bestimmen
- eine lokale Lernsession starten oder einen lokalen Lernscreen mit dieser Kategorie oeffnen koennen
- den alten Supabase-basierten Startflow nicht ersetzen
- die bestehende Produktnavigation nicht unkontrolliert veraendern

Der bestehende Startbutton ruft aktuell `seedForStart(currentId)` auf und navigiert danach zu `LearnModeScreen`. Dieser Pfad ist weiterhin alt/Supabase-nah und darf nicht nebenbei umgebaut werden.

## 2. Moegliche Varianten

### A) Zusaetzlicher Debug-only Button In CategoryDetailScreen

Beschreibung:

- Ein separater Debug-only Einstieg wuerde nur erscheinen, wenn eine lokale `categoryId` aufloesbar ist.
- Der bestehende Startbutton bleibt unveraendert.
- Der Button koennte zur lokalen Debug-Route beziehungsweise zum `LocalLearningTestScreen` fuehren.

Risiko:

- niedrig bis mittel
- beruehrt spaeter zwar `CategoryDetailScreen`, ersetzt aber keinen bestehenden Flow
- klar rueckbaubar

Aufwand:

- niedrig bis mittel

Testbarkeit:

- gut mit Widget-Test und Provider-/Adapter-Overrides

Bewertung:

- sicherste reale UI-Annäherung, aber nicht als allererster Code-Schritt, solange noch kein UI-neutraler Startpfad geplant/getestet ist

### B) Bestehender Startbutton Bekommt Optional Lokalen Pfad

Beschreibung:

- Der vorhandene `onStartPressed` entscheidet zwischen altem Supabase-Pfad und neuem lokalem Pfad.

Risiko:

- hoch
- beruehrt die wichtigste bestehende Startaktion
- Gefahr, alten Flow zu brechen
- Vermischung von `seedForStart`, `LearnModeScreen` und lokaler Session moeglich

Aufwand:

- mittel bis hoch

Testbarkeit:

- anspruchsvoll, weil bestehende UI, Supabase-Pfad und lokale Kette parallel abgesichert werden muessten

Bewertung:

- nicht als naechster Schritt geeignet

### C) Navigation Zum LocalLearningTestScreen Mit categoryId

Beschreibung:

- Nach erfolgreichem Mapping wird `LocalLearningTestScreen(categoryId: localCategoryId)` geoeffnet.
- Bestehender Startbutton bleibt unveraendert.
- Der Screen ist bereits isoliert vorhanden und kann lokale Aktionen ausfuehren.
- Die Debug-Route-Definition existiert bereits unter `/debug/local-learning` mit Default `basics`.

Risiko:

- niedrig
- lokale Kette bleibt sichtbar getrennt vom Produkt-LearnMode
- keine direkte Abhaengigkeit von `LearnModeScreen`
- keine direkte Aenderung an `LearnModeController`

Aufwand:

- niedrig

Testbarkeit:

- gut

Bewertung:

- beste erste UI-nahe Variante nach einem UI-neutralen Startpfad-Test

### D) Direkte Anbindung An LearnModeScreen

Beschreibung:

- `LearnModeScreen` wuerde lokale Daten oder lokalen Controller konsumieren.

Risiko:

- sehr hoch
- `LearnModeScreen` ist aktuell an alten `LearnModeController`, `WordUserView` und Supabase-nahe Logik gekoppelt
- hohe Regressionsgefahr

Aufwand:

- hoch

Testbarkeit:

- erst nach mehreren Adapter-Schritten sinnvoll

Bewertung:

- nicht fuer den naechsten Schritt geeignet

## 3. Empfehlung

Empfohlen wird:

1. Nicht den bestehenden Startbutton umbauen.
2. Nicht `LearnModeScreen` direkt anbinden.
3. Zuerst einen UI-neutralen lokalen Startpfad planen und testen.
4. Danach optional einen Debug-only Button in `CategoryDetailScreen` planen, der nur bei vorhandenem lokalem Mapping sichtbar wird.
5. Als erste Zielnavigation `LocalLearningTestScreen` beziehungsweise die bestehende lokale Debug-Route verwenden.

Die sicherste erste Integrationsrichtung ist also:

`CategoryDetail-Daten -> CategoryDetailLocalCategoryAdapter -> localCategoryId -> LocalLearningTestScreen`

Erst danach sollte eine echte Produktintegration in bestehende Lernscreens diskutiert werden.

## 4. Daten Aus CategoryDetail

`CategoryDetailScreen` kann perspektivisch folgende Daten liefern:

- `widget.categorySlug`
- `widget.categoryId`
- `widget.title`
- `currentId`
- aktueller Name aus `CategoryInfo.name`
- `CategoryInfo.slug`
- `CategoryInfo.id`

`CategoryDetailController` nutzt intern `CategoryInfo` mit:

- `id`
- `name`
- `slug`
- `groupSlug`
- `groupName`
- `orderIndex`

Fuer den lokalen Pfad sind zuerst sinnvoll:

- `categorySlug`
- spaeter `CategoryInfo.slug`
- optional ein expliziter lokaler `categoryKey`

Nicht als primaere lokale Eingabe empfohlen:

- Supabase-`categoryId`
- `currentId`, solange es aus `CategoryInfo.id` und damit aus der alten Datenquelle kommt
- sichtbarer Titel/Name als einziges Mapping

## 5. Nutzung Des CategoryDetailLocalCategoryAdapter

Der Adapter soll den lokalen Startpfad vorbereiten:

- `categoryKey` pruefen
- falls nicht bekannt: `categorySlug` pruefen
- lokale `categoryId` bestimmen
- bei `null` keinen lokalen Start anbieten

Aktuelle Regeln:

- `basics` -> `basics`
- normalisierte `basics`-Werte -> `basics`
- unbekannte Werte -> `null`
- kein Fallback auf `basics`

Wichtig:

Wenn kein lokales Mapping existiert, soll der lokale Startpfad nicht angezeigt oder nicht aktiviert werden. Der alte Supabase-Flow darf dabei unveraendert verfuegbar bleiben.

## 6. Optionen Nach Erfolgreichem Mapping

### Option 1: LocalLearningTestScreen Mit localCategoryId Oeffnen

Beschreibung:

- `LocalLearningTestScreen(categoryId: localCategoryId)` wird geoeffnet.

Vorteile:

- nutzt vorhandenen isolierten lokalen Screen
- keine direkte Kopplung an Produkt-LearnMode
- lokale Aktionen sind bereits testbar
- gute Debug-/QA-Stufe

Nachteile:

- noch keine finale Produkt-UI
- muss klar als Debug/Dev sichtbar bleiben

Bewertung:

- beste erste Option

### Option 2: LocalLearningController.startOrResume Direkt Starten

Beschreibung:

- Lokaler Startpfad ruft `LocalLearningController.startOrResume(...)` direkt auf.

Vorteile:

- startet echte lokale Session ohne Umweg

Nachteile:

- braucht klare UI-State-Anbindung
- Gefahr, Sessionstart und Navigation zu vermischen
- mehr Tests noetig

Bewertung:

- sinnvoll spaeter, aber nicht als erster CategoryDetail-Schritt

### Option 3: Spaeter LearnModeScreen Anbinden

Beschreibung:

- Bestehender `LearnModeScreen` konsumiert lokale Daten.

Vorteile:

- erhaelt bestehende Produkt-UI

Nachteile:

- hoechstes Kopplungsrisiko
- braucht vorher Adapter fuer LearnMode-Daten und Controller-Fassade

Bewertung:

- erst nach mehreren lokalen Adapter- und Regressionstests

## 7. Was Nicht Passieren Darf

Nicht erlaubt:

- alten Startflow ersetzen
- automatische Session beim Screen-Build starten
- automatischen Import ausloesen
- Supabase entfernen oder umbauen
- `LearnModeController` umbauen
- `learn_mode_screen.dart` umbauen
- `category_detail_screen.dart` im Planungsschritt veraendern
- unbekannte Kategorien auf `basics` fallbacken
- lokalen Startpfad anzeigen, wenn kein lokales Mapping existiert
- Produktnavigation unkontrolliert erweitern

## 8. Sinnvolle Tests Spaeter

Sinnvolle Tests:

- `local_start_path_resolves_basics_from_category_slug`
- `local_start_path_hidden_when_no_local_mapping`
- `local_start_path_does_not_trigger_old_flow`
- `local_start_path_opens_debug_screen_with_local_category_id`
- `existing_supabase_start_flow_still_available`

Weitere spaetere Tests:

- `local_start_path_does_not_start_session_on_build`
- `local_start_path_does_not_import_assets`
- `local_start_path_uses_adapter_before_navigation`
- `local_start_path_does_not_use_supabase_id_as_local_id`

## 9. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt sollte weiterhin UI-neutral sein.

Empfohlen:

1. Einen kleinen `CategoryDetailLocalStartPath` oder `CategoryDetailLocalStartPathAdapter` planen/erstellen.
2. Er bekommt:
   - `CategoryDetailLocalCategoryAdapter`
   - einfache Eingaben wie `categorySlug`
3. Er gibt nur eine Entscheidung zurueck, z. B.:
   - `localCategoryId`
   - `canOpenLocalDebugLearning`
4. Er startet keine Session.
5. Er navigiert nicht.
6. Er importiert nichts.

Erster Test:

- `local_start_path_resolves_basics_from_category_slug`

Erwartung:

- `categorySlug: basics` ergibt `localCategoryId: basics`
- lokaler Start ist erlaubt
- keine Datenbank ist noetig
- kein Supabase ist noetig
- kein Import wird gestartet
- keine Session wird gestartet

Erst nach diesem UI-neutralen Schritt sollte ein Debug-only UI-Einstieg in `CategoryDetailScreen` geplant werden.
