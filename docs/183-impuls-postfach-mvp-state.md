# Impuls-Postfach MVP State

## Ausgangslage

Tagesimpulse werden lokal geplant und über `generate-daily-impulses` erzeugt. Notifications funktionieren lokal auf dem Gerät. Das Produktkonzept für ein Messenger-ähnliches Impuls-Postfach ist in `docs/182-impuls-postfach-category-chat-concept.md` dokumentiert.

## Was vorbereitet wurde

Das MVP ergänzt ein lokales Impuls-Postfach mit:

- Chatliste
- Tagesimpuls-Chat
- Chatdetail mit Sprechblasen
- lokal gespeicherten Impulsnachrichten
- ungelesenem Status
- vorbereiteter Notification-Payload mit `chatId` und `messageId`
- einfacher Antwortfunktion im Tagesimpuls-Chat über `ai-chat`

Es wurde kein Server-Push und kein Supabase-Verlauf eingebaut.

## Lokale Speicherung

Die Daten werden im MVP über `SharedPreferences` gespeichert und über ein Repository gekapselt:

- `ImpulseInboxRepository`
- `SharedPreferencesImpulseInboxRepository`

Diese Kapselung hält den Weg offen, später auf SQLite oder einen anderen lokalen Speicher umzuziehen.

## Datenmodelle

`ImpulseChat` enthält unter anderem:

- `id`
- `sourceType`
- `sourceId`
- `title`
- `avatarKey`
- `enabled`
- `createdAt`
- `lastMessageAt`
- `unreadCount`

`ImpulseMessage` enthält unter anderem:

- `id`
- `chatId`
- `text`
- `usedWords`
- `createdAt`
- `readAt`
- `source`
- `notificationId`
- `slot`

## Tagesimpuls-Chat

Wenn Tagesimpulse erzeugt und geplant werden, stellt die App sicher, dass der Tagesimpuls-Chat existiert. Die erzeugten Impulse werden als lokale Nachrichten gespeichert.

Die Nachrichten werden weiterhin nicht als Vorschau im Tagesimpuls-Planungsbereich angezeigt. Sie erscheinen im Impuls-Postfach.

Auch bei `Eigene Zeit` läuft der echte Tagesimpuls-Pfad über diesen Speicher:

- `ensureDailyImpulseChat()`
- generierte Tagesimpulse als `ImpulseMessage` speichern
- `unreadCount` erhöhen
- `lastMessageAt` aktualisieren
- `chatId` und `messageId` an die lokale Notification-Payload übergeben

Für die Geräte-Diagnose gibt es zusätzlich zum technischen Notification-Test einen echten Tagesimpuls-Test in 10 Sekunden. Dieser Test erzeugt die Nachricht über den normalen Tagesimpuls-AI-Client, speichert sie im Tagesimpuls-Chat und plant dann eine lokale Notification mit genau dieser gespeicherten Nachricht. Damit wird überprüft, dass nicht nur das iOS-Notification-System funktioniert, sondern auch der komplette Pfad:

- KI-Generierung
- lokales Speichern im Postfach
- Payload mit `chatId`/`messageId`
- lokale One-Shot Notification
- Pending-ID-Prüfung

Der echte Tagesimpuls-Test nutzt immer die aktuelle globale Tagesimpuls-Auswahl. Er ist erst aktiv, wenn mindestens 3 Wörter ausgewählt sind. Die technische Test-Benachrichtigung bleibt davon getrennt und verwendet weder KI noch Postfach.

Die App führt diesen echten Test über `runRealTagesimpulsTestInTenSeconds` aus. Der Flow setzt sofort einen sichtbaren Vorbereitungsstatus, speichert die erzeugte Nachricht im Tagesimpuls-Chat und verwendet die gespeicherte `messageId` für die Notification-Payload. Wenn das Speichern im Postfach fehlschlägt, wird keine Notification geplant.

Der echte 10-Sekunden-Test nutzt einen eigenen Notification-ID-Bereich (`910000` bis `910099`) und wird nicht in den regulären Tagesimpuls-Planungsstate (`plannedTimes`) geschrieben. Reguläres Replanning löscht nur reguläre IDs (`920000` bis `920999`) und kann dadurch keine gerade geplante echte Testnotification entfernen.

## Chatliste

`ImpulsPostfachScreen` zeigt:

- Titel „Impuls-Postfach“
- aktive Chats
- runden Avatar/Icon
- Chat-Titel
- letzte Nachricht
- Uhrzeit oder Datum
- ungelesen Badge
- leeren Zustand

Der Stil folgt Talvoris Dark-Neon-Look und kopiert keine externe Messenger-App 1:1.

Die Chatliste wurde für das MVP produktnäher poliert:

- dezenter Verlaufskopf mit Anzahl der aktiven Verläufe
- dunkle Chat-Kacheln mit Neon-Cyan-/Mint-Kanten
- Tagesimpuls-Avatar als leuchtender Kreis mit Impuls-Icon
- letzte Nachricht einzeilig und gut scanbar
- Uhrzeit/Datum rechts
- Ungelesen-Badge mit starkem Kontrast
- leerer Zustand mit großem Chat-Icon und ruhigem Erklärungstext

## Chatdetail

`ImpulseChatDetailScreen` zeigt:

- Chat-Titel
- Zurück-Button im App-Header
- Nachrichten als Sprechblasen
- KI-/Systemimpulse links bzw. neutral
- Datum/Uhrzeit klein in der Bubble
- verwendete Wörter als Chips
- leeren Zustand, falls lokal noch keine Nachricht vorhanden ist

Das Chatdetail wurde von einer Card-/Feed-Optik zu einem klareren Messenger-Muster umgebaut. Die Nachrichten sind kompakte Bubbles statt großer Karten:

- KI- und Tagesimpuls-Nachrichten stehen links.
- Nutzer-Nachrichten stehen rechts.
- Die Bubble-Geometrie nutzt einheitlich große, harmonische Rundungen.
- Bubble und Tail werden als zusammenhängende Custom-Shape gezeichnet.
- Die Bubble-Form hat links oder rechts unten ein kleines weich-spitzes Tail, das nicht wie ein separates Rechteck wirkt.
- Der Tail von Assistant-/grauen Bubbles nutzt exakt dieselbe Füllfarbe wie die Bubble; es gibt keine dunkle Naht zwischen Bubble und Tail.
- Kurze Nachrichten bleiben kurze Bubbles.
- Lange Nachrichten umbrechen innerhalb einer maximalen Bubble-Breite.
- Zeitstempel sitzen klein in der Bubble.
- `usedWords` sind deutlich kleinere, dezente Chips.
- Die Abstände im Verlauf sind luftiger, ohne Full-Width-Cards.
- Reine Emoji-Nachrichten werden groß und frei stehend dargestellt, ohne Standard-Bubble.
- Text mit Emoji bleibt eine normale Chatbubble.
- Mehrere aufeinanderfolgende Nachrichten desselben Senders werden enger gruppiert; das Tail sitzt nur an der letzten Bubble der Gruppe.
- Der Chatverlauf hat ein dezentes dunkles Hintergrundmuster im Talvori-Stil.
- Datums-Trenner werden als kleine zentrierte Pills angezeigt.

Der Stil bleibt Talvori Dark-Neon und kopiert keine externe Messenger-App 1:1. Der Header ist kompakter mit Zurück-Button, Tagesimpuls-Avatar, Titel und Unterzeile. Beim Öffnen wird nach unten gescrollt, damit der aktuelle Impuls sichtbar ist. Wenn eine Notification mit `messageId` öffnet, kann die Zielnachricht visuell hervorgehoben werden.

Die Eingabeleiste folgt ebenfalls dem Messenger-Muster: Plus-Platzhalter, runde dunkle Textkapsel und rechts ein kontextabhängiger Button. Wenn Text vorhanden ist, erscheint der Senden-Button. Wenn das Textfeld leer ist, erscheint ein Mikrofon-Button fuer Sprache-zu-Text. Wenn der Nutzer in den Chatverlauf tippt oder im Verlauf scrollt, wird die Tastatur geschlossen. Beim Öffnen der Tastatur und nach neuen Nachrichten scrollt der Verlauf wieder nach unten.

Beim Öffnen wird der Chat als gelesen markiert.

## Nachrichten-Aktionsmenü

Nachrichten im Chatdetail unterstützen ein lokales Long-Press-Menü im Talvori Dark-Neon-Stil. Das Muster orientiert sich an modernen Messenger-Kontextmenüs, kopiert aber keine externe App:

- Long-Press schließt die Tastatur und öffnet ein dunkles Aktionsmenü.
- Oben erscheint eine kompakte Emoji-Reaktionsleiste mit `👍`, `❤️`, `😂`, `😮`, `😢`, `🙏`, `🥰` und einem Plus-Platzhalter.
- Eine gewählte Reaktion wird lokal an der Nachricht gespeichert und klein an der Bubble angezeigt.
- „Antworten“ setzt eine lokale Reply-Vorschau über der Eingabeleiste. Die anschließend gesendete Nutzer-Nachricht speichert `replyToMessageId`, `replyPreviewText` und die Reply-Rolle.
- „Kopieren“ kopiert den Nachrichtentext in die Zwischenablage.
- „Mit Stern markieren“ bzw. „Stern entfernen“ toggelt einen lokalen Sternstatus und zeigt den Stern klein an der Nachricht.
- „Löschen“ entfernt die Nachricht nach Bestätigung nur lokal aus diesem Chat. Chatvorschau und letzte Nachricht werden danach neu berechnet.
- „Mehr ...“ öffnet ein zweites Menü mit vorbereiteten Aktionen `Fixieren`, `Sprechen` und `Übersetzen`.

Für das MVP bleibt alles lokal. Es gibt keine Server-Synchronisation von Reaktionen, Sternen, Replies oder gelöschten Nachrichten.

## Interaktiver Tagesimpuls-Chat

Das Impuls-Postfach ist nicht mehr nur ein Archiv. Der Tagesimpuls-Chat kann im MVP als einfacher KI-Impuls-Chat genutzt werden:

- Tagesimpuls- und KI-Nachrichten werden links als eingehende Bubbles dargestellt.
- Nutzer-Nachrichten werden rechts als ausgehende Bubbles dargestellt.
- Die Bubble-Form ist asymmetrisch und erinnert an Messenger-Muster, ohne eine bestehende Messenger-App zu kopieren.
- Zeitstempel bleiben klein in der Bubble.
- `usedWords` erscheinen nur bei KI-/Tagesimpuls-Nachrichten als kleine Chips.
- Unten gibt es eine Eingabeleiste mit Plus-Platzhalter, Textfeld und Senden-Button.
- Bei leerem Textfeld gibt es einen Mikrofon-Button fuer Sprache-zu-Text.
- Der Plus-Button ist aktuell nur ein Platzhalter für spätere Anhänge.

Beim Senden wird die Nutzer-Nachricht sofort lokal im Impuls-Postfach gespeichert. Danach ruft die App den bestehenden `ai-chat` Flutter-Client auf, der über die Supabase Edge Function `ai-chat` läuft. Flutter enthält weiterhin keine KI-Secrets und hat keine direkte OpenAI-Anbindung.

Die KI-Antwort wird als lokale Assistant-Nachricht im selben Chat gespeichert. Während die Antwort läuft, zeigt der Chat eine kleine „Talvori denkt...“-Bubble. Bei Fehlern bleibt die Nutzer-Nachricht erhalten und der Chat zeigt eine lokale Fehlermeldung.

Alte gespeicherte Nachrichten ohne explizite Rolle bleiben kompatibel und werden als Assistant-/KI-Nachrichten behandelt. Neue Nachrichten speichern zusätzlich Rolle und Status:

- `source`/`role`: `ai`, `system` oder `user`
- `status`: `sending`, `sent` oder `failed`
- optional `errorMessage`
- optional `reaction`
- optional `isStarred`
- optional `isPinned`
- optional `replyToMessageId`
- optional `replyPreviewText`
- optional `replyPreviewSource`

User-Nachrichten erhöhen den Ungelesen-Zähler nicht. KI-Antworten, die im geöffneten Chat entstehen, gelten direkt als gelesen. Die Chatliste zeigt nach User- oder KI-Nachrichten weiterhin die neueste Nachricht und den aktuellen Zeitstempel.

Spracheingabe nutzt lokal das Flutter-Paket `speech_to_text`. Die App speichert keine Audiodateien und lädt keine Voice-Nachrichten hoch. Gesprochene Sprache wird in das Textfeld übertragen, damit der Nutzer den erkannten Text prüfen und anschließend normal senden kann. Flutter enthält dafür keine Secrets.

Nicht umgesetzt in diesem Schritt:

- keine Fotos
- keine Dateien
- keine Audio-Nachrichten
- keine gespeicherten Voice-Messages
- keine freie globale Chatfunktion außerhalb des Impuls-Postfachs
- keine komplexe Retry-Logik

## Notification-Payload

Geplante Tagesimpuls-Notifications erhalten eine strukturierte JSON-Payload:

```json
{
  "type": "impulse_message",
  "chatId": "impulse-chat-daily-impulse",
  "messageId": "...",
  "source": "daily_impulse"
}
```

Damit kann der Notification-Tap-Handler direkt den passenden Chat und die passende Nachricht öffnen. Falls die Payload unvollständig ist oder der Chat nicht gefunden wird, fällt die App kontrolliert ins Impuls-Postfach und navigiert nicht in den Tagesimpuls-Screen. Legacy-Payloads im alten Format `impuls-postfach:<chatId>:<messageId>` werden weiterhin tolerant gelesen.

Beim Öffnen des Chatdetails wird der Chat als gelesen markiert. Das reduziert den Ungelesen-Badge im Impuls-Postfach.

Der Notification-Router wartet bei Cold-Starts, bis der App-Navigator bereit ist. Dadurch wird eine Payload nicht mehr zu früh während des Init-/Splash-Zustands verarbeitet. Sobald die App bereit ist, wird der gespeicherte Tap in das Chatdetail oder bei ungültiger Payload ins Postfach weitergeleitet.

Die Notification-Initialisierung ist zentralisiert: Der Payload-Handler wird vor dem App-Start registriert und der lokale Notification-Scheduler initialisiert das Plugin idempotent. Dadurch kann ein Tagesimpuls-Tap nicht durch eine zweite Scheduler-Instanz oder ein zu frühes Launch-Payload verloren gehen.

Das sichtbare Öffnen läuft über den Root-Navigator. Bestehende Tagesimpuls-Routen, Dialoge oder Bottom Sheets werden per `pushAndRemoveUntil` bis zur ersten Route aus dem Weg geräumt. Danach baut der Router den fachlichen Messenger-Stack:

- Home/root
- `ImpulsPostfachScreen`
- `ImpulseChatDetailScreen`

Ein Log `routeSuccess=chat_detail` mit `navigationMethod=root_stack_inbox_then_detail` bedeutet damit, dass das Chatdetail als oberstes sichtbares Ziel geöffnet wurde und das Impuls-Postfach als Parent darunter liegt. Zurück aus dem Chatdetail führt ins Postfach, Zurück aus dem Postfach führt nach Home. Der Tagesimpuls-Bereich ist kein Back-Ziel für Impuls-Nachrichten.

Das Routing-Ziel für `impulse_message` ist immer:

- `ImpulseChatDetailScreen`, wenn der Chat vorhanden ist
- `ImpulsPostfachScreen`, wenn Payload, Chat oder Nachricht nicht sauber auflösbar sind

Der Tagesimpuls-Planungsbereich ist kein Fallback-Ziel für Impuls-Nachrichten.

Zur Tap-Diagnose gibt es einen kleinen globalen Debug-State. Er speichert den letzten Notification-Tap, eine gekürzte Payload-Vorschau, den geparsten Typ, `chatId`, `messageId`, das geplante Routing-Ziel, das Routing-Ergebnis und mögliche Fehler. Der Debug-Bereich kann dadurch anzeigen, ob noch kein Tap empfangen wurde oder ob zuletzt eine `impulse_message` Payload angekommen ist.

Zusätzlich sind zwei Debug-Aktionen vorbereitet:

- „Letzte Notification-Payload öffnen“ routet den zuletzt empfangenen Payload erneut.
- „Chat-Payload simulieren“ erzeugt eine lokale `impulse_message` Payload und öffnet damit den Router ohne iOS-Notification.

So lässt sich trennen, ob das lokale Scheduling funktioniert, ob iOS den Tap an Flutter übergibt und ob der Impuls-Postfach-Router korrekt zum Chatdetail navigiert.

Nach dem Scheduling wird diagnostiziert, ob iOS die erwartete Pending Notification kennt. Die Logs enthalten keine Secrets, aber sie zeigen für die Tagesimpuls-Planung unter anderem:

- Anzahl gespeicherter Nachrichten
- ob eine Inbox-Payload vorhanden ist
- geplante kleine Notification-ID
- Pending-Count
- Pending-IDs
- Payload-Länge
- Cancel-Grund und betroffener ID-Bereich bei Replanning

Der primäre Einstieg ins Impuls-Postfach liegt auf der Home-Seite. Der Button sitzt als sichtbares Chat-/Sprechblasen-Icon neben den Home-Quick-Actions und kann optional einen Ungelesen-Badge anzeigen.

## Kategorie-Chats

Das Impuls-Postfach unterstützt jetzt lokale Kategorie-Chats. Ein Kategorie-Chat ist ein eigener Verlauf für eine Wort-Kategorie und nutzt dieselbe Messenger-Oberfläche wie der Tagesimpuls-Chat:

- KI-/Assistant-Nachrichten links
- Nutzer-Nachrichten rechts
- Eingabeleiste mit Sprache-zu-Text
- Long-Press-Menü
- Reaktionen
- Antworten
- Kopieren
- Stern
- Löschen lokaler Nachrichten

Kategorie-Chats werden lokal als `ImpulseChat` gespeichert:

- `sourceType`: `category`
- `sourceId`: lokale `categoryId`
- `title`: Kategoriename
- `avatarKey`: `category:<categoryId>`
- `enabled`: steuert, ob der Chat in der normalen Postfachliste sichtbar ist

Der Tagesimpuls-Chat bleibt `sourceType=daily_impulse`. Alte gespeicherte Chats mit dem bisherigen `dailyImpulse`-Wert werden weiterhin tolerant gelesen.

Das Repository stellt dafür lokale Funktionen bereit:

- `ensureCategoryChat(categoryId, categoryTitle)`
- `getCategoryChat(categoryId)`
- `setCategoryChatEnabled(categoryId, enabled)`

`ensureCategoryChat` legt einen Kategorie-Chat nur einmal an, aktualisiert aber den Titel, falls sich der Kategoriename ändert. `enabled=false` blendet den Chat aus der normalen Postfachliste aus, löscht aber keine Nachrichten. Wird der Chat später wieder aktiviert, bleibt der lokale Verlauf erhalten.

Im WordHub erhalten lokal verfügbare Kategorie-Kacheln ein kleines Sprechblasen-Icon. Das Icon zeichnet nur den runden Neon-Kreis; der Bereich außerhalb des Kreises bleibt transparent und erzeugt keinen eckigen Fremdhintergrund auf der Kachel. Ein Tap auf dieses Icon erstellt oder aktiviert den passenden Kategorie-Chat und öffnet direkt das generische `ImpulseChatDetailScreen`. Die Kategorie-Kachel verändert dabei keine SRS-Werte und startet keine Lernsession.

Kategorie-Chats können im Chatdetail über eine Kategorie-spezifische Aktion deaktiviert werden. Diese Aktion erscheint nur bei `sourceType=category`, nicht beim Tagesimpuls-Chat. Nach Bestätigung wird `enabled=false` gesetzt und der Chat verschwindet aus der normalen Postfachliste. Lokale Nachrichten bleiben erhalten. Wenn der Nutzer später wieder das Chat-Icon derselben Kategorie-Kachel antippt, setzt `ensureCategoryChat` den Chat erneut auf `enabled=true` und öffnet den bestehenden Verlauf.

Beim Senden aus einem Kategorie-Chat wird der bestehende `ai-chat` Client weiterverwendet. Der Request bekommt zusätzlichen Kontext:

- `chatType: category`
- `categoryId`
- `categoryTitle`
- `categoryWordsSample` mit maximal zehn lokal gelesenen Wörtern, falls verfügbar
- kurzer Hinweis, dass keine Lernstände, Queues oder SRS-Werte verändert werden sollen

Die Kategorie-Wörter werden rein lesend über die lokale Word-Repository-Schicht geladen. Es wird keine Lernsession gestartet, keine Queue verändert und kein `is_mastered`-, `pass_count`- oder `next_due_at`-ähnlicher Lernstand geschrieben.

## Moderner Chat-Hub

Das Impuls-Postfach ist jetzt stärker als eigener Chat-Hub gestaltet. Der Screen besitzt:

- einen kompakten Header `Impuls-Postfach`
- eine Suche mit Placeholder `Chats oder Kategorien suchen`
- ein Plus-Menü zum Hinzufügen von Chats
- interne Tabs `Chats`, `Kategorien`, `Gespeichert` und `Du`

Die Chatliste ist weniger card-lastig und näher an einem Messenger-Startbildschirm: runde Avatare links, Titel und Vorschau in der Mitte, Zeit und Ungelesen-Badge rechts. Die Suche filtert aktive Chats nach Titel und letzter Nachricht.

Das Plus-Menü bietet:

- `Kategorie-Chat hinzufügen`
- `Eigenen KI-Chat erstellen`
- `Tagesimpuls öffnen`

Der Kategorien-Tab zeigt lokal verfügbare Kategorien mit Wortanzahl und Status. Noch nicht vorhandene Kategorie-Chats können hinzugefügt werden, deaktivierte Kategorie-Chats werden über denselben Weg reaktiviert und behalten ihren lokalen Verlauf.

Eigene KI-Chats werden lokal als `ImpulseChat` gespeichert:

- `sourceType`: `custom_ai`
- `sourceId`: lokale Chat-ID
- `title`: vom Nutzer gewählter Chatname
- `avatarKey`: `custom:<chatId>`
- `enabled`: steuert die Sichtbarkeit im Hub

Eigene KI-Chats nutzen dieselbe Messenger-Oberfläche wie Tagesimpuls- und Kategorie-Chats. Der `ai-chat` Request bekommt `chatType: custom_ai` und den Chat-Titel als Kontext. Eigene Chats können lokal ausgeblendet werden, ohne automatisch den Verlauf zu löschen.

Chats können optional ein lokales Avatarbild bekommen. Das Modell speichert dafür `avatarImagePath`; die UI zeigt ein rundes Bild, wenn ein lokaler Pfad vorhanden ist, sonst das bisherige Neon-Icon. Bilder werden nur als Chat-/Kategorie-Avatar verwendet, nicht als Chat-Anhang und nicht in die Cloud hochgeladen. iOS enthält dafür eine Fotomediathek-Beschreibung.

Der Tab `Gespeichert` ist jetzt ein echter Sammelbereich für lokal markierte Nachrichten. Das Repository durchsucht alle lokalen Impuls-Chats nach `isStarred=true`, auch wenn ein Kategorie- oder eigener KI-Chat gerade ausgeblendet ist. Angezeigt werden Chatname, gekürzter Nachrichtentext, Datum/Uhrzeit, Quelle und optional die lokale Reaktion. Ein Tap öffnet den Ursprungschat; bei ausgeblendeten Chats wird der Chat lokal wieder sichtbar gemacht, ohne Nachrichten zu löschen. Die `messageId` wird an das Chatdetail übergeben, damit eine spätere gezielte Hervorhebung oder Scroll-Position vorbereitet ist.

Der Tab `Du` enthält ein kleines lokales KI-Profil statt einer Einstellungswüste. Nutzer können festlegen:

- KI-Stil: `Kurz & direkt`, `Motivierend`, `Locker`, `Trainer`
- Antwortlänge: `Kurz`, `Normal`, `Ausführlich`
- Lernziel: `Alltag`, `Schule`, `Reisen`, `Prüfung`, `Beruf`
- Erklärungssprache: `Deutsch`, `Englisch`, `Gemischt`

Das Profil wird lokal im Impuls-Postfach-Store gespeichert und hat Default-Werte für bestehende Installationen. Beim Senden aus Tagesimpuls-, Kategorie- oder eigenem KI-Chat ergänzt der Controller den bestehenden `ai-chat` Kontext um `aiStyle`, `answerLength`, `learningGoal` und `explanationLanguage`. Kategorie-Kontext wie `categoryId`, `categoryTitle` und `categoryWordsSample` bleibt erhalten. Es wird weiterhin keine Lernsession gestartet, keine Queue verändert und kein SRS-Fortschritt geschrieben.

## Bewusst nicht umgesetzt

- Kein Server-Push
- Kein APNs-/FCM-Ausbau
- Kein Supabase-Verlauf
- Kein Premium-Gating
- Kein freier globaler Chat außerhalb des Impuls-Postfachs
- Keine Foto-/Datei-/Audio-Nachrichten
- Keine Cloud-Speicherung von Avatarbildern
- Keine SRS-Änderung

## Tests

Abgedeckt sind:

- DailyImpulseChat wird automatisch erstellt.
- Nachrichten werden lokal gespeichert.
- Ungelesen-Count steigt beim Speichern.
- Chat öffnen markiert Nachrichten als gelesen.
- Chatliste zeigt letzte Nachricht.
- Chatdetail zeigt Sprechblasen und usedWords.
- Tagesimpuls-Planung speichert generierte Nachrichten im Postfach.
- Notification-Payload enthält `chatId` und `messageId`.
- Kategorie-Chat wird lokal erstellt.
- Kategorie-Chat wird nicht dupliziert.
- Deaktivierte Kategorie-Chats verschwinden aus der normalen Chatliste.
- Reaktivierte Kategorie-Chats behalten ihre lokalen Nachrichten.
- Kategorie-Chatdetail zeigt Kategorie-Titel und Kategorie-Unterzeile.
- Kategorie-Chats senden Kategorie-Kontext an den bestehenden `ai-chat` Client.
- Kategorie-Chat-Icon rendert als runder Kreis ohne eckigen Fremdhintergrund.
- Kategorie-Chat kann deaktiviert werden, ohne lokale Nachrichten zu löschen.
- Tagesimpuls-Chat zeigt keine Kategorie-Deaktivieren-Aktion.
- Eigene KI-Chats können lokal erstellt werden.
- Avatar-Pfade werden lokal gespeichert und gelesen.
- Suche filtert aktive Chats.
- Plus-Menü öffnet Kategorie- und Custom-Chat-Flows.
- Kategorie-Wörter werden rein lesend als KI-Kontext bereitgestellt.
- Gespeicherte Nachrichten werden aus allen lokalen Chats gesammelt.
- Entfernen des Sterns oder Löschen einer Nachricht entfernt sie aus `Gespeichert`.
- Ein Tap auf eine gespeicherte Nachricht öffnet den Ursprungschat.
- Das KI-Profil hat lokale Default-Werte und kann gespeichert werden.
- `ai-chat` Requests erhalten den KI-Profil-Kontext zusätzlich zum Kategorie-Kontext.

## Nächster Schritt

Als nächstes kann `Gespeichert` gezieltes Scrollen oder Highlighting der markierten Nachricht im Chatdetail bekommen. Im `Du`-Tab können später weitere lokale Präferenzen wie Tonalität pro Chat, Lernfokus oder Benachrichtigungsstil ergänzt werden.
