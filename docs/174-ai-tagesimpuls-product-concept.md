# Tagesimpuls Product Concept

## Produktziel

Der Tagesimpuls ist ein appweites Lernfeature, bei dem der Nutzer 3-5 Wörter sammelt. Aus diesen Wörtern erzeugt die KI kurze natürliche Nachrichten, die sich wie echte Messenger- oder Alltagsnachrichten anfühlen.

Ziel ist beiläufiges Wiedererkennen im Alltag: Der Nutzer soll schwierige oder wichtige Wörter später unerwartet im Kontext lesen, idealerweise wie eine kurze WhatsApp-ähnliche Nachricht auf dem Sperrbildschirm. Tagesimpuls ergänzt SRS, ersetzt es aber nicht.

## HomeScreen-Rolle

Der HomeScreen bleibt clean. Er zeigt primär den Auswahlstatus, zum Beispiel `0/5`, und bietet einen Einstieg in die Tagesimpuls-Verwaltung.

Eine große dauerhafte Tagesimpuls-Karte auf dem HomeScreen ist nicht das Hauptziel. Später reicht ein kleines Bottom Sheet oder ein Dialog, um Folgendes zu verwalten:

- ausgewählte Wörter
- Anzahl Tagesimpulse pro Tag
- Tagesimpuls planen
- Auswahl leeren

## Appweite Verfügbarkeit

Die Tagesimpuls-Auswahl darf nicht nur an den HomeScreen gekoppelt sein. Sie soll appweit verfügbar sein:

- HomeScreen: Auswahlstatus und Einstieg
- Lernmodus: direkter Add-Button auf der Karte
- Wortdetailseite: später optional ebenfalls ein Add-Button

So kann der Nutzer ein Wort genau dann hinzufügen, wenn es auffällt oder schwerfällt.

## Globale Tagesimpuls-Auswahl

Die Auswahl ist ein globaler lokaler Zustand.

Regeln:

- maximal 5 Wörter
- lokal gespeichert
- appweit verfügbar
- Counter zeigt globalen Stand, z. B. `0/5`
- Duplikate werden verhindert
- Auswahl kann geleert werden

Wenn der Nutzer Wörter manuell auswählt, werden genau diese Wörter bevorzugt für den nächsten Tagesimpuls verwendet.

## Automatische Wortauswahl

Wenn keine manuelle Auswahl vorhanden ist, kann Talvori später automatisch geeignete Wörter vorschlagen. Mögliche Quellen:

- schwierige Wörter
- zuletzt falsch beantwortete Wörter
- Wörter aus S1-S3
- neue Wörter aus „Meine Wörter“
- Favoriten
- Wörter mit unsicherem Lernstatus

Diese automatische Auswahl ist nur Grundlage für den Impuls und verändert keinen SRS-Fortschritt. Ohne bewusste Nutzerkonfiguration darf daraus maximal 1 Nachricht pro Tag entstehen.

## Anzahl Tagesimpulse Pro Tag

Die spätere Einstellung soll begrenzt bleiben:

- 1 pro Tag als Standard
- 2 pro Tag
- 3 pro Tag
- 4 pro Tag
- 5 pro Tag

Mehr als 1 automatische Nachricht pro Tag darf nie ohne bewusste Nutzerentscheidung passieren. 2-5 Tagesimpulse pro Tag sind nur erlaubt, wenn der Nutzer dies aktiv einstellt. Später kann hier eine Free-/Premium-Unterscheidung greifen.

## KI-Nachrichten

Die KI erzeugt kurze natürliche Nachrichten mit den ausgewählten oder automatisch vorgeschlagenen Wörtern.

Eigenschaften:

- natürlich formuliert
- kurz genug für eine Benachrichtigung
- verständlich für Sprachlernende
- keine trockene Vokabelliste
- keine allgemeine Chat-Antwort

Wenn Übersetzungen vorhanden sind, können sie als Kontext mitgegeben werden. Die KI-Anfrage erfolgt nicht automatisch beim Hinzufügen eines Wortes.

## Kostenstrategie

Aus Kostengründen sollten 1-5 Nachrichten möglichst in einem KI-Aufruf erzeugt werden. Ein einzelner Request mit mehreren Nachrichten spart Systemprompt- und Kontext-Overhead gegenüber mehreren einzelnen Requests.

Die Kosten hängen hauptsächlich an der Tokenmenge, nicht nur an der Anzahl Requests. Trotzdem sind mehrere einzelne Requests meist ungünstiger, weil Systemprompt und Kontext mehrfach gesendet werden.

Ziel für spätere Generierung:

- ein Planungslauf
- ein KI-Request
- strukturierte JSON-Liste mit 1-5 Nachrichten

Beispiel-Output:

```json
[
  { "slot": "morning", "message": "..." },
  { "slot": "afternoon", "message": "..." },
  { "slot": "evening", "message": "..." }
]
```

## Backend-Strategie

Langfristig läuft die Generierung über Supabase Edge Function. Flutter enthält keine KI-Secrets. Supabase hält API-Keys serverseitig.

Eine spätere spezialisierte Function könnte heißen:

- `generate-daily-impulses`

Usage Tracking und Limits gelten auch für Tagesimpuls. Die bestehende `ai-chat`-Function kann als technische Referenz dienen, ist aber nicht zwingend die finale Produkt-Function.

## Notification-Strategie

### Phase A: Lokale Notification

Die App erzeugt oder lädt Tagesimpuls-Nachrichten und plant lokale Notifications auf dem Gerät. Das ist der einfachere MVP.

Voraussetzungen:

- Nutzer erteilt Notification-Berechtigung
- App plant lokale Zeitpunkte
- Lernen bleibt offline-first
- keine Push-Server-Komplexität

### Phase B: Server-Push

Später kann ein Backend die Zustellung steuern und Push über APNs/FCM versenden. Das ist aufwendiger, aber besser für echte tägliche Zustellung, Premium-Funktionen, Retention und Coach-Logik.

## Tagesplanung

Wenn 1 Nachricht geplant ist, kann der Zeitpunkt zufällig innerhalb eines sinnvollen Tagesfensters liegen oder vom Nutzer gewählt werden.

Wenn mehrere Nachrichten geplant sind, werden sie über Tagesfenster verteilt:

- morgens
- mittags
- nachmittags
- abends
- nachts nur optional und nicht standardmäßig

Ohne explizite Einstellung darf die App keine übermäßigen Benachrichtigungen erzeugen.

## Offline-First

Die Auswahl der Wörter funktioniert lokal. KI-Generierung und spätere Push-Zustellung benötigen Internet. Wenn der Nutzer offline ist, bleibt die Auswahl erhalten und Lernen funktioniert weiter.

Lokales Lernen bleibt unabhängig:

- SRS funktioniert ohne KI
- Tagesimpuls-Auswahl bleibt lokal
- keine Online-Pflicht für Lernmodus oder Wortdetail

## Datenschutz

Nur notwendige Wörter und minimale Kontextdaten werden an die KI gesendet. Vollständige Lernhistorien werden nicht ungefiltert übertragen.

Grundsätze:

- keine Secrets in Flutter
- keine Benachrichtigung ohne Zustimmung
- Nutzer kann Tagesimpuls deaktivieren
- keine sensiblen Texte unnötig loggen
- serverseitige API-Keys bleiben geschützt

## Abgrenzung

Tagesimpuls ist:

- kein allgemeiner Chat
- kein automatisches Sammeln ohne nachvollziehbare Logik
- kein Ersatz für SRS
- kein Spam-Reminder
- kein Push ohne Berechtigung
- keine automatische Progression

Mehr als 1 Nachricht pro Tag darf nur durch bewusste Nutzerentscheidung entstehen.

## Umsetzung in Phasen

### Phase 1

- globale Tagesimpuls-Auswahl
- Add-Button im Lernmodus
- Counter `0/5`
- Favoriten/Quick-Actions

### Phase 2

- Backend-Strategie dokumentieren
- `generate-daily-impulses` Edge Function planen
- 1-5 Nachrichten in einem Request generieren

### Phase 3

- manuelle Vorschau/Planung in der App
- lokale Notification planen

### Phase 4

- automatische Tagesplanung
- Nutzer-Einstellung 1-5 Nachrichten
- automatische Wortauswahl nur max. 1 Nachricht ohne manuelle Auswahl

### Phase 5

- Server-Push über APNs/FCM
- Premium-/Free-Limits
- Usage Tracking produktiv

## Nächster Technischer Schritt

Als nächstes sollte die Edge Function `generate-daily-impulses` geplant werden:

- Request-/Response-Format definieren
- 1-5 Nachrichten in einem strukturierten Output zurückgeben
- Usage Tracking und Limits berücksichtigen
- noch keine Notifications implementieren

Danach kann die lokale Notification-Scheduling-Implementierung separat geplant werden.
