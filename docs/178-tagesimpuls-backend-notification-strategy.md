# Tagesimpuls Backend Notification Strategy

## Zielbild

Tagesimpuls soll langfristig nicht primär eine große HomeScreen-Karte sein, sondern eine kurze Messenger-/WhatsApp-ähnliche Nachricht, die der Nutzer im Alltag beiläufig liest.

Der Nutzer sammelt 3-5 Wörter oder Talvori wählt später automatisch geeignete Wörter aus. Die KI erzeugt daraus natürliche kurze Nachrichten. Diese Nachrichten sollen später per lokaler Notification oder serverseitigem Push auf dem Sperrbildschirm erscheinen.

## Grundregeln

- Standard ist maximal 1 Tagesimpuls pro Tag.
- Mehr als 1 Nachricht pro Tag ist nur nach bewusster Nutzerentscheidung erlaubt.
- Der Nutzer kann später 1, 2, 3, 4 oder 5 Tagesimpulse pro Tag einstellen.
- Ohne manuelle Auswahl oder explizite Einstellung darf automatische Wortauswahl maximal 1 Nachricht pro Tag erzeugen.
- Tagesimpuls verändert keinen SRS-Fortschritt.

## Auswahlstrategie

### Manuelle Auswahl

Wenn der Nutzer Wörter auswählt, werden genau diese Wörter bevorzugt. Die globale Tagesimpuls-Auswahl bleibt die direkte Steuerung:

- maximal 5 Wörter
- Duplikate verhindert
- lokal gespeichert
- appweit nutzbar

### Automatische Auswahl

Wenn keine manuelle Auswahl vorhanden ist, kann Talvori später Wörter automatisch vorschlagen. Mögliche Quellen:

- schwierige Wörter
- zuletzt falsch beantwortete Wörter
- Wörter aus S1-S3
- neue Wörter aus „Meine Wörter“
- Favoriten
- Wörter mit unsicherem Lernstatus

Die automatische Auswahl ist nur eine Grundlage für die Nachricht. Sie schreibt keine Progress-Werte und startet keine SRS-Session.

## Anzahl Tagesimpulse Pro Tag

Geplante Einstellung:

- 1 pro Tag: Standard
- 2 pro Tag: bewusst aktivierbar
- 3 pro Tag: bewusst aktivierbar
- 4 pro Tag: bewusst aktivierbar
- 5 pro Tag: bewusst aktivierbar

Aus Kosten- und Nutzerfreundlichkeitsgründen bleibt die Obergrenze bei 5. Später kann eine Free-/Premium-Logik entscheiden, welche Stufen verfügbar sind.

## Kostenstrategie

Tagesimpulse sollen möglichst effizient generiert werden.

Statt für jede Notification einen eigenen KI-Request zu senden, sollte ein Planungslauf 1-5 Nachrichten in einem Request erzeugen. Das spart Systemprompt- und Kontext-Overhead.

Wichtig:

- Kosten hängen hauptsächlich an Tokenmenge.
- Mehrere einzelne Requests sind trotzdem oft teurer, weil Systemprompt und Kontext mehrfach gesendet werden.
- Ein einzelner strukturierter Request ist besser kontrollierbar.
- Usage Tracking und Limits müssen pro Planungslauf und Feature greifen.

## Geplantes Request-/Response-Modell

Spätere Edge Function:

- `generate-daily-impulses`

Beispiel-Request:

```json
{
  "words": [
    { "word": "move", "translation": "bewegen" },
    { "word": "superstar", "translation": "Superstar" },
    { "word": "destroyed", "translation": "zerstört" }
  ],
  "count": 3,
  "language": "EN",
  "style": "natural_message"
}
```

Beispiel-Response:

```json
[
  { "slot": "morning", "message": "..." },
  { "slot": "afternoon", "message": "..." },
  { "slot": "evening", "message": "..." }
]
```

Die Function sollte strukturierte Antworten validieren und ungültige KI-Ausgaben kontrolliert ablehnen.

## Backend-Strategie

Die Generierung läuft langfristig servergestützt:

- Flutter sendet nur Wörter, Anzahl und Einstellungen.
- Supabase Edge Function hält KI-Secrets serverseitig.
- Flutter enthält keine API-Keys.
- Usage Tracking und Limits gelten auch für Tagesimpuls.
- Rate Limits und Premiumstatus werden serverseitig geprüft.

Die bestehende AI-Chat-Function ist ein Vorbild für sichere Provider-Anbindung. Tagesimpuls sollte jedoch eine eigene spezialisierte Function erhalten, weil Request, Output und Kostenkontrolle enger definiert sind.

## Notification-Strategie

### Phase A: Lokale Notification

Die App erzeugt oder lädt Tagesimpuls-Nachrichten und plant lokale Notifications auf dem Gerät.

Vorteile:

- einfacher MVP
- keine Push-Server-Komplexität
- offline-first bleibt verständlich
- Nutzer kann Berechtigung lokal steuern

Voraussetzungen:

- Notification-Berechtigung
- lokale Planung der Zeitpunkte
- Deaktivieren jederzeit möglich

### Phase B: Server-Push

Später kann Supabase oder ein eigener Backend-Layer die Zustellung steuern.

Möglicher Ablauf:

- Backend plant Tagesimpulse
- Push über APNs/FCM
- Limits/Premiumstatus serverseitig
- bessere tägliche Zustellung

Diese Phase ist produktnäher, aber deutlich aufwendiger. Sie ist eher für Beta, Premium oder Coach-Funktionen geeignet.

## Tagesplanung

Bei 1 Nachricht:

- zufälliger sinnvoller Zeitpunkt
- oder vom Nutzer gewählter Zeitpunkt

Bei mehreren Nachrichten:

- morgens
- mittags
- nachmittags
- abends
- nachts standardmäßig nicht senden

Ohne explizite Einstellung bleibt die App zurückhaltend und erzeugt keine übermäßige Benachrichtigung.

## Datenschutz

Es werden nur notwendige Wörter und minimale Kontextdaten gesendet.

Nicht senden:

- vollständige Lernhistorien
- unnötige personenbezogene Daten
- Secrets
- Rohdaten ohne Zweck

Der Nutzer muss Benachrichtigungen aktiv erlauben und Tagesimpuls deaktivieren können.

## Abgrenzung

Tagesimpuls ist kein allgemeiner Chat und kein Ersatz für SRS.

Nicht Teil dieser Strategie:

- Push ohne Berechtigung
- automatische Mehrfachnachrichten ohne Nutzerentscheidung
- automatische Progressänderungen
- unlimitierte KI-Anfragen
- vollständige Lernhistorien im Prompt

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

Als nächstes sollte `generate-daily-impulses` fachlich und technisch geplant werden:

- Request-/Response-Format finalisieren
- Output-Validierung definieren
- Usage Tracking für `daily_impulse` planen
- Limits für Free/Beta/Premium skizzieren
- noch keine Notification-Implementierung bauen
