# Tagesimpuls Daily Impulse Client State

## Ausgangslage

Die Supabase Edge Function `generate-daily-impulses` existiert und wurde remote erfolgreich getestet. Sie erzeugt aus ausgewählten Wörtern 1 bis 5 kurze Messenger-artige Tagesimpuls-Nachrichten in einem KI-Request.

Flutter enthält keine Secrets. Die globale Tagesimpuls-Auswahl bleibt lokal und ist appweit nutzbar.

## Neuer Flutter Client

Neu vorbereitet wurde ein spezialisierter Tagesimpuls-Client:

- `TagesimpulsAiClient`
- `SupabaseTagesimpulsAiClient`
- `TagesimpulsGenerateRequest`
- `TagesimpulsGeneratedImpulse`
- `TagesimpulsGenerateResult`
- `TagesimpulsAiException`

Der Client ruft die Supabase Edge Function `generate-daily-impulses` über den bestehenden Supabase Function Caller auf. Er kennt keine API-Keys und enthält keine KI-Secrets.

Der Tagesimpuls-Provider stellt den Function Caller separat bereit. Dadurch kann der echte App-Flow einen `SupabaseTagesimpulsAiClient` mit `SupabaseEdgeFunctionCaller` nutzen, während Tests denselben Provider mit einem Fake Function Caller überschreiben können.

## Fehlerbehandlung

Der Client normalisiert Edge-Function- und Provider-Fehler auf appseitige Diagnosezustände:

- `aiClientNotConfigured`
- `functionCallFailed`
- `quotaExceeded`
- `invalidAiResponse`
- `noImpulsesReturned`
- `notEnoughWords`
- `wordsRequired`
- `generationSucceeded`

Die UI mappt diese Zustände auf konkrete deutsche Hinweise. Dadurch ist unterscheidbar, ob die Edge Function nicht erreichbar ist, das Limit erreicht wurde, die KI-Antwort nicht parsebar war oder keine Impulse zurückkamen.

`functionCallFailed` bedeutet appseitig: Der Flutter-Aufruf der Supabase Function lieferte keine verwertbare Function-Response. Edge-Function-Fehler mit JSON-Body, zum Beispiel `{ "error": "quota_exceeded" }`, werden vom gemeinsamen `SupabaseEdgeFunctionCaller` aus `FunctionException.details` zurück in eine Map normalisiert, damit der Tagesimpuls-Client sie konkret mappen kann.

Der Client ruft exakt `generate-daily-impulses` auf und sendet:

- `words` als Liste mit `word` und optional `translation`
- `count`
- `language`
- `style`

Das erwartete Request-Format ist:

```json
{
  "words": [
    { "word": "move", "translation": "bewegen" },
    { "word": "reefs" },
    { "word": "serving" }
  ],
  "count": 1,
  "language": "EN",
  "style": "natural_message"
}
```

Vor dem Senden normalisiert Flutter die ausgewählten Tagesimpuls-Wörter. Zeilenumbrüche werden geglättet, offensichtliche URL-Reste aus importierten Shared-Texten werden entfernt und leere Wörter werden nicht an die Edge Function gesendet. Ein importiertes Feld wie `move https://www.bbc.com/...` wird dadurch als `move` übertragen.

`words_required` wird als `wordsRequired` gemappt. Wenn lokal mindestens 3 Wörter ausgewählt sind, aber nach der Payload-Normalisierung keine gültigen Wörter übrig bleiben oder die Edge Function `words_required` meldet, zeigt die App nicht den normalen Mindestwort-Hinweis, sondern den konkreten Datenhinweis `Tagesimpuls-Wörter konnten nicht vorbereitet werden.`

Sichere Debug-Logs enthalten nur Function-Name, Payload-Keys, Response-Keys, Exception-Typ und gekürzte Fehlermeldungen. API-Keys, Tokens und vollständige Prompts werden nicht geloggt.

Die erwartete Response bleibt:

```json
{
  "impulses": [
    {
      "slot": "morning",
      "message": "...",
      "usedWords": ["move"]
    }
  ]
}
```

`usedWords` wird tolerant behandelt, falls die Function es ausnahmsweise nicht liefert. `message` bleibt Pflicht.

## Planungsflow

Der `TagesimpulsMessageController` verwaltet den App-seitigen Generierungszustand:

- ausgewählte Wörter aus der globalen Tagesimpuls-Auswahl
- Anzahl `1` bis `5`
- Standard `1`
- Ladezustand
- Fehlerzustand
- generierte Impulse im lokalen State

Die Generierung wird nicht beim App-Start und nicht beim Hinzufügen eines Wortes ausgelöst. Im aktuellen Selbstläufer-Flow passiert sie intern nur, wenn der Nutzer Tagesimpuls-Einstellungen aktiv nutzt und genug Wörter vorhanden sind.

## UI-Stand

Home bleibt clean. Der HomeScreen zeigt weiterhin primär den Auswahlstatus, zum Beispiel `0/5`, und bietet nur einen kompakten Einstieg.

Die Tagesimpuls-Verwaltung zeigt:

- ausgewählte Wörter als Chips
- Counter `0/5`
- Hinweis bei zu wenigen Wörtern
- bewusste Auswahl der Anzahl `1` bis `5`
- Hinweis, dass mehrere Impulse eine bewusste Entscheidung sind
- Status zu Generierung/Planung

Es gibt keine große dauerhafte Tagesimpuls-Karte auf Home.
KI-Texte werden nicht als Vorschau angezeigt; sie sind für lokale Notifications gedacht.

## Regeln

- Für manuelle Vorschau werden mindestens 3 Wörter erwartet.
- Maximal 5 Wörter können ausgewählt sein.
- `count` darf 1 bis 5 sein.
- Standard ist 1.
- 2 bis 5 Impulse entstehen nur durch bewusste Auswahl des Nutzers.
- Automatische Wortauswahl ohne Nutzerwörter ist noch nicht implementiert.

## Bewusst nicht umgesetzt

- Keine Notification-Implementierung
- Keine Push-Funktion
- Keine automatische KI-Anfrage beim App-Start
- Keine automatische KI-Anfrage beim Hinzufügen eines Wortes
- Kein Secret in Flutter
- Keine Supabase-Datenbank-Logik im lokalen Flow
- Keine SRS-Änderung

## Tests

Abgedeckt sind:

- Client sendet `words`, `count`, `language` und `style`
- Client parst `impulses`
- Client behandelt `quotaExceeded`
- Client behandelt ungültige KI-Antworten
- Client behandelt leere Impulslisten
- Client behandelt Function-Call-Fehler
- Client behandelt fehlende KI-Konfiguration
- Supabase Function Caller übernimmt JSON-Fehlerdetails aus `FunctionException`
- Provider baut den Tagesimpuls-Client mit injiziertem Function Caller
- Controller startet mit `count = 1`
- Controller erlaubt `count` 1 bis 5
- Controller generiert nicht automatisch beim Erstellen
- UI zeigt Hinweis bei zu wenigen Wörtern
- UI zeigt konkrete Fehlerstatus
- keine echten Netzwerkaufrufe in Tests

## Nächster Schritt

Als nächstes sollte die lokale Notification-Scheduling-Implementierung geplant werden. Dabei bleibt wichtig: keine automatische Generierung ohne Nutzerentscheidung und keine Push-/Notification-Freischaltung ohne Berechtigungs- und Kostenstrategie.
