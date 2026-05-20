# Impuls-Postfach und Kategorie-Chats

## Produktziel

Tagesimpuls-Nachrichten sollen sich langfristig wie kurze Messenger-Nachrichten anfühlen. Eine Notification soll beim Antippen nicht nur verschwinden, sondern in einen Verlauf führen, in dem der Nutzer ältere Impulse nachlesen kann.

Der Verlauf soll geordnet bleiben. Statt eines einzigen gemischten Stroms sollen Impulse nach Kategorie, Quelle oder Kontext in eigene Chats einsortiert werden.

## Warum kein einzelner globaler Chat

Ein einzelner globaler Impuls-Chat würde schnell zu lang und unübersichtlich. Unterschiedliche Themen wie Favoriten, eigene Wörter, Wortwelten und schwierige Wörter würden vermischt.

Kategorie-Chats schaffen Ordnung und ermöglichen später gezielte Interaktion. Der Nutzer kann einzelne Lernkontexte öffnen, stummschalten, deaktivieren oder vertiefen, ohne den gesamten Impuls-Verlauf durchsuchen zu müssen.

## Chat-Typen

Mögliche Chat-Typen:

- Automatischer Tagesimpuls-Chat
- Kategorie-Chats aus Wortwelten
- Meine-Wörter-Chat
- Favoriten-Chat
- Wörter-die-ich-kenne-Chat
- Später optional: Schwierige-Wörter-Chat oder Unsichere-Wörter-Chat

## Aktivierung über Kategorie-Kacheln

Jede Kategorie-Kachel kann später ein Chat- oder Sprechblasen-Icon erhalten.

- Icon aus: Für diese Kategorie ist kein Chat aktiv.
- Icon an oder leuchtend: Der Kategorie-Chat ist aktiv.
- Aktivierte Kategorien erscheinen im Impuls-Postfach.
- Deaktivierte Kategorien verschwinden aus dem Impuls-Postfach.
- Die Wörter und Lernstände bleiben beim Deaktivieren erhalten.

Diese Logik gilt nicht nur für Wortwelten, sondern auch für Spezialbereiche wie Favoriten, Meine Wörter und Wörter, die ich kenne.

## Aktivierung im Impuls-Postfach

Das Impuls-Postfach kann später zusätzlich ein Plus-Zeichen erhalten. Darüber kann der Nutzer Kategorie-Chats aktivieren, ohne den Weg über das Kategorie-Popup nehmen zu müssen.

Der Plus-Flow kann eine Liste verfügbarer Quellen zeigen, zum Beispiel Wortwelten, Favoriten, Meine Wörter und weitere lokale Lernkontexte.

## Automatische Chat-Erstellung

Wenn der erste Tagesimpuls als Notification erzeugt wird, kann automatisch ein Tagesimpuls-Chat erstellt werden. Die erzeugte Nachricht wird dort gespeichert.

Für konkrete Kategorie-Chats soll automatische Erstellung vorsichtig bleiben: Eine Nachricht wird nur dann einem Kategorie-Chat zugeordnet, wenn die Kategorie aktiv ist oder die Nachricht eindeutig einer aktiven Kategorie zugeordnet werden kann.

## Chatliste

Das Impuls-Postfach kann eine Messenger-ähnliche Chatliste verwenden, ohne WhatsApp direkt zu kopieren.

Elemente der Chatliste:

- Runder Avatar oder Kategorie-Bild
- Chat-Titel
- Letzte Nachricht
- Uhrzeit oder Datum
- Ungelesen-Badge
- Dark-Neon-Stil von Talvori

Der Fokus liegt auf schneller Orientierung: Welche Quelle hat zuletzt einen Impuls geschickt, was war der Inhalt, und gibt es ungelesene Nachrichten?

## Chatdetail

Das Chatdetail zeigt den Verlauf eines einzelnen Impuls-Chats.

Mögliche Elemente:

- Sprechblasen
- Datum und Uhrzeit
- Verwendete Wörter als kleine Chips oder Detailzeile
- Markierung neuer Nachrichten
- Später zusätzliche Aktionen direkt an einer Nachricht

Der Verlauf soll wie ein Lernkontext wirken, nicht wie ein allgemeiner Chat ohne Struktur.

## Spätere Interaktion

Später können Impuls-Nachrichten interaktiv werden.

Mögliche Aktionen:

- Mehr erklären
- Noch ein Beispiel
- Dieses Wort üben
- Wort favorisieren
- Heute pausieren
- Kurze Antwort oder Reaktion auf den Impuls

Diese Interaktionen sollten den lokalen Lernfluss ergänzen, aber keine SRS-Werte stillschweigend verändern.

## Premium-Idee

Mögliche Staffelung:

Free:

- 1 Tagesimpuls-Chat
- Begrenzter Verlauf
- Wenige aktive Kategorie-Chats

Premium:

- Mehrere aktive Kategorie-Chats
- 2 bis 5 Impulse pro Tag
- Längerer Verlauf
- Reaktionen und Antworten
- Eigene Stile
- Intelligente Kategorie-Auswahl

Die genaue Produktgrenze muss später mit Usage Tracking, Kostenkontrolle und Nutzerwert abgestimmt werden.

## Datenschutz und Kontrolle

Der Nutzer entscheidet, welche Kategorie-Chats aktiv sind. Keine Kategorie soll ungefragt dauerhaft als Chatbereich aufgedrängt werden.

Kontrollregeln:

- Chats können deaktiviert werden.
- Verläufe können später gelöscht werden.
- KI nutzt nur notwendige Wörter und minimale Kontextdaten.
- Keine vollständige Lernhistorie wird ungefiltert an KI-Dienste gesendet.
- Secrets bleiben serverseitig und nicht in Flutter.

## Technische Architektur-Idee

Spätere lokale Datenmodelle könnten so aussehen:

### ImpulseChat

- id
- sourceType: dailyImpulse, category, favorites, myWords
- sourceId
- title
- avatar oder theme
- enabled
- lastMessageAt
- unreadCount

### ImpulseMessage

- id
- chatId
- text
- usedWords
- createdAt
- readAt
- source: ai, system, user
- notificationId optional

Die Daten sollten lokal gespeichert werden, damit das Impuls-Postfach offline lesbar bleibt. Online-Generierung und Push-Zustellung bleiben getrennte Erweiterungen.

## Umsetzung in Phasen

Phase 1:

- Doku und Konzept
- Lokale Chatmodelle planen

Phase 2:

- Lokales Impuls-Postfach MVP
- Tagesimpuls-Chat
- Nachrichten lokal speichern
- Notification Tap öffnet Chat

Phase 3:

- Kategorie-Chats aktivieren und deaktivieren
- Kategorie-Kachel mit Sprechblasen-Icon
- Plus im Impuls-Postfach

Phase 4:

- Chatdetail mit Sprechblasen und Verlauf
- Ungelesen-Status

Phase 5:

- Interaktion und Premium-Funktionen

## Nächster technischer Schritt

Als nächstes sollten zuerst lokale Datenmodelle und ein Repository für das Impuls-Postfach geplant werden.

Danach kann die Notification-Payload so erweitert werden, dass ein Tap auf eine Tagesimpuls-Notification den passenden Chat öffnet. Erst anschließend sollten Chatliste und Chatdetail als UI gebaut werden.
