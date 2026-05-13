# 04 SRS Engine Theory

Stand: 2026-05-13

## Ziel

Die neue SRS-Engine soll stabil, verständlich und testbar sein. Sie soll nicht maximal komplex sein, sondern verlässlich lernen lassen:

- A-SRS: freies/intensives Lernen ohne hartes Tageslimit.
- T-SRS: zeitbasierte Langzeitwiederholung mit kontrollierten Intervallen.
- Hybrid: frühe Stufen frei/intensiv, höhere Stufen zeitbasiert.

Technische Begriffe wie A-SRS, T-SRS und Hybrid sollen intern erlaubt sein, aber nicht in der Nutzeroberfläche erscheinen.

## Empfohlene Nutzernamen

- `time` / T-SRS: **Nach Zeitplan**
- `adaptive` / A-SRS: **Intensiv lernen**
- `hybrid`: **Ausgewogen lernen**

Alternative für A-SRS: **Freies Lernen**. Empfehlung: **Intensiv lernen**, weil der Prüfungsfall und hohes Tagesvolumen klarer werden.

## Bedeutung von S0-S5

Interne Stufen:

- S0: Neu, noch nicht eingeführt.
- S1: Gerade begonnen, sehr unsicher.
- S2: Erste Wiederholungen geschafft, noch fragil.
- S3: Grundsätzlich abrufbar, braucht Festigung.
- S4: Sicher, aber noch nicht langfristig stabil.
- S5: Langzeitstufe, weiterhin wiederholbar.

Nutzernahe Namen:

- S0: Neu
- S1: Begonnen
- S2: Im Aufbau
- S3: Gefestigt
- S4: Sicher
- S5: Langzeit

S5 ist kein endgültiges Verschwinden. S5 bedeutet: seltenere, aber weiterhin mögliche Wiederholung.

## Grunddaten pro Karte

Pro `category_id + word_id + mode_id`:

- `stage`
- `pass_count`
- `next_due_at`
- `last_reviewed_at`
- `total_correct`
- `total_wrong`
- `lapses`
- `ever_introduced`
- `introduced_at`
- `s5_reached_at`
- optionales Anzeige-/Statistikfeld `is_mastered`, aber nicht als Engine-Regel

## Rolle von pass_count

`pass_count` zählt richtige Antworten innerhalb der aktuellen Stufe. Bei Aufstieg wird er auf 0 gesetzt.

Empfohlene Schwellen:

- S0 -> S1: 1 richtige Antwort
- S1 -> S2: 2 richtige Antworten
- S2 -> S3: 2 richtige Antworten
- S3 -> S4: 3 richtige Antworten
- S4 -> S5: 3 richtige Antworten
- S5 bleibt S5; richtige Antworten setzen nur den nächsten Termin und stärken Langzeitstatus

Bewertung: Diese Regel ist sinnvoll, weil höhere Stufen mehr Stabilität verlangen. Sie verhindert, dass eine Karte an einem Tag zu schnell dauerhaft als gelernt gilt.

Entscheidung für Version 1: S5 erhält keinen separaten Abschlussstatus. Richtige S5-Antworten setzen nur das nächste Wiederholungsdatum gemäß Modus. S5 bleibt wiederholbar.

## Rolle von Fehlern

Bei falscher Antwort:

- `pass_count` wird auf 0 gesetzt.
- Karte wird innerhalb der Session erneut eingeplant.
- `lapses` wird erhöht.
- Stufe fällt kontrolliert zurück oder bleibt je nach Modus/Stufe.

Empfohlene Rückfallregel:

- S0 falsch: bleibt S0.
- S1 falsch: bleibt S1.
- S2 falsch: fällt auf S1.
- S3 falsch: fällt auf S2.
- S4 falsch: fällt auf S3.
- S5 falsch: fällt auf S3.

Entscheidung: S5 fällt bei falscher Antwort auf S3. S4 wäre zu mild, weil ein Fehler in S5 eine echte Instabilität zeigt. S0 wäre zu hart, weil die Karte nicht völlig neu ist.

## Rolle von next_due_at

- T-SRS: zentrale Fälligkeitsregel.
- Hybrid: zentral für S3-S5, weniger hart für S0-S2.
- A-SRS: nicht als harte Sperre verwenden, höchstens für Vorschläge/Sortierung.

Eine Karte darf in A-SRS nicht blockiert werden, nur weil `next_due_at` in der Zukunft liegt.

## Rolle von is_mastered

Entscheidung: `is_mastered` wird nicht als harter Engine-Zustand verwendet.

- S5 bleibt der höchste aktive und wiederholbare Langzeitstatus.
- Karten in S5 dürfen nicht aus der Wiederholung verschwinden.
- `is_mastered` darf höchstens später als Anzeige- oder Statistikfeld betrachtet werden.
- `is_mastered` darf niemals eine Regel sein, die Karten aus Queue, Fälligkeit oder Engine entfernt.

## T-SRS: Nach Zeitplan

Ziel: langfristige Wiederholung mit klaren Zeitabständen.

Version-1-Intervalle:

- S0: sofort / neu
- S1: 1 Tag
- S2: 3 Tage
- S3: 7 Tage
- S4: 14 Tage
- S5: 30 Tage

Begründung:

- Einfache Stufenmodelle brauchen kurze frühe Abstände.
- 1/3/7/14/30 Tage ist leicht erklärbar und konservativ.
- S5 bleibt wiederholbar und ist kein endgültiger Abschlusszustand.

T-SRS arbeitet vollständig zeitbasiert. T-SRS darf S1-Karten am selben Tag zur Festigung erneut zeigen, aber ein weiterer Aufstieg am selben Tag ist nicht erlaubt. Beispiel: S0 richtig -> S1. Am selben Tag erneut richtig -> bleibt S1. Erst ab dem nächsten Tag kann S1 zu S2 werden.

## A-SRS: Intensiv lernen

Ziel: Nutzer können bewusst viele Karten an einem Tag durcharbeiten, z. B. vor einer Prüfung.

Regeln:

- kein hartes Tageslimit
- keine harte Sperre durch Zeitintervalle
- Karten dürfen bei ausreichender Leistung auch am selben Tag bis S5 aufsteigen
- Session-interne Wiederholung ist Pflicht
- Aufstieg braucht mehrere richtige Antworten pro Stufe
- Fehler führen zu Requeue nach ca. 10/5 anderen Karten und bei dritten Fehlern ans Session-Ende
- S5 kann erreicht werden, aber nicht durch einmaliges Durchklicken

A-SRS unterscheidet sich von "alles sofort gelernt" dadurch, dass `pass_count` und Requeue greifen. Viele Karten können bearbeitet werden, aber stabile Stufen werden nicht verschenkt.

Die vorgeschlagene Aufstiegsregel ist für Version 1 sinnvoll und wird übernommen:

- S0 -> S1 nach 1 richtiger Antwort
- S1 -> S2 nach 2 richtigen Antworten
- S2 -> S3 nach 2 richtigen Antworten
- S3 -> S4 nach 3 richtigen Antworten
- S4 -> S5 nach 3 richtigen Antworten

Diese Regel schützt ohne Zeitlimit vor zu schnellem Scheinerfolg, weil höhere Stufen mehrere bestätigte Abrufe brauchen. Sie passt zum Prüfungsfall, da hohe Lernmenge möglich bleibt, aber Fehler und fehlende Wiederholung den Aufstieg bremsen.

## Hybrid: Ausgewogen lernen

Ziel: aktives Lernen neuer/unsicherer Karten plus zeitbasierte Stabilisierung.

Empfohlene Logik:

- S0-S2: A-SRS-artig, also aktiv lernbar und nicht hart durch Tagesintervalle blockiert.
- S3-S5: T-SRS-artig, also durch `next_due_at` gesteuert.
- Intervalle kürzer als T-SRS, damit Hybrid lebendiger bleibt.

Version-1-Logik:

- S0 bis S2: eher wie A-SRS / Intensiv lernen, also freier und nicht hart zeitblockiert
- S3: 1 Tag
- S4: 3 Tage
- S5: 5 Tage

Hybrid arbeitet damit in S0-S2 aktiver als T-SRS und in S3-S5 zeitbasiert mit kürzeren Intervallen. S5-Karten verschwinden nicht dauerhaft.

## Wann gilt eine Karte als gelernt?

Für die Engine:

- gelernt = `stage == S5`
- aber weiterhin wiederholbar

Für die UI:

- S5 kann als "Langzeit" oder "Sehr sicher" angezeigt werden.
- Kein Begriff "fertig für immer".

## Gezielt üben

Entscheidung für Version 1: **Gezielt üben** verändert nicht die normale SRS-Progression.

- keine Änderung an `stage`
- keine Änderung an `pass_count`
- keine Änderung an `next_due_at`
- keine Änderung am S5-Status
- richtige und falsche Antworten dürfen später optional als separate Übungsstatistik gespeichert werden

Gezielt üben ist damit ein Fokus-Training außerhalb der normalen SRS-Progression. Es darf nicht heimlich Aufstieg, Rückfall oder Fälligkeit verändern.

## Regeln, die nie verletzt werden dürfen

- Eine falsche Karte darf nicht dauerhaft verschwinden.
- Eine aktive Session darf durch Neustart nicht zurückgesetzt werden.
- Fortschritt ist pro `category_id + word_id + mode_id` getrennt.
- S5 ist wiederholbar.
- `is_mastered` entfernt keine Karten aus der Engine.
- Gezielt üben verändert in Version 1 keine SRS-Progression.
- A-SRS darf keine harte Tagesblockade haben.
- A-SRS darf bei ausreichender Leistung am selben Tag bis S5 aufsteigen.
- T-SRS darf keine Mehrfachaufstiege am selben Tag erlauben; S1 darf aber zur Festigung erneut gezeigt werden.
- Neue S0-Karten dürfen Wiederholungen nicht verdrängen.
- Queue-Regeln müssen deterministisch testbar sein.
