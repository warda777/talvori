# Browser-Return-Flow

Stand: 2026-05-22

## Stabilitätsentscheidung

Der Browser-Return zur zuletzt geteilten Safari-Seite ist vorerst deaktiviert.
Der Ansatz mit Safari JavaScript Preprocessing, `pageUrl`/`sourceUrl` im
iOS-Share-Payload und BrowserReturn-Speicherung aus dem Share-Import hat
wiederholt native iOS-`EXC_BAD_ACCESS`-Crashes ausgelöst.

Talvori liest keine Browser-Historie und erzeugt keine Fake-Links.

## Aktiver Zustand

Aktiv bleibt:

- iOS Share Extension für stabilen Textimport
- Android Share Import
- Import nach „Meine Wörter“
- automatische Übersetzung über Supabase `translate-word`
- Browser-Button als stabiler Dark-Neon-Hinweis

Deaktiviert ist:

- Safari JavaScript Preprocessing
- `sourceUrl`/`pageUrl`/`title` im iOS-Share-Payload
- BrowserReturn-Speicherung aus iOS Share
- Share-Diagnose im Start-/Resume-Pfad
- iOS EventChannel-Push für Share-Events
- SceneDelegate-Eingriff

## iOS Share Extension

Die Extension schreibt nur noch einen einfachen Text-Payload in App Group
UserDefaults:

- `id`
- `text`
- `createdAt`
- `source`
- `type`

Der Runner liest diesen Payload über den bestehenden MethodChannel
`talvori/share`. Es werden nur primitive Werte an Flutter übergeben. Wenn kein
Text vorhanden ist, wird kein BrowserReturn-Versuch gestartet.

## Browser-Button

Der Home-Browser-Button behauptet aktuell nicht mehr, eine letzte Seite öffnen
zu können. Er zeigt den stabilen Hinweis:

> Browser-Rückkehr wird vorbereitet.

## Historischer Befund

Frühere BrowserReturn-Implementierungen speicherten nur eine URL, wenn sie als
Text im Share-Inhalt enthalten war. Es gab keine stabile alte iOS-Funktion, die
bei markiertem Safari-Text automatisch die Ursprungsseite ermittelt hat.

## Nächster möglicher Ansatz

Ein neuer Browser-Return-Versuch sollte als isoliertes Feature neu geplant
werden:

- keine Writes im App-Start-/Resume-Pfad
- keine native Debug-Diagnose im Hot Path
- keine EventChannel-Pushes
- kein SceneDelegate-Eingriff
- zuerst kleiner nativer Spike außerhalb des produktiven Share-Imports

## Grenzen

- Keine Browser-Historie
- Kein Tab-Tracking
- Keine Cloud-Speicherung
- Keine Supabase Storage Nutzung
- Keine Secrets
- Keine SRS-Änderung
