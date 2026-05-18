# 140 Local Offline Learning System State

## 1. Ausgangslage

Der lokale Offline-Lernflow wurde schrittweise aus Debug-Pfaden in die echte UI integriert.

Ziel war ein funktionsfähiger Offline-first-Lernflow, der im lokalen Pfad ohne Supabase-Abhängigkeit arbeiten kann. Die Simulator-Gesamtabnahme wurde erfolgreich durchgeführt.

Geprüft wurden:

- Zeitplan
- Limitlos
- Kombination
- Übungsmodus Alle Stufen
- Übungsmodus Einzelstufe
- StageInspector
- Vocabs / Wortdetail / Verlauf

## 2. Hauptflow

Der bestätigte lokale Hauptflow:

```text
Wortwelten
→ CategoryDetail local
→ Start
→ LearnMode local
```

Zusätzlicher Vocabs-/Detailflow:

```text
CategoryDetail local
→ Vocabs
→ LocalWordListScreen
→ LocalWordDetailScreen
```

## 3. Wortwelten

Der lokale WordHub heißt sichtbar **Wortwelten**.

Aktueller Stand:

- WordHub-Kacheln sind die Lernkategorien.
- `displayLabel` und `localCategoryId` sind getrennt.
- Sichtbare Labels bleiben fachlich, z. B. `Health & Fitness`.
- Technische IDs bleiben intern, z. B. `seed-category-basics`.
- Counts kommen lokal.
- nicht gemappte Kacheln bleiben sichtbar, starten aber nicht falsch auf eine andere Kategorie.

## 4. CategoryDetail local

CategoryDetail local ist der zentrale Einstieg in Kategorie, Modus, Fortschritt und Wiederholung.

Aktueller Stand:

- Wheel zeigt WordHub-Kategorien.
- `selectedCategoryId` folgt der Wheel-Auswahl.
- `selectedMode` steuert die StageCounts.
- Vocabs-Counter kommt lokal.
- Start nutzt `selectedCategoryId` + `selectedMode`.
- Reset setzt nur aktuelle Kategorie + aktuellen Modus zurück.
- Reset bereinigt stale LearnMode-State und Review-History.
- andere Kategorien und andere Modi bleiben isoliert.

## 5. SRS-Modi

### Zeitplan

Zeitplan entspricht T-SRS.

Aktueller Stand:

- 20 neue Karten am ersten Tag einer neuen Kategorie.
- keine weitere neue Nachladung am selben Tag über dieses Limit hinaus.
- Due-State und Countdown werden kommuniziert.
- nicht fällige Karten werden verständlich angezeigt.
- Wiederholungsmodus ist progress-neutral.

### Limitlos

Limitlos entspricht A-SRS.

Aktueller Stand:

- Karten werden sinnvoll gemischt.
- neue Karten und Wiederholungen kommen ausgewogener zusammen.
- Fortschritt bis S5 funktioniert.
- Reset funktioniert mode- und category-isoliert.

### Kombination

Kombination entspricht Hybrid.

Aktueller Stand:

- S0-S2 verhalten sich frei/intensiv.
- ab S3 greift Zeitlogik.
- Countdown und Blocked-State werden angezeigt.
- Wiederholungsmodus ist progress-neutral.
- kein automatischer Progress-Reset.

## 6. LearnMode local

LearnMode local ist im lokalen Pfad produktiv nutzbar.

Aktueller Stand:

- Karte erscheint.
- Tap/Flip funktioniert.
- Swipe links/rechts funktioniert.
- StageCounts werden angezeigt.
- Plasma-Link bleibt aktiv.
- farbiger Pulse zeigt Review-Feedback.
- betroffener Switch leuchtet temporär farbig auf.
- Completed-State ist sichtbar.
- Weiterlernen / Replay verhält sich je nach Modus korrekt.

## 7. Übungsmodus

Der Übungsmodus ist ein progress-neutraler Übungsbereich.

Aktueller Stand:

- Einstieg über Alle Stufen.
- Einstieg über Einzelstufe.
- progress-neutral.
- keine echten Stage-Switches im Übungsmodus.
- eigene UI.
- keine Veränderung von:
  - `stage`
  - `pass_count`
  - `wrong_count`
  - `next_due_at`
  - normalen SRS-Sessions
  - CategoryDetail-Counts

## 8. StageInspector

Der StageInspector ist ein gemeinsames lokales Sheet für CategoryDetail und LearnMode.

Aktueller Stand:

- Tap auf Merkstufe in CategoryDetail öffnet das Sheet.
- Tap auf Merkstufe in LearnMode öffnet dasselbe Sheet.
- Wörter pro Stufe werden angezeigt.
- Legende passt zur jeweiligen Stufe.
- Feedback-Farben sind sichtbar.
- manuelle Rückstufung ist nur nach unten möglich.
- Counts aktualisieren sich nach Rückstufung.
- category-/mode-isolierte Datenbasis.

## 9. Vocabs / Wortliste / Wortdetail

Der lokale Vocabs-Pfad ist angebunden.

Aktueller Stand:

- lokale Wortliste.
- Suche.
- Sortierung.
- Wortdetail.
- Lernstatus.
- Review-History / Verlauf.
- richtige und falsche Reviews sind sichtbar.
- Stage-Wechsel und Wiederholungen sind nachvollziehbar.

## 10. Persistenz und Manipulationsschutz

Der lokale SRS-/Session-Pfad ist gegen Manipulation und App-Neustart abgesichert.

Aktueller Stand:

- Sessions sind persistent.
- Queue bleibt stabil.
- `current_position` bleibt erhalten.
- DB-Reopen wurde getestet.
- Controller-/ViewModel-Persistenz wurde getestet.
- kein Fortschrittsverlust durch App-Neustart.
- aktive Sessions werden fortgesetzt statt neu gemischt.
- Reset ist ein expliziter Pfad und kein normales Resume-Verhalten.

## 11. Tests

Wichtige Testbereiche:

- `test/core/srs/`
- `test/core/local_database/`
- `test/features/learn_mode_screen_local_branch_test.dart`
- `test/features/category_detail_screen_local_branch_test.dart`
- `test/features/local_word_list_screen_test.dart`
- `test/features/local_word_detail_screen_test.dart`
- `test/core/local_database/local_stage_inspector_provider_test.dart`
- `test/core/local_database/local_time_replay_cards_provider_test.dart`
- `test/core/local_database/local_practice_cards_provider_test.dart`

Diese Tests decken Engine-Regeln, lokale Persistenz, Session-Manipulationsschutz, Replay, Practice Mode, StageInspector, CategoryDetail, LearnMode und lokale Wortlisten-/Detailpfade ab.

## 12. Bekannte offene Punkte

- weitere Kategorien importieren/mappen
- `Gezielt üben` ggf. weiter fachlich ausbauen
- lokale Importpipeline
- `profile_id` / Multi-Profil später
- Analyzer-Alt-Warnungen in älteren UI-Dateien separat bereinigen
- UI-Feinschliff später möglich

## 13. Nächster sinnvoller Schritt

Sinnvolle nächste Richtungen:

- lokale Kategorie-/Wortimportstrategie planen
- Analyzer-/Alt-Code-Cleanup separat planen
- `Gezielt üben` weiter ausbauen
