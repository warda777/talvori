# AI Tagesimpuls Message State

## Ausgangslage

Talvori besitzt eine globale lokale Tagesimpuls-Auswahl mit maximal 5 Wörtern. Wörter können auf dem HomeScreen und im lokalen Lernmodus manuell hinzugefügt werden. Die Auswahl bleibt lokal gespeichert und ist appweit lesbar.

Die Produktstrategie ist auf eine Messenger-/Notification-Logik ausgerichtet: Der Tagesimpuls soll langfristig nicht als große HomeScreen-Karte funktionieren, sondern als kurze natürliche Nachricht außerhalb der App erscheinen.

## Aktueller Stand

Der Tagesimpuls-Flow ist jetzt als selbstlaufende Einstellung aufgebaut. Standard ist:

- Modus `Automatisch`
- `1` Tagesimpuls pro Tag
- Zeitfenster `Automatisch`

Es gibt keinen zentralen Speichern- oder Planen-Button mehr. Änderungen an Modus, Häufigkeit oder Zeitfenster werden sofort lokal gespeichert. Wenn Tagesimpuls aktiv ist und mindestens 3 Wörter ausgewählt sind, wird die lokale Planung ruhig im Hintergrund aktualisiert.

Home bleibt bewusst clean. Der HomeScreen zeigt primär den Auswahlstatus, zum Beispiel `0/5`, und bietet einen kompakten Einstieg in die Tagesimpuls-Verwaltung.

Der Status der Tagesimpuls-Verwaltung reagiert live auf die globale Wortauswahl. Header-Counter und Planungsbereich lesen aus derselben globalen Tagesimpuls-Auswahl. Wenn Wörter hinzugefügt oder entfernt werden, wird der Hinweis „Füge mindestens 3 Wörter hinzu.“ sofort neu bewertet. Ein Wechsel des Zeitfensters oder der Häufigkeit ist nicht mehr als Refresh nötig.

Alte `notEnoughWords`-Meldungen werden auch dann entfernt, wenn sie vorher als Fehlerstatus gespeichert wurden. Dadurch bleibt kein stale Snapshot im Planungsbereich stehen, sobald die globale Auswahl wieder mindestens 3 Wörter enthält.

Der Tagesimpuls-Planungsbereich hat eine zentrale Statusquelle. Sie leitet aus globaler Auswahl, aktivem Modus, Häufigkeit, Zeitfenster und Planungs-/Fehlerzustand genau eine sichtbare Statusmeldung ab. Der optionale Untertext wiederholt die Statusmeldung nicht.

## Nutzerkontrolle

Der Nutzer kann wählen:

- Modus: `Aus` oder `Automatisch`
- Häufigkeit: `1`, `2`, `3`, `4`, `5`
- Zeitfenster: `Automatisch`, `Morgens`, `Mittags`, `Nachmittags`, `Abends`

`2` bis `5` Tagesimpulse pro Tag entstehen nur durch bewusste Auswahl. Wenn `Aus` gewählt wird, werden geplante lokale Tagesimpuls-Benachrichtigungen gelöscht und es wird keine KI-Anfrage ausgelöst.

## Keine sichtbare KI-Vorschau

KI-Texte werden nicht als Vorschaukarte angezeigt. Es gibt keine sichtbare Karte mit Slot, Nachricht oder `usedWords`.

Der Nutzer sieht:

- ausgewählte Wörter
- Modus
- Häufigkeit
- Zeitfenster
- Status, zum Beispiel „Tagesimpuls ist ausgeschaltet.“, „Benachrichtigungen sind nicht erlaubt.“ oder „Nächster Impuls: heute Nachmittag.“

Die generierten Nachrichten sollen erst als lokale Benachrichtigung sichtbar werden.

## Regeln

- Mindestens 3 manuell ausgewählte Wörter werden benötigt.
- Maximal 5 Wörter können in der Auswahl liegen.
- Bei weniger als 3 Wörtern erscheint „Füge mindestens 3 Wörter hinzu.“
- Automatische Wortauswahl ist noch nicht umgesetzt und wird als späterer Schritt markiert.
- Es gibt keine automatische Anfrage beim App-Start.
- Es gibt keine automatische Anfrage beim Hinzufügen eines Wortes.
- Es gibt keine KI-Anfrage nur durch Hinzufügen oder Entfernen von Tagesimpuls-Wörtern.
- Es gibt keine automatische Mehrfachbenachrichtigung ohne Nutzerentscheidung.
- Der Debug-Test „Tagesimpuls in 10 Sekunden testen“ nutzt immer die aktuelle globale Wortauswahl.
- Der Button „Tagesimpuls in 10 Sekunden testen“ ist nur bei 3 oder mehr aktuell ausgewählten Wörtern aktiv.
- Beim Tippen setzt der echte Debug-Test sofort den Status „Tagesimpuls-Test wird vorbereitet...“.
- Der echte Debug-Test läuft über die zentrale Methode `runRealTagesimpulsTestInTenSeconds`.

## Feedback und Status

Der Flow nutzt primär eine ruhige Statusanzeige unter den Einstellungen. Normale Änderungen wie `1` auf `2` oder `Morgens` auf `Nachmittags` zeigen keine Fehlersnackbar, solange die Einstellung gespeichert werden konnte.

Snackbars werden nur für wichtige bewusste Statuswechsel verwendet:

- „Tagesimpuls ist aktiv.“
- „Benachrichtigungen müssen erlaubt werden.“

Ruhige Statusmeldungen sind unter anderem:

- „Automatisch aktiv · 1 Impuls pro Tag.“
- „Tagesimpuls ist ausgeschaltet.“
- „Nächster Impuls: heute Nachmittag.“
- „Benachrichtigungen sind nicht erlaubt.“
- „Benachrichtigungen konnten noch nicht geplant werden.“
- „Tagesimpuls konnte nicht geplant werden.“
- „Füge mindestens 3 Wörter hinzu.“

Wenn ein Zustand bereits dauerhaft sichtbar ist, wird dieselbe Meldung nicht zusätzlich als Snackbar angezeigt.

Es gibt keine zweite konkurrierende Statusanzeige wie „Füge mindestens 3 Wörter hinzu. Automatische Wortauswahl folgt später.“ mehr. Automatische Wortauswahl kann als kurzer Untertext erscheinen, aber nicht als zweiter Statusblock.

Der echte 10-Sekunden-Test priorisiert seinen Aktionsstatus, damit „wird vorbereitet“ oder „Tagesimpuls-Test geplant.“ nicht sofort durch den Standardstatus überschrieben werden. Während der Test läuft, wird der Button deaktiviert, um Doppel-Auslösungen zu verhindern.

Konkrete Fehlerzustände im echten Test sind:

- „Tagesimpulse konnten nicht erzeugt werden.“
- „Impuls konnte nicht im Postfach gespeichert werden.“
- „Benachrichtigung konnte nicht geplant werden.“

## Offline-first

Die Auswahl der Wörter bleibt lokal und funktioniert offline. Die aktive Planung benötigt Internet, weil dabei die Supabase Edge Function `generate-daily-impulses` genutzt wird.

Lokales Lernen, SRS-Fortschritt und Wortlisten bleiben unabhängig.

## Bewusst nicht umgesetzt

- Kein Server-Push
- Kein APNs/FCM
- Kein Secret in Flutter
- Keine sichtbare KI-Vorschau
- Keine automatische Mehrfachbenachrichtigung
- Keine Supabase-Datenbank-Änderung im lokalen Flow
- Keine SRS-Änderung

## Tests

Abgedeckt sind:

- Standard ist `Automatisch`, `1` pro Tag und Zeitfenster `Automatisch`.
- `Aus` deaktiviert und löscht geplante Benachrichtigungen.
- Häufigkeitsänderung auf `3` persistiert automatisch und plant drei Benachrichtigungen.
- Zeitfensteränderungen werden automatisch übernommen.
- Frequenz- und Zeitfensteränderungen spammen keine Fehlersnackbars.
- `Aus` zeigt keine doppelte identische Snackbar.
- Permission-/Scheduling-Probleme erscheinen als ruhiger Status.
- KI-Texte werden nicht sichtbar als Vorschau angezeigt.
- Wörter bleiben sichtbar und entfernbar.
- Hinweis bei weniger als 3 Wörtern.
- Live-Status wird ohne Zeitfensterwechsel aktualisiert, wenn die Wortauswahl von unter 3 auf mindestens 3 Wörter wechselt oder wieder darunter fällt.
- Keine KI-Anfrage beim Öffnen.
- Keine KI-Anfrage nur durch Wortänderungen.
- Keine echten Netzwerkaufrufe in Tests.

## Nächster Schritt

Als nächstes sollte der lokale Notification-Gerätetest auf iOS und Android fortgeführt werden. Danach kann die automatische Wortauswahl und später ein wiederkehrender Tagesplan separat geplant werden.
