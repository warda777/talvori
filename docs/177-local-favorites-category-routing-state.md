# Local Favorites Category Routing State

## Ausgangslage

Der lokale Lernmodus besitzt eine Favoriten-Quick-Action auf der Lernkarte. Diese Aktion speichert lokale Word-IDs in der lokalen Favoritenstruktur unter `lib/features/favorites/`.

Die Kachel „Favoriten“ im Kategorie-Popup zeigte bisher noch auf den alten Quick-Set-/CategoryDetail-Pfad. Dadurch war für Nutzer nicht sichtbar, wo ein im Lernmodus favorisiertes Wort landet.

## Neuer Stand

Die Favoriten-Kachel im Kategorie-Popup öffnet jetzt eine lokale Favoritenliste.

Der Pfad ist:

Kategorie-Popup
→ Favoriten
→ lokale Favoritenliste
→ lokales Wortdetail

Die alte CategoryDetail-/Quick-Set-Route wird für lokale Favoriten nicht mehr verwendet.

## Datenquelle

Die Favoritenliste liest aus der lokalen Favoritenstruktur:

- `LocalFavoritesRepository`
- `localFavoritesControllerProvider`
- `localFavoriteWordsProvider`

Gespeichert werden lokale Word-IDs. Die Liste löst diese IDs gegen die lokale SQLite-Wortdatenbank auf und zeigt nur vorhandene, nicht archivierte lokale Wörter an.

## Verhalten

Wenn ein Wort im lokalen Lernmodus als Favorit markiert wurde:

- wird die Word-ID lokal gespeichert
- die Favoriten-Kachel zeigt den lokalen Einstieg
- die lokale Favoritenliste zeigt das Wort
- das Wortdetail kann geöffnet werden

Duplikate werden durch die lokale Favoritenlogik verhindert und daher nicht mehrfach angezeigt.

Wenn noch keine Favoriten vorhanden sind, erscheint ein lokaler Empty-State:

- „Noch keine Favoriten“
- „Markiere Wörter im Lernmodus als Favorit.“

## Abgrenzung

Nicht verändert wurden:

- Supabase-Favoritenlogik
- Online-/Sync-Pfade
- SRS-Fortschritt
- CategoryDetail-Fachlogik
- KI- oder Tagesimpuls-Logik

Lokale Favoriten bleiben lokal.

## Tests

Abgedeckt sind:

- Favoriten-Kachel öffnet lokale Favoritenliste
- leerer Favoritenzustand wird angezeigt
- favorisierte lokale Wörter erscheinen in der Liste
- lokale Favoriten zeigen keine technische Kategorie-ID
- Lernmodus-Favoritenbutton speichert weiterhin lokal

## Nächster Schritt

Optional kann später eine Entfernen-Aktion für lokale Favoriten ergänzt werden. Für den aktuellen Block ist der sichtbare lokale Pfad vom Lernmodus zur Favoriten-Kachel geschlossen.
