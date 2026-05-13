# 09 Risk List

Stand: 2026-05-13

## Technische Risiken

### Falsche Queue-Logik

Risiko: Karten erscheinen zu früh, zu spät oder verschwinden.

Gegenmaßnahme:

- Queue-Regeln vor Implementierung dokumentieren.
- Queue-Builder isoliert testen.
- Review-Events und Session-Items persistieren.

### Zu viele neue Karten

Risiko: Nutzer werden später von Wiederholungen überrollt.

Gegenmaßnahme:

- Tages-/Sessionlimits in T-SRS und Hybrid.
- A-SRS bewusst frei, aber mit Warn-/Hinweislogik.
- Fehlerquote senkt neue Karten.

### Datenverlust beim Entfernen von Supabase

Risiko: bestehende Wörter, Kategorien oder Fortschritte gehen verloren.

Gegenmaßnahme:

- Export-/Importentscheidung treffen.
- Supabase erst entfernen, wenn lokale Daten vollständig sind.
- Migrationspfad testen.

### UI-Brüche

Risiko: bestehende Lernscreens brechen durch neue Modusstruktur.

Gegenmaßnahme:

- UI erst nach Engine-/Datenmodell-Stabilisierung ändern.
- Moduslabels zentralisieren.
- keine versteckten Longpress-Aktionen.

### Zu große Refactoring-Schritte

Risiko: Regressionen sind nicht mehr nachvollziehbar.

Gegenmaßnahme:

- kleine PR-/Commit-Schritte.
- erst Interfaces, dann Implementierung.
- keine gleichzeitige UI-/DB-/Engine-Großänderung.

### Fehlende Tests

Risiko: SRS-Fehler fallen erst in Nutzung auf.

Gegenmaßnahme:

- natürliche Testfälle zuerst.
- Unit-Tests vor Engine-Austausch.
- SQLite-Sessiontests.

### Nicht fortgesetzte Sessions

Risiko: Neustart erzeugt neue Session und verliert Fehler/Reihenfolge.

Gegenmaßnahme:

- eindeutige aktive Session pro Kategorie/Modus/Bereich.
- Session-Queue persistieren.
- Start-Button lädt aktive Session statt neuer Queue.

### Manipulierbare Sessions

Risiko: Abbruch/Neustart setzt Fehler zurück.

Gegenmaßnahme:

- Review-Event sofort speichern.
- Requeue sofort speichern.
- Session-Items nicht nur im Speicher halten.

## Fachliche Risiken

### Zu schnelles Erreichen von S5

Risiko: Nutzer glauben, Karten seien gelernt, obwohl sie nur kurz wiedererkannt wurden.

Gegenmaßnahme:

- `pass_count` pro Stufe.
- höhere Stufen brauchen mehr richtige Antworten.
- T-SRS limitiert Tagesaufstiege.

### S5 als endgültiger Zustand

Risiko: Karten verschwinden dauerhaft.

Gegenmaßnahme:

- S5 bleibt wiederholbar.
- `is_mastered` nicht als Ausschluss verwenden.

### Rückfälle zwischen Stufen erzeugen Unwucht

Risiko:

- zu viele Karten in S2
- zu wenige in S3
- zu viele fällige Wiederholungen
- zu wenige neue Karten

Gegenmaßnahme:

- einfache Rückfallregeln.
- keine komplexen Kaskaden ohne Simulation.
- Queue priorisiert fällige Karten.

### Unklare Modus-Bezeichnungen

Risiko: Nutzer wählen falschen Modus.

Gegenmaßnahme:

- `Nach Zeitplan`
- `Intensiv lernen`
- `Ausgewogen lernen`
- keine Fachbegriffe in UI.

### Launch-Verzögerung

Risiko: zu große Offline-/SRS-/UI-Sanierung gleichzeitig.

Gegenmaßnahme:

- zuerst stabiler lokaler Kern.
- optionale Features verschieben.
- keine Perfektionsfalle bei SRS-Komplexität.

## Offene Hochrisiko-Entscheidungen

- [ENTSCHEIDUNG NOTWENDIG] S5 falsch -> S3 oder S4.
- [ENTSCHEIDUNG NOTWENDIG] `is_mastered` behalten oder entfernen.
- [ENTSCHEIDUNG NOTWENDIG] Supabase-Datenmigration für bestehende Nutzer.
- [ENTSCHEIDUNG NOTWENDIG] Wortimport/DeepL für Offline-Launch.
- [ENTSCHEIDUNG NOTWENDIG] exakte T-SRS-/Hybrid-Intervalle.

