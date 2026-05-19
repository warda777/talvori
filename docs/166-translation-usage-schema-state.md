# Translation Usage Schema State

## Ausgangslage

Talvori hat einen lokalen manuellen Übersetzungsflow und eine Supabase Edge Function `translate-word`.

Der DeepL-Key liegt serverseitig als Supabase Secret. Flutter enthält keine Secrets. Der lokale Offline-Flow bleibt unverändert und nutzt SQLite als Hauptquelle für Wörter, Lernfortschritt und Translation-Status.

Für eine spätere produktive Freischaltung braucht die Übersetzungsfunktion Usage Tracking, Limits und Kostenkontrolle.

## Neue Tabelle

Die Migration legt die Tabelle `public.translation_usage_events` an.

Zweck der Tabelle:

- Übersetzungsnutzung serverseitig erfassen
- spätere Tages-/Monatslimits ermöglichen
- Free-/Premium-Grenzen vorbereiten
- Kostenkontrolle für DeepL vorbereiten
- Missbrauchsschutz für spätere Online-Funktionen unterstützen

## Felder

Die Tabelle enthält:

- `id`: UUID Primary Key, `gen_random_uuid()`
- `user_id`: nullable UUID, später bevorzugt aus Supabase Auth
- `feature`: Text, Default `translation`
- `request_count`: Integer, Default `1`
- `character_count`: Integer, Default `0`
- `status`: Text, z. B. `success`, `failed`, `blocked`
- `day_bucket`: Datum, Default `current_date`
- `plan`: optionaler Plan, z. B. `free`, `premium`, `internal`
- `created_at`: Zeitpunkt des Events

## Constraints

Die Migration ergänzt Schutzregeln:

- `request_count >= 0`
- `character_count >= 0`
- `status in ('success', 'failed', 'blocked')`

`user_id` verweist auf `auth.users(id)` und wird bei gelöschten Nutzern auf `null` gesetzt. Dadurch können aggregierte Usage-Daten erhalten bleiben, ohne eine harte User-Referenz zu behalten.

## Indexe

Die Tabelle erhält Indexe für spätere Abfragen:

- `user_id`, `day_bucket`
- `feature`, `day_bucket`
- `created_at`

Diese Indexe unterstützen spätere Tageslimits, Feature-Auswertungen und einfache Zeitreihen-/Audit-Abfragen.

## RLS

Row Level Security ist aktiviert.

Es wurden bewusst keine breiten Client-Policies angelegt. Die Tabelle soll später serverseitig über die Edge Function geschrieben und ausgewertet werden.

Das schützt davor, dass normale Flutter-Clients Usage-Events direkt schreiben oder manipulieren.

## Noch keine harte Limitierung

Diese Migration aktiviert noch keine produktive Limitprüfung.

Noch nicht umgesetzt:

- keine Blockierung in `translate-word`
- keine Tages-/Monatsquota
- keine Premiumprüfung
- keine Supabase-Datenbanklogik im Flutter-Offline-Flow
- keine automatische Übersetzung

Die Tabelle ist nur die Grundlage für spätere Limits und Kostenkontrolle.

## Offline-First-Bezug

Lokales Lernen bleibt unabhängig.

Wenn Online-Übersetzung nicht verfügbar ist oder später ein Limit erreicht wird, bleiben Wörter lokal `pending` oder `failed`. SRS, Wortliste und Lernmodus bleiben weiterhin lokal nutzbar.

## Nächster technischer Schritt

Als nächstes kann `translate-word` serverseitig erweitert werden:

1. Auth/JWT sauber validieren.
2. `user_id` bestimmen.
3. Usage für `user_id + day_bucket` aggregieren.
4. Limit prüfen.
5. Erst danach DeepL aufrufen.
6. Event mit `success`, `failed` oder `blocked` schreiben.

Vor produktiver Freischaltung müssen Auth, Premiumstatus und konkrete Free-/Premiumlimits final entschieden werden.
