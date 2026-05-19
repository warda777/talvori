# Translate Word Auth Rate Limit State

## Ausgangslage

Die Supabase Edge Function `translate-word` ist deployed, gehärtet und wird für lokale manuelle Übersetzungen vorbereitet.

Der DeepL-Key bleibt serverseitig als Supabase Secret. Flutter enthält keine Secrets und der lokale Offline-Flow bleibt die Hauptquelle für Wörter, Lernfortschritt und Translation-Status.

## Auth-Vorbereitung

Die Function liest jetzt den `Authorization`-Header und bereitet daraus einen internen Auth-Kontext vor.

Aktuell wird der Header noch nicht produktiv validiert. Das ist bewusst so, damit lokale Entwicklungs- und Edge-Function-Tests nicht blockiert werden, solange die finale Auth-/User-Struktur noch nicht feststeht.

Vor produktiver Freigabe muss ergänzt werden:

- Supabase JWT validieren
- `user_id` aus dem Token ableiten
- ungültige oder abgelaufene Tokens ablehnen
- Premium-/Entitlement-Informationen für Quota-Prüfungen anbinden
- Auth verpflichtend machen

Der vorbereitete Fehlercode für verpflichtende Auth lautet:

```json
{
  "error": "auth_required"
}
```

## Entwicklungsmodus

Der Entwicklungsmodus bleibt nutzbar.

Standardmäßig blockiert die Function nicht hart, wenn kein Auth-Header vorhanden ist. Eine spätere Pflichtprüfung kann kontrolliert über die Function-Logik und Runtime-Konfiguration aktiviert werden, sobald Auth, Limits und Produktivregeln final sind.

## Rate-Limit-Vorbereitung

Die Function enthält jetzt eine eigene Rate-Limit-Prüfstelle.

Sie blockiert aktuell noch nicht, sondern dokumentiert den späteren Zielpfad:

- Limitierung pro `user_id`
- IP-Fallback für anonyme oder frühe Entwicklungsrequests
- Tageslimits
- Premium-/Nutzerlimits
- Missbrauchsschutz
- gemeinsame Strategie für spätere KI-Chat-Edge-Functions

Vorbereitete Fehlercodes:

```json
{
  "error": "rate_limit_exceeded"
}
```

```json
{
  "error": "quota_exceeded"
}
```

## Warum noch nicht aktiv?

Eine echte produktive Limitierung braucht eine klare Persistenz- und Auth-Entscheidung.

Aktuell wurde bewusst keine Supabase-Datenbank-Migration ergänzt und keine harte Auth-Pflicht aktiviert. Dadurch bleiben die bestehenden Entwicklungs-, Simulator- und manuellen Edge-Function-Tests stabil.

## Response-Kompatibilität

Die erfolgreiche Response bleibt unverändert:

```json
{
  "translation": "Haus"
}
```

Fehlerresponses bleiben kompatibel:

```json
{
  "error": "..."
}
```

Zusätzliche Fehlercodes sind vorbereitet, ohne den bestehenden Flutter-Client zu brechen.

## Nicht geändert

- kein Secret in Git
- kein Secret in Flutter
- keine automatische Übersetzung beim Import
- keine automatische Übersetzung beim App-Start
- keine Hintergrundverarbeitung
- keine Supabase-Datenbank-Migration
- keine Änderung am lokalen SQLite-/Offline-Flow

## Vor produktiver Veröffentlichung

Vor echter Freigabe müssen noch erledigt werden:

- Auth verpflichtend machen
- JWT-Verifikation implementieren
- Rate-Limit-Speicher festlegen
- Premium-/Free-Limits definieren
- Kosten- und Missbrauchsschutz testen
- Logging ohne sensible Texte sicherstellen
- deployed Function mit Auth-/Limit-Fehlerfällen testen

## Bezug zur KI-Chatfunktion

Die gleiche Sicherheitslogik gilt später für KI-Chatfunktionen.

Auch dort sollen API-Keys serverseitig bleiben, Requests authentifiziert werden und Rate-/Premiumlimits zentral kontrolliert werden.
