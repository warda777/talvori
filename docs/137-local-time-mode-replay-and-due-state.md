# Lokaler Zeitplan-Modus, Replay und Faelligkeit

## 1. Ausgangslage

Der Modus Zeitplan / T-SRS war regeltechnisch bereits getestet. Im Simulator zeigte sich aber, dass der Empty-State bei nicht faelligen Karten und die Faelligkeit einzelner Woerter fuer Nutzer zu unklar waren.

Zusaetzlich sollte es moeglich sein, bereits gelernte Zeitplan-Karten freiwillig und progress-neutral zu wiederholen.

Relevanter Commit:

- `5572fdb feat: add time replay mode and due indicators`

## 2. Was neu ist

Neu im lokalen Zeitplan-Flow:

- klarer Zeitplan-Empty-State, wenn keine Karten faellig sind
- Meldung `Fuer heute sind keine Zeitplan-Karten faellig`
- Anzeige der naechsten Verfuegbarkeit / Countdown
- Button `Im Wiederholungsmodus ueben`
- lokaler Wiederholungsmodus ohne Einfluss auf den Zeitplan-Fortschritt
- Due-/Blocked-Indikatoren im CategoryDetail
- StageInspector mit Wartezeit, `next_due_at` und Countdown

Damit wirkt der Zeitplan-Modus nicht mehr wie ein leerer oder kaputter Lernmodus, wenn fachlich gerade keine Karten faellig sind.

## 3. Zeitplan-Tageslimit

Die Zeitplan-Regeln fuer neue Karten wurden geschaerft:

- Eine neue Kategorie darf im Zeitplan-Modus am ersten Tag maximal 20 neue S0-Karten einfuehren.
- Am selben ersten Tag gibt es keine zusaetzliche 5er-Nachladung.
- Danach werden neue Karten nach den normalen Zeitplan-Regeln eingefuehrt.
- Faellige Wiederholungen haben Vorrang vor neuen Karten.

Die Limitierung bezieht sich auf neue S0-Karten. Faellige Wiederholungskarten bleiben davon getrennt.

## 4. Wiederholungsmodus

Der Wiederholungsmodus ist ein lokaler, progress-neutraler Replay-Pfad fuer Zeitplan:

- Er laedt Karten aus der letzten lokalen Time-Session.
- Er nutzt keine neuen S0-Karten.
- Er erzeugt keinen normalen SRS-Fortschritt.
- Er schreibt keine regulaeren Zeitplan-Reviews.
- Er kann verlassen werden und zeigt danach wieder den Zeitplan-Empty-State.

Der Wiederholungsmodus veraendert nicht:

- `stage`
- `pass_count`
- `wrong_count`
- `next_due_at`

Er dient nur zum freiwilligen Ueben der zuletzt gelernten Zeitplan-Karten.

## 5. Due-/Blocked-Anzeige

CategoryDetail local kann im Zeitplan-Modus zeitlich blockierte Merkstufen sichtbar machen:

- Stufen mit wartenden, aber nicht faelligen Karten koennen rot / blockiert wirken.
- Faellige Stufen bleiben aktiv bzw. nicht blockiert.
- Die Anzeige basiert auf Due-Status, nicht nur auf Gesamtanzahl.

Der StageInspector zeigt dazu passend:

- Wartezeit der ausgewaehlten Merkstufe
- `next_due_at` pro Wort
- Countdown bis zur naechsten Faelligkeit
- `Jetzt faellig`, wenn ein Wort regulär verfuegbar ist

CategoryDetail und StageInspector nutzen damit dieselbe fachliche Idee: Karten koennen vorhanden sein, aber im Zeitplan gerade noch warten.

## 6. Neue zentrale Bausteine

Wichtige neue oder erweiterte Bausteine:

- `LocalStageDueSummary`
- `LocalTimeReplayCard`
- `localStageDueSummaryProvider`
- `localTimeReplayCardsProvider`
- Erweiterungen an `local_session_read_service`
- Erweiterungen an `local_srs_session_service`
- Erweiterungen an lokalen Repositories fuer Session-, Due- und Replay-Daten

Der Replay-Provider laedt gezielt die letzte lokale Time-Session mit echten Session-Items, damit eine spaetere leere Zeitplan-Session die zuletzt gelernten Karten nicht verdeckt.

## 7. Tests

Relevante Testdateien:

- `test/core/local_database/local_time_replay_cards_provider_test.dart`
- `test/core/local_database/local_srs_mode_scenario_test.dart`
- `test/features/learn_mode_screen_local_branch_test.dart`
- `test/features/category_detail_screen_local_branch_test.dart`
- `test/core/local_database/learning_session_repository_test.dart`

Abgedeckt sind u. a. Zeitplan-Tageslimit, Empty-State-Kommunikation, Replay-Karten aus der letzten Time-Session, progress-neutrales Replay-Verhalten und Due-/Blocked-Anzeigen.

## 8. Bewusst nicht geaendert

Nicht geaendert wurden:

- Limitlos / A-SRS
- Kombination / Hybrid
- Supabase-Logik
- WordHub
- grosses UI-Redesign
- regulaerer SRS-Fortschritt durch den Wiederholungsmodus

Der Wiederholungsmodus bleibt strikt progress-neutral.

## 9. Bekannte offene Punkte

- Der Wiederholungsmodus kann spaeter optisch weiter verfeinert werden.
- Gezielt ueben bleibt als eigener progress-neutraler Trainingsbereich noch separat auszugestalten.
- Analyzer-Alt-Warnungen in alten UI-Dateien bleiben ein separates Cleanup-Thema.

## 10. Naechster sinnvoller Schritt

Moegliche naechste Schritte:

- Simulator-Abnahme fuer Zeitplan wiederholen.
- Kombination / Hybrid separat pruefen.
- Gezielt ueben finalisieren.
- Weitere Kategorieimporte / Mappings ausbauen.
