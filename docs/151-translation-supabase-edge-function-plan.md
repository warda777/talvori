# Translation Supabase Edge Function Plan

## Ausgangslage

Talvori bleibt offline-first. Lokale Wörter, Lernfortschritt und Translation-Status werden weiterhin lokal gespeichert.

Aktueller Stand:

- `DeepLTranslationClient` existiert als isolierte vorbereitende Implementierung.
- `FakeTranslationClient` bleibt Default.
- `LocalTranslationConfig` ist vorbereitet.
- Manuelle Verarbeitung von `pending`- und `failed`-Übersetzungen funktioniert lokal.
- Die Architekturentscheidung lautet: Produktive DeepL-Übersetzung soll über eine Supabase Edge Function laufen.

## Ziel der Supabase Edge Function

Die Flutter-App sendet eine Übersetzungsanfrage an eine eigene Supabase Edge Function. Die Edge Function hält den DeepL-Key serverseitig geheim, ruft DeepL auf und gibt nur Übersetzung oder Fehler an die App zurück.

Die lokale SQLite-Datenbank speichert anschließend die Übersetzung und den Status.

## Grober Ablauf

1. Nutzer importiert ein Wort.
2. Wort wird lokal mit Status `pending` gespeichert.
3. Nutzer startet Übersetzung manuell.
4. App sendet Wort, `sourceLang` und `targetLang` an die Supabase Edge Function.
5. Edge Function validiert die Anfrage.
6. Edge Function ruft DeepL auf.
7. Bei Erfolg setzt die App lokal den Status `translated`.
8. Bei Fehler setzt die App lokal den Status `failed`.
9. Ohne Internet bleibt das Wort `pending` oder `failed`; die App bleibt weiter nutzbar.

## Warum nicht direkter DeepL-Key in Flutter

Eine Flutter-App kann Secrets nicht vollständig sicher schützen. Ein API-Key darf weder im Repository noch hart im App-Code liegen.

Ein Server-/Edge-Function-Layer schützt den Key besser. Außerdem können Missbrauchsschutz, Rate Limits, Logging und Kostenkontrolle zentral umgesetzt werden.

## Schnittstellenidee

Request:

```json
{
  "text": "house",
  "sourceLang": "EN",
  "targetLang": "DE"
}
```

Response success:

```json
{
  "translation": "Haus"
}
```

Response error:

```json
{
  "error": "translation_failed"
}
```

## Sicherheitsanforderungen

- DeepL-Key nur als Supabase Secret / Environment Variable speichern.
- Kein Secret in Git.
- Nutzer-Authentifizierung prüfen, falls Premium- oder User-Limits relevant werden.
- Rate Limiting einplanen.
- Missbrauchsschutz einplanen.
- Sensible Texte nicht unnötig loggen.
- Fehler kontrolliert zurückgeben.
- Spätere KI-Chatfunktion ebenfalls über Edge Function absichern.

## Auswirkungen auf Flutter

Später entsteht ein `ProxyTranslationClient` oder `SupabaseTranslationClient`. Dieser implementiert ebenfalls `TranslationClient`.

Der `PendingTranslationProcessor` bleibt dadurch austauschbar und muss nicht wissen, ob Fake, DeepL-direkt oder Edge Function verwendet wird. Die UI bleibt ebenfalls unabhängig vom konkreten Online-Anbieter.

Der Offline-Flow bleibt erhalten.

## Bezug zur späteren KI-Chatfunktion

Eine KI-Chatfunktion benötigt ebenfalls Internet und geschützte API-Keys. Die gleiche Grundarchitektur kann später genutzt werden:

```text
Flutter-App -> Supabase Edge Function -> KI-Anbieter
```

Damit entsteht ein einheitlicher sicherer Online-Layer.

## Nächste technische Schritte

1. Supabase Edge Function `translate-word` planen.
2. Supabase Secrets für DeepL vorbereiten.
3. `SupabaseTranslationClient` in Flutter planen.
4. Tests mit Mock/Fake Function-Response ergänzen.
5. Erst danach produktive Aktivierung überlegen.
