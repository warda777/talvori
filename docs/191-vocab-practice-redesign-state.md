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

Die ersten echten Spielmodi sind `Hoer & Schreib`, `Wort-Match`,
`Blitzrunde`, `Lueckenwort`, `Wort-Puzzle`, `Bedeutungs-Duell` und
`Wort-Jagd`. Die anderen vier Karten sind bewusst vorbereitet und starten noch keine echte
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

Beim Tippen auf vorbereitete Karten erscheint nur der Hinweis
`Dieses Wortspiel wird vorbereitet.` Es wird keine Queue gestartet und kein
SRS-Fortschritt geschrieben.

## Blitzrunde

`Blitzrunde` ist der dritte echte Wortspielmodus:

- liest lokale Woerter offline ueber dieselbe lokale Wortquelle
- nutzt nur Woerter mit Begriff und Uebersetzung
- benoetigt mindestens vier passende Wortpaare
- startet erst nach der Startkarte `Bereit fuer die Blitzrunde?`
- laeuft im Produkt mit 60 Sekunden
- zeigt Zeit, lokalen Punktestand, ein Wort und vier Uebersetzungen
- waehlt eine richtige Antwort und drei lokale Ablenker
- vergleicht Antworten ueber stabile Wort-IDs
- erlaubt Wiederholungen, wenn die lokale Wortbasis klein ist
- zeigt am Ende `Zeit vorbei`

Der Modus schreibt keine SRS-, XP-, Liga-, Rewards- oder Statistikdaten.

## Wort-Jagd

`Wort-Jagd` ist der siebte echte Wortspielmodus:

- liest lokale Woerter offline ueber dieselbe lokale Wortquelle
- nutzt nur Woerter mit Begriff und Uebersetzung
- benoetigt mindestens vier passende Wortpaare
- startet erst nach der Startkarte `Bereit fuer die Wort-Jagd?`
- spielt maximal 10 eindeutige Fragen pro Runde
- zeigt Fortschritt, lokalen Trefferstand, ein Wort und vier Uebersetzungen
- waehlt eine richtige Antwort und drei lokale Ablenker
- wechselt nach jeder Antwort direkt zur naechsten Frage
- filtert doppelte Begriffe oder Uebersetzungen fuer stabile Runden
- vergleicht Antworten ueber stabile Wort-IDs
- zeigt am Ende `Jagd beendet`

Der Modus schreibt keine SRS-, XP-, Liga-, Rewards- oder Statistikdaten.

## Bedeutungs-Duell

`Bedeutungs-Duell` ist der sechste echte Wortspielmodus:

- liest lokale Woerter offline ueber dieselbe lokale Wortquelle
- nutzt nur Woerter mit Begriff und Uebersetzung
- benoetigt mindestens vier passende Wortpaare
- spielt maximal 10 Fragen pro Runde
- zeigt keinen Timer und keine Startkarte
- zeigt ein Wort und vier lokale Uebersetzungen
- waehlt eine richtige Antwort und drei lokale Ablenker
- filtert doppelte Begriffe oder Uebersetzungen fuer stabile Runden
- vergleicht Antworten ueber stabile Wort-IDs
- zeigt bei falschen Antworten die richtige Bedeutung ohne Strafe
- erlaubt `Aufloesen` und `Naechste Frage`
- zeigt am Ende `Duell beendet`

Der Modus schreibt keine SRS-, XP-, Liga-, Rewards- oder Statistikdaten.

## Wort-Puzzle

`Wort-Puzzle` ist der fuenfte echte Wortspielmodus:

- liest lokale Woerter offline ueber dieselbe lokale Wortquelle
- nutzt nur stabile Begriffe mit mindestens drei Zeichen
- filtert Begriffe mit Leerzeichen oder Bindestrichen fuer eindeutige Chips
- spielt maximal 10 Woerter pro Runde
- mischt Buchstaben lokal und deterministisch
- unterstuetzt doppelte Buchstaben ueber indexierte Buchstaben-Chips
- zeigt optional die lokale Uebersetzung als Hinweis
- erlaubt `Pruefen`, `Zuruecknehmen`, `Zuruecksetzen`, `Aufloesen` und
  `Naechstes Wort`
- vergleicht Eingaben robust mit trim, Kleinschreibung und normalisierten
  Leerzeichen
- zeigt am Ende `Puzzle geschafft`

Der Modus schreibt keine SRS-, XP-, Liga-, Rewards- oder Statistikdaten.

## Lueckenwort

`Lueckenwort` ist der vierte echte Wortspielmodus:

- liest lokale Woerter offline ueber dieselbe lokale Wortquelle
- nutzt nur Woerter mit mindestens vier Buchstaben
- spielt maximal 10 Woerter pro Runde
- erzeugt die Luecken lokal und deterministisch
- laesst den ersten Buchstaben sichtbar
- entfernt keine Leerzeichen oder Bindestriche als Luecken
- zeigt optional die lokale Uebersetzung als Hinweis
- erlaubt `Pruefen`, `Aufloesen` und `Naechstes Wort`
- vergleicht Eingaben robust mit trim, Kleinschreibung und normalisierten
  Leerzeichen
- zeigt am Ende `Runde beendet`

Der Modus schreibt keine SRS-, XP-, Liga-, Rewards- oder Statistikdaten.

## Wort-Match

`Wort-Match` ist der zweite echte Wortspielmodus:

- liest lokale Woerter offline ueber dieselbe lokale Wortquelle
- nutzt nur Woerter mit Begriff und Uebersetzung
- benoetigt mindestens drei passende Wortpaare
- spielt maximal sechs Wortpaare pro Runde
- mischt die Uebersetzungen lokal und vergleicht Paare ueber die Wort-ID
- filtert doppelte Begriffe oder Uebersetzungen fuer stabile Runden
- markiert korrekte Paare als erledigt
- zeigt bei falschen Paaren nur neutrales Feedback ohne Strafe
- zeigt am Ende eine Abschlusskarte

Der Modus schreibt keine SRS-Daten. Er veraendert nicht `pass_count`, `stage`,
`is_mastered`, `next_due_at` oder Review-/Learn-Fortschritt.

## Hoer & Schreib

`Hoer & Schreib` ist der erste echte Wortspielmodus:

- liest lokale Woerter offline ueber die lokale Wortquelle
- verwendet native TTS ueber den bestehenden Aussprache-Service
- zeigt das gesuchte Wort nicht sofort an
- erlaubt `Anhoeren`, `Pruefen`, `Aufloesen` und `Naechstes Wort`
- vergleicht Eingaben robust mit trim, Kleinschreibung und normalisierten
  Leerzeichen
- spielt maximal 10 lokale Woerter pro Runde
- zeigt am Ende eine lokale Abschlusskarte mit richtig erkannten Woertern
- zeigt einen freundlichen Empty State, wenn lokal noch keine Woerter vorhanden
  sind

Der Modus schreibt keine SRS-Daten. Er veraendert nicht `pass_count`, `stage`,
`is_mastered`, `next_due_at` oder Review-/Learn-Fortschritt.

## Spaetere Umsetzungsprioritaet

1. `Boss-Fight`, sobald Fehlerstatistiken sauber verfuegbar sind.
2. `Kontext-Challenge`, sobald KI-Satz-Kontext stabil angebunden ist.

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
