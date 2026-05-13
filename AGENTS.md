# AGENTS.md

## Arbeitsregeln für Codex in Talvori

- Kein Code ohne vorherige Planung.
- Keine Änderung an der SRS-Engine, bevor die Theorie dokumentiert und geprüft ist.
- Keine Änderung an bestehendem App-Code im ersten Analyse-/Planungsschritt.
- Keine Supabase-Entfernung ohne vollständige Abhängigkeitsanalyse.
- Keine großen Umbauten in einem Schritt.
- Immer kleine, nachvollziehbare Änderungen.
- UI, Engine und Datenbank müssen getrennt bleiben.
- Flutter/Dart ist die einzige App-Technologie.
- Offline-first ist Pflicht.
- SQLite ist die geplante lokale Datenbank.
- Nach jeder späteren Codeänderung müssen `flutter analyze` und passende Tests berücksichtigt werden.
- Offene fachliche Fragen müssen mit `[ENTSCHEIDUNG NOTWENDIG]` markiert werden.
- Stabilität der Engine ist wichtiger als schnelle Umsetzung.
- Wenn eine Regel zu kompliziert wird, muss eine einfachere Alternative vorgeschlagen werden.

## Architekturregeln

- UI kennt keine Supabase-RPCs und keine Datenbankdetails.
- SRS-Engine bleibt reine Dart-Fachlogik ohne Flutter-Widgets.
- SQLite-Zugriff bleibt in der Data-Schicht.
- Controller koordinieren, aber enthalten keine schwer testbaren SRS-Regeln.
- Fortschritt wird pro `category_id + word_id + mode_id` getrennt gespeichert.
- Sessions werden persistent gespeichert und nach Neustart fortgesetzt.
- S5 ist kein endgültiges Verschwinden, sondern ein wiederholbarer Langzeitstatus.

## Sicherheitsregeln für Änderungen

- Bestehende App-Dateien nicht ohne explizite Freigabe ändern.
- Keine destruktiven Git- oder Dateisystembefehle ohne ausdrückliche Zustimmung.
- Keine Windows-spezifischen Annahmen; Arbeitsumgebung ist macOS mit Flutter/Dart.
- Bei Unsicherheit erst dokumentieren, nicht implementieren.

