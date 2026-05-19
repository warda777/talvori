# Global Tagesimpuls Selection State

## Ausgangslage

Der Tagesimpuls war bisher optisch auf dem HomeScreen sichtbar, die Auswahl selbst war aber an den alten Home-/Wheel-Zustand gekoppelt. Für die spätere Nutzung im Lernmodus und im Wortdetail braucht Talvori eine appweite lokale Quelle.

## Neuer Stand

Es gibt eine globale lokale Tagesimpuls-Auswahl mit maximal 5 Wörtern. Die Auswahl ist über einen zentralen Riverpod-Provider lesbar und kann von mehreren Screens genutzt werden.

Unterstützt werden:

- Wort hinzufügen
- Wort entfernen
- Auswahl leeren
- Count lesen, z. B. `0/5`
- Voll-Zustand erkennen
- Duplikate verhindern

## Datenmodell

Ein Tagesimpuls-Item enthält:

- `wordId`
- `text`
- optionale `translation`
- optionale `categoryId`
- `addedAt`

Duplikate werden über `wordId` oder normalisierten Worttext verhindert.

## Lokale Persistenz

Die Auswahl wird lokal über `SharedPreferences` gespeichert. Damit überlebt sie einen App-Neustart, ohne eine neue Supabase- oder SRS-Abhängigkeit einzuführen.

Der Speicher ist bewusst klein gehalten, weil der Tagesimpuls nur bis zu 5 Wörter enthält.

## HomeScreen-Anbindung

Die bestehende `0/5` Anzeige auf dem HomeScreen liest nun aus dem globalen Tagesimpuls-State. Der Quick-Send-Button auf der Home-Wortkarte schreibt ebenfalls in diese globale Auswahl.

Der alte Home-gebundene In-Memory-Zustand ist damit nicht mehr die Quelle für die Home-Auswahl.

## Bewusst nicht umgesetzt

- Keine KI-Anfrage
- Keine Supabase-Änderung
- Keine Push- oder Benachrichtigungsfunktion
- Keine Änderung am SRS-Fortschritt
- Kein Add-Button im Lernmodus in diesem Schritt

## Tests

Abgedeckt sind:

- erstes Wort erhöht den Count
- maximal 5 Wörter
- Duplikate werden verhindert
- Entfernen funktioniert
- Leeren funktioniert
- Persistenz über Repository
- HomeScreen liest den Counter aus dem globalen State

## Nächster Schritt

Als nächstes kann der Lernmodus einen Add-Button bekommen, der denselben globalen Tagesimpuls-State nutzt.
