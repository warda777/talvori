# 99 Category Detail Debug Local Button Plan

Stand: 2026-05-15

## 1. Ziel

Ziel ist ein optionaler Debug-only Button in `CategoryDetailScreen`, der einen lokalen Lernpfad sichtbar macht, ohne den bestehenden Startbutton oder den alten Supabase-Flow zu veraendern.

Der Button soll:

- nur im Debug-Modus sichtbar sein
- nur erscheinen, wenn `CategoryDetailLocalStartPath` ein lokales Mapping liefert
- den bestehenden Startbutton unveraendert lassen
- den alten Supabase-basierten Lernflow unveraendert lassen
- den lokalen Debug-Lernscreen fuer die gemappte lokale Kategorie oeffnen

Der Button ist kein Produkt-Feature, sondern ein kontrollierter Dev-/QA-Einstieg.

## 2. Moegliche Position

Sinnvolle Positionen:

### Unterhalb Des Bestehenden Startbereichs

Vorteile:

- klar getrennt vom bestehenden Startbutton
- geringe Gefahr, den alten Startflow zu verwechseln
- kann klein und sichtbar als Debug markiert werden

Nachteile:

- braucht Layoutplatz im ohnehin kompakten `CategoryDetailScreen`

### Oberhalb Des Bestehenden Startbuttons

Vorteile:

- sichtbar nah am Lernstart-Kontext

Nachteile:

- groessere Verwechslungsgefahr mit dem produktiven Startbutton

### Kleiner Debug-Hinweis / Debug-Button In Der Naehe Des LevelsCard-Bereichs

Vorteile:

- klar als Debug-Einstieg markierbar
- bestehender Startbutton bleibt visuell primaer

Nachteile:

- braucht sorgfaeltige Platzierung, damit kein bestehendes Layout verschoben wird

Empfehlung:

- kleiner Debug-only Button unterhalb oder neben dem bestehenden Startbereich
- deutlich als Debug beschriften
- nur unter `kDebugMode`
- nicht als Ersatz fuer den vorhandenen Startbutton

## 3. Zu Nutzende Daten

Fuer den ersten Schritt sollen nur bereits vorhandene, einfache Eingaben genutzt werden:

- `widget.categorySlug`
- `CategoryDetailLocalStartPath`
- `localCategoryId`

Spaeter moeglich:

- `CategoryInfo.slug`
- expliziter `categoryKey`
- weitere lokale Asset-Kategorien

Nicht fuer den ersten Schritt:

- Supabase-`categoryId` als lokale ID
- `currentId`, solange es aus der alten Kategoriequelle kommt
- sichtbarer `title` als Mapping
- Kategorie-Name als automatische lokale ID

Der Ablauf waere:

1. `CategoryDetailLocalStartPath.resolve(categorySlug: widget.categorySlug)` aufrufen.
2. Wenn `canOpenLocalDebugLearning == true`, Debug-Button anzeigen.
3. Beim Tap `localCategoryId` verwenden.
4. Wenn kein Mapping existiert, keinen lokalen Debug-Button anzeigen.

## 4. Verhalten Des Buttons

Der Button soll:

- `LocalLearningTestScreen` mit `localCategoryId` oeffnen
- oder die bestehende Debug-Route mit `localCategoryId` verwenden, falls die Route Parameter sauber unterstuetzt
- keine Session automatisch starten
- keinen Import automatisch ausloesen
- keinen bestehenden Startflow beruehren

Empfehlung fuer den ersten UI-Schritt:

- Direkt `LocalLearningTestScreen(categoryId: localCategoryId)` ueber eine klar isolierte Debug-Navigation oeffnen
- oder die vorhandene Debug-Route-Builder-Funktion `buildLocalLearningDebugScreen(categoryId: localCategoryId)` verwenden

Wichtig:

Die bestehende Route `/debug/local-learning` hat aktuell `basics` als Default. Fuer CategoryDetail sollte die konkrete `localCategoryId` genutzt werden, nicht blind der Default.

## 5. Was Nicht Passieren Darf

Nicht erlaubt:

- bestehenden Startbutton veraendern
- bestehenden Startbutton ersetzen
- `LearnModeController` anfassen
- `LearnModeScreen` anfassen
- Supabase entfernen oder umbauen
- automatischen Import starten
- automatische lokale Session starten
- beim `CategoryDetailScreen`-Build eine lokale Aktion ausloesen
- unbekannte Kategorie auf `basics` fallbacken
- Button in Release/Profile sichtbar machen
- produktive Navigation erweitern

Wenn `CategoryDetailLocalStartPath` kein lokales Mapping liefert, darf der Button nicht sichtbar oder nicht aktiv sein.

## 6. Noetige Tests Spaeter

Sinnvolle Tests:

- `debug_local_button_visible_for_basics_slug`
  - bei `widget.categorySlug: basics`
  - `CategoryDetailLocalStartPath` liefert `basics`
  - Debug-Button ist sichtbar

- `debug_local_button_hidden_without_local_mapping`
  - bei `unknown`, `travel` oder `null`
  - kein lokales Mapping
  - Debug-Button ist nicht sichtbar

- `debug_local_button_opens_local_learning_screen_with_category_id`
  - Tap auf Debug-Button oeffnet lokalen Testscreen mit `categoryId: basics`
  - kein Import wird gestartet
  - keine Session wird automatisch gestartet

- `existing_start_button_still_uses_old_flow`
  - bestehender Startbutton bleibt an altem Pfad
  - keine lokale Navigation durch den bestehenden Startbutton
  - alter Supabase-Flow bleibt separat

Weitere Absicherung:

- Debug-Button ist nur unter Debug-Gate sichtbar
- kein Fallback auf `basics`
- keine Supabase-Initialisierung fuer die lokale Button-Entscheidung

## 7. Risiken

Risiken:

- Button wird versehentlich produktiv sichtbar
- bestehender Startflow wird aus Versehen veraendert
- falsche `categoryId` wird geoeffnet
- `basics`-Fallback wird versehentlich eingefuehrt
- Nutzer verwechseln Debug-Einstieg mit produktivem Lernstart
- Layout wird durch einen zusaetzlichen Button instabil

Risikoreduktion:

- `kDebugMode` verwenden
- bestehenden Startbutton nicht anfassen
- Button nur bei `canOpenLocalDebugLearning == true` anzeigen
- `localCategoryId` explizit aus `CategoryDetailLocalStartPath` verwenden
- Tests zuerst mit isolierter UI-nahem Builder oder kleinem Widget planen

## 8. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt sollte noch nicht sofort `CategoryDetailScreen` umbauen.

Empfohlen:

1. Einen kleinen UI-neutralen oder widget-nahen Debug-Button-Presenter planen/erstellen, z. B.:
   - entscheidet aus `CategoryDetailLocalStartPathResult`, ob der Button sichtbar ist
   - liefert `localCategoryId`
   - startet keine Navigation
2. Erster Test:
   - `debug_local_button_visible_for_basics_slug`
3. Danach:
   - `debug_local_button_hidden_without_local_mapping`

Alternative, wenn direkt ein Widget-Schritt gewuenscht ist:

- einen kleinsten isolierten Debug-Button-Widget-Test schreiben, ohne `CategoryDetailScreen` zu veraendern
- erst danach den Button in `CategoryDetailScreen` planen

Erst nach diesen Tests sollte eine minimale Debug-only Aenderung an `CategoryDetailScreen` erfolgen.
