# Tagesimpuls Learn Mode Button State

## Ausgangslage

Die globale lokale Tagesimpuls-Auswahl existiert als eigenes Feature unter `lib/features/tagesimpuls/`. Der HomeScreen liest den globalen `0/5` Counter und die Home-Wortkarte kann Wörter bereits in diese Auswahl senden.

## Neuer Stand

Der lokale Lernmodus zeigt auf der aktiven Lernkarte einen kleinen Button zum Hinzufügen des aktuellen Wortes zum Tagesimpuls.

Der Button nutzt denselben globalen Tagesimpuls-State wie der HomeScreen.

## Verhalten

Beim Tippen auf den Button:

- wird das aktuell sichtbare lokale Lernwort hinzugefügt
- wird die globale Auswahl aktualisiert
- werden Duplikate verhindert
- wird das Limit von 5 Wörtern beachtet
- bleibt der SRS-Fortschritt unverändert

Feedback:

- Erfolg: „Zum Tagesimpuls hinzugefügt.“
- Duplikat: „Bereits im Tagesimpuls.“
- Voll: „Tagesimpuls ist voll.“

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
- aktuelles Wort wird zum Tagesimpuls hinzugefügt
- Duplikate werden nicht doppelt gezählt
- Limit von 5 Wörtern wird eingehalten
- SRS-Submit-Calls bleiben unberührt

## Nächster Schritt

Als nächstes kann aus der globalen Tagesimpuls-Auswahl manuell eine KI-Nachricht generiert werden.
