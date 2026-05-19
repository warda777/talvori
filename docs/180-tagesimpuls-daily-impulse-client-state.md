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

## Fehlerbehandlung

Der Client behandelt kontrollierte Fehlercodes:

- `ai_not_configured`
- `quota_exceeded`
- `ai_rate_limited`
- `ai_invalid_response`
- `ai_request_failed`
- `ai_auth_failed`
- `invalid_count`
- `words_required`

Die UI mappt diese Codes auf verständliche deutsche Hinweise.

## Planungs-/Vorschau-Flow

Der neue `TagesimpulsMessageController` verwaltet den App-seitigen Vorschauzustand:

- ausgewählte Wörter aus der globalen Tagesimpuls-Auswahl
- Anzahl `1` bis `5`
- Standard `1`
- Ladezustand
- Fehlerzustand
- generierte Impulse im lokalen UI-State

Die Generierung wird nur manuell durch den Button „Tagesimpulse vorbereiten“ ausgelöst.

## UI-Stand

Home bleibt clean. Der HomeScreen zeigt weiterhin primär den Auswahlstatus, zum Beispiel `0/5`, und bietet nur einen kompakten Einstieg.

Die Tagesimpuls-Verwaltung zeigt:

- ausgewählte Wörter als Chips
- Counter `0/5`
- Hinweis bei zu wenigen Wörtern
- bewusste Auswahl der Anzahl `1` bis `5`
- Hinweis, dass mehrere Impulse eine bewusste Entscheidung sind
- Button „Tagesimpulse vorbereiten“
- generierte Impulse mit Slot, Nachricht und verwendeten Wörtern

Es gibt keine große dauerhafte Tagesimpuls-Karte auf Home.

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
- Client behandelt `quota_exceeded`
- Client behandelt ungültige KI-Antworten
- Controller startet mit `count = 1`
- Controller erlaubt `count` 1 bis 5
- Controller generiert nur manuell
- UI zeigt Hinweis bei zu wenigen Wörtern
- UI zeigt generierte Impulse
- keine echten Netzwerkaufrufe in Tests

## Nächster Schritt

Als nächstes sollte die lokale Notification-Scheduling-Implementierung geplant werden. Dabei bleibt wichtig: keine automatische Generierung ohne Nutzerentscheidung und keine Push-/Notification-Freischaltung ohne Berechtigungs- und Kostenstrategie.
