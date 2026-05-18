# Local Time/Hybrid Replay Final State

## 1. Ausgangslage

- Zeitplan hatte bereits Due-/Empty-State und einen progress-neutralen Wiederholungsmodus.
- Kombination hatte bereits Due-/Blocked-Kommunikation fuer wartende Stufen.
- Danach wurde Replay fuer Kombination ergaenzt.
- Der Replay-Datenpfad wurde von einer reinen Time-Loesung zu einem gemeinsamen lokalen Replay-Pfad fuer Zeitplan und Kombination generalisiert.
- Aktueller Referenz-Commit: `17291bf feat: add time and hybrid replay states`.

## 2. Was funktioniert jetzt

- Zeitplan zeigt bei nicht faelligen Karten einen verstaendlichen Empty-State.
- Kombination zeigt bei nicht faelligen Karten einen verstaendlichen Empty-State.
- In diesen Wartezustaenden ist `Starten/Fortsetzen` deaktiviert.
- Der Button `Im Wiederholungsmodus ueben` bleibt verfuegbar, wenn Replay-Karten vorhanden sind.
- Replay zeigt Karten aus der letzten relevanten Session.
- Replay funktioniert fuer Zeitplan und Kombination.
- Replay ist progress-neutral.
- Replay-Swipe veraendert nicht:
  - `stage`
  - `pass_count`
  - `wrong_count`
  - `next_due_at`
- Der Replay-Kartenbereich scrollt nicht stoerend und bleibt swipe-freundlich.

## 3. Due-/Blocked-Anzeige

- CategoryDetail kann blockierte bzw. wartende Stufen anzeigen.
- StageInspector zeigt Faelligkeit, `next_due_at` und Countdown.
- Zeitplan und Kombination nutzen diese Due-Kommunikation.
- Faellige Stufen bleiben aktiv.
- Wartende Stufen koennen blockiert wirken.
- Die Anzeige basiert auf Due-/Blocked-Informationen, nicht nur auf Stage-Counts.

## 4. Replay-Datenpfad

- `LocalReplayCard` ist der gemeinsame Replay-Kartentyp.
- `LocalTimeReplayCard` bleibt als Kompatibilitaetspfad fuer bisherige Time-Nutzung erhalten.
- `localReplayCardsProvider` laedt Replay-Karten fuer einen `categoryId + mode`-Kontext.
- Der bisherige `localTimeReplayCardsProvider` delegiert auf den generalisierten Replay-Provider fuer `LearningMode.time`.
- Replay laedt Karten aus dem passenden lokalen `categoryId + mode + trainingArea`-Kontext.
- Completed-, answered-, done- und retry-Items koennen fuer Replay beruecksichtigt werden.
- Mehrere Sessions desselben letzten Lerntags koennen zusammengefuehrt werden.
- Doppelte `wordId`s durch Requeue oder Continuation werden fuer Replay bereinigt.
- Die Reihenfolge bleibt positions- und sessionsstabil.

## 5. Fachliche Abgrenzung

- Replay ist kein regulaeres SRS-Lernen.
- Replay ist freiwilliges Wiederholen ohne Einfluss auf Zeitplan oder Kombination.
- Replay laedt keine neuen S0-Karten.
- Replay oeffnet keine neuen SRS-Sessions.
- Replay schreibt keine normale Progression fort.
- Replay ist als Uebungsmodus fuer bereits gelernte Karten aus dem letzten relevanten Session-Kontext gedacht.

## 6. Tests

Relevante Testbereiche:

- `test/core/local_database/local_time_replay_cards_provider_test.dart`
- `test/features/learn_mode_screen_local_branch_test.dart`
- `test/features/category_detail_screen_local_branch_test.dart`
- `test/core/local_database/local_srs_mode_scenario_test.dart`
- `test/core/local_database/local_srs_session_service_test.dart`

Abgesichert sind insbesondere:

- Time-Replay funktioniert weiterhin.
- Hybrid/Kombination-Replay nutzt den eigenen Mode-Kontext.
- Replay laedt mehrere Karten aus relevanten Sessions.
- Completed Items werden nicht versehentlich ausgeschlossen.
- Replay-Swipe bleibt progress-neutral.
- Empty-State-Startbutton ist deaktiviert, Replay bleibt nutzbar.
- Replay-Kartenbereich enthaelt keine stoerende ScrollView.

## 7. Bewusst nicht geaendert

- Kein Limitlos-Umbau in diesem Block.
- Keine Supabase-Logik.
- Kein WordHub-Umbau.
- Kein grosses LearnMode- oder CategoryDetail-Redesign.
- Keine SRS-Regelaenderung ausser Replay-/Due-Kommunikation.
- Keine Alt-Code-Bereinigung.

## 8. Bekannte offene Punkte

- Replay-UI kann spaeter weiter verfeinert werden.
- Gezielt ueben bleibt separat auszugestalten.
- Analyzer-Alt-Warnungen in `learn_mode_screen.dart` bleiben ein separates Cleanup-Thema.
- Weitere Kategorieimporte und Mappings bleiben offen.

## 9. Naechster sinnvoller Schritt

- Entweder gezielt ueben finalisieren.
- Oder weitere Kategorien/Importe ausbauen.
- Oder Analyzer-/Alt-Code-Cleanup separat planen.
- Oder Replay/History visuell weiter verfeinern.
