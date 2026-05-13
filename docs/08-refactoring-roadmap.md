# 08 Refactoring Roadmap

Stand: 2026-05-13

## Leitprinzip

Kleine, prüfbare Schritte. Kein großer Umbau, solange SRS-Regeln, Datenmodell und Tests nicht stabil sind.

## Roadmap

### 1. Analyse abschließen

Ergebnis:

- Ist-Struktur dokumentiert
- Supabase-Abhängigkeiten bekannt
- SRS-Risiken sichtbar

Prüfung:

- Dokumente 01-12 geprüft
- offene Entscheidungen markiert

### 2. Supabase-Abhängigkeiten erfassen

Aufgaben:

- alle `supabase_flutter` Imports erfassen
- alle RPC-Namen katalogisieren
- alle Tabellen/Views katalogisieren
- Edge Functions bewerten

Prüfung:

- Liste vollständig
- jede Abhängigkeit hat lokalen Ersatzplan

### 3. SQLite-Zielmodell festlegen

Aufgaben:

- Tabellen finalisieren
- Primärschlüssel festlegen
- Indizes festlegen
- Seed-/Migrationpfad klären

Prüfung:

- Datenmodell deckt Wörter, Kategorien, Fortschritt, Reviews, Sessions, Settings ab

### 4. SRS-Regeln finalisieren

Aufgaben:

- Stufenbedeutung festlegen
- `pass_count`-Schwellen festlegen
- Intervalle festlegen
- Rückfälle festlegen
- S5-Verhalten festlegen
- `is_mastered` entscheiden

Prüfung:

- keine [ENTSCHEIDUNG NOTWENDIG] mehr in Kernregeln

### 5. Tests definieren

Aufgaben:

- natürliche Testfälle finalisieren
- Unit-Test-Struktur planen
- SQLite-Testdaten definieren

Prüfung:

- alle Regeln haben Testfall
- Grenzfälle sind enthalten

### 6. Alte Engine isolieren

Aufgaben:

- Repository-/Engine-Interfaces einziehen
- direkte Supabase-Imports aus UI schrittweise entfernen
- alte RPC-Engine als Legacy-Adapter belassen

Prüfung:

- UI spricht nicht mehr direkt mit Supabase
- Verhalten unverändert

### 7. Neue Engine implementieren

Aufgaben:

- reine Dart-Engine ohne Flutter/UI/SQLite
- Mode Policies
- Review Transition
- Queue Builder
- Session-Regeln

Prüfung:

- Unit-Tests grün
- theoretische Szenarien passen

### 8. UI an neue Modi anbinden

Aufgaben:

- drei einfache Modusbuttons
- Longpress entfernen
- Switch entfernen
- technische Begriffe ersetzen
- Trainingsbereiche umbenennen

Prüfung:

- UI verständlich ohne SRS-Fachbegriffe
- bestehende Screens bleiben strukturell erhalten

### 9. Supabase entfernen

Aufgaben:

- lokale Repositories aktivieren
- Supabase aus `main.dart` entfernen
- Edge Function Abhängigkeiten ersetzen/deaktivieren
- `supabase_flutter` entfernen

Prüfung:

- App startet offline
- `flutter analyze`
- relevante Tests

### 10. Launch-Vorbereitung

Aufgaben:

- Smoke Tests auf macOS/iOS/Android soweit relevant
- Seed-Daten prüfen
- leere Datenbank prüfen
- bestehende Datenbankmigration prüfen
- UI-Texte final prüfen

Prüfung:

- App ist ohne Netzwerk nutzbar
- Lernsession kann gestartet, geschlossen und fortgesetzt werden
- keine bekannten kritischen SRS-Lücken

