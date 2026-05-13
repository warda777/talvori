# 05 New Card Distribution Strategy

Stand: 2026-05-13

## Ziel

Neue Karten aus S0 sollen kontrolliert eingeführt werden. Die App soll weder die Queue leer laufen lassen noch Nutzer mit zu vielen neuen Karten überlasten.

Wiederholungen sind der Normalfall wichtiger als neue Karten. Ausnahme: Der Nutzer wählt bewusst **Intensiv lernen**.

## Grundprinzipien

- Fällige Wiederholungen haben Vorrang.
- Neue Karten werden dosiert eingemischt.
- S0 darf nicht automatisch leergezogen werden.
- Session-Größe und Tageslimit hängen vom Modus ab.
- Fehler und Requeues haben höhere Priorität als neue Karten.
- Wenn keine Wiederholungen fällig sind, darf die App neue Karten anbieten, aber nicht erzwingen.

## Trainingbereiche

Empfohlene Nutzerlabels:

- S0-S5: **Alles lernen**
- S1-S5: **Nur wiederholen**
- Single: **Gezielt üben**

Interne Bedeutung:

- `all`: neue Karten plus Wiederholungen
- `review_only`: keine neuen S0-Karten
- `single`: ausgewählte Stufe/Bereich, ohne normalen SRS-Aufstieg in Version 1

## Session-Größe

Empfehlung:

- Standard-Session: 20 Karten
- Kurze Session: 10 Karten
- Lange/Intensiv-Session: 40 Karten
- Hard Cap pro erzeugter Queue: 80 Karten

Eine Session darf durch Requeues länger wirken, aber die initiale Queue sollte überschaubar bleiben.

Für Version 1 kann die Engine mit einer Standard-Session von 20 Karten planen. Eine spätere UI-Auswahl zwischen 10/20/40 bleibt möglich, blockiert aber die Engine nicht.

## T-SRS: Nach Zeitplan

Ziel: ruhige, langfristige Wiederholung.

Neue Karten:

- Standard: max. 10 neue Karten pro Tag und Kategorie.
- Pro Session: max. 5 neue Karten.
- Verhältnis: mindestens 70% Wiederholung, höchstens 30% neu.
- Wenn mehr als 20 Wiederholungen fällig sind: keine neuen Karten.
- Wenn 1-20 Wiederholungen fällig sind: neue Karten nur bis Session aufgefüllt ist.
- Wenn keine Wiederholungen fällig sind: bis zu 5 neue Karten anbieten.

T-SRS darf S0 nicht leerziehen. Bei großen Kategorien sollte die App lieber über viele Tage dosieren.

## A-SRS: Intensiv lernen

Ziel: bewusst hohe Lernmenge ermöglichen.

Neue Karten:

- kein hartes Tageslimit
- pro Session initial max. 20 neue Karten
- danach weitere neue Karten nur, wenn der Nutzer aktiv fortsetzt
- Verhältnis bei normaler Intensiv-Session: 50-60% Wiederholung, 40-50% neu
- bei Prüfungssituation darf der Nutzer mehrere Sessions nacheinander spielen
- Karten dürfen bei ausreichender Leistung auch am selben Tag bis S5 aufsteigen

Schutz gegen Scheinstabilität:

- Aufstieg braucht `pass_count`.
- Fehler kommen nach ca. 10 Karten zurück.
- S5 braucht mehrere richtige Antworten in mehreren Stufen.
- S0 -> S1 ist leicht, S3-S5 werden deutlich strenger.

A-SRS darf viel ermöglichen, aber nicht so tun, als sei schnelles Durchklicken Langzeitlernen.

Fehlerregel für neue Karten in A-SRS:

- Wenn innerhalb der letzten 10 Antworten mindestens 3 Fehler auftreten, soll die App auch in A-SRS keine neuen Karten automatisch nachschieben.
- Anders als T-SRS/Hybrid darf A-SRS dem Nutzer aber bewusstes Fortsetzen mit neuen Karten erlauben, z. B. über "trotzdem weiter intensiv lernen".
- Ohne bewusste Fortsetzung laufen aktive Wiederholungen und Requeues weiter.

## Hybrid: Ausgewogen lernen

Ziel: neue Karten aktiv lernen, stabile Karten zeitnah wiederholen.

Neue Karten:

- Standard: max. 15 neue Karten pro Tag und Kategorie.
- Pro Session: max. 8 neue Karten.
- Verhältnis: 60-70% Wiederholung, 30-40% neu.
- S0-S2 dürfen aktiver bearbeitet werden.
- S3-S5 folgen Due-Terminen.
- Wenn viele S3-S5 fällig sind: neue Karten stark reduzieren.

Hybrid soll sich aktiver als T-SRS anfühlen, aber kontrollierter als A-SRS.

## Prioritätsreihenfolge in der Queue

Empfohlene Reihenfolge:

1. Retry-Karten aus Fehlern, deren `retry_after_cards` erreicht ist.
2. Überfällige Wiederholungen S3-S5.
3. Fällige Wiederholungen S1-S2.
4. Neue Karten aus S0 gemäß Moduslimit.
5. Nicht fällige Karten nur im A-SRS oder in S0-S2-Hybrid.

## Wenn keine fälligen Wiederholungen vorhanden sind

- T-SRS: bis zu 5 neue Karten anbieten oder "Heute ist alles erledigt" zeigen.
- A-SRS: neue Karten oder freie Wiederholung anbieten.
- Hybrid: neue Karten bis Tages-/Sessionlimit anbieten; alternativ S1-S2 festigen.

## Wenn zu viele Wiederholungen fällig sind

Regel:

- Session bleibt begrenzt.
- Die ältesten/überfälligsten Karten zuerst.
- Neue Karten werden pausiert.
- UI sollte nicht bestrafen, sondern ruhig eine "Wiederholungen zuerst"-Session starten.

Schwellen:

- über 20 fällige Karten: neue Karten in T-SRS aussetzen.
- über 30 fällige Karten: neue Karten in Hybrid stark reduzieren oder aussetzen.
- A-SRS: Nutzer darf trotzdem neue Karten nehmen, aber UI sollte "Viele Wiederholungen offen" anzeigen.

## Fehlerquote und neue Karten

Version-1-Regel:

- Wenn innerhalb der letzten 10 Antworten mindestens 3 Fehler auftreten, werden für diese Session keine neuen S0-Karten mehr automatisch eingeführt.
- Bereits aktive Wiederholungen laufen weiter.
- Diese Regel gilt strikt für T-SRS und Hybrid.
- Für A-SRS gilt sie als Auto-Nachschub-Bremse, aber nicht als harte Sperre, wenn der Nutzer bewusst intensiv weiterlernen möchte.

## Schutz gegen zu schnelles Leerlaufen von S0

- Tageslimit in T-SRS/Hybrid.
- Sessionlimit in allen Modi.
- Wiederholungen vor neuen Karten.
- "Nur wiederholen" Bereich führt keine neuen Karten ein.
- A-SRS führt neue Karten nur in aktiven Sessions ein, nicht automatisch im Hintergrund.

## Schutz gegen Überforderung

- Standard-Session klein halten.
- Neue Karten automatisch stoppen, wenn in den letzten 10 Antworten mindestens 3 Fehler auftreten.
- Neue Karten reduzieren, wenn viele Requeues entstehen.
- Keine großen automatischen Refills.
- Nach einer fehlerreichen Session eher Wiederholen als Neu anbieten.

Die Fehlerquote-Regel ist absichtlich einfach und sessionnah. Sie verhindert Überforderung, ohne ein komplexes Adaptionsmodell einzuführen.
