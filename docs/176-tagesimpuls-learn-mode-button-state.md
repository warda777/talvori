# Tagesimpuls Learn Mode Button State

## Ausgangslage

Die globale lokale Tagesimpuls-Auswahl existiert als eigenes Feature unter `lib/features/tagesimpuls/`. Der HomeScreen liest den globalen `0/5` Counter und die Home-Wortkarte kann Wörter bereits in diese Auswahl senden.

## Neuer Stand

Der lokale Lernmodus zeigt auf der aktiven Lernkarte Quick-Actions für das aktuell sichtbare Wort.

Vorhanden sind:

- Zum Tagesimpuls hinzufügen
- Zu Favoriten hinzufügen

Der Tagesimpuls-Button wurde ergonomischer tiefer platziert und sitzt jetzt zusammen mit der Favoriten-Aktion in einer kleinen Quick-Action-Gruppe. Die Aktionen überlappen nicht mit anderen Kartenbuttons.

Die Quick-Actions sind Teil der `SwipeableWordCard`. Dadurch bewegen sich die Icons mit der Karte mit, wenn die Lernkarte per Swipe/Animation verschoben wird. Sie sind kein unabhängiges Screen-Overlay mehr.

Der Tagesimpuls-Button nutzt denselben globalen Tagesimpuls-State wie der HomeScreen. Die Favoriten-Aktion speichert das lokale Wort in der lokalen Favoriten-Auswahl.

Beide Quick-Actions haben sichtbares Tap-Feedback:

- kurzer Scale-Effekt beim Antippen
- kurzer Glow-/Ring-Pulse nach dem Ergebnis
- Cyan/Violett-Pulse für Tagesimpuls
- Pink-/Herz-Pulse für Favoriten
- gedämpfter Warn-Pulse bei Duplikat oder vollem Tagesimpuls

Die Effekte liegen innerhalb der Quick-Action-Gruppe und bleiben damit an die swipebare Karte gebunden.

## Verhalten

Beim Tippen auf den Tagesimpuls-Button:

- wird das aktuell sichtbare lokale Lernwort hinzugefügt
- wird die globale Auswahl aktualisiert
- werden Duplikate verhindert
- wird das Limit von 5 Wörtern beachtet
- bleibt der SRS-Fortschritt unverändert

Feedback:

- Erfolg: „Zum Tagesimpuls hinzugefügt.“
- Duplikat: „Bereits im Tagesimpuls.“
- Voll: „Tagesimpuls ist voll.“

Beim Tippen auf den Favoriten-Button:

- wird nur das aktuell sichtbare lokale Lernwort als Favorit gespeichert
- werden Duplikate verhindert
- bleibt der SRS-Fortschritt unverändert

Feedback:

- Erfolg: „Zu Favoriten hinzugefügt.“
- Duplikat: „Bereits in Favoriten.“

Die Feedback-Anzeige nutzt eine dunkle, deckende Snackbar mit Neon-Kontur und ist nicht mehr transparent.

## Fachliche Abgrenzung

Der Button ist eine manuelle Zusatzaktion. Er bewertet keine Karte und löst kein Richtig/Falsch aus.

Nicht verändert werden:

- stage
- pass_count
- wrong_count
- next_due_at
- normale Review-History
- lokale SRS-Session-Progression

## Bewusst nicht umgesetzt

- Keine KI-Anfrage
- Keine Supabase-Änderung
- Keine Push- oder Benachrichtigungsfunktion
- Kein automatisches Hinzufügen
- Keine Tagesimpuls-Nachricht

## Tests

Abgedeckt sind:

- Button wird im lokalen Lernmodus angezeigt
- Favoriten-Button wird im lokalen Lernmodus angezeigt
- aktuelles Wort wird zum Tagesimpuls hinzugefügt
- aktuelles Wort wird zu Favoriten hinzugefügt
- Tap-Feedback erscheint bei Tagesimpuls- und Favoriten-Aktion
- Duplikate werden nicht doppelt gezählt
- Limit von 5 Wörtern wird eingehalten
- SRS-Submit-Calls bleiben unberührt

## Nächster Schritt

Als nächstes kann aus der globalen Tagesimpuls-Auswahl manuell eine KI-Nachricht generiert werden.
