# Translation Usage Tracking Plan

## Ausgangslage

Der manuelle lokale Übersetzungsflow funktioniert.

Die Supabase Edge Function `translate-word` ist deployed und wurde getestet. Der DeepL-Key liegt serverseitig als Supabase Secret. Flutter enthält keine Secrets und ruft DeepL nicht direkt auf.

Talvori bleibt offline-first:

- lokale Wörter bleiben in SQLite
- lokaler Lernfortschritt bleibt unabhängig
- Translation-Status bleibt lokal
- Übersetzung ist eine optionale Online-Ergänzung

Auth- und Rate-Limit-Struktur für `translate-word` ist vorbereitet, aber noch nicht produktiv aktiv.

## Ziel

Usage Tracking soll vor einer produktiven Freischaltung sicherstellen, dass Talvori Übersetzungsnutzung kontrollieren kann.

Ziele:

- DeepL-Kosten begrenzen
- Missbrauch verhindern
- Nutzung pro Nutzer nachvollziehbar machen
- Free-/Premium-Limits ermöglichen
- eine Grundlage für spätere KI-Chatlimits schaffen

## Warum Usage Tracking nötig ist

Jede Online-Übersetzung kann Kosten verursachen.

Ohne Limits könnte ein Nutzer sehr viele Wörter übersetzen oder die Edge Function automatisiert missbrauchen. Der DeepL-Key bleibt zwar serverseitig geschützt, aber ohne Nutzungsbegrenzung kann trotzdem Kosten- oder Abuse-Risiko entstehen.

Eine produktive Freischaltung braucht deshalb:

- Auth
- Nutzungszählung
- Limits
- kontrollierte Fehlerantworten
- vorsichtiges Logging ohne sensible Texte

## Mögliche Tracking-Daten

Eine spätere Usage-Tabelle oder View könnte folgende Felder enthalten:

- `user_id`
- `feature`, z. B. `translation`
- `request_count`
- `character_count`
- `day_bucket` oder `date`
- `status`, z. B. `success` oder `failed`
- `created_at`
- optional `plan`, z. B. `free`, `premium`, `internal`

Je nach Implementierung kann auch monatlich aggregiert werden, z. B. über `month_bucket`.

Wichtig: Vollständige Nutzereingaben sollten nicht unnötig gespeichert werden.

## Mögliche Limit-Regeln

Beispiele für spätere Regeln:

- Free: X Übersetzungen pro Tag oder Monat
- Premium: höheres Tages- oder Monatslimit
- Dev/Beta: eigenes internes Testlimit
- IP-Fallback nur, wenn kein stabiler User vorhanden ist
- KI-Chat später separat limitieren

Limits können request-basiert oder zeichenbasiert sein.

Für Übersetzungen ist `character_count` besonders relevant, weil DeepL-Kosten typischerweise mit Textmenge zusammenhängen. Für Phase 1 kann zusätzlich ein einfaches Request-Limit sinnvoll sein.

## Supabase-Ansatz

Der produktive Zielablauf:

1. Flutter sendet eine Übersetzungsanfrage an `translate-word`.
2. Die Edge Function prüft Auth und ermittelt `user_id`.
3. Die Edge Function prüft Tages- oder Monatslimit.
4. Wenn das Limit überschritten ist, antwortet sie kontrolliert mit `quota_exceeded` oder `rate_limit_exceeded`.
5. Nur wenn das Limit frei ist, ruft die Edge Function DeepL auf.
6. Nach Erfolg oder Fehler protokolliert die Function den Versuch.
7. Flutter setzt lokal den Status auf `translated` oder `failed`.

Die Edge Function sollte keine vollständigen sensiblen Texte loggen. Für Kostenkontrolle reichen typischerweise Anzahl, Zeichenmenge, Status und Nutzerbezug.

## Offline-First-Bezug

Usage Tracking betrifft nur Online-Übersetzungen.

Der lokale Lernflow bleibt unabhängig:

- ohne Internet bleiben Wörter `pending` oder `failed`
- Lernen bleibt lokal möglich
- SQLite bleibt Hauptquelle für Wörter und Lernstatus
- SRS-Modi werden nicht von Online-Limits beeinflusst

Wenn ein Nutzer sein Limit erreicht, darf das lokale Lernen nicht blockiert werden. Nur die Online-Übersetzung wird abgelehnt oder später erneut ermöglicht.

## Noch offene Entscheidungen

Vor Umsetzung müssen entschieden werden:

- genaue Free-Limits
- genaue Premium-Limits
- Tageslimit, Monatslimit oder Kombination
- ob Zeichen, Requests oder beides gezählt werden
- ob failed Requests zählen
- ob anonyme Nutzung erlaubt bleibt
- wie Premiumstatus gespeichert und geprüft wird
- ob Stripe, App-Store-Abos oder ein anderes Modell genutzt werden
- ob KI-Chat ein separates Budget bekommt

## Nächster technischer Schritt

Empfohlene Reihenfolge:

1. Supabase-Tabelle oder View für Usage Tracking planen.
2. Auth/User-Zuordnung für `translate-word` finalisieren.
3. Edge Function um echte Limitprüfung erweitern.
4. Usage-Einträge nach Erfolg und Fehler kontrolliert schreiben.
5. Flutter-Fehlermeldungen für `rate_limit_exceeded` und `quota_exceeded` sauber anzeigen.
6. Erst danach KI-Chat-API nach gleichem Sicherheitsmodell anbinden.
