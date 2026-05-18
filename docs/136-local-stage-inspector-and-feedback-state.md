# Lokaler Stage-Inspector und Feedback-Farben

## 1. Ausgangslage

Der lokale LearnMode und der lokale CategoryDetailScreen funktionieren im End-to-End-Flow. Stage-Counts, Plasma-Link und Pulse beim Swipe waren bereits vorhanden.

Ziel des Blocks war, Merkstufen interaktiv pruefbar zu machen und die Review-Feedback-Farben fachlich klarer darzustellen.

Relevanter Commit:

- `71047c2 feat: add local stage inspector and feedback colors`

## 2. Was neu ist

Neu ist ein gemeinsamer lokaler Stage-Inspector fuer Merkstufen:

- `StageInspectorSheet` fuer CategoryDetail local und LearnMode local
- Tap auf eine Merkstufe oeffnet die Detailansicht
- farbiges Review-/Pulse-Feedback nach Swipe
- Stage-Switches leuchten waehrend des Bounce kurz in der Feedback-Farbe auf
- manuelle Rueckstufung von Woertern innerhalb einer Kategorie und eines Modus

Die Rueckstufung ist bewusst nur nach unten moeglich.

## 3. Neue zentrale Bausteine

Wichtige neue oder erweiterte Bausteine:

- `LocalReviewVisualFeedback`
- `LocalStageInspectorItem`
- `localStageInspectorProvider`
- `localStageAdjustmentControllerProvider`
- `localStageCountsProvider`
- `localCategoryProgressResetProvider`
- `LocalStageInspectorSheet`
- `localLearningModeMapper`

## 4. Feedback-Farben

Die Farben sind fachlich codiert:

- gruen = hochgestuft
- rot = falsch / zurueckgestuft
- cyan/blau = Wiederholung innerhalb derselben Stufe, z. B. 1. Wiederholung
- violett = weitere Wiederholung
- orange/amber = weitere Wiederholung, falls relevant

Der aeussere Pulse und der betroffene Stage-Switch verwenden dieselbe Farbe. Der Switch leuchtet nur waehrend des Bounce temporaer auf und kehrt danach in seine normale dunkle Optik zurueck.

## 5. StageInspectorSheet

Das Sheet zeigt fuer eine ausgewaehlte Merkstufe:

- Stage-Titel, z. B. `Merkstufe 2`
- Anzahl der Woerter in dieser Stufe
- Legende / Farbkodex
- Wortliste mit Term und Uebersetzung
- `passCount` / `wrongCount`
- letzter Review-Status, soweit vorhanden
- Rueckstufungsaktionen fuer einzelne Woerter

Der Inhalt ist lokal, scroll-bar und fuer den Dark-Neon-Stil vorbereitet.

## 6. Manuelle Rueckstufung

Regeln der manuellen Rueckstufung:

- nur nach unten
- niemals nach oben
- nicht unter S0
- category-/mode-isoliert
- `passCount` wird zurueckgesetzt
- `wrongCount` bleibt erhalten
- Stage-Counts aktualisieren sich danach
- keine Supabase-Logik

Die Rueckstufung veraendert nur das ausgewaehlte Wort in der aktuellen Kategorie und im aktuellen Modus.

## 7. Integration in Screens

CategoryDetail local:

- Tap auf eine Merkstufe oeffnet `LocalStageInspectorSheet`.
- Das Sheet nutzt `selectedCategoryId` und den aktuell ausgewaehlten Lernmodus.
- Nach Rueckstufung aktualisieren sich die Stage-Counts.

LearnMode local:

- Tap auf eine Merkstufe oeffnet dasselbe Sheet.
- Swipe erzeugt `LocalReviewVisualFeedback`.
- Der Pulse nutzt die Feedback-Farbe.
- Der betroffene Switch leuchtet waehrend des Bounce temporaer in derselben Farbe.
- Plasma-Link bleibt weiter aktiv.

## 8. Tests

Relevante Testbereiche:

- `test/core/local_database/local_stage_inspector_provider_test.dart`
- `test/features/category_detail_screen_local_branch_test.dart`
- `test/features/learn_mode_screen_local_branch_test.dart`
- lokale DB-/SRS-Tests unter `test/core/local_database/`
- Core-SRS-Tests unter `test/core/srs/`

Abgedeckt sind u. a. Inspector-Daten, category-/mode-isolierte Rueckstufung, Stage-Inspector-Oeffnung in beiden lokalen Screens und farbiges Pulse-Feedback im LearnMode.

## 9. Bewusst nicht geaendert

Nicht geaendert wurden:

- Online-Flow
- Supabase-Logik
- WordHub
- CategoryDetail-/LearnMode-Layout oder Redesign
- manuelle Hochstufung
- Alt-Code-Bereinigung

## 10. Offene Punkte

- UI-Feinschliff des Inspector-Sheets ist spaeter moeglich.
- Weitere Status-/Historydaten koennen spaeter ergaenzt werden.
- Review-History kann spaeter staerker visualisiert werden.
- Analyzer-Alt-Warnungen in alten UI-Dateien bleiben ein separates Cleanup-Thema.

## 11. Naechster sinnvoller Schritt

Moegliche naechste Schritte:

- Simulator-Abnahme weiterfuehren.
- Weitere Kategorien / Import ausbauen.
- Review-History-Visualisierung planen.
- Gezielt ueben finalisieren.
- Analyzer-/Alt-Code-Cleanup separat planen.
