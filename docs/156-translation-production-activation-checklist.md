# Translation Production Activation Checklist

## Ausgangslage

Der lokale Offline-first Flow funktioniert. Lokale Wörter werden lokal gespeichert, und die manuelle Verarbeitung von `pending`- und `failed`-Übersetzungen ist vorbereitet.

Vorhanden:

- `SupabaseTranslationClient`
- `SupabaseEdgeFunctionCaller`
- Supabase Edge Function `translate-word`
- `FakeTranslationClient` als Default

Die echte produktive Online-Übersetzung ist noch nicht aktiviert.

## Noch nicht produktiv aktiv

- Supabase-Modus ist noch nicht automatisch aktiv.
- Keine automatische Übersetzung beim Import.
- Keine automatische Übersetzung beim App-Start.
- Kein echter DeepL-Key im Repository.
- Kein UI-Schalter für produktive Aktivierung.
- Keine automatische Kostenverursachung im Hintergrund.

## Voraussetzungen für Aktivierung

- [ ] Supabase CLI ist eingerichtet.
- [ ] Supabase-Projekt ist festgelegt.
- [ ] Edge Function `translate-word` ist deployed.
- [ ] `DEEPL_API_KEY` ist als Supabase Secret gesetzt.
- [ ] Optional `DEEPL_API_BASE_URL` ist als Supabase Secret gesetzt.
- [ ] Testrequest gegen deployed Function war erfolgreich.
- [ ] Flutter-App kann Supabase Functions erreichen.
- [ ] Fehlerfälle wurden manuell geprüft.

## Sicherheitsanforderungen

- [ ] Kein Secret in Git.
- [ ] Kein Secret in Flutter.
- [ ] Auth vor Produktion prüfen.
- [ ] Rate Limiting einplanen.
- [ ] Premium- oder Nutzerlimits einplanen.
- [ ] Missbrauchsschutz einplanen.
- [ ] Sensible Texte nicht unnötig loggen.
- [ ] Fehler kontrolliert und ohne Secret-Leak zurückgeben.

## Funktionale Anforderungen

- [ ] `pending -> translated` bei erfolgreicher Übersetzung.
- [ ] `pending -> failed` bei Fehler.
- [ ] Failed Retry bleibt manuell.
- [ ] Offline bleibt nutzbar.
- [ ] Keine Endlosschleife.
- [ ] Keine automatische Hintergrundverarbeitung ohne explizite Aktivierung.
- [ ] Lokaler Lernflow bleibt unabhängig von Online-Übersetzung.

## Testplan vor Aktivierung

- [ ] `flutter test`
- [ ] lokaler Edge Function Test per `curl`
- [ ] deployed Edge Function Test per `curl`
- [ ] App-Test mit `SupabaseTranslationClient`
- [ ] Test ohne Internet
- [ ] Test mit ungültiger Antwort
- [ ] Test mit fehlendem Secret
- [ ] Test mit DeepL-Fehlerstatus
- [ ] Test, dass Fake weiterhin Default bleibt

## Aktivierungsstrategie

Empfohlen:

1. Nur Entwicklungsmodus.
2. Interner Test.
3. Begrenzter Beta-Test.
4. Produktive Freischaltung.

Automatische Übersetzung sollte erst später geprüft werden und nur mit klaren Limits, Rate Limiting und Kostenkontrolle.

## Bezug zur späteren KI-Chatfunktion

Für eine spätere KI-Chatfunktion gilt dieselbe Sicherheitslogik:

- API-Keys bleiben serverseitig.
- Flutter ruft nur eigene gesicherte Endpunkte auf.
- Rate Limits und Premiumstatus werden noch wichtiger.
- Logging muss besonders vorsichtig mit Nutzereingaben umgehen.
