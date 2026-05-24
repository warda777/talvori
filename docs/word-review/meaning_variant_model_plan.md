# Meaning Variant Model Plan

Stand: 2026-05-24

Diese Datei ist eine reine Planungs- und Entscheidungsgrundlage fuer die
drei verbleibenden Sprachcode-Konflikte, die keine einfachen Dubletten sind:

- `incident`
- `move`
- `throughout`

Es wurden keine Supabase-Daten geaendert, keine Woerter geloescht, keine
Kategorien veraendert und keine `user_words`, `word_progress` oder
`user_word_srs` beruehrt.

Grundlage:
- `docs/word-review/language_code_conflict_decisions.md`
- `docs/word-review/language_code_conflict_context.csv`
- `docs/word-review/language_code_conflicts_remaining_summary.md`
- `docs/192-word-worlds-and-levels-plan.md`

## Warum diese Faelle keine einfachen Dubletten sind

Bei `incident`, `move` und `throughout` ist der englische Begriff gleich,
aber die deutsche Uebersetzung unterscheidet sich fachlich:

- `incident`: `Vorfall` vs. `Störung/Vorfall`
- `move`: `umziehen` vs. `bewegen`
- `throughout`: `durchgehend` vs. `in ganz`

Damit ist der Konflikt nicht nur technischer Natur (`EN`/`DE` vs. `en`/`de`),
sondern betrifft echte Bedeutungsvarianten. Eine Sprachlern-App sollte solche
Nuancen nicht blind verlieren.

## Warum automatisches Loeschen oder Mergen riskant waere

Ein automatischer Merge koennte:

- eine wichtige Bedeutung entfernen,
- Lernkarten fachlich verengen,
- spaetere Beispiele oder Kontexte verfälschen,
- Nutzerfortschritt unklar machen, falls spaeter SRS pro Bedeutung relevant
  wird,
- Wortwelten oder Level falsch vermischen.

Ein automatisches Loeschen ist deshalb nicht empfohlen. Auch ein simples
Zusammenfuehren in eine Zeichenkette wie `bewegen; umziehen` kann nur eine
Zwischenloesung sein, solange Talvori kein echtes Bedeutungsmodell besitzt.

## Fachliche Moeglichkeiten

### 1. Getrennte Eintraege behalten

Vorteil:
- Bedeutungen gehen nicht verloren.
- Keine riskante Migration.
- Gut, solange Datenmodell und SRS-Bezug unklar sind.

Nachteil:
- Unique Constraint `(text, from_lang, to_lang)` verhindert einfache
  Sprachcode-Normalisierung fuer beide Eintraege.
- Doppelte Woerter koennen in UI/Exporten irritieren.

### 2. Uebersetzungen zusammenfuehren

Beispiele:

- `incident`: `Vorfall; Störung`
- `move`: `bewegen; umziehen`
- `throughout`: `durchgehend; während des gesamten`

Vorteil:
- Ein technischer `words`-Eintrag pro englischem Begriff.
- Einfacher als ein neues Modell.

Nachteil:
- Bedeutungen, Beispiele und Kontexte koennen nicht sauber getrennt werden.
- SRS-/Spiel-Logik weiss nicht, welche Bedeutung gerade geuebt wird.
- Lange Uebersetzungsstrings koennen UI und Tests belasten.

### 3. Echtes Mehrbedeutungsmodell einfuehren

Langfristig ist das fuer Talvori die sauberste Zielrichtung.

Beispiel:

Ein Wort:

```text
move
```

Mehrere Bedeutungen:

1. `bewegen`
2. `umziehen`

Jede Bedeutung kann spaeter eigene Felder bekommen:

- `translation`
- `explanation`
- `example_sentence`
- `context`
- `difficulty` / `level`
- `tags`
- optionale `word_worlds`

Offene Architekturfrage:

- SRS/Progress pro Wort?
- SRS/Progress pro Bedeutung?
- Hybrid: Wort-Fortschritt plus Bedeutungsabdeckung?

Diese Frage sollte vor einer produktiven Migration geklaert werden.

## Empfohlene Zielrichtung fuer Talvori

Kurzfristig:

- Bedeutungsvarianten nicht automatisch mergen.
- Keine Eintraege loeschen.
- Konflikte als Review-Faelle behalten.
- Falls dringend noetig, nur nach manueller Entscheidung eine kombinierte
  Uebersetzung verwenden.

Langfristig:

- Ein echtes Mehrbedeutungsmodell planen.
- `public.words` als Lexem/Grundwort behandeln.
- Bedeutungen in einer separaten Struktur modellieren, z. B.
  `word_meanings`.
- Danach Spiele, Review und SRS bewusst entscheiden lassen, ob sie auf Wort-
  oder Bedeutungsebene arbeiten.

## Fall: incident

### Aktuelle Varianten

- candidate: `incident` -> `Vorfall` (`EN` -> `DE`)
- conflict: `incident` -> `Störung/Vorfall` (`en` -> `de`)

### Moegliche kanonische Bedeutungen

- `Vorfall`
- `Störung`

### Moegliche kombinierte Uebersetzung

`Vorfall; Störung`

### Fachlicher Hinweis

In Work-/Career-/Tech-Kontexten kann `incident` eher `Störung` oder
`Störfall` bedeuten. Allgemeiner ist `Vorfall` passend.

### Empfehlung

Nicht automatisch mergen. Erst klaeren, ob `incident` als ein Wort mit
mehreren Bedeutungen oder als mehrere kontextuelle Bedeutungen modelliert
werden soll.

## Fall: move

### Aktuelle Varianten

- candidate: `move` -> `umziehen` (`EN` -> `DE`)
- conflict: `move` -> `bewegen` (`en` -> `de`)

### Moegliche kanonische Bedeutungen

- `bewegen`
- `umziehen`

### Moegliche kombinierte Uebersetzung

`bewegen; umziehen`

### Fachlicher Hinweis

Beide Bedeutungen sind fuer Lernende wichtig. `move` ist ein sehr
haeufiges Wort, und die Bedeutungen unterscheiden sich kontextuell deutlich.

### Empfehlung

Nicht automatisch loeschen. Dieser Fall ist ein guter Pilotkandidat fuer ein
spaeteres Mehrbedeutungsmodell.

## Fall: throughout

### Aktuelle Varianten

- candidate: `throughout` -> `durchgehend` (`EN` -> `DE`)
- conflict: `throughout` -> `in ganz` (`en` -> `de`)

### Moegliche kanonische Bedeutungen

- `durchgehend`
- `während des gesamten`

### Moegliche kombinierte Uebersetzung

`durchgehend; während des gesamten`

### Fachlicher Hinweis

`in ganz` wirkt isoliert unvollstaendig und sollte fachlich geprueft werden.
Je nach Satzkontext ist `während des gesamten`, `in ganz` oder `überall in`
moeglich.

### Empfehlung

Nicht automatisch mergen. Zuerst die kanonische deutsche Bedeutung klaeren.

## Offene Datenmodell-Fragen

- Soll `public.words.translation` langfristig nur eine Hauptuebersetzung
  enthalten?
- Wie werden alternative Bedeutungen in der UI angezeigt?
- Sollen Beispiele pro Bedeutung gespeichert werden?
- Soll SRS an `word_id` oder an `meaning_id` haengen?
- Wie werden Wortwelten/Level auf Bedeutungen verteilt, wenn ein Wort in
  mehreren Kontexten vorkommt?

## Naechste Empfehlung

Vor produktiven Aenderungen ein kleines Datenmodell-RFC fuer
`word_meanings` erstellen. Danach koennen `incident`, `move` und
`throughout` als Pilotfaelle verwendet werden.

