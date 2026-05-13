# 13 Decision Overview

Stand: 2026-05-13

## Kurzfazit

Die Planung ist für den nächsten Schritt gut genug, aber noch nicht implementierungsreif. Stabil wirken vor allem die Grundinvarianten: offline-first, SQLite als lokale Quelle, persistente Sessions, getrennte Fortschritte pro Modus, Requeue nach Fehlern und S5 als wiederholbarer Langzeitstatus.

Weitere Kernentscheidungen sind getroffen: T-SRS- und Hybrid-Intervalle stehen für Version 1 fest, Intensiv lernen darf bei ausreichender Leistung am selben Tag bis S5 aufsteigen, T-SRS darf S1 am selben Tag nur festigen, die Fehlerquote-Regel ist festgelegt, Mehrfach-Requeue ist definiert, und Engine/Repository-Grenzen sowie das SQLite-Mindestmodell sind geklärt. Supabase-Datenmigration und DeepL/Wortimport sind zurückgestellt und blockieren die erste lokale Engine nicht.

Die Konsistenzregel für A-SRS ist ebenfalls festgelegt: A-SRS hat kein Tageslimit und darf am selben Tag bis S5 führen, aber eine einzelne Session bleibt technisch begrenzt. Neue Karten werden nicht endlos automatisch nachgeladen; nach Session-Ende entscheidet der Nutzer bewusst, ob weitergelernt wird.

## Muss vor Implementierung entschieden werden

Vor Implementierung bleiben keine fachlichen Kernregeln aus dieser Runde offen. Nächster Pflichtschritt ist, die entschiedenen Regeln in Testfälle und eine minimale Engine-Schnittstellenplanung zu übertragen.

## Kann während der Implementierung entschieden werden

### Fachliche Entscheidungen

- [ENTSCHEIDUNG NOTWENDIG] Darf `Gezielt üben` später gezielt S0 enthalten?
  - Für Version 1 führt Gezielt üben keine neuen S0-Karten in die normale SRS-Progression ein.

- [ENTSCHEIDUNG NOTWENDIG] Ob kleine Kategorien nach einer kurzen T-SRS-Session weitere neue Wörter anbieten dürfen.
  - Nicht kritisch für den Kern, aber relevant für Nutzergefühl.

### Technische Entscheidungen

- [ENTSCHEIDUNG NOTWENDIG] Ob `learning_modes` als SQLite-Tabelle oder als Dart-Konstante startet.
  - Empfehlung: zunächst Dart-Konstante, solange `mode_id` stabil bleibt.

- [ENTSCHEIDUNG NOTWENDIG] Wie alte große Dateien praktisch geschnitten werden.
  - Reihenfolge sollte erst nach stabilen Interfaces entschieden werden.

## Kann später nach dem Launch entschieden werden

- [ENTSCHEIDUNG NOTWENDIG] S0-S5 Kürzel komplett aus der UI entfernen oder klein zusätzlich anzeigen.
  - Empfehlung: für normale Nutzer ausblenden, intern weiter nutzen.

- [ENTSCHEIDUNG NOTWENDIG] Manuelle S5-Reaktivierung: nur `next_due_at = now` oder Rückstufung.
  - Empfehlung: `next_due_at = now`, keine künstliche Verschlechterung.

- [ENTSCHEIDUNG NOTWENDIG] Soll Fortschritt zwischen Kategorien geteilt werden, wenn dasselbe Wort in mehreren Kategorien vorkommt?
  - Empfehlung: nein, Fortschritt bleibt kategoriebasiert.

- [ENTSCHEIDUNG NOTWENDIG] Spätere Online-Sync- oder Cloud-Funktionen.
  - Für offline-first Launch nicht nötig.

- [ENTSCHEIDUNG NOTWENDIG] Erweiterte Statistiken aus `review_history`.
  - Kann nach stabiler Engine wachsen.

## Getroffene Entscheidungen

- `is_mastered` wird nicht als harter Engine-Zustand verwendet.
  - S5 bleibt der höchste aktive und wiederholbare Langzeitstatus.
  - Karten in S5 dürfen nicht aus der Wiederholung verschwinden.
  - `is_mastered` darf später höchstens Anzeige- oder Statistikfeld sein.

- S5 falsch fällt auf S3 zurück.
  - S4 wäre zu mild.
  - S0 wäre zu hart.

- **Gezielt üben** verändert in Version 1 keine normale SRS-Progression.
  - keine Änderung an `stage`
  - keine Änderung an `pass_count`
  - keine Änderung an `next_due_at`
  - keine Änderung am S5-Status
  - optionale separate Statistik bleibt später möglich

- T-SRS-Intervalle Version 1: S0 sofort/neu, S1 1 Tag, S2 3 Tage, S3 7 Tage, S4 14 Tage, S5 30 Tage.

- Hybrid-Intervalle Version 1: S0-S2 freier wie Intensiv lernen, S3 1 Tag, S4 3 Tage, S5 5 Tage.

- Intensiv lernen darf bei ausreichender Leistung am selben Tag bis S5 aufsteigen.

- T-SRS darf S1 am selben Tag erneut zur Festigung zeigen, aber ohne weiteren Aufstieg.

- Fehlerquote-Regel: ab 3 Fehlern in den letzten 10 Antworten keine neuen S0-Karten mehr automatisch in dieser Session.

- Mehrfach-Requeue: erster Fehler derselben Karte in derselben Session nach ca. 10 Karten, zweiter Fehler nach ca. 5 Karten, dritter Fehler als schwierig ans Session-Ende.

- Standard-Sessiongröße Version 1: 20 Karten; Nutzerwahl 10/20/40 bleibt spätere Option.

- Neue S0-Karten pro Session: T-SRS maximal 5, Hybrid maximal 8, A-SRS ohne Tageslimit, aber ohne unkontrollierten Auto-Nachschub.

- A-SRS-Weiterlernen ist eine bewusste Nutzerentscheidung nach Session-Ende oder über eine weitere A-SRS-Session.

- Engine/Repository-Grenze: Engine entscheidet Lernlogik; Repository speichert Daten.

- SQLite-Mindestmodell Version 1: `categories`, `words`, `word_progress`, `review_history`, `learning_sessions`, `session_items`, `settings`.

- Supabase-Datenmigration und DeepL/Wortimport werden zurückgestellt und blockieren die erste lokale Engine nicht.

## Aktuell blockierende Risiken

- Supabase enthält noch Geschäftslogik, nicht nur Datenzugriff.
- Die SRS-Regeln sind historisch auf Supabase-RPCs, Dart-Controller und UI-Kommentare verteilt.
- `learn_mode_controller.dart` und `supabase_word_repository.dart` sind zu groß für sichere Direktumbauten.
- Ohne persistierte Sessions wären Neustart und Abbruch manipulierbar.
- Ohne Review-Eventlog sind Fehler, Queue-Reihenfolge und Debugging schwer abzusichern.
- Ohne Testfälle für Queue, Sessions und Rückfälle ist die Engine nicht launchsicher.

## SRS-Regeln, die stabil wirken

- S0-S5 als einfache sechs Stufen.
- S5 ist wiederholbar und kein endgültiges Verschwinden.
- `is_mastered` entfernt keine Karten aus Wiederholung, Queue oder Engine.
- S5 falsch fällt auf S3 zurück.
- Gezielt üben verändert in Version 1 keine normale SRS-Progression.
- Fortschritt wird pro `category_id + word_id + mode_id` getrennt gespeichert.
- Trainingsbereich gehört in den Session-Schlüssel, aber nicht in den Fortschrittsschlüssel.
- `pass_count` steuert Aufstieg innerhalb einer Stufe.
- Höhere Stufen brauchen mehr richtige Antworten.
- Falsche Karten setzen `pass_count` zurück und bleiben in der Session.
- `retry_after_cards = 10`, bei weniger Karten ans Ende der Queue.
- Eine aktive Session pro Kategorie, Modus und Trainingsbereich.
- Nach jeder Antwort zuerst persistieren, dann UI aktualisieren.
- A-SRS hat kein hartes Tageslimit.
- A-SRS darf bei ausreichender Leistung am selben Tag bis S5 aufsteigen.
- T-SRS- und Hybrid-Intervalle sind für Version 1 festgelegt.
- T-SRS S1 darf am selben Tag festigen, aber nicht weiter aufsteigen.
- Fehlerquote und Mehrfach-Requeue sind festgelegt.
- Standard-Sessiongröße ist 20 Karten.
- Neue Karten pro Session sind für T-SRS und Hybrid begrenzt; A-SRS bleibt bewusst fortsetzbar, aber nicht automatisch endlos.
- T-SRS und Hybrid brauchen Tages-/Sessionlimits für neue Karten.
- Fällige Wiederholungen haben im Normalfall Vorrang vor neuen Karten.

## SRS-Regeln, die noch unsicher oder widersprüchlich wirken

- Hybrid-S5 alle 5 Tage kann bei großen Kategorien hohe Wiederholungslast erzeugen und muss simuliert werden.
- A-SRS kann viele Karten am selben Tag bis S5 bewegen; die Schutzwirkung der pass_count-Regel muss getestet werden.
- A-SRS-Weiterlernen muss in der UI später klar als bewusste Entscheidung erscheinen, nicht als automatischer Endlos-Refill.
- Rückfälle können S2 überfüllen; es braucht Tests, aber keine komplexen Kaskaden.

## Dokumente zuerst prüfen

1. `docs/04-srs-engine-theory.md`
   - wichtigste fachliche Engine-Regeln.

2. `docs/10-session-and-queue-rules.md`
   - Persistenz, Requeue, Manipulationsschutz.

3. `docs/05-new-card-distribution-strategy.md`
   - neue Karten, Tageslimits, Überlastung.

4. `docs/03-offline-first-sqlite-plan.md`
   - lokales Datenmodell.

5. `docs/02-supabase-removal-analysis.md`
   - technische Entfernung und Migrationsrisiken.

6. `docs/07-test-strategy.md`
   - natürliche Tests vor Code.

## Nächster kleinster sinnvoller Schritt

Der nächste kleinste sinnvolle Schritt ist, `docs/14-final-engine-rules-v1.md` als verbindliche Kurzspezifikation zu prüfen und danach die Testfälle aus `docs/07-test-strategy.md` gegen diese Regeln zu schärfen.

Erst danach ist ein minimales, reines Dart-SRS-Engine-Interface plus Testfallliste sinnvoll, noch ohne bestehende App-Dateien umzubauen.

## Erste 3 Entscheidungen

Die zuerst empfohlenen drei Entscheidungen wurden getroffen:

1. `is_mastered`: kein harter Engine-Zustand; S5 bleibt der wiederholbare Langzeitstatus.

2. S5 falsch: Rückfall auf S3, weil binäres falsch eine echte Instabilität signalisiert und S4 zu mild sein kann.

3. `Gezielt üben`: zunächst ohne normalen SRS-Aufstieg/Rückfall, damit Kern-SRS und Fokus-Training getrennt bleiben.

Als nächste Prüfaufgaben stehen jetzt an:

1. `docs/14-final-engine-rules-v1.md` gegen die gewünschte Produktlogik prüfen.

2. Testfälle in `docs/07-test-strategy.md` finalisieren.

3. Danach erst ein minimales Engine-Interface planen.
