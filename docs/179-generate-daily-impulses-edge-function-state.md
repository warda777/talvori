# Generate Daily Impulses Edge Function State

## Ausgangslage

Tagesimpuls ist als spätere Backend-/Notification-Strategie dokumentiert. Die globale lokale Auswahl funktioniert bereits, Wörter können über Home und Lernmodus hinzugefügt werden, und der bestehende AI-Chat läuft über eine Supabase Edge Function mit serverseitigem KI-Key.

Für Tagesimpuls soll langfristig nicht der allgemeine Chat verwendet werden, sondern eine spezialisierte Function, die 1 bis 5 kurze Messenger-artige Nachrichten in einem KI-Request erzeugt.

## Neue Edge Function

Neu vorbereitet wurde:

- `supabase/functions/generate-daily-impulses/index.ts`

Die Function unterstützt:

- `OPTIONS`
- `POST`
- OpenAI-kompatible Provider-Konfiguration über serverseitige Environment Variables
- Usage Tracking über Feature `daily_impulse`
- Tageslimit über `DAILY_IMPULSE_DAILY_REQUEST_LIMIT`

Flutter enthält weiterhin keine KI-Secrets.

## Request-Format

Beispiel:

```json
{
  "words": [
    { "word": "move", "translation": "bewegen" },
    { "word": "superstar", "translation": "Superstar" },
    { "word": "destroyed", "translation": "zerstört" }
  ],
  "count": 3,
  "language": "EN",
  "style": "natural_message"
}
```

Unterstützte optionale Felder:

- `language`
- `style`
- `targetLevel`
- `timeSlots`

## Regeln

- `words` muss mindestens 1 Wort enthalten.
- Es werden maximal 5 Wörter akzeptiert.
- `count` ist optional und defaultet auf `1`.
- `count` muss zwischen `1` und `5` liegen.
- `count > 1` ist technisch möglich, soll produktseitig aber nur durch bewusste Nutzerentscheidung aktiviert werden.
- Standard bleibt 1 Tagesimpuls pro Tag.

## Response-Format

Erfolg:

```json
{
  "impulses": [
    {
      "slot": "morning",
      "message": "You moved like a superstar today.",
      "usedWords": ["move", "superstar"]
    }
  ]
}
```

Die KI-Antwort wird serverseitig validiert:

- JSON muss parsebar sein.
- `impulses` muss eine Liste sein.
- `message` darf nicht leer sein.
- `usedWords` wird geprüft oder fallback-mäßig aus den Request-Wörtern ergänzt.
- Die Ausgabe wird auf `count` begrenzt.

Ungültige KI-Ausgaben führen zu:

```json
{ "error": "ai_invalid_response" }
```

## Fehlercodes

Unterstützt werden:

- `method_not_allowed`
- `invalid_json`
- `words_required`
- `invalid_count`
- `ai_not_configured`
- `ai_provider_not_supported`
- `ai_auth_failed`
- `ai_rate_limited`
- `ai_request_failed`
- `ai_invalid_response`
- `quota_exceeded`

## Usage Tracking und Limits

Die Function nutzt die bestehende Usage-Tabelle mit:

- `feature = daily_impulse`
- `status = success`
- `status = failed`
- `status = blocked`

Das Tageslimit kommt aus:

- `DAILY_IMPULSE_DAILY_REQUEST_LIMIT`

Wenn das Limit `0` ist oder erreicht wurde, wird kein KI-Provider aufgerufen und die Function antwortet mit:

```json
{ "error": "quota_exceeded" }
```

Der Dev-Default liegt bei `1000` Requests pro Tag. Per-User-Limits und Premiumlogik bleiben spätere Produktionspunkte.

## Bewusst nicht umgesetzt

- Keine Notification-Implementierung
- Keine Push-Implementierung
- Keine automatische Generierung
- Keine Flutter-UI-Änderung
- Kein Secret in Flutter
- Keine SRS-Änderung
- Keine produktive Tagesplanung

## Nächster Schritt

Als nächster Schritt kann ein Flutter-seitiger Client für `generate-daily-impulses` vorbereitet werden. Danach sollte die lokale Vorschau/Planung diesen spezialisierten Client nutzen, bevor später lokale Notifications oder Push-Zustellung geplant werden.
