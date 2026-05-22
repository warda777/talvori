# Fortschritt & Liga Hub

Der obere rechte Home-Button öffnet den Bereich `Fortschritt`.

## Ziel

Der Hub verbindet lokale Lernmotivation, Belohnungen und Statistik in einem Talvori Dark-Neon-Bereich:

- `Liga`: wöchentliche Liga-Idee mit fairem Reset jeden Montag.
- `Belohnungen`: lokale Badges und vorbereitete kosmetische Rewards.
- `Statistik`: lokale Wort- und Lernübersicht.

## Lokale/offline-first Umsetzung

Der aktuelle Stand verwendet ausschließlich lokale Daten:

- alle lokalen Wörter
- `Meine Wörter`
- lokale Favoriten
- bekannte Wörter aus lokal gelesenen SRS-Fortschritten
- offene Übersetzungen über lokale Translation-Status

Die Seite schreibt beim Öffnen keine SRS-Werte, startet keine Session und vergibt keine Punkte für bloßes Anschauen.

## Wochenliga

Die Online-Liga ist vorbereitet, aber noch nicht als echtes Supabase-Ranking aktiv.
Deshalb zeigt die UI keine erfundenen fremden Nutzer. Sichtbar sind:

- `Du` mit lokalen Lernpunkten
- `Online-Liga vorbereitet`
- `Wöchentlicher Reset`

Spätere Punkte sollen nur aus echten Lernaktionen entstehen, z. B. richtige Antworten, abgeschlossene Sessions und Wiederholungen. Wochenreset bleibt wichtig, damit neue Nutzer regelmäßig faire Chancen haben.

## Belohnungen

Badges lesen vorhandene lokale Daten, wo möglich:

- Erste 10 Wörter
- Erste 50 Wörter
- Übersetzungsmeister
- Kategorie-Champion
- Neon-Rahmen
- Aussprache-Profi als `bald verfügbar`

Nicht vorhandene Unlock-Logik wird nicht als echt freigeschaltet dargestellt.

## Statistik

Die Statistik zeigt lokale Werte:

- Wörter insgesamt
- Meine Wörter
- Favoriten
- bekannte Wörter
- offene Übersetzungen
- lokale Lernpunkte

Antworten, Lernzeit und Trefferquote sind als lokale Statistik vorbereitet, werden aber nicht erfunden, solange keine verlässliche lokale Quelle vorhanden ist.

## Schutz

- keine neue Serverlogik
- kein Supabase-Leaderboard in diesem Schritt
- keine Fake-Online-Daten
- keine Secrets
- kein Server-Push
- keine SRS-Änderung beim Anzeigen
