# AI Tagesimpuls Message State

## Ausgangslage

Talvori besitzt eine globale lokale Tagesimpuls-Auswahl mit maximal 5 Wörtern. Wörter können auf dem HomeScreen und im lokalen Lernmodus manuell hinzugefügt werden. Die Auswahl bleibt lokal gespeichert und ist appweit lesbar.

Die Produktstrategie wurde auf eine spätere Messenger-/Notification-Logik ausgerichtet: Der Tagesimpuls soll langfristig nicht als große dauerhafte HomeScreen-Karte funktionieren, sondern als kurze natürliche Nachricht außerhalb der App erscheinen.

## Aktueller Stand

Home bleibt bewusst clean. Der HomeScreen zeigt primär den Auswahlstatus, zum Beispiel `0/5`, und bietet einen kompakten Einstieg in die Tagesimpuls-Verwaltung.

Die bestehende Tagesimpuls-Message-UI ist aktuell nur eine manuelle Vorschau- und Planungsfläche. Sie ist kein automatischer Tagesimpuls, keine Push-Funktion und keine verpflichtende Home-Komponente.

Die Aktion heißt:

- „Impuls vorbereiten“

Sie nutzt die ausgewählten Wörter und erstellt daraus manuell eine kurze natürliche Nachricht auf Englisch. Die Nachricht soll sich wie eine echte Alltagsnachricht anfühlen und für Sprachlernende verständlich bleiben.

## Regeln

- Mindestens 3 Wörter müssen ausgewählt sein.
- Maximal 5 Wörter können in der Auswahl liegen.
- Bei weniger als 3 Wörtern erscheint der Hinweis „Wähle mindestens 3 Wörter aus.“
- Die KI-Anfrage wird nur durch den Button ausgelöst.
- Es gibt keine automatische Anfrage beim App-Start.
- Es gibt keine automatische Anfrage beim Hinzufügen eines Wortes.
- Es gibt keine Notification-Planung in diesem Schritt.

## Notification-Strategie

Die aktuelle Vorschau bereitet nur den späteren Produktfluss vor. Langfristig soll eine separate Backend-/Notification-Architektur übernehmen:

- Standard bleibt maximal 1 Tagesimpuls pro Tag.
- 2 bis 5 Impulse pro Tag dürfen nur nach bewusster Nutzerentscheidung entstehen.
- Ohne manuelle Wortauswahl darf automatische Auswahl später höchstens 1 Nachricht pro Tag erzeugen.
- Die spätere Generierung soll möglichst mehrere geplante Nachrichten in einem Backend-Request erzeugen.

## Anzeige

Der Tagesimpuls-Flow zeigt:

- die ausgewählten Wörter
- den Button „Impuls vorbereiten“
- einen Ladezustand
- eine optionale „Impuls-Vorschau“
- verständliche Fehlerhinweise

Der Stil bleibt dunkel/neon und passt zum lokalen Talvori-Design. Die Vorschau ist nicht als große dauerhafte HomeScreen-Fläche gedacht.

## Fehlerfälle

Gemappt werden unter anderem:

- `ai_not_configured` → „KI ist noch nicht konfiguriert.“
- `quota_exceeded` / `ai_rate_limited` → „Limit erreicht oder Anbieter begrenzt Anfrage.“
- `ai_request_failed` / `ai_auth_failed` → „Tagesimpuls konnte nicht erzeugt werden.“
- sonstige Fehler → „Tagesimpuls konnte nicht geladen werden.“

## Offline-first

Die Auswahl der Wörter bleibt lokal und funktioniert offline. Nur das manuelle Vorbereiten der KI-Vorschau benötigt Internet und die Supabase Edge Function.

Lokales Lernen, SRS-Fortschritt und Wortlisten bleiben unabhängig.

## Bewusst nicht umgesetzt

- Keine automatische KI-Anfrage
- Kein Secret in Flutter
- Keine Push-Funktion
- Keine lokale Notification-Planung
- Keine neue Supabase Function
- Keine Supabase-Datenbank-Änderung
- Keine SRS-Änderung
- Keine persistente Historie der generierten Tagesimpulse

## Tests

Abgedeckt sind:

- Hinweis bei weniger als 3 Wörtern
- manuelle KI-Anfrage bei 3 bis 5 Wörtern
- Fake-AI-Client wird im Test verwendet
- generierte Vorschau wird angezeigt
- Fehler wird verständlich angezeigt
- HomeScreen enthält keine große Pflicht-Tagesimpuls-Karte
- keine echten Netzwerkaufrufe in Tests

## Nächster Schritt

Der nächste technische Schritt ist die Planung einer Edge Function `generate-daily-impulses` mit Request-/Response-Format für 1 bis 5 geplante Nachrichten. Erst danach sollte lokale Notification-Planung separat vorbereitet werden.
