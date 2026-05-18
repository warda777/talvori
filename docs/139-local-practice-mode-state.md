# 139 Local Practice Mode State

## 1. Ausgangslage

CategoryDetail local hat im Bereich **Wiederholungsauswahl** die Buttons:

- Alle Stufen
- Einzelstufe

Ziel des Blocks war, diese Auswahl nicht nur visuell anzubieten, sondern als echten lokalen Übungsmodus nutzbar zu machen. Wichtig war dabei: Der Übungsmodus darf den normalen SRS-Fortschritt nicht verändern.

Stand nach Commit `5379f2c feat: add progress-neutral practice mode`.

## 2. Was ist der Übungsmodus?

Der Übungsmodus ist kein echter SRS-Lernmodus.

Er dient zum freien Wiederholen bereits gelernter Wörter und läuft progress-neutral. Er ist damit fachlich getrennt von:

- Zeitplan / T-SRS
- Limitlos / A-SRS
- Kombination / Hybrid

Swipes im Übungsmodus können die Karte bewegen und die Übungsrunde intern weiterzählen, schreiben aber keinen normalen Lernfortschritt.

## 3. Einstiege

### Alle Stufen

- nutzt Wörter aus S1-S5
- S0 wird nicht verwendet
- startet den Übungsmodus für alle vorhandenen Wiederholungsstufen
- ist für freie Wiederholung über mehrere Merkstufen gedacht

### Einzelstufe

- Nutzer wählt eine konkrete Stufe aus
- startet den Übungsmodus nur für diese Stufe
- wenn die gewählte Stufe keine Wörter enthält, erscheint ein Empty-State

## 4. Progress-Neutralität

Swipes im Übungsmodus ändern nicht:

- `stage`
- `pass_count`
- `wrong_count`
- `next_due_at`
- normale `review_history`
- CategoryDetail-Counts
- echte SRS-Sessions

Der Übungsmodus darf dadurch keine Zeitplan-, Limitlos- oder Kombinations-Progression beeinflussen.

## 5. UI

Der Übungsmodus hat eine eigene Cyan/Blau-Violett-Dark-Neon-Optik und ist klar vom normalen LearnMode getrennt.

Aktuell gilt:

- keine S0-S5-StageSwitches im Übungsmodus
- größere, fokussierte Karte
- eigener Übungsbereich statt normaler Stage-Anzeige
- Anzeige von `Übungsmodus`
- Anzeige von `Ohne Einfluss auf deinen Lernfortschritt`
- Anzeige von `Noch offen`
- Anzeige von `Geübt`
- Flip funktioniert
- Swipe funktioniert

Die Anzeige `Noch offen` / `Geübt` beschreibt nur den Fortschritt innerhalb der aktuellen Übungsrunde, nicht den echten SRS-Fortschritt.

## 6. Technische Bausteine

Zentrale Bausteine:

- `LocalPracticeCard`
- `localPracticeCardsProvider`
- Anpassungen im `CategoryDetailScreen`
- Anpassungen im `LearnModeScreen`
- `SwipeableWordCard` Practice-Styling
- `StageSwitchRow` Auswahlzustände für Alle Stufen / Einzelstufe

`localPracticeCardsProvider` lädt lokale Karten abhängig von Kategorie, Modus und Übungsauswahl. Die Daten kommen lokal und ohne Supabase-Zugriff.

## 7. Tests

Relevante Testbereiche:

- `test/core/local_database/local_practice_cards_provider_test.dart`
- `test/features/category_detail_screen_local_branch_test.dart`
- `test/features/learn_mode_screen_local_branch_test.dart`

Regression:

- `test/core/local_database/`
- `test/core/srs/`

Die Tests sichern unter anderem ab, dass der Übungsmodus Karten lädt, S0 bei Alle Stufen ausschließt, mode-/category-isoliert arbeitet und keine normalen SRS-Submit-Pfade nutzt.

## 8. Bewusst nicht geändert

- keine Supabase-Logik
- kein Online-Flow
- keine SRS-Regeln
- kein WordHub-Umbau
- keine echte Progression im Übungsmodus
- keine Alt-Code-Bereinigung

## 9. Bekannte offene Punkte

- UI-Feinschliff später möglich
- optionale separate Übungsstatistik später möglich
- bessere Animationen oder ein eigener Übungsabschluss können später ergänzt werden
- `Gezielt üben` kann als eigener Bereich fachlich weiter ausgebaut werden

## 10. Nächster sinnvoller Schritt

Sinnvolle nächste Richtungen:

- Simulator-Abnahme weiterführen
- weitere Kategorien importieren oder mappen
- `Gezielt üben` fachlich weiter ausarbeiten
- Analyzer-/Alt-Code-Cleanup separat planen
