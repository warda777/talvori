# Browser-Button Und Browser-Return

Stand: 2026-05-22

## Entscheidung

Der Browser-Return zur zuletzt geteilten Safari-/Chrome-/Brave-Seite ist
deaktiviert. Talvori versucht nicht mehr, externe Browserseiten zu merken,
zurueckzuverfolgen oder ueber Share-Diagnose/Preprocessing zu rekonstruieren.

Gruende:

- Safari JavaScript Preprocessing und `sourceUrl`-Pfade hatten wiederholt
  native iOS-`EXC_BAD_ACCESS`-Crashes ausgeloest.
- Talvori kann und soll keine Browser-Historie auslesen.
- Der Home-Button soll ein stabiler, einfacher Einstieg in den externen Browser
  sein.

## Aktives Verhalten

Der Home-Browser-Button oeffnet eine kleine Dark-Neon-Auswahl:

- Standardbrowser
- Chrome
- Brave

Alle Optionen oeffnen eine konkrete URL. Wenn eine lokal gespeicherte
`WordSource.sourceUrl` vorhanden ist, wird die neueste Quelle verwendet. Wenn
keine Quelle vorhanden ist, nutzt Talvori die lokal gespeicherte eigene
Startseite. Ohne eigene Startseite gilt vorerst die neutrale Platzhalter-
Startseite `https://www.bbc.com`. Es wird keine letzte externe Browserseite
gesucht und keine Browser-Historie gelesen.

Unter den drei Browseroptionen gibt es die abgesetzte Aktion „Eigene Webseite
hinterlegen“. Sie speichert lokal in SharedPreferences unter
`talvori_browser_custom_start_url_v1`, welche Webseite als Startseite verwendet
wird. Eingaben ohne Schema, zum Beispiel `bbc.com`, werden zu
`https://bbc.com` normalisiert. Erlaubt sind nur `http` und `https`; leere oder
ungueltige Eingaben werden nicht gespeichert.

### Standardbrowser

Standardbrowser nutzt `url_launcher` mit der normalen HTTPS-URL. iOS/Android
oeffnen dadurch den aktuell eingestellten Systemstandardbrowser, zum Beispiel
Brave oder Safari.

### Safari

Safari wird nicht als eigene technische Option erzwungen. Wenn Safari auf dem
Geraet als Standardbrowser eingestellt ist, oeffnet sich Safari ueber die Option
„Standardbrowser“.

### Chrome

Chrome versucht auf iOS zuerst das Chrome-Scheme
`googlechromes://www.bbc.com` beziehungsweise dieselbe Ziel-URL mit Chrome-
Scheme. Wenn Chrome nicht verfuegbar ist oder der
Scheme-Start fehlschlaegt, faellt Talvori auf die normale HTTPS-URL und damit
den Standardbrowser zurueck.

`ios/Runner/Info.plist` enthaelt dafuer `LSApplicationQueriesSchemes` fuer:

- `googlechrome`
- `googlechromes`
- `brave`

### Brave

Brave versucht auf iOS zuerst das Scheme `brave://open-url?url=...`. Wenn Brave
nicht verfuegbar ist oder der Scheme-Start fehlschlaegt, zeigt Talvori einen
Dark-Neon-Hinweis und faellt auf die normale HTTPS-URL und damit den
Standardbrowser zurueck.

Es gibt keinen Talvori-Leser als Ziel des Home-Browser-Buttons.

## Deaktiviert

Deaktiviert oder entfernt sind:

- Talvori-Leser/WebView als Home-Browser-Ziel
- Missing-URL-Bottom-Sheet
- Clipboard-URL-Speicherung
- BrowserReturn zur letzten Seite
- BrowserReturnService
- ReaderBrowserService
- Profil-Auswahl „Browser oeffnen mit“
- Profil-Auswahl fuer zusaetzliche Drittbrowser
- Safari JavaScript Preprocessing
- Share-Diagnose im Start-/Resume-Pfad
- EventChannel-Pushes fuer BrowserReturn
- SceneDelegate-Eingriffe

## Share-Import

Der stabile Text-Share bleibt aktiv:

- iOS Share Extension fuer Textimport
- Android Share Import
- Import nach „Meine Woerter“
- automatische Uebersetzung ueber Supabase `translate-word`

Der Share-Import startet keine BrowserReturn-Speicherung und nutzt keine
Browser-Diagnose im Hot Path.

## Grenzen

- Keine Browser-Historie
- Kein Tab-Tracking
- Kein harter Browser-Zwang ohne kontrollierten Fallback
- Keine Cloud-Speicherung fuer Browserdaten
- Keine Secrets
- Keine SRS-Aenderung
