# Manual Translation Button State

## Ausgangslage

Lokale importierte Wörter können den Status `pending`, `translated` oder `failed` haben.

Der Supabase-basierte Entwicklungsmodus ist vorbereitet und kann über Dart define aktiviert werden:

```sh
flutter run --dart-define=TALVORI_TRANSLATION_MODE=supabase
```

Ohne dieses Define bleibt der `FakeTranslationClient` aktiv.

## Detail-Button

Im `LocalWordDetailScreen` ist jetzt ein klarer manueller Übersetzungsbutton sichtbar:

- `pending`: `Jetzt übersetzen`
- `failed`: `Erneut übersetzen`
- `translated`: kein Übersetzungsbutton

Der Button verarbeitet nur das aktuell geöffnete Wort. Nach der Verarbeitung wird das lokale Wortdetail neu geladen.

## Listen-Button

Der `LocalWordListScreen` behält den batchweisen manuellen Einstieg.

Die Texte sind eindeutiger:

- `Ausstehende Übersetzungen starten`
- `Übersetzungen starten / erneut versuchen`

Der Button erscheint nur, wenn pending oder failed Wörter vorhanden sind.

## Keine automatische Übersetzung

Es wurde keine automatische Verarbeitung aktiviert:

- nicht beim Import
- nicht beim App-Start
- nicht im Hintergrund
- nicht ohne Nutzeraktion

## Translation-Client

Der manuelle Button nutzt den bestehenden injizierten Translation-Pfad.

Default:

```text
FakeTranslationClient
```

Entwicklungsmodus:

```text
SupabaseTranslationClient -> SupabaseEdgeFunctionCaller -> translate-word
```

In Flutter liegt kein DeepL-Key und kein Secret.

## Status-Texte

Die UI unterscheidet klar:

- `Übersetzung ausstehend`
- `Übersetzung verfügbar`
- `Übersetzung fehlgeschlagen`

Pending-Wörter werden nicht mehr so beschrieben, als wäre die Übersetzung bereits verfügbar.

## Testablauf im Simulator

```sh
flutter run --dart-define=TALVORI_TRANSLATION_MODE=supabase
```

Danach:

1. `Meine Wörter` öffnen.
2. Importiertes pending Wort öffnen.
3. `Jetzt übersetzen` drücken.
4. Prüfen, ob die Übersetzung erscheint und der Status zu `Übersetzung verfügbar` wechselt.
5. Für failed Wörter `Erneut übersetzen` testen.

## Grenzen

- keine Endnutzer-Produktivaktivierung
- kein Secret in Flutter
- keine Supabase-Datenbank-Logik
- lokale SQLite-Daten bleiben Hauptquelle
