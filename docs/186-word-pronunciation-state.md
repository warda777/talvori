# 186 Word Pronunciation State

Stand: 2026-05-21

## Umfang

- Wörter können lokal über native Geräte-TTS ausgesprochen werden.
- Die Aussprache startet nur nach Nutzeraktion auf ein Sound-Icon.
- Es werden keine Audiodateien gespeichert.
- Es wird keine externe TTS-API und keine Supabase Edge Function für Aussprache genutzt.
- Es entstehen keine API-Kosten und es liegen keine TTS-Secrets in Flutter.

## Umsetzung

- `WordPronunciationService` kapselt die Aussprache.
- Die produktive Implementierung nutzt `flutter_tts`.
- UI-Aufrufe laufen über `wordPronunciationServiceProvider`, damit Widgettests Fakes verwenden können.
- Fehler werden kontrolliert zurückgegeben und in der UI als kurzer Hinweis angezeigt.

## Sprachmapping

- Englisch: `en-US`
- Deutsch: `de-DE`
- Spanisch: `es-ES`
- Französisch: `fr-FR`
- Unbekannte oder fehlende Sprache: Fallback `en-US`

## Verfügbare Stellen

- Word Detail / lokales Wortdetail
- Meine-Wörter-/Vocabs-Liste
- Home-Wheel-Karte, wenn ein aktuelles Wort sichtbar ist
- Lokale Lernkarten im aktuellen Lernmodus

## SRS-Schutz

- Aussprache liest nur das sichtbare Wort.
- Aussprache verändert keine SRS-Felder.
- Aussprache startet keine Lernsession.
- Aussprache verändert keine Queue.
