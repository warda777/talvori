# Remote Supabase Translation Dev Mode State

## Ausgangslage

Die Supabase Edge Function `translate-word` ist deployed und wurde remote erfolgreich getestet.

Test:

```json
{
  "text": "house",
  "sourceLang": "EN",
  "targetLang": "DE"
}
```

Antwort:

```json
{
  "translation": "Haus"
}
```

Die Supabase Secrets `DEEPL_API_KEY` und `DEEPL_API_BASE_URL` sind serverseitig gesetzt. In Flutter liegt kein DeepL-Key.

## Entwicklungsmodus

Talvori kann den Supabase-basierten Translation-Pfad im Entwicklungsmodus aktivieren.

Aktivierung:

```sh
flutter run --dart-define=TALVORI_TRANSLATION_MODE=supabase
```

Ohne dieses Define bleibt der lokale Default unverändert bei Fake.

## Technische Verdrahtung

Der lokale Translation-Provider liest:

```text
TALVORI_TRANSLATION_MODE
```

Wenn der Wert `supabase` ist, wird `LocalTranslationConfig.developmentSupabase()` verwendet.

Der manuelle Pending-/Retry-Flow nutzt dann:

```text
PendingTranslationProcessor
-> SupabaseTranslationClient
-> SupabaseEdgeFunctionCaller
-> translate-word
```

Die lokale SQLite-Datenbank bleibt die Quelle für Wörter und Translation-Status.

## Default bleibt Fake

Ohne Dart define gilt:

```dart
LocalTranslationConfig.defaultConfig
```

Das entspricht weiterhin dem `FakeTranslationClient`.

Unbekannte Werte für `TALVORI_TRANSLATION_MODE` fallen ebenfalls auf Fake zurück.

## Keine automatische Übersetzung

Der Supabase-Modus aktiviert keine automatische Verarbeitung:

- nicht beim Import
- nicht beim App-Start
- nicht im Hintergrund
- nicht ohne manuellen Button

Pending- und failed-Wörter werden weiterhin nur über den bestehenden manuellen Flow verarbeitet.

## Keine Endnutzer-UI

Es wurde keine sichtbare Produktiv-Einstellung und kein Endnutzer-Schalter eingebaut.

Der Modus ist nur für Entwicklung und Beta-Tests gedacht.

## Secrets

In Flutter gibt es:

- keinen DeepL-Key
- kein Secret
- keine DeepL-Base-URL mit Secret-Bezug

Der DeepL-Key bleibt serverseitig in Supabase Secrets.

## Testabdeckung

Abgesichert ist:

- Default ohne Define bleibt Fake
- `supabase`-Define erzeugt Supabase-Konfiguration
- unbekannte Werte fallen auf Fake zurück
- Supabase-Modus nutzt injizierbaren Fake Function Caller in Tests
- manueller Pending-/Retry-Flow bleibt testbar
- keine echten Netzwerkaufrufe in Tests
- keine Secrets nötig

## Nächster Schritt

Simulator-Test starten:

```sh
flutter run --dart-define=TALVORI_TRANSLATION_MODE=supabase
```

Dann:

1. Wort lokal importieren.
2. In `Meine Wörter` öffnen.
3. Manuellen Übersetzungsbutton starten.
4. Prüfen, ob pending zu translated wird.
5. Fehlerfall manuell mit ungültiger Function-Konfiguration oder fehlender Verbindung prüfen.
