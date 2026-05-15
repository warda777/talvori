# 100 Category Detail Debug Local Button Presenter Summary

Stand: 2026-05-15

## 1. Aufgabe

`CategoryDetailDebugLocalButtonPresenter` ist ein UI-neutraler Presenter fuer den spaeteren Debug-only lokalen Lernbutton in `CategoryDetailScreen`.

Er entscheidet nicht selbst ueber Kategorie-Mapping, Navigation oder Debug-Gates. Er uebersetzt nur ein bereits berechnetes `CategoryDetailLocalStartPathResult` in einen kleinen Button-State.

Der Presenter ist damit ein isolierter Zwischenbaustein zwischen lokalem Startpfad und spaeterer UI-Anzeige.

## 2. Eingabe

Der Presenter nutzt:

- `CategoryDetailLocalStartPathResult`

Dieses Ergebnis enthaelt:

- `localCategoryId`
- `canOpenLocalDebugLearning`

## 3. Ausgabe

`present(...)` erzeugt einen `CategoryDetailDebugLocalButtonState` mit:

- `isVisible`
- `localCategoryId`

Bedeutung:

- `isVisible` entscheidet, ob ein spaeterer Debug-Local-Button angezeigt werden darf.
- `localCategoryId` wird nur weitergegeben, wenn der Button sichtbar sein darf.

## 4. Regeln

Aktuell gelten:

- Mapping vorhanden und `canOpenLocalDebugLearning == true` -> Button sichtbar
- `localCategoryId != null` und `canOpenLocalDebugLearning == true` -> `localCategoryId` wird uebernommen
- kein Mapping -> Button nicht sichtbar
- `canOpenLocalDebugLearning == false` -> Button nicht sichtbar
- kein Fallback auf `basics`

Damit verhindert der Presenter, dass ein lokaler Debug-Einstieg ohne freigegebenen lokalen Startpfad sichtbar wird.

## 5. Tests

Die Tests liegen in:

- `test/core/local_database/category_detail_debug_local_button_presenter_test.dart`

Aktuell existieren:

- `debug_local_button_visible_for_basics_slug`
  - sichert ab, dass ein StartPathResult mit `localCategoryId: basics` und offenem Startpfad einen sichtbaren Button-State erzeugt
  - sichert ab, dass `localCategoryId: basics` erhalten bleibt
- `debug_local_button_hidden_without_local_mapping`
  - sichert ab, dass fehlendes Mapping keinen sichtbaren Button-State erzeugt
  - sichert ab, dass ein vorhandenes `localCategoryId` bei `canOpenLocalDebugLearning == false` nicht durchgereicht wird
  - verhindert implizite Fallbacks auf `basics`

## 6. Grenzen

Der Presenter macht weiterhin nicht:

- keine UI-Anbindung
- keine Datenbank oeffnen
- kein Supabase verwenden
- keinen Import starten
- keine Session starten
- keine Navigation ausloesen
- keinen bestehenden Startbutton veraendern
- kein `kDebugMode` pruefen
- keinen Fallback auf `basics` erzeugen

`kDebugMode` bleibt bewusst Aufgabe der spaeteren UI-Schicht.

## 7. Aktuelle Stabilitaetschecks

Zuletzt gruen:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter test test/features/local_learning_debug/`
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`

Ergebnis:

- 202 lokale Tests bestanden
- gezielter Analyzer: `No issues found`

## 8. Naechste Schritte

Sinnvoll:

- `CategoryDetailDebugLocalButtonPresenter` als abgeschlossen markieren
- danach einen minimalen Debug-only Button in `CategoryDetailScreen` separat planen
- bestehenden Startbutton weiterhin unangetastet lassen
- UI-Schritt nur unter klarem Debug-Gate planen
- keine produktive Navigation oder bestehende Lernflow-Anbindung daraus ableiten

Nicht empfohlen:

- kein direkter Umbau des bestehenden Startbuttons
- keine automatische Session beim Anzeigen von `CategoryDetailScreen`
- kein automatischer Import
- keine Kopplung an Supabase- oder alte Lerncontroller-Logik
