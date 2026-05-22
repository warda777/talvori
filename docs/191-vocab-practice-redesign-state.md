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

Die ersten echten Spielmodi sind `Hoer & Schreib` und `Wort-Match`. Die
anderen neun Karten sind bewusst vorbereitet und starten noch keine echte
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

1. `Blitzrunde`, weil es gut zu XP, Wochenliga und kurzen Sessions passt.
2. `Boss-Fight`, sobald Fehlerstatistiken sauber verfuegbar sind.
3. `Kontext-Challenge`, sobald KI-Satz-Kontext stabil angebunden ist.

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
