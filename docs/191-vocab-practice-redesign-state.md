# 191 Wortspiele State

Stand: 2026-05-22

## Entscheidung

Die alte Seite `Vocab Practice` war ein Mock mit englischen Platzhaltern,
gesperrten Kacheln und leeren Controller-Methoden. Der zwischenzeitliche
Umbau zu `Uebungsarten` hat sich fachlich mit dem normalen Lernstart
ueberschnitten.

Der untere Home-Button ist deshalb jetzt der direkte Einstieg in
**Wortspiele**. Normales Lernen bleibt beim grossen Play-Button und den
lokalen Wortquellen:

- Alle Woerter
- Favoriten
- Meine Woerter
- Woerter, die ich kenne
- Mein Mix

Wortspiele beantworten nicht mehr, welche Quelle gelernt wird, sondern welche
spielerische Form spaeter genutzt werden soll.

## Navigation

Alt:

- Home -> Ueben -> Vocabs / Course -> Vocab Practice / Uebungsarten

Neu:

- Home -> Wortspiele

Der alte `Vocabs`/`Course`-Picker wurde aus dem unteren Button-Flow entfernt.
`Course` bleibt als Screen erhalten, ist aber nicht mehr ueber diesen Button
angeboten.

## Aktuelle Spielkarten

Alle elf Karten sind bewusst vorbereitet und starten noch keine echte
Spielsession:

### Schnellspiele

- `Blitzrunde` - 60 Sekunden, so viele Woerter wie moeglich
- `Wort-Jagd` - Tippe schnell die richtige Bedeutung
- `Bedeutungs-Duell` - Waehle die richtige Antwort

### Woerter bauen

- `Wort-Match` - Verbinde Wort und Uebersetzung
- `Wort-Puzzle` - Sortiere Buchstaben zum richtigen Wort
- `Lueckenwort` - Ergaenze fehlende Buchstaben
- `Hangman` - Errate das Wort Schritt fuer Schritt

### Smart Challenges

- `Hoer & Schreib` - Hoere das Wort und schreibe es
- `Kontext-Challenge` - Verstehe Woerter im KI-Satz
- `Boss-Fight` - Besiege deine schwierigsten Woerter
- `Daily Word Quest` - Deine taegliche Wortmission

Beim Tippen erscheint nur der Hinweis `Dieses Wortspiel wird vorbereitet.` Es
wird keine Queue gestartet und kein SRS-Fortschritt geschrieben.

## Spaetere Umsetzungsprioritaet

1. `Hoer & Schreib`, weil TTS bereits vorhanden ist.
2. `Wort-Match`, weil es einfach, bewaehrt und lokal gut testbar ist.
3. `Blitzrunde`, weil es gut zu XP, Wochenliga und kurzen Sessions passt.
4. `Boss-Fight`, sobald Fehlerstatistiken sauber verfuegbar sind.
5. `Kontext-Challenge`, sobald KI-Satz-Kontext stabil angebunden ist.

## Entfernt

Sichtbar entfernt wurden:

- `Vocab Practice`
- `Uebungsarten`
- `Try Game shuffle`
- `Vocab classic`
- `Build words`
- `Choose the word`
- `Guess the word`
- `Coming soon (tap to vote!)`
- dreifache `Perfection`-Kacheln
- `Klassisch ueben`
- `Frei wiederholen`
- funktionslose `voteFor`-Mechanik
- funktionslose `startGameShuffle`-Mechanik
- viele leere Lock-Kacheln

## Sicherheit

Beim Oeffnen der Seite und beim Tippen auf vorbereitete Spielkarten werden
keine SRS-Daten veraendert. Die Seite startet keine Queue und keine Lernsession
automatisch.

Keine Secrets, keine Server-Push-Logik und keine neue Supabase-Logik wurden
eingefuehrt.
