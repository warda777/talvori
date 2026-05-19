# Translation Usage Limit State

## Ausgangslage

`translate-word` kann Übersetzungen über DeepL ausführen und schreibt Usage Events in `translation_usage_events`.

Bis zu diesem Schritt wurde Nutzung nur protokolliert. Eine echte Blockierung vor dem DeepL-Aufruf war noch nicht aktiv.

## Was neu ist

Die Edge Function prüft jetzt vor dem DeepL-Aufruf ein serverseitiges Tageslimit.

Wenn das Limit erreicht ist:

- DeepL wird nicht aufgerufen
- ein Usage Event mit `status = blocked` wird geschrieben
- die Function antwortet kontrolliert mit:

```json
{
  "error": "quota_exceeded"
}
```

Normale erfolgreiche Responses bleiben unverändert:

```json
{
  "translation": "Haus"
}
```

## Limit-Konfiguration

Das Limit wird über eine serverseitige Environment Variable gesteuert:

```text
TRANSLATION_DAILY_REQUEST_LIMIT
```

Verhalten:

- nicht gesetzt: Dev-Default `1000`
- ungültig: Dev-Default `1000`
- `0`: keine Übersetzung erlauben, sofort `quota_exceeded`
- positiver Wert: Tageslimit für Requests

Der Wert ist kein Secret und wird nicht in Flutter gespeichert.

## Aktuelle Zählweise

Die Function summiert `request_count` aus `translation_usage_events` für:

- `feature = translation`
- `day_bucket = heute`

Wenn später eine verlässliche `user_id` aus Supabase Auth verfügbar ist, soll pro Nutzer gezählt werden.

Aktuell bleibt die Fallback-Prüfung global pro Tag, solange `user_id` noch nicht produktiv aus JWT/Auth abgeleitet wird.

## Usage Events

Weiterhin werden geschrieben:

- `success` bei erfolgreicher Übersetzung
- `failed` bei DeepL-, Netzwerk- oder Response-Fehlern
- `blocked` bei Limitüberschreitung

Es werden keine vollständigen Texte gespeichert. Für Limits und Kostenkontrolle wird nur `character_count` genutzt.

## Fehlerverhalten

Wenn die Limitprüfung wegen fehlender Supabase-Service-Konfiguration oder Query-Fehlern nicht möglich ist, bleibt die Function im Entwicklungsmodus fail-open.

Das bedeutet:

- die Übersetzung wird nicht künstlich blockiert
- der Fehler wird serverseitig vorsichtig geloggt
- vor Produktion muss dieser Pfad strenger entschieden werden

## Noch offen

Vor produktiver Freigabe fehlen weiterhin:

- echte JWT-Verifikation
- zuverlässiges `user_id`-Mapping
- per-user Limits
- Free-/Premiumlimits
- Premiumstatus-/Entitlement-Prüfung
- Monitoring und Missbrauchsschutz

## Offline-First-Bezug

Der lokale Offline-Flow bleibt unverändert.

Wenn das Limit erreicht ist, schlägt nur die Online-Übersetzung kontrolliert fehl. Wörter bleiben lokal vorhanden und können weiter gelernt werden. Pending-/Failed-Status bleiben lokale Zustände.

## Nächster Schritt

Als nächstes sollte Auth produktionsnah angebunden werden:

1. Supabase JWT in `translate-word` validieren.
2. `user_id` aus dem Token ableiten.
3. Limitprüfung auf `user_id + day_bucket` umstellen.
4. Free-/Premiumlimits definieren.
5. Flutter-Fehlertext für `quota_exceeded` nutzerfreundlich darstellen.
