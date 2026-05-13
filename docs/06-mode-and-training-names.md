# 06 Mode And Training Names

Stand: 2026-05-13

## Problem

Die aktuelle UI verwendet technische Begriffe:

- `T-SRS`
- `A-SRS`
- `Hybrid`
- `AUTO`
- `T1-T5`, `A1-A5`, `H1-H5`
- `SINGLE`
- Hinweise wie `Long-press for Hybrid`

Diese Begriffe sind für Entwickler hilfreich, aber für normale Nutzer unnötig technisch. Nutzer wollen wissen, was der Modus für ihr Lernen bedeutet.

## Lernmodi

### T-SRS

Mögliche Namen:

- Nach Zeitplan
- Geplant wiederholen
- Langfristig lernen
- Ruhig wiederholen

Bewertung:

- **Nach Zeitplan** ist klar, kurz und beschreibt den Kern.
- "Langfristig lernen" klingt gut, erklärt aber die Bedienlogik weniger konkret.

Empfehlung: **Nach Zeitplan**

### A-SRS

Mögliche Namen:

- Intensiv lernen
- Freies Lernen
- Nach Können
- Prüfungstraining

Bewertung:

- **Intensiv lernen** passt zur Anforderung, viele Wörter an einem Tag bearbeiten zu können.
- "Freies Lernen" erklärt fehlende Limits, klingt aber weniger lernzielorientiert.
- "Nach Können" klingt angenehm, aber etwas abstrakt.
- "Prüfungstraining" ist zu eng.

Empfehlung: **Intensiv lernen**

Optionaler Untertitel: "Viele Wörter aktiv durcharbeiten."

### Hybrid

Mögliche Namen:

- Ausgewogen lernen
- Gemischt lernen
- Aktiv und geplant
- Balance

Bewertung:

- **Ausgewogen lernen** erklärt die Mischung am natürlichsten.
- "Gemischt lernen" ist verständlich, aber weniger wertig.
- "Aktiv und geplant" ist präzise, aber etwas sperrig.

Empfehlung: **Ausgewogen lernen**

## Trainingsbereiche

### S0-S5

Aktuell: `AUTO`, teilweise "Neu + Wiederholen"

Mögliche Namen:

- Alles lernen
- Neu und wiederholen
- Normale Session

Empfehlung: **Alles lernen**

Warum: kurz, selbsterklärend, nicht technisch.

### S1-S5

Aktuell: `T1-T5/A1-A5/H1-H5`

Mögliche Namen:

- Nur wiederholen
- Ohne neue Wörter
- Wiederholen

Empfehlung: **Nur wiederholen**

Warum: macht klar, dass S0 nicht eingeführt wird.

### Single

Aktuell: `SINGLE`

Mögliche Namen:

- Gezielt üben
- Eine Stufe üben
- Fokus üben

Empfehlung: **Gezielt üben**

Warum: beschreibt Absicht statt Technik.

## Stufenlabels

Interne Stufen S0-S5 können in Debug/Tests bleiben. In der UI besser:

- S0: Neu
- S1: Begonnen
- S2: Im Aufbau
- S3: Gefestigt
- S4: Sicher
- S5: Langzeit

[ENTSCHEIDUNG NOTWENDIG] Ob die UI die Kürzel S0-S5 komplett versteckt oder klein zusätzlich anzeigt. Für normale Nutzer ist komplettes Verstecken besser.

## Empfohlene UI-Struktur

Statt Switch und Longpress:

- Button 1: **Nach Zeitplan**
- Button 2: **Intensiv lernen**
- Button 3: **Ausgewogen lernen**

Trainingsbereiche:

- **Alles lernen**
- **Nur wiederholen**
- **Gezielt üben**

Nicht mehr in der Nutzeroberfläche verwenden:

- T-SRS
- A-SRS
- Hybrid
- AUTO
- SINGLE
- T1/T2/A1/H1 etc.
- Longpress als versteckte Moduswahl

## Klare Empfehlung

Für den Launch:

- T-SRS -> **Nach Zeitplan**
- A-SRS -> **Intensiv lernen**
- Hybrid -> **Ausgewogen lernen**
- S0-S5 -> **Alles lernen**
- S1-S5 -> **Nur wiederholen**
- Single -> **Gezielt üben**

