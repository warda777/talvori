# Translation Usage Event Recording State

## Ausgangslage

Die Supabase Edge Function `translate-word` ist deployed und kann Übersetzungen über DeepL ausführen.

Die Tabelle `public.translation_usage_events` existiert und ist als Grundlage für spätere Limits, Quotas und Kostenkontrolle angelegt.

## Was neu ist

`translate-word` schreibt jetzt serverseitig Usage Events für echte Übersetzungsversuche.

Erfasst werden:

- `user_id`, aktuell noch `null`, bis JWT/User-Auflösung produktiv umgesetzt ist
- `feature = translation`
- `request_count = 1`
- `character_count` als Länge des getrimmten Textes
- `status = success` bei erfolgreicher Übersetzung
- `status = failed` bei DeepL-, Netzwerk- oder Response-Fehlern
- `plan`, optional über serverseitige Runtime-Konfiguration

Die DB-Defaults setzen weiterhin `day_bucket` und `created_at`.

## Nicht-blockierendes Logging

Usage Logging ist bewusst defensiv implementiert.

Wenn `SUPABASE_URL` oder `SUPABASE_SERVICE_ROLE_KEY` nicht verfügbar sind, wird kein Usage Event geschrieben. Die Übersetzung wird dadurch nicht blockiert.

Wenn das Schreiben in `translation_usage_events` fehlschlägt, wird die Übersetzungsantwort ebenfalls nicht zerstört. Die Function gibt weiterhin die normale Übersetzungs- oder Fehlerresponse zurück.

## Keine sensiblen Texte im Usage Event

Die Usage-Tabelle speichert nicht den vollständigen übersetzten Text.

Für Kosten- und Limitkontrolle wird nur die Zeichenanzahl gespeichert. Dadurch können spätere Limits und Kostenabschätzungen erfolgen, ohne Nutzereingaben unnötig in der Usage-Tabelle zu speichern.

## Response-Kompatibilität

Erfolgreiche Responses bleiben unverändert:

```json
{
  "translation": "Haus"
}
```

Fehlerresponses bleiben ebenfalls kompatibel:

```json
{
  "error": "..."
}
```

Der Flutter-Client muss für dieses Usage Logging nichts direkt wissen.

## Noch keine harte Limitprüfung

Diese Änderung protokolliert Nutzung, blockiert aber noch nicht produktiv.

Noch nicht aktiv:

- keine Tageslimits
- keine Monatslimits
- keine Premium-/Free-Quota
- keine harte Rate-Limit-Blockierung
- keine automatische Übersetzung

Die vorhandene Auth-/Rate-Limit-Struktur bleibt vorbereitet, aber weiterhin dev-freundlich.

## Offline-First-Bezug

Der lokale Talvori-Flow bleibt unverändert.

SQLite bleibt Hauptquelle für importierte Wörter, Lernstatus und Translation-Status. Wenn Online-Übersetzung nicht funktioniert, bleiben Wörter lokal `pending` oder `failed`; Lernen bleibt möglich.

## Nächster Schritt

Als nächster technischer Schritt kann die Edge Function vor dem DeepL-Aufruf echte Limits prüfen:

1. Supabase JWT validieren.
2. `user_id` aus Auth ableiten.
3. Usage für `user_id + day_bucket` aggregieren.
4. Free-/Premiumlimit prüfen.
5. Bei Überschreitung `rate_limit_exceeded` oder `quota_exceeded` zurückgeben.
6. Blockierte Versuche als `status = blocked` protokollieren.
