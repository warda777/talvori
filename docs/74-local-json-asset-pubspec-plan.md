# 74 Local JSON Asset Pubspec Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant den spaeteren `pubspec.yaml`-Asset-Eintrag fuer die echte lokale JSON-Asset-Datei.

Es ist nur Planung:

- kein Code
- keine `pubspec.yaml`-Aenderung
- keine UI-Aenderung
- keine Supabase-Aenderung
- keine App-Flow-Aenderung
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`
- keine Aenderung an `local_word_database.dart`

## 1. Ziel Des pubspec.yaml-Eintrags

Der spaetere `pubspec.yaml`-Eintrag soll:

- `assets/local_import/default_words_v1.json` als Flutter-Asset registrieren
- spaeteres Laden ueber `AssetBundle` oder `rootBundle` ermoeglichen
- den bestehenden `LocalJsonAssetImportService` mit einer echten Asset-Datei nutzbar machen
- weiterhin keinen automatischen Import beim App-Start ausloesen

Wichtig:

Der Eintrag macht die Datei nur fuer Flutter als Asset verfuegbar. Er soll keine Datenbank oeffnen, keinen Import starten und keine bestehenden App-Flows veraendern.

## 2. Sinnvolle Asset-Zeile

Es gibt zwei naheliegende Varianten.

### Variante A: Einzelne Datei

Geplanter Eintrag:

```yaml
flutter:
  assets:
    - assets/local_import/default_words_v1.json
```

Vorteile:

- kleinster moeglicher Scope
- klarer Testumfang
- keine versehentlichen weiteren Dateien
- Review bleibt einfach
- passt zum aktuellen Stand mit genau einer echten Asset-Datei
- reduziert Risiko, dass unfertige lokale Importdateien im App-Bundle landen

Nachteile:

- weitere Importdateien muessen spaeter einzeln ergaenzt werden
- bei vielen Dateien etwas mehr Pflegeaufwand

### Variante B: Ganzes Verzeichnis

Moeglicher Eintrag:

```yaml
flutter:
  assets:
    - assets/local_import/
```

Vorteile:

- neue Dateien im Verzeichnis koennen spaeter einfacher mitregistriert werden
- praktisch, falls viele lokale Importdateien geplant sind

Nachteile:

- zu breiter Scope fuer den aktuellen Stand
- unfertige oder experimentelle Dateien koennten versehentlich als App-Assets registriert werden
- groesseres Risiko, Test-/Demo-/Produktdaten zu vermischen
- unklarerer Testumfang
- hoeheres Risiko bei spaeteren Inhaltsaenderungen

### Empfehlung

Fuer Version 1 wird die einzelne Datei empfohlen:

```yaml
flutter:
  assets:
    - assets/local_import/default_words_v1.json
```

Begruendung:

Aktuell existiert genau eine echte lokale Asset-Datei. Die einzelne Datei ist daher der risikoaermste Eintrag und passt zur bisherigen isolierten TDD-Linie.

## 3. Stelle In pubspec.yaml

Aktueller relevanter Bereich:

```yaml
flutter:
  uses-material-design: true
  assets:
    - .env
    - assets/icons/
    - assets/images/
    - assets/sounds/
```

Der spaetere Eintrag gehoert unter:

- `flutter:`
- darunter `assets:`
- mit derselben Einrueckung wie die bestehenden Asset-Zeilen

Geplanter Zielzustand:

```yaml
flutter:
  uses-material-design: true
  assets:
    - .env
    - assets/icons/
    - assets/images/
    - assets/sounds/
    - assets/local_import/default_words_v1.json
```

Wichtig:

- `flutter:` bleibt auf Root-Ebene.
- `assets:` bleibt zwei Leerzeichen unter `flutter:`.
- einzelne Asset-Zeilen bleiben vier Leerzeichen unter `flutter:`.
- keine Tabs verwenden.

## 4. Warum Zunaechst Nur Die Einzelne Datei

Zunaechst nur `assets/local_import/default_words_v1.json` zu registrieren ist sinnvoll, weil:

- der lokale Asset-Datei-Block aktuell genau diese Datei absichert
- die Datei bereits per normalem `File` getestet ist
- der naechste Test gezielt beweisen kann, dass genau diese Datei ueber Flutter-Assets ladbar ist
- keine weiteren Dateien im Verzeichnis unabsichtlich Teil des App-Bundles werden
- die Trennung zwischen Fixture, Asset-Datei und spaeteren Produktdaten klar bleibt

Das ganze Verzeichnis sollte erst registriert werden, wenn mehrere echte Importdateien bewusst kuratiert, getestet und fuer das App-Bundle freigegeben sind.

## 5. Tests Nach Dem pubspec.yaml-Eintrag

Nach dem spaeteren `pubspec.yaml`-Eintrag sollten zuerst isolierte Tests folgen.

Sinnvolle Tests:

- `asset_is_registered_and_loadable_with_root_bundle`
- `asset_bundle_can_load_default_words_v1`
- `loaded_asset_can_be_imported_with_local_json_import_service`

### asset_is_registered_and_loadable_with_root_bundle

Sichert ab:

- Flutter kennt den Asset-Key.
- `rootBundle.loadString('assets/local_import/default_words_v1.json')` kann die Datei laden.
- der geladene Inhalt ist nicht leer.
- JSON ist parsebar.

Dieser Test prueft nur die Registrierung und Ladbarkeit, nicht den Datenbankimport.

### asset_bundle_can_load_default_words_v1

Sichert ab:

- `LocalJsonAssetImportService.loadJsonFromAsset(...)` kann die echte Asset-Datei ueber ein passendes `AssetBundle` laden.
- der erwartete Asset-Key wird verwendet.
- kein direkter `File`-Zugriff noetig ist.

Dieser Test sollte weiterhin ohne App-Start und ohne UI laufen.

### loaded_asset_can_be_imported_with_local_json_import_service

Sichert ab:

- geladener Asset-JSON-String kann an `LocalJsonImportService` uebergeben werden.
- Kategorie `basics` wird erstellt.
- Woerter `basics_hello` und `basics_water` werden erstellt.
- `word_progress` bleibt leer.
- `learning_sessions` bleibt leer.
- `review_history` bleibt leer.

Dieser Test verbindet Asset-Laden und Import, darf aber weiterhin keine App-Flows starten.

## 6. Was Weiterhin Nicht Passieren Darf

Auch nach dem `pubspec.yaml`-Eintrag gilt:

- kein automatischer App-Start-Import
- keine UI-Anbindung
- keine Navigation
- keine Provider-Umstellung
- keine Supabase-Entfernung
- keine Supabase-Nutzung im Importpfad
- kein Zugriff auf `local_word_database.dart`
- kein Zugriff auf alte `word_progress.db`
- kein Progress durch Import
- keine Sessions durch Import
- keine Review-History durch Import
- keine Aenderung an bestehenden App-Flows
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`

Der Asset-Eintrag darf nur die Ladbarkeit der Datei herstellen.

## 7. Risiken

### Falsche YAML-Einrueckung

Risiko:

- Flutter erkennt den Asset-Eintrag nicht.
- `flutter test` oder Asset-Ladetests schlagen fehl.

Gegenmassnahme:

- Eintrag direkt unter bestehendem `assets:`-Block mit gleicher Einrueckung setzen.
- Danach einen gezielten Asset-Ladetest ausfuehren.

### Zu Breite Asset-Registrierung

Risiko:

- `assets/local_import/` registriert mehr Dateien als beabsichtigt.
- unfertige JSON-Dateien koennen versehentlich ins App-Bundle gelangen.

Gegenmassnahme:

- zunaechst nur `assets/local_import/default_words_v1.json` registrieren.

### Unkontrollierter App-Start-Import

Risiko:

- die Datei wird spaeter beim App-Start automatisch importiert und schreibt ungeplant Daten in `talvori_local_v1.db`.

Gegenmassnahme:

- `pubspec.yaml`-Eintrag strikt vom Importausloeser trennen.
- Import spaeter nur bewusst ueber separaten, getesteten Pfad planen.

### Testdaten Und Produktdaten Werden Vermischt

Risiko:

- Fixture-Daten aus `test/fixtures/...` und echte Asset-Daten aus `assets/...` werden konzeptionell vermischt.

Gegenmassnahme:

- Fixture bleibt Testdatenquelle.
- echte Asset-Datei bleibt spaetere App-Bundle-Datenquelle.
- Tests benennen klar, welche Quelle sie verwenden.

## 8. Kleinster Naechster TDD-Schritt

Empfohlener kleinster naechster TDD-Schritt nach dieser Planung:

1. `pubspec.yaml` minimal erweitern:
   - nur `assets/local_import/default_words_v1.json`
2. genau einen Test schreiben:
   - `asset_is_registered_and_loadable_with_root_bundle`
3. Testinhalt:
   - `rootBundle.loadString('assets/local_import/default_words_v1.json')`
   - Inhalt ist nicht leer
   - JSON ist parsebar
   - Top-Level ist eine Liste
4. Danach nur den gezielten Test ausfuehren.

Noch nicht Teil dieses naechsten Schritts:

- kein Import in Datenbank ueber `rootBundle`
- keine App-Anbindung
- kein automatischer Import
- keine Provider-Aenderung
- keine UI-Aenderung
- keine Supabase-Aenderung

Empfehlung:

Der naechste Schritt sollte nur beweisen, dass die bestehende echte Asset-Datei durch Flutter registriert und ladbar ist. Erst danach sollte ein separater Test den geladenen Asset-String wieder an `LocalJsonImportService` uebergeben.
