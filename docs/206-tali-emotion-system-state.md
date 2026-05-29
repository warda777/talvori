# Tali-Emotion-System: aktueller Architekturstand

## Ziel

Das Tali-Emotion-System bereitet die App darauf vor, Tali gezielt auf Ereignisse reagieren zu lassen. Emotionen wechseln nicht zufällig, sondern werden über App-Events, Companion-Zustände oder spätere Lern-/Belohnungs-Hooks gesetzt.

## Vorhandene Emotionen

Die zentrale Darstellung läuft über `TaliEmotion`:

- `neutral`
- `happy`
- `thinking`
- `bored`
- `surprised`
- `cool`
- `hurra`
- `embarrassed`
- `sleepy`
- `loveEyes`
- `wink`
- `party`
- `starEyes`

## Varianten

Die Mascot-Variante läuft über `TalvoriMascotStyle`:

- `female`
- `male`

Die Auswahl wird lokal über die bestehenden `ProfilePreferences` gespeichert. Home und Companion nutzen diese Auswahl, um das passende Asset zu laden.

## Legacy-Mood und neue Emotion

`TalvoriMascotMood` bleibt als Legacy-/Companion-Mood erhalten, damit bestehende Companion-Logik nicht gebrochen wird. `TaliEmotion` ist die neue visuelle Emotionsebene.

Die Vermittlung läuft zentral über:

- `TalvoriMascotAssets.emotionForLegacyMood(...)`
- `TalvoriMascotAssets.emotionForEvent(...)`

Dadurch gibt es keinen zweiten verstreuten Mapping-Pfad.

## Event-Mapping

`TaliEvent` beschreibt appweite Ereignisse, die künftig Emotionen auslösen können:

| Event | Emotion |
| --- | --- |
| `appReady` | `neutral` |
| `userIdle` | `bored` |
| `chatOpened` | `neutral` |
| `userMessageSent` | `thinking` |
| `aiThinking` | `thinking` |
| `aiResponseSuccess` | `happy` |
| `aiResponseError` | `surprised` |
| `wordCorrect` | `happy` |
| `wordWrong` | `embarrassed` |
| `pointsGained` | `starEyes` |
| `dailyGoalReached` | `party` |

## Emotion-Controller

`TaliEmotionController` verwaltet die aktuelle Emotion als Riverpod-Notifier. Er unterstützt:

- direkte Emotionen über `setEmotion(...)`
- temporäre Emotionen über `showTemporaryEmotion(...)`
- Event-basierte Emotionen über `handleEvent(...)`
- Rücksetzen über `reset()`

Temporäre Timer werden bei neuen Emotionen abgebrochen und beim Dispose sauber gecancelt.

## Asset-Namensschema

Die Assets liegen unter `assets/images/mascot/` und folgen dem Schema:

- `tali_female_<emotion>.png`
- `tali_male_<emotion>.png`

Beispiele:

- `tali_female_neutral.png`
- `tali_female_star_eyes.png`
- `tali_male_neutral.png`
- `tali_male_party.png`

## Fallback-Regel

Die Asset-Auflösung läuft zentral über `TalvoriMascotAssets.spiritPathFor(...)`.

Regel:

1. `style + emotion` wird direkt aufgelöst.
2. Wenn für eine Emotion kein Asset gemappt ist, wird auf `neutral` derselben Variante zurückgefallen.
3. Wenn auch das fehlt, wird das vorhandene Standard-Spirit-Asset verwendet.

Aktuell fällt `thinking` bewusst auf `neutral` derselben Variante zurück, bis ein dediziertes Thinking-Asset existiert.

## Aktuell angebundene Events

Sicher angebunden sind Companion-/Chat-Zustände:

- Chat geöffnet: `chatOpened`
- Nutzer sendet Nachricht: `userMessageSent`
- KI denkt: `aiThinking`
- KI-Antwort erfolgreich: `aiResponseSuccess`
- KI-Fehler: `aiResponseError`
- App/Companion wird geweckt: `appReady`

## Bewusst offene Events

Folgende Events sind vorbereitet, aber noch nicht breit in Lern- oder Belohnungslogik verdrahtet:

- `wordCorrect`
- `wordWrong`
- `pointsGained`
- `dailyGoalReached`
- `userIdle`

Diese Hooks sollen später an echte, sichere Ereignisse angeschlossen werden, ohne zufällige Emotionen einzuführen.

## Aktueller Stand

Die technische Grundlage für gezielte Tali-Emotionen ist vorhanden. Male/Female-Varianten bleiben erhalten, Legacy-Mood und neue Emotion sind zentral vermittelt, und fehlende Assets fallen robust auf neutrale Varianten zurück.
